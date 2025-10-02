parser.add_argument(
    "--version_notes",
    default="Initial onboarding via automation",
    help="Notes to set on the newly created configuration version (default: 'Initial onboarding via automation')."
)

---------------------------------------------------------------------------
def set_config_version_notes(session, base_url, config_id, version, notes: str) -> bool:
    """
    Sets the 'Version Notes' for a given security configuration version.
    We try PATCH first (partial update), then fall back to PUT with a minimal body.
    """
    if not notes:
        return True  # nothing to do

    endpoint = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}"
    payload = {"notes": notes}

    try:
        # Prefer PATCH (partial update)
        resp = session.patch(endpoint, json=payload)
        if resp.status_code in (200, 201):
            print(f"[SUCCESS] Set version notes on config {config_id} v{version}.")
            return True
        # Fallback to PUT (some tenants require PUT)
        resp = session.put(endpoint, json=payload)
        if resp.status_code in (200, 201):
            print(f"[SUCCESS] Set version notes on config {config_id} v{version}.")
            return True

        print(f"[WARN] Unable to set version notes (status={resp.status_code}): {resp.text}")
        return False

    except Exception as e:
        print(f"[ERROR] Failed to set version notes: {e}")
        return False

-----------------------------------------------------

In main(), immediately after config_id = create_security_config(...) succeeds, call:


# Set version notes on v1 
set_config_version_notes(session, base_url, config_id, 1, args.version_notes)

------------------------------------------------------------------------------------------------------
update fqd hostnames to Config after prod policy created

def _get_config_hostnames(session, base_url, config_id, version):
    """
    Returns the current hostname list for a config version.
    Tries the dedicated /hostnames endpoint first, then falls back to the version doc.
    """
    host_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/hostnames"
    try:
        r = session.get(host_url)
        if r.status_code == 200:
            return r.json().get("hostnames", [])
    except Exception:
        pass  # fall back below

    # Fallback to reading the version document (some tenants)
    ver_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}"
    r = session.get(ver_url)
    r.raise_for_status()
    return r.json().get("hostnames", [])


def _set_config_hostnames(session, base_url, config_id, version, hostnames):
    """
    Writes the hostname list to the config version. Uses the dedicated endpoint,
    and falls back to PUT on the version if needed.
    """
    payload = {"hostnames": hostnames}

    # Prefer the dedicated endpoint
    host_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/hostnames"
    r = session.put(host_url, json=payload)
    if r.status_code in (200, 201, 204):
        return True

    # Fallback to updating the version doc
    ver_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}"
    r = session.put(ver_url, json=payload)
    return r.status_code in (200, 201)


def update_config_hostnames_with_fqdns(session, base_url, config_id, version, additional_fqdns):
    """
    Ensures the config version's 'Hostnames currently associated with this configuration'
    includes the provided FQDNs. No-op if already present.
    """
    try:
        current = set(_get_config_hostnames(session, base_url, config_id, version))
        target = current | set(additional_fqdns or [])
        if target == current:
            print("[INFO] Config hostnames already include provided FQDNs; no update needed.")
            return True

        ok = _set_config_hostnames(session, base_url, config_id, version, sorted(target))
        if ok:
            print(f"[SUCCESS] Updated config {config_id} v{version} hostnames: {sorted(target)}")
            return True

        print("[WARN] Failed to update config hostnames (non-200 response).")
        return False

    except Exception as e:
        print(f"[ERROR] Unable to update config hostnames: {e}")
        return False


2) Call it right after creating a brand-new config (Non-Prod flow)

In main(), immediately after:
config_id = create_security_config(
    session,
    base_url,
    config_name,
    region_data["group_id"],
    region_data["contract_id"],
    template_config_id,
    fqdn_list
)
add:
# Belt & braces: ensure v1 has the Non-Prod FQDNs recorded
update_config_hostnames_with_fqdns(session, base_url, config_id, args.template_version, fqdn_list)


(If template_version is your new config’s version number; if you always create v1, that’s correct.)

3) Call it after creating Prod policy & cloning its match targets

At the end of onboard_prod_policy(...), after match_target_result:
# Belt & braces: ensure the config version also lists the Prod FQDNs
update_config_hostnames_with_fqdns(session, base_url, config_id, version, fqdn_list)

That’s it. With these two calls, the “Hostnames currently associated with this configuration” panel will always show the union of Non-Prod and Prod FQDNs, regardless of creation order or UI auto-updates.


---------------------------------------------------------------------------
Updated Bypass lists DoS function
Perfect—here’s a drop-in replacement for your original reassign_dos_protection_rate_policies that keeps all the cloning logic and fixes the DoS “NetworkListCondition” to use the cloned SC-<access_group> … bypass lists (instead of the template list). It also scrubs read-only fields before PUT.

def reassign_dos_protection_rate_policies(
    session,
    base_url,
    config_id,
    version,
    access_group,
    template_policy_name_prefix="Security Policy Template",
    target_policy_id: str | None = None,   # optional: only fix policies attached to this security policy
    activate_clones: bool = True,          # keep your staging activation behavior
):
    """
    1) For every DoS rate policy attached to this config/version:
       - If its name starts with the template prefix, clone it to 'SC-<access_group> <suffix>'.
       - Otherwise keep the existing policy id.
    2) For each kept/cloned policy, rewrite additionalMatchOptions/NetworkListCondition
       values so that any template client list names/ids are replaced by the
       corresponding 'SC-<access_group> …' client list (if found).
    3) PUT the cleaned policy back, then update the config's dos-rates assignment list.
    """
    list_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/dos-rates"
    clone_url = f"{base_url}/appsec/v1/rate-policies/clone"
    policy_url_template = f"{base_url}/appsec/v1/rate-policies/{{policy_id}}"

    summary = {"processed": 0, "successful": 0, "failed": 0, "fixed_conditions": 0, "details": []}

    # helper: resolve the cloned client-list id from either a template-like name or any name fragment
    def _resolve_client_list_id_from_name(name: str) -> str | None:
        # if it looks like a template list name, derive the expected SC- name
        expected = name
        if "Security Policy Template" in name:
            suffix = name.split("Security Policy Template", 1)[-1].strip()
            expected = f"SC-{access_group} {suffix}".strip()

        # try to find a client list whose *name* contains/equals the expected
        matches = search_client_lists_by_name(session, base_url, expected)
        return matches[0][0] if matches else None  # (listId, name) -> listId

    try:
        # 1) Read the assignment list
        resp = session.get(list_url)
        resp.raise_for_status()
        policies = resp.json().get("ratePolicies", [])
        updated_assignments: list[str] = []

        for p in policies:
            summary["processed"] += 1
            orig_name = p.get("name", "")
            orig_id = p.get("id")

            # decide which policy id we will keep (clone or original)
            kept_id = orig_id
            kept_name = orig_name

            # clone if it looks like a template copy
            if orig_name.startswith(template_policy_name_prefix):
                suffix = orig_name.replace(template_policy_name_prefix, "").strip()
                clone_name = f"SC-{access_group} {suffix}".strip()

                # if a policy with clone_name already exists in the assignment list, reuse it
                existing = next((rp for rp in policies if rp.get("name") == clone_name), None)
                if existing:
                    kept_id = existing.get("id")
                    kept_name = clone_name
                else:
                    try:
                        clone_payload = {
                            "cloneFromRatePolicyId": orig_id,
                            "name": clone_name,
                            "description": f"Cloned from {orig_name}",
                            "matchType": p.get("matchType"),
                        }
                        c = session.post(clone_url, json=clone_payload)
                        c.raise_for_status()
                        kept_id = c.json().get("id")
                        kept_name = clone_name

                        if activate_clones and kept_id:
                            act = session.post(policy_url_template.format(policy_id=kept_id) + "/activate",
                                               json={"network": "STAGING"})
                            # don't fail build on activation errors; it's best-effort
                        summary["successful"] += 1
                        summary["details"].append({"template": orig_name, "clone": kept_name, "status": "success"})
                    except Exception as clone_err:
                        # fallback to the original template policy id
                        kept_id = orig_id
                        kept_name = orig_name
                        summary["failed"] += 1
                        summary["details"].append(
                            {"template": orig_name, "status": "clone_failed", "error": str(clone_err)}
                        )

            # 2) Fix NetworkListCondition for the kept policy (cloned or original)
            try:
                # fetch full policy
                d = session.get(policy_url_template.format(policy_id=kept_id))
                d.raise_for_status()
                full = d.json()

                # optional: only touch policies attached to a specific security policy
                if target_policy_id and full.get("policyId") != target_policy_id:
                    updated_assignments.append(kept_id)
                    continue

                changed = False
                for opt in full.get("additionalMatchOptions", []):
                    if opt.get("type") != "NetworkListCondition":
                        continue
                    new_vals = []
                    for v in opt.get("values", []):
                        v_str = str(v)

                        # if appears numeric (already an id), keep as-is
                        if v_str.isdigit():
                            new_vals.append(v)
                            continue

                        # treat as a name and try to resolve it to the SC- list id
                        resolved = _resolve_client_list_id_from_name(v_str)
                        new_vals.append(resolved if resolved else v)  # fall back to original if not found
                        if resolved and resolved != v:
                            changed = True

                    if changed:
                        opt["values"] = new_vals

                # scrub read-only fields before PUT
                for ro in ("id", "updateDate", "used"):
                    full.pop(ro, None)

                if changed:
                    u = session.put(policy_url_template.format(policy_id=kept_id), json=full)
                    u.raise_for_status()
                    summary["fixed_conditions"] += 1

                updated_assignments.append(kept_id)

            except Exception as fix_err:
                summary["failed"] += 1
                summary["details"].append(
                    {"id": kept_id, "name": kept_name, "status": "update_failed", "error": str(fix_err)}
                )
                # still keep this policy in the assignment list to avoid breaking the config
                updated_assignments.append(kept_id)

        # 3) Replace the assignment list in the config
        try:
            put_resp = session.put(list_url, json={"ratePolicies": updated_assignments})
            put_resp.raise_for_status()
        except Exception as assign_err:
            summary["failed"] += 1
            summary["details"].append({"status": "assign_failed", "error": str(assign_err)})

    except Exception as e:
        summary["failed"] += 1
        summary["details"].append({"status": "failed", "error": str(e)})

    return summary



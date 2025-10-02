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




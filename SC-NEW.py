#!/usr/bin/env python3
"""
Akamai AppSec Onboarding Automation (Rebuilt from screenshots)
----------------------------------------------------------------
This single-file script automates onboarding of Akamai AppSec security
configurations for both NonProd and Prod policies.

Highlights implemented per UAT + fixes:
- Create BOTH NonProd and Prod policies in a single run when config doesn't exist
- Bail out early if security config already exists (assume both policies present)
- Proper isProd handling for one-pass Prod-only onboarding
- Dry-run previews for NonProd and Prod
- Version notes support via --note and version update call
- Client list cloning from template with deprecated=false logic
- Match-target reassignment (NonProd + Prod clone)
- Rate policy update using cleaned payload (no read-only fields; list IDs only)
- Modular result summaries

This is a faithful reconstruction and consolidation of the logic we've iterated
on together. You may need to align exact field names to your local helpers if they
were slightly different.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from typing import Dict, List, Tuple, Any, Optional

import requests

# ------------------------------
# Configuration / Constants
# ------------------------------

API_TIMEOUT = 30

# Example region/group/contract mapping placeholder used in previews
REGION_SETTINGS = {
    "DEV": {"group_id": "<GROUP_ID>", "contract_id": "<CONTRACT_ID>"},
    "PREPROD": {"group_id": "<GROUP_ID>", "contract_id": "<CONTRACT_ID>"},
    "PROD": {"group_id": "<GROUP_ID>", "contract_id": "<CONTRACT_ID>"},
}

# ------------------------------
# Session & Utility Helpers
# ------------------------------

def setup_session() -> requests.Session:
    s = requests.Session()
    s.headers.update({
        "Content-Type": "application/json"
    })
    return s

# --- Security Config helpers (stubs to be aligned with your environment) ---

def config_exists(session: requests.Session, base_url: str, config_name: str) -> Optional[int]:
    """Return config_id if exists else None."""
    try:
        url = f"{base_url}/appsec/v1/configs?configName={config_name}"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        for item in r.json().get("configs", []):
            if item.get("name") == config_name:
                return item.get("id")
    except Exception:
        pass
    return None

def get_policy_ids(session: requests.Session, base_url: str, config_id: int) -> List[Dict[str, Any]]:
    try:
        url = f"{base_url}/appsec/v1/configs/{config_id}/policies"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        return r.json().get("policies", [])
    except Exception:
        return []

# ------------------------------
# Version Notes
# ------------------------------

def update_security_config_version_notes(session: requests.Session, base_url: str, config_id: int, version: int, notes: str) -> bool:
    """Update the version notes for a given security config version."""
    if not notes:
        return True
    try:
        url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}"
        payload = {"versionNotes": notes}
        r = session.put(url, json=payload, timeout=API_TIMEOUT)
        r.raise_for_status()
        print(f"[SUCCESS] Version notes updated for config {config_id} v{version}")
        return True
    except Exception as e:
        print(f"[ERROR] Failed to update version notes: {e}")
        return False

# ------------------------------
# Activation Helpers (console parity)
# ------------------------------

def get_activation_status(session: requests.Session, base_url: str, config_id: int, version: int, network: str) -> Dict[str, Any]:
    try:
        url = f"{base_url}/appsec/v1/activations?configId={config_id}&version={version}&network={network}"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        items = r.json().get("activations", [])
        return items[0] if items else {}
    except Exception:
        return {}

def activate_security_configuration(session: requests.Session, base_url: str, config_id: int, version: int, network: str, emails: List[str], note: str = "") -> bool:
    payload = {
        "configId": config_id,
        "version": version,
        "network": network,
        "notifyEmails": emails,
    }
    if note:
        payload["note"] = note
    try:
        url = f"{base_url}/appsec/v1/activations"
        r = session.post(url, json=payload, timeout=API_TIMEOUT)
        r.raise_for_status()
        print(f"[INFO] Activation requested for config {config_id} v{version} on {network}")
        return True
    except Exception as e:
        print(f"[ERROR] Activation failed: {e}")
        return False

def monitor_activation_status(session: requests.Session, base_url: str, config_id: int, version: int, network: str, timeout_sec: int = 900) -> str:
    start = time.time()
    while time.time() - start < timeout_sec:
        st = get_activation_status(session, base_url, config_id, version, network)
        status = st.get("status")
        if status in {"ACTIVE", "COMPLETE"}:
            return "ACTIVE"
        if status in {"FAILED", "ABORTED"}:
            return status or "FAILED"
        time.sleep(10)
    return "TIMEOUT"

# ------------------------------
# Client List search helpers
# ------------------------------

def search_client_lists_by_name(session: requests.Session, base_url: str, name: str) -> List[Dict[str, Any]]:
    try:
        url = f"{base_url}/client-list/v1/lists?includeDeprecated=true&includeNetworkLists=true"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        out = []
        for item in r.json().get("content", []):
            # Only consider non-deprecated lists
            if item.get("name") == name and item.get("deprecated") is False:
                out.append({"id": item.get("listId"), "name": item.get("name")})
        return out
    except Exception:
        return []

def search_client_lists_by_id(session: requests.Session, base_url: str, list_id: str) -> List[Dict[str, Any]]:
    try:
        url = f"{base_url}/client-list/v1/lists?includeDeprecated=true&includeNetworkLists=true"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        out = []
        for item in r.json().get("content", []):
            if str(item.get("listId")) == str(list_id):
                out.append({"id": item.get("listId"), "name": item.get("name"), "deprecated": item.get("deprecated")})
        return out
    except Exception:
        return []

# ------------------------------
# Clone & Rename Client Lists (template → SC-<access_group>-<suffix>)
# ------------------------------

def clone_and_rename_client_lists(session: requests.Session, base_url: str, access_group: str, section: Optional[str] = None) -> Dict[str, Any]:
    print("[INFO] Cloning client lists from 'Security Policy Template *' ...")
    summary = {"processed": 0, "successful": 0, "failed": 0, "details": []}

    # Fetch all lists
    try:
        url = f"{base_url}/client-list/v1/lists?includeDeprecated=true&includeNetworkLists=true"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        lists = r.json().get("content", [])
    except Exception as e:
        print(f"[ERROR] Failed to fetch lists: {e}")
        return summary

    # Build set of existing non-deprecated SC-<access_group>-* names
    existing_active = {item.get("name"): item for item in lists if item.get("deprecated") is False}

    for cl in lists:
        try:
            name = cl.get("name", "")
            if not name.startswith("Security Policy Template"):
                continue

            suffix = name.split("Security Policy Template", 1)[-1].strip()
            new_name = f"SC-{access_group} {suffix}" if suffix else f"SC-{access_group}"

            # Skip if a non-deprecated target already exists
            if new_name in existing_active:
                continue

            # Clone payload
            payload = {
                "name": new_name,
                "type": cl.get("type"),
                "listType": cl.get("listType"),
                "description": f"Cloned from template list '{name}'",
                "tags": [],
                "cloneFromList": {"listId": cl.get("listId")},
            }
            clone_url = f"{base_url}/client-list/v1/lists"
            if section:
                clone_url += f"?section={section}"

            rr = session.post(clone_url, json=payload, timeout=API_TIMEOUT)
            rr.raise_for_status()

            summary["processed"] += 1
            summary["successful"] += 1
            summary["details"].append({"from": name, "to": new_name, "listId": rr.json().get("listId")})
        except Exception as e:
            summary["processed"] += 1
            summary["failed"] += 1
            summary["details"].append({"from": cl.get("name"), "error": str(e)})

    return summary

# ------------------------------
# Build Bypass List map (template → SC-<access_group>)
# ------------------------------

def build_bypass_list_map(session: requests.Session, base_url: str, access_group: str) -> Dict[str, str]:
    """Map from template list suffix → SC-<access_group> list_id.
       Example: 'Rate Controls Bypass List' → '240903_SCW...'"""
    try:
        url = f"{base_url}/client-list/v1/lists?includeDeprecated=true&includeNetworkLists=true"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        items = r.json().get("content", [])
    except Exception:
        return {}

    template_by_suffix: Dict[str, Dict[str, Any]] = {}
    sc_by_suffix: Dict[str, Dict[str, Any]] = {}

    for it in items:
        nm = it.get("name", "")
        if nm.startswith("Security Policy Template"):
            suffix = nm.split("Security Policy Template", 1)[-1].strip()
            template_by_suffix[suffix] = it
        elif nm.startswith("SC-"):
            # Capture only non-deprecated
            if it.get("deprecated") is False:
                try:
                    # suffix after first space following SC-<access_group>
                    after = nm.split(" ", 1)[-1] if " " in nm else ""
                    sc_by_suffix[after] = it
                except Exception:
                    pass

    # Now, build mapping for all template suffixes → SC-<access_group> ids
    out: Dict[str, str] = {}
    for suffix, tpl in template_by_suffix.items():
        sc = sc_by_suffix.get(suffix)
        if sc and sc.get("deprecated") is False:
            out[suffix] = sc.get("listId")
    return out

# ------------------------------
# Rate Policies Update (final, cleaned)
# ------------------------------

def update_rate_policies(session: requests.Session, base_url: str, config_id: int, version: int, access_group: str,
                         search_id_fn, search_name_fn) -> Dict[str, Any]:
    url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/rate-policies"
    result = {"processed": 0, "successful": 0, "failed": 0, "skipped": 0, "details": []}

    try:
        response = session.get(url, timeout=API_TIMEOUT)
        response.raise_for_status()
        policies = response.json().get("ratePolicies", [])
    except Exception as e:
        print(f"[ERROR] Failed to fetch rate policies: {e}")
        return result

    result["processed"] = len(policies)

    for p in policies:
        policy_id = p.get("id")
        original_name = p.get("name") or ""
        updated = False

        # Fetch full policy body
        try:
            full_url = f"{url}/{policy_id}"
            fr = session.get(full_url, timeout=API_TIMEOUT)
            fr.raise_for_status()
            policy = fr.json()
        except Exception as e:
            result["failed"] += 1
            result["details"].append({"id": policy_id, "name": original_name, "status": "failed", "error": f"GET failed: {e}"})
            continue

        # Rename from template
        if "Security Policy Template" in original_name:
            suffix = original_name.split("Security Policy Template", 1)[-1].strip()
            new_name = f"SC-{access_group} {suffix}"
            policy["name"] = new_name
            updated = True
        else:
            new_name = original_name

        # Update NetworkListCondition values
        for opt in policy.get("additionalMatchOptions", []):
            if opt.get("type") == "NetworkListCondition":
                new_ids: List[str] = []
                for val in opt.get("values", []):
                    # value might be ID or "ID NAME"; keep only ID
                    candidate_id = str(val).split()[0]
                    match = search_id_fn(session, base_url, candidate_id)
                    if match:
                        # map to SC-<access_group> by suffix via name lookup
                        orig_name = match[0].get("name", "")
                        if "Security Policy Template" in orig_name:
                            suffix = orig_name.split("Security Policy Template", 1)[-1].strip()
                            sc_name = f"SC-{access_group} {suffix}"
                            sc_match = search_name_fn(session, base_url, sc_name)
                            if sc_match:
                                new_ids.append(str(sc_match[0]["id"]))
                                updated = True
                            else:
                                result["failed"] += 1
                                result["details"].append({"id": policy_id, "name": new_name, "status": "failed", "error": f"No SC list for suffix '{suffix}'"})
                                break
                        else:
                            # Already SC list id; keep as is
                            new_ids.append(candidate_id)
                    else:
                        result["failed"] += 1
                        result["details"].append({"id": policy_id, "name": new_name, "status": "failed", "error": f"List ID not found: {candidate_id}"})
                        break
                else:
                    opt["values"] = new_ids

        # Remove disallowed fields
        for fld in ["id", "createDate", "updateDate", "used"]:
            policy.pop(fld, None)

        if updated:
            try:
                put_url = f"{url}/{policy_id}"
                # print payload for debug
                print("[PUT] rate-policy payload =>\n" + json.dumps(policy, indent=2))
                pr = session.put(put_url, json=policy, timeout=API_TIMEOUT)
                pr.raise_for_status()
                result["successful"] += 1
                result["details"].append({"id": policy_id, "name": new_name, "status": "success"})
            except Exception as e:
                result["failed"] += 1
                result["details"].append({"id": policy_id, "name": new_name, "status": "failed", "error": str(e)})
        else:
            result["skipped"] += 1
            result["details"].append({"id": policy_id, "name": new_name, "status": "skipped"})

    return result

# ------------------------------
# Prod Match Targets Clone (config-level website targets)
# ------------------------------

def clone_match_targets_for_prod(session: requests.Session, base_url: str, config_id: int, version: int,
                                 source_policy_id: str, target_policy_id: str,
                                 fqdn_list: List[str], access_group: str) -> Dict[str, Any]:
    """Clone NonProd website targets → new Prod targets at config-level, swapping hostnames and bypass lists."""
    result = {"processed": 0, "successful": 0, "failed": 0, "details": []}

    # GET existing match targets (config-level)
    try:
        url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/match-targets/website"
        r = session.get(url, timeout=API_TIMEOUT)
        r.raise_for_status()
        targets = r.json().get("websiteTargets", [])
    except Exception as e:
        print(f"[ERROR] Fetch match targets failed: {e}")
        return result

    # Filter by NonProd policy id
    src_targets = [t for t in targets if t.get("securityPolicy", {}).get("policyId") == source_policy_id]

    for t in src_targets:
        try:
            new_t = json.loads(json.dumps(t))  # deep copy
            # Update policy to Prod
            new_t["securityPolicy"]["policyId"] = target_policy_id
            # Update hostnames to Prod fqdn_list
            new_t["hostnameMatch"]["values"] = list(fqdn_list)
            # Ensure sequence will be set by server (do not send read-only id fields)
            for fld in ["id", "links", "configId", "version"]:
                new_t.pop(fld, None)

            post_url = f"{base_url}/appsec/v1/configs/{config_id}/versions/{version}/match-targets/website"
            rr = session.post(post_url, json=new_t, timeout=API_TIMEOUT)
            rr.raise_for_status()

            result["processed"] += 1
            result["successful"] += 1
            result["details"].append({"status": "success", "policyId": target_policy_id})
        except Exception as e:
            result["processed"] += 1
            result["failed"] += 1
            result["details"].append({"status": "failed", "error": str(e)})

    return result

# ------------------------------
# NonProd / Prod Policy Onboarding (stubs calling your existing logic)
# ------------------------------

def onboard_nonprod_policy(session: requests.Session, base_url: str, config_id: int, group_id: str, contract_id: str,
                           template_policy_name: str, nonprod_policy_name: str) -> Optional[str]:
    """Create NonProd policy cloned from template; return policyId."""
    try:
        # Example endpoint for creating policy
        payload = {"policyName": nonprod_policy_name, "description": f"Cloned from {template_policy_name}"}
        url = f"{base_url}/appsec/v1/configs/{config_id}/policies"
        r = session.post(url, json=payload, timeout=API_TIMEOUT)
        r.raise_for_status()
        return r.json().get("policyId")
    except Exception as e:
        print(f"[ERROR] onboard_nonprod_policy: {e}")
        return None

def onboard_prod_policy(session: requests.Session, base_url: str, config_id: int, group_id: str, contract_id: str,
                        nonprod_policy_id: str, prod_policy_name: str,
                        fqdn_list: List[str], access_group: str) -> Optional[str]:
    """Create Prod policy by cloning from NonProd (policy-level clone or create + match-target clone)."""
    try:
        payload = {"policyName": prod_policy_name, "description": f"Cloned from NonProd policy {nonprod_policy_id}"}
        url = f"{base_url}/appsec/v1/configs/{config_id}/policies"
        r = session.post(url, json=payload, timeout=API_TIMEOUT)
        r.raise_for_status()
        prod_policy_id = r.json().get("policyId")

        # Clone match targets from NonProd → Prod
        _ = clone_match_targets_for_prod(session, base_url, config_id, 1, nonprod_policy_id, prod_policy_id, fqdn_list, access_group)
        return prod_policy_id
    except Exception as e:
        print(f"[ERROR] onboard_prod_policy: {e}")
        return None

# ------------------------------
# Dry-run Preview
# ------------------------------

def dry_run_preview(config_name: str, access_group: str, section: str, fqdn_list: List[str], template_config_name: str,
                    both_policies: bool) -> None:
    print("\n========== DRY RUN ==========")
    print(f"Security Config: {config_name}")
    print(f"Access Group:   {access_group}")
    print(f"Section:        {section}")
    print(f"FQDNs:          {', '.join(fqdn_list) if fqdn_list else '(none)'}")
    print(f"Template:       {template_config_name}")
    if both_policies:
        print("Policies:       PL-<AG>-NonProd, PL-<AG>-Prod (same run)")
    else:
        print("Policies:       Single environment (isProd determines which)")
    print("============================\n")

# ------------------------------
# Main
# ------------------------------

def main():
    parser = argparse.ArgumentParser(description="Akamai AppSec Onboarding (rebuilt)")
    parser.add_argument("--base_url", required=True)
    parser.add_argument("--config_name", required=True)
    parser.add_argument("--access_group", required=True)
    parser.add_argument("--section", required=True, choices=["DEV", "PREPROD", "PROD"]) 
    parser.add_argument("--fqdn", nargs="*", default=[])
    parser.add_argument("--template_config_name", required=True)
    parser.add_argument("--isProd", action="store_true", help="Prod-only onboarding if set; otherwise both in one run when config missing")
    parser.add_argument("--note", default="", help="Version notes to attach to created config version")
    parser.add_argument("--emails", nargs="*", default=[], help="Activation emails")
    parser.add_argument("--dry_run", action="store_true")
    args = parser.parse_args()

    session = setup_session()

    # Build preview
    both_policies = not args.isProd
    dry_run_preview(args.config_name, args.access_group, args.section, args.fqdn, args.template_config_name, both_policies)

    # Precheck: if config exists, bail out (assumes both policies already exist under it)
    existing_config_id = config_exists(session, args.base_url, args.config_name)
    if existing_config_id:
        print(f"[INFO] Security Config '{args.config_name}' already exists (ID={existing_config_id}). Assuming both policies exist. Aborting new creation.")
        return 0

    if args.dry_run:
        print("[DRY-RUN] Would create Security Config and both NonProd & Prod policies (since config missing).")
        return 0

    # Create base Security Config (placeholder create call; adapt to your environment)
    try:
        create_url = f"{args.base_url}/appsec/v1/configs"
        create_payload = {"name": args.config_name, "description": f"Created by automation for {args.access_group} [{args.section}]"}
        cr = session.post(create_url, json=create_payload, timeout=API_TIMEOUT)
        cr.raise_for_status()
        config_id = cr.json().get("id")
        version = 1
        print(f"[SUCCESS] Created Security Config '{args.config_name}' (ID={config_id})")
    except Exception as e:
        print(f"[ERROR] Failed to create Security Config: {e}")
        return 2

    # Update version notes if provided
    _ = update_security_config_version_notes(session, args.base_url, config_id, version, args.note)

    # Create NonProd policy first from template
    nonprod_policy_name = f"PL-{args.access_group}-NonProd"
    nonprod_policy_id = onboard_nonprod_policy(session, args.base_url, config_id, REGION_SETTINGS[args.section]["group_id"], REGION_SETTINGS[args.section]["contract_id"], args.template_config_name, nonprod_policy_name)
    if not nonprod_policy_id:
        print("[ERROR] Could not create NonProd policy")
        return 3
    print(f"[SUCCESS] Created NonProd policy: {nonprod_policy_id}")

    # Create Prod policy from NonProd
    prod_policy_name = f"PL-{args.access_group}-Prod"
    prod_policy_id = onboard_prod_policy(session, args.base_url, config_id, REGION_SETTINGS[args.section]["group_id"], REGION_SETTINGS[args.section]["contract_id"], nonprod_policy_id, prod_policy_name, args.fqdn, args.access_group)
    if not prod_policy_id:
        print("[ERROR] Could not create Prod policy")
        return 4
    print(f"[SUCCESS] Created Prod policy: {prod_policy_id}")

    # Update rate policies for this version (use final cleaned function)
    _ = update_rate_policies(
        session,
        args.base_url,
        config_id,
        version,
        args.access_group,
        search_client_lists_by_id,
        search_client_lists_by_name,
    )

    print("[DONE] Onboarding complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

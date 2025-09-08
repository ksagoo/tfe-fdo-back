# Akamai Entitlement Check

This repository provides a Python utility script for **validating LDAP/AD user entitlements** and **cross-checking Akamai Access Groups**.  
It is intended for automation pipelines (Jenkins, GitLab CI/CD) as well as local troubleshooting.

---

## Features

- Query LDAP/AD API for a given user ID.
- Print user summary fields (displayName, mail, sAMAccountName, employeeID, department, company).
- List all AD groups for a user.
- Check if user is a member of a specific group (substring or exact match).
- Search groups by substring.
- Save raw LDAP JSON for offline inspection.
- **Compare groups between two users** to find common and unique memberships.
- Validate an **Akamai Access Group** via PAPI (EdgeGrid) and reuse it for LDAP substring membership checks.
- Configurable LDAP **timeout** and **retry policy** with exponential backoff.
- Optional **TLS certificate verification** for LDAP requests (`--verify-ca`).
- Debug mode for verbose tracing of requests and headers.

---

## Requirements

- Python 3.7+
- Packages:
  ```bash
  pip install requests akamai-edgegrid urllib3
  ```

- A valid `.edgerc` file for Akamai EdgeGrid authentication if using `--access-group` validation.

---

## Usage

```bash
python entitlement_check.py [options]
```

### Required Arguments
- `--user <ID>`  
  Primary user ID (e.g., 45384191).

### Optional Arguments
- `--user-b <ID>`  
  Compare against a second user and show differences in group memberships.

- `--summary`  
  Print user summary fields.

- `--groups`  
  List only groups.

- `--is-member <GROUP>`  
  Check if user is in a group (substring by default).

- `--exact`  
  Require exact match for `--is-member`.

- `--find <PATTERN>`  
  Find groups containing substring.

- `--save-json <PATH>`  
  Save raw JSON LDAP response to file.

- `--verify-ca <CA_PATH>`  
  Path to CA certificate for LDAP TLS verification (applies to LDAP only).

- `--access-group <NAME>`  
  Validate Access Group via PAPI and reuse name as LDAP substring search.  
  Requires `--region`.

- `--region <REGION>`  
  Region key (`Global`, `APAC`, `EMEA`, `LATAM`, `AMER`, `DEV`).  
  Maps to a contract ID internally.

- `--edgerc-file <PATH>`  
  Path to `.edgerc` file for PAPI auth (default: `~/.edgerc`).

- `--section-name <NAME>`  
  Section inside `.edgerc` (default: `default`).

- `--timeout <SECONDS>`  
  LDAP request timeout (default: 20).

- `--retries <N>`  
  LDAP retry attempts on transient errors (default: 3).

- `--retry-backoff <FACTOR>`  
  Backoff multiplier for retries (default: 0.5).

- `--debug`  
  Enable verbose debug output.

---

## Examples

### Print summary of a user
```bash
python entitlement_check.py --user 45384191 --summary
```

### List groups only
```bash
python entitlement_check.py --user 45384191 --groups
```

### Check membership (substring match)
```bash
python entitlement_check.py --user 45384191 --is-member "ServiceNowDEV-Fulfiller"
```

### Check membership (exact match)
```bash
python entitlement_check.py --user 45384191 \
  --is-member "CN=InfoDir-ServiceNowDEV-Fulfiller,OU=ServiceNow,OU=Applications,OU=Groups,DC=InfoDir,DC=Prod,DC=HSBC" \
  --exact
```

### Find groups containing substring
```bash
python entitlement_check.py --user 45384191 --find "ServiceNowDEV-Fulfiller"
```

### Save JSON for inspection
```bash
python entitlement_check.py --user 45384191 --save-json ldap.json
```

### Run with CA cert verification
```bash
python entitlement_check.py --user 45384191 --summary \
  --verify-ca "/C/Users/45384191/certs/certs.pem"
```

### Validate Access Group via PAPI and check LDAP membership
```bash
python entitlement_check.py --region APAC --user 45384191 \
  --access-group "HSBC-APAC-VL" \
  --edgerc-file ~/.edgerc --section-name default \
  --verify-ca "/C/Users/45384191/certs/certs.pem"
```

### Compare groups between two users
```bash
python entitlement_check.py --user 45384191 --user-b 87654321
```

Example output:
```
User A: John Smith (45384191)
User B: Jane Doe (87654321)
Totals: A=42, B=38, common=30

-- Only in A (12) --
GroupX
GroupY

-- Only in B (8) --
GroupZ
...

-- In BOTH (30) --
CommonGroup1
CommonGroup2
```

---

## Notes

- **LDAP vs Akamai calls**:
  - LDAP calls (`--user`, `--is-member`, `--find`, `--user-b`) honor `--verify-ca`, `--timeout`, and retry settings.
  - Akamai PAPI calls (`--access-group`) always use EdgeGrid auth and default system CA.

- **Exit Codes** (future enhancement):
  - Non-zero codes can be added for pipeline automation (e.g., `1` if membership check returns `NO`).

---

## License

Internal HSBC Automation Utility – Not for external distribution.

# Akamai CPS Certificate Renewal Automation

## Overview
This document describes the structure, usage, and configuration of the Akamai CPS Certificate Renewal Automation module.
It supports both **live execution** and **dry-run mode** for simulation of Akamai API calls.

---

## Features
- Certificate renewal and deployment via Akamai CPS APIs
- Dry-run simulation with mock JSON outputs
- Polling for deployment completion
- Email rendering via Jinja2 templates
- Confluence-ready structured documentation

---

## Prerequisites
- Python 3.8+
- `akamai-edgegrid` and `requests` libraries
- `.edgerc` credentials file with appropriate sections
- Access to the Akamai CPS API

---

## Usage
```bash
python akamai_cps_manager.py --section EMEA --access_group HSBC-EMEA --fqdn example.hsbc.com --enrollment_id 12345 --action renew_and_deploy --dry-run
```

### Arguments
| Flag | Description | Example |
|------|--------------|----------|
| `--section` | .edgerc section name | `EMEA` |
| `--access_group` | Akamai access group | `HSBC-EMEA` |
| `--fqdn` | Target certificate hostname | `example.hsbc.com` |
| `--enrollment_id` | CPS enrollment ID | `12345` |
| `--action` | Operation to perform | `renew_and_deploy` |
| `--dry-run` | Simulate API calls | `--dry-run` |

---

## Execution Flow
1. Retrieve enrollment details  
2. Trigger renewal (or simulate if dry-run)  
3. Create deployment request  
4. Poll deployment status (if live)  
5. Output JSON results for email rendering

---

## Outputs
All results are stored as structured JSON in `/json_samples/`.
These files feed directly into the email rendering templates.

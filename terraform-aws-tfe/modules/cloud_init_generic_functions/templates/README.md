# Akamai CPS Certificate Renewal Automation - Developer Edition

## Developer Overview
This document provides an in-depth view for developers integrating or extending the Akamai CPS automation module.

### Module Responsibilities
- Handles certificate lifecycle operations (renewal, deployment, polling)
- Supports dry-run simulation for testing without live API calls
- Produces structured JSON outputs compatible with email rendering templates

### Design Goals
- Maintain API safety via `--dry-run`
- Modularize Akamai API interactions
- Enable local testability before Jenkins integration

---

## Core Components
| File | Purpose |
|------|----------|
| `akamai_cps_manager.py` | Main CPS logic, including renewal, deployment, and polling |
| `templates/` | Jinja2 HTML templates for notifications |
| `json_samples/` | Dry-run output examples for simulated API responses |
| `docs/` | Documentation and guides for developers and testers |

---

## Developer Setup
```bash
# Clone repository
git clone https://gitlab.example.com/akamai/cps-automation.git
cd cps-automation

# Install dependencies
pip install -r requirements.txt
```

### Required Files
- `.edgerc` with credentials (EdgeGrid format)
- Access to the appropriate Akamai group and contract IDs

---

## API Call Flow
1. `GET /cps/v2/enrollments/{id}` → retrieve current enrollment
2. `POST /cps/v2/enrollments/{id}/renew` → renew certificate
3. `POST /cps/v2/enrollments/{id}/deployments` → deploy to staging/production
4. Poll `/deployments/{deploymentId}` until `deploymentStatus=COMPLETE`

Each call includes structured error handling and optional dry-run short-circuiting.

# Akamai Certificate Lifecycle – Command Cheat Sheet

### Purpose
This cheat sheet lists all supported **Akamai CPS automation commands** (live and dry-run), with example usage, expected outputs, and intended purpose in the Jenkins/Jira workflow.

---

## 1️⃣ Discover All Enrollments (Inventory)

| Purpose | Discover all CPS enrollments under a given access group or account. Returns all active FQDNs, enrollment IDs, expiry dates, and SANs. |
|----------|----------------------------------------------------------------------------------------------|
| Typical Use | Jira “Certificate Inventory” or periodic audit reports |
| When to Use | Monthly inventory or baseline verification |
| Mode | Live or Dry-run |

### Commands
```bash
# Live discovery
python akamai_cert_manager.py --section APAC --access_group AppSec --action get_enrollment

# Dry-run (mock discovery)
python akamai_cert_manager.py --section DEV --access_group AppSec --action get_enrollment --dry-run
```

### Output
- `output/discovered_enrollments.json`
- Optional discovery HTML report (`output/email_discovery.html`)
- `[INFO]` or `[DRY-RUN]` summary in console

---

## 2️⃣ Discover Expiring Certificates (Filtered Inventory)

| Purpose | Retrieve only enrollments expiring within N days |
|----------|------------------------------------------------|
| Typical Use | Jira “Upcoming Expiry Notification” workflow |
| When to Use | Daily or weekly expiry checks |
| Mode | Live or Dry-run |

### Commands
```bash
# Certificates expiring in next 40 days
python akamai_cert_manager.py --section APAC --access_group AppSec --action get_enrollment --expiry-threshold 40

# Within 14 days (e.g. used by escalation notifications)
python akamai_cert_manager.py --section APAC --access_group AppSec --action get_enrollment --expiry-threshold 14

# Dry-run simulation for pipeline testing
python akamai_cert_manager.py --section DEV --access_group AppSec --action get_enrollment --expiry-threshold 14 --dry-run
```

### Output
Filtered JSON list and optionally rendered escalation emails (14/10/7-day templates).

---

## 3️⃣ Renew Certificate Only

| Purpose | Initiate a renewal for a specific enrollment |
|----------|---------------------------------------------|
| Typical Use | Jira “Renewal Approved” stage |
| When to Use | After CAB or change approval |
| Mode | Live or Dry-run |

### Commands
```bash
# Live renewal
python akamai_cert_manager.py --section APAC --access_group AppSec --fqdn api.hsbc.com --enrollment_id 104530 --action renew_only

# Dry-run simulation
python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn renewonly.example.com --enrollment_id 10003 --action renew_only --dry-run
```

---

## 4️⃣ Deploy Certificate Only

| Purpose | Deploy the most recent certificate version |
|----------|--------------------------------------------|
| Typical Use | Jira “Deployment Approved” or scheduled rollout stage |
| When to Use | After renewal success |
| Mode | Live or Dry-run |

### Commands
```bash
# Live deployment to production
python akamai_cert_manager.py --section EMEA --access_group InfraSec --fqdn portal.hsbc.com --enrollment_id 104531 --action deploy_only --deployment-network production

# Dry-run simulation
python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn deployonly.example.com --enrollment_id 10004 --action deploy_only --dry-run
```

---

## 5️⃣ Full Lifecycle (Renew + Deploy)

| Purpose | Complete lifecycle including renewal, deployment, polling, and notification |
|----------|------------------------------------------------------------------------------|
| Typical Use | Jira “Certificate Renewal & Deployment” automated step |
| When to Use | Standard certificate change with no scheduling delay |
| Mode | Live or Dry-run |

### Commands
```bash
# Live combined
python akamai_cert_manager.py --section APAC --access_group AppSec --fqdn login.hsbc.com --enrollment_id 104532 --action renew_and_deploy --deployment-network production

# Dry-run combined simulation
python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn fullflow.example.com --enrollment_id 10010 --action renew_and_deploy --dry-run
```

---

## 6️⃣ Scheduled Deployment or Staging Deployment

| Purpose | Deploy to staging or schedule future production deployment |
|----------|-----------------------------------------------------------|
| Typical Use | Jira “Change Window Scheduling” |
| Mode | Live only |

### Commands
```bash
# Schedule future deployment
python akamai_cert_manager.py --section LATAM --access_group InfraSec --fqdn schedule.hsbc.net --enrollment_id 105001 --action renew_and_deploy --schedule-time 2025-10-14T09:00:00Z

# Deploy to staging
python akamai_cert_manager.py --section AMER --access_group AppSec --fqdn staging.hsbc.net --enrollment_id 105002 --action renew_and_deploy --deployment-network staging
```

---

## 7️⃣ Polling Test / Verification

| Purpose | Test or verify polling loop and status change handling |
|----------|-------------------------------------------------------|
| Typical Use | QA and pipeline timeout tuning |
| Mode | Live or Dry-run |

### Example
```bash
python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn fullflow.example.com --enrollment_id 10010 --poll-interval 10 --poll-timeout 120 --dry-run
```

---

## 8️⃣ Debug & JSON Output Modes

| Flag | Description |
|------|--------------|
| `--debug` | Write detailed logs to `output/debug.log` |
| `--json-only` | Console-safe for CI parsing (suppresses detailed output) |
| `--no-email` | Skip HTML rendering when only JSON output needed |

---

## 9️⃣ Typical CI/CD Use Cases

| Stage | Jenkins / Jira Purpose | Typical Command |
|--------|------------------------|-----------------|
| **Discovery** | Inventory collection or expiry audit | `--action get_enrollment` |
| **Renewal** | Approved renewals only | `--action renew_only` |
| **Deployment** | Deployment change window | `--action deploy_only` |
| **Full Lifecycle** | Auto renew + deploy | `--action renew_and_deploy` |
| **Dry-Run** | Internal validation | `--dry-run` |

---

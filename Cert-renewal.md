# Akamai Certificate Lifecycle Automation

## Overview

This project automates certificate lifecycle management for Akamai CPS (Certificate Provisioning System), enabling renewal, deployment, and notification workflows.  
It supports both **live API calls** and **dry-run simulation mode**, allowing full local validation before integrating with Jenkins pipelines.

### Key Features

- Automated certificate renewal and deployment using CPS API (v2).
- Dry-run simulation to generate realistic JSON outputs and email templates without calling APIs.
- Escalation and deployment notifications rendered from HTML/Jinja2 templates.
- Support for regional contracts and multi-environment (`DEV`, `APAC`, `EMEA`, `LATAM`, etc.).
- Jenkins-ready CLI for integration with Front Door forms and change ticket validation.
- JSON-based structured logging for automation tracking.

---

## Folder Structure

```
akamai_cert_manager/
├── akamai_cert_manager.py         # Main CPS automation module
├── templates/
│   ├── 7Days-EscalationNotificationEmail.html
│   ├── 10Days-EscalationNotificationEmail.html
│   ├── 14Days-EscalationNotificationEmail.html
│   ├── CertRenewalDeploymentNotification.html
│   └── certdata.j2
├── output/
│   ├── dryrun_output.json         # Generated during dry-run tests
│   ├── rendered_email.html        # Rendered from templates
│   └── logs/
│       └── run_log.json
└── README.md
```

---

## Requirements

- **Python**: 3.x  
- **Dependencies**:
  ```bash
  pip install requests akamai-edgegrid jinja2
  ```
- **Credentials**: Valid Akamai `.edgerc` configuration with appropriate group access.

---

## Setup

Ensure your `.edgerc` file is configured correctly:

```
[DEV]
client_secret = <secret>
host = akab-xxxxx.luna.akamaiapis.net
access_token = <access>
client_token = <token>
```

---

## CLI Arguments

| Argument | Required | Description | Default |
|-----------|-----------|--------------|----------|
| `--section` | Yes | .edgerc section for Akamai credentials | - |
| `--access_group` | Yes | Access group name (for logs) | - |
| `--fqdn` | Yes | Primary certificate FQDN | - |
| `--enrollment_id` | Yes | CPS enrollment ID | - |
| `--action` | No | Operation: `get_enrollment`, `renew_only`, `deploy_only`, `renew_and_deploy` | `renew_and_deploy` |
| `--deployment-network` | No | Target network: `staging` or `production` | `production` |
| `--schedule-time` | No | ISO-8601 start time for scheduled deployment | `None` |
| `--poll-timeout-sec` | No | Max seconds for deployment polling | `1800` |
| `--poll-interval-sec` | No | Polling interval in seconds | `20` |
| `--version-notes` | No | Notes annotation for logging | `None` |
| `--dry-run` | No | Enable simulation mode without calling CPS | `False` |

---

## Usage Examples

### 1. Dry-Run Mode (Simulate Full Flow)

```bash
python akamai_cert_manager.py   --section DEV   --access_group AppSec   --fqdn test.example.com   --enrollment_id 12345   --action renew_and_deploy   --dry-run
```

**Output:**
```json
{
  "fqdn": "test.example.com",
  "action": "renew_and_deploy",
  "dryRun": true,
  "steps": [
    {"name": "getEnrollmentDetails", "dryRun": true},
    {"name": "triggerRenewal", "url": ".../cps/v2/enrollments/12345/renew"},
    {"name": "createDeployment", "payload": {"network": "production"}}
  ]
}
```

### 2. Live Renewal and Deployment

```bash
python akamai_cert_manager.py   --section DEV   --access_group AppSec   --fqdn mydomain.com   --enrollment_id 67890   --action renew_and_deploy
```

This will trigger renewal and automatically deploy to the specified network.

---

## Dry-Run Workflow

When `--dry-run` is enabled:
- All CPS API calls are simulated.
- JSON responses are written to `/output/dryrun_output.json`.
- Escalation or deployment notification emails are rendered from templates.
- No real changes occur on the Akamai platform.

---

## Email Rendering

Templates under `/templates/` are rendered automatically.  
The correct escalation template is selected based on `--days-to-expiry` or deployment stage.

| Template | Purpose |
|-----------|----------|
| `7Days-EscalationNotificationEmail.html` | Expiry within 7 days |
| `10Days-EscalationNotificationEmail.html` | Expiry within 10 days |
| `14Days-EscalationNotificationEmail.html` | Expiry within 14 days |
| `CertRenewalDeploymentNotification.html` | Deployment confirmation |
| `certdata.j2` | Raw JSON data renderer |

---

## Jenkins Integration

The pipeline executes this module as a standalone job or step within a larger Jenkinsfile.  
Example Jenkins step:

```groovy
stage('Renew Akamai Cert') {
    steps {
        sh '''
        python akamai_cert_manager.py           --section ${SECTION}           --access_group ${ACCESS_GROUP}           --fqdn ${FQDN}           --enrollment_id ${ENROLLMENT_ID}           --action renew_and_deploy           --dry-run=${DRY_RUN}
        '''
    }
}
```

---

## Logging and Output

- All execution steps and results are written to `/output/logs/run_log.json`.
- Each dry-run generates a unique timestamped JSON summary.
- Email HTML files are stored under `/output/` for validation.

---

## Debugging

To enable detailed logging:

```bash
export LOG_LEVEL=DEBUG
python akamai_cert_manager.py --dry-run ...
```

Common issues:
- **Invalid .edgerc section:** Ensure the section exists and contains valid tokens.
- **Timeout:** Increase `--poll-timeout-sec` for long-running deployments.

---

## Testing Scenarios

| Scenario | Expected Behavior |
|-----------|------------------|
| `--dry-run` | Simulates all API calls and creates sample outputs |
| Expiry within 7 days | Triggers 7-day escalation template |
| Expiry within 14 days | Triggers 14-day escalation template |
| `--schedule-time` set | Creates a scheduled deployment JSON payload |
| `--deployment-network staging` | Deploys to staging instead of production |

---

## Example Dry-Run Output

```json
{
  "fqdn": "demo.hsbc.com",
  "enrollmentId": "99999",
  "region": "DEV",
  "action": "renew_and_deploy",
  "dryRun": true,
  "steps": [
    {"name": "getEnrollmentDetails", "note": "Would fetch enrollment details"},
    {"name": "triggerRenewal", "url": "https://akab-xxxx.luna.akamaiapis.net/cps/v2/enrollments/99999/renew"},
    {"name": "createDeployment", "payload": {"network": "production"}}
  ]
}
```

---

## License

**Internal Use Only – HSBC / Akamai Automation Team**  
Created: October 2025  
Last Updated: October 2025

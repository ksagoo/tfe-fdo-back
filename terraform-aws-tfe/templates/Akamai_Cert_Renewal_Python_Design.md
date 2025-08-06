
# Python Migration Structure & High-Level Design for Akamai Certificate Renewals

## Objective
This document outlines the proposed Python-based automation architecture to replace the existing Ansible-driven Akamai Certificate Renewal solution. The goal is to achieve a modular, scalable, and CI/CD-integrated Python automation framework that interacts with Akamai CPS APIs and supports dynamic triggering via Jenkins pipelines.

---

## High-Level Architecture
```bash
Python Project (akamai_cert_automation/)
├── core/
│   ├── akamai_cert_manager.py       # Main orchestrator class (renewals, deployment, notifications)
│   ├── client.py                    # Generic HTTP Client wrapper with EdgeGrid auth
│   ├── edgegrid_auth.py             # EdgeGrid signature/authentication logic
│   ├── cps_api.py                   # CPS-specific API service (enrollments, deploys, schedules)
│   └── notification_service.py      # Email (SMTP/API) notification sender
├── workflows/
│   ├── deploy_certificate.py        # Workflow to deploy renewed certs (invokes core services)
│   ├── schedule_deployment.py       # Workflow to set deployment schedule
│   ├── disable_credentials.py       # Workflow to disable old API credentials
│   └── escalation_notifications.py  # Workflow to send escalation emails (7/10/14 days prior expiry)
├── templates/
│   ├── escalation_email.html        # Unified HTML template with placeholders
│   └── deployment_notification.html # Deployment result notification template
├── cli/
│   └── renew_certificate.py         # CLI entrypoint script to trigger workflows
├── utils/
│   ├── logger.py                    # Centralized logging setup
│   └── config_loader.py             # Reads configuration from JSON/YAML/env variables
├── tests/                           # Unit tests for core modules and workflows
├── Jenkinsfile                      # Jenkins Pipeline definition (parameterized)
├── requirements.txt                 # Python dependencies (requests, edgegrid-python, etc.)
└── README.md                        # Project documentation
```

---

## Key Components Breakdown

### core/
| Module Name              | Purpose |
| ------------------------ | ------- |
| akamai_cert_manager.py   | Central orchestrator class to manage certificate lifecycle workflows. |
| client.py                | Generic HTTP client for Akamai API requests, includes retry/error handling. |
| edgegrid_auth.py         | Implements Akamai EdgeGrid Authentication (Header signing logic). |
| cps_api.py               | Service class encapsulating CPS-specific API calls (enrollment fetch, deploy, schedule). |
| notification_service.py  | Sends email notifications using SMTP or API-based email services (like SendGrid). |

### workflows/
| Workflow Script              | Purpose |
| ---------------------------- | ------- |
| deploy_certificate.py         | Triggers deployment of renewed certificates via CPS API. |
| schedule_deployment.py        | Schedules deployment windows post-renewal. |
| disable_credentials.py        | Disables obsolete API credentials after cert deployment. |
| escalation_notifications.py   | Sends escalation emails based on expiry timeline (7/10/14 days). |

### cli/
| CLI Script               | Purpose |
| ------------------------ | ------- |
| renew_certificate.py      | Main CLI entrypoint to trigger workflows dynamically (e.g., deploy, escalate, disable). |

### utils/
| Utility Module            | Purpose |
| ------------------------- | ------- |
| logger.py                  | Centralized logging setup with structured logs (JSON format optional). |
| config_loader.py           | Reads configurations from YAML/JSON/env files for dynamic parameter injection. |

### templates/
| Template File                      | Purpose |
| ---------------------------------- | ------- |
| escalation_email.html              | HTML template for escalation notifications (parameterized placeholders). |
| deployment_notification.html       | HTML template for deployment success/failure notifications. |

---

## Jenkins Integration

- **Declarative Pipeline (Jenkinsfile)**
  - Parameters:
    - CERTIFICATE_NAME
    - RENEWAL_TYPE (Auto/Manual CSR)
    - NOTIFICATION_EMAILS
    - SCHEDULE_TIME
  - Executes CLI script with appropriate flags.
  - Archives logs and posts deployment status.

- **Secrets Management with HashiCorp Vault**
  - All sensitive credentials, including Akamai .edgerc tokens, subaccount-specific API credentials, and notification service secrets, will be securely managed via HashiCorp Vault.
  - Jenkins will retrieve secrets dynamically from Vault during pipeline execution.
  - Role-based access control (RBAC) will be enforced at the Vault level to ensure credentials are isolated per subaccount.
  - Secrets access will be audited, and Vault policies will enforce TTL (time-to-live) on credential tokens.

---

## Front Door Integration

- The solution will integrate with the **Jira Front Door Form System** to allow users to initiate certificate renewal workflows via a self-service interface.

- **Entitlement Validation (AD Group-Based Access Control):**
  - Before proceeding with certificate renewal actions, the automation will perform a **real-time entitlement check**.
  - This involves validating whether the initiating user is a member of the **Active Directory (AD) Group** that corresponds to the **Akamai Access Group** for the targeted configuration.
  - This entitlement verification step ensures that only authorized teams can initiate renewals, eliminating reliance on manual entitlement spreadsheets.
  - Refer to the **“Entitlement Enforcement Design Document”** for detailed architecture and workflow of this validation logic.

- **Form Behavior:**
  - Submitting the form creates a Jira Ticket capturing the certificate renewal request.
  - Jira workflows enforce approval chains (Change Approval, Assignment Group validation).
  - Form captures necessary parameters:
    - Certificate Name (dropdown or free text)
    - Renewal Type (Auto / Manual CSR)
    - Notification Recipients (email addresses)
    - Deployment Schedule Time (optional)

- **Workflow Execution:**
  1. Upon form submission, a Jira workflow transition triggers a webhook to Jenkins.
  2. Jenkins pipeline starts, pulling parameters from the Jira issue.
  3. The Python CLI automation is executed with form parameters.
  4. Execution status is updated back to the Jira ticket.
  5. All escalation notifications and deployment results are logged to the Jira ticket.

- **End-to-End Visibility:**
  - Jira becomes the central source of truth for the request lifecycle.
  - Logs, status updates, and approval actions are tracked within the Jira issue.
  - End-to-end automation ensures traceability from request initiation to deployment completion.

---

## Improvements Over Ansible Solution
| Limitation (Ansible)           | Python Solution Improvement |
| ------------------------------ | --------------------------- |
| Tied to Ansible Playbooks      | Fully CLI-driven workflows, no external orchestration dependency. |
| Static YAML variable files     | Dynamic parameter intake via CLI or Jenkins pipeline inputs. |
| Siloed module-specific scripts | Modular Python classes/services promoting code reuse. |
| Limited logging/observability  | Enhanced structured logging, metrics, and API-level observability. |
| Basic SMTP notifications       | Scalable notification service with API-based mailers. |
| Travis CI integration          | Jenkins Pipeline with dynamic triggers and deployment controls. |
| No Self-Service Trigger        | Jira Front Door form enabling self-service initiation workflows. |
| No End-to-End Request Logging  | Full visibility and audit trail via Jira ticket lifecycle logging. |
| Static Credential Handling     | Dynamic, secure secrets management using HashiCorp Vault. |

---

## Next Steps
- Develop core modules (client.py, edgegrid_auth.py, cps_api.py).
- Build orchestration class (akamai_cert_manager.py).
- Migrate workflows into Python scripts under workflows/.
- Implement CLI interface for triggering.
- Design Jenkinsfile for pipeline automation.
- Integrate Jira Front Door form workflows into Jenkins triggers.
- Implement logging back to Jira tickets (via Jira REST API).
- Integrate Vault secrets retrieval mechanism.
- Write unit tests for key modules.

---

## Outcome
This Python-native solution will provide a robust, scalable, and maintainable framework for Akamai Certificate Renewals, removing Ansible dependency and aligning with modern CI/CD practices while enabling self-service operations through Jira Front Door integration, with full audit trail, end-to-end request logging, and secure secrets management via HashiCorp Vault.

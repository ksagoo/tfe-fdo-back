
# Akamai Certificate Renewal Automation - Current Ansible Solution Documentation

## Overview
This document captures the current Ansible-based automation solution for Akamai Certificate Renewals. It outlines the project structure, key logic components, shared utilities, and functional workflows that are essential for certificate lifecycle management via Akamai's CPS (Certificate Provisioning System) APIs.

---

## Project Folder Structure
```bash
akamai-ansible/
├── akamai-vault-test/                     # Test and experimental files
├── docs/                                  # Documentation files
├── roles/
│   └── akamai-cert/
│       ├── defaults/
│       │   └── main.yml                   # Default variables
│       ├── handlers/
│       │   └── main.yml                   # Notification handlers
│       ├── library/                       # Custom Ansible modules
│       │   ├── cert_escalation_email_notification.py
│       │   ├── cert_renewal_deploy.py
│       │   ├── cert_renewal_set_schedule.py
│       │   ├── credentials_disable.py
│       │   └── credentials_increase_time.py
│       ├── meta/
│       │   └── main.yml                   # Role metadata
│       ├── module_utils/                  # Shared Python utilities
│       │   ├── __init__.py
│       │   ├── akamai_certs.py
│       │   ├── client.py
│       │   └── edgegrid.py
│       ├── tasks/                         # Task orchestration YAMLs
│       │   ├── certificate-escalation_email_notification.yml
│       │   ├── certificate-renewal_deploy.yml
│       │   ├── certificate-renewal_set_schedule.yml
│       │   └── main.yml
│       ├── templates/                     # HTML email templates
│       │   ├── 10Days-EscalationNotificationEmail.html
│       │   ├── 14Days-EscalationNotificationEmail.html
│       │   ├── 7Days-EscalationNotificationEmail.html
│       │   ├── certEmail.html
│       │   └── certRenewalDeploymentNotification.html
│       └── vars/                          # Variable files (minimal)
├── .travis.yml                           # Legacy CI config
└── README.md                             # Project documentation
```

---

## Key Logic Components

### Custom Modules (library/)
| Module Name                              | Description                                                                                 |
| ---------------------------------------- | ------------------------------------------------------------------------------------------- |
| cert_escalation_email_notification.py   | Sends escalation emails based on certificate expiry timeline using SMTP and HTML templates. |
| cert_renewal_deploy.py                  | Triggers Akamai CPS API to deploy a renewed certificate and polls until completion.         |
| cert_renewal_set_schedule.py            | Schedules certificate deployment to a specific time window via Akamai API.                  |
| credentials_disable.py                  | Disables old Akamai API credentials post-renewal for security hygiene.                      |
| credentials_increase_time.py            | Extends credential validity period or adjusts deployment schedules as needed.               |

### Shared Utilities (module_utils/)
| Utility File | Functionality |
| ------------ | ------------- |
| __init__.py  | Python package initializer. |
| akamai_certs.py | Core CPS API logic: Enrollment lookups, deployment triggers, payload construction, and response parsing. |
| client.py    | Generic API client wrapper: Handles HTTP GET, POST, PUT, PATCH with retries and error handling. |
| edgegrid.py  | Implements Akamai EdgeGrid Authentication for signing API requests. |

---

## Workflow Example: Certificate Renewal Deployment
1. Ansible Playbook invokes **cert_renewal_deploy.py** module.
2. The module imports **akamai_certs.py** from module_utils to:
   - Prepare CPS API request payload.
   - Make authenticated API call via **client.py**.
   - Handle EdgeGrid authentication using **edgegrid.py**.
3. Deployment is triggered, and the module polls for success/failure.
4. Results (success/failure messages) are returned to Ansible.

---

## Common Patterns
- All custom modules delegate API call logic to module_utils.
- client.py ensures robust API communication (retries, error handling).
- akamai_certs.py contains the business logic for Akamai CPS operations.
- Notification emails are handled using templates/ HTML files.
- Orchestration of module execution is managed via YAML files in tasks/.

---

## Current Limitations & Points of Improvement
| Area                      | Current Limitation                                                  | Improvement Goal                                                                                |
| ------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Ansible Dependency        | Tightly coupled with Ansible Playbooks and Roles for orchestration. | Transition to a standalone Python automation framework.                                         |
| Manual Parameter Handling | Relies on YAML variable files and Ansible CLI arguments.            | Switch to dynamic parameter intake via Jenkins Front Door Form.                                 |
| Scalability & Reusability | Task-specific modules with duplicated API call logic.               | Modular Python classes with reusable service components.                                        |
| Logging & Observability   | Minimal structured logging, lacks centralized visibility.           | Integrate detailed logging and metrics for better observability.                                |
| CI/CD Modernization       | Uses Travis CI which is deprecated in the current workflow.         | Migrate to Jenkins Pipeline-driven automation.                                                  |
| Error Handling & Retries  | Limited error handling in module-specific scripts.                  | Implement robust exception handling and API retry logic in shared utilities.                    |
| Notification Mechanism    | Basic SMTP notification through hardcoded templates.                | Dynamic templating and integration with centralized notification platforms (Slack, Email APIs). |

---

## Summary
The current solution cleanly separates API logic (module_utils) from task execution (custom modules), maintaining a modular and reusable code structure. It efficiently integrates with Akamai's CPS API for automated certificate renewals, while providing email escalation workflows based on certificate expiry timelines.

This documentation serves as the baseline for transitioning the automation to a Python-native solution, removing Ansible dependency while preserving functional integrity.

---

## Next Steps
- Define Python Automation Migration Plan.
- Rebuild shared utilities as Python services/classes.
- Design CLI-driven workflows to replicate Ansible Playbook orchestrations.
- Integrate with Jenkins for pipeline-based execution.
- Enhance logging, error handling, and observability.
- Improve notification mechanisms with dynamic templating.

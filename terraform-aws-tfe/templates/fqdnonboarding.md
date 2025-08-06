## FQDN Onboarding Automation - Current Ansible Module Summary

### Overview

The current **Ansible-based FQDN Onboarding Automation Module** is designed to automate ServiceNow (SNOW) onboarding tasks by gathering request metadata, generating Jira stories, and managing JSON files for tracking onboarding requests. However, it does **not create any Akamai resources directly** (e.g., no property activation, client list management, or configuration updates).

The primary purpose of this module is to coordinate onboarding steps by automating Jira story creation, generating onboarding task descriptions, and updating Confluence templates with structured onboarding information.

---

### Current Functionality Summary

| Functionality Area                  | Details                                                                                                                      |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Akamai Resource Creation**        | **None.** No properties, client lists, configurations, or Akamai objects are created/modified.                               |
| **ServiceNow (SNOW) API Queries**   | Gathers request data (Request Item, Task Item) from SNOW using API calls.                                                    |
| **Jira Ticket Automation**          | Automates Jira ticket creation (Stories, Sub-tasks) with pre-filled descriptions and acceptance criteria based on SNOW data. |
| **Onboarding Templates Management** | Pulls YAML onboarding templates from GitHub repo and injects SNOW request data.                                              |
| **Kong API Integrations**           | API calls to Kong for status checking (related to Mulesoft to Kong migration validation).                                    |
| **Confluence Updates**              | Syncs onboarding file data into Confluence pages (file sync task).                                                           |
| **Data Management**                 | Manages onboarding request details via JSON/YAML files stored in Git.                                                        |
| **Shell-based Git Operations**      | Clones onboarding repo, commits updates, pushes data for collaboration.                                                      |

---

### Folder Structure & Key Files

```
akamai-ansible/roles/fqdns-onboarding/
├── defaults/
│   └── main.yml                   # Default role variables
├── files/
│   └── on_boarding.yaml           # YAML template for onboarding task content (Acceptance Criteria, TaskSteps)
├── handlers/
│   └── main.yml                   # Ansible handlers (currently minimal/unused)
├── library/
│   └── snow_result_data.py        # Custom module for processing SNOW request data
├── meta/
│   └── main.yml                   # Ansible role metadata definition
├── module_utils/
│   ├── __init__.py                # Python package initializer
│   └── snow.py                    # Core logic for Jira ticket creation and SNOW data processing
├── tasks/
│   └── main.yml                   # Main orchestration logic for executing tasks (data pulls, ticket creation)
├── vars/
│   └── main.yml                   # Role variables (API URLs, credentials references, project names)
└── README.md                      # Instructions for running Ansible Tower Job and parameter usage
```

---

### File Descriptions

| File / Directory                  | Purpose                                                                                                  |
| --------------------------------- | -------------------------------------------------------------------------------------------------------- |
| **defaults/main.yml**             | Contains default values for role variables.                                                              |
| **files/on\_boarding.yaml**       | YAML template defining Jira onboarding task structure (Steps, Acceptance Criteria).                      |
| **handlers/main.yml**             | Placeholder for handlers (no active use).                                                                |
| **library/snow\_result\_data.py** | Custom Ansible module parsing SNOW API response data into structured variables.                          |
| **meta/main.yml**                 | Metadata about this Ansible role (author, license, dependencies).                                        |
| **module\_utils/snow\.py**        | Core Python script handling Jira ticket creation logic, sub-task generation, SNOW API parsing.           |
| **tasks/main.yml**                | Main playbook logic performing Git operations, SNOW data retrieval, Jira automation, and Kong API calls. |
| **vars/main.yml**                 | Variables for environment-specific configurations (API endpoints, tokens, project names).                |
| **README.md**                     | User guide for running this module via Ansible Tower (parameters, links to Confluence doc).              |

---

### Key Observations & Limitations

| Limitation Area                          | Details                                                                                                                                                                                                     |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dynamic Entitlement Enforcement**      | Relies on static spreadsheets for entitlement tracking, posing a risk of stale or incorrect ownership data. No real-time IAM validation or AD Group-based checks are performed during onboarding execution. |
| **Secrets & Configuration Management**   | API tokens, URLs, and project references are statically defined in YAML files. Although Vault placeholders are used, secrets are still managed manually and not dynamically fetched during execution.       |
| **Modular Reuse Across CI/CD Pipelines** | The Ansible-centric design limits reuse in modern CI/CD workflows (Jenkins, GitLab pipelines). Workflow logic is tightly coupled within Ansible playbooks and custom modules.                               |
| **Observability & Audit Logging**        | Minimal logging is available beyond console outputs. There is no structured audit trail, SIEM integration, or Jira-based logging of entitlement validations.                                                |
| **Manual Pre-Validation Dependencies**   | Assumes pre-validation of user entitlement is done manually before triggering the onboarding flow. No runtime enforcement exists within the automation itself.                                              |
| **Hardcoded Workflow Dependencies**      | API endpoints, project names, and workflow control flags are statically defined in vars/main.yml, limiting flexibility and requiring code changes for environment variations.                               |

---

### Summary

The current FQDN Onboarding module is effective in automating the **coordination and documentation aspects of onboarding requests**, handling integrations with ServiceNow, Jira, and Git repositories for onboarding task preparation. However, it has **significant limitations in terms of dynamic entitlement enforcement, runtime IAM validations, secrets management, and modular reuse across modern CI/CD pipelines**. The reliance on static spreadsheets for entitlement tracking and the hardcoded configuration approach introduces risks of human error and scalability challenges. To support a fully automated, secure, and governance-aligned onboarding workflow, this module requires a migration to a **Python-based microservice architecture** with dynamic entitlement validation, Vault-based secrets management, and CI/CD-native modular designs.

---

Would you like a "Current Ansible vs Future Python Onboarding Design" **comparison table and diagram** next?


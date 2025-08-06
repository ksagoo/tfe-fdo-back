## Entitlement Enforcement Design Document

### Overview

The Entitlement Enforcement module serves as a **centralized access validation layer** across all onboarding automation workflows (Certificate Renewals, FQDN Onboarding, Client List Management). It ensures that only authorized users, based on their **Active Directory (AD) Group memberships**, are allowed to execute actions against specific Akamai Access Groups.

This design replaces the previous model which relied on manually updated spreadsheets (Confluence Excel templates) as entitlement sources.

---

### Objective

- Provide a **dynamic, real-time entitlement validation mechanism**.
- Align entitlement checks with corporate **Identity & Access Management (IAM)** practices.
- Enforce **runtime authorization** per user/action based on **AD Group ↔ Akamai Access Group mapping**.

---

### High-Level Architecture

```
Entitlement Enforcement Module
├── Directory Service Integration (LDAP / AD API)
├── Entitlement Mapping Config (Naming Convention Driven)
├── Python Entitlement Validator
│   ├── check_user_entitlement(user, access_group)
│   └── resolve_ad_group(access_group)
├── Jenkins Pipeline Invocation
├── Audit Logging to Jira / SIEM
└── Reusable across: Cert Renewals, FQDN Onboarding, Client List Modules
```

---

### Workflow Integration Points

| Workflow                       | Entitlement Validation Step                                                        |
| ------------------------------ | ---------------------------------------------------------------------------------- |
| Certificate Renewal Workflow   | Validate user membership in AD Group mapped to Akamai Access Group.                |
| FQDN Onboarding Workflow       | Validate entitlement before client list modifications.                             |
| Confluence Automation Workflow | Future-proofing: validate automation triggers initiated by authorized groups only. |

---

### AD Group ↔ Access Group Mapping Standards

- AD Groups will be named using a **strict naming convention** that mirrors Akamai Access Groups.
  - Example: `AD-AKAMAI-ACCESSGROUP-<Environment>-<AppName>`
- Automation logic will resolve the required AD Group for a given Akamai Access Group dynamically.
- Mapping rules will be centralized in a **configuration file or directory attribute schema**.

---

### Entitlement Check Workflow

1. User initiates a request via Jira Front Door Form.
2. Jenkins triggers pipeline, capturing the user’s identity.
3. Python Entitlement Validator:
   - Resolves the correct AD Group for the targeted Akamai Access Group.
   - Queries Directory Services to check if the user is an active member of that AD Group.
4. If **validation passes**, workflow proceeds.
5. If **validation fails**, workflow halts with appropriate notifications.
6. All entitlement checks are logged for auditing.

---

### Audit Logging & Governance

- All entitlement validation results (pass/fail) will be logged:
  - **Jira Ticket Comments** (success/failure notes).
  - **Central Audit Log File (JSON structured logs)**.
  - Optional SIEM integration for centralized monitoring.
- Failed entitlement attempts will trigger alert notifications to OpsSec teams.

---

### Key Python Components

| Module Name                    | Purpose                                                                   |
| ------------------------------ | ------------------------------------------------------------------------- |
| entitlement\_validator.py      | Core validation logic for AD group membership checks.                     |
| ad\_directory\_client.py       | Handles API queries to Active Directory / LDAP for group memberships.     |
| entitlement\_config\_loader.py | Loads entitlement mapping rules based on Access Group naming conventions. |
| logger.py                      | Structured logging of entitlement checks and results.                     |

---

### Benefits

| Current Limitation                             | Entitlement Enforcement Solution Improvement           |
| ---------------------------------------------- | ------------------------------------------------------ |
| Manual entitlement declarations (spreadsheets) | Dynamic, live directory-driven entitlement lookups.    |
| No runtime enforcement of access               | Real-time access validation during workflow execution. |
| High risk of stale/incorrect ownership data    | Centralized identity-driven entitlement management.    |
| Lack of auditability                           | Full audit trail of entitlement validations.           |

---

### Outcome

The Entitlement Enforcement module will establish a scalable, reusable, and governance-aligned entitlement validation system that supports all critical onboarding workflows. It will ensure automation actions are securely gated, eliminating dependency on static entitlement files and aligning with enterprise IAM standards.

---


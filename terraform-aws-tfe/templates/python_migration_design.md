## Confluence Automation (Current Ansible Solution) - Documentation Blueprint

### Folder Structure

```
confluence/
├── defaults/
│   └── main.yml
├── handlers/
│   └── main.yml
├── library/
│   └── confluence_file_download.py
├── meta/
│   └── main.yml
├── module_utils/
│   ├── __init__.py
│   └── confluence_file.py
├── tasks/
│   └── main.yml
├── vars/
│   └── main.yml
```

---

### Key Logic Components

| File Path                             | Description                                                                                                |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| library/confluence\_file\_download.py | Custom Ansible module to trigger Confluence file retrieval using `module_utils.confluence_file`.           |
| module\_utils/confluence\_file.py     | Contains `Confluence` class to download Excel templates, convert to JSON, and persist output files.        |
| tasks/main.yml                        | Orchestrates git repository checkout, invokes the file download module, checks diffs, and commits changes. |
| defaults/main.yml                     | Defines default proxy settings and declaration paths used across the role.                                 |
| vars/main.yml                         | Contains Confluence URLs, credentials (obfuscated), file paths, commit messages, and Git repo references.  |
| meta/main.yml                         | Metadata file defining role info, supported platforms, version, and dependencies.                          |

---

### High-Level Workflow

1. Clone target Git repository.
2. Create/checkout working branch.
3. Download Excel template from Confluence, convert specified tab to JSON.
4. Check if changes are detected.
5. If differences exist:
   - Commit updated JSON.
   - Push to Git repository.
6. Clean up local working directory.

---

### Purpose of this Module

This module automates the retrieval of onboarding documentation (Excel Templates) from Confluence, transforms them into structured JSON files, and commits the updated data into a Git repository that acts as a source of truth for downstream automation systems (e.g., Akamai configurations).

Currently, the Confluence spreadsheet serves as an **Entitlement Declaration Source**, mapping FQDNs/domains to:

- Application Owners / Teams
- Approval Groups
- Renewal Statuses

It governs who owns or is responsible for onboarding specific domains and is used to drive downstream processes like client list onboarding, notifications, and escalation paths.

---

### Identified Limitations

While effective, relying on a **manually maintained spreadsheet** in Confluence as a Single Source of Truth introduces:

- Risk of human error or stale data.
- Lack of real-time entitlement checks.
- No enforcement mechanism for runtime access control.

---

### Future-State Enhancement (Python/Jenkins-Based Solution)

The new Python-based solution will eliminate reliance on Confluence spreadsheets by integrating a **dynamic entitlement check leveraging Active Directory (AD) Groups and Akamai Access Groups**.

#### Proposed Mechanism:

- **AD Groups will be linked directly to Akamai Access Groups** using a standardized naming convention (e.g., AD Group = Access Group Name).
- When a user initiates an onboarding/update request via Jenkins Front Door:
  - The automation will validate if the user is a member of the AD Group corresponding to the Access Group being updated.
  - Only if this entitlement check passes, will the workflow proceed.

#### Benefits:

| Limitation (Current Spreadsheet Model)     | Solution Enhancement (Entitlement via AD Groups)                                 |
| ------------------------------------------ | -------------------------------------------------------------------------------- |
| Manual updates prone to data inconsistency | Dynamic entitlement lookup using live AD group membership.                       |
| Spreadsheet not enforcing runtime controls | Runtime enforcement tied to user’s AD group membership for Access Group actions. |
| No linkage between approvals and runtime   | Aligns Access Control with corporate identity systems (AD/SSO integration).      |

This will create a **real-time entitlement enforcement model**, ensuring only authorized users/teams can update onboarding data based on their group memberships without manual spreadsheet intervention.

---

### Outcome

The Confluence-based entitlement declarations will be replaced with a scalable, dynamic entitlement system, integrating AD Groups and Akamai Access Groups in a unified access control model. This will improve data governance, automation accuracy, and streamline user access validation at runtime.

---


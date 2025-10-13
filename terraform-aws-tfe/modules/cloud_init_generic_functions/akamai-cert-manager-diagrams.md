# Akamai Certificate Lifecycle Automation

## Overview

This module automates the complete certificate lifecycle for Akamai CPS (Certificate Provisioning System), including certificate renewal, deployment, polling, and notification rendering.  
It supports both **live API mode** and **dry-run simulation**, allowing safe pre-deployment validation within Jenkins pipelines or local environments.

This implementation fully replaces the previous Ansible-based automation by providing a consolidated, Python-based orchestration layer with enhanced observability, safety, and CI/CD integration.

---

## Flow Diagram

```mermaid
flowchart TD
    A[Jenkins Trigger] --> B{Dry-run Mode?}
    B -->|Yes| C[Simulate CPS discovery and renewal]
    B -->|No| D[Live CPS API discovery and renewal]
    C --> E[Render dry-run emails and save results]
    D --> F[Filter expiring enrollments]
    F --> G[Renew certificates via CPS API]
    G --> H[Deploy certificates to target network]
    H --> I[Poll CPS status until complete or timeout]
    I --> J[Render escalation email notifications]
    J --> K[Write results and summary JSON]
    E --> K
    K --> L[Notify Jenkins of SUCCESS or FAILURE]
```

---

## Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant Jenkins/GitLab as CI/CD Trigger
    participant Script as akamai_cert_manager.py
    participant AkamaiAPI as Akamai CPS API
    participant EmailTemplate as Jinja2 Templates
    participant Output as Output Directory

    Note over Script: Step 1 — Discovery Phase
    Jenkins/GitLab->>Script: Start job (--section, --access_group, [--dry-run])
    Script->>AkamaiAPI: GET /cps/v2/enrollments (simulated if dry-run)
    AkamaiAPI-->>Script: Enrollment list with expiry data
    Script->>Output: Write discovered_enrollments.json
    Note right of Script: Discovery identifies expiring certificates

    loop For each discovered enrollment
        Note over Script: Step 2 — Renewal
        Script->>AkamaiAPI: POST /cps/v2/enrollments/{id}/renew (simulated if dry-run)
        AkamaiAPI-->>Script: Renewal accepted or simulated response
        Script->>AkamaiAPI: Poll CPS status until complete or failed
        AkamaiAPI-->>Script: Renewal completed or simulated result

        Note over Script: Step 3 — Deployment
        Script->>AkamaiAPI: POST /cps/v2/enrollments/{id}/deployments (simulated if dry-run)
        AkamaiAPI-->>Script: Deployment accepted or simulated response
        Script->>AkamaiAPI: Poll CPS status until complete or failed
        AkamaiAPI-->>Script: Deployment completed or simulated result

        Note over Script: Step 4 — Notification
        Script->>EmailTemplate: Render escalation or dry-run HTML template
        EmailTemplate-->>Script: Generated HTML content
        Script->>Output: Save rendered email and JSON results
    end

    Note over Script: Step 5 — Finalization
    Script->>Output: Write result_<fqdn>.json, summary.json, debug.log
    Script-->>Jenkins/GitLab: Print SUCCESS or FAILURE for CI/CD parsing
```

---

## Example Rendered Email (Dry-Run)

Below is an example of the email summary generated in **dry-run mode** using `certEmail_dryrun.j2`.  
It mimics the live production format but clearly displays the `DRY-RUN MODE` tag and simulated data.


<div class="container">
  <h1>Akamai Certificate Renewal — Dry Run Summary <span class="tag">DRY-RUN MODE</span></h1>
  <table>
    <tr><th>FQDN</th><td>test.example.com</td></tr>
    <tr><th>Enrollment ID</th><td>10001</td></tr>
    <tr><th>Expiry Date</th><td>27 Oct 2025</td></tr>
    <tr><th>Auto-Renewal Date</th><td>24 Oct 2025 09:00 UTC</td></tr>
    <tr><th>Deployment Network</th><td>production</td></tr>
  </table>
  <p><strong>No live changes were performed.</strong></p>
</div>


---

## License

**Internal Use Only – HSBC / Akamai Automation Team**  
Created: October 2025  
Last Updated: October 2025

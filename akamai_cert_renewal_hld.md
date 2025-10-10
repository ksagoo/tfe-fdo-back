
# Akamai Certificate Renewal Automation - High Level Design

## Objective

To replace the legacy Ansible-based solution for Akamai certificate renewals with a Python-based automation framework that:

- Leverages Akamai CPS APIs directly  
- Integrates into Jira and Jenkins for workflow and scheduling  
- Eliminates static spreadsheet-based entitlement models  
- Supports enterprise-grade security with AD group enforcement and secrets via Vault  

---

## Key Components

### Python Module

All logic will be consolidated into a single Python module, aligned with existing onboarding practices.

| Function               | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| Session Setup          | Establish Akamai EdgeGrid-authenticated session using .edgerc               |
| Entitlement Check      | Validate user's group membership against AD Group linked to the Access Group|
| Renew Certificate      | CPS API interaction to renew/enroll certificate                             |
| Deployment Scheduling  | CPS API call to schedule deployment (after approval)                        |
| Deployment Execution   | API call to deploy cert to network                                          |
| Status Tracking        | Periodic polling of enrollment/deployment status                            |
| Jira Logging           | Updates Jira issue with execution results                                   |
| Error Handling         | Logs failures to Jira and stops execution                                   |

---


h3. Certificate Renewal Flow

The diagram below outlines the key decision points and logical steps in the certificate renewal process, including entitlement validation, CPS renewal, and deployment sequencing.


## Architectural Overview (Mermaid Flowchart)

```mermaid
graph TD
    A[Jira Form Submitted by Requestor] --> B[Jenkins Pipeline Triggered]
    B --> C[Python Certificate Automation]
    C --> D[Entitlement Check: AD Group vs Access Group]
    D --> E{Entitlement Valid?}
    E -- No --> Z[Fail & Send Email to User]
    E -- Yes --> F[Certificate Renewed via CPS API]
    F --> G[Deployment Scheduled via CPS API]
    G --> H[SNOW Change Ticket: Optional Validation via Kong API]
    H --> I[Deploy to Network via CPS API]
    I --> J[Track Status]
    J --> K[Log to Jira & Notify User]
    K --> L[Success Email Notification]
    Z --> M[Failure Email Notification]
```

---

## Flowchart - Certificate Lifecycle

```mermaid
graph TD
    A[Start - Certificate Active\n>90 days] --> B[EPS Checks Renewal Status]
    B --> C[At 90 Days - New Cert\nCreated]
    C --> D[Renewal Script Scans\nCertificates Daily]
    D --> E[Query Akamai API +\nOnboarded List]
    E --> F[Notify Cyber WASP if <28\nDays]
    F --> G[Threshold Reduced to 14/7\nDays if Needed]
    G --> H[Deploy Certificate via\nAkamai API]
    H --> I[Send Confirmation Email]
    I --> J[Update Tracking\nSheet]
    J --> K[Check Certificate Pinning]
    K --> L[Monitor for Issues/Failures]
    L --> M{Any Issue?}
    M -- Yes --> N[Raise Incident via\nAkamai Portal]
    N --> O[Submit Hostname, Slot,\nExpiry Details]
    O --> P[Akamai Rollback /\nRe-deploy]
    P --> Q[Business Retesting]
    Q --> R[Process Complete]
    M -- No --> R
```

---

## Sequence Diagram - Full Flow

```mermaid
sequenceDiagram
    participant User
    participant Jira
    participant Jenkins
    participant PythonScript
    participant AD
    participant AkamaiAPI
    participant KongAPI
    participant SNOW
    participant MailServer

    User->>Jira: Submit Certificate Renewal Form
    Jira->>Jenkins: Trigger Pipeline via Webhook
    Jenkins->>PythonScript: Execute with Form Parameters
    PythonScript->>AD: Check Group Membership

    PythonScript->>MailServer: Trigger Failure Email - Not Entitled
    MailServer->>User: Failure Email - Not Entitled
    PythonScript->>Jenkins: Log Failure - Not Entitled
    PythonScript->>Jenkins: Exit

    Note over PythonScript: IF Entitled

    PythonScript->>AkamaiAPI: Authenticate via EdgeGrid
    PythonScript->>AkamaiAPI: Call CPS API to Renew Certificate
    PythonScript->>KongAPI: Validate SNOW Change Ticket
    KongAPI->>SNOW: Check Ticket Validity

    PythonScript->>MailServer: Trigger Failure Email - Invalid Change
    MailServer->>User: Failure Email - Invalid Change
    PythonScript->>Jenkins: Log Failure - Invalid Change
    PythonScript->>Jenkins: Exit

    Note over PythonScript: IF Change Ticket is Valid

    PythonScript->>AkamaiAPI: Schedule or Deploy Certificate
    PythonScript->>MailServer: Trigger Success Email
    MailServer->>User: Success Email - Deployment Complete
    PythonScript->>Jenkins: Return Output
    Jenkins->>Jira: Update Deployment Status
```

---
## Secrets Management with Vault

- Akamai credentials (EdgeGrid tokens) are securely retrieved from Vault.
- RBAC is enforced per subaccount.
- Secrets are audited, rotated, and TTL is applied.

---

## Entitlement Enforcement & ServiceNow Controls

### AD Group Validation

- Before triggering a renewal, the user's Active Directory (AD) group membership is validated.
- Only authorized groups mapped to the specific FQDN can initiate certificate renewals.

### ServiceNow/Deployment Controls

- Integration with Kong API is used to validate the ServiceNow Change Ticket (SNOW).
- Only approved changes proceed to certificate deployment.

---

## Certificate Pinning

- If certificate pinning is enabled, ISTO must confirm readiness to accept the new certificate.
- The pinning check occurs *after certificate renewal* but *before deployment*.
- A notification is sent to the relevant stakeholders including the certificate to be pinned.

---

## Benefits

| Legacy Limitation                  | New Design Improvement                                            |
|-----------------------------------|-------------------------------------------------------------------|
| Spreadsheet-based entitlement     | Real-time AD Group validation                                     |
| Hardcoded secrets                 | Vault-based dynamic secret injection                              |
| No structured workflow            | Jira-triggered automation with pipeline logic                     |
| Manual cert handling              | Automated CPS renewals and deployments                            |
| No change control link            | Optional SNOW Change ticket validation via Kong API               |
| Static observability              | Dynamic Jira logging and error propagation                        |

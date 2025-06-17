# Akamai AppSec Onboarding Automation

This repository contains a Python-based automation script for onboarding new Akamai security configurations across environments (NonProd and Prod). It streamlines the creation and reassignment of policies, match targets, rate limits, reputation profiles, client lists, and other key security controls.

## Features

- **Configuration Cloning**: Clone from a known template or NonProd policy.
- **Client List Handling**: Clone and rename security client lists per access group.
- **Policy Reassignment**: Automatically reassign match targets, custom rules, IP ACLs, rate limits, and more.
- **Environment-Aware**: Supports both NonProd (with deletion of temp policies) and Prod (with match target cloning logic).
- **Activation**: Initiates and monitors activation for specified environments.
- **Dry Run Support**: Preview planned changes before execution.

## Usage

```bash
python akamai_appsec_onboarding.py \
  --section DEV \
  --access_group WP-APAC-IN-CyberWASPTesting \
  --fqdn epspos-dev-wasp-01.hsbc.com.hk \
  --isProd true
```

### Key Arguments

| Argument         | Description                                               |
|------------------|-----------------------------------------------------------|
| `--section`       | Environment section (e.g. `DEV`, `PROD`, `UAT`)          |
| `--access_group`  | Logical group name to onboard (used in naming)           |
| `--fqdn`          | Primary FQDN (SANs can be inferred if needed)            |
| `--isProd`        | Boolean flag to indicate whether onboarding is for Prod  |

### Optional Parameters

| Argument         | Description                                      |
|------------------|--------------------------------------------------|
| `--template_config_name` | Name of existing template config to clone from (for NonProd) |
| `--template_policy_name` | Name of existing policy to clone (for NonProd)              |
| `--version_to_clone`     | Specific version to use when cloning config or policy       |
| `--emails`               | Notification list for activation                            |
| `--network`              | Activation network (`staging` or `production`)              |

## Modules Executed

The script automates the following modules during onboarding:

1. Clone and rename client lists
2. Clone or reassign match targets
3. Reassign custom rules
4. Reassign rate limits
5. Reassign reputation profiles
6. Reassign slow post protection
7. Reassign bot category actions
8. Reassign WAF group and rule exceptions
9. Reassign IP geo ACLs
10. Reassign DoS protection rate policies
11. Activate configuration and monitor

## Output

The script provides a detailed summary per module, including:

- Number of items processed
- Successes and failures
- Warnings on deprecated or missing elements
- Activation status for final deployment

## Notes

- Match targets for Prod are cloned and modified to avoid removing references from existing NonProd environments.
- Logic respects deprecated and `DELETE.available` status when deciding to reuse or recreate entities.
- A single JSON config defines group ID, contract ID, and region mapping.

## Example Workflow

1. **Dry Run**  
   Preview actions before committing.

2. **NonProd Onboarding**  
   Creates new config, policy, and performs direct reassignment.

3. **Prod Onboarding**  
   Clones from NonProd, modifies match targets, and reassigns safely.

4. **Activation**  
   Initiates and monitors the activation process.

## Requirements

- Python 3.7+
- `requests` module
- Akamai API credentials with access to AppSec APIs


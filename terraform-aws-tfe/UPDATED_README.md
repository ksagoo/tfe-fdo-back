
# Akamai AppSec Onboarding Automation

This repository contains a Python-based automation script for onboarding new Akamai security configurations across environments (NonProd and Prod). It streamlines the creation and reassignment of policies, match targets, rate limits, reputation profiles, client lists, DoS protections, and other key security controls.

## Features

- **Configuration Cloning**: Clone from a known template config or policy
- **Client List Handling**: Clone and rename security client lists per access group
- **Policy Reassignment**: Automatically reassign match targets, custom rules, IP ACLs, rate limits, DoS policies, and more
- **Environment-Aware**: Supports both NonProd (with deletion of temp policies) and Prod (with match target cloning logic)
- **DoS Rate Protection**: Updates DoS rate policy references using clean, validated payloads (read-only fields removed)
- **Activation**: Initiates and monitors activation for specified environments
- **Dry Run Support**: Preview planned changes before execution

## Usage

```bash
python akamai_appsec_onboarding.py \
  --section <SECTION> \
  --access_group <ACCESS_GROUP> \
  --fqdn <FQDN> \
  --template_config_name <TEMPLATE_NAME> \
  --isProd <true|false>
```

## Key Arguments

| Argument                | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| `--section`             | Account name (Dev, Global, EMEA, APAC, AMER)                                |
| `--access_group`        | Access group used for client list lookup and config scoping                 |
| `--fqdn`                | Hostname to apply security configuration to                                 |
| `--template_config_name`| Name of existing policy to clone (for NonProd)                              |
| `--version_to_clone`    | Specific version to use when cloning config or policy                       |
| `--emails`              | Notification list for activation                                            |
| `--network`             | Activation network (`staging` or `production`)                              |

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

- Requires valid Akamai API credentials (EdgeGrid auth)
- Python 3.x 
- Intended for HSBC internal use only

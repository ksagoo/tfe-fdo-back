# Akamai AppSec Onboarding Tool

This repository contains a Python-based onboarding automation tool designed to create and manage Akamai Application Security configurations, policies, and related client lists in a streamlined, automated fashion. The tool supports both Non-Production and Production environment provisioning using a clear and extensible CLI-based interface.

## Overview

This tool automates:

* Creation of Security Configurations and Policies
* Cloning from a pre-defined Security Policy Template (v1)
* Assignment of match targets, rules, protections, and exception lists
* Activation of cloned client lists (e.g., Rate Control Bypass)
* Consolidation of hostnames for Production policy deployment
* Adding version notes linked to change references (e.g., Jira)

## How It Works

### 1. Parse CLI Arguments

`parse_args()` collects inputs such as:

* `--section`: EdgeGrid credentials section
* `--access_group`: Business unit or group identifier
* `--fqdn`: Comma-separated list of hostnames
* `--isProd`: Flag to determine if this is a Production deployment
* `--version-notes`: Description or ticket to annotate version creation

### 2. Session Setup

* `setup_session()` reads EdgeGrid credentials from `.edgerc`
* `get_region_from_section()` resolves contract and group ID metadata

### 3. Determine Config and Policy Names

* Security Config name: `SC-<access_group>`
* Policy name: `PL-<access_group>-NonProd` or `PL-<access_group>-Prod`

### 4. Check for Existing Config and Policy

* `config_exists()` and `policy_exists()` validate presence of SC and policy

### 5. isProd Logic

#### If `isProd=True`:

* Verify Security Config and Non-Prod policy exist
* If not, abort
* If yes:

  * Call `onboard_prod_policy()`
  * Clone from Non-Prod policy
  * Clone match targets: `clone_match_targets_for_prod()`
  * Consolidate hostnames: `build_desired_fqdns()` and `ensure_config_hostnames()`
  * Set version notes: `set_config_version_notes()`
  * Done

#### If `isProd=False`:

* If SC not found, clone new SC from template using `create_security_config()`
* Get template policy ID using `get_policy_id_from_config()`
* Clone default policy: `create_default_policy()`
* Set version notes with ticket or description
* Assign hostnames
* Run `run_all_reassignments()` to rewire all settings:

  * `clone_and_rename_client_lists()` with staging activation
    * Wait only for `Rate Controls Bypass List` to become ACTIVE
  * `reassign_match_targets()`
  * `reassign_custom_rules()`
  * `reassign_rate_limits()`
  * `update_rate_policies()`
  * `reassign_reputation_profiles()`
  * `reassign_dos_protection_rate_policies()`
  * `reassign_slow_post_protection()`
  * `reassign_akamai_bot_category_actions()`
  * `reassign_waf_rule_exceptions()`
  * `reassign_waf_group_actions()`
  * `reassign_waf_overrides()`
  * `reassign_ip_geo_asn_lists()` using `build_cloned_list_id_map()`

* Finally, remove the temporary template policy via `delete_policy()`
* Print summary and exit

## Diagram

```mermaid
flowchart TD
  A[Start] --> B[Parse CLI arguments]
  B --> C[Setup session & region metadata]
  C --> D{isProd?}

  D -- "True (Prod)" --> P1[Check if Security Config<br>and NonProd Policy exist]
  P1 -->|Missing| PX[Abort:<br>prerequisites not met]
  P1 -->|Exists| P2[Create Prod Policy<br>cloned from NonProd]
  P2 --> P3[Copy match targets]
  P3 --> P4[Consolidate hostnames<br>into Security Config]
  P4 --> P5[Set version notes]
  P5 --> Z[Print summary]

  D -- "False (NonProd)" --> N1[Check if Security Config exists]
  N1 --> N2[If missing, clone from<br>Security Policy Template v1]
  N2 --> N3[Create Security Config<br>and NonProd Policy]
  N3 --> N4[Set version notes]
  N4 --> N5[Assign hostnames]
  N5 --> R

  subgraph R[Run all reassignments]
    R1[Clone and rename client lists] --> 
    R2[Activate client lists in STAGING] --> 
    R3[Wait for Rate Control Bypass list<br>to become ACTIVE] --> 
    R4[Reassign match targets] --> 
    R5[Reassign custom rules] --> 
    R6[Reassign rate limits] --> 
    R7[Update rate policies] --> 
    R8[Reassign reputation profiles] --> 
    R9[Reassign DoS protection rate policies] --> 
    R10[Reassign slow POST protection] --> 
    R11[Reassign Akamai bot category actions] --> 
    R12[Reassign WAF rule exceptions] --> 
    R13[Reassign WAF group actions] --> 
    R14[Reassign WAF overrides] --> 
    R15[Reassign IP/Geo/ASN lists]
  end

  R15 --> N6[Delete temporary<br>template policy]
  N6 --> Z[Print summary]
```

## Usage Examples

### Non-Prod Provisioning

```bash
python akamai_appsec_onboarding_complete.py   --section default   --access_group HSBC   --fqdn app.dev.hsbc.com   --version-notes "WAFAUTOJSD-1192"   --isProd false
```

### Prod Provisioning

```bash
python akamai_appsec_onboarding_complete.py   --section default   --access_group HSBC   --fqdn app.prod.hsbc.com   --version-notes "WAFAUTOJSD-1192"   --isProd true
```
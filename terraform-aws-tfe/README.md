# Akamai Application Security Configuration Pipeline

This repository provides an automated pipeline for generating and importing Akamai Application Security (AppSec) configurations using modular Jinja templates and Akamai APIs.

## Overview

The solution includes:

- YAML-based centralized configuration
- Jinja2 templates for each module (Client Lists, Rules, Bots, etc.)
- Two main scripts:
  - `akamai_config_generator.py`: Renders configuration files from templates and YAML.
  - `akamai_appsec_importer.py`: Imports rendered files into Akamai AppSec using API.
- Optional wrapper: `akamai_appsec_pipeline.py` for end-to-end orchestration.
- Supports dry-run, partial execution, and debug logging.

## Directory Structure

```
.
├── config/
│   └── appsec_config.yaml           # Input configuration
├── templates/
│   ├── client_list_template.j2
│   ├── custom_bot_templates.j2
│   ├── custom_rule_template.j2
│   ├── rate_limit_template.j2
│   ├── waf_rule_exceptions_template.j2
│   ├── waf_group_actions_template.j2
│   └── akamai_bot_category_actions_template.j2
├── generated/                       # Rendered JSON output
├── akamai_config_generator.py      # Jinja + YAML-based renderer
├── akamai_appsec_importer.py       # Akamai API importer
└── akamai_appsec_pipeline.py       # Wrapper script (optional)
```

## Prerequisites

- Python 3.7+
- `requests`, `PyYAML`, `jinja2`
- Akamai `.edgerc` file with appropriate credentials

Install dependencies:

```bash
pip install -r requirements.txt
```

If needed:

```bash
pip install requests PyYAML jinja2
```

## Script 1: Generate Configuration JSONs

### akamai_config_generator.py

**Description**: Generates JSON configuration files from a YAML input using Jinja2 templates.

**Usage**:

```bash
python akamai_config_generator.py \
  --config config/appsec_config.yaml \
  --template_dir templates \
  --output_dir generated \
  --dry_run
```

**Options**:
- `--config`: Path to the YAML configuration file.
- `--template_dir`: Directory containing `.j2` Jinja templates.
- `--output_dir`: Output folder for rendered JSON files.
- `--dry_run`: Optional. Prevents import into Akamai.

## Script 2: Import Configuration to Akamai

### akamai_appsec_importer.py

**Description**: Uploads the rendered JSONs into the Akamai AppSec API.

**Usage**:

```bash
python akamai_appsec_importer.py \
  --input_dir generated \
  --account DEV \
  --dry_run
```

**Options**:
- `--input_dir`: Folder where JSONs were rendered.
- `--account`: Akamai account/environment name. Must match the section in `.edgerc`.
- `--edgerc_file`: Path to `.edgerc`. Defaults to `~/.edgerc`.
- `--dry_run`: Optional. Skips actual API calls.

## Script 3: Combined Pipeline Runner

### akamai_appsec_pipeline.py

**Description**: Executes generation and import in sequence.

**Usage**:

```bash
python akamai_appsec_pipeline.py \
  --config config/appsec_config.yaml \
  --template_dir templates \
  --output_dir generated \
  --account DEV
```

**Optional Flags**:
- `--only_generate`: Generate only, skip import.
- `--only_import`: Import only, skip generation.
- `--dry_run`: Skip API calls.
- `--log_file pipeline.log`: Output all stdout/stderr to a log file.

## Notes

- The `access_group` in your YAML config must match the section name in `.edgerc`.
- Default account is `DEV` if not explicitly specified.
- Each module is modular. Missing files (e.g., no custom_bots) will be skipped gracefully.

## Example End-to-End Run

```bash
python akamai_appsec_pipeline.py \
  --config config/appsec_config.yaml \
  --template_dir templates \
  --output_dir generated \
  --account EMEA \
  --dry_run
```

This generates all templates and simulates import without pushing to Akamai.

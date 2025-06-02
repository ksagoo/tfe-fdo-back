# Akamai AppSec Automation

This repository contains a suite of Python scripts to **generate**, **import**, and optionally **delete** Akamai Application Security configurations using a YAML + Jinja2 templating approach.

## 📁 Overview

### 1. `akamai_config_generator.py`

Generates Akamai AppSec JSON configuration files from:
- A central YAML config file
- Jinja2 templates (one per module)

Supported modules:
- Client Lists
- Custom Bots
- Custom Rules
- Rate Limits
- WAF Rule Exceptions
- WAF Group Actions
- Akamai Bot Category Actions

#### Usage
```bash
python akamai_config_generator.py \
  --config config/appsec_config.yaml \
  --template_dir templates \
  --output_dir generated \
  --dry_run
```

---

### 2. `akamai_appsec_importer.py`

Imports the JSON files generated above into Akamai using the AppSec API. Uses `.edgerc` credentials.

#### Usage
```bash
python akamai_appsec_importer.py \
  --input_dir generated \
  --account EMEA \
  --dry_run
```

You can also set `--edgerc_file ~/.edgerc` if your `.edgerc` isn't in the default location.

---

### 3. `akamai_appsec_deleter.py` (Optional)

Used to **clean up** old or test configurations. Supports:
- Dry-run mode
- Selective deletion of client lists, rules, bots, etc.

---

### 4. `akamai_appsec_pipeline.py`

Wrapper script that ties together generation, import, and optional delete into a full automation pipeline.

#### Flags
- `--only_generate`: Only generate configs
- `--only_import`: Only import previously generated configs
- `--logfile path.log`: Log output to file
- `--dry_run`: No API calls will be made
- `--delete`: Enable deletion of pre-existing resources (if supported)

#### Example
```bash
python akamai_appsec_pipeline.py \
  --config config/appsec_config.yaml \
  --template_dir templates \
  --output_dir generated \
  --account DEV \
  --only_generate
```

---

## 🔧 Configuration

### YAML File (`appsec_config.yaml`)
Contains all data required to populate templates (rate limits, bot configs, etc.)

### Jinja2 Templates
One template per module:
```
templates/
├── client_list_template.j2
├── custom_bot_templates.j2
├── custom_rule_template.j2
├── rate_limit_template.j2
├── waf_rule_exceptions_template.j2
├── waf_group_actions_template.j2
└── akamai_bot_category_actions_template.j2
```

---

## 🔑 Authentication

### `.edgerc`
Used for authentication with the Akamai API.

Example:
```
[DEV]
client_secret = xxxx
host = xxxx.luna.akamaiapis.net
access_token = xxxx
client_token = xxxx
```

---

## 🚀 CI/CD Usage

Can be invoked in a GitLab, Jenkins or similar pipeline. Use `--dry_run` to validate before committing.

```bash
python akamai_appsec_pipeline.py --config config/appsec.yaml --template_dir templates --output_dir generated --account DEV --dry_run
```

---

## 🛠 Troubleshooting

- `ModuleNotFoundError`: Run `pip install -r requirements.txt`
- `UnicodeEncodeError`: Use `PYTHONIOENCODING=utf-8` or avoid special characters
- `.edgerc section not found`: Ensure the `[account]` section matches your `--account` value

---

## ✅ Requirements

```bash
pip install -r requirements.txt
```

Contents:
```
PyYAML
jinja2
requests
edgegrid-python
```
# Akamai CPS Certificate Enrollment Management Script

This Python script is designed to manage certificate enrollments using Akamai’s Certificate Provisioning System (CPS) API. It supports creating new enrollments (for both Domain Validated (DV) and Extended Validation (EV) certificates) and incorporates regional configuration. The script automatically derives the contract ID based on the selected region and can adjust network settings via a ChinaCDN flag.

## Features

- **Create Enrollment**:  
  Build and optionally send an enrollment creation request.
  - Supports both DV and EV enrollments.
  - Accepts CSR details, network configuration, and (if EV) full admin and tech contact details.
  - Includes a `--chinacdn` flag to adjust the network configuration geography (`"china+core"` vs. `"core"`).
  - Automatically derives the contract ID based on the region provided via the `--account` parameter.
  - If the `--create` flag is not provided, the script outputs the enrollment JSON payload without sending it.

## Prerequisites

- **Python 3.x**
- The following Python packages:
  - `requests`
  - `akamai-edgegrid`

Install the required packages using:

```bash
pip install requests akamai-edgegrid

Usage

The script is executed from the command line. Below are examples for various operations:
Create Enrollment (Output JSON Only)

This command builds the enrollment payload and outputs it without sending the request:

python cps_enrollment_creation.py --operation create --common_name "example.com" \
  --csr_org "Example Corp" --account Global \
  --admin_email "admin@example.com" --admin_first_name "John" --admin_last_name "Doe" \
  --admin_phone "800-555-1234" --admin_org "Example Corp" --admin_address1 "123 Main St" \
  --admin_city "San Diego" --admin_region "CA" --admin_country "US" --admin_postal "92101" \
  --admin_title "Administrator" \
  --tech_email "tech@example.com" --tech_first_name "Jane" --tech_last_name "Doe" \
  --tech_phone "617-555-0111" --tech_org "Example Corp" --tech_title "Engineer"

Create Enrollment (Send Request)

To send the enrollment creation request, use the --create flag. For example, with ChinaCDN enabled:

python cps_enrollment_creation.py --operation create --common_name "example.com" --create --account APAC --chinacdn true \
  --csr_org "Example Corp" \
  --admin_email "admin@example.com" --admin_first_name "John" --admin_last_name "Doe" \
  --admin_phone "800-555-1234" --admin_org "Example Corp" --admin_address1 "123 Main St" \
  --admin_city "San Diego" --admin_region "CA" --admin_country "US" --admin_postal "92101" \
  --admin_title "Administrator" \
  --tech_email "tech@example.com" --tech_first_name "Jane" --tech_last_name "Doe" \
  --tech_phone "617-555-0111" --tech_org "Example Corp" --tech_title "Engineer"

Note: The contract ID is automatically derived from the region specified via --account.
Regional Contract Mapping

The script supports the following regions (provided via --account), which automatically assign a corresponding contract ID:

    Global: Contract ID "a"
    APAC: Contract ID "b"
    EMEA: Contract ID "c"
    LATAM: Contract ID "d"
    AMER: Contract ID "e"
    DEV: Contract ID "f"

Update the REGION_SETTINGS dictionary in the script with your actual contract IDs as needed.
Parameters Summary

    Operation Parameters:
        --operation: Specifies the operation to perform (currently only create is supported in this module).

    CSR and Enrollment Details (for Create):
        --common_name: Required; primary domain name.
        --san: Optional; additional domains.
        --csr_country, --csr_state, --csr_locality: CSR fields (defaults provided).
        --csr_org: Required.
        --preferred_trust_chain: Optional.
        --validation_type: Defaults to ev (for EV enrollments); can also be set to dv for DV.
        --ra, --certificate_type, --change_management: Additional configuration.

    Regional & Network Configuration:
        --chinacdn: Boolean flag. If true, sets geography to "china+core"; otherwise, "core".
        --account: Region (allowed: Global, APAC, EMEA, LATAM, AMER, DEV). Automatically derives the contract ID.

    Admin and Tech Contact Details (for EV enrollments):
        Admin: --admin_email, --admin_first_name, --admin_last_name, --admin_phone, --admin_org, --admin_address1, --admin_city, --admin_region, --admin_country, --admin_postal, --admin_title.
        Tech: --tech_email, --tech_first_name, --tech_last_name, --tech_phone, --tech_org, --tech_title.

    Edgerc File Parameter:
        --edgerc_file: Path to the credentials file (default: ~/.edgerc.txt).

    Sending the Request:
        --create: If set, sends the enrollment request. If not set, the script outputs the JSON payload only.

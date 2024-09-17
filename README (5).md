
# Akamai Access Group Management Script

## Overview
This script is designed to manage the creation of access groups within the Akamai platform. It checks whether a specified group exists under a particular parent group, and if it doesn't, it creates the group. The script also supports creating up to four levels of subgroups based on the specified level.

## Features
- Checks if a group exists before attempting to create it.
- Supports creation of up to four levels of subgroups:
  - **Level 1:** Top-level group.
  - **Level 2:** Regional subgroups (APAC, EMEA, AMER, Global).
  - **Level 3:** Service/Country subgroups under each regional subgroup.
  - **Level 4:** NonProd and Prod subgroups under each Service/Country subgroup.
- Supports environment-specific configurations (DEV or PROD).
- Reads Akamai API credentials from a `.edgerc` file.

## Usage
```bash
python script.py "LOB" "CountryServiceName" [options]
```

### Command Line Arguments
- `LOB` (required): Line of Business, e.g., `TEST01`.
- `CountryServiceName` (required): Country or Service Name, e.g., `AkamaiDevOps`.
- `--group_prefix`: The prefix for the group name. Default is `HSBC-DDoS-KSD`.
- `--regions`: Regions for which subgroups will be created (APAC, EMEA, AMER, Global). Default is all four.
- `--parent_group_name`: The name of the parent group. Provide either this or `--parent_group_id`.
- `--parent_group_id`: The numeric ID of the parent group. Provide either this or `--parent_group_name`.
- `--env`: The environment (DEV or PROD). Default is `DEV`.
- `--edgerc_file`: Path to the `.edgerc` file. Default is `~/.edgerc`.
- `--section_name`: Section name in the `.edgerc` file. Default is `default`.
- `--levels`: Levels to create (1, 2, 3, or 4). Default is `4`.

### Examples
1. **Create only the top-level group:**
   ```bash
   python script.py "LOB" --levels=1
   ```

2. **Create up to regional subgroups:**
   ```bash
   python script.py "LOB" "CountryServiceName" --levels=2
   ```

3. **Create up to service-level subgroups:**
   ```bash
   python script.py "LOB" "CountryServiceName" --levels=3
   ```

4. **Create all levels (default):**
   ```bash
   python script.py "LOB" "CountryServiceName" --levels=4
   ```

5. **Create a group in the DEV environment with a default parent group ID:**
   ```bash
   python script.py "LOB" "CountryServiceName" --env=DEV
   ```

6. **Create a group in the PROD environment using a specific parent group ID:**
   ```bash
   python script.py "LOB" "CountryServiceName" --env=PROD --parent_group_id=1234567
   ```

## Notes
- The script will avoid creating duplicate groups by checking the existence of each group and subgroup before attempting to create them.
- If both `--parent_group_name` and `--parent_group_id` are provided, the script will use the `--parent_group_id` as the primary identifier.
- The `Global` region will maintain its capitalization, unlike other regions, which are converted to uppercase.

## Setup
1. **Install Dependencies:**
   Ensure you have the necessary Python packages installed:
   ```bash
   pip install requests akamai.edgegrid
   ```

2. **Set Up the `.edgerc` File:**
   Create a `.edgerc` file with the following sections:
   ```ini
   [default]
   host = your_host
   client_token = your_client_token
   client_secret = your_client_secret
   access_token = your_access_token
   ```

3. **Run the Script:**
   Use the command line options described above to execute the script according to your needs.

## Troubleshooting
If you encounter any issues, ensure that:
- The `.edgerc` file is correctly configured and accessible.
- The specified parent group exists if using `--parent_group_name`.
- The environment is set correctly (DEV or PROD).

## License
This script is licensed under the MIT License.

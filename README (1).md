
# Akamai Access Group Management Script

## Description

This script is designed to manage the creation of Akamai access groups. It checks if a group exists under a specified parent group and creates it if it does not exist. The script also supports the creation of regional subgroups (APAC, EMEA, AMER) under the newly created group. Additionally, `Prod` and `PreProd` subgroups are automatically created under each regional subgroup.

## Features

- **Group Creation**: Automatically creates a group under a specified parent group.
- **Regional Subgroups**: Creates regional subgroups (`APAC`, `EMEA`, `AMER`) under the new group.
- **Automatic Subgroups**: Automatically adds `Prod` and `PreProd` subgroups under each regional subgroup.
- **Environment-Specific Defaults**: Uses different default parent group IDs depending on the environment (`DEV` or `PROD`).
- **Flexible Configuration**: Allows the use of either a parent group name or ID, along with customizable group prefixes and regions.

## Requirements

- Python 3.x
- `requests` library
- `akamai-edgegrid` library

To install the required libraries, use the following command:
```bash
pip install requests akamai-edgegrid
```

## Usage

### Command-Line Arguments

- `group_name_segment` (required): The name segment of the group to create.
- `--group_prefix`: The prefix for the group name. Default is `KSSS-DDoS-KSD`.
- `--regions`: Regions for which subgroups will be created (`APAC`, `EMEA`, `AMER`). Default is all three.
- `--parent_group_name`: The name of the parent group. Provide either this or `--parent_group_id`.
- `--parent_group_id`: The numeric ID of the parent group. Provide either this or `--parent_group_name`.
- `--env`: The environment (`DEV` or `PROD`). Default is `DEV`.
- `--edgerc_file`: Path to the `.edgerc` file. Default is `~/.edgerc`.
- `--section_name`: Section name in the `.edgerc` file. Default is `default`.

### Example Commands

1. **Create a group in the DEV environment with a default parent group ID:**
    ```bash
    python script.py "NewGroupNameSegment" --env=DEV
    ```

2. **Create a group in the PROD environment using a specific parent group ID:**
    ```bash
    python script.py "NewGroupNameSegment" --env=PROD --parent_group_id=1234567
    ```

3. **Create a group using a parent group name:**
    ```bash
    python script.py "NewGroupNameSegment" --parent_group_name="Main Street Corporation"
    ```

4. **Create a group using a parent group ID in the PROD environment:**
    ```bash
    python script.py "NewGroupNameSegment" --env=PROD --parent_group_id=1234567
    ```

5. **Create a group with a custom prefix and specific regions:**
    ```bash
    python script.py "NewGroupNameSegment" --group_prefix="ABCD-DDoS-BSB" --regions APAC EMEA --env=DEV
    ```

### Notes

- Under each regional subgroup (`APAC`, `EMEA`, `AMER`), `Prod` and `PreProd` subgroups are automatically created.

## Contributing

If you would like to contribute to this project, feel free to fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

For any questions or issues, please contact [Your Name](mailto:your.email@example.com).

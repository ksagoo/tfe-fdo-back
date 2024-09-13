
# Akamai Access Group Management Script

This script manages the creation of Akamai access groups. It checks if a group exists under a specified parent group and creates it if it does not exist. The script is designed to work in different environments (DEV or PROD) and provides flexibility in specifying the parent group by either name or ID.

## Features

- **Environment-Aware**: Operates differently in DEV and PROD environments.
- **Parent Group Flexibility**: Allows specification of parent groups by either name or ID.
- **Group Existence Check**: Ensures a group is only created if it does not already exist under the specified parent group.

## Parameters

### Required

- **`group_name`**: The name of the group to create.
  - **Usage**: `"NewGroupName"`

### Optional

- **`--parent_group_name`**: The name of the parent group. Use this if the parent group is identified by name rather than ID.
  - **Usage**: `--parent_group_name="Main Street Corporation"`

- **`--parent_group_id`**: The numeric ID of the parent group. Takes precedence over `--parent_group_name` if both are provided.
  - **Usage**: `--parent_group_id=1234567`

- **`--env`**: The environment in which the script is running. Defaults to `DEV`.
  - **Values**:
    - `DEV` (default): Uses `parent_group_id = 199633`.
    - `PROD`: Uses `parent_group_id = 1234567`.
  - **Usage**: `--env=DEV` or `--env=PROD`

- **`--edgerc_file`**: The path to the `.edgerc` file containing Akamai credentials.
  - **Default**: `~/.edgerc`
  - **Usage**: `--edgerc_file="/path/to/.edgerc"`

- **`--section_name`**: The section name in the `.edgerc` file to use for credentials.
  - **Default**: `default`
  - **Usage**: `--section_name="section_name"`

## Usage Examples

### Create a group in the DEV environment with the default parent group ID:

```bash
python script.py "NewGroupName" --env=DEV
```

### Create a group in the PROD environment with the default parent group ID:

```bash
python script.py "NewGroupName" --env=PROD
```

### Create a group in the DEV environment using a specific parent group ID:

```bash
python script.py "NewGroupName" --env=DEV --parent_group_id=199633
```

### Create a group in the PROD environment using a specific parent group ID:

```bash
python script.py "NewGroupName" --env=PROD --parent_group_id=1234567
```

### Create a group using a parent group name in the DEV environment:

```bash
python script.py "NewGroupName" --parent_group_name="Main Street Corporation" --env=DEV
```

### Create a group using a parent group name in the PROD environment:

```bash
python script.py "NewGroupName" --parent_group_name="Main Street Corporation" --env=PROD
```

### Create a group using a parent group ID (ignores `--parent_group_name` if both are provided):

```bash
python script.py "NewGroupName" --parent_group_id=199633 --parent_group_name="Main Street Corporation"
```

### Specify a custom `.edgerc` file and section name:

```bash
python script.py "NewGroupName" --parent_group_id=199633 --edgerc_file="/path/to/.edgerc" --section_name="custom_section"
```

## Notes

- **Parent Group Priority**: If both `--parent_group_name` and `--parent_group_id` are provided, `--parent_group_id` takes precedence.
- **Default Behavior**: If neither `--parent_group_name` nor `--parent_group_id` are provided, the script defaults to using `parent_group_id = 199633` for `DEV` and `parent_group_id = 1234567` for `PROD`.

## License

This project is licensed under the MIT License.

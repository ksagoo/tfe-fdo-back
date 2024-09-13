
# Detailed Explanation of the Akamai Access Group Management Script

## Overview

The Akamai Access Group Management Script is a Python-based tool designed to automate the management of access groups within the Akamai platform. It checks whether a specified group exists under a particular parent group, and if not, it creates the group along with regional subgroups (APAC, EMEA, AMER). Each regional subgroup further includes automatically created `Prod` and `PreProd` subgroups. The script is environment-aware, allowing it to function differently based on whether it is running in a development (DEV) or production (PROD) environment. It also offers flexibility by allowing the user to specify the parent group by either name or ID.

## Script Components in Logical Flow Order

### 1. `main` Function

```python
def main():
```

The `main` function coordinates the script's overall flow, handling parameter parsing, environment setup, and function calls.

**Parameters:**
- **`group_name_segment` (required):** The name segment for the group to create.
- **`--group_prefix` (optional):** The prefix for the group name. Default is `KSSS-DDoS-KSD`.
- **`--regions` (optional):** Specifies the regions for which subgroups will be created (`APAC`, `EMEA`, `AMER`). Default is all three regions.
- **`--parent_group_name` (optional):** The name of the parent group. You must provide either this or `--parent_group_id`.
- **`--parent_group_id` (optional):** The numeric ID of the parent group. You must provide either this or `--parent_group_name`.
- **`--env` (optional):** The environment (`DEV` or `PROD`). Default is `DEV`. This determines the default parent group ID.
- **`--edgerc_file` (optional):** Path to the `.edgerc` file for Akamai API authentication. Default is `~/.edgerc`.
- **`--section_name` (optional):** Section name in the `.edgerc` file. Default is `default`.

**Key Steps:**
- Parses command-line arguments, including `group_name_segment`, `parent_group_name`, `parent_group_id`, `env`, `edgerc_file`, and `section_name`.
- Trims any leading or trailing spaces from `group_name_segment`, `group_prefix`, and `parent_group_name`.
- Sets the default `parent_group_id` based on the `env` parameter (`DEV` or `PROD`).

### 2. `setup_session` Function

```python
def setup_session(edgerc_file, section_name):
```

This function establishes a session with the Akamai API using credentials stored in a `.edgerc` file.

**Parameters:**
- **`edgerc_file`:** Path to the `.edgerc` file containing Akamai API credentials.
- **`section_name`:** The section name within the `.edgerc` file to use for retrieving credentials.

**Returns:**
- A session object configured with the necessary authentication headers, and the base URL for the Akamai API.

**Key Steps:**
- Reads the `.edgerc` file.
- Extracts the host, client token, client secret, and access token from the specified section.
- Sets up the session with `EdgeGridAuth` for secure API communication.

### 3. `check_group_exists` Function

```python
def check_group_exists(session, base_url, group_name, parent_group_name=None, parent_group_id=None):
```

This function coordinates the search for the parent group and checks for the existence of the specified group under it.

**Parameters:**
- **`session`:** The session object configured for API communication.
- **`base_url`:** The base URL of the Akamai API.
- **`group_name`:** The name of the group to check for.
- **`parent_group_name`:** The name of the parent group.
- **`parent_group_id`:** The ID of the parent group.

**Returns:**
- A tuple `(group_exists, existing_group_id, resolved_parent_group_id)` indicating whether the group exists, the ID of the existing group, and the ID of the resolved parent group.

**Key Steps:**
- Calls the Akamai API to retrieve the list of groups.
- Uses `find_group_by_name_or_id` to locate the parent group.
- Calls `check_group_exists_under_parent` to check for the existence of the specified group.
- Returns the results of the check.

### 4. `find_group_by_name_or_id` Function

```python
def find_group_by_name_or_id(groups, parent_group_name=None, parent_group_id=None):
```

This function recursively searches through the group hierarchy to find a parent group based on either its name or ID.

**Parameters:**
- **`groups`:** The list of groups and subgroups to search within.
- **`parent_group_name`:** The name of the parent group to search for.
- **`parent_group_id`:** The numeric ID of the parent group to search for.

**Returns:**
- The parent group object if found, otherwise `None`.

**Key Steps:**
- Iterates through the provided groups.
- If a group matches the `parent_group_name` or `parent_group_id`, it returns that group.
- Recursively searches through subgroups if the group is not found at the current level.

## Summary

This document provides a detailed explanation of the Akamai Access Group Management Script. The script is designed to automate the creation and management of access groups within the Akamai platform, ensuring that necessary groups and subgroups are created under specified parent groups. It is environment-aware, functioning differently based on whether it is running in a development or production environment.

The main function orchestrates the script's flow, setting up the necessary session and checking for the existence of groups. If a group does not exist, the script creates it, along with regional subgroups (APAC, EMEA, AMER) and their respective Prod and PreProd subgroups. The script is highly flexible, allowing for group creation based on either a parent group name or ID.

## Usage

Here are some examples of how to execute the script:

1. **Create a group in the DEV environment with a default parent group ID:**

   ```bash
   python script.py "TestGroup" --env=DEV
   ```

2. **Create a group in the PROD environment with a specific parent group ID:**

   ```bash
   python script.py "ProdGroup" --env=PROD --parent_group_id=1234567
   ```

3. **Create a group using a parent group name:**

   ```bash
   python script.py "NamedGroup" --parent_group_name="Main Street Corporation"
   ```

4. **Create a group with a custom prefix in the DEV environment:**

   ```bash
   python script.py "CustomSegment" --group_prefix="ABCD-DDoS-KSD" --env=DEV
   ```

5. **Create a group and specify regions for subgroups:**

   ```bash
   python script.py "RegionalGroup" --regions="APAC,EMEA" --env=DEV
   ```

6. **Specify a custom `.edgerc` file and section name:**

   ```bash
   python script.py "CustomEdgercGroup" --parent_group_id=199633 --edgerc_file="/path/to/.edgerc" --section_name="custom_section"
   ```

## Summary

This document provides a detailed explanation of the Akamai Access Group Management Script. The script is designed to automate the creation and management of access groups within the Akamai platform, ensuring that necessary groups and subgroups are created under specified parent groups. It is environment-aware, functioning differently based on whether it is running in a development or production environment.

The main function orchestrates the script's flow, setting up the necessary session and checking for the existence of groups. If a group does not exist, the script creates it, along with regional subgroups (APAC, EMEA, AMER) and their respective Prod and PreProd subgroups. The script is highly flexible, allowing for group creation based on either a parent group name or ID.

### 5. `check_group_exists_under_parent` Function

```python
def check_group_exists_under_parent(parent_group, group_name):
```

This function checks if a specific group exists under the identified parent group.

**Parameters:**
- **`parent_group`:** The parent group object under which to search.
- **`group_name`:** The name of the group to check for.

**Returns:**
- A tuple `(True, groupId)` if the group exists, or `(False, None)` if it does not.

**Key Steps:**
- Iterates through the subgroups of the parent group.
- If a subgroup matches the `group_name`, it returns `True` along with the group's ID.
- If no match is found, it returns `False`.

### 6. `create_group` Function

```python
def create_group(session, base_url, group_name, parent_group_id):
```

This function creates a new group under the specified parent group.

**Parameters:**
- **`session`:** The session object configured for API communication.
- **`base_url`:** The base URL of the Akamai API.
- **`group_name`:** The name of the group to create.
- **`parent_group_id`:** The ID of the parent group under which the new group will be created.

**Key Steps:**
- Constructs the API endpoint URL using the `parent_group_id`.
- Sends a POST request to the Akamai API to create the group.
- Prints the result, including the new group's ID if the creation is successful.

### 7. `ensure_subgroups` Function

```python
def ensure_subgroups(session, base_url, parent_group_id, region):
```

This function ensures that regional subgroups (`APAC`, `EMEA`, `AMER`) and their respective `Prod` and `PreProd` subgroups are created under the specified parent group.

**Parameters:**
- **`session`:** The session object configured for API communication.
- **`base_url`:** The base URL of the Akamai API.
- **`parent_group_id`:** The ID of the parent group under which the regional subgroups will be created.
- **`region`:** The region name to append to the subgroup names.

**Key Steps:**
- Constructs the regional group name and checks if it exists.
- Creates the regional group if it does not exist.
- Ensures that `Prod` and `PreProd` subgroups are created under the regional group.

## Usage

Here are some examples of how to execute the script:

1. **Create a group in the DEV environment with a default parent group ID:**

   ```bash
   python script.py "TestGroup" --env=DEV
   ```

2. **Create a group in the PROD environment with a specific parent group ID:**

   ```bash
   python script.py "ProdGroup" --env=PROD --parent_group_id=1234567
   ```

3. **Create a group using a parent group name:**

   ```bash
   python script.py "NamedGroup" --parent_group_name="Main Street Corporation"
   ```

4. **Create a group with a custom prefix in the DEV environment:**

   ```bash
   python script.py "CustomSegment" --group_prefix="ABCD-DDoS-KSD" --env=DEV
   ```

5. **Create a group and specify regions for subgroups:**

   ```bash
   python script.py "RegionalGroup" --regions="APAC,EMEA" --env=DEV
   ```

6. **Specify a custom `.edgerc` file and section name:**

   ```bash
   python script.py "CustomEdgercGroup" --parent_group_id=199633 --edgerc_file="/path/to/.edgerc" --section_name="custom_section"
   ```

### 5. `check_group_exists_under_parent` Function

```python
def check_group_exists_under_parent(parent_group, group_name):
```

This function checks if a specific group exists under the identified parent group.

**Parameters:**
- **`parent_group`:** The parent group object under which to search.
- **`group_name`:** The name of the group to check for.

**Returns:**
- A tuple `(True, groupId)` if the group exists, or `(False, None)` if it does not.

**Key Steps:**
- Iterates through the subgroups of the parent group.
- If a subgroup matches the `group_name`, it returns `True` along with the group's ID.
- If no match is found, it returns `False`.

### 7. `ensure_subgroups` Function

```python
def ensure_subgroups(session, base_url, parent_group_id, region):
```

This function ensures that regional subgroups (`APAC`, `EMEA`, `AMER`) and their respective `Prod` and `PreProd` subgroups are created under the specified parent group.

**Parameters:**
- **`session`:** The session object configured for API communication.
- **`base_url`:** The base URL of the Akamai API.
- **`parent_group_id`:** The ID of the parent group under which the regional subgroups will be created.
- **`region`:** The region name to append to the subgroup names.

**Key Steps:**
- Constructs the regional group name and checks if it exists.
- Creates the regional group if it does not exist.
- Ensures that `Prod` and `PreProd` subgroups are created under the regional group.

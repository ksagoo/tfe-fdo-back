
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

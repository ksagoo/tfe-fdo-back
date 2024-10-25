# Akamai Security Configuration Activation Script

This script is designed to activate security configurations on the Akamai platform. It allows users to specify either a configuration name or ID for activation, and optionally compare a new configuration version with the currently active one. The script also includes functionality to check the status of ongoing activations.

## Features
- **Activate Security Configurations**: Activate a specific security configuration by ID or name.
- **Version Comparison**: Compare the new version to be activated with the current active version before activation.
- **Activation Status**: Check the status of an ongoing activation using the activation ID.
- **Flexible Inputs**: Support for both config name and config ID as inputs, with version and environment selection.
- **Notification Emails**: Specify notification emails to receive updates on the activation status.

## Prerequisites
- **Python 3.x**
- **Akamai EdgeGrid Authentication**: The script uses Akamai’s EdgeGrid authentication, which requires an `.edgerc` file with the appropriate API credentials.

### Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/your-repository-url.git
    cd your-repository-url
    ```

2. Install the required Python packages:
    ```bash
    pip install requests akamai.edgegrid
    ```

3. Ensure your `.edgerc` file is configured with the necessary Akamai credentials. Example `.edgerc`:
    ```ini
    [default]
    client_token = akab-client-token
    client_secret = akab-client-secret
    access_token = akab-access-token
    host = akab-baseurl.luna.akamaiapis.net
    ```

## Usage

### Monitor Activation Status
Check the status of an activation by providing the activation ID:
```bash
python activate_security.py --activation_id 1234

Compare Versions Before Activation
Optionally compare the current active version with the target version before activating:

bash
Copy code
python activate_security.py --config_name "Corporate Sites WAF" --config_version v9 --compare Y
Activate Configuration Using Config ID
Alternatively, activate a configuration using its ID without version comparison:

bash
Copy code
python activate_security.py --config_id 7180 --config_version v9 --network staging --compare N
Parameters
Parameter	Description
--config_id	(Optional) The ID of the security configuration. Use this or --config_name.
--config_name	(Optional) The name of the security configuration. Use this or --config_id.
--config_version	(Required) The version of the security configuration to activate, in the format 'v1', 'v2', etc.
--network	(Optional) The network to activate on (staging or production). Default is staging.
--note	(Optional) A note to include with the activation request. Default is "New Version to Activate".
--emails	(Optional) Notification emails for activation status updates. Default is aactivation@test.com.
--edgerc_file	(Optional) Path to the .edgerc file for Akamai API authentication. Default is ~/.edgerc.
--section_name	(Optional) Section name in the .edgerc file. Default is default.
--activation_id	(Optional) Activation ID to check the status of an ongoing activation.
--compare	(Optional) Whether to compare the current active version with the target version (Y or N). Default is N.
Functionality Overview
Activation
The script activates a specified configuration version on the chosen network (staging or production) using either a configuration name or ID. If successful, it provides the activation ID and begins monitoring the activation status if requested.

Status Monitoring
After initiating an activation, the script periodically checks the activation status until it is ACTIVATED. During this time, concise status updates are provided. Once activated, a detailed JSON output of the activation data is displayed.

Version Comparison
When --compare Y is specified, the script compares the current active version with the target version. Differences between the versions are displayed in JSON format.

Output
The script outputs results in a JSON format, both on the console and in the configNames.json file if specified. Detailed activation data and configuration differences are also printed in JSON when applicable.

.edgerc Configuration
Ensure your .edgerc file includes the necessary credentials for API authentication:

ini
Copy code
[default]
client_token = your_client_token
client_secret = your_client_secret
access_token = your_access_token
host = your_akamai_host
Error Handling
The script provides clear messages for:

Missing required arguments
Incorrect .edgerc configurations
HTTP status errors for API calls

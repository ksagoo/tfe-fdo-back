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

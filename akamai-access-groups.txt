Python Script: akamai_access_group.py
python
Copy code
import os
import requests
from akamai.edgegrid import EdgeGridAuth, EdgeRc

# Load credentials from the .edgerc file
edgerc = EdgeRc(os.path.expanduser("~/.edgerc"))
section = "default"  # Change to the desired section, e.g., "production"

# Set up the base URL and session with credentials
base_url = f"https://{edgerc.get(section, 'host')}/"
session = requests.Session()
session.auth = EdgeGridAuth.from_edgerc(edgerc, section)

def check_access_group_exists(session, base_url, group_name):
    """
    Check if an access group with the given name already exists.
    
    Parameters:
    - session: The authenticated session object.
    - base_url: The base URL for the Akamai API.
    - group_name: The name of the access group to check.
    
    Returns:
    - True if the group exists, False otherwise.
    """
    endpoint = f"{base_url}identity/v1/groups"
    response = session.get(endpoint)

    if response.status_code == 200:
        groups = response.json()
        for group in groups['groups']:
            if group['groupName'] == group_name:
                return True
    else:
        print(f"Error fetching access groups: {response.status_code}")
    return False

def create_access_group(session, base_url, group_name, description):
    """
    Create a new access group if it doesn't already exist.
    
    Parameters:
    - session: The authenticated session object.
    - base_url: The base URL for the Akamai API.
    - group_name: The name of the access group to create.
    - description: A description for the new access group.
    """
    if not check_access_group_exists(session, base_url, group_name):
        endpoint = f"{base_url}identity/v1/groups"
        payload = {
            "groupName": group_name,
            "description": description
        }
        response = session.post(endpoint, json=payload)
        if response.status_code == 201:
            print(f"Access group '{group_name}' created successfully.")
        else:
            print(f"Failed to create access group. Status code: {response.status_code}")
            print(f"Response: {response.text}")
    else:
        print(f"Access group '{group_name}' already exists.")

# Define the group name and description
group_name = "NewAccessGroup"
description = "This is a description for the new access group."

# Create the access group
create_access_group(session, base_url, group_name, description)
requirements.txt
text
Copy code
requests==2.31.0
akamai-edgegrid==2.2.4
Instructions for Running the Script
Create and Set Up the .edgerc File:

Create a .edgerc file in your home directory (~/.edgerc).
Add your Akamai credentials under the appropriate section (e.g., [default]).
Example .edgerc file:

text
Copy code
[default]
client_secret = your_client_secret
host = your_akamai_host
access_token = your_access_token
client_token = your_client_token
Install the Required Python Packages:

Navigate to the directory containing your script and requirements.txt file.
Install the necessary packages using pip:
bash
Copy code
pip install -r requirements.txt
Run the Script:

Run the script using Python:
bash
Copy code
python akamai_access_group.py
Switching Environments:

If you need to use a different set of credentials (e.g., for a production environment), simply modify the section variable in the script to match the desired section in your .edgerc file.
Directory Structure
Your project directory should look something like this:

bash
Copy code
/my-akamai-project/
│
├── akamai_access_group.py
├── requirements.txt
└── ~/.edgerc  # This is stored in your home directory
This setup provides a clean and organized way to manage dependencies and configurations, ensuring that your script works reliably across different environments.

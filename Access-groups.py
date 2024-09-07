pip install requests akamai-open

import requests
from akamai.edgegrid import EdgeGridAuth

# Replace these with your actual Akamai credentials
base_url = "https://{your_account}.akamaiapis.net/"
client_token = "your_client_token"
client_secret = "your_client_secret"
access_token = "your_access_token"

session = requests.Session()
session.auth = EdgeGridAuth(
    client_token=client_token,
    client_secret=client_secret,
    access_token=access_token
)

def check_access_group_exists(session, base_url, group_name):
    endpoint = f"{base_url}/identity/v1/groups"
    response = session.get(endpoint)

    if response.status_code == 200:
        groups = response.json()
        for group in groups['groups']:
            if group['groupName'] == group_name:
                return True
    return False

def create_access_group(session, base_url, group_name, description):
    if not check_access_group_exists(session, base_url, group_name):
        endpoint = f"{base_url}/identity/v1/groups"
        payload = {
            "groupName": group_name,
            "description": description
        }
        response = session.post(endpoint, json=payload)
        if response.status_code == 201:
            print(f"Access group '{group_name}' created successfully.")
        else:
            print(f"Failed to create access group. Status code: {response.status_code}")
    else:
        print(f"Access group '{group_name}' already exists.")

group_name = "NewAccessGroup"
description = "This is a description for the new access group."

create_access_group(session, base_url, group_name, description)

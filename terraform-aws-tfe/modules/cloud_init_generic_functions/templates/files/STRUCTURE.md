# Folder Structure

```
akamai_cps_module/
├── akamai_cps_manager.py        # Main CPS automation module
├── templates/
│   ├── 10Days-EscalationNotificationEmail.html
│   └── 7Days-RenewalNotificationEmail.html
├── json_samples/
│   ├── renew_dryrun_output.json
│   ├── deploy_dryrun_output.json
│   ├── status_dryrun_output.json
│   ├── poll_deployment_success.json
│   └── poll_deployment_failure.json
├── docs/
│   ├── README.md
│   ├── TESTCASES.md
│   ├── DEBUG_GUIDE.md
│   └── STRUCTURE.md
└── README.md                    # Confluence overview file
```

Each JSON sample file maps directly to its corresponding dry-run scenario.

# Developer Folder Layout and Comments

```
akamai_cps_module/
├── akamai_cps_manager.py         # Core CPS logic (renew, deploy, poll)
├── helpers/
│   ├── edgegrid_session.py       # Handles EdgeGrid authentication setup
│   └── utils.py                  # Shared helpers for date/time/validation
├── templates/
│   ├── CertRenewalNotification.html
│   ├── 10Days-EscalationNotificationEmail.html
│   └── 7Days-RenewalNotificationEmail.html
├── json_samples/
│   ├── renew_dryrun_output.json
│   ├── deploy_dryrun_output.json
│   ├── poll_deployment_success.json
│   └── poll_deployment_failure.json
├── docs/
│   ├── README.md
│   ├── TESTCASES_DEV.md
│   ├── DEBUG_GUIDE_DEV.md
│   └── STRUCTURE_DEV.md
└── logs/
    └── akamai_cps_debug.log
```

> Each `.json` file under `json_samples/` represents a dry-run output.  
> The `/logs/` folder is created dynamically during runtime.

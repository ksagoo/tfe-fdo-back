# Developer Test Scenarios and Command References

## Dry-Run Scenarios
| Scenario | Command | Expected Output |
|-----------|----------|----------------|
| Renewal simulation | `python akamai_cps_manager.py --action renew_only --dry-run` | `renew_dryrun_output.json` |
| Deployment simulation | `python akamai_cps_manager.py --action deploy_only --dry-run` | `deploy_dryrun_output.json` |
| Full lifecycle | `python akamai_cps_manager.py --action renew_and_deploy --dry-run` | Combined JSON output |

---

## Live Scenarios
| Scenario | Command | Validation |
|-----------|----------|------------|
| Renewal + Deploy (staging) | `python akamai_cps_manager.py --action renew_and_deploy --deployment-network staging` | Confirms deployment in staging |
| Production deploy | `python akamai_cps_manager.py --deployment-network production` | Triggers CPS production rollout |

---

## Validation Checks
1. Verify enrollment ID matches target FQDN.
2. Ensure deployment link returned in CPS API response.
3. Confirm polling loop exits cleanly with success or failure.

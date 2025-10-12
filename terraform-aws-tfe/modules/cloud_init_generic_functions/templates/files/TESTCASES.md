# Akamai CPS Renewal Test Cases

## Test Matrix
| Scenario | Dry Run | Expected Outcome | Output File |
|-----------|----------|------------------|--------------|
| Renewal request simulation | ✅ | Renewal API simulated | `renew_dryrun_output.json` |
| Deployment scheduling | ✅ | Deployment simulated | `deploy_dryrun_output.json` |
| Enrollment status | ✅ | Active status with SANs | `status_dryrun_output.json` |
| Successful deployment | ✅ | Completed status | `poll_deployment_success.json` |
| Failed deployment | ✅ | Failure reported | `poll_deployment_failure.json` |

---

## Live Mode
When dry-run is disabled, these same scenarios call Akamai CPS APIs directly.
Outputs mirror API responses and can be validated through Akamai Control Center.

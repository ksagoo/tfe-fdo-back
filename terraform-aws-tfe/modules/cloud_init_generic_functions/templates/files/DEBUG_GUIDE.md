# Debug and Logging Guide

## Logging
All module stages print JSON logs for structured parsing:
```json
{
  "stage": "poll",
  "status": "COMPLETE",
  "at": "2025-10-12T10:12:32Z"
}
```

Logs are designed for ingestion into Splunk or ELK dashboards.

---

## Debug Flags
| Flag | Description |
|------|--------------|
| `--dry-run` | Skip live API calls and output mock data |
| `--poll-interval-sec` | Adjust polling frequency |
| `--poll-timeout-sec` | Maximum wait time for deployments |

---

## Common Issues
1. **Invalid credentials** – Verify `.edgerc` configuration  
2. **Timeouts** – Increase `--poll-timeout-sec`  
3. **Empty response** – Enable `--dry-run` to confirm logic paths  

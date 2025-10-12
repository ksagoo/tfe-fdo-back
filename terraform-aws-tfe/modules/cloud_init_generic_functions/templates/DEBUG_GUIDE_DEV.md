# Developer Debug Reference

## Verbose Mode
To enable detailed logs:
```bash
export CPS_DEBUG=1
python akamai_cps_manager.py --dry-run
```

This enables:
- Full HTTP trace for all CPS API calls
- Intermediate state dumps to `/logs/akamai_cps_debug.log`

---

## Example Debug Log
```json
{
  "stage": "renewal",
  "endpoint": "/cps/v2/enrollments/12345/renew",
  "method": "POST",
  "dryRun": true,
  "timestamp": "2025-10-12T09:12:45Z"
}
```

---

## Common Developer Errors
| Issue | Cause | Resolution |
|--------|--------|-------------|
| 401 Unauthorized | Invalid EdgeGrid credentials | Verify `.edgerc` tokens |
| 400 Bad Request | Malformed payload | Inspect `payload.json` |
| Timeout | Long polling duration | Increase `--poll-timeout-sec` |

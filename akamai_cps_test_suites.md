# Akamai CPS Certificate Manager — Test Suites (Live & Dry-Run)
**Version:** October 2025  
**Maintainer:** AppSec Engineering Automation  
**Purpose:**  
Provides standardized shell-based test suites for validating both *dry-run* and *live* modes of the Akamai CPS Certificate Lifecycle Automation (`akamai_cert_manager.py`) script.  
Each suite runs a consistent set of certificate renewal and deployment flows with safe logging, structured output, and clear PASS/FAIL reporting.

---

## 1. Overview
The test suites are designed to:
- Verify full CPS lifecycle automation (discovery, renewal, deployment, polling, and email rendering)
- Support both simulation (`--dry-run`) and live API integration
- Be easily runnable locally or through CI/CD environments
- Generate detailed logs and summaries in the `output/` directory

Both suites automatically create their own output directories and maintain `test.log`, `debug.log`, and `summary.json`.

---

## 2. Usage Examples

### Dry-Run Mode
```bash
python akamai_cert_manager.py   --section DEV   --access_group AppSec   --fqdn test.example.com   --enrollment_id 10001   --action renew_and_deploy   --dry-run
```

### Live Mode (Full Flow)
```bash
python akamai_cert_manager.py   --section APAC   --access_group AppSec   --action renew_and_deploy   --expiry-threshold 90   --deployment-network production
```

---

## 3. Parameter Reference

| Parameter | Description | Example |
|------------|--------------|----------|
| `--section` | .edgerc section name (maps to Akamai credentials and host) | `--section APAC` |
| `--access_group` | Access group name for tagging and email content | `--access_group AppSec` |
| `--fqdn` | Fully qualified domain name for a specific enrollment | `--fqdn login.hsbc.com` |
| `--enrollment_id` | Enrollment ID (numeric CPS identifier) | `--enrollment_id 104532` |
| `--action` | Operation type (`get_enrollment`, `renew_only`, `deploy_only`, `renew_and_deploy`) | `--action renew_and_deploy` |
| `--deployment-network` | Target network for deployment (`production`, `staging`) | `--deployment-network production` |
| `--expiry-threshold` | Discovery threshold in days (for auto-discovery) | `--expiry-threshold 90` |
| `--schedule-time` | Optional scheduled deployment time (ISO 8601) | `--schedule-time 2025-10-14T09:00:00Z` |
| `--dry-run` | Simulated mode (no live API calls) | `--dry-run` |
| `--debug` | Enables extended logging | `--debug` |
| `--no-email` | Disables email template rendering | `--no-email` |

---

## 4. Dry-Run Test Suite (v6.1)
Below is a self-contained shell test suite for validating all dry-run logic.  
Place this in the same directory as `akamai_cert_manager.py` and execute:

```bash
#!/bin/bash
# =====================================================
# Akamai CPS Certificate Manager - Dry-Run Test Suite
# Version: 6.1
# =====================================================
# Simulates all major lifecycle flows in --dry-run mode.
# Each test mirrors live CPS logic safely.
# =====================================================

set -Eeo pipefail
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

echo "====================================================="
echo " Starting Akamai CPS Certificate Manager Dry-Run Suite"
echo "====================================================="
echo "All results and logs will be written under: $OUTPUT_DIR/"
echo "-----------------------------------------------------"

TOTAL=0
PASS=0
FAIL=0

run_test() {
  local name="$1"
  local cmd="$2"
  echo -e "\n[TEST]: $name"
  echo "-----------------------------------------------------"
  echo "COMMAND: $cmd"
  local start_time=$(date +%s)

  set +e
  eval $cmd >>"$OUTPUT_DIR/test.log" 2>&1
  local status=$?
  set -e
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  TOTAL=$((TOTAL + 1))
  if [[ $status -ne 0 ]] || grep -q "\[FAILURE\]" "$OUTPUT_DIR/debug.log" 2>/dev/null; then
    echo "[RESULT]: FAIL (${duration}s)"
    FAIL=$((FAIL + 1))
  else
    echo "[RESULT]: SUCCESS (${duration}s)"
    PASS=$((PASS + 1))
  fi
  echo "-----------------------------------------------------"
  sleep 1
}

# --- DRY-RUN TESTS ---
run_test "Basic Dry-Run" "python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn dryrun.example.com --enrollment_id 10001 --action renew_and_deploy --dry-run --json-only"

run_test "Renew Only" "python akamai_cert_manager.py --section APAC --access_group Security --fqdn renewonly.example.com --enrollment_id 10003 --action renew_only --dry-run --json-only"

run_test "Deploy Only" "python akamai_cert_manager.py --section EMEA --access_group InfraSec --fqdn deployonly.example.com --enrollment_id 10004 --action deploy_only --dry-run --json-only"

run_test "Staging Deployment" "python akamai_cert_manager.py --section AMER --access_group AppSec --fqdn staging.example.com --enrollment_id 10006 --action renew_and_deploy --deployment-network staging --dry-run --json-only"

run_test "Debug Logging Enabled" "python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn debug.example.com --enrollment_id 10007 --action renew_and_deploy --dry-run --debug"

run_test "Expiry Template (7-Day)" "python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn seven.example.com --enrollment_id 10008 --action renew_and_deploy --days-to-expiry 7 --dry-run --json-only"

run_test "Full Integration (Poll Simulation)" "python akamai_cert_manager.py --section DEV --access_group AppSec --fqdn fullflow.example.com --enrollment_id 10011 --action renew_and_deploy --poll-interval 10 --poll-timeout 120 --dry-run --debug"

# --- SUMMARY ---
echo "====================================================="
echo " Dry-Run Suite Summary"
echo "====================================================="
echo " Total Tests : $TOTAL"
echo " Passed      : $PASS"
echo " Failed      : $FAIL"
echo "-----------------------------------------------------"
[[ $FAIL -eq 0 ]] && PIPELINE_RESULT="SUCCESS" || PIPELINE_RESULT="FAILURE"
echo "PIPELINE_RESULT=$PIPELINE_RESULT"
echo "====================================================="
echo " Dry-Run Test Suite Completed ($PIPELINE_RESULT)"
echo "====================================================="
```

---

## 5. Live Test Suite (v1.0)
This suite performs **actual CPS API calls** for discovery, renewal, deployment, and polling.  
Parameters `--threshold` and `--network` are configurable at runtime.  
The script defaults to running all tests unless a specific test name is passed.

```bash
#!/bin/bash
# =====================================================
# Akamai CPS Certificate Manager - Live Test Suite
# Version: 1.0
# =====================================================
# Executes real API tests for discovery, renewal, and deployment.
# Supports parameterized threshold and network.
# =====================================================

set -Eeo pipefail
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

THRESHOLD=${1:-30}
NETWORK=${2:-production}
TARGET=${3:-all} # can be 'all', 'discover', 'renew', 'deploy', 'poll'

echo "====================================================="
echo " Starting Akamai CPS Certificate Manager Live Suite"
echo "====================================================="
echo " Threshold: ${THRESHOLD} days"
echo " Network:   ${NETWORK}"
echo " Target:    ${TARGET}"
echo "-----------------------------------------------------"

TOTAL=0
PASS=0
FAIL=0

run_test() {
  local name="$1"
  local cmd="$2"
  echo -e "\n[TEST]: $name"
  echo "-----------------------------------------------------"
  echo "COMMAND: $cmd"
  local start_time=$(date +%s)

  set +e
  eval $cmd >>"$OUTPUT_DIR/test_live.log" 2>&1
  local status=$?
  set -e
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))

  TOTAL=$((TOTAL + 1))
  if [[ $status -ne 0 ]] || grep -q "\[FAILURE\]" "$OUTPUT_DIR/debug.log" 2>/dev/null; then
    echo "[RESULT]: FAIL (${duration}s)"
    FAIL=$((FAIL + 1))
  else
    echo "[RESULT]: SUCCESS (${duration}s)"
    PASS=$((PASS + 1))
  fi
  echo "-----------------------------------------------------"
  sleep 1
}

if [[ "$TARGET" == "all" || "$TARGET" == "discover" ]]; then
run_test "Discover Enrollments" "python akamai_cert_manager.py --section APAC --access_group AppSec --action get_enrollment --expiry-threshold ${THRESHOLD} --deployment-network ${NETWORK}"
fi

if [[ "$TARGET" == "all" || "$TARGET" == "renew" ]]; then
run_test "Renew Certificates" "python akamai_cert_manager.py --section APAC --access_group AppSec --action renew_only --expiry-threshold ${THRESHOLD} --deployment-network ${NETWORK}"
fi

if [[ "$TARGET" == "all" || "$TARGET" == "deploy" ]]; then
run_test "Deploy Certificates" "python akamai_cert_manager.py --section APAC --access_group AppSec --action deploy_only --expiry-threshold ${THRESHOLD} --deployment-network ${NETWORK}"
fi

if [[ "$TARGET" == "all" || "$TARGET" == "poll" ]]; then
run_test "Poll Deployment Status" "python akamai_cert_manager.py --section APAC --access_group AppSec --action renew_and_deploy --expiry-threshold ${THRESHOLD} --poll-interval 20 --poll-timeout 180 --deployment-network ${NETWORK}"
fi

echo "====================================================="
echo " Live Suite Summary"
echo "====================================================="
echo " Total Tests : $TOTAL"
echo " Passed      : $PASS"
echo " Failed      : $FAIL"
echo "-----------------------------------------------------"
[[ $FAIL -eq 0 ]] && PIPELINE_RESULT="SUCCESS" || PIPELINE_RESULT="FAILURE"
echo "PIPELINE_RESULT=$PIPELINE_RESULT"
echo "====================================================="
echo " Live Test Suite Completed ($PIPELINE_RESULT)"
echo "====================================================="
```

---

## 6. Example Execution

```bash
bash test_suite_live.sh 90 production
bash test_suite_live.sh 60 production discover
bash test_suite_dryrun.sh
```

---

## 7. Output Structure

| File | Description |
|------|--------------|
| `output/test.log` | Standard test log (dry-run) |
| `output/test_live.log` | Standard test log (live) |
| `output/debug.log` | Verbose debug details |
| `output/discovered_enrollments.json` | Discovery output |
| `output/summary.json` | Consolidated results |

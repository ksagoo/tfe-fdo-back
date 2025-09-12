# Combined Python + CI/CD + IaC Interview Tool

This repository provides an **interactive, command-line based interview tool** for testing candidates on:
- **Python debugging skills**  
- **CI/CD configuration skills** (GitLab CI, GitHub Actions, Jenkins)  
- **Infrastructure as Code (IaC)** using Terraform  
- **Git version control concepts**

The tool presents buggy code and multiple choice fixes. Candidates select their answer, and results are recorded for later review.  

---

## Usage

Run the combined tool:

```bash
python combined_interview_runner_v3.py --all
```

### Options

- `--section python` → Only Python questions  
- `--section cicd` → Only CI/CD questions  
- `--section iac` → Only Terraform IaC questions  
- `--section git` → Only Git questions  
- `--all` → Run everything  

CI/CD can be filtered further:
```bash
--tool gitlab
--tool github
--tool jenkins
--tool gitlab jenkins
```

General flags:
- `--shuffle` → Randomize order of questions  
- `--limit N` → Limit number of questions  
- `--time-limit N` → Limit seconds allowed per question  
- `--pause` → Pause between exercises until Enter pressed  
- `--output-dir results/` → Directory to save result files  
- `--results-file results.csv` → Summary CSV filename  
- `--details-file details.csv` → Detailed CSV filename  
- `--pdf summary.pdf` → Save PDF summary for agency/hiring team  
- `--no-display-results` → Suppress final results on screen  

---

## Output

Two CSV files are produced:
1. **Summary file** → Score and percentage per candidate  
2. **Details file** → Candidate choices, correctness, buggy code, chosen code, correct code  

If `--pdf` is supplied, a **PDF summary** is also generated.

---

## Appendix — Interviewer Guide

### Python Section (14 Questions)

| Exercise | Focus / Concept Tested |
|----------|-------------------------|
| 1 | **Indentation** — ensure code inside a function is indented correctly |
| 2 | **Add two numbers** — code references `a` and `b`. The fix is to use parameters `a` and `b` |
| 3 | **Add 5 to an age** — Strings cannot be added to integers. Convert input to `int` before arithmetic |
| 4 | **Check if a number is even** — Even numbers have `n % 2 == 0` |
| 5 | **Build a list of items** — Default list is shared between calls. Use `None` and create a new list inside the function |
| 6 | **Read a config file** — Use `with open(..., encoding="utf-8")` to ensure files are closed properly and text is read safely |
| 7 | **Save rows to a CSV file** — Must open with `newline=""` and proper encoding to avoid extra blank lines and encoding issues |
| 8 | **Fetch multiple results asynchronously** — `time.sleep()` blocks event loop. Use `await asyncio.sleep()` and `await asyncio.gather()` |
| 9 | **Count safely across threads** — `n += 1` is not atomic. Protect shared state with a `threading.Lock()` |
| 10 | **Look up a user in a database** — Never interpolate strings into SQL. Use placeholders (`?`) with parameter binding |
| 11 | **Work with dates and times** — Naive datetimes break across DST shifts. Use `zoneinfo.ZoneInfo` for timezone-aware datetimes |
| 12 | **Process lines from text** — Iterators are consumed after one pass. Convert to list or use the source iterable multiple times |
| 13 | **Manage a shopping cart** — Use `field(default_factory=list)` to give each instance its own list |
| 14 | **Log an error without exposing secrets** — Never log API keys. Only log the error message, and use specific exceptions |

---

### CI/CD Section (12 Questions)

| Exercise | Platform | Focus / Concept Tested |
|----------|----------|-------------------------|
| 1 | GitLab | Ensure correct `only` syntax (`only: - master`) |
| 2 | GitLab | Correct job name (`test-job` not duplicated) |
| 3 | GitLab | Job names must be unique |
| 4 | GitLab | Use variables correctly with `$VAR` |
| 5 | GitLab | Fix YAML syntax issues |
| 6 | GitLab | Use `when` correctly for conditional execution |
| 7 | GitLab | Job names cannot be duplicated across stages |
| 8 | GitLab | `stages:` must be defined properly |
| 9 | GitLab | Image specification must be `name:tag` |
| 10 | GitLab | Correct usage of `extends` |
| 1 | GitHub Actions | Correct job declaration under `jobs:` |
| … | … | … (remaining GitHub & Jenkins follow same format) |

---

### IaC Section (10 Questions)

Covers:
- General Terraform syntax  
- Variables and outputs  
- AWS provider usage  
- GCP provider usage  
- Unique resource naming, state management  

---

### Git Section (10 Questions)

Covers:
- Basic Git workflow (clone, add, commit, push)  
- Branching and merging  
- Rebasing vs merging  
- Resolving conflicts  
- Reset vs revert  
- Git tags and releases  
- `.gitignore` usage  
- Squash merges  
- Amending commits  
- Interactive rebase  

# CI/CD Debugging Interview — Candidate-Safe Runner

This repository contains a candidate-friendly **CI/CD debugging interview** tool.  
It presents **buggy CI/CD pipeline snippets** (GitLab CI, GitHub Actions, Jenkins) along with **randomized fix options** (A/B/C).  

The candidate:
- Sees only the buggy code and the options.
- Picks one option per question.
- Does **not** see correctness or hints during the session.
- Results are recorded for the interviewer/hiring team.

The interviewer/agency receives:
- **Summary CSV** with per-exercise PASS/FAIL and totals.
- **Details CSV** with buggy snippet, candidate’s choice, and correct fix (if wrong).
- **Optional one-page PDF summary** (candidate name, timestamp, per-exercise PASS/FAIL, overall score).

---

## Key Features

- Neutral exercise titles (e.g., *GitLab CI — Snippet 3*) — no hints about the bug.
- Supports **GitLab CI, GitHub Actions, and Jenkins** snippets.
- Options are randomized per run.
- Candidate’s screen remains clean (no logs, no answers revealed).
- Results are automatically saved for later review.

---

## Usage

### Run all exercises
```bash
python cicd_interview_runner_v1.py --all --name "Jane Doe"
```

### Run a specific subset
```bash
python cicd_interview_runner_v1.py --pick 2 5 9 --name "John Smith"
```

### Shuffle order and pause between exercises
```bash
python cicd_interview_runner_v1.py --all --shuffle --pause --name "Alice Jones"
```

### Export results to PDF
```bash
python cicd_interview_runner_v1.py --all --name "Bob Brown" --pdf
```

---

## Flags

| Flag                | Description |
|---------------------|-------------|
| `--all`             | Run all exercises. |
| `--pick N N ...`    | Run only selected exercises. |
| `--shuffle`         | Shuffle chosen exercises. |
| `--limit N`         | Limit number of exercises (after shuffle/pick). |
| `--pause`           | Pause after each exercise and clear screen. |
| `--time-limit SEC`  | Set per-exercise time limit (0 = unlimited). |
| `--output-dir DIR`  | Directory to save results (default: current dir). |
| `--results-file`    | Explicit summary CSV filename. |
| `--details-file`    | Explicit details CSV filename. |
| `--pdf`             | Write one-page PDF summary. |
| `--pdf-file FILE`   | Explicit PDF filename. |
| `--name NAME`       | Candidate name (otherwise prompted). |
| `--no-display-results` | Suppress final results printout (results still saved). |

---

## Output Files

1. **Summary CSV** — one row per exercise (choice, pass/fail, totals).
2. **Details CSV** — buggy code, chosen code, correct code if wrong, explanation.
3. **Summary PDF** — candidate-facing one-page score report (optional, agency use).

---

## Platforms Covered

- **GitLab CI/CD** — `.gitlab-ci.yml`
- **GitHub Actions** — `.github/workflows/main.yml`
- **Jenkins Pipelines** — `Jenkinsfile`

(Extensible to CircleCI, Azure Pipelines, etc.)

---

## Example Workflow

1. Interviewer launches script with:
   ```bash
   python cicd_interview_runner_v1.py --all --shuffle --pause --name "Jane Doe"
   ```
2. Candidate views each buggy snippet + 3 randomized options.
3. Candidate selects A, B, or C.
4. Script pauses between questions, clears screen, then continues.
5. At the end:
   - Candidate sees **nothing about correctness** (if `--no-display-results`).
   - Interviewer/agency receives CSVs (and optional PDF).

---

## Appendix: Interviewer Guide

Each snippet is designed to test specific **CI/CD knowledge areas**.

| Exercise | Platform        | Focus / Concept Tested |
|----------|-----------------|-------------------------|
| 1        | GitLab CI       | Job must declare a stage |
| 2        | GitLab CI       | `script` must be a YAML sequence (list) |
| 3        | GitLab CI       | Docker image tag syntax (single colon) |
| 4        | GitLab CI       | Correct environment variable usage (`$VAR`) |
| 5        | GitHub Actions  | Workflow trigger key must be `on` |
| 6        | GitHub Actions  | Jobs must include a `steps:` section |
| 7        | GitHub Actions  | `strategy` block indentation inside job |
| 8        | GitHub Actions  | Condition expressions must compare to quoted strings |
| 9        | Jenkins         | Declarative pipeline requires a `stages {}` block |
| 10       | Jenkins         | Correct spelling of `stages` key |
| 11       | Jenkins         | Environment variable interpolation (`${VAR}`) |
| 12       | Jenkins         | Stage names must be unique |

This guide is **for interviewers only** — candidates never see these hints.

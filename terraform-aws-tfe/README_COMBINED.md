# Combined Debugging Interview — Python + CI/CD

## Overview
This tool lets you run a single, **candidate-safe interview session** covering both:
- **Python debugging exercises** (buggy snippet + randomized fix options, validated by execution)
- **CI/CD troubleshooting exercises** (GitLab CI, GitHub Actions, Jenkins, validated by metadata)

The candidate sees the **buggy snippet** and a set of randomized fix options.  
They choose one — but the app does **not reveal correctness on screen** (unless enabled).  
All results are saved to CSV files, and you can generate a one-page PDF summary.

---

## Features
- **Combined sections**: Python + CI/CD in one run.
- **Filtering**: run Python only, CI/CD only, or both.
- **Platform-specific CI/CD filtering**: `--tool gitlab`, `--tool github`, `--tool jenkins`.
- **Randomized options**: correct answer position changes each run.
- **Result capture**: 
  - Summary CSV (pass/fail counts, total, percentage)
  - Details CSV (buggy code, chosen code, correct code if wrong)
  - Optional one-page PDF (candidate name, timestamp, pass/fail per question)
- **No external dependencies**: pure Python 3 standard library.

---

## Usage Examples

### Run both sections
```bash
python combined_interview_runner_v1.py --all --name "Jane Doe"
```

### Python only
```bash
python combined_interview_runner_v1.py --section python --all --name "Alice"
```

### CI/CD only — GitLab + Jenkins
```bash
python combined_interview_runner_v1.py --section cicd --tool gitlab jenkins --all --name "Bob"
```

### Specific questions (Python #3, CI/CD #5 + #9)
```bash
python combined_interview_runner_v1.py --section both --pick-python 3 --pick-cicd 5 9 --name "Eve"
```

### Shuffled, pause between, PDF output
```bash
python combined_interview_runner_v1.py --all --shuffle --pause --pdf --name "Chris"
```

---

## Flags

| Flag | Description |
|------|-------------|
| `--section python|cicd|both` | Choose section(s) (default: `both`) |
| `--all` | Run all exercises in chosen section(s) |
| `--tool gitlab github jenkins` | Filter CI/CD exercises by platform |
| `--pick-python N [N ...]` | Select specific Python exercises |
| `--pick-cicd N [N ...]` | Select specific CI/CD exercises |
| `--shuffle` | Shuffle the final order |
| `--limit N` | Limit number of exercises after selection |
| `--time-limit SEC` | Seconds to answer each (0 = unlimited) |
| `--pause` | Pause & clear screen after each exercise |
| `--output-dir DIR` | Directory to save results |
| `--results-file FILE` | Custom summary CSV filename |
| `--details-file FILE` | Custom details CSV filename |
| `--pdf` | Generate one-page PDF summary |
| `--pdf-file FILE` | Custom PDF filename |
| `--name NAME` | Candidate name (otherwise prompted) |
| `--no-display-results` | Don’t show summary at end (files still written) |

---

## Output Files
- **Summary CSV**: candidate name, timestamp, per-question results, totals, percentage.
- **Details CSV**: buggy snippet, chosen code, correct code (if wrong).
- **Optional PDF**: one-page summary with candidate name, timestamp, per-question pass/fail, total score.

---

## Dependencies
- **Python 3 standard library only**
- Runs in terminal (ideal for Zoom or in-person interviews).

---

## Appendix — Interviewer Guide

### Python Section (14 Questions)

| Exercise | Focus / Concept Tested |
|----------|-------------------------|
| 1  | Indentation — ensure code inside a function is indented correctly |
| 2  | NameError — use correct variable names in expressions |
| 3  | Mutable default arguments — avoid list/dict defaults in function signatures |
| 4  | Off-by-one errors — correct use of `range()` in summation |
| 5  | String formatting — using f-strings instead of literal braces |
| 6  | Joining lists — converting items to string before `join()` |
| 7  | Sorting with key functions — sorting tuples by value not key |
| 8  | Dictionary mutation — counting letters with `get` instead of appending to lists |
| 9  | Exception handling — catching `ZeroDivisionError` and returning `inf` |
| 10 | Generators — using generator expressions instead of slicing lists |
| 11 | String reversal — proper use of slicing vs. `reversed()` object |
| 12 | Async/await — properly awaiting coroutines with `asyncio.run()` |
| 13 | JSON parsing — using `json.loads` safely instead of `eval` |
| 14 | Enumerate — using `enumerate(..., start=1)` for correct indices |

---

### CI/CD Section (12 Questions)

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

---

This guide is **for interviewers only** — candidates never see these hints.



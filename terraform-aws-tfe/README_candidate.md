# Python Debugging Interview — Candidate-Safe Runner

This script is the **candidate-facing** version of the debugging interview tool.  
It **does not reveal** correct answers during the session and only writes results to files for the interviewer/agency.

## What the candidate sees
- A short description: `Exercise N - <description>`
- The buggy code snippet
- Three options (A/B/C) in random order
- A prompt to enter the choice (A/B/C)

## What is NOT shown
- No per-question PASS/FAIL
- No reveal of the correct answer
- No code execution outputs

## Outputs
- **CSV** with per-question PASS/FAIL, total score, and percentage
- **Optional PDF** summary (`--pdf`) with **only**:
  - Candidate name
  - Timestamp
  - Lines of `Ex NN: PASS` or `FAIL`
  - Overall score `X / N (YY%)`
  - No code or question text

## Quick start
```bash
# Run all exercises, pause between, save CSV + PDF with no visual displat of result on screen at end of test
python interview_debug_showcode_candidate.py --all -no-display-results --pause --name "John Smith" --output-dir results --pdf
```

## CLI options

**Required (choose one):**
- `--all` — run all exercises.
- `--pick 2 5 8` — run only specific exercises.

**Common:**
- `--shuffle` — randomize exercise order.
- `--limit N` — limit number of exercises after shuffle/filter.
- `--time-limit SECS` — seconds allowed for entering a choice (0 = no limit).
- `--pause` — pause and clear the screen between questions.

**Output / identification:**
- `--name "Candidate Name"` — candidate name (if omitted, you’ll be prompted).
- `--output-dir PATH` — where to store results (default: current dir).
- `--results-file NAME.csv` — explicit CSV filename.
- `--no-display-results` — do not print final score to the terminal.

**Agency PDF:**
- `--pdf` — also write a one-page PDF summary (no question details).
- `--pdf-file NAME.pdf` — explicit PDF filename.

## CSV format
The CSV includes:
```
candidate,<sanitized-name>
timestamp,<YYYY-MM-DD HH:MM:SS>

exercise,description,choice,correct
1,Print a greeting,B,True
2,Add two numbers,A,True
...

TOTAL_CORRECT,10
TOTAL_QUESTIONS,14
PERCENT,71%
```

## PDF format
One-page A4 with:
```
Python Debugging Interview — Summary
Candidate: Jane Doe
Timestamp: 2025-09-10 10:00:00

Ex  1: PASS
Ex  2: FAIL
...
------------------------------
Score: 10 / 14 (71%)
```

> The PDF intentionally omits question text and code.

## Notes
- Intended for Python 3.8+.
- Keep this script separate from the interviewer-oriented version if you use both.
- If you want to add a logo or footer to the PDF, we can extend the built-in PDF generator.

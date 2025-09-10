# Python Debugging Interview

A self-contained Python quiz tool for **live coding interviews**.  
Presents buggy code snippets and multiple-choice fixes (A, B, C).  
The candidate selects one, and the tool runs it to determine **PASS/FAIL**.

Designed for screen-sharing (e.g. Zoom) and controlled interview sessions.

---

## File Overview

- **`interview_debug_showcode_allinone_final.py`**  
  Self-contained script with:
  - Embedded exercises (buggy code + options).
  - Full runner logic.  
   No external files required.

- *(Legacy modular setup – not required if using the all-in-one version)*  
  - `interview_options_runner_full_v2.py` → Defines exercises (EXERCISES dict).  
  - `interview_session_runner.py` → Loads exercises, shows buggy code and option titles only.  
  - `interview_session_runner_showcode.py` → Loads exercises, shows full code for buggy snippet and options.

---

## Quick Start

Run the all-in-one script with Python 3:

```bash
# Run all 14 exercises (scroll mode)
python interview_debug_showcode_allinone_final.py --all
```

### Examples

```bash
# Shuffle order, 45s per question
python interview_debug_showcode_allinone_final.py --all --shuffle --time-limit 45

# Debugging mode: run buggy code first, explain if wrong
python interview_debug_showcode_allinone_final.py --all --run-buggy-first --explain

# Pause & clear screen between questions
python interview_debug_showcode_allinone_final.py --all --pause

# Limit whole session to 10 minutes
python interview_debug_showcode_allinone_final.py --all --limit-time 600

# Pick specific questions
python interview_debug_showcode_allinone_final.py --pick 1 5 9
```

---

## Command-Line Flags

- `--all`  
  Run all exercises in order.

- `--pick 1 5 9`  
  Run only the listed exercises.

- `--shuffle`  
  Randomize exercise order.

- `--limit N`  
  Limit number of exercises (after shuffle).

- `--time-limit SECS`  
  Time allowed per question (0 = unlimited).

- `--limit-time SECS`  
  Overall session time limit.

- `--pause`  
  Wait for Enter after each question and clear the screen.

- `--run-buggy-first`  
  Execute buggy code first to show its output/error.

- `--explain`  
  If wrong, show and run the correct answer with explanation.

- `--reveal`  
  Reveal the correct option label after each exercise (if answered correctly).

---

## Exercise Format

Each exercise includes:
- **Buggy code snippet** (shown to candidate).
- **3 options** (random order, one correct).
- **PASS/FAIL check** based on expected output.
- Optional **explanation** if candidate is wrong (`--explain`).

Covers:
- Indentation & syntax errors  
- Undefined variables  
- Type mismatches  
- Logic bugs  
- Mutable defaults  
- Async & threading mistakes  
- Dataclasses, SQL injection, timezone handling, logging secrets, etc.  

---

## Output

At the end, a clean session summary:

```
======================================================================
Session Summary
======================================================================
Ex  1: PASS
Ex  2: FAIL
Ex  3: PASS
---------------
Score: 10 / 14 (71%)
```

---

## Notes

- All code examples are safe for interview/demo use.  
- Secrets are scrubbed (e.g. API keys in logging examples).  
- Compatible with Python 3.8+.

---

## Typical Use in Interview

1. Start Zoom screen-share.  
2. Run the script with desired flags.  
3. Candidate reads buggy code + options, then chooses.  
4. Script executes choice and shows PASS/FAIL.  
5. At end, review session summary.  

---

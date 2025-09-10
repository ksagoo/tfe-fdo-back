# Python Debugging Interview

A self-contained Python quiz tool for **live coding interviews**.  
Presents buggy code snippets and multiple-choice fixes (A, B, C).  
The candidate selects one, and the tool runs it to determine **PASS/FAIL**.

Designed for screen-sharing (e.g. Zoom) and controlled interview sessions.

---

## 📂 File Overview

- **`interview_debug_showcode_allinone_final.py`**  
  Self-contained script with:
  - Embedded exercises (buggy code + options).
  - Full runner logic.  
  ✅ No external files required.

- *(Legacy modular setup – not required if using the all-in-one version)*  
  - `interview_options_runner_full_v2.py` → Defines exercises (EXERCISES dict).  
  - `interview_session_runner.py` → Loads exercises, shows buggy code and option titles only.  
  - `interview_session_runner_showcode.py` → Loads exercises, shows full code for buggy snippet and options.

---

## 🚀 Quick Start

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

## ⚙️ Command-Line Flags

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

## 🧩 Exercise Format

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

## 📊 Output

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

## 🔒 Notes

- All code examples are safe for interview/demo use.  
- Secrets are scrubbed (e.g. API keys in logging examples).  
- Compatible with Python 3.8+.

---

## 👩‍💻 Typical Use in Interview

1. Start Zoom screen-share.  
2. Run the script with desired flags.  
3. Candidate reads buggy code + options, then chooses.  
4. Script executes choice and shows PASS/FAIL.  
5. At end, review session summary.  

---

# 📘 Appendix: Interviewer Guide

This section is for interviewers only.  
It describes what each exercise tests, the correct answer, and why.

---

## Exercise 1 — Print a greeting
- **Concept:** Indentation rules (Python syntax).  
- **Correct Option:** A  
- **Explanation:** Python requires code inside a function to be indented. The `print` statement must be indented under `def main():`.

## Exercise 2 — Add two numbers
- **Concept:** Variable scope, using function parameters.  
- **Correct Option:** A  
- **Explanation:** The buggy code references `c` (undefined). The fix is to use parameters `a` and `b`.

## Exercise 3 — Add 5 to an age
- **Concept:** Type conversion (string → int).  
- **Correct Option:** A  
- **Explanation:** Strings cannot be added to integers. Convert input to `int` before arithmetic.

## Exercise 4 — Check if a number is even
- **Concept:** Boolean expressions, modulo operator.  
- **Correct Option:** A  
- **Explanation:** Even numbers have `n % 2 == 0`.

## Exercise 5 — Build a list of items
- **Concept:** Mutable default arguments.  
- **Correct Option:** A  
- **Explanation:** Default list is shared between calls. Use `None` and create a new list inside the function.

## Exercise 6 — Read a config file
- **Concept:** File handling, resource management.  
- **Correct Option:** A  
- **Explanation:** Use `with open(..., encoding='utf-8'):` to ensure files are closed properly and text is read safely.

## Exercise 7 — Save rows to a CSV file
- **Concept:** File handling, CSV writing.  
- **Correct Option:** A  
- **Explanation:** Must open with `newline=''` and proper encoding to avoid extra blank lines and encoding issues.

## Exercise 8 — Fetch multiple results asynchronously
- **Concept:** AsyncIO, event loop, awaiting tasks.  
- **Correct Option:** A  
- **Explanation:** `time.sleep()` blocks event loop. Use `await asyncio.sleep()` and `await asyncio.gather()`.

## Exercise 9 — Count safely across threads
- **Concept:** Concurrency, race conditions.  
- **Correct Option:** A  
- **Explanation:** `+=` is not atomic. Protect shared state with a `threading.Lock()`.

## Exercise 10 — Look up a user in a database
- **Concept:** SQL injection prevention, parameterized queries.  
- **Correct Option:** A  
- **Explanation:** Never interpolate strings into SQL. Use placeholders (`?`) with parameter binding.

## Exercise 11 — Work with dates and times
- **Concept:** Timezones, DST issues.  
- **Correct Option:** A  
- **Explanation:** Naive datetimes break across DST shifts. Use `zoneinfo.ZoneInfo` for timezone-aware datetimes.

## Exercise 12 — Process lines from text
- **Concept:** Iterators vs lists (one-shot iterators).  
- **Correct Option:** A  
- **Explanation:** Iterators are consumed after one pass. Convert to list or use the source iterable multiple times.

## Exercise 13 — Manage a shopping cart
- **Concept:** Dataclasses and mutable defaults.  
- **Correct Option:** A  
- **Explanation:** Use `field(default_factory=list)` to give each instance its own list.

## Exercise 14 — Log an error without exposing secrets
- **Concept:** Secure logging, avoid leaking secrets.  
- **Correct Option:** A  
- **Explanation:** Never log API keys. Only log the error message, and use specific exceptions.

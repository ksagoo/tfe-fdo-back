# Combined Debugging Interview — Python + CI/CD + IaC (Terraform) + Git

A single, dependency‑free Python script to run technical debugging/troubleshooting interviews live over Zoom or in person.  
Candidates see **buggy snippets + multiple-choice fix options**. You type their choice (A/B/C) and the tool records results **without revealing the answer**. At the end it saves:
- **Summary CSV** (per question pass/fail + totals + percentage)
- **Details CSV** (buggy code, chosen option code, correct code if wrong, explanation)
- Optional **one‑page PDF** summary (no question details)

> Script file: `combined_interview_runner_v3.py`

---

## Quick Start

```bash
python combined_interview_runner_v3.py --section all --all --shuffle --name "Jane Doe" --pdf
```

- The screen clears and shows each exercise: **Buggy code** then **Options (A/B/C)**.
- You type `A`, `B`, or `C`. No pass/fail is shown to the candidate.
- CSVs (and optional PDF) are written to the current folder by default.

---

## Sections

- **python** — 14 short debugging snippets (indentation, NameError, async/await, etc.).
- **cicd** — 12 config snippets (GitLab CI, GitHub Actions, Jenkins).
- **iac** — 10 Terraform items (general, AWS, GCP).
- **git** — 10 Git workflows (branching, tracking, rebase, stash, safe push).
- **all** — include every section.

You can combine sections, e.g. `--section cicd git` or use `--section all` (default).

---

## Usage & Flags

### Section selection
```bash
--section python|cicd|iac|git|all     # default: all
--all                                 # select all items in chosen section(s)
--pick-python 2 5 11                  # pick specific Python numbers
--pick-cicd 1 8                       # pick specific CI/CD numbers
--pick-iac 3 7                        # pick specific IaC numbers
--pick-git 4 10                       # pick specific Git numbers
--limit N                             # cap total questions after selection/shuffle
--shuffle                             # randomize final order
```

### Filters
```bash
--tool gitlab github jenkins          # CI/CD platforms to include
--iac-scope general aws gcp           # Terraform scopes to include
```

### Session control
```bash
--name "Full Name"                    # candidate name (prompted if omitted)
--pause                               # pause after each exercise and clear screen
--time-limit SEC                      # (kept simple; accepts input until Enter)
```

### Output control
```bash
--output-dir ./out                    # where to save files
--results-file my_summary.csv         # explicit summary CSV filename
--details-file my_details.csv         # explicit details CSV filename
--no-display-results                  # no end-of-run printout
--pdf                                 # also write one-page PDF summary
--pdf-file summary.pdf                # explicit PDF filename
```

---

## Example Commands

Everything (shuffled) with PDF:
```bash
python combined_interview_runner_v3.py --section all --all --shuffle --pdf --name "Alex"
```

Only Python (all 14), ordered:
```bash
python combined_interview_runner_v3.py --section python --all --name "Sam"
```

CI/CD (GitLab + Jenkins only), plus Git; shuffle & limit to 12 total:
```bash
python combined_interview_runner_v3.py --section cicd git --all --tool gitlab jenkins --shuffle --limit 12 --name "Priya"
```

IaC only — AWS + General:
```bash
python combined_interview_runner_v3.py --section iac --all --iac-scope aws general --name "Jordan"
```

Pick specifics (Python 3 5; IaC 2 7; Git 1 10):
```bash
python combined_interview_runner_v3.py --pick-python 3 5 --pick-iac 2 7 --pick-git 1 10 --name "Taylor"
```

---

## Output Files

- **Summary CSV** (UTF‑8 with BOM so Excel shows titles correctly)  
  Columns: `section, exercise, description, choice, correct` + totals and percentage

- **Details CSV** (UTF‑8 with BOM)  
  Columns: `section, exercise, platform, title, description, chosen_label, chosen_ok, correct_label_if_wrong, buggy_code, chosen_code, correct_code_if_wrong, explanation`

- **PDF summary** (optional)  
  One page; just PASS/FAIL per item and total score. No question details.

File names auto‑include candidate name (sanitized) and timestamp unless you override with `--results-file`, `--details-file`, or `--pdf-file`.

---

## Interview Flow Tips

- Use `--pause` so you can discuss each snippet, then press **Enter** to move on.
- Keep Zoom screen share on the **terminal** to avoid exposing any answers.
- If you need just one Python + one CI/CD item, omit `--all` and the tool will prompt interactively.
- `--shuffle` helps reduce pattern‑guessing across candidates.

---

## Appendix — Topic Coverage

### Python (14)
1. Indentation / print
2. NameError / variable scope
3. Mutable default args
4. Range off‑by‑one
5. f‑strings
6. `str.join` on numbers
7. Sorting by key (tuples)
8. Counting in dicts
9. ZeroDivisionError handling
10. Sum of squares (generator)
11. Reverse string (slicing)
12. Asyncio: `async`/`await` (`asyncio.run()`)
13. `json.loads` vs `eval`
14. `enumerate(..., start=1)`

### CI/CD (12)
- **GitLab CI**: stages, `script` array, `image` tag syntax, env var expansion  
- **GitHub Actions**: top‑level `on`, steps under `jobs.*.steps`, `strategy` placement, quoting in conditionals  
- **Jenkins**: declarative `stages`, key spelling, Groovy interpolation, unique stage names

### IaC / Terraform (10)
- Init/plan/apply order  
- Remote state (S3 + DynamoDB)  
- Variables & defaults (avoid hardcoding)  
- AWS provider config  
- Unique resource names (`for_each`/`count` idea)  
- Outputs  
- GCP credentials file  
- GCP project/region  
- Modules  
- Workspaces for environments

### Git (10)
- Create & switch branch (`checkout -b` / `switch -c`)  
- Track remote branch  
- Amend last commit  
- Rebase vs merge (linear history)  
- Resolve merge conflicts  
- Stash/pull/pop  
- Remove committed secret (history rewrite)  
- Set upstream on first push (`-u`)  
- Safe force push (`--force-with-lease`)  
- Interactive rebase cleanup

---

## Notes

- The runner is **dependency‑free** (pure Python stdlib).  
- The IaC and CI/CD items are *metadata‑driven* multiple choice; Python items are executed in a sandboxed namespace to verify output.  
- No correct answers or pass/fail are shown on screen during the interview — only saved to files.

---

## License

Internal interview utility. Adapt as needed.

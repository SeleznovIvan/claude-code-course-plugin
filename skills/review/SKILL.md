---
name: cc-course:review
description: Review a student submission and provide detailed, critical feedback with scoring
argument-hint: "<path-to-submission.zip>"
---

# Review Student Submission

Analyze a student's homework submission zip and produce a detailed, critical review with scoring across 5 dimensions.

## Input

`$ARGUMENTS` is the path to a submission zip file (e.g., `seminar1-jane-doe-2026-02-10.zip`).

### If No Path Provided

1. Scan `{cwd}` for `seminar*.zip` files
2. If exactly one found, use it
3. If multiple found, list them and ask the user to pick
4. If none found, ask the user for the path

### Path Resolution

If the path is relative, resolve it against `{cwd}`. Verify the file exists before proceeding.

## Review Pipeline

For the complete review system with scoring framework, rubric extraction, and feedback templates, read [review.md](../review.md).

## Steps

1. **Validate zip** — confirm file exists and is a valid zip archive
2. **Unzip** to a temporary directory:
   ```bash
   REVIEW_DIR="/tmp/cc-review-$(date +%s)"
   mkdir -p "$REVIEW_DIR"
   unzip -o "{path}" -d "$REVIEW_DIR"
   ```
3. **Read `manifest.json`** from the unpacked zip — extract:
   - `seminar` → module key (e.g., `1-foundations-and-commands`)
   - `student` → name, role, repository
   - `validation` → task pass/fail results
   - `artifacts` → file counts, line counts, metadata
   - `sessions` → session IDs and file references
4. **Read `progress/progress.json`** — extract:
   - Task completion states and timestamps
   - Session history (session IDs, durations, tasks completed per session)
   - Module timing (started_at, completed_at)
5. **Load module SCRIPT.md** — read `lesson-modules/{module-key}/SCRIPT.md` to extract learning objectives, verification blocks, and quality expectations
6. **Run the review pipeline** (see [review.md](../review.md)):
   - a. Extract dynamic rubric from SCRIPT.md
   - b. Analyze artifacts (read each file in `student-work/`)
   - c. Analyze sessions via cclogviewer MCP
   - d. Score all 5 dimensions
   - e. Calculate weighted overall score
   - f. Generate feedback report
7. **Output the formatted review report** to the user
8. **Cleanup**:
   ```bash
   rm -rf "$REVIEW_DIR"
   ```

## Error Handling

### File Not Found
```
File not found: {path}
Provide the path to a seminar submission zip (created by /cc-course:submit).
```

### Not a Valid Zip
```
"{path}" is not a valid zip archive. Was it created with /cc-course:submit?
```

### Missing manifest.json
```
This zip does not contain manifest.json.
It may not be a valid course submission. Was it created with /cc-course:submit?
```

### Missing SCRIPT.md for Module
```
No SCRIPT.md found for module "{module-key}".
Expected at: lesson-modules/{module-key}/SCRIPT.md
Cannot build review rubric without the module script.
```

### MCP Unavailable for Session Analysis
```
cclogviewer MCP is not available. Session analysis will use data from the zip's sessions/ directory instead.
```
If the zip also has no session data:
```
No session data available. The Process dimension will be scored as N/A and excluded from the overall grade.
```

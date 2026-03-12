---
name: cc-course:review
description: Review student submissions with detailed feedback, PDF reports, and parallel agent execution. Usage: /cc-course:review <path-to-zip-or-directory>
argument-hint: "<path-to-zip-or-directory>"
---

# Review Student Submissions

Analyze student homework submissions and produce detailed, critical reviews with scoring across 5 dimensions. Each reviewer agent writes reports directly to a `reviews/` folder — instructor report and student feedback as both markdown and PDF.

## Input Modes

`$ARGUMENTS` can be:
1. **A zip file path** — single submission review
2. **A directory path** — batch review of all `seminar*.zip` files in the directory
3. **Empty** — auto-discover mode

### Auto-Discover (no arguments)

1. Scan `{cwd}` for `seminar*.zip` files
2. If none, check for a `submissions/` subdirectory and scan that
3. If exactly one zip found, use single mode
4. If multiple zips found, use batch mode
5. If nothing found, ask the user for the path

### Path Resolution

If the path is relative, resolve it against `{cwd}`. Verify the path exists before proceeding.

---

## Mode 1: Single Submission Review

When `$ARGUMENTS` points to a **single zip file**.

### Steps

1. **Validate zip** — confirm file exists and is a valid zip archive
2. **Determine submissions directory** — the parent directory of the zip file
3. **Compute output directory**:
   ```
   SUBMISSIONS_DIR = parent directory of the zip
   REVIEWS_DIR = SUBMISSIONS_DIR/reviews
   STUDENT_DIR = REVIEWS_DIR/{zip-basename-without-ext}
   ```
4. **Unzip** to a temporary directory:
   ```bash
   REVIEW_DIR="/tmp/cc-review-$(date +%s)"
   mkdir -p "$REVIEW_DIR"
   unzip -o "{path}" -d "$REVIEW_DIR"
   ```
5. **Read `manifest.json`** — extract module key and student info
6. **Launch a reviewer agent** using the Agent tool:
   - `subagent_type`: `"general-purpose"`
   - Prompt: use the Agent Prompt Template below, passing `REVIEW_DIR`, `STUDENT_DIR`, module key, and plugin root
7. **After agent completes** — the agent has already written all files to `STUDENT_DIR`
8. **Display results**:
   ```
   Review complete. Reports saved to:
     Instructor: {STUDENT_DIR}/instructor-report.pdf
     Student:    {STUDENT_DIR}/student-feedback.pdf
   ```
9. **Cleanup**:
   ```bash
   rm -rf "$REVIEW_DIR"
   ```

---

## Mode 2: Batch Review (Directory)

When `$ARGUMENTS` points to a **directory** containing `seminar*.zip` files.

### Steps

1. **Glob** for `seminar*.zip` files in the directory
2. If no zips found:
   ```
   No seminar*.zip files found in {directory}.
   ```
3. **Show batch preview**:
   ```
   Found {N} submissions to review:
     - seminar1-jane-doe-2026-02-10.zip
     - seminar1-john-smith-2026-02-10.zip
     - ...

   Launching {N} reviewer agents in parallel...
   ```
4. **For each zip**, compute:
   - `REVIEW_DIR` — unique temp directory for unpacking
   - `STUDENT_DIR` — output directory under `{directory}/reviews/{zip-basename-without-ext}/`
5. **Unzip all** — each to its own temporary directory
6. **Quick-read each manifest.json** — extract module key for each
7. **Launch ALL reviewer agents in parallel** — use the Agent tool with multiple calls in a **single message**:
   - One agent per zip file
   - Each agent receives its own `REVIEW_DIR`, `STUDENT_DIR`, and module key
   - Each agent writes its own reports directly — no post-processing needed
   - All agents run concurrently

8. **After all agents complete** — collect `REVIEW_RESULT|...` lines from each agent's output

9. **Write batch summary** to `{directory}/reviews/batch-summary.md`:

   ```markdown
   # Batch Review Summary

   **Date**: {current date}
   **Submissions reviewed**: {N}

   ## Results

   | Student | Module | Grade | Score | Flags |
   |---------|--------|-------|-------|-------|
   | {from REVIEW_RESULT lines} |

   ## Distribution

   | Grade | Count |
   |-------|-------|
   | Excellent | {N} |
   | Good | {N} |
   | Satisfactory | {N} |
   | Needs Improvement | {N} |
   | Incomplete | {N} |

   ## Flagged Submissions

   {List submissions with CRITICAL or WARNING flags}
   ```

10. **Display batch summary** inline and note:
    ```
    Individual reports saved to: {directory}/reviews/
    Batch summary: {directory}/reviews/batch-summary.md

    {N} submissions reviewed. {N} flagged for attention.
    ```

11. **Cleanup** all temporary directories:
    ```bash
    rm -rf /tmp/cc-review-*
    ```

---

## Agent Prompt Template

Every reviewer agent (single or batch) receives this prompt. The agent is fully responsible for creating the output folder, writing reports, and generating PDFs.

```
You are a homework reviewer for the Claude Code developer course.

READ THESE FILES FIRST (in this order):
1. {plugin_root}/agents/reviewer.md — your persona, behavioral guidelines, and report formats
2. {plugin_root}/skills/review.md — the complete review methodology (Phases 1-6: rubric, scoring, feedback, persistence)
3. {plugin_root}/lesson-modules/{module-key}/SCRIPT.md — the module's teaching script (for dynamic rubric extraction)

SUBMISSION TO REVIEW:
- Unpacked at: {REVIEW_DIR}
- Original zip: {zip_filename}
- Contains: manifest.json, student-work/, progress/, sessions/

OUTPUT DIRECTORY: {STUDENT_DIR}
You MUST write all reports to this directory. Create it if it doesn't exist.

YOUR TASK:
1. Read manifest.json and progress/progress.json from {REVIEW_DIR}
2. Follow the review pipeline in skills/review.md (Phases 1-5)
3. Use cclogviewer MCP tools to analyze session data (MANDATORY — see agents/reviewer.md)
4. Score all 5 dimensions, detect flags, generate both reports
5. Write reports to {STUDENT_DIR} (Phase 6 of skills/review.md):
   a. Create directory: mkdir -p {STUDENT_DIR}
   b. Write {STUDENT_DIR}/instructor-report.md (full review with all flags and MCP evidence)
   c. Write {STUDENT_DIR}/student-feedback.md (constructive student-facing version — NO fraud flags, NO raw MCP data)
   d. Generate PDFs if pandoc+weasyprint are available:
      pandoc {STUDENT_DIR}/instructor-report.md -o {STUDENT_DIR}/instructor-report.pdf --pdf-engine=weasyprint
      pandoc {STUDENT_DIR}/student-feedback.md -o {STUDENT_DIR}/student-feedback.pdf --pdf-engine=weasyprint
   e. If pandoc/weasyprint unavailable, skip PDFs and note in output
6. End your output with: REVIEW_RESULT|{name}|{module}|{grade}|{score}|{flags}
```

---

## Error Handling

### File Not Found
```
File not found: {path}
Provide the path to a seminar submission zip or a directory containing submissions.
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

### Empty Directory
```
No seminar*.zip files found in {directory}.
Ensure submission zips are in this directory (created by /cc-course:submit).
```

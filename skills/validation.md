# Validation System

Validation logic shared by course subcommands.

## Parsing SCRIPT.md for Checks

Read the SCRIPT.md for the current module and extract YAML verification blocks containing:
- `chapter:` — Chapter identifier
- `type:` — `automated` or `manual`
- `verification:` — Check definitions
- `task_key:` — Maps to progress.json task

---

## Verification Block Types

### file_exists
```yaml
- file_exists: "CLAUDE.md"
  task_key: create_claude_md
```
**Check**: File exists at the specified path in student's repository.
**Result**: PASS if file exists, FAIL otherwise.

### file_contains
```yaml
- file_contains: ["## Overview", "# Project"]
  task_key: add_project_overview
```
**Check**: File contains at least one of the listed strings.
**Result**: PASS if at least one string found, FAIL otherwise.

### file_quality
```yaml
- file_quality:
    path: "CLAUDE.md"
    max_lines: 500
    warn_lines: 300
    max_chars: 40000
    required_sections:
      - "^#+ .*Overview|^# Project"
      - "^#+ .*(Tech Stack|Stack|Technologies)"
    warn_patterns:
      - pattern: "TODO|FIXME"
        message: "Contains placeholder text"
  task_key: claude_md_quality
```
**Check**: Comprehensive file quality validation including size, sections, and patterns.
**Result**: PASS if no errors, report warnings separately.

### directory_exists
```yaml
- directory_exists: ".claude/commands"
  task_key: create_commands_directory
```
**Check**: Directory exists at the specified path.
**Result**: PASS if directory exists, FAIL otherwise.

### file_pattern
```yaml
- file_pattern: ".claude/commands/*.md"
  min_count: 1
  task_key: create_custom_command
```
**Check**: At least `min_count` files match the glob pattern.
**Result**: PASS if count >= min_count, FAIL otherwise.

### git_committed
```yaml
- git_committed: "CLAUDE.md"
  task_key: commit_claude_md
```
**Check**: File appears in git log (has been committed).
**Result**: PASS if output is non-empty, FAIL otherwise.

### command
```yaml
verification:
  command: "which claude && claude --version"
  success_pattern: "claude"
  task_key: install_claude_code
```
**Check**: Command exits successfully and output matches pattern.
**Result**: PASS if command succeeds and pattern matches, FAIL otherwise.

### manual
```yaml
verification:
  questions:
    - "Ask Claude about your project and verify accurate response"
  task_key: test_claude_understanding
```
**Check**: Ask the user to confirm they completed the task.
**Result**: PASS if user confirms, PENDING if not yet asked.

> **IMPORTANT**: For manual checks, if the student reports the task **failed** or **didn't work**, do NOT mark it as PASS. Instead: diagnose the issue, troubleshoot, and only mark PASS after the student either succeeds or explicitly agrees to move on after understanding the concept (see teaching.md "Learner reports a task didn't work").

---

## CLAUDE.md Quality Checks

Based on official Anthropic documentation, validate CLAUDE.md files:

| Check | Threshold | Type |
|-------|-----------|------|
| Line count | < 500 lines | Error |
| Line count | > 300 lines | Warning |
| Character count | < 40,000 chars | Error |
| Project Overview | `^#+ .*Overview` or `^# Project` | Required |
| Tech Stack | `^#+ .*(Tech Stack\|Stack\|Technologies)` | Required |
| Conventions | `^#+ .*(Convention\|Standards\|Code Style)` | Required |
| Commands | `^#+ .*(Commands?)` | Required |
| File references | Suggest `@path/to/file` if > 200 lines | Suggestion |
| Placeholder text | Warn on `TODO\|FIXME` patterns | Warning |

### Quality Report Format

```
CLAUDE.md Quality Check
-----------------------
[PASS] Line count: 127 lines (limit: 500)
[PASS] Character count: 4,532 chars (limit: 40,000)
[PASS] Project Overview section found
[PASS] Tech Stack section found
[WARN] Conventions section missing - add coding standards
[PASS] Commands section found
[WARN] Found 2 TODO markers - consider completing or removing

Overall: 4/5 required sections, 2 warnings
```

---

## Running Checks

For each task in the module's tasks list:

1. Parse the verification block from SCRIPT.md
2. Run the appropriate check based on type
3. If PASS: Set `modules[module].tasks[task_key] = true`
4. If FAIL: Leave as `false`
5. Append completed tasks to current session's `tasks_completed`
6. Save progress.json

---

## Validation Report Format

```
VALIDATION: Module [X] - [Name]

[PASS] task_name: Description
[PASS] task_name: Description
[PASS] task_name: Description
  [WARN] Warning: Found 1 TODO marker
[FAIL] task_name: Description
[PEND] task_name: Needs verification

Result: X/Y checks passed

[Next steps message]
```

## Status Icons

- `[PASS]` = Passed
- `[FAIL]` = Failed
- `[PEND]` = Needs manual verification
- `[WARN]` = Warning (non-blocking)

---

## On Module Completion

When all checks pass:

1. Update progress.json:
   - Set `modules[module].status = "completed"`
   - Set `modules[module].completed_at = <timestamp>`
   - Unlock next module

2. End current session:
   - Set `session.ended_at = <timestamp>`

3. Offer session export:
   ```
   Module complete! Would you like to export your session logs?

   This will save:
   - Session logs to exports/seminarN-session-{uuid}.json
   - Summary stats to exports/seminarN-summary-{uuid}.json
   - Visual report to exports/seminarN-report.html (optional)

   [Yes, export] [No, skip] [Yes, with HTML report]
   ```

4. If user accepts export, run MCP calls:
   ```
   mcp__cclogviewer__get_session_logs(
     session_id=<session_id>,
     output_path="./exports/seminarN-session-{session_id}.json"
   )

   mcp__cclogviewer__get_session_summary(
     session_id=<session_id>,
     output_path="./exports/seminarN-summary-{session_id}.json"
   )
   ```

5. Record export in progress.json under `exports[]`

6. Show next steps:
   ```
   Ready for Module [N+1]? Type /cc-course:start [N+1] to continue.
   ```

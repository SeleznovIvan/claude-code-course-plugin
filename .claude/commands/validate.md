---
name: validate
description: Validate completion of the current module by checking all required files and configurations exist.
---

# Validate Current Module

Run validation checks for the current module and report what's complete vs. what's missing.

## Overview

This command uses the **course-tutor** skill to:
1. Read progress.json to get current module
2. Dynamically parse SCRIPT.md for verification criteria
3. Run checks based on type definitions
4. Update progress.json with results
5. Offer session export if module complete

## Validation Workflow

### Step 1: Load Context

1. Read `progress.json` to get:
   - Current module (e.g., `1-foundations-and-commands`)
   - Student's repository path
   - Current session ID

2. If no module in progress:
   - Show message: "No module in progress. Run /start-1 to begin."
   - Exit

### Step 2: Parse SCRIPT.md

Read `lesson-modules/[module]/SCRIPT.md` and extract all YAML verification blocks.

Look for patterns:
```yaml
verification:
  checks:
    - <check_type>: <value>
      task_key: <key>
```

Build a map of task_key -> check definition.

### Step 3: Run Checks by Type

For each task in the module's tasks list, run the appropriate check:

#### file_exists
```
Check if file exists at the specified path in student's repository.
Result: PASS if file exists, FAIL otherwise.
```

#### file_contains
```
Read the file and check if it contains any of the listed strings.
Result: PASS if at least one string found, FAIL otherwise.
```

#### file_quality
```
Comprehensive CLAUDE.md quality validation:
1. Count lines (fail if > max_lines, warn if > warn_lines)
2. Count characters (fail if > max_chars)
3. Check for required sections (regex patterns)
4. Scan for warning patterns (TODO/FIXME, placeholders)
5. Suggest file references if file is long

Result: PASS if no errors, report warnings separately.
```

#### directory_exists
```
Check if directory exists at the specified path.
Result: PASS if directory exists, FAIL otherwise.
```

#### file_pattern
```
Use glob to find files matching the pattern.
Count matches and compare to min_count.
Result: PASS if count >= min_count, FAIL otherwise.
```

#### git_committed
```
Run: git log --oneline <file_path>
Result: PASS if output is non-empty, FAIL otherwise.
```

#### command
```
Run the specified command.
Check exit code and optionally match success_pattern.
Result: PASS if command succeeds and pattern matches, FAIL otherwise.
```

#### manual
```
Ask the user the verification questions.
Record their confirmation.
Result: PASS if user confirms, PENDING if not yet asked.
```

### Step 4: CLAUDE.md Quality Check

For Module 1, always run the quality check on CLAUDE.md:

```
Quality Criteria:
- Line count: < 500 (error), > 300 (warning)
- Character count: < 40,000
- Required sections:
  - Project Overview (^#+ .*Overview|^# Project)
  - Tech Stack (^#+ .*(Tech Stack|Stack|Technologies))
  - Conventions (^#+ .*(Convention|Standards|Code Style))
  - Commands (^#+ .*(Commands?))
- Warning patterns:
  - TODO|FIXME (placeholder text)
  - \[.*\] (unfilled brackets)
- Suggestion: Use @references if > 200 lines
```

### Step 5: Update Progress

For each check:
1. If PASS: Set `modules[module].tasks[task_key] = true`
2. If FAIL: Leave as `false`
3. Append completed tasks to current session's `tasks_completed`
4. Save progress.json

### Step 6: Generate Report

```
╔═══════════════════════════════════════════════════════════════╗
║  VALIDATION: Module [X] - [Name]                              ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ install_claude_code: Claude Code is installed             ║
║  ✅ create_claude_md: CLAUDE.md exists                        ║
║  ✅ claude_md_quality: Quality checks passed                  ║
║     ⚠️  Warning: Found 1 TODO marker                          ║
║  ✅ add_project_overview: Overview section found              ║
║  ❌ add_conventions: Missing conventions section              ║
║  ⏳ test_claude_understanding: Needs verification             ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  Result: 8/12 checks passed                                   ║
║                                                               ║
║  Fix the issues above, then run /validate again.              ║
║  Need help? Try /hint                                         ║
╚═══════════════════════════════════════════════════════════════╝
```

### Step 7: Handle Completion

If ALL checks pass:

1. Update progress.json:
   - Set `modules[module].status = "completed"`
   - Set `modules[module].completed_at = <timestamp>`
   - Unlock next module

2. End current session:
   - Set `session.ended_at = <timestamp>`

3. Offer session export:
   ```
   🎉 Module complete! Would you like to export your session logs?

   This will save:
   - Session logs to exports/seminar1-session-{uuid}.json
   - Summary stats to exports/seminar1-summary-{uuid}.json
   - Visual report to exports/seminar1-report.html (optional)

   [Yes, export] [No, skip] [Yes, with HTML report]
   ```

4. If user accepts export, run MCP calls:
   ```
   mcp__cclogviewer__get_session_logs(
     session_id=<session_id>,
     output_path="./exports/seminar1-session-{session_id}.json"
   )

   mcp__cclogviewer__get_session_summary(
     session_id=<session_id>,
     output_path="./exports/seminar1-summary-{session_id}.json"
   )
   ```

5. Record export in progress.json

6. Show next steps:
   ```
   Ready for Module 2? Type /start-2 to continue.
   ```

## Status Icons

- ✅ = Passed
- ❌ = Failed
- ⏳ = Needs manual verification
- ⚠️ = Warning (non-blocking)

## Error Handling

### No Module in Progress
```
You haven't started a module yet.
Run /start-1 to begin the course.
```

### SCRIPT.md Not Found
```
Could not find lesson script for module: [module]
Expected: lesson-modules/[module]/SCRIPT.md
```

### MCP Unavailable for Export
```
Session export unavailable - cclogviewer MCP not configured.
Your progress has been saved. You can export manually later.
```

## Relationship to Other Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/validate` | Check completion, run all checks | Verify progress, check quality |
| `/start-1` | Begin/resume module, teach content | Start learning |
| `/status` | Quick progress dashboard | Check where you are |
| `/hint` | Contextual help for current task | When stuck |

`/validate` is the most comprehensive check - use it to verify you're ready to advance.

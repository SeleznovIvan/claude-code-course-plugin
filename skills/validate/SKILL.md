---
name: cc-course:validate
description: Check if current module requirements are complete
---

# Validate Module Completion

Run validation checks for the current module.

## Progress File Location

> **PROGRESS DISCOVERY** (works after `/clear`):
>
> 1. `Read` the file `{cwd}/.claude/claude-course/progress.json` where `{cwd}` is your current working directory — this is the student's project repo
> 2. If not found, run `Bash: git rev-parse --show-toplevel` to get the git root, then `Read` `{git-root}/.claude/claude-course/progress.json`
> 3. If neither exists, ask the user for their repository path
>
> **NEVER** read a `progress.json` from any path containing `plugins/` or `cache/` — those are blank templates, not student data.

## Determine Module

Read `progress.json` to find `current_module`.

If no module in progress:
```
No module in progress. Run /cc-course:start 1 to begin.
```

## Validation Logic

For the complete validation system with all check types, read [validation.md](../validation.md).

## Check Types Supported

- `file_exists` - File exists at path
- `file_contains` - File contains specified strings
- `file_quality` - Comprehensive quality validation
- `directory_exists` - Directory exists at path
- `file_pattern` - Files match glob pattern
- `git_committed` - File has been committed
- `command` - Command runs successfully
- `manual` - User confirms completion

## After Validation

1. Update `progress.json` with results
2. If complete, unlock next module
3. End current session with timestamp
4. Offer session export via cclogviewer

## Report Format

```
VALIDATION: Module [X] - [Name]

[check-result] task_name: Description
[check-result] task_name: Description
  [warning] Warning message if applicable
...

Result: X/Y checks passed

[Next steps based on result]
```

## On Completion

When all checks pass:
1. Set module status to "completed"
2. Unlock next module
3. Export session data to `{student-repo}/.claude/claude-course/sessions/`
4. Prompt for homework submission
5. Show summary and next steps

### Submission Prompt

After successful validation, prompt the user:

```
Module complete! Would you like to submit your work for instructor review?

This will package:
- Your CLAUDE.md and custom commands
- Progress snapshot
- Session logs for instructor review

[1] Yes, submit now (Recommended)
[2] No, I'll submit later with /cc-course:submit

Your work is already validated - submission is for instructor feedback.
```

If user chooses "Yes":
- Invoke the submit skill logic (see [submission.md](../submission.md))
- Create zip in `{student-repo}/.claude/claude-course/submissions/`

If user chooses "No":
- Show reminder: "Run /cc-course:submit when ready"
- Continue to next steps

## Error Handling

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

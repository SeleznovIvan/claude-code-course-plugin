---
name: cc-course:validate
description: Check if current module requirements are complete
---

# Validate Module Completion

Run validation checks for the current module.

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
3. Offer session export
4. Show summary and next steps

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

---
name: cc-course:submit
description: Package completed module work into a zip archive for instructor review
argument-hint: "[module-number]"
---

# Submit Module Work

Package your completed module work into a submission archive for instructor review.

## Before Submitting

> **PROGRESS DISCOVERY** (works after `/clear`):
>
> 1. `Read` the file `{cwd}/.claude/claude-course/progress.json` where `{cwd}` is your current working directory — this is the student's project repo
> 2. If not found, run `Bash: git rev-parse --show-toplevel` to get the git root, then `Read` `{git-root}/.claude/claude-course/progress.json`
> 3. If neither exists, ask the user for their repository path
>
> **NEVER** read a `progress.json` from any path containing `plugins/` or `cache/` — those are blank templates, not student data.

1. Find and read `progress.json` using the discovery block above
2. Verify the module has been completed (all tasks passed)
3. If not completed, prompt to run validation first

## Argument Handling

If `$ARGUMENTS` is provided:
- Use as module number (1-5)
- Map to module key: `{N}-{module-name}`

If `$ARGUMENTS` is empty:
- Use `current_module` from progress.json
- If no current module, use most recently completed module

## Module Mapping

| Argument | Module Key |
|----------|-----------|
| 1 | 1-foundations-and-commands |
| 2 | 2-skills |
| 3 | 3-extensions |
| 4 | 4-agents |
| 5 | 5-workflows |

## Submission Logic

For the complete submission system with manifest schema and artifact lists, read [submission.md](../submission.md).

## Validation Check

Before packaging, verify:

```python
module_key = get_module_key(module_number)
module_data = progress["modules"][module_key]

if module_data["status"] != "completed":
    print("Module not complete. Run /cc-course:validate first.")
    return
```

## Gather Artifacts

### 1. Student Work Files

For Module 1, collect:
- `{repo}/CLAUDE.md` (required)
- `{repo}/.claude/commands/*.md` (required, min 1)

### 2. Progress Snapshot

Copy `{student-repo}/.claude/claude-course/progress.json`

### 3. Session Data via MCP

Get session IDs from progress.json:

```python
sessions = progress["modules"][module_key]["sessions"]
```

For each session, call MCP:

```
mcp__cclogviewer__get_session_logs(
    session_id=session["session_id"],
    project=student_repo
)
```

```
mcp__cclogviewer__get_session_summary(
    session_id=session["session_id"],
    project=student_repo
)
```

Save responses as JSON files for inclusion in zip.

## Create Manifest

Build manifest.json with:
- Submission metadata (version, seminar, timestamp)
- Student info (name, role, repository)
- Validation results (passed status, task completion)
- Artifact inventory (files included, counts)
- Session summary (count, duration, file list)

See [submission.md](../submission.md) for full schema.

## Create Zip Archive

### Filename

```
seminar{N}-{sanitized-name}-{YYYY-MM-DD}.zip
```

### Structure

```
seminar1-jane-doe-2026-02-10.zip
├── manifest.json
├── student-work/
│   ├── CLAUDE.md
│   └── .claude/
│       └── commands/
│           └── *.md
├── progress/
│   └── progress.json
└── sessions/
    ├── {session-id}-logs.json
    └── {session-id}-summary.json
```

### Zip Creation

Use the Bash tool with `zip` command:

```bash
cd {temp-staging-dir}
zip -r {output-path} .
```

Or use Python's zipfile module if available.

## Output Location

Default location:
```
{student-repo}/.claude/claude-course/submissions/seminar{N}-{name}-{date}.zip
```

Ask user:
```
Where would you like to save the submission?
[1] Default: .claude/claude-course/submissions/ (Recommended)
[2] Custom location
```

## Update Progress

After successful submission, update progress.json:

```json
"modules": {
  "1-foundations-and-commands": {
    "submission": {
      "submitted_at": "2026-02-10T14:30:00Z",
      "file_path": "/path/to/submission.zip",
      "file_size_bytes": 45678
    }
  }
}
```

## Success Message

```
Submission created successfully!

File: seminar1-jane-doe-2026-02-10.zip
Location: {path}
Size: {size} KB

Contents:
- manifest.json
- student-work/CLAUDE.md
- student-work/.claude/commands/ ({N} files)
- progress/progress.json
- sessions/ ({N} session files)

To submit for review, share this file with your instructor.

Next: Ready for Module 2? Run /cc-course:start 2
```

## Error Handling

### Module Not Completed

```
Module {N} is not complete.

Run /cc-course:validate to check what's missing.
```

### CLAUDE.md Missing

```
Error: CLAUDE.md is required for submission but was not found.

Create CLAUDE.md in your repository root and run /cc-course:validate.
```

### No Commands Found (Module 1)

```
Warning: No custom commands found in .claude/commands/

This is a required artifact for Module 1. Would you like to:
[1] Continue anyway (partial submission)
[2] Cancel and create a command first

Hint: Run /cc-course:hint for help creating your first command.
```

### MCP Unavailable

```
Warning: Session data unavailable - cclogviewer MCP not configured.

Proceeding without session logs. Your submission will include:
- Student work files
- Progress snapshot

Note: Instructor review may be limited without session history.
```

### No Sessions Recorded

```
Error: No sessions recorded for this module.

At least one session must be tracked in progress.json.
This happens automatically when you run /cc-course:start.

Run /cc-course:start {N} to begin a tracked session, complete the
module tasks, then run /cc-course:submit.
```

### Already Submitted

```
A previous submission exists:
  File: seminar1-jane-doe-2026-02-08.zip
  Submitted: 2026-02-08

Would you like to create a new submission?
[1] Yes, overwrite previous
[2] No, keep existing
```

### Zip Creation Failed

```
Error creating submission archive: {error message}

Please check:
- Disk space available
- Write permissions to output directory
- All source files are readable

Try running /cc-course:submit again or contact support.
```

---
name: cc-course:status
description: View your course progress dashboard
---

# Course Progress Dashboard

Display the learner's progress through the Claude Code Developer Course.

## Data Source

> **PROGRESS DISCOVERY** (works after `/clear`):
>
> 1. `Read` the file `{cwd}/.claude/claude-course/progress.json` where `{cwd}` is your current working directory — this is the student's project repo
> 2. If not found, run `Bash: git rev-parse --show-toplevel` to get the git root, then `Read` `{git-root}/.claude/claude-course/progress.json`
> 3. If neither exists, ask the user for their repository path
>
> **NEVER** read a `progress.json` from any path containing `plugins/` or `cache/` — those are blank templates, not student data.

## Display Format

For the complete dashboard rendering logic and visual format, read [status.md](../status.md).

## Include

- Student info (name, role, repository)
- Module completion status (completed/in_progress/locked)
- Task counts per module
- Submission status per module
- Overall progress percentage
- Total submissions count
- Session information
- Next steps recommendation

## Status Icons

- Completed modules
- In Progress modules (current)
- Locked modules (prerequisites not met)
- Skipped items (if any)

## If No Progress Yet

If progress.json shows no student info:

```
CLAUDE CODE DEVELOPER COURSE

You haven't started the course yet!

To begin, type: /cc-course:start 1

This will:
- Set up your profile
- Begin Module 1: Foundations & Commands
- Guide you through CLAUDE.md and your first command
```

## Session Info

If sessions have been recorded, show:
- Total sessions across all modules
- Current session ID (if active)
- Exports available (if any)

## Submission Info

Show submission status for each module:
- "Submitted" - Work has been packaged for review
- "Ready to submit" - Module complete but not yet submitted
- Empty - Module not yet completed

Show overall submission count: "SUBMISSIONS: X/5 submitted"

If completed modules are not submitted, show reminder:
```
Note: Module [N] is complete but not yet submitted.
Run /cc-course:submit [N] to package your work for instructor review.
```

---
name: course:status
description: View your course progress dashboard
---

# Course Progress Dashboard

Display the learner's progress through the Claude Code Developer Course.

## Data Source

Read `progress.json` for all progress data.

## Display Format

For the complete dashboard rendering logic and visual format, read [status.md](../status.md).

## Include

- Student info (name, role, repository)
- Module completion status (completed/in_progress/locked)
- Task counts per module
- Overall progress percentage
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

To begin, type: /course:start 1

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

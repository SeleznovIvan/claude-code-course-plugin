---
name: cc-course:hint
description: Get contextual help for your current course task
argument-hint: "[hint-level 1-4]"
---

# Course Hint System

Provide a hint for the learner's current task.

## Determine Context

> **PROGRESS DISCOVERY** (works after `/clear`):
>
> 1. `Read` the file `{cwd}/.claude/claude-course/progress.json` where `{cwd}` is your current working directory — this is the student's project repo
> 2. If not found, run `Bash: git rev-parse --show-toplevel` to get the git root, then `Read` `{git-root}/.claude/claude-course/progress.json`
> 3. If neither exists, ask the user for their repository path
>
> **NEVER** read a `progress.json` from any path containing `plugins/` or `cache/` — those are blank templates, not student data.

1. Find and read `progress.json` using the discovery block above
2. Find `current_module` and `current_task`
3. If no active task, guide learner to start a module

## Hint Level

- If `$ARGUMENTS` provided, use that level (1-4)
- Otherwise, start at level 1 and escalate on repeated requests

## Hint Logic

For the complete hint system with escalation levels and role-specific examples, read [hints.md](../hints.md).

## Response Format

```
Hint for: [Current Task]

[Hint text based on level]

---
Still stuck? Type /cc-course:hint again for more detailed help.
Or describe specifically what's blocking you.
```

## Escalation

Track hint level in progress.json under current task. If this is their 3rd+ hint for the same task:

```
Let's work through this together.

I'll guide you step by step. First, [first concrete action].

What do you see when you try that?
```

## No Active Module

If no module is in progress:

```
You haven't started a module yet.
Run /cc-course:start 1 to begin the course.
```

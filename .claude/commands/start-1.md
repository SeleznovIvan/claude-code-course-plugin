---
name: start-1
description: Start Module 1 - Foundations & Commands. Learn to install Claude Code, create CLAUDE.md, use commands, and create a custom command.
---

# Module 1: Foundations & Commands

You are starting the **Foundations & Commands** module. This is where the journey begins.

## Session Tracking

When this command is invoked:

1. **Record session start** using MCP cclogviewer:
   ```
   mcp__cclogviewer__list_sessions(
     project=<auto-detect-from-cwd>,
     days=1,
     limit=1
   )
   ```

2. **Create session record** in progress.json:
   ```json
   {
     "session_id": "<uuid-from-mcp>",
     "started_at": "<ISO timestamp>",
     "ended_at": null,
     "tasks_completed": []
   }
   ```

3. **Update progress.json**:
   - Append session to `modules["1-foundations-and-commands"].sessions`
   - Set `current_session_id`
   - Set `current_module = "1-foundations-and-commands"`
   - Set module `status = "in_progress"` if was `"not_started"`
   - Set `started_at` timestamp if first session

## Pre-flight Checks

1. Read `progress.json` to check the learner's state

2. If this is a **new learner**:
   - Welcome them to the course
   - Ask for their name, role, and repository path
   - Save this to `progress.json` under `student`

3. If **returning learner**:
   - Welcome them back by name
   - Show their progress in this module (completed tasks / total)
   - Resume from where they left off

## Module Objectives

By the end of this module, the learner will:
- Have Claude Code installed and authenticated
- Understand basic CLI interactions
- Create a comprehensive CLAUDE.md for their project
- Use essential slash commands fluently
- Understand and use plan mode
- Create their first custom slash command

## Teaching Content

Read the detailed teaching content from:
`lesson-modules/1-foundations-and-commands/SCRIPT.md`

Follow each chapter in order:
1. **Chapter 1**: What is Claude Code? (conceptual)
2. **Chapter 2**: Installation & Authentication
3. **Chapter 3**: Basic CLI Interactions
4. **Chapter 4**: CLAUDE.md - Your Project's Memory (includes quality checks)
5. **Chapter 5**: Testing Your Setup
6. **Chapter 6**: Essential Slash Commands
7. **Chapter 7**: Plan Mode
8. **Chapter 8**: Creating Custom Commands
9. **Chapter 9**: Commit Your Work

## Task Tracking

Task keys for this module (in order of completion):
- `install_claude_code` - Chapter 1.2
- `create_claude_md` - Chapter 1.4
- `claude_md_quality` - Chapter 1.4 (NEW: quality validation)
- `add_project_overview` - Chapter 1.4
- `add_tech_stack` - Chapter 1.4
- `add_conventions` - Chapter 1.4
- `test_claude_understanding` - Chapter 1.5
- `explore_slash_commands` - Chapter 1.6
- `test_session_commands` - Chapter 1.6
- `use_plan_mode` - Chapter 1.7
- `create_custom_command` - Chapter 1.8
- `commit_work` - Chapter 1.9

When a task is completed:
1. Set `modules[module].tasks[task_key] = true`
2. Append `task_key` to current session's `tasks_completed`
3. Save progress.json

## Validation During Teaching

After each chapter, use the verification block in SCRIPT.md to:
- Run automated checks where specified
- Ask manual verification questions
- Update progress.json with completed tasks
- Move to next chapter when verification passes

## Module Completion

When all tasks are complete:

1. **Update progress.json**:
   - Set module status to `"completed"`
   - Set `completed_at` timestamp
   - Set module 2-skills status to `"unlocked"`
   - End current session (`ended_at` timestamp)

2. **Offer session export** (via course-tutor):
   ```
   🎉 Module 1 complete! Would you like to export your session logs?

   This will save your learning session for review.
   [Yes] [No] [Yes, with HTML report]
   ```

3. **Show summary**:
   ```
   Excellent! You've completed Module 1: Foundations & Commands.

   What you created:
   - CLAUDE.md at [path]
   - Custom command at .claude/commands/[name].md

   Time spent: ~[X] minutes

   Ready for Module 2? Type /start-2 to learn about creating Skills.
   ```

## Error Handling

### MCP Unavailable
If cclogviewer MCP is not available:
- Log a warning: "Session tracking unavailable - cclogviewer MCP not configured"
- Continue without session tracking
- Use fallback session ID based on timestamp

### Progress File Issues
If progress.json is missing or corrupted:
- Create a fresh progress.json from template
- Warn user that previous progress may be lost

## Relationship to Other Commands

| Command | Purpose |
|---------|---------|
| `/start-1` | Begin/resume Module 1 (this command) |
| `/validate` | Check all tasks, verify completion |
| `/status` | Quick progress overview |
| `/hint` | Help with current task |

Use `/validate` at any time to check your progress without advancing the teaching.

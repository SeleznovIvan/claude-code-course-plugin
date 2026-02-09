---
name: status
description: Show your current progress through the Claude Code Developer Course.
---

# Course Status

Display the learner's progress through all modules.

This command uses the **course-tutor** skill for progress management.

## What to Show

1. Read `progress.json` via course-engine
2. Display a visual progress dashboard
3. Show session information if available

## Output Format

```
╔═══════════════════════════════════════════════════════════════╗
║              CLAUDE CODE DEVELOPER COURSE                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Student: [name]                                              ║
║  Role: [role]                                                 ║
║  Repository: [path]                                           ║
║  Started: [date]                                              ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  MODULE PROGRESS                                              ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  [✅/🔄/🔒] Module 1: Foundations & Commands  [status]        ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [✅/🔄/🔒] Module 2: Skills                  [status]        ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [✅/🔄/🔒] Module 3: Extensions              [status]        ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [✅/🔄/🔒] Module 4: Agents                  [status]        ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [✅/🔄/🔒] Module 5: Workflows               [status]        ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  OVERALL: [X]/5 modules complete                              ║
║  TIME SPENT: ~[X] minutes                                     ║
║  SESSIONS: [X] recorded                                       ║
║                                                               ║
║  [Current status message based on progress]                   ║
║                                                               ║
║  Next step: /start-[next-module]                              ║
╚═══════════════════════════════════════════════════════════════╝
```

## Session Information

If sessions have been recorded, show:
- Total sessions across all modules
- Current session ID (if active)
- Exports available (if any)

```
╠═══════════════════════════════════════════════════════════════╣
║  SESSION INFO                                                 ║
║  Current: abc123-def456                                       ║
║  Module 1 sessions: 2                                         ║
║  Exports: 1 available in ./exports/                           ║
╚═══════════════════════════════════════════════════════════════╝
```

## Status Icons

- ✅ = Completed
- 🔄 = In Progress
- 🔒 = Locked
- ⏭️ = Skipped (if any)

## Status Messages

Based on progress, show encouraging message:

- **Just started**: "Welcome! You're about to unlock Claude Code's full potential."
- **Module 1 done**: "Great foundation! Your project now has memory and custom commands."
- **Module 2 done**: "Skills created! Claude now knows your team's patterns."
- **Module 3 done**: "Extensions configured! Automation is working for you."
- **Module 4 done**: "One module left! You're almost a Claude Code master."
- **All done**: "🎓 Congratulations! You've completed the course!"

## If No Progress Yet

If progress.json shows no student info:

```
╔═══════════════════════════════════════════════════════════════╗
║              CLAUDE CODE DEVELOPER COURSE                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  You haven't started the course yet!                          ║
║                                                               ║
║  To begin, type: /start-1                                     ║
║                                                               ║
║  This will:                                                   ║
║  • Set up your profile                                        ║
║  • Begin Module 1: Foundations & Commands                     ║
║  • Guide you through CLAUDE.md and your first command         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

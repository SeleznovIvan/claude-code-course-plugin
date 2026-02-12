---
name: cc-course:continue
description: Signal that you've completed the current step and are ready to proceed
---

# Continue

The student is signaling they are ready to proceed to the next phase.

## Instructions

1. Read `progress.json` from the plugin root
2. Extract `current_module` and `current_task`
3. If found, output: **Continuing — Module: [current_module], Task: [current_task]**
4. If `progress.json` is missing or fields are empty, output: **Ready to continue.**
5. Resume the teaching flow — proceed to the next phase for the current chapter:
   - After **ACTION** phase → run **VERIFY**
   - After failed **VERIFY** → re-run **VERIFY**
   - After **CHECKPOINT** "I need more time" → resume where the student left off
   - After **CHECKLIST** → advance to the next chapter

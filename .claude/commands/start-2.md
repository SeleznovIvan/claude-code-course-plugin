---
name: start-2
description: Start Module 2 - Skills. Create reusable SKILL.md files that encode your team's best practices.
---

# Module 2: Skills

You are starting the **Skills** module. Time to teach Claude your team's playbooks.

## Pre-flight Checks

1. Read `progress.json`
2. Verify Module 1 is completed (if not, redirect to `/start-1`)
3. Note the learner's role and repository path

## Module Objectives

By the end of this module, the learner will:
- ✅ Understand the difference between CLAUDE.md and Skills
- ✅ Create a reference skill (standards/conventions)
- ✅ Create an action skill (step-by-step procedure)
- ✅ Test skills and see Claude's behavior change

## Teaching Script

Read the detailed teaching content from:
`lesson-modules/2-skills/SCRIPT.md`

Follow each chapter in order:
1. **Chapter 1**: What Are Skills?
2. **Chapter 2**: Skill File Structure
3. **Chapter 3**: Creating a Reference Skill
4. **Chapter 4**: Creating an Action Skill
5. **Chapter 5**: Testing Your Skills
6. **Chapter 6**: Advanced Skill Patterns
7. **Chapter 7**: Commit Your Skills

## Validation

Task keys for this module:
- `create_skills_directory`
- `write_reference_skill`
- `write_action_skill`
- `test_skills`
- `commit_skills`

## Completion

When all tasks are complete:

1. Update `progress.json`:
   - Set module status to "completed"
   - Unlock module 3-extensions

2. Celebrate!
   > "Amazing! You've taught Claude your team's playbooks!
   > Every new component/endpoint/test will follow your standards.
   >
   > Ready to add hooks and MCP? Type `/start-3`"

## Common Issues

**"Claude isn't using my skill"**
→ Check the description — is it specific enough to trigger?

**"The skill is too long"**
→ Keep SKILL.md under 500 lines; split details to separate files

**"I don't know what skills to create"**
→ Think: "What do I explain to new team members over and over?"

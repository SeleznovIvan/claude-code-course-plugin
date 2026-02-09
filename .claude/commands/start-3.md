---
name: start-3
description: Start Module 3 - Extensions. Create hooks, configure MCP servers, and build advanced commands.
---

# Module 3: Extensions

You are starting the **Extensions** module. Time to automate and integrate.

## Pre-flight Checks

1. Read `progress.json`
2. Verify Module 2 is completed (if not, redirect to `/start-2`)
3. Note the learner's role and tech stack

## Module Objectives

By the end of this module, the learner will:
- ✅ Create hooks for automated pre/post actions
- ✅ Configure at least one MCP server
- ✅ Build advanced custom commands
- ✅ Understand the extension ecosystem

## Teaching Script

Read the detailed teaching content from:
`lesson-modules/3-extensions/SCRIPT.md`

Follow each chapter in order:
1. **Chapter 1**: Understanding Hooks
2. **Chapter 2**: Creating Hooks
3. **Chapter 3**: Testing Hooks
4. **Chapter 4**: MCP (Model Context Protocol)
5. **Chapter 5**: Configuring MCP Servers
6. **Chapter 6**: Using MCP in Practice
7. **Chapter 7**: Advanced Custom Commands
8. **Chapter 8**: Commit Your Extensions

## Validation

Task keys for this module:
- `create_hook`
- `test_hook`
- `configure_mcp`
- `test_mcp`
- `create_advanced_command`
- `commit_extensions`

## Completion

When all tasks are complete:

1. Update `progress.json`:
   - Set module status to "completed"
   - Unlock module 4-agents

2. Celebrate!
   > "Incredible! You've extended Claude Code with automation superpowers!
   > Hooks save time, MCP connects data, commands capture workflows.
   >
   > Ready for multi-agent orchestration? Type `/start-4`"

## Common Issues

**"My hook isn't running"**
→ Check pattern matches your file path exactly

**"MCP server won't connect"**
→ Verify environment variables are set, check npx can access the package

**"Command doesn't do what I want"**
→ Be more specific in the instructions; reference your skills

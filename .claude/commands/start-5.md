---
name: start-5
description: Start Module 5 - Workflows. Build CI/CD integrations, GitHub Actions, and headless automation.
---

# Module 5: Workflows

You are starting the **Workflows** module — the final frontier!

## Pre-flight Checks

1. Read `progress.json`
2. Verify Module 4 is completed (if not, redirect to `/start-4`)
3. Confirm they have a GitHub repository (needed for this module)

## Module Objectives

By the end of this module, the learner will:
- ✅ Install and use the Claude GitHub App
- ✅ Create a GitHub Actions workflow with Claude
- ✅ Build headless automation scripts
- ✅ Document their complete Claude Code setup

## Teaching Script

Read the detailed teaching content from:
`lesson-modules/5-workflows/SCRIPT.md`

Follow each chapter in order:
1. **Chapter 1**: GitHub Integration Overview
2. **Chapter 2**: GitHub App Installation
3. **Chapter 3**: Creating GitHub Actions
4. **Chapter 4**: Headless Mode
5. **Chapter 5**: Creating Automation Scripts
6. **Chapter 6**: Testing Workflows
7. **Chapter 7**: Production Patterns
8. **Chapter 8**: Documenting Workflows
9. **Chapter 9**: Final Commit

## Validation

Task keys for this module:
- `install_github_app`
- `create_github_action`
- `test_headless`
- `create_automation_script`
- `test_workflow`
- `document_workflows`
- `final_commit`

## Course Completion! 🎓

When all tasks are complete:

1. Update `progress.json`:
   - Set module status to "completed"
   - Set graduation.completed = true
   - Set graduation.completed_at

2. **CELEBRATE!** 🎉

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🎓 CONGRATULATIONS! YOU'VE GRADUATED! 🎓                   ║
║                                                               ║
║   You've completed the Claude Code Developer Course!          ║
║                                                               ║
║   Your repository now has:                                    ║
║   ✅ CLAUDE.md with comprehensive project context             ║
║   ✅ Custom commands for your workflow                        ║
║   ✅ Skills encoding your team's best practices               ║
║   ✅ Hooks for automated workflows                            ║
║   ✅ MCP integrations for external tools                      ║
║   ✅ Multi-agent patterns documented                          ║
║   ✅ CI/CD integration with GitHub Actions                    ║
║   ✅ Headless automation scripts                              ║
║                                                               ║
║   You're now a Claude Code power user!                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

3. Show their complete setup and suggest next steps

## Common Issues

**"GitHub Action failed"**
→ Check secrets are set, verify workflow syntax

**"Script doesn't work"**
→ Check permissions (chmod +x), verify paths

**"PR review is wrong"**
→ Refine the prompt, add more context about your standards

---
name: hint
description: Get contextual help for your current task in the Claude Code Developer Course.
---

# Hint System

Provide contextual help based on where the learner is stuck.

This command uses the **course-tutor** skill for progress management.

## How Hints Work

1. Read `progress.json` via course-engine to find:
   - Current module
   - Current task (first incomplete task)
   - Student's role
2. Provide targeted help for that specific task
3. Adapt examples to their role/tech stack

## Hint Levels

Hints escalate if the learner keeps asking:

1. **Level 1**: Gentle nudge in the right direction
2. **Level 2**: More specific guidance
3. **Level 3**: Step-by-step walkthrough
4. **Level 4**: Do it together (pair programming)

Track hint level in progress.json under current task.

## Hints by Module and Task

### Module 1: Foundations

#### install_claude_code
**L1**: "Have you tried running `npm install -g @anthropic-ai/claude-code`?"
**L2**: "Make sure you have Node.js 18+ installed. Check with `node --version`."
**L3**: "Let's troubleshoot: What error do you see when running the install command?"
**L4**: "Let me help. Run these commands one at a time and tell me what happens..."

#### create_claude_md
**L1**: "Try running `/init` inside a Claude Code session in your repo."
**L2**: "If /init doesn't work well for your project, we can create CLAUDE.md manually."
**L3**: "Create a file called CLAUDE.md in your repo root. Start with: `# Project: [Your Name]`"
**L4**: "Let me help you create it. What's your project called?"

#### add_project_overview
**L1**: "Think: How would you describe this project to a new team member in 2-3 sentences?"
**L2**: "Add a `## Overview` section. What problem does this project solve? Who uses it?"
**L3**: "Here's a template: '## Overview\n[Project name] is a [type of app] that [main purpose] for [target users].'"

#### add_tech_stack
**L1**: "List the main technologies: language, framework, testing tool, build tool."
**L2**: "Check your package.json/requirements.txt/go.mod - what dependencies are core to the project?"
**L3**: "Add: '## Tech Stack\n- Language: [X]\n- Framework: [Y]\n- Testing: [Z]'"

#### add_conventions
**L1**: "What rules does your team follow? Naming? File organization? Code style?"
**L2**: "Think about: How do you name files? Where do tests go? What patterns do you use?"
**L3**: "Even simple conventions help: 'We use camelCase for variables, PascalCase for components.'"

#### claude_md_quality
**L1**: "Run /validate to check your CLAUDE.md quality. Look for warnings about size and placeholders."
**L2**: "Common issues: TODO markers, unfilled [brackets], missing sections. Check the validation output."
**L3**: "Quality checks: < 500 lines, < 40K chars, has Overview/Tech Stack/Conventions/Commands sections."
**L4**: "Let me review your CLAUDE.md and suggest specific improvements."

### Module 2: Commands

#### explore_slash_commands
**L1**: "Just type `/help` to see all available commands."
**L2**: "Try these five: /help, /doctor, /config, /cost, /clear"
**L3**: "Start a Claude session (`claude`) and type `/` to see autocomplete options."

#### use_plan_mode
**L1**: "Press Shift+Tab before sending your message to enter plan mode."
**L2**: "Or explicitly say: 'Plan how to [task], but don't execute yet.'"
**L3**: "Pick a task from your backlog and ask Claude to plan the approach first."

#### create_cheat_sheet
**L1**: "Add a '## My Claude Code Cheat Sheet' section to your CLAUDE.md"
**L2**: "List 5 commands you found useful and 3 flags you'll use regularly."
**L3**: "Template: '### Commands I Use Daily\n- /clear — reset context\n- /cost — check usage'"

### Module 3: Skills

#### create_skills_directory
**L1**: "Run: `mkdir -p .claude/skills`"
**L2**: "This creates the directory where Claude looks for custom skills."

#### write_reference_skill
**L1**: "Think: What coding standards does your team follow?"
**L2**: "Create `.claude/skills/coding-standards.md` with your team's conventions."
**L3**: "I can give you a template for your role. What's your tech stack?"
**L4**: "Let me help you write it. Tell me about your naming conventions and I'll draft the skill."

#### write_action_skill
**L1**: "Think: What's a task you do repeatedly? Creating components? Endpoints? Tests?"
**L2**: "Create `.claude/skills/create-[thing].md` with step-by-step instructions."
**L3**: "Include: file locations, templates, verification commands."
**L4**: "Let's build it together. Walk me through how you normally create a new [X]."

### Module 4: Extensions

#### create_hook
**L1**: "Hooks go in `.claude/hooks/` as JSON files."
**L2**: "What would you like to happen automatically? Linting? Testing? Formatting?"
**L3**: "Template: `{\"event\": \"PostToolUse\", \"tool\": \"write_file\", \"command\": \"[your-command]\"}`"
**L4**: "Let's create one together. What command do you normally run after editing code?"

#### configure_mcp
**L1**: "Create `.claude/mcp.json` with at least one server."
**L2**: "Start simple with the filesystem server - it works for everyone."
**L3**: "Template: `{\"servers\": {\"filesystem\": {\"command\": \"npx\", \"args\": [\"-y\", \"@anthropic-ai/mcp-server-filesystem\", \".\"]}}}`"

#### create_custom_command
**L1**: "What workflow do you repeat weekly? Make it a command!"
**L2**: "Create `.claude/commands/[name].md` with clear instructions."
**L3**: "Include: name, description, step-by-step instructions for Claude to follow."

### Module 5: Agents

#### use_subagent
**L1**: "Ask Claude to delegate part of a task: 'Use a subagent to write tests while you implement the feature.'"
**L2**: "Subagents work best for independent subtasks that don't need to coordinate."
**L3**: "Example prompt: 'I need [feature]. Use a subagent for tests, you do the implementation, then integrate.'"

#### create_worktrees
**L1**: "Git worktrees let you work on multiple branches simultaneously."
**L2**: "Run: `git worktree add ../[project]-feature [branch-name]`"
**L3**: "First create branches, then: `git worktree add ../myproject-feature-a feature-a`"

#### run_parallel_agents
**L1**: "Open two terminals, cd to different worktrees, run `claude` in each."
**L2**: "Give each agent an independent task that won't conflict with the other."
**L3**: "Watch them work simultaneously! Check both terminals."

### Module 6: Workflows

#### install_github_app
**L1**: "In a Claude session, run `/install-github-app`"
**L2**: "Follow the OAuth flow to authorize and select repositories."
**L3**: "If it fails, check you have admin access to the repository."

#### create_github_action
**L1**: "Create `.github/workflows/claude-review.yml` with a workflow that uses Claude."
**L2**: "The workflow needs: checkout, install claude, run claude -p, post results."
**L3**: "I can give you a template for your role. What kind of review do you want?"
**L4**: "Let me generate the full workflow file for you. What should Claude check in PRs?"

#### create_automation_script
**L1**: "Create `scripts/claude-[task].sh` for a common batch operation."
**L2**: "Use `claude -p '[prompt]' --print --max-turns 10` for headless execution."
**L3**: "Don't forget `chmod +x scripts/[name].sh` to make it executable."

## Response Format

```
💡 HINT for: [Current Task]

[Hint text based on level]

---
Still stuck? Type /hint again for more detailed help.
Or describe specifically what's blocking you.
```

## Escalation

If this is their 3rd+ hint for the same task:

```
🤝 Let's work through this together.

I'll guide you step by step. First, [first concrete action].

What do you see when you try that?
```

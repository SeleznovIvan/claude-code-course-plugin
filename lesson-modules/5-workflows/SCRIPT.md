# Seminar 5: Workflows

**Duration**: 120 minutes (80 min guided + 40 min implementation)

**Seminar ID**: `5-workflows`

---

## Before You Begin

**Prerequisites**: You must have completed Modules 1-4 (Foundations & Commands, Skills, Extensions, Agents). Specifically:
- CLAUDE.md exists in your repository with project context, conventions, and agent patterns
- You've created custom commands in `.claude/commands/`
- You've created skills in `.claude/skills/`
- You've configured hooks in `.claude/settings.json`
- You've configured at least one MCP server in `.mcp.json`
- You understand subagent architecture, parallel execution patterns, and git worktrees
- You've documented multi-agent patterns in CLAUDE.md

If you haven't completed earlier modules, run `/cc-course:start 1`, `/cc-course:start 2`, `/cc-course:start 3`, or `/cc-course:start 4` first.

---

## How This Course Works

This is an interactive course — Claude guides you through each chapter step by step. Here are the commands you'll use:

| Command | When to Use |
|---------|-------------|
| `/cc-course:start N` | Begin a module (1-5) |
| `/cc-course:continue` | Signal you're done with the current step and ready to move on |
| `/cc-course:hint` | Get help when you're stuck on a task |
| `/cc-course:status` | Check your overall progress across all modules |
| `/cc-course:validate` | Verify your work at the end of a module |
| `/cc-course:submit` | Package your completed work for instructor review |

**The flow**: Claude presents a concept → checks your understanding → gives you a hands-on task → you do it → Claude verifies → repeat. Use `/cc-course:continue` to tell Claude you're ready for the next step.

---

## Learning Objectives

By the end of this seminar, participants will:
- Understand the three methods for integrating Claude Code with CI/CD: headless CLI, GitHub Actions, and GitHub MCP
- Use headless mode (`claude -p "prompt"`) for automated, non-interactive tasks
- Create GitHub Actions workflows that leverage Claude for PR review and code quality
- Build reusable automation scripts with proper error handling and bounded execution
- Test and productionize Claude-powered workflows with cost management and safety patterns
- Document all automated workflows in CLAUDE.md for team reuse

---

## Chapter Phase Map

Quick reference showing which interactive phases each chapter has:

| Chapter | PRESENT | CHECKPOINT | ACTION | VERIFY |
|---------|---------|------------|--------|--------|
| 1 — CI/CD Overview | yes | yes | — | — |
| 2 — GitHub Integration | yes | yes | yes | yes |
| 3 — Headless Mode | yes | yes | yes | yes |
| 4 — GitHub Actions | yes | yes | yes | yes |
| 5 — Automation Scripts | yes | yes | yes | yes |
| 6 — Testing & Production | yes | yes | yes | yes |
| 7 — Documenting Workflows | yes | yes | yes | yes |
| 8 — Final Commit & Graduation | yes | — | yes | yes |

---

## Chapter Progress Map

Data for the table of contents and progress bar (see teaching.md).

| Step | Chapter Label | Short Title |
|------|---------------|-------------|
| 1 | Chapter 1 | CI/CD Overview |
| 2 | Chapter 2 | GitHub Integration |
| 3 | Chapter 3 | Headless Mode |
| 4 | Chapter 4 | GitHub Actions |
| 5 | Chapter 5 | Automation Scripts |
| 6 | Chapter 6 | Testing & Production |
| 7 | Chapter 7 | Documenting Workflows |
| 8 | Chapter 8 | Final Commit & Graduation |

**Total steps**: 8 | **Module title**: Workflows | **Module number**: 5

---

## Chapter 1: CI/CD with Claude Overview

**Chapter ID**: `5.1-cicd-overview`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.1](./KNOWLEDGE.md#chapter-51-cicd-with-claude-overview) for a full comparison of integration methods, architecture diagrams, and real-world CI/CD pipeline examples.

### Content

#### What CI/CD with Claude Enables

Claude Code is not just an interactive tool — it can run **non-interactively** as part of your development pipeline. This unlocks:

| Capability | Description |
|------------|-------------|
| **Automated PR Reviews** | Claude reviews every pull request for quality, bugs, and security |
| **Issue Triage** | Auto-label, assign, and prioritize incoming issues |
| **Code Fixes** | Suggest or apply fixes automatically on push events |
| **Documentation** | Generate or update docs as code changes |
| **Test Generation** | Create missing tests when new code is added |
| **Release Notes** | Summarize changes for release PRs |

#### Three Integration Methods

There are three ways to integrate Claude Code into your workflows:

| Method | What It Is | Best For |
|--------|-----------|----------|
| **Headless CLI** (`claude -p`) | Run Claude from the command line, non-interactively | Local scripts, quick automation, testing |
| **GitHub Actions** | CI/CD workflows that invoke Claude on events (PR, push, issue) | Automated PR review, code quality gates, issue triage |
| **GitHub MCP** | Direct GitHub API access from within Claude sessions | Interactive issue/PR management, ad-hoc queries |

#### How They Work Together

```
Local Development          CI/CD Pipeline            Interactive Session
       │                        │                          │
  claude -p "..."         GitHub Actions              GitHub MCP
  (headless CLI)         (event-driven)            (API access)
       │                        │                          │
       ▼                        ▼                          ▼
  scripts/               .github/workflows/         Live PR/issue
  claude-*.sh            claude-*.yml               management
```

- **Headless CLI** is the foundation — both scripts and GitHub Actions use `claude -p` under the hood
- **GitHub Actions** trigger headless Claude on repository events
- **GitHub MCP** gives you interactive access to GitHub data within Claude sessions

#### What You'll Build in This Module

| Artifact | Description |
|----------|-------------|
| GitHub integration | Verify or set up GitHub MCP for PR/issue access |
| Headless mode experience | Run `claude -p` for non-interactive tasks |
| GitHub Action | `.github/workflows/claude-*.yml` for automated PR review |
| Automation scripts | `scripts/claude-*.sh` for reusable tasks |
| Workflow documentation | "Automated Workflows" section in CLAUDE.md |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the three integration methods? Key: headless CLI (`claude -p`) for local scripts, GitHub Actions for event-driven CI/CD, and GitHub MCP for interactive access. Headless CLI is the foundation — scripts and Actions both use it."
- **Options**: "Yes, I understand — let's continue" / "I have a question" / "I need more explanation"
- On questions: answer them, then re-ask
- On "need more explanation": elaborate on the relationship between the three methods — headless CLI is the building block, GitHub Actions orchestrate it in CI/CD, and GitHub MCP gives interactive access within sessions. Provide a concrete example: "A PR review GitHub Action runs `claude -p 'Review this PR...'` in a CI runner, while locally you might run the same command in a script." Then re-ask.

### Checklist

- [ ] Understand what CI/CD with Claude enables (automated reviews, triage, fixes, docs)
- [ ] Know the three integration methods (headless CLI, GitHub Actions, GitHub MCP)
- [ ] Understand how headless CLI is the foundation for both scripts and Actions
- [ ] Know what artifacts you'll build in this module

---

## Chapter 2: GitHub Integration Setup

**Chapter ID**: `5.2-github-integration`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.2](./KNOWLEDGE.md#chapter-52-github-integration-setup) for GitHub MCP configuration details, API authentication methods, and the `@anthropic-ai/claude-code-action` reference.

### Content

#### GitHub MCP from Module 3

In Module 3, you configured MCP servers in `.mcp.json`. If you set up the GitHub MCP server there, you already have GitHub integration. Let's verify it works.

#### Verifying Your GitHub Integration

Test your GitHub MCP by asking Claude to interact with your repository:

```
List the open issues in this repository
```

or:

```
Show me the most recent pull requests
```

If Claude can list issues or PRs, your GitHub integration is working.

#### Setting Up GitHub MCP (If Not Done)

If you didn't configure GitHub MCP in Module 3, you can set it up now by adding it to your `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

Generate a token at https://github.com/settings/tokens with `repo` scope.

#### The `@anthropic-ai/claude-code-action`

For CI/CD, there's an official GitHub Action you can use instead of manually installing Claude in your workflow:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

This action handles Claude Code setup and execution in GitHub Actions. You'll use this or the manual approach in Chapter 4.

#### What GitHub Integration Enables

With GitHub MCP or the official action, Claude can:
- Read issues and pull requests
- Post review comments
- Suggest code changes
- Create and label issues
- Query repository metadata

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you have GitHub integration working? You should be able to ask Claude to list issues or PRs in your repository. If you set up GitHub MCP in Module 3, it should already work."
- **Options**: "Yes, GitHub integration is working" / "I need to set it up" / "I have a question"
- On "need to set it up": walk them through adding the GitHub MCP to `.mcp.json` using the configuration above
- On questions: answer them, then re-ask

### Instructor: Action

#### Discover GitHub usage patterns from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for GitHub-related patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="github|pr|issue|review|merge")

# Get recent sessions
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)
```

**Analyze the results** for:
- Sessions involving PR creation or review
- Issue management tasks
- Merge-related workflows
- Any GitHub MCP tool usage

**Present findings** to the student via AskUserQuestion:

"Based on your session history, here's what I found about your GitHub usage:

1. **[Pattern]** — [Description]. [How this connects to CI/CD automation].
2. **[Pattern]** — [Description]. [What could be automated].

These patterns will inform what GitHub Actions and scripts you create later in this module."

- **Options**: "Makes sense — let's continue" / "I have questions about these patterns"

**Fallback** — if cclogviewer MCP is unavailable, no session history exists, or no GitHub patterns are found:

"Let's verify your GitHub integration works. Try asking Claude:

'List the open issues in this repository'

or:

'Show me the most recent pull requests'

If it works, great — we'll build on this. If not, we'll set up GitHub MCP now."

Tell the student:
"Verify your GitHub integration by asking Claude to list issues or PRs. If you need to set up GitHub MCP, follow the configuration above.

Use the {cc-course:continue} Skill tool when your GitHub integration is working."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Is your GitHub integration working? Can Claude list issues, PRs, or other repository data?"
- **Options**: "Yes, it's working" / "I couldn't get it working" / "I set it up but I'm not sure it's correct"

For issues:
1. If GitHub MCP isn't responding: check `.mcp.json` configuration, verify the token has correct scopes
2. If the student doesn't have a GitHub token: walk them through creating one at https://github.com/settings/tokens
3. If the repository isn't on GitHub: they can still proceed — the GitHub Action chapter will be informational for them

**On failure** (student cannot get it working and repo is on GitHub): Help debug the issue. Wait for {cc-course:continue}, then re-verify.

**On success** (student confirms GitHub integration works, or repo is not on GitHub and they understand the concepts): Update progress.json: set task `install_github_app` to `true`, set `current_task` to `"test_headless"`

### Verification

```yaml
chapter: 5.2-github-integration
type: manual
verification:
  questions:
    - "Verify GitHub MCP is configured (or set it up)"
    - "Test GitHub integration by listing issues or PRs"
    - "Understand the official claude-code-action for CI/CD"
  task_key: install_github_app
```

### Checklist

- [ ] GitHub MCP is configured in `.mcp.json` (or understood the setup)
- [ ] Claude can list issues or PRs from the repository
- [ ] Know about `@anthropic-ai/claude-code-action` for GitHub Actions
- [ ] Understand what GitHub integration enables for CI/CD

---

## Chapter 3: Headless Mode

**Chapter ID**: `5.3-headless-mode`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.3](./KNOWLEDGE.md#chapter-53-headless-mode) for the complete `-p` flag reference, output format options, allowed tools configuration, piping patterns, and advanced scripting techniques.

### Content

#### What Is Headless Mode?

Headless mode runs Claude **non-interactively** — it processes a prompt, does the work, outputs results, and exits. This is the foundation for all automation with Claude Code.

#### The `-p` Flag

The `-p` flag (short for "print") is how you invoke headless mode:

```bash
claude -p "Your prompt here"
```

This is equivalent to starting an interactive session, typing the prompt, and getting the response — but without any user interaction.

#### Key Flags for Headless Mode

| Flag | Purpose | Example |
|------|---------|---------|
| `-p "prompt"` | Run in headless mode | `claude -p "Summarize this project"` |
| `--output-format json` | Machine-parseable output | `claude -p "List files" --output-format json` |
| `--max-turns N` | Limit execution turns (cost control) | `claude -p "Fix bugs" --max-turns 10` |
| `--allowedTools` | Restrict available tools | `claude -p "Review code" --allowedTools Read,Glob,Grep` |
| `--model NAME` | Specify model to use | `claude -p "Analyze" --model claude-sonnet-4-20250514` |

#### Basic Headless Usage

```bash
# Simple query
claude -p "What files are in src/?"

# With turn limit for cost control
claude -p "Fix all lint errors" --max-turns 10

# JSON output for parsing in scripts
claude -p "List all TODO comments" --output-format json

# Read-only mode (restrict tools)
claude -p "Review this code for security issues" --allowedTools Read,Glob,Grep
```

#### Piping and Scripting Patterns

```bash
# Capture output in a variable
SUMMARY=$(claude -p "Summarize recent changes" --max-turns 3)
echo "Summary: $SUMMARY"

# Pipe input to Claude
git diff HEAD~1 | claude -p "Review this diff for potential issues"

# Chain with other tools
claude -p "List all API endpoints" --output-format json | jq '.result'

# Use in conditionals
if claude -p "Are there any lint errors?" --max-turns 3 | grep -q "no errors"; then
  echo "Clean!"
fi
```

#### When to Use Each Flag

| Scenario | Recommended Flags |
|----------|-------------------|
| Quick analysis | `-p "prompt" --max-turns 3` |
| Code modification | `-p "prompt" --max-turns 10` |
| Read-only review | `-p "prompt" --allowedTools Read,Glob,Grep` |
| Script integration | `-p "prompt" --output-format json --max-turns 5` |
| Cost-sensitive CI/CD | `-p "prompt" --max-turns 5 --model claude-sonnet-4-20250514` |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand headless mode? Key: `-p \"prompt\"` runs Claude non-interactively, `--max-turns` controls cost, `--allowedTools` restricts scope, `--output-format json` enables scripting. This is the foundation for all automation."
- **Options**: "Yes, I understand — let's try it" / "I have a question" / "Can you show more examples?"
- On questions: answer them, then re-ask
- On "more examples": provide 3-4 role-specific headless mode examples based on the student's role (e.g., Frontend: "Review component accessibility", Backend: "Check API endpoint security"), then re-ask

### Instructor: Action

Tell the student:
"Let's try headless mode. Run this command in your project directory:

```bash
claude -p \"Summarize the structure of this project\" --max-turns 3
```

This will run Claude in headless mode — it'll analyze your project and print the summary without any interactive prompts.

After running it, try one more command with output capture:

```bash
RESULT=$(claude -p \"What are the main technologies used in this project?\" --max-turns 3)
echo \"Claude said: $RESULT\"
```

Use the {cc-course:continue} Skill tool when you've run at least one headless command and seen the output."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Did you run a headless Claude command with `-p`? What was the output like? Did you notice it ran without any interactive prompts?"
- **Options**: "Yes, it worked — I saw the output" / "It ran but something was unexpected" / "I got an error" / "I have questions about the output"

For issues:
1. If the command didn't produce output: check that `claude` CLI is installed and in PATH, verify API key is set
2. If it ran too long: suggest adding `--max-turns 3` to limit execution
3. If output format was unexpected: explain that default output is plain text, use `--output-format json` for structured data

**On failure**: Help debug the issue. Wait for {cc-course:continue}, then re-verify.

**On success** (student confirms headless mode worked): Update progress.json: set task `test_headless` to `true`, set `current_task` to `"create_github_action"`

### Verification

```yaml
chapter: 5.3-headless-mode
type: manual
verification:
  questions:
    - "Run a headless Claude command with -p flag"
    - "Capture the output in a variable or observe it"
    - "Verify output was returned correctly"
  task_key: test_headless
```

### Checklist

- [ ] Understand what headless mode is (non-interactive Claude execution)
- [ ] Ran Claude with the `-p` flag
- [ ] Captured or observed the output
- [ ] Know when to use `--max-turns`, `--allowedTools`, and `--output-format`
- [ ] Understand how headless mode is the foundation for scripts and CI/CD

---

## Chapter 4: Creating GitHub Actions

**Chapter ID**: `5.4-github-actions`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.4](./KNOWLEDGE.md#chapter-54-creating-github-actions) for GitHub Actions YAML syntax, workflow triggers, the official claude-code-action reference, and advanced workflow patterns.

### Content

#### GitHub Actions Basics

GitHub Actions are event-driven workflows defined in `.github/workflows/`. They run on GitHub's infrastructure when specific events occur (PR opened, push to main, issue created, etc.).

#### Two Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Official Action** (`@anthropic-ai/claude-code-action`) | Simple setup, maintained by Anthropic | Less customization |
| **Custom workflow** (install CLI + `claude -p`) | Full control over prompts and flags | More setup, you maintain it |

#### Approach 1: Official Action

```yaml
name: Claude PR Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

#### Approach 2: Custom Workflow with `claude -p`

Create `.github/workflows/claude-review.yml`:

```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Claude Code
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "Review this PR. Focus on:
          - Code quality issues
          - Potential bugs
          - Missing tests
          - Security concerns

          Format your response as markdown." \
            --max-turns 5 \
            > review.md

      - name: Post Review Comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: `## Claude Code Review\n\n${review}`
            });
```

#### Adding API Key to Secrets

1. Go to Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Anthropic API key

> **Security note**: Never commit API keys to your repository. Always use GitHub Secrets.

#### Role-Specific Workflow Ideas

| Role | Workflow Idea | Trigger |
|------|--------------|---------|
| Frontend | Review component accessibility, check bundle size impact | PR on `src/components/` |
| Backend | Review API changes for breaking changes, security scan | PR on `src/api/` |
| QA | Generate missing test cases, check coverage gaps | PR with code changes |
| DevOps | Validate infrastructure changes, audit security config | PR on `infrastructure/` |
| Data | Validate schema changes, check data quality rules | PR on `schemas/` or `migrations/` |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand how to create GitHub Actions with Claude? Key: two approaches (official action vs custom `claude -p` workflow), API key goes in GitHub Secrets, and workflows trigger on events like PR open/push."
- **Options**: "Yes, I understand — let's create one" / "I have a question" / "Can you help me choose the right approach?"
- On questions: answer them, then re-ask
- On "help me choose": if they want simplicity, recommend the official action; if they want customization, recommend the custom `claude -p` approach. Ask about their specific use case to give targeted advice.

### Instructor: Action

Tell the student:
"Create a GitHub Actions workflow for your repository. Choose the approach that fits your needs:

1. **Create the workflow file**: `.github/workflows/claude-review.yml` (or another name that fits your use case)
2. **Use either**:
   - The official `anthropics/claude-code-action@v1` for simplicity
   - A custom workflow with `claude -p` for more control
3. **Customize the prompt** for your project and role
4. **Add your API key** to GitHub Secrets (Repository → Settings → Secrets → Actions → `ANTHROPIC_API_KEY`)

You can use the example YAML from the lesson as a starting point and modify it for your needs.

> **Tip**: If you're not ready to add your API key to GitHub Secrets yet, just create the workflow file — you can add the secret later.

Use the {cc-course:continue} Skill tool when you've created your workflow file."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_exists**: Use Glob to check for `.github/workflows/*.yml` files
2. **content_check**: Use Read to verify at least one workflow file contains `claude` (case-insensitive — could be `claude-code-action`, `claude -p`, `@anthropic-ai/claude-code`, etc.)

**On failure**: Tell the student what's missing. Common issues:
- Directory doesn't exist: create `.github/workflows/` first
- File doesn't contain Claude references: they may have created a generic workflow — remind them to include Claude
- YAML syntax errors: help fix indentation or syntax issues
Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `create_github_action` to `true`, set `current_task` to `"create_automation_script"`

### Verification

```yaml
chapter: 5.4-github-actions
type: automated
verification:
  checks:
    - file_exists: ".github/workflows/*.yml"
      contains: "claude"
      task_key: create_github_action
```

### Checklist

- [ ] Created `.github/workflows/` directory
- [ ] Created a Claude workflow file (`.yml`)
- [ ] Workflow references Claude (official action or `claude -p`)
- [ ] Understand how to add `ANTHROPIC_API_KEY` to GitHub Secrets
- [ ] Customized the workflow for your project and role

---

## Chapter 5: Creating Automation Scripts

**Chapter ID**: `5.5-automation-scripts`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.5](./KNOWLEDGE.md#chapter-55-creating-automation-scripts) for script design patterns, error handling best practices, and a library of role-specific automation script templates.

### Content

#### Script Location and Conventions

Store automation scripts in: `scripts/`

| Convention | Why |
|------------|-----|
| Prefix with `claude-` | Easy to identify Claude-powered scripts |
| Use `set -e` | Exit on first error (fail fast) |
| Set `--max-turns` | Prevent runaway costs |
| Add error handling | Graceful failure with useful messages |
| Make executable | `chmod +x scripts/claude-*.sh` |

#### Example: Lint Fix Script

Create `scripts/claude-lint-fix.sh`:

```bash
#!/bin/bash
# scripts/claude-lint-fix.sh
# Automatically fix linting errors using Claude

set -e

echo "Running Claude to fix lint errors..."

claude -p "Find and fix all linting errors in the codebase.
Apply our coding standards from CLAUDE.md.
Commit each fix separately with descriptive messages." \
  --max-turns 20 \
  > /tmp/claude-lint-output.txt

echo "Claude completed lint fixes"
echo "Output:"
cat /tmp/claude-lint-output.txt
```

#### Example: PR Prep Script

Create `scripts/claude-pr-prep.sh`:

```bash
#!/bin/bash
# scripts/claude-pr-prep.sh
# Prepare current branch for PR

set -e

BRANCH=$(git branch --show-current)

echo "Preparing branch '$BRANCH' for PR..."

# Generate PR description
PR_DESC=$(claude -p "Generate a PR description for this branch.
Include:
- Summary of changes
- List of files modified
- Testing notes
- Any breaking changes

Format as markdown." --max-turns 3)

echo "Branch ready for PR"
echo ""
echo "Suggested PR description:"
echo "========================="
echo "$PR_DESC"
```

#### Example: Code Review Script

Create `scripts/claude-review.sh`:

```bash
#!/bin/bash
# scripts/claude-review.sh
# Review specific files or directories

set -e

TARGET=${1:-.}

echo "Reviewing: $TARGET"

claude -p "Review the code in '$TARGET' for:
- Code quality issues
- Potential bugs
- Performance concerns
- Security vulnerabilities

Provide specific file:line references for each issue." \
  --max-turns 10 \
  --allowedTools Read,Glob,Grep
```

#### Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Fail fast** | `set -e` at the top of every script |
| **Bounded execution** | Always use `--max-turns` to limit cost |
| **Error handling** | Check exit codes, provide useful error messages |
| **Read-only when possible** | Use `--allowedTools Read,Glob,Grep` for review scripts |
| **Idempotent** | Scripts should be safe to re-run |

#### Making Scripts Executable

```bash
chmod +x scripts/claude-*.sh
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand automation script design? Key: scripts go in `scripts/`, use `set -e` for fail-fast, always set `--max-turns` for cost control, use `--allowedTools` to restrict scope, and `chmod +x` to make executable."
- **Options**: "Yes, I understand — let's create one" / "I have a question" / "Can you suggest a script for my role?"
- On questions: answer them, then re-ask
- On "suggest a script": provide 2-3 role-specific script ideas based on the student's role and project, then re-ask

### Instructor: Action

#### Discover automation opportunities from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for repetitive tasks that could be automated
mcp__cclogviewer__search_logs(project=<project_name>, query="lint|test|deploy|review|build|release|check|fix|format")

# Get tool usage to identify repetitive patterns
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)

# Get recent sessions
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)
```

**Analyze the results** for:
- Tasks the student performs repeatedly (lint fixes, test runs, code reviews)
- Patterns that involve the same sequence of tool calls
- Long-running analysis sessions that could be scripted
- Workflows that always start with the same prompt

**Present 2-3 discovered patterns** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are tasks I found that could be turned into automation scripts:

1. **[Pattern Name]** — [Description]. Found in [N] sessions. Would make a great `scripts/claude-[name].sh`.
2. **[Pattern Name]** — [Description]. Found in [N] sessions. Could be automated with [flags].
3. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why scripting helps].

Which one would you like to create? Or use one of the example scripts from the lesson."

- **Options**: The discovered patterns + "I'll use one of the example scripts" + "I have my own idea"

**Fallback** — if cclogviewer MCP is unavailable, the project has no session history, or no meaningful patterns are found:

"Let's create a useful automation script. Choose one that fits your workflow:

1. **Lint fix script** — `scripts/claude-lint-fix.sh` — automatically fix linting errors
2. **PR prep script** — `scripts/claude-pr-prep.sh` — generate PR descriptions
3. **Code review script** — `scripts/claude-review.sh` — review specific files or directories
4. **Your own idea** — a script that automates a task you do regularly

Which would you like to create?"

#### Create the script

Tell the student:
"Create your automation script now:

1. **Create** `scripts/` directory if it doesn't exist
2. **Write** your script using the examples from the lesson as templates
3. **Make it executable**: `chmod +x scripts/claude-*.sh`

Key requirements:
- Use `set -e` for fail-fast behavior
- Include `--max-turns` in every `claude -p` call
- Add comments explaining what the script does

Use the {cc-course:continue} Skill tool when you've created at least one script and made it executable."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **script_exists**: Use Glob to check for `scripts/*.sh` — must find at least 1 file
2. **content_check**: Use Read to verify the script contains `claude -p` (headless mode usage)

**On failure**: Tell the student what's missing. Common issues:
- No scripts directory: `mkdir -p scripts`
- Script doesn't use headless mode: remind them to include `claude -p` in the script
- Script not executable: `chmod +x scripts/claude-*.sh`
Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `create_automation_script` to `true`, set `current_task` to `"test_workflow"`

### Verification

```yaml
chapter: 5.5-automation-scripts
type: automated
verification:
  checks:
    - file_pattern: "scripts/*.sh"
      min_count: 1
      task_key: create_automation_script
```

### Checklist

- [ ] Created `scripts/` directory
- [ ] Created at least one automation script
- [ ] Script uses headless mode (`claude -p`) correctly
- [ ] Script includes `set -e` and `--max-turns`
- [ ] Script is executable (`chmod +x`)

---

## Chapter 6: Testing & Production Patterns

**Chapter ID**: `5.6-testing-production`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.6](./KNOWLEDGE.md#chapter-56-testing-and-production-patterns) for local testing strategies with `act`, production safety patterns, cost management formulas, and human-in-the-loop workflow designs.

### Content

#### Testing Scripts Locally

Before deploying to CI/CD, test your scripts locally:

```bash
# Test your automation scripts
./scripts/claude-lint-fix.sh
./scripts/claude-pr-prep.sh
./scripts/claude-review.sh src/
```

Check for:
- Does the script exit cleanly?
- Is the output useful and well-formatted?
- Does `--max-turns` prevent runaway execution?
- Do error cases produce helpful messages?

#### Testing GitHub Actions

**Option 1: Push to a test branch**
```bash
git checkout -b test-claude-workflow
echo "// test change" >> src/index.ts
git add .
git commit -m "Test Claude workflow"
git push -u origin test-claude-workflow
```
Then create a PR on GitHub and watch the Actions tab.

**Option 2: Use `act` for local testing**
```bash
# Install act
brew install act  # macOS

# Run workflow locally
act pull_request -s ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
```

#### Production Best Practices

| Practice | Why | Implementation |
|----------|-----|----------------|
| **Set `--max-turns`** | Prevent runaway costs | Always include in every `claude -p` call |
| **Use `--allowedTools`** | Limit blast radius | Restrict to `Read,Glob,Grep` for review-only tasks |
| **Error handling** | Graceful failure recovery | `set -e`, trap errors, log failures |
| **Human-in-the-loop** | Final approval before action | Post suggestions as PR comments, don't auto-merge |
| **Cost management** | Control API spend | Use `--max-turns`, choose appropriate models |
| **Rate limiting** | Prevent burst costs | Add delays between multiple Claude calls |
| **Logging** | Audit trail for debugging | Capture output to files, log timestamps |

#### Production Pattern: Continuous Review Agent

```
PR Opened
    |
    v
+------------------+
|  Review Agent    |---> Posts review comments
+------------------+
    |
    v (if issues found)
+------------------+
|  Human Reviews   |---> Approves, requests changes, or merges
+------------------+
```

Key: the agent reviews, but a human makes the final decision.

#### Production Pattern: Issue Triage

```
Issue Created
    |
    v
+------------------+
|  Triage Agent    |---> Labels, assigns, estimates complexity
+------------------+
    |
    v
+------------------+
| Suggestion Agent |---> Posts a comment with suggested approach
+------------------+
    |
    v
+------------------+
|  Human Decides   |---> Assigns to developer or creates draft PR
+------------------+
```

#### Cost Management Tips

| Strategy | Savings |
|----------|---------|
| Use `--max-turns 5` for reviews (read-only analysis) | Limits per-invocation cost |
| Use `--model claude-sonnet-4-20250514` for simpler tasks | Lower per-token cost |
| Run only on specific file paths (workflow `paths` filter) | Fewer workflow runs |
| Cache results where possible | Avoid duplicate analysis |
| Set up spending alerts in your Anthropic dashboard | Catch cost spikes early |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know how to test and productionize workflows? Key: test scripts locally first, use `act` or test branches for GitHub Actions, always use `--max-turns` and `--allowedTools` in production, and keep human-in-the-loop for final decisions."
- **Options**: "Yes, I understand the patterns" / "I have a question" / "Can you help me plan my production setup?"
- On questions: answer them, then re-ask
- On "help me plan": discuss their specific workflows, recommend appropriate `--max-turns` values, suggest which tasks should be read-only vs write-enabled, and which need human approval

### Instructor: Action

Tell the student:
"Let's test at least one of your workflows. Choose what to test:

1. **Test an automation script**: Run one of your `scripts/claude-*.sh` scripts locally
2. **Test a GitHub Action**: Push to a test branch and create a PR to trigger it
3. **Dry run**: Run a headless Claude command that simulates what your workflow would do

```bash
# Option 1: Test a script
./scripts/claude-lint-fix.sh

# Option 2: Create a test branch
git checkout -b test-claude-workflow
# make a small change, commit, push, create PR

# Option 3: Dry run a review
claude -p \"Review the most recent changes for code quality\" --max-turns 3 --allowedTools Read,Glob,Grep
```

Use the {cc-course:continue} Skill tool when you've tested at least one workflow."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Did you test your workflows? What did you test and what was the result? Did you observe the output and verify it was useful?"
- **Options**: "Yes, I tested and it worked" / "I tested but the output wasn't what I expected" / "I had errors during testing" / "I couldn't test (no API key / offline)"

For issues:
1. If output wasn't useful: discuss prompt engineering — more specific prompts get better results
2. If there were errors: help debug (API key issues, script syntax, permissions)
3. If they couldn't test: accept their understanding of the concepts and move on

**On failure** (fixable issues): Help debug. Wait for {cc-course:continue}, then re-verify.

**On success** (student confirms testing worked, or couldn't test but understands concepts): Update progress.json: set task `test_workflow` to `true`, set `current_task` to `"document_workflows"`

### Verification

```yaml
chapter: 5.6-testing-production
type: manual
verification:
  questions:
    - "Test at least one automation script or GitHub Action"
    - "Verify the output is useful"
    - "Understand production best practices"
  task_key: test_workflow
```

### Checklist

- [ ] Tested at least one automation script or workflow
- [ ] Verified the output was useful
- [ ] Understand production best practices (`--max-turns`, `--allowedTools`, human-in-the-loop)
- [ ] Know how to manage costs (turn limits, model selection, path filters)
- [ ] Understand the Continuous Review Agent and Issue Triage patterns

---

## Chapter 7: Documenting Workflows

**Chapter ID**: `5.7-documenting-workflows`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.7](./KNOWLEDGE.md#chapter-57-documenting-workflows) for workflow documentation templates, team onboarding guides, and documentation maintenance strategies.

### Content

#### Why Document Workflows?

Your CLAUDE.md is the central source of truth for how Claude works in your project. Without workflow documentation:
- Team members won't know what automation exists
- Claude won't know about your workflows when asked
- Scripts and Actions become "hidden" knowledge

#### What to Add to CLAUDE.md

| Section | What to Write |
|---------|--------------|
| **Overview** | What CI/CD integrations exist and what they do |
| **Script inventory** | Each script, its purpose, and how to run it |
| **GitHub Actions** | Each workflow, its trigger, and what it does |
| **Production rules** | Cost limits, safety guardrails, human-in-the-loop requirements |

#### Template for CLAUDE.md

```markdown
## Automated Workflows

### CI/CD Integration

**PR Review** (`.github/workflows/claude-review.yml`)
- Triggered: On PR open/sync
- Actions: Reviews code, posts comment
- Checks: Quality, bugs, tests, security

### Utility Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `scripts/claude-lint-fix.sh` | Fix lint errors | `./scripts/claude-lint-fix.sh` |
| `scripts/claude-pr-prep.sh` | Prepare branch for PR | `./scripts/claude-pr-prep.sh` |
| `scripts/claude-review.sh` | Review code | `./scripts/claude-review.sh [path]` |

### Production Rules

- All automation uses `--max-turns` to limit cost
- Review scripts use `--allowedTools Read,Glob,Grep` (read-only)
- Human approval required before merging automated changes
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know what to document? Key: add an 'Automated Workflows' section to CLAUDE.md covering your GitHub Actions, automation scripts, and production rules. This ensures Claude and your team know what automation exists."
- **Options**: "Yes, I know what to document" / "I have a question" / "Can you show the template again?"
- On questions: answer them, then re-ask
- On "show template": re-present the CLAUDE.md template from the Content section, then re-ask

### Instructor: Action

#### Discover patterns worth documenting from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for workflow and automation patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="workflow|script|action|automate|cicd|pipeline")

# Get recent sessions to see what they've built
mcp__cclogviewer__list_sessions(project=<project_name>, days=7, limit=5)
```

**Analyze the results** for:
- The workflows the student created in this module
- Any earlier automation patterns from previous modules
- Patterns that should be documented for team use

**Fallback** — if cclogviewer is unavailable or no additional patterns are found, the student should document the workflows they created in Chapters 4 and 5 (GitHub Action + automation scripts).

#### Create the documentation

Tell the student:
"Add an 'Automated Workflows' section to your CLAUDE.md. Include:

1. **CI/CD Integration** — describe your GitHub Action workflow (trigger, what it does, what it checks)
2. **Utility Scripts** — list each script in `scripts/` with its purpose and usage
3. **Production Rules** — document cost limits, safety guardrails, and approval requirements

Use the template from the lesson, but customize it with your actual workflows and scripts.

Use the {cc-course:continue} Skill tool when you've added the Automated Workflows section to your CLAUDE.md."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_exists**: Use Glob to check `CLAUDE.md` exists
2. **content_check**: Use Read to verify CLAUDE.md contains workflow documentation. Check for keywords matching the regex: `Automated Workflows|CI/CD|Workflow|workflow|automation`

**On failure**: Tell the student what's missing — they need an "Automated Workflows" section documenting their GitHub Action(s) and scripts. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `document_workflows` to `true`, set `current_task` to `"final_commit"`

### Verification

```yaml
chapter: 5.7-documenting-workflows
type: automated
verification:
  checks:
    - file_contains: "CLAUDE.md"
      pattern: "Automated Workflows|CI/CD|Workflow"
      task_key: document_workflows
```

### Checklist

- [ ] Added "Automated Workflows" section to CLAUDE.md
- [ ] Documented GitHub Action(s) with triggers and purpose
- [ ] Listed all utility scripts with usage instructions
- [ ] Included production rules (cost limits, safety, approvals)
- [ ] Documentation is clear enough for a teammate to understand

---

## Chapter 8: Final Commit & Course Graduation

**Chapter ID**: `5.8-commit-graduation`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 5.8](./KNOWLEDGE.md#chapter-58-final-commit-and-course-graduation) for commit conventions, what to include in workflow commits, and course completion overview.

### Content

#### What to Commit

```
your-repo/
├── CLAUDE.md                           # Updated with Automated Workflows section
├── .github/
│   └── workflows/
│       └── claude-review.yml           # GitHub Action (or your custom workflow)
└── scripts/
    └── claude-*.sh                     # Automation script(s)
```

#### What NOT to Commit

- API keys or secrets (use GitHub Secrets, `.env`, or environment variables)
- Temporary output files (`/tmp/claude-*.txt`)
- Test branches (clean up with `git branch -d test-claude-workflow`)

#### Commit Message Template

```bash
git add CLAUDE.md .github/workflows/ scripts/
git commit -m "Add Claude Code CI/CD integration and automation

- Add PR review GitHub Action workflow
- Add automation scripts for [your scripts]
- Document all workflows in CLAUDE.md"
```

### Instructor: Action

Tell the student:
"Let's commit your Module 5 work.

1. **Check what needs committing**:
   ```bash
   git status
   ```

2. **Stage and commit**:
   ```bash
   git add CLAUDE.md .github/workflows/ scripts/
   git commit -m \"Add Claude Code CI/CD integration and automation

   - Add PR review GitHub Action workflow
   - Add automation scripts
   - Document all workflows in CLAUDE.md\"
   ```

3. **Validate your work**: Run the {cc-course:validate} Skill tool to verify all Module 5 tasks are complete.

4. **Submit your work**: Run the {cc-course:submit} Skill tool to package your completed work.

Use the {cc-course:continue} Skill tool after committing and validating."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. Use Bash (read-only) to run `git log --oneline -5` in the student's repository
2. Check that a recent commit includes the workflow files (CLAUDE.md, .github/workflows/, scripts/)
3. Alternatively, run `git show --name-only HEAD` to verify committed files

**On failure**: Tell the student what's not committed yet. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `final_commit` to `true`, set `current_task` to `null`

### Verification

```yaml
chapter: 5.8-commit-graduation
type: automated
verification:
  checks:
    - git_committed: "CLAUDE.md"
      task_key: final_commit
```

### Checklist

- [ ] All workflow files staged and committed
- [ ] All scripts staged and committed
- [ ] Updated CLAUDE.md committed
- [ ] Commit message describes the CI/CD additions
- [ ] Ran {cc-course:validate} — all checks passed
- [ ] Ran {cc-course:submit} — work packaged for review

---

## Module Completion

### Instructor: Final Validation

After Chapter 8 is complete, tell the student:

"You've finished all the chapters! Let's validate your work and package it for submission.

**Step 1 — Validate**: Run the {cc-course:validate} Skill tool now. This checks that you've set up GitHub integration, tested headless mode, created a GitHub Action, built automation scripts, tested your workflows, documented everything, and committed your work."

**Wait for the student to run validate.** If validation fails, help them fix issues and re-run.

**After validation passes**, tell the student:

"All checks passed!

**Step 2 — Submit**: Run the {cc-course:submit} Skill tool to package your work into a submission archive. This bundles your CLAUDE.md updates, progress data, and session logs for instructor review."

**Wait for the student to run submit.**

After submission completes or if the student declines, proceed to the Course Graduation below.

---

## Course Graduation

Congratulations — you've completed all 5 modules of the Claude Code Developer Course!

### What You've Built

Throughout this entire course, you've created a complete Claude Code configuration for your repository:

```
your-repo/
├── CLAUDE.md                     # Project context, conventions, agent patterns, workflows
├── .claude/
│   ├── settings.json             # Hook configurations (Module 3)
│   ├── commands/                 # Custom slash commands (Modules 1, 3)
│   └── skills/                   # Team skills and standards (Module 2)
├── .mcp.json                     # MCP server configurations (Module 3)
├── .github/
│   └── workflows/
│       └── claude-*.yml          # CI/CD workflows (Module 5)
└── scripts/
    └── claude-*.sh               # Automation scripts (Module 5)
```

### Skills Demonstrated

**Module 1 — Foundations & Commands**:
- [ ] Installed and configured Claude Code
- [ ] Created and maintained CLAUDE.md as project memory
- [ ] Used slash commands and CLI flags effectively
- [ ] Created custom slash commands in `.claude/commands/`

**Module 2 — Skills**:
- [ ] Created reusable skills in `.claude/skills/`
- [ ] Understood skill frontmatter and team skill sharing

**Module 3 — Extensions**:
- [ ] Configured hooks for event-driven automation
- [ ] Set up MCP servers for external tool integration
- [ ] Created advanced slash commands

**Module 4 — Agents**:
- [ ] Used subagents for focused, isolated tasks
- [ ] Set up git worktrees for parallel agent work
- [ ] Ran multiple Claude instances simultaneously
- [ ] Documented multi-agent patterns in CLAUDE.md

**Module 5 — Workflows**:
- [ ] Set up GitHub integration (GitHub MCP)
- [ ] Used headless mode (`claude -p`) for automation
- [ ] Created GitHub Actions for CI/CD
- [ ] Built reusable automation scripts
- [ ] Documented all workflows for team reuse

### Next Steps

1. **Iterate**: Refine your CLAUDE.md, skills, and workflows based on daily use. The best configurations evolve over time.
2. **Share**: Help teammates adopt Claude Code by sharing your configuration as a template. Your documented patterns make onboarding easy.
3. **Extend**: Add more skills, automation scripts, and GitHub Actions as new needs arise. Each addition compounds your productivity.
4. **Contribute**: Share improvements with the community. Your role-specific patterns could help developers worldwide.

---

## Seminar Summary

### What You Learned

1. **CI/CD Integration Methods**: Headless CLI (`claude -p`), GitHub Actions, and GitHub MCP — three ways to integrate Claude into your development pipeline
2. **Headless Mode**: Non-interactive execution with `-p "prompt"`, `--max-turns` for cost control, `--allowedTools` for scope control, and `--output-format json` for scripting
3. **GitHub Actions**: Event-driven workflows using the official `claude-code-action` or custom `claude -p` workflows
4. **Automation Scripts**: Reusable scripts in `scripts/` with `set -e`, `--max-turns`, error handling, and `chmod +x`
5. **Production Patterns**: Continuous Review Agent, Issue Triage, human-in-the-loop, cost management, rate limiting
6. **Testing Workflows**: Local script testing, test branches for Actions, `act` for local CI testing
7. **Documentation**: "Automated Workflows" section in CLAUDE.md covering Actions, scripts, and production rules

### Key Commands

| Command | Purpose |
|---------|---------|
| `claude -p "prompt"` | Run Claude in headless mode |
| `claude -p "prompt" --max-turns 5` | Limit execution turns for cost control |
| `claude -p "prompt" --allowedTools Read,Glob,Grep` | Read-only headless execution |
| `claude -p "prompt" --output-format json` | Machine-parseable output |
| `chmod +x scripts/claude-*.sh` | Make scripts executable |

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar5-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar5-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar5-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar5-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar5-report.html",
  open_browser=true
)
```

### What's Captured

| Data | Description |
|------|-------------|
| Session ID | Unique identifier for your learning session |
| Duration | Time spent on the module |
| Tool usage | Read, Write, Bash, Glob, Grep calls |
| Tasks completed | Which verification steps passed |
| Errors | Any issues encountered |

---

## Validation Summary

```yaml
seminar: 5-workflows
tasks:
  install_github_app:
    chapter: 5.2
    type: manual
    check: "student_confirms"

  test_headless:
    chapter: 5.3
    type: manual
    check: "student_confirms"

  create_github_action:
    chapter: 5.4
    type: automated
    check: "file_exists:.github/workflows/claude-*.yml"

  create_automation_script:
    chapter: 5.5
    type: automated
    check: "glob:scripts/*.sh"

  test_workflow:
    chapter: 5.6
    type: manual
    check: "student_confirms"

  document_workflows:
    chapter: 5.7
    type: automated
    check: "file_contains:CLAUDE.md:Automated Workflows|CI/CD|Workflow"

  final_commit:
    chapter: 5.8
    type: automated
    check: "git_log:CLAUDE.md"
```

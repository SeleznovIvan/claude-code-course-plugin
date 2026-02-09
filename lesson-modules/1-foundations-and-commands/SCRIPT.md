# Seminar 1: Foundations & Commands

**Duration**: 120 minutes (90 min guided + 30 min hands-on)

**Seminar ID**: `1-foundations-and-commands`

---

## Learning Objectives

By the end of this seminar, participants will:
- Install and authenticate Claude Code in their development environment
- Navigate basic CLI interactions confidently
- Create a CLAUDE.md file that captures their project's context
- Use slash commands fluently for common operations
- Create a custom slash command for their workflow

---

## Chapter 1: What is Claude Code?

**Chapter ID**: `1.1-what-is-claude-code`

### Content

Claude Code is an agentic coding assistant that runs in your terminal. Unlike chat-based AI tools:

- **Terminal-native**: Works where you already work
- **Full codebase awareness**: Reads and understands your entire project
- **Agentic execution**: Can read files, write code, run commands
- **Memory persistence**: Remembers context across sessions via CLAUDE.md

**Mental model**: Think of Claude Code as a pair programmer who lives in your terminal and never forgets what you told them about your project.

### Key Differences from Other Tools

| Feature | Claude Code | Copilot/Cursor |
|---------|-------------|----------------|
| Interface | Terminal | IDE plugin |
| Scope | Full codebase | Current file/context |
| Execution | Can run commands | Suggestions only |
| Memory | CLAUDE.md persistence | Session only |

### Verification

```yaml
chapter: 1.1-what-is-claude-code
type: conceptual
verification: manual
question: "Can you explain the difference between Claude Code and IDE-based AI tools?"
```

### Checklist

- [ ] Understand what "agentic" means in the context of coding assistants
- [ ] Know the key differences between Claude Code and Copilot/Cursor
- [ ] Understand the "pair programmer in terminal" mental model

---

## Chapter 2: Installation & Authentication

**Chapter ID**: `1.2-installation`

### Content

#### Step 1: Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

#### Step 2: Verify Installation

```bash
claude --version
```

Expected output: Version number (e.g., `1.x.x`)

#### Step 3: First Launch

```bash
claude
```

On first launch, Claude Code will:
1. Open browser for authentication
2. Request API key or OAuth connection
3. Complete initial setup wizard

#### Step 4: Verify Authentication

```bash
claude "Hello, can you hear me?"
```

If Claude responds, authentication is complete.

### Verification

```yaml
chapter: 1.2-installation
type: automated
verification:
  command: "which claude && claude --version"
  success_pattern: "claude-code"
  task_key: install_claude_code
```

### Checklist

- [ ] Claude Code installed globally via npm
- [ ] `claude --version` returns a version number
- [ ] Successfully authenticated (first session works)
- [ ] Can run `claude` and get a response

---

## Chapter 3: Basic CLI Interactions

**Chapter ID**: `1.3-cli-basics`

### Content

#### Starting a Session

| Command | Description |
|---------|-------------|
| `claude` | Interactive mode (recommended for learning) |
| `claude "prompt"` | One-shot mode (run and exit) |
| `claude -p "prompt"` | Print mode (output only, no interactive) |
| `claude -c` | Continue last conversation |

#### Inside a Session

- Type naturally - Claude understands context
- Use `/` to access slash commands
- Press `Ctrl+C` to cancel current operation
- Type `exit` or press `Ctrl+D` to end session

#### Reading Claude's Output

Claude shows what tools it's using:
- `Reading file...` - Examining your code
- `Writing file...` - Making changes (asks permission)
- `Running command...` - Executing shell commands (asks permission)

### Practice Exercise

1. Start interactive mode: `claude`
2. Ask: "What files are in the current directory?"
3. Ask: "What is the main purpose of this project?"
4. Exit the session

### Verification

```yaml
chapter: 1.3-cli-basics
type: manual
verification:
  questions:
    - "Start an interactive Claude session"
    - "Ask Claude to list files in your project"
    - "Exit the session gracefully"
  task_key: basic_cli_usage
```

### Checklist

- [ ] Can start an interactive Claude session
- [ ] Understand difference between `claude`, `claude "prompt"`, and `claude -p`
- [ ] Know how to exit a session (`exit` or Ctrl+D)
- [ ] Understand what Claude shows when using tools

---

## Chapter 4: CLAUDE.md - Your Project's Memory

**Chapter ID**: `1.4-claude-md`

### Content

#### Why CLAUDE.md Matters

Without CLAUDE.md:
```
You: "Where should I add a new component?"
Claude: "I don't have context about your project structure..."
```

With CLAUDE.md:
```
You: "Where should I add a new component?"
Claude: "Based on your project structure, new components go in src/components/..."
```

#### The `/init` Command

Run inside your project:
```bash
claude
/init
```

This auto-generates a CLAUDE.md based on your codebase.

#### CLAUDE.md Structure

```markdown
# Project: [Name]

## Overview
[2-3 sentences about what this project does]

## Tech Stack
- Language: [e.g., TypeScript, Python]
- Framework: [e.g., React, FastAPI]
- Testing: [e.g., Jest, pytest]
- Build: [e.g., Vite, Poetry]

## Architecture
[Brief description of codebase organization]

## Conventions
- [Naming conventions]
- [File organization rules]
- [Code style preferences]

## Common Commands
- Run tests: `[command]`
- Start dev: `[command]`
- Build: `[command]`

## Important Context
- [Domain-specific knowledge]
- [Key business logic locations]
- [Sensitive areas]
```

#### Role-Specific Additions

| Role | Add to CLAUDE.md |
|------|------------------|
| Frontend | Component patterns, styling approach, browser support |
| Backend | API patterns, database schemas, auth flow |
| QA | Test organization, fixtures, coverage requirements |
| DevOps | Infrastructure layout, environments, deployment |
| Data | Pipeline architecture, data models, sources |

### Verification

```yaml
chapter: 1.4-claude-md
type: automated
verification:
  checks:
    - file_exists: "CLAUDE.md"
      task_key: create_claude_md
    - file_contains: ["## Overview", "# Project"]
      task_key: add_project_overview
    - file_contains: ["Tech Stack", "Stack", "Technologies"]
      task_key: add_tech_stack
    - file_contains: ["Convention", "Standards", "Style"]
      task_key: add_conventions
    - file_quality:
        path: "CLAUDE.md"
        max_lines: 500
        warn_lines: 300
        max_chars: 40000
        required_sections:
          - "^#+ .*Overview|^# Project"
          - "^#+ .*(Tech Stack|Stack|Technologies)"
          - "^#+ .*(Convention|Standards|Code Style)"
          - "^#+ .*(Commands?)"
        suggest_references_if_lines: 200
        warn_patterns:
          - pattern: "TODO|FIXME"
            message: "Contains placeholder text - consider completing or removing"
          - pattern: "\\[.*\\]"
            message: "Contains placeholder brackets - fill in actual values"
      task_key: claude_md_quality
```

### CLAUDE.md Best Practices

Based on official Anthropic documentation:

| Guideline | Recommendation |
|-----------|----------------|
| **Length** | Keep under 500 lines (warn at 300) |
| **Size** | Max 40,000 characters |
| **Sections** | Overview, Tech Stack, Conventions, Commands |
| **References** | Use `@path/to/file` for long files to avoid bloat |
| **Placeholders** | Remove TODO/FIXME before committing |

If your CLAUDE.md exceeds 200 lines, consider:
- Moving detailed specs to separate files (reference with `@docs/api-spec.md`)
- Using `.claude/settings.json` for project-specific settings
- Creating skills in `.claude/skills/` for reusable instructions

### Checklist

- [ ] Run `/init` in your repository
- [ ] Review and enhance the auto-generated CLAUDE.md
- [ ] Add project overview section
- [ ] Add tech stack section
- [ ] Add conventions section
- [ ] Add common commands section
- [ ] Check CLAUDE.md quality (line count, no placeholders)

---

## Chapter 5: Testing Your Setup

**Chapter ID**: `1.5-testing-setup`

### Content

#### Verification Questions

Ask Claude these questions to verify CLAUDE.md is working:

1. **"What is this project about?"**
   - Claude should describe your project accurately

2. **"What testing framework do we use?"**
   - Claude should reference your tech stack

3. **"Where would I add a new [component/endpoint/test]?"**
   - Claude should know your file structure

4. **"What are the naming conventions in this project?"**
   - Claude should reference your conventions

#### If Claude Doesn't Understand

Common fixes:
- Add more specific examples to CLAUDE.md
- Remove jargon and use concrete terms
- Include actual file paths, not just descriptions
- Add a "Key Files" section pointing to important code

### Verification

```yaml
chapter: 1.5-testing-setup
type: manual
verification:
  questions:
    - "Ask Claude about your project and verify accurate response"
    - "Confirm Claude knows your tech stack"
    - "Confirm Claude understands your file structure"
  task_key: test_claude_understanding
```

### Checklist

- [ ] Asked Claude "What is this project about?" - got accurate answer
- [ ] Asked about testing framework - Claude knew it
- [ ] Asked where to add new code - Claude gave correct location
- [ ] Claude references information from CLAUDE.md

---

## Chapter 6: Essential Slash Commands

**Chapter ID**: `1.6-slash-commands`

### Content

#### Navigation & Help

| Command | Purpose |
|---------|---------|
| `/help` | Show all available commands |
| `/clear` | Reset conversation context |
| `/compact` | Compress context (when running low) |

#### Session Management

| Command | Purpose |
|---------|---------|
| `/cost` | Show token usage and spending |
| `/model` | Switch models mid-session |
| `/config` | View/modify settings |

#### Development Commands

| Command | Purpose |
|---------|---------|
| `/init` | Initialize project (create CLAUDE.md) |
| `/doctor` | Diagnose installation issues |
| `/review` | Code review mode |

#### CLI Flags (Outside Session)

| Flag | Purpose |
|------|---------|
| `--print` / `-p` | Output and exit (for scripts) |
| `--continue` / `-c` | Resume last conversation |
| `--resume` / `-r` | Resume specific session |
| `--max-turns` | Limit agentic loops |
| `--model` | Specify model |

### Practice Exercise

Run these commands and observe the output:
1. `/help` - See all commands
2. `/doctor` - Check installation health
3. `/config` - View your settings
4. `/cost` - Check token usage

### Verification

```yaml
chapter: 1.6-slash-commands
type: manual
verification:
  questions:
    - "Run /help and identify 5 useful commands"
    - "Run /doctor and confirm no issues"
    - "Run /cost to see token usage"
  task_key: explore_slash_commands
```

### Checklist

- [ ] Used `/help` to see available commands
- [ ] Used `/doctor` to verify installation
- [ ] Used `/config` to see current settings
- [ ] Used `/cost` to see token usage
- [ ] Know the difference between `/clear` and `/compact`

---

### Session Management Commands

These commands help you manage your Claude Code sessions and context.

#### Session Information

| Command | Purpose |
|---------|---------|
| `/context` | Show files and context currently loaded |
| `/statusline` | Configure the status bar display |
| `/config` | View and modify Claude Code settings |

#### Session Continuation

| Command / Flag | Purpose |
|----------------|---------|
| `/export` | Export current conversation |
| `claude -c` | Resume last conversation (CLI flag) |
| `claude -r <id>` | Resume specific session by ID (CLI flag) |

#### Understanding Session IDs

Every Claude Code session has a unique ID. You can find it by:
- Looking at the output when starting a session
- Using `/config` to see session info
- Checking `~/.claude/projects/` directory

Session IDs allow you to:
- Resume a specific conversation days or weeks later
- Share session logs for debugging
- Export and analyze your work patterns

#### Practice Exercise

1. Run `/context` to see what files are loaded in your session
2. Run `/statusline` to explore display options
3. Run `/config` to view your current settings
4. Note your current session ID for future reference
5. Exit Claude Code and resume with `claude -c`

### Verification

```yaml
chapter: 1.6-session-commands
type: manual
verification:
  questions:
    - "Run /context and describe what files are currently loaded"
    - "Exit Claude Code and resume with claude -c - did it work?"
    - "What is the difference between -c and -r flags?"
  task_key: test_session_commands
```

### Additional Checklist

- [ ] Used `/context` to see loaded files
- [ ] Explored `/statusline` options
- [ ] Successfully resumed a session with `-c` flag
- [ ] Understand session ID usage with `-r` flag

---

## Chapter 7: Plan Mode

**Chapter ID**: `1.7-plan-mode`

### Content

#### What is Plan Mode?

Plan mode makes Claude explain its approach **before** executing. This is useful for:
- Complex refactoring tasks
- Tasks with multiple approaches
- When you want to review before changes happen

#### Entering Plan Mode

- **Keyboard**: Press `Shift+Tab` before sending
- **Explicit**: Add "Plan this first, don't execute" to your prompt

#### Plan Mode Workflow

1. Enter plan mode
2. Describe your task
3. Claude generates a plan (no execution)
4. You review and modify
5. Approve to execute, or refine the plan

#### When to Use Plan Mode

| Use Plan Mode | Skip Plan Mode |
|---------------|----------------|
| Refactoring across files | Simple file edits |
| Adding new features | Quick fixes |
| Architectural changes | Reading/exploring code |
| Unfamiliar codebases | Familiar, small changes |

### Practice Exercise

1. Enter plan mode (`Shift+Tab`)
2. Ask: "Plan how to add [a feature relevant to your project]"
3. Review the plan Claude generates
4. Do NOT execute - just observe the plan quality

### Verification

```yaml
chapter: 1.7-plan-mode
type: manual
verification:
  questions:
    - "Enter plan mode and request a plan for a feature"
    - "Review the generated plan without executing"
    - "Identify if Claude understood your codebase from the plan"
  task_key: use_plan_mode
```

### Checklist

- [ ] Know how to enter plan mode (Shift+Tab)
- [ ] Generated at least one plan without executing
- [ ] Understand when plan mode is appropriate
- [ ] Can review and evaluate a generated plan

---

## Chapter 8: Creating Custom Commands

**Chapter ID**: `1.8-custom-commands`

### Content

#### What Are Custom Commands?

Custom commands are project-specific slash commands you define. They live in `.claude/commands/` and appear when you type `/`.

#### Command File Structure

Location: `.claude/commands/[command-name].md`

```markdown
---
name: command-name
description: What this command does (shown in /help)
---

# Command: [Name]

## Instructions

When this command is invoked:

1. [First step Claude should take]
2. [Second step]
3. [Third step]

## Context

[Any additional context or constraints]

## Output Format

[How Claude should present results]
```

#### Example: Create a "New Feature" Command

Create `.claude/commands/new-feature.md`:

```markdown
---
name: new-feature
description: Scaffold a new feature with tests and documentation
---

# Command: New Feature

## Instructions

When invoked with a feature name:

1. Create the main implementation file in the appropriate directory
2. Create a corresponding test file
3. Update any index/barrel files
4. Add a brief documentation entry

## Naming Convention

- Feature file: `src/features/[name].ts`
- Test file: `src/features/__tests__/[name].test.ts`

## After Creation

Show a summary of files created and next steps.
```

#### Using Your Command

```bash
claude
/new-feature user-profile
```

### Practice Exercise

1. Create the commands directory: `mkdir -p .claude/commands`
2. Create a simple command for a task you do often
3. Test it with Claude

**Command Ideas by Role**:

| Role | Command Idea |
|------|--------------|
| Frontend | `/new-component` - Create component with styles and tests |
| Backend | `/new-endpoint` - Create API endpoint with validation |
| QA | `/test-suite` - Generate test suite for a module |
| DevOps | `/new-service` - Scaffold service configuration |
| Data | `/new-pipeline` - Create data pipeline template |

### Verification

```yaml
chapter: 1.8-custom-commands
type: automated
verification:
  checks:
    - directory_exists: ".claude/commands"
      task_key: create_commands_directory
    - file_pattern: ".claude/commands/*.md"
      min_count: 1
      task_key: create_custom_command
    - file_contains_frontmatter: ["name:", "description:"]
      task_key: valid_command_format
```

### Checklist

- [ ] Created `.claude/commands/` directory
- [ ] Created at least one custom command file
- [ ] Command has proper frontmatter (name, description)
- [ ] Tested the command with Claude
- [ ] Command appears in `/help` output

---

## Chapter 9: Commit Your Work

**Chapter ID**: `1.9-commit`

### Content

#### What to Commit

After completing this seminar, you should have:

```
your-repo/
├── CLAUDE.md              # Project memory file
└── .claude/
    └── commands/
        └── [your-command].md  # Custom command
```

#### Commit Commands

```bash
# Stage your files
git add CLAUDE.md .claude/

# Commit with descriptive message
git commit -m "Add Claude Code configuration

- Add CLAUDE.md with project context
- Add custom command for [your workflow]"
```

### Verification

```yaml
chapter: 1.9-commit
type: automated
verification:
  checks:
    - git_committed: "CLAUDE.md"
      task_key: commit_claude_md
    - git_committed: ".claude/commands"
      task_key: commit_commands
```

### Checklist

- [ ] CLAUDE.md committed to git
- [ ] `.claude/commands/` committed to git
- [ ] Commit message is descriptive

---

## Seminar Summary

### What You Learned

1. **Claude Code Basics**: Installation, authentication, CLI usage
2. **Project Memory**: Creating and maintaining CLAUDE.md
3. **Commands**: Using slash commands effectively
4. **Plan Mode**: Thinking before executing
5. **Custom Commands**: Extending Claude for your workflow

### Files Created

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project context and memory |
| `.claude/commands/*.md` | Custom slash commands |

### Next Seminar Preview

In **Seminar 2: Skills**, you'll learn to create reusable instruction files that teach Claude your team's specific patterns and procedures.

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar1-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar1-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-report.html",
  open_browser=true
)
```

### What's Captured

| Data | Description |
|------|-------------|
| Session ID | Unique identifier for your learning session |
| Duration | Time spent on the module |
| Tool usage | Read, Write, Bash, Glob calls |
| Tasks completed | Which verification steps passed |
| Errors | Any issues encountered |

---

## Validation Summary

```yaml
seminar: 1-foundations-and-commands
tasks:
  install_claude_code:
    chapter: 1.2
    type: automated
    check: "command -v claude"

  create_claude_md:
    chapter: 1.4
    type: automated
    check: "file_exists:CLAUDE.md"

  claude_md_quality:
    chapter: 1.4
    type: automated
    check: "file_quality:CLAUDE.md"

  add_project_overview:
    chapter: 1.4
    type: automated
    check: "file_contains:## Overview"

  add_tech_stack:
    chapter: 1.4
    type: automated
    check: "file_contains:Tech Stack"

  add_conventions:
    chapter: 1.4
    type: automated
    check: "file_contains:Convention"

  test_claude_understanding:
    chapter: 1.5
    type: manual
    check: "student_confirms"

  explore_slash_commands:
    chapter: 1.6
    type: manual
    check: "student_confirms"

  test_session_commands:
    chapter: 1.6
    type: manual
    check: "student_confirms"

  use_plan_mode:
    chapter: 1.7
    type: manual
    check: "student_confirms"

  create_custom_command:
    chapter: 1.8
    type: automated
    check: "glob:.claude/commands/*.md"

  commit_work:
    chapter: 1.9
    type: automated
    check: "git_log:CLAUDE.md"
```

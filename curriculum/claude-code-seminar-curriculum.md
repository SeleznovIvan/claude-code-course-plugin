# Claude Code Seminar Series: Complete Curriculum Plan

**Course Philosophy**: Each seminar builds on the previous one. Developers work on their own GitHub repository throughout the course, progressively implementing Claude Code features that match their specific domain (frontend, backend, QA, DevOps, data engineering, etc.).

---

## Seminar 1: Foundations

**Duration**: 90 minutes (60 min lecture + 30 min hands-on setup)

### Learning Objectives
By the end of this seminar, participants will:
- Install and authenticate Claude Code in their development environment
- Navigate basic CLI interactions confidently
- Create a CLAUDE.md file that captures their project's context
- Understand how memory persistence works across sessions

### Topics Covered

**1.1 What is Claude Code?**
- Agentic coding assistant vs. chat-based AI
- How Claude Code differs from Copilot/Cursor (terminal-native, full codebase awareness)
- The "pair programmer in your terminal" mental model

**1.2 Installation & Authentication**
- Installing via npm: `npm install -g @anthropic-ai/claude-code`
- Authentication flow and API key management
- Verifying installation: `claude --version`
- First launch and initial setup wizard

**1.3 Basic CLI Interactions**
- Starting a session: `claude` (interactive) vs `claude "prompt"` (one-shot)
- The `-p` flag for direct prompts without interactive mode
- The `-c` flag for continuing previous conversations
- Reading Claude's responses and understanding tool usage indicators
- Exiting sessions gracefully

**1.4 CLAUDE.md: Your Project's Memory**
- Why memory matters: context persistence across sessions
- The `/init` command and auto-generated CLAUDE.md
- CLAUDE.md file structure and best practices:
  - Project overview and architecture
  - Key conventions and patterns
  - Common commands and workflows
  - Known issues and gotchas
- Memory hierarchy: ~/.claude/CLAUDE.md (global) vs project-level
- When Claude reads memory files (session start, file changes)

### Live Demo
- Install Claude Code on a fresh environment
- Run `/init` on a sample repository
- Show before/after of Claude's responses with and without CLAUDE.md
- Demonstrate how adding conventions to CLAUDE.md changes Claude's behavior

---

### Practical Task: "Initialize Your Project"

**Objective**: Set up Claude Code for your own repository and create a comprehensive CLAUDE.md file.

**Steps for all participants**:

1. **Install Claude Code** on your machine and verify authentication works

2. **Clone or navigate to your chosen repository**
   - This should be a real project you're working on (not a toy example)
   - If you don't have one, fork a popular open-source project in your domain

3. **Run `/init`** and review the auto-generated CLAUDE.md

4. **Enhance your CLAUDE.md** with the following sections:

```markdown
# Project: [Your Project Name]

## Overview
[2-3 sentences describing what this project does]

## Tech Stack
- Language: [e.g., TypeScript, Python, Go]
- Framework: [e.g., React, FastAPI, Gin]
- Testing: [e.g., Jest, pytest, go test]
- Build: [e.g., Webpack, Poetry, Make]

## Architecture
[Brief description of how the codebase is organized]

## Conventions
- [Naming conventions]
- [File organization rules]
- [Code style preferences]

## Common Commands
- Run tests: `[your test command]`
- Start dev server: `[your dev command]`
- Build: `[your build command]`

## Important Context
- [Any domain-specific knowledge Claude should know]
- [Key business logic locations]
- [Areas that need careful handling]
```

5. **Test your setup** by asking Claude:
   - "What is this project about?"
   - "Where would I add a new [feature relevant to your domain]?"
   - "What testing framework does this project use?"

**Success Criteria**:
- [ ] Claude Code installed and authenticated
- [ ] CLAUDE.md exists in your repository root
- [ ] CLAUDE.md contains at least 5 meaningful sections
- [ ] Claude correctly answers basic questions about your project
- [ ] Commit your CLAUDE.md to a new branch

**Role-Specific Guidance**:

| Role | Focus Areas for CLAUDE.md |
|------|---------------------------|
| Frontend | Component patterns, state management approach, styling conventions, browser support |
| Backend | API design patterns, database schemas, authentication flow, error handling conventions |
| QA/Testing | Test organization, fixture patterns, mocking strategies, coverage requirements |
| DevOps | Infrastructure layout, deployment processes, environment configurations |
| Data | Pipeline architecture, data models, transformation conventions |

---

## Seminar 2: Commands

**Duration**: 90 minutes (60 min lecture + 30 min practice)

### Learning Objectives
By the end of this seminar, participants will:
- Use slash commands fluently for common operations
- Configure CLI flags for different use cases
- Leverage plan mode for complex tasks
- Understand and configure permission levels appropriately

### Topics Covered

**2.1 Slash Commands Mastery**
- `/help` - Command reference
- `/init` - Project initialization (revisited with advanced options)
- `/clear` - Reset conversation context
- `/compact` - Summarize and compress context when running low
- `/cost` - Monitor token usage and spending
- `/model` - Switch models mid-session
- `/config` - View and modify settings
- `/doctor` - Diagnose installation issues
- `/review` - Code review mode
- `/pr-comments` - Address PR feedback

**2.2 CLI Flags Deep Dive**
- `--print` / `-p` - Output response and exit (scripting mode)
- `--continue` / `-c` - Resume last conversation
- `--resume` / `-r` - Resume specific session by ID
- `--output-format` - JSON, text, stream-json options
- `--max-turns` - Limit agentic loops
- `--model` - Specify model at launch
- `--permission-mode` - Set permission level
- `--verbose` - Debug output

**2.3 Plan Mode: Think Before Acting**
- What is plan mode? (Claude explains approach before executing)
- Entering plan mode: `Shift+Tab` or explicit instruction
- When to use plan mode:
  - Complex refactoring tasks
  - Tasks with multiple possible approaches
  - When you want to review before changes happen
- Reviewing and modifying plans before execution
- The "ultrathink" technique for maximum reasoning

**2.4 Thinking Mode**
- Extended thinking for complex problems
- `--max-thinking-tokens` flag
- When to enable vs. disable thinking
- Balancing speed and thoroughness

**2.5 Permission Management**
- Permission modes: default, auto-accept, plan
- Understanding what Claude can do without asking:
  - Read files: always allowed
  - Write files: asks permission
  - Run commands: asks permission
  - Network requests: asks permission
- The `--dangerously-skip-permissions` flag (and when NOT to use it)
- Creating trust boundaries for different environments

### Live Demo
- Show plan mode on a complex refactoring task
- Demonstrate permission prompts and how to configure them
- Use `/cost` to show token consumption patterns
- Show `--output-format json` for scripting integration

---

### Practical Task: "Master Your Workflow Commands"

**Objective**: Develop a personalized command workflow for your daily development tasks.

**Part A: Command Exploration (15 min)**

1. **Run these commands** in your repository and document what you learn:
   ```
   /help
   /doctor
   /config
   /cost
   ```

2. **Create a "cheat sheet"** section in your CLAUDE.md:
   ```markdown
   ## My Claude Code Cheat Sheet
   
   ### Commands I Use Daily
   - [List the 5 most useful commands for your workflow]
   
   ### My Preferred Flags
   - [Document flags you'll use regularly]
   ```

**Part B: Plan Mode Practice (20 min)**

3. **Choose a task** from your actual backlog (something you need to do anyway):
   
   | Role | Suggested Task |
   |------|----------------|
   | Frontend | "Plan how to add dark mode support to the app" |
   | Backend | "Plan how to add request rate limiting to the API" |
   | QA | "Plan how to add integration tests for [critical flow]" |
   | DevOps | "Plan how to add health check endpoints" |
   | Data | "Plan how to add data validation to the pipeline" |

4. **Enter plan mode** (Shift+Tab) and submit your task

5. **Document the plan** Claude generates (don't execute yet):
   - Was the plan appropriate for your codebase?
   - What would you modify?
   - Did Claude understand your conventions from CLAUDE.md?

**Part C: Permission Configuration (10 min)**

6. **Experiment with permission modes**:
   ```bash
   # Try a task with default permissions
   claude "add a comment to the main entry file"
   
   # Observe: What did Claude ask permission for?
   ```

7. **Update your CLAUDE.md** with permission preferences:
   ```markdown
   ## Permission Notes
   - Safe operations in this repo: [list them]
   - Always ask before: [list sensitive areas]
   ```

**Success Criteria**:
- [ ] Used at least 5 different slash commands
- [ ] Generated a plan using plan mode without executing
- [ ] Documented your command preferences in CLAUDE.md
- [ ] Understand the difference between permission modes
- [ ] Can explain when to use `-p` vs interactive mode

**Deliverable**: Updated CLAUDE.md with a "Cheat Sheet" and "Permission Notes" section

---

## Seminar 3: Skills

**Duration**: 90 minutes (60 min lecture + 30 min implementation)

### Learning Objectives
By the end of this seminar, participants will:
- Understand what Skills are and why they matter
- Distinguish between reference skills and action skills
- Create a custom SKILL.md file for their project
- Load and use skills effectively in Claude Code sessions

### Topics Covered

**3.1 What Are Skills?**
- Skills as reusable, project-specific instructions
- The difference from CLAUDE.md (memory vs. capabilities)
- Skills as "teaching Claude how to do something specific"
- Real-world analogy: skills are like runbooks/playbooks for Claude

**3.2 SKILL.md File Structure**
- Location: `.claude/skills/` directory
- Naming conventions: `SKILL.md` or `[skill-name].md`
- Basic structure:
  ```markdown
  # Skill: [Name]
  
  ## Description
  [What this skill enables]
  
  ## When to Use
  [Trigger conditions]
  
  ## Instructions
  [Step-by-step process]
  
  ## Examples
  [Concrete examples]
  ```

**3.3 Reference Skills vs. Action Skills**
- **Reference Skills**: Provide context and conventions
  - Style guides
  - Architecture documentation
  - API specifications
- **Action Skills**: Define specific procedures
  - "How to create a new component"
  - "How to add a new API endpoint"
  - "How to write tests for this codebase"

**3.4 Skill Loading and Discovery**
- How Claude discovers skills (directory scanning)
- Explicit skill loading with `@skill-name`
- Automatic skill matching based on task context
- Skill inheritance and composition

**3.5 Advanced Skill Patterns**
- Parameterized skills (templates with placeholders)
- Conditional instructions based on context
- Skills that reference other skills
- Version-controlled skills for team consistency

### Live Demo
- Create a skill for "adding a new feature" in a sample repo
- Show how Claude's behavior changes with and without the skill
- Demonstrate skill loading and the @ mention syntax
- Build a testing skill that enforces specific patterns

---

### Practical Task: "Build Your First Skills"

**Objective**: Create 2-3 custom skills that encode your team's best practices.

**Part A: Identify Skill Opportunities (10 min)**

1. **List repetitive tasks** you do in your codebase:
   - What do you do every time you create a new [X]?
   - What patterns must every [Y] follow?
   - What do new team members always get wrong?

2. **Select 2-3 candidates** for skills:

   | Role | Suggested Skill Ideas |
   |------|----------------------|
   | Frontend | "Create new component", "Add new page/route", "Write component tests" |
   | Backend | "Create new endpoint", "Add database migration", "Write API tests" |
   | QA | "Create test suite for feature", "Add E2E test scenario", "Document test case" |
   | DevOps | "Add new service to docker-compose", "Create Terraform module", "Add monitoring alert" |
   | Data | "Create new data model", "Add transformation step", "Document data source" |

**Part B: Create Your Skills (25 min)**

3. **Create the skills directory**:
   ```bash
   mkdir -p .claude/skills
   ```

4. **Write your first skill** (Reference type):
   
   Create `.claude/skills/coding-standards.md`:
   ```markdown
   # Skill: Coding Standards
   
   ## Description
   Enforces our team's coding standards and conventions.
   
   ## When to Use
   Apply these standards when writing or reviewing any code.
   
   ## Standards
   
   ### Naming
   - [Your naming conventions]
   
   ### File Organization
   - [Your file structure rules]
   
   ### Code Style
   - [Your style preferences]
   
   ### Documentation
   - [Your documentation requirements]
   ```

5. **Write your second skill** (Action type):
   
   Create `.claude/skills/create-[your-thing].md`:
   ```markdown
   # Skill: Create [Component/Endpoint/Test/etc.]
   
   ## Description
   Step-by-step process for creating a new [X] in this codebase.
   
   ## When to Use
   When asked to create, add, or implement a new [X].
   
   ## Prerequisites
   - [What must exist before this skill runs]
   
   ## Steps
   
   1. **Create the main file**
      - Location: `[path pattern]`
      - Template:
        ```[language]
        [Your boilerplate template]
        ```
   
   2. **Create the test file**
      - Location: `[test path pattern]`
      - Must include: [minimum test requirements]
   
   3. **Update exports/registry**
      - File: `[index file location]`
      - Add: [what to add]
   
   4. **Verify**
      - Run: `[verification command]`
   
   ## Examples
   
   ### Example: Creating a [concrete example]
   [Show a real example from your codebase]
   ```

**Part C: Test Your Skills (10 min)**

6. **Test your skills** with Claude:
   ```
   # Start a new session
   claude
   
   # Ask Claude to use your skill
   "Create a new [X] called [name] following our team standards"
   ```

7. **Evaluate the output**:
   - Did Claude follow your skill's steps?
   - Did it apply your coding standards?
   - What's missing from your skill definition?

8. **Iterate**: Update your skills based on what you learned

**Success Criteria**:
- [ ] Created `.claude/skills/` directory
- [ ] Written at least 1 reference skill (standards/conventions)
- [ ] Written at least 1 action skill (how-to procedure)
- [ ] Tested skills with Claude and verified behavior change
- [ ] Committed skills to your branch

**Deliverable**: At least 2 skill files in `.claude/skills/` committed to your repository

---

## Seminar 4: Extensions

**Duration**: 120 minutes (80 min lecture + 40 min implementation)

### Learning Objectives
By the end of this seminar, participants will:
- Create hooks for automating pre/post actions
- Configure MCP servers for external tool integration
- Build custom slash commands for team workflows
- Understand the extension ecosystem and possibilities

### Topics Covered

**4.1 Hooks: Automation Triggers**
- What are hooks? (Event-driven automation)
- Hook types:
  - `PreToolUse` - Before Claude uses a tool
  - `PostToolUse` - After Claude uses a tool
  - `Notification` - On notifications
  - `Stop` - When Claude stops
- Hook configuration location: `.claude/hooks/`
- Hook file format (JSON configuration)

**4.2 Practical Hook Examples**
```json
// .claude/hooks/pre-commit-lint.json
{
  "event": "PreToolUse",
  "tool": "write_file",
  "command": "npm run lint --fix ${file}"
}
```
- Auto-formatting before file writes
- Running tests after code changes
- Notifications on task completion
- Logging and audit trails
- Security scanning hooks

**4.3 MCP (Model Context Protocol) Servers**
- What is MCP? (Protocol for tool integration)
- MCP vs. direct API calls (standardized, discoverable)
- Popular MCP servers:
  - File system operations
  - Database queries
  - API integrations (GitHub, Jira, Slack)
  - Browser automation (Playwright)
  - Design tools (Figma)
- Configuring MCP servers in `.claude/mcp.json`

**4.4 MCP Configuration**
```json
// .claude/mcp.json
{
  "servers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

**4.5 Custom Slash Commands**
- Creating project-specific commands
- Command definition syntax
- Parameterized commands
- Commands that invoke skills
- Sharing commands across team

**4.6 Building a Custom Command**
```json
// .claude/commands/deploy-preview.json
{
  "name": "deploy-preview",
  "description": "Deploy current branch to preview environment",
  "steps": [
    "Run tests to ensure build passes",
    "Build the project",
    "Deploy to preview using [your deployment tool]",
    "Return the preview URL"
  ]
}
```

### Live Demo
- Create a hook that runs linting before every file write
- Configure the GitHub MCP server and use it to create issues
- Build a custom command for a common workflow
- Show how hooks, MCP, and commands can work together

---

### Practical Task: "Extend Your Claude Code Setup"

**Objective**: Add at least one hook, explore MCP, and create a custom command.

**Part A: Create a Hook (15 min)**

1. **Create the hooks directory**:
   ```bash
   mkdir -p .claude/hooks
   ```

2. **Choose a hook** based on your role:

   | Role | Suggested Hook |
   |------|---------------|
   | Frontend | Auto-run Prettier/ESLint on file save |
   | Backend | Run type checker after Python/Go file changes |
   | QA | Auto-run related tests after test file changes |
   | DevOps | Validate YAML/JSON syntax on config file changes |
   | Data | Validate schema after model file changes |

3. **Create your hook file** `.claude/hooks/[name].json`:
   ```json
   {
     "event": "PostToolUse",
     "tool": "write_file", 
     "pattern": "**/*.[your-extension]",
     "command": "[your-lint-or-check-command] ${file}"
   }
   ```

4. **Test the hook**: Make a change and verify it triggers

**Part B: Explore MCP (15 min)**

5. **Configure a basic MCP server** in `.claude/mcp.json`:

   For most developers, start with the filesystem or GitHub server:
   ```json
   {
     "servers": {
       "filesystem": {
         "command": "npx",
         "args": ["-y", "@anthropic-ai/mcp-server-filesystem", "/path/to/allowed/dir"]
       }
     }
   }
   ```

6. **Explore available MCP servers** for your domain:
   - GitHub: Issue tracking, PR management
   - PostgreSQL/MySQL: Database querying
   - Slack: Team notifications
   - Playwright: Browser testing
   - Sentry: Error tracking

7. **Document MCP possibilities** in your CLAUDE.md:
   ```markdown
   ## MCP Integrations (Current & Planned)
   - [ ] GitHub - for issue management
   - [ ] [Database] - for schema exploration
   - [ ] [Your tools]
   ```

**Part C: Build a Custom Command (15 min)**

8. **Create commands directory**:
   ```bash
   mkdir -p .claude/commands
   ```

9. **Identify a repeated workflow** you do weekly:
   - "Check what PRs need my review"
   - "Set up a new feature branch with boilerplate"
   - "Generate a changelog from recent commits"
   - "Run the full test suite and summarize failures"

10. **Create the command** `.claude/commands/[name].json`:
    ```json
    {
      "name": "[your-command-name]",
      "description": "[What this command does]",
      "instructions": [
        "Step 1: [First action]",
        "Step 2: [Second action]",
        "Step 3: [Final action and output format]"
      ]
    }
    ```

11. **Test with**: `/[your-command-name]`

**Success Criteria**:
- [ ] Created at least 1 working hook
- [ ] Configured MCP (even if just filesystem server)
- [ ] Created at least 1 custom command
- [ ] Documented your extensions in CLAUDE.md
- [ ] Committed all configuration to your branch

**Deliverable**: 
- `.claude/hooks/` with at least 1 hook
- `.claude/mcp.json` with at least 1 server configured
- `.claude/commands/` with at least 1 custom command

---

## Seminar 5: Agents

**Duration**: 120 minutes (80 min lecture + 40 min practice)

### Learning Objectives
By the end of this seminar, participants will:
- Understand the subagent architecture and when to use it
- Launch and orchestrate parallel agent execution
- Design effective agent delegation patterns
- Apply agent orchestration to their own workflows

### Topics Covered

**5.1 Understanding Subagents**
- What is a subagent? (Isolated Claude instance for subtask)
- Why subagents? (Parallel work, isolation, specialization)
- Subagent vs. single session (trade-offs)
- The "one Claude writes, another reviews" pattern

**5.2 Launching Subagents**
- Implicit subagents (Claude spawns when needed)
- Explicit subagent requests: "Create a subagent to..."
- Subagent configuration and context passing
- Communication between main agent and subagents

**5.3 Parallel Execution Patterns**
- **Pattern 1**: Divide and conquer
  - Split large task into independent subtasks
  - Each subagent handles one subtask
  - Main agent aggregates results
- **Pattern 2**: Specialist agents
  - Different agents for different expertise
  - Code agent + Test agent + Doc agent
- **Pattern 3**: Review agents
  - One agent implements
  - Another agent reviews/critiques
  - Iterate until quality threshold met

**5.4 Agent Orchestration Strategies**
```
User Request
    │
    ▼
┌─────────────────┐
│  Main Agent     │
│  (Coordinator)  │
└────────┬────────┘
         │
    ┌────┴────┬────────┐
    ▼         ▼        ▼
┌───────┐ ┌───────┐ ┌───────┐
│Agent 1│ │Agent 2│ │Agent 3│
│(Code) │ │(Test) │ │(Docs) │
└───────┘ └───────┘ └───────┘
```

**5.5 Git Worktrees for Parallel Development**
- What are git worktrees? (Multiple working directories, one repo)
- Why worktrees + agents? (True parallel file modifications)
- Setting up worktrees:
  ```bash
  git worktree add ../feature-a feature-branch-a
  git worktree add ../feature-b feature-branch-b
  ```
- Running agents in different worktrees simultaneously

**5.6 Agent Communication Patterns**
- Passing context to subagents
- Collecting and aggregating results
- Error handling in multi-agent scenarios
- When to intervene vs. let agents resolve

**5.7 Best Practices for Multi-Agent Work**
- Keep subagent tasks focused and independent
- Provide clear success criteria for each agent
- Use plan mode before launching complex orchestrations
- Monitor token usage (multiple agents = multiple costs)

### Live Demo
- Launch a subagent to write tests while main agent implements feature
- Set up git worktrees and run parallel agents
- Show the "writer + reviewer" pattern in action
- Demonstrate error recovery when a subagent fails

---

### Practical Task: "Orchestrate Your First Multi-Agent Workflow"

**Objective**: Use agents to parallelize a real task in your repository.

**Part A: Single Subagent (15 min)**

1. **Identify a task with clear subtasks**:
   
   | Role | Suggested Task |
   |------|---------------|
   | Frontend | "Add a new feature component" → Code + Tests + Storybook |
   | Backend | "Add new API endpoint" → Handler + Tests + OpenAPI spec |
   | QA | "Create comprehensive test coverage" → Unit + Integration + E2E |
   | DevOps | "Add new service" → Config + Dockerfile + K8s manifests |
   | Data | "Add new data source" → Ingestion + Validation + Documentation |

2. **Launch with explicit subagent delegation**:
   ```
   I need to [your task]. Please:
   1. Use a subagent to [write tests/generate docs/etc.] 
   2. While you [implement the main code]
   3. Then integrate both results
   ```

3. **Observe and document**:
   - How did Claude split the work?
   - Did the subagent context include your CLAUDE.md?
   - How were results integrated?

**Part B: Parallel Execution with Worktrees (20 min)**

4. **Create two worktrees** for parallel work:
   ```bash
   # Create branches
   git checkout -b agent-task-a
   git checkout -b agent-task-b
   git checkout main
   
   # Create worktrees
   git worktree add ../my-project-task-a agent-task-a
   git worktree add ../my-project-task-b agent-task-b
   ```

5. **Open two terminal windows**, one in each worktree

6. **Launch Claude in each** with related but independent tasks:
   - Terminal 1: `claude "Implement [feature A] with tests"`
   - Terminal 2: `claude "Implement [feature B] with tests"`

7. **Let both run** and observe parallel execution

8. **Merge results**:
   ```bash
   git checkout main
   git merge agent-task-a
   git merge agent-task-b
   ```

**Part C: Design Your Agent Pattern (10 min)**

9. **Document your ideal multi-agent workflow** in CLAUDE.md:
   ```markdown
   ## Multi-Agent Patterns for This Project
   
   ### Pattern: [Name]
   **Use when**: [Scenario]
   **Agents involved**:
   1. Main agent: [Role]
   2. Subagent A: [Role]
   3. Subagent B: [Role]
   
   **Orchestration**:
   [How they coordinate]
   
   ### Commands
   - `/parallel-feature` - Launch parallel implementation + testing
   ```

**Success Criteria**:
- [ ] Successfully used at least one subagent
- [ ] Created and used git worktrees for parallel execution
- [ ] Ran two Claude sessions simultaneously on related tasks
- [ ] Merged parallel work back to main branch
- [ ] Documented your agent pattern in CLAUDE.md

**Deliverable**: 
- At least 2 branches with agent-generated work merged to main
- Updated CLAUDE.md with "Multi-Agent Patterns" section

---

## Seminar 6: Workflows

**Duration**: 120 minutes (80 min lecture + 40 min implementation)

### Learning Objectives
By the end of this seminar, participants will:
- Integrate Claude Code with GitHub workflows
- Set up CI/CD pipelines that leverage Claude Code
- Implement multi-agent production patterns
- Use headless mode for automated tasks

### Topics Covered

**6.1 GitHub Integration**
- Installing the Claude GitHub App: `/install-github-app`
- Capabilities enabled:
  - Automated PR reviews
  - Issue triage and labeling
  - Automated code fixes
  - Documentation generation
- Configuration options and permissions

**6.2 PR Review Automation**
```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review
on: [pull_request]
jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Claude Review
        run: |
          claude -p "Review this PR for:
          - Code quality issues
          - Potential bugs
          - Missing tests
          - Documentation gaps"
```

**6.3 CI/CD Integration Patterns**
- Pre-commit hooks with Claude
- PR validation workflows
- Automated fix suggestions
- Test generation in CI
- Documentation auto-update

**6.4 Headless Mode**
- What is headless mode? (Non-interactive, scripted execution)
- The `--print` flag for scripted output
- The `--output-format json` for programmatic parsing
- Combining with `--max-turns` for bounded execution
- Example: `claude -p "Fix all lint errors" --print --max-turns 10`

**6.5 Multi-Agent Production Patterns**

**Pattern: Continuous Integration Agent**
```
PR Opened
    │
    ▼
┌──────────────┐
│ Review Agent │──→ Posts review comments
└──────────────┘
    │
    ▼
┌──────────────┐
│  Fix Agent   │──→ Pushes fix commits
└──────────────┘
    │
    ▼
┌──────────────┐
│  Test Agent  │──→ Adds missing tests
└──────────────┘
```

**Pattern: Issue Triage**
```
Issue Created
    │
    ▼
┌──────────────┐
│ Triage Agent │──→ Labels, assigns, estimates
└──────────────┘
    │
    ▼
┌──────────────────┐
│ Implementation   │──→ Creates draft PR
│ Suggestion Agent │
└──────────────────┘
```

**6.6 Building Automated Workflows**
- Cron-triggered Claude jobs
- Event-driven automation (webhooks)
- Slack/Discord integration for notifications
- Dashboard for monitoring agent activity

**6.7 Production Best Practices**
- Rate limiting and cost management
- Error handling and fallback strategies
- Audit logging for agent actions
- Human-in-the-loop checkpoints
- Security considerations for automated agents

### Live Demo
- Install GitHub App and configure PR reviews
- Create a GitHub Action that runs Claude on PR
- Show headless mode for batch operations
- Demonstrate issue triage automation

---

### Practical Task: "Build Your CI/CD Integration"

**Objective**: Create at least one automated workflow using Claude Code in your repository.

**Part A: GitHub Integration Setup (15 min)**

1. **Install the GitHub App**:
   ```
   claude
   /install-github-app
   ```
   Follow the OAuth flow to connect your repository

2. **Verify integration**:
   ```
   "List the open issues in this repository"
   "What PRs are waiting for review?"
   ```

3. **Test basic automation**:
   ```
   "Review the most recent PR and post a comment with your findings"
   ```

**Part B: Create a CI Workflow (20 min)**

4. **Choose a workflow** based on your needs:

   | Role | Suggested Workflow |
   |------|-------------------|
   | Frontend | Auto-review component changes for accessibility |
   | Backend | Auto-review API changes for breaking changes |
   | QA | Auto-generate test cases for new code |
   | DevOps | Auto-review infrastructure changes for security |
   | Data | Auto-validate data schema changes |

5. **Create the workflow file** `.github/workflows/claude-[your-workflow].yml`:

   ```yaml
   name: Claude [Your Workflow Name]
   
   on:
     pull_request:
       paths:
         - '[relevant paths for your domain]/**'
   
   jobs:
     claude-review:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
           with:
             fetch-depth: 0
         
         - name: Install Claude Code
           run: npm install -g @anthropic-ai/claude-code
         
         - name: Run Claude Analysis
           env:
             ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
           run: |
             claude -p "[Your specific review prompt]" \
               --print \
               --max-turns 5 \
               > claude-review.md
         
         - name: Post Review Comment
           uses: actions/github-script@v7
           with:
             script: |
               const fs = require('fs');
               const review = fs.readFileSync('claude-review.md', 'utf8');
               github.rest.issues.createComment({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 issue_number: context.issue.number,
                 body: `## Claude Code Review\n\n${review}`
               });
   ```

6. **Add the API key** to repository secrets:
   - Go to Settings → Secrets → Actions
   - Add `ANTHROPIC_API_KEY`

**Part C: Headless Automation Script (10 min)**

7. **Create a utility script** `scripts/claude-[task].sh`:

   ```bash
   #!/bin/bash
   # scripts/claude-lint-fix.sh
   
   # Run Claude to fix all linting issues
   claude -p "Find and fix all linting errors in the codebase. 
   Use our coding standards from CLAUDE.md.
   Commit each fix separately with descriptive messages." \
     --print \
     --max-turns 20 \
     --output-format json > /tmp/claude-output.json
   
   # Parse and report results
   echo "Claude completed with status:"
   cat /tmp/claude-output.json | jq '.status'
   ```

8. **Make it executable and test**:
   ```bash
   chmod +x scripts/claude-lint-fix.sh
   ./scripts/claude-lint-fix.sh
   ```

**Part D: Document Your Workflows (10 min)**

9. **Update CLAUDE.md** with workflow documentation:
   ```markdown
   ## Automated Workflows
   
   ### CI/CD Integration
   - PR Review: Auto-reviews all PRs for [what you check]
   - Triggered by: [events]
   - Actions taken: [what happens]
   
   ### Utility Scripts
   - `scripts/claude-lint-fix.sh` - Automated lint fixing
   - `scripts/claude-[other].sh` - [Description]
   
   ### GitHub App Capabilities
   - Issue triage: [enabled/disabled]
   - PR review: [enabled/disabled]
   - Auto-fix: [enabled/disabled]
   ```

**Success Criteria**:
- [ ] GitHub App installed and connected
- [ ] Created at least 1 GitHub Actions workflow using Claude
- [ ] Created at least 1 headless automation script
- [ ] Tested the workflow on a real (or test) PR
- [ ] Documented all workflows in CLAUDE.md
- [ ] Committed all workflow files to your branch

**Deliverable**:
- `.github/workflows/` with at least 1 Claude-powered workflow
- `scripts/` with at least 1 automation script
- Final updated CLAUDE.md with complete documentation

---

## Course Completion Checklist

By the end of all 6 seminars, each participant should have:

### Repository Artifacts
- [ ] `CLAUDE.md` - Comprehensive project documentation with:
  - Project overview and tech stack
  - Coding conventions and standards
  - Command cheat sheet
  - Permission notes
  - Multi-agent patterns
  - Automated workflow documentation

- [ ] `.claude/skills/` - Custom skills including:
  - At least 1 reference skill (standards)
  - At least 1 action skill (procedures)

- [ ] `.claude/hooks/` - Automation hooks for:
  - At least 1 pre or post tool use hook

- [ ] `.claude/commands/` - Custom commands:
  - At least 1 project-specific command

- [ ] `.claude/mcp.json` - MCP configuration:
  - At least 1 server configured

- [ ] `.github/workflows/` - CI/CD integration:
  - At least 1 Claude-powered workflow

- [ ] `scripts/` - Utility scripts:
  - At least 1 headless automation script

### Skills Demonstrated
- [ ] Can install and configure Claude Code from scratch
- [ ] Effectively uses slash commands and CLI flags
- [ ] Creates and maintains CLAUDE.md for project context
- [ ] Writes custom skills for team workflows
- [ ] Configures hooks for automation
- [ ] Uses MCP for external integrations
- [ ] Orchestrates multi-agent workflows
- [ ] Sets up CI/CD pipelines with Claude Code
- [ ] Runs headless Claude for batch operations

---

## Appendix: Role-Specific Resource Paths

### Frontend Developers
- Skills focus: Component creation, styling patterns, state management
- Hooks focus: Prettier/ESLint, build validation, bundle size checks
- Workflows focus: Visual regression, accessibility audits, Storybook updates

### Backend Developers
- Skills focus: API endpoint creation, database migrations, service patterns
- Hooks focus: Type checking, API spec validation, security scanning
- Workflows focus: API contract testing, performance benchmarks, docs generation

### QA Engineers
- Skills focus: Test case creation, fixture patterns, coverage reporting
- Hooks focus: Test execution after changes, coverage thresholds
- Workflows focus: Automated test generation, regression detection, flaky test identification

### DevOps Engineers
- Skills focus: Infrastructure patterns, deployment procedures, monitoring setup
- Hooks focus: Config validation, security scanning, cost estimation
- Workflows focus: Infrastructure validation, deployment automation, incident response

### Data Engineers
- Skills focus: Pipeline patterns, data modeling, transformation conventions
- Hooks focus: Schema validation, data quality checks, lineage tracking
- Workflows focus: Pipeline testing, data quality monitoring, documentation generation

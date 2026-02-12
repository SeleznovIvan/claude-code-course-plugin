# Seminar 5: Workflows

**Duration**: 120 minutes (80 min guided + 40 min implementation)

**Seminar ID**: `5-workflows`

**Prerequisites**: Completed Seminars 1-4 (Full Claude Code setup, agent patterns understood)

---

## Learning Objectives

By the end of this seminar, participants will:
- Integrate Claude Code with GitHub workflows
- Set up CI/CD pipelines that leverage Claude
- Use headless mode for automated tasks
- Implement production-ready automation patterns

---

## Chapter 1: GitHub Integration Overview

**Chapter ID**: `5.1-github-overview`

### Content

#### What Claude Can Do with GitHub

| Capability | Description |
|------------|-------------|
| **PR Reviews** | Automated code review on pull requests |
| **Issue Triage** | Label, assign, and prioritize issues |
| **Code Fixes** | Suggest or apply fixes automatically |
| **Documentation** | Generate or update docs from code |

#### Integration Methods

1. **GitHub App**: Official Anthropic GitHub integration
2. **GitHub Actions**: Custom workflows using Claude CLI
3. **MCP GitHub Server**: Direct API access from Claude sessions

### Verification

```yaml
chapter: 5.1-github-overview
type: conceptual
verification: manual
question: "What are the three ways to integrate Claude with GitHub?"
```

### Checklist

- [ ] Understand GitHub integration capabilities
- [ ] Know the three integration methods
- [ ] Identified which method fits your needs

---

## Chapter 2: GitHub App Installation

**Chapter ID**: `5.2-github-app`

### Content

#### Installing the GitHub App

In a Claude session:
```
/install-github-app
```

This will:
1. Open browser for GitHub OAuth
2. Request repository access permissions
3. Complete the connection

#### Verifying Connection

After installation:
```
List the open issues in this repository
```

If Claude can list issues, the connection works.

#### What the App Enables

With the GitHub App connected:
- Claude can read issues and PRs
- Claude can post comments
- Claude can suggest code changes
- Claude can create issues

### Verification

```yaml
chapter: 5.2-github-app
type: manual
verification:
  questions:
    - "Run /install-github-app"
    - "Complete OAuth flow"
    - "Ask Claude to list repository issues"
  task_key: install_github_app
```

### Checklist

- [ ] Ran `/install-github-app`
- [ ] Completed GitHub OAuth
- [ ] Claude can access repository data
- [ ] Tested with an issue or PR query

---

## Chapter 3: Creating GitHub Actions

**Chapter ID**: `5.3-github-actions`

### Content

#### Basic Claude Review Action

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
            --print \
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

1. Go to Repository → Settings → Secrets → Actions
2. Click "New repository secret"
3. Name: `ANTHROPIC_API_KEY`
4. Value: Your Anthropic API key

#### Role-Specific Workflow Ideas

| Role | Workflow Idea |
|------|--------------|
| Frontend | Review component accessibility, check bundle size |
| Backend | Review API changes for breaking changes, security scan |
| QA | Generate missing test cases, check coverage |
| DevOps | Validate infrastructure changes, security audit |
| Data | Validate schema changes, check data quality rules |

### Verification

```yaml
chapter: 5.3-github-actions
type: automated
verification:
  checks:
    - file_exists: ".github/workflows/claude-review.yml"
      contains: "claude"
      task_key: create_github_action
```

### Checklist

- [ ] Created `.github/workflows/` directory
- [ ] Created Claude review workflow file
- [ ] Added ANTHROPIC_API_KEY to repository secrets
- [ ] Workflow syntax is valid YAML

---

## Chapter 4: Headless Mode

**Chapter ID**: `5.4-headless-mode`

### Content

#### What is Headless Mode?

Headless mode runs Claude **non-interactively**, outputting results and exiting. Perfect for scripts and CI/CD.

#### Key Flags

| Flag | Purpose |
|------|---------|
| `--print` / `-p` | Output result and exit |
| `--output-format json` | Machine-parseable output |
| `--max-turns N` | Limit execution turns |
| `--model NAME` | Specify model to use |

#### Basic Headless Usage

```bash
# Simple query
claude -p "What files are in src/?" --print

# With turn limit
claude -p "Fix all lint errors" --print --max-turns 10

# JSON output for parsing
claude -p "List all TODO comments" --print --output-format json
```

#### Scripting with Headless Mode

```bash
#!/bin/bash

# Run Claude and capture output
OUTPUT=$(claude -p "Summarize recent changes" --print)

# Use the output
echo "Summary: $OUTPUT"
```

### Verification

```yaml
chapter: 5.4-headless-mode
type: manual
verification:
  questions:
    - "Run a headless Claude command with --print"
    - "Capture the output in a variable"
    - "Verify output was returned correctly"
  task_key: test_headless
```

### Checklist

- [ ] Understand headless mode flags
- [ ] Ran Claude with `--print` flag
- [ ] Captured output in a script
- [ ] Know when to use `--max-turns`

---

## Chapter 5: Creating Automation Scripts

**Chapter ID**: `5.5-automation-scripts`

### Content

#### Script Location

Create scripts in: `scripts/`

#### Example: Lint Fix Script

Create `scripts/claude-lint-fix.sh`:

```bash
#!/bin/bash
# scripts/claude-lint-fix.sh
# Automatically fix linting errors using Claude

set -e

echo "🔍 Running Claude to fix lint errors..."

# Run Claude with bounded turns
claude -p "Find and fix all linting errors in the codebase.
Apply our coding standards from CLAUDE.md.
Commit each fix separately with descriptive messages." \
  --print \
  --max-turns 20 \
  > /tmp/claude-lint-output.txt

echo "✅ Claude completed lint fixes"
echo "📝 Output:"
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

echo "🔄 Preparing branch '$BRANCH' for PR..."

# Run tests
echo "🧪 Running tests..."
npm test

# Run linting
echo "📝 Running linter..."
npm run lint

# Generate PR description
echo "📋 Generating PR description..."
PR_DESC=$(claude -p "Generate a PR description for this branch.
Include:
- Summary of changes
- List of files modified
- Testing notes
- Any breaking changes

Format as markdown." --print --max-turns 3)

echo "✅ Branch ready for PR"
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

echo "🔍 Reviewing: $TARGET"

claude -p "Review the code in '$TARGET' for:
- Code quality issues
- Potential bugs
- Performance concerns
- Security vulnerabilities

Provide specific file:line references for each issue." \
  --print \
  --max-turns 10
```

#### Making Scripts Executable

```bash
chmod +x scripts/claude-*.sh
```

### Verification

```yaml
chapter: 5.5-automation-scripts
type: automated
verification:
  checks:
    - file_pattern: "scripts/claude-*.sh"
      min_count: 1
      task_key: create_automation_script
    - file_executable: "scripts/claude-*.sh"
      task_key: script_executable
```

### Checklist

- [ ] Created `scripts/` directory
- [ ] Created at least one automation script
- [ ] Script uses headless mode correctly
- [ ] Script is executable (`chmod +x`)
- [ ] Tested script works

---

## Chapter 6: Testing Workflows

**Chapter ID**: `5.6-testing-workflows`

### Content

#### Testing GitHub Actions Locally

Use [act](https://github.com/nektos/act) to test locally:

```bash
# Install act
brew install act

# Run workflow locally
act pull_request -s ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
```

#### Testing on Real PR

1. Create a test branch:
   ```bash
   git checkout -b test-claude-workflow
   echo "// test change" >> src/index.ts
   git add .
   git commit -m "Test Claude workflow"
   git push -u origin test-claude-workflow
   ```

2. Create a PR on GitHub

3. Watch the Actions tab for workflow execution

4. Verify Claude's review comment appears

#### Testing Automation Scripts

```bash
# Test lint fix script
./scripts/claude-lint-fix.sh

# Test PR prep script
./scripts/claude-pr-prep.sh

# Test review script on specific directory
./scripts/claude-review.sh src/components/
```

### Verification

```yaml
chapter: 5.6-testing-workflows
type: manual
verification:
  questions:
    - "Test at least one GitHub Action (local or on PR)"
    - "Test at least one automation script"
    - "Verify workflows complete successfully"
  task_key: test_workflow
```

### Checklist

- [ ] Tested GitHub Action (locally or on real PR)
- [ ] Action completed without errors
- [ ] Tested automation script
- [ ] Script produced expected output

---

## Chapter 7: Production Patterns

**Chapter ID**: `5.7-production-patterns`

### Content

#### Pattern: Continuous Review Agent

```
PR Opened
    │
    ▼
┌──────────────┐
│ Review Agent │──→ Posts review comments
└──────────────┘
    │
    ▼ (if issues found)
┌──────────────┐
│  Fix Agent   │──→ Pushes fix commits
└──────────────┘
    │
    ▼
┌──────────────┐
│  Test Agent  │──→ Runs tests, reports status
└──────────────┘
```

#### Pattern: Issue Triage

```
Issue Created
    │
    ▼
┌──────────────┐
│ Triage Agent │──→ Labels, assigns, estimates
└──────────────┘
    │
    ▼
┌────────────────────┐
│ Suggestion Agent   │──→ Creates draft PR with fix
└────────────────────┘
```

#### Production Best Practices

| Practice | Why |
|----------|-----|
| Set `--max-turns` | Prevent runaway costs |
| Log agent actions | Audit trail for debugging |
| Human-in-the-loop | Final approval before merge |
| Rate limiting | Control API costs |
| Error handling | Graceful failure recovery |

#### Cost Management

```yaml
# In workflow, add cost tracking
- name: Check Token Usage
  run: |
    claude -p "Report your token usage" --print
```

### Verification

```yaml
chapter: 5.7-production-patterns
type: conceptual
verification: manual
question: "Describe two production patterns for Claude automation"
```

### Checklist

- [ ] Understand continuous review pattern
- [ ] Understand issue triage pattern
- [ ] Know production best practices
- [ ] Considered cost management

---

## Chapter 8: Documenting Workflows

**Chapter ID**: `5.8-documenting`

### Content

#### Add to CLAUDE.md

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

### GitHub App Capabilities

- Issue queries: Enabled
- PR comments: Enabled
- Code suggestions: Enabled
```

### Verification

```yaml
chapter: 5.8-documenting
type: automated
verification:
  checks:
    - file_contains: "CLAUDE.md"
      pattern: "Automated Workflows|CI/CD|Workflow"
      task_key: document_workflows
```

### Checklist

- [ ] Added automated workflows section to CLAUDE.md
- [ ] Documented all GitHub Actions
- [ ] Documented all utility scripts
- [ ] Included usage instructions

---

## Chapter 9: Final Commit

**Chapter ID**: `5.9-commit`

### Content

#### What to Commit

```
your-repo/
├── CLAUDE.md                           # Updated with workflow docs
├── .github/
│   └── workflows/
│       └── claude-review.yml           # GitHub Action
└── scripts/
    ├── claude-lint-fix.sh              # Automation script
    ├── claude-pr-prep.sh               # Automation script
    └── claude-review.sh                # Automation script
```

#### Final Commit

```bash
git add CLAUDE.md .github/workflows/ scripts/
git commit -m "Add Claude Code CI/CD integration

- Add PR review GitHub Action
- Add automation scripts for lint, PR prep, review
- Document all workflows in CLAUDE.md"
```

#### Push to Remote

```bash
git push origin main
```

### Verification

```yaml
chapter: 5.9-commit
type: automated
verification:
  checks:
    - git_pushed: "origin/main"
      task_key: final_commit
```

### Checklist

- [ ] All workflow files committed
- [ ] All scripts committed
- [ ] Updated CLAUDE.md committed
- [ ] Changes pushed to remote

---

## Course Completion

### What You've Built

Throughout this course, you've created:

```
your-repo/
├── CLAUDE.md                     # Project memory with full documentation
├── .claude/
│   ├── settings.json             # Hooks configuration
│   ├── mcp.json                  # MCP server configuration
│   ├── commands/                 # Custom slash commands
│   └── skills/                   # Team skills and standards
├── .github/
│   └── workflows/
│       └── claude-*.yml          # CI/CD workflows
└── scripts/
    └── claude-*.sh               # Automation scripts
```

### Skills Demonstrated

- [ ] Install and configure Claude Code
- [ ] Create and maintain CLAUDE.md
- [ ] Use slash commands and CLI flags effectively
- [ ] Create custom skills and commands
- [ ] Configure hooks and MCP servers
- [ ] Orchestrate multi-agent workflows
- [ ] Set up CI/CD with Claude
- [ ] Run headless automation

### Next Steps

1. **Iterate**: Refine your setup based on daily use
2. **Share**: Help teammates adopt Claude Code
3. **Extend**: Add more skills and automations
4. **Contribute**: Share improvements with the community

---

## Validation Summary

```yaml
seminar: 5-workflows
tasks:
  install_github_app:
    chapter: 5.2
    type: manual
    check: "student_confirms"

  create_github_action:
    chapter: 5.3
    type: automated
    check: "file_exists:.github/workflows/claude-*.yml"

  test_headless:
    chapter: 5.4
    type: manual
    check: "student_confirms"

  create_automation_script:
    chapter: 5.5
    type: automated
    check: "glob:scripts/claude-*.sh"

  test_workflow:
    chapter: 5.6
    type: manual
    check: "student_confirms"

  document_workflows:
    chapter: 5.8
    type: automated
    check: "file_contains:CLAUDE.md:Automated Workflows"

  final_commit:
    chapter: 5.9
    type: automated
    check: "git_remote:origin"
```

---

## Course Validation Summary

```yaml
course: claude-code-developer-course
seminars:
  1-foundations-and-commands:
    tasks: 10
    required_for_completion: all

  2-skills:
    tasks: 5
    required_for_completion: all

  3-extensions:
    tasks: 6
    required_for_completion: all

  4-agents:
    tasks: 6
    required_for_completion: all

  5-workflows:
    tasks: 7
    required_for_completion: all

graduation:
  requires: all_seminars_complete
  generates: completion_certificate
```

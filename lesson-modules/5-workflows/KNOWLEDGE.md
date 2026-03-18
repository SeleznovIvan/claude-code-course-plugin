# Seminar 5: Workflows — Knowledge Base

## How to Use This File

This file complements `SCRIPT.md` with:
- **Deep dive explanations** — detailed background on each topic
- **External resources** — curated links to official docs and community content
- **Links verified** as of March 2026

**Separation of concerns:**
- `SCRIPT.md` = Teaching flow, validations, checklists (instructor guide)
- `KNOWLEDGE.md` = Deep content, external links, conceptual foundations (knowledge base)

---

## Chapter 5.1: CI/CD with Claude Overview

### Deep Dive

#### CI/CD Fundamentals and Where Claude Fits

Continuous Integration and Continuous Deployment (CI/CD) automate the build-test-deploy lifecycle. Claude Code integrates into this lifecycle not as a replacement for existing tools but as an **intelligent layer** that handles tasks traditionally requiring human judgment: code review, issue triage, code fixes, and documentation generation.

The key insight is that Claude operates as a reasoning agent, not a deterministic linter or formatter. Where traditional CI tools check for known patterns (syntax errors, style violations, dependency vulnerabilities), Claude can evaluate code for **semantic quality** — logic errors, architectural drift, missing edge cases, unclear naming, and security patterns that require understanding intent.

```
Traditional CI/CD Pipeline:
  Push → Build → Lint → Test → [HUMAN REVIEW] → Merge → Deploy

Claude-Enhanced Pipeline:
  Push → Build → Lint → Test → [CLAUDE REVIEW] → Human Approval → Merge → Deploy
```

Claude does not eliminate human review — it accelerates it. A reviewer who receives a PR with Claude's analysis already attached can focus on architectural decisions and business logic rather than catching typos and missing null checks.

#### What Claude Can Do in CI/CD

| Capability | Description | Example Trigger |
|------------|-------------|-----------------|
| **PR Reviews** | Automated code review on pull requests | `pull_request: [opened, synchronize]` |
| **Issue Triage** | Label, assign, and prioritize issues | `issues: [opened]` |
| **Code Fixes** | Suggest or apply fixes automatically | `push` to specific branches |
| **Documentation** | Generate or update docs from code | `pull_request: [closed]` when merged |
| **Security Scans** | Analyze code for security vulnerabilities | `schedule` (nightly) or `push` |
| **Changelog Generation** | Summarize changes between releases | `release: [created]` |
| **Test Generation** | Write missing test cases for changed code | `pull_request` with coverage drop |

#### Three Integration Methods

Claude Code provides three distinct methods for integrating with your development workflow:

**1. Headless CLI (`claude -p`)** — Runs Claude non-interactively from the command line. You pass a prompt, Claude processes it using its full tool set, and the result is printed to stdout. This is the foundation for all automation — scripts, cron jobs, and custom CI steps.

**2. GitHub Actions** — Event-driven workflows that run on GitHub's infrastructure. By installing Claude Code in a workflow step and providing an API key via secrets, you can trigger Claude analysis on any GitHub event.

**3. GitHub MCP** — Gives Claude interactive access to GitHub APIs during a live session. Unlike the other two methods, this runs within a Claude Code session where you are actively working.

#### Method Comparison

| Method | Best For | Requires | Runs | Interactive? |
|--------|----------|----------|------|-------------|
| Headless CLI | Scripts, cron jobs, local automation | API key | Locally or in CI | No |
| GitHub Actions | PR reviews, CI checks, automated fixes | API key in secrets | GitHub runners | No |
| GitHub MCP | Interactive issue/PR work in sessions | MCP config + token | In Claude session | Yes |

#### Security Considerations for CI/CD with AI

**API Key Management:** Never hardcode API keys in workflow files or scripts. Use GitHub Secrets for Actions, environment variables for local scripts. Rotate keys regularly; use separate keys for CI vs development.

**Output Sanitization:** Claude's output may contain sensitive data from your codebase. PR comments are visible to anyone with repository access. Sanitize or redact secrets, internal URLs, and PII before posting.

**Scope Limitation:** Use `--max-turns` to cap execution time and cost. Use `--allowedTools` to restrict what Claude can do in CI (e.g., read-only for reviews). Use `paths` filters in workflow triggers to limit which file changes trigger Claude.

#### Cost Management Strategies

| Strategy | Implementation | Impact |
|----------|---------------|--------|
| `--max-turns` limit | Add to every `claude -p` call | Caps per-invocation cost |
| Conditional triggers | Use `paths`, `if`, branch filters | Reduces total invocations |
| Draft PR skip | `if: github.event.pull_request.draft == false` | Avoids reviewing WIP |
| File-change filters | `paths: ['src/**', '!*.md']` | Skips irrelevant changes |
| Model selection | Use `--model claude-sonnet-4-6` for routine tasks | Lower per-token cost |

### External Resources

- **[Claude Code CLI Usage](https://docs.anthropic.com/en/docs/claude-code/cli-usage)** — Official reference for all CLI flags and modes
- **[GitHub Actions Documentation](https://docs.github.com/en/actions)** — Complete GitHub Actions reference
- **[Claude Code GitHub Action](https://github.com/anthropic-ai/claude-code-action)** — Anthropic's official pre-built GitHub Action

---

## Chapter 5.2: GitHub Integration Setup

### Deep Dive

#### GitHub MCP Server

The GitHub MCP server provides Claude with programmatic access to GitHub's APIs during interactive sessions. Once configured, Claude can create issues, read pull requests, post comments, manage labels, and interact with repository data.

**Available GitHub MCP tools:**

| Tool | Description |
|------|-------------|
| `create_issue` | Create a new issue with title, body, labels, assignees |
| `list_issues` | List issues with filters (state, labels, assignee) |
| `create_pull_request` | Create a PR from a branch |
| `get_pull_request` | Get PR details including diff |
| `create_review` | Post a code review on a PR |
| `get_file_contents` | Read a file from the repository at a specific ref |
| `search_code` | Search for code patterns across the repository |

#### GitHub MCP Authentication

**Fine-grained Personal Access Token (Recommended):**
- Generate at: Settings > Developer settings > Personal access tokens > Fine-grained tokens
- Select specific repositories rather than all repositories
- Grant only needed permissions: Contents (read/write), Issues (read/write), Pull requests (read/write)
- Shorter expiration for better security

**Rate Limits:** Authenticated requests: 5,000/hour. Search API: 30/minute. Claude's typical session uses 10-50 API calls — well within limits.

#### GitHub MCP Configuration

Add the GitHub MCP server to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "<your-fine-grained-pat>"
      }
    }
  }
}
```

Once configured, Claude can use GitHub tools in any session started from the project directory. You do not need to restart Claude — the MCP server is loaded automatically on session start.

#### The `@anthropic-ai/claude-code-action` GitHub Action

Anthropic provides an official pre-built GitHub Action that handles setup, execution, and result posting automatically.

**Configuration options:**

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `anthropic_api_key` | Yes | — | Anthropic API key for authentication |
| `prompt` | Yes | — | The prompt to send to Claude |
| `model` | No | `claude-sonnet-4-6` | Model to use |
| `max_turns` | No | `5` | Maximum agentic turns |
| `allowed_tools` | No | All | Comma-separated list of allowed tools |
| `post_comment` | No | `true` | Post result as PR comment |

**Comparison with custom `claude -p` actions:**

| Aspect | `claude-code-action` | Custom `claude -p` |
|--------|---------------------|--------------------|
| Setup complexity | One step | Multiple steps (checkout, node, install, run) |
| PR context | Automatically included | Must manually provide |
| Comment posting | Built-in | Requires `actions/github-script` |
| Customization | Limited to inputs | Full control over prompt and processing |

**When to use `claude-code-action`:** Simple PR review workflows with minimal configuration. **When to use custom `claude -p`:** Complex pipelines where you need to process output, chain multiple Claude calls, or integrate with other tools.

#### Token and Secret Management

**GitHub Secrets hierarchy:**
- **Repository secrets**: Available to all workflows in the repository
- **Environment secrets**: Available only to workflows targeting a specific environment
- **Organization secrets**: Shared across repositories in an organization

**Best practices:** Use repository secrets for API keys. Never log secrets. Use separate API keys for CI (with usage limits) and development. Rotate API keys quarterly.

#### Repository Permission Requirements

```yaml
permissions:
  contents: read          # Read repository files
  pull-requests: write    # Post PR comments
  issues: write           # Create/edit issues
  checks: write           # Create check annotations
```

**Principle of least privilege**: Only grant the permissions your workflow actually needs.

### External Resources

- **[Claude Code GitHub Action](https://github.com/anthropic-ai/claude-code-action)** — Official pre-built action with usage examples
- **[GitHub MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)** — MCP server providing GitHub API access
- **[GitHub Actions: Using Secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)** — Official guide on secret management

---

## Chapter 5.3: Headless Mode

### Deep Dive

#### What Headless Mode Is

Headless mode (`claude -p`) runs Claude Code non-interactively. You provide a prompt, Claude executes it using its full agent loop (reading files, writing code, running commands), and the result is output to stdout. There is no interactive TUI, no permission prompts — Claude runs autonomously until it completes the task or reaches the turn limit. This is the building block for all Claude Code automation.

#### Complete CLI Flag Reference

| Flag | Description | Example |
|------|-------------|---------|
| `-p, --prompt <prompt>` | Run non-interactively with the given prompt | `claude -p "fix lint errors"` |
| `--output-format <fmt>` | Output format: `text`, `json`, `stream-json` | `--output-format json` |
| `--max-turns <N>` | Limit the number of agentic turns | `--max-turns 10` |
| `--allowedTools <tools>` | Comma-separated list of allowed tools | `--allowedTools Read,Glob,Grep` |
| `--model <model>` | Override the default model | `--model claude-sonnet-4-6` |
| `-c, --continue` | Continue the most recent session | `claude -p -c "now fix the tests"` |
| `--resume <session>` | Resume a specific session by ID | `--resume abc123def` |
| `--verbose` | Enable verbose output (debugging) | `claude -p --verbose "..."` |

#### Output Format Details

- **`text` (default)** — Human-readable text output, stripped of tool call details. Best for human consumption and simple scripts.
- **`json`** — Structured JSON with `result`, `session_id`, `cost_usd`, `input_tokens`, `output_tokens`, `duration_ms`, and `num_turns`. Best for machine processing and cost tracking.
- **`stream-json`** — Streaming JSON events emitted in real time. Each line is a separate JSON object (`system`, `tool_use`, `tool_result`, `text`, `done`). Best for real-time progress monitoring and audit logging.

#### Piping Patterns

```bash
# stdin — Feed data to Claude
cat error.log | claude -p "Analyze these errors and suggest fixes"
git diff HEAD~3 | claude -p "Summarize these changes for a changelog entry"

# stdout — Capture output
REVIEW=$(claude -p "Review src/auth.ts for security issues" --max-turns 5)
claude -p "List all TODOs as JSON" --output-format json | jq '.result'

# stderr — Error handling (warnings go to stderr, results to stdout)
claude -p "fix all bugs" --max-turns 5 > result.txt 2> errors.txt
```

#### Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| `0` | Success — Claude completed the task |
| `1` | General error — Claude failed or encountered an error |
| `2` | Invalid arguments — bad flags or missing required parameters |

#### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_API_KEY` | API key for authentication | Required |
| `CLAUDE_MODEL` | Default model override | `claude-sonnet-4-6` |
| `CLAUDE_MAX_TURNS` | Default turn limit | Unlimited |
| `CLAUDE_CODE_USE_BEDROCK` | Use AWS Bedrock as provider | `0` |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex as provider | `0` |

#### Multi-Turn Headless Execution

Headless mode runs Claude in a full agentic loop — Claude reads files, writes code, runs tests, and iterates until complete or it reaches `--max-turns`. Each turn is one cycle of reasoning + tool use. Complex tasks like "fix all lint errors" might need 15-20 turns; simple queries need 1-2.

**Session continuation**: By default, each `claude -p` starts fresh. To continue a previous session:

```bash
# First invocation — capture session ID
claude -p "Find all security vulnerabilities in src/" --output-format json > first.json
SESSION_ID=$(jq -r '.session_id' first.json)

# Continue the same session
claude -p --resume "$SESSION_ID" "Now fix the top 3 most critical issues you found"
```

#### Typical Costs Per Invocation

| Task Type | Turns | Approximate Cost |
|-----------|-------|-----------------|
| Simple query | 1-2 | $0.01-0.03 |
| Code review (single file) | 3-5 | $0.05-0.15 |
| Lint fix (small project) | 5-15 | $0.10-0.50 |
| Full PR review | 5-10 | $0.10-0.30 |
| Codebase audit | 10-25 | $0.30-1.00 |

### External Resources

- **[Claude Code CLI Usage](https://docs.anthropic.com/en/docs/claude-code/cli-usage)** — Complete CLI flag reference and usage patterns
- **[Claude Code SDK](https://docs.anthropic.com/en/docs/agents/claude-code-sdk)** — Programmatic access for advanced automation

---

## Chapter 5.4: Creating GitHub Actions

### Deep Dive

#### GitHub Actions Fundamentals

A GitHub Action workflow is a YAML file in `.github/workflows/` that defines automated tasks triggered by repository events. Each workflow contains **events** (`on:`), **jobs** (`jobs:`), **steps** (`steps:`), and **runners** (`runs-on:`).

#### Production-Ready Claude Review Workflow

```yaml
name: Claude Code Review
on:
  pull_request:
    types: [opened, synchronize]
    paths: ['src/**', 'lib/**', '!**/*.md']

concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  review:
    if: github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - uses: actions/cache@v4
        with:
          path: ~/.npm
          key: ${{ runner.os }}-npm-claude-code
      - run: npm install -g @anthropic-ai/claude-code
      - name: Run Claude Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude -p "Review the changes in this PR. Focus on bugs, security, and missing tests.
          Format as markdown. Only mention issues you find." \
            --max-turns 5 > review.md
      - name: Post Review Comment
        if: success()
        uses: actions/github-script@v7
        with:
          script: |
            const review = require('fs').readFileSync('review.md', 'utf8');
            if (review.trim().length > 0) {
              await github.rest.issues.createComment({
                owner: context.repo.owner, repo: context.repo.repo,
                issue_number: context.issue.number,
                body: `## Claude Code Review\n\n${review}\n\n---\n_Automated review_`
              });
            }
```

**Key design decisions:** `fetch-depth: 0` for full git history; `concurrency` with `cancel-in-progress` to avoid stale reviews; draft PR skip for cost savings; `paths` filter to skip documentation-only changes; `timeout-minutes` as a hard cap.

#### Workflow Trigger Patterns

**Issue Triage** — Classify and label new issues:
```yaml
on:
  issues:
    types: [opened]
```

**Scheduled Audit** — Weekly security scan:
```yaml
on:
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM UTC
```

**Manual Dispatch** — On-demand with custom inputs:
```yaml
on:
  workflow_dispatch:
    inputs:
      task:
        description: 'What should Claude do?'
        required: true
        type: string
```

#### Posting Results

**As PR comments** — via `actions/github-script@v7` calling `github.rest.issues.createComment`. **As check annotations** — via `github.rest.checks.create` with inline annotations on specific lines. **As artifacts** — via `actions/upload-artifact@v4` for downloadable reports.

#### Cost Optimization in Actions

| Strategy | Implementation | Savings |
|----------|---------------|---------|
| Path filters | `paths: ['src/**']` | Skip docs-only changes |
| Draft PR skip | `if: !github.event.pull_request.draft` | Skip WIP PRs |
| Concurrency | `cancel-in-progress: true` | Cancel stale reviews |
| Turn limits | `--max-turns 5` | Cap per-invocation cost |
| Changed-files only | Pipe `git diff --name-only` to Claude | Smaller context |

### External Resources

- **[GitHub Actions Documentation](https://docs.github.com/en/actions)** — Complete reference for workflows
- **[Claude Code GitHub Action](https://github.com/anthropic-ai/claude-code-action)** — Anthropic's official pre-built action
- **[GitHub Actions: Events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)** — Full list of trigger events

---

## Chapter 5.5: Creating Automation Scripts

### Deep Dive

#### Script Design Patterns

**1. Guard Pattern** — Check preconditions before running Claude:
```bash
#!/bin/bash
set -euo pipefail
git rev-parse --is-inside-work-tree &>/dev/null || { echo "Not in a git repo" >&2; exit 1; }
[ -n "${ANTHROPIC_API_KEY:-}" ] || { echo "ANTHROPIC_API_KEY not set" >&2; exit 1; }
claude -p "..." --max-turns 10
```

**2. Capture Pattern** — Run Claude, capture output, process results:
```bash
OUTPUT=$(claude -p "Analyze src/ for code smells" --max-turns 5 --output-format json)
RESULT=$(echo "$OUTPUT" | jq -r '.result')
COST=$(echo "$OUTPUT" | jq -r '.cost_usd')
echo "Analysis complete (cost: \$$COST)"
echo "$RESULT" > analysis-report.md
```

**3. Pipeline Pattern** — Chain multiple Claude calls:
```bash
ISSUES=$(claude -p "List all TODO comments as JSON" --max-turns 5 --output-format json | jq -r '.result')
echo "$ISSUES" | claude -p "Prioritize these issues by severity. Return the top 5." --max-turns 3
```

**4. Report Pattern** — Generate structured reports:
```bash
DATE=$(date +%Y-%m-%d)
mkdir -p reports
claude -p "Generate a weekly code quality report. Include: statistics, trends, debt, recommendations." \
  --max-turns 10 > "reports/quality-report-$DATE.md"
```

#### Bash Best Practices for Claude Scripts

- **`set -euo pipefail`** — Exit on error, treat unset variables as errors, fail pipelines on any error
- **`trap "rm -rf $TEMP_DIR" EXIT`** — Clean up temporary files on exit
- **Proper quoting** — Always quote prompts and variables: `claude -p "Review '$FILE'"`
- **Timeout handling** — `timeout 300 claude -p "..." --max-turns 10` to add hard time limits
- **Heredocs for complex prompts** — Use `$(cat <<EOF ... EOF)` for multi-line prompts

#### Script Parameterization

```bash
#!/bin/bash
set -euo pipefail
TARGET="${1:-.}"              # First arg or current directory
MAX_TURNS="${2:-10}"          # Second arg or 10
[[ "${1:-}" == "--help" ]] && { echo "Usage: $0 [path] [max_turns]"; exit 0; }
claude -p "Review the code in '$TARGET'" --max-turns "$MAX_TURNS"
```

#### Combining Scripts with Git Hooks

**Pre-commit** — lint check on staged files:
```bash
#!/bin/bash
# .git/hooks/pre-commit
STAGED=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|js|py)$' || true)
[ -z "$STAGED" ] && exit 0
echo "$STAGED" | claude -p "Check these staged files for critical issues" --max-turns 3
```

**Pre-push** — quick security scan:
```bash
#!/bin/bash
# .git/hooks/pre-push
timeout 60 claude -p "Quick security scan. Check for hardcoded secrets, injection." --max-turns 5 || true
```

#### Cron Job Integration

```bash
# crontab -e
0 2 * * * cd /path/to/repo && ./scripts/claude-security-audit.sh >> /var/log/claude-audit.log 2>&1
0 8 * * 1 cd /path/to/repo && ./scripts/claude-quality-report.sh >> /var/log/claude-report.log 2>&1
```

Cron runs in a minimal environment — set `ANTHROPIC_API_KEY` explicitly, use absolute paths, redirect output to log files, and use `timeout` to prevent hung jobs.

#### Script Testing Strategies

- **Dry-run mode**: `DRY_RUN=true ./scripts/claude-review.sh` — print commands instead of executing
- **Verbose mode**: `set -x` to print every command before execution
- **Mock testing**: Create a mock `claude` script that returns canned responses for testing script logic without API calls

### External Resources

- **[Claude Code CLI Usage](https://docs.anthropic.com/en/docs/claude-code/cli-usage)** — Complete CLI reference for headless mode flags
- **[Git Hooks Documentation](https://git-scm.com/docs/githooks)** — Official git hooks reference

---

## Chapter 5.6: Testing and Production Patterns

### Deep Dive

#### Testing Methodology for AI-Powered Workflows

AI-powered workflows require a different testing approach than deterministic pipelines. Claude's output varies between runs — the same prompt on the same codebase might produce different wording, different orderings, or surface different issues. Tests must verify **behavior and structure** rather than exact output: did Claude produce a review? Does the output contain expected sections? Did the script handle errors correctly?

| Tier | What It Tests | How | Cost |
|------|--------------|-----|------|
| Unit | Script logic without calling Claude | Mock `claude` command | Free |
| Integration | Claude invocation on test data | `--max-turns 2` on small files | Low |
| End-to-end | Full workflow trigger-to-output | Trigger on test PR/issue | Medium |

#### `act` for Local GitHub Action Testing

[`act`](https://github.com/nektos/act) runs GitHub Actions locally using Docker:

```bash
brew install act
act pull_request -s ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"  # Run PR workflow
act pull_request -n                                          # Dry run
```

**Limitations**: Does not perfectly replicate GitHub runners; `github` context may be incomplete; `actions/github-script` steps that post comments will fail locally. Add `if: ${{ !env.ACT }}` to skip GitHub API calls during local testing.

#### Production Deployment Checklist

- [ ] All scripts tested locally with real Claude invocations
- [ ] API keys stored in GitHub Secrets (never hardcoded)
- [ ] `--max-turns` set on every `claude -p` call
- [ ] Error handling in all scripts (`set -euo pipefail`)
- [ ] Timeout set on workflow jobs (`timeout-minutes`)
- [ ] Cost budget defined and monitoring configured
- [ ] Human-in-the-loop for destructive actions
- [ ] Path filters to reduce unnecessary triggers
- [ ] Concurrency groups to prevent duplicate runs
- [ ] Workflow permissions follow principle of least privilege

#### Error Recovery Patterns

**Retry with backoff:**
```bash
for i in 1 2 3; do
  claude -p "..." --max-turns 5 > output.txt && break
  [ $i -eq 3 ] && { echo "Failed after 3 attempts" >&2; exit 1; }
  sleep $((5 * i))
done
```

**Graceful degradation:**
```bash
if ! REVIEW=$(claude -p "Review this PR" --max-turns 5 2>/dev/null); then
  REVIEW="Automated review unavailable. Please review manually."
fi
```

#### Production Pattern Deep Dives

**Continuous Review Agent:**
```
PR Opened → Diff Analysis → Claude Review (--max-turns 5) → Post Comment
    └── If critical issues → Claude Fix Agent (--max-turns 10) → Push fix commit → Re-review
```

**Issue Triage Bot:**
```
Issue Created → Extract title+body → Claude Classification (--max-turns 3)
    → Parse JSON → Apply labels → Assign → Post summary comment
```

**Scheduled Auditor:**
```
Cron (weekly) → Full checkout → Claude Security Scan (--max-turns 15)
    → Compare with previous scan → Create issues for new findings → Update audit log
```

#### Cost Monitoring

| Method | Description | Setup |
|--------|-------------|-------|
| Anthropic Dashboard | View usage by API key | Automatic with any API key |
| JSON output parsing | Track `cost_usd` from each invocation | `--output-format json \| jq '.cost_usd'` |
| Billing alerts | Get notified at spending thresholds | Anthropic Console > Billing |
| CI cost tags | Tag invocations by workflow | Use different API keys per workflow |

A practical approach is to accumulate costs in a log file and alert when daily spending exceeds a threshold:

```bash
COST=$(claude -p "..." --output-format json | jq -r '.cost_usd')
echo "$COST" >> .claude-costs.log
DAILY=$(awk '{s+=$1} END {print s}' .claude-costs.log)
if (( $(echo "$DAILY > 5.00" | bc -l) )); then
  echo "WARNING: Daily Claude cost ($DAILY) exceeds $5.00 budget" >&2
fi
```

#### Audit Logging

Log every Claude CI invocation for compliance and debugging:

```bash
log_claude_run() {
  jq -n --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg trigger "$1" \
    --arg result "$(cat "$2")" --arg sha "$(git rev-parse HEAD)" \
    '{timestamp: $ts, trigger: $trigger, result: $result, git_sha: $sha}' \
    >> "logs/claude-ci-$(date +%Y%m%d).jsonl"
}
```

**What to log**: timestamp, trigger source (PR, cron, manual), prompt summary, result summary, git SHA, branch, cost. **Where to store**: JSONL files per day in a `logs/` directory, or ship to your observability platform. **Retention**: Keep at least 30 days for debugging; longer for compliance.

### External Resources

- **[`act` — Run GitHub Actions Locally](https://github.com/nektos/act)** — Local testing tool for GitHub Actions
- **[Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Official guidance on production usage patterns
- **[Anthropic Console](https://console.anthropic.com)** — Monitor API usage and costs

---

## Chapter 5.7: Documenting Workflows

### Deep Dive

#### Why Workflow Documentation Matters

AI-powered workflows are opaque by default. Unlike a linter that runs the same checks every time, Claude's analysis varies between runs. Documentation must capture the **intent**, **boundaries**, and **cost expectations** of each workflow so that team members can understand, maintain, and troubleshoot them.

#### CLAUDE.md Workflow Documentation Template

```markdown
## Automated Workflows

### CI/CD Integration
**PR Review** (`.github/workflows/claude-review.yml`)
- Triggered: On PR open/sync to `main`
- Scope: Reviews changed files in `src/` and `lib/`
- Max turns: 5 | Cost: ~$0.05-0.15 per review
- Skips: Draft PRs, documentation-only changes

### Utility Scripts
| Script | Purpose | Usage | Cost |
|--------|---------|-------|------|
| `scripts/claude-lint-fix.sh` | Fix lint errors | `./scripts/claude-lint-fix.sh` | ~$0.10-0.50 |
| `scripts/claude-pr-prep.sh` | Prepare branch for PR | `./scripts/claude-pr-prep.sh` | ~$0.05 |
| `scripts/claude-review.sh` | Review specific code | `./scripts/claude-review.sh [path]` | ~$0.10-0.30 |
```

#### Team Onboarding Guide

When introducing new team members to Claude workflows, provide a concise guide:

```markdown
## Getting Started with Claude Workflows

### What's Automated
- **PR reviews**: Every non-draft PR gets an automated Claude review comment.
  You don't need to do anything — it runs automatically.
- **Security scans**: Weekly audit creates issues for new findings.
  Check the "claude-security" label.

### Scripts You Can Run
- `./scripts/claude-review.sh src/components/` — Review a specific directory
- `./scripts/claude-lint-fix.sh` — Auto-fix lint errors
- `./scripts/claude-pr-prep.sh` — Generate a PR description

### Prerequisites
- `ANTHROPIC_API_KEY` set in your environment
- Claude Code installed: `npm install -g @anthropic-ai/claude-code`

### Cost Awareness
- Each script invocation costs $0.05-0.50 depending on scope
- Be mindful when running scripts on large directories
```

#### Runbook Format for Automation Scripts

Each script should have a companion runbook entry covering:

- **Purpose**: What the script does and when to use it
- **Prerequisites**: Environment variables, clean git state, dependencies
- **Usage**: Command with arguments and options
- **What it does**: Step-by-step description of the script's behavior
- **Expected output**: What success looks like
- **Troubleshooting**: Common failure modes and their solutions
- **Cost**: Expected cost range per invocation

#### Version Tracking

- Commit workflow files alongside the code they operate on
- Tag workflow changes in commit messages
- Review workflow changes in PRs — prompt changes affect review behavior for the entire team
- Document breaking changes and notify the team

### External Resources

- **[Claude Code Memory (CLAUDE.md)](https://docs.anthropic.com/en/docs/claude-code/memory)** — Official documentation on CLAUDE.md
- **[GitHub Actions: Sharing Workflows](https://docs.github.com/en/actions/sharing-automations/sharing-workflows-with-your-organization)** — Share workflows across repositories

---

## Chapter 5.8: Final Commit and Course Graduation

### Deep Dive

#### Complete Course Artifact Inventory

Over the course of all 5 modules, you have built a comprehensive Claude Code configuration:

```
your-repo/
├── CLAUDE.md                           # Modules 1-5: Project context, conventions, workflows
├── .claude/
│   ├── settings.json                   # Module 3: Hook configurations
│   ├── commands/                       # Module 1: Custom slash commands
│   │   └── *.md
│   └── skills/                         # Module 2: Team skills and standards
│       └── *.md
├── .mcp.json                           # Module 3+5: MCP server configurations
├── .github/
│   └── workflows/
│       └── claude-*.yml                # Module 5: CI/CD workflows
└── scripts/
    └── claude-*.sh                     # Module 5: Automation scripts
```

#### Skills Self-Assessment Checklist

**Module 1 — Foundations & Commands:**
- [ ] Create and maintain an effective CLAUDE.md
- [ ] Create custom slash commands
- [ ] Use essential CLI flags

**Module 2 — Skills:**
- [ ] Create skills that encode team standards
- [ ] Understand commands vs skills distinction
- [ ] Share skills via version control

**Module 3 — Extensions:**
- [ ] Configure hooks for PreToolUse and PostToolUse events
- [ ] Understand handler types (command, http, prompt, agent)
- [ ] Set up and configure MCP servers

**Module 4 — Agents:**
- [ ] Understand subagent architecture (isolation, context, tools)
- [ ] Orchestrate multi-agent workflows
- [ ] Use git worktrees for isolated agent work

**Module 5 — Workflows:**
- [ ] Create GitHub Actions that use Claude
- [ ] Run Claude in headless mode for scripting
- [ ] Build automation scripts for common tasks
- [ ] Document all workflows in CLAUDE.md
- [ ] Manage costs for CI/CD with Claude

#### What to Do After the Course

**Immediate next steps (week 1):**
- Use your Claude Code setup daily for real work
- Note friction points and adjust CLAUDE.md accordingly
- Refine skill prompts based on actual output quality
- Monitor CI workflow costs and adjust `--max-turns` as needed

**Short-term improvements (weeks 2-4):**
- Share your configuration with teammates
- Collect feedback on automated PR reviews
- Add more automation scripts for repetitive tasks
- Fine-tune hook configurations based on real usage patterns

**Medium-term growth (months 2-3):**
- Explore advanced features: custom MCP servers, plugin development
- Build team-specific skills for your domain
- Create reusable workflow templates for your organization
- Contribute to the Claude Code community

#### Community Contribution Paths

| Contribution | Where | Impact |
|-------------|-------|--------|
| Share skills | GitHub, team wiki | Help others adopt best practices |
| Build MCP servers | npm, GitHub | Extend Claude's capabilities |
| Create plugins | Plugin marketplace | Add features for all users |
| Workflow templates | GitHub Actions Marketplace | Reusable CI/CD patterns |

#### Advanced Topics for Continued Learning

**Custom MCP Servers:** Build servers in TypeScript, Python, or Go that expose domain-specific capabilities — database queries, internal API access, deployment triggers.

**Plugin Development:** Bundle skills, commands, MCP servers, and configuration into distributable packages. If you have built a useful configuration for your domain, packaging it as a plugin lets others install it with one command.

**Enterprise Configuration:** Organization-level CLAUDE.md, centralized hook policies, shared MCP server configurations, API key management through team accounts, usage monitoring and cost allocation per team.

### External Resources

- **[Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)** — Complete official documentation
- **[Claude Code SDK](https://docs.anthropic.com/en/docs/agents/claude-code-sdk)** — Build programmatic integrations
- **[MCP Specification](https://modelcontextprotocol.io)** — Build custom MCP servers
- **[Claude Code GitHub Action](https://github.com/anthropic-ai/claude-code-action)** — Official CI/CD integration
- **[Anthropic Cookbook](https://github.com/anthropics/anthropic-cookbook)** — Example implementations and patterns
- **[Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Official guidance for effective usage

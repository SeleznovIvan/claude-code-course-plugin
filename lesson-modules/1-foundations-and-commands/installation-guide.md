# Claude Code and Course Installation Guide

**Complete this guide before starting the interactive course.**

---

## Prerequisites

Before installing Claude Code, ensure you have:

- **Node.js 18+** installed
  ```bash
  node --version  # Should show v18.x.x or higher
  ```

- **npm** (comes with Node.js)
  ```bash
  npm --version
  ```

If you don't have Node.js, install it from [nodejs.org](https://nodejs.org/) or via your package manager:

```bash
# macOS (Homebrew)
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Windows (Chocolatey)
choco install nodejs
```

---

## Step 1: Install Claude Code

Run this command in your terminal:

```bash
npm install -g @anthropic-ai/claude-code
```

**Expected output:**
```
added 1 package in Xs
```

### Troubleshooting Installation

| Issue | Solution |
|-------|----------|
| Permission denied | Use `sudo npm install -g @anthropic-ai/claude-code` or fix npm permissions |
| Command not found | Ensure npm bin directory is in your PATH |
| Network error | Check your internet connection and proxy settings |

---

## Step 2: Verify Installation

Confirm Claude Code is installed:

```bash
claude --version
```

**Expected output:** Version number (e.g., `1.0.34`)

If the command is not found:
1. Close and reopen your terminal
2. Check your PATH includes npm global bin: `npm bin -g`
3. Add to PATH if needed: `export PATH="$PATH:$(npm bin -g)"`

---

## Step 3: First Launch & Authentication

Navigate to your project directory and start Claude Code:

```bash
cd /path/to/your/project
claude
```

### Authentication Flow

On first launch, Claude Code will:

1. **Open your browser** for authentication
2. **Prompt for authentication method:**
   - **Anthropic Console** (recommended) — Use your Anthropic account
   - **API Key** — Enter your API key directly

### Option A: Anthropic Console (OAuth)

1. Click "Log in with Anthropic"
2. Sign in to your Anthropic account (or create one)
3. Authorize Claude Code
4. Return to your terminal — you're authenticated!

### Option B: API Key

1. Get an API key from [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys)
2. When prompted, paste your API key
3. Claude Code stores it securely

---

## Step 4: Verify Authentication

Test that authentication works:

```bash
claude "Hello, can you hear me?"
```

**Expected:** Claude responds with a greeting.

If you see an error:
- Check your API key is valid
- Ensure you have credits in your Anthropic account
- Try re-authenticating: `claude auth logout` then `claude`

---

## Step 5: Run Doctor Check

Verify everything is working:

```bash
claude
/doctor
```

**Expected output:** All checks pass (green checkmarks).

---

## Step 6: Install the Course Plugin

This course is delivered as a Claude Code plugin. Install it from the course repository:

1. Visit [Claude Code Education](https://github.com/SeleznovIvan/claude-code-education) for the full course catalog
2. Install the plugin:
   ```bash
   claude plugin install github:SeleznovIvan/claude-code-course-plugin
   ```
3. Verify the plugin is installed:
   ```bash
   claude plugin list
   ```
   **Expected:** You should see `cc-course` in the list of installed plugins.

---

## You're Ready!

Once you can:
- ✅ Run `claude --version` and see a version number
- ✅ Start `claude` and get a response
- ✅ Run `/doctor` with all checks passing
- ✅ Course plugin installed

Navigate to your project folder, run the one-time setup, and start the course:

```bash
cd /path/to/your/project
claude

# Inside Claude Code:
/cc-course:setup       # One-time MCP server installation
/cc-course:start 1     # Start Module 1!
```

---

## After Course Completion

When you finish all modules:

1. Run `/cc-course:validate` to verify your work
2. Run `/cc-course:submit` to package your work into a zip archive
3. Send the zip archive to **Ivan** for review

The submission includes your configurations, progress data, and session logs.

---

## About This Course

This course teaches you Claude Code by having you **build real configurations in YOUR OWN repository**. Unlike tutorials with toy examples:

- Every task applies to your actual project
- Everything you create (CLAUDE.md, custom commands, skills, hooks) stays in your repo and you keep using it
- Claude teaches you inside Claude Code itself — you learn the tool by using the tool
- Guidance adapts to your role (frontend, backend, QA, DevOps, data)

By the end, your repository will have a complete Claude Code setup: project memory, custom commands, skills, hooks, MCP integrations, and CI/CD workflows.

---

## Getting Help

- **Installation issues:** Run `/doctor` inside Claude Code
- **Authentication issues:** Try `claude auth logout` then `claude` again
- **General help:** Visit [docs.anthropic.com](https://docs.anthropic.com)

---

*This guide is part of the Claude Code Developer Course.*

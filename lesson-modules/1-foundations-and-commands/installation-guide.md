# Claude Code Installation Guide

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

## Quick Reference Card

### Starting Claude Code

| Command | Description |
|---------|-------------|
| `claude` | Start interactive session |
| `claude "prompt"` | One-shot mode (run and exit) |
| `claude -p "prompt"` | Print mode (output only) |
| `claude -c` | Continue last conversation |

### Essential Commands (inside session)

| Command | Description |
|---------|-------------|
| `/help` | Show all available commands |
| `/doctor` | Diagnose installation issues |
| `/clear` | Reset conversation context |
| `exit` | End the session |

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current operation |
| `Ctrl+D` | Exit session |
| `Shift+Tab` | Enter plan mode |

---

## You're Ready!

Once you can:
- ✅ Run `claude --version` and see a version number
- ✅ Start `claude` and get a response
- ✅ Run `/doctor` with all checks passing

You're ready to start the interactive course:

```bash
claude
/cc-course:start 1
```

---

## Getting Help

- **Installation issues:** Run `/doctor` inside Claude Code
- **Authentication issues:** Try `claude auth logout` then `claude` again
- **General help:** Visit [docs.anthropic.com](https://docs.anthropic.com)

---

*This guide is part of the Claude Code Developer Course.*

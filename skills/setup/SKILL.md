---
name: cc-course:setup
description: Install and configure the cclogviewer MCP server required for session tracking
---

# Course Setup

This skill installs the cclogviewer MCP server required for session tracking.

## Execution Steps

When this skill is invoked, perform the following steps:

### Step 1: Check if cclogviewer-mcp is already installed

```bash
which cclogviewer-mcp
```

If found, skip to Step 3 (verification).

### Step 2: Run the installation script

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-mcp.sh"
```

If the script fails, provide manual installation instructions:

```
Manual installation options:

1. Download pre-built binary:
   curl -L https://github.com/SeleznovIvan/cclogviewer/releases/latest/download/cclogviewer-mcp-darwin-arm64 -o ~/.local/bin/cclogviewer-mcp
   chmod +x ~/.local/bin/cclogviewer-mcp

2. If you have Go 1.21+:
   go install github.com/SeleznovIvan/cclogviewer/cmd/cclogviewer-mcp@latest

3. Build from source (requires Go):
   cd ${CLAUDE_PLUGIN_ROOT}/mcp/cclogviewer
   make build-mcp
   cp bin/cclogviewer-mcp ~/.local/bin/
```

### Step 3: Verify installation

```bash
which cclogviewer-mcp
```

Test the MCP server responds to JSON-RPC:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | cclogviewer-mcp 2>/dev/null | head -c 200
```

### Step 4: Add MCP to Claude Code (if not already configured)

Check if cclogviewer is already in Claude's MCP list:

```bash
claude mcp list 2>/dev/null | grep -q cclogviewer
```

If not found, add it:

```bash
claude mcp add cclogviewer cclogviewer-mcp
```

### Step 5: Final verification

Verify MCP is configured:

```bash
claude mcp list
```

## Output Messages

### Success

```
✓ cclogviewer-mcp installed at /path/to/binary
✓ MCP server responds to JSON-RPC
✓ cclogviewer MCP configured in Claude Code

Setup complete! You're ready to start the course.
Run: /cc-course:start 1
```

### Partial Success (MCP works but not in Claude)

```
✓ cclogviewer-mcp installed at /path/to/binary
✓ MCP server responds to JSON-RPC
⚠ Could not automatically configure MCP in Claude Code

Please run manually:
  claude mcp add cclogviewer cclogviewer-mcp

Then run: /cc-course:start 1
```

### Failure

```
✗ Setup failed: {reason}

Manual installation required:

1. Download the binary for your platform:
   https://github.com/SeleznovIvan/cclogviewer/releases

2. Or install via Go (requires Go 1.21+):
   go install github.com/SeleznovIvan/cclogviewer/cmd/cclogviewer-mcp@latest

3. Add to Claude Code:
   claude mcp add cclogviewer cclogviewer-mcp

Then run: /cc-course:start 1
```

## PATH Note

If the binary is installed to `~/.local/bin` but not in PATH, remind the user:

```
Note: Add ~/.local/bin to your PATH by adding this to your shell profile:
  export PATH="$HOME/.local/bin:$PATH"

Then restart your terminal or run:
  source ~/.bashrc  # or ~/.zshrc
```

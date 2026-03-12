# Release

Commit all changes, bump the plugin version, and create a GitHub release.

## Input

`$ARGUMENTS` is an optional release description. If not provided, generate one from the commits since the last tag.

## Steps

1. **Check for changes** — run `git status`. If there are no staged or unstaged changes and no untracked files (excluding ignored), skip to step 4.

2. **Commit changes** — review all changes (staged, unstaged, untracked) and split them into logical commits following the project's commit message style. Use `git log --oneline -5` for style reference. Do NOT commit files that should be ignored (debug logs, credentials, etc).

3. **Push** — push all commits to the remote.

4. **Determine next version**:
   - Read the current version from `.claude-plugin/plugin.json` (field: `version`, format: `X.Y.Z-alpha`)
   - Bump the minor version (e.g., `0.11.0-alpha` → `0.12.0-alpha`)
   - The corresponding tag format is `vX.Y-alpha` (e.g., `v0.12-alpha`)

5. **Bump version in plugin.json** — update the `version` field.

6. **Commit and push the version bump**:
   ```
   Bump version to vX.Y-alpha
   ```

7. **Generate release notes**:
   - If `$ARGUMENTS` is provided, use it as the release description
   - Otherwise, collect commits since the last tag (`git log <last-tag>..HEAD --oneline`) and summarize them into a "What's New" section with bullet points grouped by theme

8. **Create GitHub release**:
   ```bash
   gh release create vX.Y-alpha --title "vX.Y-alpha" --notes "<release-notes>" --prerelease
   ```

9. **Output** the release URL.

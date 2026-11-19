# Progressive Agentic Coding - Portable Personal Workflow

A user-level, repo-independent toolkit for implementing with agents while understanding and reviewing the code in small, stable increments. One agent can keep building while another agent and the human review immutable checkpoints. The skills and rules are local/global; GitHub tracks shared task state.

## Contents
- `rules/progressive-agentic-coding.md` - reusable global rule (source of truth)
- `skills/progressive-build/SKILL.md` - incrementally implement, verify, checkpoint and hand off
- `skills/progressive-review/SKILL.md` - interactive, read-only comprehension of pinned commits
- `skills/open-review-worktree/SKILL.md` - detach a ready checkpoint in a sibling review worktree
- `skills/review-loop/SKILL.md` - open a ready checkpoint and walk it in chat, one decision at a time
- `skills/reconcile-feedback/SKILL.md` - address feedback on earlier checkpoints via new commits
- `templates/` - copy/paste GitHub issue, checkpoint and review templates
- `scripts/install.ps1` - Windows PowerShell installer (supports preview)
- `scripts/install.sh` - macOS/Linux/WSL installer (supports preview)
- `docs/workflow.md` - day-to-day operating procedure

## Quick setup (Windows)

1. Clone or copy this repository outside all application repositories.
2. In PowerShell, from that folder, run:

   `powershell -NoProfile -File .\scripts\install.ps1 -Agents all -WhatIf`

   Review the output, then run:

   `powershell -NoProfile -File .\scripts\install.ps1 -Agents all`

3. In **Cursor > Customize > Rules > User Rules**, paste the contents of `rules/progressive-agentic-coding.md` manually. Cursor's user rules are managed through its UI, not by our installer.
4. For Cursor Cloud Agents: **Settings > Agents > Context and Tools > Sync Skills for Cloud Agents**. Only `~/.cursor/skills/` is synced; `~/.agents/skills/` alone does **not** sync to Cursor Cloud Agents. Synced personal skills do not apply to Cursor Automations.
5. On a repo, ask your chosen builder: `Use progressive-build to implement <outcome>; publish review checkpoints in GitHub.` In a separate review workspace, ask: `Start the review loop on the latest ready checkpoint.`

## macOS, Linux, WSL

Run `bash scripts/install.sh --agents all --dry-run`, then `bash scripts/install.sh --agents all`. Native Windows and WSL have separate home directories; install in each environment that runs agents.

## Global installation targets

| Agent | Personal/global rules | Personal/global skills |
| --- | --- | --- |
| Cursor | Paste into Customize > Rules > User Rules | `~/.cursor/skills/` (for Cloud Agent sync) |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills/` |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` |
| OpenCode | `~/.config/opencode/AGENTS.md` | `~/.agents/skills/` |

The installers add a **marked section** to preexisting rules files rather than replacing the entire file. Existing skill directories are left in place unless you answer yes to the overwrite prompt, or pass `-Force` / `--force` to replace them without asking. Overwritten skill directories are backed up. Non-interactive runs skip existing directories unless force is passed. The installers do not make changes to application repositories, push code or contact any cloud service. They do not automatically configure Cursor's User Rules or Cloud Agent sync.

### Cross-tool duplicate discovery

A full install is visible more than once. Cursor loads `~/.cursor/skills/`, `~/.agents/skills/`, and `~/.claude/skills/`. OpenCode loads `~/.agents/skills/` and `~/.claude/skills/`, and prefers `~/.config/opencode/skills/` when that directory also has the same skill. Copies from this repository are identical at install time. If a tool lists duplicates, remove the extras and keep `~/.cursor/skills/` so Cursor Cloud sync still works. Install a subset with `-Agents cursor,claude` or `--agents cursor,claude`.

## What lives in GitHub?

Put checkpoint links, commit SHAs, discussions, status and feedback in GitHub issue/PR descriptions or comments. Do not rely on a vendor's chat history. Use `templates/task-state.md` as a GitHub issue description; repository documents are optional.

## Important caveats

- Cloud agents cannot automatically read all local files, even though they can read published GitHub task state. Configure cloud-specific skill sync as supported by the provider.
- Agent capabilities and required permissions vary. The rule requires authorization for Git pushes/PR creation; when those are unavailable, agents should provide a local checkpoint and a paste-ready summary.
- Personal rules may conflict with repository or organization instructions; respect higher-priority policies and explicit user directions.
- These are workflow instructions, **not** an orchestration daemon; they cannot run an agent in the background if that agent's environment does not support continued execution.

## Primary documentation

- Cursor skills: https://cursor.com/docs/skills
- Cursor rules: https://cursor.com/docs/rules
- Claude Code docs: https://code.claude.com/docs
- Codex skills: https://developers.openai.com/codex/skills
- OpenCode skills: https://opencode.ai/docs/skills
- OpenCode instructions: https://opencode.ai/docs/instructions

---
name: progressive-build
description: Implement a substantial coding outcome as a stream of small, tested, reviewable Git checkpoints. Use when the user asks for agentic implementation, iterative coding, incremental commits, ongoing development while review happens, or progressive agentic coding.
---

# Progressive Build

## Inputs
Desired outcome and acceptance criteria; repository and branch; permission for commits, pushes and PRs; relevant review feedback and current task-state/issue if available.

## Procedure
1. Inspect relevant code, existing tests, repository guidance, and current Git status. Do not overwrite unrelated changes.
2. Propose 2-6 *cohesive* increments covering behavior, tests and integration; state dependencies and any decisions needing approval. Re-plan when new evidence emerges.
3. For the next increment, define its observable behavior and verification. Implement it without mixing unrelated refactors.
4. Run the most relevant checks. Inspect the final diff. Report failures and remaining risks rather than claiming success without evidence.
5. If authorized and Git is available, commit with a meaningful message. Publish only if allowed. Record the immutable SHA with `git rev-parse HEAD`. If not authorized or available, create a clearly identified local checkpoint/diff instead; never invent a SHA or PR.
6. Publish a checkpoint summary in the shared task issue/PR when available, otherwise provide a portable Markdown handoff for the user to paste there. Use `../../templates/checkpoint.md` only if it exists in the installed bundle; otherwise follow the format below.
7. Continue independent, safe work in capable environments; otherwise stop at the end of the session and explain how to resume. Do not wait for routine approval, but do not exceed the default 2 unreviewed checkpoint limit.
8. If review flags a blocking dependency, pause that dependent line of work, pivot to safe independent tasks, or obtain the decision.

## Checkpoint format

```
Checkpoint: <number> - <short title>
Status: ready-for-review | local-only | blocked
Base SHA: <sha or unavailable>
Commit SHA: <sha or unavailable>
Behavior: <user-visible change>
Key code paths: <file:function -> file:function>
How to try it: <command or manual steps>
Verification: <exact checks and outcomes>
Decisions/risks: <tradeoffs and unresolved issues>
Review focus: <1-3 meaningful questions>
Next increment: <short description>
```

## Guardrails
- Never treat a passing test as proof of correctness.
- Keep reviewed checkpoints stable; fix in subsequent commits, avoiding force pushes.
- Do not merge, rewrite public history, or undertake destructive operations without authorization.
- Use GitHub issues/PR comments and commit SHAs for durable multi-agent state; do not require modifying application files to store task state.

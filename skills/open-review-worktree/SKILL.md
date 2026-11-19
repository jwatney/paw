---
name: open-review-worktree
description: Resolve a ready-for-review checkpoint and open it in a detached sibling worktree for read-only review. Use when the user asks to open the review worktree, check out a checkpoint for review, or start a review on the latest ready commit.
---

# Open Review Worktree

## Inputs
Repository; optional checkpoint number, title, or commit SHA. When none is given, use the latest checkpoint marked `ready-for-review`.

## Procedure
1. Confirm the repository root and its directory name. Leave the builder's worktree and branch untouched.
2. Resolve the checkpoint. Read the task issue, PR, or checkpoint notes for SHAs marked `ready-for-review`. Use the user's number, title, or SHA when they named one. If exactly one ready checkpoint exists, use it. If several are ready and the choice is ambiguous, ask which one and stop until they answer.
3. Confirm the commit exists (`git rev-parse --verify <sha>^{commit}`). Fetch from the remote that should contain it when the SHA is missing locally. If it still cannot be resolved, stop and say so. Record the full SHA.
4. Take the base SHA from the checkpoint note. When the note has none, use the first parent of the commit.
5. Place the review checkout at `../<repo>-review`, a sibling of the repository directory. When that path is already a worktree of this repo and its worktree is clean, detach it at the resolved SHA and reuse it. When that path exists and is not a clean worktree of this repo, stop and report the path. When the path is absent, create it with `git worktree add --detach <path> <sha>`.
6. Report the worktree path, the full SHA, `git show --stat <sha>`, and `git diff <base> <sha>`. State that the checkout is detached and that this session treats it as read-only.

Done when the worktree is detached at the confirmed SHA and the stat plus diff have been shown, or when you have stopped on an ambiguous checkpoint, a missing SHA, or a path that cannot be reused.

## Guardrails
- A detached worktree is still writable on disk. Do not edit, stage, or commit there unless the user specifically asks for a change in that checkout.
- Do not add, remove, or modify the builder's worktree.
- Prefer the recorded base SHA over guessing a merge base.

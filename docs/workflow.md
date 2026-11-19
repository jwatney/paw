# Operating procedure

## Start
1. State the outcome, constraints and verification criteria to a builder agent.
2. Say `Use progressive-build`. Confirm branch ownership and permission for Git operations.
3. Create or reuse a GitHub issue or PR description from `templates/task-state.md`.

## Work asynchronously *when the environment supports it*
- Builder creates checkpoint A and records its full commit SHA and verification.
- You or your review agent uses a separate worktree or checkout pinned to A.
- Builder can work on checkpoint B without modifying A's history.
- Review agent walks you through input -> code path -> outputs, then shares categorized feedback.
- Builder reconciles review feedback using `reconcile-feedback` and produces new commits.

## Review checkout

Say `Open the review worktree for the latest ready checkpoint` (or name a checkpoint number or title). The `open-review-worktree` skill resolves the SHA, fetches, and creates or reuses a detached sibling worktree at `../<repo>-review`.

A detached worktree is still writable on disk; **do not edit or commit** unless specifically tasked. The skill reports `git show --stat` and `git diff <base> <sha>` as read-only views. If two checkpoints are `ready-for-review`, it asks which one.

## Review loop

Say `Start the review loop on the latest ready checkpoint.` The `review-loop` skill opens that checkout, then walks the checkpoint in chat: one bite, then one decision (unpack this, next slice, record a finding, or finish). It drafts the review note and asks before posting. Accepted fixes go to the builder through `reconcile-feedback`. The loop does not commit on the builder branch.

## Review/throughput policy

- Default pending-review budget: 2 checkpoints.
- Beyond that, shift to non-dependent work (tests, documentation, experiments).
- Stop dependent architecture work on unresolved blocking design feedback.
- Make each increment cohesive and explainable rather than mechanically small.
- Never let an agent overwrite another agent's active worktree.

## Example prompts

Builder: `Use progressive-build. Implement a session-auth refactor in cohesive increments. You own the implementation branch. Commit each verified increment and, if permitted, publish SHA-linked checkpoint notes to our GitHub issue. Continue with independent safe changes while I review. Cap the unreviewed backlog at two.`

Reviewer: `Start the review loop on the latest ready checkpoint.`

Feedback: `Use reconcile-feedback on the comments for checkpoint <SHA>. Separate correctness issues from questions. Resolve accepted issues with new commits and report downstream test results.`

Agent handoff: `Read the GitHub task issue and all checkpoint SHAs, review notes and unresolved decisions. State what you can safely continue next; do not assume access to the previous agent's chat context.`

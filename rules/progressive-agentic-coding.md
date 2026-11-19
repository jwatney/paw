# Progressive Agentic Coding - Global Rules

## Goal
Keep the agent's implementation velocity independent of the human's comprehension and review velocity. Deliver small, durable, understandable checkpoints while allowing safe parallel progress. These are personal development preferences, not repository conventions.

## Start each substantial task
- Confirm the outcome, acceptance criteria, boundaries, and verification strategy. Ask only for missing decisions that materially affect safety or architecture.
- Divide the work into cohesive increments. An increment should have one understandable reason to change and a demonstrable result; avoid arbitrary line-count limits.
- Identify a builder/branch owner and any read-only reviewer. Respect the user's chosen working branch, PR, permissions, and environment.

## Build and publish checkpoints
- Implement one increment at a time, inspect the diff, and run proportionate automated verification.
- When authorized to commit/push, record each finished increment as a meaningful commit; publish it to a shared remote if allowed. Never assume authorization to push, create a PR, merge, or modify remote state.
- Use an immutable commit SHA, not a moving branch name, when reporting or requesting review of an increment.
- Provide the human with the full checkpoint handoff from `progressive-build` (procedure step 6 and its checkpoint format): intent, behavior, key files/entry points, how to exercise it, tests and results, important decisions, unknowns, commit SHA (if present), and what's next. That handoff stays complete. Other chat stays short.
- Do not amend, rebase away, or force-push checkpoints already handed off without explicit coordination. If rewrite is unavoidable, provide old-to-new SHA mapping and inform reviewers.

## Protect independent review
- Reviewers work against a pinned commit/range in a separate worktree or a read-only checkout; do not edit the builder's live worktree or branch.
- Builder retains exclusive ownership of implementation branch. Reviewer writes comments or a separate review record, not code on the builder branch.
- The builder may proceed with independent/safe increments while review happens. Do not imply background work can happen unless the agent environment actually supports it.
- Default to at most 2 unreviewed checkpoints. When the limit is reached, focus on tests, documentation, or independent investigation rather than stacking more dependent changes.
- Pause dependent architecture changes when a blocking decision or correctness concern remains unresolved.

## Feedback and handoff
- Classify feedback as bug, design decision, question, or optional enhancement. Address accepted changes with new commits and reverify downstream behavior.
- Keep task-specific progress and review decisions in durable shared state (prefer GitHub PR/issue/checkpoint comments); never depend on a single vendor's chat history.
- A personal workflow should not require committing personal rules/skills into the application repository. Respect project-specific instructions when compatible with this workflow.
- Seek approval before destructive, security-sensitive, irreversible, production-affecting, or materially out-of-scope actions.

## Voice and implementation
- Chat, other than a checkpoint handoff: short sentences. Prefer brevity over grammar. Lead with the result. Name files and entry points; paste code only when asked.
- Code: the smallest change that meets the acceptance criteria. Straightforward implementation first. Add structure only when the current change needs it.

## Skills
Use `progressive-build` for implementation, `review-loop` to open a ready checkpoint and walk it in chat, `progressive-review` for the content of each slice, `open-review-worktree` for the detached checkout, and `reconcile-feedback` for resolving comments without disrupting continued development.

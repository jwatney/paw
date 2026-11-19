---
name: review-loop
description: Run an interactive review session in chat. Opens the latest ready checkpoint, walks one slice at a time, and records the human's judgment. Use when the user says to start the review loop, open the review, or review the next ready checkpoint with them.
---

# Review Loop

A review session is a state machine in the chat. Each turn is one bite of the checkpoint and one decision. The agent runs git, moves between states, and drafts the note. The human judges the code.

## Inputs
Repository; optional checkpoint number, title, or SHA; optional task issue or PR. Default to the latest checkpoint marked `ready-for-review`.

## Chat turn
Send one short message, then one question. The message contains only the current bite. The question offers explicit options for the legal moves from the current state, and accepts a free-text question when the human wants something the options do not cover. Wait for the answer before the next state. Do not paste a list of commands for them to run.

## Procedure
1. **Resolve.** Find ready-for-review checkpoints from the task issue, PR, or checkpoint notes. Continue with the latest, or the one the human named. When more than one is ready and the choice is ambiguous, ask which one. Done when a single full SHA is chosen.
2. **Open.** Run `open-review-worktree` for that SHA. Done when its report (path, SHA, stat, diff) is in hand, or it has stopped.
3. **Orient.** Follow `progressive-review` for this SHA, but publish only the first bite: a short mental model, the two most important files, and one concrete input traced through the change, including the failure path. Inspect the code yourself. Done when that bite has been sent.
4. **Discuss.** Ask which move they want: unpack this, next slice, record a finding, or finish this checkpoint. On unpack or next slice, send one further bite from `progressive-review` and ask again. Done when they finish the checkpoint, or they stop the session.
5. **Capture.** Fold each finding into the review note as `blocking`, `recommended`, `question`, or `optional`, with file and line when available. Ask before labeling a finding `blocking`, and ask when they disagree with a label. Done when every finding from this sitting is labeled, or they have deferred one.
6. **Hand off.** Draft the note in the `templates/review-note.md` shape and a builder prompt that names `reconcile-feedback` plus this SHA. Ask whether to post the note to the issue or PR. Post only if they say yes. Done when the note is delivered in chat, and posted only with a yes.
7. **Advance.** When another ready checkpoint is still inside the backlog of 2, return to Resolve for that one. Otherwise idle. When a finding is `blocking` for later work, say that dependent increments should pause. When the environment can watch the builder ref, arm one wake that re-enters at Resolve for a newly ready SHA, then wait. When it cannot, stop and give the resume prompt: `Start the review loop on the latest ready checkpoint.`

## Guardrails
- Keep the review checkout read-only. Do not commit on the builder's branch.
- Keep each turn to one bite and one question.
- Stop stacking reviews past the pending-review budget of 2.
- Questions are not instructions to change code. Accepted changes go to the builder through `reconcile-feedback` as new commits.

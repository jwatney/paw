---
name: reconcile-feedback
description: Reconcile human code-review questions and corrections against pinned agent-generated checkpoints without rewriting reviewed history or derailing unrelated work. Use when a builder receives feedback on earlier increments or needs to hand a corrected implementation back for review.
---

# Reconcile Feedback

## Inputs
Review comments with referenced checkpoint SHAs; current branch/commit; permission for changes and publication; task acceptance criteria.

## Procedure
1. Read each comment against its original checkpoint. Identify any code or architecture that has changed in later commits.
2. Classify as `correctness`, `design`, `clarification`, or `optional` and determine severity. Distinguish disagreement from defect.
3. For each accepted code change, identify downstream dependencies and a minimal repair plan. For clarification-only items, explain and link code without changing it.
4. If blocking dependent implementation has already progressed, check downstream effects and amend the *current* design with new commits; never silently rewrite reviewed checkpoints.
5. Implement accepted repairs on the builder-owned branch only, with permission and ownership coordination. Verify affected behavior and regression tests.
6. Commit and publish fixes only if authorized. Link new SHA(s) to the original checkpoint/comments and explain which outstanding feedback is resolved.
7. Update the issue/PR shared task record with feedback status and any revised increment plan. Provide a durable handoff even when no remote write is possible.

## Feedback reconciliation format

```
Original checkpoint: <sha>
Feedback: <GitHub URL or concise quote>
Category: correctness | design | clarification | optional
Decision: accepted | answered | deferred | rejected (reason)
Impact on later work: <scope>
Resolution: <implementation/explanation>
Fix SHA: <sha or unavailable>
Verification: <tests/outcomes>
Remaining questions: <list or none>
```

## Guardrails
- Do not force-push or rewrite a published checkpoint without explicit consent and a clear replacement mapping.
- Do not treat questions as implicit instructions to rewrite code.
- Ask for approval on destructive or material product/architecture scope changes.

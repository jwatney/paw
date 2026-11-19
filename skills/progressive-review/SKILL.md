---
name: progressive-review
description: Interactively review and understand an agent-written code increment at a pinned Git commit, focusing on mental models, execution flow, tradeoffs, correctness and test coverage. Use when the user asks to learn or inspect incremental agent changes without stopping the builder.
---

# Progressive Review

## Inputs
Repository; immutable commit SHA or base..head range; target behavior; optional builder checkpoint note; current human questions.

## Procedure
1. Confirm that the SHA/range exists. Prefer a read-only checkout or separate worktree to avoid disturbing the builder. If no Git access, explicitly review only the supplied diff; never imply a checkout occurred.
2. Inspect the actual implementation and relevant neighboring code, rather than relying on the builder's summary. Restrict primary commentary to the requested checkpoint.
3. Lead with a concise mental model: the purpose, what happens at runtime, and the major data/control flow. Highlight 2-4 significant code locations with paths and symbols.
4. Trace one concrete input or use case through the changed path, including failure behavior. Explain design choices and plausible alternatives only where they materially affect comprehension.
5. Separately assess correctness, test coverage, boundary handling, and architectural risks. Clearly label observed facts vs. interpretation vs. unanswered questions.
6. Present bite-sized review steps rather than flooding the user with a line-by-line dump. Adapt depth to follow-up questions; invite the user to decide which concept to unpack next.
7. Produce feedback anchored to the exact checkpoint (file/line when available). Mark each item `blocking`, `recommended`, `question`, or `optional` and give a concrete reason.
8. Offer a portable review note to post on the GitHub PR/issue. Do not modify the builder branch or post remotely unless authorized.

## Review note format

```
Checkpoint SHA: <sha>
Mental model: <2-4 sentences>
Key code paths: <file:function -> file:function>
Verified by reviewer: <observations/checks>
Questions: <what needs explanation>
Findings:
- [blocking|recommended|optional] <file:line> - <problem / why / suggestion>
Builder feedback: <actionable request or none>
```

## Guardrails
- Keep review read-only by default; no writes on implementation branches.
- Identify when a decision would block subsequent dependent increments.
- Avoid claims of runtime behavior that have not been checked or demonstrated.

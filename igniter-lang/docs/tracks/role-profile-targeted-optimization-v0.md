# Track: Role Profile Targeted Optimization v0

Card: supervisor-side
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: role-profile-targeted-optimization-v0
Status: done
Date: 2026-05-08

---

## Goal

Apply the accepted minimal interventions from
`docs/discussions/agent-role-optimization-v0.md` before the next documentation
round starts.

This is a targeted role-profile update, not a role-system rewrite.

## Decisions

[D] Research Agent no longer owns round-close status consolidation by default.
It owns proofs, fixtures, runtime experiments, and bridge-ready evidence.

[D] Meta Expert owns round-close status consolidation in **Status Curator
mode**. Status Curator is a mode of Meta Expert, not a separate role.

[D] Compiler/Grammar Expert now has explicit spec-lag stewardship. When a round
changes language semantics, compiler boundaries, SemanticIR, `.igapp`, or
runtime-facing language contracts, C/G Expert must flag stale spec chapters and
route bounded spec-sync work.

[D] External Pressure Reviewer may borrow `runtime-pressure` as a lens for
production/runtime risk review. This lens adds vocabulary, not authority.

## Files Updated

```text
igniter-lang/roles/research-agent.md
igniter-lang/roles/compiler-grammar-expert.md
igniter-lang/roles/meta-expert.md
igniter-lang/roles/external-pressure-reviewer.md
igniter-lang/roles/README.md
igniter-lang/docs/operating-model.md
igniter-lang/docs/tracks/role-profile-targeted-optimization-v0.md
```

## Next-Round Instruction

Every agent in the next round should reread:

```text
igniter-lang/roles/README.md
their assigned role profile
igniter-lang/docs/operating-model.md
igniter-lang/docs/current-status.md
```

If assigned a discussion with `Borrowed lens: runtime-pressure`, External
Pressure Reviewer should use the new lens definition in
`roles/external-pressure-reviewer.md`.

## Handoff

```text
Card: supervisor-side
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: role-profile-targeted-optimization-v0
Status: done

[D] Decisions
- Applied three minimal role interventions from agent-role-optimization-v0.
- Kept the role spine intact; no role merge or broad restructure.

[S] Shipped / Signals
- Research Agent focuses on proofs/fixtures instead of status consolidation.
- Meta Expert owns Status Curator mode.
- Compiler/Grammar Expert owns spec-lag stewardship.
- External Pressure Reviewer has `runtime-pressure` lens.

[T] Tests / Proofs
- Docs-only profile update; no code proofs run.

[R] Risks / Recommendations
- Next cards should explicitly instruct agents to reread updated role profiles.
- Agent Context Capsule remains a separate docs-round slice.
```

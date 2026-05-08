# Track: PROP-029 Entrypoint Section Surface v0

Card: S3-R8-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `PROP-029-entrypoint-section-surface-v0`
Status: done
Date: 2026-05-08

---

## Goal

Draft the formal proposal for the `entrypoint` / `section` source surface
without implementing parser support.

---

## Inputs

- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/tracks/spec-entrypoint-sync-v0.md`
- `docs/spec/ch2-source-surface.md`
- `docs/value-index.md`
- `docs/meta-proposals/syntax-pressure-registry-v0.md`
- `docs/meta-proposals/syntax-pressure-review-results-v0.md`
- `experiments/human_agent_syntax_comprehension_fixture/primitive_surface_evaluator_guide.md`
- `experiments/human_agent_syntax_comprehension_fixture/primitive_surface_fixture.ig`

---

## Decision

[D] Authored `docs/proposals/PROP-029-entrypoint-section-surface-v0.md`.

[D] Proposal status is `proposal`, not canon and not implemented.

[D] `entrypoint` v0 recommendation:

```text
named source-level evaluation/run profile over an existing contract
```

It is not a new contract, not a scheduler, not a runtime route, and not a
package/API entrypoint.

[D] `section` v0 recommendation:

```text
grouping-only source organization
```

It must flatten to normal declarations while preserving spans and
`section_path` metadata. No namespace, visibility, lifecycle, dependency, or
evaluation-order semantics.

[D] Future parser implementation should use contextual declaration keywords.
This slice does not reserve `entrypoint` or `section` in the current parser.

---

## Proposal Index Update

[S] Updated `docs/proposals/README.md` so `PROP-029` now names the authored
entrypoint/section proposal.

[S] Renumbered the previously queued placeholder proposal IDs after `PROP-029`
because they were not authored documents.

---

## OOF Coverage

[S] PROP-029 defines:

- `OOF-EP1..EP9` for duplicate names, missing/unknown target contract, unknown
  output, arg shape/type mismatches, multiple defaults, and duplicate fields.
- `OOF-SEC1..SEC3` for nested sections, illegal section body declarations, and
  malformed section labels.

---

## Non-Goals

[X] No parser changed.

[X] No SemanticIR emitter changed.

[X] No runtime, CLI, `.igapp`, or package entrypoint behavior changed.

[X] No round-close map authored.

---

## Verification

Docs/proposal-only checks:

```text
rg "PROP-029|entrypoint|section" docs/proposals/PROP-029-entrypoint-section-surface-v0.md docs/proposals/README.md docs/current-status.md docs/tracks/prop-029-entrypoint-section-surface-v0.md
git diff --check -- docs/proposals/PROP-029-entrypoint-section-surface-v0.md docs/proposals/README.md docs/current-status.md docs/tracks/prop-029-entrypoint-section-surface-v0.md
```

---

## Handoff

```text
Card: S3-R8-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: PROP-029-entrypoint-section-surface-v0
Status: done

[D] Decisions:
- PROP-029 drafted with status proposal.
- Entrypoint means named evaluation/run profile over an existing contract.
- Section means grouping-only source organization.
- Parser implementation and keyword reservation remain future work.

[S] Shipped / Signals:
- New proposal under docs/proposals/.
- Track doc records the decision and non-goals.
- Proposal index now assigns PROP-029 to entrypoint/section.
- current-status now says PROP-029 is drafted but proposal-only.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Future parser slice must prove contextual keyword behavior and OOF-EP/SEC diagnostics.
- Runtime/CLI tools must not treat entrypoint metadata as execution authorization.

[Next] Suggested next slice:
- entrypoint-section-parser-typechecker-v0, after proposal acceptance.
```

## Files Changed

```text
igniter-lang/docs/proposals/PROP-029-entrypoint-section-surface-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/prop-029-entrypoint-section-surface-v0.md
```

# Track: Spec Entrypoint Sync v0

Card: S3-R7-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/spec-entrypoint-sync-v0`
Status: done
Date: 2026-05-08

---

## Goal

Resolve entrypoint/section spec drift without expanding parser semantics.

The issue was not implementation absence alone. The docs had enough pressure
artifacts that agents could reasonably infer `entrypoint` and `section` were
planned, while the parser/spec kernel still had no such declarations. This
track gives those spellings a precise current disposition.

---

## Inventory

[D] Current parser/library surface:

- `lib/igniter_lang/parser.rb` has no `entrypoint` or `section` keyword.
- Grammar kernel v0 in `docs/spec/ch2-source-surface.md` has no
  `entrypoint` or `section` declaration.
- No parser support was implemented in this slice.

[D] Syntax pressure artifacts:

- `docs/meta-proposals/syntax-pressure-registry-v0.md` classifies
  `entrypoint` as proposal pressure and `section` as pressure, with no canon
  promotion.
- `docs/meta-proposals/syntax-pressure-review-results-v0.md` routes both
  spellings toward a future proposal.
- `experiments/human_agent_syntax_comprehension_fixture/primitive_surface_fixture.ig`
  uses `section` and `entrypoint` only as non-canon pressure syntax.
- The primitive evaluator guide states `section` is grouping pressure and
  `entrypoint` is not canon.

[D] Status map before this card:

- `current-status.md` already said entrypoint/section were proposal candidates,
  but the freshness table still carried an open disposition debt.

---

## Disposition

[D] `entrypoint` and `section` are Stage 3 proposal candidates.

[D] They are not current canonical syntax.

[D] They are not parser-supported declarations.

[D] They are not hard-reserved parser keywords today.

[D] `contract` remains the canonical source computation boundary.

[D] Entry selection remains external to source syntax until a PROP is accepted:
CLI/API arguments, fixture metadata, or explicit tool invocation may select the
contract/output to inspect or evaluate.

[D] If `section` is promoted later, the recommended default is grouping-only:
no namespace, no visibility, no dependency boundary, no lifecycle, and no
evaluation order.

---

## Spec/Status Updates

[S] Updated `docs/spec/ch2-source-surface.md` with a Stage 3 candidate
disposition section after Grammar Kernel v0.

[S] Updated `docs/current-status.md` to mark the entrypoint/section disposition
as set and remove the specific open doc debt for this card.

---

## Collision Risks

[R] `entrypoint` has two competing meanings:

- package/compiler/API entrypoint, such as compile/evaluate commands
- source-language entrypoint, if future syntax chooses one

A future PROP should use "source entrypoint" or "`entrypoint` declaration" when
it means source syntax.

[R] A source `entrypoint` could mean default contract, default output,
evaluation target, UI route, scheduled trigger, or test fixture start. The PROP
must choose exactly one initial meaning.

[R] Multiple contracts and `.igapp` bundles require rules for duplicate
entrypoints, no default entrypoint, multiple defaults, profile-specific
entrypoints, and unknown contract references.

[R] `section` can be confused with `module`, namespace, scope, or visibility.
If accepted, flattening and span preservation must be proven so diagnostics do
not hide where declarations came from.

[R] Reserving either spelling before the PROP would risk identifier collisions
without a settled AST shape.

---

## Recommended Future PROP

[Next] Suggested proposal track:

```text
PROP-029-entrypoint-section-surface-v0
```

Minimum scope:

- Define whether `entrypoint` names a default contract, output, evaluation
  profile, or fixture start.
- Define whether a program may have zero, one, or many entrypoints.
- Define `section` as grouping-only or reject it until namespace/profile
  semantics exist.
- Specify ParsedProgram shape and span preservation.
- Specify whether `entrypoint` / `section` become reserved keywords.
- Add parser proof fixtures only after the PROP is accepted.

Expected OOF questions:

- duplicate entrypoint
- entrypoint references unknown contract
- entrypoint args are missing, extra, or wrong type
- multiple default entrypoints without selector/profile
- illegal declaration inside section
- duplicate section label, if labels become semantically visible

---

## Verification

Docs-only sync. Sanity checks:

```text
rg "entrypoint|section" docs/spec/ch2-source-surface.md docs/current-status.md docs/tracks/spec-entrypoint-sync-v0.md
git diff --check -- docs/spec/ch2-source-surface.md docs/current-status.md docs/tracks/spec-entrypoint-sync-v0.md
```

---

## Handoff

```text
Card: S3-R7-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/spec-entrypoint-sync-v0
Status: done

[D] Decisions:
- Entrypoint/section are Stage 3 proposal candidates, not current canon.
- No parser support or hard keyword reservation exists today.
- Contract remains the canonical computation boundary.
- Section, if promoted later, should default to grouping-only.

[S] Shipped / Signals:
- Ch2 now states the disposition directly near Grammar Kernel v0.
- current-status freshness table marks the disposition set.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Future PROP must disambiguate source entrypoint from compiler/API entrypoint.
- Future PROP must prevent section from silently becoming namespace/scope.

[Next] Suggested next slice:
- PROP-029-entrypoint-section-surface-v0.
```

## Files Changed

```text
igniter-lang/docs/spec/ch2-source-surface.md
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/spec-entrypoint-sync-v0.md
```

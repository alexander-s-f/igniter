# Branch Conditional Counterfactual Audit Vocabulary Docs Sync Acceptance Decision v0

Card: S3-R207-C3-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0  
Route: UPDATE  
Status: done / accepted  
Date: 2026-05-30

Depends on:
- S3-R207-C1-I
- S3-R207-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-vocabulary-docs-sync-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round206-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`

Additional verification:

```bash
git show --name-only --oneline --no-renames 11358925
git status --short
```

---

## Decision

Decision:

```text
accept S3-R207-C1-I bounded Option A docs sync
accept S3-R207-C2-X pressure verdict: PASS 10/10, no blockers, no notes
recognize `branch_intention` as discoverable Level 1 docs vocabulary
keep `if_expr_branch_intention` proof-local / non-canonical
keep Level 2 dry-run, runtime/report/API/public claims, and Spark/API/CLI closed
route next to S3-R207-C4-S status curation, then Level 2 dry-run boundary design-only may open
```

The docs sync satisfies the R206 Option A boundary. It improves discoverability
without moving branch-intention vocabulary into high-authority spec-body
chapters or public/runtime/report surfaces.

The governing phrase remains:

```text
Runtime is lazy.
Audit is aware.
```

---

## Accepted Changed Files

C1-I primary commit:

```text
11358925 docs(igniter-lang): complete S3-R207 Level 1 branch-intention vocabulary/docs-sync
```

Accepted changed files:

| File | Acceptance status |
| --- | --- |
| `igniter-lang/docs/current-status.md` | Accepted status pointer / current-lane summary. |
| `igniter-lang/docs/dev/semantic-governance-heat-map.md` | Accepted governance row for proof-local Level 1 `branch_intention`. |
| `igniter-lang/docs/spec/README.md` | Accepted one-line spec index pointer labeled proof-local / held. |
| `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md` | Accepted C1-I implementation track doc. |

No uncommitted changes were present during C3-A review.

---

## Acceptance Findings

| Check | Decision |
| --- | --- |
| Option A target compliance | Accepted. Exactly the authorized four files changed. |
| Forbidden phrase scan | Accepted. C2-X independently reports CLEAR across touched docs. |
| Proof-local descriptor status | Accepted. `if_expr_branch_intention` is labeled non-canonical and proof-local. |
| Assumptions / PROP-032 status | Accepted. Assumptions remain premise capsule only; PROP-032 was not edited. |
| Ch2/Ch5/Ch6/Ch7 body edit status | Accepted. No spec-body chapter edits occurred. |
| Runtime/API/report/public claim status | Accepted. No public counterfactual/runtime/API/report/receipt/schema claim. |
| Spark/API/CLI status | Accepted. No Spark/API/CLI claim or behavior. |
| Evidence anchor | Accepted. R205 concept proof remains the evidence base: `sha256:0fc1b8005833478a22abc816ed3bf74364ef7b21c263ea1a57450676d81a8a9a`. |

C2-X pressure result:

```text
PASS — 10/10 PASS, no blockers, no non-blocking notes
```

---

## Required Answers

| Question | Answer |
| --- | --- |
| Is the docs sync accepted? | Yes. Accepted unconditionally. |
| Is `branch_intention` now discoverable as Level 1 docs vocabulary? | Yes. It is visible in current status, semantic governance, and the spec index as proof-local static audit vocabulary. |
| Does `if_expr_branch_intention` remain non-canonical? | Yes. It is not a SemanticIR node/field, report/result/receipt shape, runtime output, public API/CLI object, or artifact schema. |
| Does Level 2 dry-run remain closed? | Yes. It requires a separate design gate before any proof or implementation. |
| Do public counterfactual/runtime/demo claims remain closed? | Yes. |
| May implementation open next? | No live implementation. Only a future design-only route may open. |
| What next route should open? | Immediate S3-R207-C4-S status curation; after that, a Level 2 counterfactual dry-run boundary design-only route may open if the Main Line continues on this axis. |

---

## Next Route

Immediate status handoff:

```text
Card: S3-R207-C4-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round207-status-curation-v0
Route: UPDATE
Depends on:
- S3-R207-C1-I
- S3-R207-C2-X
- S3-R207-C3-A

Goal:
Curate R207 acceptance, record the accepted Option A docs-sync status, preserve
closed surfaces, and record the next Main Line route.
```

Recommended later Main Line route after C4-S:

```text
Card: S3-R208-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0
Route: UPDATE
Depends on:
- S3-R207-C4-S

Goal:
Design-only boundary for Level 2 counterfactual dry-run: determine whether and
how Igniter-Lang could describe "what would have happened" for a latent branch
without mutating actual runtime results, public reports, cache/dependency
authority, or production behavior.
```

Required R208 constraints:

- design-only;
- no code;
- no runtime/evaluator/RuntimeSmoke changes;
- no report/result/receipt/CompatibilityReport shape changes;
- no cache/dependency authority;
- no non-selected branch evaluation in live runtime;
- no public counterfactual/runtime/demo claims;
- no Spark/API/CLI;
- define minimum evidence required before any spec-body promotion of
  `branch_intention`.

---

## Remaining Closed Surfaces

Remain closed after R207:

- live implementation;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator;
- RuntimeSmoke;
- proof RuntimeMachine changes;
- non-selected branch evaluation in live runtime;
- Level 2 counterfactual dry-run implementation/proof;
- Level 3 comparison report;
- dependency/cache authority;
- report/result/receipt/CompatibilityReport shape changes;
- `language-spec.md`;
- Ch2/Ch5/Ch6/Ch7 body chapter edits;
- PROP-032 amendment;
- public API/CLI widening;
- release evidence rewrite or relabeling;
- release commands, publish/yank/tag/push/sign/deploy;
- public demo/release/stable/production/all-grammar/runtime/counterfactual
  claims;
- Spark data, fixtures, specs, ids, integration, or demo behavior.

---

## Compact Handoff

R207 docs sync is accepted. `branch_intention` is now discoverable as Level 1
proof-local static audit vocabulary in low-authority documentation surfaces.
`if_expr_branch_intention` remains non-canonical. Assumptions remain premise
capsule only. Level 2 dry-run and public/runtime/report/API/Spark claims remain
closed. Next immediate card is status curation; the recommended next Main Line
axis is Level 2 counterfactual dry-run boundary design-only.

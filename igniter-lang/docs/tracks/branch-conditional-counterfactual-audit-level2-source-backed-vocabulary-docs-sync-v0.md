# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Docs Sync v0

Card: S3-R213-C2-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-30

Depends on:
- S3-R213-C1-A

---

## Summary

Bounded docs-only Option A-min sync making source-backed proof-local Level 2
counterfactual dry-run evidence discoverable in low-authority internal navigation
surfaces. No spec body chapters, PROP-032, `docs/current-status.md`, public docs,
`lib/**`, runtime/report/API, or public claims were touched.

---

## Authorized Write Scope

| File | Edit type |
|------|-----------|
| `igniter-lang/docs/dev/semantic-governance-heat-map.md` | New `source_backed_dry_run_projection` governance row + footnote § |
| `igniter-lang/docs/spec/README.md` | One-line proof-local index pointer |
| `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md` | This track doc |

`docs/current-status.md` — **not touched** (closed for C2-I per C1-A).

---

## Required Wording Applied

Per C1-A binding wording class, the following phrase appears in the touched documents:

> source-backed proof-local Level 2 counterfactual dry-run evidence

And the required non-claim disambiguation:

> Not source syntax, not canonical SemanticIR schema, not CompilerResult or
> CompilationReport shape, not report/result/receipt/CompatibilityReport shape,
> not runtime behavior, not live non-selected branch evaluation, not public
> counterfactual audit support, and not Spark/API/CLI support.

---

## Exact Changes

### `docs/dev/semantic-governance-heat-map.md`

New row appended to **Domain 2 — Epistemic Declarations** table, below the Level 1 `branch_intention` row:

```markdown
| `source_backed_dry_run_projection` / source-backed Level 2 counterfactual dry-run (proof-local)§ | — | — | — | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | ⚙️ | sem |
```

New footnote § inserted after the existing ‡ footnote:

```markdown
> § Source-backed proof-local Level 2 evidence (R211 SB-1..SB-15 61/61 PASS; R212 accepted
> vocabulary/spec boundary; R213 docs-only Option A-min sync). Proof-local and non-canonical:
> `source_backed_dry_run_projection` is not a SemanticIR node kind or field, not emitted by
> compiler surfaces, not a spec chapter, not a PROP, not parser/grammar/runtime/schema, not a
> report/receipt/CompatibilityReport field. All pipeline stages gated (🚫). Assumptions-shaped
> premise refs in `premise_set` records are proof-local labels only; not PROP-032 branch syntax
> and not receipt `assumption_refs`. Level 2 projection is not public counterfactual audit support,
> not runtime behavior, not public API/CLI, and not Spark/production support.
```

### `docs/spec/README.md`

One line appended to the **Implementation Coverage Matrix** after the Level 1 `branch_intention` row:

```markdown
| — (no spec chapter; source-backed Level 2 evidence, held) | — | experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/ (61/61 PASS) | ⚙️ proof-local only — source-backed Level 2 counterfactual dry-run evidence; non-canonical; not source syntax, not SemanticIR schema, not runtime behavior, not report/receipt/CompatibilityReport field; body spec chapters, PROP-032, runtime/report/API, and public claims remain closed |
```

---

## Held Files (Not Touched)

| File | Reason |
|------|--------|
| `igniter-lang/docs/current-status.md` | Closed for C2-I per C1-A |
| `igniter-lang/docs/spec/ch2-source-surface.md` | Body chapter — held for later gate |
| `igniter-lang/docs/spec/ch5-compiler-pipeline.md` | Body chapter — held |
| `igniter-lang/docs/spec/ch6-semanticir.md` | Body chapter — held |
| `igniter-lang/docs/spec/ch7-runtime.md` | Body chapter — held |
| `igniter-lang/docs/language-spec.md` | Held |
| `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md` | No amendment authorized |
| All `lib/**` code files | Closed |
| Public API/CLI/release/runtime/report docs | Closed |

---

## Forbidden Phrase Scan

Commands run:

```bash
rg -n "would_result|would_output|would_fail|counterfactual result|counterfactual output|counterfactual failure|latent runtime value|latent runtime failure|latent execution|latent branch execution|simulated branch result|dry-run result|branch replay|replayed branch value|symbolic_execution|causal_estimate|alternate_actual_output" docs/dev/semantic-governance-heat-map.md docs/spec/README.md

rg -n "counterfactual audit support|runtime counterfactual support|public counterfactual support|counterfactual runtime|runtime can evaluate latent|runtime can dry-run|SemanticIR emits branch_intention|SemanticIR emits source_branch|source-backed branch intentions are SemanticIR|source_branch_intention_ref is a Compilation|dry_run_projection is a Compatibility|receipt contains counterfactual|public API supports counterfactual|CLI supports counterfactual|branch-level uses assumptions|PROP-032 branch syntax" docs/dev/semantic-governance-heat-map.md docs/spec/README.md
```

**Scan 1 (Level 2 forbidden vocabulary):** CLEAR — no matches.

**Scan 2 (forbidden positive claims):** 3 matches, all in negative-disambiguation / non-claim
context inside the new § footnote:

| Line | Text | Status |
|------|------|--------|
| heat-map:88 | `not PROP-032 branch syntax` (existing ‡ footnote) | ✅ Negative — acceptable |
| heat-map:96 | `not PROP-032 branch syntax` (new § footnote) | ✅ Negative — acceptable |
| heat-map:97 | `is not public counterfactual audit support` (new § footnote) | ✅ Negative — acceptable |

C1-A permits matches inside "explicit forbidden, non-claim, negative-disambiguation, or
closed-surface sections." All three are negative-disambiguation in the § footnote. **CLEAR.**

---

## Closed-Surface Scan

```bash
git diff --name-only
# → igniter-lang/docs/dev/semantic-governance-heat-map.md
# → igniter-lang/docs/spec/README.md
```

| Closed surface | Status |
|----------------|--------|
| `docs/current-status.md` | ✅ Not in diff |
| Body spec chapters (ch2/ch5/ch6/ch7) | ✅ Not in diff |
| `docs/language-spec.md` | ✅ Not in diff |
| `docs/proposals/PROP-032-assumptions-block-v0.md` | ✅ Not in diff |
| `lib/**` code files | ✅ Not in diff |
| Public API/CLI/release/runtime/report docs | ✅ Not in diff |
| Total changed files | 2 (both authorized) |

---

## Non-Claim Block

```text
This docs sync is not source syntax, not canonical SemanticIR schema, not
CompilerResult or CompilationReport shape, not report/result/receipt/
CompatibilityReport shape, not runtime behavior, not live non-selected branch
evaluation, not public counterfactual audit support, and not Spark/API/CLI
support.

source_backed_dry_run_projection is proof-local and non-canonical.
source_branch_intention_ref is not emitted by compiler surfaces.
SHA-256 digest-addressed source refs do not make the evidence canonical.
projected_value is not an actual runtime output.
projected_failure is not an actual runtime failure.
Assumptions-shaped premise refs in premise_set records are proof-local labels
only; they are not PROP-032 branch syntax and are not receipt assumption_refs.
```

---

## Proof-Local Evidence Citation Stance

C2-I cites R211/R212 evidence only as internal proof-local evidence:

- R211 source-backed proof-local Level 2 evidence (SB-1..SB-15 61/61 PASS)
- R212 accepted vocabulary/spec boundary (S3-R212-C4-A)
- R213 authorized docs-only Option A-min sync (S3-R213-C1-A)
- Proof-owned SemanticIR-shaped artifacts, frozen input snapshots, explicit premise sets,
  SHA-256 digest-addressed refs, no-authority projection envelopes

Not implied:

- Source evidence is not canonical SemanticIR
- `source_branch_intention_ref` is not emitted by compiler surfaces
- Proof projection is not an actual runtime result
- Live runtime does not evaluate latent branches
- No public API/CLI/report/receipt/cache authority exists

---

## Exact Dispatch

```text
Card: S3-R213-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0
Route: UPDATE
Status: done
Depends on:
- S3-R213-C1-A
```

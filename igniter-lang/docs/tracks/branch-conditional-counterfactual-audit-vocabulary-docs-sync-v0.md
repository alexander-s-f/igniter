# Branch Conditional Counterfactual Audit Vocabulary Docs Sync v0

Card: S3-R207-C1-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-30

Depends on:
- S3-R206-C5-S

---

## Summary

Applied the bounded Option A docs-sync for Level 1 branch-intention vocabulary:
current-status status pointer, semantic-governance heat-map row, and spec README
index pointer. No spec-body chapter edits. No code edits.

---

## Authorized Write Scope (Option A)

| File | Edit type |
|------|-----------|
| `igniter-lang/docs/current-status.md` | Status pointer / current-lane summary |
| `igniter-lang/docs/dev/semantic-governance-heat-map.md` | New `branch_intention` governance row |
| `igniter-lang/docs/spec/README.md` | One-line proof-local index pointer |
| `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md` | This track doc |

---

## Required Wording Class

Per S3-R206-C4-A binding requirement, the following wording class appears in the
touched documents:

> Level 1 branch-intention vocabulary is proof-local static audit vocabulary for
> explaining actual and latent if_expr branches without evaluating latent branches.
> It is not source syntax, not a SemanticIR schema field, not runtime behavior,
> and not public counterfactual audit support.

> Proof-local branch premise refs may be assumptions-shaped, but they are not
> PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.

---

## Exact Changes

### `docs/current-status.md`

**Change 1 — current-lane narrative** (inserted after R206 summary):

```text
R207 applies the bounded Option A docs-sync:
current-status pointer, semantic-governance heat-map
row, and spec README index pointer; Level 1
branch-intention vocabulary is proof-local static
audit vocabulary for explaining actual and latent
if_expr branches without evaluating latent branches;
not source syntax, not a SemanticIR schema field,
not runtime behavior, not public counterfactual audit
support; spec-body chapter edits remain held;
```

**Change 2 — chronological log** (inserted after Round 206):

```text
Round 207 landed:
  S3-R207-C1-I: Level 1 branch-intention vocabulary docs sync   ✅ done; Option A applied;
  current-status pointer, heat-map row, spec README pointer;
  wording class confirmed; no code/grammar/runtime/report edits
```

---

### `docs/dev/semantic-governance-heat-map.md`

New row added to **Domain 2 — Epistemic Declarations** table:

```markdown
| `branch_intention` / `if_expr_branch_intention` (Level 1 static audit, proof-local)‡ | — | — | — | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | ⚙️ | sem |
```

Footnote ‡:

> Accepted as Level 1 docs vocabulary by S3-R206-C4-A. R205 concept proof
> (BIA-1..BIA-10 46/46 PASS) is the only evidence base. Proof-local and
> non-canonical: `if_expr_branch_intention` is not a SemanticIR node kind or
> field, not a spec chapter, not a PROP, not parser/grammar/runtime/schema.
> All pipeline stages gated (🚫). Level 2 dry-run, dependency/cache authority,
> reports/receipts/CompatibilityReport, and public counterfactual claims remain
> closed. Proof-local branch premise refs may be assumptions-shaped but are not
> PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.

---

### `docs/spec/README.md`

New row added to **Implementation Coverage Matrix** (after the last `if_expr` row):

```markdown
| — (no spec chapter; Level 1 static audit vocab, held) | — |
  experiments/branch_conditional_counterfactual_audit_concept_proof_v0/ (46/46 PASS) |
  ⚙️ proof-local only — `branch_intention` Level 1 static audit vocabulary for
  explaining actual and latent if_expr branches without evaluating latent branches;
  `if_expr_branch_intention` non-canonical; not source syntax, not SemanticIR schema
  field, not runtime behavior; Level 2 dry-run, grammar, runtime, reports/receipts closed |
```

---

## Held Files (Not Touched)

| File | Reason |
|------|--------|
| `igniter-lang/docs/language-spec.md` | Held for a later explicit gate |
| `igniter-lang/docs/spec/ch2-source-surface.md` | Held for a later explicit gate |
| `igniter-lang/docs/spec/ch5-compiler-pipeline.md` | Held for a later explicit gate |
| `igniter-lang/docs/spec/ch6-semanticir.md` | Held for a later explicit gate |
| `igniter-lang/docs/spec/ch7-runtime.md` | Held for a later explicit gate |
| `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md` | Held; no amendment authorized |
| All `lib/**` code files | Closed; no code edits authorized |
| All runtime/report/receipt/CompatibilityReport docs | Closed |

---

## Verification Matrix

| Check | Command | Result |
|-------|---------|--------|
| Forbidden Level 2 vocabulary absent | `rg -n "would_result\|would_output\|would_fail\|counterfactual result\|counterfactual output\|counterfactual failure\|latent runtime value\|latent runtime failure\|latent execution\|latent branch execution\|simulated branch result\|dry-run result\|branch replay\|replayed branch value" current-status.md heat-map.md spec/README.md` | ✅ CLEAR — no matches |
| Forbidden positive claims absent | `rg -n "SemanticIR now emits branch_intention\|supports counterfactual audit\|RuntimeSmoke supports counterfactual\|branch-level uses assumptions\|dependency tracking or cache keys" current-status.md heat-map.md spec/README.md` | ✅ CLEAR — no matches |
| No code files touched | `git diff --name-only` | ✅ No `lib/**` or `experiments/**` in diff |
| No Ch2/Ch5/Ch6/Ch7 touched | `git diff --name-only` | ✅ Spec body chapters not in diff |
| No PROP-032 touched | `git diff --name-only` | ✅ Not in diff |
| No language-spec.md touched | `git diff --name-only` | ✅ Not in diff |
| Exact changed files | `git diff --name-only` | `docs/current-status.md`, `docs/dev/semantic-governance-heat-map.md`, `docs/spec/README.md` |
| Required wording class present | Manual check | ✅ Confirmed in all three files |

---

## Claim Policy (Binding)

```text
Level 1 branch-intention vocabulary is proof-local static audit vocabulary.
It is not source syntax, not a SemanticIR schema field, not runtime behavior,
and not public counterfactual audit support.

if_expr_branch_intention is non-canonical and proof-local.

Proof-local branch premise refs may be assumptions-shaped, but they are not
PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.

Level 1 static audit excludes would-result, would-output, would-fail, latent
runtime value, latent runtime failure, Level 2 dry-run, dependency/cache
authority, and report/result/receipt/CompatibilityReport shape changes.
```

---

## Exact Dispatch

```text
Card: S3-R207-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0
Route: UPDATE
Status: done
Depends on:
- S3-R206-C5-S
```

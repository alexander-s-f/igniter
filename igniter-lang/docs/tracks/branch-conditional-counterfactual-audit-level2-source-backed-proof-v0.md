# Branch Conditional Counterfactual Audit Level 2 Source-Backed Proof v0

Card: S3-R211-C2-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `branch-conditional-counterfactual-audit-level2-source-backed-proof-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-30

Depends on:
- S3-R211-C1-A

---

## Summary

Proof-local source-backed Level 2 counterfactual dry-run evidence extending R209:
branch-intention evidence is now derived from proof-owned SemanticIR-shaped source
artifacts written to disk, with SHA-256 digest-addressed `source_branch_intention_ref`,
`input_snapshot_ref`, and `premise_set` objects.

Proves SB-1..SB-15 (61 checks, all PASS on first run — no fixes required).

Governing principle applied:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

---

## Authorized Write Scope

Written:
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/` (source artifacts + projections + summary)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md` (this file)

No `lib/**`, spec chapters, PROP-032, runtime/evaluator, RuntimeSmoke, or prior
proof evidence were modified.

---

## Architecture Extension Over R209

| Dimension | R209 (L2-DRY) | R211 (source-backed) |
|-----------|--------------|----------------------|
| Source artifact | Hand-authored in-memory fixture | Proof-owned JSON written to `out/source_artifacts/` |
| Source reference | Bare string | Structured `source_branch_intention_ref` with `source_digest` |
| Input snapshot | Inline `{}` | Structured `input_snapshot_ref` with `digest` |
| Premise set | Simple dict | Enhanced with `assumed_condition_source` + `premise_set_digest` |
| Evidence packet | Absent | `source_branch_intention_evidence_packet` derived from source artifact |
| Digest chain | Not present | SHA-256 on all source refs, snapshots, premise sets, projections |
| Tier 0 legacy | Implicit | Explicit Tier 0 label: `not_sole_proof_authority: true` |
| Execution-summary citation | Absent | R209 summary read-only ref |

---

## Source Artifacts

All proof-owned source artifacts are written to `out/source_artifacts/` and
SHA-256 digest-addressed.

| File | Digest | Purpose |
|------|--------|---------|
| `semanticir_risk_gate_v0.json` | `sha256:…` | Main if_expr: apply latent then_branch |
| `semanticir_nested_if_v0.json` | `sha256:…` | Nested if_expr laziness proof |
| `semanticir_tbackend_v0.json` | `sha256:…` | tbackend_read refusal case |
| `semanticir_escape_v0.json` | `sha256:…` | escape/effect refusal case |
| `input_snapshot_risk_gate_v0.json` | `sha256:…` | Frozen inputs `{flag:true,a:10,b:5,fallback:99}` |
| `input_snapshot_empty_v0.json` | `sha256:…` | Empty snapshot for unresolved-ref test |

---

## Projections

| ID | Latent expr | Snapshot | `assumed_condition` | `projected_value` | `projected_failure` |
|----|------------|---------|---------------------|------------------|---------------------|
| A | `apply(add,a,b)` | `{a:10,b:5}` | true | 15 | — |
| B (SB-7) | `apply(add,a,b)` | `{}` (empty) | true | — | ref_not_in_scope:a |
| C (SB-10) | nested `if_expr` | `{}` | false | 7 | — |
| D (SB-9) | `tbackend_read` | `{}` | false | — | tbackend_read_refused |
| E (SB-8) | `escape` | `{}` | false | — | escape_refused |

---

## SB-1..SB-15 Result Table

| ID | Required proof | Result |
|----|---------------|--------|
| SB-1 | Source artifact loaded as proof-owned evidence only | PASS (4 sub-checks) |
| SB-2 | `source_branch_intention_evidence_packet` with `canonical:false` | PASS (5 sub-checks) |
| SB-3 | `source_branch_intention_ref` structured and digest-addressed | PASS (5 sub-checks) |
| SB-4 | Frozen `input_snapshot_ref` digest-addressed and no-authority | PASS (4 sub-checks) |
| SB-5 | `premise_set` with `assumed_condition_source`, digest, authority-false | PASS (5 sub-checks) |
| SB-6 | Pure latent branch produces `projected_value` (≠ actual output) | PASS (4 sub-checks) |
| SB-7 | Unresolved snapshot → `projected_failure`, not actual failure | PASS (4 sub-checks) |
| SB-8 | Effect/escape refused; no side effect | PASS (3 sub-checks) |
| SB-9 | `tbackend_read` refused; no live Ledger/TBackend read | PASS (3 sub-checks) |
| SB-10 | Nested `if_expr` projection is lazy inside dry-run | PASS (3 sub-checks) |
| SB-11 | Execution-summary citation is actual-path read-only context only | PASS (4 sub-checks) |
| SB-12 | Hand-authored fixture is Tier 0 legacy fallback only; not sole authority | PASS (3 sub-checks) |
| SB-13 | Forbidden vocabulary scan passes | PASS (3 sub-checks) |
| SB-14 | Source/digest chain complete and stable | PASS (5 sub-checks) |
| SB-15 | Closed-surface scan | PASS (6 sub-checks) |

**Total: 61/61 PASS**

---

## Key Findings

### SB-3: Structured `source_branch_intention_ref`

```json
{
  "kind":          "source_branch_intention_ref",
  "source_kind":   "proof_derived_from_semanticir",
  "source_path":   "semanticir_risk_gate_v0.json",
  "source_digest": "sha256:…",
  "if_expr_id":    "if:risk_gate_source_backed_v0",
  "branch_label":  "then",
  "branch_role":   "latent",
  "expr_kind":     "apply",
  "derivation":    "proof-local",
  "canonical":     false,
  "authority":     { all false }
}
```

### SB-5: Enhanced `premise_set` with Required `assumed_condition_source`

```json
{
  "kind":                     "counterfactual_premise_set",
  "assumed_condition":        true,
  "assumed_condition_source": "explicit_proof_request",
  "input_snapshot_ref":       { "digest": "sha256:…", "mutable": false },
  "assumption_refs":          ["risk_threshold_is_valid"],
  "authority":                { all false },
  "premise_set_digest":       "sha256:…"
}
```

### SB-7: Unresolved Snapshot → `projected_failure`

Empty snapshot `{}` with `apply(add, ref("a"), ref("b"))`: `ref("a")` not found in scope → `{refused: "ref_not_in_scope:a", kind: "projection_refusal"}`. Not an actual runtime failure.

### SB-10: Laziness Inside Source-Backed Dry-Run

Nested `if_expr(lit(true), apply(add,3,4), escape("laziness_trap"))`:
- `projected_value: 7` (then_branch only evaluated)
- `escape("laziness_trap")` else_branch never reached
- If eager: escape refusal would set `projected_failure`

### SB-14: Digest Chain Stability

`premise_set_digest` and `projection_digest` both recompute stably:
- Omit the `*_digest` key, re-serialize, re-hash → same value
- Source artifact on-disk digest matches in-memory computed value

---

## Evidence Source Tier Policy Applied

| Tier | Source used | Notes |
|------|------------|-------|
| Tier 1 (primary) | Proof-owned SemanticIR-shaped JSON | All 4 source artifacts |
| Tier 0 (legacy fallback) | Hand-authored fixture label | Explicitly labeled `not_sole_proof_authority:true` |
| Tier 2 (actual-path citation) | R209 execution summary | Read-only `execution_summary_ref`; `latent_execution:false` |
| Tier 3 (closed) | `CompilerResult`/`CompilationReport` | Not loaded or used |
| Tier 4 (closed) | Live runtime | Not executed |

---

## Closed Surfaces Verified

| Surface | Status |
|---------|--------|
| `lib/**` edits | Closed — no lib files loaded or modified |
| Runtime/evaluator/RuntimeSmoke | Closed — not loaded |
| `tbackend_read` live execution | Closed — refused as `projection_refusal` |
| Effect/escape execution | Closed — refused as `projection_refusal` |
| `CompilerResult`/`CompilationReport` modification | Closed — scanned, no new keys |
| Spec body chapters | Closed — scanned, no SB- or source_branch_intention_ref entries |
| PROP-032 | Closed — not touched |
| Public API/CLI | Closed |
| Release commands | Closed |
| Spark integration | Closed |

---

## Summary JSON

```text
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json
sha256:e9474cf0ac5bda39a9af6a748d966722f9c43c5911aeb2fa25ec36e6da0a2178
```

---

## Command Matrix Output

```bash
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
# → Syntax OK

ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
# → PASS branch_conditional_counterfactual_audit_level2_source_backed_proof_v0
# → checks_total=61 checks_pass=61 checks_fail=0
```

---

## Disclaimers (Binding per C1-A)

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
source evidence from proof-owned SemanticIR-shaped artifacts != canonical schema
source_branch_intention_ref != CompilerResult or CompilationReport field
dry_run_projection != public_runtime_support
Level2_source_backed_proof != public_counterfactual_support
Tier 0 hand-authored fixtures are legacy fallback only; not primary source authority
Assumptions-shaped premise refs are proof-local labels only; not PROP-032 branch syntax or receipt assumption_refs
```

---

## Exact Dispatch

```text
Card: S3-R211-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
Route: UPDATE
Status: done
Depends on:
- S3-R211-C1-A
```

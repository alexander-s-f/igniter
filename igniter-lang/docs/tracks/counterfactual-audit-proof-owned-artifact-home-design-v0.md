# Counterfactual Audit Proof-Owned Artifact Home Design v0

Card: S3-R218-C2-I  
Agent: `[Implementation Agent]`  
Role: `implementation-agent`  
Track: `counterfactual-audit-proof-owned-artifact-home-design-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-31

Depends on:
- S3-R218-C1-A

---

## Summary

Implements Option B: a proof-owned artifact directory for source-backed Level 2
counterfactual dry-run evidence, carrying explicit no-authority flags across all
artifacts. Proves AH-1..AH-10 (47 checks, all PASS).

Governing principle:

```text
Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
Artifact homes must be explicit, non-canonical, and proof-owned.
```

---

## Authorized Write Scope

Written:
- `igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/counterfactual_audit_proof_owned_artifact_home_v0.rb`
- `igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/` (artifact home + summary)
- `igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md` (this file)

No `lib/**`, spec chapters, PROP-032, runtime/evaluator, RuntimeSmoke, R211
evidence, or any closed surface was modified.

---

## Option B Artifact Home Shape

```
experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/artifact_home/
├── artifact_home_manifest.json     ← no-authority index with all required flags
├── source_refs/
│   ├── semanticir_score_gate_v0.json      ← proof-owned SemanticIR-shaped source artifact
│   └── source_ref_score_gate_then_v0.json ← structured source_branch_intention_ref
├── input_snapshots/
│   └── input_snapshot_score_v0.json       ← frozen proof-local snapshot {x:3,y:4}
├── premise_sets/
│   └── premise_set_score_gate_v0.json     ← explicit premise set with assumed_condition_source
└── projections/
    └── projection_score_gate_then_v0.json ← projection envelope (multiply→12)
```

### No-Authority Manifest

The `artifact_home_manifest.json` is the Option B index. It carries:

```json
{
  "kind":        "proof_owned_artifact_home_manifest",
  "option_label": "Option B: proof-owned artifact directory with no compiler/report authority",
  "proof_owned": true,
  "canonical":   false,
  "authority": {
    "canonical":             false,
    "runtime_authority":     false,
    "report_authority":      false,
    "cache_authority":       false,
    "dependency_authority":  false,
    "public_api_authority":  false,
    "compiler_emitted":      false,
    "spark_authority":       false,
    "production_authority":  false
  },
  "evidence_index":          { "source_refs": [...], "input_snapshots": [...], ... },
  "non_claim_block":         "projected_value != actual_output ...",
  "snapshot_privacy_posture": "No persistence authority. No privacy-policy authority.",
  "digest_policy":           "SHA-256 content-addressed; no cache/dependency authority",
  "manifest_digest":         "sha256:…"
}
```

---

## New Evidence Packet (Distinct from R211)

| Dimension | R211 main projection | C2-I new packet |
|-----------|---------------------|-----------------|
| if_expr_id | `if:risk_gate_source_backed_v0` | `if:score_gate_artifact_home_v0` |
| operator | `stdlib.integer.add` | `stdlib.integer.multiply` |
| variables | `{a:10, b:5}` | `{x:3, y:4}` |
| projected_value | 15 | **12** |
| source artifact digest | sha256:… (R211 file) | sha256:… (new file) |

This is a fresh evidence packet, not a republication of R211.

---

## AH-1..AH-10 Proof Matrix

| ID | Check | Result |
|----|-------|--------|
| AH-1 | Option B home is proof-owned and non-canonical | PASS (4 sub-checks) |
| AH-2 | No-authority manifest with all 9 required false flags | PASS (9 sub-checks) |
| AH-3 | R211 evidence remains immutable (61/61 PASS confirmed) | PASS (4 sub-checks) |
| AH-4 | New evidence packet distinct from R211 | PASS (3 sub-checks) |
| AH-5 | Digest recomputation/verification policy | PASS (5 sub-checks) |
| AH-6 | Input snapshot privacy/persistence posture | PASS (4 sub-checks) |
| AH-7 | Premise set stance (no PROP-032 widening; no cache/dependency) | PASS (4 sub-checks) |
| AH-8 | Projection trace is proof/debug/explanatory only | PASS (3 sub-checks) |
| AH-9 | Projected value/failure disclaimers | PASS (4 sub-checks) |
| AH-10 | Closed-surface scan | PASS (7 sub-checks) |

**Total: 47/47 PASS**

---

## Key Findings

### AH-2: Authority Flags

All 9 required false flags verified on the manifest and propagated to every artifact:
`canonical`, `runtime_authority`, `report_authority`, `cache_authority`,
`dependency_authority`, `public_api_authority`, `compiler_emitted`,
`spark_authority`, `production_authority`.

### AH-3: R211 Immutability

R211 source-backed proof summary read as historical evidence:
- `checks_pass: 61`, `checks_fail: 0`, `status: "PASS"` — intact.
- All 6 R211 source artifact files exist unchanged.
- R211 regression rerun: 61/61 PASS.

### AH-5: Digest Policy

- All 6 digests (`SA_DIGEST`, `SS_DIGEST`, `SR_DIGEST`, `PS_DIGEST`, `PROJ_DIGEST`, `MANIFEST_DIGEST`) start with `"sha256:"`.
- `manifest_digest`, `projection_digest`, `premise_set_digest` all recompute stably (same content → same SHA-256).
- On-disk source artifact digest matches in-memory computed value.
- Digests carry no cache/dependency/compiler authority.

### AH-6: Snapshot Privacy/Persistence Posture

- `mutable: false`
- `privacy_policy_authority: false`
- `persistence_authority: false`
- Explicit note: "Proof-local frozen snapshot; no persistence authority; no privacy-policy authority; not actual runtime input"

### AH-9: Projection Disclaimers

- `projected_value_is_not_actual_output: true`
- `projected_failure_is_not_actual_failure: true`
- `no_authority_disclaimer` present
- `projected_value: 12` (multiply(3,4)) — not an actual runtime output

---

## Command Matrix Output

```bash
ruby -c igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/counterfactual_audit_proof_owned_artifact_home_v0.rb
# → Syntax OK

ruby igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/counterfactual_audit_proof_owned_artifact_home_v0.rb
# → PASS counterfactual_audit_proof_owned_artifact_home_v0
# → checks_total=47 checks_pass=47 checks_fail=0

# Read-only R211 regression:
ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
# → PASS branch_conditional_counterfactual_audit_level2_source_backed_proof_v0
# → checks_total=61 checks_pass=61 checks_fail=0
```

---

## Closed Surfaces Verified

| Surface | Status |
|---------|--------|
| `lib/**` edits | Closed — no lib files loaded or modified |
| Runtime/evaluator/RuntimeSmoke | Closed — not loaded |
| `CompilerResult`/`CompilationReport` modification | Closed — scanned, no artifact_home keys |
| `.igapp` outside experiment | Closed — no .igapp files created |
| Spec body chapters | Closed — not touched |
| PROP-032 | Closed — not touched |
| R211 evidence mutation | Closed — read-only citation; 61/61 PASS confirmed |
| Public API/CLI | Closed |
| Release commands | Closed |
| Spark integration | Closed |

---

## Summary JSON

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/counterfactual_audit_proof_owned_artifact_home_v0_summary.json
sha256:2e5628f3f2c61561d7e7ef3ebc6b085ff551c9e16a7ad6f84279660b1c1253d7
```

---

## Non-Claim Block (Binding per C1-A)

```text
This artifact home is not canonical SemanticIR schema, not a CompilerResult or
CompilationReport field, not report/result/receipt/CompatibilityReport shape,
not runtime behavior, not live non-selected branch evaluation, not public
counterfactual audit support, and not Spark/API/CLI support.

projected_value != actual_output
projected_failure != actual_runtime_failure

source_backed_dry_run_projection is proof-local and non-canonical.
source_branch_intention_ref is not emitted by compiler surfaces.
SHA-256 digest-addressed refs carry no cache/dependency/compiler authority.
Assumptions-shaped premise refs are proof-local labels only; not PROP-032
branch syntax and not receipt assumption_refs.
```

---

## Compact Handoff for C3-X / C4-A

**What C2-I proved:**

Option B (proof-owned artifact directory) can carry source-backed Level 2
counterfactual dry-run evidence with all authority flags explicitly false.
The artifact home has:
- a versioned directory under `experiments/`
- a manifest/index with all 9 required false flags
- digest-addressed source refs, snapshots, premise sets, and projection envelopes
- explicit snapshot privacy/persistence posture
- projection disclaimers (`projected_value != actual_output`)
- a closed-surface scan proving no lib/runtime/report/API mutation

**What remains open:**

- C3-X pressure review of this design/proof
- C4-A acceptance decision
- Option C (internal docs index) as companion route after/alongside B
- Option D (internal non-canonical carrier) held until B clarifies authority fields
- All live implementation, runtime/report/API, public/Spark/release surfaces remain closed

---

## Exact Dispatch

```text
Card: S3-R218-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: counterfactual-audit-proof-owned-artifact-home-design-v0
Route: UPDATE
Status: done
Depends on:
- S3-R218-C1-A
```

# Counterfactual Audit Proof-Owned Artifact Home Design Acceptance Decision v0

Card: S3-R218-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-proof-owned-artifact-home-design-acceptance-decision-v0
Route: UPDATE
Status: done / accepted-option-b-proof-owned-artifact-home
Date: 2026-05-31

Depends on:
- S3-R218-C2-I
- S3-R218-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-proof-owned-artifact-home-design-authorization-review-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-proof-owned-artifact-home-design-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-proof-owned-artifact-home-design-pressure-v0.md`
- `igniter-lang/experiments/
  counterfactual_audit_proof_owned_artifact_home_v0/out/
  counterfactual_audit_proof_owned_artifact_home_v0_summary.json`
- `igniter-lang/docs/tracks/stage3-round217-status-curation-v0.md`

---

## Decision

Decision:

```text
accept Option B proof-owned artifact-home design/proof
accept C3-X pressure verdict: PASS, no blockers, no notes
recognize proof-owned artifact home as non-canonical evidence only
do not authorize live implementation
do not authorize runtime/report/API/public/Spark authority
```

Accepted evidence class:

```text
proof-owned, non-canonical Option B artifact home evidence
```

This does not create runtime, report, API, public, Spark, release, cache,
dependency, compiler-emitted, or production authority.

---

## Exact Changed Files

C2-I changed only the authorized scope:

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/
  counterfactual_audit_proof_owned_artifact_home_v0.rb
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/artifact_home_manifest.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/source_refs/semanticir_score_gate_v0.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/source_refs/source_ref_score_gate_then_v0.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/input_snapshots/input_snapshot_score_v0.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/premise_sets/premise_set_score_gate_v0.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  artifact_home/projections/projection_score_gate_then_v0.json
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/
  counterfactual_audit_proof_owned_artifact_home_v0_summary.json
igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md
```

C4-A adds this decision doc only.

---

## Accepted Proof Results

Command matrix:

```text
ruby -c igniter-lang/experiments/
  counterfactual_audit_proof_owned_artifact_home_v0/
  counterfactual_audit_proof_owned_artifact_home_v0.rb
PASS: Syntax OK

ruby igniter-lang/experiments/
  counterfactual_audit_proof_owned_artifact_home_v0/
  counterfactual_audit_proof_owned_artifact_home_v0.rb
PASS: 47/47

ruby igniter-lang/experiments/
  branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/
  branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
PASS: 61/61 read-only regression
```

Proof matrix:

```text
AH-1..AH-10: PASS
checks_total: 47
checks_pass: 47
checks_fail: 0
failed_checks: []
```

Accepted digests:

```text
manifest_digest:
sha256:f61ca7941ff064358eb09a1629e0b382871acb7b8ecddfc51963e770930515d3

summary_digest:
sha256:2e5628f3f2c61561d7e7ef3ebc6b085ff551c9e16a7ad6f84279660b1c1253d7
```

---

## Accepted Artifact-Home Status

Artifact home:

```text
experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/artifact_home/
```

Status:

```text
accepted as proof-owned, non-canonical evidence home
```

Authority:

```text
evidence-only
not runtime authority
not report authority
not cache/dependency authority
not public API authority
not compiler-emitted authority
not Spark authority
not production authority
```

Required no-authority flags are accepted as present and false:

```text
canonical: false
runtime_authority: false
report_authority: false
cache_authority: false
dependency_authority: false
public_api_authority: false
compiler_emitted: false
spark_authority: false
production_authority: false
```

---

## Accepted Evidence Details

Digest recomputation:

- manifest digest recomputes stably;
- projection digest recomputes stably;
- premise-set digest recomputes stably;
- on-disk source artifact digest matches computed digest;
- digests remain evidence anchors only.

R211 immutability:

```text
R211 remains historical evidence only
R211 PASS 61/61 confirmed
R211 digest preserved:
sha256:e9474cf0ac5bda39a9af6a748d966722f9c43c5911aeb2fa25ec36e6da0a2178
```

Projected value/failure disclaimer:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

Snapshot posture:

```text
mutable: false
persistence_authority: false
privacy_policy_authority: false
production_data: false
```

Closed-surface scan:

```text
lib_files_loaded: false
runtime_smoke_loaded: false
compiled_program_loaded: false
compiler_result_modified: false
compilation_report_modified: false
igapp_created_outside_experiment: false
spark_or_cli_loaded: false
spec_chapters_modified: false
```

---

## C3-X Acceptance

C3-X verdict:

```text
PASS
no blockers
no non-blocking acceptance notes
```

C3-X confirms:

- C2-I stayed experiments-only;
- Option B remains proof-owned and non-canonical;
- all 9 authority flags are present and false;
- R211 evidence remained immutable;
- digest and snapshot policies are clear;
- no public/Spark/API/release claims leaked.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is Option B design/proof accepted? | Yes. |
| Is the artifact home proof-owned evidence only? | Yes. |
| Is the artifact home canonical? | No. |
| Does this create runtime authority? | No. |
| Does this create report/API/public/Spark authority? | No. |
| May Option C companion/index open next? | Yes, as design-only authorization review. |
| Does Option D carrier remain held? | Yes. |
| Do Options E/F remain closed? | Yes. |
| Is live implementation authorized? | No. |
| Is release execution authorized? | No. |

---

## Next Route Decision

Chosen next route:

```text
counterfactual-audit-docs-status-index-companion-authorization-review-v0
```

Why:

- R218 accepted the proof-owned artifact home as evidence-only;
- Option C was explicitly allowed as a companion/index route after or alongside
  Option B;
- a low-authority internal index reduces rediscovery drift before Runtime/Bridge
  or carrier work;
- it can remain docs/status-only and avoid report/runtime/API authority.

Do not open next:

- Runtime/Bridge architecture survey first, unless Portfolio redirects;
- internal non-canonical carrier options;
- compiler-emitted artifact design;
- report/result/receipt sidecar design;
- live implementation.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R219-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-docs-status-index-companion-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R218-C4-A
```

Goal:

```text
Decide whether a bounded Option C internal docs/status index companion may
begin for the accepted Option B proof-owned artifact home, without creating
canonical, runtime, report, API, public, Spark, release, cache, or dependency
authority.
```

Candidate allowed files, if authorized:

```text
igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-v0.md
igniter-lang/docs/current-status.md
```

Default closed unless explicitly named by C1-A:

```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
body spec chapters
public docs
PROP-032
```

Required boundary:

- cite Option B as proof-owned, non-canonical evidence only;
- include no-authority flags;
- avoid canon-by-repetition wording;
- keep report/runtime/API/Spark/release claims closed;
- preserve Option D held and Options E/F closed.

---

## Remaining Closed Surfaces

Remain closed:

- live implementation;
- `lib/**`;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifests, sidecars, artifact hashes, and goldens outside the
  experiment-owned proof directory;
- body spec chapters, public docs, PROP-032 unless separately authorized;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

---

## Compact Summary

R218 accepts the Option B proof-owned artifact-home design/proof. The artifact
home is now accepted as proof-owned, non-canonical evidence only, with all
authority flags false and 47/47 checks passing. It creates no runtime, report,
API, public, Spark, release, cache, dependency, compiler-emitted, or production
authority. Next recommended route is a bounded Option C docs/status index
companion authorization review.

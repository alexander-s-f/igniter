# Counterfactual Audit Proof-Owned Artifact Home Design Authorization Review v0

Card: S3-R218-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-proof-owned-artifact-home-design-authorization-review-v0
Route: UPDATE
Status: done / authorized-experiments-only-design-proof
Date: 2026-05-31

Depends on:
- S3-R217-C4-A

---

## IDD Classification

Mode:

```text
standard / controlled-flow boundary
```

This card authorizes the smallest artifact that reduces drift:

```text
experiments-only proof/design track
```

It does not change behavior authority. Evidence remains evidence.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round217-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-artifact-home-and-authority-decision-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-artifact-home-and-authority-options-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-runtime-artifact-authority-facts-packet-v0.md`
- `igniter-lang/docs/discussions/
  counterfactual-audit-artifact-home-and-authority-pressure-v0.md`
- `igniter-lang/docs/tracks/
  branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `igniter-lang/experiments/
  branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/
  branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json`

---

## Decision

Decision:

```text
authorize bounded experiments-only design/proof
do not authorize live implementation
do not authorize lib/** edits
do not authorize compiler/runtime/report/API/public/Spark/release authority
```

R218-C2-I may begin in this round.

The authorized card is Option B only:

```text
proof-owned artifact directory with no compiler/report authority
```

Option B remains:

```text
proof-owned
non-canonical
experiments-only
evidence-only
not implementation authority
```

---

## Authorized C2-I Boundary

Card:

```text
S3-R218-C2-I
```

Agent:

```text
[Implementation Agent]
```

Track:

```text
counterfactual-audit-proof-owned-artifact-home-design-v0
```

Allowed write scope:

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/**
igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md
```

Forbidden write scope:

```text
igniter-lang/lib/**
igniter-lang/docs/spec/**
igniter-lang/docs/language-spec.md
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/public/**
```

Also closed:

- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior;
- CompilerResult and CompilationReport;
- report/result/receipt/CompatibilityReport fields;
- `.igapp`, manifests, sidecars, artifact hashes, or goldens outside the
  experiment-owned directory;
- public API/CLI, Spark, release evidence, production, or demo behavior.

---

## Required Artifact Home Candidate

C2-I must design a proof-owned artifact home under:

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/
```

The home may contain experiment-owned outputs only, such as:

- proof-owned source artifact copies or generated fixtures;
- no-authority manifest or index;
- digest records;
- projection envelopes;
- summary JSON;
- closed-surface scan output.

The home must not be described as:

- canonical SemanticIR schema;
- compiler output;
- `.igapp` output;
- report/result/receipt output;
- RuntimeSmoke support;
- public API or Spark evidence;
- release evidence.

---

## Required Authority Shape

C2-I must carry these default false flags where an artifact, manifest, ref, or
projection envelope is produced:

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

Required source-ref stance:

- proof-owned evidence ref only;
- digest-addressed;
- not CompilerResult;
- not CompilationReport;
- not canonical schema.

Required input snapshot stance:

- frozen proof evidence only;
- no persistence authority;
- no privacy policy authority;
- explicit privacy/persistence note required.

Required premise-set stance:

- premise capsule only;
- no PROP-032 widening;
- no branch-level syntax;
- no receipt or dependency/cache authority.

Required projection trace stance:

- proof/debug/explanatory only;
- no cache authority;
- no dependency authority;
- no report/runtime authority.

Required projected value/failure disclaimers:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

---

## R211 Parity / Replay Expectations

C2-I must not mutate R211 evidence.

Required:

- read R211 source-backed proof summary as historical evidence;
- preserve R211 PASS `61/61` as historical fact;
- verify or replay enough artifact-home logic to prove Option B can carry the
  same evidence class without promoting authority;
- record whether digests are recomputed or copied as evidence refs;
- record whether any R211 source artifacts are copied, mirrored, or cited;
- prove historical R211 files remain unchanged.

The new C2-I outputs must be a new evidence packet, not a rewrite of R211.

---

## Command Matrix

Required:

```text
ruby -c \
  igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/\
counterfactual_audit_proof_owned_artifact_home_v0.rb
ruby \
  igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/\
counterfactual_audit_proof_owned_artifact_home_v0.rb
```

Recommended read-only regression:

```text
ruby \
  igniter-lang/experiments/\
branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/\
branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
```

C2-I may skip the recommended regression only with an explicit reason.

---

## Result Packet Shape

C2-I must write a summary JSON under the experiment `out/` directory.

Minimum summary keys:

```text
status
checks_total
checks_pass
checks_fail
failed_checks
artifact_home
authority_flags
r211_immutability
digest_policy
snapshot_privacy_posture
projection_disclaimers
closed_surface_scan
non_claims
```

Track doc must include:

- exact changed files;
- command matrix result;
- artifact-home shape;
- no-authority field status;
- digest recomputation or reference policy;
- input snapshot privacy/persistence posture;
- projected value/failure disclaimer status;
- closed-surface scan result;
- remaining closed surfaces.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| Is experiments-only write scope enough? | Yes. |
| Does `lib/**` remain closed? | Yes. |
| Does compiler pipeline remain closed? | Yes. |
| Does RuntimeSmoke remain closed? | Yes. |
| Do report/result/receipt surfaces remain closed? | Yes. |
| Does `.igapp` remain closed? | Yes, outside experiment-owned outputs. |
| Do public API/CLI, Spark, release surfaces remain closed? | Yes. |
| Does Option B remain non-canonical and proof-owned? | Yes. |
| Does Option C remain separate? | Yes. |
| Does Option D remain held? | Yes. |
| Do Options E/F remain comparison-only? | Yes. |

---

## Closed Surfaces

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
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

---

## Compact Summary

R218-C1-A authorizes the smallest useful next contract: an experiments-only
Option B design/proof for a proof-owned, non-canonical artifact home. It does
not authorize implementation or any runtime/report/API/public/Spark/release
authority. C2-I may begin with the exact write scope and command matrix above.

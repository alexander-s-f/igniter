# Counterfactual Audit Docs Status Index Companion Authorization Review v0

Card: S3-R219-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-docs-status-index-companion-authorization-review-v0
Route: UPDATE
Status: done / authorized-bounded-docs-status-sync
Date: 2026-05-31

Depends on:
- S3-R218-C4-A

---

## IDD Classification

Mode:

```text
standard / docs-status companion
```

Smallest useful artifact:

```text
bounded internal index + compact current-status delta
```

This card authorizes discoverability work only. It does not change authority.

---

## Inputs Read

- `igniter-lang/docs/tracks/
  counterfactual-audit-proof-owned-artifact-home-design-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-proof-owned-artifact-home-design-v0.md`
- `igniter-lang/experiments/
  counterfactual_audit_proof_owned_artifact_home_v0/out/
  counterfactual_audit_proof_owned_artifact_home_v0_summary.json`
- `igniter-lang/docs/tracks/stage3-round217-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Decision

Decision:

```text
authorize bounded docs/status index sync
authorize docs/current-status.md compact delta
authorize track doc for Option C companion
do not authorize Heat Map or Spec README edits
do not authorize body spec, public docs, or PROP-032 edits
do not authorize implementation or release/public claims
```

R219-C2-I may begin in this round.

The authorized sync must cite Option B as:

```text
proof-owned, non-canonical evidence only
```

It must not create canonical, runtime, report, API, public, Spark, release,
cache, dependency, compiler-emitted, or production authority.

---

## Authorized C2-I Boundary

Card:

```text
S3-R219-C2-I
```

Agent:

```text
[Implementation Agent]
```

Track:

```text
counterfactual-audit-docs-status-index-companion-v0
```

Allowed write scope:

```text
igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-v0.md
igniter-lang/docs/current-status.md
```

Forbidden files:

```text
igniter-lang/lib/**
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/language-spec.md
igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md
public docs
body spec chapters
```

Also closed:

- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior;
- CompilerResult and CompilationReport;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- `.igapp`, manifests, sidecars, artifact hashes, and goldens;
- public API/CLI, Spark, release evidence, production, or demo behavior.

---

## Required Wording

Required index wording:

```text
Option B proof-owned artifact home is accepted as proof-owned, non-canonical
evidence only.
```

Required authority wording:

```text
canonical:false
runtime_authority:false
report_authority:false
cache_authority:false
dependency_authority:false
public_api_authority:false
compiler_emitted:false
spark_authority:false
production_authority:false
```

Required disclaimer wording:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

Required status wording:

```text
Option C is an internal docs/status index companion only.
It improves discoverability and reduces rediscovery drift.
It does not make Option B canonical.
```

---

## Forbidden Wording

Forbidden wording includes:

- `canonical artifact home`;
- `runtime support`;
- `public counterfactual support`;
- `report support`;
- `API support`;
- `Spark support`;
- `release evidence`;
- `production behavior`;
- `CompilerResult field`;
- `CompilationReport field`;
- `cache authority`;
- `dependency authority`;
- `actual output` for `projected_value`;
- `actual runtime failure` for `projected_failure`.

C2-I must run a forbidden wording scan over touched files and record the result.

---

## Evidence Citation Policy

C2-I may cite:

- R218 acceptance decision;
- Option B track doc;
- Option B summary JSON;
- manifest digest;
- summary digest;
- artifact home path.

C2-I must not:

- recalculate or rewrite Option B evidence;
- mutate Option B experiment outputs;
- treat Option B as compiler output;
- cite Option B as public/runtime/report/API readiness.

---

## Target-Specific Stance

`docs/current-status.md`:

```text
authorized for compact delta only
```

Allowed current-status delta:

- one concise status line or compact paragraph under Compiler Internals;
- optional compact landed-round note if the local file pattern requires it;
- must include evidence-only/non-canonical wording.

Heat Map:

```text
closed
```

Spec README:

```text
closed
```

Body spec chapters:

```text
closed
```

Public docs:

```text
closed
```

PROP-032:

```text
closed
```

---

## Proof Matrix

C2-I must prove:

| ID | Requirement |
| --- | --- |
| IDX-1 | Track doc created in allowed path. |
| IDX-2 | Current-status delta stays compact and internal. |
| IDX-3 | Option B cited as proof-owned/non-canonical/evidence-only. |
| IDX-4 | All false no-authority flags represented. |
| IDX-5 | Manifest and summary digests cited. |
| IDX-6 | Projected value/failure disclaimers preserved. |
| IDX-7 | Option D held and Options E/F closed. |
| IDX-8 | Forbidden wording scan PASS. |
| IDX-9 | Closed-surface scan PASS. |
| IDX-10 | No public/runtime/report/API/Spark/release claim. |

---

## Command Matrix

Required:

```text
rg -n "<forbidden scan pattern>" \
  igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-v0.md \
  igniter-lang/docs/current-status.md
```

Recommended:

```text
git diff --check
```

No code/proof runtime commands are required by this docs-status authorization.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| May `docs/current-status.md` be edited? | Yes, compact delta only. |
| May Heat Map be edited? | No. |
| May Spec README be edited? | No. |
| Do body spec chapters remain closed? | Yes. |
| Do public docs and PROP-032 remain closed? | Yes. |
| Does Option B remain evidence-only and non-canonical? | Yes. |
| Does Option D remain held? | Yes. |
| Do Options E/F remain comparison-only? | Yes. |
| Do runtime/report/API/public/Spark/release claims remain closed? | Yes. |

---

## Compact Summary

R219-C1-A authorizes a bounded Option C docs/status index companion. The only
allowed files are the companion track doc and a compact `current-status` delta.
The sync must reduce rediscovery drift without making Option B canonical or
creating runtime/report/API/public/Spark/release/cache/dependency authority.

# Stage3 Round217 Status Curation v0

Card: S3-R217-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round217-status-curation-v0
Route: SUMMARY
Status: done
Date: 2026-05-31

Depends on:
- S3-R217-C1-D
- S3-R217-C2-P1
- S3-R217-C3-X
- S3-R217-C4-A

---

## Inputs Read

- `igniter-lang/docs/cards/S3/S3-R217.md`
- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-options-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-artifact-authority-facts-packet-v0.md`
- `igniter-lang/docs/discussions/counterfactual-audit-artifact-home-and-authority-pressure-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round216-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Outcome Table

| Card | Output | Status |
| --- | --- | --- |
| S3-R217-C1-D | Artifact-home / authority options matrix | done; Option B preferred; E/F comparison-only |
| S3-R217-C2-P1 | Runtime artifact authority facts packet | done; Option B ranked best next route |
| S3-R217-C3-X | Pressure review | PASS; no blockers; AN-1 scope clarification accepted by C4-A |
| S3-R217-C4-A | Architect decision | accepted Option B as next design/proof target only |
| S3-R217-C5-S | Status curation | done; current Main Line status updated compactly |

---

## Curated Status

R217 is accepted.

Accepted state:

- C1-D artifact-home / authority options matrix accepted;
- C2-P1 runtime artifact authority facts packet accepted;
- C3-X verdict accepted as PASS with no blockers;
- Option B accepted as next bounded design/proof route target;
- Option B is not an implemented artifact home;
- no implementation, public claim, release execution, runtime/report/API, cache,
  dependency, Spark, or production authority opened.

Selected artifact-home / authority stance:

```text
Option B: proof-owned artifact directory with no compiler/report authority
```

Authority posture:

```text
proof-owned
non-canonical
no runtime authority
no report authority
no cache/dependency authority
no public API authority
no compiler-emitted authority
no Spark or production authority
```

Required default flags for any future Option B artifact:

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

## Option Disposition

| Option | Disposition |
| --- | --- |
| A. Permanent proof-local-only evidence | accepted as safe fallback baseline |
| B. Proof-owned artifact directory | accepted as next design/proof target only |
| C. Internal docs/status index | allowed only as companion/index route after or alongside B |
| D. Internal non-canonical carrier | held until B clarifies home and authority fields |
| E. Compiler-emitted artifact | comparison-only; closed as next route |
| F. Report/result/receipt sidecar | comparison-only; closed as next route |

C3-X AN-1 was resolved by C4-A: the Option B route is design-only and
experiments-only. Accepting Option B as the next route is not implementation
authorization.

---

## Closed Surfaces

Remain closed after R217:

- implementation and `lib/**` edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- RuntimeSmoke feature/support claims;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifests outside experiment scope, sidecars, artifact hashes,
  goldens;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

---

## Current-Status Delta

`igniter-lang/docs/current-status.md` was updated with a compact R217 delta:

- artifact-home / authority options accepted;
- Option B selected as next design/proof target only;
- Option A fallback, Option C companion/index only, Option D held, and Options
  E/F comparison-only recorded;
- R218 authorization-review boundary recorded.

No card index, proposal, gate, spec, code, runtime, or public docs files were
changed.

---

## Exact Next Route

Open:

```text
Card: S3-R218-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-proof-owned-artifact-home-design-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R217-C4-A
```

Goal:

```text
Decide whether a bounded Option B proof-owned artifact-home design/proof card
may begin, with experiments-only write scope and no implementation authority.
```

Candidate later card, only if authorized by R218-C1-A:

```text
Card: S3-R218-C2-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: counterfactual-audit-proof-owned-artifact-home-design-v0
Route: UPDATE
```

Candidate later write scope:

```text
igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/**
igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md
```

---

## Handoff

R217 closes the L3 artifact-home / authority options decision. The next round
must first decide whether the Option B experiments-only design/proof card may
begin. It must not treat Option B as already implemented, and it must not open
`lib/**`, compiler pipeline, RuntimeSmoke behavior, report/result/receipt
surfaces, `.igapp`, public API/CLI, Spark, release evidence, public docs, cache,
dependency, or production authority.

# Stage 3 Round 234 Status Curation v0

Card: S3-R234-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round234-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-06-02

Depends on:
- S3-R234-C4-A

---

## Executive Summary

R234 accepts the bounded pre-v1 experimental `igc run` Slice 0
implementation.

The accepted command is implementation evidence only for a narrow delegated
experimental `.igapp` run path. It does not create public runtime support,
Reference Runtime support, stable API authority, production readiness, Spark
integration, release evidence, compiler passport emission, `.igbin` execution,
RuntimeSmoke productization, or public performance claims.

Exact next route:

```text
S3-R235-C1-A
experimental-igc-run-slice0-quickstart-docs-authorization-review-v0
```

This next route is an authorization review for bounded quickstart/docs exposure
only. It must not edit docs itself or widen runtime authority.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice0-implementation-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round233-status-curation-v0.md`
- `igniter-lang/experiments/experimental_igc_run_v0/out/summary.json`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R234-C1-A | authorized | Bounded Slice 0 implementation authorized for `.igapp` + explicit passport/input/runtime/out + `--experimental`. |
| S3-R234-C2-I | done / PASS | Slice 0 implemented in authorized scope; `bin/igc` unchanged; 20/20 IGR PASS. |
| S3-R234-C3-X | PASS | Pressure accepts unconditionally; no blockers; CF-1/CF-2 informational only. |
| S3-R234-C4-A | accepted | Accepts implementation closure as bounded pre-v1 delegated-runtime Slice 0 run evidence only. |
| S3-R234-C5-S | done | Current status updated with compact R234 delta and exact R235 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
accepted
```

What changed in R234:

```text
Experimental igc run Slice 0 moved from accepted design to accepted bounded
implementation evidence.
```

Accepted command:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Accepted implementation status:

```text
pre-v1 experimental Slice 0 command vocabulary accepted
mandatory --experimental
explicit .igapp input
explicit proof-local passport
explicit input JSON object
explicit delegated runtime selector
explicit output path
machine-readable experimental_igc_run_v0_result packet
```

Proof status:

```text
IGR-1..IGR-20: PASS
checks_total: 20
checks_pass: 20
checks_fail: 0
positive result: outputs.sum == 42
compile regression: PASS / runtime_smoke null
```

Changed files accepted by C4-A:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/experiments/experimental_igc_run_v0/**
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
igniter-lang/docs/discussions/experimental-igc-run-slice0-implementation-pressure-v0.md
```

`bin/igc` status:

```text
unchanged
existing entrypoint dispatches through IgniterLang::CLI.run(ARGV)
```

---

## Boundary Status

Implementation / authorization distinction:

```text
R234 implementation accepted only for bounded Slice 0.
No further implementation is authorized by this status curation.
Future docs exposure requires S3-R235-C1-A authorization.
```

Passport validation status:

```text
accepted
fail-closed
artifact_ref checked
artifact_digest recomputed and checked
artifact_kind limited to igapp_dir
output_contract must be present and not deferred
output_contract.contract_name required
runtime_target_kind / authority_status / non_claims checked
```

Delegated runtime selector status:

```text
delegated-experimental:ivm-proof accepted only as explicit pre-v1 selector
for Slice 0.
It resolves only to:
  igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
  RuntimeMachineMemoryProof::CompiledProgram.load_igapp(...)
  program.validate!
  program.evaluate_contract(...)
```

RuntimeSmoke status:

```text
closed
not invoked
not referenced by Slice 0 helper
runtime_smoke.rb unchanged
```

`.igbin` status:

```text
closed
rejected by artifact path policy
rejected by passport artifact_kind policy
no .igbin execution authority created
```

Compiler passport emission status:

```text
closed
proof-local passport remains external evidence metadata only
```

Public/stable/production/Spark/release/performance claim status:

```text
closed
no public runtime support
no Reference Runtime support
no stable API before v1
no production readiness
no public demo claim
no Spark integration
no release evidence
no public performance claim
```

What remains non-authoritative evidence only:

```text
experimental igc run Slice 0 outputs
proof-local passport manifests
delegated runtime selector
runtime_implementation_id
experimental result packet
```

---

## Carry-Forwards

CF-1:

```text
Slice 0 result packet carries the C1-A-required non_claims set.
Future result packet schema work may add:
- not certified alternative implementation
- not artifact portability guarantee
```

CF-2:

```text
RUN_USAGE in cli.rb now exposes the experimental run command vocabulary.
Future cli.rb edits must preserve --experimental wording and delegated selector
requirement so usage does not imply general runtime support.
```

---

## Closed Surfaces

```text
additional igc run widening: closed
.igbin execution: closed
compiler passport emission: closed
RuntimeSmoke productization: closed
Reference Runtime: closed
public runtime support: closed
stable API / production / public demo claims: closed
Spark integration: closed
release execution/evidence/public claims: closed
public performance claims: closed
README/gemspec/public docs: closed unless S3-R235-C1-A explicitly opens docs exposure
compiler result/report/CompatibilityReport/result conflation: closed
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated because C4-A accepted the
Slice 0 implementation closure and changed Main Line routing.

Delta recorded:

- accepted bounded `igc run` Slice 0 implementation;
- command vocabulary and proof status;
- passport validation and delegated selector status;
- RuntimeSmoke / `.igbin` / compiler passport emission closure;
- public/stable/production/Spark/release/performance non-claims;
- CF-1/CF-2 carry-forwards;
- exact next route to quickstart/docs authorization review.

No code, compiler, CLI, runtime, package, release, public docs, Spark,
production, or playground files were edited or authorized by this status
curation card.

---

## Exact Handoff

Next card boundary:

```text
Card: S3-R235-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-quickstart-docs-authorization-review-v0
Route: UPDATE

Goal:
Decide whether bounded pre-v1 quickstart/docs exposure may begin for the
accepted experimental igc run Slice 0 command, using only accepted R234
evidence and preserving all public/runtime/release non-claims.
```

Must preserve:

```text
quickstart/docs authorization review only
no docs edits in C1-A
no runtime/API/package changes
no .igbin execution
no compiler passport emission
no RuntimeSmoke productization
no public runtime support
no Reference Runtime support
no stable API before v1
no production/Spark/release/public performance claims
```

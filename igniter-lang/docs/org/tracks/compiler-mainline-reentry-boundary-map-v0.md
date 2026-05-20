# Compiler Mainline Reentry Boundary Map v0

Card: S3-R89-C0-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: compiler-mainline-reentry-boundary-map-v0
Route: UPDATE
Status: done
Date: 2026-05-20
Authority: org-sidecar boundary map / non-canon / non-implementation

---

## Goal

Re-establish the compiler mainline as a separate active lane from Spark applied
pressure, with current authority boundaries and Portfolio reporting obligations
visible before selecting the next compiler/profile axis.

This track does not authorize implementation.

---

## Read Set

```text
igniter-lang/roles/base-role.md
igniter-lang/docs/org/portfolio-guidance-log-v0.md
igniter-lang/docs/org/portfolio-reporting-protocol-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/cards/S3/S3.md
igniter-lang/docs/tracks/stage3-round88-status-curation-v0.md
igniter-lang/docs/dev/compiler-profile-architecture-direction.md
```

---

## Lane Separation Summary

Spark applied pressure remains active, but it is not the compiler mainline.

Spark lane status:

```text
applied-pressure / receipt-vocabulary intake / response-intake pending
```

Spark does not block compiler mainline planning because:

- R88 left Spark letter status as `draft`;
- Spark guidance questions remain open and routed to response intake;
- Igniter-Lang fixture work remains held until stable redacted receipt
  vocabulary exists;
- no Spark fixture/spec work is authorized by R88;
- no Spark implementation or production behavior is authorized.

Compiler mainline status:

```text
active Stage 3 compiler/profile lane may plan next route under governance
```

The next compiler/profile route must be selected independently from Spark
receipt-vocabulary intake unless a later Architect decision explicitly bridges
the lanes.

---

## Portfolio Guidance Boundary

Active guidance:

```text
PG-2026-05-20-01
```

It remains active for:

```text
Spark CRM
Igniter Ruby Framework
Igniter-Lang fixture coordination
Igniter Ledger sidecar posture
```

It does not authorize:

```text
compiler implementation
compiler/profile architecture migration
Igniter-Lang fixture work
Spark production behavior
Ruby Framework API generalization
Ledger sidecar source-of-truth behavior
```

For compiler mainline, `PG-2026-05-20-01` is a separation constraint:

```text
do not let Spark receipt pressure masquerade as compiler authority
```

---

## Accepted Compiler/Profile Foundations

Current accepted foundations visible from Stage 3 status and direction docs:

| Foundation | Current status |
| --- | --- |
| PROP-036 `compiler_profile_id` manifest identity | Accepted and bounded partial implementation landed. |
| PROP-036 `compiler_profile_source` transport | Assembler/orchestrator/Ruby facade/CLI transport landed in bounded release-ready package scope. |
| PROP-036 CLI blocker package | B1-B9 formally closed; bounded `--compiler-profile-source PATH.json` transport release-ready in exact approved scope. |
| CompilerProfile obligation coverage | Proof-local/report-only obligation report accepted; no enforcement/refusal authority. |
| Compiler profile contract boundary | Design accepted; SemanticIR checkpoint after emit/before assembly remains design-only. |
| PROP-038 `compiler_profile_contract` | Accepted proposal-only, then incrementally proven and implemented inside bounded internal validator/report-only/live-internal surfaces. |
| PROP-038 validator extraction | Internal validator library accepted; report-only integration accepted; public result/refusal/runtime remained closed until later strict internal path gates. |
| PROP-038 `contract_digest` | Shape, recompute-match, report-only proof, errata/design, and live validator implementation accepted in bounded internal scope. |
| PROP-038 strict internal refusal path | Bounded internal-only strict refusal live implementation landed and accepted as live internal foundation; public/API/runtime surfaces remain closed. |
| PROP-038 canon/spec sync | Canon sync and Ch5/Ch7/language-spec sync accepted through R86. |
| Compiler Profile Architecture Direction | Profile-Baseline-Pack direction recorded as post-POC target, not implementation authorization. |

Compact interpretation:

```text
CompilerProfile now has identity, source transport, contract vocabulary,
internal validation, report-only evidence, digest policy, and internal strict
terminal foundation.
```

It does not yet have:

```text
profile-assembled compiler migration
pack registry implementation
public profile discovery/defaulting/finalization
loader/report or CompatibilityReport authority
runtime/production binding
```

---

## Blocked Surfaces

The compiler mainline must preserve these blocked surfaces unless a later
Architect decision explicitly opens a narrower slice:

- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- obligation-coverage enforcement or compile refusal beyond the accepted
  internal strict path;
- public API/CLI widening;
- profile discovery/defaulting/finalization in public surfaces;
- `.igapp` golden migration;
- `.ilk` profile references;
- CompilationReceipt links;
- signing / production verification;
- compiler dispatch migration;
- profile-assembled compiler rewrite;
- parser/classifier/TypeChecker/SemanticIR/assembler broad rewrites;
- RuntimeMachine binding beyond signed Gate 3 scope;
- Ledger/TBackend binding;
- BiHistory;
- stream/OLAP production executors;
- production cache;
- production deployment;
- Spark fixtures/specs from this compiler-lane card.

---

## Candidate Next Compiler Axes For C1/C2

Recommended candidate axes for the main Architect to choose from:

| Axis | Why now | Safe first slice |
| --- | --- | --- |
| `compiler-pack-boundary-report-v0` | Matches the recorded architecture direction and does not require code movement. | No-code report mapping current compiler passes, PROPs, OOF codes, fixtures, and proof outputs into candidate packs. |
| `compiler-profile-slot-contract-map-v0` | Builds on obligation coverage and contract vocabulary without dispatch migration. | Design/proof map of profile slots, owners, missing-slot behavior, and report-only lifecycle. |
| `ordered-rule-contract-proof-v0` | Addresses the architecture-direction Q1 about pack install order vs before/after precedence. | Proof-local rule-order model for classifier/typechecker precedence; no pass rewrite. |
| `compiler-profile-id-mandatory-transition-design-v0` | Connects PROP-036 identity to future `.igapp` compatibility without changing manifests now. | Design-only transition policy: optional -> required conditions, golden migration blockers, compatibility risks. |
| `profile-pack-manifest-shadow-proof-v0` | Tests the Profile/Baseline/Pack model while keeping current compiler as POC. | Shadow manifest/proof experiment outside production compiler dispatch. |
| `poc-compiler-close-delta-report-v0` | Helps answer what remains before a demonstrable compiler/run POC and future rewrite. | Delta report: accepted foundations, missing demo surfaces, proof debt, and MVP demonstration path. |

Preferred conservative first route:

```text
compiler-pack-boundary-report-v0
```

Reason:

```text
It advances the architecture direction without code churn, dispatch migration,
or compiler authority widening.
```

---

## R89 Portfolio Closure Packet

Confirmed default R89 Portfolio closure packet:

```text
igniter-lang/docs/tracks/stage3-round89-status-curation-v0.md
```

Use it as the Portfolio report packet if it includes:

```text
status
executive summary
completed cards
changed files
evidence
risks / drift
cross-lane requests
recommended next route
decisions needed from Portfolio, if any
```

Fallback packet, only if status curation cannot satisfy the reporting fields:

```text
igniter-lang/docs/reports/s3-r89-round-report.md
```

Decision rule:

```text
stage3-round89-status-curation-v0 sufficient -> no extra report file
stage3-round89-status-curation-v0 insufficient -> add s3-r89-round-report.md
```

---

## Closed Surfaces

This org-sidecar boundary map does not authorize:

- code edits;
- implementation;
- compiler dispatch migration;
- profile-assembled compiler rewrite;
- parser/classifier/TypeChecker/SemanticIR/assembler rewrites;
- public API/CLI widening;
- `.igapp` or golden migration;
- loader/report or CompatibilityReport changes;
- runtime/Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior;
- Spark fixtures/specs;
- Spark implementation;
- treating Spark applied-pressure as compiler authority;
- treating this org track as a decision, proposal, spec, or implementation card.

---

## Disposition

Recommendation:

```text
continue compiler mainline planning in R89
keep Spark applied-pressure separate
prefer a no-code compiler-pack-boundary-report route unless Architect chooses
another compiler/profile axis
close R89 for Portfolio via stage3-round89-status-curation-v0.md
add s3-r89-round-report.md only if status curation is insufficient
```

No implementation is authorized by this track.

# Round Report: Igniter-Lang S3-R87

Card: S3-R87-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round87-status-curation-v0
Status: done
Date: 2026-05-20
Supervisor: [Igniter-Lang Status Curator]
Scope: Close S3-R87 after Architect decision and serve as Portfolio closure packet.

## Executive Summary

- R87 accepted the Spark CRM contractable shadowing pilot scope as design/scope only.
- Accepted first target: `AvailabilityLedger::SlotMap`.
- Accepted pilot theme: why-not availability diagnostics.
- Accepted first mode: `primary_observed_only`; optional shadow candidate remains later and unauthorized.
- C2-X pressure result: `proceed`, 11/11 PASS, no blockers, four non-blocking notes.
- C3-A status: `accepted-scope-letter-next-implementation-held`.
- Next route is a cross-lane communication/request letter only: `sparkcrm-contractable-shadowing-pilot-scope-letter-v0`.

## Decisions Needed From Portfolio

- None for round closure.
- Portfolio may later read the letter route if it is used for cross-lane coordination, but this R87 close packet asks for no Portfolio authorization.

## Completed Cards

| Card | Output | Status |
| --- | --- | --- |
| S3-R87-C0-O | `sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0` | done |
| S3-R87-C1-P1 | `sparkcrm-contractable-shadowing-pilot-scope-v0` | done |
| S3-R87-C2-X | `sparkcrm-contractable-shadowing-pilot-scope-pressure-v0` | complete / proceed |
| S3-R87-C3-A | `sparkcrm-contractable-shadowing-pilot-scope-decision-v0` | accepted-scope-letter-next-implementation-held |
| S3-R87-C4-S | `stage3-round87-status-curation-v0` | done |

## Changed Files

R87 evidence files:
- `igniter-lang/docs/cards/S3/S3-R87.md`
- `igniter-lang/docs/org/tracks/sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0.md`
- `igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md`
- `igniter-lang/docs/discussions/sparkcrm-contractable-shadowing-pilot-scope-pressure-v0.md`
- `igniter-lang/docs/gates/sparkcrm-contractable-shadowing-pilot-scope-decision-v0.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/cards/S3/S3.md`

Status-curation updates:
- `igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/discussions/README.md`
- `igniter-lang/docs/inbox/README.md`

No code files were edited by this status-curation slice.

## Evidence Links

Tracks:
- `igniter-lang/docs/org/tracks/sparkcrm-pilot-cross-lane-reporting-and-letter-boundary-v0.md`
- `igniter-lang/docs/tracks/sparkcrm-contractable-shadowing-pilot-scope-v0.md`
- `igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md`

Gate:
- `igniter-lang/docs/gates/sparkcrm-contractable-shadowing-pilot-scope-decision-v0.md`

Discussion:
- `igniter-lang/docs/discussions/sparkcrm-contractable-shadowing-pilot-scope-pressure-v0.md`

Reporting protocol:
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- `igniter-lang/docs/reports/README.md`

## Risks / Drift

- Letter path is authorized as communication/request material only; it is not a decision, Portfolio close report, implementation authorization, or canon.
- Future implementation must define `service_ref` abstraction before authorization.
- Future implementation must define idempotency key generation and low-volume storage behavior before authorization.
- Spark CRM lane confirmation is required before implementation authorization.
- `sparkcrm-availability-ledger-why-not-fixture-v0` remains a recommendation only and requires a separate card/round.

## Cross-Lane Requests

To Ruby Framework:
- Future letter may request review of contractable observed wrappers, redaction defaults, digest helpers, sampling gates, fail-open receipts, and durable observation adapter support. No Ruby Framework implementation is authorized.

To Igniter-Lang:
- Use only sanitized synthetic fixture/spec pressure. No fixture/spec implementation is authorized by R87.

To Spark CRM:
- Future letter may ask whether `AvailabilityLedger::SlotMap` is operationally acceptable for a low-volume, fail-open, primary-observed-only pilot. No Spark code access, code edits, or production behavior is authorized.

To Portfolio:
- No immediate decision required. Read this packet as the R87 closure report.

## Preserved Closed Surfaces

C3-A preserves these closures:
- pilot implementation;
- Spark CRM code inspection;
- Spark CRM code edits;
- Spark production integration;
- Spark production behavior changes;
- Spark primary-ledger replacement;
- real Spark data, endpoints, credentials, provider payloads, customer records, technician/user raw records, phone/email data, or infrastructure details in docs, fixtures, receipts, reports, or sidecar examples;
- Igniter Ruby Framework code edits;
- Igniter Ledger code edits;
- Igniter Ledger as primary Spark database;
- production TBackend/Ledger binding for Spark;
- automatic Spark-to-Igniter migration;
- Igniter-Lang compiler/runtime code edits;
- Igniter-Lang runtime execution of Spark decisions;
- public `.igapp` operational policy deployment for Spark;
- public API or CLI widening;
- loader/report behavior;
- CompatibilityReport behavior;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`, signing, dispatch, RuntimeMachine/Gate 3, stream/OLAP, cache, or production widening;
- treating a cross-lane letter as a decision, report packet, canon, or implementation authorization.

## Recommended Next

```text
Track: sparkcrm-contractable-shadowing-pilot-scope-letter-v0
Path: igniter-lang/docs/org/letters/sparkcrm-contractable-shadowing-pilot-scope-letter-v0.md
Boundary: communication / handoff / request only
```

The letter may request Spark lane confirmation and neighbor-lane review. It must not authorize implementation or cross-lane commitments by itself.

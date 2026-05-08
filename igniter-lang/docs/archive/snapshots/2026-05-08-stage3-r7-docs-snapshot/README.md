# Igniter-Lang Stage 3 Round 7 Docs Snapshot

Status: cold archive snapshot
Date: 2026-05-08
Created by: `[Architect Supervisor / Codex]`
Reason: preserve active docs before the first value-hoisting / compaction wave

---

## Purpose

This snapshot preserves the active Igniter-Lang documentation state after
Stage 3 Round 7.

It is not a stage close. It is a working-memory safety snapshot before further
documentation compaction, categorization, and value hoisting.

Use it when:

- a compact living document appears to have lost useful nuance;
- a future agent needs archaeology for a Stage 3 Round 1-7 decision;
- a hoisted value in `docs/value-index.md` needs its original source context;
- a compaction pass needs to verify what existed before it simplified docs.

Do not use this snapshot as the working context for current tasks. Start from:

```text
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/value-index.md
```

---

## Contents

This snapshot copies active documentation and role context, but intentionally
does not recursively copy `docs/archive/`.

Copied:

```text
top-level docs/*.md
bridge/
discussions/
meta-proposals/
proposals/
reviews/
spec/
tracks/
roles/
```

Approximate size at creation:

```text
339 files
4.1M
```

---

## Current State Captured

Key captured state:

- Stage 1: closed
- Stage 2: closed
- Stage 3: open after Round 7
- production compiler path: `emit_typed(typed)`
- TEMPORAL `.igapp` load for inspection: proven/report-shaped
- TEMPORAL evaluation: refused until executor/TBackend authorization
- Gate 2 Ledger descriptor exposure: ratification recommended
- Gate 3 live Ledger/TBackend/runtime operations: closed
- `entrypoint` / `section`: proposal candidates only
- `agent-context.md`: trusted first context layer

---

## Archaeology Map

Start here inside the snapshot:

| Need | Snapshot path |
|------|---------------|
| S3-R7 status | `current-status.md` |
| Agent context at snapshot time | `agent-context.md` |
| Track index | `tracks/README.md` |
| Runtime/spec state | `spec/ch7-runtime.md` |
| Compiler pipeline state | `spec/ch5-compiler-pipeline.md` |
| TEMPORAL fragment state | `spec/ch4-fragment-classification.md` |
| S3-R7 runtime boundary | `tracks/runtime-compatibility-report-temporal-load-check-v0.md` |
| S3-R7 smoke | `tracks/runtime-smoke-temporal-post-switch-v0.md` |
| S3-R7 descriptor mapping | `tracks/descriptor-compatibility-package-consumption-v0.md` |
| S3-R7 pressure review | `discussions/runtime-compatibility-and-typed-delta-pressure-v0.md` |

---

## Rule

This directory is read-only archaeology. Do not edit files in this snapshot.
Create new living docs in `igniter-lang/docs/` and link back here when detail
is needed.

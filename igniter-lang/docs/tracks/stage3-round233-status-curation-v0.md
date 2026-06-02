# Stage 3 Round 233 Status Curation v0

Card: S3-R233-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round233-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-06-02

Depends on:
- S3-R233-C4-A

---

## Executive Summary

R233 accepts the experimental `igc run` design-only boundary.

The accepted design defines a narrow pre-v1 command boundary for a future Slice
0 implementation authorization review. It does not authorize implementation.

Exact next route:

```text
S3-R234-C1-A
experimental-igc-run-slice0-implementation-authorization-review-v0
```

This next route is an authorization review only. It may decide whether a
bounded Slice 0 implementation can begin.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-current-surface-and-lab-signals-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-design-only-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md`

---

## Outcome Table

| Card | Status | Curated result |
| --- | --- | --- |
| S3-R233-C1-D | accepted | Experimental `igc run` design-only boundary accepted as design-ready. |
| S3-R233-C2-P1 | accepted as facts basis | Current CLI/facts packet accepted: current CLI supports `compile` only; no `run` branch exists today. |
| S3-R233-C3-X | PASS | No blockers; AN-1/AN-2/AN-3 carry into S3-R234-C1-A. |
| S3-R233-C4-A | accepted | Opens bounded implementation-authorization review next, not implementation. |
| S3-R233-C5-S | done | Current status updated with compact R233 delta and exact R234 route. |

---

## Curated Status

Accepted / conditional / held status:

```text
accepted
```

What changed in R233:

```text
Experimental igc run moved from "design-only may open" to
"design boundary accepted; bounded implementation-authorization review may
open next."
```

Accepted future Slice 0 shape:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Accepted Slice 0 constraints:

```text
.igapp only
explicit proof-local passport path required
explicit sample input JSON required
explicit delegated runtime selector required
mandatory --experimental flag
machine-readable experimental result packet
pre-v1 / no-stable-API wording
fail-closed passport/readiness checks
```

`igc run` status:

```text
design boundary: accepted
implementation authorization: may open next
implementation now: closed
```

Passport evidence status:

```text
R232 proof-local passport manifests remain accepted as evidence/compatibility
metadata only.
Add.igapp passport satisfies Slice 0 prerequisite.
.igbin passports remain held for execution because output_contract is deferred.
```

Compiler passport emission status:

```text
closed
```

Delegated runtime status:

```text
delegated-experimental:ivm-proof may be named only as an unstable pre-v1
non-canonical selector label.
S3-R234-C1-A must define what the selector resolves to as a concrete adapter
path.
```

Rust TBackend / benchmark-app lab-signal status:

```text
igniter-tbackend: backend/substrate lab signal only; not an igc run runtime.
benchmark-app: benchmark-consumer lab signal only; not igc run performance
evidence and not public performance evidence.
```

What remains non-authoritative evidence only:

```text
proof-local passport manifests
delegated runtime evidence
runtime_implementation_id
igniter-tbackend lab signals
benchmark-app lab signals
```

---

## Watchpoints and Acceptance Notes

Carry into S3-R234-C1-A:

```text
AN-1:
  RuntimeSmoke must remain closed in all igc run code paths.
  "production-compiler-cli" must be forbidden in run result output.

AN-2:
  TBackend README wording ("production-grade" / "SparkCRM") remains lab-only.
  Any future public reference to TBackend requires a separate wording audit.

AN-3:
  The selector "delegated-experimental:ivm-proof" must resolve to an explicit
  adapter path. Runtime selector resolution must not remain implicit.
```

Additional carried gap:

```text
.igbin output_contract remains deferred and blocks .igbin execution in Slice 0.
```

---

## Closed Surfaces

```text
igc run implementation: closed until S3-R234-C1-A explicitly authorizes it
.igbin execution: closed
compiler passport emission: closed
implicit runtime discovery/defaulting: closed
RuntimeSmoke productization: closed
Reference Runtime: closed
Rust TBackend execution through igc run: closed
benchmark/performance claims: closed
Spark integration: closed
release execution/public claims: closed
stable API / production / public runtime / public demo claims: closed
CompilerResult / CompilationReport / CompatibilityReport result conflation: closed
README/gemspec/public docs: closed unless S3-R234-C1-A explicitly opens them
```

---

## Current Status Delta

`igniter-lang/docs/current-status.md` was updated because C4-A accepted the
design boundary and changed Main Line routing.

Delta recorded:

- accepted `igc run` design-only boundary;
- future Slice 0 command shape and constraints;
- implementation-authorization review next;
- `igc run` implementation still closed;
- passport/delegated-runtime/TBackend/benchmark-app authority status;
- AN-1/AN-2/AN-3 watchpoints;
- Round 233 card receipt.

No code, compiler, CLI, runtime, package, release, public docs, Spark,
production, or playground files were edited or authorized by this status
curation card.

---

## Exact Handoff

Next card boundary:

```text
Card: S3-R234-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-implementation-authorization-review-v0
Route: UPDATE

Goal:
Decide whether a bounded pre-v1 experimental igc run Slice 0 implementation
may begin, limited to .igapp input plus explicit proof-local passport
validation, explicit sample input, explicit delegated runtime selector, and
machine-readable experimental result output.
```

Must explicitly answer:

```text
whether C2-I may begin
whether lib/igniter_lang/cli.rb may be edited
whether bin/igc may be edited
whether .igbin remains excluded
whether RuntimeSmoke remains closed in all run code paths
what delegated-experimental:ivm-proof resolves to
whether compiler passport emission remains closed
whether README/gemspec/public docs remain closed
whether stable API, production, public demo, Spark, release, Reference Runtime,
public runtime, and performance claims remain closed
```

# Experimental Loops/Recursion Proof Fixture Authorization Review v0

Card: S3-R248-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-proof-fixture-authorization-review-v0
Route: UPDATE
Status: authorized / route-c2-i
Date: 2026-06-04

Depends on:
- S3-R247-C4-A

---

## Decision

Authorize a bounded proof-local loop/recursion specification fixture route.

Decision:

```text
authorize bounded proof-local specification fixture packet
```

Authorized as:

```text
specification fixture evidence only
fixture/source-shape pressure for PROP-039+ and OOF follow-up
not executable proof
not compiler support
not parser/typechecker/runtime implementation
```

Rationale:

```text
R247 accepted the wording boundary and explicitly opened this authorization
review. The wording is concrete enough to create proof-local fixture sources
and result metadata that test whether the accepted boundaries can be named,
separated, and reviewed.

The wording is not mature enough to authorize executable compiler/runtime
behavior. Ch13 remains proposed / Stage 4 deferred, and managed local
loops/recursion remain PROP-039+ or later territory.
```

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-v0.md`
- `igniter-lang/docs/discussions/experimental-loops-recursion-spec-prop037-wording-sync-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round247-status-curation-v0.md`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/source/loops_and_recursion.ig`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`

No code, runtime, CLI, package, public docs, spec/proposal source, canonical
source fixture, playground, release, Spark, or production surface was edited by
this authorization review.

This C1-A decision adds:

- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-authorization-review-v0.md`

---

## Authorization Summary

| Question | Decision |
| --- | --- |
| May C2-I begin? | Yes. |
| Route type | Proof-local specification fixture packet. |
| Writes under `igniter-lang/experiments/**` | Authorized, limited to the C2-I experiment directory. |
| Mainline proof track doc | Authorized. |
| `igniter-lang/source/**` edits | Closed. |
| `source/loops_and_recursion.ig` copying | Source file is read-only; C2-I may create derived proof-local fixtures under the experiment directory with explicit provenance. |
| Spec / proposal / covenant docs edits | Closed. |
| `lib/**`, `bin/igc`, gemspec, README, public docs | Closed. |
| RuntimeSmoke, CompilerResult, CompilationReport edits | Closed. |
| Parser/typechecker/runtime support | Not created. |
| Executable compiler proof | Not authorized. |
| `.igapp` / `.igbin` generation | Not authorized for this C2-I. |
| Lab behavior | Frontier evidence only. |
| Fixture output authority | Proof-local specification fixture evidence only. |

---

## Authorized C2-I Boundary

```text
Card: S3-R248-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-proof-fixture-v0

Route: UPDATE
Depends on:
- S3-R248-C1-A

Goal:
Create proof-local loops/recursion specification fixtures and evidence packets
inside the authorized experiment boundary, using accepted R247 wording as the
source of truth, without changing parser/typechecker/runtime/API/CLI/package
surfaces or creating public/runtime/reference/stable claims.
```

### Allowed Write Scope

```text
igniter-lang/experiments/
  experimental_loops_recursion_spec_fixtures_v0/**

igniter-lang/docs/tracks/
  experimental-loops-recursion-proof-fixture-v0.md
```

### Read-Only / Closed Surfaces

Closed unless a later card explicitly authorizes them:

```text
igniter-lang/source/**
igniter-lang/docs/spec/**
igniter-lang/docs/proposals/**
igniter-lang/docs/language-covenant.md
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
playgrounds/**
release/signing/tag/publish/deploy surfaces
```

### Fixture Provenance Policy

C2-I may:

- read `igniter-lang/source/loops_and_recursion.ig`;
- create derived proof-local fixture files under the experiment directory;
- cite exact source/proposal/spec origins in a manifest.

C2-I may not:

- edit `igniter-lang/source/loops_and_recursion.ig`;
- treat copied/adapted fixture text as canonical source;
- generate `.igapp` or `.igbin` outputs;
- run or claim compiler/runtime execution support.

---

## Required Fixture Classes

C2-I must create a compact fixture packet covering:

1. **Bounded local collection loop**:
   - maps to Ch13 / future PROP-039+ input only;
   - must distinguish local repetition from `fold_stream`.

2. **Recursion / `decreases fuel`**:
   - maps to Ch13 / future PROP-039+ input only;
   - must state that exact syntax, metric model, and diagnostics remain future
     design work.

3. **Service-loop `clock.every` / `tick.time`**:
   - maps to PROP-037 progression descriptor input only;
   - must state that `clock.every` is a progression `source_kind` / source
     binding, not `Stream[DateTime]`;
   - must represent `tick.time` as explicit event-time binding.

4. **Source-level `now()` prohibition**:
   - maps to Ch8 `OOF-L6` wording anchor;
   - must not mint a new OOF registry code.

5. **Postulate 28 / unnamed-loop robustness**:
   - captures naming pressure for future diagnostics;
   - does not claim enforcement is implemented.

6. **`break` deferral**:
   - records that source-level `break` remains deferred and unsupported by this
     slice.

---

## Required Result Packet

C2-I must produce:

```text
igniter-lang/experiments/
  experimental_loops_recursion_spec_fixtures_v0/
    fixtures/**
    manifest.json
    out/summary.json

igniter-lang/docs/tracks/
  experimental-loops-recursion-proof-fixture-v0.md
```

The result packet must be machine-readable enough for C3-X / C4-A review and
must explicitly state:

```text
evidence_class: proof-local specification fixture
authority_status: evidence-only
compiler_support: not_claimed
runtime_support: not_claimed
public_runtime_support: not_claimed
reference_runtime_support: not_claimed
stable_api: not_claimed
production: not_claimed
performance: not_claimed
certification: not_claimed
portability: not_claimed
```

---

## Required Proof Matrix

| Check | Requirement |
| --- | --- |
| LRF-1 | Only authorized files changed. |
| LRF-2 | Fixtures are proof-local and not placed under `source/**`. |
| LRF-3 | Bounded local loop fixture maps to Ch13 / PROP-039+ input only. |
| LRF-4 | Recursion / `decreases fuel` fixture maps to Ch13 / PROP-039+ input only. |
| LRF-5 | Service-loop fixture maps to PROP-037 progression descriptor input only. |
| LRF-6 | `tick.time` is represented as explicit event-time binding. |
| LRF-7 | Source-level `now()` fixture is prohibited through Ch8 `OOF-L6`. |
| LRF-8 | `clock.every` is not treated as `Stream[DateTime]`. |
| LRF-9 | Postulate 28 / unnamed-loop robustness is captured as future diagnostic pressure only. |
| LRF-10 | `break` remains deferred. |
| LRF-11 | OOF-L / OOF-R wording is not promoted into registry authority. |
| LRF-12 | Lab behavior remains frontier evidence only. |
| LRF-13 | No parser/typechecker/runtime/API/CLI/package files changed. |
| LRF-14 | No `igc run`, `.igbin`, compiler passport, RuntimeSmoke, `.igapp`, or execution path is touched. |
| LRF-15 | Forbidden wording scan passes. |
| LRF-16 | Result packet states no implementation/public/reference/stable/production/performance/certification/portability claims. |

---

## Required Command Matrix

Required:

```text
git diff --check -- \
  igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0 \
  igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md
```

Required:

```text
find igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0 \
  -type f | sort
```

Required:

```text
ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' \
  igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json
```

No compiler, runtime, `igc run`, `.igapp`, `.igbin`, release, or playground
command is required or authorized by this card.

---

## Forbidden Wording Scan

C2-I must not introduce wording that claims or implies:

```text
implemented loops
implemented recursion
parser support
typechecker support
runtime support
igc run support
.igbin execution
.igapp execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production-ready
Spark integration
release evidence
public performance
official reference implementation
alternative certification
portability guarantee
lab behavior as canon
```

Allowed only in negative/non-claim contexts.

---

## Explicit Answers

### May C2-I begin?

Yes. C2-I may begin as a proof-local specification fixture packet.

### Are writes under `igniter-lang/experiments/**` allowed?

Yes, limited to:

```text
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/**
```

### May the mainline proof track doc be written?

Yes:

```text
igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md
```

### May `igniter-lang/source/**` be edited?

No. `igniter-lang/source/**` remains read-only.

### May spec/proposal docs be edited?

No. `docs/spec/**`, `docs/proposals/**`, and
`docs/language-covenant.md` remain read-only.

### May `lib/**`, `bin/igc`, gemspec, README, public docs, RuntimeSmoke,
CompilerResult, or CompilationReport be edited?

No. They remain closed.

### May fixture output be called proof-local specification fixture evidence?

Yes. It may be called proof-local specification fixture evidence only.

### Is any parser/typechecker/runtime support created?

No. This route creates no parser, TypeChecker, SemanticIR, runtime, CLI, or
package support.

### Does lab behavior remain frontier evidence only?

Yes. Lab behavior remains frontier evidence only and creates no canonical
authority.

### Do protected surfaces and claims remain closed?

Yes. `igc run`, `.igbin`, `.igapp` execution, compiler passport emission,
RuntimeSmoke, public runtime, Reference Runtime, stable API, production, Spark,
release, public performance, official/reference status, alternative
certification, and portability claims remain closed.

---

## Compact Authorization Summary

[D] Authorize C2-I as proof-local specification fixture packet only.

[S] R247 wording is concrete enough to create non-executable fixtures for local
loops, recursion / `decreases fuel`, service-loop `tick.time`, `now()` refusal,
Postulate 28 naming pressure, and `break` deferral.

[T] The fixture packet must remain under the experiment directory and produce a
machine-readable summary JSON.

[R] No parser/typechecker/runtime/API/CLI/package implementation, `.igapp`,
`.igbin`, `igc run`, RuntimeSmoke, public/reference/stable/production/release/
performance/certification/portability authority opens.

---

## Exact Next Dispatch

Open:

```text
Card: S3-R248-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-proof-fixture-v0
Route: UPDATE
Depends on:
- S3-R248-C1-A
```

Use the authorized boundary above exactly. C2-I should return:

- proof-fixture doc;
- experiment fixture packet;
- `LRF-1..LRF-16` matrix;
- exact C4-A recommendation.

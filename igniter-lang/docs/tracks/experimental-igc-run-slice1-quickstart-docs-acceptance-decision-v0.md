# Experimental igc run Slice 1 Quickstart Docs Acceptance Decision v0

Card: S3-R244-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-quickstart-docs-acceptance-decision-v0
Route: UPDATE
Status: accepted / route-status-curation-then-loops-recursion-pressure
Date: 2026-06-03

Depends on:
- S3-R244-C2-I
- S3-R244-C3-X

---

## Decision

Accept the bounded Slice 1 quickstart/docs exposure.

Decision:

```text
accepted
```

Acceptance basis:

```text
QD-S1-1..QD-S1-14: PASS
C3-X pressure verdict: PASS — unconditional
changed files: exactly 3 authorized docs files
root README / ruby-api / lib / bin / experiments / examples / playgrounds:
  not edited by R244 docs sync
forbidden wording scan: 0 positive-claim hits
```

This accepts internal documentation exposure only. It does not accept positive
Add.igapp integer execution, public runtime support, Reference Runtime support,
stable API, production readiness, release evidence, Spark integration, public
demo, public performance evidence, alternative certification, portability
guarantees, `.igbin` execution, compiler passport emission, RuntimeSmoke
productization, or adjacent source/conformance artifact authority.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice1-quickstart-docs-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round243-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/current-status.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`
- `igniter-lang/source/loops_and_recursion.ig`

---

## Accepted Changed Files

Accepted as R244 docs exposure:

```text
igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/README.md
```

Accepted purpose per file:

```text
experimental-igc-run-slice1-quickstart-docs-v0.md
  Internal quickstart/docs track for pre-v1 experimental Slice 1 Path C
  fail-closed evidence.

docs/current-status.md
  Compact breadcrumb for R244 authorization/docs sync status.

docs/README.md
  Narrow navigation pointer only, labeled pre-v1 / Path C fail-closed
  evidence only.
```

Closed / not accepted as changed by R244:

```text
igniter-lang/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/experiments/**
igniter-lang/examples/**
playgrounds/**
```

---

## Accepted QD-S1 Matrix

```text
QD-S1-1   PASS  authorized write scope followed
QD-S1-2   PASS  command shape matches accepted Slice 1 selector
QD-S1-3   PASS  Path C fail-closed behavior described clearly
QD-S1-4   PASS  integer-add blocked diagnostics named exactly
QD-S1-5   PASS  Slice 0 compatibility kept separate from Slice 1 evidence
QD-S1-6   PASS  runtime_implementation_id remains evidence-facing metadata
QD-S1-7   PASS  positive Add.igapp integer execution is not claimed
QD-S1-8   PASS  .igbin remains excluded
QD-S1-9   PASS  compiler passport emission remains closed
QD-S1-10  PASS  RuntimeSmoke productization remains closed
QD-S1-11  PASS  public/runtime/reference/stable/production/release/
                 performance/portability claims remain closed
QD-S1-12  PASS  adjacent source/conformance artifacts remain excluded
QD-S1-13  PASS  forbidden wording scan passes
QD-S1-14  PASS  closed-surface scan passes
```

---

## Accepted Wording Status

Command vocabulary status:

```text
accepted
selector: delegated-experimental:igniter-vm-candidate
requires: --experimental
artifact input: .igapp directory only
```

Path C fail-closed wording status:

```text
accepted
Path C is the central Slice 1 docs truth.
```

Integer-add blocked diagnostics status:

```text
accepted
diagnostics named exactly:
  unsupported_capability_integer_add
  unsupported_capability_stdlib_integer_add
```

Slice 0 compatibility separation status:

```text
accepted
Slice 0 delegated-experimental:ivm-proof result outputs.sum=42 is separate
selector sanity evidence, not Slice 1 VM candidate success.
```

`runtime_implementation_id` wording status:

```text
accepted
igniter.delegated.experimental.vm.rust-tokio.v0 remains evidence-facing
metadata only, not a user-typed selector and not runtime authority.
```

Adjacent artifact exclusion status:

```text
accepted
R243-C5-S adjacent source/conformance artifacts remain excluded from Slice 1
docs evidence, runtime authority, conformance authority, portability evidence,
public claim support, release evidence, and alternative certification.
```

Docs README pointer status:

```text
accepted
one narrow navigation pointer only; root README and ruby-api remain closed.
```

Forbidden wording scan status:

```text
accepted
C3-X reports 0 positive-claim hits; all forbidden-phrase hits are in explicit
negation/non-claim context.
```

Closed-surface scan status:

```text
accepted
C3-X reports exactly 3 authorized docs files changed.
```

---

## Explicit Answers

Whether Slice 1 quickstart/docs exposure is accepted:

```text
Yes. Accepted unconditionally.
```

Whether generated docs may be called internal pre-v1 experimental
delegated-runtime Slice 1 evidence documentation only:

```text
Yes.
```

Whether this creates public runtime support:

```text
No.
```

Whether this creates Reference Runtime support:

```text
No.
```

Whether stable API remains unpromised before v1:

```text
Yes.
```

Whether positive Add.igapp integer execution remains unaccepted:

```text
Yes. It remains unaccepted and blocked under Path C for Slice 1.
```

Whether `.igbin`, compiler passport emission, RuntimeSmoke productization,
Spark, release, production, public demo, public performance, certification,
and portability claims remain closed:

```text
Yes. All remain closed.
```

---

## Next Route Decision

Immediate closure route:

```text
S3-R244-C5-S
stage3-round244-status-curation-v0
```

Purpose:

```text
Record R244 accepted quickstart/docs exposure, changed files, QD-S1 14/14
PASS, and the next Main Line route.
```

Next Main Line route after status curation:

```text
S3-R245-C1-D
experimental-loops-recursion-pressure-and-spec-boundary-v0
```

Route type:

```text
design / intake / authority boundary
not implementation
not lab certification
not public runtime support
```

Route intent:

```text
Review `loops/recursion pressure` after accepted Slice 1 docs exposure and
rapid igniter-lab implementation pressure. Decide which parts are ready as
canonical design input, which remain frontier draft evidence, and what exact
Runtime Specification / PROP-037+ boundary should open next.
```

Why this route opens next:

```text
igniter-lab now has concrete loop/service-loop/recursion pressure artifacts,
including a `loops_and_recursion.ig` source fixture and lab-docs pressure
packages. Leaving the surface undefined risks drift between frontier
implementation and canonical language/runtime semantics.
```

Preserve in R245:

```text
lab evidence is pressure input only
no canonical acceptance of lab loops/recursion implementation
no `igc run` widening
no public runtime support
no Reference Runtime support
no stable API or production claim
no release evidence
```

Recommended R245 read set:

```text
igniter-lang/docs/tracks/stage3-round244-status-curation-v0.md
igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-
  acceptance-decision-v0.md
igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md
igniter-lang/docs/discussions/experimental-igc-run-slice1-quickstart-docs-
  pressure-v0.md
playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md
playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md
igniter-lang/source/loops_and_recursion.ig
playgrounds/igniter-lab/igniter-compiler/src/lexer.rs
playgrounds/igniter-lab/igniter-compiler/src/parser.rs
playgrounds/igniter-lab/igniter-compiler/src/classifier.rs
playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs
playgrounds/igniter-lab/igniter-compiler/src/emitter.rs
playgrounds/igniter-lab/igniter-vm/src/instructions.rs
playgrounds/igniter-lab/igniter-vm/src/vm.rs
playgrounds/igniter-lab/igniter-compiler/verify_loops.rb
```

Decision recommendation for R245:

```text
Open a design/intake boundary that separates:
  - bounded collection loops / max_steps;
  - recursion / decreases fuel;
  - service loops / tick.time;
  - now() prohibition;
  - progression fragment-class decision;
  - VM opcode evidence;
  - OOF code registry needs.
```

---

## Compact Decision Summary

```text
R244 C2-I docs sync accepted.
QD-S1 14/14 PASS.
Slice 1 docs are internal pre-v1 experimental delegated-runtime Path C
fail-closed evidence only.
Positive Add.igapp integer execution remains unaccepted.
All public/runtime/reference/stable/release/performance/portability claims
remain closed.
Route status curation next, then open R245 loops/recursion pressure and spec
boundary.
```

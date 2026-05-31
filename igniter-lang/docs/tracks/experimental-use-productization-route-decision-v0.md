# Experimental Use Productization Route Decision v0

Card: S3-R222-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-use-productization-route-decision-v0
Route: UPDATE
Status: accepted / sharpened-to-experimental-executable-quickstart
Date: 2026-05-31

Depends on:
- S3-R222-C1-D
- S3-R222-C2-P1
- S3-R222-C3-X

---

## Decision

Accept the R222 experimental-use productization route, with one sharpening:

```text
the next productization path is not compile-only quickstart;
it is a bounded experimental executable quickstart with a three-runtime boundary.
```

This changes sequencing. Market-window pressure is now high enough to pause
additional counterfactual/report/API expansion and route toward the smallest
honest executable developer experience.

Implementation is not authorized by this card. The next card may be an
implementation-authorization review only.

---

## Inputs Accepted

- C1-D productization options: accepted as the route basis.
- C2-P1 current-surface facts: accepted as accurate facts basis.
- C3-X pressure verdict: accepted; no blockers.

C1-D and C3-X correctly identify the highest-friction gap: a published alpha
and compile CLI exist, but there is no curated first experiment. C4-A sharpens
the target from "compile success" to "bounded executable success" because
Igniter's product direction is executable temporal auditable systems, not only
compiler artifacts.

---

## Three-Runtime Boundary

Runtime layers for the next route:

```text
1. Runtime Specification
   Canonical/normative target. Defines semantics slowly and carefully.
   No implementation authority opens here.

2. Reference Runtime
   Our future canonical implementation candidate. Moves slowly/moderately.
   Closed for the next quickstart unless separately authorized.

3. Delegated Experimental Runtime
   Fast, non-canonical, external/frontier runtime surface. It may execute
   bounded examples and return learning/evidence, but it is not canon.
```

The next quickstart, if later authorized, must use only layer 3:

```text
.ig source -> compile -> .igapp -> delegated experimental runtime harness
```

It must not claim Reference Runtime support, public runtime support, production
readiness, stable API, or v1 compatibility.

---

## Accepted Route

Route accepted:

```text
experimental executable quickstart
```

Expected developer story:

```text
install/use alpha
choose one curated source
compile to .igapp
execute through a delegated experimental runtime harness
see output and evidence
read the pre-v1 / non-production / non-stable disclaimer at point of use
```

The first executable path should be intentionally narrow. It may start from
`source/add.ig` or a copied bounded fixture, not from parser-only,
counterfactual, temporal/TBackend, Spark, or all-grammar pressure sources.

---

## Next Route Authorized

Open an authorization review next:

```text
Card: S3-R223-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-executable-quickstart-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R222-C4-A
```

Goal for that review:

```text
Decide whether a bounded experimental executable quickstart implementation may
begin, using existing compile surfaces plus a non-canonical delegated runtime
harness, without promising stable API, production readiness, public demo,
Reference Runtime support, Spark integration, or release execution.
```

Candidate implementation boundary for the future C2-I, if C1-A authorizes:

- `igniter-lang/examples/experimental_executable_quickstart_v0/**`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`

Default closed unless C1-A explicitly opens:

- `igniter-lang/lib/**`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- public docs
- body spec chapters
- RuntimeSmoke source, behavior, and result shape
- CompilerResult and CompilationReport fields
- report/result/receipt sidecars
- profile discovery/defaulting/finalization
- release/tag/push/publish/sign/deploy

---

## Required Future Proof Matrix

The authorization review should require a compact proof/regression matrix:

- source fixture is compiler-accepted and narrowly labeled;
- compile command produces `.igapp`;
- delegated experimental runtime harness returns expected output;
- harness output stays under example-local or temp `out/`;
- no `lib/**` or public API/CLI widening unless separately authorized;
- no RuntimeSmoke result-shape or callback behavior change;
- no CompilerResult or CompilationReport key additions;
- no package/gemspec/release mutation;
- forbidden wording scan passes;
- pre-v1 disclaimer is present at point of use.

Forbidden wording scan set:

```text
stable API
production-ready
public demo-ready
Spark-ready
Reference Runtime support
runtime-ready
all grammar support
v1 compatibility
```

Allowed wording:

```text
experimental
alpha
pre-v1
subject to change
delegated experimental runtime
non-canonical runtime harness
not production-ready
no stable API guarantee
```

---

## Explicit Answers

Experimental-use pressure changes sequencing?

```text
Yes. Move next toward experimental executable use instead of more
counterfactual/report/API expansion or compile-only documentation.
```

Route accepted?

```text
Yes, accepted and sharpened to experimental executable quickstart with a
three-runtime boundary.
```

May implementation authorization open next?

```text
Yes. S3-R223-C1-A may open as an authorization review only.
Implementation is not authorized by this card.
```

Does stable API remain unpromised before v1?

```text
Yes. Stable API, v1 compatibility, production readiness, and public runtime
support remain explicitly unpromised.
```

Does release execution remain closed?

```text
Yes.
```

Do public demo / production / Spark claims remain closed?

```text
Yes. Public demo, production, Spark, stable API, all-grammar, and release
claims remain closed.
```

---

## Compact Summary

R222 is accepted. The next Main Line move is a bounded authorization review for
an experimental executable quickstart. The quickstart must prove a tiny
end-to-end path from `.ig` to `.igapp` to a delegated experimental runtime
result, while preserving the canonical/runtime/report/API/release fences.

No implementation, release, public claim, Spark claim, or stable API authority
opens in this card.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R223-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-executable-quickstart-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R222-C4-A

Goal:
Decide whether a bounded experimental executable quickstart implementation may
begin, using the accepted R222 productization decision and preserving the
three-runtime boundary.

Scope:
- Read:
  - igniter-lang/docs/tracks/
    experimental-use-productization-route-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-use-productization-route-options-v0.md
  - igniter-lang/docs/tracks/
    experimental-use-current-surface-and-gap-facts-v0.md
  - igniter-lang/docs/discussions/
    experimental-use-productization-pressure-v0.md
  - igniter-lang/docs/tracks/stage3-round221-status-curation-v0.md
  - igniter-lang/lib/igniter_lang/cli.rb
  - igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - igniter-lang/source/add.ig
  - igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
- Decide:
  - authorize bounded experimental executable quickstart implementation;
  - authorize compile-only quickstart instead;
  - authorize design-only prep;
  - hold pending runtime boundary clarification;
  - redirect.
- If authorizing implementation, define exact:
  - allowed files;
  - source fixture policy;
  - `.igapp` output policy;
  - delegated experimental runtime harness boundary;
  - three-runtime wording;
  - pre-v1 / no-stable-API wording;
  - proof/regression matrix;
  - forbidden phrase scan;
  - closed surfaces.
- Explicitly answer:
  - whether C2-I may begin in this round;
  - whether the quickstart must be executable, not compile-only;
  - whether delegated experimental runtime may be used;
  - whether Runtime Specification remains design/normative only;
  - whether Reference Runtime remains closed;
  - whether RuntimeSmoke source/result shape remains closed;
  - whether lib/bin/gemspec/README/public docs remain closed;
  - whether stable API, production, public demo, Spark, and release claims
    remain closed.

Do not:
- implement code in this card;
- authorize stable API, production, public demo, Spark, or release claims;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize release execution.

Candidate C2-I boundary, if authorized:
- Card: S3-R223-C2-I
- Agent: [Implementation Agent]
- Role: implementation-agent
- Track: experimental-executable-quickstart-v0
- Allowed write scope:
  - igniter-lang/examples/experimental_executable_quickstart_v0/**
  - igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md
- Required behavior:
  - provide one curated `.ig` source fixture;
  - compile it to `.igapp`;
  - execute it through a delegated experimental runtime harness;
  - keep outputs example-local or temp-local;
  - label runtime execution as non-canonical and experimental;
  - include point-of-use pre-v1 / no-stable-API / non-production disclaimer;
  - avoid public API/CLI/runtime/report/release widening.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact C2-I implementation boundary
- If held/redirected: blocker list
```

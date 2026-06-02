# Stage 3 Round 233 Dispatch v0

Status: dispatch-ready
Date: 2026-06-02

## Round Intent

R233 opens a design-only boundary for pre-v1 experimental `igc run` after the
accepted proof-local artifact passport manifest evidence from R232.

This round must decide how an experimental executable command could be shaped
without authorizing implementation. It must preserve the three-runtime model,
passport evidence boundaries, delegated runtime non-authority, and all public
claim closures.

Carry forward from R232:

```text
proof-local passport manifests = evidence/compatibility metadata only
artifact passport != portability guarantee
artifact passport != certification
compiler passport emission remains closed
igc run implementation remains closed
Reference Runtime remains closed
delegated runtime evidence remains non-canonical
```

Lab signal stance for this round:

```text
igniter-tbackend = temporal backend / substrate candidate signal
benchmark-app = performance evidence harness signal
neither creates runtime support, public API, or performance authority
```

## Card Map

| Card | Agent | Purpose |
| --- | --- | --- |
| S3-R233-C1-D | Portfolio Architect Supervisor | Design pre-v1 experimental `igc run` boundary. |
| S3-R233-C2-P1 | Implementation Surface Surveyor | Map current CLI, passport, runtime, backend, and lab surfaces. |
| S3-R233-C3-X | External Pressure Reviewer | Pressure-test design boundary and overclaim risk. |
| S3-R233-C4-A | Portfolio Architect Supervisor | Accept, conditionally accept, hold, or redirect. |
| S3-R233-C5-S | Status Curator | Curate accepted status and next route. |

## Dispatch Cards

```text
Card: S3-R233-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-design-only-boundary-v0

Route: UPDATE
Depends on:
- S3-R232-C5-S

Goal:
Design the pre-v1 experimental `igc run` boundary now that proof-local
artifact passport manifests exist, without authorizing implementation,
compiler passport emission, Reference Runtime support, public runtime support,
stable API, production readiness, Spark integration, release evidence, or
public performance claims.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-v0.md
  - igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/summary.json
  - igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/*.passport.json
  - igniter-lang/docs/tracks/
    experimental-executable-quickstart-acceptance-decision-v0.md
  - igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/
    quickstart_result.json
  - igniter-lang/lib/igniter_lang/cli.rb
  - igniter-lang/bin/igc if present
  - igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - playgrounds/igniter-lab/igniter-runtime/docs/* if present
  - playgrounds/igniter-lab/igniter-tbackend/src/main.rs
  - playgrounds/igniter-lab/igniter-tbackend/src/kernel.rs
  - playgrounds/igniter-lab/igniter-tbackend/src/packs/auth.rs
  - playgrounds/igniter-lab/igniter-tbackend/src/packs/query.rs
  - playgrounds/igniter-lab/igniter-tbackend/src/packs/mcp.rs
  - playgrounds/igniter-lab/igniter-apps/benchmark-app/benchmark.rb
  - playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb
- Design:
  - experimental `igc run` command vocabulary;
  - input artifact policy;
  - required passport/readiness checks;
  - runtime selection policy;
  - delegated runtime adapter stance;
  - output/result shape stance;
  - failure and unsupported-artifact stance;
  - `output_contract` gap handling;
  - lab backend / benchmark signal wording;
  - three-runtime model wording;
  - pre-v1 / no-stable-API wording;
  - implementation authorization prerequisites;
  - closed surfaces.
- Evaluate next-route options:
  - bounded `igc run` implementation authorization review;
  - passport manifest hardening proof;
  - Runtime Specification input slice;
  - Rust TBackend candidate intake;
  - benchmark-app consumer intake;
  - delegated runtime helper extraction;
  - hold / pause.
- Explicitly answer:
  - whether an experimental `igc run` boundary is design-ready;
  - whether implementation authorization may open next or must wait;
  - whether proof-local passport manifests are a sufficient prerequisite;
  - whether compiler passport emission is required before `igc run`;
  - whether delegated runtimes may be named in an experimental command;
  - whether `igniter-tbackend` belongs to runtime, backend, or substrate
    vocabulary;
  - whether benchmark-app evidence may influence design without creating
    public performance claims;
  - whether Reference Runtime, public runtime, stable API, production, Spark,
    release, RuntimeSmoke productization, and public performance claims remain
    closed;
  - exact C4-A recommendation.

Do not:
- edit code;
- authorize `igc run` implementation;
- authorize compiler passport emission;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime support;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize stable API, production, public demo, Spark, release, or public
  performance claims.

Deliver:
- Design doc in `igniter-lang/docs/tracks/`
- Compact `igc run` boundary matrix
- Exact C4-A recommendation
```

```text
Card: S3-R233-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igc-run-current-surface-and-lab-signals-facts-v0

Route: REVIEW
Depends on:
- S3-R232-C5-S

Goal:
Produce a read-only facts packet for the current experimental `igc run`
surface, including CLI shape, proof-local passport manifests, delegated
runtime evidence, Rust TBackend lab signals, and benchmark-app signals, without
making any authority or implementation recommendation beyond surface facts.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
  - igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/summary.json
  - igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/*.passport.json
  - igniter-lang/lib/igniter_lang/cli.rb
  - igniter-lang/bin/igc if present
  - igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb
  - playgrounds/igniter-lab/igniter-runtime/docs/* if present
  - playgrounds/igniter-lab/igniter-runtime/out/**/summary.json if present
  - playgrounds/igniter-lab/igniter-tbackend/README.md
  - playgrounds/igniter-lab/igniter-tbackend/Cargo.toml
  - playgrounds/igniter-lab/igniter-tbackend/src/**
  - playgrounds/igniter-lab/igniter-tbackend/verify_auth.rb
  - playgrounds/igniter-lab/igniter-tbackend/verify_mcp.rb
  - playgrounds/igniter-lab/igniter-apps/benchmark-app/benchmark.rb
  - playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb
- Report:
  - current CLI command surface;
  - whether `igc run` exists today;
  - current compiler output / `.igapp` shape relevant to run design;
  - accepted passport manifest field coverage and gaps;
  - delegated runtime evidence surfaces and implementation ids;
  - Rust TBackend surface classification;
  - AuthPack / QueryPack / McpPack status;
  - benchmark-app status and what it actually measures;
  - RuntimeSmoke surface status;
  - package/gemspec/public docs touch risk;
  - exact closed-surface observations.
- Classify every inspected surface as one of:
  - compiler_surface;
  - cli_surface;
  - runtime_surface;
  - delegated_experimental_runtime;
  - temporal_backend;
  - benchmark_consumer;
  - docs_status_surface;
  - public_claim_surface.
- Explicitly answer:
  - whether any current surface already implements `igc run`;
  - whether passport manifests contain enough fields for design discussion;
  - whether `output_contract` gaps are real and where;
  - whether `igniter-tbackend` is runtime authority, backend candidate, or
    substrate signal;
  - whether MCP/Auth/Query surfaces create public API authority;
  - whether benchmark-app creates public performance evidence;
  - whether any source files contain wording that could confuse lab evidence
    with production/public support.

Do not:
- edit files;
- run destructive commands;
- make implementation recommendations beyond facts;
- authorize runtime/API/CLI/package changes;
- authorize public claims.

Deliver:
- Facts packet in `igniter-lang/docs/tracks/`
- Compact surface classification table
- Exact ambiguity/blocker list for C4-A
```

```text
Card: S3-R233-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-design-only-boundary-pressure-v0

Route: REVIEW
Depends on:
- S3-R233-C1-D
- S3-R233-C2-P1

Goal:
Pressure-test the experimental `igc run` design-only boundary for authority
leaks, market-window realism, implementation creep, runtime/backend
conflation, passport overclaim, and public/stable/performance claim risk.

Scope:
- Read:
  - S3-R233-C1-D design output
  - S3-R233-C2-P1 facts packet
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md
- Pressure-test:
  - whether design-only stayed design-only;
  - whether implementation authorization is too early or correctly bounded;
  - whether `igc run` wording risks becoming a stable CLI/API promise;
  - whether passport manifests are treated as metadata rather than authority;
  - whether compiler passport emission remains closed;
  - whether delegated runtime naming is honest and reversible;
  - whether `igniter-tbackend` is incorrectly promoted to runtime authority;
  - whether benchmark-app signals become public performance claims;
  - whether RuntimeSmoke, Reference Runtime, Spark, public demo, production,
    release, and stable API claims remain closed;
  - whether next route should be implementation authorization, more design,
    Runtime Specification, Rust TBackend intake, benchmark intake, or hold.
- Explicitly answer:
  - accept / conditional accept / hold / redirect recommendation;
  - strongest market-window argument for moving faster;
  - strongest governance argument for holding implementation;
  - exact overclaim phrases to forbid;
  - exact C4-A blocker list if any.

Do not:
- edit files;
- authorize implementation;
- authorize public runtime support;
- authorize stable API, production, public demo, Spark, release, Reference
  Runtime, RuntimeSmoke productization, or public performance claims.

Deliver:
- Pressure verdict in `igniter-lang/docs/discussions/`
- Compact risk table
- Exact accept/hold/redirect recommendation for C4-A
```

```text
Card: S3-R233-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-design-only-boundary-decision-v0

Route: UPDATE
Depends on:
- S3-R233-C1-D
- S3-R233-C2-P1
- S3-R233-C3-X

Goal:
Accept, conditionally accept, hold, or redirect the experimental `igc run`
design-only boundary, and choose the next exact Main Line route toward
experimental executable runtime productization.

Scope:
- Read:
  - C1-D design output
  - C2-P1 surface facts packet
  - C3-X pressure verdict
  - igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
- Decide:
  - accept `igc run` design boundary and authorize later bounded
    implementation-authorization review;
  - accept design but keep implementation held;
  - conditional accept with exact follow-up;
  - hold pending passport/output_contract hardening;
  - redirect to Runtime Specification input slice;
  - redirect to Rust TBackend candidate intake;
  - redirect to benchmark-app consumer intake;
  - pause.
- If accepting any next route, define exact:
  - route/card boundary;
  - whether next route is implementation authorization, design-only, or
    read-only intake;
  - allowed files/surfaces;
  - command vocabulary;
  - passport validation stance;
  - delegated runtime stance;
  - runtime/backend/benchmark separation stance;
  - proof/regression matrix expectations;
  - pre-v1 / no-stable-API wording;
  - public/stable/production non-claims;
  - closed surfaces.
- Explicitly record:
  - `igc run` design boundary status;
  - passport prerequisite status;
  - compiler passport emission status;
  - delegated runtime naming status;
  - `igniter-tbackend` classification status;
  - benchmark-app classification status;
  - RuntimeSmoke status;
  - Reference Runtime/public runtime status;
  - stable API/production/Spark/release/performance claim status.
- Explicitly answer:
  - whether experimental `igc run` design boundary is accepted;
  - whether implementation authorization may open next;
  - whether `igc run` implementation remains closed now;
  - whether compiler passport emission remains closed;
  - whether delegated runtimes may be named by an experimental CLI boundary;
  - whether `igniter-tbackend` and benchmark-app remain lab evidence only;
  - whether Reference Runtime, public runtime, stable API, production,
    public demo, Spark, RuntimeSmoke productization, release, and public
    performance claims remain closed;
  - exact next dispatch recommendation.

Do not:
- authorize implementation unless explicitly and narrowly stated as a future
  authorization-review route;
- authorize compiler passport emission;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime, Reference Runtime, stable API, production, Spark,
  RuntimeSmoke productization, release, or public performance claims.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- Exact next dispatch recommendation or blocker list
```

```text
Card: S3-R233-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round233-status-curation-v0

Route: UPDATE
Depends on:
- S3-R233-C4-A

Goal:
Curate the accepted R233 status into a compact Stage 3 status packet and make
the next Main Line route unambiguous.

Scope:
- Read:
  - S3-R233-C4-A decision
  - S3-R233-C1-D design output
  - S3-R233-C2-P1 facts packet
  - S3-R233-C3-X pressure verdict
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
- Curate:
  - accepted / conditional / held status;
  - exact next route;
  - `igc run` design/implementation status;
  - passport evidence status;
  - compiler passport emission status;
  - delegated runtime status;
  - Rust TBackend / benchmark-app lab-signal status;
  - closed surfaces;
  - open blockers or watchpoints.
- Explicitly answer:
  - what changed in R233;
  - what remains non-authoritative evidence only;
  - what implementation remains closed;
  - what the next card should be.

Do not:
- edit code;
- authorize implementation;
- authorize release execution or public claims.

Deliver:
- Status curation doc in `igniter-lang/docs/tracks/`
- Compact handoff summary
- Exact next card pointer
```

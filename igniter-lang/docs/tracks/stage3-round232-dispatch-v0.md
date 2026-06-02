# Stage 3 Round 232 Dispatch v0

Status: dispatch-ready
Date: 2026-06-02

## Round Intent

R232 opens the proof-local artifact passport manifest step accepted by R231.

This round must produce or reject the first machine-readable passport manifest
for existing delegated experimental runtime evidence. It must not authorize
compiler passport emission, `igc run`, Reference Runtime, public runtime
support, stable API, production readiness, Spark integration, release evidence,
or public performance claims.

Carry forward from R231:

```text
artifact passport = evidence/compatibility metadata boundary
artifact passport != portability guarantee
artifact passport != certification
artifact passport != runtime support
artifact passport != stable API
canonical AOT artifact_kind = igbin_aot_binary
include or explicitly defer execution_substrate
keep runtime/backend/app-consumer dimensions separate
machine-readable non_claims are required
```

Forbidden downstream wording:

```text
formal Artifact Passport Portability Boundary
PORTABILITY PASSPORT
cryptographic signature chains
portable artifact
certified alternative implementation
```

## Card Map

| Card | Agent | Purpose |
| --- | --- | --- |
| S3-R232-C1-A | Portfolio Architect Supervisor | Authorize or hold proof-local manifest proof. |
| S3-R232-C2-I | Implementation Agent | If authorized, create proof-local manifests and evidence. |
| S3-R232-C3-X | External Pressure Reviewer | Pressure-test proof output and authority boundary. |
| S3-R232-C4-A | Portfolio Architect Supervisor | Accept, conditionally accept, hold, or redirect. |
| S3-R232-C5-S | Status Curator | Curate accepted status and next route. |

## Dispatch Cards

```text
Card: S3-R232-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R231-C5-S

Goal:
Decide whether a bounded proof-local artifact passport manifest proof may
begin for existing delegated experimental runtime evidence, without
authorizing passport emission in the compiler, igc run implementation,
Reference Runtime, public runtime support, stable API, production, Spark,
release evidence, or public performance claims.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-minimum-boundary-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-surface-facts-v0.md
  - igniter-lang/docs/discussions/
    experimental-runtime-artifact-passport-minimum-boundary-pressure-v0.md
  - igniter-lang/docs/tracks/
    experimental-executable-quickstart-acceptance-decision-v0.md
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/
    quickstart_result.json
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
    manifest.json
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
    semantic_ir_program.json
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md
  - playgrounds/igniter-lab/igniter-runtime/out/
    ivm_aot_bytecode_file_loading_proof/summary.json if present
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0.md
  - playgrounds/igniter-lab/igniter-runtime/out/
    resident_supervisor_candidate_intake/summary.json if present
- Decide:
  - authorize bounded proof-local passport manifest proof;
  - authorize only schema/design prep;
  - hold pending source artifact availability;
  - hold pending field/vocabulary fixes;
  - redirect to Runtime Specification input slice;
  - redirect to Rust TBackend candidate intake;
  - pause.
- If authorizing C2-I, define exact:
  - allowed write scope;
  - read-only artifact/source scope;
  - minimum manifest field set;
  - artifact kinds to cover;
  - digest recomputation policy;
  - source/SemanticIR chain policy;
  - runtime/backend/app-consumer separation policy;
  - execution_substrate policy;
  - output_contract stance;
  - machine-readable non_claims;
  - forbidden wording scan;
  - proof matrix;
  - command matrix;
  - result packet shape;
  - closed surfaces.
- Must explicitly answer:
  - whether C2-I may begin in this round;
  - whether experiments-only write scope is enough;
  - whether proof may generate manifests for existing .igapp and .igbin
    evidence;
  - whether source artifacts may be copied or must remain read-only;
  - whether canonical AOT artifact_kind is igbin_aot_binary;
  - whether execution_substrate must be included or may be explicitly
    deferred;
  - whether output_contract is mandatory in this proof;
  - whether generated manifests are evidence/compatibility metadata only;
  - whether compiler passport emission remains closed;
  - whether igc run implementation remains closed;
  - whether Reference Runtime, public runtime support, stable API, production,
    Spark, release, and public performance claims remain closed.

Do not:
- implement code in this card;
- authorize compiler passport emission;
- authorize igc run implementation;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime support;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize release execution or public claims.

Candidate C2-I boundary, if authorized:
- Card: S3-R232-C2-I
- Skill: IDD Agent Protocol
- Agent: [Implementation Agent]
- Role: implementation-agent
- Track: experimental-runtime-artifact-passport-manifest-proof-v0
- Allowed write scope:
  - igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-v0.md
- Read-only / closed unless explicitly authorized:
  - igniter-lang/lib/**
  - igniter-lang/bin/igc
  - igniter-lang/igniter_lang.gemspec
  - igniter-lang/README.md
  - igniter-lang/docs/README.md
  - igniter-lang/docs/ruby-api.md
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - igniter-lang/lib/igniter_lang/compiler_result.rb
  - igniter-lang/lib/igniter_lang/compilation_report.rb
  - playgrounds/igniter-lab/**

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact C2-I proof boundary
- If held/redirected: blocker list
```

```text
Card: S3-R232-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-runtime-artifact-passport-manifest-proof-v0

Route: UPDATE
Depends on:
- S3-R232-C1-A

Goal:
Create a bounded proof-local artifact passport manifest proof for existing
delegated experimental runtime evidence, using experiments-only write scope
and preserving all compiler, runtime, CLI, package, public, release, and
playground source surfaces as read-only.

Scope:
- Read:
  - S3-R232-C1-A authorization decision
  - igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/
    quickstart_result.json
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
  - playgrounds/igniter-lab/igniter-runtime/out/
    ivm_aot_bytecode_file_loading_proof/summary.json if present
  - playgrounds/igniter-lab/igniter-runtime/out/
    ivm_aot_bytecode_file_loading_proof/*.igbin if present
  - playgrounds/igniter-lab/igniter-runtime/out/
    resident_supervisor_candidate_intake/summary.json if present
  - playgrounds/igniter-lab/igniter-runtime/out/
    resident_supervisor_candidate_intake/*.igbin if present
- Write only:
  - igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-v0.md
- Required behavior:
  - generate proof-local passport manifest JSON under experiment `out/`;
  - cover at least one compiler-emitted `.igapp` artifact;
  - cover at least one delegated `.igbin` artifact if available;
  - recompute artifact digests deterministically;
  - record source/SemanticIR digest chain when available;
  - explicitly record missing source/SemanticIR links when unavailable;
  - use canonical artifact kinds:
    - `igapp_dir`
    - `semantic_ir_program`
    - `igbin_aot_binary`
    - `evidence_result_packet`
  - include `surface_dimension`;
  - keep `runtime_implementation_id`, `backend_implementation_id`, and
    `consumer_surface_id` distinct;
  - include or explicitly defer `execution_substrate`;
  - include `input_contract`;
  - include `output_contract` or exact deferred rationale;
  - include `failure_policy`;
  - include `evidence_class`, `authority_status`, and machine-readable
    `non_claims`;
  - generate summary/result JSON with proof matrix results;
  - scan generated docs/outputs for forbidden vocabulary.
- Required proof matrix:
  - PPM-1: manifest schema contains all required minimum field families.
  - PPM-2: `.igapp` passport uses `artifact_kind: igapp_dir`.
  - PPM-3: `.igbin` passport uses `artifact_kind: igbin_aot_binary` when
    `.igbin` evidence is present.
  - PPM-4: artifact digest recomputation is deterministic.
  - PPM-5: source digest is recorded when source-backed evidence exists.
  - PPM-6: SemanticIR digest is recorded when SemanticIR exists.
  - PPM-7: missing source/SemanticIR links are explicit, not invented.
  - PPM-8: runtime/backend/app-consumer dimensions remain separated.
  - PPM-9: `runtime_implementation_id` is evidence metadata only.
  - PPM-10: `execution_substrate` is included or explicitly deferred.
  - PPM-11: `input_contract` and `failure_policy` are present.
  - PPM-12: `output_contract` is present or explicitly deferred.
  - PPM-13: `evidence_class`, `authority_status`, and `non_claims` are
    machine-readable.
  - PPM-14: forbidden wording scan passes.
  - PPM-15: source artifact immutability is preserved.
  - PPM-16: closed-surface scan passes.
- Required command matrix:
  - ruby -c igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/
    experimental_runtime_artifact_passport_manifest_v0.rb
  - ruby igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/
    experimental_runtime_artifact_passport_manifest_v0.rb

Do not:
- edit `igniter-lang/lib/**`;
- edit `igniter-lang/bin/igc`;
- edit package/gemspec/readme/public docs;
- edit RuntimeSmoke, CompilerResult, or CompilationReport;
- edit playground sources or evidence artifacts;
- implement compiler passport emission;
- implement igc run;
- claim portability, certification, public runtime support, stable API,
  production readiness, Spark support, release evidence, or public
  performance.

Deliver:
- Proof track doc in `igniter-lang/docs/tracks/`
- Proof script and generated manifests under experiment `out/`
- Summary/result JSON
- Compact handoff with D/S/T/R packet
```

```text
Card: S3-R232-C3-X
Skill: IDD Agent Protocol
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-runtime-artifact-passport-manifest-proof-pressure-v0

Route: REVIEW
Depends on:
- S3-R232-C1-A
- S3-R232-C2-I

Goal:
Pressure-test the proof-local artifact passport manifest proof for authority
drift, schema completeness, vocabulary hygiene, digest integrity,
runtime/backend/app-consumer separation, and premature igc run pressure.

Scope:
- Read:
  - S3-R232-C1-A authorization decision
  - S3-R232-C2-I proof output
  - proof track doc
  - generated passport manifest JSON files
  - proof summary/result JSON
  - igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
- Review:
  - whether proof stayed inside authorized write scope;
  - whether source artifacts remained immutable;
  - whether required field families are complete;
  - whether `igbin_aot_binary` is canonical;
  - whether `.igapp`, SemanticIR, `.igbin`, and result packets are not
    conflated;
  - whether digest recomputation is deterministic and honest;
  - whether `execution_substrate` is included or explicitly deferred;
  - whether `output_contract` stance is sufficient;
  - whether `non_claims` are machine-readable;
  - whether forbidden wording is absent;
  - whether generated outputs avoid portability/certification/runtime claims;
  - whether igc run remains closed to implementation.
- Explicitly answer:
  - whether proof output can be accepted as proof-local passport manifest
    evidence only;
  - whether any field is missing or ambiguous;
  - whether any public/stable/production/performance wording leaks;
  - whether next route may be igc run design-only or must be manifest
    hardening;
  - whether Runtime Specification, Rust TBackend intake, or another route
    should be preferred.

Do not:
- edit files;
- authorize implementation;
- authorize compiler passport emission;
- authorize igc run;
- authorize public runtime support, Reference Runtime, stable API, production,
  Spark, release, or public performance claims.

Deliver:
- Pressure verdict in `igniter-lang/docs/discussions/`
- Compact PASS / CONDITIONAL / HOLD verdict
- Blocker or watchpoint list
- Exact C4-A recommendation
```

```text
Card: S3-R232-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0

Route: UPDATE
Depends on:
- S3-R232-C2-I
- S3-R232-C3-X

Goal:
Accept, conditionally accept, hold, or redirect the proof-local artifact
passport manifest proof, and choose the next exact Main Line route toward
experimental executable runtime productization.

Scope:
- Read:
  - S3-R232-C1-A authorization decision
  - S3-R232-C2-I proof output
  - S3-R232-C3-X pressure verdict
  - proof track doc
  - generated passport manifest JSON files
  - proof summary/result JSON
  - igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
- Decide:
  - accept proof-local manifest evidence;
  - conditional accept with exact follow-up;
  - hold pending proof/schema/digest fixes;
  - route manifest hardening proof;
  - route experimental igc run design-only boundary;
  - route Runtime Specification input slice;
  - route Rust TBackend candidate intake;
  - pause.
- If accepting, explicitly record:
  - exact changed files;
  - command matrix result;
  - PPM-1..PPM-16 result;
  - generated manifest files;
  - artifact kind status;
  - digest recomputation status;
  - source/SemanticIR chain status;
  - runtime/backend/app-consumer separation status;
  - execution_substrate status;
  - output_contract status;
  - authority_status / non_claims status;
  - forbidden wording scan status;
  - source artifact immutability status;
  - closed-surface scan status.
- Explicitly answer:
  - whether proof-local passport manifest evidence is accepted;
  - whether generated manifests may be called evidence/compatibility metadata
    only;
  - whether this creates portability guarantees;
  - whether this creates compiler passport emission authority;
  - whether igc run design-only may open next;
  - whether igc run implementation remains closed;
  - whether Runtime Specification or Rust TBackend intake should open before
    igc run design;
  - whether Reference Runtime, public runtime support, stable API, production,
    Spark, release, and public performance claims remain closed;
  - exact next dispatch recommendation.

Do not:
- authorize new implementation unless explicitly and narrowly stated as a
  future authorization-review or design-only route;
- authorize compiler passport emission;
- authorize igc run implementation;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime, Reference Runtime, stable API, production, Spark,
  RuntimeSmoke productization, release, or public performance claims.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- Exact next dispatch recommendation or blocker list
```

```text
Card: S3-R232-C5-S
Skill: IDD Agent Protocol
Agent: [Status Curator]
Role: status-curator
Track: stage3-round232-status-curation-v0

Route: SUMMARY
Depends on:
- S3-R232-C4-A

Goal:
Curate the accepted, conditional, held, or redirected R232 status into a
compact Main Line status packet and exact next route, without expanding
historical narrative.

Scope:
- Read:
  - S3-R232-C4-A decision doc
  - S3-R232-C2-I proof output if accepted or conditionally accepted
  - S3-R232-C3-X pressure verdict
  - igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md
  - igniter-lang/docs/current-status.md
- Curate:
  - R232 outcome table;
  - accepted / conditional / held status;
  - generated manifest status if accepted;
  - carry-forward constraints;
  - closed surfaces;
  - exact next route;
  - whether `docs/current-status.md` needs a compact delta.
- Preserve:
  - artifact passport evidence/compatibility metadata boundary;
  - no portability/certification/runtime/stable API claims;
  - igc run implementation closed;
  - runtime/backend/app-consumer separation.

Do not:
- edit code;
- authorize implementation;
- authorize compiler passport emission;
- authorize igc run implementation;
- authorize release execution or public claims.

Deliver:
- Status curation doc in `igniter-lang/docs/tracks/`
- Optional compact `docs/current-status.md` delta only if C4-A changes Main
  Line status
- Exact next route receipt
```

# Track: PROP-038 Compiler Profile Contract Implementation Scope Survey v0

Card: S3-R62-C1-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-compiler-profile-contract-implementation-scope-survey-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Survey the exact implementation scope for PROP-038
`compiler_profile_contract` without implementing it.

This track edits no code and no experiments. It prepares an implementation
authorization boundary only.

---

## Inputs Read

- `igniter-lang/roles/implementation-agent.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/gates/prop038-compiler-profile-contract-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/docs/tracks/prop038-compiler-profile-contract-authoring-v0.md`
- `igniter-lang/docs/discussions/prop038-compiler-profile-contract-pressure-v0.md`
- `igniter-lang/docs/gates/compiler-profile-contract-validator-coverage-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round61-status-curation-v0.md`

---

## Inspection Commands

```text
rg -n "compiler_profile|profile_contract|contract_digest|CompilerProfile|compiler_profile_contract|obligation|profile_not_supplied" igniter-lang/lib igniter-lang/experiments igniter-lang/spec
```

Result:

- `igniter-lang/lib` scanned.
- `igniter-lang/experiments` scanned.
- `igniter-lang/spec` is absent in this workspace, so that path reported
  `No such file or directory`.
- No files were edited by the inspection.

```text
rg --files igniter-lang/lib/igniter_lang igniter-lang/experiments | rg "(compiler_profile|profile|contract|orchestrator|assembler|compilation_report|cli)"
```

Result:

- identified current compiler/profile implementation and proof surfaces listed
  below.

```text
find igniter-lang/lib/igniter_lang -maxdepth 2 -type f | sort
```

Result:

- confirmed current production library file layout and likely integration
  candidates.

---

## Current Code Surface Findings

### Public Ruby Facade

File: `igniter-lang/lib/igniter_lang.rb`

Current surface:

- `IgniterLang.compile(..., compiler_profile_source: nil)` accepts an already
  finalized caller-supplied source.
- The facade does not discover, finalize, default, or load profile sources.

Implementation implication:

- PROP-038 must not widen this public API in the first implementation unless a
  later gate explicitly authorizes public contract input.

### CLI

File: `igniter-lang/lib/igniter_lang/cli.rb`

Current surface:

- `--compiler-profile-source PATH.json` loads JSON and passes it to
  `IgniterLang.compile`.
- No CLI `compiler_profile_contract` input exists.

Implementation implication:

- CLI widening is closed for this survey and should stay closed for a first
  implementation boundary.

### Compiler Orchestrator

File: `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`

Current pipeline:

```text
parse -> classify -> typecheck -> emit -> enrich report -> assemble
```

Current profile behavior:

- `compiler_profile_source` is accepted as an optional keyword.
- The source is forwarded unchanged into `Assembler#assemble_case`.
- `AssemblyRefused` is converted into a compilation report with rule
  `assembler_refused`.

Implementation implication:

- This is the only obvious production insertion point for report-only or
  compile-refusal behavior after existing parser/classifier/typechecker/emitter
  work completes.
- It is not currently an insertion point for validation before profile
  finalization because finalization is outside this compiler surface.
- Without a new internal contract input, the orchestrator cannot validate a
  `compiler_profile_contract` object independently of `compiler_profile_source`.

### Assembler

File: `igniter-lang/lib/igniter_lang/assembler.rb`

Current profile behavior:

- Owns `compiler_profile_source` shape validation through
  `validate_compiler_profile_source!`.
- Emits diagnostics under `compiler_profile_source.*`.
- Injects `compiler_profile_id` into artifact hash material and manifest when a
  non-nil source is supplied.
- Preserves legacy behavior when the source is nil.

Implementation implication:

- Assembler is the wrong first home for PROP-038 contract validation because
  assembler and `.igapp` mutation are explicitly closed surfaces.
- Reusing assembler refusal for contract validation would blur
  `compiler_profile_source.*` and `compiler_profile_contract.*`.

### Compilation Report

File: `igniter-lang/lib/igniter_lang/compilation_report.rb`

Current surface:

- Stages are parse/classify/typecheck/emit-oriented.
- Existing helpers cover parse failure, runtime smoke failure, internal error,
  and report enrichment.
- No contract-validation result field exists.

Implementation implication:

- Report-only compiler integration would likely need this file or an adjacent
  report object, but output schema and persistence location are not authorized
  yet.

### Diagnostics

File: `igniter-lang/lib/igniter_lang/diagnostics.rb`

Current surface:

- Shared diagnostic object helpers exist.

Implementation implication:

- A future integrated validator may use this file or a local validator helper
  for canonical `compiler_profile_contract.*` diagnostics.
- The namespace should remain separate from `compiler_profile_source.*`,
  loader/report, runtime-readiness, and obligation diagnostics.

### Existing Proof

File:
`igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`

Current proof behavior:

- Builds and validates proof-local `compiler_profile_contract` objects.
- Uses `compiler_profile_contract.*` diagnostics.
- Covers required slots, duplicate strict registry keys, duplicate fragment
  owners, rule cycles, missing rule references, unsupported versions, wrong
  kinds, digest shape, and forbidden authority vocabulary.
- Uses short SHA-256 references for descriptor and contract digests.

Implementation implication:

- This is the safest basis for a future proof-local implementation card.
- It still needs explicit missing-`after` `missing_rule_reference` coverage
  before or with first implementation authorization.

---

## Exact Write-Surface Options

| Option | Candidate write surface | First-use mode | What it would do | Risks / blockers | Recommendation |
| --- | --- | --- | --- | --- | --- |
| A | `igniter-lang/experiments/compiler_profile_contract_proof/` | Proof-local only | Extend proof-local validator coverage, including missing-`after`; keep output under proof summary only. | Experiments are not authorized for this card; future card must authorize experiment edits. Does not integrate compiler behavior. | Best first implementation boundary after authorization. |
| B | New `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | Proof-local or internal library | Introduce isolated validator returning `compiler_profile_contract.*` diagnostics without parser/typechecker/assembler changes. | Needs implementation authorization; must decide digest input material and short-vs-full policy before durable claims. | Good second step if A proves exact behavior. |
| C | `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | Report-only compiler integration | Invoke validator in the compile pipeline and attach diagnostics/report state without refusing compilation. | No current contract input; report schema and persistence location unresolved; public API/CLI widening is closed. | Hold until contract input and report policy are authorized. |
| D | `igniter-lang/lib/igniter_lang/compilation_report.rb` | Report-only compiler integration | Add structured contract-validation report fields or diagnostic attachment. | Schema change without output-location policy; may create de facto public behavior. | Hold until report-only contract is explicitly accepted. |
| E | `igniter-lang/lib/igniter_lang/diagnostics.rb` | Integrated diagnostics | Centralize canonical `compiler_profile_contract.*` diagnostic construction. | Premature if validator remains proof-local; namespace policy must remain narrow. | Optional only with B/C/D authorization. |
| F | `igniter-lang/lib/igniter_lang/compiler_result.rb` | Public result exposure | Expose contract validation state on compile result. | Public surface widening and compatibility implications. | Do not use for first implementation. |
| G | `igniter-lang/lib/igniter_lang/assembler.rb` | Assembly-time refusal | Validate contract near artifact assembly. | Assembler and `.igapp` changes are closed; wrong ownership; conflates source and contract diagnostics. | Do not use for first implementation. |
| H | `igniter-lang/lib/igniter_lang.rb` | Public API input | Add public `compiler_profile_contract:` input. | CLI/API widening is closed; finalization/discovery/defaulting policy unresolved. | Do not use. |
| I | `igniter-lang/lib/igniter_lang/cli.rb` | CLI input | Add CLI flag or loader for contract JSON. | CLI widening, loader/report vocabulary risk, path-loading policy not authorized. | Do not use. |
| J | `.igapp`, goldens, receipts, `.ilk`, signing outputs | Persistence | Persist contract, digest, receipt, or validation result. | Explicitly closed by acceptance decision; fixture/golden policy unresolved. | Do not use. |

---

## First Implementation Mode Comparison

### Proof-Local Only

Boundary:

- edit only a future authorized proof-local experiment and summary;
- no production compiler behavior;
- no public API or CLI widening;
- no artifact or golden mutation.

Pros:

- matches proposal-only acceptance status;
- can close missing-`after` coverage;
- can exercise digest policy variants without making durable compiler claims;
- preserves all closed surfaces.

Cons:

- does not prove compiler integration.

Verdict:

```text
recommended first implementation boundary
```

### Report-Only Compiler Integration

Boundary:

- validator runs in compiler pipeline;
- failures appear as diagnostics/report metadata;
- compilation does not refuse solely because of contract validation.

Pros:

- lower risk than compile refusal;
- could prepare visibility before enforcement.

Blockers:

- no authorized contract input surface exists;
- report schema and persistence location are undecided;
- may create public behavior if exposed through `CompilationReport` or
  `CompilerResult`;
- insertion point is ambiguous until contract input ownership is resolved.

Verdict:

```text
hold until report/output and contract-input policy are authorized
```

### Compile-Refusal Capable

Boundary:

- invalid contract can refuse compilation.

Pros:

- aligns with eventual strict contract intent.

Blockers:

- acceptance decision explicitly holds implementation;
- refusal behavior is a new compiler behavior;
- digest material, digest length, diagnostic placement, report shape, and
  insertion point are unresolved;
- would risk unauthorized widening if contract input is public.

Verdict:

```text
not ready
```

### Hold For More Design

Boundary:

- no implementation.

Pros:

- avoids premature compiler behavior.

Cons:

- misses an opportunity to close proof-local coverage and refine validator
  shape.

Verdict:

```text
not necessary if first card is proof-local only; necessary for compiler
integration or refusal
```

---

## Policy Blockers

### Descriptor Digest Input Material

Open:

- exact object/material computed over by `descriptor_digest`;
- canonical serialization rules;
- whether `descriptor_digest` itself is excluded from the hashed material;
- whether the source is the descriptor object, the full contract projection, or
  a finalized profile descriptor payload.

Required before implementation authorization:

```text
Define descriptor_digest canonical input material exactly.
```

### Short-Vs-Full Digest Reference Policy

Open:

- PROP-038 accepts 24+ lowercase hex for descriptor and contract digest
  references.
- Proof uses short references.
- Durable storage may need full 64-character references.

Required before durable or persisted implementation:

```text
Decide whether implementation accepts 24+ only, emits full 64, or supports
short references only in proof-local summaries.
```

Recommended policy:

- proof-local may keep PROP-038-compatible `24+` validation;
- persisted or durable outputs should prefer full 64-character SHA-256 unless a
  gate explicitly approves short references.

### Report-Only Versus Compile-Refusal

Open:

- whether invalid contracts should only report diagnostics or refuse compile;
- whether refusal is allowed before a contract is public/compiler input.

Required before compiler integration:

```text
Authorize one behavior: proof-only, report-only, or refusal-capable.
```

Recommended policy:

- first implementation: proof-local only;
- second step: report-only only after report schema approval;
- refusal: hold for a dedicated gate.

### Persistence / Output Location

Open:

- no accepted location for contract object, validation report, digest, receipt,
  `.ilk`, sidecar, or `.igapp` output.

Required before output changes:

```text
Choose whether there is no persisted output, proof summary only, compilation
report metadata, sidecar, receipt, `.ilk`, or another artifact.
```

Recommended policy:

- first implementation should use proof summary only;
- do not mutate `.igapp` or goldens.

### Fixture / Golden Policy

Open:

- whether future fixtures live in experiments only or production specs;
- whether any golden output must be updated.

Required before implementation:

```text
Authorize fixture location and explicitly state whether golden mutation is
allowed.
```

Recommended policy:

- proof-local fixtures only for first card;
- no golden migration.

### Missing-`after` `missing_rule_reference` Coverage

Open:

- accepted proof covers missing rule reference behavior but the authoring and
  pressure tracks call out missing-`after` direction coverage as a follow-up.

Required before or with first implementation:

```text
Add proof-local missing-`after` `missing_rule_reference` coverage.
```

Recommended placement:

- `igniter-lang/experiments/compiler_profile_contract_proof/` in a future
  authorized proof-local implementation card.

### Diagnostic Namespace Placement

Open:

- whether diagnostics remain local to a validator or are centralized in
  `IgniterLang::Diagnostics`.

Required before integration:

```text
Keep all new contract diagnostics under `compiler_profile_contract.*` and do
not reuse loader/report, runtime-readiness, obligation, or
`compiler_profile_source.*` vocabulary.
```

Recommended placement:

- proof-local validator first;
- optional production helper only when an integrated validator is authorized.

### Compiler / Orchestrator Insertion Point

Open:

- current compiler receives only finalized `compiler_profile_source`, not a
  contract object.
- PROP-038 validation order wants contract validation before source transport,
  but current public compiler surface cannot satisfy that without widening.

Candidate future insertion points:

```text
proof-local: before any compiler call, inside the proof harness
report-only: orchestrator after emit/report enrichment and before assembler,
             only if a contract object is internally available
refusal:     same as report-only, but only after explicit refusal authority
```

Not candidates:

- parser;
- classifier;
- TypeChecker;
- SemanticIR emitter;
- assembler;
- CLI;
- public Ruby facade.

---

## Preserved Closed Surfaces

This survey preserves and recommends preserving the following closed surfaces:

- parser changes;
- TypeChecker changes;
- SemanticIR changes;
- assembler or `.igapp` changes;
- CLI/API widening;
- profile discovery/defaulting/finalization in public surfaces;
- golden migration;
- loader/report;
- CompatibilityReport;
- `.ilk`, receipts, signing;
- dispatch migration;
- RuntimeMachine / Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP;
- cache;
- production behavior.

---

## Recommendation

```text
recommended first implementation boundary: proof-local only
```

Recommended first card:

- authorize edits only under
  `igniter-lang/experiments/compiler_profile_contract_proof/`;
- add missing-`after` `missing_rule_reference` coverage;
- keep diagnostics under `compiler_profile_contract.*`;
- keep summary output proof-local;
- do not touch compiler orchestrator, assembler, CLI, public facade, `.igapp`,
  goldens, loader/report, CompatibilityReport, receipts, `.ilk`, signing,
  runtime, Ledger/TBackend, cache, or production behavior.

Recommended hold:

- hold report-only compiler integration until contract input and report output
  policy are explicit;
- hold compile-refusal capability until a dedicated gate authorizes refusal
  behavior.

---

## Blockers Before Implementation Authorization

[B1] Define exact descriptor digest input material and canonicalization.

[B2] Decide short-vs-full digest reference policy for implementation and any
persisted output.

[B3] Authorize one first behavior: proof-local only, report-only compiler
integration, or compile-refusal capable.

[B4] Define output location: proof summary only, compilation report metadata,
sidecar, receipt, `.ilk`, `.igapp`, or none.

[B5] Authorize fixture location and state whether golden mutation is allowed.

[B6] Place missing-`after` `missing_rule_reference` coverage in a future
authorized proof-local validator proof.

[B7] Decide whether `compiler_profile_contract.*` diagnostics stay local to a
validator or become shared `Diagnostics` helpers.

[B8] Define compiler/orchestrator insertion point only after contract input
ownership is resolved.

---

## Handoff

```text
Card: S3-R62-C1-P1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-compiler-profile-contract-implementation-scope-survey-v0
Status: done

[D] Decisions
- No implementation performed.
- No code edited.
- No experiments edited.
- Candidate write surfaces are mapped.
- First implementation should be proof-local only.
- Report-only compiler integration is held pending contract-input and report
  output policy.
- Compile-refusal capability is not ready.

[S] Signals
- Current compiler path accepts `compiler_profile_source`, not
  `compiler_profile_contract`.
- Existing assembler validates source shape and injects `compiler_profile_id`;
  it should not own PROP-038 contract validation.
- Existing proof is the safest first implementation base.

[T] Tests / Proofs
- Survey-only track.
- `rg` inspection completed.
- No test suite run because no code was changed.

[R] Recommendation
- Authorize a proof-local-only implementation card after B1-B6 are accepted or
  explicitly scoped.
- Do not authorize report-only compiler integration or compile-refusal until
  B1-B8 are resolved.
```

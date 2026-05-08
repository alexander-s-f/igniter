# Bridge Agent Entry v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/bridge-agent-entry-v0`
Status: research
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Entry Point

This slice initializes the Bridge Agent presence in `igniter-lang/docs/bridge/`
and records the current pressure map. It is not a package integration request.

## Current Horizon

- Igniter-Lang is an Epistemic Contract Language, not syntax sugar for the Ruby
  platform.
- The stable spine is `ParsedProgram -> ClassifiedProgram -> TypedProgram ->
  SemanticIR -> CompiledProgram / .igapp -> RuntimeMachine`.
- Runtime meaning is governed by contract, explicit time, observation evidence,
  capability-gated ESCAPE, receipts/failures, semantic images, compatibility
  reports, and schema migration evidence.
- Proof-scale artifacts exist for parser fixtures, `.igapp` fixtures, memory
  RuntimeMachine, packet profiles, FFI receipts, and schema migration receipt
  shape.
- The bridge role translates approved signals into platform requests; it does
  not edit packages in this slice.

## Pressure Map

Critical:

- The full parser -> classifier -> typechecker -> SemanticIR path is still
  missing. Any bridge to the current platform must not imply source compiler
  integration is ready.
- `polymorphic_add.ig` is still pressure-only. Platform bridge work must not
  expose unresolved traits, generic type variables, or overload dispatch as
  runtime concerns.
- Schema migration evidence exists, but replacement `SemanticImage` production
  is still open. Migration bridge work should stay diagnostic or fixture-level
  until trusted post-migration resume is proven.
- External/package candidate equivalence is not defined for real package
  outputs. Platform adapters should target `selected_profile` candidates first.

High:

- Runtime evidence packet builders have a completed implementation plan, but
  no approved package integration slice.
- FFI Ruby calls are contractable at proof scale, but capability algebra
  details such as delegation, overlap, revocation, serialization, and
  composition are still queued.
- Temporal lifecycle boundary fixtures now model dispatch pressure. A bridge
  must preserve the difference between reproducible decision meaning and exact
  raw telemetry replay.

## Source Signals

[S] Runtime evidence bridge vocabulary is already specified through completed
tracks for observation envelopes, runtime evidence, package mapping, and
metadata-only implementation planning.

[S] RuntimeMachine proof artifacts now provide golden ObsPackets,
SemanticImage, CompatibilityReport, negative evidence, result summary, sidecar
profiles, and selected-profile candidate checks.

[S] FFI proof artifacts model host calls as ESCAPE contracts:

```text
intent_observation
  -> CapabilityGate
  -> host call
  -> receipt_observation | failure_observation
```

[S] Schema migration proof artifacts model:

```text
MigrationDescriptor
  -> schema_check:migrating
  -> intent_observation
  -> audit receipt_observation
```

## Bridge Claims

[D] The first Bridge Agent presence is an index plus pressure note, not an
integration request.

[D] A valid bridge note must start from an approved source signal and must keep
the CORE / ESCAPE / OOF boundary visible.

[D] The default bridge target is metadata-only: sidecar ObsPacket builders,
fixture normalizers, diagnostics, compatibility reports, and admission checks.

[D] Package code should remain untouched until the Architect Supervisor approves
a separate integration slice.

## Candidate Touch Points

- Runtime evidence sidecars: `RuntimeMachine`, execution environment,
  checkpoint, resume, compatibility report, and meaning-status diagnostics.
- TBackend adapter admission: Ledger or file-backed adapters as candidates only
  after selected-profile evidence exists.
- FFI receipts: capability-gated host calls with intent, receipt, and failure
  packets before platform-level executor work.
- Schema compatibility: report surfaces for trusted, provisional, migrating,
  downgraded, and blocked resume decisions.
- Temporal lifecycle: boundary packets for snapshots, compacted stubs, decision
  receipts, and audit roots.

## Migration Risk

[R] Avoid a direct bridge from language theory into package semantics. The
current low-risk path is:

```text
completed source signal
  -> bridge note
  -> sidecar fixture/profile target
  -> checker admission
  -> Architect approval
  -> package integration slice
```

[R] Keep all bridge artifacts contract-addressable and evidence-linked. A
platform result without observation links should remain provisional or
non-admissible for language claims.

## Architect Decision Required

[Q] Which bridge should be first:
runtime evidence packet builders, FFI receipt admission, schema compatibility
diagnostics, or temporal lifecycle boundary packets?

[Q] Should the first approved package bridge target a sidecar builder only, or
may it add a diagnostics surface in the platform once candidate fixtures pass?

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/bridge-agent-entry-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Initialized docs/bridge/ as the Bridge Agent landing pad.
- Recorded Bridge Agent entry as pressure analysis only, not package integration approval.
- Set metadata-only sidecars, fixture normalizers, diagnostics, compatibility reports, and checker admission as the default bridge path.

[R] Recommendations:
- Ask Architect Supervisor to select the first approved bridge request.
- Prefer runtime evidence packet builders or schema compatibility diagnostics as first bridge candidates because both have clear proof artifacts and low package semantics risk.
- Require selected-profile or equivalent checker admission before real package-derived packets claim language evidence.

[S] Signals:
- Current research has proof-scale artifacts for RuntimeMachine packets, FFI receipts, and schema migration receipt shape.
- The full compiler path, PROP-016 monomorphization proof, replacement SemanticImage after migration, and package candidate equivalence remain open pressure.

[T] Tests / Proofs:
- Not run. Documentation-only slice.

[Files] Changed:
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/bridge/bridge-agent-entry-v0.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Which bridge should be first: runtime evidence packet builders, FFI receipt admission, schema compatibility diagnostics, or temporal lifecycle boundary packets?
- Should the first approved package bridge target sidecar builders only, or may it add a diagnostics surface once candidate fixtures pass?

[X] Rejected:
- Direct platform package edits in this slice.
- Treating Ledger as the language core instead of a possible TBackend adapter.

[Next] Proposed next slice:
- Architect Supervisor selects one approved bridge note target and assigns a narrow Bridge Agent package touch-point map.
```

# Igniter-Lang Bridge Notes

Status: active bridge index
Owner: `[Igniter-Lang Bridge Agent]`

## Purpose

This directory is the landing pad for bridge notes from `igniter-lang`
research into the Igniter platform.

Bridge notes do not authorize package edits. They translate approved language
signals into compact platform requests that the `[Architect Supervisor /
Codex]` can approve, redirect, or reject.

## Bridge Rules

- Start from an approved source signal, fixture, proposal, or completed track.
- Name the bridge claim and target package touch points explicitly.
- Preserve the current fixed point: contract-addressable meaning, explicit
  time, observation evidence, CORE / ESCAPE / OOF, capability gates, receipts,
  SemanticIR with no unresolved overloads, and schema migration evidence.
- Prefer metadata-only sidecar builders, diagnostics, and fixture admission
  before any runtime/package behavior changes.
- Treat Ledger as a possible `TBackend` adapter, not the language core.
- End every bridge note with a handoff in
  `igniter-lang/handoff/HANDOFF_TEMPLATE.md` shape.

## Active Bridge Notes

| Bridge Note | Status | Purpose |
|-------------|--------|---------|
| [bridge-agent-entry-v0.md](bridge-agent-entry-v0.md) | research | Initializes Bridge Agent presence and records current bridge pressure before any package integration request |
| [schema-compatibility-diagnostics-bridge-v0.md](schema-compatibility-diagnostics-bridge-v0.md) | proposal | First metadata-only bridge request for schema compatibility diagnostics |
| [schema-compatibility-diagnostics-package-touchpoint-map-v0.md](schema-compatibility-diagnostics-package-touchpoint-map-v0.md) | proposal | Architect-reviewable package target map for SchemaCompatibilityDiagnostic v0 |
| [schema-compatibility-diagnostics-igniter-contracts-plan-v0.md](schema-compatibility-diagnostics-igniter-contracts-plan-v0.md) | proposal | Architect-approved implementation plan for SchemaCompatibilityDiagnostic v0 in igniter-contracts |
| [schema-migration-bridge-profile-v0.md](schema-migration-bridge-profile-v0.md) | proposal | Single-hop migration evidence profile for SchemaCompatibilityDiagnostic v0 |
| [spark-availability-diagnostics-bridge-profile-v0.md](spark-availability-diagnostics-bridge-profile-v0.md) | proposal | Metadata-only diagnostics profile for the executable Spark availability fixture |
| [operation-diagnostics-and-receipts-bridge-profile-v0.md](operation-diagnostics-and-receipts-bridge-profile-v0.md) | proposal | Generic metadata-only operation action diagnostics and receipt profiles before package work |
| [lead-boundary-diagnostics-retention-bridge-profile-v0.md](lead-boundary-diagnostics-retention-bridge-profile-v0.md) | proposal | Metadata-only lead boundary diagnostics, rollup, Decimal, idempotency, and retention receipt profiles |
| [model-validity-and-scenario-comparison-bridge-profile-v0.md](model-validity-and-scenario-comparison-bridge-profile-v0.md) | proposal | Metadata-only simulation run diagnostics, model validity, scenario comparison, assumption diff, and review-only strategy profiles |
| [human-agent-review-approval-bridge-profile-v0.md](human-agent-review-approval-bridge-profile-v0.md) | proposal | Metadata-only human-agent proposal, review, meaning diff, correction, verification, and acceptance receipt profiles |
| [osint-claim-factcheck-correction-bridge-profile-v0.md](osint-claim-factcheck-correction-bridge-profile-v0.md) | proposal | Metadata-only OSINT-like source observation, claim trace, evidence, confidence, contradiction, fact-check snapshot, analyst decision, citation/redaction, and correction profiles |
| [osint-product-bridge-profiles-v0.md](osint-product-bridge-profiles-v0.md) | proposal | Metadata-only personal OSINT assistant product profiles for watchlists, daily briefs, evidence-linked alerts, reputation drift, source reliability, claim timelines, audit reports, and safe action policy |
| [semanticir-verification-report-bridge-v0.md](semanticir-verification-report-bridge-v0.md) | proposal | Report-only bridge for compiled SemanticIR artifact hashes, classifier/typecheck diagnostics, OOF findings, and runtime proof receipts into VerificationReport metadata |
| [compiler-pipeline-profile-bridge-v0.md](compiler-pipeline-profile-bridge-v0.md) | proposal | Unified report-only compiler pipeline profile family for ParsedProgram, ClassifiedProgram, TypedProgram, SemanticIR, compiler OOF diagnostics, and RuntimeMachine load receipts |
| [compiler-pipeline-profile-prop019-alignment-v0.md](compiler-pipeline-profile-prop019-alignment-v0.md) | proposal | PROP-019/019.1 alignment for compiler_pipeline_profiles examples: canonical semantic_ir_program, separated CompilationReport diagnostics, typed profile pending, and historical semanticir_verification_profiles |

## Current Bridge Pressure

[S] The bridge surface is ready for analysis but not package integration.
Runtime evidence, packet profiles, FFI receipts, and schema migration receipts
have proof-scale artifacts. The next safe bridge motion is to convert approved
signals into metadata-only sidecar or diagnostics requests.

[S] Schema compatibility diagnostics now have a first bridge request. It stays
read-only and metadata-only: schema versions, schema fingerprints,
`schema_check` outcome, migration availability/ref, compatibility decision, and
evidence links.

[S] The package touch-point map recommends `packages/igniter-contracts`
Lang/reporting as the first target because it already owns report-only metadata
near the embedded contract kernel.

[S] The igniter-contracts plan recommends both: a standalone immutable
`Igniter::Lang::SchemaCompatibilityDiagnostic` plus an optional
`VerificationReport` section.

[S] The migration bridge profile carries P-1 through P-10 into package
metadata: `migration_chain: []`, no `supersedes`, required `replaces`,
`caused_by`, `produced_by`, `produced_in`, and OOF-MR3 blocked
wrong-fingerprint diagnostics.

[S] The Spark availability bridge profile maps the executable synthetic
fixture to report-only diagnostics: tenant scope source, scoped reads,
cardinality bounds, slot reason counts, source refs, failure step/kind, and
redaction policy.

[S] Operation diagnostics now have generic report-only profiles for action
policy, request receipts, execution receipts, duplicate pending/idempotent
no-op receipts, and optional external bridge receipts.

[S] Lead boundary diagnostics now have generic report-only profiles for
boundary decisions, hourly rollups, duplicate non-admission, Decimal wire
values, idempotency `identified_by` links, late-boundary blocking, and retention
dry-run/execution receipts.

[S] Simulation/world-modeling outputs now have generic report-only profiles for
model validity, scenario comparison, run diagnostics, assumption/parameter
diffs, and review-only strategy candidates with explicit non-authorization
semantics.

[S] Human-agent review now has generic report-only profiles for proposal,
review projection, meaning diff, human correction, runtime verification, and
scoped acceptance, with agent prose explicitly excluded from artifact-of-record
status.

[S] OSINT-like claim/fact-check correction now has generic report-only profiles
for source observations, claim traces, evidence links, confidence assessments,
contradictions, snapshots, analyst decisions, citation/redaction policies, and
correction receipts. Repeated claims remain non-independent evidence, and
confidence remains not-truth.

[S] Personal OSINT assistant outputs now have report-only product profiles
aligned with `VerificationReport` `custom_sections.osint_product_profiles` and
`carrier_manifest` semantics. No real ingestion, runtime, external actions, UI,
or package edits are authorized.

[S] SemanticIR proof results now have a report-only bridge into
`VerificationReport` metadata through
`custom_sections.semanticir_verification_profiles`, while `metadata_manifest`
stays focused on package operation declarations.

[S] Compiler pipeline profiles now have unified package-facing names under
`custom_sections.compiler_pipeline_profiles`: parsed, classified, typed,
SemanticIR, compiler OOF diagnostic, and runtime load receipt profiles. This
supersedes the narrower `semanticir_verification_profiles` name for new package
work.

[S] Compiler pipeline profile examples are now aligned to PROP-019 and
PROP-019.1: `semanticir_program_profile_v0` expects
`kind: "semantic_ir_program"`, OOF diagnostics live in `CompilationReport`, and
`typed_program_profile_v0` remains planned/pending until the PROP-021 proof
lands.

[Q] Should generic package diagnostics be named
`ProjectionDiagnostic`/`PipelineDiagnostic`, or remain plain
`VerificationReport` payload sections?

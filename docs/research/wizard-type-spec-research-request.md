# Wizard Type Spec Research Request

Status date: 2026-04-29.
From: `[Architect Supervisor / Codex]`.
To: Research.
Track: `wizard-type-spec-lineage-materialization`.

## Claim

`WizardTypeSpec` may be more than a wizard draft store. It may be the durable
lineage layer for user-defined contract shapes, static contract synchronization,
portable config export, and future migration planning.

## Current App-Local Proof

Companion now proves this shape without core/runtime promotion:

- `WizardTypeSpec`: persisted latest dynamic spec
  - `id`
  - `contract`
  - `spec`, `type: :json`
- `WizardTypeSpecChange`: append-only spec lineage
  - static sync/backfill events
  - full spec snapshots for migration analysis
- `DurableTypeMaterializationContract`: read-only lowering from latest spec to
  static record/history/relation materialization plan
- `StaticMaterializationParityContract`: read-only parity check between the plan
  and current static manifests
- `WizardTypeSpecExportContract`: portable config projection
  - dev export keeps history
  - prod export compresses to latest-only specs

The current example is `Article` + `Comment`:

- latest spec lives in `wizard_type_specs`
- history lives in `wizard_type_spec_changes`
- static contracts still exist as normal Ruby contracts
- materialization plan and parity are inspectable through setup endpoints
- no dynamic spec is executed as runtime code
- no write/git/restart capability is granted

## Decision Pressure

Static contracts can sync their own specs into `WizardTypeSpec`. That creates a
shared representation for:

- wizard-authored drafts
- static contract manifests
- materialization plans
- drift/parity reports
- migration candidates
- portable config snapshots

This suggests `WizardTypeSpec` may become the neutral durable shape registry,
while static contracts remain the production execution shape.

## Research Questions

1. Should `WizardTypeSpec` be modeled as `Store[ContractSpec]` in the future
   language layer?
2. Should `WizardTypeSpecChange` be modeled as `History[ContractSpecChange]`,
   or as a specialized migration/lineage history?
3. What is the correct canonical form of `spec` so it can round-trip between:
   wizard JSON, static Ruby contracts, and future `Igniter::Lang` syntax?
4. What belongs in dev export versus prod export?
5. Can spec history become the foundation for migration planning without
   implying automatic DB migrations too early?
6. How should static contracts sync their specs: at boot, via explicit command,
   via materializer agent, or via build-time report?
7. What invariants should parity check before any future write/git/restart
   materializer capability is allowed?

## Guardrails

- Keep this app-local for now.
- Do not promote `WizardTypeSpec`, `persist`, `history`, relation declarations,
  or materialization contracts into core from this proof alone.
- Dynamic authoring remains sandbox-only.
- Static contracts remain the production materialized shape.
- Spec export is data/config, not executable code.
- Prod export may compress history away; dev export may preserve lineage.
- Relation enforcement remains false.
- No cascade semantics, automatic migrations, DB planners, or runtime dynamic
  code execution yet.

## Requested Research Output

Please analyze whether this should become a first-class architecture concept and
return:

- a recommended mental model for `WizardTypeSpec`
- the relation to `Store[T]`, `History[T]`, and future migration planning
- the minimum canonical spec shape
- dev/prod export rules
- materializer capability boundaries
- reasons this should not be promoted yet
- the smallest next reversible app-local experiment

## Handoff

```text
[Architect Supervisor / Codex]
Track: wizard-type-spec-lineage-materialization
Status: Companion app-local proof now has persisted latest specs, append-only
spec lineage, read-only materialization plans, parity checks, and dev/prod
portable exports.
[D] Dynamic specs are durable data, not executable runtime code.
[D] Production behavior still materializes into static contracts.
[R] Preserve path to Store[ContractSpec] and History[ContractSpecChange].
[R] Do not infer automatic migrations or DB planning yet.
[S] Article/Comment proves wizard-shaped specs can round-trip into static
contract manifests with parity.
[Q] Is WizardTypeSpec the neutral lineage/migration registry for future
user-defined contract shapes?
Next: Research should define the canonical spec model and materializer
capability boundary.
Block: none.
```

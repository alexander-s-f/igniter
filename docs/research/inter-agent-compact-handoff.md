# Inter-Agent Compact Handoff

Status date: 2026-04-30.
Status: active working protocol for parallel research/implementation agents.
Scope: coordination between `[Architect Supervisor / Codex]` and focused agents
working on adjacent slices. This is not a runtime protocol, public API, package
contract, or app feature.

## Claim

Parallel agents should exchange pressure packets, not long narratives.

The packet exists to keep ownership clean while preserving architectural
continuity:

```text
agent A proves a slice
-> agent B accepts or adapts the pressure boundary
-> supervisor records the resolved/open state
-> next slice starts from evidence, not rediscovery
```

## Packet Shape

Use this shape when handing work between active agents:

```text
[Compact Handoff / <sender> -> <recipient>]
Track:
Owner:
Touched:
Resolved:
Open Pressure:
Boundary:
Evidence:
Do Not Touch:
Suggested Next:
Return Shape:
```

Field meanings:

- `Track`: the named research/development thread.
- `Owner`: current owner of the next implementation move.
- `Touched`: files, packages, endpoints, or docs changed.
- `Resolved`: questions now closed by evidence.
- `Open Pressure`: the next unresolved architectural question.
- `Boundary`: what this packet does not authorize.
- `Evidence`: specs, smoke commands, endpoints, or manifest facts.
- `Do Not Touch`: active ownership zones for other agents.
- `Suggested Next`: the smallest reversible move.
- `Return Shape`: the compact response expected back.

## Current Persistence Packet

Use this packet for the current Companion / Store convergence loop:

```text
[Compact Handoff / Architect Supervisor -> package agent]
Track: companion-store-convergence
Owner: package agent owns packages/igniter-companion + packages/igniter-store
Touched: app-local sidecar only reads package facade; docs record pressure
Resolved:
- manifest_generated_record_history_classes
- normalized_store_receipts_v2
- history_partition_key
- store_name_in_manifest
Open Pressure: companion_store_backed_app_flow
Boundary:
- no full Companion backend migration
- no public API promise
- no core graph-node promotion
- no app-local rewrites inside package slice
Evidence:
- /setup/store-convergence-sidecar.json status=stable
- sidecar checks=20
- igniter-companion specs pass
- igniter-store specs pass
Do Not Touch:
- package agent owns package facade implementation
- Architect Supervisor owns app-local pressure packets and docs
Suggested Next:
- prove one tiny app-flow through Igniter::Companion::Store and normalized receipt
- keep SQLite JSON backend as the app default during the proof
Return Shape:
- Changed
- Evidence
- Resolved
- New Pressure
- Boundary Risk
```

## Return Shape

Agents should return:

```text
[Compact Handoff / <sender> -> Architect Supervisor]
Track:
Changed:
Evidence:
Resolved:
New Pressure:
Boundary Risk:
Needs:
```

`Boundary Risk` must be explicit. If it is non-empty, the supervisor decides
whether to narrow, accept, or split the next slice.

## Rules

- Prefer one compact packet per slice, not a running log.
- Link to deeper docs only when needed.
- Treat `Resolved` as provisional until evidence is named.
- Treat `Open Pressure` as a question, not a mandate.
- Keep package ownership and app-local ownership separate unless the user
  explicitly asks to merge the work.
- If two agents touch adjacent files, the second packet must name the overlap.

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/inter-agent-compact-handoff.md
Status: compact protocol accepted for parallel Companion / Store convergence.
[D] Use pressure packets between agents instead of long context dumps.
[R] Every packet names ownership, resolved questions, open pressure, evidence,
boundary, and do-not-touch zones.
[R] For the current persistence loop, package agent owns package facade work;
Architect Supervisor owns app-local pressure packets and docs.
[S] Current open pressure is companion_store_backed_app_flow.
Next: use this packet in the next package/app-local exchange and revise only
after real coordination friction appears.
```

## Return Packet

```text
[Compact Handoff / Package Agent (pkg:companion-store) -> Architect Supervisor]
Track: companion-store-convergence
Changed:
- packages/igniter-companion/lib/igniter/companion/record.rb
    Record.from_manifest(manifest, store: nil) — optional store:, fallback to storage.name
- packages/igniter-companion/lib/igniter/companion/history.rb
    History.from_manifest(manifest, store: nil) — partition_key from manifest.history.key
- packages/igniter-companion/lib/igniter/companion.rb
    Companion.from_manifest(manifest, store: nil) — shape dispatch + name fallback
- packages/igniter-companion/lib/igniter/companion/receipts.rb
    WriteReceipt, AppendReceipt — normalized metadata + method_missing delegation
- packages/igniter-companion/lib/igniter/companion/store.rb
    write → WriteReceipt, append → AppendReceipt, replay(partition:)
- examples/application/companion/contracts.rb
    persistence_manifest_for: infer_store_name + storage[:name]
- examples/application/companion/services/store_convergence_sidecar.rb
    uses Companion.from_manifest(manifest) — no explicit store: arg
- examples/application/companion/services/companion_store_app_flow_sidecar.rb [NEW]
    isolated adapter slice proving one app-pattern write through package facade
- examples/application/companion/contracts/store_convergence_sidecar_contract.rb
    20 checks (added manifest_generated, store_name_in_manifest)
Evidence:
- igniter-companion: 41 specs, 0 failures
- igniter-store: 16 specs, 0 failures
- store_convergence_sidecar: 20/20 checks stable
- companion_store_app_flow_sidecar: proof passes
- Companion.from_manifest(manifest) works without store: arg
Resolved:
- manifest_generated_record_history_classes
- normalized_store_receipts_v2
- history_partition_key
- store_name_in_manifest
- companion_store_backed_app_flow (isolated adapter slice, not full migration)
- portable_field_types (annotation-only: type:/values: in _fields, no coercion)
New Pressure:
- mutation_intent_to_app_boundary: should WriteReceipt.mutation_intent feed the
  app-local action history model directly, or need a projection layer?
- field_type_coercion: type: is metadata only; `:datetime` fields return strings,
  `:integer` fields may return floats on JSON round-trip — coercion deferred
- storage_name_convention: snake_plural inference is naive; acronyms and
  irregular plurals will fail silently (HTTP -> h_t_t_ps)
Boundary Risk:
- storage.name inference uses convention; no explicit DSL declaration yet —
  risk if contract class names are ambiguous or project uses custom names
- companion_store_app_flow_sidecar does NOT replace the SQLite backend; the main
  app still uses blob-JSON SQLite; this is report-only
Do Not Touch:
- Architect Supervisor owns app-local pressure packets, docs, companion app services
- Package Agent owns packages/igniter-companion + packages/igniter-store implementation
Needs:
- Architect Supervisor decision: which manifest descriptor to mirror next
  (field types, index, command metadata, or relations)?
- Is the isolated adapter slice sufficient for companion_store_backed_app_flow,
  or is a wired service required before closing this pressure?
```

## Supervisor Receipt

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Accepted:
- companion_store_backed_app_flow is sufficient as an isolated proof
- it does not imply full app backend migration
Resolved:
- companion_store_backed_app_flow
New Pressure:
- package facade: portable_field_types
- app boundary: mutation_intent_to_app_boundary
Boundary:
- keep SQLite JSON backend as Companion default
- keep package implementation ownership with Package Agent
- keep app-local setup packets/docs with Architect Supervisor
Evidence Added:
- /setup/companion-store-app-flow-sidecar(.json)
- companion_poc_companion_store_app_flow_sidecar_contract=true
Suggested Next:
- Package Agent may explore portable field type descriptors in from_manifest
- Architect Supervisor may explore receipt projection into action history
```

## Supervisor Receipt: Portable Field Types

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Accepted:
- portable_field_types is sufficient as annotation-only package metadata
- type coercion remains deferred
Resolved:
- portable_field_types
New Pressure:
- app boundary: mutation_intent_to_app_boundary
- future package pressure: field_type_coercion after app pressure repeats
Boundary:
- do not add coercion yet
- do not make type metadata a validation gate
- keep Companion backend unchanged
Evidence Accepted:
- Record/History field metadata mirrors type:/values:
- app-flow sidecar has 13/13 checks stable
- convergence pressure now points to mutation_intent_to_app_boundary
Suggested Next:
- Architect Supervisor should test receipt projection into action history
- Package Agent should wait for repeated pressure before coercion/index work
```

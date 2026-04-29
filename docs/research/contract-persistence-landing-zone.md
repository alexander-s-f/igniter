# Contract Persistence Landing Zone

Status date: 2026-04-29.
Scope: research placement decision. Not a package commitment or public API.

## Claim

Contract persistence now deserves a named landing path, but not an immediate
package split.

The Companion proof is no longer just CRUD convenience. It shows a recursive
system shape: contracts declare durable capabilities, inspect their own
infrastructure, produce materializer review packets, lower approvals into
history append intents, and expose audit read models for the process that may
later materialize more contracts.

That fractal signal is strong evidence for the direction. It is still extraction
pressure, not an API-promotion trigger.

## Decision

Keep the next iteration app-local in Companion.

When extraction starts, split by responsibility:

- `igniter-extensions`: optional contract vocabulary and report-only
  descriptors over `igniter-contracts`
- `igniter-application`: host/runtime binding, adapters, setup/readiness
  surfaces, explicit mutation boundaries, materializer review flows
- future `igniter-persistence`: stable durable capability package after repeated
  app pressure and a smaller adapter/manifest contract

Do not create `igniter-data` yet. The name is too broad: it can mean dataflow,
analytics, datasets, ETL, tables, events, or persistence. The sharper future
name is `igniter-persistence`, because the capability is durable `Store[T]`,
append-only `History[T]`, typed relations, commands, materialization, and audit.

Do not put this in `igniter-contracts` now. The kernel should stay
host-agnostic; persistence remains optional vocabulary and app-boundary
behavior until the lowerings are clear.

## Landing Map

`igniter-extensions` owns:

- `persist` / `history` as optional Ruby product sugar
- future `Store[T]` / `History[T]` / `Relation[...]` descriptors
- field/index/scope/command metadata descriptors
- relation manifest shape
- operation-intent metadata shape
- report-only validation and diagnostics

`igniter-application` owns:

- capability registry/factory
- app-local record/history bindings
- adapter wiring and backend choice
- explicit write boundary
- setup/readiness/materializer surfaces
- approval/attempt receipt persistence
- application lifecycle around generated or materialized files

Future `igniter-persistence` owns only after stabilization:

- adapter contract
- migration/change-plan contract
- durable capability runtime APIs
- relation enforcement policy
- index/partition/placement metadata
- cross-app persistence test kit

## Maturity Ladder

1. Companion app-local proof: current state.
2. Companion internal stabilization: freeze manifest vocabulary, operation
   algebra, relation semantics, approval lifecycle, and status packets.
3. Split-shaped extraction without package promise: isolate extension-shaped and
   application-shaped modules inside the app or example boundary.
4. Optional shared packs: move descriptors to `igniter-extensions` and host
   bindings to `igniter-application` only when another app/example repeats the
   pressure.
5. `igniter-persistence`: create only when adapter semantics, migrations,
   relation policy, and Store/History lowerings have stable tests.
6. `Igniter::Lang`: lower `persist` to `Store[T]`, `history` to `History[T]`,
   and relation manifests to typed relation descriptors.

## Next Slice

Best next move:

- keep Companion as the proving ground
- stabilize a canonical manifest schema with `schema_version` and
  `storage.shape`
- keep `persist`/`history` aliases for current app-local compatibility
- make operation algebra and relation metadata boring and explicit
- keep materializer execution blocked behind human approval and audited
  app-boundary writes
- avoid SQL planners, migrations, FK generation, cascade semantics, and relation
  enforcement until the descriptors stop moving

Acceptance:

- a new agent can read the manifest and know what is durable, append-only,
  projected, related, command-driven, blocked, or approved
- no setup/read endpoint mutates durable state
- all mutation still flows through explicit command intent plus app boundary
- all terms still lower cleanly to future `Store[T]` / `History[T]`

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/contract-persistence-landing-zone.md
Status: persistence has a reserved landing path, not a new package yet.
[D] Keep proof app-local in Companion for the next stabilization slice.
[D] First extraction, when justified, is split: contract vocabulary to
igniter-extensions; host/runtime/adapters/materializer boundary to
igniter-application.
[D] Reserve igniter-persistence as the future package name; avoid igniter-data.
[R] Do not promote persistence DSL into igniter-contracts from this proof alone.
[R] Treat fractality as a positive architecture signal, not a promotion trigger.
[S] Preserve persist -> Store[T], history -> History[T], and typed relation
lowerings.
Next: stabilize manifest vocabulary, operation algebra, relation semantics, and
approval/materializer lifecycle while staying app-local.
```

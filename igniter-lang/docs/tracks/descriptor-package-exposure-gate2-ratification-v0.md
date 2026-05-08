# Track: Descriptor Package Exposure Gate 2 Ratification v0

Card: S3-R5-C5-G
Role: `[Igniter-Lang Bridge Agent]`
Track: `descriptor-package-exposure-gate2-ratification-v0`
Status: ratify
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Gate State

```text
Gate 1  proof-local CompatibilityReport descriptor consumption     approved + PASS
Gate 2  metadata-only package exposure                             ratify
Gate 3  production Ledger/runtime binding                          closed
```

This track verifies the current package descriptor surface and recommends Gate 2
ratification only. It does not add package code and does not open Gate 3.

---

## Scope Reviewed

Gate 2 package exposure means:

```text
metadata_snapshot + descriptor_snapshot
  -> TBackendAdapterDescriptor value object
  -> descriptor_hash / descriptor_registry_hash
  -> diagnostics(requirement)
```

It excludes:

```text
read_as_of
bihistory_at
Ledger reads/writes/append/replay/compact/subscribe
RuntimeMachine production binding
production CompatibilityReport enforcement
migration execution
```

---

## Package Surface Evidence

Read-only package files reviewed:

```text
packages/igniter-ledger/lib/igniter/store/tbackend_adapter_descriptor.rb
packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md
```

Observed class/module surface:

```ruby
Igniter::Store::TBackendAdapterDescriptor
Igniter::Ledger::TBackendAdapterDescriptor
```

The package track documents that `Igniter::Ledger` is currently a pre-v1 alias
for `Igniter::Store`, so internal `Igniter::Store` placement is acceptable for
Gate 2.

Observed constructor:

```ruby
.build(
  metadata_snapshot:,
  descriptor_snapshot:,
  schema_fingerprint:,
  adapter_ref: nil,
  ledger_protocol_ops: nil
)
```

Observed metadata methods:

```ruby
#descriptor_hash
#descriptor_registry_hash
#ledger_protocol_ops
#supported_tbackend_ops
#hook_methods
#capabilities
#history_axes
#cursor_policy
#diagnostics(requirement = {})
#to_h
```

---

## Evidence Table

| Requirement | Evidence | Status |
|---|---|---|
| Package descriptor class exists | `Igniter::Store::TBackendAdapterDescriptor` file present | PASS |
| Ledger alias visibility | Spec asserts `Igniter::Ledger::TBackendAdapterDescriptor` is same class | PASS |
| Constructor is metadata-only | `.build(metadata_snapshot:, descriptor_snapshot:, schema_fingerprint:, ...)` | PASS |
| Descriptor packet shape | package spec checks `kind`, `adapter_kind`, `contract_version`, protocol, evidence mode | PASS |
| Descriptor hash stability | package spec checks stable hashes under key reorder | PASS |
| Registry hash sensitivity | package spec checks registry hash changes when descriptor snapshot changes | PASS |
| Capabilities / axes | package spec checks `history_read`, `bihistory_read`, `valid_time`, `transaction_time` | PASS |
| Diagnostics shape | package spec checks ok, missing ops, missing history, schema mismatch | PASS |
| Non-authorization flags | package spec checks runtime/Ledger operation flags are false | PASS |
| No operational methods | package spec checks no `read_as_of`, `bihistory_at`, `read`, `write`, `append`, `replay`, `compact`, `subscribe` | PASS |
| Targeted package spec | `9 examples, 0 failures` | PASS |
| Gate 3 production binding | not present / not requested | CLOSED |

---

## Verification

Command run:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec \
  packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
```

Observed result:

```text
9 examples, 0 failures
```

No package files were edited by this Bridge Agent track.

---

## Gate 2 Recommendation

Recommendation: **ratify Gate 2**.

Ratification wording:

```text
Gate 2 is ratified for metadata-only package exposure of
Igniter::Store::TBackendAdapterDescriptor, visible through
Igniter::Ledger::TBackendAdapterDescriptor.

The ratified surface is limited to descriptor construction from
metadata_snapshot / descriptor_snapshot, canonical descriptor and registry
hashes, derived capabilities/axes/hook metadata, and diagnostics.

This ratification does not authorize live adapter behavior, Ledger operations,
RuntimeMachine production binding, production CompatibilityReport enforcement,
or migration behavior.
```

Rationale:

- Gate 1 fixture PASS proves report-only descriptor consumption.
- Package descriptor surface exists and matches the Gate 2 boundary.
- Targeted package spec passes.
- The descriptor is explicitly non-operational.

---

## If Held Or Redirected

Hold Gate 2 only if Architect Supervisor wants package exposure to remain
provisional despite passing evidence.

Redirect Gate 2 only if Architect Supervisor wants one of:

- a deep-renamed `Igniter::Ledger` file namespace before ratification
- different descriptor field names
- a different hash canonicalization policy
- additional package-local diagnostics before exposure

No redirect is recommended by this Bridge Agent slice.

---

## Gate 3 Non-Authorization

Still closed:

- live Ledger-backed TBackend adapter
- `read_as_of`
- `bihistory_at`
- Ledger `read`, `write`, `append`, `replay`, `compact`, or `subscribe`
- RuntimeMachine production binding
- production CompatibilityReport enforcement
- migration execution
- Ledger history rewrite
- replacement SemanticImage
- Ledger-as-core semantics

Gate 3 requires a separate approval request that names production operations
explicitly and carries new proof evidence.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S3-R5-C5-G
Track: descriptor-package-exposure-gate2-ratification-v0
Status: ratify

[D] Decisions:
- Recommend ratifying Gate 2 for metadata-only package exposure.
- Ratified surface is the descriptor value object and diagnostics only.
- Gate 3 remains closed.

[S] Signals:
- Gate 1 fixture PASS supports report-only descriptor consumption.
- Package descriptor class exists under Igniter::Store and is visible through
  Igniter::Ledger alias.
- Package spec confirms hash stability, diagnostics, non-authorization flags,
  alias visibility, and absence of operational methods.

[T] Tests / Proofs:
- BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec
  packages/igniter-ledger/spec/igniter/store/tbackend_adapter_descriptor_spec.rb
  -> 9 examples, 0 failures

[R] Risks / Recommendations:
- Do not infer RuntimeMachine or Ledger operation rights from Gate 2.
- Future deep rename may move the file namespace, but current alias is acceptable.
- Next bridge should ask separately whether metadata-only CompatibilityReport
  package consumption may use the ratified descriptor.

[Next] Architect Supervisor may record Gate 2 as ratified; Gate 3 remains closed.
```

# Track: Parity Track Stale Header Sweep v0

Card: S3-R6-C7-S
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `igniter-lang/parity-track-stale-header-sweep-v0`
Status: done
Date: 2026-05-08

---

## Goal

Mark superseded parity/cache tracks so agents do not treat old blocker states as
current truth.

---

## Scope

[S] Headers only in the target tracks.

[S] No content rewrite, no archive moves, no parser/spec/runtime changes.

Affected neighbor roles:

- Compiler/Grammar Expert
- Bridge Agent

---

## Header Sweep

| Document | Marker | Current truth pointer |
|----------|--------|-----------------------|
| `typed-emission-main-path-parity-v0.md` | Stale / superseded as current status | S3-R5-C4 `orchestrator-emit-typed-switch-v0`; S3-R4-C4 `typed-emission-stage2-switch-decision-v0` |
| `typed-emission-canonical-shape-v0.md` | Stale / superseded as current blocker state | S3-R5-C4 `orchestrator-emit-typed-switch-v0`; Stage 1/2 close candidates passed after switch |
| `typed-emission-stage2-source-lowering-parity-v0.md` | Stale / superseded as current switch guidance | S3-R4-C4 Option B decision; S3-R5-C4 `emit_typed` production switch |
| `temporal-cache-key-proof-v0.md` | Stale / absorbed as current cache guidance | S3-R4-C5 `runtime-cache-proof-local-memoization-v0`; production RuntimeMachine caching remains disabled |

---

## Handoff

[D] The four requested tracks now carry stale/superseded or stale/absorbed
headers at the file top.

[S] The original bodies are intentionally unchanged. They remain historical
evidence, not current Stage 3 truth.

[T] Verification should remain textual: check headers and current-truth
pointers only.

[R] No rotation/archive move was performed. These documents can be considered
for a later archive round once governance asks for movement rather than markers.

[Next] A future Status Curator or Archive/Form slice can update track indexes or
perform archive moves if the Architect decides the stale-marker holding period
has elapsed.

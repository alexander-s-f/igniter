# Track: Phase 1 Backend Identity Guard v0

Card: S3-R18-C4-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `phase1-backend-identity-guard-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Define and prove a backend identity guard so Phase 1 cannot quietly call a real
Ledger-backed adapter before a Phase 2 Architect addendum.

Sources read:

- `igniter-lang/docs/gates/gate3-decision-record-v0.md`
- `igniter-lang/docs/discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/temporal_executor.rb`

---

## Decision

[D] This is a code-level guard, not docs-only.

Reason: S3-R17-X1 identified that the `backend:` parameter accepted any object
with `read_as_of`. Documentation alone would leave a quiet path where a future
Ledger-backed adapter could be passed into `IgniterLang::TemporalExecutor::Phase1`
with `gate3_authorized: true`.

Implemented in:

```text
igniter-lang/lib/igniter_lang/temporal_executor.rb
```

---

## Backend Identity Rule

Phase 1 allows only:

1. `IgniterLang::TemporalAccessRuntime::MemoryBackend`
2. an explicitly identified non-Ledger backend whose
   `phase1_backend_identity` returns a Hash with:

```json
{
  "phase1_allowed": true,
  "ledger_backed": false,
  "invokes_ledger_package": false,
  "package_adapter": false,
  "backend_family": "proof_local|non_ledger",
  "kind": "proof_local_non_ledger_backend"
}
```

Phase 1 blocks:

- unmarked objects that only respond to `read_as_of`;
- Igniter-Ledger package adapters;
- Ledger-backed adapters;
- wrappers/proxies that invoke Ledger package code;
- malformed backend identity declarations;
- backend identities whose family/kind/class name is Ledger-like.

Blocked backend identity emits:

```text
runtime.phase1_backend_identity_blocked
```

The guard runs after `approval_token` and `gate_state`, and before scope,
cache-key, execution kernel, or backend `read_as_of`. This preserves the
canonical token-before-gate diagnostics while preventing `gate3_authorized: true`
from quietly enabling a Ledger path.

---

## Proof Fixture

Added proof-local fixture:

```text
igniter-lang/experiments/phase1_backend_identity_guard/
  phase1_backend_identity_guard.rb
  out/phase1_backend_identity_guard_summary.json
```

The proof uses fake local backends only. It does not bind Ledger, call packages,
or perform live reads.

---

## Acceptance Matrix

| Case | Expected result | Backend call |
|---|---|---:|
| `proof_local_memory_backend_allowed` | `ok` | proof-local MemoryBackend read |
| `explicit_non_ledger_backend_allowed` | `ok` | proof-local fake non-Ledger read |
| `unmarked_read_as_of_backend_blocked` | blocked at `backend_identity` | 0 |
| `ledger_backed_adapter_blocked` | blocked at `backend_identity` | 0 |
| `ledger_proxy_wrapper_blocked` | blocked at `backend_identity` | 0 |
| `malformed_identity_backend_blocked` | blocked at `backend_identity` | 0 |
| `missing_token_blocks_before_backend_identity` | blocked at `approval_token` | 0 |

All blocked cases preserve:

```json
{
  "temporal_executor_call_attempted": false,
  "live_tbackend_call_attempted": false,
  "ledger_call_attempted": false,
  "temporal_read_attempted": false,
  "cache_call_attempted": false
}
```

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb
```

Observed result:

```text
PASS phase1_backend_identity_guard
  memory_backend.allowed: ok
  explicit_non_ledger.allowed: ok
  unmarked_backend.blocked: ok
  ledger_backed_adapter.blocked: ok
  ledger_proxy_wrapper.blocked: ok
  malformed_identity.blocked: ok
  blocked_backends.no_read_attempts: ok
  missing_token.blocks_before_backend_identity: ok
  blocked_cases.no_live_operations: ok
summary: igniter-lang/experiments/phase1_backend_identity_guard/out/phase1_backend_identity_guard_summary.json
```

Regression command:

```bash
ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
```

Observed result: `PASS temporal_executor_lib_prep`.

---

## Addendum Blocker Status

[R] Backend identity guard is now present for Phase 1 proof-local use.

This does not open Phase 2. A real Ledger-backed adapter remains blocked until
an explicit Phase 2 Architect addendum names:

- adapter identity and package/class boundary;
- descriptor hash or registry hash;
- allowed operation scope;
- approval token scope;
- observation emission shape;
- persistence gap handling;
- refusal cases for writes/replay/compact/subscribe/stream/BiHistory.

Recommendation: treat this guard as a required precondition for any future
Phase 2 addendum review, not as evidence that Phase 2 is authorized.

---

## Non-Authorization

This track does not authorize:

- Ledger binding;
- Igniter-Ledger package reads;
- live TBackend calls;
- live reads;
- writes/replay/compact/subscribe;
- BiHistory serving;
- production cache;
- production signing or authority registry behavior.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/phase1-backend-identity-guard-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Backend identity guard is code-level, not docs-only.
- Phase 1 allows MemoryBackend or explicit non-Ledger identity only.
- Ledger-backed adapters and Ledger-invoking wrappers block before scope/cache/kernel/backend read.

[R] Recommendations:
- Keep Phase 2 Ledger adapter binding blocked until explicit Architect addendum.
- Treat this guard as a prerequisite for addendum review, not as addendum approval.

[S] Signals:
- Proof fixture blocks unmarked, Ledger-backed, Ledger proxy, and malformed identity backends with zero read attempts.
- Existing temporal_executor_lib_prep regression remains PASS.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb
- ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
- ruby -c igniter-lang/lib/igniter_lang/temporal_executor.rb
- ruby -c igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb

[Files] Changed:
- igniter-lang/docs/tracks/phase1-backend-identity-guard-v0.md
- igniter-lang/lib/igniter_lang/temporal_executor.rb
- igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb
- igniter-lang/experiments/phase1_backend_identity_guard/out/phase1_backend_identity_guard_summary.json
- igniter-lang/experiments/temporal_executor_lib_prep/out/temporal_executor_lib_prep_summary.json

[Q] Open Questions:
- What exact Phase 2 adapter identity and descriptor hash will the future Architect addendum name?

[X] Rejected:
- No Ledger binding, live reads, package adapter calls, cache calls, or BiHistory serving.

[Next] Proposed next slice:
- If requested, add a small spec-facing note in the runtime chapter that `backend_identity` is a required Phase 1 preflight stage before scope/cache/kernel.
```

# Track: Gate 3 Authority Registry Shape v0

Card: S3-R21-C2-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `gate3-authority-registry-shape-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Define a proof-local authority registry shape for Gate 3 without turning it into
production signing, key management, or Phase 2 Ledger adapter authorization.

Sources read:

- `igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md`
- `igniter-lang/docs/tracks/stage3-round20-status-curation-v0.md`
- `igniter-lang/docs/tracks/gate3-first-post-signature-fixture-v0.md`
- `igniter-lang/docs/discussions/gate3-post-signature-runtime-pressure-v0.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`

---

## Registry Shape

[D] The proof-local registry entry shape is:

```json
{
  "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09",
  "status": "active|revoked|superseded",
  "issued_on": "2026-05-09",
  "revoked_on": null,
  "superseded_by": null,
  "allowed_scope": {
    "gate": "gate3",
    "phase": "phase1",
    "executor": "IgniterLang::TemporalExecutor::Phase1",
    "operation": "history_valid_time_read",
    "history_axis": "valid_time",
    "backend_family": "memory_or_explicit_non_ledger"
  },
  "required_capability": "history_read",
  "decision_doc_ref": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
}
```

The registry is proof-local policy metadata. It is not:

- a signature;
- a signing-key registry;
- a revocation service;
- a production authority service;
- a Ledger adapter descriptor;
- runtime self-authorization inside `Phase1`.

---

## Composition Point

[D] The registry check composes before the caller passes
`gate3_authorized: true`.

Flow:

```text
caller invocation evidence
-> authority registry check
-> caller may/may not pass gate3_authorized: true
-> existing Phase1 source-code-parity authority_ref check remains unchanged
```

The executor remains non-self-authorizing. A blocked registry check means the
caller must keep `gate3_authorized: false` and must not call the executor as an
authorized live-read path.

The current authority URI behavior remains source-code-parity:

```text
token.authority_ref == IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
```

No cryptographic signing is introduced by this track.

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/gate3_authority_registry_shape/
  gate3_authority_registry_shape.rb
  out/gate3_authority_registry_shape_summary.json
```

The fixture proves registry policy decisions without calling the executor:

| Case | Expected result |
|---|---|
| `active_registry_allows_gate3_authorized` | caller may pass `gate3_authorized: true` |
| `revoked_registry_blocks_before_caller_sets_true` | caller may not pass true |
| `superseded_registry_blocks_before_caller_sets_true` | caller may not pass true |
| `missing_registry_entry_blocks` | caller may not pass true |
| `missing_signed_addendum_evidence_blocks` | caller may not pass true |
| `wrong_scope_blocks` | caller may not pass true |
| `wrong_required_capability_blocks` | caller may not pass true |
| `malformed_registry_entry_blocks` | caller may not pass true |

All cases preserve:

```json
{
  "executor_called": false,
  "production_signing": false
}
```

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb
```

Observed output:

```text
PASS gate3_authority_registry_shape
  active_registry.allows_gate3_authorized: ok
  active_registry.source_code_parity_uri_unchanged: ok
  revoked.blocks: ok
  superseded.blocks: ok
  missing_entry.blocks: ok
  missing_signed_addendum_evidence.blocks: ok
  wrong_scope.blocks: ok
  wrong_required_capability.blocks: ok
  malformed_entry.blocks: ok
  no_case_uses_signing_or_keys: ok
  no_case_calls_executor: ok
summary: igniter-lang/experiments/gate3_authority_registry_shape/out/gate3_authority_registry_shape_summary.json
```

---

## Production Split Recommendation

[R] Keep production registry and production signing as separate future tracks.

Recommended split:

1. `gate3-authority-registry-v1`
   - durable registry storage;
   - revocation and supersession lookup;
   - status transition receipts;
   - registry audit observations;
   - still no private signing keys.
2. `gate3-production-signing-v1`
   - signer identity;
   - key rotation;
   - signature algorithm;
   - verification policy;
   - deployment trust store.

Reason: revocation/rotation policy and cryptographic token issuance are related
but not the same boundary. Mixing them would make proof-local source-code-parity
look more production-ready than it is.

---

## Non-Authorization

This track does not authorize:

- cryptographic signing;
- production key management;
- production authority service;
- executor code changes;
- Phase 2 Ledger adapter;
- Ledger package binding;
- BiHistory, stream, OLAP, writes, replay, compact, subscribe;
- production cache;
- durable audit.

It only defines and proves the proof-local authority registry shape.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/gate3-authority-registry-shape-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Registry shape is proof-local metadata with authority_ref, status, dates, scope, capability, and decision_doc_ref.
- Registry check composes before caller passes gate3_authorized: true.
- Current source-code-parity authority URI behavior remains unchanged.

[R] Recommendations:
- Split future production registry/revocation work from production signing/key-management work.
- Keep Phase 2 Ledger adapter behind its own Architect addendum.

[S] Signals:
- Fixture proves active/revoked/superseded/missing/scope/capability/malformed cases.
- No case calls the executor or uses signing/keys.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb
- ruby -c igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb

[Files] Changed:
- igniter-lang/docs/tracks/gate3-authority-registry-shape-v0.md
- igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb
- igniter-lang/experiments/gate3_authority_registry_shape/out/gate3_authority_registry_shape_summary.json

[Q] Open Questions:
- Which durable store, if any, should own a future production registry?
- Which separate authority will own production signing/key management?

[X] Rejected:
- No cryptographic signing, production keys, executor changes, Phase 2 Ledger adapter, or Ledger package binding.

[Next] Proposed next slice:
- `gate3-authority-registry-v1` for durable registry/revocation semantics, or `compatibility-report-persistence-audit-v0` for durable observation/audit.
```

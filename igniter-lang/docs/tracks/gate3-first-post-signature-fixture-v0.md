# Track: Gate 3 First Post-Signature Fixture v0

Card: S3-R20-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `gate3-first-post-signature-fixture-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

After C1 signed the Gate 3 live-read addendum, prove that signing changes only
caller policy/status, not executor behavior.

Signed source:

```text
igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md
Status: signed-approved-restricted-phase1-live-read
```

---

## Decision

[D] The signed addendum authorizes callers to pass `gate3_authorized: true`
only inside the restricted Phase 1 scope and only with invocation evidence
referencing the signed addendum.

[D] The executor still does not self-authorize. The fixture models the caller
policy step separately from `IgniterLang::TemporalExecutor::Phase1`.

[D] No executor code changed in this card.

---

## Fixture

Added:

```text
igniter-lang/experiments/gate3_first_post_signature_fixture/
  gate3_first_post_signature_fixture.rb
  out/gate3_first_post_signature_fixture_summary.json
```

The fixture proves:

- before signed reference: caller policy must not pass `gate3_authorized: true`;
- before signed reference: executor blocks at `gate_state`;
- after signed reference: caller policy may pass `gate3_authorized: true`;
- executor guard order remains:

```text
approval_token -> gate_state -> backend_identity -> scope -> cache_key
```

- MemoryBackend path executes when all checks pass;
- explicit non-Ledger Phase 1 backend path executes when all checks pass;
- Ledger-like backend blocks at `backend_identity` before read;
- BiHistory, stream, OLAP, write, and CORE-shaped cache-key paths remain closed.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb
```

Observed output:

```text
PASS gate3_first_post_signature_fixture
  addendum.signed_status_detected: ok
  before_signed_reference.caller_must_not_pass_true: ok
  before_signed_reference.executor_blocks_at_gate_state: ok
  after_signed_reference.caller_may_pass_true: ok
  executor.guard_order_unchanged: ok
  memory_backend.executes_when_all_checks_pass: ok
  non_ledger_backend.executes_when_all_checks_pass: ok
  dangerous_backend.blocked_before_read: ok
  excluded_surfaces.no_live_paths: ok
  cache_key.core_shape_blocked: ok
summary: igniter-lang/experiments/gate3_first_post_signature_fixture/out/gate3_first_post_signature_fixture_summary.json
```

Syntax:

```text
ruby -c igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb
Syntax OK
```

Related regression:

```text
ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb
PASS phase1_backend_identity_guard
```

---

## Non-Authorization

[X] This card does not add a Ledger adapter.

[X] This card does not add production cache.

[X] This card does not add durable audit/persistence.

[X] This card does not open BiHistory, stream, OLAP, writes, replay, compact,
subscribe, production signing/registry, or Phase 2.

---

## Handoff

```text
Card: S3-R20-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gate3-first-post-signature-fixture-v0
Status: done

[D] Decisions
- C1 signed status is detected from gate3-live-read-decision-addendum-v0.md.
- Signing changes caller policy/status only; executor behavior is unchanged.
- `gate3_authorized: true` is modeled as caller-provided policy evidence, not
  executor self-authorization.

[S] Shipped / Signals
- Added post-signature fixture and summary JSON.
- Proved before/after signed-reference caller behavior.
- Proved MemoryBackend and explicit non-Ledger Phase 1 paths execute when all
  checks pass.
- Proved Ledger-like backend and excluded surfaces remain blocked.

[T] Tests / Proofs
- ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb -> PASS
- ruby -c igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb -> Syntax OK
- ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb -> PASS

[R] Risks / Recommendations
- Keep current-status/agent-context sync as a Meta Expert follow-up; they may
  lag signed C1 until status curation lands.
- Next runtime safety work should be persistence/audit or authority registry,
  not Phase 2 expansion.

[Next] Suggested next slice
- compatibility-report-persistence-audit-v0 or gate3-authority-registry-v0.
```

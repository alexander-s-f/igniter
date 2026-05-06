# Track: Runtime Machine FFI Ruby Receipt Fixtures v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures/manifest.json`
- `igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures/ffi_ruby_receipts.golden.json`

---

## Frame

This slice turns the Ruby FFI contractable proof into executable fixture
coverage.

```text
FFIRequirement descriptors
  -> read success packet
  -> write/audit success receipt
  -> capability denied failure
  -> host error failure
  -> manifest + checker
```

It remains standalone research/devkit code. It does not call package code and
does not define a production FFI API.

---

## Fixture Scenarios

The fixture set covers:

- `read_success`: read-only Ruby FFI emits `fact_observation`
- `write_audit_success`: write Ruby FFI emits `receipt_observation` with
  lifecycle `audit`
- `capability_denied`: missing capability emits `failure_observation` and marks
  `host_call_attempted: false`
- `host_error`: declared host conflict emits `failure_observation`

Each scenario validates required links:

```text
read_from
executed_by
produced_in
caused_by        -- required for write/failure scenarios caused by decision
```

---

## Commands

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb
```

Expected output:

```text
PASS runtime_machine_ffi_ruby_receipt_fixtures
manifest: ok
artifact_header: ok
descriptor_packets: ok
scenario_packets: ok
read_success: ok
write_audit_success: ok
capability_denied: ok
host_error: ok
cross_case: ok
```

---

## What This Proves

[S] FFI receipts and failures now have golden packet coverage, not only prose.

[S] Write FFI with `audit: true` is represented as action evidence, not a log
line.

[S] Capability denial is observable and happens before a host call is attempted.

[S] Host errors are contract failures with declared shape, not swallowed Ruby
exceptions.

---

## What It Does Not Prove

[X] It does not integrate real Spark CRM code.

[X] It does not execute real host mutations.

[X] It does not prove capability registry ownership.

[X] It does not define normalized equivalence for package-derived FFI packets.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md
Status: done

[D] Decisions:
- FFI fixture coverage lives beside the memory proof experiment.
- Read, write/audit, capability-denied, and host-error cases are covered.
- Fixture manifest hashes the trusted golden packet file.
- Capability-denied proves host_call_attempted: false.

[R] Recommendations:
- Add normalized-equivalence rules before real package-derived FFI packets may
  differ from these fixtures.
- Define a shared capability registry before package integration.
- Keep real Spark CRM integration blocked until bridge/package candidates pass
  fixture gates.

[S] Signals:
- Ruby FFI is now a tangible ESCAPE boundary with evidence, not just an idea.
- The receipt/failure packet shape is strong enough to inform package bridge
  work later.

[Q] Open Questions:
- Should `intent_observation` be added to this fixture set, or remain in the
  call-discipline proof skeleton only?
- Should capability registry names live in language docs, platform docs, or a
  bridge note?

[Next] Proposed next slice:
- `runtime-machine-normalized-equivalence-profile-v0`
  Define when package/bridge candidate packets may differ from golden fixtures
  while preserving result meaning, evidence links, lifecycle, and compatibility
  decisions.
```

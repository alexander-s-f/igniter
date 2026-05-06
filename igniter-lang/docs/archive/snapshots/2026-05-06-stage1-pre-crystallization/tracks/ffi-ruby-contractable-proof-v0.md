# Track: FFI Ruby Contractable Proof v0

Status: approved_experiment
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Depends on: `PROP-012 §Contractable FFI`, `PROP-003`, `PROP-005.1`, `PROP-010`

---

## Frame

PROP-012 defines the FFI call discipline:

```text
intent_observation
  -> capability check
  -> host call
  -> receipt_observation | failure_observation
  -> links to runtime/session/artifact
```

This track proves that discipline in Ruby against the existing memory harness.
No gem, no package edit. Standalone experiment extending compiled_program.rb.

---

## Compact Claim

[D] A Ruby host call becomes a contractable FFI boundary when it:
1. Declares `FFIRequirement` (typed ports, effects, capabilities, lifecycle)
2. Emits `intent_observation` before calling the host
3. Passes a capability gate (grants checked; missing → `failure_observation`)
4. Calls the host Ruby callable
5. Emits `receipt_observation` on success (lifecycle from FFIRequirement)
6. Emits `failure_observation` on host error (lifecycle: :session)
7. Links all observations back to the runtime evidence chain

The result is classified **ESCAPE** — it reads or mutates external state —
but it is observable, capability-gated, and receipt-producing.

---

## FFIRequirement Declaration

```text
FFIRequirement = Record {
  ffi_id       : String
  host_ref     : String             -- Ruby class/method (e.g. "SparkCRM::OrderLookup")
  host_lang    : :ruby
  input_ports  : Collection[Port]
  output_ports : Collection[Port]
  effects      : Collection[:read | :write | :observe | :notify]
  capabilities : Collection[CapabilityName]
  lifecycle    : LifecycleClass     -- of the receipt_observation
  failures     : Collection[FailureKind]
  audit        : Bool               -- true -> receipt lifecycle: :audit
}
```

---

## Call Discipline (observed sequence)

```text
[1] Obs[:intent_observation, FFICallPlan]
      subject:   "ffi://<ffi_id>/intent"
      lifecycle: :local  (intent does not persist)
      payload:   { ffi_id, host_ref, inputs }

[2] CapabilityGate.check(required: ffi.capabilities, granted: runtime.granted_caps)
    -> granted: proceed to [3]
    -> missing: emit [F] and halt

[F] Obs[:failure_observation, CapabilityDenied]
      subject:   "ffi://<ffi_id>/failure"
      lifecycle: :session
      reason_code: "capability.denied"
      payload:   { missing_caps, ffi_id }

[3] host call: Ruby callable.call(inputs)
    -> success: proceed to [4]
    -> exception: emit [E] and halt

[E] Obs[:failure_observation, HostError]
      subject:   "ffi://<ffi_id>/failure"
      lifecycle: :session
      reason_code: "ffi.host_error"
      payload:   { ffi_id, error_class, error_message }

[4] Obs[:receipt_observation, FFIReceipt]
      subject:   "ffi://<ffi_id>/receipt"
      lifecycle: ffi.audit ? :audit : ffi.lifecycle
      payload:   { ffi_id, host_ref, output, call_id }
      links:     evidence_links
               + [{ rel: :caused_by,  ref: intent_obs.id }]
               + [{ rel: :produced_by, ref: "ffi://<ffi_id>" }]
```

---

## Fragment Classification

| FFI type | Class | Rule |
|----------|-------|------|
| Pure declared adapter (no external state) | CORE candidate | Only if deterministic + no real IO |
| Read external state | ESCAPE | External state may change across as_of |
| Write external world | ESCAPE + capability + receipt | `:write` in effects |
| Undeclared host call | OOF | No FFIRequirement entry |
| FFI with `audit: true` | ESCAPE | Receipt lifecycle: :audit |

---

## Lifecycle Rules for FFI Observations

| Observation | Lifecycle | Rule |
|-------------|-----------|------|
| `intent_observation` | `:local` | Intent is ephemeral |
| `receipt_observation` (non-audit) | `ffi.lifecycle` | As declared |
| `receipt_observation` (audit: true) | `:audit` | Long-term action rights |
| `failure_observation` | `:session` | Persists for diagnosis |

---

## Signals

[S] The existing `ToyDispatchContract.evaluate` in the memory proof already
acts as an implicit FFI: it reads from the backend and calls Ruby logic.
This track makes that boundary explicit and observable.

[S] The SparkCRM `AssignTechnician` mutation (PROP-012 §Contractable FFI)
requires `audit: true`. This track proves the receipt-as-audit-record pattern.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: ffi-ruby-contractable-proof-v0
Status: done

[Next] See spec/igniter/ffi_ruby_contractable_spec.rb for executable proof.
```

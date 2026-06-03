# Experimental igc run Slice 1 — Quickstart Docs v0

Card: S3-R244-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice1-quickstart-docs-v0
Route: UPDATE
Status: done
Date: 2026-06-03

Depends on:
- S3-R244-C1-A

---

## Authority Notice

**This is pre-v1 experimental delegated-runtime Slice 1 evidence only.**

This document describes the accepted experimental `igc run` Slice 1 VM
candidate Path C fail-closed behavior. It is documentation exposure for
internal evidence, not positive Add.igapp integer execution.

The Slice 1 selector proves proof-local passport/binding validation and
machine-readable fail-closed diagnostics for the current integer capability
gap. It is subject to change before v1.

Non-claims:

- not a stable API;
- not public runtime support;
- not Reference Runtime support;
- not production-ready;
- not release evidence;
- not Spark integration;
- not public performance evidence;
- not alternative certification;
- not a portability guarantee.

---

## Accepted Command Shape

The accepted experimental Slice 1 command shape is:

```bash
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:igniter-vm-candidate \
  --out RESULT.json \
  --experimental
```

`--experimental` is mandatory. Omitting it rejects the run before Slice 1
evaluation.

Only `.igapp` directory input is accepted. `.igbin` remains excluded and fails
closed.

`--passport`, `--input`, `--runtime`, and `--out` are explicit inputs. The
compiler does not emit this passport, and compiler passport emission remains
closed.

The delegated runtime selector is:

```text
delegated-experimental:igniter-vm-candidate
```

The `runtime_implementation_id` is evidence-facing metadata only:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

It is not a user-typed selector and does not create runtime authority.

---

## Path C Behavior

Slice 1 currently uses AN-1 Path C fail-closed behavior for Add.igapp integer
capabilities.

When the artifact requires:

```text
integer_add
stdlib_integer_add
```

the VM candidate does not execute Add.igapp as a successful integer run. It
writes a machine-readable blocked result packet with these exact diagnostics:

```text
unsupported_capability_integer_add
unsupported_capability_stdlib_integer_add
```

This is the accepted behavior for the current capability gap.

---

## Blocked Result Packet Shape

The accepted blocked packet observed in R243 has this shape:

```json
{
  "kind": "experimental_igc_run_slice1_result",
  "format_version": "0.1.0",
  "status": "blocked",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "runtime_selector": "delegated-experimental:igniter-vm-candidate",
  "runtime_implementation_id": "igniter.delegated.experimental.vm.rust-tokio.v0",
  "runtime_authority": "non-canonical / delegated experimental / candidate only",
  "selected_an1_path": "Path C fail-closed",
  "capability_check": "ok",
  "passport_check": "runtime_implementation_id_mismatch_acknowledged",
  "binding_check": "ok",
  "outputs": {},
  "diagnostics": [
    { "code": "unsupported_capability_integer_add" },
    { "code": "unsupported_capability_stdlib_integer_add" }
  ],
  "not_runtime_smoke": true,
  "not_compiler_passport_emission": true
}
```

`outputs` is empty for the accepted Slice 1 Path C blocked case.

---

## Proof-Local Passport and Binding

Slice 1 validates proof-local binding/passport metadata before runtime
dispatch. The validation evidence maps the existing Add.igapp artifact to:

```text
runtime_selector=delegated-experimental:igniter-vm-candidate
runtime_implementation_id=igniter.delegated.experimental.vm.rust-tokio.v0
```

The existing Add.igapp passport mismatch is acknowledged as evidence and is
not silently reinterpreted.

---

## Slice 0 Compatibility

Slice 0 compatibility remains a separate selector sanity check:

```text
delegated-experimental:ivm-proof
```

The accepted Slice 0 packet has:

```text
status=ok
outputs.sum=42
```

That result is not Slice 1 VM candidate success. Slice 1 Path C remains blocked
for the Add.igapp integer capability gap.

---

## Adjacent Artifact Exclusion

Adjacent source/conformance artifacts excluded by R243-C5-S are not accepted
as Slice 1 docs evidence, runtime authority, conformance authority,
portability evidence, public claim support, release evidence, or alternative
certification.

Excluded adjacent artifacts include:

```text
igniter-lang/source/availability_projection.ig
igniter-lang/source/tenant_availability_projection.ig
igniter-lang/out/conformance/ruby/availability_projection.igapp/**
igniter-lang/out/conformance/ruby/tenant_availability_projection.igapp/**
igniter-lang/out/conformance/rust/availability_projection.igapp/**
igniter-lang/out/conformance/rust/tenant_availability_projection.igapp/**
```

---

## Evidence Read

- `igniter-lang/docs/tracks/stage3-round243-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/summary.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice1_integer_add_blocked.result.json`
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice0_compat.result.json`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/README.md`

---

## Changed Files

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-quickstart-docs-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/README.md`

No runtime/API/CLI/package, experiment, example, playground, `.igbin`,
RuntimeSmoke, compiler passport emission, root README, or Ruby API docs file
was edited by this card.

---

## QD-S1 Proof Matrix

| ID | Result | Evidence |
| --- | --- | --- |
| QD-S1-1 | PASS | Write scope limited to the three S3-R244-C1-A docs files. |
| QD-S1-2 | PASS | Command shape uses `--runtime delegated-experimental:igniter-vm-candidate`. |
| QD-S1-3 | PASS | Path C fail-closed behavior is described as blocked Slice 1 output. |
| QD-S1-4 | PASS | Both integer-add diagnostics are named exactly. |
| QD-S1-5 | PASS | Slice 0 `delegated-experimental:ivm-proof` compatibility is separate from Slice 1 evidence. |
| QD-S1-6 | PASS | `runtime_implementation_id` is evidence-facing metadata only. |
| QD-S1-7 | PASS | Positive Add.igapp integer execution is not claimed. |
| QD-S1-8 | PASS | `.igbin` remains excluded. |
| QD-S1-9 | PASS | Compiler passport emission remains closed. |
| QD-S1-10 | PASS | RuntimeSmoke productization remains closed. |
| QD-S1-11 | PASS | Public/runtime/reference/stable/production/release/performance/portability claims remain closed through explicit non-claims. |
| QD-S1-12 | PASS | Adjacent source/conformance artifacts remain excluded. |
| QD-S1-13 | PASS | Forbidden wording scan passes with zero non-claim hits. |
| QD-S1-14 | PASS | Closed-surface scan passes; no closed files were edited by this card. |

---

## Scan Result

Forbidden wording scan over the changed docs files:

```text
status: PASS
non_claim_exception_policy: phrases are allowed only inside explicit non-claim or closure wording
non_claim_forbidden_hits: 0
```

Closed-surface scan:

```text
status: PASS
closed surfaces edited by R244: 0
```

---

## Exact C4-A Recommendation

```text
accept bounded internal quickstart/docs sync
```

Keep the boundary:

```text
Slice 1 remains Path C fail-closed evidence only.
Explicit non-claims remain:
not public runtime support
not Reference Runtime support
not stable API
not production readiness
not release evidence
not Spark integration
not public demo
not public performance evidence
not alternative certification
not portability authority
```

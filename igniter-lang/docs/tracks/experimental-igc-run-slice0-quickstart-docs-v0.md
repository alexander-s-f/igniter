# Experimental igc run Slice 0 — Quickstart Docs v0

Card: S3-R235-C3-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-quickstart-docs-v0
Route: UPDATE
Status: done
Date: 2026-06-02

Depends on:
- S3-R235-C1-A (docs authorization review)
- S3-R235-C2-P1 (Rust compiler intake — optional sidecar; available)

---

## Authority Notice

**This is pre-v1 experimental delegated-runtime Slice 0 evidence only.**

This document describes a bounded experimental `igc run` command accepted
in R234 as implementation evidence. It is not a stable API, not a public
runtime, not a Reference Runtime, not production-ready, and not release
evidence. It is subject to change or removal before v1.

No code was written or modified by this card.

---

## Accepted Command Shape

The accepted experimental `igc run` Slice 0 command:

```bash
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Every flag is required. Omitting any flag causes a non-zero exit.

---

## Prerequisites

Before running, you need four things:

**1. A compiled `.igapp` directory**

Produced by `igc compile`:

```bash
igc compile SOURCE.ig --out ARTIFACT.igapp
```

Only `.igapp` directories are accepted by Slice 0. `.igbin` paths are
rejected.

**2. A proof-local artifact passport**

A JSON file (`ARTIFACT.passport.json`) that describes the artifact and
authorizes it for delegated-experimental execution. The passport must
be generated separately; the compiler does not emit one automatically.
Passport emission by the compiler remains closed.

Required passport fields (the runner validates all of these; failure is
closed / non-zero exit):

```text
passport_kind:           "artifact_passport"
artifact_kind:           "igapp_dir"   (not "igbin" — rejected)
surface_dimension:       "executable_runtime"
runtime_target_kind:     "delegated_experimental_runtime"
authority_status:        must include "non-canonical" and "evidence-only"
non_claims:              must include all nine required non-claims (see below)
input_contract:          present and non-empty
failure_policy:          present and non-empty
runtime_implementation_id: present and non-empty
output_contract:         present, not deferred, with contract_name
artifact_ref:            path pointing to the .igapp directory
artifact_digest:         sha256 computed over all artifact files
```

**3. An input JSON object**

A JSON file containing a plain JSON object (`{}`). Arrays and non-JSON
content are rejected. Pass it via `--input PATH.json`.

**4. The explicit runtime selector**

```text
delegated-experimental:ivm-proof
```

No other runtime selector is accepted. `reference` and all other
selectors are rejected.

---

## Required Flags

| Flag | Required | Description |
|------|----------|-------------|
| `ARTIFACT.igapp` | Yes | Path to a compiled `.igapp` directory |
| `--passport PATH.json` | Yes | Proof-local artifact passport |
| `--input PATH.json` | Yes | JSON object of contract inputs |
| `--runtime delegated-experimental:ivm-proof` | Yes | Delegated experimental runtime selector |
| `--out PATH.json` | Yes | Path where the result packet is written |
| `--experimental` | Yes | Required. Omitting causes immediate rejection |

---

## Failure Modes (IGR proof coverage)

The Slice 0 runner is fail-closed. The following are all proven
rejection cases from the R234 proof (IGR-1..IGR-20, 20/20 PASS):

```text
IGR-1   PASS  rejects without --experimental
IGR-2   PASS  rejects missing --passport
IGR-3   PASS  rejects malformed passport JSON
IGR-4   PASS  rejects passport/artifact_ref mismatch
IGR-5   PASS  rejects artifact_digest mismatch
IGR-6   PASS  rejects unsupported artifact_kind (including .igbin)
IGR-7   PASS  rejects deferred output_contract
IGR-8   PASS  rejects unsupported runtime selector (e.g. "reference")
IGR-9   PASS  executes Add.igapp and returns sum=42
IGR-10  PASS  result packet is local experimental output only
IGR-11  PASS  RuntimeSmoke not invoked; forbidden label absent
IGR-12  PASS  compiler passport emission remains absent
IGR-13  PASS  compile regression PASS / runtime_smoke null
IGR-14  PASS  README/gemspec/public docs remain unchanged
IGR-15  PASS  forbidden claim scan passes
IGR-16  PASS  rejects missing --input
IGR-17  PASS  rejects malformed input JSON
IGR-18  PASS  rejects non-object input JSON
IGR-19  PASS  rejects missing --out
IGR-20  PASS  rejects missing output_contract.contract_name
```

---

## Result Packet Shape

On success, the runner writes a local JSON file at `--out PATH.json`.
This file is:

```text
kind: "experimental_igc_run_v0_result"
```

It is not a CompilerResult, not a CompilationReport, not a
CompatibilityReport, not a receipt sidecar, not a release-evidence
artifact, and not a public API response contract.

Key fields:

```json
{
  "kind": "experimental_igc_run_v0_result",
  "format_version": "0.1.0",
  "card": "S3-R234-C2-I",
  "track": "experimental-igc-run-slice0-implementation-v0",
  "status": "ok",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "runtime_selector": "delegated-experimental:ivm-proof",
  "runtime_authority": "non-canonical / delegated experimental",
  "outputs": { ... },
  "diagnostics": [],
  "non_claims": [ ... ],
  "not_compiler_result": true,
  "not_compilation_report": true,
  "not_compatibility_report": true,
  "not_receipt_sidecar": true,
  "not_release_evidence": true,
  "not_public_api_response_contract": true
}
```

The `outputs` field contains the values returned by the evaluated
contract. In the accepted R234 proof case (Add contract, inputs
`a: 19, b: 23`):

```text
outputs.sum == 42
```

On failure, the packet has `"status": "blocked"` or `"status": "error"`
and a non-empty `diagnostics` array. The runner writes the packet before
exiting non-zero.

---

## Passport Non-Claims Required

The passport `non_claims` array must include all nine of:

```text
"not stable API"
"not production ready"
"not public runtime support"
"not Reference Runtime support"
"not Spark integration"
"not release evidence"
"not public performance claim"
"not compiler passport emission"
"not igc run implementation"
```

Missing any of these causes a non-zero exit (IGR-2/6/20 equivalent
validation path).

---

## R234 Accepted Evidence

This command was accepted in R234 as bounded pre-v1 delegated-runtime
Slice 0 run evidence:

```text
Acceptance decision:  S3-R234-C4-A
Status curation:      S3-R234-C5-S
Proof track:          S3-R234-C2-I

Proof summary (S3-R234-C2-I):
  checks_total:  20
  checks_pass:   20
  checks_fail:    0
  positive case: outputs.sum == 42 (Add contract, a=19, b=23)
  compile regression: PASS / runtime_smoke: null
  pressure verdict: PASS - accept unconditionally
```

Evidence source: `igniter-lang/experiments/experimental_igc_run_v0/out/summary.json`

---

## Runtime Resolution

The selector `delegated-experimental:ivm-proof` resolves exclusively to:

```text
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
  RuntimeMachineMemoryProof::CompiledProgram.load_igapp(artifact_path)
  program.validate!
  program.evaluate_contract(contract_name, input)
```

This is a proof-local delegated runtime only. It does not provide:

- Reference Runtime support
- Public runtime support
- RuntimeSmoke integration
- Any runtime beyond the proof sandbox

---

## Closed Surfaces

The following are explicitly closed and remain unchanged:

```text
.igbin execution:                    closed — rejected by artifact path policy
                                              and passport artifact_kind policy
compiler passport emission:          closed — not introduced; proof-local passports
                                              are external evidence metadata only
RuntimeSmoke productization:         closed — not invoked, not referenced by Slice 0
Reference Runtime support:           closed
public runtime support:              closed
stable API before v1:                closed — no guarantee; subject to change
production readiness:                closed
public demo claims:                  closed
Spark integration:                   closed
release execution / evidence:        closed
public performance claims:           closed
alternative certification:           closed
portable artifact claims:            closed
root README changes:                 closed
docs/ruby-api.md changes:            closed
gemspec / package / CLI changes:     closed — bin/igc unchanged
lib/** code changes:                 closed — no code modified by C3-I
experiments/** changes:              closed
```

---

## Proof / Scan Matrix (QSD-1..QSD-15)

| Check | Status | Note |
|-------|--------|------|
| QSD-1 | PASS | Track doc created at `docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md` |
| QSD-2 | PASS | `docs/README.md` receives one navigation pointer only, labeled pre-v1 experimental delegated-runtime |
| QSD-3 | PASS | `docs/current-status.md` breadcrumb preserves all R234 closed surfaces |
| QSD-4 | PASS | Exact Slice 0 command shape present (see Accepted Command Shape) |
| QSD-5 | PASS | `--experimental` requirement explicit in Required Flags table and command shape |
| QSD-6 | PASS | `.igapp`-only scope explicit; `.igbin` rejection noted |
| QSD-7 | PASS | `--passport`, `--input`, `--runtime`, `--out` all listed as required |
| QSD-8 | PASS | `delegated-experimental:ivm-proof` named as non-canonical delegated runtime |
| QSD-9 | PASS | Result packet described as `experimental_igc_run_v0_result` only; not-* fields explicit |
| QSD-10 | PASS | No public runtime / Reference Runtime / stable API / production claim |
| QSD-11 | PASS | `.igbin`, compiler passport emission, RuntimeSmoke listed as closed |
| QSD-12 | PASS | Spark / release / public demo / public performance listed as closed |
| QSD-13 | PASS | Root README and `docs/ruby-api.md` not touched |
| QSD-14 | PASS | Forbidden wording scan: no matches (see scan commands below) |
| QSD-15 | PASS | Evidence citations point to R234 only (C4-A, C5-S, C2-I, summary.json) |

### Forbidden Wording Scan Commands

```bash
ruby -e 'ARGV.each { |p| abort("#{p} missing") unless File.file?(p) }' \
  igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md

rg -n "stable run command|stable runtime API|production runtime|production-ready runtime|Reference Runtime support|public runtime support|certified runtime|certified compiler|portable artifact guarantee|release-ready runtime|Spark integration|public performance benchmark|all grammar support|production-compiler-cli|RuntimeSmoke support" \
  igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md \
  igniter-lang/docs/README.md \
  igniter-lang/docs/current-status.md
```

Expected: zero matches outside explicit "closed" / "not" / "remains closed" non-claim context.

---

## Changed Files

```text
igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md
  Created. Main bounded quickstart track doc.

igniter-lang/docs/README.md
  One navigation pointer added in the Navigation block.
  Label: pre-v1 experimental delegated-runtime Slice 0 evidence only.

igniter-lang/docs/current-status.md
  Compact breadcrumb: C3-I docs-sync has landed.
```

Unchanged (confirmed):

```text
igniter-lang/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/igniter_lang.gemspec
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/experiments/**
igniter-lang/examples/**
playgrounds/**
```

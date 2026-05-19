# PROP-038 Strict Mode Refusal Trigger Proof-Local Boundary Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R77-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R77 agents distinguish a proof-local `would_refuse` model from
live compiler refusal, public API/CLI behavior, `CompilerResult` changes,
persisted artifacts, loader/report, CompatibilityReport, runtime, or production
behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md
igniter-lang/docs/tracks/stage3-round76-status-curation-v0.md
igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md
igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## Current Authority Snapshot

R76 accepted strict-mode/refusal trigger design and authorized only a bounded
proof-local experiment:

```text
prop038-strict-mode-refusal-trigger-proof-local-v0
```

The accepted design is not live compiler behavior:

```text
live compile refusal remains closed
report-only remains current live behavior
loader/report remains closed
CompatibilityReport remains closed
runtime/production remains closed
```

Accepted first strict-mode source:

```text
gate-controlled proof-local strict requirement object
```

This source exists only for the proof-local experiment.

---

## Allowed Proof-Local Source And Vocabulary

Accepted proof-local strict requirement object shape:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "proof_local_gate",
  "refusal_candidates": [
    "compiler_profile_contract.contract_digest_mismatch"
  ],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

Accepted proof-local trigger vocabulary:

```text
report_only
strict_validation_requested
strict_validation_source
refusal_candidate_diagnostic
compiler_refusal_decision
loader_report_status
runtime_readiness
```

Accepted proof-local decision vocabulary:

```text
not_evaluated
allow
would_refuse
configuration_error
```

Forbidden term until a later implementation gate:

```text
refused
```

Accepted first wrapper code for proof-local modeling:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

It cites evidence:

```text
compiler_profile_contract.contract_digest_mismatch
```

Wrapper codes are not `IgniterLang::Diagnostics`, top-level report diagnostics,
public API/CLI output, live compiler status, loader/report vocabulary, or
CompatibilityReport vocabulary.

---

## Allowed Experiment-Only Write Scope

R77 may write only:

```text
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/
igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md
```

Allowed experiment behavior:

```text
create proof-local trigger evaluation code outside igniter-lang/lib
consume existing IgniterLang::CompilerProfileContractValidator behavior
model strict_validation_source: "proof_local_gate"
model compiler_refusal_decision values:
  not_evaluated
  allow
  would_refuse
  optional configuration_error
model only contract_digest_mismatch as would_refuse
use wrapper code compiler_profile_contract_refusal.contract_digest_mismatch
model contract_digest_recompute_unavailable as fail-open/report-only
include legacy no-field/no-refusal cases
produce JSON summary under the experiment out/ directory
```

R77 must not edit:

```text
igniter-lang/lib/
```

---

## What `would_refuse` May Mean

Allowed meaning:

```text
In a proof-local strict-source model, this case would be a candidate for future
compiler refusal if a later Architect gate authorized live refusal behavior.
```

Allowed evidence path:

```text
proof_local_gate strict source
  + live validator result contains compiler_profile_contract.contract_digest_mismatch
  + first wrapper code compiler_profile_contract_refusal.contract_digest_mismatch
  => compiler_refusal_decision = would_refuse
```

Allowed scope:

```text
experiment summary
proof-local model vocabulary
future design evidence
```

---

## What `would_refuse` Must Not Mean

Forbidden meanings:

```text
compiler refused
compile status changed
refusal report was written
public API/CLI returned refusal
CompilerResult changed
top-level report diagnostics changed
loader/report status changed
CompatibilityReport changed
.igapp changed
RuntimeMachine behavior changed
production behavior changed
```

Also forbidden:

```text
would_refuse != refused
would_refuse != compile_refusal_authorized=true
would_refuse != compiler_integrated=true
```

Current live fixed flags remain:

```text
compiler_integrated=false
compile_refusal_authorized=false
report_only=true
```

---

## Required Proof Matrix Anchors

The proof-local experiment should include:

```text
report-only + valid contract => compile/result behavior unchanged
report-only + digest mismatch => nested diagnostic only
no strict source => not_evaluated
strict proof-local source + valid contract => allow
strict proof-local source + digest mismatch => would_refuse with wrapper evidence
strict proof-local source + invalid digest => not would_refuse in first model
strict proof-local source + unsupported policy => not refusal; optional configuration_error
strict proof-local source + recompute unavailable => fail-open/report-only
nil/non-Hash/provider-error/validator-error paths => no-field/no-refusal
top-level diagnostics/public result/CompilerResult/.igapp/loader/report/
  CompatibilityReport/runtime/production behavior remain untouched
```

Required command matrix:

```bash
ruby -c igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/<script>.rb
ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/<script>.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

The concrete script name is a proof-local implementation detail.

---

## Forbidden Live / Public / Persisted / Runtime Surfaces

Closed in R77:

```text
edits under igniter-lang/lib
live compiler/orchestrator behavior changes
live compile refusal
public API or CLI widening
CompilerResult changes
persisted reports or sidecars outside proof-local experiment output
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
.ilk
CompilationReceipt links
signing
dispatch migration
RuntimeMachine
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Closed inference paths:

```text
provider presence does not imply strict mode
validation["valid"] == false does not imply strict mode
contract_digest_mismatch does not imply strict mode
report_only=true does not imply refusal
compiler_integrated=false does not imply refusal
compile_refusal_authorized=false does not imply refusal
CLI --compiler-profile-source does not imply strict mode
assembler compiler_profile_source.* vocabulary does not imply strict mode
```

---

## Likely Pressure Hazards For C2-X

C2-X should pressure-test:

```text
1. Live-refusal leakage:
   Does any output say or imply the compiler actually refused?

2. Vocabulary drift:
   Did the experiment use `refused` instead of `would_refuse`?

3. Write-scope drift:
   Did C1-I edit anything outside the experiment directory and its track doc?

4. Wrapper-code drift:
   Did compiler_profile_contract_refusal.* become a live diagnostics namespace?

5. Candidate expansion:
   Did invalid digest, unsupported policy, or recompute unavailable become
   would_refuse without a later gate?

6. Fail-closed creep:
   Did recompute unavailable stop being fail-open/report-only?

7. Public-surface creep:
   Did CLI/API, CompilerResult, public result, top-level diagnostics, or user
   messages change?

8. Persisted-artifact creep:
   Did the proof create reports/sidecars outside experiment out/, .igapp
   changes, loader/report output, or CompatibilityReport output?

9. Runtime implication:
   Did proof-local runtime_readiness vocabulary imply RuntimeMachine, Gate 3,
   cache, Ledger/TBackend, or production behavior?

10. Regression omission:
    Were existing validator proof and report-only integration proof rerun?

11. No-field path regression:
    Did nil/non-Hash/provider-error/validator-error paths remain
    no-field/no-refusal?

12. Authority language:
    Does the track state proof-local/non-authority clearly enough for future
    agents not to promote it accidentally?
```

---

## One-Line Handoff

Model `would_refuse` in proof-local space; do not make refusal real.

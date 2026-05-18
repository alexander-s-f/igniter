# PROP-038 Contract Digest Report-Only Integration Boundary Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-18
Source card: `S3-R71-C0-O`
Authority: orientation only, not canon

---

## Purpose

Keep R71 proof-local report-only digest integration distinct from:

```text
live validator implementation
compiler authority
compile refusal
public/report surfacing
persisted reports or sidecars
loader/report or CompatibilityReport behavior
runtime or production behavior
```

This map does not authorize code, semantics, gates, proposals, implementation,
compile refusal, public output, persisted output, loader/report behavior,
CompatibilityReport behavior, runtime behavior, or production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md
igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md
igniter-lang/docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md
igniter-lang/docs/tracks/stage3-round70-status-curation-v0.md
igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md
```

Decision status:

```text
accepted-proof-local-recompute-match-closure
```

Next allowed route:

```text
prop038-contract-digest-report-only-integration-proof-v0
```

Boundary:

```text
proof-local integration model only
wire shape + recompute diagnostics through an experiment-local report-only
validation result
do not edit live validator/compiler/orchestrator code
do not create compile refusal
do not widen public API/CLI, CompilerResult, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, runtime, or production behavior
```

---

## R67 Report-Only Integration Invariants

R71 should reuse the accepted R67 mental model:

```text
internal provider on CompilerOrchestrator constructor
in-memory CompilationReport field only
report-only, never refusal
```

Accepted invariant set:

```text
invalid validation does not change compile status
invalid validation does not change pass_result
invalid validation does not change stages
invalid validation does not append to top-level report["diagnostics"]
invalid validation does not block assembler execution
invalid validation does not mutate .igapp manifest/artifacts
invalid validation does not write a refusal report
invalid validation does not change public result
provider nil preserves legacy behavior
provider exception preserves legacy behavior
```

For R71, replace "invalid contract" with:

```text
digest invalid / policy unsupported / recompute unavailable / digest mismatch
```

and the invariant must still hold.

---

## Digest Diagnostics In Proof-Local Validation Output

The complete four-code candidate set is proof-covered across R69/R70:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

R71 may carry these only inside an experiment-local report-only validation
result.

Intended nested location for proof modeling:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
report["compiler_profile_contract_validation"]["diagnostic_codes"]
```

Forbidden locations:

```text
top-level report["diagnostics"]
IgniterLang::Diagnostics
CompilerResult public output
CLI output
persisted success .compilation_report.json
sidecar JSON
loader/report status
CompatibilityReport
```

---

## Forbidden Compile-Outcome Changes

R71 proof must show digest diagnostics do not change:

```text
orchestration status
report["pass_result"]
report["stages"]
report["diagnostics"]
CompilerResult.public_result
assembler execution
.igapp manifest/artifacts
refusal report creation
compile_refusal_authorized
compiler_integrated outcome interpretation
```

Forbidden implication:

```text
contract_digest_mismatch => compiler failure
contract_digest_recompute_unavailable => compiler internal_error
contract_digest_policy_unsupported => CLI/API refusal
contract_digest_invalid => loader/report or CompatibilityReport not-ready status
```

Current safe reading:

```text
digest diagnostics may be observed inside proof-local validation output;
they must not decide compiler behavior.
```

---

## Required `non_authorizations_preserved` Block

R70-C3-A accepted NB-1 as a future traceability requirement:

```text
Future proof summaries should include a structured
non_authorizations_preserved block matching the R65/R67/R69 pattern.
```

R71 summaries should include a block at least covering:

```json
{
  "live_validator_implementation": false,
  "compiler_orchestrator_implementation": false,
  "compilation_report_live_change": false,
  "compiler_result_change": false,
  "compile_refusal": false,
  "public_api_cli_widening": false,
  "persisted_success_reports_or_sidecars": false,
  "parser_typechecker_semanticir_assembler_igapp": false,
  "loader_report_or_compatibility_report": false,
  "diagnostics_centralization": false,
  "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production": false
}
```

Exact key names may differ, but the hold inventory should be explicit,
structured, and machine-readable.

---

## Non-Authority Surfaces

Unless a later Architect gate explicitly opens them, R71 proof evidence must not
affect:

```text
CompilerProfileContractValidator live behavior
CompilerOrchestrator live behavior
CompilationReport live behavior
CompilerResult or public_result
public API / CLI
parser / classifier / TypeChecker / SemanticIR
assembler / .igapp artifacts
persisted success reports
sidecar JSON
loader/report
CompatibilityReport
IgniterLang::Diagnostics
receipts / .ilk / signing
dispatch migration
RuntimeMachine / Gate 3
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Compact rule:

```text
proof-local report-only integration may carry digest diagnostics;
it must not create compiler authority.
```

---

## Proof Acceptance Questions

Before accepting any R71 report-only integration proof, check:

```text
1. Did it stay proof-local?
2. Did it avoid editing live validator/compiler/report/runtime files?
3. Did it carry all four digest diagnostic candidates only inside nested
   validation output?
4. Did mismatch still return compile status ok?
5. Did public result remain unchanged?
6. Did .igapp manifest/artifacts remain unchanged?
7. Did it avoid writing a refusal report?
8. Did top-level report["diagnostics"] remain unchanged?
9. Did provider nil/exception behavior preserve legacy behavior if modeled?
10. Did it include structured non_authorizations_preserved?
11. Did it preserve R69/R70 proof status and R67 report-only invariants?
12. Did it avoid public API/CLI, CompilerResult, loader/report,
    CompatibilityReport, RuntimeMachine, Gate 3, runtime, and production
    surfaces?
```

---

## Future Route Separation

Recommended sequence remains:

```text
R69: shape-only proof accepted
R70: recompute/canonicalization proof accepted
R71: report-only integration proof-local evidence
later: Architect decision on R71 proof acceptance
later: possible PROP-038 errata after full four-code vocabulary proves stable
later: possible live validator implementation design/authorization
later: possible report-only live implementation authorization
much later: possible compile-refusal gate, if ever
```

No future agent should skip from R71 proof-local evidence directly to live code,
public surfacing, persisted artifacts, loader/report, CompatibilityReport, or
refusal behavior.

---

## Return Summary

R71 may prove that the full `contract_digest_*` candidate vocabulary can travel
through a report-only validation result without changing compiler behavior. It
must remain proof-local and must include a structured
`non_authorizations_preserved` block.

The compact rule:

```text
carry digest diagnostics in proof-local report-only output;
do not create compiler authority
```

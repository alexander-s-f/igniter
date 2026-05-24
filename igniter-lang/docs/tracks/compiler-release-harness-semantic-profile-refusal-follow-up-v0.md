# Compiler Release Harness Semantic Profile Refusal Follow-up v0

Card: S3-R163-C2-I  
Agent: [Igniter-Lang Implementation Agent]  
Role: implementation-agent  
Track: compiler-release-harness-semantic-profile-refusal-follow-up-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-24

---

## Authorization

- S3-R163-C1-A: authorized bounded proof-local harness fix
- S3-R163-C2-S: c2_i_authorized_open

---

## Authorized Write Scope

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md
```

No other files were edited. No compiler/library code was touched.

---

## Gap Being Resolved

R162 identified that `semantic_profile_wrong_kind.has_qualified_diagnostic` was
`false` in the harness summary. The root cause was that the harness computed
`has_qualified_diagnostic` from a truncated stdout snippet, which ended before
the diagnostics array was emitted. The compiler already produced the qualified
diagnostic `compiler_profile_source.wrong_kind` in the generated refusal
compilation report.

---

## Fix Applied

Updated `run_cli_semantic_refusal` in
`compiler_release_acceptance_harness_v0.rb`:

1. After CLI run, compute the refusal compilation report path:
   `OUT_DIR/wrong_kind_should_not_exist.compilation_report.json`
2. Read the report JSON and inspect `diagnostics[].message` for
   `compiler_profile_source.` prefix.
3. Set `has_qualified_diagnostic: true` when a matching diagnostic is found.
4. Record `qualified_diagnostic_source` and `observed_qualified_diagnostic`
   in the summary.
5. Update `pass` logic: requires non-zero exit AND no igapp AND
   `has_qualified_diagnostic: true`.
6. Added `preflight.semantic_profile_wrong_kind.no_qualified_diagnostic` to
   `failed_checks` sensitivity in the `run` method.

Added helper `extract_qualified_profile_diagnostic` with stdout fallback if
the report file is absent.

No compiler/library files were modified.

---

## Required Proof Commands

```bash
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
# => Syntax OK

ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
# => HOLD compiler_release_acceptance_harness_v0
# => positive_corpus_entries=5
# => negative_corpus_entries=3
# => command_matrix_entries=14
# => failed_checks=0
# => hold_reasons=1
# => summary=igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
```

---

## Proof Matrix

| Check | Result |
|-------|--------|
| Write scope respected | PASS — only harness experiment dir + this track |
| Syntax check | PASS — `Syntax OK` |
| Harness command | PASS — completes |
| `semantic_profile_wrong_kind.pass` | true |
| `semantic_profile_wrong_kind.has_qualified_diagnostic` | true |
| Observed diagnostic | `add_baseline: compiler_profile_source.wrong_kind: "not_a_compiler_profile_id_source"` |
| Diagnostic source | `report_diagnostics` (wrong_kind_should_not_exist.compilation_report.json) |
| No `.igapp` for wrong-kind case | true |
| `failed_checks` | 0 |
| Top-level status | HOLD — only from accepted branch/conditional boundary |
| Closed-surface scan | PASS — 0 hits |
| RC evidence claim | false |
| Release execution claim | false |
| Compiler/library code mutated | false |
| POC/golden/existing igapp mutated | false |

---

## semantic_profile_wrong_kind Summary Entry

```json
{
  "surface": "repo_local_compiler_cli_refusal",
  "kind": "cli_semantic_profile_refusal",
  "name": "semantic_profile_wrong_kind",
  "pass": true,
  "exit_status": 1,
  "no_igapp_written": true,
  "has_qualified_diagnostic": true,
  "qualified_diagnostic_source": "report_diagnostics",
  "observed_qualified_diagnostic": "add_baseline: compiler_profile_source.wrong_kind: \"not_a_compiler_profile_id_source\""
}
```

---

## R162 Conditional Accept Disposition

The R162 semantic follow-up condition is now closed:

```text
semantic_profile_wrong_kind qualified diagnostic condition: CLOSED
```

Remaining separate HOLD:

```text
branch_conditional_if_expr_unsupported: REMAINS OPEN
```

The branch/conditional boundary remains HOLD until a later Portfolio decision
either narrows the first-RC language scope or routes branch/conditional support
separately.

---

## Remaining Blockers Before RC Evidence Authorization

```text
1. branch_conditional_if_expr_unsupported: TypeChecker does not support if_expr.
   Requires later Portfolio decision to either:
   a. narrow first-RC language scope to exclude branch/conditional, or
   b. route branch/conditional support as a separate track.
```

The semantic profile-source refusal gap is resolved. RC evidence gathering
remains closed pending Portfolio disposition of the branch/conditional scope
boundary.

---

## Non-Claims

```text
no_official_rc_evidence: generated outputs are proof-local harness follow-up
  evidence only; not official release-candidate evidence
no_release_execution: not authorized
no_public_demo_claim: not authorized
no_compiler_library_changes: this fix is proof-local harness only
```

---

## Round Receipt

```text
card: S3-R163-C2-I
track: compiler-release-harness-semantic-profile-refusal-follow-up-v0
status: done
fix_type: proof_local_harness_evidence_extraction_fix
gap_resolved: semantic_profile_wrong_kind_has_qualified_diagnostic_false
has_qualified_diagnostic: true
qualified_diagnostic_source: report_diagnostics
observed_qualified_diagnostic: compiler_profile_source.wrong_kind
failed_checks: 0
hold_reasons: 1
hold_reason_1: branch_conditional_if_expr_unsupported (accepted boundary)
harness_status: HOLD
r162_semantic_condition: closed
branch_conditional_hold: remains_open
rc_evidence_gathering: closed
write_scope_respected: yes
no_compiler_library_changes: yes
no_poc_golden_igapp_mutated: yes
no_public_api_cli_widening: yes
no_release_execution: yes
no_public_demo_claim: yes
```

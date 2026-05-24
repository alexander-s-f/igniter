# Compiler Release Harness Semantic Profile Refusal Follow-up Decision v0

Card: S3-R163-C1-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-harness-semantic-profile-refusal-follow-up-decision-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round162-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-decision-v0.md`
- `igniter-lang/docs/discussions/compiler-release-acceptance-harness-design-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/wrong_kind_should_not_exist.compilation_report.json`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`

---

## Decision

Decision:

```text
authorize bounded proof-local harness fix
do not reclassify as unresolved assembler-only refusal
do not authorize compiler/library changes
keep official RC evidence gathering closed
```

The R162 gap is accepted as a harness proof-detection gap, not as evidence
that the compiler lacks the qualified diagnostic.

Observed evidence:

```text
summary semantic_profile_wrong_kind.has_qualified_diagnostic: false
wrong_kind report diagnostic message: compiler_profile_source.wrong_kind
compiler status: assembler_refused
no .igapp written: true
```

The generated `wrong_kind_should_not_exist.compilation_report.json` contains
the qualified diagnostic text:

```text
compiler_profile_source.wrong_kind
```

The harness currently computes `has_qualified_diagnostic` from a short stdout
snippet. That snippet truncates before diagnostics, while the accepted behavior
allows a compilation report for semantic profile-source refusal. Therefore the
right next move is a narrow harness fix: inspect the generated refusal report
diagnostics and record qualified diagnostic evidence from the report.

---

## Explicit Answers

### Must `semantic_profile_wrong_kind` require a qualified diagnostic?

Yes.

For the release-acceptance harness, `semantic_profile_wrong_kind` must require
and prove a qualified `compiler_profile_source.*` diagnostic. The expected
v0 diagnostic is:

```text
compiler_profile_source.wrong_kind
```

This diagnostic may be observed in the generated compilation report, not only
in the CLI stdout snippet.

### May current behavior be reclassified as assembler wrong-kind only?

No, not as the preferred disposition.

The live compiler status is correctly `assembler_refused`, but the report
already carries the qualified `compiler_profile_source.wrong_kind` reason. A
reclassification would hide useful evidence and keep a gap open that can be
closed proof-locally.

### May compiler/library code be touched now?

No.

No compiler/library change is authorized. In particular, this decision does
not authorize changes to:

```text
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/cli.rb
```

The existing compiler behavior is sufficient for this follow-up.

### May generated harness outputs be refreshed?

Yes, but only harness-local outputs under the accepted experiment directory.

Allowed:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/**
```

The implementation may rerun the harness and refresh the summary/report outputs
it owns.

### Can the R162 conditional accept become fully closed after this follow-up?

Yes, for the semantic profile-source refusal condition only.

If C2-I proves `semantic_profile_wrong_kind.has_qualified_diagnostic = true`
using the generated refusal report diagnostics, the R162 semantic follow-up
condition is closed.

This does not close the separate branch/conditional RC-scope boundary:

```text
branch_conditional_if_expr_unsupported
```

That boundary remains HOLD until a later Portfolio decision either narrows the
first RC language scope or routes branch/conditional support separately.

### Does RC evidence gathering remain closed?

Yes.

Official RC evidence gathering remains closed after this decision. This card
authorizes only a proof-local harness fix and proof report.

---

## Authorized C2-I Boundary

Card authorized:

```text
Card: S3-R163-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-harness-semantic-profile-refusal-follow-up-v0
Route: UPDATE
Depends on:
- S3-R163-C1-A
- S3-R163-C2-S
```

Allowed write scope:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md
```

No other files may be edited.

---

## Required Fix Shape

C2-I must update the harness so `semantic_profile_wrong_kind` proves qualified
diagnostic evidence from the accepted evidence source.

Required behavior:

- run the wrong-kind profile-source compile case;
- preserve non-zero exit status requirement;
- preserve no `.igapp` write requirement;
- read the generated refusal report for that case;
- inspect report diagnostics for a qualified `compiler_profile_source.*`
  reason;
- set `has_qualified_diagnostic` to `true` only when the report or stdout
  contains a qualified diagnostic;
- record the observed diagnostic string or diagnostic-source field in the
  summary;
- keep `failed_checks` sensitive to missing qualified diagnostic evidence.

Expected diagnostic:

```text
compiler_profile_source.wrong_kind
```

Expected source:

```text
wrong_kind_should_not_exist.compilation_report.json diagnostics[].message
```

The summary may add fields such as:

```text
qualified_diagnostic_source: report_diagnostics
observed_qualified_diagnostic: compiler_profile_source.wrong_kind
```

Field names may vary if the proof track documents them exactly, but the
machine-readable summary must make the source and observed diagnostic clear.

---

## Command Matrix

C2-I must run:

```text
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
```

Required command result:

```text
syntax: PASS
harness command: completes
failed_checks: 0
semantic_profile_wrong_kind.pass: true
semantic_profile_wrong_kind.has_qualified_diagnostic: true
```

The top-level harness status may remain `HOLD` because
`branch_conditional_if_expr_unsupported` remains an accepted boundary signal.

---

## No-Mutation Policy

C2-I must not mutate:

- POC/MVP live-touch outputs;
- existing non-harness `.igapp` artifacts;
- goldens outside the harness experiment;
- compiler/library code;
- public CLI/API code;
- docs outside the named follow-up track unless separately authorized.

Harness-local output refresh is allowed.

---

## Proof Matrix

C2-I must explicitly report:

| Check | Required result |
| --- | --- |
| Write scope respected | PASS |
| Syntax check | PASS |
| Harness command | PASS / completes |
| `semantic_profile_wrong_kind.pass` | true |
| `semantic_profile_wrong_kind.has_qualified_diagnostic` | true |
| Observed diagnostic | `compiler_profile_source.wrong_kind` |
| Diagnostic source | report diagnostics or stdout, exactly recorded |
| No `.igapp` for wrong-kind case | true |
| `failed_checks` | 0 |
| Top-level status | PASS or HOLD; HOLD allowed only for accepted branch/conditional boundary |
| RC evidence claim | false |
| Release execution claim | false |
| Closed-surface scan | unchanged or PASS |

---

## RC Evidence Gathering Status

Closed.

Generated outputs after C2-I remain proof-local harness follow-up evidence.
They must not be called official release-candidate evidence.

Before any official RC evidence gathering can open, a later Portfolio decision
must address at least:

- this follow-up result;
- branch/conditional first-RC scope disposition;
- any remaining harness HOLD reasons.

---

## Closed Surfaces

This decision does not authorize:

- official RC evidence gathering;
- release execution;
- public release or public demo claims;
- compiler/library implementation;
- public analyzer/tracer/visualizer implementation or command/UI;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, or assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or `CompatibilityReport` widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration
  outside harness-local generated output;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R163-C1-A
decision: authorize_bounded_proof_local_harness_fix
gap: semantic_profile_wrong_kind_has_qualified_diagnostic_false
expected_diagnostic: compiler_profile_source.wrong_kind
diagnostic_source: wrong_kind_refusal_report_diagnostics
compiler_library_changes_authorized: no
generated_harness_outputs_refresh_authorized: yes
c2_i_authorized: yes
c2_i_write_scope: experiments/compiler_release_acceptance_harness_v0 + follow_up_track
r162_semantic_condition_closable_after_c2_i: yes
branch_conditional_hold_remains: yes
rc_evidence_gathering: closed
release_execution_authorized: no
public_demo_release_authorized: no
```

# Track: OOF/Fragment Registry Profile/Pack Source Acceptance Proof v0

Card: LANG-R122-I1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R121-A
Track: `oof-fragment-registry-profile-pack-source-acceptance-proof-v0`
Status: implemented-with-matrix-stale-proof-failures
Date: 2026-05-21

---

## Goal

Implement and prove internal-only live-helper acceptance for
`profile_candidate` and `pack_descriptor_candidate` source envelopes inside
`IgniterLang::OOFFragmentRegistry`.

This implementation stays inside the R121-A boundary. It does not authorize or
open public API/CLI, loader/report, CompatibilityReport, `.igapp`, PROP-036,
PROP-038, compiler integration, runtime, production, or Spark behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: old proof-local tracks now contain stale
  held-mode assertions.
- `[Igniter-Lang Bridge Agent]`: external bridge surfaces remain closed.
- `[Architect Supervisor / Codex]`: owns whether stale proof updates are a new
  repair card or acceptance note.

---

## Evidence Read

- `docs/gates/oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0.md`
  (LANG-R121-A)
- `docs/tracks/oof-fragment-registry-profile-pack-source-acceptance-preconditions-design-v0.md`
  (LANG-R119-D1)
- `docs/discussions/oof-fragment-registry-profile-pack-source-acceptance-bridge-pressure-v0.md`
  (LANG-R120-X)
- `docs/gates/oof-fragment-registry-source-authority-model-acceptance-decision-v0.md`
  (LANG-R118-A)
- `lib/igniter_lang/oof_fragment_registry.rb`

---

## Implementation Summary

Updated:

```text
igniter-lang/lib/igniter_lang/oof_fragment_registry.rb
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/
```

Implemented:

- `SOURCE_ACCEPTED_MODES` now contains exactly:

```text
proof_fixture
caller_supplied
profile_candidate
pack_descriptor_candidate
```

- `SOURCE_HELD_MODES` is now empty.
- authority validation still accepts only:

```text
authority_kind: proof_only | design_accepted
canon_status:   non_canon | accepted_design
```

- source authority is validated before nested registry validation.
- `pack_descriptor_candidate` validates pack-row provenance and can be accepted
  without a nested complete registry.
- `profile_candidate` validates selected pack refs, deterministic pack order,
  conflict policy, pack-row provenance, duplicate ownership, excluded namespace
  claims, and profile override attempts before deriving a nested registry.
- derived profile registry validation runs only after source/aggregation checks
  pass.

The helper result family remains internal-only:

```text
kind: oof_fragment_registry_source_validation
```

No public/report/runtime keys were added.

---

## Acceptance Proof

New proof:

```text
ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/oof_fragment_registry_profile_pack_source_acceptance_proof.rb
```

Result:

```text
PASS oof-fragment-registry-profile-pack-source-acceptance-proof-v0
cases: 13/13
checks: 5/5
```

Covered cases:

| Case | Result |
| --- | --- |
| accepted modes changed only for authorized modes | PASS |
| valid pack descriptor candidate accepted without registry | PASS |
| valid profile candidate derives and validates registry | PASS |
| duplicate OOF descriptor ownership rejected | PASS |
| duplicate fragment row ownership rejected | PASS |
| duplicate support marker ownership rejected | PASS |
| duplicate alias ownership rejected | PASS |
| missing selected pack refs rejected | PASS |
| excluded namespace claims rejected | PASS |
| profile override of pack conflict rejected | PASS |
| invalid authority kind rejected before nested validation | PASS |
| canon status rejected before nested validation | PASS |
| `proof_fixture` and `caller_supplied` still accepted | PASS |

Covered checks:

| Check | Result |
| --- | --- |
| helper result family internal-only | PASS |
| no public surface keys in results | PASS |
| closed-surface assertions false | PASS |
| surface files not opened | PASS |
| PROP-036/PROP-038 surfaces not mutated | PASS |

Summary output:

```text
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/out/oof_fragment_registry_profile_pack_source_acceptance_proof_summary.json
```

---

## R121 Proof Matrix

| Command | Result | Notes |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS | Syntax OK. |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/oof_fragment_registry_profile_pack_source_acceptance_proof.rb` | PASS | New R122 proof, 13/13 cases and 5/5 checks. |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | FAIL | Stale pre-R121 assertions: `live_helper_profile_pack_modes_held`, `source_accepted_modes_unchanged`; cascading `r115_profile_pack_proof.pass_evidence` after old summary state. |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | FAIL | Stale pre-R121 assertions: `live_helper_profile_pack_modes_held`; cascading `source_helper_summary.pass_evidence`. |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | FAIL | Stale pre-R121 cases `SE5.profile_candidate_held_internally` and `SE6.pack_descriptor_candidate_held_internally`; related shape checks fail because candidate modes now validate. |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS | 27/27 checks. |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS | Classifier unaffected. |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS | TypeChecker golden check unaffected. |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS | Source-to-SemanticIR golden check unaffected. |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS | Assembler/runtime smoke unaffected. |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | PROP-038 report-only behavior unaffected. |

Interpretation:

```text
Implementation proof: PASS
Downstream compiler/regression proofs: PASS
Full R121 matrix: FAIL due to three stale pre-R121 OOF registry proof scripts
that still assert profile/pack candidate modes are held.
```

Those stale proof scripts are outside the R122 authorized write scope, so this
card does not edit them.

---

## Surface Closure

Preserved closed surfaces:

- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 mutation;
- PROP-038 validator/report/refusal mutation;
- compiler integration;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, and CLI changes;
- `lib/igniter_lang.rb` require changes;
- `oof_fragment_registry_data.rb`;
- runtime, production, Spark, Ledger/TBackend, and Gate 3.

---

## Handoff

[D] Implemented authorized internal-only acceptance of `profile_candidate` and
`pack_descriptor_candidate` in `IgniterLang::OOFFragmentRegistry`.

[S] New R122 proof passes, and downstream compiler/regression proofs pass. Full
R121 matrix is not green because three old proof scripts still assert the
pre-R121 held-mode state.

[T] PASS: new proof 13/13 cases, 5/5 checks; syntax; implementation boundary;
classifier; typechecker golden; source-to-SemanticIR golden; assembler;
PROP-038 report-only integration. FAIL: three stale OOF registry proof scripts
named in the matrix.

[R] Recommend an immediate bounded stale-proof repair card if Architect wants
the full R121 matrix green:
`oof-fragment-registry-profile-pack-source-proof-refresh-v0`.

[Next] Update or supersede the old source-envelope/source-mode/source-authority
proof expectations from "candidate modes held" to "candidate modes accepted
only inside internal helper, with external surfaces still closed".

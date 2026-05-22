# Fragment Registry Compatibility Adapter Helper Boundary Pressure v0

Card: S3-R146-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Route: UPDATE
Track: fragment-registry-compatibility-adapter-helper-boundary-pressure-v0
Status: complete
Date: 2026-05-22

---

## Goal

Pressure-review the S3-R146-C1-P1 proof-only internal helper boundary for
hidden implementation, classifier wiring drift, root-require leakage, and
accidental public/report/`.igapp`/runtime/Spark surface widening.

---

## Evidence Read

- `docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md`
  (S3-R146-C1-P1) — the primary subject of this review
- `docs/gates/fragment-registry-adapter-implementation-boundary-decision-v0.md`
  (S3-R145-C4-A) — the Architect gate that authorized C1's allowed write scope
  and required command matrix
- `docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md`
  (LANG-R144-P1) — the source R144 matrix evidence
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json`
  — proof summary (19 checks, 0 failures)
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json`
  — full 23-row projection result
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb`
  — proof runner source code (read to verify scan vocabulary and write paths)

No code was edited. No proof commands were run by this reviewer.

---

## Scope Checks

### Check 1 — C1 stayed within allowed write scope

**Question:** Do C1's changed files fall entirely within the scope authorized
by S3-R145-C4-A?

**C4-A authorized write scope:**

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/**
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md
```

**C1's changed files:**

```text
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_input_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json
```

All 5 files fall within the authorized paths. No files outside the authorized
scope were written.

Git status confirms these 5 files are staged and no other files are pending.

**Verdict: PASS**

---

### Check 2 — No `lib/` files created or edited

**Question:** Did C1 create or modify any file under `igniter-lang/lib/`?

**Evidence:**

The `closed_surface_assertions` block in both `helper_result_shape.json` and
the proof summary carries:

```json
"lib_helper_file_created": false,
"root_require_changed": false,
"classifier_wiring": false,
...
```

The proof runner source code writes only to `OUT_DIR`, which is resolved to:

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out
```

No `lib/` path appears in the runner's write logic. The `write_outputs` method
calls `Canonical.write_json` only for `helper_input_shape.json`,
`helper_result_shape.json`, and the summary — all under `OUT_DIR`.

Git status independently confirms: only the 5 authorized files are staged under
`experiments/` and `docs/tracks/`. No `lib/` entry appears.

**Verdict: PASS**

---

### Check 3 — No root require or classifier wiring

**Question:** Does the proof runner contain any `require` referencing lib files,
or does any lib file reference the helper vocabulary?

**Evidence from runner source code:**

Top-level requires in the proof runner:

```ruby
require "digest"
require "json"
require "pathname"
```

All three are Ruby stdlib. No `require_relative` or `require` pointing to
`lib/igniter_lang/` or any other lib path is present. The runner reads only
from `fragment_precedence_compatibility_adapter_proof/out/` JSON artifacts.

Negative scan vocabulary (read directly from source code):

| File scanned | Terms searched |
| --- | --- |
| `lib/igniter_lang.rb` | `fragment_registry_compatibility_adapter`, `FragmentRegistryCompatibilityAdapter` |
| `lib/igniter_lang/classifier.rb` | `fragment_registry_compatibility_adapter`, `FragmentRegistryCompatibilityAdapter` |
| `lib/igniter_lang/compilation_report.rb` | `fragment_registry_compatibility_adapter`, `declaration_fragment_presence` |
| `lib/igniter_lang/assembler.rb` | `fragment_registry_compatibility_adapter`, `declaration_fragment_presence` |
| `lib/igniter_lang/cli.rb` | `fragment_registry_compatibility_adapter`, `declaration_fragment_presence` |
| `lib/igniter_lang/temporal_executor.rb` | `fragment_registry_compatibility_adapter`, `declaration_fragment_presence` |
| `experiments/sparkcrm_bihistory_fixture/...rb` | `fragment_registry_compatibility_adapter`, `declaration_fragment_presence` |

All 7 scans returned no hits (confirmed in summary JSON). The scan vocabulary
is explicit in the runner source — both the helper class name and the
declaration-presence field name were searched in every target file.

Summary: `classifier_wiring_authorized: false` and
`classifier_wiring: false` appear in both the result shape and summary.

**Verdict: PASS**

---

### Check 4 — R144 compatibility invariants remain proven

**Question:** Does C1 independently re-prove all R144 compatibility invariants,
or does it merely assert them by reference?

**Evidence:**

The proof runner independently re-derives selected-fragment values from R144
presence data using the `selected_fragment` method, then asserts parity against
`current_selected_fragment` for all 23 contracts. The selection logic:

```ruby
def selected_fragment(presence)
  return "oof"       if presence.include?("oof")
  return "temporal"  if presence.include?("temporal")
  return "escape"    if presence.include?("escape")
  return "escape"    if presence.include?("stream")
  return "epistemic" if presence.include?("epistemic")
  "core"
end
```

This is a live re-derivation, not a copy of R144 results.

Required compatibility cases verified from `helper_result_shape.json`:

| Case | Contracts | Result |
| --- | --- | --- |
| Stream present (no OOF) | `StreamFoldCore`, `StreamIngressEscape` | Both: presence=[core,escape,stream], selected=escape PASS |
| Epistemic + escape (no OOF) | `Risk.Scoring.ScoreInteraction` | presence=[core,epistemic,escape], selected=escape PASS |
| Epistemic-only | `Risk.Scoring.PureEpistemicScore` | presence=[core,epistemic], selected=epistemic PASS |
| Temporal + escape | `ObservedTemporalPrecedence.ReadHistory` | presence=[core,escape,temporal], selected=temporal PASS |
| OOF (all 7 cases) | `NegativeConfidence`, `NegativeAlert`, `StreamDirectUse`, `StreamMissingWindow`, `BadUnresolvedSymbol`, `OofM1.BrokenPure`, `BadAssumptionUse` | All: oof in presence, selected=oof PASS |
| Guarded non-fragments | olap, progression | classification_kind=not_fragment_class, selected_fragment=null PASS |

`selected_fragment_projection.mismatches: []` — zero mismatches across 23 contracts.

Source R144 matrix digest cited: `65e876f5ae23ce761c16b704` — matches the
digest recorded in LANG-R144-P1's proof summary. Chain is unbroken.

**Verdict: PASS**

---

### Check 5 — Full classifier regression ran for non-wired helper

**Question:** Did C1 run classifier regression even though no helper was wired,
satisfying the NB-3 requirement from S3-R145-C3-X?

**C4-A required commands and C1 results:**

| Command | Required | Result |
| --- | --- | --- |
| proof runner | PASS | PASS |
| `classifier_pass_proof.rb` | PASS | PASS |
| `contract_modifiers_proof.rb` | PASS | PASS |
| `source_to_semanticir_fixture.rb --check-golden` | PASS | PASS |
| `igapp_assembler_proof.rb` | PASS | PASS |
| `ruby -c` syntax check | not required | Syntax OK |

All 5 required commands PASS. C1 also added a syntax check beyond requirements.

The classifier regression confirms no load-path side effect, shared state, or
accidental require change affected live classifier behavior — satisfying the
NB-3 pre-condition from the S3-R145-C3-X pressure review.

**Verdict: PASS**

---

### Check 6 — SemanticIR/report/`.igapp` commands prove no unintended artifact drift

**Question:** Do the `source_to_semanticir_fixture --check-golden` and
`igapp_assembler_proof` results confirm no SemanticIR, CompilationReport, or
`.igapp` mutation?

**Evidence:**

`source_to_semanticir_fixture.rb --check-golden` PASS — SemanticIR goldens
unchanged; this command fails on any golden delta.

`igapp_assembler_proof.rb` PASS — `.igapp` artifact content and manifest
unchanged.

Closed surface assertions confirm:
```json
"semanticir_changed": false,
"report_changed": false,
"igapp_changed": false,
"assembler_changed": false
```

Since these are hardcoded declarations (the runner cannot write to these paths),
the golden check commands are the behavioral evidence. Both commands PASS,
providing independent confirmation that no drift occurred.

**Verdict: PASS**

---

### Check 7 — All forbidden surfaces remain closed

**Question:** Are public API/CLI, loader/report, CompatibilityReport, runtime,
Spark, production, Ledger/TBackend, cache, signing, and deployment surfaces
explicitly closed in the proof record?

**Evidence:**

Summary `closed_surface_assertions` — 13 keys, all `false`:

```json
"lib_helper_file_created": false,
"root_require_changed": false,
"classifier_wiring": false,
"parser_changed": false,
"typechecker_changed": false,
"semanticir_changed": false,
"assembler_changed": false,
"report_changed": false,
"igapp_changed": false,
"public_api_cli_changed": false,
"runtime_changed": false,
"spark_changed": false,
"production_changed": false
```

Summary also carries: `"implementation_authorized": false`.

The Spark surface scan confirms no `fragment_registry_compatibility_adapter`
or `declaration_fragment_presence` vocabulary appears in
`sparkcrm_bihistory_fixture.rb`.

C1's closed-surfaces section explicitly names CompatibilityReport, loader/
report, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP
executors, cache, signing, and deployment as prohibited surfaces, consistent
with the C4-A gate.

**Verdict: PASS**

---

## Non-Blocking Notes

**NB-1 — Hardcoded closed_surface_assertions:**

The `closed_surface_assertions` dictionary in both the result shape and
summary is hardcoded as a static `closed_surface_assertions` Ruby method
returning a literal hash of `false` values. This is appropriate for this
proof-only track — the runner's write path is structurally scoped to
`experiments/.../out/`, making it impossible for the runner to set
`lib_helper_file_created: true` even if it wanted to.

However, any future implementation card that does write a `lib/` helper file
should compute `lib_helper_file_created` dynamically from a filesystem check
(e.g., `File.exist?(HELPER_PATH)`) rather than hardcoding `false`. A
hardcoded `false` on an implementation card that intentionally creates the
helper file would be a misleading assertion.

This note is for the implementation authorization card, not a concern about C1.

**NB-2 — `assumptions_proof` absent from regression matrix:**

The C4-A required command matrix does not include `assumptions_proof`, and C1
satisfies all 5 required commands. The epistemic compatibility cases are
adequately covered by the proof runner's own `epistemic_escape_presence_selects_escape`
and `epistemic_only_selects_epistemic` checks, which re-derive from R144
presence data.

However, `assumptions_proof` remains the living golden anchor for epistemic
classifier behavior (`assumption_basic.classified.json`). Any future
implementation card that writes a `lib/` helper file should add
`assumptions_proof` to its required regression matrix, since it is a direct
golden anchor for the most sensitive compatibility case (epistemic + escape
stays escape).

This note is for the implementation authorization card, not a concern about C1.

---

## Verdict

```text
proceed
```

7/7 scope checks PASS. No blockers. Two non-blocking notes for the
implementation authorization card only:

- NB-1: Hardcoded `closed_surface_assertions` should become dynamic
  filesystem checks in any implementation card that writes a lib file.
- NB-2: `assumptions_proof` should be added to the regression matrix in
  the implementation authorization card.

---

## Implementation-Authorization Blockers

The following must all be satisfied before a
`lib/igniter_lang/fragment_registry_compatibility_adapter.rb` implementation
card may open. These carry forward from C1's blockers section and the prior
S3-R145-C3-X review, now updated to reflect that the proof-only helper
boundary proof (C1) is complete.

**Unresolved (8 required decisions for the implementation card):**

1. **Architect gate** — Must open a specific implementation authorization card
   with exact write scope. The proof-only helper boundary is now complete, but
   the `lib/` file remains unauthorized.

2. **Direct-require-only confirmation** — The gate must state the helper is
   `require`-able only by explicit caller, never root-required from
   `lib/igniter_lang.rb`.

3. **Classifier wiring forbidden for first slice** — Must be restated as an
   explicit prohibition in the implementation card scope. A separate later gate
   is required to open classifier wiring.

4. **Helper output is internal-only** — Must confirm that helper result fields
   (`declaration_fragment_presence`, `selected_fragment_projection`) remain
   purely internal and do not become `ClassifiedProgram` fields or appear in
   reports, CLI output, or public result.

5. **Byte-for-byte classifier parity proof** — The implementation card must
   specify the exact golden-match assertion count expected from
   `classifier_pass_proof`, `contract_modifiers_proof`, and `assumptions_proof`
   after the lib file is introduced. "PASS" without count is insufficient for a
   card that writes to `lib/`.

6. **Full regression matrix pinned** — Implementation card must name all
   required commands including: `classifier_pass_proof`,
   `contract_modifiers_proof`, `assumptions_proof`, `source_to_semanticir_fixture
   --check-golden`, `igapp_assembler_proof`, TypeChecker proof (if applicable),
   and `invariant_severity_proof` (to confirm PINV/TINV support metadata is
   unaffected).

7. **Broad negative vocabulary scan** — The spot-scans in C1 covered 7
   specific files. The implementation card must scan all `lib/igniter_lang/*.rb`
   files for `declaration_fragment_presence` to ensure the new lib file does
   not leak into any pipeline pass via a side-channel require or shared module.

8. **PROP-036 and PROP-038 non-mutation restated** — Must be explicit in the
   implementation card; cannot be inferred from prior chain.

**Already resolved by C1 (may be cited as evidence):**

- Proof-only helper input/result shape defined and machine-proved:
  `helper_input_digest: 47e938fdea0e46e067a2c88b`,
  `helper_result_digest: ae26685d3afd77a2e2cc35c5`.
- R144 compatibility invariants re-proved: 23/23 contracts PASS.
- Classifier regression PASS even for unwired helper (NB-3 from R145-C3-X).
- SemanticIR/report/`.igapp` baselines confirmed unchanged.
- Negative scans for 7 key lib/experiment paths: all PASS.

---

[Agree]
- C1 correctly models the helper boundary as proof-only data artifacts
  without creating a `lib/` file. The distinction between modeling the API
  shape and implementing it is cleanly maintained.
- The proof runner independently re-derives selected-fragment values rather
  than copying R144 output, making the compatibility invariant proof
  behavioral, not referential.
- The scan vocabulary is explicit in the runner source code, removing the
  ambiguity noted as potential NB-1 in the S3-R145-C3-X review.
- Full classifier regression satisfies S3-R145-C3-X NB-3 exactly.

[Challenge]
- None. C1 delivers cleanly within the C4-A gate boundary.

[Missing]
- NB-1: Dynamic `lib_helper_file_created` assertion for future implementation
  card.
- NB-2: `assumptions_proof` in future regression matrix.
- Neither is a C1 gap; both belong in the implementation authorization card.

[Sharper Question]
- The implementation authorization card must resolve whether the helper
  result shape exposed by `helper_result_shape.json` is the exact API
  surface to be implemented, or whether the implementation card may refine
  field names and shape. If refinement is allowed, the implementation card
  needs a delta-from-C1 review step before code is written.

[Route]
- implementation-authorization-review after the 8 blockers above are
  addressed

# oof-fragment-registry-shadow-proof-pressure-v0

Card: S3-R92-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Track: oof-fragment-registry-shadow-proof-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/org/tracks/oof-fragment-registry-shadow-proof-boundary-v0.md` (C0-O)
- `igniter-lang/docs/tracks/oof-fragment-registry-shadow-proof-v0.md` (C1-P1)
- `igniter-lang/docs/tracks/oof-fragment-registry-semantics-review-v0.md` (C2-P1)
- `igniter-lang/docs/gates/compiler-pack-boundary-report-decision-v0.md` (R90-C4-A)
- `igniter-lang/docs/tracks/compiler-pack-shadow-profile-proof-v1.md` (LANG-R91)
- `igniter-lang/docs/reports/lang-r91-compiler-pack-shadow-profile-proof-v1.md`
- `igniter-lang/docs/cards/S3/S3-R92.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json`
- `igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`

---

## Scope Checks

### 1. Registry output is proof-local data only

C0-O authorized C1 to write only:

```text
igniter-lang/docs/tracks/oof-fragment-registry-shadow-proof-v0.md
igniter-lang/experiments/oof_fragment_registry_shadow_proof/
```

C1 writes exactly three output files under `experiments/oof_fragment_registry_shadow_proof/out/`:

```text
oof_fragment_registry_shadow_proof_summary.json
oof_descriptors.shadow_registry.json
fragment_registry.shadow_registry.json
```

These are all under the authorized `experiments/oof_fragment_registry_shadow_proof/` directory. C0-O states "registry data may be modeled in docs and/or proof-local experiment outputs only" — the additional registry JSON outputs are proof-local data under that umbrella. No lib/, spec/, gate, proposal, or production file is created or modified.

The summary JSON's `closed_surfaces` block confirms this independently:

```json
"compiler_code_changed": false,
"specs_or_proposals_changed": false,
"registry_implementation_authorized": false
```

The proof script syntax is verified (`ruby -c` → `Syntax OK`). The proof reads the R91 summary JSON as evidence and generates registry data; it does not mutate any live compiler or test surface.

**Result: PASS**

---

### 2. No live `OOFRegistry` / `FragmentRegistry` implementation is created

C0-O's closed-surface list explicitly includes:

```text
OOF registry implementation
FragmentRegistry implementation
pack registry implementation
```

Verifying against C1 and the summary JSON:

- `registry_implementation_authorized: false` in summary.
- `implementation_authorized: false` in summary.
- `compiler_code_changed: false` in summary.
- C1 track closed-surface list repeats "registry implementation" and "live pack dispatch."
- `lib/igniter_lang/` directory was not touched — only `experiments/` and `docs/tracks/` paths appear in C1's written deliverables.
- The proof script is a read-only data generator; it produces frozen JSON blobs under `out/`. It does not define a module, class, or require path under `lib/`.

The `fragment_registry.shadow_registry.json` carries:

```json
"non_authority": {
  "fragment_registry_implementation_authorized": false,
  "compiler_classification_change_authorized": false,
  "assembler_summary_change_authorized": false
}
```

This machine-asserts the non-implementation stance at the output level, not just in prose.

**Result: PASS**

---

### 3. No parser/classifier/TypeChecker/SemanticIR/assembler behavior changes implied

C0-O's closed-surface list explicitly names:

```text
parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites
public OOF code renaming or diagnostic wording changes
```

C1 track closed-surface section repeats "parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites" and "diagnostic renames, deletions, or public wording changes." The proof produces data only.

Checking the proof's 18 checks:

- None assert a change to a parser rule, classifier decision, typechecker path, SemanticIR structure, assembler fragment summary, or public diagnostic wording.
- `descriptor.codes_unique` and `descriptor.current_codes_have_owner_stage_stability` confirm that existing codes are covered in their current form — they are not renamed or removed.
- `descriptor.profile_contract_diagnostics_excluded` confirms the separation boundary.
- `fragment.candidate_precedence_deterministic_non_canon` confirms precedence is modeled as data, not as a behavior change.

The C2 semantics review explicitly states: "The shadow proof may model OOF descriptors and fragment registry entries, but it must not change live compiler classification, public OOF codes, SemanticIR, CompilationReport, `.igapp`, public API/CLI, loader/report, CompatibilityReport, runtime, or production behavior."

No behavior change is implied or authorized by C1, C2, or the summary JSON.

**Result: PASS**

---

### 4. Public OOF code stability is preserved

C0-O's proof contract requires that the proof:

- does not rename live OOF codes;
- does not delete live OOF codes;
- does not change public diagnostic wording;
- does not change parser/classifier/typechecker behavior;
- does not update specs as if the model were canon.

C1's alias/deprecation section states its v0 policy explicitly:

> current codes are not renamed or deleted; aliases remain explicit descriptors with
> `replacement_code`; candidate/proof-only codes are marked `candidate` and cannot be
> treated as public blocking OOF codes by this proof.

The alias model used is additive-only: `OOF-TM1..TM6` are compatibility alias descriptors that point to `OOF-H1` / `OOF-BT*` as canonical replacements. No current live code is deleted or overwritten.

The proof table covers 63 descriptor entries. All entries marked `stable_current` retain their current status. Candidate or proof-only codes are explicitly marked `candidate_proof_only` or `proof_only` and the summary check `descriptor.current_codes_have_owner_stage_stability` PASS confirms that every current-status descriptor has owner, stage, and stability assigned.

No spec file, proposal, or public diagnostic vocabulary was edited.

**Result: PASS**

---

### 5. Profile-contract diagnostics are not absorbed into OOF

C0-O's proof contract requires:

```text
profile-contract diagnostics are explicitly excluded from OOF namespace;
runtime/proof-only helper diagnostics are not promoted into language OOFs.
```

C1 explicitly excludes:

| Namespace | Classification | Reason |
| --- | --- | --- |
| `compiler_profile_contract.*` | excluded from OOF | Nested report-only validator diagnostics. |
| `compiler_profile_contract_refusal.*` | excluded from OOF | Internal strict-terminal wrapper diagnostics. |
| `OOF-RUNTIME-SMOKE` | excluded runtime helper | Must not seed the language OOF registry. |

The summary JSON check `descriptor.profile_contract_diagnostics_excluded` PASS and the separate check `descriptor.runtime_smoke_helper_excluded` PASS both confirm this machine-verified exclusion.

C2's review verdict on this point:

> `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*` diagnostics
> are not OOF codes. Neither namespace should be included in
> `strict_registries.oof_descriptors`. Neither namespace should be appended to
> top-level `report["diagnostics"]` without a separate decision.

C1 and C2 are fully aligned. The separation is both prose-stated and machine-asserted.

**Result: PASS**

---

### 6. Fragment precedence remains candidate, not canon

C0-O's proof contract states:

```text
Any precedence result must be marked:
  candidate / proof-local / non-canon
It must not be used to alter current compiler classification or assembler
fragment summaries.
```

The summary JSON carries:

```json
"candidate_precedence_high_to_low": ["oof","temporal","stream","epistemic","escape","core"]
```

The fragment registry JSON carries `"precedence_status": "proof_local_non_canon"` and every fragment row has `"canonical_status": "non_canon_candidate"`.

The summary check `fragment.candidate_precedence_deterministic_non_canon` PASS confirms this.

C1 track doc explicitly states:

> This differs from some historical/current implementation orderings in small ways and is
> intentionally not used to change classifier or assembler behavior.

No classifier rule, assembler summary logic, or spec section was changed.

The non-canon labeling is both prose-stated (in track doc and handoff), machine-asserted (in two JSON outputs), and verified by the proof check.

**Result: PASS**

---

### 7. `.igapp`, loader/report, CompatibilityReport, runtime, production, and Spark fixture/spec work remain closed

Checking each forbidden surface against the summary JSON `closed_surfaces` block:

```json
"igapp_or_golden_mutation_authorized": false,
"loader_report_or_compatibility_report_authorized": false,
"runtime_or_production_authorized": false,
"spark_fixture_or_production_authorized": false
```

All four surface families machine-assert closed. In addition:

```json
"public_api_cli_widening_authorized": false,
"dispatch_authorized": false
```

C1's closed-surface section explicitly names every forbidden surface from the C0-O closed-surface list, including "runtime, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production executor, production cache, signing, or production behavior" and "Spark fixture/spec work or Spark production integration."

C2's closed-surface list is equally explicit and comprehensive.

Neither C1, C2, nor the summary JSON introduces any wording implying that the shadow registry data is a loader/report or CompatibilityReport source, a runtime dispatch table, or a Spark fixture schema.

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: C1 candidate precedence has `epistemic > escape`; C2 recommends `escape > epistemic`

C1's fragment registry models:

```text
oof > temporal > stream > epistemic (70) > escape (60) > core
```

C2's semantics review explicitly recommends:

```text
oof > temporal > stream > escape > epistemic > core
```

C2's reasoning: PROP-032 specifies that a contract with both escape and epistemic declarations yields an escape-level contract. Placing `escape > epistemic` preserves that accepted interaction without modification.

C0-O's example precedence also shows `escape > epistemic`.

Since both orderings are labeled `non-canon / proof-local`, this discrepancy does not block acceptance of the shadow proof. However, C4-A should choose a single reference candidate ordering before this data is referenced in any future proof or design card, so that future authors do not have two conflicting non-canon precedences in the record.

C2's `escape > epistemic` ordering is better-grounded in the accepted PROP-032 evidence and should be preferred as the reference candidate.

---

### NB-2: `oof_as_both` recommendation vs. C2's `status-primary / fragment-projection-secondary` framing

C1 recommends `oof_as_both` as the shadow model. C2 recommends `status-primary, fragment-projection-secondary` — conceptually the same intent expressed with stricter vocabulary. The summary JSON's `oof_recommendation: "model_oof_as_both_for_shadow_only"` and `fragment_registry.shadow_registry.json`'s `classification_kind: "status_fragment_both_candidate"` are consistent with C2's framing but use slightly different language.

This is a vocabulary alignment gap, not a correctness issue. The key invariant — that `oof` may appear in fragment registry data but must not imply a loadable capability — is stated explicitly in both tracks. C4-A should confirm that C2's `status-primary` language is binding for any future canon decision, with C1's `oof_as_both` as the proof-local modeling vehicle only.

Not a blocker. No change to C1 or C2 is required for acceptance.

---

### NB-3: Additional output files not named individually in C0-O's write-scope list

C0-O's `Exact C1 Allowed Write Scope` lists:

```text
igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json
```

C1 also produces:

```text
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json
```

C0-O's prose scope section states: "registry data may be modeled in docs and/or proof-local experiment outputs only," and the boundary doc names the whole `experiments/oof_fragment_registry_shadow_proof/` directory as the allowed location. The additional JSON files are within that directory and contain proof-local data only (no live registry implementation, no production data). This is within boundary.

Not a blocker. C4-A may optionally acknowledge that the additional registry JSON outputs are within scope when accepting the proof.

---

## Summary

| Check | Result |
| --- | --- |
| 1. Registry output is proof-local data only | PASS |
| 2. No live `OOFRegistry` / `FragmentRegistry` implementation created | PASS |
| 3. No parser/classifier/TypeChecker/SemanticIR/assembler behavior changes implied | PASS |
| 4. Public OOF code stability preserved | PASS |
| 5. Profile-contract diagnostics not absorbed into OOF | PASS |
| 6. Fragment precedence remains candidate, not canon | PASS |
| 7. `.igapp`, loader/report, CompatibilityReport, runtime, production, Spark remain closed | PASS |

```text
checks: 7/7
blockers: 0
non-blocking notes: 3
  NB-1: C1 uses epistemic > escape; C2 and C0-O recommend escape > epistemic
        — C4-A should pick one reference candidate ordering
  NB-2: oof_as_both vs. status-primary/fragment-projection-secondary vocabulary
        — consistent intent, C4-A should confirm status-primary is binding for canon decisions
  NB-3: Two additional output JSONs not individually named in C0-O write-scope list
        — within authorized directory, no blocker
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 3
```

---

## Recommendation For C4-A

The OOF/Fragment registry shadow proof (C1) and semantics review (C2) are
well-formed, grounded in LANG-R91 evidence, and satisfy the C0-O acceptance bar:

- proof-local data only ✓
- no live registry or dispatch implementation ✓
- public OOF codes and diagnostics unchanged ✓
- profile-contract diagnostics excluded from OOF ✓
- fragment precedence deterministic and non-canon ✓
- all closed surfaces preserved ✓

Recommend C4-A:

1. **Accept** the OOF/Fragment registry shadow proof as proof-only data with no
   implementation authority.

2. **Resolve NB-1** by choosing `escape > epistemic` as the reference candidate
   precedence ordering going forward:
   - C2's reasoning (PROP-032 escape+epistemic → escape-level) is better-grounded
     than C1's implicit ordering.
   - C0-O's example also shows `escape > epistemic`.
   - The choice should be marked non-canon until a later Architect decision.
   - No retroactive edit to C1 is required; the resolution belongs in the C4-A
     decision record.

3. **Confirm NB-2** by noting that `status-primary / fragment-projection-secondary`
   (C2's framing) is the binding semantic intent for any future canon decision, and
   that `oof_as_both` is the proof-local modeling vehicle only.

4. **Acknowledge NB-3** briefly: the additional registry JSON outputs
   (`oof_descriptors.shadow_registry.json`, `fragment_registry.shadow_registry.json`)
   are within the C0-O authorized directory and are accepted as proof-local data.

5. **Route the next bounded proof or design slice** per C1/C2 recommendations:
   - C1 and C2 both recommend no immediate follow-up implementation.
   - The remaining blockers before any registry implementation include: canon
     `oof` semantics decision, registry ownership decision (kernel service vs.
     installed pack vs. support metadata), public-code stability policy for
     candidate codes, and `PINV-*` / `TINV-*` descriptor vs. marker decision.
   - The most natural next route is either:
     - a design-only card to decide registry ownership and `oof` canon semantics; or
     - the backup route `prop038-strict-terminal-regression-hardening-v0` if
       strict-terminal evidence hardening is the team's current priority.

6. **Preserve all blocked surfaces** as listed in R90-C4-A, C0-O, C1, and C2
   without exception.

No implementation is authorized by this review.

# PROP-038 Strict-Mode / Refusal Trigger Design Pressure v0

Card: S3-R76-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-strict-mode-refusal-trigger-design-pressure-v0

Question:
Does the strict-mode/refusal trigger design (C1-P1) correctly separate trigger
vocabulary from existing diagnostics without enabling compile refusal? Does the
current compiler surface survey (C2-P1) accurately map the refusal boundary and
make explicit what must not be inferred as strict mode from current plumbing?

Context:
- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md`
- `docs/tracks/prop038-contract-digest-strict-mode-refusal-trigger-design-v0.md`
- `docs/tracks/prop038-strict-mode-current-compiler-surface-survey-v0.md`
- `docs/tracks/stage3-round75-status-curation-v0.md`

---

## Inputs Read

- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md` (R75-C3-A)
- `docs/tracks/prop038-contract-digest-strict-mode-refusal-trigger-design-v0.md` (S3-R76-C1-P1)
- `docs/tracks/prop038-strict-mode-current-compiler-surface-survey-v0.md` (S3-R76-C2-P1)
- `docs/tracks/stage3-round75-status-curation-v0.md` (S3-R75-C4-S)

---

## Scope Checks

### Check 1: Compile refusal remains closed in both cards

C1-P1 surfaces still closed section explicitly lists:

```text
live compiler/orchestrator refusal
public API strict mode
CLI strict mode
manifest/profile policy strict mode
CompilerResult fields
refusal reports, persisted reports, or sidecars
loader/report or CompatibilityReport status
runtime or production readiness
```

C1-P1 non-authorization preserved section explicitly states no code
implementation, no proof-local refusal experiment, no enabling compile refusal,
no compiler/orchestrator behavior changes.

The proof-local decision vocabulary deliberately stops at `would_refuse` and does
not introduce `refused` until a future implementation gate authorizes it.

The proof-local strict requirement shape keeps `compile_refusal_authorized: false`
hard-coded as a design signal.

C2-P1 confirms the current refusal boundary is pass_result-based and that the
report-only contract validation does not change `pass_result`.

**Pass.** Compile refusal is closed in both cards.

---

### Check 2: Trigger/source options are explicit and not inferred from provider presence

C1-P1 source option table enumerates 5 options with explicit recommendation:
gate-controlled proof-local source only. The table assigns first-fit, public-
surface risk, and recommendation columns for each. The recommended option
explicitly avoids widening API/CLI.

C2-P1 Must Not Infer Strict Mode From list includes `presence of
compiler_profile_contract_provider` and `presence of
compiler_profile_contract_validation` as the first two items.

The C2-P1 short rule `compiler_profile_contract.* diagnostic != compiler compile
refusal` maps exactly to the R75-C3-A accepted core rule.

**Pass.** Strict mode cannot be inferred from provider presence, and the option
table makes the first recommended source explicit.

---

### Check 3: Trigger vocabulary separates validator diagnostics from compiler refusal decisions

C1-P1 proposes 7 vocabulary items in a table. Each is explicitly assigned to a
layer:

| Item | Layer |
| --- | --- |
| `report_only` | Compiler report mode (current behavior) |
| `strict_validation_requested` | Future trigger input |
| `strict_validation_source` | Future trigger input |
| `refusal_candidate_diagnostic` | Validator evidence |
| `compiler_refusal_decision` | Compiler-level decision |
| `loader_report_status` | Loader/report layer (separate) |
| `runtime_readiness` | Runtime layer (separate) |

Validator diagnostics remain evidence, not decisions. The `compiler_refusal_decision`
vocabulary (`not_evaluated`, `allow`, `would_refuse`, `configuration_error`) is
explicitly kept distinct from any `compiler_profile_contract.*` diagnostic code.

C1-P1 also explicitly blocks reuse of loader/report names such as
`missing_required`, `present_verified`, and `runtime_ready` from the proof-local
model.

**Pass.** Vocabulary is layered and non-colliding.

---

### Check 4: Report-only behavior is preserved as current live behavior

C1-P1 mode separation matrix table lists all four current report-only cases:

- report-only + valid contract: compile/result behavior unchanged
- report-only + digest mismatch: compile/result behavior unchanged; nested diagnostic only
- report-only + digest invalid: compile/result behavior unchanged; nested diagnostic only
- report-only + recompute unavailable: compile/result behavior unchanged; nested diagnostic only

These match the R75-C3-A accepted live behavior table exactly.

C2-P1 confirms the refusal boundary `return refusal(...) unless report["pass_result"] == "ok"` is the current gate and that the report-only contract validation is attached before this line but does not change `pass_result`.

The C1-P1 boundary guard assertions include: top-level `report["diagnostics"]` remains unchanged in report-only mode; public result remains unchanged in report-only mode.

**Pass.** Report-only behavior is correctly preserved and machine-asserted as required before any strict proof-local model.

---

### Check 5: User-facing wording does not imply runtime, loader/report, or production readiness

C1-P1 wording matrix lists explicit constraints:

- do not promise runtime readiness
- do not imply loader/report acceptance
- do not say `.igapp` output is verified
- do not expose private canonicalization helper names
- include the evidence diagnostic code in structured proof/API output
- reserve human prose for UX, not for authority

Each of the six wording contexts (API, CLI, proof, report-only, fail-open,
fail-closed) is bounded to the compiler refusal decision; none imply loader
interpretation, runtime execution readiness, or production deployment.

**Pass.** Wording constraints are explicit and correctly scoped.

---

### Check 6: `contract_digest_mismatch` is not accidentally promoted to current compile-refusal behavior

Both cards cite the R75-C3-A accepted status for `contract_digest_mismatch`:
"Strongest conditional future refusal candidate, but not enabled."

C1-P1 uses `contract_digest_mismatch` only as the first `refusal_candidate` in
the proof-local strict requirement shape (`compile_refusal_authorized: false`)
and as evidence for the wrapper code
`compiler_profile_contract_refusal.contract_digest_mismatch`. These are design
vocabulary only, not `IgniterLang::Diagnostics`.

C2-P1 explicitly includes `contract_digest_mismatch` in the Must Not Infer
Strict Mode list.

The R75-C3-A gate requires "successful recomputation" and "stable mismatch proof"
as conditions before `contract_digest_mismatch` can be considered. Those
conditions are not met by design cards alone; they require proof authorization.

**Pass.** `contract_digest_mismatch` remains a conditional future candidate and
is not promoted in either card.

---

### Check 7: `contract_digest_recompute_unavailable` has explicit fail-open stance

C1-P1 fail-open/fail-closed policy table explicitly recommends:

```text
contract_digest_recompute_unavailable => fail_open_report_only
```

Reason given: R75 held this diagnostic by default; current report-only behavior
is proven stable; mismatch is the stronger first refusal candidate; fail-closed
needs user recovery and operational support that do not exist yet.

The fail-closed and dual-policy options are deferred explicitly. The fail-closed
wording example is framed as "Only if fail-closed policy is accepted later."

The proof-local strict requirement shape uses `"recompute_unavailable_policy": "fail_open_report_only"`.

**Pass.** Fail-open is explicitly recommended and fail-closed is deferred without
ambiguity.

---

### Check 8: Nil, non-Hash, provider-error, and validator-error paths stay legacy/no-refusal

C1-P1 legacy path shielding table covers all five cases:

| Case | Expected |
| --- | --- |
| no provider | Legacy compile behavior; no refusal trigger |
| nil provider | Legacy compile behavior; no validation field; no refusal trigger |
| non-Hash provider | Legacy compile behavior; no validation field; no refusal trigger |
| provider error | Legacy compile behavior; no validation field; no refusal trigger |
| validator error | Legacy compile behavior unless fail-closed validator-error policy authorized |

C2-P1 no-field/no-refusal paths table covers the same 6 paths (5 provider/validator
paths + pre-validation compile failure) with explicit "intentionally fail-open"
language.

The validator error row in C1-P1 correctly qualifies that fail-closed for
validator error requires separate authorization — consistent with R75-C3-A holding
`contract_digest_recompute_unavailable` by default.

**Pass.** Legacy paths are shielded in both cards consistently.

---

### Check 9: No forbidden surfaces are implied by the design

C1-P1 non-authorization preserved section explicitly lists all surfaces closed:
code implementation, proof-local refusal experiment, compile refusal, compiler/
orchestrator changes, public API/CLI widening, `CompilerResult` changes, persisted
reports/sidecars, parser/TypeChecker/SemanticIR/assembler/`.igapp`, loader/report,
CompatibilityReport, `IgniterLang::Diagnostics` centralization, RuntimeMachine,
Gate 3 widening, Ledger/TBackend, BiHistory, stream/OLAP, cache, production behavior.

C2-P1 eight future write-scope candidates are presented as "non-authority
observations only" with explicit "Not implementation authorization" caveat. Each
candidate entry includes a "Current caution" column with reasons the surface must
not change without explicit authorization.

The C2-P1 risks section names five mixing risks that could cause unintended
surface widening: confusing invalidity with refusal, assuming provider presence
means strict requirement, using `compile_refusal_authorized=false` as a switch,
leaking report-only details into CLI/API, and mixing PROP-036 transport with
PROP-038 strictness.

C1-P1 also explicitly blocks reuse of `compiler_profile_source` CLI transport
as a strict mode source — directly consistent with C2-P1 risk 5 and the C2-P1
Must Not Infer list entry for `CLI --compiler-profile-source`.

**Pass.** No forbidden surfaces are implied. Non-authorization is comprehensive
and consistent between both cards.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 2
```

---

## Non-Blocking Notes

### NB-1: Open blocker list in C1-P1 and R75-C3-A do not fully align

R75-C3-A names the following blockers before refusal implementation:

1. Accepted strict profile/contract requirement source
2. Compiler/orchestrator refusal status design
3. User-facing diagnostic wording design
4. Accepted fail-open/fail-closed policy for `recompute_unavailable`
5. Proof-local strict-mode refusal matrix
6. Authorization to change compiler/orchestrator behavior
7. Authorization to change public API/CLI behavior
8. Authorization to change `CompilerResult`
9. Authorization to write refusal reports or persisted sidecars

C1-P1 open blockers table contains 8 entries. Items 2, 3, 4, 5 from R75-C3-A
are addressed as design output of C1-P1, and C1-P1 correctly marks them as
"addressed by this track." However, C1-P1 marks "Accepted strict source for
production/compiler implementation" as still open, correctly noting that only a
proof-local source recommendation is made — not a production/compiler
implementation source.

The alignment is correct in substance. The R75-C3-A items 1 and 6–9 remain
closed/open as before. C4-A should confirm whether the C1-P1 design output
satisfies R75-C3-A blocker 2 ("Compiler/orchestrator refusal status design")
enough to authorize the proof-local experiment, or whether that blocker formally
requires a separate Architect gate closure record.

This is documentation disambiguation only. No implementation decision is implied.

### NB-2: C2-P1 questions for C3-X/C4-A are advice questions, not blockers

C2-P1 poses 7 open questions. These are non-blocking research questions suitable
for the proof-local design gate. C4-A should acknowledge the questions but does
not need to resolve all of them before accepting the design tracks. Specifically:

- Q1 (strict source) is answered by C1-P1: gate-controlled proof-local source first
- Q2 (provider absence = strict failure) is answered by C1-P1: no, absence stays legacy/no-refusal
- Q3 (wrapper diagnostic) is answered by C1-P1: yes, `compiler_profile_contract_refusal.*` wrapper namespace
- Q4 (recompute unavailable) is answered by C1-P1: fail-open/report-only first
- Q5 (strict diagnostics in public result) is partially answered: not in current report-only integration; public surface decision deferred

Q6 and Q7 are correctly held open pending future gate authorization. C4-A should
note that Q6 (assembly boundary behavior under strict mode) and Q7 (CLI strict
behavior) remain open and must not be inferred from C1-P1 or C2-P1 as answered.

---

## Summary

Both design tracks maintain the R75-C3-A accepted invariants exactly. Compile
refusal is held. The five vocabulary layers (contract-object invalidity,
report-only diagnostics, compiler refusal, loader/report, runtime readiness) are
kept distinct. The proof-local trigger design is bounded to a gate-controlled
source and uses `would_refuse` vocabulary that does not claim live refusal
behavior. The compiler surface survey is read-only and presents a complete and
accurate map of where refusal could be designed without inferring it from existing
plumbing. All legacy/fail-open paths are shielded in both cards consistently.

The only open items are documentation cross-referencing questions for C4-A (NB-1)
and confirmation that two C2-P1 questions remain open (NB-2). Neither blocks
acceptance of the design tracks.

---

## [Agree]

- Strict mode cannot be inferred from provider presence, existing diagnostics, or
  any current report-only plumbing. This is correctly bounded in both cards.
- `compiler_profile_contract_refusal.*` as a wrapper namespace above
  `compiler_profile_contract.*` is the correct architecture for separating
  validator evidence from compiler decisions.
- Gate-controlled proof-local strict requirement object is the correct first
  source option; it avoids widening API/CLI/manifest surfaces prematurely.
- `contract_digest_recompute_unavailable => fail_open_report_only` is the correct
  conservative first policy and is correctly justified.
- `would_refuse` as the maximum proof-local decision vocabulary is correct;
  `refused` must wait for an implementation gate.
- The `report_for_assembly = report` capture before annotation correctly isolates
  `.igapp` from any future strict-mode design, and C2-P1 correctly maps this
  as an explicit assembly boundary.
- `CompilerResult.public_result` stripping `report` correctly keeps report-only
  validation out of CLI output; this is accurately described in C2-P1.

## [Challenge]

None. Both cards stay design-only, the vocabulary layering is consistent with
R75-C3-A, and no surface boundaries are crossed.

## [Missing]

- The mapping between C1-P1 open blockers and the R75-C3-A blocker list is
  correct in substance but C4-A should provide explicit alignment to confirm
  which R75-C3-A blockers are addressed by C1-P1 design output and which remain
  pending separate gate records (NB-1).
- C2-P1 Q6 (assembly boundary under strict mode) and Q7 (CLI strict behavior)
  are correctly held open but should be explicitly acknowledged in C4-A as
  requiring future decisions, not silently deferred.

## [Sharper Question]

Does C4-A accept C1-P1 as closing R75-C3-A blockers 2–5 in design (trigger
vocabulary, wording, fail-open/fail-closed, proof matrix), such that a proof-
local strict-mode trigger experiment becomes the only remaining open blocker for
any proof-local refusal model?

## [Route]

```text
track: proof-local strict-mode trigger experiment
```

Only if C4-A explicitly accepts C1-P1 and C2-P1 and authorizes a bounded proof-
local strict-mode trigger experiment. Experiment scope: proof-local gate object
only; no compiler/orchestrator behavior changes; no public API/CLI/CompilerResult/
`.igapp`/loader/CompatibilityReport/RuntimeMachine/Gate 3/production changes.

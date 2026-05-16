# Discussion: Compiler Profile Obligation Coverage Proof Pressure v0

Card: S3-R56-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-obligation-coverage-proof-pressure-v0

Depends on: S3-R56-C1-P1 delivered

Question:

Are the obligation coverage statuses genuinely report-only? Does `missing_slot`
avoid becoming a compile refusal? Is surface detection evidence-based against
real fixtures? Does the slot mapping match the C4-A gate requirements? Is
PROP-037 progression correctly held under `pipeline`? Is the vocabulary clean
of collisions with `compiler_profile_source.*`, future
`compiler_profile_contract.*`, and loader/report status terms? Does the proof
imply any implementation, CLI, loader/report, CompatibilityReport, dispatch,
runtime, or production widening?

Context:
- C4-A (S3-R55-C4-A): Authorized obligation coverage proof as proof-local,
  report-only only; output-only guardrail explicit; progression under `pipeline`
  for v0; implementation held pending proof + pressure review + Architect gate
- C1-P1 (S3-R56-C1-P1): Proof-local `CompilerProfileObligationReport` over
  8 existing SemanticIR/proof artifacts; 4 guard cases; 18 checks PASS;
  summary artifact written; no goldens mutated

---

## Scope Check 1 — Statuses Are Report-Only and Output-Only

The summary artifact was read independently. Every report object in the JSON
carries an explicit `output_only` block:

```json
"output_only": {
  "gates_igapp_emission": false,
  "changes_cli_exit_status": false,
  "changes_assembler_output": false,
  "touches_loader_report": false,
  "touches_compatibility_report": false,
  "touches_dispatch": false,
  "touches_runtime_machine": false,
  "touches_production_behavior": false
}
```

This block appears in all four case reports: `covered.full_finalized_source`,
`missing_slot.temporal_removed`, `profile_not_supplied.core_add`,
`unsupported_surface.synthetic_unknown_node`.

The summary check `output_only.flags_all_false: true` (PASS) confirms that
the proof script asserts these flags internally, not merely at the JSON schema
level. The check `output_only.selected_artifact_digests_unchanged: true` (PASS)
confirms existing golden artifacts were not mutated. ✓

The C4-A gate required guardrail:

> The obligation report is output-only. It must not gate `.igapp` emission,
> CLI exit status, assembler emission, loader/report status, CompatibilityReport,
> or RuntimeMachine behavior.

All eight corresponding flags are `false` across all four cases. The guardrail
is mechanically asserted in the proof itself, not only declared in the track doc.
✓

---

## Scope Check 2 — `missing_slot` Does Not Gate Compile

The `missing_slot` guard case:

```json
"case": "missing_slot.temporal_removed",
"status": "missing_slot",
"output_only": {
  "gates_igapp_emission": false,
  "changes_cli_exit_status": false,
  ...
}
```

The `missing_slot` status is a report verdict, not a compiler refusal. The
artifact `history_single_axis.igapp/semantic_ir_program.json` is analyzed
against a synthetic profile source from which the `temporal` slot has been
removed. The output: `coverage_status: "missing_slot"`, `missing_slots:
["temporal"]`. The `gates_igapp_emission` flag remains `false`.

This confirms the R55-C3-X pressure concern (NB in Challenge section): "If
'blocks' means the obligation validator refuses to proceed and no `.igapp` is
emitted → this changes current compile behavior and is not authorized." The
proof correctly implements the safe interpretation: `missing_slot` is a report
status, not a compile gate. ✓

The future enforcement path (where `missing_slot` could trigger a refuse) is
explicitly listed in the remaining blockers as requiring "separate Architect
implementation authorization with exact write scope." The current proof never
takes that path. ✓

---

## Scope Check 3 — Surface Detection Is Evidence-Based

Surface detection is performed over actual existing proof artifacts, not
synthetic or speculative inputs. Each covered-case artifact maps to a real prior
proof round:

| Artifact path | Source proof | Real? |
|---|---|---|
| `runtime_smoke_post_switch_full_coverage/out/core_add_compute.igapp/semantic_ir_program.json` | Stage 1/2 runtime smoke | ✓ |
| `contract_modifiers_proof/golden/observed_contract_basic.semantic_ir.json` | PROP-031 golden | ✓ |
| `runtime_smoke_post_switch_full_coverage/out/history_single_axis.igapp/semantic_ir_program.json` | PROP-028 temporal runtime smoke | ✓ |
| `runtime_smoke_post_switch_full_coverage/out/stream_fold.igapp/semantic_ir_program.json` | Stage 2 stream runtime smoke | ✓ |
| `runtime_smoke_post_switch_full_coverage/out/olap_point.igapp/semantic_ir_program.json` | Stage 2 OLAP runtime smoke | ✓ |
| `runtime_smoke_post_switch_full_coverage/out/invariant_severity.igapp/semantic_ir_program.json` | Stage 2 invariant runtime smoke | ✓ |
| `assumptions_proof/golden/assumption_basic.semantic_ir.json` | PROP-032 golden | ✓ |
| `prop037_progression_descriptor_shape_proof/...summary.json` | PROP-037 descriptor proof | ✓ |

All eight artifacts are products of previously accepted proof rounds. No surface
detection claim is made against fabricated SemanticIR. ✓

The `unsupported_surface` guard is the only case using a synthetic input
(`synthetic://future_surface_node`). This is a detector-guard, not a surface
claim: it proves the proof script returns `unsupported_surface` when it
encounters a node kind it does not recognize. The track doc notes: "The
unsupported case is a detector guard only. It does not define or propose a new
language surface." ✓

The synthetic path (`synthetic://`) is unambiguously not a real filesystem path
and cannot be confused with a production artifact.

---

## Scope Check 4 — Required Slot Mapping Matches C4-A Gate

The gate C4-A authorized surface detection for: core, contract modifiers,
temporal, stream, olap, invariant, assumptions, and progression descriptor.

The summary `surface_to_required_slots` map is checked against the R55 C1-P1
obligation map table:

| Surface | C1-P1 (R55) required slots | C1-P1 (R56) summary slots | Match |
|---|---|---|---|
| `core` | `core`, `oof_registry`, `fragment_registry`, `pipeline` | identical | ✓ |
| `escape_boundary` | `escape_boundary`, `fragment_registry`, `oof_registry` | identical | ✓ |
| `contract_modifiers` | `contract_modifiers`, `oof_registry`, `fragment_registry`, `escape_boundary` | identical | ✓ |
| `temporal` | `temporal`, `fragment_registry`, `escape_boundary`, `oof_registry`, `pipeline` | identical | ✓ |
| `stream` | `stream`, `fragment_registry`, `escape_boundary`, `oof_registry` | identical | ✓ |
| `olap` | `olap`, `fragment_registry`, `oof_registry` | identical | ✓ |
| `invariant` | `invariant`, `oof_registry`, `evidence_observation` | identical | ✓ |
| `assumptions` | `assumptions`, `fragment_registry`, `oof_registry`, `evidence_observation`, `pipeline` | identical | ✓ |
| `progression_descriptor` | `pipeline`, `stream`, `evidence_observation`, `oof_registry` | identical | ✓ |

All nine mappings are byte-identical between R55 C1-P1 obligation map and the
R56 C1-P1 proof summary. No slot was added, removed, or renamed. ✓

---

## Scope Check 5 — Progression Remains Under `pipeline` for v0

The C4-A gate decision:

> For the obligation coverage proof v0: progression descriptor/report metadata
> remains under the existing `pipeline` slot if it appears at all. No new
> `progression` slot is authorized in this decision.

The track doc:

> PROP-037 progression metadata remains under `pipeline` for v0. No new
> `progression` slot was introduced.

The summary confirms `progression_descriptor` maps to:
`pipeline`, `stream`, `evidence_observation`, `oof_registry`.

No `progression` slot appears anywhere in the proof or summary. The 12-slot
canonical model from PROP-036 §4 is unchanged. ✓

The open question (pipeline-only or future dedicated `progression` slot) is
correctly preserved as a remaining blocker item (blocker 4) for the future
contract design track. ✓

---

## Scope Check 6 — Vocabulary Collision Check

**Obligation report status vocabulary:**

```text
covered
missing_slot
unsupported_surface
profile_not_supplied
```

**Check against `compiler_profile_source.*` assembler vocabulary:**

```text
wrong_kind, unfinalized, runtime_authority_forbidden, missing, malformed,
absent_legacy, present_verified, mismatch, id_digest_mismatch,
slot_order_mismatch, dispatch_migration_forbidden, payload_id_inclusion_forbidden
```

No collision. The obligation statuses are unnamespaced plain strings in the
proof-local context; the source vocabulary uses namespaced dot-notation. ✓

**Check against PROP-036 §5/§6 loader/report vocabulary:**

```text
absent_legacy, present_verified, mismatch, malformed, missing_required
```

No collision. `missing_slot` ≠ `missing_required`. Semantically: `missing_slot`
means the profile's declared slots don't cover a detected surface; `missing_required`
means the manifest field is absent under `profile_required` policy. Different
layers, different meanings. ✓

**Check against future `compiler_profile_contract.*` vocabulary from C2-P1:**

```text
descriptor_missing, schema_mismatch, digest_mismatch, missing_required_slot,
slot_order_mismatch, duplicate_strict_key, missing_rule_reference, rule_cycle,
pack_missing, runtime_authority_forbidden, dispatch_migration_forbidden
```

Near-collision: `missing_slot` (obligation) vs `missing_required_slot` (contract).
These are semantically distinct:
- `missing_slot` = a surface requires a slot not present in the profile's `slot_order`/`slot_assignments`
- `missing_required_slot` = a required slot in the contract schema is absent from the contract object itself

They operate at different layers and would appear in different namespaced
contexts. No technical collision. However, a future reader unfamiliar with both
vocabularies could confuse them. The future contract design track should
explicitly note the distinction. Flagged as NB-1, non-blocking.

The track doc explicitly states: "This vocabulary is intentionally not
loader/report vocabulary and not `compiler_profile_source.*` assembler refusal
vocabulary." ✓

The remaining blockers correctly list "stable diagnostic namespace for
`compiler_profile_obligation.*` distinct from `compiler_profile_source.*`
and loader/report statuses" as a pre-implementation gate. ✓

---

## Scope Check 7 — No Implementation or Surface Widening Implied

The summary `non_authorizations_preserved` block:

```json
{
  "gates_igapp_emission": false,
  "changes_cli_exit_status": false,
  "changes_assembler_output": false,
  "loader_report_implementation": false,
  "compatibility_report_section": false,
  "compiler_dispatch_migration": false,
  "runtime_machine_behavior": false,
  "production_behavior": false
}
```

All false. ✓

The track non-authorization list covers 20 items including compile refusal, CLI
flags, loader/report, CompatibilityReport, golden migration, dispatch, pack
loading, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP
production, cache, and production behavior. ✓

**CLI interlock check:** The bounded CLI transport
(`--compiler-profile-source PATH.json`) is not referenced as an input or output
path for the obligation proof. The proof reads SemanticIR artifacts and the
finalized `compiler_profile_id_source` directly. The CLI transport layer is
untouched. ✓

---

## Additional Integrity Checks

**Authority flags in all case reports:**

Every report object contains:
```json
"profile_authority": {
  "compiler_understanding_only": true,
  "runtime_authority_granted": false,
  "dispatch_migration_authorized": false
}
```

This appears across all four cases, including `profile_not_supplied` where
`profile_ref` is null. The null-profile case correctly asserts
`compiler_understanding_only: true` — absence of a profile does not grant
any authority. This is the correct semantic. ✓

**`profile_not_supplied` edge case:**

When profile is null, `missing_slots` lists all required slots from the artifact
analysis. This is a conservative treatment: with no profile, all required slots
are considered uncovered. The status `profile_not_supplied` is correctly
distinguished from `missing_slot` (profile present but incomplete). The two
statuses are semantically distinct and their separation is correct. ✓

**Remaining blockers list completeness:**

The five listed blockers are exactly the items a future implementation
authorization card would need to satisfy:

1. Pressure review — satisfied by this card
2. Proof placement decision (before compile / after emit / before assembly)
3. Stable `compiler_profile_obligation.*` namespace
4. PROP-037 progression slot disposition
5. Architect implementation write-scope authorization

No blocker is softened or omitted. The list is consistent with what C4-A
requires before implementation. ✓

---

[Agree]

1. **The proof is genuinely output-only.** The `output_only` block is machine-
   asserted in the proof script (the check `output_only.flags_all_false` passes),
   not only declared textually. Every case report carries the same eight false
   flags. No `.igapp` is gated, no CLI exit is changed, no assembler output is
   altered.

2. **`missing_slot` is correctly implemented as a report status, not a compile
   gate.** The R55-C3-X challenge on this exact point is addressed. The proof
   demonstrates the safe interpretation: a missing slot affects the obligation
   report verdict, nothing else.

3. **Surface detection is evidence-grounded.** Eight real SemanticIR artifacts
   from previously accepted proof rounds are used. No surface is claimed from
   fabricated or speculative inputs. The `unsupported_surface` guard is clearly
   labeled as a detector probe, not a surface assertion.

4. **Slot mapping is stable and matches the gate.** All nine surface → slot
   entries in the proof summary are byte-identical to the R55 C1-P1 obligation
   map. No slot was added or changed between rounds.

5. **Progression correctly held under `pipeline`.** The C4-A decision is
   followed precisely. No `progression` slot appears. The open question is
   correctly categorized as a remaining blocker.

6. **Vocabulary is collision-free for practical purposes.** The obligation
   statuses (`covered`, `missing_slot`, `unsupported_surface`,
   `profile_not_supplied`) do not collide with `compiler_profile_source.*`,
   loader/report vocabulary, or future `compiler_profile_contract.*` at the
   technical level.

7. **The remaining blockers list is complete and honest.** Blocker 1 (pressure
   review) is satisfied by this card. Blockers 2–5 are real pre-implementation
   requirements, none artificially softened.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision on next route.

---

[NB-1 — Non-blocking: `missing_slot` vs `missing_required_slot` near-collision]

The obligation vocabulary uses `missing_slot` (a surface requires a slot not
present in the profile). The future `compiler_profile_contract.*` vocabulary
from C2-P1 uses `missing_required_slot` (a required slot in the contract schema
is absent). These are technically distinct — different namespaces, different
layers, different semantics — but visually similar enough to confuse a reader
who encounters both in isolation.

The future `compiler-profile-contract-boundary-v0` design track should include
an explicit vocabulary comparison table that distinguishes:

```text
compiler_profile_obligation.missing_slot
  = surface requires a slot not declared in profile slot_order/slot_assignments

compiler_profile_contract.missing_required_slot
  = required slot absent from the contract object itself
```

Non-blocking. Vocabulary namespace formalization is already a remaining blocker
before implementation authorization.

---

[NB-2 — Non-blocking: `profile_not_supplied` populates `missing_slots` with all required slots]

In the `profile_not_supplied` case, `missing_slots` lists all required slots
derived from the artifact surfaces. This is technically correct (no profile
means no slots are covered), but it may be confusing for a future consumer of
obligation reports: if `status` is `profile_not_supplied`, does `missing_slots`
carry actionable information or is it just empty-profile noise?

A future implementation design might treat `missing_slots` as empty in the
`profile_not_supplied` case (since there is no profile to compare against), and
reserve `missing_slots` exclusively for the `missing_slot` status case. This
would make the status the primary signal and the slot list a qualified
detail.

For a proof-local v0 experiment, the current behavior is acceptable. This is a
design-preference note for the future implementation card, not a correctness
issue.

---

## Verdict

**Proceed.**

All seven scope checks pass. The proof is output-only, evidence-grounded,
vocabulary-clean, correctly aligned with the C4-A gate, and carries an honest
remaining blockers list. Two non-blocking NB items are vocabulary-clarity notes
for the future design track.

Blocker 1 from the remaining blockers list (`pressure review of report shape and
status vocabulary`) is satisfied by this card.

---

[Route]

**Verdict: proceed.**

No blockers. Two non-blocking notes (NB-1: vocabulary near-collision; NB-2:
`profile_not_supplied` missing_slots semantics) for the future design track.

**Recommended Architect decision (C3-A):**

1. Accept the proof as satisfying its own blocker 1. The obligation coverage
   proof is confirmed sound: output-only, evidence-based, gate-aligned.

2. Open a formal owner decision for blocker 2: where in the compiler pipeline
   does the obligation report belong? Options: before compile (profile check
   before compilation starts), after SemanticIR emit (profile check after surface
   detection is possible), before assembly (profile check before manifest is
   written). This is a design-only decision card, not an implementation card.

3. Open `compiler-profile-contract-boundary-v0` design track as the next
   step informed by the proof's surface/slot evidence. Scope that track to also
   formalize the `compiler_profile_obligation.*` namespace (blocker 3) and
   address the PROP-037 progression slot question (blocker 4).

4. Implementation authorization (blocker 5) remains held until blockers 2–4 are
   resolved. No production compiler path should be modified until an Architect
   implementation decision names the exact write scope.

**For R57:**
- No implementation work is open from R56.
- If C3-A opens the proof-placement decision card, R57 can run that design-only
  card.
- If C3-A opens `compiler-profile-contract-boundary-v0` in parallel, R57 can
  begin that design track.
- Golden migration, loader/report, CompatibilityReport, dispatch, and production
  surfaces remain closed until obligation semantics and the contract design
  stabilize.

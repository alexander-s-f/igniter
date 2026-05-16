# Discussion: Compiler Profile Contract Boundary Pressure v0

Card: S3-R57-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-contract-boundary-pressure-v0

Depends on: S3-R57-C1-P1 and S3-R57-C2-P1 delivered

Question:

Is the lifecycle placement explicit and free of enforcement implication?
Are the four vocabulary namespaces clean and non-colliding? Are the R56 NB-1
and NB-2 pressure items properly resolved? Does PROP-037 progression remain
under `pipeline`? Are loader/report and CompatibilityReport kept as design-only
future surfaces rather than accidentally implemented? Does any wording imply
runtime readiness, dispatch migration, production authority, or CLI widening?

Context:
- R56-C3-A (gate): Accepted obligation coverage proof as output-only; authorized
  `compiler-profile-contract-boundary-v0` as design-only with specific guardrails
- R57-C1-P1: Compiler/Grammar Expert — vocabulary table, lifecycle placement
  ("SemanticIR profile-obligation checkpoint"), NB-1/NB-2 resolutions, governance
  route, blockers
- R57-C2-P1: Bridge Agent — bridge/report implication table, vocabulary boundary,
  forbidden implications, recommendations to C1/C3/C4

---

## Scope Check 1 — Lifecycle Placement Is Explicit and Non-Enforcing

**Placement decision:** C1-P1 recommends "after SemanticIR emit, before assembly",
named "SemanticIR profile-obligation checkpoint."

**Rationale check:**

| Candidate position | C1-P1 rationale | Verdict |
|---|---|---|
| Before compile | Too early — surface detection needs normalized SemanticIR | Correctly rejected |
| After SemanticIR emit | First stable point for all accepted surfaces | Selected ✓ |
| Before assembly | Keeps obligation report separate from `manifest.compiler_profile_id` | Additional criterion ✓ |

The "before assembly" criterion is important: placing the checkpoint before
assembly prevents a future reader from treating the manifest `compiler_profile_id`
as implicit proof of surface coverage. The separation is architecturally sound. ✓

**Enforcement check.** C1-P1 says explicitly:

> Current implementation remains unchanged. The checkpoint is a proposed
> design position only.

The non-authorization list names "code changes" and "TypeChecker or SemanticIR
changes" as explicitly prohibited. ✓

The C3-A gate guardrail is:

> The next design-only track must not implement a compiler pass.

C1-P1 respects this. ✓

**Design sequence diagram risk.** C1-P1 presents:

```text
parse -> classify -> typecheck -> SemanticIR emit
  -> SemanticIR profile-obligation checkpoint
  -> assemble artifacts
```

This diagram is labeled "Design-only sequence." The label is present and
distinguishes the design from a current implementation description. However,
a future implementation card author who reads only this diagram without the
surrounding prose could mistake it for a description of current behavior.
The phrase "current implementation remains unchanged" appears elsewhere in the
track but not adjacent to the diagram.

Non-blocking. The label is sufficient for the design track context. Future
cards that reference this sequence as a scope input should explicitly note
"design position, not current implementation." Flagged as NB-1.

---

## Scope Check 2 — Vocabulary Namespaces Are Clean and Non-Colliding

C1-P1 provides a four-column vocabulary boundary table. C1-P1 also provides
the near-collision comparison table closing R56-C2-X NB-1. Both are checked
here.

**Four-layer boundary table:**

| Namespace | Owner/layer | Primary question |
|---|---|---|
| `compiler_profile_source.*` | Caller/facade/orchestrator/assembler | Is the finalized source object valid to transport? |
| `compiler_profile_obligation.*` | Report-only coverage checkpoint | Do program surfaces require slots the profile lacks? |
| `compiler_profile_contract.*` | Future semantic contract validator | Is the contract object internally valid? |
| Loader/report vocabulary | Manifest/load/report interpretation | How should manifest `compiler_profile_id` be interpreted under rollout policy? |

The four layers answer four structurally different questions. No layer is
given authority from a downstream layer's answer. ✓

**Near-collision comparison table (R56-C2-X NB-1):**

| Term | Namespace | Meaning | Layer |
|---|---|---|---|
| `compiler_profile_obligation.missing_slot` | Obligation report | Program surface requires a slot not in profile `slot_order`/`slot_assignments` | Post-SemanticIR coverage report |
| `compiler_profile_contract.missing_required_slot` | Future contract validator | Contract object lacks a schema-required slot | Contract schema/semantic validation |
| `missing_required` | Loader/report status | Manifest lacks `compiler_profile_id` under `profile_required` policy | Manifest load/report |

The design rule stated explicitly:

> missing_slot != missing_required_slot != missing_required

These three terms answer: (1) program-to-profile gap; (2) contract-schema gap;
(3) manifest-policy gap. Lexically similar, semantically disjoint. ✓

**C2-P1 vocabulary boundary check:**

The Bridge Agent segregates: compiler-only vocabulary (`source.*`, `obligation.*`,
`contract.*`, slot ownership terms) vs. loader/report-facing vocabulary
(`absent_legacy`, `present_verified`, `mismatch`, `malformed`, `missing_required`,
policy names, evidence refs, non-authority flags).

The segregation rule is explicit:

> These terms answer compiler-understanding questions. They should not become
> loader/report statuses by direct copy.

This is the correct guard. "By direct copy" is precise: a future report adapter
may translate obligation statuses into loader-readable signals, but that
translation requires an explicit gate decision, not silent promotion. ✓

---

## Scope Check 3 — R56 NB-1 and NB-2 Are Resolved

**NB-1 (vocabulary near-collision):** Closed by C1-P1's near-collision
comparison table. The three terms are defined in distinct namespaces with
distinct semantics, and the design rule `missing_slot != missing_required_slot
!= missing_required` is explicitly stated. ✓

**NB-2 (`profile_not_supplied.missing_slots` semantics):**

R56 proof behavior:
```text
status: profile_not_supplied
missing_slots: [all required slots]
```

C1-P1 design recommendation for future implementation:
```text
status: profile_not_supplied
required_slots: [populated]
missing_slots: []
```

Rationale: `missing_slots` is reserved for profile-present comparison failures.
When no profile exists, there is no slot set to compare against.

The recommendation resolves the NB-2 concern. C1-P1 correctly notes: "This is
a future design recommendation only. It does not invalidate or rewrite the
accepted R56 proof summary." The R56 proof is accepted as-is; the behavioral
change belongs to a future implementation card. ✓

C2-P1's bridge implication table confirms consistency: the `profile_not_supplied`
row says "required slots may still be shown as evidence" — meaning `required_slots`
is still useful information even when `missing_slots` would be empty. ✓

---

## Scope Check 4 — PROP-037 Progression Under `pipeline`

C1-P1: "progression_descriptor stays under `pipeline` for v0. No new
`progression` slot is introduced by this track." ✓

The future question is explicitly preserved:

> Does PROP-037 need a dedicated `progression` slot before parser/SemanticIR/
> runtime implementation? That question requires a later Architect decision.
> It must not be silently encoded in obligation coverage or contract validation.

The phrase "must not be silently encoded" is the correct governance instruction.
It prevents incremental slot-scope creep without Architect authorization. ✓

The C3-A gate explicitly holds this open (blocker 5 in the gate). ✓

---

## Scope Check 5 — Loader/Report and CompatibilityReport Not Accidentally Implemented

**C1-P1 design check:**

The vocabulary boundary table shows loader/report status vocabulary as: "PROP-036
future loader/report language; not implemented here."

The boundary diagram marks loader/report as "manifest/load interpretation, not
compiler contract validation" — a downstream layer separated from contract
validation.

C1-P1 non-authorization list: "loader/report implementation", "CompatibilityReport
implementation". ✓

**C2-P1 design check:**

All three recommendations to C3 and C4 use conditional language: "If loader/
report work is later opened..." and "If CompatibilityReport work is later
opened..." These are not implementation authorizations — they describe what
future cards would need to satisfy.

C2-P1 non-authorization list: "loader/report implementation", "loader/report
schema", "CompatibilityReport implementation", "CompatibilityReport schema". ✓

The "Safe Report-Only Fields" section in C2-P1 lists candidate fields for
future report surfaces. This is a design-time recommendation, not schema
authoring. The section header includes "if a later gate opens them." ✓

**Bridge report implication table:** Every row includes a "Must not imply"
column. For example:
- `covered` must not imply "loader acceptance, compile acceptance, runtime
  readiness, production authority" ✓
- `missing_slot` must not imply "compile refusal or load refusal by default" ✓
- `compiler_profile_contract.*` diagnostics must not imply "loader refusal,
  CompatibilityReport readiness, runtime authority" ✓

---

## Scope Check 6 — No Runtime Readiness, Dispatch, Production, or CLI Widening

**C1-P1:**

The non-authorization list includes:
- "compiler dispatch migration"
- "CLI/API changes"
- "RuntimeMachine or Gate 3 widening"
- "Ledger/TBackend, BiHistory, stream/OLAP production execution, cache,
  production behavior"

The object relationship section explicitly states: "Neither the profile nor the
receipt grants runtime execution authority." ✓

**C2-P1:**

The forbidden implications list (12 items) includes:

> any compiler-profile report implies RuntimeMachine load/evaluate readiness

> any compiler-profile report grants Gate 3, executor/backend, Ledger/TBackend,
> stream/OLAP, cache, production, CLI, `.igapp`, `.ilk`, signing, or receipt
> authority

The list covers all the surfaces that must remain closed. ✓

C2-P1 states the hard invariant explicitly:

```text
present_verified
  != obligation covered
  != compiler_profile_contract valid
  != runtime_evaluation_readiness.ready
```

This chain of non-implications is correct and comprehensive. ✓

**CLI surface check.** Neither C1-P1 nor C2-P1 references the CLI transport
(`--compiler-profile-source PATH.json`) as needing any change. The bounded CLI
transport remains at its R54 confidence-confirmed state. ✓

---

## Additional Integrity Check: Boundary Diagram vs Object Relationship Ordering

C1-P1 presents two representations of the four-layer model:

**Boundary diagram** (top-down chain):
```text
compiler_profile_source.*
  -> compiler_profile_obligation.*
  -> compiler_profile_contract.*  [future proof-only]
  -> loader/report status vocabulary
```

**Object relationship section** (implied execution order):
```text
compiler_profile_contract
  -> finalizes to compiler_profile_id_source
  -> participates in SemanticIR profile-obligation checkpoint
  -> may supply manifest compiler_profile_id during assembly
```

These orderings are different:
- The boundary diagram places `source.*` before `obligation.*` before
  `contract.*` — which reads as "source validation first, then coverage, then
  contract."
- The object relationship section implies: contract is validated before it
  finalizes to a source; the source is then transported and the obligation
  checkpoint runs later.

The natural future execution order would be:
```text
compiler_profile_contract (validated)
  -> finalizes to compiler_profile_id_source
  -> transported by caller / CLI
  -> source object validated by assembler (compiler_profile_source.*)
  -> SemanticIR profile-obligation checkpoint (compiler_profile_obligation.*)
  -> assembly + manifest.compiler_profile_id
  -> future loader/report interpretation
```

This is not the order the boundary diagram suggests.

The boundary diagram appears to represent **design/validation authority layers**
(most caller-proximate to most compiler-internal), not execution order.
C1-P1 states: "These are four different layers." The diagram ordering is a
conceptual authority hierarchy, not a temporal sequence.

The ambiguity is real but non-blocking: the surrounding text clarifies the
intent, and the C3-A gate makes clear this is design-only. A future proof or
implementation card that references this diagram as a scope input should
explicitly choose the execution-order interpretation, not the diagram ordering.
Flagged as NB-2.

---

[Agree]

1. **Four-layer vocabulary boundary is the correct architecture.** Keeping
   `compiler_profile_source.*`, `compiler_profile_obligation.*`, future
   `compiler_profile_contract.*`, and loader/report vocabulary as independent
   namespaces answering independent questions is necessary for correctness. The
   vocabulary table and near-collision comparison table close the R56-C2-X NB-1
   concern completely.

2. **Lifecycle placement "after SemanticIR emit, before assembly" is correct.**
   This is the only stable point where the full accepted surface vocabulary is
   observable without re-deriving it from parser/classifier internals. The
   "before assembly" criterion correctly prevents the manifest profile identity
   from appearing to imply surface coverage.

3. **NB-2 resolution (`profile_not_supplied.missing_slots: []`) is the right
   design decision.** Reserving `missing_slots` for profile-present comparison
   failures makes the `profile_not_supplied` status unambiguous and prevents
   semantic confusion with `missing_slot`. Keeping `required_slots` populated
   preserves the diagnostic value of the detected surface analysis. ✓

4. **C2-P1's forbidden implications list is comprehensive and precise.** The
   12 forbidden implications close the most important authority-leak paths: the
   `present_verified` ≠ `covered` ≠ `valid contract` ≠ `runtime_ready` chain
   is the key invariant and it is stated explicitly.

5. **The governance route (new PROP, not PROP-036 errata) is correct.** PROP-036
   owns manifest identity and source transport. A compiler-profile contract that
   spans descriptor validity, slot schema, strict registries, ordered rules, and
   pack refs is architecturally broader. The new-PROP route is appropriate.

6. **Neither card creates implementation or widening.** Non-authorization lists
   in both C1-P1 and C2-P1 cover all required surfaces. C2-P1's conditional
   language ("if a later gate opens...") is the correct posture for bridge
   design work.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C4-A Architect decision.

---

[NB-1 — Non-blocking: design sequence diagram should carry implementation-state disclaimer in future cards]

C1-P1's design sequence diagram:

```text
parse -> classify -> typecheck -> SemanticIR emit
  -> SemanticIR profile-obligation checkpoint
  -> assemble artifacts
```

Is labeled "Design-only sequence." This is sufficient for the current design
track context. However, future cards that cite this sequence as a scope input
— particularly the future `compiler-profile-contract-proof-v0` or any
implementation authorization card — should include an explicit note that this is
a "proposed future design position, not current implementation." Without that
note, a future agent may treat the sequence as a description of what already
exists.

The C4-A card scope definition should include this disclaimer when referencing
the checkpoint position.

---

[NB-2 — Non-blocking: boundary diagram ordering vs execution ordering ambiguity]

C1-P1's boundary diagram:

```text
compiler_profile_source.*
  -> compiler_profile_obligation.*
  -> compiler_profile_contract.*  [future]
  -> loader/report status vocabulary
```

Suggests source → obligation → contract, but the object relationship section
implies contract is validated before it finalizes to source. The natural future
execution order is:

```text
contract (validated) -> source (transport) -> obligation (checkpoint) ->
  manifest identity -> loader/report
```

The diagram appears to show a **validation authority hierarchy** (caller-
proximate to compiler-internal), not temporal execution order. This is
architecturally meaningful but different from execution sequencing.

The future `compiler-profile-contract-proof-v0` scope card should explicitly
clarify which ordering the proof validates: does the proof test
contract-before-source, or does it accept the diagram's left-to-right ordering
as the validation flow? Resolving this in the proof scope card prevents the
proof from encoding an incorrect assumption about when contract validation runs
relative to source transport.

Non-blocking for the current design track. Must be addressed in the proof scope
definition.

---

## Verdict

**Proceed.**

All six scope checks pass. Lifecycle placement is explicit and non-enforcing.
Four vocabulary namespaces are clean with no technical collision. R56 NB-1
(near-collision table) and NB-2 (`profile_not_supplied.missing_slots`) are both
resolved by design decisions in C1-P1. PROP-037 progression stays under
`pipeline`. Loader/report and CompatibilityReport remain design-only futures.
No runtime readiness, dispatch migration, production authority, or CLI widening
is implied.

Two non-blocking notes: NB-1 (design sequence diagram needs implementation-state
disclaimer in future cards); NB-2 (boundary diagram ordering vs execution
ordering needs clarification in the proof scope card).

---

[Route]

**Verdict: proceed.**

No blockers. Two non-blocking notes for the C4-A scope definition.

**Recommended Architect decision (C4-A):**

1. Accept C1-P1 contract boundary design and C2-P1 bridge surface review as the
   R57 design record. These collectively satisfy the design-only boundary track
   authorized by C3-A.

2. Open `compiler-profile-contract-proof-v0` as the next proof-local experiment.
   Scope must include:
   - validate a canonical `compiler_profile_contract` object (descriptor digest,
     slot schema, strict registries, ordered rule graph, non-authority flags);
   - prove `compiler_profile_contract.missing_required_slot` is distinct from
     `compiler_profile_obligation.missing_slot` in a shared test case;
   - prove `profile_not_supplied` behavior with `missing_slots: []` and
     `required_slots: [populated]`;
   - explicitly clarify execution ordering: contract validated before finalization
     to source, source transported, obligation checkpoint after SemanticIR emit
     (NB-2 resolution);
   - carry the design sequence diagram disclaimer: "proposed future position,
     not current implementation" (NB-1 resolution).

3. Confirm governance route: the future promotion vehicle is a new PROP (not
   PROP-036 errata). Record this in C4-A to prevent future routing confusion.

4. Implementation authorization remains held until the contract proof lands and
   is pressure reviewed.

**For R58:**
- No implementation work is open from R57.
- If C4-A opens `compiler-profile-contract-proof-v0`, R58 can run that
  proof-local experiment.
- Loader/report, CompatibilityReport, dispatch, golden migration, and production
  surfaces remain closed.
- PROP-037 progression slot question remains open for a later Architect decision.

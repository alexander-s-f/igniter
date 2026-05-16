# Discussion: Compiler Profile Contract Pressure v0

Card: S3-R55-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-contract-pressure-v0

Depends on: S3-R55-C1-P1 and S3-R55-C2-P1 delivered

Question:

Is "language surface → profile identity → compiler obligations → infrastructure
pressure" a thesis supported by current evidence? Does the recommended next
route stay within scope boundaries? Does either card confuse profile identity
with compiler dispatch or runtime execution authority? Is there proposal or
status drift? Does either recommendation create unnecessary interlocks with the
CLI transport or Gate 3?

Context:
- R54: PROP-036 CLI transport fully release-confident; docs navigation closed;
  no further CLI or implementation work pending
- R55-C1-P1 (Research Agent): Language surface → profile slot → compiler
  obligation map; identifies "missing middle" between profile transport and
  surface coverage proof; recommends `compiler-profile-obligation-coverage-proof-v0`
  as the bounded next track
- R55-C2-P1 (Compiler/Grammar Expert): Five options for treating CompilerProfile
  as a compiler contract; recommends hybrid contract as the eventual target after
  staged proof-local gates; recommends a new PROP rather than PROP-036 errata

---

## Scope Check 1 — Evidence Support for the Thesis

**Thesis under review:**

```text
language surface -> profile identity -> compiler obligations -> infrastructure pressure
```

**C1-P1 thesis test result:** "directionally correct, but the current system
has a missing middle artifact."

This is an honest assessment. The evidence base for the thesis was checked:

| Leg | Evidence present | Gaps |
|---|---|---|
| Language surface → slot | Obligation map table with per-surface PROP citations and proof references | ✓ |
| Slot → compiler obligation | Existing slot model from PROP-036 §4 + finalization proof | ✓ |
| Profile identity → manifest | Assembler field landed; orchestrator/facade/CLI transport all PASS | ✓ |
| Profile identity → surface coverage | **ABSENT** | Missing middle |
| Coverage → infrastructure | Deferred pending coverage proof | Correctly deferred |

The missing middle is the proof that a finalized `compiler_profile_id_source`
whose `slot_order` and `slot_assignments` actually cover the language surfaces
used in a given program. Today, the CLI transport accepts any finalized profile
source object and passes it through to the assembler, which validates the object
shape but does not check whether the profile's declared slots match the surfaces
the compiler actually exercised.

This gap is real, not speculative. A program using temporal nodes could be
compiled and profiled with a `core`-only profile today, and the system would
accept it. The profile transport says "this profile was supplied"; it does not
say "this profile covered this program."

**Evidence quality:** Each row in the obligation map table cites a real proof
artifact or PROP that was read (not asserted): `source_to_semanticir_fixture`,
`contract_modifiers_proof`, `assumptions_proof`, PROP-037 descriptor proof, etc.
The thesis is grounded in the existing proof chain. ✓

**Architecture-pressure verdict:** The thesis is valid. C1-P1's identification
of the missing middle layer is the key architectural insight in R55. It
correctly places the next bounded proof as a prerequisite to loader/report,
CompatibilityReport, dispatch, and golden migration — not as an optional
enhancement, but as the semantic foundation those later surfaces need.

---

## Scope Check 2 — Recommended Route Preserves Scope Boundaries

**C1-P1 recommended sequence:**

```text
1. compiler-profile-obligation-coverage-proof-v0  (report-only, proof-local)
2. loader-report-compiler-profile-status-v0       (after obligation coverage)
3. compatibility-report-compiler-profile-section-v0  (after loader/report)
4. profile-driven-compiler-dispatch-proof-v0      (after slots/obligations proven)
5. artifact-hash-profile-id-golden-migration-v0   (after semantics stable)
```

**C2-P1 recommended sequence:**

```text
1. compiler-profile-contract-boundary-v0          (design-only)
2. compiler-profile-contract-proof-v0             (proof-local experiment)
3. new PROP if proof stabilizes                   (not PROP-036 errata)
4. Implementation authorization only after proof closure
```

Both sequences correctly gate implementation behind proof. Both defer dispatch,
golden migration, and loader/report until earlier proof gates close. Neither
sequence asks for implementation authorization in R55.

**Gate structure check:** C2-P1 provides a five-gate proof structure for the
hybrid contract:

| Gate | Purpose | Prohibited action |
|---|---|---|
| Contract shape proof | Validate canonical hybrid object and digest stability | No live dispatch |
| Slot/rule proof | Validate slots, strict registries, ordered rule graph | No handler execution |
| Source object adapter proof | Show how finalized contract produces existing source | No assembler golden migration |
| Conformance proof | Show current monolith can be described by the contract | No pack loader |
| Implementation request | Ask for tiny validator boundary after proof closure | No CLI/runtime widening |

Each gate has a hard "must not" constraint. The structure is consistent with the
blocker-chain pattern used for B1–B9 in PROP-036 CLI. ✓

**Sequencing question (not a blocker):** C1-P1 recommends starting with the
obligation coverage proof (from existing `compiler_profile_id_source`); C2-P1
recommends starting with a new contract formalization design track (for a new
`compiler_profile_contract` object shape). These are not contradictory — the
obligation proof exercises coverage from the existing source transport, while
the contract formalization designs a richer first-class contract object. They
can proceed as parallel tracks. However, the relationship is not explicitly
resolved in either card. The Architect decision (C4-A) should choose:
- parallel with explicit separation of concerns, or
- sequential (obligation proof first, contract formalization second) to let the
  proof findings inform the contract design.

This is a routing clarification, not a scope violation. Flagged below as NB-1.

---

## Scope Check 3 — Profile Identity vs Compiler Dispatch vs Runtime Authority

This is the principal authority-confusion risk for compiler profile work.

The three lanes must remain separated:

```text
profile identity   -> compiler understanding
compiler dispatch  -> separate future authorization
runtime authority  -> Gate 3 / TBackend / approval tokens / entirely separate
```

**C1-P1:**

- "compiler_profile_id identifies compiler understanding. It does not grant
  runtime execution authority." — stated explicitly on line 98 ✓
- Gap kinds in the obligation map: "reporting / governance", "implementation /
  reporting", "semantic / governance" — none tagged "runtime authority" ✓
- Non-authorization list explicitly names RuntimeMachine, Gate 3 widening,
  Ledger/TBackend, BiHistory, stream/OLAP production execution ✓
- Obligation report verdict language: "missing a required slot blocks
  'profile-covered compile' status but does not imply runtime readiness" ✓

**C2-P1:**

- Every option row in the formal options table lists "Runtime authority" under
  Excluded ✓
- `dispatch_migration_authorized: false` is a required field in all proposed
  contract shapes ✓
- `runtime_authority_granted: false` is a required field in all proposed
  contract shapes ✓
- Diagnostic vocabulary includes both `runtime_authority_forbidden` and
  `dispatch_migration_forbidden` as explicit refusal codes ✓
- The vocabulary boundary rule is explicit:
  ```text
  compiler_profile_source.* = caller/facade/assembler source object refusal
  compiler_profile_contract.* = semantic profile contract validation refusal
  ```
  This preserves the R50/R51/R52 boundary proofs. ✓

No authority-lane confusion found in either card. ✓

**Load/report vocabulary check.** C2-P1 includes the existing assembler source
vocabulary in its "remaining valid" list:

```text
compiler_profile_source.present_verified
compiler_profile_source.mismatch
compiler_profile_source.malformed
compiler_profile_source.missing_required
```

These are the same vocabulary items that PROP-036 §5 and §6 define for loader
status reports. The formalization options correctly leave this vocabulary
unchanged and propose a separate `compiler_profile_contract.*` namespace for the
new contract validation layer. The two vocabularies do not collide. ✓

C2-P1 explicitly prohibits reusing loader status tokens (`present_verified`,
`mismatch`, `malformed`, `missing_required`) as compiler contract refusal codes.
This preserves the loader/report boundary that was a central concern in the
B3/B5/B6 blocker chain. ✓

---

## Scope Check 4 — Proposal and Status Drift

**C1-P1 proposal citations:**

PROP-028 (temporal), PROP-031 (contract modifiers), PROP-032 (assumptions),
PROP-036 (compiler profile manifest identity), PROP-037 (progression). All are
active Stage 3 proposals. No reference to closed or rejected proposals. No
reference to post-POC implementation that was not separately authorized. ✓

**C2-P1 proposal citations:**

PROP-036 and current implementation surfaces only. The formalization options
correctly treat `compiler_profile_id_source` as the current live transport
(accurate) and propose a new `compiler_profile_contract` object as future work.
This does not drift into PROP-036 errata territory — C2-P1 explicitly says
"Treating `CompilerProfile` as a compiler contract is broader than manifest
identity and should become either a new PROP or a separate design/proof packet
first." ✓

**Status map check.** `current-status.md` Compiler Internals lane records:

```text
R54 release-confidence smoke 5/5 PASS and docs navigation polished;
profile discovery/defaulting/finalization, golden migration, loader/report,
CompatibilityReport, receipts, signing, dispatch, runtime, production remain blocked
```

C1-P1 and C2-P1 both respect these closures. Neither card proposes opening any
of the listed blocked surfaces. ✓

**PROP-037 progression slot question.** C1-P1 notes:

> PROP-037 is the first pressure that may not fit the current slot set cleanly.
> `pipeline` can carry descriptor/report obligations for now, but a future
> `progression` slot may be needed before parser/SemanticIR implementation.

C2-P1 does not address PROP-037. This is not a problem for the formalization
options — the hybrid contract shape is generic enough to accommodate a future
`progression` slot without redesign. But the Compiler/Grammar Expert should
confirm whether `progression` should appear as an open question in the new PROP
or design track, so it is captured before contract vocabulary stabilizes.
Flagged as NB-2.

---

## Scope Check 5 — CLI and Gate 3 Interlocks

**CLI interlock check:**

The obligation coverage proof (C1-P1 recommendation) operates on
SemanticIR/CompilationReport surfaces. It reads a finalized
`compiler_profile_id_source` and checks slot coverage against surfaces used in a
compiled program. It does not change what the CLI transports, what path the
profile source takes, or what the assembler emits. The existing CLI transport
(`--compiler-profile-source PATH.json`) remains unchanged.

C2-P1's contract formalization design track would produce a new
`compiler_profile_contract` object. This object lives at the finalization or
proof-local layer — it does not touch the CLI transport layer. C2-P1 explicitly
states "CLI source-shape widening remains closed." ✓

Neither recommendation creates a new CLI interlock. The bounded CLI transport
remains exactly:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

No change, no dependency. ✓

**Gate 3 interlock check:**

Gate 3 owns runtime evaluation authority. Neither C1-P1 nor C2-P1 creates a
dependency on Gate 3 for their recommended tracks.

The obligation coverage proof is a compile-time evidence artifact. It does not
require Gate 3 approval. The contract formalization design track is documentation
and design. Neither feeds into Gate 3 inputs or creates a prerequisite for Gate
3 widening. ✓

C1-P1's ranked sequence explicitly keeps CompatibilityReport and dispatch as
later steps, and even those steps would not widen Gate 3 authority. The hard
invariant from PROP-036 §6 is preserved:

```text
compiler_profile_status.present_verified does not imply runtime_evaluation_readiness.ready
```

✓

---

[Agree]

1. **The thesis is architecturally sound and evidence-backed.** C1-P1 does not
   state it as intuition — it tests it against the current proof chain and finds
   the missing middle layer. That identification of the coverage gap (profile
   transport vs surface coverage proof) is the key architectural contribution of
   R55. It correctly positions the obligation proof as the semantic prerequisite
   for loader/report, CompatibilityReport, dispatch, and golden migration.

2. **C2-P1's five-option analysis is well-structured.** The formal options table
   gives the Architect a clear decision surface without forcing a premature choice.
   The recommendation (hybrid as eventual target, proof-local gates before any
   implementation) is the correct posture. The staged proof gates directly mirror
   the B1–B9 blocker pattern that successfully delivered the CLI transport.

3. **C2-P1's vocabulary boundary is correct and important.** Keeping
   `compiler_profile_contract.*` separate from `compiler_profile_source.*` and
   from loader-status tokens preserves the refusal vocabulary discipline
   established in the B3/B6 closure. This separation will matter when the
   contract validator eventually runs alongside the existing assembler
   source-validation path.

4. **Neither card blurs the three authority lanes.** Profile identity =
   compiler understanding; dispatch migration = separate future authorization;
   runtime authority = completely separate and explicitly forbidden. Both cards
   are consistent on this. ✓

5. **Neither card creates CLI or Gate 3 interlocks.** The bounded CLI transport
   is complete and undisturbed. Gate 3 is independent. ✓

---

[Challenge]

**C1-P1 obligation map gap: does "profile-covered compile" create a new
reject/accept surface?**

The C1-P1 obligation report would emit `covered`, `missing_slot`,
`unsupported_surface`, or `profile_not_supplied`. C1-P1 specifies "missing a
required slot blocks 'profile-covered compile' status but does not imply runtime
readiness." The word "blocks" needs precision before the proof-local experiment
runs.

- If "blocks" means "the proof emits a non-success status, the caller can see
  the report, but the compile still succeeds and emits `.igapp`" → this is
  report-only and safe.
- If "blocks" means "the obligation validator refuses to proceed and no `.igapp`
  is emitted" → this changes current compile behavior and is not authorized by
  C1-P1 (which explicitly says "keep assembler/loader/CompatibilityReport/
  dispatch unchanged").

The C1-P1 proof design should explicitly clarify that the obligation report is
output-only (does not gate `.igapp` emission or CLI exit) until a separate
implementation card authorizes the enforcement path. This clarification should
appear in the proof-local experiment scope before implementation authorization
is requested.

This is a scoping note for the proof design, not a blocker for opening the
recommended track.

---

[Missing]

1. **Sequencing decision between C1-P1 and C2-P1 tracks.** The obligation
   coverage proof (C1-P1) and the contract formalization design track (C2-P1)
   can run in parallel, but their relationship to each other is not stated.
   If the proof discovers something unexpected about slot coverage semantics, it
   may change the contract design. If the design track settles the contract object
   first, the proof has a richer input. The Architect decision (C4-A) should
   declare the relationship explicitly. See NB-1.

2. **PROP-037 progression slot disposition.** C1-P1 raises this; C2-P1 does
   not. Before a new PROP or design track opens, the Compiler/Grammar Expert
   should confirm whether `progression` is in-scope for the contract design or
   deferred. See NB-2.

---

[NB-1 — Non-blocking: C1-P1 and C2-P1 track relationship needs Architect routing]

C1-P1 recommends starting with the obligation coverage proof (proof-local, uses
existing `compiler_profile_id_source`). C2-P1 recommends starting with a
contract formalization design track (new `compiler_profile_contract` object).

These can run in parallel because:
- Obligation proof: input = finalized source object; output = CompilerProfileObligationReport
- Contract design: input = requirements from options analysis; output = design doc + new PROP draft

But if they are parallel, care is needed: the obligation proof must not depend
on the contract design completing first, and the contract design must not assume
the obligation proof has fixed coverage semantics.

If sequential, the obligation proof is the natural first step: it reveals what
"coverage" means concretely before a formal contract must declare it abstractly.

The Architect decision (C4-A) should record the chosen relationship.

---

[NB-2 — Non-blocking: PROP-037 progression slot open question]

C1-P1 notes that PROP-037 may not fit the current slot set cleanly:

> `pipeline` can carry descriptor/report obligations for now, but a future
> `progression` slot may be needed before parser/SemanticIR implementation.

C2-P1 does not address PROP-037. Before a new PROP or contract design track
opens, the Compiler/Grammar Expert should confirm whether the open `progression`
slot question should appear in the scope of the new PROP or be handled as a
PROP-037 errata. This prevents the contract design from baking in a slot model
that later needs amendment when PROP-037 implementation is authorized.

Non-blocking for R55. Should be on the checklist for C4-A scope definition.

---

## Release-Confidence and Architecture Verdict

**The R55 research is architecturally sound and correctly scoped.**

C1-P1's obligation map identifies a genuine structural gap — the missing middle
between profile transport and surface coverage proof — and proposes a bounded
proof-local track to close it. C2-P1's formalization options provide the
Architect with a complete decision surface for the contract object shape, with
a recommended hybrid target and staged proof gates.

Both cards stay inside their respective roles (research → mapping; grammar
expert → formalization options), preserve all existing non-authorizations, and
do not create CLI or Gate 3 interlocks.

---

[Route]

**Verdict: proceed-with-notes.**

No blockers. Two non-blocking notes (NB-1: track sequencing; NB-2: PROP-037
progression slot) require Architect clarification in C4-A, but neither delays
opening recommended tracks.

**Recommended Architect decision (C4-A):**

1. Accept C1-P1's obligation coverage proof as the primary next bounded track.
   Open `compiler-profile-obligation-coverage-proof-v0`. Scope: proof-local,
   report-only, does not change CLI/assembler/loader behavior.

2. Accept C2-P1's contract formalization options. Decide sequencing:
   - Preferred: obligation coverage proof runs first (proof findings inform
     contract design); contract formalization design track opens after.
   - Alternative: both tracks open in parallel with explicit separation of
     concerns documented in their scope cards.
   Do not open a contract implementation card yet.

3. Confirm that the contract vehicle is a new PROP (not PROP-036 errata), as
   C2-P1 recommends. Record this in C4-A to prevent future routing confusion.

4. Address NB-2 in C4-A scope: confirm whether PROP-037 `progression` slot
   question is in or out of scope for the new contract design track.

5. Clarify in the obligation coverage proof card that the proof is output-only
   (does not gate `.igapp` emission) until a separate implementation card
   explicitly authorizes enforcement.

**For R56:**
- No implementation work is open from R55.
- If C4-A opens `compiler-profile-obligation-coverage-proof-v0`, R56 can run
  the bounded proof experiment.
- If C4-A opens the contract formalization design track in parallel or
  sequentially, R56 or R57 can begin that design work.
- Golden migration, loader/report, CompatibilityReport, dispatch migration, and
  production surfaces remain closed until the obligation proof (and optionally
  the contract design) stabilize.

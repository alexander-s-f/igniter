# Discussion: Compiler Profile Contract Schema Ownership Pressure v0

Card: S3-R59-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-contract-schema-ownership-pressure-v0

Depends on: S3-R59-C1-P1 delivered

Question:

Does C1 avoid silently authorizing implementation? Are slot schema and
ordered-rule ownership precise enough? Are one-owner registry semantics
concrete enough? Are untested validator paths handled explicitly? Is positional
`required_slots` debt routed clearly? Is the new PROP route still distinct from
PROP-036 errata? Are loader/report, CompatibilityReport, dispatch, runtime, and
production surfaces still closed?

Context:
- R58-C3-A (gate): Accepted R58 proof; opened Compiler/Grammar pressure track;
  held PROP authoring and implementation; identified 7 PROP-authoring blockers
- R59-C1-P1: Compiler/Grammar Expert — formal clearance/blocker table; ownership
  decisions for 9 schema areas; verdict `PROP authoring: hold`; recommended next
  card `compiler-profile-contract-validator-coverage-proof-v0`

---

## Scope Check 1 — C1 Does Not Silently Authorize Implementation

**Verdict is explicitly `PROP authoring: hold`.** The track opens with:

```text
PROP authoring: hold
Recommended next route: more proof, narrow proof-evolution card
Implementation authorization: held
```

The non-authorization list covers every surface that must stay closed:
PROP authoring itself, compiler implementation, TypeChecker/SemanticIR,
assembler/`.igapp`, CLI/API, loader/report, CompatibilityReport, dispatch,
RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, and
production behavior. ✓

The handoff section states "Documentation-only pressure track. No code or
artifact checks required beyond doc validation." This is the correct posture
for a grammar-ownership review. ✓

The recommendation section routes to a narrowly scoped next proof card
(`compiler-profile-contract-validator-coverage-proof-v0`) and then to a
separate Architect authorization for PROP authoring. This enforces the gate
chain rather than collapsing it. ✓

---

## Scope Check 2 — Slot Schema And Ordered-Rule Ownership Are Precise

The clearance/blocker table covers 11 areas, each with: R58 evidence, formal
ownership decision, clearance for PROP authoring, and specific blocker or
next action.

**Ownership assignments:**

| Area | Owner |
|---|---|
| Required slot schema | Compiler/Grammar |
| Slot order | Compiler/Grammar |
| Slot assignments (meaning) | Compiler/Grammar (declared understanding only); Implementation (later code path, if authorized separately) |
| Strict registries | Compiler/Grammar |
| One-owner semantics | Compiler/Grammar |
| Ordered rule graph well-formedness | Compiler/Grammar; Implementation owns dispatcher only if separately authorized |
| Rule cycle semantics | Compiler/Grammar |
| Rule reference semantics | Compiler/Grammar |
| Diagnostic namespace separation | Compiler/Grammar |
| Future `profile_not_supplied` design | Compiler/Grammar (semantics); Research (proof mechanics) |

These are precise enough for a clearance review. Each area has a named owner
and a scope boundary. ✓

**The slot-assignment scoping is the most important precision.** C1-P1 says:

> "in this contract stage that means 'the profile claims this slot is understood
> by this declared owner.' It does not mean the compiler is dynamically loading
> or calling that pack."

This split — declared-ownership vs. execution-authority — is the exact
distinction needed to prevent a PROP that defines `slot_assignments` from being
read as a dispatch migration authorization. ✓

**Ordered-rule stage vocabulary gap (see NB-1).** The clearance table correctly
assigns stage vocabulary to Compiler/Grammar ownership, but the C1-P1 does not
decide whether `stage` names (`parse`, `classify`, `typecheck`, `emit`) are
normatively validated fields or informational metadata. The proof validator
does not check stage values against a permitted set. A PROP that uses the rule
graph vocabulary without resolving this question leaves an ambiguity that an
implementation or future proof could fill in any direction. Non-blocking for
the grammar pressure track but must be addressed in PROP authoring.

---

## Scope Check 3 — One-Owner Registry Semantics Are Concrete

C1-P1 defines the invariant precisely:

```text
within one registry, one key must have exactly one owner entry
```

And the scope boundary:

```text
The strict registry is closed within the contract object being validated. This
does not claim the global language can never add new keys in later proposals.
```

These two sentences together answer both the synchronic question (what the
contract validator enforces right now) and the diachronic question (what this
means for future language evolution). The "closed within the contract object"
qualifier correctly prevents over-claiming a global-language property from a
proof-local validator decision. ✓

**Registry-general claim vs. single-registry proof coverage.** The R58 proof
exercises the `duplicate_strict_key` case for `oof_descriptors` only. C1-P1
acknowledges an optional extension case for `fragment_class_owners`. The PROP
can claim registry-general one-owner semantics because the validator's
`strict_registries.each` loop applies the same check to every registry. A PROP
claiming registry-general semantics on proof of one registry is sound given the
validator code structure. The optional `fragment_class_owners` case in the
next proof card would strengthen the evidence without changing the semantics.
Non-blocking, as C1-P1 correctly judges. ✓

---

## Scope Check 4 — Untested Validator Paths Are Handled Explicitly

C1-P1 provides a dedicated table for all five untested paths:

| Path | PROP blocker? | Reason |
|---|---|---|
| `compiler_profile_contract.missing_rule_reference` | Yes — highest priority | Rule references are core formal graph semantics |
| `compiler_profile_contract.wrong_kind` | Yes | PROP should not define a contract without proving wrong-kind refusal shape |
| `compiler_profile_contract.unsupported_format_version` | Yes | Version support is normative schema surface |
| `compiler_profile_contract.descriptor_digest_invalid` | Yes | Digest validity is part of the contract's identity bridge |
| `compiler_profile_contract.finalization_payload_digest_invalid` | Yes | Finalization digest validates the bridge to `compiler_profile_id_source` |

The severity calibration is correct. `missing_rule_reference` is correctly
elevated as highest priority: if the ordered-rule graph contains a `before` or
`after` reference to a non-existent rule, the graph's semantics are undefined.
A PROP that specifies the ordered-rule graph without defining what happens to
dangling references leaves a normative gap. ✓

The four front-door paths (`wrong_kind`, format version, digest fields) are
similarly correctly required: these define the entry validity contract of the
object. A PROP should not freeze the contract object shape while the front-door
refusal behavior is unproven. ✓

The recommended next card is precisely scoped:

```text
compiler-profile-contract-validator-coverage-proof-v0
```

Scope constraints: "add proof cases and no new semantics." This is correct
because all five paths already exist in the validator code as branches — the
proof card exercises existing logic without requiring new design decisions. ✓

**Additional observation: these five paths add no semantic ambiguity.** The
`wrong_kind` check is a string equality test; format version is a string
equality test; the digest paths are regex tests. None introduce ordered-rule or
slot-schema semantics. The `missing_rule_reference` path adds only "every
`before`/`after` target must be a declared rule id" — a referential integrity
rule that C1-P1 already states as the decision for rule reference semantics. ✓

---

## Scope Check 5 — Positional `required_slots` Debt Is Routed Clearly

C1-P1 distinguishes semantics from mechanics:

**Semantics (correct):**
```text
status: profile_not_supplied
required_slots: populated
missing_slots: []
```
These are the R58 design decisions. The PROP should use this shape.

**Mechanics (fragile):** The proof script derives `required_slots` from
`obligation_summary.dig("reports", 2, "artifacts", 0, "required_slots")`.
This is positional derivation that could silently fail under proof evolution.

C1-P1's routing:
- Does not block PROP authoring
- Requires explicit recording as proof-only debt
- Recommends fix in the same validator coverage proof card, or before
  implementation authorization at latest
- Explicitly says the PROP should not cite the derivation mechanism

The routing is correctly calibrated. The positional lookup is a proof
implementation detail, not a language semantic. The PROP defines the behavioral
shape; the proof mechanics are an implementation concern of the proof script
itself. The distinction is cleanly maintained. ✓

---

## Scope Check 6 — New PROP Route Remains Distinct From PROP-036 Errata

C1-P1 states:

> "The PROP route should be a new PROP, not a PROP-036 errata. PROP-036 owns
> manifest identity and finalized source transport. `compiler_profile_contract`
> owns contract object schema, strict registries, ordered rules, and validation
> order."

This is consistent with the original R57-C4-A governance decision, the R58-C3-A
gate, and the R58-C2-X pressure review — all of which established new PROP as
the correct vehicle.

The distinction is grounded in scope:
- PROP-036: `compiler_profile_id_source` shape, manifest identity, source
  transport; bounded CLI flag transport
- Future contract PROP: `compiler_profile_contract` schema, strict registries,
  one-owner invariant, ordered rule graph, validation order, authority flags

These are genuinely different scope surfaces. Keeping them as separate PROPs
prevents PROP-036 from acquiring contract-validation authority through amendment.
✓

---

## Scope Check 7 — Forbidden Surfaces Remain Closed

**Loader/report and CompatibilityReport:** Not mentioned in any authorization.
Non-authorization list explicitly includes "loader/report implementation or
schema" and "CompatibilityReport implementation or schema." ✓

**Dispatch migration:** Non-authorization list includes "compiler dispatch
migration" and C1-P1's ownership decision for ordered rule graph explicitly
states "Implementation owns any later dispatcher if authorized" (separate future
gate required). ✓

**Runtime and production:** Non-authorization list includes RuntimeMachine/Gate
3, Ledger/TBackend, BiHistory, stream/OLAP, cache, and production behavior. ✓

**CLI/API:** Non-authorization list includes "CLI/API widening." ✓

The non-authorization list in C1-P1 is equally comprehensive as the R58
proof's list. No new surface is claimed between R58 and R59. ✓

---

## Additional Integrity Check: Blocker Table Is Internally Consistent

The three blocking items in C1-P1's blocker table:

1. **Untested `missing_rule_reference`** — correctly blocking; closure condition
   is specific (add proof case showing missing target emits the expected
   diagnostic)
2. **Untested front-door schema paths** — correctly blocking; closure condition
   names all four paths
3. **Architect PROP-authoring authorization** — correctly blocking; preserves
   the gate chain

The non-blocking items are correctly scoped:
- Required slot schema ownership: clear (C1-P1 formally assigns it)
- Strict registry one-owner: clear (semantics formally stated)
- Rule cycle semantics: clear (R58 proof case confirmed)
- Positional `required_slots` derivation: proof debt, not PROP content
- PROP-037 progression slot: separate question; PROP can state v0 uses `pipeline`

The three blocking items are logically independent — each closes via a distinct
action. The two non-blocking items are correctly scoped away from PROP authoring.
The blocker table does not conflate implementation blockers with PROP-authoring
blockers. ✓

---

[Agree]

1. **Verdict `PROP authoring: hold` is correct.** The five untested validator
   paths — especially `missing_rule_reference` — represent genuine normative gaps
   in the ordered-rule graph semantics. A PROP that defines the rule graph
   without proving what happens to dangling references leaves formal ambiguity.
   The hold is properly motivated, not over-cautious.

2. **Ownership assignments are actionable.** Eleven schema areas have explicit
   owners and scope boundaries. The slot-assignment split (declared understanding
   vs. execution authority) is the most important and is correctly stated.

3. **One-owner semantics are concrete and correctly scoped.** The "closed within
   the contract object" qualifier prevents the contract from accidentally claiming
   global registry authority. The registry-general claim is sound given the
   validator's code structure.

4. **Untested paths are prioritized correctly.** `missing_rule_reference` is
   highest priority; front-door paths are secondary but still required. The
   recommended validator-coverage card adds cases without adding semantics.

5. **Positional debt routing is correctly calibrated.** Semantics are stable;
   mechanics are proof debt; PROP should not cite the derivation mechanism.

6. **PROP route governance is preserved.** New PROP (not PROP-036 errata) is
   confirmed for the third consecutive card. The distinction is grounded in
   genuine scope difference.

7. **Forbidden surfaces are all closed.** Non-authorization list is complete and
   consistent with previous cards in this track.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

[NB-1 — Non-blocking: `stage` field in ordered rules is unresolved as normative or informational]

C1-P1 assigns stage vocabulary ownership to Compiler/Grammar, and the ordered
rule graph includes `stage` fields (`"parse"`, `"classify"`, `"typecheck"`,
`"emit"`) in every rule. The R58 proof validator does not check whether `stage`
values belong to a permitted set. C1-P1 does not resolve whether:

- `stage` names are normative validated fields (requiring a closed enum in the
  PROP);
- or `stage` is informational metadata (the PROP may label but not constrain it).

This is not a blocker for the grammar pressure track or the validator coverage
proof, but it must be decided before PROP authoring. A PROP that defines the
ordered-rule graph vocabulary without specifying whether `stage` is validated
leaves an implementation-facing ambiguity: a contract with `stage: "made_up"`
would pass the current validator silently.

The validator-coverage proof card does not need to address this. The PROP scope
definition card (after validator coverage lands) should include a decision on
`stage` validation scope.

---

[NB-2 — Non-blocking: optional `fragment_class_owners` duplicate case left out of validator-coverage scope]

C1-P1 notes the optional extension of adding a `fragment_class_owners` duplicate
key case to verify registry-general one-owner behavior, but does not require it.
The PROP can claim registry-general semantics because the validator applies the
same loop to all registries.

The validator-coverage card is a convenient opportunity to add this case
alongside the five required ones, at minimal additional effort. If it is not
added in the validator-coverage card, the PROP text should note that the
registry-general one-owner invariant is supported by validator code structure
and the `oof_descriptors` proof case, not by separate `fragment_class_owners`
coverage.

Non-blocking. Record as optional for the validator-coverage card scope.

---

## Verdict

**Proceed.**

All seven scope checks pass. C1-P1 correctly holds PROP authoring. Ownership
assignments are precise and actionable across eleven schema areas. One-owner
registry semantics are concrete with correct scope boundaries.
All five untested validator paths are explicitly named with correct priority and
clear closure conditions. Positional `required_slots` debt is correctly
distinguished from PROP-authoring content. New PROP governance route is
confirmed. All forbidden surfaces remain closed.

Two non-blocking notes: NB-1 (stage field normative vs. informational status —
must be resolved in PROP scope definition); NB-2 (optional `fragment_class_owners`
one-owner proof case — convenient addition to the validator-coverage card).

---

[Route]

**Verdict: proceed.**

No blockers.

**Recommended Architect decision (C3-A):**

1. Accept C1-P1 schema ownership pressure as the R59 formal record. Ownership
   assignments for all eleven schema areas are established. The grammar pressure
   track closes the R58-C3-A PROP-authoring blocker #2/#3/#4.

2. Authorize `compiler-profile-contract-validator-coverage-proof-v0` as the next
   proof-local experiment. Scope must:
   - add proof cases for `missing_rule_reference`, `wrong_kind`,
     `unsupported_format_version`, `descriptor_digest_invalid`, and
     `finalization_payload_digest_invalid`;
   - optionally add `fragment_class_owners` duplicate key case (NB-2);
   - optionally replace positional `required_slots` lookup with named case
     selection;
   - preserve all existing R58 diagnostics and namespace separation;
   - add no implementation behavior.

3. Keep PROP-authoring authorization held until the validator-coverage proof
   lands and a separate Architect decision explicitly opens PROP authoring.
   Include the NB-1 question (stage field normative status) in the PROP scope
   definition — not in the validator-coverage proof.

4. Confirm governance chain: validator-coverage proof → pressure review →
   Architect PROP-authoring authorization → new PROP. Not PROP-036 errata.

5. Implementation authorization, loader/report, CompatibilityReport, dispatch,
   and all production surfaces remain closed.

**For R60:**
- If C3-A opens `compiler-profile-contract-validator-coverage-proof-v0`, R60
  runs that proof-local experiment.
- No other surfaces open from R59.

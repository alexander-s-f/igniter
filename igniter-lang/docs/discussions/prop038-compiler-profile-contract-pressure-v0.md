# Discussion: PROP-038 Compiler Profile Contract Pressure v0

Card: S3-R61-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: prop038-compiler-profile-contract-pressure-v0

Depends on: S3-R61-C1-P1 delivered

Question:

Does PROP-038 stay distinct from PROP-036 and PROP-037? Is the contract object
schema complete and aligned with R60 proof? Are digest semantics normative
rather than proof-local regex prose? Is ordered-rule `stage` decided clearly?
Are `before`/`after` referential integrity, acyclicity, and owner-slot validity
formalized? Is slot assignment clearly declared compiler-understanding ownership
only? Is one-owner registry semantics registry-general? Are diagnostic
vocabularies separated cleanly? Does the proposal preserve progression under
`pipeline` for v0? Does any wording imply implementation, dispatch, runtime,
loader/report, CompatibilityReport, production, or Gate 3 authority?

Context:
- R60-C3-A (gate): Accepted R60 validator coverage proof; lifted R59 PROP-authoring
  hold; assigned PROP-038 to `compiler_profile_contract`; required 17 proposal
  sections and explicit non-authority language; listed 5 blockers before implementation
- R61-C1-P1: Compiler/Grammar Expert — authored PROP-038-compiler-profile-contract-v0.md
  (§1–§19); updated proposals README index; moved loop-class placeholder to PROP-039+

---

## Scope Check 1 — PROP-038 Is Distinct From PROP-036 And PROP-037

**PROP-036 boundary (§2.1):**

| PROP-036 owns | PROP-038 owns |
|---|---|
| `compiler_profile_id` | `compiler_profile_contract` |
| Manifest identity | Contract object schema |
| Finalized `compiler_profile_id_source` transport | Required slot schema |
| Loader/report status vocabulary | Slot assignment semantics |
| | Strict registry one-owner invariant |
| | Ordered-rule graph validity |
| | Contract diagnostic vocabulary |

Relationship stated explicitly:

```text
compiler_profile_contract
  -> finalizes to compiler_profile_id_source
  -> may supply manifest compiler_profile_id through PROP-036 paths
```

The PROP adds: "`compiler_profile_id` remains a compact identity. PROP-038 does
not inline the full contract object into `.igapp/manifest.json`." This closes the
risk of the contract object silently becoming part of the manifest transport. ✓

**PROP-037 boundary (§2.2):**

PROP-037 owns external progression and service liveness semantics. PROP-038 does
not introduce a `progression` slot. The text states: "Any future dedicated
`progression` slot requires a separate Architect decision and proposal/proof
path." ✓

The PROP also carries the queue authority note, which explicitly states the
managed local recursion / loop-class placeholder moves to `PROP-039+`. The
PROP-038 numbering is correctly grounded in the C3-A gate record. ✓

---

## Scope Check 2 — Contract Object Schema Is Complete And Aligned With R60 Proof

**Required section check against C3-A gate (17 sections):**

| C3-A required section | PROP-038 section | Present? |
|---|---|---|
| Status and scope | Queue note, §1 | ✓ |
| Relationship to PROP-036 and PROP-037 | §2 | ✓ |
| Contract object schema | §4 | ✓ |
| Required and optional slot vocabulary | §5 | ✓ |
| Slot assignment semantics | §6 | ✓ |
| Strict registry one-owner invariant | §7 | ✓ |
| Ordered-rule graph semantics | §8 | ✓ |
| Decision on ordered-rule `stage` | §8.3 | ✓ |
| Digest semantics | §9 | ✓ |
| Diagnostic vocabulary | §10 | ✓ |
| Future `profile_not_supplied` shape | §12 | ✓ |
| Progression handling | §2.2 | ✓ |
| Non-authority section | §13 | ✓ |
| OOF / refusal rules | §10.1 | ✓ |
| Proof evidence links | §15 | ✓ |
| Explicit excluded surfaces | §16 | ✓ |
| Open questions / deferred implementation gates | §17, §18 | ✓ |

All 17 required sections present. ✓

**Schema alignment with R60 canonical object:**

The §4 required top-level fields match the R60 proof canonical object exactly:
`kind`, `format_version`, `profile_namespace`, `profile_kind`,
`compiler_profile_id`, `descriptor_digest`, `finalization_payload_digest`,
`required_slot_schema`, `slot_order`, `slot_assignments`, `strict_registries`,
`ordered_rule_graph`, `non_authority`, `contract_digest`. ✓

`kind` must be `"compiler_profile_contract"` ✓  
`format_version` must be `"0.1.0"` ✓

**Acceptance criteria check (§19, 14 items):** All 14 criteria are satisfied
by the authored document. ✓

**Proposals README:** PROP-038 is indexed as `authored-pending-review` with a
description of scope and non-authorization status. ✓

---

## Scope Check 3 — Digest Semantics Are Normative

The R60 pressure review NB-2 required the PROP to express digest formats as
normative specifications, not proof-local regex strings. §9 addresses this.

**§9.1 Descriptor digest:**

```text
compiler_profile_descriptor/sha256:<24+ lowercase hex>
```

Described as: "The hex segment is a SHA-256 digest reference. The v0 proof and
PROP-036 profile ids use short content-addressed references with at least 24
lowercase hexadecimal characters. Full 64-character SHA-256 references are valid
and preferred for durable storage."

**§9.2 Finalization payload digest:**

```text
sha256:<64 lowercase hex>
```

Described as: "computed over canonicalized finalization payload material that
excludes the derived profile id."

**§9.3 Contract digest:**

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

Described as: "computed over canonicalized contract material excluding
`contract_digest` itself."

**§9.4 Digest limits:** "Digest validity proves content-addressed identity. It
does not prove runtime readiness, loader acceptance, signature validity, or
execution authorization."

Assessment:

- R60 NB-2 is substantially closed. The formats are stated as normative
  specification text, not as regex patterns. ✓
- §9.2 (finalization payload digest) is the most precisely specified: required
  format, required length, and stated input material. ✓
- §9.3 (contract digest) correctly identifies what the hash excludes. ✓

**See NB-1.** §9.1 (descriptor digest) states the format and the SHA-256
algorithm but does not say what material the hash is computed over. §9.2 and
§9.3 both provide "computed over..." language; §9.1 does not. The PROP says
the digest "identifies the canonical compiler profile descriptor" but doesn't
state whether the hash input is the full descriptor document, a normalized JSON
form, or a specific byte sequence. This should be aligned with §9.2/§9.3 in a
future revision.

**See NB-2.** §9.1 and §9.3 permit "24+ lowercase hex," allowing short
proof-era references. The finalization payload digest (§9.2) requires the full
64-character form. The dual-validity for descriptor and contract digests is an
intentional v0 proof-compatibility accommodation, acknowledged in §17 open
question 3. Non-blocking; the open question routes the tightening decision to
a future proposal revision or implementation authorization card.

---

## Scope Check 4 — Ordered-Rule `stage` Is Decided Clearly

§8.3 Stage Field Decision:

> `stage` is informational metadata in PROP-038 v0.
>
> R60 did not validate `stage` values against a closed set. Therefore v0 does
> not make `stage` a normative validated vocabulary. Unknown `stage` values must
> not be used as a contract-refusal basis under PROP-038 v0.
>
> A future proposal may promote `stage` to normative validated vocabulary after
> a dedicated proof or implementation gate.

This closes the R59 NB-1 that was carried forward through R60-C3-A. The decision is:

1. Informational metadata in v0 — explicitly stated ✓
2. Unknown values must not cause contract refusal — normative prohibition ✓
3. Promotion path is future-gated — prevents silent scope creep ✓

The §17 open question carries the forward-looking version: "Should
`ordered_rule_graph.stage` become normative validated vocabulary in a future
version?" This preserves the question without resolving it prematurely. ✓

---

## Scope Check 5 — Referential Integrity, Acyclicity, And Owner-Slot Validity Are Formalized

§8.1 Required Validity Rules states all four invariants normatively:

```text
Each rule must have a unique rule_id.
Every owner_slot must be present in slot_order.
Every target in before and after must resolve to a declared rule_id in the same
ordered_rule_graph.rules set.
The directed ordering graph must be acyclic.
```

§8.2 Edge Semantics defines direction:

```text
rule.before target  => rule must run before target
rule.after source   => source must run before rule
```

The referential-integrity rule covers both `before` and `after` directions:
"Every target in `before` and `after` must resolve..." — direction-agnostic at
specification level, even though the R60 proof only tested a missing `before`
reference. ✓

The diagnostic vocabulary in §10 covers all validity rule violations:
- `compiler_profile_contract.missing_rule_reference` ← referential integrity ✓
- `compiler_profile_contract.rule_cycle` ← acyclicity ✓
- `compiler_profile_contract.unknown_rule_owner_slot` ← owner-slot validity ✓

§8.2 also adds the correct scope limit: "These are contract-level ordering
constraints. PROP-038 does not define a live dispatcher that executes them." ✓

The R60-C2-X NB-1 (before-direction only tested) is surfaced in §17 open
question 2: "Should a future proof add a missing-`after` direction case for
`missing_rule_reference`, even though v0 referential integrity is
direction-agnostic?" The PROP correctly names this as a proof improvement
question, not a specification gap. ✓

---

## Scope Check 6 — Slot Assignment Is Clearly Declared Ownership Only

§6 Slot Assignment Semantics:

```text
slot assignment = declared compiler-understanding ownership
```

Explicit non-meanings:

```text
slot assignment != handler execution
slot assignment != live dispatch binding
slot assignment != dynamic pack loading
slot assignment != runtime authority
```

The distinction is sharpened in the surrounding prose:

> "`implementation_id` identifies the implementation/adapter identity that the
> profile claims for a slot. `pack_name` is descriptive profile material. Neither
> field authorizes the current compiler to call a pack."

This closes the most important authority-leak path at the PROP level. A future
implementation or dispatch card cannot treat `implementation_id` as a dispatch
instruction without a separate authorization decision. ✓

The non-authority chain in §13 reinforces this:

```text
valid compiler_profile_contract != dispatch binding
```

And: "compiler_profile_contract does not authorize dynamic pack loading." ✓

---

## Scope Check 7 — One-Owner Registry Semantics Are Registry-General

§7.1 One-Owner Invariant:

> "Within one strict registry: one key must have exactly one owner entry."

The "within one strict registry" scope is registry-general — it applies to any
entry in `strict_registries`, not only `oof_descriptors`. ✓

The scope boundary is correctly stated:

> "This invariant is closed within the contract object being validated. It does
> not claim that the language can never add new keys in a future proposal."

This matches the R59 accepted ownership formulation exactly. ✓

§7.2 Owner Slot Validity is also stated registry-general:

> "Every `owner_slot` in a strict registry entry must be present in `slot_order`."

The R60 proof covers both `oof_descriptors` and `fragment_class_owners` with
duplicate-key cases. The PROP can correctly claim registry-general semantics. ✓

---

## Scope Check 8 — Diagnostic Vocabularies Are Separated Cleanly

§11 Vocabulary Separation provides a four-column table:

| Vocabulary | Owns | Example |
|---|---|---|
| `compiler_profile_contract.*` | Contract object validity | `compiler_profile_contract.missing_required_slot` |
| `compiler_profile_source.*` | Source transport validity | `compiler_profile_source.id_digest_mismatch` |
| `compiler_profile_obligation.*` | Surface/slot coverage | `compiler_profile_obligation.missing_slot` |
| Loader/report status | Manifest/rollout interpretation | `missing_required`, `present_verified` |

Three-way separation rule (§11):

```text
compiler_profile_contract.missing_required_slot
  != compiler_profile_obligation.missing_slot
  != loader/report missing_required
```

With distinct meanings:
1. `missing_required_slot`: contract object lacks a schema-required slot
2. `missing_slot`: emitted program surfaces require a slot the supplied profile did not cover
3. `missing_required`: manifest lacks `compiler_profile_id` under future `profile_required` policy

§10 provides all 12 diagnostic codes, all correctly namespaced under
`compiler_profile_contract.*`. ✓

The key scope limit in §10: "Invalid contract diagnostics are refusal rules for
the contract object only. They do not create compile-time refusal behavior in
the current compiler unless a later implementation card explicitly authorizes
that behavior." This prevents the diagnostic vocabulary from accidentally
becoming a compile-time enforcement gate. ✓

---

## Scope Check 9 — Progression Under `pipeline` Preserved For v0

§2.2 Relationship To PROP-037:

```text
For v0 profile contracts:
  progression_descriptor metadata remains under pipeline
```

> "Any future dedicated `progression` slot requires a separate Architect decision
> and proposal/proof path."

§17 carries the forward-looking open question: "When should a dedicated PROP-037
`progression` slot be considered?"

The PROP-037 gate is correctly maintained through three consecutive proposals
(PROP-036, PROP-037, PROP-038). No `progression` slot is introduced, and the
decision path for future introduction is clearly named. ✓

---

## Scope Check 10 — No Forbidden Authority Implied

**Non-authority language (§13)** includes all C3-A required text verbatim:

```text
compiler_profile_contract grants no runtime authority.
compiler_profile_contract grants no dispatch migration authority.
compiler_profile_contract does not authorize dynamic pack loading.
compiler_profile_contract does not authorize loader/report behavior.
compiler_profile_contract does not authorize CompatibilityReport behavior.
compiler_profile_contract does not authorize production behavior.
```

And the chain:

```text
valid compiler_profile_contract != runtime evaluation readiness
valid compiler_profile_contract != loader/report present_verified
valid compiler_profile_contract != obligation coverage success
valid compiler_profile_contract != dispatch binding
```

**Excluded surfaces (§16)** explicitly names: parser, TypeChecker, SemanticIR,
assembler/`.igapp`, CLI/API, profile discovery, loader/report, CompatibilityReport,
`.ilk`, receipts, signing, dispatch migration, dynamic pack loading, RuntimeMachine/
Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, production behavior. ✓

**Deferred implementation gates (§18)** correctly holds:
1. Separate PROP acceptance governance decision ✓
2. Separate implementation authorization with exact write scope ✓
3. Card must state report-only vs. compile-refusal ✓
4. Artifact mutation policy if persisted ✓
5. Loader/report, CompatibilityReport, dispatch, runtime/production all separately gated ✓

**Queue authority note** states the PROP does not authorize any code or behavior
change. The authoring card scope also prohibited editing code or experiments. ✓

**§14 Validation Order** carries the implementation-state disclaimer:

> "The SemanticIR profile-obligation checkpoint is a proposed future design
> position, not current implementation."

The R57 NB-1 disclaimer requirement survives through PROP-038. ✓

---

[Agree]

1. **Scope distinction is precise and grounded.** §2.1 and §2.2 draw the
   PROP-036/PROP-037 boundaries with concrete ownership tables. The "does not
   inline the full contract object into `.igapp/manifest.json`" statement
   closes the most natural scope-creep path.

2. **All 17 C3-A required sections are present and all 14 acceptance criteria
   are met.** The PROP is structurally complete.

3. **`stage` is decided correctly.** Informational metadata for v0, with an
   explicit prohibition on using unknown stage values as a refusal basis, and a
   named future-gate path. This closes R59 NB-1 at the PROP level.

4. **Referential integrity, acyclicity, and owner-slot validity are normative
   ("must") language.** Both `before` and `after` directions are covered by the
   specification-level invariant, even though only one direction was proof-tested.

5. **Slot assignment non-meanings are precise.** The `implementation_id` and
   `pack_name` explanation prevents these fields from being misread as dispatch
   instructions. The chain `!= handler execution != live dispatch binding !=
   dynamic pack loading != runtime authority` is the strongest statement in the
   PROP.

6. **One-owner invariant is correctly registry-general.** "Within one strict
   registry" applies to any registry entry; the scope boundary ("closed within
   the contract object") prevents over-claiming.

7. **Vocabulary separation is explicit in two places.** §10 names all 12 codes
   under `compiler_profile_contract.*`; §11 provides the four-row table and the
   three-way semantic distinction. Both placements are necessary.

8. **Non-authority language matches C3-A required text exactly.** No required
   clause is missing. The `valid != ...` chain extends to four terms: runtime
   readiness, `present_verified`, obligation coverage, dispatch binding.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect acceptance decision.

---

[NB-1 — Non-blocking: §9.1 descriptor digest does not state what material the hash is computed over]

§9.2 and §9.3 both include "computed over..." language:
- §9.2: "computed over canonicalized finalization payload material that excludes the derived profile id"
- §9.3: "computed over canonicalized contract material excluding `contract_digest` itself"

§9.1 says: "The hex segment is a SHA-256 digest reference" — names the algorithm
but does not say what the hash is computed over. An implementor reading §9.1
knows the format and the algorithm but must infer the input material.

Recommendation: a future PROP-038 revision or the implementation authorization
card should add: "The hex segment is a SHA-256 digest computed over the
canonical serialized compiler profile descriptor content." This is consistent
with the other digest sections and removes the inference requirement.

Non-blocking for PROP acceptance. Recommend adding to §17 open questions or
addressing in the first implementation card.

---

[NB-2 — Non-blocking: §9.1 and §9.3 permit 24+ hex; dual-validity is intentional but implementors need guidance]

Both descriptor digest (§9.1) and contract digest (§9.3) permit "24+ lowercase
hex" while the finalization payload digest (§9.2) requires exactly 64 characters.
The PROP acknowledges this in the note "Full 64-character SHA-256 references are
valid and preferred for durable storage" and explicitly raises it in §17 open
question 3.

This is an intentional v0 proof-compatibility accommodation: the R60 proof used
short content-addressed references. The dual-validity is correctly surfaced.

However, an implementation or tooling that stores contract digests for later
verification must choose between accepting short references (validation risk)
and requiring full 64-character references (proof incompatibility until the
proof is updated). The §17 question routes this decision correctly.

Non-blocking. The open question is the right vehicle for resolution.

---

## Verdict

**Proceed.**

All ten scope checks pass. PROP-038 is structurally complete with all 17
required sections and all 14 acceptance criteria met. Distinction from PROP-036
and PROP-037 is explicit and grounded. Contract object schema matches the R60
canonical proof object. Digest semantics are normative text (NB-1 and NB-2 are
non-blocking). `stage` is resolved as informational metadata with correct future
gating. Referential integrity, acyclicity, and owner-slot validity are all
"must"-level invariants. Slot assignment non-meanings are precise and close the
dispatch-leak path. One-owner invariant is registry-general. Diagnostic
vocabularies are separated in two independent sections (§10, §11). Progression
stays under `pipeline`. No forbidden authority is implied; non-authority language
matches C3-A required text exactly; implementation gates are all separately
required.

Two non-blocking notes: NB-1 (§9.1 descriptor digest lacks "computed over..."
language present in §9.2/§9.3); NB-2 (24+ hex dual-validity for descriptor and
contract digests is intentional and correctly routed to §17 open question 3).

---

[Route]

**Verdict: proceed.**

No blockers.

**Recommended Architect decision (C3-A):**

1. Accept PROP-038 as authored. The proposal satisfies all C3-A required
   sections and the R57-R60 evidence chain.

2. Record PROP-038 status as `accepted-pending-implementation` (or equivalent
   governance status in the proposal index).

3. Implementation authorization remains held. The first implementation
   authorization card must:
   - name exact write scope in the compiler (which file/class/path receives the
     validator);
   - decide whether validation is report-only or can refuse compilation (§18
     item 3);
   - address §9.1 descriptor digest "computed over" specification (NB-1);
   - decide the full 64-character digest requirement for durable storage (NB-2);
   - name a golden/artifact mutation policy if contract validation output
     becomes persisted.

4. Loader/report, CompatibilityReport, dispatch migration, RuntimeMachine/Gate 3,
   and production surfaces remain closed.

5. PROP-037 `progression` slot question remains open for a later decision.

**For R62:**
- If C3-A accepts PROP-038, the next work is either a separate implementation
  authorization card or a follow-up proof/design card for any of the §17 open
  questions.
- NB-1 (descriptor digest input specification) should be addressed in the
  implementation card scope definition, not in a separate proof round.
- NB-2 (short vs. full digest dual-validity) should be resolved before the
  implementation card writes any digest comparison code.

# Discussion: PROP-038 Contract Digest Validation Policy Pressure v0

Card: S3-R68-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-contract-digest-validation-policy-pressure-v0

Depends on: S3-R68-C1-P1 delivered

Question:

Does the policy keep `descriptor_digest` and `contract_digest` cleanly separated?
Is canonicalization material explicit if recomputation is proposed? Is shape-only
validation correctly distinguished from integrity proof? Is mismatch validation
guarded from accidentally becoming compile refusal? Is the proposed diagnostic
vocabulary precise and free of hidden authority implications? Does report-only
behavior remain report-only? Does the card avoid authorizing implementation,
public surfaces, loader/report, CompatibilityReport, RuntimeMachine, Gate 3, or
production behavior?

Context:
- R67-C3-A (gate): Accepts Candidate A report-only compiler integration; closes
  R66 authorization; `contract_digest` validation remains deferred; any future
  move toward digest validation requires a separate design/pressure/Architect
  chain
- R67-C2-X (pressure): Proceed; no blockers; no non-blocking notes
- R68-C1-P1: Compiler/Grammar Expert — design-only track; recommends hybrid
  policy; keeps current validator at `prop038_24_plus` with no `contract_digest`
  checks now; designs two-phase future path (shape-only proof, then
  recompute-match proof); no code changed

---

## Scope Check 1 — `descriptor_digest` And `contract_digest` Are Kept Cleanly Separated

The design provides an explicit comparison table:

| Field | Identifies | Recompute material |
| --- | --- | --- |
| `descriptor_digest` | Compiler profile descriptor identity | Descriptor object/document (not currently supplied) |
| `contract_digest` | Whole compiler profile contract identity | Contract object excluding `contract_digest` |

Five explicit rules enforce the boundary:

1. Contract digest recomputation must not attempt to recompute `descriptor_digest`.
2. Contract digest canonicalization includes `descriptor_digest` as a string field
   value — its declared string becomes input material, not a separately-resolved
   descriptor object.
3. A malformed `descriptor_digest` remains `compiler_profile_contract.descriptor_digest_invalid`;
   it is not re-diagnosed as a `contract_digest` problem.
4. A mismatched `descriptor_digest` against external descriptor material is not a
   `contract_digest` mismatch unless the contract object's own digest also fails.
5. Descriptor material discovery remains out of scope for the current validator.

These five rules together prevent the two most common conflation paths: (a)
using descriptor material to validate the contract digest, and (b) treating a
descriptor format error as evidence of contract digest corruption.

The Phase 2 proof matrix includes a direct test:

```text
canonical_does_not_recompute_descriptor_material
→ Missing descriptor material does not become descriptor recompute behavior.

canonical_includes_descriptor_digest_string
→ Changing descriptor_digest string changes recomputed contract digest input.
```

The first case guards against scope creep into descriptor material. The second
confirms that `descriptor_digest` participates as a field value, not as an
independently resolved identity. ✓

---

## Scope Check 2 — Canonicalization Material Is Explicit

The design provides a complete, named list of canonicalization inputs.

Included top-level fields (13):

```text
kind, format_version, profile_namespace, profile_kind, compiler_profile_id,
descriptor_digest, finalization_payload_digest, required_slot_schema,
slot_order, slot_assignments, strict_registries, ordered_rule_graph, non_authority
```

Excluded fields (explicitly named):

```text
contract_digest (excluded from its own digest input)
validation result fields, report_only, compiler_integrated, compile_refusal_authorized
provider metadata, source_path, out_path, parsed_program, compiler_profile_source
```

Canonicalization rules by material type:

| Material | Rule |
| --- | --- |
| Object keys | Sort recursively by UTF-8 string key |
| `slot_order` | Preserve order (order is semantic) |
| `required_slot_schema.{required,optional,all}_slots` | Preserve declared order for v0 |
| `slot_assignments` | Sort slot keys recursively |
| `strict_registries` | Sort registry names; sort entries by `[key, owner_slot, rule_ref]` |
| `ordered_rule_graph.rules` | Sort by `rule_id` |
| Rule `before`/`after` arrays | Sort unique rule ids for digest material |

The asymmetry between order-preserving fields (`slot_order`, slot schema arrays)
and order-normalizing fields (registries, rule graph) is explicit and correct:
`slot_order` carries semantic meaning; registry and rule graph entry order does not.

The design explicitly separates:

```text
canonicalization for digest
validation rules for contract correctness
```

And states: "Canonicalization should not silently fix invalid contract semantics.
It only normalizes material for hashing." ✓

The Phase 2 proof matrix reinforces this with specific canonicalization invariant
cases — including `canonical_rule_reference_still_validated` which asserts that
missing rule references still produce `missing_rule_reference` diagnostics and
that canonicalization does not hide invalidity. ✓

---

## Scope Check 3 — Shape-Only Validation Is Not Presented As Integrity Proof

The design clearly separates validation levels:

**Shape-only (Phase 1):** validates that `contract_digest` matches the reference
format:

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

Diagnostic: `compiler_profile_contract.contract_digest_invalid`

**Integrity (Phase 2):** canonicalizes the contract material, recomputes
SHA-256, compares against the declared value.

Diagnostic: `compiler_profile_contract.contract_digest_mismatch`

These are two distinct diagnostic codes under two distinct policy phases. A
consumer cannot confuse format validity with integrity because:

1. The diagnostics have different names.
2. The policy options table names them separately: shape-only and recompute-match.
3. The Phase 1 proof matrix has no recompute cases.
4. The Phase 2 proof matrix has explicit distinction between prefix match
   (`recompute_prefix_match`) and mismatch (`recompute_full_mismatch`,
   `recompute_prefix_mismatch`).

The short-answer table is explicit:

```text
Is full recomputation stable enough to design? Yes, as a design target.
Is full recomputation stable enough to implement now? No.
```

No shape-only result is described as proving contract integrity. ✓

---

## Scope Check 4 — Mismatch Validation Is Not Accidentally Compile Refusal

The report-only section states the default rule with no exceptions:

```text
contract_digest diagnostics remain report-only
```

Eight properties that must not change even after future mismatch implementation:

```text
compile status, pass_result, stages, compiler diagnostics, public result,
assembler execution, .igapp manifest, refusal report creation
```

Compile refusal is guarded by a four-condition prerequisite chain:

```text
1. PROP-038 contract digest policy is accepted or amended.
2. Shape-only and recompute-match proofs pass.
3. Report-only integration proves digest diagnostics are stable.
4. A separate compile-refusal gate explicitly authorizes refusal and exact write scope.
```

The design states explicitly: "This card does not open that path."

The Phase 2 integration checks directly machine-assert the report-only invariant
for mismatch:

```text
mismatch still returns compile status ok
mismatch does not alter public result
mismatch does not mutate .igapp
mismatch does not write refusal report
provider exception still behaves as nil
```

These mirror the seven invariant checks from R67-C2-X Scope Check 5, which
established the behavioral pattern for the existing report-only path. Future
mismatch diagnostics must pass the same battery. ✓

---

## Scope Check 5 — Diagnostic Vocabulary Is Precise And Free Of Authority Implications

Four proposed future diagnostic codes:

| Code | Meaning | Phase |
| --- | --- | --- |
| `compiler_profile_contract.contract_digest_invalid` | Format or reference shape failure | 1 (shape-only) |
| `compiler_profile_contract.contract_digest_policy_unsupported` | Caller selected policy the validator does not support | 1 (shape-only) |
| `compiler_profile_contract.contract_digest_recompute_unavailable` | Policy requires recomputation but capability is unavailable | 2 (recompute-match) |
| `compiler_profile_contract.contract_digest_mismatch` | Recomputed SHA-256 does not match declared reference | 2 (recompute-match) |

All four are under `compiler_profile_contract.*` namespace. None reference:

- OOF authority;
- runtime authority;
- dispatch migration authorization;
- loader/report status terms (`absent_legacy`, `present_verified`, `mismatch` in
  the loader sense);
- obligation coverage terms.

The four-layer vocabulary separation established in R57-R67 is preserved:
`compiler_profile_source.*` / `compiler_profile_obligation.*` /
`compiler_profile_contract.*` / loader/report status. None of the proposed codes
cross namespace boundaries. ✓

`contract_digest_recompute_unavailable` is the most novel code. It signals that
a policy requiring recomputation was selected but the validator cannot satisfy it —
a graceful degradation for when implementation capability lags behind policy
selection. This does not imply any authority; it reports a validator limitation.
It cannot change compile outcome because all four codes remain report-only by
design. ✓

The design restricts diagnostic placement:

```text
Do not add these to IgniterLang::Diagnostics without a separate diagnostics
centralization decision.
Do not append these to top-level report["diagnostics"] without a separate
report integration decision.
```

Diagnostic location is: `report["compiler_profile_contract_validation"]["diagnostics"]` —
the same nested location established by R67. ✓

---

## Scope Check 6 — Report-Only Behavior Remains Report-Only Throughout

The design explicitly names the default rule:

```text
contract_digest diagnostics remain report-only
```

The future policy options table shows no option that permits compile refusal as
a side effect of digest validation. The four options are: deferred, shape-only,
recompute-match, hybrid — all report-only.

The design's non-authorization section explicitly lists compile refusal as
not authorized by this track. The 4-condition prerequisite chain (Scope Check 4)
means compile refusal cannot be reached from this card by any chain of
implementation decisions — it requires its own gate.

The diagnostic location (`report["compiler_profile_contract_validation"]["diagnostics"]`)
keeps digest diagnostics nested inside the validation result, which is itself
nested inside the in-memory `CompilationReport` field. This is the same structure
accepted in R67, and it cannot affect public output because `CompilerResult.public_result`
strips the `"report"` key entirely.

The Phase 2 proof matrix explicitly requires checking the R67 path at every step:
valid digest attaches `valid=true`; mismatch attaches `valid=false`; mismatch
still returns compile status `ok`; mismatch does not alter public result; mismatch
does not write refusal report. ✓

---

## Scope Check 7 — No Implementation, Public Surface, Loader/Report, Or Production Authority Implied

The track declares explicitly:

```text
No implementation is recommended from this card.
```

The non-authorization list is comprehensive and matches the full R57-R67 hold
inventory:

```text
implementation, compile refusal, public API/CLI widening, CompilerResult changes,
persisted success reports or sidecars, parser/TypeChecker/SemanticIR/assembler/.igapp,
loader/report behavior, CompatibilityReport behavior, IgniterLang::Diagnostics
centralization, RuntimeMachine / Gate 3 widening, Ledger/TBackend, BiHistory,
stream/OLAP production execution, cache, production behavior
```

The smallest implementation slice described is gated behind explicit conditions:

```text
Allowed only after Phase 1 proof/design acceptance.
```

The recommendation for C3-A explicitly separates the current card from any
implementation:

```text
Open a proof-local prop038-contract-digest-shape-policy-proof-v0 route.
Hold implementation. Hold recompute-match implementation. Hold compile refusal.
```

The next-card suggestion scope is itself proof-local only:

```text
produce summary JSON only under an experiment directory;
do not edit compiler integration paths;
do not mutate .igapp;
do not change public API/CLI, CompilerResult, loader/report, or CompatibilityReport.
```

No design decision in this track implies a write to any production file. ✓

---

[Agree]

1. **Descriptor/contract digest separation is clean and explicit.** Five named
   rules, two proof cases, and a table with "Recompute material" column each
   targeting a different thing. A future implementer cannot confuse the two
   without violating a named constraint.

2. **Canonicalization material is complete and explicit.** 13 included fields,
   explicitly named excluded fields, per-field canonicalization rules, and the
   correct asymmetry between semantic-order fields (preserve) and unordered
   fields (normalize). Separation from validation logic is stated.

3. **Shape-only and recompute-match are distinct phases with distinct diagnostics.**
   `contract_digest_invalid` (format) and `contract_digest_mismatch` (integrity)
   are different codes with different proof phases. Short answer table explicitly
   says recomputation is not implementation-ready.

4. **Mismatch-to-refusal path has a four-condition gate.** Conditions 1–3 are
   sequential proofs; condition 4 is an explicit separate gate. This card does
   not open the refusal path. Future cards cannot reach refusal by inference
   alone.

5. **Diagnostic vocabulary is clean.** Four new codes under `compiler_profile_contract.*`,
   none crossing vocabulary namespace boundaries, none implying authority.
   `contract_digest_recompute_unavailable` is correctly scoped as a graceful
   degradation code for policy-vs-capability gap.

6. **Report-only invariant is carried forward intact.** Phase 2 proof requirements
   include the full R67 battery for mismatch. The diagnostic location is the same
   nested structure accepted in R67. Public result stripping continues unchanged.

7. **Two-phase proof approach is the correct sequencing.** Shape-only first
   limits blast radius; recompute-match second proves the harder canonicalization
   invariants before any implementation touches the compiler. The 14-case Phase 2
   proof matrix is thorough.

8. **No implementation or production surface is opened.** Design-only card from
   a grammar/compiler expert role. Non-authorization list matches R57-R67 hold
   inventory.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

## Verdict

**Proceed.**

All seven scope checks pass. Descriptor and contract digests are explicitly
separated with five named rules and two direct proof cases. Canonicalization
material is fully enumerated with per-field rules and correct semantic/non-semantic
ordering asymmetry. Shape-only validation is distinguished from integrity proof by
separate diagnostic codes and separate proof phases. Mismatch cannot accidentally
become compile refusal — the four-condition prerequisite chain is explicit and
this card does not open that path. The four proposed diagnostic codes are
namespace-clean and carry no hidden authority implications. Report-only behavior
is maintained with a required Phase 2 integration proof battery mirroring R67's
invariant checks. No implementation, public surface, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, or production authority is implied.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the hybrid policy: keep current validator at `prop038_24_plus` with no
   `contract_digest` checks for now; future digest validation proceeds through
   a two-phase proof sequence.

2. Authorize the next proof-local design card:
   ```text
   prop038-contract-digest-shape-policy-proof-v0
   ```
   Scope: exercise Phase 1 shape-only matrix (8 cases plus regression checks);
   produce summary JSON under an experiment directory only; no compiler
   integration edit; no golden/fixture mutation.

3. Hold Phase 2 recompute-match implementation until Phase 1 proof is accepted
   and separate canonicalization design is authorized.

4. Hold compile refusal. The four-condition prerequisite chain (PROP-038 policy
   amendment, Phase 1 proof, Phase 2 proof, explicit refusal gate) is correct and
   must be satisfied in sequence.

5. Confirm that future `contract_digest_*` diagnostics live in
   `report["compiler_profile_contract_validation"]["diagnostics"]` — the same
   nested path accepted in R67 — and are not appended to `report["diagnostics"]`
   or centralized in `IgniterLang::Diagnostics`.

6. Confirm that PROP-038 should not be amended for `contract_digest_*` vocabulary
   until Phase 1 and Phase 2 proofs stabilize. A separate PROP-038 errata card
   adds the vocabulary once proofs pass.

7. All surfaces held in R67-C3-A remain closed: compile refusal, public API/CLI,
   `CompilerResult`, persisted reports, sidecars, assembler/`.igapp`, loader/report,
   CompatibilityReport, `IgniterLang::Diagnostics`, RuntimeMachine, Gate 3,
   and production behavior.

# Discussion: PROP-038 Contract Digest Errata Pressure v0

Card: S3-R72-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: canon-pressure
Mode: discussion
Initiator: user
Track: prop038-contract-digest-errata-pressure-v0

Depends on: S3-R72-C1-P1 delivered

Question:

Are all four `contract_digest_*` codes present and correctly worded? Is
diagnostic placement nested/report-only and not top-level? Does the
canonicalization material match R70? Are short-vs-full digest references
consistent with R69/R70? Is `descriptor_digest` explicitly not
recomputed as part of the contract digest? Is compile refusal explicitly
closed? Is live validator/compiler implementation explicitly held? Is no
public API/CLI, `.igapp`, loader/report, CompatibilityReport,
RuntimeMachine, Gate 3, or production authority implied? Are proof
references to R69/R70/R71 accurate?

Context:
- R71-C3-A (gate): Accepts proof-local report-only integration closure;
  authorizes `prop038-contract-digest-errata-authoring-v0` as
  documentation-only; vocabulary stable for PROP-038 errata but not for
  live implementation
- R71-C2-X (pressure): Proceed; no blockers; no non-blocking notes
- R72-C1-P1: Compiler/Grammar Expert — documentation-only authoring;
  updates `PROP-038-compiler-profile-contract-v0.md` only; adds §9.5,
  §9.6, four diagnostic codes in §10, §10.2, §10.3, and §15 proof
  references; no code or experiments edited

---

## Scope Check 1 — All Four `contract_digest_*` Codes Are Present And Correctly Worded

PROP-038 §10 diagnostic vocabulary table now contains 16 entries.
The four new codes appear in digest position (after
`finalization_payload_digest_invalid`) with the following text:

| Code | Stated meaning |
| --- | --- |
| `compiler_profile_contract.contract_digest_invalid` | `contract_digest` is missing or does not match accepted reference shape. |
| `compiler_profile_contract.contract_digest_policy_unsupported` | Selected contract digest policy is not supported. |
| `compiler_profile_contract.contract_digest_mismatch` | Declared `contract_digest` does not match recomputed canonical contract digest. |
| `compiler_profile_contract.contract_digest_recompute_unavailable` | Recompute was requested but canonicalization/recompute support is unavailable. |

Cross-checking against proof-chain sources:

- R69 proof-local: `contract_digest_invalid` → "contract_digest must be compiler_profile_contract/sha256:<24+ lowercase hex>" / `contract_digest_policy_unsupported` → "unsupported contract_digest policy..." ✓
- R70 proof-local: `contract_digest_mismatch` → "declared contract_digest does not match recomputed canonical contract digest" / `contract_digest_recompute_unavailable` → "contract digest recompute requested but canonicalization is unavailable" ✓
- R71-C3-A accepted vocabulary table: all four codes accepted ✓

The PROP-038 table wording generalizes the proof-local message strings into
normative code meanings, which is the correct authoring pattern — proof
messages are concrete; proposal meanings are normative. The
generalizations are accurate:

- `contract_digest_invalid` covers both "missing" and "format failure" — confirmed by R69 cases `missing_contract_digest` (nil field) and `contract_digest_too_short` / `contract_digest_non_hex` / etc. (format failures).
- `contract_digest_policy_unsupported` identifies the policy selection layer, not the digest value.
- `contract_digest_mismatch` correctly scopes to "recomputed canonical" — not a general mismatch.
- `contract_digest_recompute_unavailable` correctly identifies a capability gap, not a value error.

All four codes are under `compiler_profile_contract.*`. None cross namespace
boundaries. None introduce loader/report, OOF authority, or runtime semantics. ✓

---

## Scope Check 2 — Diagnostic Placement Is Nested/Report-Only And Not Top-Level

§10.2 `Contract Digest Diagnostic Placement` states three placement rules:

```text
If implemented later, digest diagnostics belong under:
  report["compiler_profile_contract_validation"]["diagnostics"]

Must not be appended to:
  report["diagnostics"]

Must not be centralized in:
  IgniterLang::Diagnostics
without a separate Architect decision.
```

These three rules match R71-C3-A's accepted diagnostic placement exactly.
The path `report["compiler_profile_contract_validation"]["diagnostics"]`
matches the accepted report field shape from R67-C3-A and all subsequent
decisions.

§10.2 opens with: "The four `contract_digest_*` diagnostics are accepted
as design/proof vocabulary only. They are not live validator
implementation authority." This directly guards against the errata text
being read as implementation permission.

§10.3 records the report-only behavioral invariants. The prose in §10.3
uses "do not change" — not "should not change" — signaling normative
constraint. ✓

---

## Scope Check 3 — Canonicalization Material Matches R70

§9.6 `Contract Digest Canonicalization Material` records:

**Included fields (13):**

```text
kind, format_version, profile_namespace, profile_kind,
compiler_profile_id, descriptor_digest, finalization_payload_digest,
required_slot_schema, slot_order, slot_assignments, strict_registries,
ordered_rule_graph, non_authority
```

Cross-check against R70 `CANONICAL_CONTRACT_FIELDS` constant:

```ruby
CANONICAL_CONTRACT_FIELDS = %w[
  kind format_version profile_namespace profile_kind compiler_profile_id
  descriptor_digest finalization_payload_digest required_slot_schema
  slot_order slot_assignments strict_registries ordered_rule_graph
  non_authority
].freeze
```

Exact match, same 13 fields, same ordering. ✓

**Excluded fields:**

```text
contract_digest, validation result fields, report_only,
compiler_integrated, compile_refusal_authorized, provider metadata,
source_path / out_path, parsed_program, compiler_profile_source
```

Cross-check against R70 `canonical_input_excludes` in every case result:

```json
["contract_digest", "validation result fields", "report_only",
 "compiler_integrated", "compile_refusal_authorized",
 "provider metadata", "source_path", "out_path",
 "parsed_program", "compiler_profile_source"]
```

Exact match in substance. PROP-038 compacts `source_path / out_path` onto
one line but covers the same fields. ✓

**Canonicalization rules (7):**

```text
- object keys sort recursively
- slot_order remains order-sensitive
- strict registry names and entries are order-insensitive
- ordered-rule list order is order-insensitive
- before and after edge arrays are treated as sorted unique sets
- descriptor_digest is included as a string field value
- descriptor material is not fetched or recomputed
```

Cross-check against R70-C3-A accepted rules:

```text
- object keys sort recursively ✓
- slot_order remains order-sensitive ✓
- strict registry names and entries are order-insensitive ✓
- ordered-rule list order is order-insensitive ✓
- before/after edge arrays are treated as sorted unique sets ✓
- descriptor_digest is included as a string field value ✓
- descriptor material is not fetched or recomputed ✓
```

Exact match on all seven rules. ✓

§9.6 also correctly conditions the canonicalization section: "If
recomputation is enabled by a later implementation decision..." — this
scoping prevents the design text from being misread as implementation
authorization. ✓

---

## Scope Check 4 — Short-Vs-Full Digest References Are Consistent With R69/R70

§9.3 defines the `contract_digest` v0 reference format:

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

§9.5 expands the policy:

```text
The accepted reference shape remains:
  compiler_profile_contract/sha256:<24+ lowercase hex>
Full 64-character SHA-256 references are valid under this shape.
Short references are prefix references under prop038_24_plus.
```

This correctly captures the R69 proof behavior:

- R69 case `valid_short_contract_digest` — 24 characters accepted ✓
- R69 case `valid_full_contract_digest` — 64 characters accepted ✓
- R70 cases `recompute_full_match` / `recompute_prefix_match` — full and prefix matching ✓

The characterization "Short references are prefix references" is accurate
and important: a 24-character reference is not a full durable identity but
a prefix identity under `prop038_24_plus`. This matches R70's match logic
(`computed.start_with?(declared_hex)`).

§17 defers the question of requiring 64-character references for durable
storage as an open question. This is the correct posture — the current
design accepts short references; full-only policy is a future decision
that requires its own gate. ✓

---

## Scope Check 5 — `descriptor_digest` Is Not Recomputed As Part Of Contract Digest

§9.6 carries two explicit statements:

```text
descriptor_digest is included as a string field value
descriptor material is not fetched or recomputed
```

And in the closing paragraph of §9.6:

```text
descriptor_digest and contract_digest remain separate identities.
descriptor_digest identifies descriptor material.
contract_digest identifies the contract object and includes the
descriptor_digest string value as part of canonical contract material.
```

This paragraph precisely states the relationship:
- `descriptor_digest` participates in the contract digest computation as its
  declared string value (an element of the canonical material).
- It does not trigger a separate descriptor object fetch or independent
  digest computation.
- The two digest fields remain separate identities with separate purposes.

This matches R70's three-case machine proof:
- `canonical_does_not_recompute_descriptor_material`: `descriptor_material_accessed: false`, `descriptor_digest_included_as_string: true`
- `canonical_includes_descriptor_digest_string`: changing the string changes the contract digest
- R68-C1-P1 design rule: "Contract digest canonicalization includes the `descriptor_digest` string as a field value — its declared string becomes input material, not a separately-resolved descriptor object."

The PROP-038 text accurately encodes all three aspects. ✓

---

## Scope Check 6 — Compile Refusal Remains Explicitly Closed

Three independent locations in PROP-038 close compile refusal:

**§10 preamble:**

```text
Invalid contract diagnostics are refusal rules for the contract object
only. They do not create compile-time refusal behavior in the current
compiler unless a later implementation card explicitly authorizes that
behavior.
```

**§10.3 closing sentence:**

```text
Compile refusal remains closed. Any future refusal behavior requires a
separate explicit gate after live implementation and report-only behavior
are accepted.
```

**§18 deferred implementation gate #3:**

```text
The implementation card must state whether validation is report-only or
can refuse compilation.
```

These three statements together satisfy the four-condition chain from
R68-C3-A: condition 5 requires a separate compile-refusal gate after
live implementation and report-only behavior are both proven stable.
§10.3 places the refusal closure inside the diagnostic behavior rules
where it is most visible to a future implementer. ✓

---

## Scope Check 7 — Live Validator/Compiler Implementation Remains Explicitly Held

Three independent locations hold implementation:

**§10.2 opening sentence:**

```text
The four contract_digest_* diagnostics are accepted as design/proof
vocabulary only. They are not live validator implementation authority.
```

**§9.5 policy statement:**

```text
live validator implementation remains held
compile refusal remains closed
```

**§18 deferred implementation gates (7 conditions):**

```text
1. PROP-038 must be reviewed and accepted by a separate governance
   decision.
2. A separate implementation authorization must name exact write scope.
3–7. Additional per-surface gates.
```

The track document also confirms: "No code or experiments were edited.
No new PROP number was created." — the authoring is documentation-only
as required by R71-C3-A. ✓

---

## Scope Check 8 — No Public API/CLI, `.igapp`, Loader/Report, CompatibilityReport, RuntimeMachine, Gate 3, Or Production Authority Implied

PROP-038 §13 Non-Authority Boundary provides a machine-readable
assertion block for the proposal itself:

```text
compiler_profile_contract grants no runtime authority.
compiler_profile_contract grants no dispatch migration authority.
compiler_profile_contract does not authorize dynamic pack loading.
compiler_profile_contract does not authorize loader/report behavior.
compiler_profile_contract does not authorize CompatibilityReport behavior.
compiler_profile_contract does not authorize production behavior.
```

And the four "also" equalities:

```text
valid compiler_profile_contract != runtime evaluation readiness
valid compiler_profile_contract != loader/report present_verified
valid compiler_profile_contract != obligation coverage success
valid compiler_profile_contract != dispatch binding
```

§16 Explicit Excluded Surfaces enumerates 19 excluded surfaces
including CLI/Ruby API widening, assembler/`.igapp`, loader/report,
CompatibilityReport, dispatch migration, dynamic pack loading,
RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache,
and production behavior.

The track's non-authorization section confirms all surfaces held:
`live_validator_implementation: false`,
`compiler_orchestrator_integration: false`, `compile_refusal: false`,
`public_api_cli_widening: false`, `compiler_result_changes: false`,
`persisted_success_reports_or_sidecars: false`,
`parser_typechecker_semanticir_assembler_igapp: false`,
`loader_report_or_compatibility_report: false`,
`diagnostics_centralization: false`,
`runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production: false`. ✓

---

## Scope Check 9 — Proof References To R69/R70/R71 Are Accurate

§9.5 cites the three proof phases:

```text
R69 shape policy proof
R70 recompute/canonicalization proof
R71 report-only integration proof
```

§15 Proof Evidence includes all three gate decision files and three
experiment summary paths as accepted evidence. The summary passage
correctly states:

```text
R69 shape policy proof: 8 cases PASS
R70 recompute/canonicalization proof: 14 cases PASS
R71 report-only integration proof: 12 cases PASS
```

Cross-checking against actual summaries:

| Phase | Stated | Actual |
| --- | --- | --- |
| R69 shape | 8 cases PASS | `cases: 8, status: "PASS"` ✓ |
| R70 recompute | 14 cases PASS | `cases: 14, status: "PASS"` ✓ |
| R71 integration | 12 cases PASS | `cases: 12, status: "PASS"` ✓ |

The §15 qualifying note is accurate:

```text
This proof evidence supports proposal authoring. It does not prove
implementation readiness.
```

The source tracks field at the top of PROP-038 correctly adds
`prop038-contract-digest-validation-policy-design-v0` (R68-C1-P1,
the design track that originated the digest policy). This is the
correct source attribution. ✓

---

[Agree]

1. **All four codes present, positioned, and correctly worded.** 16
   entries in §10 table; four digest codes grouped under their subject
   area; meanings accurately generalize proof-local message strings into
   normative vocabulary; no namespace crossings.

2. **Diagnostic placement is structurally three-layer.** §10.2 states
   the required path, the two prohibited paths, and the separation
   caveat for centralization — matching R71-C3-A's accepted placement
   rules exactly.

3. **Canonicalization material matches R70 precisely.** 13 included
   fields identical to `CANONICAL_CONTRACT_FIELDS`; excluded fields
   identical to proof-local `canonical_input_excludes`; all 7
   canonicalization rules match R70-C3-A's accepted list.

4. **Short-vs-full policy correctly characterized.** `24+` shape
   accepted; full 64-character valid; short references are "prefix
   references under `prop038_24_plus`" — accurate to R70's
   `start_with?` match semantics.

5. **`descriptor_digest` separation is explicit and three-sided.** (a)
   Included as string value in canonical material; (b) no descriptor
   material fetch; (c) separate identity from `contract_digest`.

6. **Compile refusal closed in three independent locations.** §10
   preamble, §10.3 closing sentence, §18 gate condition — multiple
   guards prevent the errata text from being read as refusal
   authorization.

7. **Live implementation held in three independent locations.** §10.2,
   §9.5, §18. Documentation-only confirmed by track: no code or
   experiments edited.

8. **Non-authority boundary is comprehensive and explicit.** §13
   provides assertive "does not" and "!=" language; §16 enumerates 19
   excluded surfaces; track non-authorization confirms all false.

9. **Proof references accurate on case counts and status.** R69: 8 cases,
   R70: 14 cases, R71: 12 cases — all confirmed PASS against actual
   summaries. Source tracks field updated with R68-C1-P1 design track.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A acceptance decision.

---

## Verdict

**Proceed.**

All nine scope checks pass. The four `contract_digest_*` diagnostic codes
are present in §10 with normative meanings that accurately generalize their
proof-local wording. Diagnostic placement is specified at three levels in
§10.2: required nested path, prohibited top-level path, and restricted
centralization path — matching R71-C3-A exactly. Canonicalization material
in §9.6 matches R70's `CANONICAL_CONTRACT_FIELDS` constant and
`canonical_input_excludes` list field-for-field, and all seven
canonicalization rules match the R70-C3-A accepted list. Short-vs-full
digest semantics are correctly characterized including the prefix-reference
nature of 24-character references. The `descriptor_digest` / `contract_digest`
separation is stated in three complementary ways. Compile refusal is
closed in three independent PROP sections. Live implementation is held in
three independent PROP sections. The full R57-R67 hold inventory is
preserved through §13, §16, and the track non-authorization block. R69/R70/R71
proof case counts and PASS status are accurate.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the PROP-038 errata/design authoring closure. The four
   `contract_digest_*` diagnostic codes, §9.5 policy errata, §9.6
   canonicalization material, §10.2 placement, §10.3 report-only
   invariants, and §15 proof-chain references are accurate and correctly
   non-authorizing. No code or experiments were changed.

2. Confirm PROP-038 is now the canonical design reference for:
   - `contract_digest` shape and full reference formats;
   - four `contract_digest_*` diagnostic codes;
   - canonicalization field list and rules;
   - nested diagnostic placement under
     `report["compiler_profile_contract_validation"]["diagnostics"]`;
   - nine report-only behavioral invariants.

3. If authorizing a live validator implementation design next:
   ```text
   prop038-contract-digest-live-implementation-design-v0
   ```
   The design card may propose:
   - whether shape-only and recompute-match are implemented together or
     sequentially;
   - exact write scope (files, methods, constants);
   - which proof-local model maps to which live validator code change;
   - updated proof requirements for the live implementation.
   This design card requires its own pressure review and Architect
   authorization before any code is written.

4. Hold live validator implementation until the design card is
   authorized.

5. Hold compile refusal. The four-condition chain from R68-C3-A
   (condition 5) still requires a separate compile-refusal gate after
   live implementation and report-only behavior are proven stable in the
   live validator.

6. All surfaces closed by R71-C3-A remain closed: live
   validator/compiler implementation, compile refusal, public API/CLI,
   `CompilerResult`, persisted reports, sidecars, assembler/`.igapp`,
   loader/report, CompatibilityReport, `IgniterLang::Diagnostics`,
   RuntimeMachine, Gate 3, and production behavior.

# Discussion: PROP-038 Contract Digest Live Implementation Design Pressure v0

Card: S3-R73-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: implementation-pressure
Track: prop038-contract-digest-live-implementation-design-pressure-v0

---

## Purpose

Pressure-review the PROP-038 live validator implementation design before any
Architect decision on future implementation authorization.

---

## Inputs Read

- `igniter-lang/docs/tracks/prop038-contract-digest-live-implementation-design-v0.md` (S3-R73-C1-P1)
- `igniter-lang/docs/tracks/prop038-contract-digest-live-implementation-surface-survey-v0.md` (S3-R73-C2-P1)
- `igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md` (S3-R72-C3-A)
- `igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md` (S3-R71-C3-A)
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`

---

## Scope Checks

### Check 1 — Design scope stays inside internal validator

**Pass.**

C1-P1 allowed write scope is:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
igniter-lang/docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md
```

C1-P1 disallowed write scope explicitly names:

```text
igniter_lang.rb
cli.rb
compiler_orchestrator.rb
compilation_report.rb
compiler_result.rb
semanticir_emitter.rb
typechecker.rb
parser.rb
assembler.rb
.igapp artifacts or goldens
loader/report and CompatibilityReport surfaces
public API/CLI surfaces
```

C2-P1 survey confirms: "No public API/CLI flag or keyword is needed" and "No
compiler/orchestrator integration change is needed." Canonicalization helpers
are explicitly scoped as private inside `CompilerProfileContractValidator`. No
new public validator method is proposed.

---

### Check 2 — One-slice vs split recommendation justified

**Pass.**

Both C1-P1 and C2-P1 independently recommend one-slice implementation with
identical rationale:

- R69 shape proof (8 cases PASS), R70 recompute proof (14 cases PASS), and R71
  integration proof (12 cases PASS) are all accepted;
- a split would create a live intermediate state where shape is required but
  identity is not checked — a temporary half-policy that the accepted proof chain
  never modeled;
- the live write surface stays small because canonicalization remains private
  helper code.

C1-P1 labels the split option as `fallback` and explicitly marks `hold` as "not
recommended" since there are no design blockers to drafting a bounded
implementation card.

C2-P1 provides hold conditions for the fallback: "hold if Architect wants to
avoid canonicalization risk by authorizing only shape-only first."

The rationale is sound under implementation-pressure lens. All four codes are
proven vocabulary. Delivering them together avoids shipping a validator that
validates `contract_digest` format but silently ignores identity, which is a
potentially confusing intermediate state.

---

### Check 3 — Diagnostic vocabulary matches PROP-038

**Pass.**

C1-P1 policy table and C2-P1 expected diagnostics list exactly the four
accepted codes from PROP-038 §10 and R72-C3-A:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

C1-P1 also explicitly lists codes not to introduce without a separate gate:

```text
prop038_full_sha256
shape_only
recompute_optional
refusal_on_mismatch
```

No vocabulary expansion beyond the four accepted codes is proposed. The
`compiler_profile_contract.*` namespace boundary is preserved.

---

### Check 4 — Canonicalization material matches R70/R72

**Pass.**

C1-P1 §Canonicalization Rules To Implement lists:

- 13 included fields, matching PROP-038 §9.6 and R72-C3-A exactly:
  `kind`, `format_version`, `profile_namespace`, `profile_kind`,
  `compiler_profile_id`, `descriptor_digest`, `finalization_payload_digest`,
  `required_slot_schema`, `slot_order`, `slot_assignments`, `strict_registries`,
  `ordered_rule_graph`, `non_authority`;
- excluded fields matching PROP-038 §9.6: `contract_digest`, validation result
  fields, `report_only`, `compiler_integrated`, `compile_refusal_authorized`,
  provider metadata, `source_path`/`out_path`, `parsed_program`,
  `compiler_profile_source`;
- 8 ordering rules: object keys sort recursively, `slot_order` order-sensitive,
  strict registry names/entries order-insensitive, ordered-rule list
  order-insensitive, `before`/`after` sorted unique sets, `descriptor_digest` as
  string value, no descriptor fetch.

C2-P1 `CANONICAL_CONTRACT_FIELDS` constant lists the same 13 fields word-for-
word. C2-P1 also correctly identifies `descriptor_digest` as included as a
string field value and confirms descriptor material is not fetched.

C2-P1 correctly identifies the canonical builder drift risk: the existing proof-
local `sha256_ref` in `compiler_profile_contract_proof.rb` uses a generic
`stable_json(normalize(value))` that does not encode the domain-specific
ordering rules for strict registry entries, ordered-rule list, or edge array
deduplication. Both cards address this:

- C1-P1 allowed write scope includes `compiler_profile_contract_proof.rb`;
- C1-P1 proof intent states "canonical contract builder emits a digest matching
  live validator canonicalization";
- C2-P1 mitigation names this explicitly: "update the proof contract builder to
  use the same canonicalization semantics."

---

### Check 5 — Report-only and no-refusal behavior preserved

**Pass.**

C1-P1 §Report-Only And No-Refusal Invariants names:

- `compiler_integrated=false` must remain;
- `compile_refusal_authorized=false` must remain;
- digest diagnostics must remain under
  `report["compiler_profile_contract_validation"]["diagnostics"]`;
- must not append to `report["diagnostics"]`;
- must not centralize in `IgniterLang::Diagnostics`;
- must not change: compile status, `pass_result`, stages, public result,
  `CompilerResult`, assembler execution, `.igapp` manifests, refusal-report
  behavior.

C1-P1 Non-Authorization Preserved section explicitly holds: compile refusal,
public API/CLI, `CompilerResult`, persisted reports, parser/TypeChecker/
SemanticIR/assembler/`.igapp`, loader/report, CompatibilityReport,
`IgniterLang::Diagnostics` centralization, RuntimeMachine, Gate 3, production.

C2-P1 Non-Authorizations Preserved section carries the identical hold inventory.

The design preserves the full R71-accepted report-only invariant set and the
R72-C3-A report-only placement acceptance without exception.

---

### Check 6 — Proof matrix catches all required regression classes

**Pass.**

C1-P1 proof matrix covers:

**Validator proof:**

| Area | Status |
| --- | --- |
| Existing 13-case parity | Required explicitly |
| Shape policy (8 named cases) | Required: short ref, full ref, missing, wrong namespace, too short, non-hex, uppercase, unsupported policy |
| Recompute policy (5 named cases) | Required: full match, prefix match, full mismatch, prefix mismatch, unavailable |
| Canonicalization (9 named cases) | Required: excludes contract_digest, includes descriptor_digest string, no descriptor recompute, slot_order order-sensitive, object key order-insensitive, registry order-insensitive, rule list order-insensitive, edge set order-insensitive, rule reference still validated |
| Result shape | Required: no new top-level fields; flags remain false |

**Integration proof:**

| Area | Status |
| --- | --- |
| Nested placement | Required |
| Top-level diagnostics untouched | Required |
| Report-only status (8 invariants) | Required |
| Nil/exception provider paths | Required |
| `CompilerResult` unchanged | Required |

**Syntax and regression commands:**

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/...
ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/...
ruby igniter-lang/experiments/compiler_profile_contract_proof/...
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/...
```

C2-P1 adds mutation test and parity check (proof-local canonical digest agrees
with live validator recomputed digest) as explicit proof suggestions.

Nil/exception paths are covered: C1-P1 integration proof required coverage
includes "Provider behavior: Nil/non-Hash/provider-error paths remain no-field/
no-refusal as accepted in R67." This matches the R71-accepted nil/exception
invariants.

The proof matrix is comprehensive for the validator-only scope. It catches shape,
recompute, nesting, nil/exception, and all compiler-outcome invariants.

---

### Check 7 — No public API/CLI, compiler/orchestrator, `.igapp`, loader/report, CompatibilityReport, RuntimeMachine, Gate 3, or production authority implied

**Pass.**

Neither C1-P1 nor C2-P1 proposes any change to:

- `igniter_lang.rb` (public facade);
- `cli.rb`;
- `compiler_orchestrator.rb`;
- `compilation_report.rb`;
- `compiler_result.rb`;
- assembler, parser, classifier, TypeChecker, SemanticIR;
- any `.igapp` manifest or golden fixture;
- loader/report or CompatibilityReport surfaces;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

C1-P1 does not propose adding `digest` or `json` as production gem dependencies
— they are explicitly scoped to the validator implementation only as stdlib
requires.

The private helper recommendation ("not a public compiler API; no other live
production surface currently needs it") correctly prevents accidental path
loading or canonicalization being exposed as a separate utility file.

---

### Check 8 — `require "digest"` and `require "json"` additions are safe

**Pass.**

Both `digest` and `json` are Ruby standard library. The validator already uses
`require "set"`. C1-P1 explicitly states: "they must not introduce production
dependencies." C2-P1 names them under expected `require` additions.

No external gem dependency is introduced.

---

### Check 9 — Open questions do not block bounded implementation authorization

**Pass.**

C1-P1 lists four open questions:

- [Q] Should a future durable profile format require 64-character references?
- [Q] Should overlong (> 64 char) digest references be accepted or tightened?
- [Q] Should `contract_digest_recompute_unavailable` ever occur in live code?
- [Q] Should full-digest-only policy be named `prop038_full_sha256` or a new
  errata gate?

None of these questions block the bounded one-slice implementation. The
`prop038_24_plus` policy is the only required live policy. The 24+ pattern
accepts both short prefix and full 64-char references. `recompute_unavailable`
is correctly kept as defensive code. Full-digest-only policy is gated. None of
these decisions affect the live validator implementation boundary as designed.

---

## Non-Blocking Notes

### NB-1 — Minor naming divergence between C1-P1 and C2-P1 private helper vocabularies

C1-P1 names private helpers: `CONTRACT_DIGEST_PATTERN`,
`SUPPORTED_CONTRACT_DIGEST_POLICIES`, `validate_contract_digest`,
`contract_digest_reference`, `contract_digest_hex`,
`canonical_contract_material`, `canonicalize_for_digest`,
`compute_contract_digest_hex`, `normalize_ordered_rule`,
`normalize_strict_registry_entries`.

C2-P1 names helpers: `validate_contract_digest`,
`contract_digest_policy_supported?`, `declared_contract_digest_hex`,
`canonical_contract_material`, `canonical_strict_registries`,
`canonical_ordered_rule_graph`, `canonical_json`,
`recomputed_contract_digest_hex`, `contract_digest_matches?`.

The two lists converge on the same functional decomposition but diverge on
granularity (`canonicalize_for_digest` vs `canonical_strict_registries` +
`canonical_ordered_rule_graph` + `canonical_json`) and naming (`contract_digest_hex`
vs `declared_contract_digest_hex`). Both cards agree helpers must be private.

The C4-A authorization text should confirm that helper names are a private
implementation detail — not binding from either design card — and that the
implementation card may choose names consistent with existing validator style.
This avoids mid-implementation ambiguity over which name set is authoritative.

### NB-2 — Write scope for the three proof-local digest proof scripts diverges between C1-P1 and C2-P1

C1-P1 allowed write scope does not include:

```text
igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/
igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/
igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/
```

C2-P1 preferred one-slice write scope explicitly includes all three directories.
C2-P1 survey rationale: "shape-policy proof now calls the live validator or
asserts exact live parity; recompute proof now calls the live validator or asserts
exact live parity."

If the implementation card intends to update these proof scripts to call the
live validator directly — which C2-P1 recommends and which produces stronger
evidence — then the C4-A authorization text should explicitly name them in scope.
Leaving them out risks the implementation card stopping to request a write-scope
clarification mid-implementation.

This is non-blocking because the base proof and integration proof can still be
updated within C1-P1's scope and the implementation is still provable without
updating the three proof-local scripts. But the stronger evidence path requires
the expanded write scope, which C4-A can authorize cleanly.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: NB-1 (helper naming divergence), NB-2 (proof-script write scope gap)
```

---

## Recommendation For C4-A

Recommendation:

```text
accept design; authorize one-slice internal validator implementation card
```

Reason:

- C1-P1 designs an exact bounded implementation boundary with no forbidden
  surface implied;
- C2-P1 independently surveys the live validator surface and confirms the design
  is feasible with high confidence;
- both cards agree on one-slice recommendation with identical rationale;
- four accepted `contract_digest_*` codes, canonicalization rules, and
  report-only/no-refusal invariants are all precisely specified;
- proof matrix covers all regression classes required by R71-C3-A acceptance;
- canonical builder drift risk is identified and mitigated within allowed scope.

Proposed C4-A authorization text refinements:

1. Confirm helper names are a private implementation detail — not binding from
   either design card — to prevent ambiguity (closes NB-1).
2. Explicitly include the three proof-local digest proof directories in write
   scope, matching C2-P1 preferred scope, to enable the stronger live-parity
   proof path (closes NB-2).
3. Retain compile refusal as closed and public API/CLI as held.

---

## Handoff

```text
Card: S3-R73-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-contract-digest-live-implementation-design-pressure-v0
Status: done

[D] Decisions
- All 9 scope checks pass.
- One-slice recommendation accepted as justified by both C1-P1 and C2-P1.
- Four-code vocabulary, canonicalization material, and report-only invariants
  verified against PROP-038 and R72-C3-A.

[S] Signals
- Design is implementation-pressure sound for validator-only scope.
- No forbidden surfaces are implied.
- Two non-blocking notes for C4-A gate refinement.

[T] Tests / Proofs
- Review-only. No code or experiments were run.

[R] Recommendation
- C4-A: accept; authorize one-slice implementation with NB-1/NB-2 refinements
  applied to authorization text.
```

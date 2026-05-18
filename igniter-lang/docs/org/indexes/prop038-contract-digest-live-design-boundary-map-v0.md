# PROP-038 Contract Digest Live Design Boundary Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R73-C0-O`
Date: 2026-05-18
Authority: orientation only / non-authority

This map helps future agents keep R73 live validator planning separate from
implementation, compiler integration, compile refusal, public/report surfacing,
and production authority.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/tracks/stage3-round72-status-curation-v0.md
```

---

## Current Authority Snapshot

R72 accepted the PROP-038 `contract_digest` errata/design text and authorized
only the next design route:

```text
prop038-contract-digest-live-implementation-design-v0
```

The route may design the exact bounded implementation slice for adding
`contract_digest` validation to the live internal validator. It must not
implement code.

Accepted design vocabulary:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

These codes are canon as PROP-038 design vocabulary. They are not live
implementation authority.

---

## What Design-Only Means For R73

Allowed in R73 design:

```text
define candidate write-scope boundaries
define candidate validator API/result-shape changes
define diagnostic vocabulary usage
define canonicalization helper boundaries
define proof matrix and regression requirements
decide whether implementation should split shape-only and recompute-match
preserve report-only/no-refusal behavior in the design
```

Not allowed in R73 design:

```text
edit live validator code
edit compiler/orchestrator/report/result code
change compile outcome
surface diagnostics publicly
persist reports or sidecars
mutate .igapp manifests or golden artifacts
centralize diagnostics in IgniterLang::Diagnostics
claim production/runtime readiness
```

Operational reading: R73 can answer "what would the bounded live validator
implementation look like?" It cannot make that implementation exist.

---

## Implementation Surfaces Still Closed

Closed unless a later Architect gate explicitly opens them:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
```

Closed behavior surfaces:

```text
live validator implementation
compiler/orchestrator integration changes
compile refusal
public API or CLI widening
CompilerResult changes
persisted reports or sidecars
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
dispatch migration
RuntimeMachine / Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

---

## Allowed Validator Design Questions

R73 may safely explore:

```text
Should live implementation be shape-only first, recompute-match later?
Or should one bounded internal validator slice include both?

Where should canonicalization helper logic live if later implemented?
Should helper methods stay private/internal to the validator?

What policy names are accepted for the first live implementation?
Should `prop038_24_plus` remain the only accepted v0 policy?

What exact result fields would carry digest diagnostics internally?
How does the design keep diagnostics nested under
  compiler_profile_contract_validation.diagnostics?

What proof cases must demonstrate no compile outcome, public result, stage,
assembler, .igapp, refusal-report, or persisted-output changes?

How should provider nil/exception behavior preserve legacy/no-field behavior?
```

R73 should not answer these by editing code. It should answer with a bounded
future implementation proposal and proof matrix.

---

## Report-Only / No-Refusal Invariants To Preserve

If a later implementation is authorized, the R71/R72 invariants must remain
visible in its design:

```text
contract_digest diagnostics remain nested under:
  report["compiler_profile_contract_validation"]["diagnostics"]

top-level report["diagnostics"] remains unchanged
IgniterLang::Diagnostics remains untouched without separate authority
compile status remains unchanged
pass_result remains unchanged
stages remain unchanged
public result remains unchanged
assembler execution remains unchanged
.igapp manifest remains unchanged
refusal-report behavior remains unchanged
nil provider preserves legacy behavior
provider exception preserves legacy behavior
```

Compile refusal remains closed. Any future refusal behavior requires a separate
explicit gate after live implementation and report-only behavior are accepted.

---

## Digest Design Boundaries

Accepted reference shape:

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

Accepted canonical material if recomputation is later enabled:

```text
contract object excluding contract_digest
```

Included canonical fields:

```text
kind
format_version
profile_namespace
profile_kind
compiler_profile_id
descriptor_digest
finalization_payload_digest
required_slot_schema
slot_order
slot_assignments
strict_registries
ordered_rule_graph
non_authority
```

Excluded canonical fields:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path / out_path
parsed_program
compiler_profile_source
```

Hazard: design work must not mix shape validation, recomputation,
canonicalization, mismatch validation, and compiler authority into one
unreviewable step.

---

## Recommended C3 Pressure Hazards

Pressure review should check:

```text
1. Design-only leakage:
   The document must not read as implementation authorization.

2. Live-code leakage:
   No live validator/compiler/report/result/public code may be edited by this
   design route.

3. Refusal creep:
   `contract_digest_*` diagnostics must not become compile refusal.

4. Public-output creep:
   Diagnostics must not leak into public result, CLI/API output, CompilerResult,
   persisted reports, sidecars, .igapp, loader/report, or CompatibilityReport.

5. Diagnostics centralization creep:
   The design must not silently move codes into `IgniterLang::Diagnostics`.

6. Canonicalization ambiguity:
   Included/excluded fields and ordering rules must match PROP-038/R70 wording.

7. Policy ambiguity:
   The design must distinguish `prop038_24_plus` proof-era prefix references
   from any future durable full-digest requirement.

8. Descriptor/contract digest confusion:
   `descriptor_digest` is a string field value inside canonical contract
   material; descriptor material is not fetched or recomputed.

9. Phase collapse:
   A shape-only slice, recompute-match slice, report-only integration slice, and
   future refusal slice must remain separable.

10. Authority language:
    "Valid compiler_profile_contract" must not be phrased as runtime readiness,
    loader/report readiness, obligation success, dispatch binding, or production
    readiness.
```

---

## Future Route Separation

Suggested mental model:

```text
R73 design-only live validator plan
  -> later Architect implementation authorization
  -> bounded live validator implementation proof
  -> later report-only live compiler integration decision, if any
  -> later compile-refusal design/decision, if ever opened
```

Each arrow requires explicit Architect authority. This org map grants none.

---

## One-Line Handoff

Design the live validator slice; do not make it live.

# Track: PROP-038 Contract Digest Live Implementation Surface Survey v0

Card: S3-R73-C2-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-contract-digest-live-implementation-surface-survey-v0`
Route: UPDATE
Status: done
Date: 2026-05-18

---

## Goal

Perform a read-only implementation surface survey for a future PROP-038
`contract_digest` live validator implementation.

Authority:

- `igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`

This track is survey-only. It does not authorize or perform implementation.

---

## Inputs Read

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/implementation-agent.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/operating-model.md`
- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb`
- `igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb`
- `igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb`
- `igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`

Supporting context read:

- `igniter-lang/docs/tracks/prop038-contract-digest-validation-policy-design-v0.md`
- `igniter-lang/docs/tracks/prop038-contract-digest-report-only-integration-proof-v0.md`

---

## Read-Only Commands

```text
sed -n '1,260p' igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
sed -n '1,320p' igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
sed -n '321,520p' igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
sed -n '1,320p' igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
sed -n '1,360p' igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
sed -n '361,520p' igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
sed -n '1,380p' igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
sed -n '380,410p' igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
rg -n "contract_digest|CONTRACT_DIGEST|canonical_material|canonical_json|digest_reference_policy|descriptor_digest|finalization_payload_digest|diagnostic\\("
```

Summary inspection:

```text
compiler_profile_contract_proof_summary.json status=PASS checks=27
prop038_contract_digest_shape_policy_proof_summary.json status=PASS cases=8 checks=19 failed=0
prop038_contract_digest_recompute_match_proof_summary.json status=PASS cases=14 checks=15 failed=0
prop038_contract_digest_report_only_integration_proof_summary.json status=PASS cases=12 checks=21 failed=0
```

No proof scripts were rerun. No generated experiment output was changed.

---

## Current Live Validator Surface

File:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

Current public API:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Current digest behavior:

- validates `descriptor_digest` against
  `compiler_profile_descriptor/sha256:<24+ lowercase hex>`;
- validates `finalization_payload_digest` against `sha256:<64 lowercase hex>`;
- records `digest_reference_policy` in the result;
- does not validate `contract_digest` shape;
- does not canonicalize contract material;
- does not recompute or compare `contract_digest`;
- returns `compiler_integrated=false`;
- returns `compile_refusal_authorized=false`.

Current internal helper surface:

- `diagnostic(code, message, path = nil)`;
- `result(diagnostics, policy)`;
- `find_rule_cycle(rules)`.

The future implementation can remain inside this module without changing the
public validator method shape.

---

## Proof-Local Surface Map

### Base Contract Proof

File:

```text
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

Relevant current behavior:

- builds the canonical contract used by downstream summaries;
- computes `contract_digest` with proof-local `sha256_ref`;
- `sha256_ref` uses `stable_json(normalize(value))`;
- that normalizer sorts object keys recursively but preserves array order;
- the live validator currently accepts the canonical contract because it does
  not validate `contract_digest`.

Implementation risk:

```text
The proof-local builder's current digest algorithm is not the accepted R70
canonicalizer in full.
```

It may coincide for some material, but it does not encode the accepted
order-insensitive rules for strict registry entry order, ordered-rule list
order, or sorted unique `before` / `after` edge sets. A future recompute-capable
live validator must make the contract builder use the same canonicalizer or the
existing canonical contract may become invalid.

### Shape-Policy Proof

File:

```text
igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
```

Proof-local logic available to migrate:

- `SUPPORTED_POLICY = "prop038_24_plus"`;
- `CONTRACT_DIGEST_PATTERN =
  /\Acompiler_profile_contract\/sha256:[0-9a-f]{24,}\z/`;
- `contract_digest_invalid`;
- `contract_digest_policy_unsupported`;
- valid short 24+ reference case;
- valid full 64 reference case;
- missing, wrong namespace, too short, non-hex, uppercase failures.

This is the minimal live validator slice if implementation is split.

### Recompute-Match Proof

File:

```text
igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
```

Proof-local logic available to migrate:

- `CONTRACT_DIGEST_PREFIX`;
- `CANONICAL_CONTRACT_FIELDS`;
- `canonical_material`;
- `canonical_strict_registries`;
- `canonical_ordered_rule_graph`;
- `canonical_json`;
- `recomputed_hex`;
- `declared_hex`;
- prefix match under `prop038_24_plus`;
- `contract_digest_mismatch`;
- `contract_digest_recompute_unavailable` model.

Accepted canonicalization behavior:

- top-level canonical input excludes `contract_digest`;
- object keys sort recursively;
- `slot_order` remains order-sensitive;
- strict registry names and entries are order-insensitive;
- ordered-rule list order is order-insensitive;
- rule `before` / `after` arrays are sorted unique sets;
- `descriptor_digest` is included as a string field value;
- descriptor material is not fetched or recomputed.

### Report-Only Integration Proof

File:

```text
igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
```

This proof models nested digest diagnostics under:

```text
compiler_profile_contract_validation.diagnostics
```

and asserts that digest diagnostics do not alter:

- top-level report diagnostics;
- `pass_result`;
- stages;
- compile status;
- public result;
- assembler execution;
- `.igapp` manifest;
- refusal report behavior.

For a live-validator-only implementation, this remains primarily a regression
proof. It should not force compiler/orchestrator changes.

---

## Likely Future Validator Changes

Minimal constants to add:

```ruby
CONTRACT_DIGEST_PREFIX = "compiler_profile_contract/sha256:"
CONTRACT_DIGEST_PATTERN = /\Acompiler_profile_contract\/sha256:[0-9a-f]{24,}\z/
SUPPORTED_DIGEST_REFERENCE_POLICIES = %w[prop038_24_plus].freeze
CANONICAL_CONTRACT_FIELDS = %w[
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
].freeze
```

Minimal helper methods to add:

- `validate_contract_digest(contract, policy, diagnostics)`;
- `contract_digest_policy_supported?(policy)`;
- `declared_contract_digest_hex(contract)`;
- `canonical_contract_material(contract)`;
- `canonical_strict_registries(registries)`;
- `canonical_ordered_rule_graph(graph)`;
- `canonical_json(contract)`;
- `recomputed_contract_digest_hex(contract)`;
- `contract_digest_matches?(declared_hex, computed_hex, policy)`;

Existing helpers to keep:

- `diagnostic`;
- `result`;
- `find_rule_cycle`.

Expected `require` additions:

```ruby
require "digest"
require "json"
```

Expected diagnostics added through the existing local `diagnostic` helper:

- `compiler_profile_contract.contract_digest_invalid`;
- `compiler_profile_contract.contract_digest_policy_unsupported`;
- `compiler_profile_contract.contract_digest_mismatch`;
- `compiler_profile_contract.contract_digest_recompute_unavailable`.

No new public validator method is needed.

No `IgniterLang::Diagnostics` change is needed.

---

## Canonicalization Boundary

Recommendation:

```text
Keep canonicalization as private helpers inside
CompilerProfileContractValidator for the first live implementation.
```

Reason:

- the canonicalizer is validator-owned policy, not a public compiler API;
- no other live production surface currently needs it;
- keeping it private avoids accidental path loading, descriptor fetching,
  profile finalization, report writing, or API widening;
- proof-local scripts can assert parity through public `validate`, not by
  calling helper APIs.

Do not create a separate public canonicalization object or utility file in the
first slice.

If a later route needs durable canonical JSON reuse outside validation, that
should be separately authorized.

---

## Candidate Future Write Scope

### Preferred One-Slice Scope

If implementation is authorized as one bounded slice:

- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/`
- `igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/`
- `igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/`
- `igniter-lang/docs/tracks/<future-live-validator-implementation-track>.md`

Expected proof intent:

- base 13-case validator matrix remains PASS;
- canonical contract builder emits a digest matching live validator
  canonicalization;
- shape-policy proof now calls the live validator or asserts exact live parity;
- recompute proof now calls the live validator or asserts exact live parity;
- report-only integration proof confirms nested diagnostics still do not change
  compiler outcomes;
- no compiler/orchestrator changes are required.

### Split Scope Option

Phase 1, shape-only:

- `compiler_profile_contract_validator.rb`;
- `compiler_profile_contract_proof.rb` and summary;
- `prop038_contract_digest_shape_policy_proof/`;
- track doc.

Phase 2, recompute-match:

- `compiler_profile_contract_validator.rb`;
- `compiler_profile_contract_proof.rb` and summary;
- `prop038_contract_digest_recompute_match_proof/`;
- `prop038_contract_digest_report_only_integration_proof/`;
- track doc.

Split is safer if Architect wants a smaller first diff, but it leaves an
intermediate validator that requires `contract_digest` shape while still not
checking contract identity.

---

## Files To Keep Untouched Without Separate Authorization

Do not touch these for a live validator-only implementation:

- `igniter-lang/lib/igniter_lang.rb`;
- `igniter-lang/lib/igniter_lang/cli.rb`;
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`;
- `igniter-lang/lib/igniter_lang/compilation_report.rb`;
- `igniter-lang/lib/igniter_lang/compiler_result.rb`;
- `igniter-lang/lib/igniter_lang/assembler.rb`;
- `igniter-lang/lib/igniter_lang/parser.rb`;
- `igniter-lang/lib/igniter_lang/classifier.rb`;
- `igniter-lang/lib/igniter_lang/typechecker.rb`;
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`;
- any `.igapp` manifest/golden fixture outside proof-local generated output;
- loader/report and CompatibilityReport surfaces;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production surfaces.

No public API/CLI flag or keyword is needed.

No compiler/orchestrator integration change is needed for the validator-only
implementation.

---

## Risks

### Canonical Builder Drift

The existing `compiler_profile_contract_proof` builds `contract_digest` using a
generic stable JSON normalizer. The accepted R70 canonicalizer has domain rules
for strict registries, ordered-rule lists, and edge arrays.

Mitigation:

- update the proof contract builder to use the same canonicalization semantics
  as the live validator when recompute is enabled;
- add a proof assertion that the canonical contract validates with no digest
  diagnostics.

### Mutation And Aliasing

Proof scripts use `Marshal` deep copies. Live validator helpers should not
mutate caller-supplied Hashes or arrays.

Mitigation:

- canonical helpers should build fresh Hash/Array material;
- proof should assert `contract` before/after equality around validation.

### Order Sensitivity Mistakes

The accepted rules deliberately mix order-sensitive and order-insensitive
fields.

Mitigation:

- keep explicit cases for `slot_order` order-sensitive;
- keep explicit cases for top-level object key order-insensitive;
- keep explicit cases for strict registry and rule-list order-insensitive;
- keep explicit cases for `before` / `after` sorted unique edge sets.

### Prefix Matching Semantics

Under `prop038_24_plus`, declared hex is a 24+ prefix. A naive implementation
could accidentally require exact 64-character match or accept too-short refs.

Mitigation:

- retain both `recompute_full_match` and `recompute_prefix_match`;
- retain too-short, uppercase, and non-hex shape failures.

### Diagnostic Accumulation Shape

Adding digest diagnostics to the existing validator may change multi-diagnostic
output for already-invalid Hash contracts.

Mitigation:

- update expected matrix intentionally;
- keep non-Hash early return behavior unchanged;
- assert base structural diagnostics still appear.

### Policy Unsupported Branch

The validator already accepts `digest_reference_policy:` but only records it.
Once policy validation exists, unsupported policies become invalid.

Mitigation:

- add a dedicated unsupported-policy case;
- keep supported policy limited to `prop038_24_plus` unless a later gate opens
  `prop038_full_sha256`.

### JSON Canonicalization Details

Ruby `JSON.generate` is deterministic for inserted Hash order, but only after
the helper constructs sorted Hashes. Numeric edge cases are not currently part
of the contract material, but booleans/null/string serialization must stay
stable.

Mitigation:

- canonical helpers should sort object keys before `JSON.generate`;
- avoid pretty generation or whitespace;
- keep string-key material.

---

## Proof Suggestions

For a future implementation card, require:

- syntax check for `compiler_profile_contract_validator.rb`;
- base `compiler_profile_contract_proof` run and summary update;
- shape-policy proof run;
- recompute-match proof run;
- report-only integration proof run;
- assertion that no `contract_digest_*` diagnostics are appended to top-level
  compilation report diagnostics;
- assertion that live validator result still has
  `compile_refusal_authorized=false`;
- assertion that public API/CLI, `CompilerResult`, orchestrator, and `.igapp`
  outputs are unchanged unless separately authorized;
- mutation test around validator input;
- parity check that proof-local canonical digest and live validator recomputed
  digest agree.

Expected command matrix:

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
```

---

## C1 / C4 Feasibility Notes

No local `prop038-contract-digest-live-implementation-design-v0` track was
present during this survey. The notes below use the requested C1/C4 labels as
future implementation planning anchors.

### C1: Live Validator Implementation

Feasibility:

```text
high, if scoped to CompilerProfileContractValidator plus proof parity
```

Why:

- the validator already has a stable public `validate` entry point;
- digest policy is already passed through as a keyword;
- diagnostic construction is already local;
- result shape already carries `digest_reference_policy`,
  `compiler_integrated=false`, and `compile_refusal_authorized=false`;
- R69/R70/R71 proof-local matrices cover shape, recompute, and report-only
  placement.

Primary C1 blocker before code:

- exact authorization must state whether to implement shape-only first or
  shape+recompute together.

### C4: Report-Only / Integration Regression

Feasibility:

```text
medium-high, but should remain proof/regression unless separately authorized
```

Why:

- R67 already provides report-only in-memory annotation;
- R71 already models digest diagnostics nested under
  `compiler_profile_contract_validation`;
- live validator changes alone do not require compiler/orchestrator changes.

Primary C4 blocker before code:

- if C4 means changing compiler/orchestrator behavior, that is outside this
  validator survey and requires separate authority. For validator-only work,
  C4 should be a regression proof, not an integration implementation.

---

## Recommendation

```text
one-slice
```

Recommended future implementation boundary:

```text
Implement all four accepted contract_digest diagnostics in the internal live
validator in one bounded slice, with proof parity and no compiler/orchestrator
changes.
```

Reason:

- all four digest diagnostics are now accepted PROP-038 design vocabulary;
- shape and recompute proof chains are already PASS;
- a split implementation creates a temporary state where `contract_digest`
  shape is required but identity is not checked;
- the actual live write surface remains small if canonicalization is kept as
  private validator helpers.

Hold conditions:

- hold if the next gate wants to avoid canonicalization risk by authorizing only
  shape-only first;
- hold if the next gate expects compiler/orchestrator integration changes in the
  same card;
- hold if public API/CLI, compile refusal, persisted report, loader/report,
  CompatibilityReport, runtime, or production behavior is requested.

---

## Non-Authorizations Preserved

This survey made no code edits and no generated experiment changes.

This survey does not authorize:

- implementation;
- golden or fixture mutation;
- compiler/orchestrator integration;
- compile refusal;
- public API/CLI widening;
- persisted success report or sidecar;
- `CompilerResult` changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- diagnostics centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

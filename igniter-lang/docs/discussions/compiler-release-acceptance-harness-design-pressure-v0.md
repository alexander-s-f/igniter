# Compiler Release Acceptance Harness Design Pressure v0

Card: S3-R160-C2-X
Agent: [Igniter-Lang Pressure Reviewer]
Role: pressure-reviewer
Track: compiler-release-acceptance-harness-design-pressure-v0
Route: UPDATE
Depends on: S3-R160-C1-D
Date: 2026-05-24

---

## Question

Does the `compiler-release-acceptance-harness-design-v0` concretely answer all
five S3-R159-C2-X non-blocking notes, specify a corpus and negative/refusal
suite specific enough to become machine-executable, handle artifact
normalization without overclaim, correctly scope package/install stance,
produce strong non-claims wording, keep analyzer/tracer/visualizer design-only,
hold Spark/Ruby non-authorizing, and preserve all closed surfaces — without
implementing the harness or authorizing release evidence gathering?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
  (S3-R160-C1-D)
- `igniter-lang/docs/tracks/compiler-release-readiness-and-ruby-hygiene-decision-v0.md`
  (S3-R159-C4-A — Portfolio gate)
- `igniter-lang/docs/discussions/compiler-release-readiness-map-pressure-v0.md`
  (S3-R159-C2-X — prior pressure review)
- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md`
  (S3-R159-C1-D — release readiness map)
- `igniter-lang/docs/tracks/poc-mvp-live-touch-v0.md`
  (S3-R157-C2-I — POC track)
- POC artifacts: `poc_mvp_live_touch_summary.json`, `compile_transcript.json`,
  `runtime_trace.json`

---

## Challenge Review

### CH1: NB-1..NB-5 Answered Concretely

**Verdict: all five answered concretely and bindingly.**

| NB | Design answer | Binding? |
| --- | --- | --- |
| NB-1: language-feature diversity | Requires ≥5 units; baseline Add; boolean gate; integer arithmetic; ≥1 contract with >2 inputs; branch/conditional if existing grammar supports it; HOLD binding if branch cannot be included without Portfolio-accepted scope narrowing | Yes — HOLD binding is exact |
| NB-2: `production_compiler_cli_proof` reuse policy | Prior proof is provenance anchor only; CLI/API/load-path must be rerun in harness or same-round RC smoke; existing output cannot substitute | Yes — explicit "cannot substitute" |
| NB-3: non-claims wording template | Full normative template included covering proof-local RuntimeSmoke, bounded PROP-036 CLI transport, and enumerated non-runtime/non-Spark/non-deployment stances | Yes — template text is specific enough to copy verbatim |
| NB-4: warnings in-scope or deferred | Warnings arrays must be present/empty; `warnings_count` present in transcript; warning-producing compile deferred; unexpected warning is HOLD | Yes — both present-empty and deferred-fixture positions bound |
| NB-5: RC-wide negative scan token list | 39-token explicit list with four named allowed-context exceptions | Yes — token list is enumerated, exceptions are narrow |

The binding HOLD for branch/conditional coverage in NB-1 is particularly well-designed: it forces Portfolio to accept a narrower language-feature scope rather than allowing an unchecked default.

---

### CH2: Positive Corpus Diversity

**Verdict: substantially more diverse than the POC; one minor
precision gap (NB-1 below).**

Minimum positive corpus:

```text
≥5 compile units
1 minimal Add-style baseline
1 synthetic micro-app group derived from POC domain
1 contract with more than two inputs
1 boolean gate / conjunction case
1 integer arithmetic case
1 accepted conditional/branch case if existing grammar supports it
```

The POC's four contracts cover only `+` (integer addition) and `&&`
(boolean AND). The new design explicitly requires the multi-input and
baseline cases to move beyond the POC floor.

The "1 contract with more than two inputs" requirement correctly signals that
input-count diversity is necessary. However, "more than two inputs" is a
structural minimum: a contract with three integer inputs summed is still
trivially simple. The harness implementation card should confirm that the
multi-input contract exercises a meaningful combination (e.g., typed
inputs with at least one non-integer, or a dependency edge between
computed nodes) rather than adding a third summand. See NB-1.

The branch/conditional binding resolves the largest language coverage gap.
If the current accepted grammar does not support branch/conditional without
new semantics, the result is HOLD — correct outcome.

---

### CH3: Negative/Refusal Cases Specific Enough

**Verdict: yes — 9 cases with evidence shape requirements; one
meaning clarification needed (NB-2).**

| Case | Evidence shape requirement | Clarity |
| --- | --- | --- |
| Parse refusal | non-zero/error result, parse stage failure, no `.igapp` | ✓ |
| Unresolved symbol | typecheck refusal with diagnostic category/path, no `.igapp` | ✓ |
| Type mismatch | typecheck refusal with diagnostic category/path, no `.igapp` | ✓ |
| CLI profile-source bad path | preflight stderr, no stdout, no report, no `.igapp` | ✓ |
| CLI profile-source malformed JSON | preflight stderr, no stdout, no report, no `.igapp` | ✓ |
| Semantic profile-source refusal | `compiler_profile_source.*` diagnostic, report allowed per accepted behavior, no `.igapp` | ✓ |
| PROP-038 strict refusal | conditional on RC scope inclusion | ✓ correct to keep conditional |
| Normalization failure specimen | harness-design specimen proving unstable fields don't falsely fail stable checks | Ambiguous — see NB-2 |
| Closed-surface leakage specimen | negative scan over source, outputs, summary | ✓ |

Case 8 (normalization failure specimen) is the only entry that is not a
compiler refusal. Its purpose — to prove that the normalization logic handles
unstable fields without false failures — is valid and important. But the
meaning is ambiguous: it could be (a) a fixture with intentionally
unstable path/hash fields that the harness normalizes correctly, or (b) a
meta-test confirming that the stable-field comparison does not over-reject
runs with minor path differences. Both interpretations are valid but require
different harness mechanics. The implementation card must pin which
interpretation applies. See NB-2.

---

### CH4: Artifact Normalization Precise and Testable

**Verdict: yes — stable fields table is artifact-specific; normalization
table is actionable; one artifact presence gap (NB-3).**

Stable fields tables covering 9 artifact areas are precise and testable. The
normalization decisions are correct:

- absolute paths → repo-relative or harness-output-relative ✓
- hash/ref fields → prefix/shape unless pinned ✓
- entry ordering → sort where semantically irrelevant ✓
- diagnostic prose → rule/severity/category/path first, full text only if
  declared stable ✓

The guardrail — "any excluded field appearing with a new public/report/runtime
authority meaning should be a HOLD, not silently ignored" — is the critical
protection against silent surface expansion through excluded fields.

**NB-3 observation:** The stable fields table includes
`.igapp/compatibility_metadata.json` with fields `kind`, format version,
canonical artifact field, and metadata presence. The design correctly notes
"Compatibility metadata is accepted only as artifact metadata shape. It is not
a public CompatibilityReport." However, the presence and current shape of
`compatibility_metadata.json` in existing assembler output is not confirmed
in this design card. If this artifact is absent from current `.igapp` output,
listing it as a required stable field would cause the harness to produce a
FAIL or HOLD on an artifact that doesn't exist yet. The implementation card
must confirm whether `compatibility_metadata.json` is produced by the current
assembler; if it is not, it should be moved to an optional/future-only entry
rather than a required stable field. See NB-3.

---

### CH5: Hash / Path / Message Fields Safe

**Verdict: yes — all three field families handled correctly.**

Hash fields: "compare prefix and shape unless the later harness design pins
recomputation" — correct; prevents brittle exact-hash comparison while still
requiring hash field presence. The design also excludes `artifact_hash` and
`source_hash` exact values from RC exact comparison. ✓

Path fields: normalized to repo-relative or harness-output-relative. The POC
already uses repo-relative paths in its `igapp_path` fields, so existing
evidence is already normalized-compatible. ✓

Message fields: "compare rule/severity/category/path first; full message text
only if declared stable for that case" — correct; prevents diagnostic message
text from becoming a brittle comparison surface without losing structural
coverage. ✓

`compiled_at` timestamp excluded from exact comparison. ✓

---

### CH6: Package / Install / Load-Path Overclaim Avoided

**Verdict: no overclaim; explicit two-scope table with correct
default.**

Two named scopes:

| Scope | Required stance |
| --- | --- |
| Repo-local compiler RC (default) | load-path smoke with `ruby -I`; no installed-gem claims |
| Installed package RC (future gate) | package build + clean install + require without `-I` + installed compile/refusal smoke |

"Default for next route: repo-local compiler RC only."

This exactly prevents the most common form of release overclaim: asserting
"release ready" when only repo-local execution has been demonstrated.
Installed package readiness is explicitly held until a separate gate.

The minimum RC command matrix is well-formed:

```text
ruby -c HARNESS_RUNNER
ruby HARNESS_RUNNER --mode acceptance
ruby -I igniter-lang/lib -e 'require "igniter_lang"; ...'
bin/igc compile POSITIVE_SOURCE --out OUT/POSITIVE.igapp
bin/igc compile POSITIVE_SOURCE ... --compiler-profile-source PROFILE.json
bin/igc compile NEGATIVE_SOURCE --out OUT/NEGATIVE.igapp
IgniterLang.compile(POSITIVE_SOURCE, out: OUT/API_POSITIVE.igapp)
```

7 commands. Covers load-path, positive CLI compile, profile-source CLI
compile, negative CLI compile, and direct API compile. No new CLI flags. ✓

---

### CH7: Non-Claims Wording Strong Enough

**Verdict: yes — NB-3 template is specific, comprehensive, and
ready to copy verbatim.**

The normative template is strong across five dimensions:

1. **Scope**: "local compiler evidence only" with explicit named compiler
   pipeline stages
2. **Runtime**: "not a public production runtime" with `RuntimeSmoke
   proof-local evaluation evidence only` qualifier
3. **PROP-036 CLI**: exact CLI shape cited (`igc compile SOURCE --out
   OUT.igapp --compiler-profile-source PATH.json`); 5 explicitly non-added
   features (profile discovery, defaulting, finalization, inline JSON, named
   profile lookup, env/config/sidecar lookup)
4. **Ecosystem non-claims**: Spark integration, deployment/signing,
   Ledger/TBackend, CompatibilityReport, loader/report all explicitly named
5. **Install scope**: "docs must say repo-local only" until package/install
   smoke is accepted

The template text is specific enough to evaluate compliance mechanically —
a future audit can verify each sentence against what the RC claims.

**NB-4 observation:** The PASS/HOLD/FAIL result packet shape includes
`"public_claims_authorized": false` in the `release_scope` block. This is a
good guard, but the machine-readable packet does not include a corresponding
`claimed_surfaces` field that enumerates what the RC positively claims.
Without a `claimed_surfaces` list, a tool reading the summary must infer the
positive scope from the corpus entries rather than from an explicit release
scope declaration. The implementation card should add a
`"claimed_surfaces": [...]` field to the `release_scope` block to mirror the
non-claims in machine-readable form. See NB-4.

---

### CH8: Analyzer / Tracer / Visualizer Design-Only

**Verdict: correctly held; no implementation authorization.**

The design separates exactly:

Allowed in harness design:
- machine-readable field definitions an analyzer would consume
- trace-to-artifact linkage definitions
- summary shape that could later be visualized
- stable/normalized/excluded field enumeration

Held:
- analyzer implementation
- tracer implementation
- visualizer implementation
- public analyzer/tracer command
- UI
- release-blocking visualization requirement

"First RC blocks on structured acceptance evidence, not on visual tooling."

This matches the S3-R159-C4-A Portfolio disposition exactly. No scope creep. ✓

---

### CH9: Spark / Ruby Pressure Non-Authorizing

**Verdict: no authorization; both held correctly.**

Spark: four candidates listed as `"Future only"` with explicit prohibitions:
"No Spark fixture creation, spec mutation, compiler change, integration, raw
data access, production behavior, or primary-ledger replacement is opened."
Token list includes `Spark`, `spark`, `sparkcrm`, `SparkCRM`,
`ServiceCall`, `LeadChannel`, `OrdersAnalytics`, and the four candidate
family names — with an allowed-context exception for harness design sections
that classify them as optional future fixture families. ✓

Ruby: "no Ruby docs sync now, no Ruby package change now, no Ruby compiler
compatibility claim now." Aligns with S3-R159-C4-A. ✓

The candidate family token names appearing in the token list itself (allowed
exception) is correctly narrow. The scanner must treat any occurrence of those
names outside the classifier section as HOLD. ✓

---

### CH10: Public / Runtime / Deployment Closed Surfaces

**Verdict: no leakage; closed surfaces comprehensive and consistent
with accumulated gate inventory.**

The "Closed Surfaces" section lists 18 prohibited categories, including:

```text
harness implementation
release evidence gathering
mutation of POC outputs or .igapp artifacts
release execution
public release or public demo claims
analyzer/tracer/visualizer implementation
public API/CLI widening
root require changes
parser/classifier/TypeChecker/SemanticIR/assembler changes
loader/report
CompilationReport, CompilerResult, or CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, demo
```

This list is consistent with S3-R159-C4-A, S3-R155-C1-X, S3-R153-C2-X, and
the prior accumulated gate record. No prohibited surface is opened by
implication in the design document.

Specific check: does listing `.igapp/compatibility_metadata.json` as a stable
artifact imply a CompatibilityReport surface? The design correctly guards this:
"Compatibility metadata is accepted only as artifact metadata shape. It is not
a public CompatibilityReport." The closed surfaces section explicitly preserves
"CompatibilityReport widening." No opening by implication. ✓

---

## Non-Blocking Notes For C3-A

### NB-1: "More than two inputs" — structural minimum may be too weak

"At least 1 contract with more than two inputs" is satisfied by three integer
inputs summed together. The intent appears to be input-combination diversity,
not merely input count. The harness implementation card should confirm that the
multi-input contract requirement means a contract with at minimum:

- inputs of more than one type (e.g., one integer and one boolean), or
- a computed node that depends on more than two inputs directly, or
- an accepted conditional/branch that conditions on one input value.

If only count matters, this requirement is weakly equivalent to the POC's
existing contracts. C3-A may strengthen this requirement or accept it as
minimum-floor coverage explicitly.

### NB-2: "Normalization failure specimen" meaning needs pinning

The negative corpus lists "normalization failure specimen — harness-design
specimen proving unstable fields do not falsely fail stable checks." Two
valid but mechanically different interpretations:

- **Interpretation A**: a fixture file that intentionally uses an absolute
  path or machine-local field, and the test asserts that the normalization
  step converts it correctly before comparison;
- **Interpretation B**: a harness self-test that reruns the positive corpus
  twice (simulating path variation) and confirms the normalized output is
  stable across runs.

Both are useful. The implementation card must pick one and document it.
Leaving it undefined risks the harness skipping this case because it is
unclear what to execute.

### NB-3: `compatibility_metadata.json` stable field presence needs confirmation

The stable artifact fields table lists `.igapp/compatibility_metadata.json`
as a required stable artifact. If the current assembler does not produce this
file, any harness check against it will produce FAIL or HOLD on an absent
artifact. The implementation card must:

- confirm the file is produced by the current assembler for the POC corpus;
- if absent: move it to an optional/future-only list and note the gap; or
- if present: verify the field shape matches `kind`, format version, canonical
  artifact field, and metadata presence.

C3-A should note that `compatibility_metadata.json` may need to become a
"HOLD-if-absent, not FAIL-if-absent" entry in the harness to avoid a false
FAIL on a not-yet-produced artifact.

### NB-4: Machine-readable packet `release_scope` lacks `claimed_surfaces`

The PASS/HOLD/FAIL summary JSON shape has:

```json
"release_scope": {
  "scope": "repo_local_compiler_rc",
  "public_claims_authorized": false,
  "production_runtime_authorized": false
}
```

A reader of this packet knows what is NOT claimed (`public_claims_authorized:
false`) but must infer the positive scope from the corpus entries. Adding a
`"claimed_surfaces": [...]` field would make the RC scope machine-readable in
both directions — what is claimed and what is not — which protects against
scope drift between rounds. The non-claims template exists in the docs, but
the machine-readable packet should mirror it. The implementation card should
add this field, e.g.:

```json
"claimed_surfaces": [
  "repo_local_compiler_cli_positive_compile",
  "repo_local_compiler_cli_refusal",
  "repo_local_compiler_api_positive_compile",
  "repo_local_load_path_smoke",
  "proof_local_runtime_smoke"
]
```

### NB-5: HOLD / FAIL precedence rule missing when both trigger simultaneously

The result packet has separate `hold_reasons` and `failed_checks` arrays, and
the decision table defines HOLD and FAIL as distinct states. But the decision
table does not specify what happens when the same run produces both HOLD and
FAIL triggers (e.g., a missing artifact produces HOLD and a leaking forbidden
token produces FAIL). The implementation card should add one rule: FAIL takes
precedence over HOLD. Without this rule, a harness with a FAIL-level finding
could report HOLD if the FAIL check is evaluated after a HOLD check.

---

## Verdict

**proceed — no blockers; 10/10 challenge items reviewed clean.**

The harness design:
- answers all five NB notes concretely and bindingly (CH1);
- requires more language-feature diversity than the POC (CH2);
- specifies 9 negative/refusal cases with evidence shapes (CH3);
- provides a testable artifact normalization policy (CH4);
- handles hash/path/message fields safely (CH5);
- avoids package/install overclaim with an explicit two-scope table (CH6);
- includes a strong, verbatim-copyable non-claims template (CH7);
- keeps analyzer/tracer/visualizer design-only (CH8);
- holds Spark and Ruby non-authorizing (CH9);
- preserves all closed surfaces without implication leakage (CH10).

Five non-blocking notes for C3-A to carry into the implementation gate:
- NB-1: multi-input corpus requirement needs input-diversity clarification
- NB-2: normalization failure specimen interpretation needs pinning
- NB-3: `compatibility_metadata.json` presence needs assembler confirmation
- NB-4: machine-readable `release_scope` should add `claimed_surfaces`
- NB-5: FAIL takes precedence over HOLD rule must be explicit

---

## Acceptance Recommendation For C3-A

**Accept the `compiler-release-acceptance-harness-design-v0`.**

The design is sufficiently specified to authorize a proof-local harness
prototype or a bounded implementation-authorization review. C3-A should choose
between:

```text
Option A: compiler-release-acceptance-harness-proof-local-prototype-design-v0
  Mode: design-only prototype boundary
  Purpose: prove the harness shape is implementable without authorizing
           a full live RC run

Option B: compiler-release-acceptance-harness-implementation-authorization-v0
  Mode: bounded implementation authorization
  Purpose: authorize the harness runner directly, guided by the
           NB-1..NB-5 answers and the five NB notes above
```

Carry NB-1 through NB-5 as explicit implementation-gate inputs in either
option.

Do not authorize RC evidence gathering, release execution, public claims,
analyzer/tracer/visualizer implementation, Spark fixture creation, Ruby
Framework docs sync, or any widening of public/runtime/deployment surfaces
from this acceptance.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
harness implementation
release evidence gathering or RC execution
mutation of POC outputs or .igapp artifacts
public release or public demo claims
analyzer/tracer/visualizer implementation or public command
public API/CLI widening
root require or compiler pipeline changes
loader/report, CompilationReport, CompilerResult, CompatibilityReport
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, or demo
```

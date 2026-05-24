# Compiler Release Readiness Map Pressure v0

Card: S3-R159-C2-X
Agent: [Igniter-Lang Pressure Reviewer]
Role: pressure-reviewer
Track: compiler-release-readiness-map-pressure-v0
Route: UPDATE
Depends on: S3-R159-C1-D
Date: 2026-05-24

---

## Question

Does the `compiler-release-readiness-map-v0` correctly bound POC evidence as
seed only (not RC, not public demo), correctly identify all major gaps before a
first compiler release candidate, hold all public/runtime/deployment surfaces
closed, and produce a design-only acceptance harness recommendation that
Portfolio can act on — without authorizing implementation or release execution?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md` (S3-R159-C1-D)
- `igniter-lang/docs/tracks/fractal-supervisor-packet-synthesis-v0.md` (S3-R158-C5-A)
- `igniter-lang/docs/tracks/poc-mvp-live-touch-v0.md` (S3-R157-C2-I)
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/poc_mvp_live_touch_summary.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/compile_transcript.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/runtime_trace.json`

---

## Challenge Review

### CH1: Overclaim — local POC vs release-candidate vs public demo

**Verdict: no overclaim detected.**

The map maintains a clear three-level distinction throughout:

| Level | Map treatment |
| --- | --- |
| POC | "seed evidence", "local proof-lab evidence" |
| Release candidate | not yet reached; requires acceptance harness, negative corpus, normalization policy, smoke matrix, and RC docs |
| Public demo | not authorized; explicitly listed under "Closed Surfaces Preserved" |

Inspecting the evidence directly:

The `compile_transcript.json` shows 4/4 modules with `diagnostics_count: 0` and
`warnings_count: 0`. The `runtime_trace.json` correctly labels every entry with
`"trace_reason": "RuntimeSmoke proof-local evaluation trusted"` — the
proof-local qualifier is in the machine-readable artifact, not only in prose.

The `poc_mvp_live_touch_summary.json` recommendation is `"accept bounded local
POC proof"` — not "release-ready" or "demo-ready".

The map does not promote any of this to RC status. The evidence classification
table draws the seed/RC/lab-only boundaries explicitly.

**One observation (not a blocker):** All four POC contracts perform only integer
addition or boolean AND (`signal_score = visits + add_to_cart`,
`ready = inventory_ready && payment_ready`, etc.). This is important context
that the positive coverage is narrow by language feature, not just by contract
count. The map says "This is good POC coverage, not broad language coverage" —
correct, but the harness design should specify minimum language-feature diversity
for the RC corpus rather than just contract count. See NB-1.

---

### CH2: Missing negative/refusal evidence

**Verdict: correctly identified as the central gap.**

The map's "Missing Negative And Refusal Coverage" section names 11 required
cases before first RC:

```text
1. parse refusal for invalid syntax
2. unresolved symbol refusal
3. type mismatch refusal
4. warning-preserving successful compile (if warnings in public result)
5. CLI bad-path preflight refusal for --compiler-profile-source
6. CLI malformed-JSON prefusal for --compiler-profile-source
7. semantic compiler_profile_source.* refusal
8. PROP-038 strict-refusal case (if in RC scope)
9. refusal no-write assertion (no .igapp where refusal blocks assembly)
10. no public/report/runtime/deployment leakage scan
11. normalization failure case for acceptance harness design
```

Current partial coverage:
- (2) unresolved symbol: exists in `production_compiler_cli_proof` ✓
- (5)/(7): PROP-036 CLI/semantic profile-source refusals: exist ✓
- All others: absent ✓

The map correctly identifies this gap and does NOT attempt to close it within
the release-readiness mapping card. The next step is harness design, not
refusal corpus implementation. This is the right sequence.

**Observation (NB-4):** Item (4) — warning-preserving compile — is framed
conditionally ("if warnings are part of public result shape"). The harness
design should make a binding decision rather than leaving this conditional, to
prevent the warning/diagnostic contract from drifting during RC evidence
gathering.

---

### CH3: Artifact field stability and normalization gaps

**Verdict: correctly scoped with actionable table; one minor gap.**

The artifact field stability table (8 artifact areas) is thorough. The
normalize/exclude policy is directionally correct:

- source/igapp paths → repo-relative ✓
- exact hashes → held until hashing policy is pinned ✓
- message text → excluded until made part of refusal contract ✓
- hash shape and recomputability → separate policy from exact hash values ✓

Checking the actual POC artifacts against the table:

The `compile_transcript.json` uses repo-relative paths already:
`"igapp_path": "igniter-lang/experiments/poc_mvp_live_touch_v0/out/channel_signal_score.igapp"` —
no absolute paths present. The map says "normalize source paths to repo-relative
paths" — the POC already does this, so the normalization recommendation is
conservative and correct.

**Observation (NB-2):** The map cites `production_compiler_cli_proof` as a
useful "RC prerequisite" but does not define the reuse policy: can the
acceptance harness cite the existing proof run as evidence, or must it rerun in
a clean context? This is left for harness design to decide. The map should
at minimum note that rerun policy must be explicit in the harness design.

---

### CH4: Package/install/load-path smoke gaps

**Verdict: correctly scoped with the right caveat boundary.**

The minimum RC smoke matrix (5 commands) is well-defined:

```text
ruby -I igniter-lang/lib -e 'require "igniter_lang"; abort unless IgniterLang.respond_to?(:compile)'
igniter-lang/bin/igc compile SOURCE --out OUT.igapp
igniter-lang/bin/igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
igniter-lang/bin/igc compile BAD_SOURCE --out BAD.igapp
IgniterLang.compile(SOURCE, out: OUT.igapp)
```

The map correctly separates repo-local RC readiness from installed-gem
readiness and explicitly says:

> "Until that package/install matrix exists, the release candidate may claim
> a repo-local compiler release boundary, but not installed gem release
> readiness."

This is exactly the right caveat. No overclaim on installability.

**No material gap in this section.** The R52/R53/R54 CLI evidence anchors the
bounded `--compiler-profile-source` CLI surface correctly.

---

### CH5: Analyzer/tracer/visualizer scope creep

**Verdict: correctly held as design-only; no implementation authorization.**

The map explicitly places analyzer/tracer/visualizer as:

```text
design-only acceptance-harness candidate
implementation deferred
not release-blocking as UI/tooling
```

The "release-blocking" vs "not release-blocking" split is correct:

Release-blocking only:
- machine-readable acceptance inputs
- normalized comparisons
- PASS/HOLD/FAIL summary fields
- artifact-trace linkage

Not release-blocking:
- interactive visualizer
- public analyzer command
- tracer UI
- report/loader/CompatibilityReport integration

This matches the fractal synthesis decision (S3-R158-C5-A) which deferred
implementation and allowed design-only consideration inside release-readiness
mapping.

The map does not open any implementation or public API/CLI surface for this
category. No scope creep is present.

---

### CH6: Spark pressure leaking into direct integration

**Verdict: no leakage detected.**

The Spark sanitized pressure section presents four candidates as fixture/design
candidates only, each with an explicit "Forbidden implication" column:

| Candidate | Forbidden implication |
| --- | --- |
| `service_call_price_shadow_evidence` | No Spark raw data, no primary-ledger replacement, no production binding |
| `service_call_override_divergence_policy` | No automatic compiler requirement |
| `lead_channel_seed_review_decision` | No Spark IDs/classes as public Lang vocabulary |
| `orders_analytics_evidence_coverage` | No Spark access, fixture creation, or spec mutation now |

The closing statement is unambiguous: "No Spark fixture/spec/compiler/runtime
work is opened by this map."

The fractal synthesis (S3-R158-C5-A) established the same stance: "direct
Spark code/data access for Igniter-Lang agents" is not authorized. The map
does not drift from this.

---

### CH7: Ruby docs implying compiler compatibility too early

**Verdict: correct stance; no premature compatibility implied.**

The map says:

> "Ruby Framework package docs should wait for a stable Lang release-candidate
> export fixture."

And:

> "Future Ruby docs must describe Lang compiler bridge behavior as additive,
> report-only, metadata-only, and not runtime-enforced unless a later Lang
> gate explicitly changes that."

These statements match the fractal synthesis (S3-R158-C5-A) decision exactly:
"hold until Igniter-Lang declares a stable release-candidate export fixture."

R159 runs `C3-P1` (Ruby Framework docs hygiene) in parallel — that card handles
any currently stale docs, which is the right separation of concerns from the
release-readiness map.

**No overclaim on Ruby compatibility. No leakage.**

---

### CH8: Public/runtime/deployment closed-surface leakage

**Verdict: no leakage detected; closed surfaces are comprehensive.**

The "Closed Surfaces Preserved" section lists 17 prohibited categories:

```text
code implementation
release execution
public demo or release claims
analyzer/tracer/visualizer implementation
public API/CLI widening
root require changes
parser, classifier, TypeChecker, SemanticIR, assembler changes
loader/report
CompilationReport, CompilerResult, or CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework package docs or release changes
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, or demo work
```

This list is consistent with the fractal synthesis decision and the accumulated
gate inventory from prior rounds (R154, R155). The evidence classification table
also correctly marks internal carrier (`InternalProfileStaticDataCarrier`) as
"Not public API, report, artifact, or compiler pipeline evidence."

**Specific scan:** does the map itself produce any implementation authorization
by implication? No. The map is a design/report-only card. The recommended next
boundary is explicitly "design-only acceptance harness boundary, not
implementation or release execution."

---

## Non-Blocking Notes

### NB-1: RC corpus must specify minimum language-feature diversity, not just module count

All four POC contracts cover only `+` (integer addition) and `&&` (boolean AND).
The map says "3-5 coherent `.ig` modules plus minimal Add fixture" for the RC
corpus. This count guidance is insufficient: the RC corpus should require at
minimum one conditional/branch case and one contract with more than two inputs.
Language-feature coverage diversity is more meaningful than contract count for
an RC corpus. The harness design should make this explicit.

### NB-2: `production_compiler_cli_proof` reuse policy undefined

The map cites this proof as a "useful RC prerequisite, but must be rerun in an
RC matrix." It does not define whether the existing run can be cited as evidence
or whether a fresh clean-room run is required. This ambiguity could lead to
reuse-by-default behavior in the harness design. The harness design gate should
explicitly choose between: (a) rerun required, (b) existing run accepted as
evidence with named provenance anchor, or (c) hybrid (syntax/API smoke reruns,
existing refusal evidence cited).

### NB-3: RC non-claims section should have normative wording template

The documentation boundary section lists what must be stated in RC docs, but
provides no example wording. The harness design should include a normative
non-claims template — especially for the runtime-trace / proof-local /
not-production-runtime distinction — so that future agents don't drift the
language. The current `runtime_trace.json` field
`"trace_reason": "RuntimeSmoke proof-local evaluation trusted"` is the right
seed for this template.

### NB-4: Warning/diagnostic coverage position is conditional, not decided

"warning-preserving successful compile, if warnings are part of public result
shape" is left conditional in the missing-coverage list. The harness design
gate must make a binary decision: are warnings a required RC result-shape
element or deferred to post-RC? Leaving it conditional will create ambiguity
during evidence collection.

### NB-5: RC-wide negative scan token list needs to be declared, not implied

The map says "Need RC-wide negative scan" but does not enumerate the RC-level
token list. The POC negative scan used 14 tokens (Spark, production, demo,
deployment, signing, etc.) — this is correct for POC scope but is narrower
than what an RC-wide scan should cover. The harness design should declare
the full RC negative scan token list, drawing on the accumulated vocabulary
from PROP-036 (9 tokens), PROP-038 (excluded-namespace list), and the
public/report/runtime vocabulary established in the carrier proof.

---

## Verdict

**proceed — map is well-bounded with no blockers.**

The C1-D release-readiness map correctly:
- distinguishes POC seed evidence from RC readiness from public demo (CH1);
- names negative/refusal coverage as the central missing gap without attempting
  to fill it prematurely (CH2);
- provides a per-artifact normalization/exclusion table with correct stance
  on hash stability (CH3);
- defines minimum RC smoke matrix with an explicit installed-gem caveat (CH4);
- holds analyzer/tracer/visualizer as design-only without implementation
  authorization (CH5);
- keeps Spark as sanitized fixture/design candidates with explicit forbidden
  implications (CH6);
- aligns Ruby Framework with the fractal synthesis hold decision (CH7);
- preserves all named public/runtime/deployment closed surfaces (CH8).

Five non-blocking notes for C4-A / harness design gate:
- NB-1: RC corpus needs language-feature diversity requirement, not just count.
- NB-2: `production_compiler_cli_proof` rerun policy needs a binding decision.
- NB-3: RC non-claims docs need a normative wording template.
- NB-4: Warning coverage position must be decided, not left conditional.
- NB-5: RC-wide negative scan token list must be declared explicitly.

---

## Acceptance Recommendation for C4-A

**Accept the release-readiness map.**

Recommended next route:

```text
compiler-release-acceptance-harness-design-v0
Mode: design-only
```

The harness design gate should carry NB-1 through NB-5 as explicit inputs and
produce binding answers on:

1. RC corpus language-feature requirements (beyond module count);
2. `production_compiler_cli_proof` reuse policy;
3. normative non-claims wording template;
4. warnings in-scope decision for RC result shape;
5. complete RC negative scan token list.

Do not authorize implementation, release execution, or public claims from
this acceptance. Any widening of public API/CLI, runtime, Spark, Ruby
Framework, loader/report, CompatibilityReport, production deployment, or demo
surfaces requires a separate gate.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
code implementation
release execution or public demo/release claims
analyzer/tracer/visualizer implementation
public API/CLI widening
root require or compiler pipeline changes
loader/report, CompilationReport, CompilerResult, CompatibilityReport
.igapp, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework package docs or release changes
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment, or demo
```

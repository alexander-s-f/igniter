# Track: OOF Fragment Registry Semantics Review v0

Card: S3-R92-C2-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `oof-fragment-registry-semantics-review-v0`
Route: UPDATE
Depends on: S3-R92-C0-O
Status: done
Date: 2026-05-20

---

## Goal

Review OOF/fragment semantics for language correctness before Architect accepts
or redirects the shadow registry proof route.

This review is docs-only. It does not edit code, specs, or proposals, and it
does not authorize canon changes or implementation.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any later proof-local shadow registry
  experiment.
- `[Igniter-Lang Architect Supervisor]`: owns acceptance, redirect, or canon
  decisions.
- `[Igniter-Lang Bridge Agent]`: public API/CLI, loader/report,
  CompatibilityReport, and runtime surfaces remain closed.

---

## Sources Read

- `docs/org/tracks/oof-fragment-registry-shadow-proof-boundary-v0.md`
- `docs/reports/lang-r91-compiler-pack-shadow-profile-proof-v1.md`
- `docs/tracks/compiler-pack-shadow-profile-proof-v1.md`
- `experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `docs/tracks/compiler-pack-boundary-proof-fixture-and-oof-survey-v0.md`
- `docs/gates/compiler-pack-boundary-report-decision-v0.md`
- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/spec/ch4-fragment-classification.md`
- `docs/spec/ch6-semanticir.md`

No tests or broad proof commands were run.

---

## Semantics Verdict

Verdict:

```text
proceed-with-notes
```

The next `oof-fragment-registry-shadow-proof-v0` route is semantically safe if
it remains proof-only, data-only, and explicitly non-canon.

The shadow proof may model OOF descriptors and fragment registry entries, but it
must not change live compiler classification, public OOF codes, SemanticIR,
CompilationReport, `.igapp`, public API/CLI, loader/report,
CompatibilityReport, runtime, or production behavior.

---

## `oof`: Fragment, Status, Or Both

Recommended proof-local treatment:

```text
status-primary, fragment-projection-secondary
```

Meaning:

- `oof` is primarily a compile/report status: it means a program or contract is
  out-of-fragment and must not reach loadable SemanticIR.
- A proof-local `oof` fragment projection is acceptable for deterministic
  max-fragment summaries and registry coverage checks.
- The projection must carry explicit non-authority notes so it is not mistaken
  for a language capability or a loadable artifact class.

Why this is safest:

- Ch4 defines OOF as compile-time rejection.
- Ch6 explicitly forbids `fragment_class: "oof"` in a loadable
  `SemanticIRProgram`.
- R90/R91 need an `oof` entry to make ownership and precedence visible in
  profile/registry data.

Required proof invariant:

```text
oof_fragment_projection => blocked/non-loadable/status-only
```

The proof should compare `oof_as_fragment`, `oof_as_status`, and `oof_as_both`,
but the recommendation should be "both only as a proof projection, with status
as the semantic source of truth."

---

## Candidate Precedence Review

Candidate under review:

```text
oof > temporal > stream > escape > epistemic > core
```

Verdict:

```text
safe as proof-local candidate / not canon
```

Why it is safe for the shadow proof:

- `oof` first preserves compile rejection dominance.
- `temporal > stream > core` is consistent with PROP-028's refined Stage 3
  ordering.
- Ch6 already includes `escape` between `stream` and `core` for current
  artifact summaries.
- `escape > epistemic` preserves PROP-032 behavior: a contract that uses
  assumptions and also has escape/observed reads remains `escape`, while
  `assumption_refs` still carry epistemic provenance.
- `epistemic > core` lets pure assumptions-only contracts remain visible as
  epistemic without changing CORE computation semantics.

Proof note:

R92-C0-O mentions an alternate example with `epistemic > escape`. The R91
candidate with `escape > epistemic` is safer for the current compiler because
PROP-032 explicitly says escape plus epistemic declarations yields an
escape-level contract.

Required proof label:

```text
candidate / proof-local / non-canon
```

No classifier, assembler, manifest, or spec behavior may be changed based on
this candidate order.

---

## `epistemic` Treatment

Verdict:

```text
current assumptions compiler surface / PROP-033 remains closed
```

`epistemic` is correctly treated as the current assumptions surface:

- PROP-032 introduces `epistemic`.
- The assumptions proof path implements parser/source, classifier,
  TypeChecker, and SemanticIR propagation for assumption registry and
  `assumption_refs`.
- `OOF-A1` and `TASSUMP-1` are owned by the assumptions boundary.

Limits:

- `epistemic` does not authorize PROP-033 evidence-list validation.
- It does not authorize runtime assumption injection.
- It does not authorize receipt enforcement beyond existing descriptive
  propagation.
- It should not outrank `escape` in the proof-local precedence while PROP-032's
  current escape interaction remains accepted.

---

## OOF Descriptor Ownership Model

Recommended model for the proof:

```text
kernel service data populated by pack-owned descriptors
```

Do not model OOF descriptors as only installed pack data.

Reason:

- OOF code uniqueness, alias collisions, deprecation, public-code stability,
  and one-owner registry checks are cross-pack invariants.
- PROP-038 already models `strict_registries.oof_descriptors` as contract-level
  registry material with one-owner semantics.
- Individual language packs should own descriptor entries for their codes, but
  the registry service must validate the complete set.

Acceptable proof vocabulary:

| Concept | Recommended proof model |
| --- | --- |
| `OOFRegistry` | kernel/support service data |
| descriptor owner | pack or support boundary |
| descriptor validity | whole-profile registry check |
| aliases/deprecations | registry-level collision and replacement policy |
| public-code stability | descriptor field required before implementation |

`OOFRegistryPack` may remain a shadow support boundary name, but the semantics
should be "registry service populated by packs," not "ordinary optional language
pack."

---

## Fragment Registry Ownership Model

Recommended model:

```text
kernel service data populated by fragment-owner packs
```

Reason:

- Fragment precedence is global.
- Node/value/contract distinctions cut across pack boundaries.
- `temporal` has node TEMPORAL / value CORE behavior.
- `oof` is not loadable even if it appears in max-fragment summaries.
- Candidate fragments like `olap` and prohibited fragments like `progression`
  must be represented without becoming live classes.

Required proof fields should include at least:

- `name`
- `owner_pack_or_boundary`
- `current_or_candidate`
- `applies_to`
- `classification_kind`
- `value_flow_notes`
- `precedence_candidate`
- `canonical_status`
- `non_authority_notes`

---

## Profile-Contract Diagnostics Separation

Verdict:

```text
must remain separate from OOF
```

`compiler_profile_contract.*` and
`compiler_profile_contract_refusal.*` diagnostics are not OOF codes.

Required separation:

- `compiler_profile_contract.*` belongs to contract-object validity and nested
  `compiler_profile_contract_validation.diagnostics`.
- `compiler_profile_contract_refusal.*` belongs to internal strict terminal
  wrapper diagnostics.
- Neither namespace should be included in `strict_registries.oof_descriptors`.
- Neither namespace should be appended to top-level `report["diagnostics"]`
  without a separate decision.

This preserves PROP-038's vocabulary separation and prevents report-only
profile evidence from becoming language OOF authority.

---

## Open Questions For C3/C4

[Q] Should the C1 proof use the exact R91 candidate precedence
`oof > temporal > stream > escape > epistemic > core`, or also include a
negative comparison case proving why `epistemic > escape` is not current-safe?

[Q] Should the descriptor schema require both `source_stage` and
`compiler_layer`, or collapse them into one field for proof-local v0?

[Q] Should `OOF-*` parser hardening codes that are not yet fully parse-owned
declare `source_stage: parser` with `current_status: partial`, or use
`source_stage: classifier/typechecker` until live behavior catches up?

[Q] Should candidate `olap` be represented as `candidate_fragment` or only as
`owned_surface` under `OLAPPack` until a proposal promotes it?

[Q] Should `fragment_registry` include `applies_to: node | value | contract |
status`, making the `oof` projection explicitly status-only?

---

## Recommended Next Route

Proceed to:

```text
oof-fragment-registry-shadow-proof-v0
```

Route constraints:

- proof-only;
- data-only shadow registry;
- no compiler behavior changes;
- no spec/proposal edits;
- mark all precedence and `oof` modeling as non-canon;
- keep profile-contract diagnostics outside OOF;
- include closed-surface assertions in summary JSON if an executable proof is
  created.

Suggested proof emphasis:

1. Descriptor schema sufficiency, including aliases, deprecation, stability,
   and owner/layer fields.
2. `oof` status-primary / projection-secondary comparison.
3. Candidate precedence determinism with explicit non-canon marking.
4. `epistemic` current surface with PROP-033 closed.
5. Profile-contract diagnostics exclusion from OOF namespace.

Backup route remains:

```text
prop038-strict-terminal-regression-hardening-v0
```

Use only if the team chooses to harden strict terminal evidence before registry
semantics.

---

## Closed Surfaces

This review does not authorize:

- code edits;
- specs or proposal edits;
- canon fragment precedence;
- live OOF registry implementation;
- live FragmentRegistry implementation;
- pack registry implementation;
- compiler dispatch migration;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites;
- public OOF code renaming or diagnostic wording changes;
- public API/CLI widening;
- public strict source;
- `IgniterLang.compile` signature changes;
- loader/report or CompatibilityReport behavior;
- `.igapp`, manifest, golden, `.ilk`, receipt, signing, or production changes;
- compile refusal beyond the accepted internal-only strict terminal foundation;
- persisted strict terminal reports or sidecars;
- `CompilerResult` public shape changes;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory production evaluation, stream/OLAP production
  executors, cache, signing, or production behavior;
- progression scheduler/materializer/durable queue/checkpoint;
- Spark fixture/spec work or Spark production integration;
- treating Spark applied pressure as compiler authority.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S3-R92-C2-P1
Track: oof-fragment-registry-semantics-review-v0
Status: done

[D]
- Reviewed R92 C0-O, LANG-R91, R90 report/survey, PROP-028, PROP-032,
  PROP-038, Ch4, and Ch6.
- Verdict: proceed-with-notes.

[S]
- Model `oof` as status-primary, fragment-projection-secondary for proof only.
- R91 precedence `oof > temporal > stream > escape > epistemic > core` is safe
  as non-canon proof candidate.
- `epistemic` is current assumptions compiler surface; PROP-033 remains closed.
- OOF/fragment registries should be kernel service data populated by pack-owned
  entries.
- Profile-contract diagnostics must stay outside OOF.

[T]
- No code, specs, or proposals edited.
- No tests or broad proofs run.

[R]
- C3/C4 should pressure the `oof` projection invariant, precedence non-canon
  labeling, and profile-contract diagnostic separation.

[Next]
- Open `oof-fragment-registry-shadow-proof-v0` as proof-only/data-only if C3/C4
  accept this semantics review.
```

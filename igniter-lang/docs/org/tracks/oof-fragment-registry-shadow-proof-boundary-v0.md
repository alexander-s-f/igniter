# OOF Fragment Registry Shadow Proof Boundary v0

Card: S3-R92-C0-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: oof-fragment-registry-shadow-proof-boundary-v0
Route: UPDATE
Depends on: LANG-R91 / compiler-pack-shadow-profile-proof-v1
Status: done
Date: 2026-05-20
Authority: org-sidecar proof-boundary map / non-canon / non-implementation

---

## Goal

Re-anchor the next compiler mainline proof route on the LANG-R91 PASS result
and define the exact proof-only boundary for:

```text
oof-fragment-registry-shadow-proof-v0
```

This track does not authorize implementation.

---

## Read Set

```text
igniter-lang/roles/base-role.md
igniter-lang/docs/org/portfolio-guidance-log-v0.md
igniter-lang/docs/reports/lang-r91-compiler-pack-shadow-profile-proof-v1.md
igniter-lang/docs/tracks/compiler-pack-shadow-profile-proof-v1.md
igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json
igniter-lang/docs/gates/compiler-pack-boundary-report-decision-v0.md
igniter-lang/docs/tracks/stage3-round90-status-curation-v0.md
igniter-lang/docs/tracks/compiler-pack-boundary-proof-fixture-and-oof-survey-v0.md
```

---

## Re-Anchor On LANG-R91

LANG-R91 result:

```text
PASS
checks: 18/18
profile_id: compiler_profile_shadow_v1/sha256:34db3eb4dbe36e18f8e6dd73
```

Accepted meaning for R92:

```text
LANG-R91 PASS = proof evidence
LANG-R91 PASS != implementation authority
LANG-R91 PASS != live pack dispatch authority
LANG-R91 PASS != registry implementation authority
```

What LANG-R91 proved:

- deterministic shadow profile id;
- `shadow_no_dispatch`;
- required OOF ownership covered;
- required fragment class ownership covered;
- profile-contract diagnostics kept out of OOF namespace;
- `.igapp`, public/runtime, production, and Spark surfaces preserved closed.

What LANG-R91 did not prove:

- OOF descriptor schema sufficiency;
- alias/deprecation semantics;
- public-code stability policy;
- fragment registry semantics;
- whether `oof` is a fragment, status, or both;
- canonical fragment precedence;
- implementation-ready registry shape.

---

## Route Boundary

R92 may open only:

```text
oof-fragment-registry-shadow-proof-v0
```

Route type:

```text
proof-only
data-only shadow registry
no implementation
no compiler behavior change
```

Allowed model location:

```text
igniter-lang/docs/tracks/
igniter-lang/experiments/oof_fragment_registry_shadow_proof/
```

Registry data may be modeled in docs and/or proof-local experiment outputs only.

It must not be treated as:

- live registry implementation;
- compiler dispatch source;
- public diagnostic contract;
- canon fragment precedence;
- loader/report or CompatibilityReport source;
- runtime or production authority.

---

## Exact C1 Allowed Write Scope

C1 may create or update only:

```text
igniter-lang/docs/tracks/oof-fragment-registry-shadow-proof-v0.md
igniter-lang/experiments/oof_fragment_registry_shadow_proof/
igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json
```

Allowed C1 content:

- proof-local OOF descriptor table/data;
- proof-local fragment registry table/data;
- executable proof script, if practical;
- summary JSON with PASS/FAIL and closed-surface assertions;
- track doc explaining evidence, gaps, and next route recommendations.

C1 must not edit:

- `igniter-lang/lib/`;
- compiler specs;
- `igniter-lang/docs/spec/`;
- proposals;
- gates;
- current status;
- cards index, unless a separate status-curation card owns it;
- `.igapp` fixtures/goldens;
- public API/CLI docs;
- Spark fixtures/specs.

---

## Proof Contract

The proof should test descriptor and registry semantics, not only ownership.

### OOF Descriptor Schema Fields To Test

The proof-local descriptor schema should include at least:

```text
code
family
owner_pack_or_boundary
source_stage
compiler_layer
severity
public_code_stability
message_stability
aliases
deprecated
deprecated_by
replacement_code
source_refs
current_status
non_authority_notes
```

Recommended stage/layer vocabulary:

```text
parser
classifier
typechecker
semanticir
assembler
report
runtime_guard
proof_only
```

Required OOF descriptor checks:

- canonical `code` values are unique;
- aliases do not collide with canonical codes;
- deprecated codes retain explicit replacement or rationale;
- every descriptor has an owner;
- every descriptor declares source stage/layer;
- every descriptor declares public-code stability;
- profile-contract diagnostics are explicitly excluded from OOF namespace;
- runtime/proof-only helper diagnostics are not promoted into language OOFs.

### Fragment Registry Semantics To Test

The proof-local fragment registry should include at least:

```text
name
owner_pack_or_boundary
current_or_candidate
applies_to
classification_kind
value_flow_notes
precedence_candidate
canonical_status
non_authority_notes
```

Required fragment names to model:

```text
core
escape
temporal
stream
epistemic
oof
```

Candidate/non-canon fragment names to guard:

```text
olap
progression
```

Required fragment checks:

- required current fragments have owners;
- `progression` is not promoted to a fragment class;
- `olap` remains candidate unless separately authorized;
- temporal read node vs CORE-typed value distinction is representable;
- `epistemic` is current compiler evidence while PROP-033 remains closed;
- fragment registry can represent node/contract/status distinctions without
  changing compiler behavior;
- candidate precedence is deterministic in the proof data;
- candidate precedence is explicitly marked non-canon.

### `oof` Question

The proof must explicitly model and compare:

```text
oof_as_fragment
oof_as_status
oof_as_both
```

Acceptance does not require choosing the live answer. It requires making the
tradeoff visible:

- `oof_as_fragment`: easy to include in max-fragment summaries, but risks
  treating failure as language capability.
- `oof_as_status`: cleaner diagnostic/status model, but may not fit existing
  fragment summaries.
- `oof_as_both`: preserves current report intuition, but needs stronger
  invariants to avoid authority leakage.

The proof should recommend a candidate, but the recommendation remains
non-canon until a later Architect decision.

### Alias / Deprecation / Public-Code Stability Boundaries

The proof may model:

- aliases;
- deprecated codes;
- replacement codes;
- stage migration;
- public-code stability levels.

It must not:

- rename live OOF codes;
- delete live OOF codes;
- change public diagnostic wording;
- change parser/classifier/typechecker behavior;
- update specs as if the model were canon.

### Candidate Fragment Precedence Boundary

The proof may test candidate precedence such as:

```text
oof > temporal > stream > epistemic > escape > core
```

or another explicitly justified order.

Any precedence result must be marked:

```text
candidate / proof-local / non-canon
```

It must not be used to alter current compiler classification or assembler
fragment summaries.

---

## Acceptance Bar

Accept the C1 proof only if it demonstrates:

- LANG-R91 PASS is used as evidence, not authority;
- OOF descriptor schema covers ownership, stage/layer, severity, aliases,
  deprecation, and stability;
- canonical OOF codes are unique;
- aliases/deprecations are deterministic and collision-free;
- profile-contract diagnostics remain outside OOF namespace;
- runtime/proof helper diagnostics are not promoted;
- current fragment names and owners are covered;
- `olap` and `progression` are guarded as candidate/non-fragment status;
- `oof` fragment/status/both alternatives are explicitly evaluated;
- fragment precedence is deterministic but marked non-canon;
- outputs are confined to docs/track and/or `experiments/`;
- closed surfaces are preserved.

Hold if the proof:

- implies registry implementation;
- edits compiler code or specs;
- changes diagnostics, OOF codes, fragments, `.igapp`, public API/CLI, reports,
  runtime, or production behavior;
- treats candidate precedence as canon;
- treats Spark applied pressure as compiler authority.

---

## Closed Surfaces

This org-sidecar boundary track does not authorize:

- compiler code edits;
- compiler specs edits;
- implementation;
- `CompilerKernel` implementation;
- pack registry implementation;
- OOF registry implementation;
- FragmentRegistry implementation;
- live pack dispatch;
- profile-assembled compiler migration;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites;
- public API/CLI widening;
- public strict source;
- `IgniterLang.compile` signature changes;
- profile discovery/defaulting/finalization;
- mandatory `compiler_profile_id` transition;
- `.igapp` golden or manifest migration;
- `.ilk` profile references;
- CompilationReceipt links;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- compile refusal beyond the accepted internal-only strict terminal foundation;
- persisted strict terminal reports or sidecars;
- `CompilerResult` public shape changes;
- Ch6 or other spec edits;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend binding;
- BiHistory production evaluation;
- stream/OLAP production executors;
- production cache;
- signing or production verification;
- production deployment;
- progression scheduler/materializer/durable queue/checkpoint;
- Spark fixture/spec work;
- Spark production integration;
- treating Spark applied pressure as compiler authority.

---

## Disposition

Recommendation:

```text
open C1 as oof-fragment-registry-shadow-proof-v0
keep it proof-only and data-only
allow docs/tracks plus experiments/oof_fragment_registry_shadow_proof only
require explicit descriptor/fragment semantics and closed-surface assertions
implementation remains held
```

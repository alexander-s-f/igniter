# OOF/Fragment Registry Ownership And Canon Semantics Design v0

Card: LANG-R93-D1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: oof-fragment-registry-ownership-and-canon-semantics-design-v0
Route: UPDATE
Parent: [Igniter-Lang Supervisor]
Status: done
Date: 2026-05-20

---

## Goal

Design the OOF/Fragment registry ownership and canon-semantics boundary from
R92 evidence only.

This track is design-only. It does not edit specs, proposals, canon, compiler
code, runtime code, proof fixtures, or public surfaces.

---

## Evidence Read

- `igniter-lang/docs/tracks/stage3-round92-status-curation-v0.md`
- `igniter-lang/docs/gates/oof-fragment-registry-shadow-proof-decision-v0.md`
- `igniter-lang/docs/tracks/oof-fragment-registry-shadow-proof-v0.md`
- `igniter-lang/docs/tracks/oof-fragment-registry-semantics-review-v0.md`
- `igniter-lang/docs/discussions/oof-fragment-registry-shadow-proof-pressure-v0.md`

No code, spec, proposal, or runtime files were edited or consulted as authority
for this route.

---

## Design Verdict

Recommended boundary:

```text
OOFRegistry:
  kernel service data populated by pack-owned descriptors

FragmentRegistry:
  kernel service data populated by fragment-owner packs

oof:
  status-primary, secondary fragment projection candidate
  projection is blocked / non-loadable / status-only

precedence candidate:
  oof > temporal > stream > escape > epistemic > core
  non-canon until a later Architect/spec decision
```

This is the design posture for the next review. It is not implementation
authorization and not canon mutation.

---

## OOFRegistry Ownership Model

Design recommendation:

```text
OOFRegistry is kernel/support service data.
Descriptor entries are owned by language packs or support boundaries.
The complete registry is validated as one profile-level set.
```

Rationale from R92:

- OOF code uniqueness is a cross-pack invariant.
- Alias and deprecation relationships can cross local owner boundaries.
- Public-code stability requires one registry-level view of current, alias,
  candidate, descriptor-only, and proof-only codes.
- Profile-contract diagnostics must remain outside OOF, so the OOF boundary
  needs a whole-registry exclusion check.
- Treating `OOFRegistryPack` as an ordinary optional language pack would hide
  the kernel-level collision and stability guarantees.

Owner vocabulary:

| Concept | Design stance |
| --- | --- |
| registry owner | kernel/support service |
| descriptor owner | pack or support boundary |
| validation scope | complete active compiler profile |
| alias policy | registry-level collision and replacement policy |
| stability policy | descriptor-level field, validated by registry |
| optionality | descriptors may be pack-populated; registry service is not optional |

Descriptor ownership rule:

```text
Each OOF descriptor has exactly one owning pack or support boundary.
The registry service owns uniqueness, alias resolution, public stability, and
profile-level exclusion rules.
```

---

## FragmentRegistry Ownership Model

Design recommendation:

```text
FragmentRegistry is kernel service data populated by fragment-owner packs.
```

Rationale from R92:

- Fragment precedence is global, not local to a single pack.
- Node/value/contract classifications cross pack boundaries.
- `temporal` can classify a node while preserving CORE-typed selected values.
- `oof` may appear in summaries only as blocked status/projection, not as a
  loadable fragment.
- Guarded non-fragment classes such as `olap` and `progression` must be visible
  without becoming promoted fragment classes.

Fragment row ownership rule:

```text
Each fragment row names a fragment owner, but precedence, projection guards,
and current/candidate/non-fragment classification are validated by the registry
service as one profile-level table.
```

Minimum future design fields:

| Field | Required design purpose |
| --- | --- |
| `name` | Stable fragment or guarded class name. |
| `owner_pack_or_boundary` | Pack/support owner of the row. |
| `current_or_candidate` | Current, candidate, guarded, or excluded state. |
| `applies_to` | Node, value, contract, status, projection, or metadata scope. |
| `classification_kind` | Language fragment, status projection, owner surface, or non-fragment guard. |
| `value_flow_notes` | Node/value/contract split and loadability notes. |
| `precedence_candidate` | Non-canon ordering data, if present. |
| `canonical_status` | Canon/current/proposed/non-canon marker. |
| `non_authority_notes` | Explicit closure against live behavior inference. |

---

## `oof` Canon-Semantics Candidate

Recommended semantics:

```text
`oof` is primarily a compile/report status.
The secondary fragment projection exists only to summarize blocked programs.
The projection is non-loadable and never a capability.
```

Required invariant:

```text
oof_fragment_projection => blocked / non-loadable / status-only
```

Design consequences:

- `oof` may be present in registry data so summaries can explain ownership and
  precedence.
- `oof` must not become a loadable `SemanticIRProgram` fragment class.
- `oof` must dominate precedence candidates because rejection beats all
  loadable fragment summaries.
- `oof_as_both` from R92 remains only a proof-local modeling vehicle.
- Any future canon text should use the stricter phrase
  `status-primary / secondary fragment projection`.

Forbidden inference:

```text
oof in a fragment registry row does not mean the compiler supports an OOF
execution mode, OOF runtime mode, or OOF-loadable artifact.
```

---

## Public OOF Code Stability

Recommended stance:

```text
Current public OOF codes are stable-current unless an explicit later
proposal/spec decision changes them.
Compatibility aliases remain additive descriptors.
Candidate/proof-only markers do not become public OOF codes.
```

Stability classes for future descriptor design:

| Class | Meaning | Public behavior |
| --- | --- | --- |
| `stable_current` | Existing public diagnostic code. | Preserve code and wording unless separately authorized. |
| `stable_compatibility_alias` | Existing or accepted alias with replacement metadata. | Additive compatibility only; no deletion by registry design. |
| `candidate_proof_only` | Candidate code surfaced by proof/design pressure. | Not public compiler behavior. |
| `descriptor_only` | Registry metadata row for ownership/coverage. | Not necessarily emitted. |
| `proof_only` | Proof marker or experiment-only checkpoint. | Never public behavior from this design. |

Future public-code changes require a separate proposal/spec or Architect
decision. This design does not rename, delete, promote, or emit any OOF code.

---

## Descriptor Schema Needs Beyond R92

R92's proof schema is sufficient for the next design layer, but not sufficient
for implementation. Before any live registry work, the descriptor model needs
these additions or precise policies:

| Need | Reason |
| --- | --- |
| explicit uniqueness scope | Clarify profile-level uniqueness across pack-populated descriptors. |
| alias collision policy | Define how aliases, deprecated codes, and replacements are validated. |
| status-transition policy | Define allowed movement from proof-only/candidate to current/canon. |
| message stability granularity | Separate code stability from message wording stability. |
| source authority field | Distinguish spec/proposal/canon/proof-only authority. |
| non-OOF exclusion registry | Keep profile-contract and runtime helper diagnostics out of OOF. |
| descriptor lifecycle | Define current, candidate, deprecated, removed, and compatibility states. |
| pack install interaction | Clarify whether absent optional packs remove descriptors or only deactivate surfaces. |

These needs should be resolved in design/proof before implementation
authorization review.

---

## Precedence Candidate Treatment

Recommended candidate ordering:

```text
oof > temporal > stream > escape > epistemic > core
```

Status:

```text
candidate / non-canon / design reference only
```

Design meaning:

- `oof` dominates because compile/report rejection dominates loadability.
- `temporal` remains above `stream` and `core` per current R92 evidence.
- `escape > epistemic` is the safer R92-forward reference because a contract
  combining escape behavior with assumptions remains escape-level, while
  assumption references preserve epistemic provenance.
- `epistemic > core` keeps assumptions-only contracts visible without changing
  CORE value semantics.

This ordering must not be used to change classifier behavior, assembler
summaries, manifests, `.igapp` output, specs, or reports without a separate
authorization.

---

## Guarded Non-Fragment Classes

`olap` treatment:

```text
owner surface only / guarded non-fragment class
```

Design stance:

- OLAP diagnostics and ownership may appear in OOF descriptor ownership.
- `olap` is not promoted to a fragment class by this design.
- Any future OLAP fragment proposal needs separate evidence and authorization.

`progression` treatment:

```text
pipeline metadata / guarded non-fragment class
```

Design stance:

- Progression-related rows may document pipeline ownership or descriptor
  pressure.
- `progression` is not a language fragment class.
- No PROGRESSION fragment semantics are opened by this route.

Required future registry invariant:

```text
guarded_non_fragment != candidate_fragment
```

---

## Profile-Contract Diagnostic Separation

Design stance:

```text
compiler_profile_contract.* and compiler_profile_contract_refusal.* remain
outside the OOF namespace.
```

Required separation:

- profile-contract diagnostics are nested contract/report validation material;
- strict-terminal wrapper diagnostics remain internal strict-refusal material;
- neither namespace becomes an OOF alias, OOF descriptor, or top-level OOF
  diagnostic by this design;
- OOFRegistry validation should contain an explicit exclusion check for those
  namespaces before any live implementation is considered.

This preserves the R92 proof and pressure guarantees.

---

## Recommended Next Route

Recommended next route:

```text
oof-fragment-registry-design-pressure-v0
```

Route type:

```text
pressure-only / docs-only
no implementation
no spec/proposal/canon mutation
```

Goal:

```text
Pressure-test this R93 design boundary before deciding whether the next route
should be a proof-only registry-policy proof, docs/spec proposal route, or an
implementation authorization review hold.
```

Pressure questions:

- Does kernel service data populated by pack-owned descriptors avoid optional
  pack authority drift?
- Does status-primary / secondary projection prevent OOF from becoming a
  loadable capability?
- Is `escape > epistemic` the right non-canon reference under current R92
  evidence?
- Are `olap` and `progression` sufficiently guarded from fragment promotion?
- Are profile-contract diagnostics strongly enough excluded from OOF?
- Are descriptor schema gaps explicit enough to block premature implementation?

Fallback route if pressure finds substantial ambiguity:

```text
oof-fragment-registry-policy-proof-v0
```

That fallback should remain proof-only and should model collision/alias,
projection, guarded non-fragment, and exclusion policies without live compiler
behavior.

---

## Blockers Before Implementation

Implementation remains blocked until all of these are resolved:

- pressure review of this design route;
- exact future write scope;
- byte-for-byte diagnostic/report/golden parity strategy;
- uniqueness and alias collision policy;
- descriptor lifecycle and source-authority policy;
- public-code stability promotion policy;
- final treatment of `PINV-*` and `TINV-*` as descriptors, markers, or support
  metadata;
- explicit `oof` projection guard proof;
- explicit guarded non-fragment policy for `olap` and `progression`;
- explicit exclusion proof for `compiler_profile_contract.*`,
  `compiler_profile_contract_refusal.*`, and runtime helper diagnostics;
- Architect decision narrowly authorizing any implementation slice.

---

## Closed Surfaces

This design does not authorize:

- specs, proposals, or canon edits;
- compiler/runtime implementation;
- live `OOFRegistry` or `FragmentRegistry` behavior;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator, or
  dispatch changes;
- public OOF code renames, deletions, promotions, or diagnostic wording
  changes;
- public API or CLI widening;
- loader/report compiler-profile status;
- CompatibilityReport changes;
- `.igapp` or golden mutation;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend binding;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec/data work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: oof-fragment-registry-ownership-and-canon-semantics-design-v0
Status: done
Card: LANG-R93-D1

[D]
- Designed OOFRegistry as kernel service data populated by pack-owned
  descriptors.
- Designed FragmentRegistry as kernel service data populated by fragment-owner
  packs.
- Set `oof` forward semantics to status-primary / secondary fragment projection.
- Preserved public OOF stability and profile-contract diagnostic separation.

[S]
- Candidate ordering remains non-canon:
  oof > temporal > stream > escape > epistemic > core.
- `olap` and `progression` remain guarded non-fragment classes.
- Descriptor schema needs policy work before implementation.

[T]
- Docs-only track; no tests run.
- No specs, proposals, canon, code, runtime, public surfaces, or fixtures edited.

[R]
- Open `oof-fragment-registry-design-pressure-v0` next.
- Hold implementation until pressure, policy proof/design, exact write scope,
  parity strategy, and Architect authorization close.
```


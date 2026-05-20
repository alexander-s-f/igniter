# Track: PINV/TINV Lifecycle And Registry Classification Design v0

Card: LANG-R97-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `pinv-tinv-lifecycle-and-registry-classification-design-v0`
Status: done
Date: 2026-05-20

---

## Goal

Design the lifecycle and registry classification for `PINV-*` / `TINV-*`
before any OOF/Fragment Registry implementation-boundary design.

This track is design-only. It does not edit specs, proposals, canon, compiler
code, runtime code, proof fixtures, `.igapp` goldens, public API/CLI,
loader/report, CompatibilityReport, RuntimeMachine/Gate 3, Ledger/TBackend,
cache, signing, production behavior, or Spark fixture/spec material.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns proof-local registry/policy evidence.
- `[Igniter-Lang Architect Supervisor]`: owns acceptance and any future
  implementation-boundary decision.
- `[Igniter-Lang Bridge Agent]`: public/report/runtime surfaces remain closed.

---

## Evidence Read

- `docs/gates/oof-fragment-registry-shadow-proof-decision-v0.md` (R92)
- `docs/tracks/oof-fragment-registry-ownership-and-canon-semantics-design-v0.md` (R93)
- `docs/discussions/oof-fragment-registry-design-pressure-v0.md` (R94)
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md` (R95)
- `docs/gates/oof-fragment-registry-policy-proof-acceptance-decision-v0.md` (R96)
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`
- `docs/proposals/PROP-025-invariant-severity-levels-v0.md`
- `docs/tracks/invariant-severity-parser-and-typechecker-ownership-v0.md`
- `docs/tracks/invariant-severity-parser-impl-v0.md`
- `docs/tracks/invariant-severity-semanticir-lowering-v0.md`
- `experiments/invariant_severity_proof/summary.json`

No broad tests or proof commands were run.

---

## Design Verdict

Recommended classification:

```text
PINV-* / TINV-* are invariant support checkpoint metadata.
They are not public OOF descriptors.
They are not compiler-emitted diagnostics.
They may appear in proof-local registry models only as non-public marker rows.
```

Short form:

```text
support metadata, not OOF descriptors
```

Rationale:

- `PINV-*` and `TINV-*` name implementation/proof checklist milestones:
  parser invariant support and TypeChecker invariant support.
- The current public/error diagnostics are `OOF-IV*` and `OOF-I*`, not
  `PINV-*` / `TINV-*`.
- R95/R96 accepted OOF registry policy as proof-only and held implementation.
- Treating `PINV-*` / `TINV-*` as ordinary OOF descriptors would blur proof
  lifecycle with public diagnostic authority.

---

## Classification Decision

| Candidate classification | Decision | Reason |
| --- | --- | --- |
| Proof markers only | Partial | Correct for original proof usage, but too weak for lifecycle/design tracking after R96. |
| OOF descriptors | Reject for now | They are not emitted public diagnostics and should not enter live `oof_descriptors` as OOF codes. |
| Support metadata | Accept | Best fit: non-public checklist/lifecycle rows owned by `InvariantPack` support metadata. |
| Separate public diagnostic namespace | Reject | Creates a new public surface without need or authority. |
| Alias to `OOF-IV*` / `OOF-I*` | Reject | A checklist marker is not a diagnostic alias; alias policy should remain for public-code compatibility. |

Recommended registry bucket if modeled later:

```text
invariant_support_markers
```

not:

```text
oof_descriptors
```

The R92 shadow proof included `PINV-*` / `TINV-*` rows in
`oof_descriptors.shadow_registry.json` as proof markers. That remains accepted
as proof-local historical evidence, not the recommended future live registry
shape.

---

## Lifecycle States

| Lifecycle state | Meaning | Can be emitted as public diagnostic? | Registry placement | Promotion authority |
| --- | --- | ---: | --- | --- |
| `proof_only_marker` | Marker used only by a proof runner or track checklist. | No | proof artifact only | None; stays local unless accepted by design. |
| `support_metadata_candidate` | Candidate non-public support marker being reviewed. | No | proof/design support metadata | Architect/design acceptance. |
| `support_metadata_current` | Accepted non-public support marker for implementation/proof coverage tracking. | No | future `invariant_support_markers` metadata | Architect/design acceptance; no compiler emission. |
| `oof_descriptor_candidate` | Candidate future public OOF code such as deferred `OOF-I1`. | Not yet | `oof_descriptors` candidate row | Proposal/spec/gate before public behavior. |
| `oof_descriptor_current` | Current emitted OOF code such as `OOF-IV1`. | Yes | `oof_descriptors` | Existing accepted compiler behavior. |
| `deprecated_support_marker` | Old support marker retained for traceability. | No | support metadata with replacement/rationale | Docs/design decision. |
| `excluded_public_code` | Marker explicitly blocked from public diagnostic namespace. | No | exclusion/support note | Separate gate required to change. |

Recommended default for all `PINV-*` and `TINV-*`:

```text
support_metadata_current
```

with `public_code_stability: non_public_support_marker`.

---

## PINV/TINV Lifecycle Table

| Marker | Meaning | Current evidence | Recommended state | Related public OOF descriptors |
| --- | --- | --- | --- | --- |
| `PINV-1` | Add `invariant` keyword. | Parser implementation track and invariant proof PASS. | `support_metadata_current` | none |
| `PINV-2` | Add invariant attribute keywords. | Parser implementation track and invariant proof PASS. | `support_metadata_current` | none |
| `PINV-3` | Implement invariant declaration parsing. | Parser implementation track; parser proof checks. | `support_metadata_current` | `OOF-IV1`, `OOF-IV2`, `OOF-I4` |
| `PINV-4` | Dispatch `invariant` in contract body parser. | Parser implementation track and live parser proof. | `support_metadata_current` | none |
| `TINV-1` | TypeChecker handles `kind: invariant`. | TypeChecker proof and implementation track. | `support_metadata_current` | none |
| `TINV-2` | TypeChecker invariant semantic checks and effect mapping. | TypeChecker proof; SemanticIR lowering proof. | `support_metadata_current` | `OOF-IV3`, `OOF-I4`, future `OOF-I1`, `OOF-I2`, `OOF-I3` |
| `TINV-3` | Add invariant blocking rules to TypeChecker blocking set. | TypeChecker proof PASS. | `support_metadata_current` | `OOF-IV3` |

Notes:

- `PINV-*` and `TINV-*` should not be aliases for the related OOF codes.
- Related OOF descriptors are the public diagnostic rows.
- PINV/TINV rows describe implementation/proof lifecycle coverage.

---

## Public OOF Descriptor Separation

Current emitted or accepted invariant OOF descriptors:

| Code | Recommended registry class | Current posture |
| --- | --- | --- |
| `OOF-IV1` | `oof_descriptor_current` | Parser-owned current diagnostic. |
| `OOF-IV2` | `oof_descriptor_current` | Parser-owned current diagnostic. |
| `OOF-IV3` | `oof_descriptor_current` | TypeChecker-owned current diagnostic. |
| `OOF-I4` | `oof_descriptor_current` | Parser/TypeChecker current diagnostic. |

Deferred or candidate invariant OOF descriptors:

| Code | Recommended registry class | Current posture |
| --- | --- | --- |
| `OOF-I1` | `oof_descriptor_candidate` | Deferred until `@bitemporal` surface exists. |
| `OOF-I2` | `oof_descriptor_candidate` / advisory | Cross-contract warning handling remains open. |
| `OOF-I3` | `oof_descriptor_candidate` | Deferred until `~T` probabilistic type support exists. |
| `OOF-I5` | `oof_descriptor_candidate` | Deferred until requirements DB integration exists. |

Runtime/proof observation diagnostics such as `INV-WARN`, `INV-SOFT`,
`INV-METRIC`, and `INV-ERROR` are not OOF descriptors. They are invariant
runtime/proof observation categories and should remain outside OOF registry
unless a separate runtime/report design opens that namespace.

---

## Source-Authority Posture

| Source type | May define support marker lifecycle? | May promote to public OOF? | Notes |
| --- | ---: | ---: | --- |
| Proof track | Yes, proof-only/candidate evidence. | No | Can show need and coverage, not public authority. |
| Design track | Yes, support metadata recommendation. | No | This track can classify, not canonize compiler behavior. |
| Architect gate | Yes, accepted design posture. | Only if explicitly scoped. | R96 opens only design; implementation held. |
| Proposal/spec/canon update | Yes. | Yes, if explicitly accepted. | Required for new public diagnostic semantics. |
| Compiler implementation | No by itself. | No by itself. | Code evidence must follow prior authority. |

Posture:

```text
PINV/TINV source authority is support-lifecycle authority only.
Public diagnostic authority remains with OOF-IV* / OOF-I* descriptors.
```

---

## Future Registry Shape Recommendation

If a later design/proof models registry data beyond OOF descriptors, use
separate buckets:

```json
{
  "oof_descriptors": [],
  "fragment_rows": [],
  "support_markers": {
    "invariant_support_markers": []
  },
  "excluded_namespaces": []
}
```

Minimum `invariant_support_markers` row:

```json
{
  "code": "PINV-3",
  "family": "invariant_parser_support",
  "owner_pack_or_boundary": "InvariantPack",
  "source_stage": "parser",
  "compiler_layer": "parser",
  "lifecycle_state": "support_metadata_current",
  "public_code_stability": "non_public_support_marker",
  "related_oof_descriptors": ["OOF-IV1", "OOF-IV2", "OOF-I4"],
  "source_refs": [
    "docs/tracks/invariant-severity-parser-impl-v0.md",
    "experiments/invariant_severity_proof/summary.json"
  ],
  "non_authority_notes": "Support marker only; not emitted as a public diagnostic."
}
```

Required invariant:

```text
support_markers.*.code must not collide with oof_descriptors.*.code
unless the row is explicitly marked as an alias by a separate authority.
```

For PINV/TINV, do not mark as aliases.

---

## Blockers Before Implementation-Boundary Design

Before implementation-boundary design can open, the lane still needs:

- Architect acceptance or redirection of this PINV/TINV classification design;
- decision whether future registry model includes `support_markers` as a
  separate bucket or keeps them entirely out of registry artifacts;
- parity strategy proving no public diagnostics, reports, goldens, `.igapp`,
  CLI/API, loader/report, or CompatibilityReport behavior changes;
- exact treatment of runtime/proof invariant observation categories
  (`INV-WARN`, `INV-SOFT`, `INV-METRIC`, `INV-ERROR`);
- source-authority rule for promoting `oof_descriptor_candidate` to
  `oof_descriptor_current`;
- exact future write scope, if implementation-boundary design is ever opened.

---

## Recommended Next Route

Recommendation:

```text
implementation-boundary design hold until Architect accepts this classification.
```

After acceptance, the next route may be:

```text
oof-fragment-registry-implementation-boundary-design-v0
```

Route type:

```text
design-only
no implementation
no spec/proposal/canon mutation unless separately opened
```

Purpose:

```text
Define exact future write scope, parity requirements, source-authority gates,
and registry-shape boundaries for any possible live registry implementation.
```

If pressure disagrees with support metadata classification, route instead to a
small proof-only follow-up that models `support_markers` separately from
`oof_descriptors`.

---

## Closed Surfaces

This design does not authorize:

- implementation;
- specs, proposals, or canon edits;
- compiler/runtime code changes;
- live OOF registry or Fragment registry behavior;
- live support marker registry behavior;
- pack registry or live dispatch;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator, or
  report behavior changes;
- public diagnostic renames, deletions, promotions, aliases, or wording changes;
- public API/CLI widening;
- loader/report or CompatibilityReport changes;
- `.igapp`, `.ilk`, or golden mutation;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP production executors;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R97-D1
Track: pinv-tinv-lifecycle-and-registry-classification-design-v0
Status: done

[D]
- Classified PINV/TINV as invariant support checkpoint metadata.
- Rejected treating PINV/TINV as public OOF descriptors or aliases.
- Kept public OOF authority with OOF-IV* / OOF-I* descriptors.

[S]
- Recommended lifecycle default: support_metadata_current with
  public_code_stability: non_public_support_marker.
- Deferred OOF-I1/I2/I3/I5 remain candidate OOF descriptors, separate from
  PINV/TINV support markers.
- Runtime/proof categories INV-WARN/SOFT/METRIC/ERROR remain outside OOF.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Architect should accept or redirect this classification before any
  implementation-boundary design.

[Next]
- After acceptance, consider `oof-fragment-registry-implementation-boundary-design-v0`
  as design-only, or a proof-only support-marker model if pressure requests it.
```

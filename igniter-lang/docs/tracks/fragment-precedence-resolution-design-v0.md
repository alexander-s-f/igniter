# Track: Fragment Precedence Resolution Design v0

Card: LANG-R143-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R142-P1, LANG-R140-P1
Track: `fragment-precedence-resolution-design-v0`
Status: done
Date: 2026-05-22

---

## Goal

Resolve fragment precedence compatibility questions before fragment registry can
become migration evidence.

This is design-only. It does not edit the classifier, implement code, authorize
live fragment registry dispatch, change public diagnostics, reports, `.igapp`,
PROP-036, PROP-038, runtime, production, or Spark behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns the next proof-only compatibility
  adapter parity harness if opened.
- `[Igniter-Lang Bridge Agent]` — remains owner before any public/report/
  runtime-facing carrier opens.
- `[Igniter-Lang Meta Expert]` — may route this as migration checkpoint
  evidence, not as implementation authority.

---

## Evidence Read

- `docs/tracks/fragment-precedence-parity-proof-v0.md` (LANG-R142-P1)
- `experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_summary.json`
- `experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json`
- `docs/tracks/compiler-pack-pass-boundary-ownership-map-v0.md` (LANG-R140-P1)
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`
- selected current classified goldens for stream, assumptions, temporal, and
  OOF behavior

No code was edited. No proof commands were required for this design-only slice.

---

## R142 Fixed Point

R142 proved coverage and guard parity, but held live precedence migration:

```text
PASS:
  observed fragment names have shadow rows
  temporal + escape selects temporal
  OOF projection is blocked, non-loadable, non-capability
  olap/progression remain guarded non-fragments

HOLD:
  stream candidate precedence would not preserve current classifier behavior
  epistemic > escape candidate precedence would not preserve current mixed behavior
```

The important lesson:

```text
Current classifier behavior is not a single linear precedence function over
all declaration fragments.
```

The model needs to distinguish:

```text
declaration fragment presence
  from
contract-level selected fragment
```

---

## Resolution Summary

| Question | Resolution |
| --- | --- |
| Stream vs escape compatibility bucket | Keep current selected contract fragment as `escape`; model `stream` as declaration/node presence plus stream-specific metadata inside an escape-compatible bucket. |
| Epistemic vs escape mixed contract precedence | Keep current selected contract fragment as `escape`; preserve `epistemic` as declaration presence when assumptions are used. |
| Epistemic-only behavior | Keep selected contract fragment as `epistemic`. |
| Temporal vs escape behavior | Keep selected contract fragment as `temporal`; R142 already proves current behavior matches temporal outranking escape. |
| OOF status projection | Keep OOF status-primary, secondary fragment projection, blocked, non-loadable, and non-capability. |

Primary design decision:

```text
Split declaration fragment presence from contract-level selected fragment.
```

Secondary design decision:

```text
Add proof-local compatibility adapter semantics before treating fragment
registry precedence as migration evidence.
```

---

## Two-Layer Fragment Model

### Layer 1 — Declaration Fragment Presence

Declaration presence records which language surfaces appear inside a contract or
node set. It can include multiple fragments:

```text
core
escape
stream
epistemic
temporal
oof
```

Rules:

- `stream` may be present even when the selected contract fragment remains
  `escape`.
- `epistemic` may be present even when the selected contract fragment remains
  `escape`.
- `temporal` may be present with `escape` and still select `temporal`.
- `oof` may be present as blocked status projection.

This layer is appropriate for future registry ownership, proof coverage, pack
metadata, and explanation. It is not by itself the contract-level fragment
selection rule.

### Layer 2 — Contract-Level Selected Fragment

Selected fragment is the current classifier-compatible projection used by
goldens and downstream compiler behavior.

Proof-local selected-fragment adapter:

```text
if OOF present:
  selected = oof
elsif temporal present:
  selected = temporal
elsif escape present:
  selected = escape
elsif stream present:
  selected = escape
elsif epistemic present:
  selected = epistemic
else:
  selected = core
```

Notes:

- `stream present -> escape` preserves current stream compatibility bucket.
- `escape present` before `epistemic present` preserves mixed assumptions +
  escape behavior.
- `epistemic present` after escape preserves epistemic-only behavior.
- `temporal present` before escape preserves accepted temporal + escape
  behavior.
- `oof present` is status-primary and blocks loadability/capability.

This adapter is proof-local until accepted by a later gate.

---

## Precedence Candidate Treatment

R142 shadow row order:

```text
oof > temporal > stream > epistemic > escape > core
```

Resolution:

```text
Do not use this as live selected-fragment precedence.
```

Keep it only as historical/proof-local row-order evidence until a replacement
two-layer proof lands.

For selected-fragment migration evidence, use the compatibility adapter above.
If encoded as a selected-fragment order, it is effectively:

```text
oof(status) > temporal > escape > epistemic > core
```

with:

```text
stream -> escape compatibility bucket
```

This is not a classifier change. It is a model of current behavior.

---

## Exact Case Resolutions

| Case | Current behavior | Design resolution | Migration status |
| --- | --- | --- | --- |
| Core-only | `core` | Select `core`. | Resolved. |
| Stream ingress/fold | `escape` | Record `stream` presence; selected fragment remains `escape`. | Resolved by compatibility adapter; needs proof. |
| Epistemic-only | `epistemic` | Select `epistemic`. | Resolved. |
| Epistemic + escape | `escape` | Record `epistemic` presence; selected fragment remains `escape`. | Resolved by compatibility adapter; needs proof. |
| Temporal + escape | `temporal` | Select `temporal`; value remains CORE-typed where applicable. | Already passing; preserve. |
| OOF | `oof` | Status-primary blocked projection; non-loadable and capability-free. | Already passing; preserve. |
| OLAP/progression | no fragment assignment | Guarded `not_fragment_class`. | Already passing; preserve. |

---

## What Shadow Precedence Should Do Next

| Option | Decision |
| --- | --- |
| Preserve current classifier behavior exactly | Yes. This is required before migration evidence. |
| Add compatibility adapter semantics | Yes, proof-local only. |
| Revise candidate order | Partially. Do not revise registry rows yet; define selected-fragment adapter as separate from row order. |
| Split declaration presence from selected fragment | Yes. This is the key design resolution. |
| Remain held | Live dispatch remains held, but proof work may continue using the adapter model. |

Therefore:

```text
Fragment registry can become migration evidence only after a proof shows that
the two-layer compatibility adapter preserves current classifier goldens.
```

---

## Required Proof Matrix Before Migration Evidence

Recommended proof route:

```text
fragment-precedence-compatibility-adapter-proof-v0
```

Required checks:

- stream contracts select `escape` while recording stream presence;
- epistemic + escape selects `escape` while recording epistemic presence;
- epistemic-only selects `epistemic`;
- temporal + escape selects `temporal`;
- OOF remains status-primary, blocked, non-loadable, and non-capability;
- guarded non-fragments `olap` and `progression` remain non-fragment;
- all observed classifier goldens retain current `fragment_class`;
- adapter output is proof-local and not live classifier dispatch;
- no diagnostics, reports, `.igapp`, PROP-036, PROP-038, runtime, production,
  or Spark behavior changes.

Optional proof artifact shape:

```json
{
  "kind": "fragment_precedence_compatibility_adapter_matrix",
  "format_version": "0.1.0",
  "declaration_fragment_presence": {},
  "selected_fragment_adapter": {},
  "current_classifier_parity": {},
  "held_live_dispatch": true,
  "closed_surface_assertions": {}
}
```

---

## Hold Reasons Before Implementation Review

Live fragment registry dispatch remains held because:

- current classifier behavior is compatibility-bucketed, not purely linear;
- the existing shadow order would change stream and mixed epistemic/escape
  contract fragments if made live;
- no proof has yet shown the two-layer adapter against all relevant goldens;
- no classifier adapter write scope is authorized;
- no public/report/artifact/runtime surface is authorized.

Implementation review should remain later even after adapter proof, because
classifier dispatch migration would still require:

- exact write scope;
- byte-for-byte classifier parity;
- OOF and fragment registry parity;
- parser/typechecker/SemanticIR/assembler regression matrix;
- explicit no-public/no-report/no-`.igapp` assertions;
- Architect authorization.

---

## Closed Surfaces

Still closed:

- code implementation;
- classifier edits;
- live fragment registry dispatch;
- public diagnostics;
- reports and `CompilationReport`;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, and
  deployment behavior.

---

## Recommendation

Recommendation:

```text
proof next
```

Suggested next card:

```text
fragment-precedence-compatibility-adapter-proof-v0
```

Goal:

```text
Prove the two-layer declaration-presence + selected-fragment compatibility
adapter against current classifier goldens, preserving current behavior exactly.
```

Do not open implementation review yet.

---

## Handoff

[D] Fragment precedence should be modeled as two layers: declaration fragment
presence and contract-level selected fragment. A single live linear order is
not compatible with current classifier behavior.

[S] Stream is currently escape-compatible at contract level. Mixed epistemic +
escape selects escape. Epistemic-only selects epistemic. Temporal + escape
selects temporal. OOF remains status-primary, blocked, non-loadable, and
non-capability.

[T] No tests were run; this was a design-only track with no code changes.

[R] Route `fragment-precedence-compatibility-adapter-proof-v0`. Hold live
fragment registry dispatch and implementation review.

[Next] Research Agent can prove adapter parity; Compiler/Grammar should review
again before any classifier migration authorization.

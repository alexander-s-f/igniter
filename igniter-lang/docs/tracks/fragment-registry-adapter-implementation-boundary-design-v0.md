# Track: Fragment Registry Adapter Implementation Boundary Design v0

Card: S3-R145-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R144-P1
Track: `fragment-registry-adapter-implementation-boundary-design-v0`
Status: done
Date: 2026-05-22

---

## Goal

Design the boundary for a future fragment registry compatibility adapter,
without authorizing implementation or changing live classifier dispatch.

This is design-only. It does not edit code, specs, proposals, classifier
behavior, diagnostics, reports, `.igapp`, PROP-036, PROP-038, runtime,
production, or Spark behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns proof-only adapter/parity evidence.
- `[Igniter-Lang Bridge Agent]` — must review before public/report/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark carriers open.
- `[Igniter-Lang Meta Expert]` — may route this as implementation-boundary
  evidence, not implementation authorization.

---

## Evidence Read

- `docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md`
  (LANG-R144-P1)
- `docs/tracks/fragment-precedence-resolution-design-v0.md` (LANG-R143-D1)
- `docs/tracks/fragment-precedence-parity-proof-v0.md` (LANG-R142-P1)
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json`
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json`
- `lib/igniter_lang/classifier.rb` read-only touchpoints:
  - declaration `fragment_class` assignment;
  - `contract_fragment_for`;
  - OOF log projection;
  - stream, assumptions, temporal, and escape classification branches.

No code was edited. No proof commands were required for this design-only slice.

---

## Current Fixed Point

R144 proves the two-layer compatibility adapter as proof-local migration
evidence:

```text
declaration fragment presence
  -> selected fragment compatibility adapter
  -> current classifier-compatible selected fragment
```

R144 PASS evidence:

- 23/23 observed classified contracts retain current selected
  `fragment_class`;
- stream presence can be recorded while selected fragment stays `escape`;
- epistemic + escape can record epistemic presence while selected fragment
  stays `escape`;
- epistemic-only stays `epistemic`;
- temporal + escape stays `temporal`;
- OOF stays status-primary, blocked, non-loadable, and non-capability;
- adapter live dispatch remains held.

Current classifier touchpoint:

```ruby
contract_fragment_for(declarations, diagnostics, modifier:)
```

This method already encodes selected-fragment compatibility:

```text
oof via diagnostics
core only
temporal before escape
escape before epistemic
epistemic only
fallback oof
```

Therefore a future adapter must not replace this method until parity and an
explicit classifier write-scope gate exist.

---

## Boundary Design Table

| Boundary question | Design decision |
| --- | --- |
| Where can declaration-fragment presence live later? | Proof/model layer first; later possibly an internal adapter result beside classified declarations, but not in live `classified_program` output without authorization. |
| Where can selected-fragment compatibility live later? | Near classifier semantics because it models `contract_fragment_for`; not in report assembly, runtime, or artifact layers. |
| Does adapter belong in classifier? | Conceptually yes, but implementation must remain held. First live candidate should be direct-require internal helper, not wired into `Classifier`. |
| Does adapter belong in registry data? | Registry data can supply rows/presence vocabulary, but selected-fragment compatibility is semantic adapter logic, not plain data. |
| Does adapter belong in profile/pack metadata? | Profile/pack metadata may reference adapter proof/digest and pack ownership, but must not execute selected-fragment dispatch. |
| Does adapter belong in report assembly? | No. Reports may not become the source of classifier semantics or readiness. |
| Can it affect `.igapp`? | No. `.igapp`/manifest/goldens remain closed. |
| Can it change public diagnostics? | No. OOF and diagnostics remain unchanged. |

---

## Candidate Owner / Location Decision

Recommended ownership:

```text
FragmentRegistryPack owns declaration fragment vocabulary and rows.
Classifier boundary owns selected-fragment compatibility semantics.
CompilerProfile/pack metadata may reference proof evidence only.
```

Recommended first implementation location, if later authorized:

```text
direct-require-only internal helper near classifier/fragment registry boundary
```

Candidate file name, design-only:

```text
igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb
```

This file is not authorized by this track. If opened later, it should:

- be direct-require-only;
- not be required from `lib/igniter_lang.rb`;
- not be called by `Classifier` in the first implementation slice unless a
  separate classifier wiring gate authorizes it;
- accept proof/model inputs, not parsed source files;
- return internal adapter results only;
- preserve selected fragment exactly against R144 matrix.

Rejected locations for first implementation:

| Location | Reason |
| --- | --- |
| `lib/igniter_lang/classifier.rb` wiring | Would change live classifier dispatch surface. |
| `oof_fragment_registry.rb` | Registry helper owns data/source validation, not selected-fragment semantic projection. |
| `CompilationReport` / report assembly | Would turn compiler semantics into report behavior. |
| `Assembler` / `.igapp` | Would mutate artifact surface. |
| `CompilerProfile` / PROP-036 carrier | Would confuse adapter evidence with profile identity. |
| PROP-038 validator | Would confuse fragment precedence with contract validation/refusal authority. |
| Runtime/Spark surfaces | Not compiler fragment semantics. |

---

## Representation Boundaries

### Declaration-Fragment Presence

Future representation candidates:

| Candidate | Status | Notes |
| --- | --- | --- |
| Proof-local adapter matrix rows | Allowed now | R144 already does this. |
| Internal adapter result field | Possible later | Direct-require-only helper, no classifier wiring. |
| `classified_contract` field | Held | Would mutate goldens/output shape. Needs explicit classifier/report/golden authority. |
| `CompilationReport` field | Held/rejected for first slice | Would create report carrier and Bridge pressure. |
| `.igapp` manifest/contract artifact | Closed | Requires assembler/manifest authority and PROP-036 review. |

### Selected-Fragment Compatibility

Future representation candidates:

| Candidate | Status | Notes |
| --- | --- | --- |
| Proof-local adapter rules | Accepted as proof evidence | R144 PASS. |
| Internal helper method | Possible later | Must mirror current classifier exactly and stay direct-require-only first. |
| Replacement for `contract_fragment_for` | Held | Requires classifier implementation gate and byte-for-byte parity. |
| Registry row precedence only | Rejected for now | R142 proved single linear row order is not sufficient. |
| Report/runtime adapter | Rejected | Wrong layer. |

---

## Required Invariant Checklist

Any future implementation card must prove:

| Invariant | Required result |
| --- | --- |
| Stream selected fragment | Stream presence may not change selected fragment from `escape`. |
| Epistemic + escape selected fragment | Mixed epistemic + escape may not change selected fragment from `escape`. |
| Epistemic-only selected fragment | Epistemic-only remains `epistemic`. |
| Temporal + escape selected fragment | Temporal + escape remains `temporal`. |
| OOF projection | OOF remains status-primary, blocked, non-loadable, non-capability. |
| Guarded non-fragments | `olap` and `progression` remain `not_fragment_class`. |
| Current classifier parity | All observed classifier goldens keep current selected `fragment_class`. |
| Adapter non-authority | Adapter result is proof/internal evidence, not live dispatch by default. |
| Diagnostics stability | No diagnostic code/message/stage changes. |
| Output stability | No `classified_program`, report, `.igapp`, or public result shape changes unless separately authorized. |
| Closed surfaces | No public/API, loader/report, CompatibilityReport, runtime, production, or Spark behavior. |

Minimum proof matrix before any code write:

```text
R144 adapter matrix PASS
classifier_pass_proof PASS
contract_modifiers_proof PASS
assumptions proof/golden fragment parity PASS if touched
fragment precedence parity matrix still references R144 resolution
no root require / no classifier wiring unless explicitly authorized
```

---

## Migration Risks

| Area | Risk | Mitigation |
| --- | --- | --- |
| Stream | Treating `stream` precedence as selected fragment would drift current `escape` bucket. | Keep `stream` as presence; selected fragment `escape`. |
| Escape | Escape is both trust boundary and compatibility bucket. | Preserve escape-before-epistemic rule for selected fragment; document presence separately. |
| Epistemic | Linear precedence would make mixed epistemic + escape select `epistemic`. | Record epistemic presence while selected fragment remains `escape` when escape is present. |
| Temporal | Temporal already outranks escape and passes parity. | Preserve temporal-before-escape selected rule. |
| OOF | OOF can look like fragment capability if modeled carelessly. | Keep status-primary projection; blocked, non-loadable, non-capability. |
| Registry data | Row order alone cannot express compatibility buckets. | Treat registry row order as vocabulary/metadata; adapter rules select contract fragment. |
| Classifier wiring | Replacing `contract_fragment_for` can silently drift goldens. | First implementation direct-require helper only; classifier wiring needs separate gate. |
| Reports/artifacts | Presence data could look like public capability/readiness. | Keep out of reports/`.igapp` until Bridge + authority gates. |

---

## Implementation Blockers

Implementation review must remain blocked until all are true:

- Architect opens a specific implementation card with exact write scope;
- implementation target is named as proof/internal helper, classifier wiring,
  or another surface;
- R144 parity remains accepted;
- invariant checklist is converted into executable proof assertions;
- root require policy is explicit;
- classifier wiring is explicitly authorized or explicitly forbidden;
- output/golden mutation policy is explicit;
- PROP-036 and PROP-038 non-mutation are restated;
- Bridge pressure is completed before any report/public/manifest/runtime
  carrier opens.

Additional blockers before classifier wiring:

- byte-for-byte current classifier output parity;
- no change to `contract_fragment_for` semantics unless the change is proven
  equivalent;
- no declaration-presence field added to `classified_contract` without golden
  update authority;
- parser/typechecker/SemanticIR/assembler regression matrix defined.

---

## What Remains Proof-Only

Until separate authorization:

- declaration-fragment presence rows;
- selected-fragment compatibility adapter rules;
- adapter matrix digests;
- fragment registry row precedence;
- profile/pack references to fragment adapter evidence;
- any future helper file name;
- any claim that adapter output is migration evidence for live dispatch.

Proof-local evidence may be cited in tracks and future gates. It must not be
interpreted as live compiler behavior.

---

## Closed Surfaces

Still closed:

- code implementation;
- classifier edits or live dispatch;
- root require;
- public diagnostics;
- reports and `CompilationReport`;
- `CompilerResult`;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, and
  deployment behavior.

---

## Recommendation

Recommended next route:

```text
implementation review later
```

If progressing, first ask for an implementation-authorization review for a
direct-require-only internal helper:

```text
fragment-registry-compatibility-adapter-internal-helper-v0
```

Recommended first slice constraints:

- new helper file only;
- no root require;
- no classifier wiring;
- consumes proof/model data only;
- emits internal adapter result only;
- proves R144 parity and closed surfaces.

Do not open classifier wiring, public/report carriers, `.igapp`, runtime, or
production behavior from this design.

---

## Handoff

[D] Future adapter belongs semantically at the classifier/fragment-registry
boundary, but first implementation candidate should be a direct-require-only
internal helper, not live classifier dispatch.

[S] Declaration presence can be represented later in proof/internal adapter
results. Selected-fragment compatibility should stay near classifier semantics
and preserve R144 invariants exactly.

[T] No tests were run; this was a design-only track with no code changes.

[R] Hold implementation until an explicit gate opens a helper-only slice. Keep
classifier wiring, reports, `.igapp`, public/runtime surfaces closed.

[Next] Architect may open helper implementation authorization, request more
proof pressure, or hold at R144 adapter parity.

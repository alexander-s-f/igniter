# History-S18: External Effects Minimal Slice Map

Date: 2026-05-11  
Stage: History-S18  
Agent: [Igniter-Lang History Curator]  
Status: compact archive report; not canon; not a proposal  

## Compact Claim

The external Agent-C/D effect research has partly crossed into current
Igniter-Lang through **PROP-031 contract modifiers**. That slice is now
implemented/proven at the parser/classifier/typechecker/SemanticIR level, with
implicit `pure` default, OOF-M1 for `pure` contracts declaring `escape`, and
`observed/effect/privileged/irreversible` widening toward `escape` or
`temporal` where applicable.

Everything beyond that is still future pressure:

- no Effect Surface validation;
- no authority resolution;
- no profile binding as an effect policy system;
- no receipt/failure/compensation enforcement;
- no runtime execution semantics for effect classes.

S18 therefore separates the landed minimal slice from the next possible slices,
so future agents do not accidentally re-propose what has already landed or
over-claim what has not.

## Source Set

Current / canon-adjacent:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/proposals/PROP-031-contract-modifiers-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`
- `igniter-lang/lib/igniter_lang/parser.rb`
- `igniter-lang/lib/igniter_lang/classifier.rb`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`

External pressure:

- `playgrounds/docs/external/Agent-C/PROP-External-Effects-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Contract-v0.md`
- `playgrounds/docs/external/Agent-C/GAPS-Impl-vs-Spec-v0.md`
- `playgrounds/docs/external/Agent-C/TRANSITION-PLAN-v0.md`
- `playgrounds/docs/external/interview/interview-agent-D-1-analysis.md`

Prior compression:

- `igniter-lang/docs/archive/history/history-s17-forms-research-snapshot.md`

## Current Reality Map

| Signal | Current Category | Evidence | Notes |
| --- | --- | --- | --- |
| Optional `pure/observed/effect/privileged/irreversible` prefix | implemented / experiment-pass | `PROP-031`, current-status, parser/classifier/SemanticIR code | Landed as syntax + metadata + classifier behavior, not full effect semantics. |
| Implicit `pure` default | implemented | `PROP-031`, parser default | Backward-compatible: unmodified `contract` is normalized to `pure`. |
| OOF-M1: `pure` cannot declare escape | implemented / experiment-pass | `PROP-031`, classifier | Minimal determinism guard. |
| `observed` + temporal precedence | implemented / experiment-pass | current-status V-3 golden note | Temporal body remains `temporal`; modifier is orthogonal. |
| Effect Surface seven fields | research_unrealized | Agent-C `PROP-External-Effects-v0`, gap docs | Not implemented; future proposal-pressure only. |
| Authority / capability resolution by effect class | research_unrealized | Agent-C effects/profile docs | Not implemented. Existing `escape` is a capability boundary, not this full model. |
| Receipt/failure/compensation obligations | research_unrealized | Agent-C effects/contract docs | Values preserved; no compiler enforcement yet. |
| `via profile` as effect policy | research_unrealized / adjacent | transition plan, profile docs | Profile architecture exists elsewhere as compiler-pack direction, but not this effect policy system. |
| Runtime effect execution semantics | parked / Stage-4-scale | current-status closed runtime surfaces | Do not infer live effect behavior from modifiers. |

## Minimal Slice Boundary

The landed slice is deliberately small:

```text
source modifier
  -> parser `modifier`
  -> classifier fragment mapping / OOF-M1
  -> typechecker passthrough
  -> SemanticIR `modifier`
  -> proof goldens
```

It does **not** mean:

- `effect contract` is allowed to mutate real systems safely;
- `privileged contract` has authority resolution;
- `irreversible contract` has compensation or audit enforcement;
- `observed contract` automatically creates observation receipts;
- profiles govern effects;
- runtime executes effect classes differently.

This is an important historical correction to S17: contract modifiers moved from
`research_unrealized` to `implemented / experiment-pass`, while the accountability
system around them remains future work.

## Next Slice Candidates

| Candidate | Category | Recommended Route | Why |
| --- | --- | --- | --- |
| Effect Surface minimal metadata | proposal_candidate | Meta Expert -> Compiler/Grammar | Depends on PROP-031; adds declared shape without runtime execution. |
| `output ... evidence [...]` / evidence refs | proposal_candidate | Compiler/Grammar | Medium-size parser/SemanticIR slice; reinforces accountability without full effects. |
| Authority field shape | research_to_proposal | Meta Expert first | Semantic pressure is high; risk of over-specifying capability model. |
| Receipt/failure/compensation fields | research_to_proposal | Needs staged split | Valuable but should not land as one seven-field block without proof strategy. |
| Profile effect policy | parked / design-lane | Architect or Meta Expert lane decision | Requires compiler pass and policy model, not just parser grammar. |
| Runtime effect execution | closed / later-stage | Stage-gated runtime work | Current status keeps broad production runtime surfaces closed. |

## Proposed Slicing Order

1. **Effect Surface Metadata v0**  
   Capture only metadata fields on `effect/privileged/irreversible` contracts:
   `affects`, `receipt`, `failure`, maybe `idempotency`. No runtime execution.

2. **Authority / Reversibility v0**  
   Add `authority`, `reversibility`, and `compensation/no_compensation` only after
   the metadata shape is stable.

3. **Evidence References v0**  
   Decide whether `output ... evidence [...]` belongs before or after Effect
   Surface. This may be the smallest accountability win.

4. **Profile Policy v0**  
   Treat as a compiler-pass design, not a syntax tail on contracts.

5. **Runtime Effect Semantics**  
   Keep explicitly out of near-term history/proposal compression unless a runtime
   stage opens it.

## Values Preserved

- Contract modifiers are meaning labels, not authority.
- Declared effects are better than hidden consequences.
- `escape` remains a boundary, not a full accountability model.
- Receipts and evidence should eventually witness consequences.
- Runtime must not infer safety from syntax alone.
- Additive-first migration worked: a small syntax/metadata slice landed without
  forcing the entire Agent-C/D theory into canon.

## Superseded / Do-Not-Repeat

Do not re-open these as if they are unresolved:

- "Should contract modifiers exist at all?" — they now exist as PROP-031.
- "Unmodified contracts need a new default" — current default is implicit `pure`.
- "Effect classes must land all at once" — PROP-031 intentionally landed without
  Effect Surface/Profile/runtime enforcement.

Do not promote these as if they are resolved:

- Effect Surface fields are not current compiler obligations.
- `privileged` does not mean authority is checked.
- `irreversible` does not mean compensation exists.
- `observed` does not mean receipt/evidence is automatic.
- `via profile` is not yet the Agent-C profile policy system.

## Rotation / Read Recommendations

Keep these hot for future effect work:

- `PROP-031-contract-modifiers-v0.md`
- current-status contract-modifier rows
- canonical semantic model rows for contract modifiers
- `PROP-External-Effects-v0.md`
- `GAPS-Impl-vs-Spec-v0.md`
- this S18 report

Keep these warm:

- `PROP-Contract-v0.md`
- `PROP-Profile-v0.md`
- `TRANSITION-PLAN-v0.md`
- Agent-D Session 2 analysis

Skip by default:

- raw external interviews;
- full Agent-C forms docs unless the next slice touches forms;
- service-loop docs unless the next slice touches runtime/liveness.

## Stage-Close Handoff

Compact claim:

- PROP-031 has already absorbed the smallest useful external-effects slice:
  contract modifiers as syntax/metadata/classifier pressure. The next work is
  not "add modifiers" but "decide the next accountability layer."

Source set:

- current status/context, PROP-031, CSM, compiler code, Agent-C effect docs,
  S17.

Categories applied:

- `implemented`
- `experiment-pass`
- `proposal_candidate`
- `research_to_proposal`
- `research_unrealized`
- `parked`
- `closed_later_stage`
- `do_not_repeat`

Values preserved:

- declared consequences;
- syntax is not authority;
- effect classes need receipts/evidence eventually;
- minimal additive slices are safer than wholesale spec migration.

Accepted / implemented signals:

- contract modifiers;
- implicit `pure`;
- OOF-M1;
- modifier passthrough into SemanticIR;
- observed temporal precedence.

Superseded / rejected signals:

- treating all effect work as unimplemented;
- trying to land full Agent-C Effect Surface in one step;
- treating modifiers as runtime authorization.

Research still alive:

- minimal Effect Surface metadata;
- evidence refs;
- authority/reversibility/compensation;
- profile policy pass;
- runtime effect semantics later.

Duplicate / rotation recommendations:

- Future agents should start from this report before reopening Agent-C effects.
- Use raw external docs for evidence only after deciding the exact next slice.

Unresolved questions:

- Is the smallest next slice Effect Surface metadata or output evidence refs?
- Which fields are required for `effect` vs `privileged` vs `irreversible` in the
  first enforceable compiler pass?
- Should authority be a field, a capability reference, or a profile obligation?
- Where should receipt/failure types live in SemanticIR?

Changed files:

- `igniter-lang/docs/archive/history/history-s18-external-effects-minimal-slice-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- **History-S19: Evidence / Receipt Minimal Slice Map** — compress current
  evidence/receipt signals across PROP-031, assumptions, temporal observations,
  external effect research, and old OSINT traces into a proposal-readiness map.

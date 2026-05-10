# History-S15 Syntax Pressure Backlog Map

Status: archived history report and syntax-pressure backlog map  
Date: 2026-05-10  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S15  
Source posture: compress syntax pressure across history and private external workbench; no canon/spec/proposal files changed

## Compact Claim

Igniter-Lang syntax pressure now has three distinct layers:

1. **Current/proposal-only surfaces** already tracked by active docs:
   `entrypoint`, `section`, executor approval, temporal scope exclusion, and
   queued Stage 3 syntax candidates.
2. **Research pressure** from expert series and external labs:
   graph-native bindings, clean-form syntax, forms, pipelines, guards,
   observation kinds, and effect taxonomy.
3. **Do-not-promote zones**:
   exact Agent-A/B/C syntax, safety-critical domain promises, broad `Any`, and
   `external pure` as a catch-all.

The durable rule remains:

```text
syntax pressure -> proposal -> proof -> spec/code sync -> canon
```

No syntax enters canon from archive, playground, external workbench, or expert
reports without that route.

## Source Set

Primary:

- `igniter-lang/docs/archive/history/history-s10-igniter-lang-expert-series-map.md`
- `igniter-lang/docs/archive/history/history-s13-external-pressure-corpus-map.md`
- `igniter-lang/docs/archive/history/history-s14-external-pressure-fixture-backlog.md`
- `playgrounds/docs/external/README.md`

Comparison:

- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/proposals/`

Context note:

- `playgrounds/docs/external/` is now indexed as a private parallel research
  workbench, not as archive history. This S15 report only compresses its syntax
  pressure for history-curation purposes.

## Syntax Pressure Classification

| Pressure | Source | Category | Current disposition |
| --- | --- | --- | --- |
| `entrypoint` / `section` | PROP-029, current status/value index | active proposal | Proposal-only; parser/typechecker proof needed before canon |
| TEMPORAL coordinate/parser syntax | PROP-028/022A and current status | active proposal/runtime pressure | Partial; runtime/gate limits still apply |
| Executor approval / authority refs | PROP-030/030A, Gate 3 lineage | implemented/proposal boundary | Runtime gate discipline, not general syntax freedom |
| Grammar after proof | S10 expert series | accepted value | Process canon |
| Semantic Information Ratio | S10 expert series | value/research | Benchmark idea, not accepted metric |
| Early v0.1 expert grammar | S10 expert series | superseded_history | Do not revive as syntax canon |
| `name = expr` graph-native binding | Agent-B / S13 / external README | research_unrealized | Clean-form pressure only |
| Collection sugar / natural operators | Agent-B | research_unrealized | Ergonomics pressure; must lower to explicit semantics |
| `effect contract` | Agent-B / S14 / external README | strong pressure | Requires effect taxonomy/proposal before syntax |
| `match`, `for`, `guard`, `pipeline` | Agent-B | proposal candidates/research | No keyword canon yet |
| Union types over `Any` | Agent-B / Agent-D pressure | strong pressure | Type-safety direction, not accepted surface here |
| Contracts + Forms | Agent-C / external README | private research line | Strong research; proposal required |
| FormKind taxonomy | Agent-D analysis / external README | private research validation | Promising constraint on forms; not canon |
| `.ifh`, `.iri`, `.ilk` artifacts | Agent-C / interviews | compiler artifact research | Not accepted build artifacts |
| External effect taxonomy | Agent-C draft / S14 EPF-01 | proposal prerequisite | Private draft; should route separately if promoted |
| Observation kinds | S13/S14 and external pressure | proposal prerequisite | Needs type-shape/proposal before runtime |
| Generated artifact review | S14 EPF-11 | research_unrealized | Agent/artifact pressure only |

## Accepted Values

- **Syntax follows proof:** syntax pressure is not a shortcut around proposals,
  proof fixtures, and spec/code sync.
- **Grammar is an interface to semantics:** surface forms should expose meaning
  already present in contract/IR/proof, not create hidden behavior.
- **Human readability matters:** syntax work is legitimate when it improves
  comprehension without weakening evidence, type, authority, or runtime
  boundaries.
- **Forms are promising but gated:** “forms expose meaning” is valuable, but a
  form system must be constrained by imports, trust, type-directed resolution,
  and build artifacts before it can be considered canon.
- **Effects must be explicit:** `external pure` cannot remain the default
  description for observed/effectful/privileged/irreversible actions.

## Do Not Promote

- Exact Agent-A, Agent-B, or Agent-C syntax.
- Old `igniter-lang-spec.md` v0.1 grammar.
- `pipeline`, `guard`, `form`, `.ifh`, `.iri`, `.ilk`, or `.iform` as accepted
  surfaces.
- `external pure` for IO, storage, model calls, hardware, money, network, or
  self-modifying actions.
- `Any` as routine contract boundary.
- Ambient time/current-style syntax that weakens explicit temporal coordinates.
- Syntax claims that imply live Ledger, BiHistory runtime, stream/OLAP runtime,
  production authority, or production signing.
- High-risk domain promises such as live robotics, medical/legal autonomy,
  neuro stimulation, real custody, or self-replication.

## Backlog Map

| Backlog line | Suggested next shape | Read first | Promotion guard |
| --- | --- | --- | --- |
| External effects | Proposal-ready pressure note | `playgrounds/docs/external/README.md`, Agent-C external effects draft, S14 EPF-01 | Define taxonomy before syntax; receipts/capabilities first |
| Forms system | Private research snapshot | Agent-C README, C5/C6, interview analyses | Must constrain FormKind/import/trust/conflicts before canon |
| Clean-form graph syntax | Authoring/lowering experiment | Agent-B B1, S13 | Prove lowering to existing semantics; no parser canon first |
| Pipeline/guard | Comparative proposal sketch | Agent-B B2/B6, S14 EPF-09 | Check whether annotations/lowering suffice before keyword |
| Observation kinds | Type-shape proposal note | S13/S14, external pressure summaries | Separate simulation/model/fact before runtime claims |
| HTTP/JSON boring fixture | Synthetic proof candidate | S14 EPF-02, Agent-A HTTP/WebMicro | No secrets/network; deterministic replay/failure receipt |
| Spark pipeline fixture | Synthetic applied fixture | S14 EPF-04, Agent-B B2/B6 | Product pressure only; no real Spark integration |
| Generated artifact review | Agent/artifact pressure note | S14 EPF-11, Methodologist/Turing pressure | Generated code remains proposal until accepted |

## Read Rules

For current syntax/canon work:

1. Read `igniter-lang/docs/agent-context.md`.
2. Read `igniter-lang/docs/current-status.md`.
3. Read current spec/proposals.
4. Use this S15 report only to route historical/private pressure.
5. Read exact external/expert sources only after choosing a narrow line.

For private research work:

1. Read `playgrounds/docs/external/README.md`.
2. Read Agent-C or Agent-B indexes depending on question.
3. Write compact private slices before proposing main-track changes.

## Rotation Recommendation

No movement in this stage.

Keep S15 as the compact syntax-pressure map. Keep `playgrounds/docs/external/`
private and indexed. Do not link private syntax research into public docs until
the user explicitly asks for proposal/spec/main-track work.

## Stage-Close Handoff

Compact claim:

S15 separates syntax pressure into active proposal surfaces, private research
pressure, and do-not-promote zones. Agent-C forms/effects research is now visible
as a strong private line, but still outside canon.

Source set:

- S10 expert series map
- S13 external pressure corpus map
- S14 external pressure fixture backlog
- private external workbench README
- current status/value/proposal inventory

Categories applied:

- accepted_canon
- active proposal
- implemented boundary
- research_unrealized
- superseded_history
- rejected / parked
- values
- do_not_promote

Values preserved:

- grammar after proof
- semantics before syntax
- human readability with evidence intact
- forms expose meaning
- explicit effects
- bounded promotion

Accepted/implemented signals:

- grammar-after-proof governance
- proposal-only treatment of `entrypoint`/`section`
- Gate 3 authority/scope boundaries
- Stage 2 temporal/stream/OLAP/invariant surfaces already proven at their
  accepted layers

Superseded/rejected signals:

- old v0.1 grammar as current syntax
- exact Agent-A/B/C syntax as canon
- broad `external pure`
- routine `Any`
- ambient temporal aliases without explicit coordinates
- syntax as authorization for runtime/live high-risk behavior

Research still alive:

- form system
- FormKind taxonomy
- `.ifh/.iri/.ilk`
- external effect taxonomy
- graph-native clean-form syntax
- pipeline/guard ergonomics
- observation kinds
- generated artifact review

Duplicate/rotation recommendations:

- use S15 as first read for syntax-pressure archaeology;
- use external README for live private workbench orientation;
- keep raw external sources exact-topic only;
- no public/canon promotion without explicit proposal work.

Unresolved questions:

- Should external effects become the first formal syntax/semantics proposal
  from the private workbench?
- Should forms be explored as a compiler architecture proposal or first as an
  authoring/lowering tool?
- Should clean-form syntax be tested against existing examples before any
  parser work?
- Which current proposal owner should handle syntax-pressure triage if it moves
  out of archive/history?

Changed files:

- `igniter-lang/docs/archive/history/history-s15-syntax-pressure-backlog-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S16 should draft an approval-ready `Playgrounds-Rotation-1`
metadata/index cleanup packet without executing it, or produce a private
forms-research snapshot if the user wants to keep following the external
workbench line.

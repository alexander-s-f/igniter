# History-S10 Igniter-Lang Expert Series Map

Status: archived history report and expert-series compression map  
Date: 2026-05-09  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S10  
Source posture: classify `playgrounds/docs/experts/igniter-lang/`; no files moved or deleted

## Compact Claim

`playgrounds/docs/experts/igniter-lang/` is the pre-canon research series where
Igniter-Lang became thinkable as a language.

It should not be read as current spec. Its durable value is a compact set of
origin pressures:

- contract-native syntax should improve semantic density, not just look nicer;
- grammar should come after semantics and proof, not before;
- Ruby DSL is the reference implementation while the language model stabilizes;
- `History[T]`, `BiHistory[T]`, `stream T`, `OLAPPoint[T,Dims]`, and invariant
  severity graduated into current Stage 2/3 canon or proof-backed proposals;
- temporal, OLAP, invariants, and content-addressed evidence are one connected
  system, not separate feature ideas;
- property-model synthesis, probabilistic pre-computation, temporal synthesis,
  distributed time, store inference, and multi-backend export remain research.

Future agents should read current spec/status first. The expert series is for
origin archaeology, syntax pressure, and long-horizon research routing.

## Source Set

Primary English sources:

- `playgrounds/docs/experts/igniter-lang/README.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-precomp.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-propmodel.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-theory2.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-spec.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-algebra.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-invariants.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-temporal.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-temporal-deep.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-olap.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-persistence.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-implementation.md`

Duplicate-language sources:

- matching `*.ru.md` files in the same directory

Current comparison sources:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/meta-proposals/META-EXPERT-008.4-origin-temporal-concordance-v0.md`
- `igniter-lang/docs/meta-proposals/META-EXPERT-008.5-runtime-ledger-mesh-concordance-v0.md`

## Series Classification

| Area | Documents | Category | Current reading |
| --- | --- | --- | --- |
| Language birth and density | `igniter-lang.md`, `README.md` | values, research_unrealized | Preserve SIR and host-language-tax pressure; do not use grammar sketch as current syntax. |
| Formal foundations | `igniter-lang-theory`, `theory2` | values, research_unrealized | Preserve formal identity checklist; keep as research grounding, not proof of current implementation. |
| Draft language spec | `igniter-lang-spec` | superseded_history, values | Early v0.1 grammar/construct inventory; current spec chapters and proposals supersede it. |
| Algebra and enterprise model | `igniter-lang-algebra` | values, research_unrealized | Preserve “everything is a contract” and enterprise primitive pressure; do not bulk-promote primitives. |
| Invariants | `igniter-lang-invariants` | partially implemented, values | Invariant severity/source metadata graduated; full invariant algebra/refinement propagation remains research. |
| Temporal model | `igniter-lang-temporal`, `temporal-deep` | partially implemented, values, research_unrealized | `History[T]`, `BiHistory[T]`, explicit axes graduated; temporal synthesis/distributed time remain research. |
| OLAP model | `igniter-lang-olap` | partially implemented, values, research_unrealized | `OLAPPoint[T,Dims]` graduated through parser/TC/SemanticIR; distributed execution and rich time travel remain closed/deferred. |
| Persistence/cluster lowering | `igniter-lang-persistence` | bridge_candidate, research_unrealized | Type-directed storage and `Store[T]` are valuable but not current canon. |
| Probabilistic pre-computation | `igniter-lang-precomp` | research_unrealized | Preserve approximate/exact pressure and cost model; not current language canon. |
| Property-model synthesis | `igniter-lang-propmodel`, `theory2` | research_unrealized, values | Preserve ontology/model/contract/execution split; synthesis remains long-horizon. |
| Implementation strategy | `igniter-lang-implementation` | accepted value, partially absorbed | Ruby DSL as reference and grammar-after-semantics are accepted process values; backend/export surface remains research/bridge. |
| RU duplicates | `*.ru.md` | duplicate/value | Useful for bilingual review; not separate evidence when EN source is already read. |

## Accepted Or Implemented Signals

| Expert signal | Current absorption |
| --- | --- |
| Grammar after semantics | Active governance norm: parser/syntax follows SemanticIR/proof evidence. |
| Ruby DSL as reference implementation | Current implementation path uses Ruby/proofs before freezing new grammar. |
| `History[T]` | Closed in Stage 2; current Stage 3 has TEMPORAL load/evaluate split and restricted Phase 1 live-read scope. |
| `BiHistory[T]` | Closed at Stage 2 type/parser/proof layer; Phase 2/runtime execution remains closed. |
| `stream T` | Closed in Stage 2; production stream executor remains unauthorized. |
| `OLAPPoint[T,Dims]` | Closed in Stage 2 at parser/typechecker/SemanticIR; distributed execution remains deferred. |
| Invariant severity | Closed in Stage 2; source metadata preservation and typed-shape work continued in Stage 3. |
| Content-addressed evidence | Reappears in Stage 3 signed addendum/content hash proof and temporal cache-key discipline. |
| Compatibility/report-first runtime | Current CompatibilityReport, audit-ready envelope, temporal observation, and proof-local runtime gates follow the same pressure. |

## Superseded Or Not Canon

- The `igniter-lang-spec.md` v0.1 grammar is superseded by current spec chapters
  and accepted proposals.
- Early grammar examples (`contract`, `in`, `compute`, `branch`, `compose`,
  `out`, annotations) are not automatically current syntax.
- Ambient temporal aliases such as `current` / implicit now-style access are
  risky unless they preserve explicit temporal coordinates and cache semantics.
- `time_machine`, `Forecast[T]`, forward/counterfactual/approximate time travel,
  probabilistic temporal rules, distributed time, and causal clocks are not
  current canon.
- `Store[T]`, storage manifest inference, cluster scatter/gather, partition
  placement, and backend choice are not current language surface.
- Property-model synthesis, LLM-as-model-author, algorithm synthesis, and
  automatic rule synthesis are research, not accepted compiler behavior.
- Multi-backend export to Rust/AADL/TLA+/Coq is a long-horizon backend bridge,
  not current implementation.
- The claim that “everything is a contract” is a valuable direction, but not a
  license to erase all boundary distinctions in current canon.

## Values To Preserve

### Semantic Density Over Pretty Syntax

The Semantic Information Ratio idea is still valuable: syntax work should be
judged by how many business/model claims become explicit per unit of surface,
not by terseness alone.

### Grammar After Proof

The expert series strongly supports the current rule: semantics, SemanticIR,
OOF/refusal behavior, reports, and runtime boundaries must be proven before
grammar freezes.

### Temporal Coordinates Are Identity

`History[T]`, `BiHistory[T]`, `as_of`, cache keys, and content-addressed
evidence all preserve one value: a fact without its time/knowledge coordinate is
not the same fact.

### Reports Are Part Of The Language

Verification reports, compatibility reports, counterfactual reports,
observations, and audit envelopes are not debugging leftovers. They are the
language’s epistemic surface.

### Orthogonality

Temporal, OLAP, invariants, persistence, and execution should compose without
forcing every business contract to rewrite itself for each concern.

### Research Without Premature Canon

The series is ambitious by design. Its best use is to feed bounded proposals and
proofs, not to reopen all language surface at once.

## Research Still Alive

| Research line | Why it matters | Promotion rule |
| --- | --- | --- |
| Semantic Information Ratio benchmark | Gives syntax work an empirical density test. | Needs corpus and claim-counting rubric after real apps exist. |
| Backend interface | Keeps Ruby, future Rust, formal export, and verification aligned. | Needs backend contract/proof against same SemanticIR/result surface. |
| Store/type-directed persistence | Makes storage shape a type property. | Must route through TBackend/Ledger/runtime gates, not source syntax first. |
| Rule algebra and temporal synthesis | Connects temporal goals, invariants, and generated rules. | Needs separate rule-system proposal and proof; not part of current TEMPORAL runtime. |
| Distributed time | Important for cluster/mesh truth. | Needs mesh/runtime/ledger proof and explicit consistency model. |
| Probabilistic pre-computation | Valuable for approximate/forecast/cost-aware execution. | Needs `~T`/approximation proposal and refusal/report semantics. |
| Property-model synthesis | Could separate ontology/model/algorithm/execution. | Long-horizon; must stay in decidable logical fragment. |
| Invariant algebra/refinement propagation | Deepens compiler-as-verifier. | Needs bounded OOF/proof slices beyond current severity/source metadata. |
| OLAP distributed execution | Natural next step after OLAP type/IR. | Deferred gap; depends on TBackend/runtime/cluster authorization. |
| Human-agent comprehension via syntax | Central to language adoption. | Promote through syntax pressure specimens and comprehension tests, not taste. |

## Duplicate And Rotation Notes

The expert series is intentionally bilingual. The `*.ru.md` files are useful for
review and author thinking, but they double the archive surface.

No files should be moved or deleted in this stage.

Recommended future cleanup, only after approval:

| Target | Recommendation | Reason |
| --- | --- | --- |
| `*.ru.md` duplicates | Keep or move as a bilingual mirror set, not separate research evidence | They duplicate the same conceptual payload and can double read cost. |
| `igniter-lang-spec.md` | Mark clearly as historical if touched later | Current spec/proposals supersede it. |
| Temporal/OLAP/Persistence trio | Keep warm | These are the strongest origin sources for current canon and deferred gaps. |
| Theory/precomp/propmodel | Keep cold research | High option value, low current implementation authority. |
| `igniter-lang-implementation.md` | Keep warm | It preserves the grammar-after-semantics and Ruby DSL reference rules. |

## Future Agent Read Rule

Default:

1. Read `igniter-lang/docs/agent-context.md`.
2. Read `igniter-lang/docs/current-status.md`.
3. Read current spec/proposals.
4. Use this S10 report before reading the full expert series.

Read the full expert source only when:

- a task names one of the source documents;
- syntax pressure needs origin evidence;
- a proposal touches temporal, OLAP, invariants, persistence, synthesis, or
  backend export;
- a history/rotation stage asks for deeper archaeology.

When reading, prefer English originals first and use RU files only for bilingual
review or wording recovery.

## Stage-Close Handoff

Compact claim:

The Igniter-Lang expert series is the language-birth research layer. It produced
several current pillars, especially temporal/history/OLAP/invariant/report
semantics, but most grammar, synthesis, storage, backend, and distributed-time
ideas remain research until routed through current proposal/proof gates.

Source set:

- `playgrounds/docs/experts/igniter-lang/`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/value-index.md`
- `META-EXPERT-008.4`
- `META-EXPERT-008.5`

Categories applied:

- accepted_canon
- implemented
- superseded_history
- research_unrealized
- rejected / parked
- values

Values preserved:

- semantic density
- grammar after proof
- Ruby DSL as reference implementation
- temporal coordinates as identity
- reports as language surface
- orthogonality
- bounded research promotion

Accepted/implemented signals:

- `History[T]`
- `BiHistory[T]`
- `stream T`
- `OLAPPoint[T,Dims]`
- invariant severity/source metadata
- TEMPORAL load/evaluate split
- content-addressed evidence
- CompatibilityReport/report-first runtime

Superseded/rejected signals:

- v0.1 expert spec as current syntax
- bulk promotion of early construct inventory
- ambient time aliases without explicit coordinates
- grammar before semantics
- storage/backends as immediate source syntax
- synthesis as current compiler behavior

Research still alive:

- SIR benchmark
- backend interface/export
- type-directed storage
- rule algebra and temporal synthesis
- distributed time
- probabilistic pre-computation
- property-model synthesis
- invariant algebra/refinement propagation
- distributed OLAP execution
- human-agent syntax comprehension

Duplicate/rotation recommendations:

- preserve RU duplicates as bilingual mirror, but do not treat them as separate
  evidence by default
- mark early spec historical if touched later
- keep temporal/OLAP/persistence/implementation warm
- keep theory/precomp/propmodel cold research

Unresolved questions:

- Should SIR become a formal benchmark in `value-index` or stay archaeology?
- What is the minimal backend-interface proof that would be useful before Rust
  or formal export work exists?
- Which expert-series research line should be next to graduate into a narrow
  Stage 3+ proposal after current gates settle?

Changed files:

- `igniter-lang/docs/archive/history/history-s10-igniter-lang-expert-series-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S11 should compress `playgrounds/docs/experts/` outside the
`igniter-lang` subfolder, separating general expert patterns from those that
should influence Igniter-Lang values or future proposals.

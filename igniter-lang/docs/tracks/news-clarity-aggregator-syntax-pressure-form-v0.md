# News Clarity Aggregator Syntax Pressure Form v0

Card: S3-R14-C7-P
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `news-clarity-aggregator-syntax-pressure-form-v0`
Status: done
Date: 2026-05-09

---

## Goal

Extract the `NewsClarityAggregator` snippet from the External Pressure Reviewer
V2 cross-test into a clean syntax-pressure fixture/form report.

This is not parser proof, runtime proof, spec promotion, or implementation
authorization.

---

## Sources Read

- `playgrounds/docs/external/External Pressure Reviewer V2 Cross Test.md`
- `igniter-lang/docs/agent-orchestra-pattern.md`
- `igniter-lang/docs/meta-proposals/syntax-pressure-registry-v0.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`

---

## Extracted Fixture

Clean non-canon fixture:

```text
igniter-lang/experiments/human_agent_syntax_comprehension_fixture/news_clarity_aggregator_v1.ig
```

The fixture header explicitly marks it as non-canon and not expected to parse.

---

## Form Summary

`NewsClarityAggregatorV1` describes an audited news/fact-checking pipeline:

1. ingest a news article;
2. extract claims;
3. find corroborating and contradictory evidence;
4. calculate misinformation risk;
5. build a `ClarityReport`;
6. require human override for high-risk cases;
7. expose a dashboard/metric pressure surface.

The snippet is valuable because it combines syntax pressure with product
pressure: fact checking, source evidence, temporal review, audit receipts, and
human override are the kind of domain where Igniter-Lang's epistemic-contract
identity is easy to explain.

---

## Authority Markers

[S] Non-canon syntax-pressure fixture.

[S] Product pressure for OSINT-like clarity/fact-checking applications.

[S] Not parser proof.

[S] Not runtime proof.

[S] Not a spec change.

[S] Not evidence that TEMPORAL/BiHistory live evaluation is supported.

---

## Syntax Gap Matrix

| Element | Current | Proposed pressure | Unknown / gap | Rejected interpretation |
|---------|---------|-------------------|---------------|-------------------------|
| `profile audited_truth_mesh` | Not in ch2 grammar kernel; registry says `profile` is pressure | Runtime/proof/evidence mode surface for audited execution | Whether source-level profiles are declarations, annotations, or package metadata | Do not treat as parser-supported or runtime-authorizing syntax |
| `threshold ... Decimal[scale: 3]` | `threshold` is pressure / route-to-proposal; `Decimal[scale: n]` is pressure | Named risk constants improve verifiability and remove magic numbers | `threshold` vs `const`, scale syntax, policy metadata, diagnostics | Do not treat thresholds as accepted grammar |
| `packet`, `event`, `receipt` | Registry pressure; not ch2 top-level canon | Data-role profiles make evidence, events, and audit decisions readable | Relation to `type`, observation kinds, receipt identity, proof/witness split | Do not collapse receipt into proof or promote all data roles to canon |
| `store` | Not ch2 canon; `History[T]` / `BiHistory[T]` are canon types | Named temporal storage binding with source/lifecycle metadata | Store declaration grammar, partition scope, source authority, lowering to reads/requirements | Do not claim production storage/runtime behavior |
| `metric` | Pressure alias over canonical `olap_point` / `OLAPPoint` | Product-readable analytics surface for clarity index | Whether `metric` is alias, new top-level declaration, or view over OLAPPoint | Do not replace OLAPPoint without proposal/proof |
| `external pure` | Ch2 has `external ruby/rust/js/wasm`; registry routes richer `external pure` to proposal | Pure helper/FFI/search/knowledge-graph signature surface | Purity verification, capabilities, LLM/search evidence, failure behavior | Do not treat external calls as safe just because they are named `pure` |
| `for claim in normalized.claims` | No `for` in ch2 grammar kernel | Loop sugar over map/fold for human readability | Mutation/accumulation semantics, scoping, graph identity | Do not admit imperative mutation as current language behavior |
| `checks.fold(... fn(...))` / `checks.map(fn(...))` | Stdlib `fold`/`map` exist; method-chain `fold/map` and `fn =>` spelling are not canon | Collection-chain sugar over standard functions | Lambda spelling, receiver-call lowering, evidence/provenance edge visibility | Do not hide graph nodes behind opaque fluent chains |
| `view global_clarity_dashboard` | Registry pressure | Materialized/product projection surface | Materialization lifecycle, source contract relation, dashboard vs query vs view | Do not treat as accepted top-level declaration |
| `BiHistory ... at { vt, tt }` | `BiHistory[T]` is canon; explicit vt/tt required; source spelling not canonical | Readable coordinate form for valid and transaction time | Final coordinate grammar, parser AST, runtime Gate 3 scope limits | Do not claim live bitemporal RuntimeMachine evaluation |
| `human_override` invariant + `overridable_with HumanOverride` | Invariant severity is canon; human override/review syntax is pressure | Human-in-the-loop risk gate for high-risk fact checks | Where `human_override` is bound, sync/async semantics, review receipt, timeout | Reject hidden global `human_override` as canonical semantics |

---

## Product Pressure

The fixture is especially useful for future product examples because it pressures
Igniter-Lang's strongest public story:

- claim extraction must preserve source evidence;
- fact-checking must expose uncertainty and contradiction;
- high-risk claims need human review, not silent automation;
- clarity metrics should remain traceable to reports and evidence;
- temporal history matters because claims and corrections change over time.

This is OSINT-like product pressure, but it must remain lawful and bounded:
the language should support user-owned/public sources, evidence links, and
review gates without implying scraping, doxxing, or unverified allegations.

---

## Route Recommendations

| Route | Owner | Recommendation |
|-------|-------|----------------|
| Named thresholds/constants | Compiler/Grammar Expert | Promote only through a bounded syntax proposal; reuse prior threshold pressure |
| `external pure` helpers | Compiler/Grammar Expert + Bridge Agent | Define purity/effect/capability/evidence semantics before parser work |
| Data-role profiles (`packet/event/receipt`) | Compiler/Grammar Expert | Create a small evidence/receipt/proof vocabulary specimen before proposal |
| `store` + temporal coordinates | Research Agent + Compiler/Grammar Expert | Keep aligned with TEMPORAL/BiHistory source grammar and runtime scope exclusions |
| `metric` / `view` | Bridge Agent + Compiler/Grammar Expert | Treat as product-facing aliases/projections over OLAP/view semantics, not standalone canon |
| `for` and method-chain collections | Compiler/Grammar Expert | Compare with canonical `fold`/`map`; prove graph identity and evidence visibility |
| Human override invariant | Research Agent + Bridge Agent | Route through review lifecycle: binding, blocking/suspend semantics, receipt, timeout |
| NewsClarity product lane | Archive/Form Expert + Bridge Agent | Preserve as future killer-example pressure after syntax and runtime guard status are clearer |

---

## Handoff

[D] Extracted `NewsClarityAggregatorV1` into a clean non-canon fixture.

[D] Classified all requested non-current syntax elements in the gap matrix.

[S] The fixture is syntax pressure and product pressure only.

[T] No parser/runtime/spec edits were made. No syntax was promoted to canon.

[R] Highest-value future proposal routes: thresholds/constants, external pure
helpers, and a bounded data-role/evidence vocabulary specimen.

[Next] A future syntax-curation slice may add the fixture to the Syntax Pressure
Registry and run blind human/agent comprehension tests against it.

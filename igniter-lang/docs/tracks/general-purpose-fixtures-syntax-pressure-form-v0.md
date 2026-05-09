# General Purpose Fixtures Syntax Pressure Form v0

Card: S3-R14-C9-P
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `general-purpose-fixtures-syntax-pressure-form-v0`
Status: done
Date: 2026-05-09

---

## Goal

Extract and classify the syntax-pressure surface from
`External Pressure Reviewer V2 Cross Test - 2`.

This is not parser proof, runtime proof, spec promotion, or implementation
authorization.

---

## Sources Read

- `playgrounds/docs/external/External Pressure Reviewer V2 Cross Test - 2.md`
- `igniter-lang/docs/agent-orchestra-pattern.md`
- `igniter-lang/docs/meta-proposals/syntax-pressure-registry-v0.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch3-type-system.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`

---

## Authority Markers

[S] The four fixture families are syntax pressure and product pressure only.

[S] No syntax here is promoted to canon.

[S] No parser, runtime, or spec canon files were edited.

[S] The source snippets are not proof that HTTP, agent mesh, OSINT, legal, or
BiHistory live runtime behavior is supported.

[T] Current canon references:

- Ch2 grammar kernel: `module`, `type`, `contract`, `input/read/compute/output`,
  `def`, `external ruby/rust/js/wasm`, expressions, arrays, records, lambdas.
- Ch3 type system: `Collection`, `Option`, `Result`, `Map`, `History`,
  `BiHistory`, `Any` as type-level concept.
- Ch8 stdlib: function-form `fold`, `map`, `filter`, `count`, option/result
  helpers, numeric/date primitives. `uuid_v4`, `sha256`, HTTP, and JSON helpers
  are not Ch8 kernel stdlib.

---

## Fixture Family Extraction

| Fixture family | Product pressure | Primary syntax pressure | Extraction risk |
|----------------|------------------|-------------------------|-----------------|
| `HttpApiClientV1` | General-purpose HTTP/API client with audited receipts | HTTP effect boundary, generic JSON external functions, `Any`, retry/profile, receipts, `error` statement | High: external effect semantics and generic deserialization can look production-ready when they are not |
| `AgentKnowledgeMeshV1` | Agent knowledge base, inference, context merge | Authority roles, BiHistory knowledge, `Any` payload dispatch, spread payload, map/fold/filter chains, human review override | High: agent/authority vocabulary can leak into canon without proof |
| `ClarityDuelEngineV1` | OSINT + rebuttal / clarity duel | Placeholder type reuse, cross-fixture dependency, BiHistory read from another module, implication invariant, uuid/sha assumptions | High: rhetoric/product metaphor should not become unsafe language semantics |
| `LegalAdvocateOSINTV1` | Legal/human-rights OSINT advocate | Global invariants, legal/critical severity, rights profile fields, placeholder reuse, temporal legal history | Very high: legal domain requires careful safety boundaries and review authority |

---

## Syntax Gap Matrix: HttpApiClientV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile audited_http_mesh` | pressure candidate | Registry keeps `profile` as pressure | Source-level profile semantics not canon; retry policy and ledger backend are not parser/runtime authorization | Runtime/profile specimen after evidence vocabulary narrows |
| `type HttpMethod = Symbol` | pressure candidate | Ch2 has record `type`; Ch3 has `Symbol` | Alias/enum syntax is not in ch2 kernel; variants/enums still pressure | Compiler/Grammar enum/alias lane |
| `Int32`, `Boolean` | future/non-canon | Ch2/Ch3 use `Integer`, `Bool` | Host-language type spelling leaks into source | Normalize in any clean fixture |
| `Any` in request body | current type concept, unsafe boundary | Ch3 includes `Any` | Dynamic boundary erases verifiability at HTTP/JSON edge | Bridge/FFI proposal must constrain `Any` use |
| `packet/event/receipt` | pressure candidate | Registry pressure | Strong data-role surface, not ch2 top-level canon | Evidence/receipt/proof vocabulary specimen |
| `store History/BiHistory` | pressure candidate | `History[T]`, `BiHistory[T]` canon types | `store` declaration and partition/source metadata not ch2 canon | Temporal/store source grammar lane |
| `stream live_api_responses` | pressure candidate | Stream semantics Stage 2; ch2 has window body only | Top-level stream declaration spelling needs sync | Stream surface specimen |
| `metric api_call_latency` | pressure candidate | OLAPPoint canon; `metric` registry pressure | Alias vs new declaration unresolved | Product-facing OLAP alias review |
| `external http_perform_request(...)` | future/non-canon | Ch2 external requires language id block | Generic external effect surface not defined | ExternalContract / Bridge Agent |
| `external json_serialize[T]` | future/non-canon | Ch2 has no generic external function spelling | Generic type parameter syntax and JSON failure model missing | External pure/generic helper proposal |
| `uuid_v4()`, `sha256(...)` | unsafe/ambiguous | Not Ch8 kernel stdlib | Looks built-in but is undeclared in this fixture | Declare external pure or remove |
| Option methods `.is_some`, `.unwrap`, `.unwrap_or` | pressure candidate | Ch8 has function-form option helpers | Method-chain surface not canon; `unwrap` risk not specified | Primitive/method sugar specimen |
| `error "Unsupported method"` | unsafe/ambiguous | No ch2 error statement | Control-flow/Result/error semantics absent | Result/error surface proposal later |
| `BiHistory at { vt, tt }` | pressure candidate | Ch4/Ch7 require vt/tt; spelling not canonical | Runtime Gate 3 excludes live BiHistory eval | Temporal coordinate grammar only, no runtime claim |

---

## Syntax Gap Matrix: AgentKnowledgeMeshV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile ... authority: strict` | pressure candidate | Profile registry pressure | Authority policy field not formalized | Agent Orchestra/profile lane |
| `EvidenceRef` used but not defined locally | unsafe/ambiguous | Existing pressure fixtures define it | Hidden dependency across snippets | Clean fixture must define or import |
| `Decimal[scale: 3]` | pressure candidate | Ch3 canon uses `Decimal[N]`; registry marks scale named form pressure | Two decimal spellings compete | Type surface cleanup |
| `packet/event/receipt` | pressure candidate | Registry pressure | Same data-role vocabulary pressure | Evidence/receipt/proof specimen |
| `store knowledge_base: BiHistory[...]` | pressure candidate | BiHistory type canon | Store declaration and partition by nested field not canon | Store/temporal syntax lane |
| `external pure ...` | pressure candidate | Registry routes to proposal | Purity/effect/evidence semantics not closed | External pure helper proposal |
| `external pure uuid_v4/sha256` | pressure candidate but risky | Can be declared external in fixture | `uuid_v4` is nondeterministic unless modeled as capability/time/evidence | Split deterministic hash from nondeterministic id generation |
| `.map/.filter/.fold/.contains` | pressure candidate | Ch8 has function-form collection ops | Method-chain lowering and evidence edges unproven | Collection sugar specimen |
| `payload: Any`, `receipt: Any` | current type concept, unsafe boundary | Ch3 includes `Any` | Orchestrator loses static shape and receipt semantics | Avoid in clean fixture or isolate as dynamic boundary |
| Record spread `{ ...payload, ... }` | pressure candidate | Registry pressure | Hidden field mapping can obscure auditability | DTO/spread specimen only |
| `error "Unknown action"` | unsafe/ambiguous | No canon error statement | Should be Result/OOF/failure observation? | Result/failure surface later |
| `evidence` free reference in invariant | unsafe/ambiguous | Evidence on output is pressure | `evidence` is not bound in `MergeAgentContexts` | Clean fixture must bind evidence explicitly |
| `overridable_with human_review` | future/non-canon | Await/human review registry pressure | Symbol/function/type ambiguity | Review lifecycle proposal |

---

## Syntax Gap Matrix: ClarityDuelEngineV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile audited_duel_mesh` | pressure candidate | Registry pressure | Authority/profile semantics not canon | Profile specimen |
| `type AuthorityRef { ... }` placeholder | unsafe/ambiguous | Ch2 type records require fields | Placeholder type reuse cannot parse or typecheck | Clean fixture must import or inline |
| `FactCheckResult { ... }` placeholder | unsafe/ambiguous | Same | Cross-fixture reuse hidden | Use imports only if module system/profiles allow |
| `packet/event/receipt` | pressure candidate | Registry pressure | Receipt identity still unsettled | Evidence/receipt/proof specimen |
| `store duel_history: BiHistory[DuelRound]` | pressure candidate | BiHistory type canon | `store` source surface not canon | Temporal/store lane |
| `metric corruption_exposure_rate` | pressure candidate | OLAPPoint canon / metric pressure | Product metric name may overstate runtime support | OLAP alias review |
| `external pure gather_osint/perform_fact_check` | pressure candidate | External pure pressure | OSINT/search/LLM purity is questionable; external evidence model needed | Bridge/OSINT capability lane |
| `knowledge_base` from another fixture | unsafe/ambiguous | Imports exist, but store sharing not specified | Hidden global store dependency | Require explicit import/store capability |
| `.map(fn(...))` | pressure candidate | Ch8 function-form `map` | Method-chain surface not canon | Collection sugar specimen |
| `DuelRound { ... }` placeholder expression | unsafe/ambiguous | Record literal canon, spread not | Placeholder value is not a valid expression | Clean fixture must compute complete round first |
| `uuid_v4`, `sha256` | unsafe/ambiguous | Not Ch8 kernel | Undeclared/non-deterministic helpers | Declare or remove |
| `=>` implication in invariant | future/non-canon | Ch2 operators omit implication | Needs boolean implication spelling or rewrite | Use `!a || b` in clean fixture |
| `severity :error` | current-ish | Invariant severity canon in Stage 2 | Invariant syntax itself outside ch2 kernel but Stage 2 surface exists | Keep as pressure/current hybrid |

---

## Syntax Gap Matrix: LegalAdvocateOSINTV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile ... authority/human_rights` | future/non-canon | Profile pressure only | Legal policy fields are not language semantics | Product policy metadata lane |
| Placeholder type reuse | unsafe/ambiguous | Ch2 requires full types/imports | `AuthorityRef { ... }`, imported `OpponentPosition` not formal | Clean fixture must inline or import explicitly |
| `store legal_knowledge: BiHistory[FactAssertion]` | pressure candidate | BiHistory type canon | Store declaration + reused type from KnowledgeMesh not canon | Temporal/store and module dependency lane |
| `store advocacy_cases: BiHistory[AdvocacyCase]` missing axes | unsafe/ambiguous | BiHistory needs valid and transaction axes | Fixture omits `valid_axis` / `transaction_axis` | Clean fixture must add axes or avoid BiHistory |
| `stream live_legal_osint` | pressure candidate | Stream surface canon/pressure split | Top-level stream declaration spelling unresolved | Stream source grammar lane |
| `metric overton_shift_exposure` | pressure candidate | OLAPPoint/metric pressure | Product metric alias not canon | OLAP alias review |
| `external pure gather_legal_osint` | pressure candidate | External pure pressure | OSINT external purity/evidence/capabilities unresolved | ExternalContract / OSINT capability |
| `detect_overton_shifts(... historical: BiHistory[LegalNorm])` | future/non-canon | BiHistory type exists | Passing store/history as pure function arg needs capability semantics | Temporal helper boundary proposal |
| Global `invariant ... { condition: ... }` | unsafe/ambiguous | Invariant severity exists in contracts | Global invariants, named fields, and referenced variables are unbound | Keep out of clean parser fixtures |
| `severity: legal`, `severity: critical` | future/non-canon | Canon severities: error/warn/soft/metric | Legal severity lattice not defined | Governance/legal policy pressure only |
| `all_evidence_cross_verified`, `human_rights_impact`, `asserted_by` | unsafe/ambiguous | No bindings | Global invariant free variables | Require explicit contract inputs/computes |
| `in` operator over symbol set | pressure candidate | Registry has set/in pressure | Set literal and membership not canon | Primitive set specimen |
| `as_of - 10.years` | pressure candidate | Ch8 has date primitives; no duration literal grammar | Duration literals and date arithmetic surface unsettled | Temporal expression specimen |
| `.map(...)`, `.all(fn(...))` | pressure candidate | Ch8 function-form collection ops | Method-chain and ellipsis callback not canon | Collection sugar specimen |
| `severity: legal` with colon | unsafe/ambiguous | Existing pressure syntax uses both `severity :warn` and `severity: legal` | Inconsistent annotation grammar | Clean fixture must choose one pressure spelling |

---

## Cross-Fixture Pressure Classes

| Pressure class | Seen in | Classification | Recommendation |
|----------------|---------|----------------|----------------|
| Runtime/profile mode | all four | pressure candidate | Keep as profile taxonomy pressure; do not parse until profile semantics exist |
| Data roles | all four | pressure candidate | Needs narrow evidence/receipt/proof vocabulary specimen |
| Store declarations | all four | pressure candidate | Needs source grammar for stores, axes, partitions, and requirements lowering |
| External helpers | all four | pressure candidate / future | Split pure deterministic helpers, capability effects, OSINT/HTTP effects, and nondeterministic id generation |
| `Any` orchestration | HTTP, Knowledge | current type concept but unsafe boundary | Use sparingly; clean fixtures should expose typed variants or `Result` |
| Method chains | all four | pressure candidate | Compare to Ch8 function-form stdlib; prove observation/evidence preservation |
| Placeholder reuse | Duel, Legal | unsafe/ambiguous | Do not extract as-is; replace with imports or local full type declarations |
| Error statements | HTTP, Knowledge | unsafe/ambiguous | Route to Result/failure observation vocabulary, not parser work now |
| Legal severity/global invariants | Legal | future/non-canon / unsafe | Treat as product policy pressure, not core invariant severity |
| uuid/sha helpers | HTTP, Knowledge, Duel, Legal | unsafe/ambiguous | Hash may be pure; UUID is nondeterministic and should be capability/evidence-bound |

---

## Clean Non-Canon Fixture Extraction Recommendation

Do not extract the four snippets verbatim into parser-facing fixtures yet.

Recommended clean extraction order:

1. `http_api_client_v1_pressure.ig`
   - Keep: HTTP request/response types, one typed call path, receipt.
   - Remove or isolate: `Any`, generic JSON externals, `error` statement,
     `uuid_v4` as hidden stdlib.
   - Mark: external HTTP as capability/ESCAPE pressure, not pure CORE.

2. `agent_knowledge_mesh_v1_pressure.ig`
   - Keep: `AuthorityRef`, `Fact`, `FactAssertion`, `KnowledgeQuery`, BiHistory
     pressure.
   - Replace: `Any` action dispatch with typed variant-like pressure or separate
     contracts.
   - Remove: unbound `evidence` in invariant.

3. `clarity_duel_engine_v1_pressure.ig`
   - Keep: OSINT/fact-check/rebuttal product pressure.
   - Inline or import all reused types explicitly.
   - Replace `=>` with current boolean spelling or mark it as implication
     pressure.
   - Remove placeholder `DuelRound { ... }`.

4. `legal_advocate_osint_v1_pressure.ig`
   - Keep: legal/human-rights product pressure, but label as high-risk.
   - Move global invariants into explicit contracts or keep them as non-parser
     policy notes.
   - Replace `legal` / `critical` severity with product-policy pressure table.
   - Add missing BiHistory axes or avoid BiHistory for `advocacy_cases`.

Each extracted fixture should start with:

```text
-- This file is not current Igniter-Lang canon and is not expected to parse.
-- It is a syntax/product pressure artifact only.
```

---

## Proposal Routing Candidates

| Candidate | Priority | Owner | Why |
|-----------|----------|-------|-----|
| External helper/effect declarations | high | Compiler/Grammar Expert + Bridge Agent | HTTP, OSINT, JSON, inference, and legal lookup all depend on separating pure helpers from capability effects |
| Data-role vocabulary (`packet/event/receipt`) | high | Compiler/Grammar Expert | All four fixtures use data-role profiles for readability; current registry already keeps this pressure warm |
| Store declaration surface | high | Compiler/Grammar Expert + Research Agent | All four use `store`; temporal axes/partition/source metadata need a formal source home |
| Collection method-chain sugar | medium | Compiler/Grammar Expert | Repeated `.map/.fold/.filter/.all/.contains` pressure; must preserve Ch8 evidence semantics |
| Error/failure expression surface | medium | Compiler/Grammar Expert + Research Agent | `error "..."` appears naturally in general-purpose examples but has no current grammar |
| Enum/alias/variant surface | medium | Compiler/Grammar Expert | `type HttpMethod = Symbol` is too weak; action/method/verdict domains need better finite choices |
| Profile taxonomy | medium | Archive/Form Expert + Compiler/Grammar Expert | Profiles are readable but semantically broad; needs taxonomy before grammar |
| Legal/policy severity | low/defer | Bridge Agent + Architect | High-risk domain-specific policy, not core severity until governance accepts a policy lane |

---

## Handoff

[D] Extracted the four fixture families as syntax/product pressure surfaces:
`HttpApiClientV1`, `AgentKnowledgeMeshV1`, `ClarityDuelEngineV1`, and
`LegalAdvocateOSINTV1`.

[D] Classified requested constructs as current, pressure candidate,
future/non-canon, or unsafe/ambiguous.

[S] The raw snippets should not become clean fixtures verbatim because they mix
valid pressure with placeholders, unbound names, `Any`, undeclared stdlib
assumptions, and high-risk legal policy semantics.

[T] No parser/runtime/spec canon files were edited. No syntax was promoted to
canon.

[R] Strongest proposal candidates: external helper/effect declarations,
data-role vocabulary, and store declaration surface.

[Next] If the Architect wants actual fixture files, extract them in the
recommended order with non-canon headers and evaluator guides.

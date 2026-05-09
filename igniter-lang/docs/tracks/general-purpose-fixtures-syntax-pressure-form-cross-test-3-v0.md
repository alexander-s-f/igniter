# General Purpose Fixtures Syntax Pressure Form Cross Test 3 v0

Card: S3-R14-C9-P follow-up
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `general-purpose-fixtures-syntax-pressure-form-cross-test-3-v0`
Status: done
Date: 2026-05-09

---

## Goal

Repeat the previous general-purpose fixture syntax-pressure intake with the new
source:

```text
playgrounds/docs/external/External Pressure Reviewer V2 Cross Test - 3.md
```

This is not parser proof, runtime proof, spec promotion, or implementation
authorization.

---

## Sources Read

- `playgrounds/docs/external/External Pressure Reviewer V2 Cross Test - 3.md`
- `igniter-lang/docs/agent-orchestra-pattern.md`
- `igniter-lang/docs/meta-proposals/syntax-pressure-registry-v0.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch3-type-system.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/tracks/general-purpose-fixtures-syntax-pressure-form-v0.md`

---

## Authority Markers

[S] The two fixture families are syntax pressure and product pressure only.

[S] No syntax here is promoted to canon.

[S] No parser, runtime, or spec canon files were edited.

[S] The snippets are not proof that agent replication, self-modification,
marketplace escrow, HTTP, legal compliance, or live BiHistory execution is
supported.

[R] The source contains high-risk product metaphors. Emergency replication,
self-modification, peer-to-peer trade, escrow, and legal compliance must remain
behind explicit authority/capability/review boundaries if they ever become real
examples.

---

## Current Canon Anchors

- Ch2 grammar kernel: `module`, record-form `type`, `contract`,
  `input/read/compute/output`, `def`, `external ruby/rust/js/wasm`, expressions,
  arrays, records, lambdas.
- Ch3 type system: `Collection`, `Option`, `Result`, `Map`, `History`,
  `BiHistory`, `Any`, `Store`, `ContractRef`, `Ref` as type-level concepts.
- Ch8 stdlib: function-form `fold`, `map`, `filter`, `count`,
  option/result helpers, numeric/date primitives. `uuid_v4`, `sha256`,
  `pair`, ranges, HTTP/spawn/broadcast/escrow helpers are not Ch8 kernel stdlib.

---

## Fixture Family Extraction

| Fixture family | Product pressure | Primary syntax pressure | Extraction risk |
|----------------|------------------|-------------------------|-----------------|
| `EmergencyAgentMeshReplicatorV1` | Emergency mesh cluster that replicates agents and applies audited self-modification | replication profile fields, global safety invariants, external spawn/modify/broadcast helpers, `Any`, `Pair`, range `for`, placeholder patches, critical/legal severity | Very high: can imply autonomous self-replication and self-modification without formal capability gates |
| `DecentralizedMarketplaceV1` | Auditable peer-to-peer marketplace with listing, bidding, escrow, reputation, legal checks | marketplace profile fields, atomic escrow invariants, `Any` payload dispatch, external legal/fact-check helpers, BiHistory stores, metrics, error statement | Very high: can imply financial/legal execution semantics without transaction, custody, dispute, and compliance proofs |

---

## Syntax Gap Matrix: EmergencyAgentMeshReplicatorV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile ... authority/replication/self_modification` | future/non-canon | Registry keeps `profile` as pressure | Policy fields are not language semantics; self-modification is a capability/gate issue | Profile taxonomy plus capability policy lane |
| `type AuthorityRef { ... }` placeholder | unsafe/ambiguous | Ch2 record types require fields | Cross-fixture placeholder cannot parse/typecheck | Clean fixture must import or inline |
| `Decimal[scale: 3]` | pressure candidate | Ch3 canon uses `Decimal[N]`; registry marks named scale form pressure | Competing decimal spellings | Type surface cleanup |
| `Boolean`, `Int32`, `Pair[String, String]` | future/non-canon | Ch2/Ch3 use `Bool`, `Integer`; no `Pair` type in kernel list | Host/utility type leakage | Normalize or define explicitly |
| `packet/event/receipt` | pressure candidate | Registry pressure | Strong data-role readability, not ch2 top-level canon | Evidence/receipt/proof vocabulary specimen |
| `store mesh_topology: BiHistory[...]` | pressure candidate | `BiHistory[T]` type canon | `store` declaration/source/axes/lifecycle not ch2 canon | Store declaration surface |
| `stream live_mesh_updates` | pressure candidate | Stream Stage 2; ch2 has window body but not this top-level spelling | Stream source declaration still needs grammar sync | Stream surface lane |
| `metric mesh_resilience_index` | pressure candidate | OLAPPoint canon; `metric` pressure | Alias/projection semantics unresolved | Product-facing OLAP alias review |
| `external pure detect_disaster(signal_data: Any...)` | pressure candidate but risky | `external pure` pressure; `Any` type exists | Disaster detection is not automatically pure/verifiable; `Any` erases shape | External effect/capability proposal |
| `external pure spawn_new_agent_instance` | unsafe/ambiguous | No runtime capability semantics for spawn | Spawning agents is an effect, not pure CORE | Treat as ESCAPE capability with receipt/review |
| `external pure apply_self_modification` | unsafe/ambiguous | No self-modification semantics | Self-modifying runtime/code is high-risk and should not be pure helper syntax | Gate/capability policy only |
| `external pure broadcast_mesh_topology(...)` without return type | future/non-canon | Ch2 external syntax differs; functions should have typed results | Void/effect return model missing | Result/effect observation surface |
| Global `invariant ... { condition/message }` | unsafe/ambiguous | Invariant severity exists inside contracts, not as global free-var policy | `replication`, `patch` unbound globally | Keep as non-parser policy notes or move into contracts |
| `severity: critical`, `severity: legal` | future/non-canon | Canon severities: error/warn/soft/metric | Domain severity lattice not defined | Governance/policy pressure |
| `in [:emergency_coordinator, :meta-expert]` | pressure candidate | Set/in pressure exists in registry | Set literal/membership not canon | Primitive set specimen |
| `signal.severity > 0.6` with `severity: critical` | mixed pressure | Comparison canon; severity label not canon | Annotation spelling differs from existing pressure examples | Normalize in clean fixture |
| `Any` signal data | current type concept, unsafe boundary | Ch3 includes `Any` | Dynamic emergency payload can hide required evidence shape | Typed `DisasterInput` specimen |
| `for i in 0..4` | future/non-canon | No `for` or range literal in ch2 kernel | Loop/range/accumulation semantics unresolved | Collection/range sugar specimen |
| `children = children + [...]` | unsafe/ambiguous | `let` is immutable in kernel; `++` exists as op, not mutation | Reassignment/mutation pressure not canon | Use fold/map or block-compute lowering experiment |
| `ModificationPatch { ... }`, `children.map(...)`, `AuthorityRef { ... }` | unsafe/ambiguous | Record literals require fields; ellipsis is not syntax | Placeholder values cannot parse/typecheck | Clean fixture must complete all values |
| `uuid_v4`, `pair` | unsafe/ambiguous | Not Ch8 kernel stdlib | Hidden helper assumptions | Declare external/effect or avoid |
| `view emergency_mesh_dashboard` | pressure candidate | Registry pressure | Materialization/projection semantics unsettled | View/metric product projection lane |

---

## Syntax Gap Matrix: DecentralizedMarketplaceV1

| Element | Classification | Current anchor | Gap / risk | Route |
|---------|----------------|----------------|------------|-------|
| `profile ... authority: peer_to_peer; escrow: atomic` | future/non-canon | Profile pressure only | Peer/escrow policy fields are not runtime semantics | Profile/capability taxonomy |
| `AuthorityRef { ... }` placeholder | unsafe/ambiguous | Ch2 types require fields/imports | Hidden dependency on KnowledgeMesh | Clean fixture must inline/import |
| `Decimal[scale: 2/3]` | pressure candidate | Ch3 canon uses `Decimal[N]` | Named-scale spelling pressure | Type surface cleanup |
| `packet/event/receipt` | pressure candidate | Registry pressure | Data-role top-level profiles not canon | Evidence/receipt/proof vocabulary |
| `store listings/escrows: BiHistory[...]` | pressure candidate | `BiHistory[T]` type canon | Store declaration, axes, partition, durability not ch2 canon | Store/temporal source grammar |
| `stream live_market_feed` | pressure candidate | Stream canon/pressure split | Top-level stream spelling unresolved | Stream surface lane |
| `metric marketplace_volume/reputation_impact` | pressure candidate | OLAPPoint canon; `metric` pressure | Product-readable analytics alias unresolved | OLAP alias review |
| `external pure validate_listing(...) -> Boolean` | pressure candidate with host leak | `external pure` pressure; `Bool` canon not `Boolean` | `Boolean` spelling and validation evidence unclear | Normalize to `Bool`; define evidence/failure |
| `external pure verify_legal_compliance(...)` | pressure candidate but risky | External pure pressure | Legal compliance is not pure unless source/evidence/capability model is explicit | Bridge/legal capability lane |
| `Any` listing/bid payloads and result | current type concept, unsafe boundary | Ch3 includes `Any` | Dynamic marketplace actions hide financial/legal shape | Prefer typed variants/contracts |
| `valid_listing` invariant with `severity: error` | mixed pressure | Stage 2 invariant severity includes error | Annotation colon spelling and invariant source surface still pressure | Normalize syntax before fixture extraction |
| `evidence: EvidenceBundle { primary: [listing_data.evidence] }` | pressure candidate | Record/array literals canon; EvidenceBundle pressure | Partial record? fields missing if type expects corroborating/contradictions | Complete records in clean fixture |
| `read current_listing ... at { vt, tt }` | pressure candidate | BiHistory coordinate requirement exists; spelling not canonical | Runtime live BiHistory eval excluded by Gate 3 scope | Temporal coordinate grammar only |
| `as_of + 7.days` | pressure candidate | Ch8 date primitives exist; no duration literal grammar | Duration literal and timestamp addition surface unset | Temporal expression specimen |
| External fact-check/legal calls inside trade | unsafe/ambiguous | External pure pressure | Marketplace execution depends on OSINT/legal systems without failure/authority semantics | Result/evidence/capability boundary |
| `escrow_atomic` with `<=>` | future/non-canon | Ch2 operators omit biconditional | Needs boolean equivalence operator or rewrite | Use `(a && b) || (!a && !b)` in clean fixture |
| `severity: legal`, `overridable_with human_arbitration` | future/non-canon | Canon severity set does not include legal; review syntax pressure | Arbitration binding/receipt/timeout undefined | Review lifecycle proposal |
| `error "Unknown marketplace action"` | unsafe/ambiguous | No ch2 error statement | Failure/Result semantics absent | Result/failure expression proposal |
| `uuid_v4` | unsafe/ambiguous | Not Ch8 kernel stdlib | Nondeterministic id helper hidden | Capability/evidence-bound id generation |
| `view marketplace_dashboard` | pressure candidate | Registry pressure | Product projection not canon | View/metric projection lane |

---

## Cross-Fixture Pressure Classes

| Pressure class | Seen in | Classification | Recommendation |
|----------------|---------|----------------|----------------|
| Replication/self-modification policy | Emergency | unsafe/ambiguous | Do not create parser fixtures until capability, review, and receipt semantics exist |
| Financial/escrow/legal policy | Marketplace | unsafe/ambiguous | Treat as product pressure only; needs transaction/custody/dispute model before runtime examples |
| Runtime profile taxonomy | both | pressure candidate | Same pressure as Cross Test 2, now with riskier policy fields |
| Store declarations | both | pressure candidate | Store/temporal source grammar remains high-priority if product examples continue using it |
| `Any` orchestration | both | current type concept but unsafe boundary | Replace with typed inputs or variants in clean fixtures |
| Global invariants | Emergency, Marketplace | unsafe/ambiguous | Keep as policy notes; do not promote to global language surface |
| Legal/critical severity | both | future/non-canon | Domain severity lattice must not leak into core invariant severity |
| Method/range/mutation sugar | Emergency | future/non-canon / unsafe | Needs block-compute or collection sugar experiments before use |
| Duration literals | Marketplace | pressure candidate | Route to temporal expression surface only |
| Hidden stdlib helpers | both | unsafe/ambiguous | `uuid_v4`, `sha256`, `pair` need declaration and effect classification |

---

## Clean Non-Canon Fixture Extraction Recommendation

Do not extract the two snippets verbatim into `.ig` fixtures yet.

Recommended clean extraction order:

1. `emergency_mesh_replicator_v1_pressure.ig`
   - Keep: emergency topology data types, replication receipt, one explicit
     replication contract.
   - Remove or isolate: self-modification, broadcast, global invariants,
     `for` range mutation, placeholder records, `Any`.
   - Mark all spawn/replicate behavior as ESCAPE capability pressure, not
     `external pure`.

2. `decentralized_marketplace_v1_pressure.ig`
   - Keep: listing, bid, escrow, trade, receipt, one typed trade path.
   - Replace: `Any` payload dispatch with typed contract inputs.
   - Remove or isolate: legal compliance execution, `error` statement, `<=>`,
     `severity: legal`, hidden `uuid_v4`.
   - Mark escrow/financial/legal behavior as product pressure, not runtime proof.

Each extracted fixture should start with:

```text
-- This file is not current Igniter-Lang canon and is not expected to parse.
-- It is a syntax/product pressure artifact only.
```

---

## Proposal Routing Candidates

| Candidate | Priority | Owner | Why |
|-----------|----------|-------|-----|
| External effect/capability declarations | high | Compiler/Grammar Expert + Bridge Agent | Spawn, self-modification, broadcast, escrow, legal checks cannot be modeled as `external pure` |
| Store declaration surface | high | Compiler/Grammar Expert + Research Agent | Both fixtures depend on `store` plus History/BiHistory metadata |
| Data-role vocabulary (`packet/event/receipt`) | high | Compiler/Grammar Expert | Both fixtures use receipts/events to preserve auditability |
| Review/arbitration lifecycle | medium-high | Research Agent + Bridge Agent | `human_arbitration`, emergency authority, and override semantics need binding/timeout/receipt |
| Failure/Result expression surface | medium | Compiler/Grammar Expert + Research Agent | `error "..."` keeps appearing in general-purpose fixtures |
| Duration/range/collection sugar | medium | Compiler/Grammar Expert | `7.days`, `0..4`, method chains, and local accumulation recur in readable examples |
| Profile taxonomy | medium | Archive/Form Expert + Compiler/Grammar Expert | Risky policy fields need taxonomy before grammar |
| Legal/critical severity lattice | low/defer | Bridge Agent + Architect | Domain severity should remain product-policy pressure until governance accepts it |

---

## Handoff

[D] Extracted the two Cross Test 3 fixture families as syntax/product pressure:
`EmergencyAgentMeshReplicatorV1` and `DecentralizedMarketplaceV1`.

[D] Classified the syntax surface as current, pressure candidate,
future/non-canon, or unsafe/ambiguous.

[S] Raw snippets should not become fixtures verbatim. They mix useful language
pressure with high-risk product semantics, placeholders, unbound names, `Any`,
global policy invariants, undeclared stdlib helpers, and effectful behavior
spelled as `external pure`.

[T] No parser/runtime/spec canon files were edited. No syntax was promoted to
canon.

[R] Strongest route: external effect/capability declarations, store declaration
surface, and data-role vocabulary. Highest-risk deferral: autonomous
self-replication/self-modification and financial/legal execution semantics.

[Next] If fixture extraction is authorized, start with a narrow emergency
replication receipt specimen and a narrow typed marketplace escrow specimen,
both explicitly non-canon.

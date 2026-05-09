# Origins: Arbor -> Ruby Igniter -> Igniter-Lang

Status: archived history report
Date: 2026-05-09
Author: [Igniter-Lang History Curator]
Scope: Obsidian `Ideas/Arbor 2.0`, `Ideas/Agentor`, current Ruby Igniter packages, and `igniter-lang/`

## Purpose

This report preserves the origin line behind Igniter and Igniter-Lang.

It is not a new proposal, package plan, or syntax promise. It is a compact
history note for future archaeology: what the early Arbor/Agentor notes were
trying to build, which ideas already landed in Ruby Igniter or Igniter-Lang,
which signals still matter, and which material can remain cold archive.

## Source Set

External notes reviewed:

- `[..]/Obsidian/Ideas/Arbor 2.0/`
- `[..]/Obsidian/Ideas/Agentor/`

Primary files:

- `Arbor.md`
- `Arbor DSL Specification v1.0.md`
- `философия Arbor 3.0.md`
- `Спецификация Ядра Nexus v0.1.0 (ранее UMSC).md`
- `Спецификация Analytics Cube.md`
- `Оценка возможности имплементации на Arbor.md`
- `Технический Аудит и План Рефакторинга Arbor 2.0.md`
- `TimeSlots.md`
- `1.md`, `2.md`, `3.md`, `Untitled*.md`
- `RFC-0001 — Agentor v0**.md`
- `RFC-0002 — Agent & Proposal Contracts.md`

Internal comparison set:

- `packages/igniter-contracts/README.md`
- `docs/dev/execution-model.md`
- `docs/dev/current-runtime-snapshot.md`
- `docs/dev/ai-agents-target-plan.md`
- `docs/research/horizon-protocol.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/spec/`
- `igniter-lang/docs/runtime-machine.md`
- `igniter-lang/docs/axiomatic-contract-model.md`
- `igniter-lang/docs/proposals/PROP-024-olap-point-primitive-v0.md`
- `igniter-lang/docs/proposals/PROP-029-entrypoint-section-surface-v0.md`

## Executive Summary

The project did not begin as a language.

It began as Arbor: a Ruby framework idea for declaring business processes as
validated dependency graphs. Arbor's core metaphor was:

```text
Declaration ("Map") -> Execution Plan ("Route") -> Runtime ("Terrain")
```

Ruby Igniter became the practical platform version of that thought:

```text
DSL / Contract class -> CompiledGraph -> Runtime execution
```

Igniter-Lang became the formal language version:

```text
.ig source
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR
  -> .igapp artifact
  -> RuntimeMachine
```

The old Arbor documents are therefore not random abandoned notes. They are the
earliest vocabulary for the split that now exists:

- Ruby Igniter: shippable framework/platform for real systems.
- Igniter-Lang: research/spec/compiler spine for contract-native computation.

The main archival rule is:

```text
Do not restore Arbor.
Recover its durable signals into the current language/platform split.
```

## Origin Layer 1: Arbor

Arbor's central claim was that business logic should be declared as a graph,
not hidden in procedural service-object chains.

The early vocabulary:

- Process: a self-contained business capability.
- Store: a namespace for values.
- Value: an atomic graph node.
- Producer: the only thing that computes a value.
- Dependency: a static edge on the map.
- EntryPoint: the public process contract.
- Runtime: per-run state, cache, failures, and tracing.

Important Arbor principles:

- The declaration is static and inspectable before execution.
- Dependencies are explicit and serializable.
- Execution is lazy by default.
- Composition should use the same mechanism as local compute.
- Tooling is part of the framework, not a secondary utility.

The strongest old phrase was the "Map and Terrain" model. It already contained
the split between graph structure and actual runtime evaluation that later
became `CompiledGraph` in Ruby Igniter and SemanticIR/.igapp in Igniter-Lang.

## Origin Layer 2: Arbor 3.0 / Nexus

The Arbor 3.0 notes added the missing middle phase:

```text
DSL -> Declaration ("Map") -> Planning -> Execution Plan ("Route") -> Runtime
```

This was the first clear appearance of compiler thinking in the project. The
old `Resolver` was no longer enough; the system wanted a planner/executor split.

The `Nexus` document proposed a general Ruby-native VM with instruction
sequences, stack operations, scheduler plugins, and `RESOLVE` instructions.

Current interpretation:

- The planner/executor split was correct.
- A low-level Nexus VM is historical, not the chosen current path.
- Igniter-Lang chose a semantic machine instead of an opcode machine.

In current terms, `Nexus` is superseded by:

- `SemanticIR`
- `.igapp` artifacts
- `RuntimeMachine`
- `CompatibilityReport`
- `TBackend` as pluggable temporal substrate

This is a stronger form of the original dream because runtime meaning is not
hidden in opcodes. It is carried by semantic artifacts, fragment classes,
observations, compatibility reports, and guard policies.

## Origin Layer 3: Ruby Igniter

Ruby Igniter is the practical runtime/platform branch.

Its current package map makes the split explicit:

- `igniter-contracts`: embedded graph kernel, DSL, compilation, execution,
  diagnostics, class DSL, Contractable service protocol.
- `igniter-extensions`: optional packs and tooling.
- `igniter-embed`: host integration.
- `igniter-application`: local application runtime.
- `igniter-ai` and `igniter-agents`: provider-neutral AI and minimal agent run
  state.
- `igniter-ledger` and durable packages: experimental persistence/fact surfaces.

Ruby Igniter currently implements the practical minimum:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total
    input :country

    compute :gross_total, depends_on: %i[order_total country] do |order_total:, country:|
      order_total * (country == "UA" ? 1.2 : 1.0)
    end

    output :gross_total
  end
end
```

Arbor's store/value vocabulary became smaller and clearer:

- `input`
- `compute`
- `output`
- `call:` / `using:` for callable services
- compiled graph execution

Important difference:

Ruby Igniter should remain shippable. It should not inherit every formal
Igniter-Lang concept immediately. Its job is to prove repeated practical shapes
in examples and packages.

## Origin Layer 4: Igniter-Lang

Igniter-Lang is not syntax sugar for Ruby Igniter.

Its own README states the current split:

```text
Igniter      = framework/platform for real systems.
Igniter-Lang = language research ecosystem for contract-native computation.
```

The language has a formal spine:

```text
Source .ig
  -> Parser
  -> Classifier
  -> TypeChecker
  -> SemanticIREmitter.emit_typed
  -> Assembler .igapp
  -> RuntimeMachine load/evaluate
```

Core ideas that came from Arbor but became formal in Igniter-Lang:

- A contract is a typed observable promise.
- The graph is finite, explicit, and dependency ordered.
- Time is explicit, not ambient.
- Lifecycle is declared.
- Effects/capabilities are classified.
- Failures are structured values.
- Runtime compatibility is a semantic concern.
- Observations and receipts are part of meaning.

The old Arbor "Map" is now:

- ParsedProgram
- ClassifiedProgram
- TypedProgram
- SemanticIR
- assembled `.igapp` contract artifacts

The old Arbor "Terrain" is now:

- RuntimeMachine
- EvaluationResult
- observations
- checkpoints
- compatibility reports
- TBackend bindings

## Concept Concordance

| Old Arbor / Agentor concept | Ruby Igniter home | Igniter-Lang home | Current disposition |
| --- | --- | --- | --- |
| Map / Declaration | `CompiledGraph` | ParsedProgram, TypedProgram, SemanticIR | Accepted, formalized |
| Route / Execution plan | resolution order / operations | `.igapp` artifacts + runtime load plan | Accepted, more formal in Lang |
| Runtime / Terrain | contracts runtime execution | RuntimeMachine | Accepted, split by platform/language |
| `store :inputs` | `input` | `input` | Accepted in simpler form |
| `value` | `compute` / internal operation | compute node | Accepted in clearer form |
| IdentityProducer for inputs | implicit input read | input node / port | Valuable rationale, no public syntax |
| EntryPoint as accepts/returns | `Contract.call`, host registration | contract boundary + PROP-029 target selector | Old meaning superseded |
| Composition | callable/contract services, package pressure | contract composition algebra | Active/future formalization |
| Reactions / side effects | effects, receipts, app commands | observations, ESCAPE, receipts | Accepted as capability/evidence problem |
| Tracer/EventBus | runtime events / diagnostics | ObsPacket / observation envelope | Accepted in stronger form |
| Analytics Cube | optional extension/product idea | OLAPPoint[T,Dims] | Formalized in PROP-024 |
| TimeSlots | application/domain pressure | availability fixtures, temporal/stream surfaces | Keep as scenario pressure |
| Agentor Proposal | `igniter-agents` future work | AgentProposalObservation / bridge profiles | Keep as agent bridge signal |
| Nexus VM | none | superseded by RuntimeMachine | Archive as rejected path |

## Entrypoint Caution

Arbor's `entry_point` meant the public API of a process:

```text
accepts inputs
returns outputs
```

Igniter-Lang must not import that meaning directly.

In Igniter-Lang, `contract` is already the computation boundary. The current
`PROP-029` proposal treats `entrypoint` only as a named evaluation profile or
target selector over an existing contract.

Recommended rule:

```text
Keep `entrypoint` as tool/run metadata, not as a second contract identity.
```

This preserves the language's semantic clarity and avoids duplicating the
computation boundary.

## Analytics Cube -> OLAPPoint

The old `Analytics::Cube` note is one of the most valuable historical signals.

It described:

- base axis
- dimensions
- data points / facts
- `each_by`
- `query`
- `aggregate`
- drill-down / roll-up / pivot

Igniter-Lang's `OLAPPoint[T, Dims]` is the correct formal successor.

Important lineage:

```text
TimeSlots / Availability grid
  -> Analytics::Cube
  -> History[T] as 1D analytical structure
  -> OLAPPoint[T, Dims]
```

This should remain part of the historical rationale for `PROP-024`. The old
cube should not become a Ruby core abstraction by itself unless repeated
package/application pressure demands it.

## Agentor -> Agent Proposal Observations

Agentor proposed a multi-agent cognitive environment:

```text
Environment
  -> active contours
  -> active agents
  -> proposals
  -> consensus
  -> state update
```

Its strongest durable idea was not the loop. It was the strict proposal shape:

- `agent_id`
- `contour`
- `type`
- `content`
- `confidence`
- `salience`
- `tags`

Current interpretation:

- Do not move Agentor wholesale into `igniter-contracts`.
- Do not make Igniter-Lang a multi-agent runtime.
- Preserve `Proposal` as an observation/receipt profile for agent review,
  human approval, meaning diff, and acceptance workflows.

This lines up with Igniter-Lang bridge material around:

- `AgentProposal`
- confidence as not truth
- review receipts
- acceptance receipts
- human-agent readable contracts

Recommended rule:

```text
Agent proposals are evidence-bearing observations, not authority by themselves.
```

## What To Promote From Old Notes

Promote these ideas as compact references, not as raw pasted docs.

### 1. Contract Authoring Method: "Skeleton and Muscles"

Old source: `Untitled 2.md`.

Durable method:

1. Declare the contract surface: inputs, computes, outputs.
2. Validate the graph and inspect the shape.
3. Add producer implementations or external bindings.
4. Add integration tests / fixture runs.
5. Use trace/observations/diagnostics to debug runtime behavior.

Current home candidates:

- Ruby Igniter guide: authoring contracts.
- Igniter-Lang guide: authoring `.ig` files and fixtures.

### 2. Tooling as Framework Semantics

Old Arbor insisted that Visualizer, Doctor, Tracer, and Inspector are part of
the framework's value.

Current stronger form:

- CompilationReport
- diagnostics
- SemanticIR
- `.igapp` artifacts
- CompatibilityReport
- runtime observations

Keep this as a product/design doctrine:

```text
If users cannot inspect the graph, the graph is not really the source of truth.
```

### 3. Inputs as Nodes

The old "IdentityProducer" idea is useful internal rationale:

```text
inputs are not magic values; they are graph boundary nodes.
```

This should influence compiler/runtime implementation and docs, but it does not
need public syntax.

### 4. Availability / TimeSlots Scenario Pressure

The TimeSlots and Ringba notes were early real-world pressure tests. They map
well to current fixtures:

- availability projection
- read nodes
- lifecycle `:window` / `:durable`
- snapshots
- temporal/stream surfaces

They should be kept as scenario ancestry, not direct architecture.

## What To Archive Cold

These old concepts are historically useful but should not drive current
implementation directly:

- Arbor `store/value/direction` surface as public language syntax.
- `entry_point accepts/returns` as language computation boundary.
- Nexus opcode/stack VM.
- Broad Agentor environment loop as core contract runtime.
- Raw chat transcripts and repeated "next step?" endings.
- Untitled syntactic snippets already covered by later specs.

## What Can Be Deleted From The Obsidian Ideas Folder Later

Only after the owner chooses to clean that folder:

- `.DS_Store`
- `Untitled 1.md` after the `on inputs... value` syntax note is considered
  archived by this report.
- Repetitive conversational endings in all Arbor/Agentor notes.

Do not delete the original files automatically from this repo process. They are
external user-owned notes.

## Recommended Current Interpretation

Use this three-way split:

```text
Arbor
  historical origin and intuition layer

Ruby Igniter
  practical platform / package runtime / examples / apps

Igniter-Lang
  formal semantic language / compiler / artifact / runtime-machine research
```

When recovering an old idea, ask:

1. Is it practical package behavior? Route to Ruby Igniter.
2. Is it semantic meaning, type, lifecycle, observation, or compiler behavior?
   Route to Igniter-Lang.
3. Is it agent review, proposal, confidence, or approval? Route to bridge /
   `igniter-agents`, not core contracts.
4. Is it only a metaphor or abandoned implementation path? Keep it archived.

## Open Follow-Up Slices

Suggested future slices:

1. Write `designing-contracts-skeleton-and-muscles-v0.md` as a guide/track.
2. Add a short historical note to `PROP-024` or a value index entry:
   `Analytics::Cube -> OLAPPoint`.
3. Draft an AgentProposal bridge note that compares Agentor RFC-0001/0002 with
   current observation/receipt profiles.
4. Create an "Arbor lineage" entry in the Igniter-Lang value index if/when a
   living signal ledger exists.
5. Review `PROP-029` against old Arbor `entry_point` to explicitly reject the
   old accepts/returns meaning for source-level `entrypoint`.

## Final Historical Claim

Arbor asked:

```text
Can business logic be a visible dependency graph instead of hidden control flow?
```

Ruby Igniter answers:

```text
Yes, as a practical Ruby platform and package ecosystem.
```

Igniter-Lang answers:

```text
Yes, and the graph can become a typed, observable, time-aware semantic artifact
with compiler reports, runtime contracts, compatibility checks, and receipts.
```

That is the project lineage. The origin should be preserved, but the current
direction should remain the platform/language split, not a return to Arbor.

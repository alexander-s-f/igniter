# Track: Contextizer Lineup Bridge Analysis v0

Card: S3-R40-C4-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `contextizer-lineup-bridge-analysis-v0`
Status: done
Date: 2026-05-12

---

## Goal

Analyze the relationship between Line Ups, the legacy Contextizer CLI, and the
`Igniter.DocumentContextizer` pressure specimen without proposing implementation.

---

## Sources Read

Igniter-Lang:

```text
docs/tracks/contextizer-pressure-specimen-routing-v0.md
experiments/pressure-specimens/mundane-application-pressure-v0/igniter-document-contextizer.ig
docs/lineups/README.md
roles/line-up-summarizer.md
```

External local utility, referenced publicly as:

```text
[GEM]/contextizer/README.md
https://github.com/alexander-s-f/contextizer
```

Additional local inventory read for vocabulary only:

```text
[GEM]/contextizer/lib/contextizer/context.rb
[GEM]/contextizer/lib/contextizer/collector.rb
[GEM]/contextizer/lib/contextizer/analyzer.rb
[GEM]/contextizer/lib/contextizer/cli.rb
[GEM]/contextizer/lib/contextizer/configuration.rb
[GEM]/contextizer/lib/contextizer/renderers/markdown.rb
[GEM]/contextizer/config/default.yml
```

---

## Boundary

This is a bridge analysis only.

It does not authorize:

```text
package creation
parser syntax
runtime behavior
LLM connector
Ledger binding
BiHistory binding
production deployment
mutation of [GEM]/contextizer
mutation of docs/lineups/
promotion of pressure specimen syntax to canon
```

Safe summary:

```text
Contextizer is a strong future capability signal, but current evidence supports
only route planning and vocabulary extraction.
```

---

## Core Finding

The three surfaces share a real problem:

```text
large source material -> selected evidence -> compact context artifact -> future
agent/human consumption
```

They should not be collapsed into one thing.

Line Ups are memory-card governance for the Igniter-Lang documentation system.
The legacy Contextizer CLI is a project-context extraction utility that renders a
Markdown report. `Igniter.DocumentContextizer` is a non-canonical pressure
specimen for a future typed, receipt-bearing, agent/swarm context pipeline.

The likely future architecture is not "replace Line Ups with Contextizer" and
not "compile the specimen". The likely route is a profile/package boundary where
context capture, context summarization, evidence linking, and optional LLM
refinement become separate named capabilities.

---

## Comparison Matrix

| Surface | Current status | Primary input | Primary output | Owner / authority | What it proves | What it does not prove |
| --- | --- | --- | --- | --- | --- | --- |
| Line Up Summarizer | Active docs workflow | Bulky docs, tracks, discussions, pressure files, history reports | Compact memory card plus index row | `[Igniter-Lang Line Up Summarizer]`; not canon | Igniter-Lang needs durable, low-context handles for source evidence | General extraction engine, package boundary, runtime behavior, LLM authority |
| Legacy Contextizer CLI | External/local Ruby CLI gem | Project filesystem or public Git repo | Single Markdown context report with metadata, tree, selected files | External utility; not Igniter-Lang authority | Practical extraction primitives exist: analyzers, providers, renderers, config profiles, remote repo intake | Typed `ContextSnapshot`, evidence receipts, Ledger/BiHistory, agent pipeline, language semantics |
| DocumentContextizer specimen | Active pressure specimen only | TextSource/TextBuffer plus params | `ContextSnapshot`, key points, receipts, quality/drift/publish contracts | Pressure only; explicitly non-canonical | Future product/language pressure: context snapshots, drift, quality, swarm publication, LLM escape | Parser syntax, package creation, runtime execution, Ledger/BiHistory binding, production readiness |

---

## Shared Vocabulary

Shared terms with useful future value:

```text
context
snapshot
source
metadata
evidence
report
summary
profile / configuration
provider
analyzer
renderer
project structure
git metadata
dependency metadata
drift / actualization
quality
publish
```

Vocabulary that should stay pressure-only until formalized:

```text
ContextSnapshot
KeyPoint
FactReceipt
History[ContextSnapshot]
BiHistory-backed snapshots
LLMConnector
publish-for-swarm
actualize
production-ready
ambient now
```

Practical vocabulary from the CLI that is lower risk:

```text
Analyzer
Collector
Provider
Renderer
Configuration
Context report
Markdown output
local project
remote git repository
filesystem components
exclude patterns
```

---

## Distinct Responsibilities

### Line Ups

Line Ups should remain documentation metabolism, not an extraction runtime.

Responsibilities:

```text
summarize bulky source docs
preserve source path and disposition
avoid context bloat for future agents
route exact proof needs back to source
mark canon/non-canon boundaries
```

Keep out:

```text
automatic source ingestion
LLM calls
remote repository cloning
runtime receipts
Ledger persistence
production context publication
```

### Legacy Contextizer CLI

The CLI is best treated as a practical extraction reference.

Responsibilities observed:

```text
detect language/framework via weighted analyzer signals
collect base project metadata
collect git, filesystem, dependency data
merge CLI/project/default configuration
render one Markdown context report
optionally analyze a public remote Git repository
```

Keep out of Igniter-Lang authority:

```text
compiler semantics
Line Up governance
runtime execution
Ledger/BiHistory semantics
LLM connector semantics
production claims
```

### DocumentContextizer Pressure Specimen

The specimen is useful as high-level pressure on future language features, not
as a source file to compile.

Signals:

```text
typed ContextSnapshot and KeyPoint shapes
quality validation and drift detection
evidence links / receipts
context actualization from source changes
agent-facing context publication
LLM refinement as explicit escape pressure
```

Keep pressure-only:

```text
non-canonical keywords: phase, given, emit
ambient now
DateTime? / Array[T] / Map[String, Any] vocabulary
History[ContextSnapshot] from string path
ContractRef facade shape
Ledger/BiHistory claims
production-ready claim
```

---

## Candidate Future Package / Profile Boundary

The clean future boundary is capability-owned, not file-owned.

Candidate profile slots or packages, subject to future Architect routing:

| Candidate | Ownership | Depends on | Why it fits | Why it is not authorized now |
| --- | --- | --- | --- | --- |
| `ContextCapturePack` | Filesystem/git/dependency/project metadata capture descriptors | Effect/escape policy, source privacy policy | Matches CLI analyzer/provider primitives | Would imply package/profile work not assigned here |
| `ContextReportPack` | Rendering compact context reports from captured source evidence | Capture descriptors | Low-risk bridge from CLI Markdown output to structured report shape | Renderer/package work is not authorized |
| `LineUpMemoryPack` | Line Up-style memory card shape and disposition vocabulary | Documentation governance, source disposition policy | Preserves current Line Up strengths as a formal profile capability later | Line Ups are role-owned docs workflow today, not compiler/runtime surface |
| `ContextSnapshotPack` | `ContextSnapshot`, `KeyPoint`, evidence link shape | Type vocabulary, receipt policy | Directly captures specimen's strongest typed-data signal | Needs proposal; specimen syntax is non-canon |
| `ContextQualityPack` | Quality/drift/actualization descriptors | Snapshot shape, source versioning semantics | Useful product pressure without requiring LLM first | Needs semantic definition; no runtime persistence authorized |
| `LLMRefinementEscapePack` | Explicit LLM call boundary, approval, receipt, refusal shape | Escape surface, runtime guard, privacy policy | Prevents hidden LLM calls and ambient agent behavior | LLM connector is explicitly unauthorized |
| `SwarmPublicationPack` | Publication target descriptors for agent consumption | Context snapshot, access policy | Captures specimen's agent/swarm goal | Production deployment and runtime publication are closed |

Research recommendation:

```text
First prove descriptor/data shapes, not execution. A future Contextizer profile
should be assembled from capture/report/snapshot/quality/LLM/publication
capabilities, with LLM and persistence kept behind explicit escape and storage
boundaries.
```

---

## Risk Analysis

### LLM Escape

Risk:

```text
The specimen uses `LLMConnector` inside a contract and frames the result as a
normal context pipeline step.
```

Required future guard:

```text
LLM calls must be explicit ESCAPE capability, never hidden pure work. Future
receipts must separate input selection, prompt construction, model invocation,
model output, quality validation, and human/agent publication.
```

Current decision:

```text
No LLM connector route is authorized by this track.
```

### Ledger / BiHistory

Risk:

```text
The specimen claims Ledger-backed `BiHistory[ContextSnapshot]`, but current
Stage 3 boundaries keep Ledger/BiHistory production binding closed outside
approved durable-audit lanes.
```

Required future guard:

```text
Context persistence must not borrow durable-audit authority, TBackend authority,
or Ledger authority. If context history becomes real, it needs its own
descriptor and compatibility review.
```

Current decision:

```text
No Ledger or BiHistory binding is authorized.
```

### Ambient Time

Risk:

```text
The specimen uses `now` in snapshot id and `created_at` generation.
```

Required future guard:

```text
Time must be explicit input or a named runtime capability with receipt/refusal
semantics. Ambient time is not acceptable as pure contract behavior.
```

Current decision:

```text
Treat `now` as syntax/semantics pressure only.
```

### Production Claims

Risk:

```text
The specimen includes "production-ready" language and package-placement
suggestions.
```

Required future guard:

```text
External pressure claims must not become project authority. Production readiness
requires proposal, proof, implementation authorization, runtime review, and
separate rollout authorization.
```

Current decision:

```text
The specimen is active pressure only.
```

### Source Privacy / Remote Intake

Risk:

```text
The legacy CLI can analyze local projects and public remote Git repositories.
Future agent-context tooling may accidentally package private source or secrets
into context artifacts.
```

Required future guard:

```text
Any ContextCapture-like package needs include/exclude policy, secret scanning
pressure, public/private disposition, and output retention rules before it is
used as an agent pipeline.
```

Current decision:

```text
The CLI remains an external utility signal, not an Igniter-Lang package.
```

---

## Candidate Future Routes

These are route candidates only.

| Candidate card | Route | Purpose |
| --- | --- | --- |
| `contextizer-utility-inventory-v0` | track | Deeper inventory of `[GEM]/contextizer` architecture, dependencies, and safe bridge signals |
| `lineup-context-card-shape-extraction-v0` | track | Extract current Line Up card fields into a non-canonical data-shape map |
| `context-snapshot-shape-proposal-prep-v0` | proposal-prep | Draft minimum `ContextSnapshot` / `KeyPoint` / evidence-link shape without runtime persistence |
| `context-capture-pack-shadow-boundary-v0` | track | Shadow-map CLI analyzer/provider/renderer concepts into future pack/profile descriptors |
| `llm-connector-escape-boundary-pressure-v0` | track or PROP prep | Define explicit escape/refusal/receipt pressure for LLM calls |
| `context-actualization-and-drift-semantics-v0` | research track | Compare drift/actualization to temporal/history semantics without enabling BiHistory |
| `document-contextizer-product-pressure-v0` | product pressure | Product-level scenario for document context pipeline, swarm publication, quality checks |

Recommended first route:

```text
context-capture-pack-shadow-boundary-v0
```

Reason:

```text
It can use the practical CLI vocabulary while staying descriptor-only. It avoids
parser work, runtime work, LLM calls, Ledger/BiHistory, and production claims.
```

---

## Non-Authorizations

This track does not authorize:

```text
creating packages/igniter-contextizer
creating packages/igniter-document-contextizer
compiling igniter-document-contextizer.ig
adding Contextizer syntax to parser
adding ContextSnapshot to stdlib
adding LLMConnector
adding Ledger or BiHistory persistence
adding context publication runtime
changing Line Up ownership or workflow
changing [GEM]/contextizer
claiming production readiness
```

---

## Handoff

```text
Card: S3-R40-C4-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: contextizer-lineup-bridge-analysis-v0
Status: done

[D] Decisions
- Line Ups, legacy Contextizer CLI, and DocumentContextizer are adjacent but
  distinct.
- The useful future route is capability-owned profile/package pressure, not
  direct specimen compilation or Line Up replacement.
- LLM, Ledger/BiHistory, ambient time, and production claims remain explicitly
  unauthorized.

[S] Signals
- The CLI contributes practical capture vocabulary: analyzers, providers,
  renderers, configuration, project/git/dependency metadata.
- Line Ups contribute governance vocabulary: compact memory card, source path,
  disposition, next route, non-canon boundary.
- The specimen contributes future typed product pressure: ContextSnapshot,
  KeyPoint, evidence links, quality, drift, actualization, swarm publication.

[T] Tests / Proofs
- Documentation-only analysis.
- No code, parser, package, runtime, Ledger/BiHistory, LLM connector, or
  production deployment work.

[R] Recommendations
- Prefer `context-capture-pack-shadow-boundary-v0` as the next safe research
  route.
- Keep LLM refinement and persistence as separate capabilities behind explicit
  escape/storage authority.

[Next]
- Optional next card: `context-capture-pack-shadow-boundary-v0`.
```

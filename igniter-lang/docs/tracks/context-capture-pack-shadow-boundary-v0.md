# Context Capture Pack Shadow Boundary v0

Card: S3-R41-C5-P2
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/context-capture-pack-shadow-boundary-v0
Status: done
Date: 2026-05-12

## Goal

Map a design-only Context Capture Pack shadow boundary from Line Ups, the legacy
Contextizer CLI, and `Igniter.DocumentContextizer` pressure.

This card is authorized by:

```text
igniter-lang/docs/gates/context-capture-pack-shadow-boundary-routing-decision-v0.md
```

Safe status phrase from the gate:

```text
Context Capture Pack shadow-boundary work is authorized for descriptor/profile/
pack vocabulary research only. No parser, package, runtime, LLM, Ledger,
BiHistory, production, or external utility mutation is authorized.
```

## Sources Read

```text
igniter-lang/docs/gates/context-capture-pack-shadow-boundary-routing-decision-v0.md
igniter-lang/docs/tracks/contextizer-pressure-specimen-routing-v0.md
igniter-lang/docs/tracks/contextizer-lineup-bridge-analysis-v0.md
igniter-lang/docs/lineups/README.md
/Users/alex/dev/projects/contextizer/README.md
```

## Core Finding

The safe shape is not a package and not a language feature. It is a
descriptor/profile vocabulary map for a possible future capability boundary:

```text
capture source descriptors
  -> analysis/provider/renderer descriptors
  -> governance memory-card signals
  -> pressure-only snapshot/key-point shapes
  -> explicit escape/storage/evidence/drift boundaries
```

The boundary should be capability-owned, not file-owned:

```text
ContextCapturePack        -> source capture descriptors
ContextAnalysisProfile    -> analyzer/provider vocabulary
ContextRenderProfile      -> report/render vocabulary
LineUpMemoryProfile       -> governance memory-card fields
ContextSnapshotProfile    -> pressure-only snapshot/key-point shape
ContextQualityProfile     -> drift/quality/actualization pressure
LLMRefinementEscapeProfile -> explicit LLM escape pressure only
```

All labels above are candidate labels only.

## Shadow-Boundary Matrix

| Candidate boundary | Input signal | Descriptor-only responsibility | Explicitly out of scope |
| --- | --- | --- | --- |
| `ContextCapturePack` | Contextizer CLI local/remote project intake | Describe capture source, include/exclude policy, privacy/retention policy, evidence links | Package creation, filesystem crawling runtime, remote clone implementation |
| `ContextAnalysisProfile` | CLI Analyzer/Provider/Collector vocabulary | Describe provider/analyzer roles as external utility signals | Accepting CLI class names as Igniter-Lang canon |
| `ContextRenderProfile` | CLI Markdown report output | Describe renderer/report output intent | Renderer implementation, report generator package |
| `LineUpMemoryProfile` | Line Up memory-card workflow | Capture source path, disposition, status, next route, canon boundary | Changing Line Up ownership/workflow |
| `ContextSnapshotProfile` | DocumentContextizer pressure specimen | Preserve `ContextSnapshot` and `KeyPoint` as future shape pressure | Adding stdlib types, parser syntax, runtime snapshot storage |
| `ContextQualityProfile` | Drift/quality/actualization pressure | Name quality, drift, and actualization as future descriptors | Runtime drift detection, BiHistory/Ledger persistence |
| `LLMRefinementEscapeProfile` | CLI README LLM usage + specimen `LLMConnector` pressure | Keep LLM refinement as explicit escape-boundary pressure | LLMConnector implementation, hidden model calls |
| `SwarmPublicationProfile` | Specimen swarm publication pressure | Describe future publication target metadata | Production publication/runtime deployment |

## Capture Source Descriptors

Candidate descriptor shape, design-only:

```json
{
  "kind": "context_capture_source_descriptor",
  "version": "context-capture-source-shadow-v0",
  "source_ref": "source/local_project/igniter-lang",
  "source_kind": "local_project | public_git_repository | line_up_source | pressure_specimen",
  "capture_profile": "candidate/context-capture/default",
  "include_policy_ref": "policy/include/default",
  "exclude_policy_ref": "policy/exclude/default",
  "privacy_policy_ref": "policy/privacy/not-reviewed",
  "retention_policy_ref": "policy/retention/not-authorized",
  "evidence_links": [],
  "runtime_authority": "not_authorized"
}
```

Candidate source kinds:

| `source_kind` | Signal source | Meaning | Boundary |
| --- | --- | --- | --- |
| `local_project` | Contextizer CLI | Local project directory context | Descriptor only; no filesystem crawl implementation |
| `public_git_repository` | Contextizer CLI | Public remote repository context | Descriptor only; no clone/network behavior |
| `line_up_source` | Line Ups | Existing source doc behind a memory card | Governance descriptor only |
| `pressure_specimen` | DocumentContextizer specimen | Non-canonical future-product pressure | No parser/compiler authority |

## External Utility Vocabulary

The legacy Contextizer CLI contributes useful vocabulary, but not naming
authority.

| CLI vocabulary | Shadow interpretation | Status |
| --- | --- | --- |
| `Analyzer` | Detects project language/framework signals | external utility signal |
| `Provider` | Extracts metadata or source slices | external utility signal |
| `Collector` | Coordinates providers/analyzers into a context object | external utility signal |
| `Renderer` | Produces Markdown/report output | external utility signal |
| `Configuration` | Merges CLI/project/default config | external utility signal |
| `Markdown report` | Human-readable context artifact | external utility signal |
| `remote repository analysis` | Capture-source pressure for public repos | external utility signal; no network/runtime authority |

These names may inspire future descriptors, but no candidate pack or profile is
accepted by being named here.

## Line Up Governance Signal

Line Ups are active documentation memory cards, not context runtime.

Candidate memory-card fields:

```json
{
  "kind": "line_up_memory_card_signal",
  "source_path": "igniter-lang/docs/tracks/example.md",
  "summary": "compact source summary",
  "disposition": "active_reference",
  "status": "active memory card",
  "owner": "[Igniter-Lang Line Up Summarizer]",
  "canon_boundary": "not canon",
  "next_route": "track | proposal | archive | keep",
  "evidence_links": []
}
```

Governance value:

| Field | Why it matters |
| --- | --- |
| `source_path` | Keeps compact memory linked to exact evidence. |
| `summary` | Reduces context load without replacing the source. |
| `disposition` | Prevents zombie documents and unclear fate. |
| `status` | Marks whether the card is active, archive, or candidate movement. |
| `owner` | Keeps workflow authority with the owning role. |
| `canon_boundary` | Prevents summary text from becoming language authority. |
| `next_route` | Gives future agents a safe follow-up path. |
| `evidence_links` | Lets future context packs preserve traceability. |

## Pressure-Only Future Shapes

`ContextSnapshot` and `KeyPoint` remain pressure-only. They are not accepted
types.

Candidate pressure sketch:

```json
{
  "kind": "context_snapshot_pressure_shape",
  "snapshot_ref": "context-snapshot/<hash>",
  "source_refs": [],
  "captured_at": "explicit-input-required",
  "key_points": [
    {
      "kind": "key_point_pressure_shape",
      "claim": "short extracted point",
      "evidence_links": [],
      "confidence": "unknown | low | medium | high",
      "actualization_state": "current | drifted | unknown"
    }
  ],
  "quality": {
    "coverage": "unknown",
    "drift": "unknown",
    "privacy_review": "not_reviewed"
  }
}
```

This shape is useful because it separates:

```text
source capture
evidence selection
summary/key point claim
quality/drift status
actualization state
```

It does not authorize `ContextSnapshot` syntax, stdlib shape, storage, or
runtime evaluation.

## Boundary Risks

| Risk | Boundary rule |
| --- | --- |
| LLM escape | LLM refinement must be explicit ESCAPE pressure with approval/refusal/receipt shape. No hidden model calls. |
| Evidence links | Summaries and snapshots must link back to source evidence; compact cards cannot replace source authority. |
| Drift | Drift is a future descriptor/status concern, not automatic temporal execution or BiHistory binding. |
| Actualization | Actualization means a candidate re-capture/update route, not an authorized runtime update. |
| Ambient time | Capture time must be explicit input or future authorized capability. No ambient `now`. |
| Privacy/secrets | Include/exclude, privacy review, and retention policy are prerequisites before any implementation. |
| Remote intake | Public Git capture is external utility signal only; no network/clone behavior authorized. |
| Production claims | External "production-ready" or LLM-ready language is pressure only. |
| Ledger/BiHistory | Context history persistence needs its own proposal/gate; existing durable-audit authority cannot be borrowed. |
| External utility mutation | `/Users/alex/dev/projects/contextizer` is read-only evidence for this card. |

## Candidate Future Routes

These are candidate future routes only:

| Candidate route | Purpose | Still blocked by |
| --- | --- | --- |
| `context-capture-descriptor-proof-v0` | Validate descriptor fields for capture sources, policies, evidence links, and non-authorization flags | Separate proof card |
| `lineup-context-card-shape-extraction-v0` | Extract Line Up card fields into a non-canonical data-shape map | Line Up owner coordination |
| `contextizer-utility-inventory-v0` | Inventory CLI classes/config more deeply for bridge-safe vocabulary | Explicit inventory card; read-only external utility |
| `context-snapshot-shape-proposal-prep-v0` | Prepare minimum `ContextSnapshot` / `KeyPoint` proposal candidate | Compiler/Grammar ownership and proposal route |
| `llm-connector-escape-boundary-pressure-v0` | Define LLM escape/refusal/receipt pressure | Escape semantics authority; no connector implementation |
| `context-actualization-and-drift-semantics-v0` | Compare drift/actualization to explicit time/history without enabling BiHistory | Temporal/storage authority |
| `context-capture-compatibility-readiness-v0` | Model readiness false when descriptors are present but runtime is unauthorized | CompatibilityReport design/proof card |

## Non-Authorizations

This track does not authorize:

```text
code implementation
package creation
packages/igniter-contextizer
packages/igniter-document-contextizer
parser syntax
TypeChecker changes
SemanticIR changes
stdlib additions
ContextSnapshot as accepted type
KeyPoint as accepted type
runtime behavior
RuntimeMachine binding
LLMConnector implementation
LLM calls
Ledger binding
BiHistory binding
durable context history
production deployment
production readiness claims
changes to Line Up ownership/workflow
changes to /Users/alex/dev/projects/contextizer
compiling or registering igniter-document-contextizer.ig
```

## Handoff

```text
Card: S3-R41-C5-P2
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/context-capture-pack-shadow-boundary-v0
Status: done

[D] Decisions
- Mapped Context Capture Pack as descriptor/profile/pack vocabulary research only.
- Treated Contextizer CLI names as external utility signals, not naming authority.
- Treated Line Up fields as governance memory-card signals, not runtime data model.
- Kept ContextSnapshot/KeyPoint/evidence/drift/actualization as pressure-only future shapes.

[S] Shipped / Signals
- Added shadow-boundary matrix.
- Added capture source descriptor sketch.
- Added external utility vocabulary table.
- Added Line Up governance vocabulary table.
- Added risk boundaries for LLM escape, evidence links, drift, actualization, ambient time, privacy, Ledger/BiHistory, and production claims.

[T] Tests / Proofs
- Documentation-only track.
- No code, parser, runtime, package, LLM, Ledger/BiHistory, production, or external Contextizer mutation.

[R] Risks / Recommendations
- Do not let candidate pack/profile labels become acceptance by repetition.
- Future implementation must start with a descriptor proof and CompatibilityReport readiness-false proof before any package/runtime work.

[Next]
- Candidate next routes only: `context-capture-descriptor-proof-v0`, `context-snapshot-shape-proposal-prep-v0`, or `llm-connector-escape-boundary-pressure-v0`.
```

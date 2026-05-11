# History-S19: Evidence / Receipt Minimal Slice Map

Date: 2026-05-11  
Stage: History-S19  
Agent: [Igniter-Lang History Curator]  
Status: compact archive report; not canon; not a proposal  

## Compact Claim

Igniter-Lang now has three different evidence/receipt layers that must not be
collapsed into one:

1. **Source-level `output ... evidence [...]`** is parsed passively after
   PROP-032, but not validated. PROP-033 remains the named future boundary.
2. **Runtime observations / receipts** exist in proof-local and accepted runtime
   surfaces, especially temporal observations, registry receipts, tamper-evidence
   chains, and FFI/runtime receipt descriptors.
3. **Effect Surface receipts** from Agent-C/D research remain unrealized: no
   authority, failure, compensation, or production audit obligations are enforced
   just because a contract modifier says `effect`, `privileged`, or
   `irreversible`.

S19 preserves the value of evidence-first design while preventing the common
mistake: treating passive source evidence syntax, runtime proof artifacts, and
future effect receipts as one implemented system.

## Source Set

Current / canon-adjacent:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/gates/prop032-assumptions-experiment-pass-decision-v0.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`
- `igniter-lang/docs/tracks/prop032-assumptions-phase4-parser-proof-v0.md`
- `igniter-lang/lib/igniter_lang/parser.rb`
- `igniter-lang/lib/igniter_lang/classifier.rb`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`
- `igniter-lang/lib/igniter_lang/temporal_access_runtime.rb`
- `igniter-lang/lib/igniter_lang/temporal_executor.rb`

External pressure:

- `playgrounds/docs/external/Agent-C/PROP-External-Effects-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Contract-v0.md`
- external pressure specimens that use `output ... evidence [...]`

Prior compression:

- `igniter-lang/docs/archive/history/history-s18-external-effects-minimal-slice-map.md`

## Current Reality Map

| Signal | Current Category | Evidence | Curator Note |
| --- | --- | --- | --- |
| Parser accepts `output ... evidence [name, ...]` | implemented / passive | parser, PROP-032 phase 4, gate decision | Source syntax only; no validation. |
| Evidence list validation | closed / future PROP | PROP-032 gate exclusion | Explicitly deferred to PROP-033. |
| Assumptions carried by name | experiment-pass | PROP-032 gate decision | Named `assumption` + `uses assumptions NAME` is bounded compiler behavior. |
| `assumption_refs` in compiler artifacts | experiment-pass | PROP-032 gate decision | Semantic evidence-adjacent, but not runtime evidence. |
| OOF-A1 / OOF-P28 / TASSUMP-1 | experiment-pass | PROP-032 gate decision | Enforces assumption identity/shape, not evidence chain validity. |
| OOF-OS2 evidence-linked alert gate | implemented / legacy bounded | CSM, classifier | Narrow product-shaped guard, not general evidence validation. |
| Temporal access `evidence_links` | experiment-pass / proof-local | temporal access runtime | Links selected temporal observation to access evaluation. |
| Temporal live-read observation | proof-local / restricted | current-status, temporal executor | Runtime observation, not source evidence syntax. |
| Registry receipts / tamper-evidence | proof-local to restricted deployment | current-status runtime lane | Strong runtime audit line; separate from language-level evidence syntax. |
| Runtime receipt descriptor | implemented runtime artifact | CSM Receipt row | FFI/runtime receipt shape, not full Effect Surface. |
| Effect Surface receipt/failure/compensation | research_unrealized | Agent-C effects docs | Future accountability layer, likely PROP-035-family. |

## Three-Layer Separation

### 1. Source Evidence Syntax

`output ... evidence [...]` currently means:

- parser can preserve the list;
- source examples can round-trip;
- assumptions examples can express intended evidence links.

It does **not** mean:

- refs are typechecked;
- refs must exist;
- evidence graph is emitted in SemanticIR;
- runtime receipts are produced;
- missing evidence is a general OOF.

### 2. Runtime Observation / Receipt Artifacts

Runtime and temporal tracks already have real proof surfaces:

- `temporal_access_evaluation.evidence_links`;
- `temporal_live_read_observation`;
- proof-local observation persistence;
- registry transition receipts;
- tamper-evidence hash chains;
- FFI/runtime receipt descriptor anchors.

These are implemented/proven in their own lanes. They should be reused as design
evidence, but they do not automatically define source-language `evidence [...]`
semantics.

### 3. Effect Accountability Receipts

Agent-C/D research wants receipts to witness external consequences:

- effect contracts require receipts;
- privileged/irreversible contracts require authority and stronger audit;
- failure and compensation are part of the consequence contract.

That value is alive, but the compiler/runtime system does not enforce it yet.

## Minimal Future Slice Options

| Slice | Category | Recommended Route | Notes |
| --- | --- | --- | --- |
| PROP-033: validate `output evidence [...]` refs exist | proposal_candidate | Compiler/Grammar | Smallest source-level evidence win. |
| Emit validated evidence refs in SemanticIR outputs | proposal_candidate | Compiler/Grammar | Should follow or accompany ref validation. |
| Evidence refs to assumptions only | narrow_candidate | Compiler/Grammar | Could start with `uses assumptions` and named assumptions before general refs. |
| General evidence graph | research_to_proposal | Meta Expert first | Needs scope: nodes, outputs, temporal observations, assumptions, receipts. |
| Effect receipt type metadata | proposal_candidate after Effect Surface metadata | Compiler/Grammar + Meta | Should not depend on runtime execution first. |
| Runtime receipt propagation from effects | closed_later_stage | Runtime lane / Architect | Too broad for source syntax work. |
| Production audit receipt semantics | gated / runtime | Architect | Current runtime status has restricted deployment only; broad surfaces remain closed. |

## Recommended Slicing Order

1. **PROP-033A: Evidence Ref Existence**  
   Validate that names in `output ... evidence [...]` refer to known local symbols
   or declared assumptions. Do not yet model runtime receipts.

2. **PROP-033B: Evidence Ref Lowering**  
   Carry validated refs into typed output declarations and SemanticIR output
   ports as metadata.

3. **PROP-033C: Evidence Graph Diagnostics**  
   Add diagnostics for empty evidence on contracts/profiles that require it,
   only after a profile/effect policy exists.

4. **Effect Receipt Metadata**  
   Once Effect Surface metadata exists, add `receipt` and `failure` type
   references as compiler metadata.

5. **Runtime Receipt Execution**  
   Keep for runtime stage work. Do not attach it to the initial PROP-033 slice.

## Values Preserved

- Evidence is part of trust, not decoration.
- Receipts witness executed consequences, not merely declared intentions.
- Passive syntax is useful, but it is not enforcement.
- Runtime proof artifacts are strong evidence, but they do not silently define
  language semantics.
- Assumptions must be named before they can be cited.
- Future effect receipts should inherit existing runtime observation discipline
  rather than inventing a parallel audit world.

## Superseded / Do-Not-Repeat

Do not re-open as unresolved:

- "Can `output evidence [...]` appear in source?" — it can be parsed passively.
- "Are assumptions named and referencable?" — PROP-032 experiment-pass covers
  the bounded compiler surface.
- "Do runtime receipts exist anywhere?" — yes, but in runtime/proof-local lanes.

Do not claim as resolved:

- evidence list validation;
- evidence refs in SemanticIR outputs as trusted graph;
- general missing-evidence OOFs;
- runtime receipt propagation from source evidence;
- Effect Surface receipt/failure/compensation enforcement;
- production audit semantics for arbitrary effects.

## Rotation / Read Recommendations

Hot for evidence-slice planning:

- `PROP-032-assumptions-block-v0.md`
- `prop032-assumptions-experiment-pass-decision-v0.md`
- `prop032-assumptions-phase4-parser-proof-v0.md`
- CSM rows for Receipt, Assumption, OOF-OS2
- this S19 report

Warm:

- `PROP-External-Effects-v0.md`
- `PROP-Contract-v0.md`
- temporal observation/runtime tracks referenced from current-status
- external pressure specimens using `output ... evidence [...]`

Skip by default:

- raw external interviews;
- full runtime durable-audit tracks unless the next task touches runtime receipts;
- full OSINT product pressure corpus unless extracting evidence graph examples.

## Stage-Close Handoff

Compact claim:

- Evidence/receipt work has split into passive source syntax, bounded assumption
  compiler behavior, runtime/proof-local observations, and future effect
  accountability. The next source-language slice should likely be PROP-033
  evidence-ref validation, not runtime receipts.

Source set:

- current status/context, PROP-032, PROP-032 gate decision, CSM, compiler code,
  temporal runtime code, Agent-C effects/contract research, S18.

Categories applied:

- `implemented`
- `implemented_passive`
- `experiment-pass`
- `proof-local`
- `proposal_candidate`
- `research_to_proposal`
- `research_unrealized`
- `closed_later_stage`
- `do_not_repeat`

Values preserved:

- evidence as trust support;
- receipts as witnesses;
- named assumptions before citation;
- runtime observations as proof discipline;
- source validation before runtime claims.

Accepted / implemented signals:

- passive parser support for `output evidence [...]`;
- PROP-032 assumption registry / refs / epistemic classification;
- OOF-A1, OOF-P28, TASSUMP-1;
- narrow OOF-OS2 evidence-linked alert guard;
- temporal access evidence links;
- runtime receipt descriptor anchor.

Superseded / rejected signals:

- treating passive evidence syntax as full validation;
- treating runtime receipts as source evidence semantics;
- attaching Effect Surface receipt enforcement to PROP-031 modifiers.

Research still alive:

- PROP-033 evidence ref validation;
- SemanticIR evidence-ref lowering;
- effect receipt/failure metadata;
- production audit receipt semantics;
- cross-module evidence graph.

Duplicate / rotation recommendations:

- Future agents should start from S19 before reading full evidence/effect
  corpora.
- Use runtime tracks for proof discipline, not as direct language spec.

Unresolved questions:

- Should PROP-033 validate only local symbol refs first, or also assumption refs?
- Should empty `evidence []` be allowed for pure outputs?
- Should evidence refs live on output ports, output nodes, or a separate graph?
- When Effect Surface lands, should `receipt` be an output type, an effect field,
  or both?

Changed files:

- `igniter-lang/docs/archive/history/history-s19-evidence-receipt-minimal-slice-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- **History-S20: Assumptions / Epistemic Surface Compression Map** — compress
  PROP-032, assumptions pressure, Covenant P28, and external evidence examples
  into a compact map for future epistemic language work.

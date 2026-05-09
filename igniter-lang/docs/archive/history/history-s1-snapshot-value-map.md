# History-S1 Snapshot Value Map

Status: archived history report
Date: 2026-05-09
Agent: [Igniter-Lang History Curator]
Role: history-curator
Stage: History-S1
Source posture: archive compression only; no canon/spec/current-status edits

## Compact Claim

The archived snapshots show one clear transition:

```text
research cloud
  -> language model crystallization
  -> proof-local compiler/runtime spine
  -> Stage 3 value-hoisting and gate discipline
```

Future agents should not reread the whole archive by default. They should read
current context first, then this report, then the specific snapshot README or
origin report only when they need evidence.

The durable memory is:

- Arbor and Ruby Igniter provided the graph/contract instinct.
- Expert research provided temporal, OLAP, stream, invariant, and distributed
  pressure.
- Igniter-Lang accepted only the parts that passed through parser, classifier,
  type checker, SemanticIR, assembler, RuntimeMachine, docs, and close evidence.
- The remaining research is valuable, but it must stay out of canon until a
  proposal, owner, and verification path exist.

## Source Set

Primary current orientation:

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/history-curator.md`
- `igniter-lang/roles/archive-form-expert.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/operating-model.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/archive/history/origins-arbor-to-igniter-lang.md`

Archive snapshots:

- `igniter-lang/docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/`
- `igniter-lang/docs/archive/snapshots/2026-05-06-stage1-close/`
- `igniter-lang/docs/archive/snapshots/2026-05-07-stage2-close/`
- `igniter-lang/docs/archive/snapshots/2026-05-08-stage3-r7-docs-snapshot/`

Playgrounds research sample:

- `playgrounds/docs/experts/igniter-lang/README.md`
- `playgrounds/docs/experts/igniter-lang/*`
- `playgrounds/docs/experts/igniter-plane.md`
- `playgrounds/docs/experts/plastic-runtime-cells.md`
- `playgrounds/docs/research-horizon/README.md`
- `playgrounds/docs/research-horizon/current-state-report.md`
- `playgrounds/docs/research-horizon/horizon-proposals.md`

This stage did not exhaustively read all `playgrounds/docs/` files. It used
directory inventory plus representative frontier/research documents because the
area is large and explicitly marked as research.

## Snapshot Timeline

| Source | Size signal | What changed | How to read it now |
| --- | ---: | --- | --- |
| `2026-05-06-stage1-pre-crystallization` | 131 files | Broad research cloud before active docs were compressed; META-EXPERT-005 and 006 surfaced buried ideas and revised the language model. | Deep cold origin evidence. Read README plus META-005/006, not the whole tree. |
| `2026-05-06-stage1-close` | 56 files | Working Stage 1 surface; Stage 2 proposal set existed but was not yet implemented. | Stage 1 transition evidence. Mostly superseded by Stage 2 close plus current docs. |
| `2026-05-07-stage2-close` | 39 files | Closed proof-local spine: parser, classifier, type checker, SemanticIR, assembler, RuntimeMachine, History/BiHistory, stream, OLAPPoint, invariants, TBackend descriptor. | Best compact evidence for Stage 2. Keep close until its signals are fully indexed. |
| `2026-05-08-stage3-r7-docs-snapshot` | 339 files | Safety copy after Stage 3 Round 7 and before value-hoisting/compaction wave; duplicates active docs, roles, discussions, proposals, reviews, spec, tracks. | Cold fallback only. Do not use as default context. |
| `origins-arbor-to-igniter-lang.md` | 1 report | External Arbor/Agentor origin line was compressed into Igniter-Lang memory. | Read for lineage from Arbor/Ruby Igniter into current language architecture. |

## Classification Table

| Signal | Category | Current reading |
| --- | --- | --- |
| Validated dependency graph / contract graph | accepted_canon, implemented | Root invariant across Arbor, Ruby Igniter, and Igniter-Lang. Current form is compiler/runtime graph, not old Arbor syntax. |
| Arbor `Map -> Route -> Terrain` | superseded_history, value | Preserved as DSL/CompiledGraph/RuntimeMachine intuition. Do not restore Arbor names as canon. |
| Ruby Igniter `Contract -> CompiledGraph -> Execution` | accepted_canon, implemented | Practical ancestor and still the Ruby framework line. Igniter-Lang formalizes it as language artifact pipeline. |
| Five formal identities: TFS, attribute grammars, CCP, stratified Datalog, category theory | accepted_canon, value | Durable theory layer. Use as design lens, not as license to expand syntax without implementation. |
| CORE / ESCAPE / OOF | accepted_canon, implemented | The main trust boundary. CORE is bounded/deterministic, ESCAPE is capability-gated, OOF is refused. |
| `Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler` | accepted_canon, implemented | Current production compiler path. Any historical path that bypasses it is obsolete. |
| SemanticIR, CompilationReport, `.igapp` | accepted_canon, implemented | Current artifact boundary. History should point here, not to broad runtime narratives. |
| RuntimeMachine load/evaluate/checkpoint/resume | accepted_canon, implemented | Proof-local runtime spine. TEMPORAL load is inspectable; evaluate is refused without allowed contract path. |
| History/BiHistory | accepted_canon, implemented | Stage 2 accepted and proof-local. Production TBackend binding remains deferred. |
| `stream T` / bounded stream folding | accepted_canon, implemented | Accepted as syntax/type/lowering surface. Full production stream execution remains future work. |
| OLAPPoint | accepted_canon, implemented | Accepted at parser/type/SemanticIR/proof level. Distributed OLAP execution remains research. |
| Invariant severity | accepted_canon, implemented | Accepted and lowered. Persistence and deferred OOF invariant storage remain future work. |
| TBackend descriptor | accepted_canon, implemented | Metadata-only proof. It is not physical serving or distributed execution proof. |
| Gate 2 vs Gate 3 split | accepted_canon, implemented | Gate 2 metadata/load proof is separate from Gate 3 live execution. This must remain explicit. |
| CompatibilityReport report-only posture | accepted_canon, implemented | Reports before execution. No hidden enforcement or live binding before gates. |
| ExecutorApprovalToken | accepted_canon, implemented, parked | Implemented as proof/report enforcement signal. Real auth, policy, and live executor binding remain Gate 3 concerns. |
| `entrypoint` / `section` surface | parked, research_unrealized | Proposal-only. `entrypoint` is an evaluation/run profile concept; `section` is grouping-only until accepted. |
| Old Arbor `entry_point` accepts/returns semantics | superseded_history, rejected | Useful ancestor, but should not return as source-level canon. |
| Nexus VM / Arbor runtime kernel | superseded_history, rejected | Replaced by compiled artifact plus RuntimeMachine discipline. |
| Agentor loop and broad autonomous runtime | superseded_history, parked | Preserved as agent proposal/review value. Not accepted as hidden runtime behavior. |
| AgentProposal, confidence, salience, proposal contracts | value, research_unrealized | Strong bridge to future human-agent review and planner tracks. Needs explicit proposal before canon. |
| Unit types / dimensional analysis | research_unrealized, value | High-value safety idea. Not current canon despite old Stage 2 priority language. |
| Deadline / WCET contracts | research_unrealized, value | Important for robotics, space, embedded, medical. Needs backend and verification model. |
| Uplink-able serializable rules | research_unrealized, value | Valuable for device/space/industrial domains. Needs restricted evaluator and safety proof. |
| Rule dependency graph / causal cycle detection | research_unrealized, value | Strong temporal/rule-system idea. Not implemented. |
| Temporal synthesis / goal-directed rule generation | research_unrealized, value | Future LP/Datalog-style synthesis lane. Keep out of near-term canon. |
| Probabilistic lift `~T` and approximate precomputation | research_unrealized, parked, value | Durable design pressure for uncertainty and decision-directed evaluation. Not accepted syntax. |
| Plastic Runtime Cells | research_unrealized, parked, value | Good distributed substrate concept. Current status: research synthesis over capsules/contracts/cluster/web. |
| Runtime Observatory Graph | research_unrealized, value | Strong read-only observation model. Good candidate before Igniter Plane. |
| Igniter Plane graph canvas | research_unrealized, parked, value | Valuable interaction metaphor over observatory graph. Too large for canon without read-only substrate. |
| Capability market / game-theoretic routing | research_unrealized, parked | Interesting cluster diagnostics lane. Risk of overbuilding; keep research-only. |
| Constraint-aware agent planner | research_unrealized, value | Good future AI/agent interface: AI proposes moves on a structured board, not hidden architecture. |
| OSINT fractal traceability | value | Preserves claim/evidence/confidence discipline. Productization remains separate. |
| Spark CRM / applied pressure | value | Useful reality test for semantic density and applied ergonomics. Keep as pressure, not universal product direction. |

## Accepted And Implemented Signals

These origin/research signals are already in current Igniter-Lang memory:

- The graph is the semantic object.
- Compiler stages are explicit and evidence-bearing.
- Fragment classification is part of trust, not presentation.
- Time is a semantic dimension, not ambient wall-clock convenience.
- RuntimeMachine is a semantic evaluator over `.igapp`, not a general VM.
- History/BiHistory, stream, OLAPPoint, and invariant severity crossed from
  buried research into Stage 2 proof-local implementation.
- TBackend exists as descriptor metadata, not as live persistence/serving.
- Compatibility and executor approval are report/evidence layers before live
  execution.
- Stage context should be compact; archives exist for evidence, not daily work.

## Values Preserved

Preserve these even when the old documents rotate deeper:

- **Map, not whole archive**: agents need current context plus compact history,
  not every old document.
- **History is evidence, not canon**: old docs explain why; current spec/status
  define what is true now.
- **Contracts are promises with observations**: execution results should carry
  provenance, diagnostics, and time context.
- **Explicit time**: no ambient temporal truth; time must be declared, loaded,
  or refused.
- **Confidence is not truth**: proposal/confidence/salience are review signals,
  not automatic authority.
- **Report before execution**: read-only/report-only layers reduce accidental
  runtime commitments.
- **Gate discipline**: metadata load, compatibility, execution, auth, and
  persistence are separate proof obligations.
- **Syntax must not outrun parser truth**: research syntax is pressure until
  parser/type/SemanticIR/assembler evidence exists.
- **Semantic density needs ergonomics**: compact language is valuable only if
  agents and humans can read, verify, and operate it.
- **Reality pressure matters**: Spark CRM, OSINT, robotics, medicine, space, and
  IoT examples are useful stress tests when scoped as evidence.

## Superseded Or Rejected Signals

Do not revive these as canon without a new proposal and explicit acceptance:

- Arbor DSL surface as language canon.
- Arbor `entry_point` accepts/returns semantics.
- Nexus VM as runtime architecture.
- Hidden global runtime loops from Agentor-style autonomy.
- Broad `playgrounds/docs` research as default context.
- Source syntax for `entrypoint`, `section`, units, deadlines, `time_machine`,
  rules, probabilistic values, or cells before accepted parser/type evidence.
- Production TBackend binding implied from descriptor metadata.
- Distributed OLAP or stream execution implied from Stage 2 syntax proof.
- TEMPORAL cache keys that ignore time.
- Gate 3 execution implied by Gate 2 compatibility/load evidence.

## Research Still Alive

The strongest future tracks are:

| Research idea | Why alive | Suggested owner lane |
| --- | --- | --- |
| Production TBackend adapter binding | Closes the gap between temporal metadata and real persistence. | Gate 3 / runtime proposal |
| Distributed OLAP execution | Completes OLAPPoint beyond local metadata/proof. | Runtime/distributed proposal |
| Invariant persistence and deferred OOFs | Turns invariant checks into durable audit/reporting. | Compiler/runtime diagnostics |
| Unit types and dimensional analysis | High safety value for scientific/robotic/medical domains. | Type system proposal |
| Deadline/WCET contracts | Makes DAG timing certifiable. Needs backend model. | Backend/verifier research |
| Uplink-able serializable rules | Enables safe rule updates without code deployment. | Rule system proposal |
| Rule dependency graph and causal cycle detection | Important for temporal rules and corrections. | Temporal/rule research |
| Temporal synthesis | Connects goals to rule generation. Needs LP/Datalog boundary. | Long-range research |
| Probabilistic values and approximate precomputation | Captures uncertainty and decision-directed exactness. | Research horizon |
| Runtime Observatory Graph | Read-only unified operational graph. Best prerequisite for visual plane. | Research horizon -> dev track candidate |
| Igniter Plane | Strong UI/operation metaphor once observation graph exists. | Interaction/observability research |
| Plastic Runtime Cells | Good composition of capsules, contracts, policy, cluster, and surfaces. | Capsule/cluster research |
| Agent proposal/planner layer | Lets AI propose inspectable moves under constraints. | Future agents/interaction kernel |

## Rotation Recommendations

No files should be moved or deleted in this stage. These are recommendations
for a future approved rotation pass.

| Area | Recommendation | Reason |
| --- | --- | --- |
| `2026-05-06-stage1-pre-crystallization/` | Keep as deep cold source. Later rotate bulk outside active repo after META-005/006 and snapshot README are linked from history index. | It is valuable archaeology but too broad for normal agent context. |
| `2026-05-06-stage1-close/` | Mark as Stage 1 transition evidence. It can rotate deeper after Stage 1/2 maps are stable. | Much of its working context is superseded by Stage 2 close and current status. |
| `2026-05-07-stage2-close/` | Keep local for now. | It is the most compact close evidence for implemented Stage 2 signals. |
| `2026-05-08-stage3-r7-docs-snapshot/` | Candidate for external cold storage after a Stage 3 close snapshot exists. | It is large, duplicates active docs, and was explicitly created before value compaction. |
| `playgrounds/docs/experts/igniter-lang/` | Keep as theory archive, but read via README/frontier plus history reports. | Strong research foundation, not active implementation context. |
| `playgrounds/docs/research-horizon/` | Keep as research lane, not canon. | It already has supervisor-gate language and proposal discipline. |
| Broad `playgrounds/docs/` | Plan a separate History-S2 inventory before rotation. | It contains many independent legacy/research/product docs and should not be bulk-classified from this pass alone. |

## Future Agent Read/Skip Rule

Default read path:

1. `igniter-lang/docs/agent-context.md`
2. `igniter-lang/docs/current-status.md`
3. `igniter-lang/docs/value-index.md`
4. `igniter-lang/docs/archive/history/origins-arbor-to-igniter-lang.md`
5. `igniter-lang/docs/archive/history/history-s1-snapshot-value-map.md`
6. Snapshot README only when exact historical evidence is needed.

Default skip path:

- Full snapshot trees.
- Full Stage 3 Round 7 copied docs/roles/tracks.
- Pre-crystallization proposal folders unless named by a current task.
- Broad `playgrounds/docs/` corpus unless the stage explicitly targets it.

## Next Stage Recommendation

Recommended next stage:

```text
History-S2: playgrounds/docs inventory and rotation plan
```

Goal:

- Produce a compact map of `playgrounds/docs/`.
- Separate product/current docs, expert reports, research horizon, guide drafts,
  reviews, and legacy/dev material.
- Identify which documents have already been absorbed into current Igniter,
  Igniter-Lang, value-index, or archive/history.
- Prepare a one-time rotation proposal with exact paths and rationale, but do
  not move/delete anything until approved.

## Stage-Close Handoff

Compact claim:

- History-S1 compressed snapshot and playground research signals into a durable
  value/history map. The accepted implementation spine is Stage 2 plus current
  Stage 3 gate discipline. The remaining material is research/value, not canon.

Source set:

- `igniter-lang/docs/archive/snapshots/`
- `igniter-lang/docs/archive/history/`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/operating-model.md`
- `playgrounds/docs/experts/igniter-lang/`
- representative `playgrounds/docs/experts/` and `playgrounds/docs/research-horizon/`

Categories applied:

- `accepted_canon`
- `implemented`
- `superseded_history`
- `research_unrealized`
- `rejected`
- `parked`
- `value`

Values preserved:

- compact context over archive bulk
- history as evidence
- explicit time
- report before execution
- gate separation
- syntax/evidence discipline
- confidence separate from truth
- applied pressure as stress test

Accepted/implemented signals:

- graph/contract core
- compiler pipeline
- CORE/ESCAPE/OOF
- SemanticIR and `.igapp`
- RuntimeMachine proof-local lifecycle
- History/BiHistory
- stream T
- OLAPPoint
- invariant severity
- TBackend descriptor metadata
- CompatibilityReport and ExecutorApprovalToken report/enforcement boundary

Superseded/rejected signals:

- Arbor syntax and `entry_point`
- Nexus VM
- hidden Agentor autonomy
- broad archive as working context
- Gate 3 execution inferred from Gate 2 metadata
- production persistence inferred from descriptor metadata

Research still alive:

- production TBackend binding
- distributed OLAP
- invariant persistence/deferred OOFs
- units
- deadlines/WCET
- serializable rules
- rule causal cycles
- temporal synthesis
- probabilistic values
- observatory graph
- Igniter Plane
- Plastic Runtime Cells
- agent proposal/planner layer

Duplicate/rotation recommendations:

- keep Stage 2 close local for now
- rotate Stage 1/pre-crystallization bulk only after index links are stable
- treat Stage 3 R7 snapshot as future external cold-storage candidate
- run separate History-S2 for `playgrounds/docs/`

Unresolved questions:

- Should `docs/value-index.md` later receive a compact pointer to this report?
  It was not edited in this stage because it is a hot context file.
- Should `playgrounds/docs/experts/igniter-lang/` remain in repo or move to a
  separate research archive after current value extraction?
- Which research lane should be promoted first after Stage 3: Runtime
  Observatory Graph, production TBackend binding, or unit types?

Changed files:

- `igniter-lang/docs/archive/history/history-s1-snapshot-value-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- `History-S2: playgrounds/docs inventory and rotation plan`

# Track: Observable Contract Language v0

Status: proposal
Slice state: done on 2026-05-05

## Frame

Research the first possible Igniter-Lang axiom:

```text
Everything observable.
Everything contract.
```

This is not a syntax design track. It is a semantics and product-language track.

## Source Horizon

Read-only sources used:

- `/docs/guide/igniter-lang-foundation.md`
- `/docs/research/igniter-lang-convergence-report.md`
- `/docs/research/project-status-horizon-report.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-algebra.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-theory2.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-persistence.md`
- `/playgrounds/docs/experts/igniter-lang/igniter-lang-temporal.md`

## Compact Claim

[D] Igniter-Lang should treat every language-level thing that can influence,
produce, block, explain, persist, or materialize a result as an observable
contract boundary.

"Everything observable" does not mean "log everything." It means there is no
silent semantic authority above the platform axiom layer. If a result changes,
the language must be able to point at an observable cause: input, rule, type,
constraint, time context, store fact, agent action, materializer receipt,
capability decision, or axiom/platform version.

"Everything contract" does not mean every primitive becomes user-written
business logic. It means values, effects, stores, agents, commands,
materializers, and failures participate in one contract algebra when they cross
a language boundary. They have typed shape, declared dependencies, constraints,
provenance, and inspection surfaces.

This makes Igniter-Lang a semantic research ecosystem, not a new skin over the
current Ruby DSL. The current platform proves useful pressure; the language
track decides which semantics deserve first-class status.

## Proposed Laws

1. **Result-orientation law.** Observable meaning is rooted in declared outputs.
   Compilation, explanation, and pruning run backward from what the contract
   promises to produce.

2. **Contract boundary law.** Anything crossing a language boundary must expose
   a contract descriptor: inputs, outputs or effects, constraints, provenance,
   and failure shape.

3. **Closed graph law.** The default core is a finite, stratified dependency
   graph. Recursion, streaming, probability, and open-world interaction are
   explicit extensions with visible cost and semantics.

4. **Uniform constraint law.** Types, guards, invariants, deadlines, cache
   policy, temporal consistency, capability checks, and store consistency are
   all constraints over the same graph, not separate side systems.

5. **Observation conservation law.** A changed result must be explainable by at
   least one changed observable: input value, fact, rule version, `as_of`,
   capability, materializer receipt, agent evidence, or axiom/platform version.

6. **Temporal explicitness law.** Time is never ambient. A temporal read has an
   `as_of` semantics supplied by the caller, execution context, or store
   consistency model, and that source is observable.

7. **Materialization law.** A materialized artifact is the output of a contract
   with source facts, parity checks, capability boundary, and receipt. It is not
   live runtime magic or an untracked build script.

8. **Agent participation law.** An agent is not a privileged meta-layer. Agent
   proposals, tool calls, decisions, and effects are contract participants with
   declared capabilities, evidence, and receipts.

9. **Thin axiom law.** The axiom layer should be small, typed, versioned, and
   inspectable at its boundary. Domain vocabulary should rise into library
   contracts before it becomes platform magic.

10. **Decidability-first law.** The default language fragment should stay in a
    Horn/stratified, finite-domain, closed-world discipline where termination,
    confluence, and useful completeness are plausible. Escapes are allowed only
    as explicit research extensions.

## What Is Observable

[D] Observable means "semantically inspectable by the language," not
"physically logged at maximum detail."

Observable surfaces:

- declared inputs, outputs, dependencies, types, refinements, and descriptors
- guards, invariants, policies, deadlines, cache rules, and consistency claims
- temporal context: `as_of`, causal clock, rule version, history segment, lag SLA
- store shape: `Store[T]`, `History[T]`, access path, partition, retention,
  compaction, replay, and receipt semantics
- effect intent and effect receipt, including idempotency and capability token
- materializer plan, source horizon, parity check, write boundary, and receipt
- agent run, prompt/model/tool boundary, evidence, confidence when declared,
  proposed patch/action, and resulting receipt
- failure as structured unsatisfied contract: which constraint failed, at which
  path, under which inputs/time/platform versions
- compiler and verifier findings, including rejected out-of-fragment constructs
- axiom/platform descriptor version when an opaque primitive affected meaning

Not every implementation detail is observable. Host call stacks, heap layout,
transport retries, database query plans, and scheduler details stay platform
noise unless they cross a semantic boundary through a descriptor, receipt, or
diagnostic.

## What Is Contract

[D] A contract is any typed, inspectable relation from required observations to
promised observations or effects, with declared constraints and failure shape.

Under that definition:

- **Types** are recognition contracts: they decide whether a value inhabits a
  shape and which refinements follow.
- **Values** are observations carried by contracts. A named constant or stored
  fact can be treated as a nullary contract once it participates in a graph.
- **Computations** are ordinary dependency contracts.
- **Effects** are contracts whose output is a receipt plus an external delta.
- **Stores** are contracts over durable shape, access path, consistency,
  retention, compaction, and replay, not just database handles.
- **Commands** are contracts from intent to validated plan and effect receipt.
- **Materializers** are contracts from source facts/specs to static artifacts
  plus evidence.
- **Agents** are contracts around proposal, reasoning evidence, tool capability,
  and action receipt.
- **Failures** are contract outputs in the diagnostic plane: an unsatisfied
  constraint with path, context, and remediation hint.

## What Remains Axiom Or Platform

[D] The axiom/platform layer is allowed to be opaque internally, but never
nameless at the boundary.

Likely axioms:

- arithmetic, comparison, boolean logic, structural equality, ordering
- serialization, hashing, parsing, encoding, and cryptographic primitives
- host IO, network transport, clock source, randomness, filesystem access
- scheduler, process runtime, memory, thread/worker execution mechanics
- storage physics: WAL, segment sealing, consensus, replication, compaction
- LLM/provider inference mechanics behind an agent boundary
- trusted capability executor that turns approved receipts into side effects

The research target is a thin and organic axiom layer:

```text
SYSTEM contracts  -> user vocabulary
LIBRARY contracts -> reusable domain vocabulary
AXIOM contracts   -> typed primitives
PLATFORM          -> host/runtime physics
```

The user should not write platform logic. Agents and humans should still be able
to inspect which axiom/platform version a result depended on.

## Agent And Human Benefit

[S] Agents benefit because the language gives them semantic handles instead of
opaque code regions:

- subscribe to access paths, descriptors, and invalidation facts rather than
  polling endpoints
- propose contracts, materializers, or bridge notes as reviewable artifacts
- explain a result through typed provenance instead of source-code guessing
- detect forbidden moves from capability boundaries and write scopes
- rerun a contract `as_of` a prior time for debugging, simulation, or review

[S] Humans benefit because the same surfaces make systems easier to trust:

- a failure is a traceable unmet contract, not an incidental exception
- time-travel and counterfactual review become ordinary product operations
- materialized code carries source/parity/receipt evidence
- agent work becomes auditable as proposals and receipts
- the language can remain compact without hiding the reasons behind behavior

## Risks And Rejected Paths

[X] Parser-first language design. Syntax should follow repeated semantic
pressure, not lead it.

[X] Treating "observable" as maximal logging. That leaks host noise and creates
data risk without improving semantics.

[X] Thick service axioms. If whole services are opaque axioms, contracts degrade
into glue and lose explainability.

[X] Hidden agent privilege. Agents should not bypass capability, provenance, or
materialization rules because they are "smart."

[X] Live dynamic materialization. Materializers should print/check/receipt
static artifacts; they should not become an unreviewed runtime evaluator.

[X] Full first-order/probabilistic/open-world semantics as the default.
Powerful extensions remain research tracks; the core should stay decidable and
boring enough to trust.

[X] Collapsing Igniter-Lang into the current Ruby platform. Ruby evidence is a
source horizon, not the language boundary.

## Bridge Candidates

[R] Do not bridge this slice directly into packages. First convert any bridge
candidate into an explicit `igniter-lang/docs/bridge/...` proposal.

Candidate bridge notes:

- **Observation packet vocabulary.** Map descriptors, facts, receipts,
  provenance, `as_of`, capabilities, failures, and diagnostics into a minimal
  shared packet model.
- **Structured failure contract.** Treat platform diagnostics as first-class
  unsatisfied-contract observations with path, context, and remediation.
- **Materializer receipt contract.** Align materializer dry-run evidence with
  source horizon, parity checks, write boundary, and capability receipt.

## Next Slice Recommendation

[R] Next slice: `observable-spine-v0`.

Purpose: define the smallest observation packet model that can carry this
track's laws without committing to grammar or runtime. It should answer:

- What is the identity of an observation?
- How do observations link to contract nodes, time, store facts, effects,
  agents, and materializers?
- Which fields are required for humans, agents, compilers, and runtimes?
- What must stay out of the packet to avoid host-language noise?
- Which packet shapes could later become explicit bridge proposals?

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/observable-contract-language-v0
Status: done

[D] Decisions:
- The first axiom is not "log everything"; it is "no silent semantic authority
  above the named axiom/platform boundary."
- Values, effects, stores, commands, materializers, agents, and failures become
  contracts when they cross a typed observable language boundary.
- The default core should remain finite, stratified, and decidability-first.

[R] Recommendations:
- Run `observable-spine-v0` next to define the minimal observation packet model.
- Keep bridge candidates as explicit bridge docs, not package edits.
- Preserve a thin, typed, versioned axiom layer and push domain vocabulary into
  library contracts.

[S] Signals:
- Current Igniter pressure around descriptors, facts, receipts, diagnostics,
  materializers, `as_of`, and reactive invalidation strongly supports this
  direction.
- The archived theory track supports a Horn/stratified default fragment and an
  explicit escape model for recursion, probability, and open-world behavior.

[Q] Open Questions:
- What is the minimal observation identity and packet shape?
- How much agent evidence is enough for audit without capturing unsafe prompt
  or user data?
- Which axiom/platform descriptors are required for reproducibility?

[X] Rejected:
- Parser-first `.il` design.
- Maximal logging as observability.
- Thick service axioms.
- Hidden agent privilege.
- Live dynamic materialization.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/observable-spine-v0.md`
```

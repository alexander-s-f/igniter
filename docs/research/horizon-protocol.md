# Horizon Protocol

Status: active research protocol. Not a stable API, package plan, or release
promise.

Mission: take one step beyond the horizon while preserving the ability to build
Igniter Lang, distributed contracts, agent-native interfaces, and compact human
tools without turning research energy into accidental runtime commitments.

## Axioms

- The contract graph is the kernel. Grammar, UI, agents, storage, and cluster
  behavior must lower to explicit graph semantics or a clearly owned layer above
  it.
- Ruby DSL is the reference implementation for Lang. A standalone grammar waits
  for stable DSL signals from real applications.
- Metadata precedes enforcement. The ladder is: declare -> report -> warn ->
  reject/execute.
- Type descriptors imply capability requirements. `Store[T]`, `History[T]`,
  `BiHistory[T]`, `OLAPPoint[T,dims]`, and `Forecast[T]` should feed manifests
  before they become schedulers, adapters, or parsers.
- Package ownership beats conceptual elegance. If an idea cannot name its owner,
  it stays research.
- Human sugar and agent-clean forms must stay equivalent. Every compact DSL form
  needs an explicit object/configuration representation.
- Interaction and handoff require policy, evidence, and receipt. Do not turn an
  affordance into autonomous execution by implication.
- Public docs are cache; private research is archive. Promote only compressed,
  current decisions.

## Planning Loop

Use four planning horizons:

- Horizon: years; preserves optionality and names non-negotiable invariants.
- Track: weeks; package or doctrine direction with ownership and acceptance.
- Slice: one to three days; narrow proof with tests or review artifact.
- Patch: hours; code or document delta with verification.

Every active slice should fit this frame:

```text
Aim:
Boundary:
Current evidence:
Smallest move:
Lang impact: opens | preserves | narrows | closes
Reversibility:
Verification:
Next owner:
```

`Lang impact: closes` requires explicit architect acceptance.

## Architect Frame

The architect reviews every serious proposal through nine lenses:

- Semantics: what meaning enters the contract graph?
- Types: what can be declared, inferred, checked, or lowered?
- Time: is this point state, history, bitemporal state, forecast, or deadline?
- Data: who owns durable shape, query shape, lineage, and materialization?
- Agency: who acts, under what policy, with what trace and receipt?
- Distribution: what is local, placed, routed, replicated, or eventually merged?
- Interface: what is human-facing sugar, agent-facing structure, or transport?
- Game theory: what incentives or failure modes appear when actors optimize?
- Constraints: what bottleneck, invariant, or irreversibility dominates?

Architect output should be terse:

```text
[D] Decision:
[R] Rule:
[S] Current status:
[H] Cold history pointer:
Risk:
Next slice:
```

## Agent Roles

Architect:

- owns invariants, package placement, and future-option preservation
- accepts, narrows, rejects, or defers proposals
- names what must remain report-only

Researcher:

- explores private and public context
- returns compressed claims, assumptions, deltas, and non-goals
- does not create runtime code or public APIs from research-only material

Implementer:

- changes the smallest owned surface
- keeps app-local pressure app-local until repeated proof exists
- includes tests, examples, or smoke evidence
- reports changed files and verification

Reviewer:

- checks boundary leaks, future-option loss, weak legacy preservation, missing
  tests, and documentation inflation
- treats `igniter-lang` compatibility as an architectural invariant

Product Pressure Agent:

- uses Companion and examples to discover real friction
- may add narrow app-local sugar
- records repeated pressure before asking for package promotion

## Igniter Lang Decision Filter

Green moves:

- add immutable descriptors, manifests, reports, or read-only diagnostics
- make backend seams more explicit without changing runtime behavior
- keep new semantics representable as explicit objects before sugar
- lower `persist`-style ergonomics toward `Store[T]` or `History[T]`
- add tests that prove existing execution remains unchanged

Yellow moves:

- add a DSL keyword before two real examples need it
- enforce a field that was previously report-only
- introduce storage behavior without a requirements manifest
- add agent memory, handoff, tools, or gates without policy and receipts
- make web/application surfaces inspect or execute each other's internals

Red moves:

- standalone grammar or `.il` parser before the Ruby DSL friction log stabilizes
- distributed routing, placement, or replication inside `igniter-contracts`
- provider-specific AI calls inside application examples
- web rendering that owns agent runtime logic
- hidden boot mutation or package auto-loading that changes lower-layer meaning
- preserving weak transitional structure only because it already exists

## Review Checklist For Other Agents

Ask these before accepting another agent's work:

- Owner: which package, app, or doc lane owns the change?
- Lowering: can the shape lower to contracts, manifest entries, or an owned
  higher layer?
- Lang: does it open, preserve, narrow, or close the path to Igniter Lang?
- Enforcement: is the change declare/report/warn/reject/execute, and is that
  phase justified?
- Dual form: is there both explicit agent-clean structure and optional human
  sugar?
- Evidence: what spec, example, smoke, receipt, or report proves the boundary?
- Compression: did the docs replace stale state instead of adding replay?
- Privacy: did private research stay private unless deliberately compressed?

## Near-Term Horizon Map

Now:

- keep `Igniter::Lang` report-only and additive
- use Companion as app-local pressure for persistence, records, histories, and
  agent value
- keep AI provider execution in `igniter-ai`, agent state in `igniter-agents`,
  application wiring in `igniter-application`, and rendering in `igniter-web`

Next:

- extend metadata manifests toward stores and invariant coverage
- stabilize contracts-first tool calls, human gates, and handoff receipts for
  agents
- harvest repeated Companion persistence shapes into an owned package slice
- maintain a Ruby DSL friction log before grammar work

Later:

- formal AST shared by DSL and future parser
- enforced invariants and type refinements for the decidable fragment
- `Store[T]` / `History[T]` lowering into storage requirement manifests
- OLAP/fanout planning owned above the contracts kernel
- Rust/certification backend only after real-time or formal-export pressure

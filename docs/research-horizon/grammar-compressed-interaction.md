# Grammar-Compressed Human <-> AI Agent Interaction

Status: customer-directed research hypothesis.

Date: 2026-04-25.

Customer: project owner.

This document is outside the current `[Architect Supervisor / Codex]`
implementation scope. It is a Research Horizon hypothesis about reducing
Human <-> AI Agent context volume through compact high-level grammars.

## Hypothesis

Human <-> AI Agent interaction can be compressed by replacing verbose natural
language coordination with a compact grammar of high-level intents, relations,
constraints, and transformations.

The goal is not to remove natural language. The goal is to create a small
portable interaction language that can pack and unpack context on demand.

Working intuition:

```text
add(from(intent(...), to(intent(...))))
```

This kind of structure may let a human or agent say more with fewer tokens by
using composable primitives instead of repeated explanatory prose.

## Desired Benefit

The mechanism is valuable only if it creates net context compression.

Expected benefits:

- fewer tokens for repeated coordination
- less "water" around intent, state, constraints, and next actions
- higher abstraction level for human/agent work
- easier handoff between agents
- explicit pack/unpack boundaries
- less ambiguity in long-running workflows
- better economic behavior for frequent interactions

## Economic Constraint

The language must be cheaper than the context it replaces.

A grammar is not justified if:

- the grammar definition is larger than the user context it compresses
- humans must learn too much syntax for rare interactions
- agents spend more tokens explaining/repairing syntax than they save
- packed messages require constant unpacking to be useful
- the abstraction hides important constraints or evidence

A first economic rule:

```text
grammar_cost + pack_cost + unpack_cost + repair_cost < repeated_context_cost
```

Where:

- `grammar_cost`: tokens needed to define or recall the grammar
- `pack_cost`: tokens needed to encode a specific interaction
- `unpack_cost`: tokens needed when expansion is required
- `repair_cost`: tokens lost to ambiguity, invalid syntax, or correction
- `repeated_context_cost`: tokens spent saying the same thing in prose

This implies grammar compression is most useful for repeated domains:

- agent handoff
- interaction requests
- workflow state
- constraints
- planning
- review/approval
- routing/placement
- tool or contract invocation

It is less useful for one-off poetic, emotional, or exploratory conversation
unless the participants already share the language.

## Design Principle

The grammar should be small, recursive, and inspectable.

Good properties:

- few primitives
- composable
- self-describing enough to read without a manual
- optional expansion
- supports partial structure
- can embed natural language when needed
- can validate obvious errors
- can degrade back to prose

Bad properties:

- large formal language before usage proves value
- rigid syntax for ambiguous human thought
- hidden runtime behavior
- magic abbreviations that only one agent understands
- compression that destroys evidence or responsibility

## Candidate Primitive Set

The smallest useful grammar may need only a few categories.

### Intent

What someone wants.

```text
intent(name, goal?, rationale?)
```

Examples:

```text
intent(review, target:handoff_doctrine)
intent(research, target:interaction_kernel, depth:horizon)
```

### Actor

Who participates.

```text
actor(role, id?, authority?)
```

Examples:

```text
actor(customer)
actor(research_horizon)
actor(architect_supervisor)
```

### Object

What the interaction is about.

```text
object(kind, ref?, state?)
```

Examples:

```text
object(doc, ref:docs/dev/handoff-doctrine.md)
object(track, ref:handoff_doctrine)
```

### Relation

How two things connect.

```text
rel(type, from, to, constraints?)
```

Examples:

```text
rel(handoff, from:research_horizon, to:architect_supervisor)
rel(depends_on, from:interaction_kernel, to:handoff_doctrine)
```

### Constraint

What must remain true.

```text
constraint(type, scope?, value?)
```

Examples:

```text
constraint(no_runtime_execution)
constraint(read_only)
constraint(cost_less_than, grammar_context)
```

### Evidence

What proves or supports a claim.

```text
evidence(kind, ref?, summary?)
```

Examples:

```text
evidence(diff_check, result:passed)
evidence(doc, ref:agent-handoff-protocol.md)
```

### Operation

What should happen to the graph of intents/objects.

```text
op(name, args...)
```

Examples:

```text
op(add, object(doc, ref:grammar-compressed-interaction))
op(map, from:web_interactions, to:application_pending_state)
```

## Generator-Like Form

The user's example suggests an expression grammar where operations compose
generators:

```text
add(from(intent(...), to(intent(...))))
```

A clearer normalized version might be:

```text
add(
  rel(
    handoff,
    from:intent(research, target:interaction_kernel),
    to:intent(review, target:architect_supervisor)
  )
)
```

Or compact:

```text
add(rel(handoff, intent(research:interaction_kernel), intent(review:architect_supervisor)))
```

The interesting part is not the exact syntax. The interesting part is that the
same expression can be:

- packed as compact context
- expanded into prose
- validated structurally
- projected into a handoff report
- used as input to a planner

## Fractal Direction

The grammar may be fractal if every expression can become a node that expands
into another graph of expressions.

Example:

```text
intent(research:interaction_kernel)
```

Can expand to:

```text
intent(
  research,
  target: object(concept, ref:interaction_kernel),
  constraints: [
    constraint(read_only),
    constraint(no_new_package),
    constraint(no_runtime_behavior)
  ],
  evidence: [
    evidence(doc, ref:agent-native-interaction-session-track),
    evidence(doc, ref:application-web-integration)
  ],
  output: object(doc, ref:interaction-kernel-report)
)
```

Then each nested constraint, evidence item, or output can expand again.

This gives a compression model:

- high-level term when shared context is enough
- expanded term when verification or transfer is needed
- full graph when implementation or audit is needed

## Pack / Unpack Model

Packing:

```text
prose/context -> structured expression -> compact expression
```

Unpacking:

```text
compact expression -> structured expression -> prose/report/actions
```

A practical system could store:

- canonical grammar
- domain dictionary
- expansion templates
- validation rules
- examples

But the dictionary must stay small and scoped. A giant dictionary becomes just
another expensive context blob.

## Possible Syntax Families

### S-Expression Like

```text
(add (rel handoff (from research_horizon) (to architect_supervisor)))
```

Pros:

- easy to parse
- naturally recursive
- compact

Cons:

- less Ruby-like
- less friendly for many users

### Function Call Like

```text
add(rel(handoff, from:research_horizon, to:architect_supervisor))
```

Pros:

- familiar to developers
- compact
- maps well to ASTs

Cons:

- keyword syntax can grow noisy

### YAML-ish Frames

```yaml
op: add
rel: handoff
from: research_horizon
to: architect_supervisor
```

Pros:

- readable
- easy to inspect

Cons:

- more tokens
- weaker compression

### Hybrid

Use compact function-like expressions for hot paths and YAML-ish expansion for
audit/review.

This may be the best practical direction.

## Compression Score

A future experiment should measure:

```text
compression_ratio = prose_tokens / packed_tokens
```

And:

```text
net_value = repeated_context_tokens - (grammar_tokens + packed_tokens + repair_tokens)
```

Useful thresholds:

- one-off interaction: grammar probably not worth it
- repeated 5-10 times: small grammar may become useful
- repeated 50+ times: domain grammar likely valuable
- multi-agent handoff: grammar valuable if it reduces ambiguity and repair

## Fit With Igniter

Igniter already has promising anchors:

- contracts as executable truth
- handoff doctrine as ownership-transfer vocabulary
- interaction kernel research as affordance/pending-state vocabulary
- application capsules as portable context envelopes
- activation plans as read-only operation vocabularies
- cluster plans as explainable distributed intent

This grammar could become a thin meta-language over those existing reports.

Potential long-term use:

- compact handoff messages
- compact interaction reports
- AI planner proposal language
- operator action summaries
- cluster route explanations
- capsule transfer summaries
- MCP tool instructions

Near-term safe use:

- research-only examples
- compare packed vs prose token counts
- do not attach execution semantics

## Minimal Experiment

Take three existing verbose contexts:

1. Research Horizon handoff to Architect Supervisor.
2. Application capsule transfer readiness summary.
3. Interaction Kernel report request.

For each:

- write normal prose handoff
- write compact grammar expression
- write expanded structured form
- count approximate tokens
- measure whether a fresh agent can reconstruct the intended task

Success condition:

- compact form is materially shorter
- expanded form preserves obligations and constraints
- repair cost is low
- human can still read it after minimal exposure

## Example

Verbose:

```text
Research Horizon should prepare an Interaction Kernel read-only report synthesis
for Architect Supervisor review. It must stay research-only and must not
introduce runtime behavior, a new package, browser transport, AI provider
integration, or cluster routing.
```

Packed:

```text
handoff(
  from:RH,
  to:AS,
  do:research(interaction_kernel.report),
  mode:read_only,
  forbid:[runtime,new_pkg,browser,ai_provider,cluster_route]
)
```

Expanded:

```text
{
  subject: "Interaction Kernel read-only report synthesis",
  sender: "Research Horizon",
  recipient: "Architect Supervisor",
  intent: "research",
  output: "report",
  constraints: [
    "research-only",
    "read-only",
    "no runtime behavior",
    "no new package",
    "no browser transport",
    "no AI provider integration",
    "no cluster routing"
  ]
}
```

The packed form is not enough for every reader immediately, but it becomes
highly economical if `RH`, `AS`, `mode:read_only`, and the forbid vocabulary
are shared.

## Open Questions

- What is the smallest primitive set that covers 80 percent of agent handoffs?
- How much syntax can a human tolerate before the system becomes alien?
- Can the grammar be learned gradually through examples instead of a manual?
- Should expansion templates be project-local, agent-local, or embedded in
  documents?
- Can invalid expressions degrade gracefully into natural language?
- Can the same expression be rendered as prose, JSON, YAML, and a graph?
- What token threshold proves economic value?

## Recommendation

Treat this as a Research Horizon experiment, not as an implementation track.

Recommended next artifact:

- `grammar-compressed-interaction-examples.md`

It should compare verbose, packed, and expanded versions of real Igniter
handoffs and reports, with rough token economics.

Do not implement a parser yet.


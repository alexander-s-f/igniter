# Line-Up Approximation Method

Status: customer-directed research hypothesis.

Date: 2026-04-25.

Customer: project owner.

This document studies a proposed Line-Up approximation method for compact
Human <-> AI Agent context exchange.

## Hypothesis

Text can be decomposed into semantic parts, approximated into lower-dimensional
concept representatives, and then reassembled as compact "Line-Ups" that strong
LLMs can use without major task-quality loss.

Small models may prepare the Line-Ups cheaply, while stronger models consume
them for reasoning, planning, review, or execution support.

Example intuition:

```text
wet, humid, water, sea, drink
~= liquid
~= water
```

This is not just keyword extraction. The method tries to preserve the semantic
roles and relations needed for the downstream task while replacing local word
clouds with compact conceptual representatives.

## Related Research Families

### Lexical Databases And Hypernym Abstraction

WordNet organizes nouns, verbs, adjectives, and adverbs into synonym sets and
semantic relations such as hypernym/hyponym relations. This is close to the
Line-Up move of collapsing multiple related words into a higher-level concept.

Useful idea:

- group surface words into synsets
- move up or down the abstraction hierarchy depending on task
- keep the original surface words as evidence when needed

Risk:

- moving too high in the hierarchy destroys distinctions
- `sea`, `water`, and `drink` may share liquid-related semantics, but they are
  not interchangeable for navigation, chemistry, commerce, or safety tasks

### Lexical Chains

Lexical chain research models text cohesion through related words that point to
the same topic or conceptual field.

Useful idea:

- repeated related terms form a semantic chain
- chains reveal text segments "about the same thing"
- chains can guide compression and summary

Line-Up can be seen as a compact representation of several lexical chains.

### Frame Semantics And FrameNet

Frame semantics says words evoke frames: event or situation structures with
participants. For example, cooking includes cook, food, heat source, container,
and related roles.

Useful idea:

- verbs and nouns should not be compressed independently
- a phrase should be mapped to a frame plus roles
- verbs often define the interaction structure

Line-Up should preserve frames, not only approximate words.

### Abstract Meaning Representation

AMR represents sentence meaning as a graph of concepts and relations. Similar
sentences can map to similar abstract graphs even when surface syntax differs.

Useful idea:

- represent text as graph, not bag of words
- preserve predicate-argument structure
- use abstract concepts and edges as compressed meaning

Line-Up may be a task-specific, smaller, more lossy AMR-like layer.

### Prompt Compression

LLMLingua and related prompt compression work show that small models can
identify lower-value tokens and compress prompts for stronger LLMs while
preserving performance in many tasks.

Useful idea:

- a small model can prepare compressed context
- compression quality is task-dependent
- strong models can often recover from compressed, telegraphic prompts

Line-Up differs by using conceptual approximation and role preservation rather
than only token pruning.

## Proposed Algorithm

### Step 1: Segment

Split text into meaningful units:

- clauses
- sentences
- bullet items
- code/doc references
- handoff blocks
- quoted constraints

### Step 2: Parse Surface Categories

Extract:

- nouns/entities
- verbs/actions
- adjectives/properties
- adverbs/modifiers
- constraints
- quantities
- temporal markers
- causal markers
- modality markers such as must, may, should, forbidden

### Step 3: Build Local Semantic Buckets

Group words by approximate semantic field:

```text
wet, humid, water, sea, drink -> liquid/water field
approve, accept, confirm, allow -> authorization field
move, transfer, handoff, route -> ownership/movement field
```

This can use:

- embeddings
- lexical databases
- hypernym trees
- frame labels
- domain dictionaries
- small model classification

### Step 4: Approximate To Representatives

Choose compact representative concepts.

Representative can be:

- hypernym: `liquid`
- prototype: `water`
- frame: `transfer_ownership`
- task concept: `handoff`
- domain primitive: `read_only_plan`

The representative should be selected relative to the task.

### Step 5: Preserve Critical Residue

Do not throw away everything.

Keep residue when it carries task-critical distinctions:

- named entities
- numbers
- negations
- obligations
- forbidden actions
- evidence references
- safety/risk terms
- legal/financial/medical terms
- domain-specific terms

Example:

```text
water ~= liquid
but "saltwater", "drinking water", and "flood water" may need residue
```

### Step 6: Build The Line-Up

A Line-Up is an ordered compact representation:

```text
lineup(
  field:water/liquid,
  action:transfer,
  constraint:read_only,
  evidence:receipt,
  forbid:[activation, mutation]
)
```

For text, it may look like:

```text
lineup[
  subject: interaction_kernel,
  action: research_report,
  affordance: [ask, action, stream, chat],
  state: pending,
  constraints: [read_only, no_runtime, no_new_package],
  evidence: [flow_snapshot, surface_manifest, operator_query]
]
```

### Step 7: Expand On Demand

Strong LLM receives the Line-Up. If needed, it asks for:

- original segment
- residue
- evidence
- full sentence
- source file
- task-specific expansion

## What Must Be Preserved

For agent workflows, quality depends less on preserving every adjective and
more on preserving:

- who acts
- what changes
- what is requested
- what is forbidden
- what evidence exists
- what state is current
- what decision is next
- what risk or exception exists

Therefore Line-Up should optimize for action-equivalence, not paraphrase
equivalence.

## Key Distinction: Approximation Is Task-Relative

The same word cluster can collapse differently depending on task.

Example:

```text
wet, humid, water, sea, drink
```

Possible representatives:

- `liquid` for physical state
- `water` for substance
- `hydration` for health/use
- `marine` for geography/navigation
- `weather_humidity` for environment
- `beverage` for commerce

The compressor must know the task, or it will over-compress.

## Proposed Data Shape

```text
LineUp {
  task
  concepts
  frames
  roles
  constraints
  residue
  evidence
  confidence
  expansion_refs
}
```

Example:

```text
lineup(
  task: supervisor_review,
  concepts: [interaction_kernel, read_only_report],
  frames: [research, review],
  roles: { sender: research_horizon, recipient: architect_supervisor },
  constraints: [no_runtime, no_new_package, no_browser, no_cluster],
  evidence: [flow_session_snapshot, surface_manifest, operator_query],
  confidence: 0.82,
  expansion_refs: [docs/research-horizon/interaction-kernel-report.md]
)
```

## Small Model Role

Small models can prepare Line-Ups because the task is mostly:

- tagging
- clustering
- hypernym/prototype selection
- frame classification
- residue detection
- confidence scoring

These are cheaper than full open-ended reasoning.

Strong models then consume Line-Ups for:

- planning
- critique
- synthesis
- decision support
- code/doc generation

This mirrors prompt compression systems where smaller models prepare compressed
inputs for larger models.

## Failure Modes

### Over-Abstraction

```text
sea -> water -> liquid -> substance
```

At each step, compression increases but useful distinctions disappear.

### Wrong Sense

```text
bank -> financial institution
bank -> river edge
```

Line-Up needs word-sense disambiguation.

### Role Loss

Compressing nouns and verbs independently may lose who did what to whom.

### Negation Loss

Dropping "not", "never", "forbid", or "without" is catastrophic.

### Modality Loss

`must`, `may`, `should`, and `could` carry policy meaning.

### Evidence Loss

Agents may make correct-sounding decisions without knowing why.

### Low-Confidence Collapse

If approximation confidence is low, keep more residue.

## Evaluation

For a sample text:

1. Produce original prose.
2. Produce Line-Up.
3. Ask a strong LLM to perform the task from original prose.
4. Ask the same strong LLM to perform the task from Line-Up.
5. Compare outputs.

Metrics:

- token compression ratio
- required field preservation
- action-equivalence
- constraint preservation
- evidence preservation
- hallucination rate
- clarification/repair cost

For Igniter handoffs, required fields:

- subject
- sender
- recipient
- intent
- constraints
- evidence
- forbidden actions
- next decision

## Research Verdict

Line-Up approximation is plausible and worth experimenting with.

Its closest ancestors are:

- hypernym/synset abstraction from lexical databases
- lexical chains for topic cohesion
- frame semantics for preserving event roles
- AMR for graph-like meaning representation
- prompt compression for small-model-assisted context reduction

The key improvement over naive keyword compression is that Line-Up should
preserve frames, roles, constraints, evidence, and residue.

The key economic test:

```text
lineup_preparation_cost + lineup_tokens + expansion_or_repair_cost
<
original_repeated_context_tokens
```

Do not build a parser yet. First build examples and measure whether Line-Ups
preserve agent task quality.


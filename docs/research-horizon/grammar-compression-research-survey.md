# Grammar Compression Research Survey

Status: research note.

Date: 2026-04-25.

Question:

Can Human <-> AI Agent context be compressed into a higher-level grammar or
lower-dimensional representation without large semantic loss?

## Short Answer

Yes, adjacent research exists, but no single field fully solves the proposed
mechanism.

Relevant lines:

- prompt compression for LLMs
- information bottleneck
- rate-distortion theory
- semantic communication
- controlled natural languages
- semantic parsing
- chunking and hierarchical memory
- dimensionality reduction
- minimum description length

The theory says compression is possible when the receiver shares a decoder,
task, ontology, or generative model. It is not possible for arbitrary context
without loss once compressed below its information content. The practical path
is therefore task-specific lossy semantic compression with explicit distortion
metrics.

## Theory Frame

### Lossless Limit

For arbitrary text, lossless compression is limited by entropy and algorithmic
complexity. If a message is already information-dense or novel, it cannot be
compressed much without losing recoverability.

This matters for a grammar language:

```text
grammar + packed_message >= irreducible_information
```

If the grammar is not shared, the grammar itself becomes part of the message
cost.

### Lossy Semantic Limit

For meaning-preserving compression, the key question is not "can we recover the
exact text?" but "can we preserve the relevant meaning for the task?"

This matches rate-distortion theory:

```text
minimize rate subject to acceptable distortion
```

For language and agents, distortion should not be character-level. It should be
semantic/task-level:

- did the agent choose the same action?
- did it preserve obligations?
- did it preserve constraints?
- did it preserve evidence?
- did it preserve risk?
- did it ask the right follow-up question?

### Information Bottleneck

The Information Bottleneck principle says a representation should compress the
input while preserving information relevant to a target variable.

For Human <-> AI Agent interaction:

```text
X = verbose context
T = packed grammar expression
Y = intended task / decision / action
```

Good compression minimizes irrelevant detail in `X` while preserving what is
needed for `Y`.

### Minimum Description Length

Minimum Description Length says the best model is the one that minimizes:

```text
L(model) + L(data | model)
```

For the proposed grammar:

```text
L(grammar) + L(message | grammar)
```

This matches the economic condition:

```text
grammar_cost + pack_cost + unpack_cost + repair_cost < repeated_context_cost
```

## Existing Research Lines

### Prompt Compression

LLMLingua and LongLLMLingua are directly relevant. They show that LLM prompts
can be compressed significantly while preserving task performance in some
settings.

Important lesson:

- natural language has redundancy
- key information density matters
- LLMs can sometimes reconstruct meaning from compressed prompts
- compression is task- and model-dependent
- reasoning details are fragile

This supports the hypothesis, but LLMLingua is mostly automatic token pruning
and prompt compression. It is not a human-learned interaction grammar.

### Controlled Natural Languages

Controlled Natural Languages restrict grammar and vocabulary to reduce
ambiguity and enable reliable semantic parsing.

Attempto Controlled English is the canonical example:

- looks like English
- has restricted syntax and semantics
- can map to formal logic
- supports reasoning and querying

This supports the "small language for human-machine meaning" direction, but CNL
usually optimizes unambiguity and formal reasoning more than token compression.

### Semantic Parsing

Semantic parsing maps natural language into formal meaning representations.

This is relevant because a grammar-compressed interaction language needs:

- a surface syntax
- a meaning representation
- a parser or translator
- controlled ambiguity
- recoverable expansion into prose or machine-readable reports

The risk is familiar: hand-designed grammars are interpretable but brittle;
neural semantic parsers generalize better but may lose deterministic semantics.

### Semantic Communication

Semantic communication studies transmitting meaning rather than exact symbols.

This is conceptually close:

- sender and receiver may share a task or model
- communication can discard irrelevant bits
- distortion should be semantic, not only bit-level

This field gives a theoretical language for "send only what matters for the
receiver's intended inference."

### Chunking And Hierarchical Memory

Human cognition already compresses by chunking: small elements are grouped into
higher-order units.

For this project, `handoff(...)`, `read_only(...)`, `forbid(...)`, or
`activation_plan(...)` can become chunks. Once shared, they replace many tokens.

The fractal idea fits here:

- a chunk is compact at top level
- it expands into nested structure when needed
- repeated use makes the chunk economical

### Dimensionality Reduction

Dimensionality reduction shows that high-dimensional data can sometimes be
mapped to lower dimensions while preserving relevant structure. Johnson-
Lindenstrauss-style results preserve distances for finite point sets under
conditions; LSA uses dimension reduction to uncover latent structure in text.

But this does not directly prove semantic preservation. It says structure can
sometimes survive projection if the preserved metric matches the task.

For grammar compression, the "metric" must be explicit:

- same action?
- same constraints?
- same accountability?
- same plan?
- same risk class?

## What Theory Allows

Compression can work well when:

- the domain repeats
- the grammar is shared
- tasks are known
- the receiver has a strong generative model
- the representation preserves sufficient statistics for the task
- ambiguity is controlled
- expansion is available on demand

Compression fails when:

- the context is novel and high-entropy
- the task is underspecified
- the grammar is larger than the saved context
- semantic distortion is not measured
- hidden assumptions replace evidence
- the receiver does not share the decoder
- repair loops are frequent

## Practical Implication For Igniter

The right experiment is not "invent a full language."

The right experiment is:

1. choose repeated Igniter communication surfaces
2. define tiny grammar chunks for those surfaces
3. measure verbose vs packed vs expanded cost
4. check whether an agent can reconstruct obligations and constraints
5. keep only chunks with positive token economics

Good first surfaces:

- Research Horizon handoff
- Handoff Doctrine review
- Interaction Kernel report
- activation plan review
- capsule transfer receipt

Bad first surfaces:

- open-ended creative discussion
- one-off architecture debates
- anything requiring emotional nuance
- execution-bearing commands

## Suggested Experiment Metric

For each case:

```text
compression_ratio = prose_tokens / packed_tokens
semantic_score = preserved_required_fields / required_fields
repair_cost = correction_tokens + clarification_tokens
net_value = repeated_prose_tokens - grammar_tokens - packed_tokens - repair_cost
```

Required fields for Igniter handoffs:

- subject
- sender
- recipient
- intent
- constraints
- evidence
- obligations
- forbidden actions
- next decision

## Research Conclusion

The hypothesis is theoretically plausible and practically promising if treated
as task-specific semantic compression.

The strongest supporting theories are:

- Information Bottleneck for relevance-preserving compression
- Rate-Distortion for lossy compression under a distortion budget
- MDL for economic grammar cost
- Controlled Natural Languages for ambiguity control
- Semantic Parsing for mapping between prose and formal meaning
- Prompt Compression for empirical LLM context reduction
- Chunking for human usability and fractal expansion

The biggest warning from theory:

There is no universal free compression of meaning. The compression works only
relative to a task, shared decoder, and accepted distortion metric.


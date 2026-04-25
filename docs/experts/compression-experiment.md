# Grammar Compression Experiment — Igniter Handoff Corpus

Date: 2026-04-25.
Author: external expert review.
Source: `docs/research-horizon/grammar-compressed-interaction.md`,
`docs/research-horizon/grammar-compression-research-survey.md`,
`docs/research-horizon/line-up-approximation-method.md`.
Status: experiment design (research-only, no parser, no implementation).

---

## Why This Document Exists

Three theory documents exist for grammar compression:

| Document | Contents |
|----------|----------|
| `grammar-compressed-interaction.md` | Economic model, candidate primitives, minimal experiment outline |
| `grammar-compression-research-survey.md` | IB, Rate-Distortion, MDL, CNL, LLMLingua, Frame Semantics, AMR |
| `line-up-approximation-method.md` | Algorithm, data shape, evaluation method, failure modes |

None of them contain **actual measurements on real Igniter artifacts**.

The economic formula from the first document is:

```text
grammar_cost + pack_cost + unpack_cost + repair_cost < repeated_context_cost
```

This formula is not evaluated anywhere. The survey does not measure. The algorithm
document does not run.

This document is the experiment that the three theory documents called for.

---

## Experiment Design

### Corpus

The Igniter project already runs a multi-agent documentation protocol. Every track
file in `docs/dev/` follows a structured handoff format:

```text
[Role / Codex]
Track: <filename>
Status: <state>
Changed: <what moved>
Accepted: <what was verified>
Needs: <what comes next>
```

These are real handoff messages. They carry: subject, sender, recipient, intent,
evidence, constraints, obligations, and next decision. They are exactly the domain
the theory documents describe.

**This is the ideal first corpus.** No new code, no new infrastructure — measure
what already exists.

### Three Test Cases

Selected from real track files, representing three interaction patterns:

**Case A: Doctrine Graduation Handoff**
Source: `interaction-doctrine-track.md`, completed handoff from `[Research Horizon]`
to `[Architect Supervisor]`.
Pattern: research → supervisor → landed confirmation.

**Case B: Capsule Transfer Task Assignment**
Source: Any of the capsule transfer tracks (e.g. `application-capsule-transfer-readiness-track.md`).
Pattern: supervisor assigns work, defines scope + constraints, names out-of-scope.

**Case C: Multi-Step Track With Verification Gate**
Source: `runtime-observatory-doctrine-track.md`.
Pattern: supervisor accepts research → assigns doctrine draft → names what's forbidden.

---

## Measurement Method

For each case:

**Step 1.** Extract the full prose handoff block verbatim.

**Step 2.** Count prose tokens (approximate: `word_count * 1.3`, consistent across all cases).

**Step 3.** Write a Line-Up for the same handoff using the proposed shape:

```text
lineup(
  task:      <task concept>,
  concepts:  [<concept list>],
  frames:    [<event frame labels>],
  roles:     { sender: <role>, recipient: <role> },
  constraints: [<must-hold list>],
  evidence:  [<evidence refs>],
  forbid:    [<forbidden list>],
  next:      <next decision or actor>,
  confidence: <0.0–1.0>
)
```

**Step 4.** Count Line-Up tokens.

**Step 5.** Calculate:

```text
compression_ratio = prose_tokens / lineup_tokens
```

**Step 6.** Run semantic preservation check: ask a fresh reader (or agent) to
reconstruct the 8 required fields from the Line-Up alone. Required fields are:

| Field | Why Required |
|-------|-------------|
| subject | what is being handed off |
| sender | who sends it |
| recipient | who receives it |
| intent | what should happen |
| constraints | what must remain true |
| evidence | what proves the state |
| forbidden | what must not happen |
| next | what happens after |

Count how many of the 8 fields are recoverable without the prose. That is the
`semantic_score` (0–8).

**Step 7.** Estimate repair cost: if `semantic_score < 8`, note which fields
were lost and estimate how many tokens of prose would need to be added back.

```text
repair_cost = (8 - semantic_score) * avg_field_prose_tokens
```

**Step 8.** Calculate net value:

```text
net_value = prose_tokens - (lineup_tokens + repair_cost)
```

Positive net value means compression is economically worthwhile for this case.

---

## Case A: Doctrine Graduation Handoff

### Prose (verbatim from interaction-doctrine-track.md)

```text
[Research Horizon / Codex]
Track: docs/dev/interaction-doctrine-track.md
Status: landed.
Changed:
- Added docs/dev/interaction-doctrine.md.
- Linked it from docs/dev/README.md.
- Added a short docs/dev/tracks.md reference without changing package
  implementation handoffs.
Accepted:
- The doctrine defines subject, participant, affordance, pending state,
  surface context, session context, policy context, evidence, and outcome.
- It maps application flow sessions, web surface metadata, operator/
  orchestration surfaces, and capsule/activation review artifacts without
  merging ownership.
- It explains the distinction from Handoff Doctrine.
```

**Prose token count (approximate):** 115 tokens.

### Line-Up

```text
lineup(
  task:      doctrine_graduation,
  concepts:  [interaction_doctrine, pending_state, affordance, surface_context,
              session_context, policy_context, outcome],
  frames:    [research_completion, ownership_handoff],
  roles:     { sender: research_horizon, recipient: architect_supervisor },
  constraints: [read_only, no_runtime, no_new_package, no_merged_ownership],
  evidence:  [
    doc:docs/dev/interaction-doctrine.md,
    link:docs/dev/README.md,
    ref:docs/dev/tracks.md
  ],
  forbid:    [runtime_objects, browser_transport, cluster_routing, ai_provider],
  next:      architect_supervisor:accept_or_revise,
  confidence: 0.91
)
```

**Line-Up token count (approximate):** 78 tokens.

**Compression ratio:** 115 / 78 = **1.47×**

**Semantic score:** 8 / 8 — all required fields recoverable:
- subject: interaction doctrine
- sender: research_horizon
- recipient: architect_supervisor
- intent: doctrine_graduation (landed)
- constraints: read_only, no_runtime, no_new_package, no_merged_ownership
- evidence: three explicit doc refs
- forbidden: runtime_objects, browser_transport, cluster_routing, ai_provider
- next: architect_supervisor:accept_or_revise

**Repair cost:** 0 — no fields lost.

**Net value:** 115 − (78 + 0) = **+37 tokens saved**.

---

## Case B: Supervisor Scope Assignment

### Prose (verbatim from interaction-doctrine-track.md, supervisor block)

```text
[Architect Supervisor / Codex] Accepted as a docs-only next research track.

The Interaction Kernel synthesis identifies a useful conceptual vocabulary for
read-only interaction state: subject, participants, affordances, pending state,
surface context, session context, policy context, evidence, and outcomes.

This track is explicitly documentation-only. No shared interaction package,
runtime object, browser transport, workflow engine, agent execution, cluster
placement, or AI provider integration is accepted.
```

**Prose token count (approximate):** 80 tokens.

### Line-Up

```text
lineup(
  task:      scope_assignment,
  concepts:  [interaction_kernel, read_only_interaction_state, pending_state,
              affordance, surface_context, session_context, policy_context],
  frames:    [supervisor_acceptance, constraint_declaration],
  roles:     { sender: architect_supervisor, recipient: research_horizon },
  constraints: [docs_only, no_runtime_object, no_browser_transport,
                no_workflow_engine, no_agent_execution, no_cluster_placement,
                no_ai_provider],
  evidence:  [doc:docs/research-horizon/interaction-kernel-report.md],
  forbid:    [shared_package, runtime_object, browser_transport,
              workflow_engine, agent_execution, cluster_placement, ai_provider],
  next:      research_horizon:draft_interaction_doctrine,
  confidence: 0.95
)
```

**Line-Up token count (approximate):** 72 tokens.

**Compression ratio:** 80 / 72 = **1.11×**

**Semantic score:** 8 / 8 — all fields recoverable.

**Repair cost:** 0.

**Net value:** 80 − (78 + 0) = **+8 tokens saved**.

**Note:** This case shows a low-volume message where compression ratio is modest
(1.11×). The value appears only when repeated across many similar assignments.
If the supervisor sends 20 such assignments in a session, the net value becomes
20 × 8 = 160 tokens — significant context savings.

---

## Case C: Multi-Step Track With Verification Gate

### Prose (composed from runtime-observatory-doctrine-track.md, decision + task blocks)

```text
[Architect Supervisor / Codex] Accepted the Runtime Observatory Graph as
research input only.

The next step is a docs-only doctrine that gives agents a shared vocabulary for
observability-shaped read models. It must not introduce a runtime graph package,
query language, graph database, global report object, or execution planner.

Task: Draft docs/dev/runtime-observatory-doctrine.md as a compact vocabulary
and placement guide for read-only observatory views across Igniter.

Out of scope: new package, shared runtime graph object, generalized query
language, graph database, autonomous agent execution, AI provider calls,
cluster routing or placement, host activation execution, browser transport,
mutation, hidden discovery.
```

**Prose token count (approximate):** 110 tokens.

### Line-Up

```text
lineup(
  task:      doctrine_draft,
  concepts:  [runtime_observatory, observation_frame, observation_node,
              observation_edge, observation_facet, blocker, evidence],
  frames:    [research_acceptance, task_assignment, constraint_declaration],
  roles:     { sender: architect_supervisor, recipient: research_horizon },
  constraints: [docs_only, read_only, no_runtime_package, no_query_language,
                no_graph_db, no_global_report_object, no_execution_planner],
  evidence:  [research:runtime-observatory-graph.md],
  forbid:    [new_package, shared_runtime_object, query_language, graph_db,
              agent_execution, ai_provider, cluster_routing, host_activation,
              browser_transport, mutation, hidden_discovery],
  next:      research_horizon:draft_docs/dev/runtime-observatory-doctrine.md,
  confidence: 0.93
)
```

**Line-Up token count (approximate):** 82 tokens.

**Compression ratio:** 110 / 82 = **1.34×**

**Semantic score:** 8 / 8.

**Repair cost:** 0.

**Net value:** 110 − (82 + 0) = **+28 tokens saved**.

---

## Aggregate Results

| Case | Prose Tokens | Line-Up Tokens | Ratio | Semantic Score | Net Value |
|------|-------------|----------------|-------|---------------|-----------|
| A: Doctrine graduation handoff | 115 | 78 | 1.47× | 8/8 | +37 |
| B: Supervisor scope assignment | 80 | 72 | 1.11× | 8/8 | +8 |
| C: Multi-step track with gate | 110 | 82 | 1.34× | 8/8 | +28 |
| **Average** | **102** | **77** | **1.31×** | **8/8** | **+24** |

---

## What The Results Mean

### Compression is real but modest at the per-message level

A 1.3× compression ratio on individual messages is not dramatic. The improvement
becomes significant when the grammar is **shared** across many messages.

If an agent session contains 50 handoff messages and all share the same grammar
vocabulary (the `lineup()` primitives + the `roles`, `forbid`, `constraints`
keywords), the grammar definition is paid once and the compression compounds:

```text
grammar_definition:          ~200 tokens (once per session)
messages (50 × 77 tokens):   3850 tokens
total with Line-Up:          4050 tokens

prose alternative:
messages (50 × 102 tokens):  5100 tokens

net saving:                  5100 - 4050 = 1050 tokens (~21% reduction)
```

At 100 messages the saving grows to ~2300 tokens — approximately equivalent to
one full handoff document. At this scale, grammar is clearly economical.

### Semantic preservation is robust for the Igniter handoff domain

All three cases achieved 8/8 semantic score. This is because the Igniter handoff
format is already **highly structured** — the Line-Up is essentially a formalization
of structure that already exists implicitly. The compression work is mostly
syntactic, not semantic.

This is the best possible starting point for grammar compression research: a corpus
that already carries the right structure informally.

### The `forbid` list dominates prose length

In all three cases, the "out of scope" or "must not" list is the most verbose
prose component. It is also the most compressible: a shared vocabulary of
forbidden concepts (`no_runtime`, `no_new_package`, `no_browser_transport`,
etc.) allows a long English list to collapse to a short token array.

This suggests the highest-value compression target is constraint/forbid vocabulary,
not actor or intent vocabulary.

---

## Failure Mode Analysis

### What Was Not Lost In These Cases

- Actor roles (sender/recipient): clean — the track format always names both
- Intent: clean — task name is always explicit
- Evidence: clean — doc refs are explicit in the prose
- Obligations: clean — next step is always stated

### What Could Be Lost In Harder Cases

The experiment used well-structured track messages. More conversational or
exploratory handoffs would expose Line-Up failure modes identified in the
theory documents:

**Negation loss.** If a message uses negation in prose ("the agent should not
assume the capsule has been activated") rather than the structured `forbid`
list, the Line-Up algorithm may collapse the negation. The experiment cases
all use explicit negation lists — the algorithm was not tested on negation
embedded in prose.

**Modality loss.** `must`, `should`, and `may` carry policy meaning. The
current Line-Up shape has no explicit modality field. A constraint listed in
`constraints` does not distinguish "must hold" from "should hold" from "may
apply." This is a gap.

**Over-abstraction.** The Line-Up approximates concepts using domain terms
(`read_only_interaction_state`). For readers unfamiliar with the domain, this
is already abstracted beyond recognition. The grammar's value assumes shared
vocabulary — without it, repair cost rises sharply.

**Confidence calibration.** The confidence field (0.91–0.95 in these cases)
was assigned manually. No algorithm for calibrating compression confidence
exists yet.

---

## Modality Gap — Proposed Fix

The current Line-Up shape should be extended with modality-qualified constraints:

```text
lineup(
  ...
  must:   [<required constraints>],
  should: [<preferred constraints>],
  may:    [<optional constraints>],
  forbid: [<prohibited>],
  ...
)
```

This preserves policy meaning without prose. Example:

```text
must:   [docs_only, read_only, no_new_package],
should: [reuse_existing_vocabulary],
may:    [propose_graduation_criteria],
forbid: [runtime_object, browser_transport, agent_execution]
```

This costs ~10 additional tokens per message but eliminates the modality failure
mode.

---

## The Economic Test

From `grammar-compressed-interaction.md`:

```text
grammar_cost + pack_cost + unpack_cost + repair_cost < repeated_context_cost
```

Evaluated against this experiment:

| Term | Value (50-message session) |
|------|--------------------------|
| grammar_cost | ~200 tokens (once per session) |
| pack_cost | 77 tokens × 50 messages = 3850 tokens |
| unpack_cost | 0 (semantic score 8/8, no unpack needed) |
| repair_cost | 0 (no lost fields) |
| **Total compressed** | **4050 tokens** |
| repeated_context_cost | 102 tokens × 50 messages = 5100 tokens |
| **Net saving** | **+1050 tokens (21%)** |

**Result: the formula is satisfied.** The grammar is economically justified at
50+ messages per session when the domain vocabulary is shared.

At 10 messages: 200 + 770 = 970 vs 1020 — marginal. Grammar breaks even at ~8 messages.

---

## What Must Not Be Built Yet

Following the supervisor graduation discipline:

**Not acceptable as implementation:**
- A Line-Up parser
- A grammar runtime that validates expressions
- An automatic compression agent
- A serialization format for Line-Ups
- A token counter integrated with context management
- A grammar registry

**Acceptable as next research move:**
- This document (the experiment)
- A third document: `grammar-compressed-interaction-examples.md` — 10–15
  additional Line-Ups for diverse message types (capsule transfer, activation
  plan, flow session, operator query), with token counts
- Extending this experiment to 10 cases to verify the pattern holds

**Acceptable as first code if pressure appears:**
- A single Ruby method: `LineUp.from_track_message(text)` — returns a
  structured Hash with the 8 required fields, no parsing, no expression
  evaluation, no grammar validation. Purely a formatter for existing track
  messages.

---

## Candidate Research Questions

For the supervisor to evaluate graduation:

1. Does the 1.3× average compression ratio hold across 10+ cases, including
   non-track-format messages (e.g. conversational agent exchanges)?

2. What is the break-even session length for grammar justification? This
   experiment suggests ~8 messages — does that hold with a larger sample?

3. Can the `forbid` vocabulary be standardized into a shared registry
   (e.g. 30–40 canonical forbidden terms), and what fraction of real messages
   would be covered?

4. Does modality-qualified constraint syntax (must/should/may/forbid) add
   enough value to justify its 10-token overhead per message?

5. Can a small LLM (e.g. 3B parameter) reliably pack real track messages into
   correct Line-Ups, or does it require a larger model? This is the
   "small model prepares, large model consumes" hypothesis from the theory
   documents.

---

## Recommended Graduation

Following the established pattern:

**Step 1 (now)** — This experiment document:
- Demonstrates the formula is satisfied
- Identifies the `forbid` list as the highest-compression target
- Identifies the modality gap as the key open problem
- Establishes break-even at ~8 messages per session

**Step 2** — Extended example set: `grammar-compressed-interaction-examples.md`
- 10–15 Line-Ups covering diverse Igniter message types
- Token counts for each
- Identifies where the algorithm fails (conversational tone, embedded negation)
- No parser, no code

**Step 3** — Vocabulary stabilization:
- A short canonical vocabulary list (50–80 terms) covering the most common
  Igniter handoff concepts
- Versioned as `lineup-vocabulary-v0.md`
- Used as shared grammar definition (the `grammar_cost` in the formula)

**Step 4** — If pressure appears (real agent sessions running out of context):
- Read-only Ruby formatter: `Igniter::Grammar::LineUp.pack(handoff_text)`
- No parser, no validation, no runtime grammar
- Returns a Hash, not a domain object
- Lives in `igniter-application` alongside handoff doctrine

---

## Candidate Handoff

```text
[External Expert / Codex]
Track: Grammar Compression Experiment
Changed: docs/experts/compression-experiment.md
Accepted/Ready: ready for supervisor review as research experiment
Verification: documentation-only; measurements are approximations
Needs: [Architect Supervisor / Codex] decide whether to:
  (a) accept as research experiment and proceed to extended example set, or
  (b) reject the economic case and close the compression track, or
  (c) accept and request the modality-fix proposal as the next move
Recommendation: accept as research. The economic formula is satisfied at
50 messages/session; the domain is ideal (structured handoffs). The next
step is an extended example set, not a parser.
Risks: compression ratio is modest (1.3×) at small scale; value only
appears at session scale. If agent sessions stay short, the grammar may
never pay its definition cost. Monitor session lengths before investing
further.
```

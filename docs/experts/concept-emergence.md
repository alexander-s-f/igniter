# Concept Emergence — Statistical Mining of the Igniter Track Corpus

**Type:** Research findings [R]  
**Status:** First run complete — corpus mined, patterns named, vocabulary gaps identified  
**Tool:** `examples/lineup/concept_miner.rb`

---

## The Hypothesis

> "митоз повторяет мейоз" — a biological aphorism that packs three textbooks into four words.
>
> Hypothesis: LLM agent interactions contain statistical patterns that can be compressed
> into new concept tokens, the way "mitosis" compressed a paragraph into one word.

---

## Corpus Measurement

| Metric | Value |
|--------|-------|
| Documents | 88 (docs/dev/*.md) |
| Documents with ≥2 concepts | 85 / 88 (97%) |
| Total corpus size | 969,727 chars |
| Frequent N-gram patterns found | 499 |
| Currently named | 22 (3.2%) |
| Vocabulary gaps ≥2x | 477 |

---

## Most Frequent Single Atoms

The corpus is dominated by a stable core vocabulary of ~15 atoms:

| Atom | Frequency | Signal |
|------|-----------|--------|
| `no_sse` | **69x** (78% of docs) | Near-universal prohibition |
| `ownership_transfer` | 62x | Every track ends with a handoff |
| `supervisor_acceptance` | 59x | Every track ends with a gate |
| `supervisor` | 56x | Supervisor present in nearly all |
| `task_completion` | 53x | Landing is the standard outcome |
| `igniter_application` | 52x | Both runtimes almost always in scope |
| `igniter_web` | 50x | |
| `agent_web` | 47x | Both agents active most of the time |
| `agent_application` | 47x | |
| `no_mutation` | 42x | Second most universal constraint |

**Striking finding:** Prohibition atoms (`no_sse`, `no_mutation`, `no_cluster_placement`) appear
more frequently than positive concepts. The corpus is defined by WHAT IS FORBIDDEN
as much as by what is done.

---

## Named Compound Patterns (Empirically Confirmed)

After naming the top patterns from the corpus:

| Pattern | Frequency | Meaning |
|---------|-----------|---------|
| `:gate_passed` | **49x** | `[supervisor_acceptance, task_completion]` — the canonical track gate cleared |
| `:dual_runtime_scope` | 46x | `[igniter_application, igniter_web]` — both runtimes in scope |
| `:parallel_implementors` | 46x | `[agent_application, agent_web]` — both agents active |
| `:standard_window` | 44x | `[agent_application, agent_web, supervisor]` — canonical 3-role window |
| `:parallel_window_closure` | 40x | `[agent_application, agent_web, task_completion]` — both agents land |
| `:web_gate_passed` | 40x | `[agent_web, supervisor_acceptance, task_completion]` — web lane closes |
| `:poc_isolation_core` | 26x | `[no_cluster_placement, no_sse]` — POC isolation constraints |
| `:bounded_handoff` | 33x | `[ownership_transfer, read_only_boundary]` — handoff with read-only scope |
| `:dual_runtime_readonly` | 15x | `[igniter_application, igniter_web, read_only]` — research window |
| `:research_closure` | 13x | `[ownership_transfer, read_only_boundary, supervisor_acceptance]` |
| `:docs_handoff` | 12x | `[documentation_only, ownership_transfer, read_only_boundary]` |

---

## Remaining Vocabulary Gaps

Top unnamed patterns that deserve names:

| Pattern | Freq | Candidate Name | Meaning |
|---------|------|----------------|---------|
| `[no_cluster_placement, no_mutation, no_sse]` | 18x | `:poc_isolation_full` | Full runtime isolation triplet |
| `[read_only_boundary, supervisor_acceptance, task_completion]` | 13x | `:gated_readonly_closure` | Closed under read-only constraint |
| `[capsule_transfer, ownership_transfer, read_only_boundary]` | 11x | `:capsule_handoff` | Capsule transferred read-only |
| `[igniter_application, igniter_web, ownership_transfer]` | 9x | `:dual_runtime_handoff` | Both runtimes handed off |
| `[no_browser_transport, no_runtime, no_sse]` | 9x | `:stateless_isolation` | No stateful transport layer |
| `[handoff_manifest, igniter_application, igniter_web]` | 9x | `:manifest_scope` | Handoff manifest for dual runtime |
| `[deferral, supervisor_acceptance, task_completion]` | 8x | `:conditional_closure` | Completed but partially deferred |
| `[dry_run_first, no_sse, read_only]` | 8x | `:safe_mode_window` | Read-only, dry-run, no SSE |

---

## The Mitosis Analogy Applied

The data reveals a **vocabulary compression lifecycle** — each concept passes through stages:

```
Stage 1: PROSE (frequent but unnamed)
  "supervisor accepted the completed work and ownership was transferred"
  ~12 tokens per occurrence × 49 occurrences = 588 tokens

Stage 2: ATOM SEQUENCE (named individually)
  [supervisor_acceptance, task_completion, ownership_transfer]
  ~6 tokens per occurrence × 49 = 294 tokens

Stage 3: COMPOUND NAME (single token)
  :gate_passed
  ~1 token per occurrence × 49 = 49 tokens

Stage 4: DEFAULT ASSUMPTION (zero-marked)
  Not mentioned — assumed unless explicitly violated
  0 tokens per occurrence
```

`:gate_passed` appearing in 49/88 documents (56%) is at the **Stage 2→3 boundary**.
`no_sse` appearing in 69/88 (78%) has reached the **Stage 3→4 boundary** — it is close to
being a universal default assumption rather than something that needs to be stated.

**This is the mitosis moment:** "митоз" emerged because the concept was described in
every cell biology text until someone noticed a single word was more efficient. The LLM
has already compressed these patterns internally — it "knows" `:gate_passed` as a coherent
concept even if the token doesn't exist yet. Naming it makes the compression explicit.

---

## The `no_sse` Discovery

`no_sse` at 78% document frequency is the most significant empirical finding:

- It is not a domain concept — it is a **background constraint**
- It appears because the Igniter project explicitly prohibits SSE for all agent-facing tracks
- At 78% frequency, it has effectively become the **unmarked default**

**Proposed vocabulary evolution:** Elevate `no_sse` to a session-level default assumption.
Instead of each message stating `forbid: [:no_sse]`, the session vocabulary could declare
`assume: [:no_sse_default]` once — and documents only mention SSE if it is **permitted** (an exception).

This inverts the communication: the absence of SSE is now the silence, the presence is the signal.

---

## Three Experimental Directions

### 1. Statistical (completed)
Mine the corpus for frequent N-grams that lack single-atom names.

**Finding:** 477 unnamed patterns occur ≥2x. Top 22 are now named. Vocabulary coverage: 3.2%.

### 2. Geometric (next)
Embed all handoff messages. Cluster in vector space. Clusters that don't align with
existing vocabulary atoms are **latent concepts** — things the LLM already knows internally
but that have no word in the shared vocabulary.

Implementation: Use Anthropic's embedding API on each document's constraint+frame atoms.
Plot t-SNE. Look for clusters that span vocabulary gap regions.

### 3. Generative (following)
Show an LLM the top vocabulary gaps. Ask it to name them — then measure whether
the new names compress future messages. This is **accelerated Zipf**:

Instead of waiting 20 years for "митоз" to emerge from usage frequency, we mine
the gaps deliberately and coin the words in one session.

Formula:
```
compression_gain_per_message × expected_future_messages > naming_session_cost
```

For `:gate_passed`: 49 past occurrences × ~10 tokens saved = 490 tokens already worth naming.
With an expected 49 more in the next 88 documents → total ROI: 980 tokens on 1 naming decision.

---

## Implications for the Vocabulary

Three immediate actions:

1. **Add the 10 newly named patterns to `vocabulary.rb`** as named constraint/pattern atoms
2. **Add a new constraint set** `:poc_isolation_full = [no_cluster_placement, no_mutation, no_sse]` with threshold 2
3. **Document the session-level assumption protocol** — `no_sse` should be the first universal default

---

## Coverage Trajectory

| Session | Named Patterns | Vocabulary Coverage |
|---------|----------------|---------------------|
| Baseline | 0 | 0% |
| After this session | 22 | 3.2% |
| After naming top 50 gaps | ~72 | ~12% |
| After set folding | — | ~35% (via constraint sets) |
| Estimated saturation | — | ~60% (long tail always exists) |

The long tail of 477 gaps won't be fully named — Zipf's law guarantees that most patterns
are rare enough that naming them costs more than the compression gain.
The top 50 patterns cover most of the economic value.

---

## Tool Reference

```bash
# Run the miner:
ruby examples/lineup/concept_miner.rb

# Output sections:
# 1. Most Frequent Single Concepts
# 2. Frequent 2-Concept Patterns (named/gap)
# 3. Frequent 3-Concept Patterns
# 4. Vocabulary Gap Analysis
# 5. Proposed New Concept Names
# 6. The Deeper Question (experimental directions)
```

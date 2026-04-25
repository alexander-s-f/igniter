# Line-Up Approximation — Prototype

Standalone experiment. No changes to `igniter` gem.

## What This Is

A working implementation of the Line-Up compression format from
`docs/research-horizon/line-up-approximation-method.md`.

Takes a handoff message (compact or prose format) and produces a compact
structured `lineup(...)` form that preserves semantic content with fewer tokens.

## Run

```bash
ruby examples/lineup/demo.rb             # all cases + session economics
ruby examples/lineup/demo.rb compact     # compact-format cases only
ruby examples/lineup/demo.rb prose       # prose-format cases only
ruby examples/lineup/demo.rb session     # session economics only
ruby examples/lineup/demo.rb pack FILE   # pack a specific file
ruby examples/lineup/demo.rb interactive # paste text, get lineup
```

No dependencies. Pure Ruby.

## What We Found

Running against 4 real Igniter handoffs:

| Case | Format | Original | Line-Up | Ratio | Semantic |
|------|--------|----------|---------|-------|----------|
| A — Agent completion | compact | 116 tok | 113 tok | 1.03x | 5/7 |
| B — Supervisor scope | prose   | 163 tok | 113 tok | 1.44x | 6/7 |
| C — Research handoff | prose   | 193 tok | 162 tok | 1.19x | 6/7 |
| D — Blocked track    | compact |  61 tok |  86 tok | 0.71x | 3/7 |

Session break-even: **15 messages**. Saving at 50 messages: ~7.5%.

### Three Key Findings

**1. The compact micro-format is already near Line-Up density.**
Case A (1.03x) shows that the micro-format handoff we designed converges on
the Line-Up shape naturally. Compressing it further adds overhead.
→ The micro-format IS the Line-Up for completion messages.

**2. Prose handoffs benefit significantly from compression.**
Case B (1.44x) shows that explanatory prose ("This track is explicitly
documentation-only. No shared interaction package, runtime object...") compresses
to a single named set reference (`forbid: [:docs_only_scope]`).
→ The value is eliminating repeated constraint prose, not reformatting structure.

**3. Constraint set folding is the highest-yield compression step.**
Without folding: 6 forbid atoms (~25 tokens). With folding: 1 set name (~4 tokens).
A shared vocabulary of named constraint sets (`:docs_only_scope`,
`:interactive_poc_guardrails`, `:activation_safety`) provides the biggest
compression gain per token invested.
→ `constraints.md` is not just documentation — it is the compression dictionary.

### What Line-Up Does Not Help With

- Messages < 80 tokens (overhead > saving; see Case D)
- Messages that are already in micro-format (already at Line-Up density)
- Blocker messages where the blocker text must be preserved as residue

## Architecture

```
lib/
  line_up.rb     — LineUp::Record struct with to_lineup / to_prose / token_count
  vocabulary.rb  — Domain registry: roles, concepts, frames, constraint patterns + folding
  packer.rb      — Text → LineUp (format detection, field extraction, constraint recognition)
  scorer.rb      — Semantic score, compression ratio, repair cost, net value, session economics
demo.rb          — 4 real test cases + aggregate + session economics
```

The packer is deliberately **rule-based** (no LLM, no external deps). It uses:
1. Structural parsing of labeled fields
2. Vocabulary pattern matching (regex → atom)
3. Constraint recognition and set folding

## The Economic Formula

From `docs/research-horizon/grammar-compressed-interaction.md`:

```
grammar_cost + pack_cost + repair_cost < repeated_context_cost
```

Measured at 50 messages/session:
- Grammar cost: 200 tokens (shared vocabulary, once per session)
- Pack cost: ~119 tokens × 50 = 5,950 tokens
- Repair cost: ~12 tokens × 50 = 600 tokens (avg 0.5 missing fields)
- **Total compressed: 6,750 tokens**
- Prose total: ~133 tokens × 50 = 6,650 tokens
- Net: +500 tokens saved (7.5% reduction)

The grammar pays for itself at 15 messages and compounds from there.

## What Would Improve This

**Shared vocabulary assumption.** The current packer must discover constraints
from text. If both sender and recipient share the vocabulary up front (load
`constraints.md` once at session start), the sender can write:
`forbid: :docs_only_scope` directly and the packer emits 1 atom instead of
recognizing 6+ patterns.

**LLM-assisted packing.** A small model could handle:
- Concept recognition for novel subjects not in the vocabulary
- Confidence calibration (when approximation is lossy, lower confidence)
- Residue detection (what CANNOT be approximated)

The current rule-based packer would be replaced by a thin Igniter contract:
```ruby
class PackingContract < Igniter::Contract
  define do
    input :text
    input :vocabulary        # shared VocabularyRegistry
    compute :segments,  with: [:text],               call: Segmenter
    compute :classified, with: [:segments],          call: Classifier
    compute :compressed, with: [:classified, :vocabulary], call: LineUpAssembler
    output  :lineup, from: :compressed
  end
end
```

This would be the first `igniter-lineup` package use case.

## Proposal for Igniter Integration

If this prototype proves useful in practice, the next step is:

```text
Proposal: igniter-lineup package
Goal: first-class Line-Up compression as an Igniter capability
Requires:
  - VocabularyRegistry (loads constraints.md at session start)
  - PackingContract (rule-based + optional LLM node)
  - LineUp::Record as a typed Igniter output
  - Integration with igniter-agents track handoff format
Not requires:
  - Changes to igniter-contracts or igniter-runtime
  - A parser or grammar validator
  - Any persistence layer
```

Write a `docs/dev/lineup-track.md` when pressure appears.

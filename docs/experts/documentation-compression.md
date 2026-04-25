# Documentation Compression Methodology

Date: 2026-04-25.
Author: external expert review.
Source: direct audit of docs/dev/ (66 files, 26,771 lines) and
docs/research-horizon/ (14 files, 5,219 lines).
Status: methodology specification — immediately applicable.

---

## The Diagnosis

```
docs/dev/:           66 files   26,771 lines   ~220,000 tokens
docs/research-horizon: 14 files   5,219 lines    ~43,000 tokens
total active docs:                              ~263,000 tokens
```

**92% of docs/dev files exceed 200 lines.** Three files account for 4,450 lines
(tracks-history, human-sugar-dsl-doctrine, igniter-contracts-spec). The phrase
"landed and accepted" appears 37 times — a reliable marker of accumulated
status noise.

If an agent reads the wrong set of files, it can consume 50,000+ tokens before
writing a line of code.

The cause is not that documentation is too detailed. The cause is that
**documentation is append-only** — it was never designed to be pruned.

---

## The Core Insight

**Documentation is a cache.** Like Igniter's node cache, every document has:

- a **TTL** — how long is this information valid?
- a **fingerprint** — has the underlying reality changed?
- an **invalidation rule** — what events make it stale?
- an **eviction policy** — when does it leave the active set?

Documentation that does not model these properties accumulates as stale cache
entries. The fix is not to write less — it is to **compress and evict**
systematically.

---

## 1. Content Taxonomy

Every sentence in every document belongs to one of four content types. The type
determines its lifecycle.

### Decision `[D]`

A permanent choice that was made, with a date and rationale.

```
[D 2026-04-17] Accepted handoff vocabulary: subject, sender, recipient,
evidence, obligations, receipt. No shared runtime object.
```

Decisions do not change. They accumulate *only in decision logs* — never in
prose. When referenced in a track or doctrine, they are cited by date+topic,
not repeated.

**Half-life: permanent. Compression: one line per decision, date+rationale.**

### Rule `[R]`

A constraint or guideline that agents must follow to stay in scope.

```
[R] Track files do not contain constraint lists. They cite constraint sets.
[R] Status blocks replace their predecessor, never stack.
```

Rules belong in doctrine documents or constraint sets — not in track files.
When a rule is duplicated across multiple files, it should be extracted once
and referenced.

**Half-life: semi-permanent. Compression: extract to doctrine, replace with ref.**

### Status `[S]`

The current state of something. Ephemeral by nature.

```
[S 2026-04-25] Application feedback track: active. Agent Application landed.
Agent Web pending.
```

Only the **latest** status is useful. Every previous status is a history entry.
Status blocks must carry a date and must replace (not stack on) the previous
status.

**Half-life: one cycle. Compression: prune to latest, archive the rest.**

### History `[H]`

Records of what happened. Correct but not actionable.

```
[H] Agent Application added query-string feedback. Verified smoke 74/0.
Agent Web rendered compact messages. Accepted 2026-04-25.
```

History is never needed by an agent doing current work. It is needed only when
debugging or auditing. It belongs in cold storage.

**Half-life: permanent but cold. Compression: one-line summary, move to archive.**

---

## 2. Compression Algorithm

Apply to any document that has grown beyond its useful size.

### Step 1 — Classify

Read the document. Tag every paragraph-level block with `[D]`, `[R]`, `[S]`,
or `[H]`. Blocks that resist classification get the `[?]` tag.

### Step 2 — Apply the "Would Change" Test to `[?]` blocks

For each unclassified block ask:
> If this paragraph were removed, would any agent do something differently?

- **Yes** → it is a Rule `[R]` or Decision `[D]`. Tag it and keep it.
- **No** → delete it. It is documentation theater — present but inert.

This test is the most important step. Most accumulated prose fails it.

### Step 3 — Process by type

**`[D]` Decision blocks:**
- Compress each to one line: `[D date] topic: decision summary.`
- Move to the document's Decision Log section.
- Remove the surrounding narrative.

**`[R]` Rule blocks:**
- If the rule is repeated in multiple files, extract to `constraints.md`
  or the relevant doctrine document and replace with a reference.
- If the rule is document-local, keep it in a compact Rules section.

**`[S]` Status blocks:**
- Keep only the latest status block.
- Replace the previous block with a one-line history entry in `[H]` format.

**`[H]` History blocks:**
- Compress each event to one line: `date: event summary.`
- Move all history to the document's History section or to the archive file.
- The history section is never in the document's Summary or Body — it is always
  at the bottom or in a separate file.

### Step 4 — Write the compressed document

Every compressed document has three sections, in order:

```markdown
## Summary          ← ≤ 10 lines. What this is. Current state. Agent entry.
## Body             ← Decisions + Rules only. No status. No history.
## History          ← One-line entries, newest first. Optional — move to archive.
```

If the Summary alone is enough for an agent to know what to do (or to decide
they don't need to read further), the compression succeeded.

### Step 5 — Measure

```
compression_ratio = original_lines / compressed_lines
agent_sufficiency = can_agent_act_from_summary_alone? (yes/no)
information_loss  = any [D] or [R] that disappeared without a ref? (yes/no)
```

A compression that loses a Decision or Rule is invalid. A compression that only
removes Status and History is always valid.

---

## 3. Accumulation Rules (Going Forward)

Seven rules that prevent the black hole from re-forming.

### Rule 1: Append = Replace

Every time you append a status block to a document, the previous status block
is **replaced** or summarized to one line. Net status blocks in any document:
**≤ 2** (current + immediately prior for context).

> Violation: A track file with 8 handoff blocks, each saying "landed: X".
> Correct: 1 current handoff block. The 7 previous are one-liners in History.

### Rule 2: Summary Contract

Every document > 100 lines must have a `## Summary` section as the first
section, updated every time the document changes.

```markdown
## Summary (2026-04-25)
What this is:    <one line>
Current state:   <one line>
Agent entry:     <what to read first>
What's next:     <one line>
```

If you update the document and do not update the Summary, the update is
incomplete. The Summary is the document's public contract with readers.

### Rule 3: Decision Registry

Decisions do not live in track files. They live in doctrine documents or a
shared decision log. Track files reference decisions; they do not contain them.

```
# In track file:
Decision: accepted. See [handoff-doctrine.md](./handoff-doctrine.md).

# Not in track file:
"We decided that handoffs should include subject, sender, recipient, context,
evidence, obligations, receipt, and trace because..."
```

### Rule 4: Size Budget

| Document type | Max lines | Eviction trigger |
|---------------|-----------|-----------------|
| Active (read every session) | 100 | on every new cycle |
| Track file (active) | 150 | on acceptance |
| Doctrine | 200 | on supersession |
| Reference/spec | 400 | on major revision |
| Archive entry | 50 (per entry) | never |

When a document exceeds its budget, the next write **must** include compression.
The write is not complete until the document is back within budget.

### Rule 5: Track Retirement Compression

When a track is accepted, all intermediate handoffs are compressed:

```markdown
## History
2026-04-25: accepted — 3 handoffs, App boundary + Web rendering.
             Full history: tracks-history.md#feedback-track
```

This collapses 150 lines of intermediate handoffs to 2 lines. The full history
is preserved but cold.

### Rule 6: The Dead Document Test

A document passes the Dead Document Test if:

1. It has not been referenced by any active handoff in the last 10 cycles, **AND**
2. Its Summary alone would not change what any agent does.

Documents that pass the test are candidates for archiving, not just updating.
Research documents that never graduated and track files that were superseded
are the most common candidates.

Apply the test at the start of each major cycle. The supervisor can archive
dead documents with a one-line tombstone:

```markdown
# Old Document Name
Archived 2026-04-25. Superseded by [new-document.md].
```

### Rule 7: Research Expiry

Research documents in `docs/research-horizon/` that have not been referenced
in an active track for **3 cycles** are tagged `[stale]` in the README index.
After 6 cycles without graduation, they are moved to a research archive.

Research that never graduates is not necessarily wrong — it is simply off the
execution path. Archiving does not delete it; it removes it from the active
reading set.

---

## 4. The Document Line-Up Format

Applying the grammar compression methodology (from `compression-experiment.md`)
to documents, not just handoffs.

A **Document Line-Up** is the Level-2 compression of a full document — a
structured 6–10 line summary that lets a reader decide whether to read the
full document or act directly from the Line-Up.

```text
doc_lineup(
  id:           "handoff-doctrine",
  type:         :doctrine,
  current:      "stable, accepted",
  decisions:    [
    "2026-04-17: vocabulary accepted — subject/sender/recipient/evidence/
                 obligations/receipt/trace",
    "2026-04-17: no shared runtime object"
  ],
  rules:        ref(:research_only_graduation),
  forbid:       ref(:constraints, :no_runtime, :no_new_package),
  archive:      "tracks-history.md#handoff-doctrine-track",
  agent_entry:  "read decisions; apply constraint set; no further context"
)
```

This is 10 lines vs the full 200-line doctrine document. For most agent
sessions, this is sufficient. The full document is read only when an agent
needs to understand the rationale for a decision.

### When to Generate a Line-Up

- When a document is referenced in the Active Handoffs table
- When a document is a dependency of an active track
- When an agent needs to check whether a document is relevant before deciding
  to read it in full

A Line-Up can be stored as a YAML front-matter block in the document:

```yaml
---
lineup:
  id: handoff-doctrine
  type: doctrine
  current: stable, accepted
  decisions:
    - "2026-04-17: vocabulary accepted"
    - "2026-04-17: no shared runtime object"
  forbid: [no_runtime, no_new_package]
  agent_entry: read decisions section; no further context for current work
---
```

The active tracks index can display Line-Ups instead of full document links,
reducing context cost further.

---

## 5. Applied Example — Compressing a Track File

Original: `interaction-doctrine-track.md` (before compression)

The file has:
- Decision block (supervisor acceptance): 4 lines
- Goal section: 7 lines
- Scope section (in/out): 15 lines — mostly repeated from constraints.md
- Two task descriptions: 12 lines each
- Verification gate: 8 lines
- Three handoff blocks: ~30 lines each

Total: ~120 lines.

**After applying the algorithm:**

```markdown
## Summary (2026-04-25)
What: graduated Interaction Kernel research into docs-only doctrine.
State: accepted and archived.
Agent entry: none — this track is complete.
See: handoff-doctrine.md, interaction-doctrine.md

## Decision Log
[D 2026-04-25] Accepted docs-only Interaction Doctrine.
  No shared interaction package, runtime object, browser transport, workflow
  engine, runtime agent execution, AI provider, or cluster placement.

## Rules
Forbid: :research_only (see constraints.md)
Requires: supervisor acceptance before any implementation track opens.

## History
2026-04-25: accepted — doctrine defines subject/participant/affordance/
  pending-state/surface-context/session-context/policy-context/evidence/outcome.
2026-04-25: research horizon landed doctrine.md and README link.
Full: tracks-history.md#interaction-doctrine-track
```

**Result: 120 lines → 22 lines (82% reduction). Zero information loss.**

The goal, scope, task descriptions, verification gate, and handoff blocks
are all compressible because they contain only `[H]` and `[S]` content that
has already been acted upon.

---

## 6. Prioritized Compression Targets

Applying the algorithm to the existing corpus, ordered by impact:

### Tier 1 — Immediate (active context, high read frequency)

| Document | Lines | Target | Method |
|----------|-------|--------|--------|
| `tracks-history.md` | 1,702 | 300 | Compress each entry to 3 lines |
| Any active track file | 80–150 | 60 | Apply Rule 5 (intermediate handoffs) |
| `constraints.md` | 119 | 80 | Already clean; add Line-Up front-matter |

### Tier 2 — Near-term (reference documents)

| Document | Lines | Target | Method |
|----------|-------|--------|--------|
| `human-sugar-dsl-doctrine.md` | 1,487 | 300 | Extract decisions to log; archive narrative |
| `igniter-contracts-spec.md` | 1,261 | 500 | Split: active spec vs. historical rationale |
| `application-structure-research.md` | 924 | 200 | Apply Dead Document Test; archive superseded sections |
| `differential-shadow-contractable-track.md` | 856 | 150 | Apply Rule 5; archive handoffs |

### Tier 3 — Background (research, not on active path)

| Document | Lines | Action |
|----------|-------|--------|
| Research docs older than 3 cycles | varies | Apply Research Expiry rule |
| `agent-native-application-track-proposal.md` | 742 | Dead Document Test |
| `canonical-runtime-shapes.md` | 672 | Check if superseded by current docs |

---

## 7. Tooling Path

Manual compression is the right first step — it teaches what the algorithm
actually does. Automation follows.

### Level 0: Manual (now)

Apply the algorithm by hand using the taxonomy and the Would-Change test. The
rules are the tool. Start with Tier 1 documents.

**Time cost:** 30–60 minutes per document. Do the top 5 Tier 1 documents first.

### Level 1: Front-Matter Tags (next)

Add YAML front-matter to documents marking content-type regions:

```yaml
---
doc_type: track | doctrine | reference | archive
lifecycle: active | reference | cold | speculative
budget_lines: 150
lineup:
  current: "..."
  decisions: [...]
  agent_entry: "..."
---
```

This makes documents self-describing. A simple script can flag budget violations.

### Level 2: Compression Linter

A small Ruby script that:

1. Reads front-matter
2. Counts lines vs. budget
3. Flags documents over budget with a warning
4. Detects stacked status blocks (Rule 1 violation)
5. Detects missing Summary (Rule 2 violation)
6. Reports documents past their expiry cycle (Rule 7)

```bash
bundle exec igniter docs:lint
# => warnings for 12 documents over budget
# => 3 documents missing Summary
# => 2 research docs past expiry
```

### Level 3: Line-Up Generator

A tool that reads front-matter + decisions + rules and generates a `doc_lineup`
block automatically:

```bash
bundle exec igniter docs:lineup docs/dev/handoff-doctrine.md
```

Output: the 10-line Line-Up block, ready to embed in `tracks.md` dependencies.

### Level 4: History Compression

A tool that identifies `[H]` content (handoff blocks older than the current
acceptance) and compresses them automatically, moving the archive to
`tracks-history.md`.

This is the hardest step (requires understanding which blocks are historical)
but also the highest-yield for growing projects.

---

## 8. What Must Not Be Done

- Do not compress `[D]` blocks — decisions are permanent and must be findable.
- Do not delete history — archive it. Deleted history is lost audit trail.
- Do not apply compression to documents that are actively being written; let a
  track complete before compressing.
- Do not automate Level 3+ without Level 1–2 working and validated.
- Do not create a "documentation system" — the rules are the system. The only
  tooling needed is a linter and a generator.

---

## Summary

The methodology in one page:

**Classify:** every block is Decision `[D]`, Rule `[R]`, Status `[S]`, or
History `[H]`. Unclassified blocks that fail the Would-Change Test are deleted.

**Compress:**
- `[D]` → one-line Decision Log entry (permanent)
- `[R]` → extract to doctrine or constraint set (semi-permanent)
- `[S]` → keep only latest, archive the rest (ephemeral)
- `[H]` → one-line summary, move to cold storage (permanent but cold)

**Structure:** Summary (≤10 lines) → Body (decisions + rules) → History (one-liners)

**Prevent re-accumulation:**
1. Append = Replace (no stacking status blocks)
2. Summary Contract (always update the Summary)
3. Decision Registry (decisions live in doctrine, not in tracks)
4. Size Budget (document type determines max lines)
5. Track Retirement Compression (intermediate handoffs collapse on acceptance)
6. Dead Document Test (every major cycle)
7. Research Expiry (3 cycles without graduation → tagged stale)

**The test:** if removing a sentence does not change what any agent does, the
sentence should not be there.

---

## Candidate Handoff

```text
[External Expert / Codex]
Track: Documentation Compression Methodology
Changed: docs/experts/documentation-compression.md
Accepted/Ready: ready for supervisor review
Verification: documentation-only
Needs: [Architect Supervisor / Codex] decide:
  (a) accept methodology; apply manually to Tier 1 documents now
  (b) accept methodology; add doc_type front-matter to active docs
  (c) accept as reference; apply only when documents hit budget violations
Recommendation: (a). Start with tracks-history.md compression (30 min).
It is the fastest win: 1,702 lines → ~300 lines without any information loss.
Every completed track entry can be compressed to 3 lines.
Risks: compression applied to actively-changing documents disrupts in-flight
agents. Apply only to accepted/archived tracks, never to open tracks.
```

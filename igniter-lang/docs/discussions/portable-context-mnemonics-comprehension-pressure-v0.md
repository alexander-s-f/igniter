# Discussion: Portable Context Mnemonics Comprehension Pressure v0

Card: Shadow-MN-R1-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: comprehension-pressure
Mode: discussion
Initiator: user
Track: portable-context-mnemonics-comprehension-pressure-v0

Shadow status: pressure-only. This discussion does not create canon, author
accepted grammar syntax, or authorize parser/tooling work.

Depends on:
- Shadow-MN-R1-C1-P1 (grammar options)
- Shadow-MN-R1-C2-P1 (reconstruction proof)

Question:

Can a fresh agent infer syntax meaning from the proposed mnemonic grammar
without a large manual? Does compactness hide authority boundaries? Which
symbols are intuitive vs overloaded? What would confuse non-dev agents? Can the
grammar transfer to non-code domains?

Context:
- C1-P1 (Compiler/Grammar Expert): Three grammar variants sketched — Minimal
  Readable (V1), Dense Operational (V2), Typed/Contract-Like (V3); 14-symbol
  vocabulary; 10-slot ambiguity table with recovery rules; recommends V1 for
  pressure-testing first
- C2-P1 (Research Agent): Three mnemonic packets (A/B/C) scored on 4 rubric
  questions; MN-A 6/8, MN-B 8/8, MN-C 8/8; MN-B recommended as default external
  validation seed; shadow only, no canon updates

---

[Agree]

1. **The core grammar concept is sound for its stated purpose.** Portable Context
   Mnemonics aim at one specific problem: agent context bootstrapping across
   session boundaries and model switches. For that problem, the minimal readable
   grammar (Variant 1) is well-scoped. The 4-question rubric in C2-P1 directly
   targets the failure modes that matter: goal recovery, authority boundary
   preservation, next-action clarity, and forbidden-scope-widening avoidance.
   These are the right questions.

2. **The balanced packet (MN-B) genuinely encodes the critical authority
   distinction.** MN-B preserves the hard invariant "evidence satisfied != formal
   closure != implementation authorization" in prose. The C2-P1 expansion of
   MN-B correctly recovers: who the Architect Supervisor is, what "transport-only"
   means, which blockers are closed and why, and what must not be touched. The
   score of 8/8 is plausible for a project-familiar agent.

3. **The `->` and `=` symbols are the strongest choices.** `->` for sequence and
   state transition is well-established across pseudocode, state machines, and
   flowcharts. `=` for current-state assertion is universally readable. These two
   symbols carry the most meaning-per-character in the grammar and have the lowest
   false-reading risk for agents with any programming or formal-methods background.

4. **The ultra-compact / balanced / verbose tiering is a good design.** C2-P1's
   finding that MN-A gets 6/8 and MN-B/MN-C get 8/8 maps directly to use-case
   tiers: reminder for oriented agents, default for fresh agents, and defensive
   for high-authority-risk contexts. This is not a binary "use or don't use" —
   it is a graduated compression schedule, which is the right model for context
   packets.

5. **The invariant line is doing important safety work.** `Evidence != closure !=
   auth` is the single phrase that prevents an agent from reading `B1=CLOSED` as
   `CLIImplementationAuthorized`. C2-P1 correctly identifies this as the most
   important thing to preserve. Any packet that drops this invariant regresses to
   MN-A's 6/8 on scope discipline regardless of how accurate the state
   description is.

---

[Challenge]

1. **`:` is the most dangerous symbol in the vocabulary.** In Variant 1, `:` is
   a frame operator: `AUTH:PROP036` reads "inside PROP036". In Variant 2, `:` also
   appears as a field separator inside `{}`: `B1:formal_gate`. In MN-B, `:` shifts
   role mid-packet between `"B1 closed:"` (English colon) and `AUTH:PROP036`
   (frame operator). The recovery rule ("if before `{}` or before a full claim,
   read as frame; inside `{}`, prefer field label") requires the reader to track
   structural position, which is exactly the kind of local parsing a fresh agent
   running in a token-by-token mode may not do reliably. The risk is not that the
   grammar is wrong — it is that `:` will be silently misread as either role
   without any error signal.

2. **`->` carries two semantically distinct meanings that require domain context
   to disambiguate.** `Dispatch: R49 = C1-A -> C2-X -> C3-S` uses `->` for card
   sequence (objects are cards). `PROP036.CLI: B1 = evidence_satisfied ->
   needs ArchitectFormalClosure` uses `->` for state transition (objects are
   states). A fresh agent must infer from the term names which reading applies.
   If a future mnemonic uses a blocker name that looks like a card ID (e.g.,
   `B1-A`) and a state that looks like a sequence step, the two readings collide
   without resolution. This is the grammar's primary semantic ambiguity.

3. **Variant 3 poses a canonization gravity risk.** C1-P1 names this: "looks more
   canonical than it is, which is dangerous." From external comprehension pressure:
   `Memory<Route>: Dispatch.R49 { sequence: C1-A -> C2-X -> C3-S }` resembles
   Ruby struct syntax, TypeScript interfaces, and Rust struct definitions. Any
   agent trained on those languages will pattern-match to "this is a typed record
   definition." That agent will then ask: "where is the parser?" or "which class
   does this instantiate?" — neither of which is the right question for a mnemonic.
   Variant 3 should be treated as off-limits for any external validation test
   because it will generate canonization pressure from the test model itself.

4. **`@` and `#` will fire incorrect priors for most general-purpose agents.**
   `@current-status` in a token stream will be decoded as "mention user
   current-status" by any agent whose training distribution includes GitHub
   Issues, Slack, Twitter, or social media. `#stage3` in a non-code-block context
   will be decoded as a markdown heading or GitHub hashtag. These are not edge
   cases — they are the dominant prior for `@` and `#` in most agent training
   corpora. The recovery rule ("in mnemonics, read as source authority / tag")
   requires the agent to already know it is reading a mnemonic — defeating the
   purpose of being guessable from scratch.

5. **The reconstruction rubric was scored by an agent with full project context.**
   MN-B's 8/8 score in C2-P1 was assigned by the Research Agent that produced the
   balanced packet — the same agent with access to current-status, all gate docs,
   and the full PROP-036 chain. That is not an external validation. The question
   is not whether an oriented agent can expand MN-B correctly, but whether an
   agent with only MN-B and no project context can do so. C2-P1 correctly flags
   this as the open question: "Should mnemonic quality be evaluated by fresh agents
   who have not read current-status?" The answer is yes — and it has not been done
   yet.

---

[Missing]

1. **A ground-truth disambiguation rule for `->`.** The grammar needs one
   additional rule: "if the terms flanking `->` are alphanumeric IDs of the form
   `C[0-9]-[A-Z]`, read as card sequence; otherwise read as state transition."
   This makes the disambiguation mechanical. Without it, future mnemonics will
   produce ambiguous lines as domain knowledge grows.

2. **A canonical notation for the invariant triple.** Every packet tier should
   carry a stable, compact rendering of `evidence != closure != auth`. Currently
   MN-A omits it entirely and MN-B/C use prose variants. A fixed one-line form —
   for example `Rule: Evidence != Closure != Auth` or `!(Evidence = Closure =
   Auth)` — would make the invariant copyable without paraphrase drift.

3. **A register distinguishing shadow grammar from project canon.** Every mnemonic
   packet currently requires the reader to know it is a "shadow grammar" from
   context. There is no in-packet marker that says "this is an orchestration-memory
   tool, not accepted Igniter-Lang syntax." A brief prefix like `[MN]` or the
   packet labels `MN-A/MN-B/MN-C` partially serve this, but the `[MN]` prefix
   should be stated explicitly in the grammar spec as required for all mnemonic
   blocks to prevent conflation with other project doc formats.

---

[Sharper Question]

**Top 5 comprehension risks** (in priority order):

1. **Invariant dropout** — ultra-compact packets silently drop `evidence != closure
   != auth`; a fresh agent reading `B1=CLOSED` without that invariant has a
   high probability of inferring implementation authorization. This is the failure
   mode with the highest authority-widening consequence.

2. **`:` role ambiguity** — namespace separator vs field separator vs English
   colon; no in-line signal tells the reader which role is active; the recovery
   rule requires structural position tracking that token-by-token readers may not
   perform.

3. **`->` dual semantics** — card sequence vs state transition; disambiguated
   only by term-name pattern; future mnemonics with non-standard term names
   will produce irresolvable readings.

4. **`@` / `#` prior collision** — both symbols have dominant conflicting priors
   from Markdown and social-media corpora; will produce false reads in any agent
   that has not been explicitly oriented to the mnemonic register.

5. **Variant 3 canonization gravity** — the typed record syntax looks like a
   formal language definition; external validation with Variant 3 will generate
   parser/spec questions rather than context-recovery questions; V3 should not
   appear in external validation tests.

For external two-model validation, the recommendation is:

```text
Setup:
  Two models with no access to Igniter-Lang canon docs, current-status,
  or prior session context.
  Provide only the MN-B packet verbatim.
  Do not show C1-P1, C2-P1, or any other project document.

Prompt:
  "You are reviewing a compact project context packet. Using only what
  is written below, answer:
  1. What is the current goal?
  2. Who has authority to authorize implementation?
  3. What is the next safe action?
  4. What must not be implemented yet?
  5. Is any implementation currently authorized?
  Packet: [paste MN-B]"

Evaluation:
  Score each model on the C2-P1 rubric (0-2 per question).
  Check specifically whether question 5 ("Is any implementation currently
  authorized?") is answered "no" — if either model answers "yes" or "I
  cannot tell", the invariant dropout risk (Comprehension Risk 1) is real.
  Note every symbol misread.

Pass bar:
  Both models score ≥7/8 AND both answer question 5 correctly.
  If one model fails question 5, revise the invariant line to be more
  explicit and re-test before treating the grammar as production-ready.
```

---

[Route]

**Verdict: promising-with-risks.**

The minimal readable grammar (Variant 1) and the balanced packet format (MN-B)
are genuinely useful for their stated purpose: agent context bootstrapping.
The grammar is readable, the tiering is sound, and the authority invariant is
the right load-bearing element. The risks are real but tractable:

- Risks 1 and 2 (invariant dropout, `:` ambiguity) are fixable with minor
  grammar amendments — a required invariant line form and a disambiguating rule
  for `->`.
- Risks 3 and 4 (`->` dual semantics, `@`/`#` priors) require external
  validation to measure true impact; they may not fire at all if MN-B is
  tested with the right prompt.
- Risk 5 (V3 canonization gravity) is avoided by simply not using Variant 3
  in external tests or handoffs until its shadow status is more explicitly
  marked.

Blockers: none for the shadow grammar concept.

Risks requiring validation before broader adoption:
- Invariant-dropout score on fresh-model question 5 (is implementation
  authorized?)
- `@`/`#` false-reading rate in untrained models

Next recommended surface:
- Run the two-model external validation prompt above using MN-B only;
  report per-symbol misread count and question-5 pass rate
- If both models pass: propose MN-B as the default bootstrap packet for
  new chats and cross-model handoffs
- If question 5 fails: revise the invariant line to a fixed canonical form
  and re-test before promotion
- Hold Variant 2 and Variant 3 for internal use only until the V1/MN-B
  external test passes

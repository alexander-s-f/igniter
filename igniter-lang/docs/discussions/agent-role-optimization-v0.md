# Discussion: Agent Role Optimization

Card: off-track
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: agent-role-optimization-v0
Date: 2026-05-08
Status: complete — routes to Architect Supervisor

---

## Framing

Roles emerged organically across Stage 1–3. This discussion names what the
empirical record shows: where blind zones exist, where responsibility is diluted,
where roles are over- or underloaded, and where the doc/spec lifecycle still
leaks. All proposals route to Architect Supervisor; none are self-authorizing.

---

## Evidence Base

Activation counts across all tracks (verified against `docs/tracks/`):

```
Research Agent           163 files  — most activated, owns proofs + status consolidation
Compiler/Grammar Expert  116 files  — owns language formalization + meta-corrections
Bridge Agent              86 files  — activated heavily, but scope is narrow/reactive
Meta Expert               21 files  — governance + scoreboard + gaps + cross-cutting
Applied Pressure Agent    14 files  — low activation, vague trigger
Archive/Form Expert        1 file   — nearly dormant
External Pressure Reviewer 3 discussions (S3 only)
```

Concrete signals observed across S3-R1 through S3-R4:

- `spec/ch4-fragment-classification.md` still says `fragment_class: "core | escape | oof"` — PROP-028 temporal class not reflected. This is spec-lag. No role owns the sync.
- `spec-entrypoint-sync-v0` is in current-status as an open item since S3-R1. Still not done.
- Card S3-R4-X1 requested borrowed lens `runtime-systems-reviewer` — not in the allowed list. The lens needed a name; the role system had no slot.
- Bridge Agent's Ledger/Rust gap (rb_range_by_valid_time, rb_at_bi) identified by external review in S3-R2. No Bridge Agent track was opened despite being in TBackend lane.
- Research Agent owns status consolidation AND proof authoring — two different cognitive modes assigned to one role.
- META-EXPERT-012 (doc lifecycle) is a methodology document authored by Meta Expert. The methodology exists; enforcement is unclear because no role has a per-round lifecycle check obligation.
- Applied Pressure Agent: last substantive activation was Stage 2 domain scenarios. Zero S3 cards. The role exists but the trigger condition is not clear enough to reliably activate it.
- Archive/Form Expert: 1 track in all history, never activated in Stage 3.

---

## [Agree]

**The core two-role spine (Research Agent + Compiler/Grammar Expert) works well.**

Research Agent = make things executable. Compiler/Grammar Expert = specify what
things are. This split is clean and proven across 250+ tracks combined. Do not
restructure this spine.

**Meta Expert's governance and gap-identification function is essential.**

Stage boundaries (META-EXPERT-007, 009.1, 011) required exactly the kind of
cross-cutting synthesis Meta Expert does. This function cannot be distributed.

**External Pressure Reviewer adds concrete value when triggered.**

Three S3 discussion documents each found code-level issues (crash on `"expr"`,
manifest collapse to `"mixed"`, `contract_index` absence). The pressure loop
→ Architect Supervisor → requirements → tracks is working. Keep the role,
extend the lens list.

---

## [Challenge]

### C-1. No role owns spec actuality

`docs/spec/` has 9 chapters. They are frozen at Stage 1/Stage 2 close state.
PROP-028 introduced `TEMPORAL` as a fragment class in S3-R2. `ch4-fragment-
classification.md` still says `"core | escape | oof"`. No one is responsible
for the sync. META-EXPERT-012 names the `spec-lag` constraint (spec may not
lag more than one stage) but assigns it to no role as a standing obligation.

Consequence: language implementation and spec diverge silently. A new agent
reading `ch4` gets wrong information about the fragment class hierarchy.

### C-2. Research Agent carries two incompatible loads

The role profile gives Research Agent ownership of:
- practical proofs, runtime experiments, fixtures
- **status consolidation**

Proof authoring is deep-focus work: build experiment, run proof, write golden.
Status consolidation is survey work: read all tracks, synthesize, update scoreboard.
These compete for the same agent slot within a round. In S3, a dedicated
"Status Curator" identity appears in track headers (e.g., `S3-R3-C7-S`), which
is an informal workaround for this tension.

### C-3. Bridge Agent is reactive-only — Ledger/Rust gaps sat uncovered

Bridge Agent's profile: "owns explicit bridge requests." The TBackend lane in
S3 includes a known Ledger Rust gap (O(n) scan for History[T] range, rb_at_bi
unimplemented). This was identified by external review in S3-R2. No Bridge
Agent track opened for it. The gap is visible but has no proactive owner in the
current role structure — Bridge Agent only moves when explicitly handed a bridge
request.

### C-4. Archive/Form Expert is a dormant role

1 activation in the project lifetime. The role is well-defined but the trigger
is rare (archaeology, historical signal preservation). Maintaining a full role
profile for a function that activates once per stage (if that) adds overhead
without proportional value.

### C-5. Applied Pressure Agent trigger is too vague

"Longer, less frequent, high-signal slices that create concrete proof/formalization
requests." When exactly? In Stage 3, 0 activations. Domain scenario pressure
(Spark CRM, OSINT, cluster) was handled ad-hoc inside Research Agent and
Compiler/Grammar Expert slices. The role has value when triggered but the
trigger condition is not precise enough to reliably invoke it.

### C-6. `runtime-systems-reviewer` lens has no slot

S3-R4-X1 card assigned a borrowed lens that doesn't exist in the allowed list.
The review still happened (using applied-pressure-agent as substitute), but the
system self-diagnosed a gap: there is pressure that looks like "runtime
implementation / production gap / cache staleness" that doesn't map cleanly
to any existing lens.

---

## [Missing]

### M-1. Per-round spec-sync obligation

No role has an explicit obligation to check `docs/spec/` for lag after each
round closes. META-EXPERT-012 defines the constraint; no role profile says "I
check this." The result: spec-lag accumulates until someone notices (or a
new agent reads stale spec and goes wrong).

Minimal fix: add a per-round checklist item to Meta Expert's round-close
responsibilities, or add spec stewardship to Compiler/Grammar Expert's profile.

### M-2. Status consolidation identity without a role profile

"Status Curator" appears in headers (`S3-R3-C7-S`) but has no role profile in
`roles/`. It's an informal workaround for the Research Agent + Meta Expert
tension around round-close status updates. Either this should be absorbed into
Meta Expert explicitly, or given a proper one-page profile.

### M-3. Proactive integration monitoring — no owner

Who notices when a platform integration gap (Ledger Rust method, TBackend
capability) sits uncovered for multiple rounds? Currently: External Pressure
Reviewer, incidentally. This is not a designed ownership. It works when the
reviewer happens to look; it fails when the reviewer is not triggered.

---

## [Sharper Question]

Not: "Should we restructure all 7 roles?"

The sharper question is:

> **Which three targeted interventions would close the blind zones with minimal
> disruption to the working spine?**

Proposed answer — three interventions only:

### Intervention 1: Assign spec stewardship to Compiler/Grammar Expert

Add to C/G Expert profile: "per-round obligation to flag `spec-lag` — spec
chapters that do not reflect accepted PROPs or closed stage evidence."

No new role. One paragraph addition. Closes M-1 and C-1.
Trigger: after each round closes, C/G Expert checks `docs/spec/` against
current-status PROP map. If lag exists → opens `spec-sync-vN` track.

### Intervention 2: Split status consolidation from Research Agent into Meta Expert

Remove "status consolidation" from Research Agent profile.
Add to Meta Expert profile: "owns round-close status consolidation — updates
`current-status.md` and `tracks/README.md` after each round."

This formalizes what the Status Curator workaround already does. Status Curator
is not a separate role — it is Meta Expert in round-close mode.

No new role. Reduces Research Agent's split focus. Closes C-2.

### Intervention 3: Add `runtime-pressure` to External Pressure Reviewer's allowed lens list

Add to `roles/external-pressure-reviewer.md` allowed borrowed lenses:
`runtime-pressure` (maps to: production implementation risk, proof-vs-production
gap detection, cache semantics, load/evaluate contract enforcement).

One line addition. Closes C-6. Makes S3-R4-X1-style cards formally valid.

---

### Deferred (not in the three interventions — route to backlog)

**Bridge Agent proactive scope** — expand to include "proactive integration
health monitoring" for platform gaps (Ledger Rust methods, TBackend bindings).
This is valuable but requires a larger profile rewrite. Defer until TBackend
lane has a concrete next-round track.

**Archive/Form Expert merge** — merge into Meta Expert as "archaeology mode"
(explicit parameter on a card, not a separate role profile). Archive/Form Expert
activates ~once per stage, which does not justify a standing separate role.
Defer until Meta Expert profile is updated after Interventions 1-2 land.

**Applied Pressure Agent trigger clarification** — add an explicit trigger
example: "when a real application (Spark CRM, OSINT, cluster) needs domain
pressure against a language or runtime surface that is being proposed or
implemented this round." Low priority; the role works correctly when assigned;
the issue is only that it is underutilized.

---

## [Route]

→ **Architect Supervisor** — decides whether Interventions 1, 2, 3 are
accepted, modified, or deferred.

→ If accepted: **Meta Expert** — updates `roles/compiler-grammar-expert.md`,
`roles/research-agent.md`, `roles/meta-expert.md`, and
`roles/external-pressure-reviewer.md` with the specific text changes implied.
Does not restructure role files from scratch; adds targeted paragraphs.

→ If deferred work (Bridge Agent, Archive/Form merge, Applied Pressure trigger)
becomes active: separate round slice, separate card.

---

## Compact summary table

| Problem | Severity | Proposed fix | Effort |
|---------|----------|-------------|--------|
| Spec-lag, no per-round sync owner | High — agents read wrong spec | C/G Expert adds spec steward paragraph | 1 paragraph |
| Research Agent split focus (proofs + status) | Medium — informal workaround exists | Status consolidation → Meta Expert | 2 paragraph moves |
| `runtime-pressure` lens missing | Low-Medium — workaround works, but gap is named | Add to allowed lens list in reviewer profile | 1 line |
| Bridge Agent reactive-only | Medium — Rust/Ledger gaps sit uncovered | Backlog: expand to proactive monitoring | Full profile revision (deferred) |
| Archive/Form Expert dormant | Low — overhead without activation | Backlog: merge into Meta Expert archaeology mode | Profile merge (deferred) |
| Applied Pressure Agent vague trigger | Low — activates when assigned, just rare | Backlog: add explicit domain-trigger examples | 1 paragraph (deferred) |

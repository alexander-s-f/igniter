# Igniter-Lang Agent Instance Routing

Status: active onboarding protocol
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-12

---

## Purpose

This file tells an Igniter-Lang agent instance how to decide which startup route
to use before doing assigned work.

The goal is to keep new and returning agents from reconstructing the whole
project, while still allowing multiple instances of the same role to work in
parallel without overwriting each other.

This protocol is not canon. If it conflicts with `docs/agent-context.md`,
`docs/current-status.md`, the assigned gate, or the assigned card, the current
maps and assigned card win.

---

## Route Decision Table

| Situation | Route | Use when |
| --- | --- | --- |
| New chat / fresh agent | `INIT` | You have no previous handoff in this chat or were just assigned a role. |
| Existing chat, new card | `UPDATE` | You already know the role, but a new card/round/stage state was assigned. |
| Existing chat, same card still in progress | `IN_FLIGHT_REFRESH` | You are midway through a slice and need to re-check changed maps or neighbor work. |
| Returning after delay | `STALE_REFRESH` | Your last card is older than the current round, a stage/gate changed, or same-role agents may have landed newer work. |
| Discussion mode | `DISCUSSION` | The card says `Mode: discussion`. |
| Stage-level / long-cycle role | `STAGE_LOOP` | The role is assigned a broad stage packet rather than one per-round card. |

---

## INIT Route

Use for a brand-new agent instance.

Read:

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. assigned role profile in `igniter-lang/roles/`
4. role onboarding card in `igniter-lang/handoff/onboarding-<role-id>-v0.md`
5. `igniter-lang/docs/agent-context.md`
6. `igniter-lang/docs/current-status.md`
7. `igniter-lang/docs/operating-model.md`
8. assigned card source files only

Output before work:

```text
Route: INIT
Role:
Card:
Current stage/round observed:
Neighbor risk:
```

Then execute the assigned slice.

---

## UPDATE Route

Use when the same agent instance receives a new card.

Read:

1. assigned new card
2. `docs/current-status.md`
3. `docs/agent-context.md` only if current-status says the horizon changed
4. role onboarding card only if the stage/gate/role surface changed
5. source files named by the new card

Check:

- Did the stage or gate state change since your last card?
- Did another instance of your role land a newer track?
- Did your role onboarding card change?
- Does the new card suffix (`P1`, `P2`, `A`, `I`, `S`, `B`) change dispatch
  behavior?

Output before work:

```text
Route: UPDATE
Previous card:
New card:
New reads:
Skipped broad reads:
```

---

## IN_FLIGHT_REFRESH Route

Use when you are already working but need to re-check state.

Read only:

1. `git status --short`
2. assigned card
3. files you are editing
4. specific neighboring files that changed and affect your slice

Do not restart from the top of the documentation stack.

Output in handoff:

```text
Route used during slice: IN_FLIGHT_REFRESH
Reason:
Neighbor files observed:
```

---

## STALE_REFRESH Route

Use when your previous card may be stale.

Stale triggers:

- current round is later than your previous card's round;
- stage changed;
- a gate/decision touched your role's allowed surface;
- `docs/current-status.md` lists same-role work after your previous card;
- worktree contains relevant uncommitted neighbor files;
- supervisor says "update", "refresh", "podkhvati", or assigns a new round.

Read:

1. `docs/current-status.md`
2. `docs/tracks/README.md` or the specific latest status-curation track named
   by current-status
3. role onboarding card if it may have changed
4. assigned card
5. assigned source files

Output before work:

```text
Route: STALE_REFRESH
Previous known card:
Latest observed round:
Same-role newer work:
Gate/status changes:
```

---

## DISCUSSION Route

Use when `Mode: discussion` is assigned.

Read:

1. assigned card
2. role profile
3. `docs/discussions/README.md`
4. source docs named by the discussion card

Do not edit canon. Produce a discussion doc with:

```text
[Agree]
[Challenge]
[Missing]
[Sharper Question]
[Route]
```

---

## STAGE_LOOP Route

Use for long-cycle roles such as History Curator or Applied Pressure Agent when
assigned a stage packet.

Read:

1. role profile
2. role onboarding card
3. stage packet / assigned source set
4. `docs/current-status.md` at the start of each internal pass

Self-manage internal passes, but do not widen write authority. End each pass
with a compact handoff that states whether the stage packet should continue,
pause, or request a supervisor decision.

---

## Multi-Instance Rule

Multiple instances of the same role may exist.

Never assume:

- you are the only Research Agent / Meta Expert / Implementation Agent;
- your previous mental model is current;
- uncommitted files are yours;
- a role owns a file tree exclusively.

Always assume:

- assigned card scope is the write boundary;
- current maps are the communication channel;
- neighbor changes are intentional until proven otherwise;
- handoff clarity is how the swarm synchronizes.

---

## Minimal Startup Statement

Every agent should include this compact line near the start of its response or
track:

```text
Route: INIT | UPDATE | IN_FLIGHT_REFRESH | STALE_REFRESH | DISCUSSION | STAGE_LOOP
Card:
Role:
Stage/Round observed:
```

This makes dispatch state visible without requiring a long explanation.

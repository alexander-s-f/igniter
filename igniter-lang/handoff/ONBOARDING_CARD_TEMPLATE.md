# Onboarding Card Template

Use this template for role-specific launch capsules in `igniter-lang/handoff/`.

Recommended filename:

```text
onboarding-<role-id>-v0.md
```

---

```text
# Onboarding Card — <Role Name>

Card: <ONBOARD-CARD-ID>
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track: igniter-lang/onboarding-<role-id>-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh `[Igniter-Lang <Agent Name>]` instance.
Read after the role profile and before doing assigned work.

This card is a launch capsule, not canon. If it disagrees with
`agent-context.md`, `current-status.md`, or the role profile, those documents
win and this card should be refreshed.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/<role-profile-id>.md`
4. `igniter-lang/handoff/INSTANCE_ROUTING.md`
5. choose your route: `INIT`, `UPDATE`, `IN_FLIGHT_REFRESH`,
   `STALE_REFRESH`, `DISCUSSION`, or `STAGE_LOOP`
6. follow the route-specific reads
7. assigned track/proposal/source docs only

Do not read archives, old tracks, package docs, or external project docs unless
the assigned card names them.

---

## Instance Route Check

Before work, write:

```text
Route:
Card:
Role:
Stage/Round observed:
Previous known card:
Same-role newer work:
```

If this is a fresh chat, use `Route: INIT`. If your last card is older than the
current round or same-role agents may have landed newer work, use
`Route: STALE_REFRESH`. If you are continuing the same card and only checking
neighbor changes, use `Route: IN_FLIGHT_REFRESH`.

---

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after any role-profile
  update, and after gate/status shifts that affect this role.
- Multiple instances of the same role may work asynchronously. Do not assume
  exclusive ownership of a role, track family, or file tree.
- Treat `agent-context.md`, `current-status.md`, gate docs, and the assigned
  card as the communication channel until native agent-to-agent messaging exists.
- Leave compact handoff notes with decisions, risks, blockers, and neighbor
  requests so the swarm can self-organize across restarts.

---

## Current Entry State

```text
Stage:
Gate state:
Primary lane:
Closed surfaces:
Open surfaces:
Blocked surfaces:
```

---

## Owns In Practice

- ...

## Does Not Own

- ...

---

## Quality Bar

Before claiming `done`:

1. ...
2. ...
3. ...

---

## Recommended First Slices / Stage Packet

```text
Card or Stage:
Track:
Goal:
Acceptance:
```

---

## Handoff Format

Card:
Agent:
Role:
Track:
Status:

[D] Decisions
- ...

[S] Shipped / Signals
- ...

[T] Tests / Proofs
- ...

[R] Risks / Recommendations
- ...

[Q] Open questions
- ...

[Next] Suggested next slice
- ...
```

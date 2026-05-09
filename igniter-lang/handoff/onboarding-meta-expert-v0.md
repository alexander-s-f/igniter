# Onboarding Card - Meta Expert

Card: S3-ONBOARD-META-1
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: igniter-lang/onboarding-meta-expert-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh Meta Expert instance.

This role owns strategic analysis, gap identification, governance routing, and
Status Curator mode for round-close map updates.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/meta-expert.md`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. `igniter-lang/docs/operating-scheduler.md`
8. this file
9. assigned tracks/discussions/gate docs only

Read `docs/value-index.md` for strategy, curation, or stage planning.

---

## Current Entry State

```text
Stage: Stage 3 open
Gate 3 request: drafted; HOLD pending revision
Next controlling route: runtime-temporal-executor-gate3-request-revision-v0
Gate approval: Architect-only; not Meta-owned
Status Curator: Meta mode for round-close maps
```

---

## Owns In Practice

- strategic gap analysis
- meta-proposals
- status curation when assigned
- gate request authoring when assigned
- lifecycle/debt routing
- next-round recommendations

## Does Not Own

- implementation code
- final Architect approval
- formal grammar authority unless explicitly assigned
- package integration
- broad archive compression unless assigned

---

## Quality Bar

Before claiming `done`:

1. Gate/request/proof/implementation states are separated.
2. Current maps change only from landed evidence.
3. Recommendations are routable as cards.
4. Durable signals are hoisted sparingly.

---

## Recommended Current Slices

```text
Track: runtime-temporal-executor-gate3-request-revision-v0
Goal: apply X1 HOLD edits to the Gate 3 request before Architect review.
```

```text
Mode: Status Curator
Track: stage3-round-status-curation-v0
Goal: close a round by updating current-status, tracks index, agent-context,
      and value-index only where durable.
```

---

## Handoff Reminder

End with: decisions, updated maps, gate state, risks, next route, and whether
Architect decision is requested or still blocked.

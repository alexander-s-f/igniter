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

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after role-profile
  updates, and after gate/status shifts that affect governance routing.
- Multiple Meta Expert / Status Curator instances may work asynchronously. Do
  not assume exclusive ownership of map maintenance unless assigned.
- Use assigned cards, track handoffs, discussion docs, and compact neighbor
  requests as the communication channel until native agent messaging exists.

---

## Current Entry State

```text
Stage: Stage 3 open
Gate 3 Phase 1: signed-approved-restricted live read (R20)
Phase 1 production durable audit: bounded implementation authorized by Architect decision (S3-R30-C1-A)
Still closed: production deployment, Ledger/Phase 2, BiHistory, stream/OLAP production executor,
              production cache, concrete HSM/KMS onboarding, broad RuntimeMachine binding
Current route: R30 decision/proof/governance consolidation
Gate approval: Architect-only; Meta may request/review/reroute but never approve
Status Curator: Meta mode for round-close maps
```

Controlling live maps:

- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`

If this onboarding card disagrees with those maps, the maps win and this card is
stale.

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
Track: stage3-round-status-curation-v0
Goal: close a round by updating current-status, tracks index, agent-context,
      and value-index only where durable.
```

```text
Track: semantic-governance-heat-map-v0
Goal: expose drift between Covenant, spec, PROP, compiler/runtime, and proof
      anchors using the CSM and current maps.
```

```text
Track: covenant-promise-enforcement-path-rule-v0
Goal: make every Covenant promise declare an enforcement path:
      enforced / planned PROP / spec_candidate / doctrine-only.
```

```text
Track: prop032-assumptions-draft-routing-v0
Goal: route Gap-H assumptions work as a single active Language Lane vector,
      without opening form/loops/constraints/effect surface in parallel.
```

---

## Handoff Reminder

End with: decisions, updated maps, gate state, risks, next route, and whether
Architect decision is requested or still blocked.

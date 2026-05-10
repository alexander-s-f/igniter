# Igniter-Lang Handoff Cards

Status: active launch capsule index
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-10

---

## Purpose

This directory contains compact handoff and onboarding materials for quickly
starting fresh Igniter-Lang agent instances.

Onboarding cards are launch capsules. They are not canon. If an onboarding card
disagrees with `docs/agent-context.md`, `docs/current-status.md`, or the role
profile, the current maps win and the card should be refreshed.

---

## Role Onboarding Cards

| Role | Card |
|------|------|
| Research Agent | [onboarding-research-agent-v0.md](onboarding-research-agent-v0.md) |
| Compiler/Grammar Expert | [onboarding-compiler-grammar-expert-v0.md](onboarding-compiler-grammar-expert-v0.md) |
| Bridge Agent | [onboarding-bridge-agent-v0.md](onboarding-bridge-agent-v0.md) |
| Applied Pressure Agent | [onboarding-applied-pressure-agent-v0.md](onboarding-applied-pressure-agent-v0.md) |
| Meta Expert | [onboarding-meta-expert-v0.md](onboarding-meta-expert-v0.md) |
| Archive/Form Expert | [onboarding-archive-form-expert-v0.md](onboarding-archive-form-expert-v0.md) |
| History Curator | [onboarding-history-curator-v0.md](onboarding-history-curator-v0.md) |
| External Pressure Reviewer | [onboarding-external-pressure-reviewer-v0.md](onboarding-external-pressure-reviewer-v0.md) |
| Implementation Agent | [onboarding-implementation-agent-v0.md](onboarding-implementation-agent-v0.md) |

## Templates

- [START_PROMPT.md](START_PROMPT.md)
- [HANDOFF_TEMPLATE.md](HANDOFF_TEMPLATE.md)
- [ONBOARDING_CARD_TEMPLATE.md](ONBOARDING_CARD_TEMPLATE.md)

## Refresh Rule

Refresh role onboarding cards:

- at every stage open;
- at least once during each active stage when the status surface changes
  materially;
- at every stage close;
- after a role profile changes;
- after gate/request state changes a role's allowed work;
- when agents report doc/code/status drift during startup.

## Swarm Rule

Multiple instances of the same role may work asynchronously. Onboarding cards
must teach agents not to assume exclusive ownership of a role or track family.
Until native agent-to-agent communication exists, the swarm communicates through
assigned cards, track handoffs, discussion docs, gate/status maps, and compact
neighbor requests.

# Onboarding Card - External Pressure Reviewer

Card: S3-ONBOARD-XPR-1
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: igniter-lang/onboarding-external-pressure-reviewer-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh External Pressure Reviewer instance.

This role provides fresh-context critique, comprehension pressure, product and
runtime risk review, and discussion output. It routes work; it does not author
canon.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/external-pressure-reviewer.md`
4. `igniter-lang/handoff/INSTANCE_ROUTING.md`
5. choose route: `INIT`, `UPDATE`, `IN_FLIGHT_REFRESH`, `STALE_REFRESH`,
   `DISCUSSION`, or `STAGE_LOOP`
6. follow the route-specific reads
7. `igniter-lang/docs/discussions/README.md`
8. this file
9. assigned discussion/source docs only

Do not read broad history unless the assigned review target requires it.

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

Use `INIT` for a fresh chat, `UPDATE` for a new card in an existing chat,
`STALE_REFRESH` when your previous card is older than the current round or same-role agents may have landed newer work, and `IN_FLIGHT_REFRESH` for a minimal mid-slice check.

---

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after role-profile
  updates, and after gate/status shifts that affect the review target.
- Multiple External Pressure instances may work asynchronously, including
  cross-tests with different context windows. Do not assume yours is the only
  pressure lens.
- Use discussion docs, assigned cards, handoff notes, and compact neighbor
  requests as the communication channel until native agent messaging exists.

---

## Current Entry State

```text
Stage: Stage 3 open
Gate 3 Phase 1: signed-approved-restricted live read (R20)
Phase 1 production durable audit: bounded implementation authorized (S3-R30-C1-A)
Still closed: production deployment, Ledger/Phase 2, BiHistory, stream/OLAP production executor,
              production cache, concrete HSM/KMS onboarding, broad RuntimeMachine binding
Useful lenses: runtime-pressure, product-pressure, comprehension-pressure,
               implementation-pressure, meta-pressure
Authority: may borrow a lens when assigned, but never Architect authority
```

---

## Owns In Practice

- external/fresh critique
- discussion docs in `docs/discussions/` when assigned
- risk tables
- comprehension tests
- route recommendations: PROP / track / review / backlog / reject

## Does Not Own

- canon/spec/status updates
- implementation
- formal PROP authorship
- gate approval
- direct package changes

---

## Quality Bar

Before claiming `done`:

1. Target and borrowed lens are explicit.
2. Findings separate blocker, risk, and backlog.
3. Output routes to concrete next work or rejection.
4. It does not imply authorization.

---

## Recommended Current Uses

```text
Mode: discussion
Track: r30-durable-audit-implementation-pressure-v0
Goal: verify bounded audit implementation work does not widen into deployment,
      Ledger, Phase 2, production cache, or real key management.
```

```text
Mode: review
Track: syntax-comprehension-pressure-v0
Goal: test source examples for human/agent comprehension and monotony risks.
```

---

## Handoff Reminder

End discussions with `[Agree]`, `[Challenge]`, `[Missing]`,
`[Sharper Question]`, and `[Route]`.

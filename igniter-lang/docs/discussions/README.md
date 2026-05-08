# Igniter-Lang Discussions

Status: active process surface
Owner: `[Architect Supervisor / Codex]`

## Purpose

Discussions are bounded debates used before a proposal, track, or rejection is
clear.

They are not canonical specs, not implementation tracks, and not global status
logs. A discussion captures pressure between roles and ends by routing the
question.

Use discussions when:

- an idea is promising but still under-shaped;
- two or more role lenses should challenge the same question;
- external review should be tested before becoming requirements;
- the user, Architect Supervisor, or Meta Expert wants a compact debate before
  slicing work.

## Directory Rules

```text
docs/discussions/
  README.md                  # this file
  templates/
    discussion-card.md       # copyable card template
  <discussion-name>.md       # accepted discussion records
```

Discussion files should be compact. If a discussion produces work, create a
separate track/proposal/backlog item and link back to the discussion.

## Initiators

Discussion can be initiated by:

- the user
- `[Architect Supervisor / Codex]`
- `[Igniter-Lang Meta Expert]`

Other agents may recommend a discussion in handoff, but should not open one
without routing through an initiator.

## Participants

Allowed participants:

- any active Igniter-Lang role
- `[Igniter-Lang External Pressure Reviewer]`
- user-provided outside review text

External Pressure Reviewer may borrow another role lens for one discussion card,
except Architect Supervisor.

## Required Card Shape

```text
Card: <Stage-Round-Card-Suffix>
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Mode: discussion
Initiator: user | architect-supervisor | meta-expert
Borrowed lens: <optional role id>
Track: <discussion-name>

Question:
...

Context:
- ...

Deliver:
- [Agree]
- [Challenge]
- [Missing]
- [Sharper Question]
- [Route]
```

## Output Shape

Every discussion response should end with:

```text
[Agree]
- What the participant accepts.

[Challenge]
- What the participant contests or reframes.

[Missing]
- What information, proof, formalization, or scenario is absent.

[Sharper Question]
- The smallest better question to ask next.

[Route]
- PROP / track / review / backlog / reject / keep-discussing
```

## Routing Semantics

| Route | Meaning |
|-------|---------|
| `PROP` | Formal language proposal needed. Usually Compiler/Grammar Expert owns next. |
| `track` | Executable proof, fixture, or implementation slice needed. |
| `review` | More external/role pressure is needed before work starts. |
| `backlog` | Worth preserving, not current priority. |
| `reject` | Do not pursue; record why. |
| `keep-discussing` | Question is still too broad or unstable. |

Discussion output does not authorize implementation by itself.

## Naming

Use compact names:

```text
temporal-fragment-cache-semantics-discussion-v0.md
entrypoint-section-entity-surface-discussion-v0.md
ledger-tbackend-runtime-binding-discussion-v0.md
```

## Index

| File | Card | Question | Status |
|------|------|----------|--------|
| [temporal-fragment-and-cache-key-pressure-discussion-v0.md](temporal-fragment-and-cache-key-pressure-discussion-v0.md) | S3-R2-X1-S | Do PROP-028 + temporal-cache-key-proof close the silent staleness class? | complete — routed |

---

## Guardrails

- Do not use discussions as a daily log.
- Do not promote fixture syntax to canon from discussion alone.
- Do not edit `current-status.md` from a discussion unless explicitly assigned.
- Do not use discussion to bypass proposal or track acceptance.
- Keep external review clearly labeled as external pressure.


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

When using external/read-only reviewers as cross-tests, label the context level
explicitly:

```text
Context: public-github-only
Write access: none
Canon authority: none
```

See `../agent-orchestra-pattern.md` for the wider role/lens/authority pattern.

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
| [temporal-manifest-and-cache-boundary-pressure-v0.md](temporal-manifest-and-cache-boundary-pressure-v0.md) | S3-R3-X1-S | Does TEMPORAL survive Classifier → SemanticIR → Assembler → RuntimeMachine? | complete — routed |
| [temporal-igapp-runtime-boundary-pressure-v0.md](temporal-igapp-runtime-boundary-pressure-v0.md) | S3-R4-X1-S | Did S3-R4 make temporal `.igapp/` safe enough for proof-local RuntimeMachine loading? | complete — routed |
| [agent-role-optimization-v0.md](agent-role-optimization-v0.md) | off-track | Agent role blind zones, diluted responsibilities, and three targeted optimizations | complete — routes to Architect Supervisor |
| [typed-emission-and-temporal-loader-pressure-v0.md](typed-emission-and-temporal-loader-pressure-v0.md) | S3-R5-X1-S | Are typed emission + temporal manifest index safe as the Stage 3 artifact path? | complete — routed |
| [docs-context-and-spec-sync-pressure-v0.md](docs-context-and-spec-sync-pressure-v0.md) | S3-R6-X1-S | Will a fresh agent starting from agent-context/current-status/spec avoid full project reconstruction? | complete — routed |
| [runtime-compatibility-and-typed-delta-pressure-v0.md](runtime-compatibility-and-typed-delta-pressure-v0.md) | S3-R7-X1-S | Are S3-R7 C1-C3 runtime/compatibility/typed-delta results safe as a pre-Gate-3 boundary layer? | complete — routed |
| [stage3-round8-pre-gate3-pressure-v0.md](stage3-round8-pre-gate3-pressure-v0.md) | S3-R8-X1-S | Are S3-R8 C1-C2 full-coverage smoke and executor-boundary report sufficient before Gate 3? | complete — routed |
| [gate3-prerequisite-package-pressure-v0.md](gate3-prerequisite-package-pressure-v0.md) | S3-R9-X1-S | Is the S3-R9 Gate 3 prerequisite package coherent enough to prepare a Gate 3 opening request? | complete — routed |
| [gate3-request-readiness-pressure-v0.md](gate3-request-readiness-pressure-v0.md) | S3-R10-X1-S | Is the S3-R10 evidence sufficient to draft a Gate 3 opening request, and what makes it unsafe now? | complete — routed |
| [gate3-request-safety-pressure-v0.md](gate3-request-safety-pressure-v0.md) | S3-R11-X1-S | Is the Gate 3 request safe to route to Architect as written, or does it contain unsafe ambiguity? | complete — hold for two edits |
| [gate3-request-revision-safety-pressure-v0.md](gate3-request-revision-safety-pressure-v0.md) | S3-R12-X1-S | Did the S3-R12-C1 revision close both HOLD blockers cleanly without introducing new ambiguity? | complete — proceed to Architect |
| [gate3-decision-safety-pressure-v0.md](gate3-decision-safety-pressure-v0.md) | S3-R13-X1-S | Does the Gate 3 decision record contain hidden authorization leaks or authority/revocation gaps? | complete — proceed; two doc amendments |
| [phase1-implementation-prep-safety-pressure-v0.md](phase1-implementation-prep-safety-pressure-v0.md) | S3-R14-X1-S | Did Phase 1 prep tracks stay correctly scoped with no live-eval or exclusion leaks? | complete — proceed; C4 ordering conflict + three pre-production conditions |
| [runtime-temporal-executor-lib-prep-safety-pressure-v0.md](runtime-temporal-executor-lib-prep-safety-pressure-v0.md) | S3-R17-X1-S | Did Phase1 enter lib/ with all eight scope guarantees intact after post-C1 regression? | complete — proceed; two pre-Phase-2 tracks |
| [live-read-addendum-draft-safety-pressure-v0.md](live-read-addendum-draft-safety-pressure-v0.md) | S3-R18-X1-S | Did R18 cleanup tracks leave any hidden path from "addendum drafted" to live-read enablement? | complete — proceed; two pre-signing conditions |
| [gate3-live-read-addendum-pre-signature-pressure-v0.md](gate3-live-read-addendum-pre-signature-pressure-v0.md) | S3-R19-X1-S | Are all addendum blockers closed after guard-order amendment and R19 regression rerun? | complete — PROCEED to Architect signature review |
| [gate3-post-signature-runtime-pressure-v0.md](gate3-post-signature-runtime-pressure-v0.md) | S3-R20-X1-S | Did the signature widen scope and does the post-signature fixture confirm policy-only change? | complete — PROCEED |
| [phase1-post-signature-audit-registry-pressure-v0.md](phase1-post-signature-audit-registry-pressure-v0.md) | S3-R21-X1-S | Do C1/C2 accidentally imply durable audit or production signing exist for Phase 1? | complete — PROCEED |
| [phase1-e2e-and-content-address-pressure-v0.md](phase1-e2e-and-content-address-pressure-v0.md) | S3-R22-X1-S | Do C1/C2 add production behavior or leave the mutable signed_addendum_ref gap open? | complete — PROCEED; P-4 + P-5 closed |

---

## Guardrails

- Do not use discussions as a daily log.
- Do not promote fixture syntax to canon from discussion alone.
- Do not edit `current-status.md` from a discussion unless explicitly assigned.
- Do not use discussion to bypass proposal or track acceptance.
- Keep external review clearly labeled as external pressure.

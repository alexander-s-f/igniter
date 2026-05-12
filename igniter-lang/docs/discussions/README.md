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
| [phase1-durable-audit-and-registry-v1-pressure-v0.md](phase1-durable-audit-and-registry-v1-pressure-v0.md) | S3-R23-X1-S | Do C1/C2/C3 widen Phase 1 scope, imply production audit/signing, or alter authorization semantics? | complete — PROCEED (non-blockers only); P-6 closed; P-9 added |
| [phase1-post-r23-regression-and-durability-pressure-v0.md](phase1-post-r23-regression-and-durability-pressure-v0.md) | S3-R24-X1-S | Does R24 regression honestly cover post-R23 chain; do registry/tamper-evidence imply production behavior? | complete — PROCEED (non-blockers only); P-8 + P-9 closed |
| [phase1-production-audit-scope-and-registry-ownership-pressure-v0.md](phase1-production-audit-scope-and-registry-ownership-pressure-v0.md) | S3-R25-X1-S | Is the 25-cmd regression honest; is the Architect scope decision design-only; do registry options avoid binding? | complete — PROCEED (non-blockers only); P-13 closed; C2-A blocker 2 satisfied |
| [phase1-production-durable-audit-design-pressure-v0.md](phase1-production-durable-audit-design-pressure-v0.md) | S3-R26-X1-S | Does durable audit design stay design-only; is signing recommendation not execution authorization; is audit traversal not Ledger replay? | complete — PROCEED (non-blockers only); P-10 + P-12 + P-14 closed |
| [durable-audit-authorization-and-prop031-pressure-v0.md](durable-audit-authorization-and-prop031-pressure-v0.md) | S3-R27-X1-S | Does C1-A correctly hold (not grant) audit implementation authorization? Does PROP-031 stay within its language-lane scope with no Effect Surface or service-loop leakage? | complete — PROCEED (non-blockers only); P-15 + P-16 closed; OOF-M1 stage ambiguity flagged |
| [r28-durable-audit-and-prop031-pressure-v0.md](r28-durable-audit-and-prop031-pressure-v0.md) | S3-R28-X1-S | Did R28 close durable audit blockers without authorizing implementation? Did PROP-031 stay within scope? Does the regression matrix prove new state? | complete — PROCEED (with blockers B-1/B-2); P-17+P-18+P-19+P-21+P-23 closed; 3/29 regression failures block Blk-6 |
| [r29-authorization-and-canon-pressure-v0.md](r29-authorization-and-canon-pressure-v0.md) | S3-R29-X1-S | Did Architect authorization land (C1 absent — safe deferral)? Did startup freshness override avoid policy leaks? Did Covenant/CSM clarify canon without unapproved semantics? | complete — PROCEED (non-blockers only); B-1+B-2 confirmed closed (29/29); P-24 through P-27 closed; P-28 implementation auth pending R30 |
| [r30-decision-heatmap-and-assumptions-pressure-v0.md](r30-decision-heatmap-and-assumptions-pressure-v0.md) | S3-R30-X1-S | Did R30 authorize only a bounded production durable audit implementation? Did heat map and Covenant enforcement rule reduce debt without canon drift? Did PROP-032 stay assumptions-only? | complete — PROCEED (non-blockers only); P-28+P-29+P-30+P-32 closed; P-33 through P-36 added; OQ-Filter-1 routes to Architect |
| [r31-bounded-audit-and-governance-pressure-v0.md](r31-bounded-audit-and-governance-pressure-v0.md) | S3-R31-X1-S | Did R31 authorize only bounded audit surfaces? Did governance decision close split-authority without widening scope? Does PROP-032 remain gated until Phase 1 gate passes? | complete — PROCEED (non-blockers only); P-31+P-33 through P-36 closed; P-37 through P-40 added; B-A/B-B/B-C open |
| [r32-durable-audit-prop032-and-compiler-profile-pressure-v0.md](r32-durable-audit-prop032-and-compiler-profile-pressure-v0.md) | S3-R32-X1-S | Did R32 close audit hash/posture design gaps without widening scope? Did PROP-032 Phase 1 stay Classifier-only? Does compiler_profile_id claim only understanding authority? | complete — PROCEED (non-blockers only); P-37 through P-40 closed; P-41+P-42 added; B-A unblocked |
| [r33-rebuild-prop032-profile-and-progression-pressure-v0.md](r33-rebuild-prop032-profile-and-progression-pressure-v0.md) | S3-R33-X1-S | Did R33 close B-A and PROP-032 Phase 2 without scope leaks? Does PROP-036 assignment stay numbering-only? Do progression semantics stay separate from stream and managed loops? | complete — PROCEED (non-blockers only); P-41+P-42 closed; P-43+P-44 added; PROP-036+ renaming gap flagged |
| [r34-audit-assumptions-profile-progression-pressure-v0.md](r34-audit-assumptions-profile-progression-pressure-v0.md) | S3-R34-X1-S | Did B-B/B-C/P-43/P-44 close cleanly? Did PROP-032 Phase 3 avoid PROP-033 scope? Does PROP-036 proposal block implementation? Did progression draft avoid parser/runtime authority? | complete — PROCEED (non-blockers only); P-43+P-44 closed; P-45+P-46 added; B-D now unblocked |
| [r35-durable-audit-prop036-progression-prop032-pressure-v0.md](r35-durable-audit-prop036-progression-prop032-pressure-v0.md) | S3-R35-X1-S | Did B-D cover all durable audit proofs with P-43 enforced? Did PROP-036 acceptance block implementation? Did PROP-037 assignment avoid parser/runtime/fragment class? Did Phase 4 avoid PROP-033 scope? | complete — PROCEED (non-blockers only); P-45+P-46 closed; P-47+P-48+P-49 added; C2-S stale on PROP-036/PROP-037 |
| [r36-deployment-prop032-prop036-prop037-mundane-pressure-v0.md](r36-deployment-prop032-prop036-prop037-mundane-pressure-v0.md) | S3-R36-X1-S | Did B-E avoid excluded surfaces? Did PROP-032 experiment-pass exclude PROP-033? Did PROP-037 avoid parser/runtime/fragment class? Did loader proof avoid real .igapp mutation? Did mundane extraction stay non-canonical? | complete — PROCEED (non-blockers only); P-47+P-48+P-49 closed; P-50+P-51+P-52 added; temporal specimen disposition gap flagged |
| [r37-deployment-prop037-regression-profile-pressure-v0.md](r37-deployment-prop037-regression-profile-pressure-v0.md) | S3-R37-X1-S | Did R37 close P-50/P-51/P-52 without authorizing excluded surfaces? Does PROP-037 acceptance stay bounded away from parser, runtime, and fragment class? Does the Stage 3 regression matrix honestly cover required surfaces? Does the PROP-036 hash ordering proof stay synthetic? | complete — PROCEED (non-blockers only); P-50+P-51+P-52 closed; P-53 added; C2-I handoff staleness NB flagged |
| [r38-durable-audit-prop037-prop036-docs-pressure-v0.md](r38-durable-audit-prop037-prop036-docs-pressure-v0.md) | S3-R38-X1-S | Did R38 confirm proof-local closure for P-53 without widening operational deployment? Do PROP-037 descriptor/OOF-PR design cards stay in design/proof territory? Does the PROP-036 assembler field plan defer implementation correctly? Do the Line Up summaries avoid hoisting stale pre-decision framing? | complete — PROCEED (non-blockers only); P-53 closed; P-54 added (Ch11 OOF-PR* collision); external_event naming NB; archive/form verification NB |
| [r39-p54-rollout-readiness-and-lineup-pressure-v0.md](r39-p54-rollout-readiness-and-lineup-pressure-v0.md) | S3-R39-X1-S | Did R39 close P-54 cleanly? Does the durable audit rollout readiness plan stay design-only? Does the Line Up authority-hoist review hold movement gates? Does the Gate 3 R13-R22 Line Up separate historical pressure from current authority? | complete — PROCEED (non-blockers only); P-54 closed; P-55 added (Gate 3 Line Up archive/form verification); P-56 added (apply RQ-1/RQ-2 before R2-R12 redirects); storage kind NB |

---

## Guardrails

- Do not use discussions as a daily log.
- Do not promote fixture syntax to canon from discussion alone.
- Do not edit `current-status.md` from a discussion unless explicitly assigned.
- Do not use discussion to bypass proposal or track acceptance.
- Keep external review clearly labeled as external pressure.

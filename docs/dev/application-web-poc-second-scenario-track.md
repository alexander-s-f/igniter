# Application Web POC Second Scenario Track

This track proposes a second, non-task interactive POC scenario to test whether
the accepted pattern repeats outside the task-board domain.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:interactive_poc_guardrails` from [Constraint Sets](./constraints.md)
- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next docs-only planning slice.

The pattern guide says not to promote command results, snapshots, or web
helpers from one task-board POC. The next useful move is to choose a second
small scenario that can pressure-test the same shape.

## Goal

Pick one compact non-task scenario and define its acceptance before writing
code.

Candidate scenario qualities:

- small enough for one or two implementation cycles
- not another task board
- has at least one command/refusal path
- has a read snapshot
- has visible web feedback and stable data markers
- can run through `examples/run.rb smoke`

## Scope

In scope:

- propose one or two candidate scenarios
- choose one recommended scenario
- define app-local seams, web surface, commands, snapshot, and smoke markers
- define what would prove the pattern repeated

Out of scope:

- code changes
- package API changes
- UI kit
- live transport
- generator
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Scenario Proposal

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose a compact non-task domain.
- Define service state, commands, refusals, action facts, command result, and
  snapshot fields.
- Keep it app-local and copyable.

## Task 2: Web Scenario Proposal

Owner: `[Agent Web / Codex]`

Acceptance:

- Define the mounted web surface and stable markers for the proposed scenario.
- Keep rendering snapshot-oriented.
- Avoid UI kit, redesign, live transport, or new web abstraction.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` proposes the second scenario from app structure
   needs.
2. `[Agent Web / Codex]` validates the scenario as a compact web surface.
3. `[Architect Supervisor / Codex]` accepts one scenario or pauses the POC line.

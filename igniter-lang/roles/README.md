# Igniter-Lang Roles

Status: active role index
Maintainer: `[Architect Supervisor / Codex]`

## Purpose

This directory gives every Igniter-Lang agent a role profile.

Roles and agent names are intentionally separate:

- **Role** describes responsibility, ownership, and expected output.
- **Agent name** is the concrete identity used in a handoff/chat for a slice.

An agent must work as exactly one role for a slice, read that role file, and
keep neighboring agents in mind without taking their ownership.

## Required Onboarding Reads

Every role starts from the same compact map:

1. [../AGENTS.md](../AGENTS.md) — workspace boundary and active identities
2. [README.md](README.md) — role index and neighbor map
3. the assigned role profile
4. [../docs/agent-context.md](../docs/agent-context.md) — trusted current context, gates, proof budget
5. [../docs/README.md](../docs/README.md) — documentation navigation
6. [../docs/operating-model.md](../docs/operating-model.md) — supervisor-owned flow
7. [../docs/current-status.md](../docs/current-status.md) — current scoreboard
8. [../docs/discussions/README.md](../docs/discussions/README.md) — only when
   `Mode: discussion` is assigned
9. [../docs/spec/](../docs/spec/) — canonical language chapters relevant to the slice
10. the assigned track/proposal/source docs only

Agents should not read archives, old tracks, or package docs unless the card
explicitly asks for archaeology, bridge mapping, or package pressure.

## Active Roles

| Role | File | Primary Ownership |
|------|------|-------------------|
| `[Igniter-Lang Research Agent]` | [research-agent.md](research-agent.md) | practical research, proofs, fixtures, runtime pressure, bridge-ready evidence |
| `[Igniter-Lang Compiler/Grammar Expert]` | [compiler-grammar-expert.md](compiler-grammar-expert.md) | formal semantics, grammar, type system, compiler boundaries, spec-lag stewardship |
| `[Igniter-Lang Bridge Agent]` | [bridge-agent.md](bridge-agent.md) | bridge notes from language research to Igniter platform packages |
| `[Igniter-Lang Applied Pressure Agent]` | [applied-pressure-agent.md](applied-pressure-agent.md) | real-system pressure, domain scenarios, interop/tooling pressure, rebuild experiments |
| `[Igniter-Lang Meta Expert]` | [meta-expert.md](meta-expert.md) | strategic analysis, gap identification, priority ordering, round-close status curation, meta-proposals |
| `[Igniter-Lang Archive/Form Expert]` | [archive-form-expert.md](archive-form-expert.md) | project archaeology, historical signal preservation, canon-vs-history indexing |
| `[Igniter-Lang History Curator]` | [history-curator.md](history-curator.md) | compact history reports, archive compression, duplicate-removal recommendations, value preservation |
| `[Igniter-Lang External Pressure Reviewer]` | [external-pressure-reviewer.md](external-pressure-reviewer.md) | outside review pressure, gap discovery, comprehension/product/runtime critique before internal routing |

Use [role-template.md](role-template.md) when adding a new role profile.

## Shared Neighbor Map

```text
Architect Supervisor
  -> assigns slices, reviews handoffs, resolves conflicts

Research Agent
  -> makes ideas executable or scenario-grounded
  -> should ask Compiler/Grammar Expert for formal pressure

Compiler/Grammar Expert
  -> formalizes, rejects, narrows, or corrects semantics
  -> should ask Research Agent for proof pressure

Bridge Agent
  -> translates approved language ideas into platform requests
  -> should wait for Architect approval before package integration

Applied Pressure Agent
  -> brings Spark CRM / home-lab / cluster / tooling / interop pressure
  -> should ask Research Agent for proofs and Compiler/Grammar Expert for
     formal boundaries

Meta Expert
  -> identifies gaps, priorities, and cross-cutting design directions
  -> produces meta-proposals that request formal work from neighbors
  -> owns Status Curator mode for current-status/tracks index consolidation
  -> writes to igniter-lang/docs/meta-proposals/

Archive/Form Expert
  -> indexes historical layers and preserves high-value signals
  -> applies formal pressure before routing old ideas into new work
  -> writes archaeology meta-proposals, not implementation code

History Curator
  -> inherits Archive/Form Expert archaeology discipline
  -> compresses historical layers into compact accepted/rejected/implemented/
     unimplemented/value reports
  -> recommends duplicate removal and external archive rotation
  -> writes archive history reports, not formal proposals or implementation code

External Pressure Reviewer
  -> provides outside review pressure and fresh-context critique
  -> may borrow runtime-pressure for load/evaluate/cache production-risk review
  -> does not author canon, update status, or implement code
  -> routes through Architect Supervisor and Meta Expert before becoming work
```

## Discussion Participation

Any role may participate in a bounded discussion when a card explicitly says:

```text
Mode: discussion
```

Discussion format lives in
[../docs/discussions/README.md](../docs/discussions/README.md). A discussion is
not canon, not a track, and not implementation authorization. It should end by
routing the question to one of:

```text
PROP / track / review / backlog / reject / keep-discussing
```

## Identity Rule

At the top of every authored track/proposal/handoff, write:

```text
Card: <Card ID>
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track: igniter-lang/<track-name>
```

Example:

```text
Card: S2-R10-C5-S
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/semanticir-stage2-surface-lowering-v0
```

Do not write as multiple roles in the same slice. If another role's perspective
is needed, add it as a recommendation, dependency, or question.

## Git And Workspace Rule

Agents share the same worktree.

- Do not stage, unstage, restore, remove, or clean files unless the assigned
  slice explicitly asks for git operations.
- Do not "fix" unrelated dirty files.
- Treat uncommitted files from other agents as neighbor work.
- If unrelated dirty files exist, mention them only when they block your slice.
- Keep your changed-file list in the handoff.

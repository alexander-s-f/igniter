# Igniter-Lang Roles

Status: active role index
Maintainer: `[Architect Supervisor / Codex]`

## Purpose

This directory gives every Igniter-Lang agent a role passport.

An agent must identify as exactly one role for a slice, read that role file,
and keep neighboring agents in mind without taking their ownership.

## Active Roles

| Role | File | Primary Ownership |
|------|------|-------------------|
| `[Igniter-Lang Research Agent]` | [research-agent.md](research-agent.md) | practical research, proofs, fixtures, runtime pressure, status consolidation |
| `[Igniter-Lang Compiler/Grammar Expert]` | [compiler-grammar-expert.md](compiler-grammar-expert.md) | formal semantics, grammar, type system, compiler boundaries, meta-corrections |
| `[Igniter-Lang Bridge Agent]` | [bridge-agent.md](bridge-agent.md) | bridge notes from language research to Igniter platform packages |

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
```

## Identity Rule

At the top of every authored track/proposal/handoff, write:

```text
Role: [Igniter-Lang <Role>]
Track: igniter-lang/<track-name>
```

Do not write as multiple roles in the same slice. If another role's perspective
is needed, add it as a recommendation or question.

## Git And Workspace Rule

Agents share the same worktree.

- Do not stage, unstage, restore, remove, or clean files unless the assigned
  slice explicitly asks for git operations.
- Do not "fix" unrelated dirty files.
- Treat uncommitted files from other agents as neighbor work.
- If unrelated dirty files exist, mention them only when they block your slice.
- Keep your changed-file list in the handoff.


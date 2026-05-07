# Igniter-Lang Agent Workspace

## Identity

Your handoff prompt assigns both:

- an **agent name** used in the chat/handoff
- a **role profile** that defines ownership and output shape

Current accepted default agent names:

- `[Igniter-Lang Research Agent]`
- `[Igniter-Lang Compiler/Grammar Expert]`
- `[Igniter-Lang Bridge Agent]`
- `[Igniter-Lang Applied Pressure Agent]`
- `[Igniter-Lang Meta Expert]`
- `[Igniter-Lang Archive/Form Expert]`

Before authoring anything, read [roles/README.md](roles/README.md) and the
role profile file for your assigned role.

This workspace is a separate research lab for `igniter-lang`, not a package in
the Igniter platform release loop.

## Write Boundary

You may read the whole Igniter repository for context, especially:

- `/docs`
- `/packages`
- `/examples`
- `/playgrounds/docs/experts/igniter-lang`

You may write only inside:

```text
/igniter-lang
```

Do not edit platform packages, root docs, examples, specs, or archived
playground docs unless `[Architect Supervisor / Codex]` explicitly asks for a
separate integration slice.

## Purpose

`igniter` and `igniter-lang` are related but separate ecosystems:

- `igniter` is a framework/platform for building real systems.
- `igniter-lang` is a contract-native language research ecosystem.

Do not reduce `igniter-lang` to syntax sugar for the current Ruby DSL.

The current center is no longer "start from scratch". Igniter-Lang now has a
theory-to-devkit spine:

```text
contracts + explicit time + observations
  -> ParsedProgram / SemanticIR / CompiledProgram
  -> RuntimeMachine
  -> SemanticImage + CompatibilityReport
  -> TBackend adapters
  -> schema evolution + migration receipts
```

New work should extend, correct, or pressure-test this spine. Do not replace it
with a parallel model unless the track explicitly asks for a rejection/rewrite.

## Agent Roles

Role details live in [roles/](roles/). Short map:

`[Igniter-Lang Research Agent]`

- owns practical proof tracks, runtime-machine experiments, fixtures, bridge
  pressure from real applications, and status consolidation
- may edit docs, tracks, experiments, fixtures, and proof scripts inside
  `igniter-lang/`

`[Igniter-Lang Compiler/Grammar Expert]`

- owns formal semantics, grammar, type theory, compiler stages, SemanticIR
  boundaries, and meta-corrections
- may author proposals and parser/compiler pressure maps inside
  `igniter-lang/`

`[Igniter-Lang Bridge Agent]`

- owns explicit bridge requests from language research to Igniter platform
  packages
- must not edit platform packages unless a separate integration slice is
  explicitly approved

`[Igniter-Lang Applied Pressure Agent]`

- owns real-system pressure maps, domain scenarios, interop/tooling demands,
  rebuild-from-scratch experiments, and reverse-planning/composition pressure
- should produce longer, less frequent, high-signal slices that create concrete
  proof/formalization/bridge requests for neighboring agents

`[Igniter-Lang Meta Expert]`

- owns strategic analysis, gap identification, priority ordering, and
  cross-cutting design decisions in `igniter-lang/docs/meta-proposals/`
- produces meta-proposals that request formal work from operational agents
- does not write formal PROP-* documents or executable proofs directly

`[Igniter-Lang Archive/Form Expert]`

- owns project archaeology, historical signal preservation, and
  canon-vs-history indexing in `igniter-lang/docs/meta-proposals/`
- inherits Compiler/Grammar discipline as a filter: recovered ideas need
  parser/type/runtime/diagnostics/bridge pressure before promotion
- does not write executable proofs or implementation directly

## Research Policy

Use compact documents. Prefer one living index plus focused tracks.

Every idea should have a status:

- `research`
- `proposal`
- `approved_experiment`
- `implementation_candidate`
- `rejected`

Use these markers:

- `[D]` Decision
- `[R]` Recommendation
- `[S]` Signal
- `[Q]` Open question
- `[X]` Rejected

## Non-Goals

- No production code.
- No package/gem integration until approved.
- No final syntax promise from source fixtures.
- No edits to `packages/`.
- No replacement of the Ruby platform.
- No long uncontrolled idea dumps.
- No staging, unstaging, restoring, cleaning, or removing unrelated worktree
  changes.

Experiments are allowed inside `igniter-lang/experiments/` when the handoff
asks for an approved proof/devkit slice.

## Handoff

End each work slice with:

```text
Card:
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track: igniter-lang/<track-name>
Status: done | partial | blocked

[D] Decisions:
- ...

[R] Recommendations:
- ...

[S] Signals:
- ...

[T] Tests / Proofs:
- ...

[Q] Open Questions:
- ...

[X] Rejected:
- ...

[Next] Proposed next slice:
- ...
```

# Igniter-Lang Research Process

Status: proposal

## Lifecycle

```text
research note
-> proposal
-> approved experiment
-> implementation candidate
-> bridge request to Igniter
```

## Document Types

`README.md`

- living index
- active tracks
- decisions
- open questions

`tracks/<name>.md`

- one focused research slice
- compact context
- decisions/recommendations/signals/questions
- handoff at the end

`proposals/<name>.md`

- design proposal ready for Architect review
- should be smaller than a full essay

`experiments/<name>.md`

- approved experiment plan or result
- can include pseudo-code, syntax sketches, semantic tables

`bridge/<name>.md`

- proposal to bring one idea back into the Igniter platform

## Status Vocabulary

- `research`: early exploration
- `proposal`: coherent recommendation
- `approved_experiment`: allowed to prototype in this workspace
- `implementation_candidate`: mature enough for a package/platform track
- `rejected`: closed with reason

## Compression Rules

- Prefer one updated index over many status files.
- Close completed tracks with a final handoff section.
- Move stale material to `archive/` only when it blocks reading.
- Keep "why it matters" and "current decision" near the top.
- Do not paste large source excerpts; link source paths and summarize.

## Review Protocol

Research agent delivers:

```text
one complete track
one compact handoff
zero package edits
```

Architect Supervisor responds with:

```text
approve / redirect / reject / bridge request
```

## Guardrails

- Bold experiments are welcome.
- Premature implementation is not.
- Syntax sketches are allowed only when they clarify semantics.
- Every syntax sketch must say whether it is illustrative or proposed.

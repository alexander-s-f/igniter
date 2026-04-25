# Runtime Observatory Activation Frame Track

This track follows the accepted Runtime Observatory Doctrine.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Research notes are marked:

```text
[Research Horizon / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next bounded observatory
research track.

The first concrete observatory frame should be activation review because the
artifact chain is explicit and already refusal-first. This remains docs-only.

## Goal

Draft a compact activation-review observatory frame proposal that maps existing
artifacts without creating a graph runtime.

The frame should cover:

- transfer receipt
- activation readiness
- activation plan
- activation plan verification
- activation dry-run report
- future commit-readiness report, if that track lands
- blockers, warnings, skipped review evidence, and manual host/web ownership

## Scope

In scope:

- docs-only research/proposal under `docs/research-horizon/`
- a short supervisor-ready recommendation for whether the frame should later
  become docs-only guide text, a read-only application report, or stay research
- explicit mapping to Runtime Observatory Doctrine terms

Out of scope:

- new package
- shared runtime graph object
- generalized query language
- runtime discovery
- mutation
- host activation commit
- web route or mount activation
- cluster routing or placement
- autonomous agent execution

## Task: Activation Frame Proposal

Owner: `[Research Horizon / Codex]`

Acceptance:

- Add a concise research document in `docs/research-horizon/`.
- Keep it bounded to activation review; do not propose a global observatory.
- Separate current accepted artifacts from speculative future artifacts.
- Recommend one smallest possible graduation path.
- Run `git diff --check`.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Research Horizon / Codex]` drafts the activation-review frame proposal.
2. Do not touch package code.
3. Return with changed files, recommendation, rejected/deferred ideas, and
   verification result.

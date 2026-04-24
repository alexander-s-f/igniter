# Contracts And Extensions Stewardship

This note declares the active stewardship posture for the lowest Igniter layer:
`igniter-contracts` and `igniter-extensions`.

Role label:

```text
[Agent Contracts / Codex]
```

Current scope:

- owns implementation work in `packages/igniter-contracts`
- absorbs the former `[Agent Extensions / Codex]` role for
  `packages/igniter-extensions`
- joins extension work when a track proves a missing contracts/extensions seam
  or when a small improvement clearly strengthens the architecture without
  pulling upper-layer concepts downward

## Current Readiness

[Agent Contracts / Codex] is ready to join the Differential Shadow Contractable
track if `[Agent Embed / Codex]` proves `DifferentialPack` cannot be reused
cleanly through a thin embed-side adapter.

The expected first seam, if needed, is a pre-normalized outputs path for
`DifferentialPack.compare`. That seam should let host layers provide already
normalized comparable hashes without fabricating execution-result-like objects.

Do not add the seam preemptively. Let the embed implementation prove the need.

## Foundation Rules

The contracts layer is the bottom of the new Igniter stack. It should stay:

- host-agnostic
- profile-driven
- pack-extensible
- locally executable
- serializable in diagnostics
- free of Rails, application, web, cluster, and legacy core dependencies

The extensions layer should remain the home for useful vocabulary that is not
small enough for baseline contracts but is still below application hosting.

## Recommendations

1. Keep baseline contracts small.

   Baseline should remain `input`, `const`, `compute`, `effect`, `output`,
   local execution, and basic diagnostics. New semantics such as step results,
   differential comparison, collection sessions, provenance, saga, and
   content addressing should enter through explicit packs first.

2. Prefer visible graph nodes over hidden pipelines.

   Ergonomic DSL is good, but it should lower into inspectable operations.
   Debugging, diagnostics, provenance, and future application/cluster tooling
   all depend on being able to see the graph.

3. Treat serializable reports as product surface.

   Every runtime feature should answer: what is the structured report shape?
   If a behavior cannot be explained through `to_h` or diagnostics, it is not
   ready to become part of the foundation.

4. Keep host concerns above contracts.

   Registration, reload, discovery, async adapters, persistence stores, rollout
   policies, and framework hooks belong in Embed/Application/Web/Cluster layers
   unless they are proven to be pure graph/runtime semantics.

5. Use packs before package sprawl.

   A coherent pack with a strong manifest is usually better than a new package.
   Split packages only when dependencies, release cadence, or host ownership
   truly differ.

6. Add seams only after a caller proves pressure.

   The foundation should be easy to extend but slow to generalize. A small
   embed-side adapter is preferable until it becomes awkward enough to reveal a
   real public seam.

7. Preserve objective facts apart from policy.

   For example, `DifferentialPack` should report whether outputs match. Embed
   can decide whether the candidate is accepted for rollout. This separation
   should guide future audit, migration, and governance features.

## Watchlist

- `DifferentialPack` may need a pre-normalized outputs comparison path.
- `StepResultPack` should be pressure-tested through embed before adding
  unwrapping helpers, non-halting steps, or broader authoring guidance.
- Pack manifests may need richer metadata, but only after host tooling proves
  which metadata is actually consumed.
- Application and Cluster must consume contracts semantics; they must not
  redefine them.

# Documentation Compression Solo Track

This track is a supervisor-only cleanup cycle for tightening Igniter
documentation after the enterprise proof push.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Decision

[Architect Supervisor / Codex] Opened at the user's request for a couple of
cycles without delegating to agents.

The immediate goal is documentation compression and project-state clarity, not
new feature work.

## Current Project State

Igniter is currently shaped around:

- contracts-native packages: `igniter-contracts`, `igniter-extensions`,
  `igniter-embed`, `igniter-application`, `igniter-web`, `igniter-cluster`, and
  `igniter-mcp-adapter`
- four showcase applications: Lense, Chronicle, Scout, and Dispatch
- additive Lang foundation with report-only metadata manifests
- enterprise verification receipt as the compact evaluator proof path
- public entry-surface hygiene accepted, with old companion/legacy onboarding
  removed from first reads

Active proof entrypoints:

- [Enterprise Verification](../guide/enterprise-verification.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Examples](../../examples/README.md)

Paused:

- [Enterprise Release Readiness Checklist Track](./enterprise-release-readiness-checklist-track.md)

## Compression Targets

First cleanup cycle:

- Keep [Active Tracks](./tracks.md) truly active-only. Done: compressed from
  299 lines to 73 lines.
- Keep [Igniter Dev](./README.md) as an entrypoint, not a full track archive.
  Done: removed the long duplicate track catalog and kept current canonical
  docs plus cold-history pointers.
- Move cold state to [Tracks History](./tracks-history.md) or leave it in the
  already accepted track documents. Started with a 2026-04-27 compression
  pivot note.
- Identify high-noise docs and decide whether to compress, index, archive, or
  leave as research/reference.

Candidate high-noise zones:

- old track files in `docs/dev/`
- duplicated expert `.ru.md` / English proposal pairs
- long research-horizon and experts documents
- older guide pages that still describe deprecated or direction-only surfaces

Observed documentation footprint:

- `docs/`: 263 markdown files, about 90k lines.
- `docs/dev`: 154 markdown files, about 42.5k lines.
- `docs/experts`: 52 markdown files, about 31.7k lines.
- `docs/research-horizon`: 16 markdown files, about 6.4k lines.
- `docs/guide`: 26 markdown files, about 4.5k lines.
- `docs/dev` contains 87 `*track*.md` files; these should be treated as cold
  cycle artifacts unless linked from the active track.

## Guardrails

- No agent delegation during this solo cleanup cycle.
- No runtime/API/package feature work.
- Do not delete research or expert material casually; prefer indexing and
  cold-storage language first.
- Public first reads should stay small and current.
- Keep legacy/private material out of public onboarding.

## Verification Gate

For docs-only cleanup, run at minimum:

```bash
git diff --check
```

Use targeted link/stale-reference scans when changing indexes.

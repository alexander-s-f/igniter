# Active Tracks

This is the first file agents should read. It is intentionally compact.

Full accepted/history context lives in [Tracks History](./tracks-history.md).
Reusable active-track boundaries live in [Constraint Sets](./constraints.md).
The lifecycle pattern is captured in
[Agent Track Lifecycle Doctrine](./agent-track-lifecycle-doctrine.md).
Documentation compression rules live in
[Documentation Compression Doctrine](./documentation-compression-doctrine.md).
Long-range research context lives in [Research Horizon](../research-horizon/README.md)
and external expert input lives in [Experts](../experts/README.md).

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Protocol

1. Read this file.
2. Find your role in **Active Handoffs**.
3. Read only the linked track and explicitly listed dependencies.
4. Apply any named constraint sets cited by the track.
5. Append a compact labeled handoff to the track you changed.
6. Return the compact status format below.

Do not paste long summaries of unrelated tracks. If a task needs historical
context, read only the linked history entry or dependency.

## Compact Status

```text
[Agent Role / Codex]
track: <path>
status: landed | blocked | needs-review
delta: <changed files, one line each>
verify: <tier/result>
ready: <who can proceed>
block: none | <blocker>
```

## Active Handoffs

| Agent | Current Task | Start Here | Dependencies | Return To |
| --- | --- | --- | --- | --- |
| `[Architect Supervisor / Codex]` | Solo documentation compression and project-state cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | [Documentation Compression Doctrine](./documentation-compression-doctrine.md), [Enterprise Verification](../guide/enterprise-verification.md), [Application Showcase Portfolio](../guide/application-showcase-portfolio.md), [Igniter Lang Foundation](../guide/igniter-lang-foundation.md) | user |
| `[Agent Application / Codex]` | Paused during supervisor-only documentation cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | none | `[Architect Supervisor / Codex]` |
| `[Agent Web / Codex]` | Paused during supervisor-only documentation cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | none | `[Architect Supervisor / Codex]` |
| `[Research Horizon / Codex]` | Paused during supervisor-only documentation cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | none | `[Architect Supervisor / Codex]` |
| `[Agent Embed / Codex]` | Paused during supervisor-only documentation cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | none | `[Architect Supervisor / Codex]` |
| `[Agent Contracts / Codex]` | Paused during supervisor-only documentation cleanup | [Documentation Compression Solo Track](./documentation-compression-solo-track.md) | none | `[Architect Supervisor / Codex]` |

## Current Cycle

[Architect Supervisor / Codex] Current compact state:

- Active implementation/proof line is paused for supervisor-only docs cleanup.
- Current accepted public proof path is
  [Enterprise Verification](../guide/enterprise-verification.md).
- Current showcase portfolio is Lense, Chronicle, Scout, and Dispatch:
  [Application Showcase Portfolio](../guide/application-showcase-portfolio.md).
- Current Lang surface is additive/report-only:
  [Igniter Lang Foundation](../guide/igniter-lang-foundation.md).
- Public entry-surface hygiene is accepted; removed companion/legacy onboarding
  paths should not return to first reads.
- [Enterprise Release Readiness Checklist Track](./enterprise-release-readiness-checklist-track.md)
  is paused until the documentation compression pass finishes.
- `docs/` currently has 263 markdown files and about 90k lines; compression
  should focus on active indexes, duplicated research/expert material, and old
  long track files.
- Do not delegate to package agents during this solo cleanup cycle.

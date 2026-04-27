# Enterprise Public Entry Surface Hygiene Track

This track aligns the public repository entrypoints with the accepted
enterprise verification receipt.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
[Agent Contracts / Codex]
[Research Horizon / Codex]
```

Inputs:

- [Enterprise Verification](../guide/enterprise-verification.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Examples](../../examples/README.md)
- [Root README](../../README.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting enterprise verification
receipt hardening.

The next step is public entry-surface hygiene, not new product scope.

## Goal

Make a new evaluator's first 10 minutes coherent:

- root README points to the current proof path
- examples README, guide index, package READMEs, and showcase docs agree on
  what is current
- stale references to removed/private legacy material are corrected or clearly
  marked as reference-only
- the enterprise receipt remains the compact proof path

## Scope

In scope:

- README/index/doc wording and links
- examples/catalog discoverability corrections
- package README cross-links to the accepted proof path
- stale public onboarding references caused by legacy relocation
- concise known-caveat wording for full RuboCop archived/research offenses

Out of scope:

- runtime/code feature work
- new app implementation
- new package APIs or DSLs
- changing the verification receipt's semantics
- restoring legacy as a public onboarding path
- production server/auth/persistence/cluster/connectors/LLM claims

## Task 1: Root And Examples Entrypoints

Owner: `[Agent Application / Codex]`

Acceptance:

- Root README links to Enterprise Verification, Application Showcase
  Portfolio, Igniter Lang Foundation, and active examples without stale
  removed-example references.
- `examples/README.md` stays aligned with `ruby examples/run.rb list` for the
  active flagship and verification examples.
- Legacy relocation is framed as private/reference context, not onboarding.

## Task 2: Web And Application Guide Links

Owner: `[Agent Web / Codex]`

Acceptance:

- Application/Web guide links consistently point evaluators to Enterprise
  Verification for proof and Application Showcase Portfolio for app review.
- Manual server wording stays review-only and does not imply production server,
  browser automation, auth, persistence, live transport, or deployment.
- Surface markers remain app-local inspection seams.

## Task 3: Contracts/Lang Package Entrypoints

Owner: `[Agent Contracts / Codex]`

Acceptance:

- `packages/igniter-contracts/README.md` and related package-local docs point
  to Enterprise Verification and Igniter Lang Foundation where appropriate.
- Lang wording remains report-only and avoids implying runtime enforcement.
- Changed-file RuboCop caveat is referenced only where useful and does not
  normalize broad lint debt as acceptable product quality.

## Task 4: Horizon Overclaim Filter

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review the public entry surfaces for overclaiming.
- Flag stale claims about production readiness, agents, LLM/provider behavior,
  cluster/distributed guarantees, or Lang runtime semantics.
- Recommend whether the next track should be release-readiness checklist,
  examples/spec smoke helper extraction, Embed/SparkCRM pressure follow-up, or
  pause for human review.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Do not expand the enterprise proof claim; make the entrypoints easier to
  find and harder to misread.
- Prefer compact links and command pointers over long repeated explanations.
- Public docs should make current packages, showcase apps, and verification
  receipts feel like one coherent product surface.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run affected specs/smoke/lint.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` cleans root/examples entrypoints.
2. `[Agent Web / Codex]` cleans app/web guide links and manual-review wording.
3. `[Agent Contracts / Codex]` cleans contracts/lang package entrypoints.
4. `[Research Horizon / Codex]` reviews the public surface for overclaiming
   and recommends the next post-hygiene track.

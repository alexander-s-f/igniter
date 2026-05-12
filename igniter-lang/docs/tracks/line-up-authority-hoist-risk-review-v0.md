# Line Up Authority-Hoist Risk Review v0

Card: S3-R39-C3-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/line-up-authority-hoist-risk-review-v0
Status: done
Date: 2026-05-12

Route: STALE_REFRESH
Previous known card: S3-R37-C6-P2
Latest observed round: Stage 3 Round 39 route items visible in R38 status
curation and tracks index.
Same-role newer work: R37 fate inventory and R38 Line Up batch landed; this
card reviews the R38 Line Up batch before movement/link rewrites.
Gate/status changes: R38 closed P-53 proof-locally, kept operational rollout
closed, added P-54, and flagged this authority-hoist review as a named follow-up.

---

## Scope

Review current Line Up summaries for authority-hoist risk before any movement,
discussion-index redirect, or broad link rewrite.

Read set:

- [lineups/README.md](../lineups/README.md)
- [old-discussions-pre-gate3-spine.md](../lineups/old-discussions-pre-gate3-spine.md)
- [stage2-compiler-package-spine.md](../lineups/stage2-compiler-package-spine.md)
- [stage2-to-stage3-typed-switch-spine.md](../lineups/stage2-to-stage3-typed-switch-spine.md)
- [line-up-stage1-stage2-second-batch-v0.md](line-up-stage1-stage2-second-batch-v0.md)
- [r38-durable-audit-prop037-prop036-docs-pressure-v0.md](../discussions/r38-durable-audit-prop037-prop036-docs-pressure-v0.md)
- [current-status.md](../current-status.md)
- [tracks/README.md](README.md)

No files were moved, deleted, or broadly relinked by this review.

---

## Review Standard

Authority-hoist risk means a compact memory card makes an old candidate route,
proof-local result, discussion verdict, or package/gem smoke test look like:

- current canon;
- runtime or Gate authority;
- production deployment approval;
- release readiness;
- parser/runtime implementation authorization;
- movement approval.

Line Ups are allowed to be active memory cards. They are not allowed to become
authority layers.

---

## Authority-Hoist Risk Table

| Line Up | Risk checked | Finding | Required edit before movement/link rewrite? | Recommendation |
| --- | --- | --- | --- | --- |
| [Stage 2 Compiler Package Spine](../lineups/stage2-compiler-package-spine.md) | Package/gem proof accidentally presented as release readiness | Low risk. The one-line claim says "local gem-native proof but not a release"; Key Signals preserve release-readiness gaps; Not promoted excludes final metadata, CI, RubyGems publish, production RuntimeMachine packaging, and TBackend binding. | No blocking edit. Optional: if used as a redirect landing page, add a current-status pointer for release lane truth. | Proceed for movement planning. Do not move package/gem tracks until implementation agents confirm exact extraction docs are no longer default reads. |
| [Stage 2 To Stage 3 Typed Switch Spine](../lineups/stage2-to-stage3-typed-switch-spine.md) | Old blocked parity tracks made current, or typed switch inflated into runtime authority | Low risk. The summary explicitly marks initial parity as stale, names stale-header protection, and limits canon/current truth to `emit_typed(typed)` as production compiler path. It excludes production temporal executor, cache, Ledger binding, and parser coordinate syntax. | No blocking edit. | Proceed for movement planning of stale parity/cache tracks after incoming-reference checks. |
| [Old Pre-Gate-3 Discussions Spine](../lineups/old-discussions-pre-gate3-spine.md) | Pre-decision discussion routes leak Gate 3/runtime authority | Medium-low risk. The document repeatedly says discussions are not current authority, uses current status/spec/gates as truth, and excludes runtime authorization, Ledger operations, production cache, and broad Gate 3 deployment. However, two short phrases become risky if the Line Up becomes the redirect landing page. | Yes, before discussion-index redirects or movement. See required edits RQ-1 and RQ-2 below. | Revise-light before movement. Keep active as memory card meanwhile. |
| [Line Up index](../lineups/README.md) | Disposition labels themselves make summaries look canonical | Low risk. Index says Line Ups are not canon and are handles. It does not claim movement approval. | No blocking edit. | Proceed. |
| [Second batch track](line-up-stage1-stage2-second-batch-v0.md) | Batch track authorizes movement or canon | Low risk. Track says no movement/deletion, no canon/gate/proposal/spec/current-status decision, and asks Archive/Form to verify authority. | No blocking edit. | Proceed. |
| [R38 pressure discussion](../discussions/r38-durable-audit-prop037-prop036-docs-pressure-v0.md) | External review made non-blockers authoritative | Low risk. Discussion route is PROCEED with non-blockers; it explicitly asks for this review. | No edit from this card. | Use as route evidence only, not movement authority. |

---

## Required Edits Before Movement

These edits are required only before discussion-index redirects, source movement,
or using `old-discussions-pre-gate3-spine.md` as a primary landing page. This
review does not perform them.

RQ-1. Tighten the current route in
[old-discussions-pre-gate3-spine.md](../lineups/old-discussions-pre-gate3-spine.md).

Current risk:

```text
Current route: Line Up complete; History Curator can plan discussion-index
redirects after Archive/Form verification.
```

Required intent:

```text
Current route: Line Up complete. History Curator may plan discussion-index
redirects after Archive/Form verification, but should not execute redirects until
the R13-R22 Gate 3 discussion Line Up lands and no-zombie checks pass.
```

Reason: the document already says R13-R22 should land first in `Next Route`,
but the top-level route reads a little more permissive than the movement ledger.

RQ-2. Correct the exact authority pointer in
[old-discussions-pre-gate3-spine.md](../lineups/old-discussions-pre-gate3-spine.md).

Current risk:

```text
igniter-lang/docs/meta-proposals/ gate decision records, when exact authority is needed.
```

Required intent:

```text
igniter-lang/docs/gates/, current-status.md, and agent-context.md when exact
Gate/runtime authority is needed.
```

Reason: Gate authority now lives in gate records and current maps, not in a
generic meta-proposals pointer. The current phrasing could send future agents to
the wrong authority layer.

RQ-3. Optional wording hardening in the Key Signals table:

```text
runtime enforcement
```

can become:

```text
guarded approval-enforcement proof tracks, without granting runtime authority
```

Reason: the existing phrase is understandable in context and is not a blocker,
but the hardened wording is safer if the Line Up becomes a redirect target.

---

## Movement Readiness Recommendation

Recommendation: `revise-light before movement`.

Proceed:

- keep the three reviewed Line Ups active as memory cards;
- continue History Curator movement planning;
- plan grouped index rows and redirect/no-zombie checks.

Do not proceed yet:

- do not execute discussion-index redirects for R2-R12;
- do not move old discussion files;
- do not collapse old discussion index rows into the Line Up as the only landing
  page;
- do not treat this review as approval for R13-R22 movement.

Required before movement/link rewrite:

1. Apply RQ-1 and RQ-2 to the old pre-Gate-3 Line Up.
2. Land the separate R13-R22 Gate 3 discussions Line Up linked to History-S7.
3. Run History Curator no-zombie checks over incoming discussion links.

The package/gem and typed-switch Line Ups do not need revision before movement
planning. They still need normal movement approval before any file move/delete.

---

## Handoff

```text
Card: S3-R39-C3-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/line-up-authority-hoist-risk-review-v0
Status: done

[D] Decisions
- No Line Up promotes old candidate routes to canon.
- Package/gem proof is not presented as release readiness.
- Typed-switch summary correctly separates compiler production path from runtime
  authority.
- Pre-Gate-3 discussion summary is safe as an active memory card, but needs
  two wording fixes before movement or redirect use.

[S] Signals
- Highest risk is not content volume; it is authority pointer precision.
- `old-discussions-pre-gate3-spine.md` should name `docs/gates/`,
  `current-status.md`, and `agent-context.md` for exact authority.

[T] Tests / Checks
- Documentation-only review.
- Searched reviewed Line Ups for authority/release/runtime/Gate/stale language.
- No movement, deletion, or broad link rewrite performed.

[R] Recommendation
- Revise-light before movement.
- Proceed with movement planning only; hold actual discussion redirects until
  RQ-1/RQ-2 and the R13-R22 Gate 3 discussion Line Up land.

[Next]
- Line Up Summarizer or assigned docs agent: apply RQ-1/RQ-2.
- Line Up Summarizer: produce `gate3-r13-r22-discussions-lineup-v0`.
- History Curator: run no-zombie checks before any discussion-index rewrite.
```

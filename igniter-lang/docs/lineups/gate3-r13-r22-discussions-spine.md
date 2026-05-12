# Line Up: Gate 3 R13-R22 Discussions Spine

Status: active memory card
Source:
- `igniter-lang/docs/discussions/gate3-decision-safety-pressure-v0.md`
- `igniter-lang/docs/discussions/gate3-decision-safety-pressure-v0-agent-v2-cross-test.md`
- `igniter-lang/docs/discussions/phase1-implementation-prep-safety-pressure-v0.md`
- `igniter-lang/docs/discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md`
- `igniter-lang/docs/discussions/live-read-addendum-draft-safety-pressure-v0.md`
- `igniter-lang/docs/discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md`
- `igniter-lang/docs/discussions/gate3-post-signature-runtime-pressure-v0.md`
- `igniter-lang/docs/discussions/phase1-post-signature-audit-registry-pressure-v0.md`
- `igniter-lang/docs/discussions/phase1-e2e-and-content-address-pressure-v0.md`
Supporting map:
- `igniter-lang/docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`
Prepared by: `[Igniter-Lang Line Up Summarizer]`
Date: 2026-05-12
Disposition input: `public_archive candidate`
Current route: Line Up complete; Archive/Form verification, then History
Curator discussion-index/link planning before any movement.

## One-Line Claim

Gate 3 R13-R22 discussion pressure converted a restricted Phase 1 Gate 3
decision into a signed, proof-local live-read policy with backend identity,
post-signature, audit/registry, end-to-end, and content-address safeguards, while
keeping production durability/signing/Ledger surfaces closed.

## Why It Matters

This chain is high-risk because the words "approved", "signed", "live read",
and "audit-ready" can be misread as broad runtime authority. The useful memory
handle is the separation between historical pressure, superseded routes,
accepted decisions, current authority, and remaining blockers.

source remains authoritative for exact proof logs.

## Historical Pressure

| Pressure point | What it forced |
| --- | --- |
| R13 decision safety | Checked that `approved-restricted-phase1` did not leak into Ledger, BiHistory, stream/OLAP, writes, replay, compact, subscribe, or production cache. |
| R14 implementation prep | Exposed production-prep gaps around canonical guard ordering, composed CompatibilityReport use, and AT-9 authority URI comparison. |
| R17 lib-prep safety | Confirmed `IgniterLang::TemporalExecutor::Phase1` was proof-local, default-blocked, token-before-gate, and in-memory-only; routed backend identity guard and reason alias cleanup. |
| R18 addendum draft pressure | Confirmed the addendum was draft-only and non-authorizing, but required post-R18 regression and guard-order amendment before signing. |
| R19 pre-signature pressure | Confirmed blockers 1-5 closed and routed the remaining Architect signature action with citation/traceability notes. |
| R20 post-signature pressure | Verified signature was policy-only: executor behavior and excluded surfaces did not widen. |
| R21 audit/registry pressure | Verified audit envelope and registry shape were proof-local only, not durable audit or production signing. |
| R22 e2e/content-address pressure | Closed mutable addendum reference and composition gaps proof-locally; added post-R22 regression and production-readiness blockers. |

## Superseded Route

- Early Gate 3 work treated live read readiness as a request/decision problem;
  later pressure split it into decision, proof, addendum, signature,
  post-signature fixture, audit/registry shape, and content-addressed evidence.
- The R18 addendum draft route is superseded by R19 pre-signature repair and R20
  signed addendum.
- Path-only signed addendum evidence is superseded by R22 content-addressed
  reference shape.
- Proof-local registry/audit shapes do not supersede production registry,
  production signing, durable audit, or Phase 2 Ledger requirements.

## Accepted Decision

Accepted by the Gate 3 R13-R22 arc:

- Gate 3 moved to `approved-restricted-phase1` for implementation, then to
  signed restricted Phase 1 live-read policy only after the addendum signature.
- Authorized scope remained narrow: `History[T]` valid-time read, explicit
  `as_of`, `IgniterLang::TemporalExecutor::Phase1`, MemoryBackend or explicitly
  named non-Ledger Phase 1 backend, caller-supplied `gate3_authorized: true`
  only with signed addendum evidence.
- Backend identity guard blocks Ledger-like, proxy, unmarked, malformed, and
  excluded-surface backends before read paths.
- Signing changes caller policy, not executor behavior.
- Audit-ready envelope and authority registry shape are proof-local,
  non-durable, and non-cryptographic.

## Current Authority

Read current authority before these discussion docs:

1. `igniter-lang/docs/agent-context.md`
2. `igniter-lang/docs/current-status.md`
3. `igniter-lang/docs/gates/README.md`
4. `igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md`
5. `igniter-lang/docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`

This Line Up is not canon. It points to routed pressure and source evidence.

## Historical R22 Remaining Blockers

Historical blocker snapshot only: still closed or open as of the R22 compressed
state.

For current durable-audit / rollout state, read
`igniter-lang/docs/current-status.md` and `igniter-lang/docs/gates/README.md`.

| Item | State |
| --- | --- |
| Ledger adapter / package binding | Closed; Phase 2 addendum required. |
| BiHistory / transaction-time | Closed; separate gate required. |
| stream / OLAP executors | Closed; separate gate required. |
| production cache / memoization | Closed; separate gate required. |
| writes / replay / compact / subscribe | Closed; separate gate required. |
| durable audit / production storage | Open future work; proof-local envelope only. |
| production authority registry | Open future work; proof-local shape only. |
| production signing / key management | Open future work; must follow registry ordering. |
| post-R22 regression matrix | Open follow-up: include R20-R22 fixtures. |
| `git_commit: workspace-current` | Proof-local placeholder; production compliance must reject it. |
| `LEGACY_ALIASES` deprecation | Carried pre-Phase-2 cleanup item. |

## Canon / History / Research / Value

- Canon/current authority: current status, gate docs, signed addendum, and
  accepted proposals/spec.
- Historical value: pressure-review route that prevented scope leaks through
  decision/signature/audit wording.
- Public archive value: completed and routed discussion records.
- Not promoted here: production durable audit, production registry, production
  signing, Ledger adapter, Phase 2, BiHistory, stream/OLAP, cache, writes, or
  broad RuntimeMachine binding.

## Current Home

All source discussions remain in `igniter-lang/docs/discussions/`. The
compression map remains in `igniter-lang/docs/archive/history/`. No file moved,
deleted, or redirected.

## Links To Keep

- `igniter-lang/docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`
- `igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md`
- `igniter-lang/docs/tracks/phase1-end-to-end-invocation-fixture-v0.md`
- `igniter-lang/docs/tracks/phase1-addendum-content-address-ref-v0.md`
- `igniter-lang/docs/tracks/compatibility-report-persistence-audit-v0.md`
- `igniter-lang/docs/tracks/gate3-authority-registry-shape-v0.md`

## Safe To Archive?

Recommended disposition: `public_archive candidate`.

Safe for Archive/Form verification as completed/routed pressure. Movement or
discussion-index rewrites still need History Curator planning and no-zombie
checks.

Public/private risk: no private secrets observed in the assigned source
documents. These are public-GitHub pressure records with runtime/security
semantics; keep summaries public and avoid treating discussion-only concerns as
accepted authority.

## Open Questions

- Should `docs/discussions/README.md` route R13-R22 readers first to this Line Up
  and History-S7?
- Should History Curator group all R13-R22 pressure docs only after a no-zombie
  check confirms current gate docs and status maps carry the active authority?
- Should production registry/signing ordering be hoisted into a future dedicated
  Line Up once those tracks land?

## Next Route

- Archive/Form Expert: verify the pressure/decision/current-authority
  separation and confirm no production authority is implied.
- History Curator: plan discussion-index redirects with History-S7 after
  Archive/Form verification.

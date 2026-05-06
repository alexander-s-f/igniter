# Track: Track Errata Application v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Apply compact formal errata to the completed practical tracks after
`semantic-domain-reconciliation-v0`.

This is not a rewrite, theory expansion, or package bridge. The goal is to keep
the historical practical slices intact while making their relationship to
`PROP-001` explicit.

## Source Horizon

- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/tracks/semantic-domain-reconciliation-v0.md`
- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/agent-motion.md`

## Applied Errata

[D] Added `Formal Errata` to `observable-contract-language-v0`.

- Law 3 now points to finite stratified graphs parameterized by explicit
  temporal context `Tt`.
- Law 5 now points to deterministic `eval(G, Tt, inputs)`.
- The original ten laws remain practical design language.

[D] Added `Formal Errata` to `observable-spine-v0`.

- Required envelope fields are grouped into Identity, Provenance, and Policy.
- Same identity plus different provenance means re-emission/refreshed evidence.
- Observation packets are semantic evidence values, not the full denotation.

[D] Added `Formal Errata` to `failure-observation-v0`.

- Flat status is now compatibility shorthand.
- Formal status is `computation_status x service_level`.
- Reason-code families are closed core semantics; package-specific codes are
  advisory platform extensions.

## Not Changed

[R] The body and handoff of each completed practical track were preserved.

Reason:

- They document the research progression.
- They remain useful for practical bridge/product pressure.
- The formal layer should anchor them, not erase them.

[X] No package docs or package code were edited.

## Bridge Readiness Impact

Future `bridge-observation-envelope-v0` must consume the errata:

- map package ids into Identity
- map producers/hashes/receipts into Provenance
- map privacy/capability/no-grant semantics into Policy
- map flat package failure statuses into `computation_status x service_level`
- keep package-specific reason codes advisory

The bridge should wait for Architect review and, ideally, the current
`PROP-003` fragment classification review.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/track-errata-application-v0
Status: done

[D] Decisions:
- Applied compact formal errata to the three completed practical tracks.
- Preserved historical track bodies and handoffs.
- Pointed all three practical tracks toward `PROP-001` without rewriting them.

[R] Recommendations:
- Wait for `PROP-003` review before opening `bridge-observation-envelope-v0`.
- Keep future practical tracks citing `PROP-001` for semantic-domain terms.
- Keep package work blocked until an approved bridge exists.

[S] Signals:
- The practical/theoretical split is working: theory corrected the tracks
  without flattening their product pressure.
- The bridge vocabulary is sharper after Identity/Provenance/Policy and
  two-dimensional failure status.

[Q] Open Questions:
- Should each future completed track include a formal errata slot by default?
- Should the research index carry the current formal anchor explicitly?

[X] Rejected:
- Destructive rewrites of completed tracks.
- Package edits before bridge approval.
- Treating flat failure status as the formal model.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-v0.md` after `PROP-003`
  is reviewed or redirected.
```

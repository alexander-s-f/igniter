# Track: Semantic Domain Reconciliation v0

Status: assigned
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Reconcile the completed practical Igniter-Lang tracks with the formal
corrections from the Compiler/Grammar Expert.

This is not a new theory track and not a package bridge. It is a compact
alignment slice: decide how `observable-spine-v0` and
`failure-observation-v0` should absorb the strongest corrections from
`META-001` and `PROP-001` without losing their practical clarity.

## Read First

- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/proposals/META-001-compiler-grammar-expert-entry.md`
- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/agent-motion.md`

Write only inside `igniter-lang/`.

## Required Decisions

Answer directly:

- Should Law 3 be restated as a finite stratified graph parameterized by
  explicit temporal context `Tt`?
- Should the observation envelope separate required fields into Identity,
  Provenance, and Policy groups?
- Should failure status become two-dimensional:
  `computation_status x service_level`?
- Should reason codes be split into closed core semantics and open platform
  advisory extensions?
- Which completed tracks need errata sections vs. full rewrites?

## Desired Output

Prefer one compact result document or direct compact edits to the completed
tracks. If editing completed tracks, preserve their historical value and add
clear correction sections instead of rewriting them into a different voice.

Suggested output shape:

- accepted corrections
- rejected or deferred corrections
- errata to apply to `observable-spine-v0`
- errata to apply to `failure-observation-v0`
- bridge candidates affected by the corrections
- questions for C/G Expert
- next slice recommendation

## Acceptance

Done means:

- The relationship between practical tracks and `PROP-001` is explicit.
- The temporal-context correction is either accepted or redirected with reason.
- The observation envelope identity/provenance/policy separation is resolved.
- The failure status model is resolved or narrowed for a follow-up.
- Closed core reason codes vs open platform extensions are resolved.
- No package docs/code are edited.
- A compact handoff is added at the end.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/semantic-domain-reconciliation-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[R] Recommendations:
- ...

[S] Signals:
- ...

[Q] Open Questions:
- ...

[X] Rejected:
- ...

[Next] Proposed next slice:
- ...
```


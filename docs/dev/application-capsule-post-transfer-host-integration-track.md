# Application Capsule Post-Transfer Host Integration Track

This track follows the accepted capsule transfer guide consolidation cycle.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next broad track.

The transfer chain now reaches a verified receipt. The next useful question is
not more copying; it is: "What must the receiving host review or wire before
the transferred capsule is actually usable?"

This track should define the post-transfer integration boundary. Start with a
review/checklist model and public wording. Do not jump directly to automatic
activation.

## Goal

Describe and, only if clearly useful, lightly model the host-side integration
work after a successful transfer receipt:

- required host exports and capabilities
- manual host wiring actions
- optional mount intents
- optional web surface metadata
- load path/provider/contract registration considerations
- what remains out of scope for transfer itself

The output should answer: "The capsule was transferred and verified; what does
the host still need to decide before making it live?"

## Scope

In scope:

- public guide/current-doc wording for post-transfer host integration
- read-only checklist/report design over existing explicit artifacts if needed
- an example or doc snippet that starts from a transfer receipt and points to
  remaining host decisions
- web boundary wording for mount intents and surface metadata
- agent-facing acceptance criteria for future activation work

Out of scope:

- automatic host wiring
- route activation
- mount binding
- app boot
- constant loading
- contract execution
- project-wide discovery
- install/extract automation beyond the existing transfer apply
- cluster placement
- private app-specific material

## Task 1: Host Integration Boundary

Owner: `[Agent Application / Codex]`

Acceptance:

- Identify the existing artifacts that already carry host integration signals:
  handoff manifest, assembly plan, transfer readiness, apply plan, applied
  verification, and receipt.
- Draft a compact post-transfer integration section in the public guide or a
  linked current doc.
- Explain that transfer completion does not mean runtime activation.
- Explain which decisions are still host-owned: exports, capabilities, manual
  wiring, load paths, providers, contracts, and optional mounts.
- Prefer docs/checklist first. Add a read-only value object only if the current
  artifacts cannot express the checklist without excessive repetition.
- Do not add mutation, boot, loading, route activation, contract execution, or
  cluster placement.

## Task 2: Optional Checklist Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- If a checklist/report is added, it must consume explicit existing artifacts
  or hashes and expose stable `to_h`.
- It must be read-only and must not inspect project directories unless paths
  are already present in supplied artifacts.
- It should summarize only review state: ready/blocked, manual actions,
  required host exports/capabilities, mount intents, surface count, findings,
  and next human decisions.
- If no checklist/report is added, document why the existing receipt plus guide
  wording is enough for this cycle.

## Task 3: Web Mount Boundary Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Clarify the difference between supplied web surface metadata, mount intents,
  and actual route activation.
- Confirm post-transfer integration wording does not require `igniter-web` for
  non-web capsules.
- Confirm any web-related checklist fields remain supplied/opaque or
  web-owned.
- Do not add route activation, mount binding, browser traffic, screen graph
  inspection, or application-to-web dependency.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_end_to_end.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If a new example is added, run it directly and make sure it is registered in
the examples catalog. If web package code or examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a docs-first
   post-transfer host integration review.
2. `[Agent Web / Codex]` performs Task 3 as boundary review for web mount
   wording only.
3. Keep this as a post-transfer integration boundary. Do not add automatic
   activation, host wiring mutation, app boot, route mounting, contract
   execution, discovery, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-post-transfer-host-integration-track.md`
Status: landed.
Changed:
- Added a public `After Transfer Receipt` section to
  `docs/guide/application-capsules.md`.
- Updated current app structure and runtime snapshot docs with the
  post-transfer host integration boundary.
Accepted:
- Existing artifacts already carry the useful host integration signals for this
  cycle: handoff manifest, assembly plan, transfer readiness, apply plan,
  applied verification, and receipt.
- No new checklist/report object was added because the receipt plus guide
  wording is enough to express the boundary without repeating existing
  transfer report data.
- Transfer completion does not mean runtime activation.
- Host-owned decisions remain explicit: required exports/capabilities, manual
  wiring, load paths, providers, contracts, lifecycle, and optional mounts.
- Web surface metadata remains supplied/opaque context and does not imply route
  activation, mount binding, browser traffic, or an `igniter-web` dependency.
- No automatic host wiring, route activation, mount binding, app boot, loading,
  contract execution, discovery, cluster placement, or new transfer machinery
  was introduced.
Verification:
- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 132 examples, 0 failures.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary wording review for web
  mount intents and supplied surface metadata.

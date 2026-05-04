# Track: Ledger Rename Hardening + Compatibility Audit v0

Status: ready
Owner: [Architect Supervisor / Codex]
Agent: Package Agent / Companion+Store (pkg:companion-store)
Target package: `packages/igniter-ledger`

## Context

The package has just been externally renamed from `igniter-store` to
`igniter-ledger`.

The first supervisor slice already landed the public rename:

- package directory: `packages/igniter-ledger`
- gemspec: `igniter-ledger.gemspec`
- main require: `require "igniter-ledger"`
- CLI: `igniter-ledger-server`
- compatibility shims:
  - `require "igniter-store"`
  - `igniter-store-server`
  - `Igniter::Ledger`
  - `Igniter::Store::LedgerStore`
  - `Igniter::Store::LedgerServer`
  - `Igniter::Store::LedgerNetworkBackend`
- `igniter-companion` now depends on `igniter-ledger`
- current verification:
  - `BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec`
  - `BUNDLE_GEMFILE=packages/igniter-companion/Gemfile bundle exec rspec packages/igniter-companion/spec`

This track is a hardening and audit slice. It should make the rename safe,
obvious, and documented without attempting a risky deep rename.

## Core Decision

Do not treat every `store` token as wrong.

There are at least six categories:

1. public package/brand naming: should be `ledger`
2. compatibility shims: may intentionally say `store`
3. internal Ruby namespace and file path: may remain `Igniter::Store` /
   `lib/igniter/store/**` for this slice
4. wire protocol token: keep `:igniter_store` for this slice
5. native extension/crate: keep `igniter_store_native` for this slice
6. historical docs/research: may retain `store` only when explicitly historical

The acceptance target is clarity, not total textual replacement.

## Goals

1. Produce an audit map of all remaining important `store` tokens.
2. Harden the public compatibility surface with specs.
3. Update current public docs/examples so new users see `ledger` first.
4. Preserve existing compatibility for old package users during pre-v1.
5. Produce a phased deep-rename plan for later tracks.

## Non-Goals

- Do not rename `Igniter::Store` to a new real namespace in this slice.
- Do not move `lib/igniter/store/**`.
- Do not rename `igniter_store_native`.
- Do not change wire protocol token `:igniter_store`.
- Do not remove compatibility shims.
- Do not perform broad mechanical replacement in historical research docs.

## Suggested Read Set

Read in this order:

1. `docs/package-agent-onboarding.md`
2. `docs/progress.md`
3. this track
4. `README.md`
5. `igniter-ledger.gemspec`
6. `lib/igniter-ledger.rb`
7. `lib/igniter-store.rb`
8. `lib/igniter/ledger.rb`
9. `lib/igniter/store.rb`
10. `exe/igniter-ledger-server`
11. `exe/igniter-store-server`
12. `packages/igniter-companion/Gemfile`
13. `packages/igniter-companion/lib/igniter/companion/store.rb`

Then use `rg` to classify remaining tokens.

## Implementation Scope

### 1. Audit Map

Add a compact doc section, either in this track under a final handoff section or
in a new focused doc if it grows too large:

```text
token/category/status/action
```

Required categories:

- package/gem/CLI
- require entrypoints
- Ruby namespace aliases
- internal namespace/file path
- protocol token
- native extension/crate
- docs/examples
- companion integration
- ledger-client relation

### 2. Compatibility Specs

Add or extend specs proving:

- `require "igniter-ledger"` loads the package.
- `require "igniter-store"` still loads the package.
- `Igniter::Ledger::LedgerStore` is usable.
- `Igniter::Store::LedgerStore` is usable.
- old `Igniter::Store.memory` still works.
- new `Igniter::Ledger.memory` works through the alias.
- `Igniter::Ledger::LedgerServer` resolves.
- `igniter-ledger-server --version` exits successfully.
- `igniter-store-server --version` exits successfully and prints the deprecation
  warning.

Prefer focused specs. Do not start real servers for CLI version checks.

### 3. Public Docs

Make current user-facing docs consistently present `igniter-ledger` as the
primary name:

- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger/docs/README.md`
- `packages/README.md` only if needed
- any current package docs that still instruct users to install/require/run
  `igniter-store`

Keep historical notes where useful, but mark them as history or compatibility.

### 4. Companion Integration

Verify that companion docs/code do not present `igniter-store` as the current
dependency.

Compatibility with `Igniter::Store` constants inside implementation code is
acceptable in this slice when it avoids a deeper namespace migration.

### 5. Deep Rename Plan

Add a short plan section:

```text
R1: public rename and compatibility hardening
R2: internal namespace/file path migration
R3: protocol/native token decision
```

For each phase, list:

- what changes
- what must stay compatible
- required tests
- rollback risk

## Acceptance

This track is done when:

- remaining `store` tokens are classified rather than ignored
- current public docs lead with `igniter-ledger`
- compatibility shims have tests
- CLI version paths work for both new and old executable names
- no accidental protocol/native token rename happened
- Package Agent provides the deep-rename phase plan
- tests pass:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
BUNDLE_GEMFILE=packages/igniter-companion/Gemfile bundle exec rspec packages/igniter-companion/spec
bundle exec rspec packages/igniter-ledger-client/spec
```

If RuboCop is available through the active bundle, run focused lint on files
touched by this track. If not available in the package Gemfile, report that
clearly and do not add RuboCop just for this slice.

## Handoff Format

At the end, respond with:

```text
[Package Agent / Companion+Store]
Track: igniter-ledger/ledger-rename-hardening-compatibility-audit-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[S] Shipped:
- ...

[T] Tests:
- ...

[R] Risks / next recommendations:
- ...
```


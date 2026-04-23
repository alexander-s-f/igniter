# Core Retirement Inventory

This note tracks the concrete blockers between the current monorepo state and
full removal of `packages/igniter-core`.

It is intentionally narrower than
[contracts-migration-roadmap.md](./contracts-migration-roadmap.md): that
document explains the strategic phases, while this one captures the practical
inventory we can burn down.

## Current Status

The extension-boundary migration backlog is closed:

- all current `igniter/extensions/*` activators in scope now point to explicit
  contracts-side replacements
- `igniter-contracts` is independent from `igniter-core` at implementation
  load-time
- `igniter-mcp-adapter` sits on top of `igniter-extensions` and does not carry
  runtime `igniter-core` semantics

What remains is retirement cleanup across package metadata, public docs, and
legacy-only runtime surfaces.

## Blocker Inventory

### 1. Package Metadata Still Coupled To Core

These packages still declare a runtime dependency on `igniter-core` in their
gemspecs:

- `igniter-agents`
- `igniter-ai`
- `igniter-app`
- `igniter-cluster`
- `igniter-extensions`
- `igniter-rails`
- `igniter-sdk`
- `igniter-server`

Package metadata version loading has now been detached from `packages/igniter-core`.

All gemspecs that still need `Igniter::VERSION` now load it from the neutral
root version source instead of from `packages/igniter-core/lib/igniter/core/version.rb`.

That means the remaining core coupling is now about real runtime/package
dependencies, not shared version metadata.

### 2. Runtime / Lib Surfaces Still Reach Into Core

The largest remaining code-level consumers are:

- `igniter-ai`
- `igniter-sdk`
- `igniter-server`
- `igniter-cluster`
- `igniter-agents`
- `igniter-app`

Typical patterns still present:

- `require "igniter/core/errors"`
- `require "igniter/core/tool"`
- `require "igniter/core/runtime"`
- `require "igniter/core/memory"`
- direct `require "igniter/core"`

This means `igniter-core` is already semantically demoted, but not yet isolated
to a legacy compatibility island.

One small peel is now already in place:

- `igniter-sdk` and `igniter-ai` no longer require
  `igniter/core/errors`, `igniter/core/tool`, or `igniter/core/effect`
  directly
- they now go through stable root entrypoints:
  `igniter/errors`, `igniter/tool`, `igniter/effect`
- `igniter-agents` and `igniter-server` no longer require
  `igniter/core/errors` directly and instead use `igniter/errors`
- `igniter-agents` no longer requires
  `igniter/core/runtime/agent_adapter` directly and instead uses the stable
  root seam `igniter/runtime/agent_adapter`
- the root facade, `igniter-server`, `igniter-cluster`, and app diagnostics
  now use stable root entrypoints for `igniter/contract`,
  `igniter/runtime`, and `igniter/diagnostics` instead of requiring
  `igniter/core/contract`, `igniter/core/runtime`, and
  `igniter/core/diagnostics` directly

That does not remove the runtime dependency yet, but it does remove direct
knowledge of legacy core file layout from those upper packages.

### 3. Docs Still Treat Core As A Public First-Class Lane

Public and dev docs still contain core-first or extension-activator-first
navigation in several places. The highest-signal cleanup targets are:

- `README.md`
- `docs/guide/README.md`
- `docs/guide/deployment-modes.md`
- `docs/dev/architecture-index.md`
- `docs/dev/package-map.md`

The migration direction is already documented, but the default reading path is
not yet consistently post-core.

### 4. Legacy Examples And Specs Still Exist By Design

This is expected right now. They should stay only while they provide one of the
following:

- parity/reference coverage during retirement
- migration comparison examples
- coverage for still-unmigrated higher-level packages

They should not continue to function as the default onboarding path.

## Immediate Work Order

### Step 1: Freeze The Dependency Surface

Prevent new package-level `igniter-core` dependencies from appearing outside the
current retirement whitelist.

This is the lowest-risk step because it does not yet force package rewrites; it
just stops the backlog from growing.

### Step 2: Detach Version Metadata From Core

Move package version loading away from:

- `require_relative "../igniter-core/lib/igniter/core/version"`
- `require "igniter/core/version"`

This work is now done for package metadata.

The remaining retirement work is runtime/package dependency cleanup.

### Step 3: Rework Remaining Runtime Consumers Package By Package

Suggested order:

1. `igniter-extensions`
   after activator migration, it should become contracts-facing plus temporary
   legacy shims only
2. `igniter-sdk` / `igniter-ai`
   mostly focused support surfaces
3. `igniter-server` / `igniter-cluster`
   higher-level runtime hosting layers
4. `igniter-app` / generators
   user-facing scaffolding should flip only after lower layers are stable

### Step 4: Rewrite Public Navigation

Once the package/runtime graph is flatter:

- make `igniter-contracts` and contracts-facing packs the default embedded story
- demote `igniter-core` docs to legacy/reference only
- remove core-first examples from default recommendation paths

## Done Criteria

`packages/igniter-core` is ready for deletion only when all of these are true:

- no gemspec outside `igniter-core` depends on `igniter-core`
- no gemspec outside `igniter-core` loads version metadata from core paths
- no target package runtime requires `igniter/core` entrypoints
- docs treat core as legacy/reference only
- remaining specs/examples that touch core do so explicitly as parity fixtures

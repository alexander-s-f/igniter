# PROP-036 CLI Docs Navigation Polish v0

Card: S3-R54-C2-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/prop036-cli-docs-navigation-polish-v0
Route: UPDATE
Status: done
Date: 2026-05-16

---

## Scope

Close the R53 NB-1 docs-navigation note by making the bounded PROP-036 CLI
transport easy to find from the docs index.

Read:

- [prop036-cli-release-readiness-docs-sync-v0.md](prop036-cli-release-readiness-docs-sync-v0.md)
- [prop036-cli-release-readiness-docs-pressure-v0.md](../discussions/prop036-cli-release-readiness-docs-pressure-v0.md)
- [stage3-round53-status-curation-v0.md](stage3-round53-status-curation-v0.md)
- [README.md](../README.md)
- [ruby-api.md](../ruby-api.md)

No code was edited.

---

## Navigation Change

Updated [docs/README.md](../README.md) navigation with a compact pointer to the
existing CLI section:

```text
Bounded CLI profile-source transport
  -> ruby-api.md#cli-compiler-profile-source-transport
     only `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
     no production/runtime authority
```

No new CLI document was created because the existing index shape supports a
small explicit pointer.

---

## Authorization Boundary

This navigation polish does not widen any surface.

Preserved distinctions:

- Ruby facade docs remain in `docs/ruby-api.md`;
- bounded CLI transport docs are a subsection of `docs/ruby-api.md`;
- release-ready CLI shape remains only:

  ```text
  igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
  ```

- production/runtime authority remains closed and requires separate gates.

No implementation, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory,
stream/OLAP, cache, CompatibilityReport, loader/report status, dispatch
migration, signing, receipts, `.ilk`, golden migration, or production behavior
is authorized by this change.

---

## Changed Files

```text
M igniter-lang/docs/README.md
A igniter-lang/docs/tracks/prop036-cli-docs-navigation-polish-v0.md
```

No code files changed.

---

## Handoff

```text
Card: S3-R54-C2-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/prop036-cli-docs-navigation-polish-v0
Status: done

[D] Decisions
- Added one compact docs-index pointer instead of creating a new CLI document.
- Kept wording explicit: only the exact R52 CLI shape is release-ready.
- Preserved production/runtime authority closure in the navigation line.

[S] Signals
- R53 NB-1 is closed as a navigation issue.
- `docs/ruby-api.md` remains the caller-facing reference for both Ruby facade
  and bounded CLI transport.

[T] Tests / Checks
- Documentation-only check.
- No code edits.

[R] Risks / Recommendations
- Future full CLI docs can be created later if CLI surface grows, but current
  bounded shape does not need a separate document.
```

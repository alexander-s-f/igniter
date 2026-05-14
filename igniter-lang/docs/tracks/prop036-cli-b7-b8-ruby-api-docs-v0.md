# Track: PROP-036 CLI B7/B8 Ruby API Docs v0

Card: S3-R47-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-cli-b7-b8-ruby-api-docs-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles: `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Land caller-facing Ruby API docs for:

```ruby
IgniterLang.compile(..., compiler_profile_source:)
```

and close or explicitly route the public-doc portions of `PROP036-CLI-B7` and
`PROP036-CLI-B8`.

This is documentation-only. It does not implement CLI flags, path loading, JSON
parsing, discovery/defaulting, loader/report, runtime, or production behavior.

---

## Inputs Read

- `docs/gates/prop036-cli-blocker-closure-criteria-decision-v0.md`
- `docs/tracks/prop036-cli-b7-b8-docs-completion-bar-v0.md`
- `docs/tracks/prop036-facade-source-contract-hardening-v0.md`
- `docs/README.md`
- `lib/igniter_lang.rb`

---

## Changed Docs

Added:

```text
docs/ruby-api.md
```

Updated:

```text
docs/README.md
```

The README navigation now links:

```text
Ruby API facade                -> ruby-api.md
```

---

## What Landed

`docs/ruby-api.md` now includes:

- `IgniterLang.compile` signature with `compiler_profile_source: nil`;
- supported shapes: `nil` or an already-finalized
  `compiler_profile_id_source` Hash-like object;
- required finalized source fields;
- nil `legacy_optional` behavior;
- invalid caller assumptions;
- non-authorized surfaces;
- transport-only facade wording;
- statement that future accepted source-shape widening needs review.

---

## B8-C Source-Comment Deferral

No source code was edited.

For `PROP036-CLI-B8-C`, source-level visibility is explicitly deferred by this
track:

```text
deferral path: docs/tracks/prop036-cli-b7-b8-ruby-api-docs-v0.md
deferral decision: B8 relies on docs/ruby-api.md plus dev-contract wording for
the current CLI blocker closure; source-level comment visibility may be opened
later as a separate authorized implementation-doc card.
```

Suggested optional follow-up card:

```text
Card: PROP036-facade-transport-source-comment-v0
Route: UPDATE
Scope:
- Add a short source comment near compiler_profile_source: in lib/igniter_lang.rb
  stating that IgniterLang.compile is transport-only and that validation/refusal
  belongs to the orchestrator/assembler source path.
- No behavior change.
```

This optional card is not required for the current public-doc closure because
B8-C permits explicit deferral by a named docs/governance card.

---

## Mechanical Evidence

Required B7/B8 strings:

```text
docs/ruby-api.md contains "compiler_profile_source: nil"
docs/ruby-api.md contains "compiler_profile_id_source"
docs/ruby-api.md contains "transport-only"
docs/ruby-api.md contains "forwards the value unchanged"
docs/ruby-api.md contains "does not validate, finalize, discover"
docs/ruby-api.md contains "future card"
docs/README.md links to docs/ruby-api.md
```

Observed commands:

```text
rg -n "compiler_profile_source: nil|compiler_profile_id_source|transport-only|forwards the value unchanged|does not validate, finalize, discover|future card" igniter-lang/docs/ruby-api.md
rg -n "ruby-api.md" igniter-lang/docs/README.md
git diff --check -- igniter-lang/docs/ruby-api.md igniter-lang/docs/README.md igniter-lang/docs/tracks/prop036-cli-b7-b8-ruby-api-docs-v0.md
```

All observed checks PASS in this slice.

---

## B7/B8 Recommendation

| Blocker | Recommendation | Reason |
| --- | --- | --- |
| `PROP036-CLI-B7` | closed | Caller-facing Ruby API doc exists at `docs/ruby-api.md`, is linked from `docs/README.md`, and includes source shape, nil behavior, invalid assumptions, and non-authorized surfaces. |
| `PROP036-CLI-B8` | closed | Public transport-only wording landed in `docs/ruby-api.md`; future widening review is explicit; B8-C source-level visibility is explicitly deferred by this named track. |

This closes B7/B8 documentation blockers only. It does not close B1, B3, B4, B5,
B6, or B9, and it does not authorize CLI implementation.

---

## Non-Authorization

This track does not authorize:

- CLI flags;
- path loading;
- JSON parsing;
- profile discovery, inference, finalization, or defaulting in CLI/API;
- source code edits;
- loader/report implementation;
- CompatibilityReport compiler-profile section;
- `.igapp` golden migration;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- RuntimeMachine binding;
- Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production executors;
- production cache;
- production behavior.

---

## Handoff

```text
Card: S3-R47-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop036-cli-b7-b8-ruby-api-docs-v0
Status: done

[D] Decisions
- Public Ruby API docs live at docs/ruby-api.md.
- docs/README.md links to the new public doc.
- B8-C source-level visibility is explicitly deferred by this track, with an
  optional later source-comment card recommended.

[S] Shipped / Signals
- Added docs/ruby-api.md.
- Updated docs/README.md navigation.
- Added this closure track with mechanical evidence strings.

[T] Tests / Proofs
- Documentation-only checks PASS.

[R] Recommendation
- PROP036-CLI-B7: closed.
- PROP036-CLI-B8: closed.
- CLI implementation remains held behind the remaining blockers.

[Next]
- Continue B1/B3/B6/B9 closure work before any CLI implementation
  authorization.
```

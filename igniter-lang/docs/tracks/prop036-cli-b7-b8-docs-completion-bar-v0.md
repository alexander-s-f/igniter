# Track: PROP-036 CLI B7/B8 Docs Completion Bar v0

Card: S3-R46-C3-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-cli-b7-b8-docs-completion-bar-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles: `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Define exact completion bars for `PROP036-CLI-B7` and `PROP036-CLI-B8`, so
dev-contract wording cannot be mistaken for public guide/API completion.

This is docs/process clarification only. It does not edit implementation, create
new language semantics, or authorize CLI implementation.

---

## Inputs Read

- `docs/tracks/prop036-facade-source-contract-hardening-v0.md`
- `docs/discussions/prop036-cli-exposure-design-pressure-v0.md`
- `docs/gates/prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md`
- `docs/tracks/README.md`
- `docs/current-status.md`
- `docs/spec/README.md`
- `docs/README.md`

---

## Current State

`PROP036-CLI-B7` currently says:

```text
Caller-facing source-shape docs:
Add or route public API/guide docs explaining the finalized source object,
nil behavior, and non-authorized assumptions.
```

`PROP036-CLI-B8` currently says:

```text
Transport-only facade contract location:
Add or route explicit contract wording so future orchestrator validation
widening does not silently become public facade policy without review.
```

R45 C2 produced the correct wording in a track document:

```text
docs/tracks/prop036-facade-source-contract-hardening-v0.md
```

That means:

```text
dev-contract wording exists: yes
public guide/API docs landed: no
source-level visibility landed: no
source-level visibility explicitly deferred: not yet
```

Therefore B7 and B8 are not closed by R45 C2 alone.

---

## Destination Decision

Recommended exact destinations:

| Need | Destination | Required status |
| --- | --- | --- |
| Public/caller-facing Ruby facade docs | `docs/ruby-api.md` plus a navigation link from `docs/README.md` | Required for B7 closure |
| Dev contract wording | `docs/tracks/prop036-facade-source-contract-hardening-v0.md` and this track | Already exists; evidence only, not public completion |
| Optional source-level comment wording | `lib/igniter_lang.rb` near `compiler_profile_source:` | Optional for B8 if later authorized; otherwise explicitly defer |
| Spec chapter | Not recommended for B7/B8 | This is caller API contract, not language semantics |
| PROP-036 errata | Not recommended for B7/B8 | PROP semantics are unchanged |

Rationale:

- `docs/spec/` is the language spec, not public Ruby API usage guidance.
- `docs/tracks/` is slice evidence, not the caller guide.
- `docs/README.md` is navigation, not enough by itself.
- The repo currently has no `docs/guide/` or `docs/api/` tree, so a root-level
  `docs/ruby-api.md` is the smallest explicit caller-facing landing target.

If a later docs card chooses a different caller-facing path, it must name that
path and update `docs/README.md` navigation. It must not close B7 by pointing
only to a track.

---

## Completion Bar: PROP036-CLI-B7

`PROP036-CLI-B7` is closed only when all criteria below are true.

### B7-A: Public Doc Exists

A caller-facing Ruby API doc exists at:

```text
docs/ruby-api.md
```

or at another explicitly named public API/guide path approved by the docs card.

### B7-B: Public Doc Is Discoverable

`docs/README.md` links to that public API/guide doc from its Navigation or an
equivalent top-level section.

### B7-C: Source Shape Is Documented For Callers

The public doc includes the `IgniterLang.compile` signature with:

```ruby
compiler_profile_source: nil
```

and describes the only supported caller shapes:

```text
nil
already-finalized compiler_profile_id_source Hash-like object
```

The doc must include the required finalized source fields:

- `kind: "compiler_profile_id_source"`
- `format_version: "0.1.0"`
- `status: "finalized"`
- `profile_namespace: "compiler_profile_unified"`
- `compiler_profile_id`
- `descriptor_digest`
- `finalization_payload_digest`
- `profile_kind`
- `slot_order`
- `slot_assignments`
- `dispatch_migration_authorized: false`
- `runtime_authority_granted: false`

### B7-D: Nil Behavior Is Explicit

The public doc states:

```text
compiler_profile_source: nil is the default and preserves legacy_optional
behavior; assembled manifests omit compiler_profile_id.
```

### B7-E: Invalid Assumptions Are Explicit

The public doc states callers must not pass:

- a file path;
- a raw JSON string;
- a raw `compiler_profile_id` string;
- an unfinalized descriptor;
- a source object that grants runtime authority;
- a source object that authorizes compiler dispatch migration.

### B7-F: Non-Authorized Surfaces Are Explicit

The public doc states `compiler_profile_id` and `compiler_profile_source` do not
grant or implement:

- CLI profile source flags;
- path loading;
- inline JSON parsing;
- profile discovery/defaulting/finalization in the facade;
- loader/report status;
- CompatibilityReport profile section;
- `.igapp` golden migration;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- RuntimeMachine/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/cache/production
  authority.

### B7-G: Closure Evidence Is Mechanical

The closing card records exact file paths and at least these evidence strings:

```text
docs/ruby-api.md contains "compiler_profile_source: nil"
docs/ruby-api.md contains "compiler_profile_id_source"
docs/ruby-api.md contains "transport-only" or references the B8 section
docs/README.md links to docs/ruby-api.md
```

The exact commands may use `rg`.

---

## Completion Bar: PROP036-CLI-B8

`PROP036-CLI-B8` is closed only when all criteria below are true.

### B8-A: Transport-Only Wording Lands In Public Docs

The public API/guide doc contains wording equivalent to:

```text
IgniterLang.compile treats compiler_profile_source: as transport-only. It
forwards the value unchanged to CompilerOrchestrator#compile.

The facade does not validate, finalize, discover, infer, load, parse, normalize,
or default compiler profile sources. Validation and refusal are owned by the
orchestrator/assembler compiler-profile-source path.

Changing accepted source shapes is a public API contract change. A future card
that widens orchestrator/assembler validation must explicitly review whether the
Ruby facade should expose that widened shape to callers.
```

### B8-B: Review Boundary Is Explicit

The public doc or a named dev-contract section states:

```text
Future orchestrator/assembler validation widening does not automatically close
the facade/API review requirement.
```

### B8-C: Source-Level Visibility Is Landed Or Explicitly Deferred

One of these must be true:

1. A later authorized tiny implementation-doc card adds a source comment in
   `lib/igniter_lang.rb` near `compiler_profile_source:` stating the facade is
   transport-only; or
2. A named docs/governance card explicitly defers source-level visibility and
   records that B8 relies on public docs plus dev-contract wording instead.

Silent absence of a source comment does not close B8.

### B8-D: Closure Evidence Is Mechanical

The closing card records exact file paths and at least these evidence strings:

```text
docs/ruby-api.md contains "transport-only"
docs/ruby-api.md contains "forwards the value unchanged"
docs/ruby-api.md contains "does not validate, finalize, discover"
docs/ruby-api.md contains "future card"
```

If source-level visibility lands, also record:

```text
lib/igniter_lang.rb contains "transport-only"
```

If source-level visibility is deferred, record the exact deferral document path.

---

## State Distinctions

| State | Meaning | Current status |
| --- | --- | --- |
| Dev-contract exists | Track wording defines safe interpretation for agents and reviewers | Done: `prop036-facade-source-contract-hardening-v0.md` |
| Guide/API docs landed | Caller-facing docs are present and linked from docs navigation | Pending |
| Source-level visibility landed | A code-adjacent comment makes transport-only visible in `lib/igniter_lang.rb` | Pending / optional |
| Source-level visibility deferred | A named docs/governance card explicitly says no source comment is required for B8 | Pending |

B7 requires Guide/API docs landed. B8 requires Guide/API transport-only wording
plus source-level visibility landed or explicitly deferred.

---

## Suggested Docs-Only Follow-Up Card

```text
Card: PROP036-CLI-B7-B8-ruby-api-docs-v0
Agent: [Igniter-Lang Compiler/Grammar Expert] or [Igniter-Lang Meta Expert]
Route: UPDATE

Goal:
Land caller-facing Ruby API docs for IgniterLang.compile(...,
compiler_profile_source:) and close PROP036-CLI-B7/B8 public-doc portions.

Scope:
- Create docs/ruby-api.md.
- Link it from docs/README.md.
- Include finalized compiler_profile_id_source shape, nil legacy behavior,
  invalid caller assumptions, non-authorized surfaces, and transport-only facade
  wording.
- Decide whether source-level visibility is deferred or routed to a tiny
  authorized source-comment card.
- Do not edit implementation unless separately authorized.
- Do not authorize CLI implementation.

Acceptance:
- B7-A through B7-G pass.
- B8-A, B8-B, and B8-D pass.
- B8-C either lands a source comment through separate authorization or records
  explicit deferral.
```

Optional later source-comment card:

```text
Card: PROP036-facade-transport-source-comment-v0
Scope:
- Add a short comment in lib/igniter_lang.rb near compiler_profile_source:
  explaining that the facade is transport-only and validation/refusal belongs to
  the orchestrator/assembler path.
- No behavior change.
```

---

## Non-Authorization

This track does not authorize:

- CLI implementation;
- CLI flags;
- path loading in code;
- inline JSON parsing;
- source comments or implementation edits;
- new language semantics;
- profile finalization/defaulting/discovery in CLI or facade;
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
Card: S3-R46-C3-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop036-cli-b7-b8-docs-completion-bar-v0
Status: done

[D] Decisions
- B7 is not closed by dev-contract wording alone; it requires linked
  caller-facing guide/API docs.
- B8 is not closed by dev-contract wording alone; it requires public
  transport-only wording plus source-level visibility landed or explicitly
  deferred.
- Recommended public destination: docs/ruby-api.md linked from docs/README.md.
- Spec/PROP errata are not the right destinations because no language semantics
  change.

[S] Shipped / Signals
- Defined exact B7 and B8 closure criteria.
- Defined proposed doc destinations and mechanical evidence strings.
- Suggested a docs-only follow-up card.

[T] Tests / Proofs
- Documentation-only completion bar; no implementation or artifact changes.

[R] Risks / Recommendations
- Do not allow "add or route" to close B7/B8 by pointing only to a track doc.
- Require mechanical evidence of public docs before CLI implementation
  authorization can claim B7/B8 closed.

[Next]
- Open `PROP036-CLI-B7-B8-ruby-api-docs-v0`.
```

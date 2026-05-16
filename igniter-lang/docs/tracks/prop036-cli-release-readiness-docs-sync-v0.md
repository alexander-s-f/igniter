# PROP-036 CLI Release Readiness Docs Sync v0

Card: S3-R53-C1-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/prop036-cli-release-readiness-docs-sync-v0
Route: UPDATE
Status: done
Date: 2026-05-16

---

## Scope

Satisfy the R52 caller-facing documentation condition for the bounded PROP-036
CLI transport without changing code.

Updated:

- [ruby-api.md](../ruby-api.md)

Not updated:

- [README.md](../README.md) - no new CLI doc was created, so no new index link
  was needed.
- `igniter-lang/lib/igniter_lang/cli.rb` - read for behavior only; no code edit.

---

## Documentation Changes

`docs/ruby-api.md` now:

- qualifies the old blanket statement that CLI profile-source flags and path
  loading were closed;
- names the R52 bounded exception exactly:

  ```text
  igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
  ```

- states that `PATH.json` must be an already-finalized
  `compiler_profile_id_source` JSON object;
- documents no-flag legacy behavior;
- documents CLI preflight refusal shape and cases;
- documents semantic compiler-profile-source refusal shape and qualified
  `compiler_profile_source.*` vocabulary;
- states transport-only CLI behavior;
- preserves no discovery/defaulting/finalization;
- preserves all excluded surfaces.

No new implementation, release authority, runtime authority, or production
behavior is authorized by this docs sync.

---

## R52 Condition Checklist

| Required content item | Yes/No | Where satisfied |
| --- | --- | --- |
| Exact bounded CLI shape: `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json` | Yes | Top summary and `CLI Compiler Profile Source Transport` |
| `PATH.json` is already-finalized `compiler_profile_id_source` object | Yes | `CLI Compiler Profile Source Transport` |
| No-flag legacy behavior | Yes | `No-Flag Legacy Behavior` |
| CLI preflight refusal behavior | Yes | `CLI Preflight Refusals` |
| Semantic compiler-profile-source refusal behavior | Yes | `Semantic Profile-Source Refusals` |
| Transport-only semantics | Yes | `CLI Compiler Profile Source Transport` and `Transport-Only Facade` |
| No discovery/defaulting/finalization | Yes | Top summary, CLI section, rejected shapes, non-authorized surfaces |
| All excluded surfaces remain closed | Yes | `Still Rejected CLI Shapes` and `Non-Authorized Surfaces` |
| Outdated blanket CLI closure statement removed or qualified | Yes | Opening section now names the R52 bounded exception and keeps all other shapes closed |
| RuntimeMachine remains closed | Yes | `Non-Authorized Surfaces` |
| Gate 3 remains closed / not widened | Yes | `Non-Authorized Surfaces` |
| Ledger/TBackend remains closed | Yes | `Non-Authorized Surfaces` |
| BiHistory remains closed | Yes | `Non-Authorized Surfaces` |
| stream/OLAP remain closed | Yes | `Non-Authorized Surfaces` |
| cache remains closed | Yes | `Non-Authorized Surfaces` |
| CompatibilityReport remains closed | Yes | `Non-Authorized Surfaces` |
| loader/report status remains closed | Yes | `Non-Authorized Surfaces` |
| dispatch migration remains closed | Yes | `Non-Authorized Surfaces` |
| signing remains closed | Yes | `Non-Authorized Surfaces` |
| receipts remain closed | Yes | `Non-Authorized Surfaces` (`CompilationReceipt links`) |
| `.ilk` remains closed | Yes | `Non-Authorized Surfaces` |
| `.igapp` golden migration remains closed | Yes | `Non-Authorized Surfaces` |
| production behavior remains closed | Yes | `Non-Authorized Surfaces` |

---

## Changed Files

```text
M igniter-lang/docs/ruby-api.md
A igniter-lang/docs/tracks/prop036-cli-release-readiness-docs-sync-v0.md
```

No code files changed.

---

## Remaining Docs Gaps / Verification Recommendation

Docs gap found by this card: none.

Recommended verification:

- run a follow-up pressure or status-curation check against the R52 checklist
  before marking `conditional-release-readiness-doc-sync-required` as fully
  satisfied in living status maps;
- no implementation proof rerun is required for this docs-only card unless a
  verifier finds a docs/behavior mismatch.

---

## Handoff

```text
Card: S3-R53-C1-P1
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/prop036-cli-release-readiness-docs-sync-v0
Status: done

[D] Decisions
- Used `docs/ruby-api.md` as the caller-facing surface; no separate CLI doc was
  needed.
- Qualified the old blanket CLI closure statement with the R52 bounded exception.
- Did not edit code and did not update `docs/README.md`.

[S] Signals
- R52 required docs content is now present in caller-facing docs.
- Bounded CLI transport remains path-JSON transport only.

[T] Tests / Checks
- Docs-only sync.
- Checklist above maps every R52 content item to `ruby-api.md`.

[R] Risks / Recommendations
- A later pressure or status-curation card should verify the docs condition
  before marking release-readiness complete in current maps.
- Keep all excluded surfaces closed unless a separate Architect decision opens
  them.
```

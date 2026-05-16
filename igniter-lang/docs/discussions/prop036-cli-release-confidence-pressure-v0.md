# Discussion: PROP-036 CLI Release Confidence Pressure v0

Card: S3-R54-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: release-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-release-confidence-pressure-v0

Depends on: S3-R54-C1-P1 and S3-R54-C2-P1 delivered

Question:

Does the R54 release-confidence smoke (C1-P1) confirm that the bounded surface
behaves as documented? Does the docs-navigation polish (C2-P1) correctly close
the R53 NB-1 without implying any wider surface? Does any wording in either
card or in updated docs drift from release-confidence toward
production-deployment authorization?

Context:
- R52 (C1-A): Conditional release-readiness approval — code/proof sufficient;
  docs condition required before marking fully release-ready
- R53 (C1-P1 + C2-X + C3-S): Docs condition satisfied; `docs/ruby-api.md`
  verified by external pressure; R53 NB-1 identified docs-navigation debt
  (CLI section buried in "Ruby API" doc, no README.md pointer)
- R54 scope: C1-P1 = caller-style release-confidence smoke; C2-P1 = docs
  navigation polish to close R53 NB-1; C3-X (this card) = external pressure
  on both outputs before status curation

---

## Scope Check 1 — Command Matrix Coverage

C1-P1 runs five commands:

| Case | Covered | Gate Requirement |
|---|---|---|
| No-flag legacy compile | ✓ | §Supported Success And Refusal Behavior (R52-C1-A) |
| Valid `--compiler-profile-source PATH.json` | ✓ | R52-C1-A |
| Bad path preflight refusal | ✓ | CLI Preflight Refusals (ruby-api.md) |
| Malformed JSON preflight refusal | ✓ | CLI Preflight Refusals (ruby-api.md) |
| Semantic unfinalized source refusal | ✓ | Semantic Profile-Source Refusals (ruby-api.md) |

**Coverage assessment.** The smoke intentionally covers the five most
caller-representative scenarios. The full B3/B6 proof matrix (12 cases) already
exercised exhaustive coverage including directory path, unreadable file,
top-level JSON array, wrong-kind source, and runtime-authority-forbidden source.
The release-confidence smoke is a caller-perspective cross-check, not a full
proof rerun. The five-case selection is appropriate and sufficient.

**Summary artifact cross-check.** The summary JSON at
`/tmp/igniter_lang_prop036_cli_release_confidence_smoke/prop036_cli_release_confidence_smoke_summary.json`
was independently read:

```json
"status": "PASS"
```

All five `"pass": true` entries confirmed. The summary was independently
observed, not taken only from C1-P1's self-report. ✓

---

## Scope Check 2 — Observed Results Match Gate Specification

Each observed result is checked against the R52-C1-A gate specification.

**No-flag legacy compile:**

| Field | Observed | Gate requires |
|---|---|---|
| exitstatus | 0 | 0 |
| stdout | compiler_result JSON, status ok | compiler_result JSON |
| stderr | empty | empty on success |
| .igapp emitted | yes | yes |
| manifest.compiler_profile_id | absent | absent |

✓ Matches.

**Valid `--compiler-profile-source PATH.json`:**

| Field | Observed | Gate requires |
|---|---|---|
| exitstatus | 0 | 0 |
| stdout | compiler_result JSON, status ok | compiler_result JSON |
| stderr | empty | empty on success |
| .igapp emitted | yes | yes |
| manifest.compiler_profile_id | `compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7` | from source object |

The emitted `compiler_profile_id` matches the `compiler_profile_id` field of
the input finalized source artifact. The CLI passed the value unchanged.
Transport-only semantics confirmed. ✓

**Bad path preflight refusal:**

| Field | Observed | Gate requires |
|---|---|---|
| exitstatus | 1 | non-zero |
| stdout | empty | empty |
| stderr | "compiler profile source path not found" | one stable line |
| .igapp emitted | no | no |
| compilation_report emitted | no | no |

✓ Matches. Stable refusal message. No artifact leakage.

**Malformed JSON preflight refusal:**

| Field | Observed | Gate requires |
|---|---|---|
| exitstatus | 1 | non-zero |
| stdout | empty | empty |
| stderr | "compiler profile source file must contain valid JSON" | one stable line |
| .igapp emitted | no | no |
| compilation_report emitted | no | no |

✓ Matches. Stable refusal message. No artifact leakage.

**Semantic unfinalized source refusal:**

| Field | Observed | Gate requires |
|---|---|---|
| exitstatus | 1 | non-zero |
| stdout | compiler_result JSON, status assembler_refused | compiler_result JSON |
| stderr | empty | empty |
| .igapp emitted | no | no |
| compilation_report emitted | yes | yes |
| refusal vocabulary | `compiler_profile_source.unfinalized` | qualified `compiler_profile_source.*` |

The refusal reason `compiler_profile_source.unfinalized` is a qualified
source-validation term, not a forbidden bare loader-status token. ✓

**Overall: all five observed results match gate specification exactly.** ✓

---

## Scope Check 3 — Forbidden-Surface Leakage in Smoke

C1-P1's non-authorization section explicitly names:

> inline JSON; named/generated profile-source lookup; env/config/sidecar
> lookup; profile discovery, defaulting, or finalization; loader/report or
> CompatibilityReport status; `.ilk`, receipts, signing, or dispatch
> migration; RuntimeMachine, Gate 3 widening, Ledger/TBackend, BiHistory,
> stream/OLAP, cache, or production behavior.

No forbidden term appears in any observed command output. The semantic refusal
diagnostic `compiler_profile_source.unfinalized` is a qualified source-validation
term consistent with the existing compiler/assembler path and the R52 gate's
accepted vocabulary.

The smoke uses existing proof artifacts:
- `compiler_profile_source.stage3_proof.json` (finalized artifact from prior
  proof round) — appropriate for a release-confidence exercise
- `invalid_json.json` and `unfinalized_source.json` from the B3/B6 proof inputs
  — known-bad inputs; reuse is appropriate

No new artifact types were created; no proof directories were mutated. ✓

---

## Scope Check 4 — Docs Navigation Wording

C2-P1 adds one navigation entry to `docs/README.md`:

```text
Bounded CLI profile-source transport
  → ruby-api.md#cli-compiler-profile-source-transport
    only `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
    no production/runtime authority
```

**Anchor check.** The section heading in `docs/ruby-api.md` is `## CLI Compiler
Profile Source Transport` which produces the GitHub Markdown anchor
`#cli-compiler-profile-source-transport`. The README pointer matches. ✓

**Scope wording check.** The navigation line explicitly:
- names the exact bounded shape;
- says "only" before it;
- says "no production/runtime authority" after it.

A caller reading the README cannot infer that discovery, finalization, inline
JSON, CompatibilityReport, RuntimeMachine, or any production surface is implied
by this navigation pointer. ✓

**No forbidden-surface implication in docs/README.md navigation.** The existing
docs/README.md entries for Stage 1 and Stage 2 surfaces are unchanged. The new
navigation entry adds only a bounded pointer consistent with R52 scope. ✓

---

## Scope Check 5 — Release-Confidence vs Production-Deployment Vocabulary

This is the principal vocabulary drift risk for R54.

C1-P1 language review:

- "Exercise the already release-ready bounded PROP-036 CLI transport from a
  caller perspective" — scoped to R52 boundary ✓
- "R53 package-surface readiness survives caller-style smoke" — uses
  "package-surface readiness", not "production-ready" ✓
- "No release-engineering blocker found for the exact R52/R53 bounded surface" —
  qualified with "exact R52/R53 bounded surface" ✓
- "If Architect wants package-release automation confidence next, run a
  separate release-engineering card... not CLI semantics widening" — correctly
  defers package-release automation; does not self-authorize ✓

No sentence in C1-P1 says "production-ready," "production-deployment authorized,"
"runtime-ready," or any equivalent. ✓

C2-P1 language review:

- "production/runtime authority remains closed and requires separate gates" —
  explicitly preserved ✓
- "future full CLI docs can be created later if CLI surface grows" — deferred
  appropriately, no self-authorization ✓

R53 status curation language that R54 cites:

- "package-surface release-readiness: fully ready in exact R52 scope" — scoped ✓
- "Production/runtime authority remains closed" — preserved ✓

No vocabulary drift from release-confidence to production-deployment found. ✓

---

## Scope Check 6 — No New Authorization Created

C1-P1 is a read-and-run card. It reads existing code and proof artifacts, runs
five commands, and writes to `/tmp`. No code files modified. No proof directory
mutated. No new gate, authorization, or implementation created.

C2-P1 is a documentation-only card. Changed files:
- `igniter-lang/docs/README.md` — navigation pointer added
- `igniter-lang/docs/tracks/prop036-cli-docs-navigation-polish-v0.md` — track doc

Neither change widens the CLI surface, adds an implementation, or grants any
authority. ✓

---

[Agree]

1. **C1-P1 smoke is a well-scoped release-confidence check.** Five cases cover
   the complete gate-required success and refusal shapes without duplicating the
   full B3/B6 proof matrix. The /tmp isolation is the correct pattern for a
   confidence check that must not disturb existing proof artifacts.

2. **All five smoke results match the R52-C1-A gate specification exactly.**
   The valid-path case confirms transport-only semantics: the emitted
   `compiler_profile_id` matches the input artifact verbatim. The semantic
   refusal uses only qualified `compiler_profile_source.*` vocabulary. No
   forbidden bare token appears anywhere in the output.

3. **C2-P1 closes R53 NB-1 with the minimum required change.** One four-line
   navigation pointer, containing the exact bounded shape, "only", and "no
   production/runtime authority". No new CLI document created. The pointer
   anchor resolves to the correct section in `docs/ruby-api.md`. A caller
   searching "CLI" from the docs index can now find the bounded transport without
   guessing.

4. **No vocabulary drift toward production-deployment.** Both C1-P1 and C2-P1
   use "release-confidence," "package-surface readiness," and "exact R52/R53
   bounded surface" consistently. Neither card introduces "production-ready,"
   "runtime-ready," or any equivalent term.

5. **R54 evidence chain is complete and traceable.** C1-P1 → gate R52-C1-A +
   R53 status curation; C2-P1 → R53 NB-1 from pressure review; this card (C3-X)
   → both C1/C2 outputs plus the gate and R53 curation. No citation gap.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before status curation.

---

[NB-1 — Non-blocking: release-engineering card path still open]

C1-P1 correctly notes that if Architect wants package-release automation
confidence (gem installation path, bundled executable behavior, installed `igc`
invocation), a separate release-engineering card is the correct shape — not a
CLI semantics widening.

This is documented as a future option, not an open gap. The current smoke
exercises the CLI semantics layer from a dev-path invocation. An
installed-gem invocation smoke would be a release-engineering layer concern,
which is beyond the R52 scope and appropriately deferred.

Not blocking. Future release-engineering card is the correct route if needed.

---

## Release-Confidence Verdict: Strengthened

**The R54 evidence strengthens release confidence for the bounded PROP-036 CLI
transport within the exact R52/R53 scope.**

- C1-P1 smoke: 5/5 PASS, confirmed against summary artifact and gate spec
- C2-P1 navigation: R53 NB-1 closed; pointer is scoped, anchored correctly,
  and carries "no production/runtime authority"
- No forbidden-surface implication in any R54 output
- No vocabulary drift toward production-deployment

---

[Route]

**Verdict: proceed.**

No blockers. The R54 package (smoke + navigation polish) confirms release
confidence without widening scope.

**Status curation (C4-S) may record:**
- R54 complete;
- release-confidence smoke 5/5 PASS for the exact bounded surface;
- R53 NB-1 (docs navigation debt) closed by C2-P1;
- `docs/README.md` now points to `ruby-api.md#cli-compiler-profile-source-transport`
  with explicit "no production/runtime authority";
- bounded PROP-036 CLI transport: fully release-ready, release-confidence
  confirmed, documentation navigable;
- production/runtime authority remains closed and requires separate gates.

**For R55:**
- No implementation work is open from R54.
- If package-release automation confidence is needed (installed gem / bundled
  executable path), route a separate release-engineering card under Architect
  authorization — not a CLI semantics card.
- If the PROP-036 CLI surface needs to grow (new input shapes, wider profiles,
  etc.), that requires a new Architect proposal and blocker chain — not an
  extension of this release-confidence track.
- This PROP-036 CLI release line is otherwise complete. No further pressure
  or curation is required unless Architect opens a new scope.

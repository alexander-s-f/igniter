# Discussion: PROP-036 CLI Release Readiness Pressure v0

Card: S3-R52-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-release-readiness-pressure-v0

Depends on: S3-R52-C1-A delivered

Question:

Is the conditional release-readiness decision correctly structured? Does the
evidence chain read accurately? Is the docs condition specific enough to be
actionable without opening new implementation scope? Does the gate avoid
granting runtime, production, or Gate 3 authority? Is "release-readiness" as
used here properly distinguished from production deployment authority?

Context:
- C1-A (Architect Supervisor): Conditionally approves release-readiness for
  bounded CLI transport; status `conditional-release-readiness-doc-sync-required`;
  cites full R50/R51 evidence chain; docs condition requires updating ruby-api.md
  to reflect now-authorized CLI surface; non-authorization list fully preserved;
  explicit "does not grant production" statement
- S3-R51-C2-X: proceed; full B1–B9 package closed confirmed
- S3-R51-C1-A: B1–B9 formally closed
- S3-R50-C3-X: proceed; 9/9 scope checks
- S3-R50-C2-I: 12/12 proof; 0 forbidden hits; self-test pass×2
- `docs/ruby-api.md`: current public API doc with blanket non-authorization
  statement for CLI profile-source flags/path loading

---

## Six Scope Checks

### Check 1 — Gate authority and status encoding

**Result: PASS.**

`prop036-cli-release-readiness-decision-v0.md` is in `docs/gates/`, issued by
`[Architect Supervisor / Codex]`, `role: architect-supervisor`. ✓

The gate status `conditional-release-readiness-doc-sync-required` encodes
the conditionality directly in the status field — not just in the body. A
future reader scanning gate statuses cannot mistake this for an unconditional
approval.

### Check 2 — Evidence chain reads accurately without overclaim

**Result: PASS.**

Every figure in the "Regression And Proof Evidence Cited" section is traceable:

| Claim in C1-A | Source | Match |
|---|---|---|
| `12/12 PASS` | R50-C2-I case matrix | ✓ |
| `4/4 PASS` | R50-C2-I command matrix | ✓ |
| `forbidden_exact_token_hits: 0` | R50 proof summary field | ✓ |
| `scanner_self_test_bare_forbidden_token_fails: true` | R50 proof summary field | ✓ |
| `scanner_self_test_qualified_source_validation_allowed: true` | R50 proof summary field | ✓ |
| `S3-R50-C3-X pressure: proceed` | C3-X route verdict | ✓ |
| `S3-R51-C1-A: approved-remaining-cli-blockers-formally-closed` | R51-C1-A status field | ✓ |
| `S3-R51-C2-X pressure: proceed` | R51-C2-X route verdict | ✓ |

No metric is inflated. No outcome is claimed beyond what the cited sources report.

### Check 3 — "Accepted source input shape" matches R50 implementation

**Result: PASS.**

The gate lists five CLI-owned preflight checks:

```text
path exists
path is a regular file
file is readable
file contains valid JSON
top-level JSON value is an object
```

These map exactly to the five checks in `cli.rb` `load_profile_source`:
- `path.exist?` → path exists ✓
- `path.file?` → regular file ✓
- `Errno::EACCES` rescue → readable ✓
- `JSON::ParserError` rescue → valid JSON ✓
- `parsed.is_a?(Hash)` → top-level object ✓

The gate's behavior description ("The CLI does not validate, finalize, normalize,
discover, infer, or default compiler profile sources") matches the implementation.
The boundary between CLI-owned preflight and assembler-owned semantic validation
is correctly stated. ✓

### Check 4 — Success and refusal behaviors match R50 proof evidence

**Result: PASS.**

| Described behavior | Proof case | Match |
|---|---|---|
| No-flag: exit 0, igapp emitted, manifest omits compiler_profile_id | B4.legacy_no_flag PASS | ✓ |
| Valid flag: igapp emitted, manifest contains compiler_profile_id | valid_profile_source_success PASS | ✓ |
| CLI preflight refusal: exit 1, stdout empty, one stderr line, no artifacts | B3.* (7 cases) PASS | ✓ |
| Semantic refusal: exit 1, stdout compiler_result_json, report exists, no igapp | B5.* (3 cases) PASS | ✓ |

No behavior is described that was not proven by the R50 proof matrix. ✓

### Check 5 — Docs condition is specific and actionable without opening implementation scope

**Result: PASS, with one note (NB-1 below).**

The docs condition lists eight named content requirements:

1. CLI flag shape `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`
2. `PATH.json` as already-finalized `compiler_profile_id_source`
3. No-flag legacy behavior
4. Preflight refusal behavior
5. Semantic refusal behavior
6. Transport-only semantics
7. No discovery/defaulting/finalization
8. All excluded surfaces that remain closed

The condition targets specific files (`docs/ruby-api.md` or a linked doc) and
the exact outdated statement to remove or qualify. A docs card can execute this
without ambiguity.

Crucially: "No code changes are required by this condition unless a future
pressure review finds a documentation/behavior mismatch." The docs sync is
docs-only by default. Any code change requires a separate Architect decision. ✓

The gate does not allow the docs sync to self-complete the condition: "a
pressure review or status-curation card may mark the R52 condition satisfied
if no mismatch is found." The condition is externally verified before being
considered closed. ✓

### Check 6 — No runtime, production, or Gate 3 authority granted

**Result: PASS.**

The non-authorization section is complete and includes the explicit clause:

> "This decision approves package-surface release-readiness only after the docs
> condition is met. It does not grant runtime, production, ledger, or Gate 3
> authority."

The full prohibited-surfaces list is preserved from R51. ✓

---

[Agree]

1. **The conditional structure is correct.** Separating "code/proof sufficient"
   from "fully release-ready" on a docs-sync condition is the right governance
   shape. The status field encodes the conditionality mechanically, not just in
   prose.

2. **The docs condition is the right size.** It requires removing one outdated
   blanket prohibition and adding specific CLI surface documentation. It does
   not require a new gate, a new proof, or code changes — unless verification
   finds a mismatch. This keeps the docs sync card appropriately bounded.

3. **The condition verification path is correct.** Allowing a status-curation
   card (not just a pressure review) to verify the docs sync is appropriate for
   a docs-only condition. The verification still requires an external card —
   the docs author cannot self-certify. ✓

4. **"Transport-only" is correctly extended to the CLI.** The gate describes
   the CLI as transport-only in the same sense as the Ruby facade: it reads
   a file and passes the parsed object unchanged, without validation,
   normalization, or discovery. The CLI-to-facade-to-orchestrator chain is
   transport-only end-to-end. Using the established term is consistent. ✓

5. **R50 NB-1 acceptance at the release level is correct.** Accepting the
   flag-as-path edge case as documented release behavior, with a "should
   document" note rather than a blocking condition, is the appropriate
   disposition for a standard Unix CLI edge case with no authority
   implications. ✓

6. **The evidence chain is complete for a release-readiness decision.** The
   gate cites the full closure and pressure trail: R50 proof → R50 pressure →
   R51 closure gate → R51 closure pressure → R52 release-readiness. No step
   in the chain is missing or uncited. ✓

---

[Challenge]

None that rise to blocking level.

---

[Missing]

Nothing required before accepting the conditional release-readiness.

---

[NB-1 — Non-blocking: "release-readiness" term should be contextually bounded
for future readers]

The gate uses "release-readiness" without defining what "release" means
operationally. A future reader could reasonably read it as:
(a) "feature is done, can be included in a gem cut"; or
(b) "ready for production deployment"; or
(c) "docs are current and the gate chain is complete."

The gate does say "It does not grant runtime, production, ledger, or Gate 3
authority" — which rules out (b). But the term is not defined positively.

The compact summary is the clearest framing: "conditionally approves
release-readiness for the already-landed bounded PROP-036 CLI transport." Read
against the non-authorization section, this means (c): the governance chain is
complete, docs are current, the feature can be treated as done within the
bounded scope. Production deployment and runtime authority require separate
decisions.

This is not a gap in the gate's authority — the explicit prohibitions are
sufficient. The NB is orientation guidance for future round openings: if R53
opens with "is this release-ready?", the answer is "yes, after docs sync, for
the bounded transport only; production authority is a separate question."

---

[Sharper Question]

With release-readiness conditionally approved pending docs sync, the docs
card has a narrow scope but a precise content bar. The sharper question for
R53 is: should the docs sync be a dedicated card (C1-D or similar) or
bundled into the status curation? Given that the docs condition has eight
named content items and one statement to remove/qualify, a dedicated docs
card reduces the risk of the status curator marking the condition satisfied
without verifying all eight items.

---

[Route]

**Verdict: proceed.**

No blockers. All six scope checks pass. The conditional release-readiness gate
is correctly structured: evidence accurate, implementation description matches
code, docs condition specific and actionable, no new implementation or
production authority granted, condition verification externally gated.

NB-1 is terminology orientation only and does not affect the gate's validity.

**For R53:**
- Recommended shape: dedicated docs card (not bundled into curation) to
  update `docs/ruby-api.md` (or create/link a CLI doc) covering all eight
  named content items from C1-A.
- After docs land, a pressure or curation card verifies the R52 condition is
  satisfied per the eight content requirements.
- After condition satisfied: R52 is complete; PROP-036 CLI bounded transport
  is fully release-ready within its stated scope.
- Production deployment authority remains a separate, future question.

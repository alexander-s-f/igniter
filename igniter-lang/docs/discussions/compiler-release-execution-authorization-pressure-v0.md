# Compiler Release Execution Authorization Pressure v0

Card: S3-R170-C3-X
Agent: [Release Execution Pressure Reviewer]
Role: review-agent
Track: compiler-release-execution-authorization-pressure-v0
Route: UPDATE
Depends on: S3-R170-C1-P1, S3-R170-C2-P1
Date: 2026-05-24

---

## Question

Are the S3-R170-C1-P1 release target/versioning options packet and the
S3-R170-C2-P1 evidence hygiene policy packet together sufficient for Portfolio
to decide the next release-execution authorization boundary — with no execution
performed, no public claims opened, version/tagging explicitly held or decided,
no installed-gem overclaim, docs/non-claims requirements target-type conditioned,
package/install criteria concrete if needed, hash verification and command
traceability handled, branch/conditional excluded, Spark absent, and Ruby
non-blocking?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-execution-options-v0.md`
  (S3-R170-C1-P1)
- `igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
  (S3-R170-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-readiness-package-acceptance-decision-v0.md`
  (S3-R169-C4-A)
- `igniter-lang/docs/tracks/stage3-round169-status-curation-v0.md`
  (S3-R169-C5-S)

---

## Check Review

### CHK-1: No release execution happened

**Result: PASS.**

C1-P1 compact handoff records:

```text
release_execution_authorized: no
tag_push_publish_authorized: no
version_edit_authorized: no
```

The closed-surfaces section explicitly lists: release execution, version file
edits, git tag creation, git push, gem build as release execution, gem publish,
signing, deployment.

C2-P1 compact policy confirms:

```text
release execution — closed surfaces
```

Both packets are analysis and policy cards only. No execution command, artifact
mutation, tag, push, or publish is described as having occurred. No execution is
implied by any wording.

---

### CHK-2: No public release/demo claims were opened

**Result: PASS.**

C1-P1 closed surfaces: "public release or demo claims."

C2-P1 Section 5 defines a guardrail list of claims that are "not allowed without
separate public-claims authorization review":

- "Igniter-Lang is available on RubyGems"
- "Production ready"
- "Supports all Igniter-Lang grammar"
- "Supports if-else / branch / conditional"
- "Compatible with [Ruby Framework version]"
- "First public release" without Tier 3 docs
- Any demo script as "try it live" or "getting started"

Neither packet opens, implies, or slides toward any of these claims. The
wording tiers (Tier 1–4) in C2-P1 make public claims contingent on separate
authorization. ✓

---

### CHK-3: Version/tagging decision is explicit or explicitly held

**Result: PASS.**

C1-P1 reads the current version directly from the source:

```text
IgniterLang::VERSION = "0.1.0.pre.stage2"
```

It explicitly names the open question:

> "Should first public/compiler RC use the existing 0.1.0.pre.stage2 package
> version, a Stage 3 prerelease version, or a new RC-specific version?"

It explicitly defers the answer:

> "Do not answer this inside execution. It must be answered before execution."

Each of the five options carries a version/tagging stance:
- Option A: no version change, no tag
- Option B: no version change by default for smoke, no tag
- Option C: tag policy must be decided before execution; avoids semver release tag
- Option D: explicit version policy required before any version edit, tag, publish
- Option E: no version/tag decision (no-op)

C2-P1 EH-7 blocker requires the authorization document to state the version string
and tagging strategy before execution begins. ✓

The version/tagging question is explicitly held for the authorization review to
resolve, not silently deferred. See NB-3 for a wording recommendation.

---

### CHK-4: Installed-gem readiness is not overclaimed

**Result: PASS.**

C1-P1 answers directly:

> "Is installed-gem readiness currently established? No, not for the accepted
> official first-RC release scope."

It carefully distinguishes:

> "There is historical local package/install evidence and release-gate evidence
> for igniter_lang-0.1.0.pre.stage2, but the official first-RC evidence accepted
> in R168 is repo_local_compiler_rc only. Installed-gem readiness must be
> re-established if the release target includes installability or public gem
> claims."

Option D (public gem release) is labeled "premature" with "Risk: High."

C2-P1 Section 4 confirms: "If the release target is repo_local_compiler_rc
(no public gem, no installed artifact distribution), the package/install matrix
is not required and is explicitly deferred."

No overclaim on installability appears in either packet. ✓

---

### CHK-5: Docs/non-claims requirements match release target type

**Result: PASS.**

C2-P1 Section 3 defines a four-tier policy that directly addresses R169-C3-X
NB-2:

| Tier | Target | Requirement |
| --- | --- | --- |
| 1 | Repo-local artifact only | Machine-readable non-claims sufficient; no prose release note required |
| 2 | Private/internal git tag | Machine-readable sufficient; tag annotation recommended |
| 3 | Public RubyGems publish | Prose CHANGELOG/RELEASE_NOTES required before execution |
| 4 | Public demo/announcement | All Tier 3 + Portfolio public-claims authorization review |

The Tier 1 explicit answer is:

> "Yes. Machine-readable non-claims in the official evidence packet are
> sufficient for a repo_local_compiler_rc target (Tier 1 or Tier 2). Prose
> release notes are not required for a repo-local artifact."

This resolves the undifferentiated docs/non-claims blocker from R169-C1-D and
matches the pressure observation from R169-C3-X. EH-3 requires the authorization
review to state which tier applies and confirm the appropriate docs standard. ✓

See NB-2 for a minor template consistency note.

---

### CHK-6: Package/install criteria are concrete if package target is proposed

**Result: PASS.**

C2-P1 Section 4 provides PKG-1 through PKG-5 with:

- specific command form for each step;
- named pass conditions per step;
- 5 hold conditions (with named triggers);
- 5 fail conditions (with named triggers);
- 4 non-blocking items;
- accepted JSON result format for the matrix output.

The PASS threshold is explicitly: "All 5 checks must pass. A single failure
triggers matrix FAIL."

The scope condition is explicit: if target is repo-local only, the matrix is
"not required and is explicitly deferred." If the target expands to any
installed-gem claim, the matrix becomes a gate condition.

This directly resolves R169-C3-X NB-3. ✓

See NB-1 for a discrepancy in the PKG-4/PKG-5 executable name.

---

### CHK-7: Independent hash verification and command traceability are handled

**Result: PASS.**

**Hash verification (R168-NB-1):** C2-P1 Section 1 defines three options (A, B, C)
and a policy by release target type:

| Target | Required policy |
| --- | --- |
| `repo_local_compiler_rc` | Option B — explicit deferral with rationale in authorization document |
| Private/internal git tag | Option B or C |
| Public RubyGems publish | Option A — independent hash verification command required |
| Public demo/announcement | Option A required |

Option B provides the exact required deferral wording. Option A provides the
exact hash-check command form. EH-1 requires the authorization review to state
explicitly which option applies. Silent deferral is not acceptable. ✓

**Command traceability (R168-NB-2):** C2-P1 Section 2 adopts Option A (normative
statement) with an explicit text that must appear in the authorization review:

> "For the repo_local_compiler_rc release target, the evidence packet
> command_matrix is normative for evidence-gathering commands only (3 entries).
> The source harness internal command matrix (14 entries) is captured by
> delegation: source_harness.command_matrix_entries: 14,
> source_harness.command_matrix_pass_count: 14, and the harness summary SHA256."

EH-2 requires this statement to appear in the authorization document. ✓

Both NB issues from R168 are closed with concrete policies and required
authorization-review dispositions.

---

### CHK-8: Branch/conditional remains excluded

**Result: PASS.**

C1-P1 closed surfaces: "branch/conditional implementation" not authorized.

C2-P1 Section 5 public wording guardrails explicitly lists as NOT allowed:

```text
"Supports if-else / branch / conditional"
```

The Tier 3 wording template in C2-P1 Section 5 carries the required exclusion:

```text
Excluded from this RC:
- branch/conditional if_expr (post-RC language/compiler design lane)
```

Neither packet opens, implies, or softens the branch/conditional exclusion.
The S3-R164-C4-A exclusion basis is preserved. ✓

---

### CHK-9: Spark is absent

**Result: PASS.**

C1-P1 closed surfaces: "Spark access, fixtures, specs, integration, or
production pressure."

C2-P1 closed surfaces: "Spark access, fixtures, specs, integration, or
production authority."

Neither packet mentions Spark in a positive, authorizing, or evidence-using
context. The R169-C5-S status curation confirms "Spark is intentionally out of
R169 and remains non-authorizing." ✓

---

### CHK-10: Ruby is non-blocking

**Result: PASS.**

C1-P1 does not reference Ruby Framework in any blocking context. Its reads of
`igniter_lang.gemspec` and `version.rb` are about the Lang compiler package, not
the Ruby Framework gem.

C2-P1 closed surfaces: "Ruby Framework docs/release/tag/package/compatibility
claims." The Tier 3 wording template in Section 5 reads "Not a published gem.
Repo-local evidence only." — this does not reference Ruby Framework status.

The R169-C4-A acceptance decision confirms "Ruby Ledger hardening may proceed
independently" and "remains non-blocking for Lang release-readiness." ✓

---

## Non-Blocking Notes

### NB-1: PKG-4/PKG-5 commands use `igniter-lang compile` but the gem executable is `igc`

C1-P1 establishes two facts:

```text
Gem executable: igc
Repo compatibility executable: bin/igniter-lang exists but is not listed as
  gem executable
```

C1-P1 Option B's required matrix also uses "installed igc positive compile" and
"installed igc refusal case" — correctly referencing `igc`.

However, C2-P1 Section 4 defines:

```text
PKG-4 CLI positive | `igniter-lang compile [positive_corpus_source]`
PKG-5 CLI refusal  | `igniter-lang compile [negative_corpus_source]`
```

`igniter-lang compile` would fail in an isolated gem installation that includes
only `igc` as the executable. `bin/igniter-lang` is a repo-relative path, not
installed by the gem.

The authorization review must resolve this discrepancy: PKG-4 and PKG-5 commands
should use `igc compile [source]`, not `igniter-lang compile [source]`, when the
test target is an isolated gem installation. C1-P1's Option B wording is correct;
C2-P1's PKG-4/PKG-5 form needs alignment.

Required fix for the authorization review: confirm that the canonical
package/install smoke uses `igc` (not `igniter-lang`) as the installed
executable.

### NB-2: The Tier 3 wording templates in C2-P1 Sections 3 and 5 differ

C2-P1 Section 3 "Approved public wording":

```text
Igniter-Lang [version] RC — first release candidate.

Supports: contract definition, compute nodes, temporal History[T] reads,
OOF fragment classification, profile source loading. Repo-local compiler
CLI and API surfaces proven.

Does not support: branch/conditional if_expr (post-RC language/compiler
design lane), production runtime, installed-gem distribution,
BiHistory, stream/OLAP executors, or Spark integration.

Evidence: official_first_rc_evidence PASS (S3-R167-C1-A).
```

C2-P1 Section 5 "Allowed Tier 3 template":

```text
Igniter-Lang [version] RC — first release candidate.

Compiler surfaces proven:
- positive compile: contract, compute, temporal History[T] reads,
  OOF fragment classification, profile source loading
- refusal: negative corpus refusal with named error

Excluded from this RC:
- branch/conditional if_expr (post-RC language/compiler design lane)
- production runtime, Spark integration, installed-gem distribution,
  BiHistory, stream/OLAP executors

Evidence: official_first_rc_evidence PASS (S3-R167-C1-A).
Not a published gem. Repo-local evidence only.
```

Section 5 is more complete: it adds the refusal coverage claim and the "Not a
published gem. Repo-local evidence only." closing statement. Section 3's shorter
version omits these and could be used to imply installability (missing the
"Not a published gem" line).

The authorization review should treat Section 5 as the canonical Tier 3 template.
If Tier 3 wording is needed, Section 5 must be used, not Section 3.

### NB-3: EH-7 should require an explicit null-version-change statement for Option A

C2-P1 EH-7 states: "State the version string and tagging strategy before
execution begins." For Option A (repo-local marker), the correct answer is a
null-change decision:

```text
No version file change is authorized for this target.
The current version IgniterLang::VERSION = "0.1.0.pre.stage2" remains unchanged.
No git tag is created.
```

The risk of a silent EH-7 disposition for Option A is that a future agent
reading the authorization document could infer "Option A was chosen" without
finding an explicit version statement, and might apply a version change later
based on unrelated context.

The authorization review should explicitly state the null-version-change decision
even when Option A is chosen, rather than omitting the version field because
"nothing changed."

---

## Verdict

**proceed — both preparation packets are sufficient for the release-execution
authorization review; no blockers.**

All 10 check items PASS:

| Check | Result |
| --- | --- |
| CHK-1: no release execution happened | PASS |
| CHK-2: no public release/demo claims opened | PASS |
| CHK-3: version/tagging explicit or held | PASS |
| CHK-4: installed-gem readiness not overclaimed | PASS |
| CHK-5: docs/non-claims match release target type | PASS |
| CHK-6: package/install criteria concrete if needed | PASS |
| CHK-7: hash verification and command traceability handled | PASS |
| CHK-8: branch/conditional remains excluded | PASS |
| CHK-9: Spark absent | PASS |
| CHK-10: Ruby non-blocking | PASS |

The combined packets provide Portfolio with:

- a concrete options table (A–E) with version/tagging stance, action class,
  required proof matrix, and user-approval boundary for each option;
- a four-tier docs/non-claims policy keyed to release target type;
- specific PKG-1..PKG-5 package/install smoke criteria with PASS/HOLD/FAIL
  definitions if an installed-gem target opens;
- explicit hash verification policy options (A/B/C) with target-type mapping;
- an adopted command traceability interpretation with required authorization-document
  wording;
- a seven-item EH blocker checklist (EH-1..EH-7) that must all be addressed in
  the authorization document;
- public wording guardrails with a canonical Tier 3 template.

Three non-blocking notes for C4-A:

- **NB-1** (most important): PKG-4/PKG-5 in C2-P1 use `igniter-lang compile`
  but the gem executable is `igc`; the authorization review must adopt `igc compile`
  for the installed-gem package smoke matrix;
- **NB-2**: Section 3 and Section 5 Tier 3 templates differ; Section 5 is canonical
  and must be used if Tier 3 wording is needed;
- **NB-3**: EH-7 must require an explicit null-version-change statement for
  Option A, not just implicit omission.

---

## Acceptance Recommendation for C4-A

**Accept both preparation packets. Open the release-execution authorization
review.**

The authorization review (`compiler-release-execution-authorization-review-v0`)
must:

1. Address EH-1 through EH-7 from C2-P1 explicitly — no silent dispositions;
2. Choose one of the five C1-P1 options (A–E) and state it explicitly;
3. Fix NB-1: adopt `igc compile` (not `igniter-lang compile`) for PKG-4/PKG-5;
4. Fix NB-2: use Section 5 template if any Tier 3 wording is required;
5. Fix NB-3: for Option A, state the null-version-change decision explicitly.

Do not authorize:

- release execution in the authorization review card itself;
- public release or demo claims;
- branch/conditional implementation;
- any compiler/library/parser/TypeChecker/SemanticIR/assembler changes;
- installed-gem readiness claim (not established by current evidence);
- any widening of closed surfaces from S3-R167-C1-A, S3-R168-C4-A, or
  S3-R169-C4-A.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
release execution
public release or demo claims
version file edits
git tag creation
git push
gem build as release execution
gem publish
signing or deployment
public API/CLI widening
branch/conditional implementation
parser, classifier, TypeChecker, SemanticIR, assembler changes
compiler/library behavior changes
loader/report, CompilationReport, CompilerResult, CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work
```

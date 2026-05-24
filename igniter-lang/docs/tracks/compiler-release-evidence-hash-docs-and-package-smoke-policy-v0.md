# Compiler Release Evidence Hygiene Policy v0

Card: S3-R170-C2-P1
Agent: [Release Evidence Hygiene Agent]
Role: release-readiness-agent
Track: compiler-release-evidence-hash-docs-and-package-smoke-policy-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R169-C4-A (package acceptance decision)
- S3-R169-C1-D (release-readiness summary package)
- S3-R169-C3-X (summary package pressure review)
- S3-R168-C3-X (official first-RC evidence pressure review)

---

## Purpose

Prepare the evidence hygiene policy packet for the release-execution
authorization review. Defines formal policies for: independent hash
verification, command traceability, docs/non-claims by release target type,
package/install smoke acceptance criteria, and public wording guardrails.

This card does not authorize release execution. It does not make public claims.
It does not edit release docs. It produces analysis and policy only.

---

## Inputs Read

| Input | Key findings |
| --- | --- |
| `compiler-release-readiness-package-acceptance-decision-v0.md` (S3-R169-C4-A) | Accepted `repo_local_compiler_rc`; opened release-execution authorization review; carries NB-1..NB-3; public claims closed |
| `compiler-release-readiness-summary-package-v0.md` (S3-R169-C1-D) | 11-item blocker checklist; installed-gem = `not_established`; docs/non-claims blocker is undifferentiated by target type |
| `compiler-release-readiness-summary-package-pressure-v0.md` (S3-R169-C3-X) | 7/7 CHK PASS; NB-1 (versioning/tagging), NB-2 (docs target-type conditioning), NB-3 (package/install criteria absent) |
| `compiler-release-official-first-rc-evidence-pressure-v0.md` (S3-R168-C3-X) | 10/10 CHK PASS; NB-1 (SHA256 self-attested), NB-2 (14 harness commands by reference), NB-3 (self-referential proof artifact path) |
| `official_first_rc_evidence_summary.json` | Status: PASS; scope: `repo_local_compiler_rc`; 3 commands; 14/14 harness; SHA256: `bc8d69f...`; 8 machine-readable non-claims; no failed/hold |

---

## Section 1 — Independent Hash Verification

### Current state

The source harness SHA256 is self-attested in the evidence packet at two
locations:

```json
"source_harness.summary_sha256": "sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"
"proof_artifacts.harness_summary_sha256": "sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"
```

The evidence command matrix has 3 entries. Command 3 (shape verification)
confirms "13 fields present" but does not recompute or verify the SHA256.
No independent hash-check command appears in the matrix. R168-NB-1 flagged
this as a non-blocking note requiring resolution before release execution.

### Policy options

**Option A — Add independent hash verification to the evidence command matrix.**

A 4th command added to `command_matrix`:

```bash
ruby -e 'require "digest"; \
  expected = "sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"; \
  path = "igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json"; \
  actual = "sha256:" + Digest::SHA256.hexdigest(File.read(path)); \
  abort "hash mismatch: #{actual}" unless actual == expected; \
  puts "hash OK #{actual}"'
```

This makes verification independently reproducible. Any agent with repo access
can run this command and confirm the harness output has not changed since
evidence was gathered. The evidence packet becomes fully self-verifiable.

**Option B — Explicitly defer with rationale in the authorization decision.**

The authorization review records: "Independent hash verification is deferred for
the `repo_local_compiler_rc` release target. Rationale: the harness output is
in-repo; any audit can recompute `sha256sum` of the harness summary file against
the recorded value. The evidence packet records the hash in two locations for
redundancy. This deferral applies only to this target; a public-facing release
target requires Option A before execution."

**Option C — Require hash verification at release execution time.**

The release-execution implementer runs an independent check before beginning
execution steps. The hash check appears in the execution checklist, not in the
evidence packet. This is weaker than Option A (not part of the machine-readable
evidence record) but stronger than pure deferral.

### Recommended policy

| Release target | Hash verification policy |
| --- | --- |
| `repo_local_compiler_rc` (local artifact only) | **Option B** — explicitly defer with rationale in authorization document |
| Private/internal git tag (no RubyGems publish) | **Option B or C** — deferral with rationale, or hash check at execution |
| Public RubyGems publish | **Option A required** — independent hash verification command in evidence matrix before publication |
| Public demo / announcement | **Option A required** — evidence must be independently verifiable before any public claim |

For the current target (`repo_local_compiler_rc`), Option B is the minimum
required disposition. The authorization review must record the deferral
explicitly; silent deferral (no mention of NB-1) is not acceptable.

---

## Section 2 — Command Traceability

### Current state

The evidence packet `command_matrix` contains 3 entries (the evidence-gathering
commands). The source harness has a separate internal `command_matrix` with 14
entries. The 14/14 pass result is captured in the evidence packet by:

- `source_harness.command_matrix_entries: 14`
- `source_harness.command_matrix_pass_count: 14`
- Command 2 stdout: `command_matrix_entries=14` `failed_checks=0`
- `source_harness.summary_sha256` (links to the harness summary that enumerates
  the 14 entries)

R168-NB-2 flagged the ambiguity: the authorization review's Required Command
Matrix said "pass/fail status for every command matrix entry," which could be
read as requiring all 14 to be enumerated in the evidence packet.

### Policy options

**Option A — 3-command evidence packet is normative; harness commands captured by delegation.**

The evidence packet's `command_matrix` covers evidence-gathering commands only.
The harness internal 14 commands are delegated to the harness track doc and its
summary file (referenced by SHA256). This is the current interpretation.

**Option B — Enumerate all 14 harness commands in the evidence packet.**

The evidence packet's `command_matrix` array grows to 17 entries (3 evidence +
14 harness). Full per-entry pass/fail traceability lives in the packet. The
harness summary SHA256 becomes redundant for command-level traceability but is
kept for binary-level verification.

**Option C — Add a `harness_command_matrix` sub-block to `source_harness`.**

The `source_harness` block gains a `command_matrix_entries` array with all 14
harness command entries. The top-level `command_matrix` remains 3 entries.
This cleanly separates evidence-gathering commands from harness-internal
commands, and the harness SHA256 remains the binding between them.

### Recommended policy

**Adopt Option A for this target with an explicit normative statement.**

The authorization review must include:

> "For the `repo_local_compiler_rc` release target, the evidence packet
> `command_matrix` is normative for evidence-gathering commands only (3 entries).
> The source harness internal command matrix (14 entries) is captured by
> delegation: `source_harness.command_matrix_entries: 14`,
> `source_harness.command_matrix_pass_count: 14`, and the harness summary
> SHA256 `sha256:bc8d69f...`. This interpretation is adopted for this release
> target."

Future evidence rounds that require full per-command enumeration should adopt
Option C (harness sub-block), not Option B (flat array), to keep the top-level
`command_matrix` semantically consistent.

---

## Section 3 — Docs/Non-Claims by Release Target Type

### Current state

The official evidence packet contains 8 machine-readable non-claims. The
R169-C1-D blocker checklist item "Docs/non-claims" is listed as a universal
gate regardless of release target type. R169-C3-X NB-2 flagged this as
requiring target-type conditioning.

### Policy: docs/non-claims requirement by target type

**Tier 1 — Repo-local artifact only (no tag, no publish, no public claims)**

Machine-readable non-claims in the official evidence packet are sufficient.
No prose release note is required.
No user-facing docs page is required.
The authorization document itself constitutes the non-claims record for
this release target.

Required: authorization document must cite the evidence packet non-claims
and confirm they are the complete non-claims record for this target.

**Tier 2 — Private/internal git tag (no RubyGems publish, no public announcement)**

Machine-readable non-claims are sufficient.
A tag annotation message is recommended: cite evidence authorization
(`S3-R167-C1-A`) and scope (`repo_local_compiler_rc`).
No standalone prose release note is required.
Branch/conditional exclusion note in tag annotation is recommended.

**Tier 3 — Public RubyGems gem publish**

A prose `CHANGELOG.md` or `RELEASE_NOTES.md` entry is required before
execution. Must include:
- RC scope statement (repo_local_compiler_rc)
- Supported grammar surfaces (5 listed)
- Excluded feature: branch/conditional `if_expr`
- Non-claim that this is not production-ready
- Reference to evidence authorization (`S3-R167-C1-A`)

Approved public wording:

```text
Igniter-Lang [version] RC — first release candidate.

Supports: contract definition, compute nodes, temporal History[T] reads,
OOF fragment classification, profile source loading. Repo-local compiler
CLI and API surfaces proven.

Does not support: branch/conditional if_expr (post-RC design lane), production
runtime, installed-gem readiness, BiHistory, stream/OLAP executors, or Spark
integration.

Evidence: official_first_rc_evidence PASS (S3-R167-C1-A).
```

**Tier 4 — Public demo, announcement, or marketing**

All Tier 3 requirements apply.
Additional requirements: demo wording review, public compatibility statement
review, explicit Portfolio authorization for each public claim.
A demo that implies production readiness or installed-gem availability is
forbidden without a separate public-claims authorization review.

### Explicit answer — machine-readable non-claims for repo-local-only target

> **Yes.** Machine-readable non-claims in the official evidence packet are
> sufficient for a `repo_local_compiler_rc` target (Tier 1 or Tier 2). Prose
> release notes are not required for a repo-local artifact. Prose release notes
> become mandatory when the target includes a public RubyGems publish or any
> public-facing announcement or demo (Tier 3 or Tier 4).

---

## Section 4 — Package/Install Smoke Policy

### Current state

Installed gem readiness is `not_established`. The R169-C1-D package lists 5
required package/install commands but provides no pass/fail/hold criteria.
R169-C3-X NB-3 requires these criteria to be defined if an installed-gem
release target opens.

### Minimum criteria if an installed-gem release target is authorized

**Pass criteria (ALL must be met for matrix PASS)**

| Step | Command form | Pass condition |
| --- | --- | --- |
| PKG-1 Build | `gem build igniter_lang.gemspec` | Exits 0; `.gem` artifact produced in working directory |
| PKG-2 Install | `gem install --local igniter_lang-*.gem` | Exits 0; gem appears in `gem list` |
| PKG-3 Require | `ruby -e 'require "igniter_lang"; puts "load OK"'` (no `-I .`) | Exits 0; output includes `load OK` |
| PKG-4 CLI positive | `igniter-lang compile [positive_corpus_source]` | Exits 0; produces `.igapp` artifact or compilation success signal |
| PKG-5 CLI refusal | `igniter-lang compile [negative_corpus_source]` | Exits non-zero; produces named refusal, not crash |

All 5 checks must pass. A single failure triggers matrix FAIL.

**Hold criteria (any triggers HOLD; fix required before pass/fail adjudicated)**

| Condition | Hold trigger |
| --- | --- |
| Build exits 0 but `.gem` artifact is absent | Missing artifact — environment issue |
| Install exits 0 but `gem list` does not show gem | Installation did not register — gem path issue |
| `require "igniter_lang"` raises `LoadError` after successful install | Load path issue — not a corpus failure |
| CLI executable `igniter-lang` not found after install | PATH issue, not a compiler failure |
| Any PKG step exits with Ruby interpreter crash (SIGKILL, OOM) | Infrastructure issue |

**Fail criteria (any triggers FAIL; blocks matrix PASS)**

| Condition | Fail trigger |
| --- | --- |
| `gem build` exits non-zero | Build failure |
| `gem install` exits non-zero | Installation failure |
| PKG-3 `require` exits non-zero for non-LoadError reason | Gem-level initialization error |
| PKG-4 positive corpus source fails to compile | Regression — installed gem does not match harness evidence |
| PKG-5 negative corpus source exits 0 (no refusal) | Regression — installed gem silent on known-bad source |

**Non-blocking (carry as NB, do not trigger HOLD or FAIL)**

- Installed executable version string differs from gemspec minor version
- RubyGems metadata fields (homepage, description, summary) incomplete
- No `.igapp/` artifact persistence test against installed gem path
- Gem binary installed to a non-standard `bin/` path requiring manual PATH adjustment

**Accepted matrix result format (analogous to harness summary)**

```json
{
  "kind": "package_install_smoke_matrix",
  "status": "PASS|HOLD|FAIL",
  "checks": [
    {"step": "PKG-1", "cmd": "...", "pass": true, "exit_status": 0},
    ...
  ],
  "failed_checks": [],
  "hold_reasons": [],
  "non_claims": [
    "no_rubygems_publish: local install only",
    "no_public_availability_claim"
  ]
}
```

### Scope condition

If the release target is `repo_local_compiler_rc` (no public gem, no installed
artifact distribution), the package/install matrix is **not required** and is
explicitly deferred. This must be stated in the authorization document.

If the target expands to any installed-gem claim (local or published), the
matrix above becomes a gate condition and must be accepted before execution.

---

## Section 5 — Public Wording Guardrails

### Currently allowed (machine-readable / internal contexts)

- Internal evidence references to `official_first_rc_evidence` with authorization `S3-R167-C1-A`
- Scope label `repo_local_compiler_rc`
- Evidence status `PASS`
- SHA256 `sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b`
- Non-claim enumeration from the evidence packet (all 8 non-claims)
- Branch/conditional exclusion wording (verbatim from S3-R164-C4-A)

### Not allowed without separate public-claims authorization review

- "Igniter-Lang is available on RubyGems" / "gem install igniter_lang"
- "Production ready" / "production compiler"
- "Supports all Igniter-Lang grammar"
- "Supports if-else / branch / conditional"
- "Compatible with [Ruby Framework version]"
- "First public release" without Tier 3 docs
- Any demo script presented as "try it live" or "getting started" without
  a public-claims authorization review

### Allowed Tier 3 template (verbatim)

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

---

## Section 6 — R168 Self-Reference Naming Note (NB-3)

### Does the self-reference block anything?

**No. NB-3 does not block anything.**

The `proof_artifacts.official_evidence_summary` field:

```json
"official_evidence_summary": "igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json"
```

Points to the file that contains this field. This is:
- Informational: correctly identifies the output file's path
- Not circular in verification: no field whose validity depends on this path
  being external
- Not a machine-readable claim: readers can ignore the self-reference without
  losing any verification capability
- Accurately labeled: the path is correct
- Not a security issue: no verification step relies on this field

**Verdict: NB-3 is cosmetic and does not block repo-local release execution.**

Recommended cosmetic fix for the next evidence round: rename this field to
`this_file_path` to make the self-referential nature explicit and avoid
confusion with externally-verifiable artifact paths.

Schedule: optional polish, no urgency before the current authorization review.

---

## Compact Evidence Hygiene Policy

```text
evidence_hygiene_policy_version: 0.1.0
authorization_basis: S3-R169-C4-A / S3-R168-C4-A / S3-R167-C1-A

HASH VERIFICATION:
  repo_local_compiler_rc: defer NB-1 with explicit rationale in auth doc
  any_public_target: Option A required (independent hash-check command in matrix)

COMMAND TRACEABILITY:
  adopted: 3-command evidence matrix + 14 harness commands by delegation
  required: auth doc must state this interpretation explicitly
  future: Option C (harness_command_matrix sub-block) for full enumeration

DOCS / NON-CLAIMS BY TARGET TYPE:
  Tier 1 (repo-local artifact): machine-readable non-claims sufficient; no prose required
  Tier 2 (private git tag): machine-readable sufficient; tag annotation recommended
  Tier 3 (public gem publish): prose CHANGELOG/RELEASE_NOTES required before execution
  Tier 4 (demo/announcement): all Tier 3 + Portfolio public-claims auth review

PACKAGE/INSTALL SMOKE (if installed-gem target opens):
  PKG-1..PKG-5 must all pass for matrix PASS
  any HOLD condition: fix before pass/fail adjudication
  any FAIL condition: blocks matrix PASS
  if target = repo_local_compiler_rc only: matrix explicitly deferred

PUBLIC WORDING:
  allowed now: internal evidence refs, scope labels, SHA256, non-claims, exclusion wording
  not allowed: RubyGems claim, production-ready, all-grammar, branch support,
    Ruby compat claim, public release, demo-live — without separate public-claims auth

NB-3 SELF-REFERENCE:
  does not block anything
  cosmetic fix for next evidence round: rename to this_file_path
```

---

## Required Blocker Checklist for Release-Execution Authorization Review

The following items must each be resolved (or explicitly deferred with rationale)
in the authorization review before any release execution is permitted:

| ID | Blocker | Required disposition |
| --- | --- | --- |
| EH-1 | Hash verification policy for accepted target | State: (A) add independent hash check command, or (B) defer with explicit rationale citing the target type |
| EH-2 | Command traceability interpretation | State: "3-command evidence matrix is normative for this round; 14 harness commands captured by delegation (count + SHA256 + stdout)" |
| EH-3 | Docs/non-claims target-type conditioning | State: which tier applies to the authorized release target; if repo-local, confirm machine-readable non-claims are sufficient |
| EH-4 | Package/install matrix gate | State: if target = repo-local only, explicitly defer package matrix; if target includes installed-gem, adopt PKG-1..PKG-5 criteria with PASS/HOLD/FAIL definitions |
| EH-5 | Public wording guardrails | State: which wording tier applies; confirm public claims remain closed if target is Tier 1 or Tier 2 |
| EH-6 | NB-3 self-reference | Confirm NB-3 does not block; schedule cosmetic fix for next evidence round or explicitly defer |
| EH-7 | Versioning/tagging decision | From R169-C3-X NB-1: state the version string and tagging strategy before execution begins |

All EH-1..EH-7 items must appear in the authorization document.
An authorization that is silent on any EH item is incomplete.

---

## Closed Surfaces

This card does not authorize:

```text
release execution
public release or demo claims
public API/CLI widening
branch/conditional implementation
any compiler/library/parser/TypeChecker/SemanticIR/assembler changes
loader/report, CompilationReport, CompilerResult, or CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production authority
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or production behavior
```

---

## Handoff

```text
Card: S3-R170-C2-P1
Track: compiler-release-evidence-hash-docs-and-package-smoke-policy-v0
Status: done

[D] Decisions / Policies

HASH (EH-1):
  - repo_local_compiler_rc → Option B (explicit deferral with rationale)
  - public-facing target → Option A (independent hash verification command required)

COMMAND TRACEABILITY (EH-2):
  - 3-command evidence packet + 14 harness by delegation is adopted
  - auth doc must state this interpretation explicitly

DOCS/NON-CLAIMS (EH-3):
  - machine-readable non-claims are sufficient for Tier 1 (repo-local) and Tier 2 (private tag)
  - prose release note required for Tier 3 (public gem) and Tier 4 (demo/announcement)
  - Tier 3 template wording provided in Section 5

PACKAGE/INSTALL (EH-4):
  - if target = repo-local only: matrix explicitly deferred (not required)
  - if installed-gem target opens: PKG-1..PKG-5 with PASS/HOLD/FAIL criteria required
  - accepted matrix result format (JSON) specified in Section 4

PUBLIC WORDING (EH-5):
  - guardrails defined; no new public claims authorized

NB-3 (EH-6):
  - does not block; cosmetic fix deferred to next evidence round

[S] Shipped
  - docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md

[Next]
  - S3-R170-C1-A (Portfolio Architect): release-execution authorization review
    must address EH-1..EH-7; this policy packet is the input
  - If target expands to installed-gem: route PKG-1..PKG-5 matrix before execution
  - NB-3 cosmetic fix: next evidence round
```

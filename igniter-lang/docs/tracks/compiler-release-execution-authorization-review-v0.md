# Compiler Release Execution Authorization Review v0

Card: S3-R170-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-execution-authorization-review-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R170-C1-P1
- S3-R170-C2-P1
- S3-R170-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-execution-options-v0.md`
- `igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
- `igniter-lang/docs/discussions/compiler-release-execution-authorization-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-package-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`

---

## Decision

Decision:

```text
authorize bounded repo-local RC marker execution next
do not authorize installed-gem/package release execution
do not authorize public release/demo claims
do not authorize version change, tag, push, gem publish, signing, or deployment
```

The next execution card may create a reversible repo-local RC marker from the
accepted official first-RC evidence. This is Option A from C1-P1.

The next card must not build a release gem as a release artifact, edit version
files, create tags, push, publish, sign, deploy, or claim public availability.

---

## Authorized Target

Authorized target:

```text
repo_local_compiler_rc_marker
```

Authorized meaning:

- record that official first-RC evidence is accepted for
  `repo_local_compiler_rc`;
- keep the marker internal/repo-local;
- preserve first-RC scope exclusions and non-claims;
- prepare the project for a later package/install smoke or public release
  authorization, without performing either now.

Not authorized:

- installed-gem readiness;
- public gem readiness;
- public demo/readme claim;
- public release note;
- version bump;
- git tag;
- `gem push`;
- release signing/deployment.

---

## Version / Tagging Stance

EH-7 disposition:

```text
No version file change is authorized.
IgniterLang::VERSION remains "0.1.0.pre.stage2".
No git tag is authorized.
No tag push is authorized.
```

This is an explicit null-version-change decision for Option A. A future
installed-gem or public release target must reopen versioning/tagging before
execution.

---

## User Approval Boundary

This decision authorizes only opening the next bounded marker-execution card.

The next card may run only when the user dispatches it. The dispatch is treated
as approval for repo-local docs/status marker writes only.

Separate explicit user approval remains required before any irreversible or
public action:

- version edit;
- git tag creation or tag push;
- gem build as a release artifact;
- gem publish;
- public release/demo claim;
- signing or deployment.

---

## Write / Command Scope For Next Card

Authorized next execution card:

```text
Card: S3-R171-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-repo-local-rc-marker-v0
Route: UPDATE
```

Allowed write scope:

```text
igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/README.md
igniter-lang/docs/cards/S3/S3.md
```

Optional write scope only if the local convention already uses it for release
markers:

```text
igniter-lang/docs/release/
```

If `igniter-lang/docs/release/` does not already exist or has no obvious local
convention, do not create it in this card.

Allowed commands:

```text
ruby -e 'require "digest"; path = "igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json"; expected = "sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"; actual = "sha256:" + Digest::SHA256.hexdigest(File.read(path)); abort "hash mismatch: #{actual}" unless actual == expected; puts "hash OK #{actual}"'
rg -n "branch_conditional_if_expr|public_claims_authorized|release_execution_authorized" igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json
```

The hash command is required for the marker card. Although C2-P1 allowed
explicit deferral for `repo_local_compiler_rc`, running the independent hash
check is cheap and removes the remaining audit wrinkle before the marker is
written.

Do not run package/install smoke in the marker card.

---

## Docs / Non-Claims Requirements

EH-3 / EH-5 disposition:

```text
Tier 1 applies: repo-local artifact/marker only.
Machine-readable non-claims in the official evidence packet are sufficient.
No public prose release note is required.
Public claims remain closed.
```

The marker track must restate these non-claims:

- no public release or demo claim;
- no installed-gem readiness claim;
- no RubyGems availability claim;
- no production runtime claim;
- no Spark integration claim;
- no Ruby Framework compatibility claim;
- no branch/conditional `if_expr` support claim;
- no version/tag/publish/sign/deploy authorization.

If any future public-facing wording is needed, C2-P1 Section 5 is the canonical
Tier 3 template. C2-P1 Section 3 is not canonical for public wording.

---

## Package / Install Criteria

EH-4 disposition:

```text
Package/install smoke is not in scope for the repo-local RC marker.
Installed-gem/package readiness remains not established.
```

If a later card opens package/install smoke, its canonical CLI checks must use
the installed gem executable:

```text
igc compile [positive_corpus_source]
igc compile [negative_corpus_source]
```

Do not use `igniter-lang compile` for installed-gem smoke unless a later
package inspection proves that executable is installed. Current C1-P1 evidence
identifies `igc` as the gem executable.

---

## Hash And Command Traceability

EH-1 disposition:

```text
Independent hash verification is required in the marker card.
```

Rationale: C2-P1 allowed explicit deferral for the repo-local target, but the
hash check is cheap and makes the marker audit-friendly.

EH-2 disposition:

```text
For the repo_local_compiler_rc marker target, the official evidence packet
command_matrix is normative for evidence-gathering commands only: 3 entries.
The source harness internal command matrix is captured by delegation:
source_harness.command_matrix_entries: 14,
source_harness.command_matrix_pass_count: 14,
and the harness summary SHA256.
```

EH-6 disposition:

```text
The self-reference field proof_artifacts.official_evidence_summary does not
block this marker. Rename to this_file_path only in a future evidence round if
a new packet is generated.
```

---

## Explicit Answers

Is release execution authorized now?

```text
Yes, but only for the bounded repo-local RC marker execution card described
above. No irreversible release action is authorized.
```

Are public release/demo claims authorized now?

```text
No. Public release/demo claims remain closed.
```

Is installed-gem/package readiness established?

```text
No. Installed-gem/package readiness remains held and requires a later
package/install smoke authorization and acceptance.
```

Does branch/conditional remain excluded?

```text
Yes. branch_conditional_if_expr remains excluded from first RC and remains a
post-RC language/compiler design lane.
```

Does Spark remain out of this round?

```text
Yes. Spark remains excluded from R170 and non-authorizing.
```

Does Ruby Ledger hardening remain independent and non-blocking?

```text
Yes. Ruby Ledger hardening remains independent under its prior bounded
authorization and does not block this Lang marker path.
```

---

## Next Dispatch Recommendation

Run the marker card next:

```text
Card: S3-R171-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-repo-local-rc-marker-v0

Route: UPDATE

Goal:
Write the repo-local compiler RC marker from the accepted official first-RC
evidence, preserving all non-claims and exclusions.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md
  - igniter-lang/docs/tracks/compiler-release-readiness-package-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md
  - igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json
  - igniter-lang/docs/tracks/stage3-round169-status-curation-v0.md
- Write only:
  - igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md
  - igniter-lang/docs/current-status.md
  - igniter-lang/docs/tracks/README.md
  - igniter-lang/docs/cards/S3/S3.md
- Optional:
  - igniter-lang/docs/release/ only if the directory already exists and has an
    obvious local convention.
- Required:
  - run independent hash verification command from S3-R170-C4-A;
  - record official evidence scope `repo_local_compiler_rc`;
  - record `branch_conditional_if_expr` as excluded;
  - record installed-gem/package readiness as not established;
  - record public claims as closed;
  - record release execution beyond marker as closed;
  - record no version change and no tag.
- Do not:
  - edit version files;
  - create tags;
  - push;
  - build or publish gems;
  - run package/install smoke;
  - make public release/demo claims;
  - edit compiler/parser/TypeChecker/SemanticIR/assembler/runtime code.

Deliver:
- Marker track doc
- Updated status/index entries
- Hash verification result
- Compact implementation summary
```

After S3-R171-C1-I closes, the next likely route is:

```text
compiler-release-package-install-smoke-authorization-review-v0
```

That route should open only if the user wants to move from repo-local marker to
installed-gem/package readiness.

---

## Closed Surfaces

This decision does not authorize:

- public release or demo claims;
- installed-gem/package readiness claim;
- version file edits;
- git tag creation;
- git push;
- gem build as release artifact;
- gem publish;
- signing;
- deployment;
- public API/CLI widening;
- branch/conditional implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- compiler/library behavior changes;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R170-C4-A
track: compiler-release-execution-authorization-review-v0
status: done
decision: authorize_bounded_repo_local_rc_marker_execution_next
release_target: repo_local_compiler_rc_marker
version_change_authorized: no
current_version_remains: 0.1.0.pre.stage2
git_tag_authorized: no
public_claims_authorized: no
installed_gem_package_readiness: not_established
package_install_smoke_authorized: no
independent_hash_check_required_for_marker: yes
command_traceability: 3 evidence commands plus 14 harness commands by delegation
branch_conditional_if_expr: excluded_from_first_rc
spark_status: excluded_from_R170
ruby_ledger_hardening: independent_non_blocking
next_route: compiler-release-repo-local-rc-marker-v0
```

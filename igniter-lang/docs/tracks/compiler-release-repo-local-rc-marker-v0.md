# Compiler Release Repo-Local RC Marker v0

Card: S3-R171-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-repo-local-rc-marker-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R170-C4-A
- S3-R170-C5-S

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-package-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/docs/tracks/stage3-round170-status-curation-v0.md`
- `igniter-lang/docs/cards/S3/S3-R171.md`

---

## Hash Verification

Required command from S3-R170-C4-A was run from the repo root
(`/Users/alex/dev/projects/igniter`):

```text
ruby -e 'require "digest"; path = "igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json"; expected = "sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"; actual = "sha256:" + Digest::SHA256.hexdigest(File.read(path)); abort "hash mismatch: #{actual}" unless actual == expected; puts "hash OK #{actual}"'
```

Result:

```text
hash OK sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
```

Independent hash verification: **PASS**

The harness summary SHA256 matches the value pinned in S3-R170-C4-A. The
official evidence packet `proof_artifacts.harness_summary_sha256` field in
`official_first_rc_evidence_summary.json` records the same value.

---

## Repo-Local Compiler RC Marker

```text
marker_target:                repo_local_compiler_rc_marker
official_evidence_scope:      repo_local_compiler_rc
evidence_status:              PASS
evidence_label:               official_first_rc_evidence
official_evidence_authorization: S3-R167-C1-A
official_evidence_acceptance: S3-R168-C4-A
marker_authorization:         S3-R170-C4-A
marker_card:                  S3-R171-C1-I
marker_date:                  2026-05-24
independent_hash_verified:    yes
hash_value:                   sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
```

### Evidence Summary

The accepted official first-RC evidence for `repo_local_compiler_rc` was
gathered under authorization S3-R167-C1-A, accepted by S3-R168-C4-A, and
packaged in:

```text
igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json
```

Key evidence facts (from the accepted package):

| Field | Value |
| --- | --- |
| kind | `official_first_rc_evidence` |
| status | `PASS` |
| authorization | `S3-R167-C1-A` |
| source harness status | `PASS` |
| command matrix | `14/14 PASS` |
| evidence command matrix | `3/3 PASS` |
| positive corpus | `5` |
| negative corpus | `3` |
| artifact checks | `5` |
| failed checks | `0` |
| hold reasons | `0` |
| closed-surface scan | `PASS` |
| excluded feature | `branch_conditional_if_expr` |

### Source Harness Traceability

```text
source_harness.track:                    compiler-release-acceptance-harness-scope-aware-update-v0
source_harness.summary_path:             igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
source_harness.summary_sha256:           sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
source_harness.command_matrix_entries:   14
source_harness.command_matrix_pass_count: 14
source_harness.existing_output_relabeled: false
```

---

## Claimed Surfaces

This marker records evidence for the following repo-local compiler surfaces only:

```text
repo_local_compiler_cli_positive_compile
repo_local_compiler_cli_refusal
repo_local_compiler_api_positive_compile
repo_local_load_path_smoke
proof_local_runtime_smoke
```

These surfaces correspond to the accepted `repo_local_compiler_rc` scope. No
other surface is claimed.

---

## Non-Claims

The following claims are explicitly NOT made by this marker:

```text
no_public_release_claim:             this marker is repo-local only; no public release is claimed
no_demo_ready_claim:                 no public demo readiness is claimed
no_installed_gem_readiness:          installed-gem/package readiness is not established; no package/install smoke was run
no_rubygems_availability:            no RubyGems publication is claimed; gem has not been pushed
no_production_runtime_claim:         no production runtime readiness is claimed
no_spark_integration_claim:          Spark is excluded from this round and from this marker
no_ruby_framework_compatibility_claim: no Ruby Framework compiler compatibility is claimed
no_branch_conditional_claim:         first RC scope explicitly excludes branch/conditional if_expr;
                                     no branch or conditional expression support is claimed;
                                     post-RC language design lane only (S3-R164-C4-A)
no_version_change:                   IgniterLang::VERSION remains 0.1.0.pre.stage2; no version file was edited
no_tag_authorized:                   no git tag is authorized or created
no_push_authorized:                  no git push is authorized
no_publish_authorized:               no gem publish is authorized
no_sign_authorized:                  no signing is authorized
no_deploy_authorized:                no deployment is authorized
no_release_execution_beyond_marker:  release execution is closed beyond this repo-local marker
```

---

## Excluded Features

```text
branch_conditional_if_expr:
  status:          out_of_scope
  exclusion_basis: S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr
  reason:          excluded from first RC scope by Portfolio decision S3-R164-C4-A;
                   post-RC language/compiler design lane; no branch/conditional if_expr
                   implementation is authorized by the first RC scope
```

---

## Release Execution Status

Release execution beyond this repo-local marker is closed.

Authorized writes for this card:

```text
igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md  ← this file
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/README.md
igniter-lang/docs/cards/S3/S3.md
```

Not created:

```text
igniter-lang/docs/release/  (directory does not exist; no local convention to follow)
```

---

## Version / Tagging Status

```text
version_change_authorized:    no
current_version_remains:      0.1.0.pre.stage2
git_tag_authorized:           no
tag_push_authorized:          no
gem_build_release_artifact:   not authorized
gem_publish:                  not authorized
signing:                      not authorized
deployment:                   not authorized
```

This is the Option A null-version-change stance from S3-R170-C4-A. Any future
installed-gem or public release target must reopen versioning and tagging before
execution.

---

## Cross-Lane Status

```text
spark_status:             excluded from this round; non-authorizing
ruby_ledger_hardening:    independent and non-blocking under prior bounded authorization
branch_conditional:       excluded from first RC; post-RC language/compiler design lane
package_install_smoke:    not authorized for the repo-local RC marker
```

---

## Closed Surfaces

This card does not authorize:

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
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

No compiler/library code was edited. No version file was edited. No tag was
created. No push was performed. No gem was built or published.

---

## Compact Implementation Summary

R171 C1-I writes the repo-local compiler RC marker authorized by S3-R170-C4-A.
The independent hash verification command was run and passed:
`sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b`.
The marker records the accepted official first-RC evidence for
`repo_local_compiler_rc` (authorization: S3-R167-C1-A; acceptance:
S3-R168-C4-A). Evidence status: PASS. All non-claims and exclusions are
preserved. Release execution beyond this marker remains closed. Version,
tag, push, publish, signing, and deployment remain unauthorized.

---

## Compact Receipt

```text
card:                           S3-R171-C1-I
track:                          compiler-release-repo-local-rc-marker-v0
status:                         done
marker_target:                  repo_local_compiler_rc_marker
official_evidence_scope:        repo_local_compiler_rc
evidence_status:                PASS
official_evidence_authorization: S3-R167-C1-A
official_evidence_acceptance:   S3-R168-C4-A
marker_authorization:           S3-R170-C4-A
independent_hash_verified:      yes
hash_value:                     sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
version_change_authorized:      no
current_version_remains:        0.1.0.pre.stage2
git_tag_authorized:             no
public_claims_authorized:       no
installed_gem_package_readiness: not_established
package_install_smoke_authorized: no
branch_conditional_if_expr:     excluded_from_first_rc
spark_status:                   excluded_from_round
ruby_ledger_hardening:          independent_non_blocking
no_code_edited:                 yes
no_version_file_edited:         yes
no_tag_created:                 yes
no_push_performed:              yes
no_gem_built_or_published:      yes
next_route:                     compiler-release-repo-local-rc-marker-pressure-v0 (S3-R171-C2-X)
```

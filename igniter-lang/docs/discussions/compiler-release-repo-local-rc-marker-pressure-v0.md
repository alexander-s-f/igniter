# Compiler Release Repo-Local RC Marker Pressure v0

Card: S3-R171-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: review-agent
Track: compiler-release-repo-local-rc-marker-pressure-v0
Route: UPDATE
Depends on: S3-R171-C1-I
Date: 2026-05-24

---

## Question

Does the S3-R171-C1-I repo-local compiler RC marker satisfy all requirements from
S3-R170-C4-A — specifically: independent hash verification run and passed, marker
target and scope correct, branch/conditional excluded, installed-gem/package
readiness not established, public claims closed, no version/tag/push/publish, no
package/install smoke, no code surfaces changed, Spark absent, Ruby non-blocking,
and release execution beyond marker explicitly closed?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md`
  (S3-R171-C1-I)
- `igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md`
  (S3-R170-C4-A)
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
  (S3-R167-C1-A evidence packet, accepted by S3-R168-C4-A)
- `igniter-lang/docs/tracks/stage3-round169-status-curation-v0.md`
  (S3-R169-C5-S)

---

## Check Review

### CHK-1: Independent hash verification was run and passed

**Result: PASS.**

The marker track explicitly records:

```text
Required command from S3-R170-C4-A was run from the repo root
```

Result:

```text
hash OK sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
```

```text
Independent hash verification: PASS
```

The compact receipt also records:

```text
independent_hash_verified: yes
hash_value: sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
```

The value matches the SHA256 pinned in S3-R170-C4-A and recorded in
`proof_artifacts.harness_summary_sha256` in the official evidence packet. The
required command is quoted verbatim from S3-R170-C4-A. ✓

---

### CHK-2: Marker target is exactly `repo_local_compiler_rc_marker`

**Result: PASS.**

The marker target block records:

```text
marker_target: repo_local_compiler_rc_marker
```

This matches S3-R170-C4-A's authorized target exactly. No broader target is
implied or claimed. ✓

---

### CHK-3: Official evidence scope is `repo_local_compiler_rc`, evidence status PASS

**Result: PASS.**

The marker records:

```text
official_evidence_scope: repo_local_compiler_rc
evidence_status:          PASS
evidence_label:           official_first_rc_evidence
official_evidence_authorization: S3-R167-C1-A
official_evidence_acceptance: S3-R168-C4-A
```

The Evidence Summary table confirms:

| Field | Value |
| --- | --- |
| kind | `official_first_rc_evidence` |
| status | `PASS` |
| authorization | `S3-R167-C1-A` |
| command matrix | `14/14 PASS` |
| evidence command matrix | `3/3 PASS` |
| failed checks | `0` |
| hold reasons | `0` |

These are consistent with the accepted evidence packet. ✓

---

### CHK-4: `branch_conditional_if_expr` is excluded with correct basis

**Result: PASS.**

The Excluded Features section records:

```text
branch_conditional_if_expr:
  status:          out_of_scope
  exclusion_basis: S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr
  reason:          excluded from first RC scope by Portfolio decision S3-R164-C4-A;
                   post-RC language/compiler design lane; no branch/conditional if_expr
                   implementation is authorized by the first RC scope
```

The compact receipt also records:

```text
branch_conditional_if_expr: excluded_from_first_rc
```

The exclusion basis correctly cites S3-R164-C4-A. Status is `out_of_scope` (not
`hold` or `deferred`), matching the definitive nature of the Portfolio exclusion
decision. The non-claims section also records `no_branch_conditional_claim`. ✓

---

### CHK-5: Installed-gem/package readiness is not established

**Result: PASS.**

The non-claims section records:

```text
no_installed_gem_readiness: installed-gem/package readiness is not established;
                             no package/install smoke was run
```

The compact receipt records:

```text
installed_gem_package_readiness: not_established
package_install_smoke_authorized: no
```

The cross-lane status section confirms:

```text
package_install_smoke: not authorized for the repo-local RC marker
```

No installed-gem readiness claim is implied anywhere in the document. ✓

---

### CHK-6: Public release/demo claims are closed with comprehensive non-claims

**Result: PASS.**

The non-claims section lists 13 explicit non-claims:

```text
no_public_release_claim
no_demo_ready_claim
no_installed_gem_readiness
no_rubygems_availability
no_production_runtime_claim
no_spark_integration_claim
no_ruby_framework_compatibility_claim
no_branch_conditional_claim
no_version_change
no_tag_authorized
no_push_authorized
no_publish_authorized
no_sign_authorized
no_deploy_authorized
no_release_execution_beyond_marker
```

This meets or exceeds the eight required non-claims from S3-R170-C4-A:

- no public release or demo claim ✓
- no installed-gem readiness claim ✓
- no RubyGems availability claim ✓
- no production runtime claim ✓
- no Spark integration claim ✓
- no Ruby Framework compatibility claim ✓
- no branch/conditional `if_expr` support claim ✓
- no version/tag/publish/sign/deploy authorization ✓

The Closed Surfaces section provides further comprehensive enumeration consistent
with the S3-R170-C4-A closed-surface list. ✓

---

### CHK-7: No version change, no git tag, no push, no publish, no signing, no deployment

**Result: PASS.**

Version / Tagging Status section records:

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

The compact receipt records:

```text
version_change_authorized:    no
current_version_remains:      0.1.0.pre.stage2
git_tag_authorized:           no
no_code_edited:               yes
no_version_file_edited:       yes
no_tag_created:               yes
no_push_performed:            yes
no_gem_built_or_published:    yes
```

The implementation summary confirms: "Version, tag, push, publish, signing, and
deployment remain unauthorized."

This is the explicit null-version-change stance (Option A from S3-R170-C4-A),
directly addressing R170-C3-X NB-3. ✓

---

### CHK-8: Package/install smoke was not run and not authorized

**Result: PASS.**

The non-claims section records:

```text
no_installed_gem_readiness: installed-gem/package readiness is not established;
                             no package/install smoke was run
```

The compact receipt records:

```text
package_install_smoke_authorized: no
```

The S3-R170-C4-A EH-4 disposition is quoted in the Release Execution Status
section: "Release execution beyond this repo-local marker is closed." The
cross-lane status confirms: "package_install_smoke: not authorized for the
repo-local RC marker." No package/install command was run or implied. ✓

---

### CHK-9: No code surfaces changed

**Result: PASS.**

The Closed Surfaces section explicitly states:

> "No compiler/library code was edited. No version file was edited. No tag was
> created. No push was performed. No gem was built or published."

The compact receipt records:

```text
no_code_edited:          yes
no_version_file_edited:  yes
no_tag_created:          yes
no_push_performed:       yes
no_gem_built_or_published: yes
```

The Authorized writes section names only documentation files:

```text
igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/README.md
igniter-lang/docs/cards/S3/S3.md
```

No compiler, parser, TypeChecker, SemanticIR, assembler, runtime, or library file
is named as changed. The Closed Surfaces enumeration explicitly closes all of these
surfaces. ✓

---

### CHK-10: Spark is absent and non-authorizing

**Result: PASS.**

The cross-lane status records:

```text
spark_status: excluded from this round; non-authorizing
```

The non-claims section records:

```text
no_spark_integration_claim: Spark is excluded from this round and from this marker
```

The Closed Surfaces section lists Spark explicitly: "Spark access, fixtures, specs,
integration, or production pressure." Spark does not appear in any authorizing or
evidence-using context. ✓

---

### CHK-11: Ruby Ledger hardening remains non-blocking

**Result: PASS.**

The cross-lane status records:

```text
ruby_ledger_hardening: independent and non-blocking under prior bounded authorization
```

The compact receipt records:

```text
ruby_ledger_hardening: independent_non_blocking
```

The Ruby Framework compatibility claim is listed in the non-claims section as
explicitly closed. This matches the S3-R169-C5-S confirmation that Ruby Ledger
hardening is non-blocking for Lang release-readiness. ✓

---

### CHK-12: EH-1 through EH-7 from S3-R170-C4-A are addressed

**Result: PASS.**

| EH | Requirement | Marker Record | Status |
| --- | --- | --- | --- |
| EH-1 | Independent hash verification required | Run and passed; `independent_hash_verified: yes` | ✓ |
| EH-2 | Command traceability: 3 evidence commands + 14 harness by delegation | Source Harness Traceability section with `command_matrix_entries: 14`, `command_matrix_pass_count: 14`, SHA256 | ✓ |
| EH-3 | Tier 1 applies: machine-readable non-claims sufficient | 13 non-claims in marker; "release execution beyond marker is closed"; Tier 1 target | ✓ |
| EH-4 | Package/install smoke not in scope | `package_install_smoke_authorized: no`; cross-lane confirms not authorized | ✓ |
| EH-5 | Public claims remain closed | 13 non-claims; Closed Surfaces enumeration; compact receipt `public_claims_authorized: no` | ✓ |
| EH-6 | EH-6 self-reference NB-3 does not block | Not reopened; EH-6 cosmetically deferred as expected | ✓ |
| EH-7 | Explicit null-version-change decision for Option A | `version_change_authorized: no`, `current_version_remains: 0.1.0.pre.stage2`, `git_tag_authorized: no` | ✓ |

All seven EH blockers from S3-R170-C4-A are addressed. ✓

---

## Non-Blocking Notes

### NB-1: The secondary `rg` confirmation command from S3-R170-C4-A is not explicitly confirmed as run

S3-R170-C4-A's allowed commands included:

```text
rg -n "branch_conditional_if_expr|public_claims_authorized|release_execution_authorized" igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json
```

The marker track does not record that this `rg` command was run or its output.
The primary hash check (the required command) was run and passed. The `rg` command
is informational — it confirms the official evidence packet contains the expected
fields — and the marker's own Evidence Summary table achieves the same informational
goal by explicitly recording the acceptance evidence values.

This is not a blocker. The C4-A authorization makes the hash check required ("The
hash command is required for the marker card") while the `rg` command is listed
under "Allowed commands" without a "required" designation. The informational
objective is met by the table in the marker track. Future marker cards may wish to
confirm both allowed commands explicitly.

---

## Verdict

**proceed — no blockers; 12/12 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: independent hash verification run and passed | PASS |
| CHK-2: marker target is `repo_local_compiler_rc_marker` | PASS |
| CHK-3: official evidence scope `repo_local_compiler_rc`, status PASS | PASS |
| CHK-4: `branch_conditional_if_expr` excluded with S3-R164-C4-A basis | PASS |
| CHK-5: installed-gem/package readiness not established | PASS |
| CHK-6: public claims closed; 13 comprehensive non-claims | PASS |
| CHK-7: no version change, no tag, no push, no publish, no sign, no deploy | PASS |
| CHK-8: package/install smoke not run and not authorized | PASS |
| CHK-9: no code surfaces changed | PASS |
| CHK-10: Spark absent and non-authorizing | PASS |
| CHK-11: Ruby Ledger hardening independent and non-blocking | PASS |
| CHK-12: EH-1..EH-7 all addressed | PASS |

The repo-local compiler RC marker (S3-R171-C1-I) satisfies all requirements from
S3-R170-C4-A. The SHA256 is independently verified. The marker is correctly
scoped, bounded, and closed. All non-claims and exclusions are preserved. Release
execution beyond the marker remains explicitly closed.

---

## Acceptance Recommendation

**Accept the repo-local compiler RC marker as written.**

The marker correctly:

- runs the required hash check and records the result;
- targets `repo_local_compiler_rc_marker` only;
- records the accepted official first-RC evidence for `repo_local_compiler_rc`;
- excludes `branch_conditional_if_expr` with the correct authorization basis;
- does not establish installed-gem/package readiness;
- closes all public release/demo claims with 13 explicit non-claims;
- records an explicit null-version-change decision (addressing R170-C3-X NB-3);
- confirms no code, version file, tag, push, gem, or signing action was taken;
- keeps Spark excluded and Ruby non-blocking;
- addresses all EH-1..EH-7 blockers from S3-R170-C4-A.

If the next route toward installed-gem/package readiness opens, the canonical
next route is:

```text
compiler-release-package-install-smoke-authorization-review-v0
```

That route must define installed-gem smoke criteria using `igc compile` (not
`igniter-lang compile`), as established by S3-R170-C4-A's NB-1 resolution.

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

---

## Compact Receipt

```text
card:                           S3-R171-C2-X
track:                          compiler-release-repo-local-rc-marker-pressure-v0
status:                         done
verdict:                        proceed
blockers:                       0
checks_passed:                  12/12
independent_hash_verified:      yes (PASS)
hash_value:                     sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b
marker_target:                  repo_local_compiler_rc_marker
official_evidence_scope:        repo_local_compiler_rc
evidence_status:                PASS
branch_conditional_if_expr:     excluded_from_first_rc
installed_gem_package_readiness: not_established
public_claims:                  closed
version_change:                 not_authorized; 0.1.0.pre.stage2 unchanged
git_tag:                        not_authorized
package_install_smoke:          not_authorized
code_surfaces_changed:          no
spark_status:                   excluded; non-authorizing
ruby_ledger_hardening:          independent_non_blocking
eh1_through_eh7:                all_addressed
nb_1_rg_command:                not_explicitly_confirmed; informational_only; not_a_blocker
next_route:                     compiler-release-package-install-smoke-authorization-review-v0 (if opened)
```

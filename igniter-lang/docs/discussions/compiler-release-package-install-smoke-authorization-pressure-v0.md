# Compiler Release Package/Install Smoke Authorization Pressure v0

Card: S3-R172-C3-X
Agent: [Package Smoke Pressure Reviewer]
Role: review-agent
Track: compiler-release-package-install-smoke-authorization-pressure-v0
Route: UPDATE
Depends on: S3-R172-C1-P1, S3-R172-C2-P1
Date: 2026-05-24

---

## Question

Are the S3-R172-C1-P1 package/install smoke boundary and S3-R172-C2-P1 package/
install smoke criteria together sufficient for Portfolio to authorize a bounded
local smoke execution card — with no smoke run yet, no public release/demo claims
opened, no version/tag/push/publish/sign/deploy actions, installed CLI confirmed
as `igc compile`, safe temp artifact policy, concrete PASS/HOLD/FAIL criteria,
sufficient corpus selection, result packet preserving non-claims, no public
release readiness mislabeling, Spark absent, and Ruby non-blocking?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-boundary-v0.md`
  (S3-R172-C1-P1)
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md`
  (S3-R172-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
  (S3-R171-C3-A)
- `igniter-lang/docs/tracks/stage3-round171-status-curation-v0.md`
  (S3-R171-C4-S)

---

## Check Review

### CHK-1: No smoke was run yet

**Result: PASS.**

C1-P1 opens with an explicit scope restriction:

> "This card does not run smoke, does not authorize implementation, does not edit
> package metadata, does not change version files, and does not open public
> release/demo claims."

C2-P1 opens with:

> "This is criteria only. It does not run package/install smoke, does not edit
> code, does not build a release artifact, and does not authorize package/install
> smoke execution."

The compact handoffs of both cards confirm status `done` as design/criteria
deliverables only. S3-R171-C4-S confirms: "Package/install smoke may open next
only as an authorization review. Smoke execution itself is not authorized by R171
C3-A." S3-R171-C3-A records: `package_install_smoke_authorized: no`.

No execution, no commands, no build, no install occurred in either preparation
packet. ✓

---

### CHK-2: No public release/demo claims opened

**Result: PASS.**

C1-P1 Closed Surfaces: "public release or demo claims" is the first item in the
explicit closed-surface list. The "Out of target" list names "public release/demo
claim" explicitly.

C2-P1 Closed Surfaces: "public release or demo claims" is explicitly closed. The
result packet shape includes `non_claims.no_public_release_claim: true` and
`no_public_demo_claim: true`. The matrix header explicitly states the PKG checks
"do not imply RubyGems publication, public availability, production readiness,
release execution beyond the smoke, or installed-gem readiness until an
Architect/Portfolio decision accepts the smoke result."

C1-P1 makes the distinction explicit: "If the smoke passes, installed-gem/package
readiness is still not a public release claim until a later acceptance decision
says so."

No public release, demo, or availability claim is opened or implied. ✓

---

### CHK-3: No version/tag/push/publish/sign/deploy opened

**Result: PASS.**

C1-P1 No-Version / No-Tag / No-Publish Stance section is explicit:

```text
- no edit to igniter-lang/lib/igniter_lang/version.rb
- no edit to igniter-lang/igniter_lang.gemspec
- no git tag
- no git push
- no gem push
- no signing
- no deployment
- no public release/demo docs
```

C1-P1 compact packet records:

```text
no_version_change: true
no_tag:            true
no_push:           true
no_publish:        true
no_signing:        true
no_deployment:     true
no_public_release_demo_claim: true
```

C2-P1 Closed Surfaces lists: "gem publish or RubyGems availability claims", "version
file edits", "git tag, push, signing, or deployment", "package metadata changes".
C2-P1 FAIL condition at matrix level: "any public/release/version/tag/publish/sign/
deploy action occurs" → FAIL.

C2-P1 result packet `non_claims` block includes:
`no_version_change: true`, `no_git_tag: true`, `no_push: true`, `no_signing: true`,
`no_deploy: true`.

Version remains at `0.1.0.pre.stage2` throughout. No action from this list is
authorized or implied. ✓

---

### CHK-4: Installed CLI uses `igc compile`

**Result: PASS.**

C1-P1 Current Facts:

```text
Gemspec executable list:      ["igc"]
Canonical installed executable: igc
Repo compatibility executable:  bin/igniter-lang, not listed in gemspec executables
```

C1-P1 states clearly: "installed-gem smoke must use `igc compile SOURCE --out
OUT.igapp`" and "must not use `igniter-lang compile` unless a later package
inspection changes the gemspec executable list."

C1-P1 Installed Executable Verification Strategy:
- "no installed smoke command uses `igniter-lang compile`";
- "no command uses repo-local `igniter-lang/bin/igc` for installed-gem proof."

C1-P1 candidate matrix: PKG-5 uses `$BIN_DIR/igc compile POSITIVE_SOURCE`;
PKG-6 uses `$BIN_DIR/igc compile NEGATIVE_SOURCE`.

C2-P1 Required Command Correction explicitly restates:

> "Installed CLI smoke command is `igc compile`. Do not use `igniter-lang compile`
> unless a future package inspection proves that the installed executable changed."

C2-P1 PKG-4 FAIL condition: "command uses `igniter-lang compile`" → FAIL.
C2-P1 PKG-5 FAIL condition: "command uses `igniter-lang compile`" → FAIL.
C2-P1 FAIL at matrix level: "any smoke command uses `igniter-lang compile` instead
of installed `igc compile`."

This directly resolves S3-R170-C3-X NB-1 (the PKG-4/PKG-5 `igniter-lang compile`
discrepancy from S3-R170-C2-P1) and is consistent with S3-R170-C4-A's canonical
fix and S3-R171-C4-S's carry-forward requirement. ✓

---

### CHK-5: Temp artifact policy is safe

**Result: PASS.**

C1-P1 defines a unique temp root with timestamp/card suffix:

```text
SMOKE_ROOT=/private/tmp/igniter_lang_package_install_smoke_${CARD}_${TIMESTAMP}
```

All build, install, executable, `.igapp`, and output artifacts are isolated under
this root. C1-P1 enumerates allowed temp outputs and specifies:

- "do not commit temp artifacts";
- "do not add generated `.gem`, `.sha256`, gem home, bindir, or `.igapp` outputs
  to the repo";
- "do not overwrite historical `igniter-lang/experiments/release_gate/release_gate.json`
  unless C4-A explicitly authorizes `release-gate`."

C2-P1 Artifact Cleanup/Retention Policy provides a five-row table:

| Artifact | Default |
| --- | --- |
| summary JSON | retain under authorized experiment `out/<run_id>/` |
| command logs / stdout / stderr | retain |
| built `.gem` | do not retain; record SHA256 only |
| isolated `GEM_HOME` | cleanup after result packet |
| copied corpus | cleanup after result packet unless HOLD |
| positive `.igapp` outputs | authorization-defined; label smoke-only if retained |
| refusal output paths | must not exist for PASS; record absence |

The built `.gem` default of "do not retain; record SHA256" is well-motivated:
"avoid mistaking smoke artifact for releasable artifact." The result packet
`artifact_policy` field carries `cleanup_isolated_gem_home: true`.

The policy is layered correctly:
- no developer gem home contamination (isolated `--install-dir`, `--bindir`);
- no repo checkout load-path leakage (`GEM_HOME`/`GEM_PATH` overridden);
- no historical release-gate overwrite without explicit C4-A authorization;
- no repo commit of temp build artifacts.

See NB-1 for a minor scope clarification item on the durable summary JSON path
that C4-A should resolve. ✓ (with NB-1)

---

### CHK-6: PASS/HOLD/FAIL criteria are concrete

**Result: PASS.**

C2-P1 provides a 5-row criteria table (PKG-1..PKG-5), each with independently
testable PASS, HOLD, and FAIL conditions. Examples:

- **PKG-1 PASS**: "`gem build` exits 0; exactly one artifact produced; version
  matches `IgniterLang::VERSION`; no repo file changes."
- **PKG-1 FAIL**: "build exits non-zero; artifact has wrong gem name/version;
  build mutates version/git/source files."
- **PKG-3 PASS**: "`ruby -e 'require "igniter_lang"'` exits 0 using only isolated
  gem env; loaded spec path is inside isolated `GEM_HOME`; no repo-relative `-I`
  or `RUBYLIB` is used."
- **PKG-3 HOLD**: "`LoadError` after successful install, or loaded path cannot be
  proven isolated."
- **PKG-3 FAIL**: "loaded path resolves to repo checkout; require only passes with
  repo-relative `-I`."

Matrix-level rules are explicit:

- **FAIL overrides HOLD**: "any PKG row is FAIL" → matrix FAIL (stated before HOLD
  rule, making precedence clear).
- **HOLD conditions**: environment/isolation/artifact-inspection ambiguity.
- **PASS**: all 5 PKG rows PASS, `failed_checks` empty, `hold_reasons` empty,
  non-claims present.

This directly resolves S3-R169-C3-X NB-3 (package/install matrix lacking
pass/fail/hold criteria). The matrix is now self-contained and auditable. ✓

---

### CHK-7: Positive/refusal corpus selection is sufficient

**Result: PASS.**

Both C1-P1 and C2-P1 specify the same minimum corpus set:

**Positive (5 sources):**
```text
add_baseline.ig
boolean_gate.ig
integer_arithmetic.ig
multi_input_diverse.ig
poc_derived.ig
```

**Negative/refusal (3 sources):**
```text
parse_refusal.ig
type_mismatch.ig
unresolved_symbol.ig
```

These are drawn exclusively from the accepted first-RC harness corpus
(14/14 PASS, with all 5 positive and 3 negative files verified). C1-P1
explicitly states: "Do not introduce new language fixtures in the smoke card."
C2-P1 mirrors this: "Minimum required set for this criteria packet."

The corpus covers multiple language feature categories across the 5 positive
sources (baseline, boolean, arithmetic, multi-input, POC-derived) and all three
refusal categories from the accepted harness. No new language surface is
introduced. The corpus is not language-expanded beyond what passed the accepted
evidence round.

See NB-2 for a scope decision C4-A should make about optional profile-source
checks. ✓ (with NB-2)

---

### CHK-8: Result packet shape preserves non-claims

**Result: PASS.**

C2-P1 provides a normative JSON schema with all required fields. The `non_claims`
block contains 15 explicit entries:

```text
no_public_release_claim
no_public_demo_claim
no_rubygems_publish
no_public_availability_claim
no_version_change
no_git_tag
no_push
no_signing
no_deploy
no_release_execution_beyond_smoke
no_production_runtime
no_spark_integration
no_ruby_framework_compatibility_claim
no_branch_conditional_claim
no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim
```

Required summary invariants include: "`non_claims` must be present for PASS, HOLD,
and FAIL." This prevents a FAIL result from accidentally omitting non-claims that
would be needed for the audit record.

The `release_scope` block adds machine-readable boolean guards:
`public_claims_authorized: false`, `rubygems_publish_authorized: false`,
`production_runtime_authorized: false`.

The result packet shape is normative per C2-P1 ("Field names are normative for the
future smoke result"). ✓

---

### CHK-9: Package/install smoke will not be mislabeled as public release readiness

**Result: PASS.**

Both packets build an explicit multi-step gate between smoke PASS and any public
release readiness claim:

C1-P1: "If the smoke passes, installed-gem/package readiness is still not a public
release claim until a later acceptance decision says so."

C2-P1 matrix header: "They do not imply RubyGems publication, public availability,
production readiness, release execution beyond the smoke, or installed-gem readiness
until an Architect/Portfolio decision accepts the smoke result."

C2-P1 `release_scope.scope: "bounded_local_package_install_smoke"` labels the
result explicitly.

C1-P1 Recommended C4-A Stance: "installed_gem_readiness: not established until
smoke PASS and later acceptance."

C1-P1 Risks table: "Installed smoke is misread as public release readiness" →
"Keep non-claims in result packet and C4-A decision."

The three-step chain is explicit:

```
smoke PASS → evidence for installed-gem readiness review
installed-gem readiness ACCEPTED → not yet public release claim
public release readiness → requires separate authorization and public claims gate
```

No step automatically escalates to the next. ✓

---

### CHK-10: Spark is absent

**Result: PASS.**

C1-P1 Current Facts: "Spark: excluded from this round." Closed Surfaces: "Spark
access, fixtures, integration, or production pressure."

C2-P1 Closed Surfaces: "Spark, Ruby Framework compatibility, production runtime..."
C2-P1 `non_claims.no_spark_integration: true` required in result packet.

S3-R171-C4-S round receipt: `spark_status: excluded_non_authorizing`. Neither
preparation packet mentions Spark in any authorizing or evidence-using context. ✓

---

### CHK-11: Ruby remains non-blocking

**Result: PASS.**

C1-P1 Closed Surfaces: "Ruby Framework compatibility claim." C2-P1 Closed Surfaces:
"Ruby Framework compatibility" claims. C2-P1 `non_claims.no_ruby_framework_compatibility_claim: true`.

S3-R171-C4-S round receipt: `ruby_ledger_hardening: independent_non_blocking`. The
status curation confirms Ruby Ledger hardening proceeds independently and does not
block Lang release-readiness.

Neither preparation packet opens any Ruby Framework, production runtime,
Ledger/TBackend, or BiHistory surface. ✓

---

## Non-Blocking Notes

### NB-1 (most important): C4-A must define the execution card's authorized repo write scope explicitly

C1-P1 states: "execution card writes only a track doc with the result summary and
temp path; do not commit temp artifacts."

C2-P1's `artifact_policy.retained_summary_path` points to:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/
  package_install_smoke_summary.json
```

These are not contradictory — C1-P1 is prohibiting temp build artifacts (.gem,
gem home, corpus copies) from being committed, while the JSON summary is evidence
(not a temp artifact). But C1-P1 says "track doc only" as the durable record,
while C2-P1 implies the JSON summary is also retained under `igniter-lang/
experiments/`.

C4-A should explicitly state:

1. whether the summary JSON under `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/` is an authorized repo write;
2. whether the execution card's track doc alone is the durable record, or whether
   the JSON summary under `experiments/` is also authorized.

A future execution card with an ambiguous write scope could accidentally commit
or not commit the JSON evidence, making the smoke result difficult to audit. The
C2-P1 JSON schema is normative — C4-A should cite it and authorize the
`experiments/` path explicitly if it wants the summary committed.

---

### NB-2: C4-A should make an explicit call on optional profile-source smoke checks

C1-P1 lists an optional profile-source compile check:

```text
igc compile add_baseline.ig \
  --out $OUT_DIR/add_baseline_with_profile.igapp \
  --compiler-profile-source finalized_profile_source.json
```

C2-P1 allows "optional profile-source refusal checks... bounded to installed
`igc compile` without opening loader/report/CompatibilityReport/public API
widening."

Neither packet decides whether this optional check is in scope for the
execution card. If the execution card runs profile-source checks without
explicit C4-A authorization, the smoke scope has widened beyond the baseline
PKG-1..PKG-5 matrix without a gate decision.

C4-A should either:
- **include** profile-source check(s) in the authorized command matrix (adding a
  PKG-6 row with PASS/HOLD/FAIL criteria), or
- **defer** profile-source checks to a separate smoke extension card.

This is a scope-boundary decision, not a criteria gap. The baseline PKG-1..PKG-5
matrix is sufficient for installed-gem readiness evidence; profile-source is additive.

---

### NB-3: C2-P1 result packet `card` field uses a placeholder (`S3-R172-C?-I`)

The normative result packet shape has:

```json
"card": "S3-R172-C?-I"
```

C4-A should assign the execution card designation explicitly (e.g., `S3-R172-C5-I`)
so the execution card can fill this field correctly in the result packet. A result
packet with `C?-I` as the card identifier would be ambiguous in future audit.

This is a minor administrative item with no scope or safety implications.

---

## Verdict

**proceed — no blockers; 11/11 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: no smoke was run yet | PASS |
| CHK-2: no public release/demo claims opened | PASS |
| CHK-3: no version/tag/push/publish/sign/deploy opened | PASS |
| CHK-4: installed CLI uses `igc compile` | PASS |
| CHK-5: temp artifact policy is safe | PASS |
| CHK-6: PASS/HOLD/FAIL criteria are concrete | PASS |
| CHK-7: positive/refusal corpus selection is sufficient | PASS |
| CHK-8: result packet shape preserves non-claims | PASS |
| CHK-9: smoke will not be mislabeled as public release readiness | PASS |
| CHK-10: Spark is absent | PASS |
| CHK-11: Ruby remains non-blocking | PASS |

Both preparation packets together provide C4-A with:

- a precise local package/install smoke target (`local_package_install_smoke_current_version`);
- an exact command candidate matrix (PKG-0..PKG-6 with isolated install);
- the correct installed executable (`igc compile`, not `igniter-lang compile`);
- a safe temp artifact policy with explicit cleanup/retention rules;
- a five-row criteria table (PKG-1..PKG-5) with per-row PASS/HOLD/FAIL
  and matrix-level precedence rules;
- the accepted first-RC harness corpus as the bounded smoke fixture set;
- a normative JSON result packet shape with 15 non-claims fields;
- explicit multi-step separation between smoke PASS and public release claims;
- Spark, Ruby Framework, and production surfaces held closed throughout.

---

## Acceptance Recommendation for C4-A

**Accept both preparation packets. Open the bounded local package/install smoke
execution authorization card.**

The authorization card (C4-A) must:

1. **Define the execution card's authorized repo write scope** (NB-1): cite C2-P1
   `artifact_policy.retained_summary_path` and explicitly authorize (or not) the
   summary JSON write under `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/`;
2. **Decide optional profile-source check scope** (NB-2): either include a PKG-6
   profile-source row with criteria, or explicitly defer;
3. **Assign the execution card designation** (NB-3): replace `S3-R172-C?-I`
   with the actual card number in the authorized write scope;
4. Confirm `igc compile` as the canonical installed executable;
5. Confirm no version change, tag, push, publish, sign, deploy;
6. Confirm installed-gem/package readiness is not established until smoke
   evidence is separately accepted;
7. Keep public claims, Spark, and Ruby Framework surfaces closed.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
package/install smoke execution
public release or demo claims
version file edits
git tag creation
git push
gem build as release artifact
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
card:                              S3-R172-C3-X
track:                             compiler-release-package-install-smoke-authorization-pressure-v0
status:                            done
verdict:                           proceed
blockers:                          0
checks_passed:                     11/11
no_smoke_run:                      confirmed
no_public_release_demo_claims:     confirmed
no_version_tag_push_publish_sign_deploy: confirmed
installed_cli:                     igc compile (confirmed; igniter-lang compile forbidden)
temp_artifact_policy:              safe; /private/tmp isolation; no repo artifact commit
criteria_concrete:                 PKG-1..PKG-5 with per-row PASS/HOLD/FAIL; matrix precedence explicit
corpus_sufficient:                 5 positive + 3 negative from accepted harness corpus; no new fixtures
result_packet_non_claims:          15 non-claims required for PASS/HOLD/FAIL; normative JSON shape
smoke_vs_public_release_mislabel:  explicit three-step gate; smoke PASS ≠ public release readiness
spark:                             absent; non-authorizing
ruby_ledger_hardening:             independent_non_blocking
nb_1:                              C4-A must define execution card authorized repo write scope (most important)
nb_2:                              C4-A must decide optional profile-source smoke check scope
nb_3:                              C4-A must assign execution card designation (replace C?-I placeholder)
next_route:                        compiler-release-package-install-smoke-authorization-review-v0 (C4-A)
```

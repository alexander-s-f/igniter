# Compiler Release Installed Gem Marker and Next Vector Pressure v0

Card: S3-R174-C3-X
Agent: [Release Marker Pressure Reviewer]
Role: review-agent
Track: compiler-release-installed-gem-marker-and-next-vector-pressure-v0
Route: UPDATE
Depends on: S3-R174-C1-S, S3-R174-C2-P1
Date: 2026-05-25

---

## Question

Do the S3-R174-C1-S installed-gem readiness marker and the S3-R174-C2-P1
next-vector options preserve the R173 evidence boundary and public non-claims —
specifically: exact R173 facts used, marker wording bounded to local smoke
readiness only, public release/demo/RubyGems/production/version/tag claims
closed, profile-source deferred or proposed only as an authorization-review
route, NB-1 refusal-kind carried without becoming a blocker, next-vector options
free of release-execution implication, branch/conditional excluded, Spark absent,
Ruby non-blocking?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-installed-gem-readiness-marker-v0.md`
  (S3-R174-C1-S)
- `igniter-lang/docs/tracks/compiler-release-next-vector-options-v0.md`
  (S3-R174-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
  (S3-R173-C3-A)
- `igniter-lang/docs/tracks/stage3-round173-status-curation-v0.md`
  (S3-R173-C4-S)
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
  (durable smoke summary, S3-R173-C1-I)

---

## Check Review

### CHK-1: Marker uses exact R173 run id, version, package, SHA256, and corpus counts

**Result: PASS.**

Verifying each field in C1-S against the durable smoke summary JSON:

| Field | C1-S value | JSON value | Match |
| --- | --- | --- | --- |
| run_id | `S3R173C1I_20260525T063543Z` | `"S3R173C1I_20260525T063543Z"` | ✓ |
| package | `igniter_lang` | `"gem_name": "igniter_lang"` | ✓ |
| version | `0.1.0.pre.stage2` | `"version": "0.1.0.pre.stage2"` | ✓ |
| built_gem_sha256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` | `"built_gem_sha256": "sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a"` | ✓ |
| positive_corpus | `5/5 PASS` | `"PKG-4": {"summary": "5 positive sources; 5 PASS"}` | ✓ |
| refusal_corpus | `3/3 PASS` | `"PKG-5": {"summary": "3 refusal sources; 3 PASS"}` | ✓ |
| failed_checks | `0` | `"failed_checks": []` | ✓ |
| hold_reasons | `0` | `"hold_reasons": []` | ✓ |
| repo_relative_i_used | `false` | `"repo_relative_i_used": false` | ✓ |
| repo_path_leak | `false` | `"repo_path_leak_observed": false` | ✓ |

The C1-S "Accepted Smoke Evidence" section also records the accepted PKG matrix
(PKG-0..PKG-5 all PASS) verbatim from S3-R173-C3-A.

The installed executable is correctly recorded as `igc compile` in both C1-S and
the JSON (`"executable_observed": "igc"`). ✓

---

### CHK-2: Marker wording is limited to local package/install smoke readiness

**Result: PASS.**

C1-S `readiness_scope: local_package_install_smoke_only` — the scope label itself
is bounded.

The accepted wording from C1-S:

> "The current local igniter_lang package builds, installs into an isolated gem
> home, loads without repo-relative -I, and the installed igc CLI compiles the
> accepted positive corpus and refuses the accepted negative corpus."

This wording:
- is marked "local" throughout — no public or network availability implied;
- describes what was mechanically proven: build, isolated install, load, compile,
  refuse — not semantic completeness or feature coverage;
- does not claim "all grammar," "production ready," "publicly available," or
  "released."

C1-S explicitly states: "This marker records accepted local evidence only. It does
not make public release, RubyGems availability, production, demo, Spark, Ruby
Framework compatibility, all-grammar, or branch/conditional support claims."

The accepted wording matches S3-R173-C3-A's "Allowed wording" verbatim. The
seven "Not allowed" wording forms from S3-R173-C3-A do not appear in the marker.

The readiness wording is correctly bounded to local smoke evidence. ✓

---

### CHK-3: Public release/demo, RubyGems, production, version/tag/push/publish/sign/deploy claims remain closed

**Result: PASS.**

C1-S Public Non-Claims section explicitly closes each required surface:

```text
- public release/demo claims
- RubyGems publish and public availability claims
- production readiness
- version edits
- gemspec/package metadata edits
- git tag creation
- git push
- signing
- deployment
```

C1-S compact handoff:

```text
public_release_demo_claims:            closed
rubygems_publish:                      closed
version_tag_push_publish_sign_deploy:  closed
```

C2-P1 current accepted state confirms:

```text
public release/demo claims: closed
release execution: closed
version/tag/push/publish/sign/deploy: closed
```

C2-P1 Explicit Answers: "May public release/demo claims open now? No. Accepted
local package/install smoke readiness is not public release readiness, RubyGems
availability, production readiness, or public demo readiness."

C2-P1 compact: `release_execution_authorized: no`, `public_claims_authorized: no`.

All required closures are in place across both cards. ✓

---

### CHK-4: Profile-source smoke remains deferred unless proposed only as a future authorization-review route

**Result: PASS.**

C1-S: `profile_source_smoke: deferred` in the compact handoff. The Public
Non-Claims section lists "profile-source smoke extension" as closed.

C2-P1 proposes profile-source as **Option B — "Profile-source smoke extension
authorization review"** with the required boundary: "Authorization review first;
define corpus, pass/fail/hold, installed `igc` command scope; no execution in
review." The explicit design is that Option B itself must be an authorization
review card, not an execution card.

C2-P1's recommendation: "conditional accept: open profile-source smoke extension
authorization review next." The conditions explicitly state: "Do not authorize
execution in C4-A unless a separate implementation/smoke card is explicitly
dispatched."

Neither C1-S nor C2-P1 runs profile-source smoke or implies profile-source is
executed now. The proposal is authorization-review-only. Profile-source remains
deferred unless C4-A explicitly opens the authorization-review route. ✓

---

### CHK-5: NB-1 refusal kind hygiene is carried without becoming a false blocker

**Result: PASS.**

C1-S Future Smoke Hygiene section carries NB-1 correctly:

```text
type_mismatch.ig refusal_kind should classify as oof
unresolved_symbol.ig refusal_kind should classify as oof
```

C1-S explicitly annotates: "This does not block the accepted readiness marker
because PKG-5 criteria passed: non-zero exit, observed refusal, and no `.igapp`
output."

C1-S compact: `future_smoke_hygiene: type_mismatch_and_unresolved_symbol_refusal_kind_should_be_oof`

C2-P1 Explicit Answers: "Must NB-1 refusal kind hygiene block the next route?
No. NB-1 is accepted as future smoke hygiene, not a blocker. PKG-5 passed because
the installed CLI returned non-zero, produced no `.igapp`, and observed refusal."

C2-P1 compact: `NB_1_refusal_kind_hygiene_blocks_next_route: no`

NB-1 is preserved as actionable hygiene information for future smoke rounds
without being elevated to a gate condition. ✓

---

### CHK-6: Next-vector options do not imply release execution

**Result: PASS.**

C2-P1 opens with an explicit scope restriction:

> "Prepare the next release-vector options...without authorizing execution, smoke
> reruns, public claims, or implementation."

C2-P1 Explicit Answers: "May release execution open now? No. Release execution
remains closed. R170 authorized only a bounded repo-local marker path, and R173/
R174 readiness recognition does not authorize version edit, tag, push, publish,
signing, deployment, or public release action."

Reviewing all six options for execution-implication:

| Option | Execution implied? | Boundary |
| --- | --- | --- |
| A. Public release/docs non-claims planning | No | "Docs/design only; no publish, no tag, no version edit" |
| B. Profile-source smoke extension authorization review | No | "Authorization review first...no execution in review" |
| C. Release execution hold | No | "status/decision only; no new commands" |
| D. Additional package/install smoke hygiene | No | "Design or proof-local...no release execution" |
| E. Return to compiler/language feature lane | No | "Explicit redirect/hold decision; release claims remain closed" |
| F. Pause | No | "no writes beyond status if needed" |

None of the six options implicitly authorize or suggest release execution. The
recommended route (Option B) is explicitly authorization-review-only.

C2-P1 compact: `release_execution_authorized: no`, `analysis_only: yes`,
`smoke_run: no`, `code_changed: no`. ✓

---

### CHK-7: Branch/conditional `if_expr` remains excluded

**Result: PASS.**

C1-S Public Non-Claims: "branch/conditional `if_expr` support" is closed.

C2-P1 current accepted state: `branch_conditional_if_expr: excluded`

C2-P1 Explicit Answers: "Does branch/conditional `if_expr` remain excluded? Yes.
`branch_conditional_if_expr` remains excluded from the first RC/release readiness
scope and remains a post-RC language/compiler design lane."

C2-P1 compact: `branch_conditional_if_expr: excluded`

The S3-R173-C3-A "Not allowed" wording explicitly prohibits "Supports branch/
conditional if_expr." This prohibition is preserved in both cards without
softening. ✓

---

### CHK-8: Spark remains absent

**Result: PASS.**

C1-S Public Non-Claims: "Spark integration" is explicitly closed.
C2-P1 Closed Surfaces: "Spark access, fixtures, specs, integration, or production
pressure" is first in the closed-surface list.
C1-S marker text: "It does not make...Spark...claims."

Neither card mentions Spark in any authorizing or evidence-using context. ✓

---

### CHK-9: Ruby remains independent and non-blocking

**Result: PASS.**

C1-S Public Non-Claims: "Ruby Framework compatibility" is closed.
C2-P1 Closed Surfaces: "Ruby Framework docs/release/tag/package/compatibility
claims."
S3-R173-C4-S round receipt: `ruby_ledger_hardening: independent_non_blocking`.

Neither C1-S nor C2-P1 opens any Ruby Framework, production runtime, or Ledger/
TBackend surface. Ruby Ledger hardening remains independent and non-blocking. ✓

---

## Non-Blocking Notes

### NB-1: C2-P1 "release execution closed" rationale cites only R170 — a future reader should also see R171–R174 in the chain

C2-P1's Explicit Answers states: "Release execution remains closed. R170 authorized
only a bounded repo-local marker path, and R173/R174 readiness recognition does
not authorize version edit, tag, push, publish, signing, deployment, or public
release action."

This is correct, but the rationale mentions only "R170" and "R173/R174 readiness
recognition" — it does not cite R171 (marker accepted), which is part of the
authorization chain closing release execution. A future agent reading C2-P1 in
isolation might infer that only R170 and R173/R174 matter, potentially missing
the R171 acceptance.

This is a documentation nuance, not a scope or safety issue. The closure is
correct and complete regardless of which rounds are cited. C4-A's decision
document could optionally cite the full chain (R170→R171→R172→R173→R174) when
reaffirming release execution closure.

---

### NB-2: C2-P1 Option A backup route wording needs care in any future implementation

C2-P1 recommends Option A (public release/docs non-claims planning) only as a
backup route, with the caveat: "must be explicitly non-public and non-claiming."
The Option A risk entry notes: "Premature wording can be mistaken for public
claim; branch/conditional exclusion can be softened accidentally."

If C4-A accepts Option A as the backup, the implementation card for Option A must:
- produce only internal docs-design templates, not public-facing content;
- explicitly preserve the seven "Not allowed" wording prohibitions from S3-R173-C3-A;
- not soften the branch/conditional exclusion wording.

This is a forward-looking note, not a blocker on C1-S or C2-P1 as written. C4-A
should carry this as a binding constraint if Option A is opened.

---

## Verdict

**proceed — no blockers; 9/9 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: marker uses exact R173 run id, version, package, SHA256, corpus counts | PASS |
| CHK-2: marker wording limited to local package/install smoke readiness | PASS |
| CHK-3: public release/demo/RubyGems/production/version/tag claims closed | PASS |
| CHK-4: profile-source deferred or proposed as authorization-review only | PASS |
| CHK-5: NB-1 refusal kind hygiene carried without becoming false blocker | PASS |
| CHK-6: next-vector options do not imply release execution | PASS |
| CHK-7: branch/conditional `if_expr` remains excluded | PASS |
| CHK-8: Spark remains absent | PASS |
| CHK-9: Ruby remains independent and non-blocking | PASS |

Both cards are correctly scoped. The readiness marker records exact R173 facts and
is bounded to local smoke evidence only. The next-vector options are analysis-only
with all six options structured as design/authorization/status routes — none
implying execution. NB-1 from R173-C2-X is carried correctly as hygiene without
becoming a blocker.

---

## Acceptance Recommendation for C4-A

**Accept both preparation cards. Open the next-vector decision.**

C4-A should:

1. **Accept the installed-gem readiness marker (C1-S)** as correctly bounded to
   local package/install smoke readiness for `igniter_lang 0.1.0.pre.stage2`;
2. **Select the next vector** from C2-P1's option table — recommended Option B
   (profile-source smoke extension authorization review), backup Option A
   (non-public docs planning, design only);
3. **Carry NB-1** (refusal-kind hygiene) forward to the next smoke execution card
   if the release vector continues — not a current blocker;
4. **Carry NB-2** (Option A wording care) as a binding constraint if the backup
   route is opened;
5. **Cite the full R170→R171→R172→R173→R174 authorization chain** when affirming
   that release execution remains closed (addressing this review's NB-1).
6. Keep public release/demo claims, version/tag/push/publish/sign/deploy, Spark,
   branch/conditional `if_expr`, and Ruby Framework surfaces closed.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
public release or demo claims
RubyGems publish
version file edits
git tag creation
git push
signing or deployment
profile-source smoke execution
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
card:                              S3-R174-C3-X
track:                             compiler-release-installed-gem-marker-and-next-vector-pressure-v0
status:                            done
verdict:                           proceed
blockers:                          0
checks_passed:                     9/9
r173_facts_exact:                  yes (run_id, version, package, SHA256, corpus counts all verified)
marker_wording_bounded:            yes (local_package_install_smoke_only; verbatim C3-A allowed wording)
public_release_demo_claims:        closed
rubygems_production_version_tag:   closed
profile_source:                    deferred; proposed as authorization-review-only (no execution)
nb1_refusal_kind_hygiene:          carried as future hygiene; not a blocker
next_vector_options_no_execution:  confirmed (analysis_only; 6 options all bounded)
branch_conditional_if_expr:        excluded
spark:                             absent; non-authorizing
ruby_ledger_hardening:             independent_non_blocking
nb_1:                              C2-P1 release-execution rationale cites R170/R173-R174 only; full chain R170→R174 recommended in C4-A for completeness
nb_2:                              Option A backup route needs seven not-allowed wording prohibitions carried as binding constraint if opened
next_route:                        compiler-release-next-vector-decision-v0 (C4-A)
```

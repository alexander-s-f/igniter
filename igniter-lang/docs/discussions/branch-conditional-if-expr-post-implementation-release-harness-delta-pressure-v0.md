# Branch Conditional If Expr Post Implementation Release Harness Delta Pressure v0

Card: S3-R192-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-post-implementation-release-harness-delta-pressure-v0

Context: internal — full read access to C1-D design, cited evidence files, R191
status curation, and C3-I docs sync track
Write access: none
Canon authority: none

---

## Question

Does the proposed post-implementation release-harness / evidence disposition
(S3-R192-C1-D) correctly treat accepted release evidence as immutable historical
artifacts, avoid public/demo/runtime/Spark claim drift, correctly scope any
future harness delta as proof-only/compiler-only and future-gated, and correctly
sequence proof-summary hygiene before harness delta evidence?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-post-implementation-release-harness-delta-design-v0.md` (S3-R192-C1-D)
- `igniter-lang/docs/tracks/stage3-round191-status-curation-v0.md` (S3-R191-C4-S)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md` (S3-R191-C3-I)
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`

---

## Live Evidence Verification

Three cited evidence packets read directly and verified:

### `compiler_release_acceptance_harness_summary.json`

```text
kind: compiler_release_acceptance_harness_summary
status: PASS
release_scope.scope: repo_local_compiler_rc
release_scope.excluded_features: ["branch_conditional_if_expr"]
release_scope.exclusion_basis: S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr
release_scope.public_claims_authorized: false
release_scope.production_runtime_authorized: false
non_claims includes: no_branch_conditional_claim, no_release_execution, no_public_demo_claim,
  no_spark_integration, no_production_runtime, no_public_api_cli_widening, no_rubygems_push
```

### `official_first_rc_evidence_summary.json`

```text
kind: official_first_rc_evidence
status: PASS
evidence_label: official_first_rc_evidence
authorization: S3-R167-C1-A
release_scope.scope: repo_local_compiler_rc
release_scope.excluded_features: ["branch_conditional_if_expr"]
release_scope.exclusion_basis: S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr
release_scope.public_claims_authorized: false
release_scope.production_runtime_authorized: false
non_claims includes: no_branch_conditional_claim, no_release_execution, no_public_demo_claim,
  no_pre_rc_output_relabeled, no_spark_integration, no_production_runtime
```

### `combined_post_prep_smoke_summary.json`

```text
kind: compiler_release_combined_post_prep_smoke_summary
status: PASS
card: S3-R183-C2-I
authorized_by: S3-R183-C1-A
non_claims.no_branch_conditional_claim: true
non_claims.no_release_execution: true
non_claims.no_public_release_claim: true
non_claims.no_production_runtime: true
non_claims.no_spark_integration: true
```

All three packets contain intact exclusion fields, correct labels, and immutable
non-claims. None has been edited since original creation.

---

## Scope Check Matrix

| ID | Check | Evidence | Result |
| --- | --- | --- | --- |
| SC-1 | Accepted alpha/first-RC/release evidence remains immutable historical evidence | C1-D Option 1 explicitly forbids editing all three out/** directories and release harness corpus; evidence label `official_first_rc_evidence` preserved; `branch_conditional_if_expr` exclusion and S3-R164-C4-A basis preserved; live file verification confirms all three packets intact | PASS |
| SC-2 | No wording implies public/demo/stable/production/all-grammar support | Required non-claims include "no public demo/stable/production/all-grammar claim"; Option 1 non-claims explicit; harness-delta future summary JSON has `no_public_demo_stable_production_all_grammar_claim: true`; vocabulary improvement ("historical first-RC/alpha evidence excluded" vs "if_expr unsupported") is a precision correction for future status docs only, not an evidence mutation | PASS |
| SC-3 | No wording implies runtime/evaluator support | C1-D explicitly: runtime closure blocks "public demo support, runtime/lazy branch execution claims, production readiness claims, all-grammar claims"; Option 4 correctly scopes what runtime closure does vs. does not block; harness-delta summary has `no_runtime_evaluator_claim: true` | PASS |
| SC-4 | No wording implies Spark/API/CLI support | Spark explicitly in forbidden lists for both Option 2 and Option 3; harness-delta summary shape has `no_spark_claim: true`; Option 2 write scope excludes Spark files | PASS |
| SC-5 | Harness delta, if recommended, is proof-only, future-scoped, and uses new evidence label | Option 2 explicitly "viable after proof-summary hygiene, but not the immediate next card"; new write scope `experiments/branch_conditional_if_expr_release_harness_delta_v0/**`; evidence label `if_expr_internal_compiler_delta`; `not_official_rc_evidence: true`; `does_not_relabel_prior_release_evidence: true`; `historical_release_evidence.unchanged: true` and `excluded_features_preserved: ["branch_conditional_if_expr"]` | PASS |
| SC-6 | Proof-summary hygiene, if recommended, cannot mutate accepted release evidence | Option 3 write scope limited to `experiments/branch_conditional_if_expr_v0_implementation_proof/**` only; "release harness/evidence files" explicitly in Option 3 forbidden section; no path from Option 3 to any `out/**` evidence packet | PASS |
| SC-7 | Release lane remains paused | C1-D closed surfaces section: "accepted alpha / first-RC / release evidence mutation; release execution, publish, yank, tag, sign, deploy; public release/demo/stable/production/all-grammar claims"; no option opens release lane | PASS |
| SC-8 | C1-D preferred option (A) is correctly sequenced and the recommendation is sound | Option A: keep historical evidence unchanged → proof-summary hygiene first → harness delta later by separate authorization; rationale is explicitly stated; hygiene-before-delta sequencing is correct because negative OOF-IF* cases in a harness delta need clean machine-readable OOF-TY0 classification | PASS |

Overall: **8/8 PASS** — no blockers.

---

## [Agree]

- C1-D's treatment of the three accepted evidence packets as immutable historical
  artifacts is exactly correct. All three packets contain `branch_conditional_if_expr`
  in their `excluded_features` arrays with the same `exclusion_basis`
  (`S3-R164-C4-A`). R190 internal compiler support landed *after* the first-RC
  exclusion decision, so the old packets must and do continue to show the
  exclusion intact. C1-D does not propose to touch any of them.

- The vocabulary improvement in Option 1's release historical wording policy is
  precise and safe. Saying "historical first-RC/alpha evidence excluded
  branch_conditional_if_expr" is more accurate than "if_expr unsupported" because
  the compiler now supports `if_expr` internally — only the release evidence scope
  excluded it. This distinction belongs in future status/gate docs, not in the
  evidence files themselves, and C1-D correctly targets only future summary
  language.

- The Option A sequencing (hygiene first, delta later) is the right order.
  The R190 implementation proof's three negative `if_expr` diagnostic cases
  (`missing_else`, `branch_type_mismatch`, `empty_branch`) show derivative
  `OOF-TY0` in their `rules` arrays without explicit secondary labeling. A
  future harness-delta proof that records these same negative cases would
  propagate the ambiguity into new evidence. Option 3 closes that before
  Option 2 opens.

- The Option 2 future summary shape is well-designed. The three-layer label
  guard (`not_official_rc_evidence`, `does_not_relabel_prior_release_evidence`,
  `release_historical_exclusion_preserved`) makes it structurally impossible
  for a future reader to conflate the new compiler-delta packet with the
  official first-RC evidence.

- The Option 2 CM-9 check (`Old evidence immutability check`) is correct
  design. A hash or read-only comparison of prior summary files ensures that the
  harness-delta proof run does not accidentally write to existing evidence
  output directories.

- The runtime/evaluator boundary is cleanly drawn. C1-D correctly identifies
  that runtime closure blocks public/runtime claims but does not block a
  compiler-only delta that compiles, diagnoses, and lowers `if_expr` via the
  existing CLI/API without claiming runtime evaluation.

- The Option 3 write scope is exactly right: `experiments/branch_conditional_if_expr_v0_implementation_proof/**` only. This is proof-owned territory, not release harness territory.

- The five-option decision table gives C3-A a clear and complete set of
  choices. Option A (preferred) is well-motivated.

---

## [Challenge]

No blocking challenges.

One forward-looking precision note on Option 2 negative case checks (SC-5,
NB-1 below): the CM-4..CM-7 checks say "derivative OOF-TY0 separated as
secondary if present." The word "if present" is slightly ambiguous — it could
mean the check passes whether or not derivative OOF-TY0 appears, as long as
it is labeled secondary when it does. This is correct intent, but if
C3-A selects Option B (open harness delta now, without waiting for hygiene), the
proof runner must enforce the separation actively, not just passively accept it.
The safest interpretation is: Option 2 must require that whenever OOF-TY0 is
present in a negative `if_expr` case, it is classified as secondary
type-propagation output, not as a primary diagnostic. This is achievable and
correct; it is why C1-D prefers Option A.

---

## [Missing]

No blocking gaps. Two non-blocking precision notes for C3-A:

**NB-1: Option 2 CM-4..CM-7 "separated as secondary if present" — clarify active vs. passive enforcement**

The future harness-delta proof runner should actively assert the OOF-TY0
secondary classification for any negative case that produces a derivative
OOF-TY0, not merely accept any diagnostic output that includes one. Specifically:

- CM-4 (non-Bool condition): must assert `oof_ty0_for_if_expr_absent: true` (no
  derivative OOF-TY0 expected here either, since OOF-IF1 resolves to `Unknown`
  but that alone does not trigger a downstream type-annotation mismatch without
  an output node check).
- CM-5..CM-7 (missing else, type mismatch, empty branch): must assert that any
  `OOF-TY0` present carries a `secondary_type_propagation: true` field or
  equivalent, not a bare `OOF-TY0` in a primary `rules` array without label.

If Option 3 (proof-summary hygiene) runs first and introduces a `secondary_rules`
or `oof_ty0_for_if_expr_absent` field for these cases, the Option 2 proof runner
can reference that pattern directly. This is the primary reason to prefer Option A.

**NB-2: Option 3 semantic-check count must be preserved**

C1-D's Option 3 allowed changes include "regenerate only the proof-owned
summary/output files." C3-A should explicitly require that the Option 3 proof
runner must produce `checks_total: 28` and `checks_pass: 28` — identical to the
R189 C2-I accepted proof count — confirming no semantic behavior was changed by
the hygiene update. This requirement is implicit in the "same semantic checks"
CM-1 wording but should be stated as an explicit gate condition in the Option 3
authorization card to prevent any reduction in check coverage being accepted as a
hygiene artifact.

---

## [Sharper Question]

If C3-A accepts Option A and opens only proof-summary hygiene now, does the
release lane remain fully paused with no implicit forward commitment to Option 2?

Answer: Yes. Option A does not commit to Option 2. The release-harness delta
(Option 2) requires a separate future authorization review that names a new
evidence packet boundary, a new experiment directory, and a new evidence label.
That future review has not been opened by C1-D. Option A's next card boundary
is proof-summary hygiene only:

```text
Card: S3-R192-C2-P1
Track: branch-conditional-if-expr-proof-summary-hygiene-v0
Goal: close derivative OOF-TY0 ambiguity and no_spark_claim JSON gap
Write scope: experiments/branch_conditional_if_expr_v0_implementation_proof/**
             + track doc
Does not open: release harness delta, release execution, public claims
```

This is the minimal and correct next boundary.

---

## [Route]

**Verdict: proceed — 8/8 PASS, no blockers.**

```text
checks total: 8
checks pass:  8
checks fail:  0
blockers:     none
non-blocking notes: 2

NB-1: Option 2 CM-4..CM-7 "separated as secondary if present" — authorization
      card for Option 2 should require active assertion of secondary
      classification (oof_ty0_for_if_expr_absent: true or secondary_rules
      pattern), not passive acceptance; Option A (hygiene first) naturally
      resolves this before Option 2 executes
NB-2: Option 3 authorization card should state an explicit gate condition:
      checks_total == 28 and checks_pass == 28 must hold after hygiene updates,
      confirming no semantic regression
```

**Recommended C3-A decision:**

```text
Accept Option A (preferred boundary):

1. Keep all three accepted evidence packets unchanged and explicitly historical.
   Accepted packet boundaries:
     compiler_release_acceptance_harness_summary.json   — immutable
     official_first_rc_evidence_summary.json            — immutable
     combined_post_prep_smoke_summary.json              — immutable
   Exclusion preserved: branch_conditional_if_expr in excluded_features, all packets.
   Evidence label preserved: official_first_rc_evidence.

2. Open proof-summary hygiene next (Option 3) as the immediate next boundary.
   Exact write scope:
     igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**
     igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md
   Required gate conditions (NB-2):
     checks_total == 28 and checks_pass == 28 after hygiene
     no_spark_claim present and true
     unsupported-if_expr OOF-TY0 absent for all negative cases
     derivative OOF-TY0 explicitly labeled secondary where present

3. Hold release-harness delta (Option 2) until hygiene lands and a separate
   authorization review names a new evidence packet boundary, new experiment
   directory, and new evidence label.

4. Keep all closed surfaces closed:
   runtime/evaluator support, release execution, publish/yank/tag/sign/deploy,
   public release/demo/stable/production/all-grammar claims, Spark,
   public API/CLI widening.

5. No forward commitment to Option 2 is created by accepting Option A.
```

Route: `track` — open `S3-R192-C2-P1` proof-summary hygiene card within the
exact Option 3 write scope and NB-2 gate conditions above.

# Counterfactual Audit Proof-Owned Artifact Home Design Pressure v0

Card: S3-R218-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: counterfactual-audit-proof-owned-artifact-home-design-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R218-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-v0.md` (C2-I)
- `igniter-lang/experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/counterfactual_audit_proof_owned_artifact_home_v0_summary.json` (proof summary)
- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-decision-v0.md` (R217-C4-A)

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Write scope compliance | C2-I: files written = experiment directory + track doc only; track doc states "No `lib/**`, spec chapters, PROP-032, runtime/evaluator, RuntimeSmoke, R211 evidence, or any closed surface was modified"; C1-A allowed scope = `experiments/counterfactual_audit_proof_owned_artifact_home_v0/**` + track doc | Write scope exactly matches C1-A authorization. No unauthorized targets written. | ✅ PASS |
| No `lib/**` changes | Summary JSON `closed_surface_scan.lib_files_loaded: false`; AH-10 check `no_lib_files_loaded: PASS`; AH-1 check `home_path_is_under_experiments_not_lib: PASS` | `lib/` was not loaded, modified, or referenced as a target. The artifact home path is under `experiments/`, not `lib/`. | ✅ PASS |
| No compiler / runtime / report / API / public surface mutation | Summary JSON: `runtime_smoke_loaded: false`, `compiled_program_loaded: false`, `compiler_result_modified: false`, `compilation_report_modified: false`, `spark_or_cli_loaded: false`, `spec_chapters_modified: false`; AH-10: 7/7 sub-checks PASS | All seven closed-surface scan fields are false. No compiler, evaluator, RuntimeSmoke, report, result, receipt, CompatibilityReport, spec chapter, or public/Spark/CLI surface was touched. | ✅ PASS |
| No `.igapp` or manifest mutation outside experiment-owned outputs | Summary JSON `closed_surface_scan.igapp_created_outside_experiment: false`; AH-10 check `no_igapp_outside_experiment_scope: PASS`; artifact home manifest lives under `experiments/…/out/artifact_home/` | `.igapp` was not created outside the designated experiment output directory. The only manifest created (`artifact_home_manifest.json`) is inside the experiment-owned scope. | ✅ PASS |
| No-authority flags present and false | Summary JSON `authority_flags`: all 9 flags (`canonical`, `runtime_authority`, `report_authority`, `cache_authority`, `dependency_authority`, `public_api_authority`, `compiler_emitted`, `spark_authority`, `production_authority`) confirmed `false`; AH-2 checks: `all_required_authority_flags_present: PASS`, `all_authority_flags_are_false: PASS`, `projection_authority_all_false: PASS`, `projection_isolation_all_false: PASS` (9/9 sub-checks PASS) | All 9 required authority flags from C1-A are present and false. Flag propagation verified at manifest, projection, and source-artifact levels. No partial or omitted flag. | ✅ PASS |
| Projected value / failure disclaimers present | Summary JSON `projection_disclaimers`: `projected_value_is_not_actual_output: true`, `projected_failure_is_not_actual_failure: true`, `no_authority_disclaimer` present; AH-9: 4/4 sub-checks PASS including `AH-9.projected_value_correct_12` (multiply 3×4 = 12, not an actual runtime output) | Both required disclaimers are present. `projected_value` is explicitly not actual output. `projected_failure` is explicitly not actual runtime failure. | ✅ PASS |
| R211 evidence immutability | Summary JSON `r211_immutability`: `immutable: true`, `pass_count: 61`, `fail_count: 0`, `overall: "PASS"`, `usage: "historical_evidence_citation_only"`, R211 digest `sha256:e9474cf0ac5bda39a9af6a748d966722f9c43c5911aeb2fa25ec36e6da0a2178`; AH-3: 4/4 sub-checks PASS including `r211_source_artifacts_exist_and_unchanged`; AH-10 check `r211_summary_digest_matches_known_pass_content: PASS` cross-verifies R211 was not tampered with between authorization and execution | R211 evidence is read-only. R211 regression rerun confirms 61/61 PASS. The new C2-I evidence packet (`if:score_gate_artifact_home_v0`, operator `multiply`, projected value 12) is genuinely distinct from R211 (`if:risk_gate_source_backed_v0`, operator `add`, projected value 15); confirmed by AH-4 (3/3 sub-checks PASS including different digests). | ✅ PASS |
| Digest recomputation policy clarity | Summary JSON `digest_policy`: convention `"sha256:<hex>"`, scope `"proof-owned outputs only"`, stability `"content-addressed; same content => same digest"`, authority `"none — digests carry no cache/dependency/compiler authority"`; AH-5: 5/5 sub-checks PASS (all digest prefixes, manifest/projection/premise digest recomputation stability, on-disk digest match) | Digest policy is unambiguous. Digests are evidence anchors, not cache keys or dependency truth. Stability is content-addressed only. All 5 digest checks pass including on-disk match against in-memory recomputation. | ✅ PASS |
| Snapshot privacy / persistence posture clarity | Summary JSON `snapshot_privacy_posture`: `mutable: false`, `persistence_authority: false`, `privacy_policy_authority: false`, `production_data: false`, explicit note present; AH-6: 4/4 sub-checks PASS | Snapshot posture covers all required stances from C1-A: not mutable, no persistence authority, no privacy-policy authority, not actual runtime input. | ✅ PASS |
| No public / Spark / API / release claims | Summary JSON `non_claims`: 12 fields all `true`, covering `not_public_counterfactual_audit_support`, `not_spark_api_cli_support`, `not_release_evidence`, `not_production_behavior`, `not_runtime_behavior`, `not_live_nonselected_branch_evaluation`, plus all CompilerResult/CompilationReport/schema/receipt exclusions | Non-claim block is comprehensive. Present in manifest, track doc, and non_claims object. No promotional language found. | ✅ PASS |
| Assumptions remain premise capsule only | AH-7: 4/4 sub-checks PASS including `premise_set_authority_no_prop032_widening: PASS` and `premise_set_authority_no_cache_dependency: PASS`; C1-A required premise-set stance (no PROP-032, no branch-level syntax, no receipt authority) confirmed | PROP-032 widening not introduced. No branch-level assumptions syntax. Premise sets remain proof-local capsules. | ✅ PASS |
| RuntimeSmoke proof-context wording remains binding | Summary JSON `closed_surface_scan.runtime_smoke_loaded: false`; C1-A "Also closed: runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior"; C2-I track doc confirms RuntimeSmoke not loaded; AH-10 check `no_runtime_smoke_or_compiled_program_loaded: PASS` | RuntimeSmoke was not loaded, referenced, or described as feature support anywhere in the proof. Canonical wording from R215-C1-D remains unaltered. | ✅ PASS |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Did C2-I stay experiments-only? | Yes. Write scope = experiment directory + track doc only. All 8 closed-surface scan fields false. AH-10 (7/7 PASS) independently confirms. |
| Does Option B artifact home remain proof-owned and non-canonical? | Yes. Manifest carries `proof_owned: true`, `canonical: false`. All 9 authority flags false at manifest, projection, and source-artifact levels. Home path is under `experiments/`, not `lib/`. |
| Are authority flags sufficient? | Yes. All 9 required flags from C1-A are present and false. Propagation verified across three artifact types (manifest, projection envelope, source refs). AH-2 (9/9 sub-checks PASS). |
| May the proof be accepted? | Yes. 47/47 PASS across 10 check groups. All scope, authority, immutability, digest, snapshot, disclaimer, and closed-surface checks clear. |
| Is follow-up required before acceptance? | No. The proof is complete as submitted. Option C (docs index companion) and Option D (non-canonical carrier) remain future routes but are not prerequisites for accepting this proof. |

---

## Verdict

```text
PASS

C2-I proof: 47/47 PASS — accept
No blockers
No non-blocking acceptance notes
C4-A HOLD: release; proceed to unconditional acceptance
```

The proof is clean. No authority flags were omitted or set to true. R211 historical evidence is intact and cross-verified by digest match. The new evidence packet is genuinely distinct. Scope compliance is fully documented. The non-claim block is comprehensive and machine-readable.

---

## Recommendation for S3-R218-C4-A

```text
Card: S3-R218-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I proof: Option B proof-owned artifact home design
- AH-1..AH-10 proof matrix (47/47 PASS) as current evidence anchor
- R211 immutability (61/61 PASS confirmed by C2-I regression + digest match)
- Artifact home path:
    experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/artifact_home/
- Manifest digest:
    sha256:f61ca7941ff064358eb09a1629e0b382871acb7b8ecddfc51963e770930515d3
- Summary digest:
    sha256:2e5628f3f2c61561d7e7ef3ebc6b085ff551c9e16a7ad6f84279660b1c1253d7

What this accepts:
- Option B is now proven as a viable proof-owned artifact home structure
- Authority-flag pattern (9 fields, all false) is the confirmed model for any
  future non-proof-local artifact
- Digest policy and snapshot privacy posture are defined

What this does not accept:
- Any promotion of the experiment-local home to lib/**, compiler, runtime,
  report/result/receipt, or public surfaces
- Option C, D routes (remain future design decisions)
- Options E/F (remain comparison-only)
- Any live implementation

Keep closed:
- lib/**, compiler pipeline, RuntimeSmoke feature claims
- report/result/receipt/CompatibilityReport fields
- cache/dependency authority
- public API/CLI/Spark/demo/production
- all implementation
```

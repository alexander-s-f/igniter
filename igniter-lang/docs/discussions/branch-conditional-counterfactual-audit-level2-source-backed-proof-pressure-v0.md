# Branch Conditional Counterfactual Audit Level 2 Source-Backed Proof Pressure v0

Card: S3-R211-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-source-backed-proof-pressure-v0`

---

## Question

Did S3-R211-C2-I stay inside the authorized write scope, prove SB-1..SB-15 with
correct source refs, digest chain integrity, no-authority semantics, execution-
summary as actual-path citation only, Tier 0 properly labeled as legacy, required
`assumed_condition_source`, and all R209 closed surfaces intact?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md` (C2-I track doc)
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/semanticir_risk_gate_v0.json` (read)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/stage3-round210-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`

Independent verification commands run:

```bash
git show --name-only HEAD
# → 9 files: track doc, harness .rb, summary JSON, 6 source_artifacts/*.json

python3 digest-verify.py
# → All 6 source artifact digests MATCH on-disk SHA-256

rg -n "would_result|...|alternate_actual_output" harness.rb summary.json source_artifacts/
# → 2 matches: both in execution_summary_citation "note" field (negative disclaimer)
# → CLEAR for all projection fields (Python verification)

grep -n "require.*igniter_lang|require.*lib/" harness.rb
# → no output
```

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Write scope exact (authorized experiment dir + track doc) | PASS |
| SC-2 | SB-1..SB-15 all present and passing (61/61) | PASS |
| SC-3 | Source refs use `sha256:<hex>` with on-disk digest match | PASS |
| SC-4 | `canonical:false` present on source refs and evidence packets | PASS |
| SC-5 | Source-backed evidence is not hand-authored-only; Tier 1 primary | PASS |
| SC-6 | Input snapshot is frozen (`mutable:false`) and no-authority | PASS |
| SC-7 | `premise_set` has required `assumed_condition_source` | PASS |
| SC-8 | Execution-summary citation is actual-path read-only context only | PASS |
| SC-9 | `projected_value` / `projected_failure` disclaimers preserved | PASS |
| SC-10 | `tbackend_read` remains refused; no live reads | PASS |
| SC-11 | Forbidden vocabulary fenced (projection fields CLEAR) | PASS |
| SC-12 | No `lib/**`, RuntimeSmoke, report/result/receipt/cache/API/Spark/public mutation | PASS |
| SC-13 | Digest chain complete and stable (SB-14 5 sub-checks) | PASS |
| SC-14 | Tier 0 labeled as legacy fallback only; not sole source authority | PASS |
| SC-15 | `premise_set_digest` and `projection_digest` stable on recompute | PASS |

**Result: 15/15 PASS — no blockers. PASS with 1 informational note.**

---

## Compact PASS/HOLD Table

| Surface | Verdict | Evidence |
|---------|---------|----------|
| Write scope | PASS | 9 files: track doc + harness + summary + 6 source artifacts, all within authorized dir |
| SB-1..SB-15 / 61 checks | PASS | All PASS; sub-check counts match C1-A matrix |
| `sha256:` digest format | PASS | Python: all 6 on-disk artifacts match summary digests |
| `canonical:false` on source refs | PASS | SB-3.source_ref_canonical_false, SB-2.evidence_packet_has_canonical_false, source artifact JSON field |
| Tier 1 is primary source | PASS | 4 proof-owned SemanticIR JSON files; SB-12 confirms Tier 0 not used as projection source |
| `mutable:false` on snapshots | PASS | SB-4.snapshot_ref_has_mutable_false (both snapshots) |
| `assumed_condition_source` required | PASS | SB-5.premise_set_has_required_assumed_condition_source |
| Execution-summary = actual-path only | PASS | `latent_execution:false`, `report_authority:false`, `runtime_authority:false` in JSON |
| `projected_value/failure` disclaimers | PASS | `projected_value_is_not_actual_output:true` on all projections (SB-6) |
| `tbackend_read` refused | PASS | SB-9 (3 checks): `REFUSED_KINDS`, `$LOADED_FEATURES`, behavioral |
| Forbidden vocabulary (projection fields) | PASS | rg matches only in disclaimer note; Python projection-field check: CLEAR |
| lib/ / runtime / public surfaces | PASS | No lib/ requires; SB-15 (6 checks) all PASS |
| Digest chain stable | PASS | SB-14.premise_set_digest_stable, projection_digest_stable, artifact_on_disk_matches |
| Tier 0 labeled legacy | PASS | `tier0.not_sole_proof_authority:true`; `SB-12.tier0_not_used_as_projection_source` |

---

## Detailed Findings

### SC-1: Write Scope

Git history confirms exactly 9 files in the C2-I commit (`23071c42`):
```text
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json
igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/{4 SemanticIR + 2 input snapshot JSONs}
```

Authorized scope (C1-A): `experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/**` and track doc. Exact match. No lib/, spec chapters, proposals, or prior proof evidence files touched.

### SC-2 / SC-3: SB-1..SB-15 and Digest Integrity

All 15 proof groups confirmed in JSON by name. 61/61 PASS.

Critical sub-check verification for source integrity:
- **SB-14.source_artifact_on_disk_digest_matches_computed: PASS** — independently
  confirmed: Python digest verification returned `MATCH` for all 6 artifact files,
  proving the summary digests were computed from the actual on-disk content.
- **SB-14.premise_set_digest_stable_on_recompute: PASS** — digest re-derived
  without the `premise_set_digest` key → same SHA-256.
- **SB-14.projection_digest_stable_on_recompute: PASS** — projection SHA-256
  is stable under re-serialization.
- **SB-14.all_source_ref_digests_have_sha256_prefix: PASS** — format verified.

All 6 source artifact digests from `source_artifact_digests` in JSON:
```
semanticir_risk_gate_v0.json:     sha256:1b163b2e67cd401a...  MATCH
semanticir_nested_if_v0.json:     sha256:7882d992c5f06b32...  MATCH
semanticir_tbackend_v0.json:      sha256:b28add45d22fba8c...  MATCH
semanticir_escape_v0.json:        sha256:0e6832f7ee17f4c2...  MATCH
input_snapshot_risk_gate_v0.json: sha256:5cb2abf582b3ef81...  MATCH
input_snapshot_empty_v0.json:     sha256:8946dda58df33247...  MATCH
```

### SC-4: `canonical:false` Present

Three independent signal points:
1. Source artifact JSON (`semanticir_risk_gate_v0.json`): `"canonical":false`, `"proof_owned":true`
2. SB-2.evidence_packet_has_canonical_false: PASS — the derived evidence packet carries `canonical:false`
3. SB-3.source_ref_canonical_false: PASS — structured `source_branch_intention_ref` carries `canonical:false`
4. Disclaimer: `"source_evidence_not_canonical_schema": true`
5. Claim policy: `"source_ref_equals_compiler_result_field": false`

### SC-5 / SC-14: Tier 1 Primary; Tier 0 Legacy Label

Tier mapping applied:
- Tier 1 (primary): 4 proof-owned SemanticIR-shaped JSON artifacts — `semanticir_risk_gate_v0.json`, `semanticir_nested_if_v0.json`, `semanticir_tbackend_v0.json`, `semanticir_escape_v0.json`
- Tier 0 (legacy): present in `tier0_legacy_fallback` metadata block with `not_sole_proof_authority: true`
- SB-12.tier0_fixture_labeled_as_legacy_fallback: PASS
- SB-12.primary_projections_use_source_backed_refs: PASS
- SB-12.tier0_not_used_as_projection_source: PASS

This correctly implements the S3-R210-C3-X NB-2 binding: Tier 1 citation is
read-only structural bootstrapping; the Tier 0 fallback is explicitly labeled and
not used as a projection source.

### SC-6: Input Snapshot Frozen and No-Authority

Both snapshots verified:
- SB-4.snapshot_ref_has_mutable_false: PASS (both `risk_gate_v0` and `empty_v0`)
- SB-4.snapshot_ref_authority_all_false: PASS
- SB-4.empty_snapshot_ref_also_mutable_false: PASS — the empty snapshot used
  for the unresolved-ref case (SB-7) also carries `mutable:false`

### SC-7: `assumed_condition_source` Required

SB-5.premise_set_has_required_assumed_condition_source: PASS.
This satisfies S3-R210-C3-X NB-3. The enhanced `premise_set` shape:
```json
{
  "kind": "counterfactual_premise_set",
  "assumed_condition": true,
  "assumed_condition_source": "explicit_proof_request",
  "input_snapshot_ref": { "digest": "sha256:...", "mutable": false },
  "assumption_refs": ["risk_threshold_is_valid"],
  "authority": { all false },
  "premise_set_digest": "sha256:..."
}
```

`assumed_condition_source: "explicit_proof_request"` marks the condition flip
as a proof-harness request, not a runtime observation — exactly the disambiguation
required by NB-3.

### SC-8: Execution-Summary Citation = Actual-Path Only

JSON `execution_summary_citation` block:
- `usage: "actual_path_read_only_context"` ✓
- `latent_execution: false` ✓
- `report_authority: false` ✓
- `runtime_authority: false` ✓
- SHA-256 digest present for the R209 summary

SB-11 (4 sub-checks): `r209_execution_summary_ref_is_actual_path_only`,
`r209_execution_summary_ref_has_no_latent_execution`,
`r209_execution_summary_ref_has_no_report_authority`,
`execution_summary_ref_digest_present_when_found` — all PASS.

### SC-9: Projected Value / Failure Disclaimers

The full disclaimer block carries 8 boolean fields:
- `projected_value_is_not_actual_output: true` ✓
- `projected_failure_is_not_actual_failure: true` ✓
- `dry_run_projection_not_public_runtime_support: true` ✓
- `level2_proof_not_public_counterfactual_support: true` ✓
- `source_evidence_not_canonical_schema: true` ✓
- `source_ref_not_compilerresult_or_report_field: true` ✓
- `tier0_fixture_is_legacy_fallback_only: true` ✓
- `assumptions_shaped_refs_not_prop032_extension: true` ✓

This expands the R209 disclaimer block from 7 to 8 fields, adding the new
source-evidence-specific disclaimers. SB-6 checks all PASS.

### SC-10: `tbackend_read` Refused

SB-9 (3 checks): `tbackend_read_produces_projected_failure`,
`no_tbackend_loaded_features`, `tbackend_read_in_refused_kinds` — all PASS.
No live Ledger/TBackend access. R209 refusal behavior preserved.

### SC-11: Forbidden Vocabulary Fenced

rg scan found 2 occurrences of "latent execution" — both in the same location:
the `note` field of `execution_summary_citation`:
```json
"note": "R209 proof summary cited as actual-path context only; not latent execution evidence"
```

This is a negative/disambiguation note (the citation is NOT latent execution
evidence), not a positive projection field name or value. It appears in the
`execution_summary_citation` metadata block, not in any projection envelope.

Python field-level check confirmed: projection fields, disclaimer, and claim_policy
all returned CLEAR for all 17 forbidden terms.

SB-13 (3 checks): `forbidden_vocabulary_absent_from_projection_field_names`,
`forbidden_vocabulary_absent_from_projection_field_values`,
`source_artifacts_do_not_contain_forbidden_terms` — all PASS.

The SB-13 check `source_artifacts_do_not_contain_forbidden_terms` extends the
scan to the source artifact files themselves — an important addition over R209.

### SC-12: Closed Surfaces

- No `lib/` requires (grep confirms empty).
- SB-15 (6 checks): `no_lib_files_loaded`, `no_runtime_smoke_or_compiled_program_loaded`,
  `compiler_result_not_modified`, `compilation_report_not_modified`,
  `no_spec_chapter_modified`, `no_spark_or_public_api_cli_loaded` — all PASS.

### SC-13 / SC-15: Digest Chain and Stability

SB-14 confirms the complete digest chain:
1. Source artifact JSON files on disk → SHA-256 → `source_artifact_digests` ✓
2. `source_branch_intention_ref.source_digest` → matches artifact digest ✓
3. `input_snapshot_ref.digest` → matches snapshot artifact digest ✓
4. `premise_set_digest` → stable re-derivation ✓
5. `projection_digest` → stable re-serialization ✓

This closes the key chain from on-disk artifact → structured ref → projection
envelope, with each link SHA-256 verified. The digest stability proofs mean
the projection envelope can be re-verified against its sources at any future point.

---

## Non-Blocking Note

**NB-1 (informational — rg scan nuance):** The rg forbidden vocabulary scan
found "latent execution" in the `"note"` field of `execution_summary_citation`:
`"not latent execution evidence"`. This is a negative disambiguation
(explaining what the citation is NOT used for). It is not a projection field
name or value; it is metadata within the execution summary citation block.
The SB-13 machine-readable scan correctly returns CLEAR for projection fields.

C4-A should confirm that `"note"` fields within citation metadata blocks are
acceptable locations for disambiguation phrases that name forbidden terms in a
negative context — consistent with the precedent set by R207 `heat-map` footnote
wording ("Level 2 dry-run remains closed") and R209 harness comments. This is
informational only; there is no functional concern.

---

## Verdict

```text
PASS — 15/15 PASS, no blockers, 1 informational note
C4-A may accept proof closure for S3-R211-C2-I
```

S3-R211-C2-I correctly extends R209 from hand-authored concept fixtures to
source-backed proof-owned SemanticIR artifacts. All source refs are SHA-256
digest-addressed with on-disk match verified. `canonical:false` is present at
three independent levels. Tier 0 is explicitly labeled as legacy and not used
as a projection source. `assumed_condition_source` is required (satisfying
S3-R210-C3-X NB-3). Execution-summary citation carries `latent_execution:false`
and is actual-path context only (satisfying S3-R210-C3-X NB-1). The complete
digest chain from artifact → ref → projection → digest is stable. All 61 checks
PASS. All R209 closed surfaces intact.

---

## Mandatory Notes for C4-A

| Note | Required C4-A action |
|------|---------------------|
| NB-1 (informational) | Confirm that `"note"` fields within citation metadata blocks may contain forbidden terms in a negative disambiguation context (not as projection field names/values) |

---

[Agree]
- Write scope exactly matches C1-A: 9 files, all within authorized
  `experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/`.
- All 6 source artifact digests independently verified to match on-disk files.
- `canonical:false` present at three levels: source artifact, evidence packet,
  source ref.
- `assumed_condition_source: "explicit_proof_request"` satisfies R210-C3-X NB-3.
- `execution_summary_citation` correctly carries `latent_execution:false`,
  `report_authority:false`, and `usage: "actual_path_read_only_context"`.
- Tier 0 labeled `not_sole_proof_authority: true` and not used as projection source.
- Digest chain is complete and stable (SB-14, 5 sub-checks, all PASS).
- SB-13 extends vocabulary scan to source artifact files (not just projection fields).
- Disclaimer block expanded to 8 fields, adding source-evidence-specific disclaimers.

[Challenge]
- None.

[Missing]
- NB-1 (informational): Clarify acceptable usage of forbidden terms in negative
  disambiguation note fields within citation metadata blocks.

[Sharper Question]
- The source artifacts are proof-owned SemanticIR-shaped JSON written by the
  harness itself. How does C4-A want future proof routes to handle the case where
  the source artifact is an existing accepted proof output (rather than harness-
  generated)? Does citing an external proof-owned artifact require a different
  `source_kind` value than `proof_derived_from_semanticir`?

[Route]
- accept — C4-A should accept S3-R211-C2-I and close the source-backed proof
  route with the NB-1 clarification noted.

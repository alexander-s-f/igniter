# Branch Conditional Counterfactual Audit Level 2 Source Evidence Boundary Pressure v0

Card: S3-R210-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-source-evidence-boundary-pressure-v0`

---

## Question

Do the S3-R210-C1-D source/evidence boundary design and S3-R210-C2-P1 current
source evidence surface survey correctly fence all new reference shapes against
authority drift, prevent `source_branch_intention_ref` / `input_snapshot_ref` /
`premise_set` from becoming canonical schema or PROP-032 branch syntax, keep
execution-summary evidence as citation-only, and maintain the live runtime
laziness and all closed surfaces from R209?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md` (C1-D)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round209-status-curation-v0.md` (R209 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md` (R209-C4-A)

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Boundary remains design-only; no implementation authority implied | PASS |
| SC-2 | Hand-authored fixtures vs emitted evidence distinction clear | PASS |
| SC-3 | `source_branch_intention_ref` does not become canonical schema | PASS |
| SC-4 | `input_snapshot_ref` does not become cache/dependency authority | PASS |
| SC-5 | `premise_set` does not become PROP-032 branch syntax | PASS |
| SC-6 | Execution-summary evidence does not become report/result/receipt authority | PASS |
| SC-7 | Live runtime remains lazy; non-selected branch live evaluation closed | PASS |
| SC-8 | `tbackend_read` remains refuse-only | PASS |
| SC-9 | Forbidden vocabulary remains fenced | PASS |
| SC-10 | Public/runtime/counterfactual/demo claims remain closed | PASS |
| SC-11 | Spark/API/CLI remain closed | PASS |

**Result: 11/11 PASS — no blockers. PASS with 3 non-blocking notes for C4-A.**

---

## Compact PASS/HOLD Table

| Surface | Verdict | Notes |
|---------|---------|-------|
| Design-only; no implementation authority | PASS | Both cards explicitly defer all authorization to a future gate |
| Tier model (hand-authored vs emitted distinction) | PASS | Tier 0/1/2/3/4 defined; Tier 0 = concept proof legacy; Tier 3/4 closed |
| `source_branch_intention_ref` non-canonical | PASS | `"canonical": false` explicit field; forbidden source_kind list covers report/result/receipt/API/production |
| `input_snapshot_ref` no cache/dep authority | PASS | Authority block `runtime_input_authority: false`, `production_authority: false`, `public_claim: false` |
| `premise_set` not PROP-032 syntax | PASS | `assumption_refs` = proof-local labels only; no branch-level `uses assumptions`; PROP-032 not amended |
| Execution-summary = citation only | PASS | "citation source, not a new report surface"; forbidden mutations listed for CompilerResult/Report/receipts/CompatibilityReport |
| Live runtime laziness | PASS | Governing principle repeated; Tier 4 = closed |
| `tbackend_read` refuse-only | PASS | Future proof matrix requires `projected_failure` for tbackend_read; no non-refusal behavior proposed |
| Forbidden vocabulary fenced | PASS | No forbidden terms introduced as positive vocabulary in either card |
| Public/runtime/demo closed | PASS | Forbidden promotion paths list covers all relevant surfaces |
| Spark/API/CLI closed | PASS | Both cards close explicitly; C2-P1 direct answer: "Yes" |

---

## Detailed Findings

### SC-1: Design-Only, No Implementation Authority

C1-D: "This is design-only. It authorizes no proof, implementation, docs/spec
edit, runtime behavior, report/result shape, public API/CLI, or public claim."
C2-P1: "this was a read-only survey plus this track doc." Neither card writes
any code, spec, or docs outside its own track doc.

### SC-2: Hand-Authored vs Emitted Evidence Distinction

C1-D's tier model is the key structural control:

| Tier | Status |
|------|--------|
| 0 — Hand-authored fixture | Concept proof legacy only; not main source for source-backed proof |
| 1 — Compiler/SemanticIR | Preferred next source |
| 2 — Execution summary | Optional read-only actual-path citation |
| 3 — Report/result/receipt | Closed |
| 4 — Live runtime / production | Closed |

The distinction between Tier 0 (R209 legacy) and Tier 1 (preferred forward path)
is explicit. C2-P1 confirms no current emitted artifact already records the full
structured `source_branch_intention_ref` + `input_snapshot_ref` + `premise_set`
+ digest trace. The gap analysis is honest and correctly motivates a new
source-backed proof route rather than recycling existing artifacts.

### SC-3: `source_branch_intention_ref` Non-Canonical

The structured ref shape includes an explicit `"canonical": false` field. The
forbidden `source_kind` list enumerates the forbidden promotion paths:
`compilation_report_field`, `compiler_result_field`, `receipt_field`,
`compatibility_report_field`, `public_api_object`, `runtime_output`,
`production_observation`.

These forbidden values map exactly to the closed report/result/receipt/API
surfaces from R209. The field is a non-canonical evidence pointer, not a
compiler artifact. C2-P1 independently confirms the current Level 1 summary is
the "strongest existing branch-intention-shaped evidence" but lacks the
structured ref fields — correctly framing the gap without over-claiming.

### SC-4: `input_snapshot_ref` No Cache/Dependency Authority

The recommended proof-local shape carries an explicit authority block:
```json
"authority": {
  "runtime_input_authority": false,
  "production_authority": false,
  "public_claim": false
}
```

Production input is explicitly closed: "Production input record: Closed —
Requires separate privacy/runtime/production authority." The `mutable: false`
field prevents drift toward treating snapshots as live runtime inputs. C2-P1
confirms no current artifact provides a suitable frozen input snapshot with the
required authority block.

### SC-5: `premise_set` Not PROP-032 Branch Syntax

C1-D is explicit: "`assumption_refs` may be assumptions-shaped refs, but only
as proof-local premise labels. They do not create branch-level `uses assumptions`,
do not amend PROP-032, and do not become receipt `assumption_refs`."

The `premise_set` authority block in the recommended shape covers:
`runtime_authority: false`, `dependency_authority: false`, `cache_authority:
false`, `report_authority: false`, `public_claim: false`. Five fields,
consistent with the R209 authority block (4 fields + public_claim). PROP-032 is
not listed as a write target in either card.

### SC-6: Execution-Summary Evidence = Citation Only

C1-D: "Execution-summary evidence must be treated as a citation source, not as a
new report surface." Forbidden uses explicitly list:
- latent branch execution evidence
- mutation of RuntimeSmoke result shape
- mutation of CompilerResult or CompilationReport
- mutation of receipts or CompatibilityReport
- public runtime/counterfactual support claims
- production observation claims

C2-P1's safety analysis: "Do not use these as source authority for Level 2
counterfactual projections: `CompilerResult.report`, `CompilerResult.public_result`,
runtime smoke fields, or CLI/API result output; `CompilationReport` diagnostics,
stages, persisted report paths, or refusal reports; CompatibilityReport fields,
load/evaluation readiness, runtime trusted status..." Both cards are consistent.

### SC-7 / SC-8: Live Runtime Laziness and `tbackend_read`

The governing principle is repeated in C1-D:
```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
```

Tier 4 (live runtime/production execution) is closed. The future proof minimum
matrix in C1-D explicitly requires "produce `projected_failure` for unresolved
snapshot, effect/escape, and `tbackend_read`" — confirming `tbackend_read`
remains refuse-only in the next source-backed proof. The R209 REFUSED_KINDS
behavior is inherited, not relaxed.

C2-P1's runtime evaluator proof summary note: confirms "non-selected branch must
not be live-evaluated" — consistent with both cards.

### SC-9: Forbidden Vocabulary Fenced

Neither C1-D nor C2-P1 introduces any of the 17 forbidden terms as positive
vocabulary. C1-D uses the established guarded Level 2 vocabulary throughout:
`projected_value`, `projected_failure`, `premise_set`, `isolation_guarantee`,
`dry_run_projection`. No would_*, counterfactual result/output/failure, latent
runtime value/failure, latent execution, simulated branch result, branch replay,
symbolic_execution, causal_estimate, or alternate_actual_output appears as a
proposed field name.

The `assumed_condition_source` field introduced by C1-D is new vocabulary — but
it is not a forbidden term and correctly marks the condition flip as an
"explicit_proof_request" rather than an observed runtime value. This is an
appropriate addition.

### SC-10 / SC-11: Public/Runtime/Demo/Spark/API/CLI Closure

C1-D "Forbidden Promotion Paths" covers all required surfaces: SemanticIR schema,
TypeChecker schema, RuntimeSmoke output contract, CompilerResult field,
CompilationReport field, receipt field, CompatibilityReport field, `.igapp`
artifact schema, public API/CLI object, release evidence rewrite, production
runtime behavior, Spark evidence or demo behavior. These match the R209 closed
surfaces exactly.

C2-P1 direct answer: "Do Spark/API/CLI remain out of scope? Yes."

---

## Non-Blocking Notes (Mandatory for C4-A)

**NB-1 (C4-A decision required — open questions from C2-P1):**

C2-P1 explicitly surfaces two open questions that require C4-A resolution before
the source-backed proof authorization review opens:

1. Should the next proof derive `source_branch_intention` evidence from
   SemanticIRProgram JSON, proof-owned `.igapp` contract JSON, or both?
2. What minimum digest/ref convention should C4-A require for `input_snapshot_ref`
   and `premise_set_ref`?

These are not blockers at the design stage, but C4-A must answer them when
authorizing the next proof route (analogous to how R206-C4-A specified the Option
A target set before R207-C1-I could proceed). Without explicit C4-A choices here,
the source-backed proof authorization card will have to make assumptions that may
not match Architect intent.

Recommendation: C4-A should specify (a) preferred source artifact type
(SemanticIRProgram JSON as primary, `.igapp` contract JSON as secondary) and
(b) minimum digest convention (SHA-256 hex string, same form as accepted proof
SHAs throughout this lane).

**NB-2 (Tier 1 authority ceiling — clarification for C4-A):**

C1-D's tier model says Tier 1 (compiler/SemanticIR) is the "Preferred next proof
source." A future card could potentially claim that referencing a Tier 1 artifact
elevates the projection above "proof-local only" toward compiler evidence. C4-A
should explicitly record that Tier 1 evidence is read-only structural citation
only — it does not promote branch-intention descriptors to canonical compiler
output, does not change SemanticIR schema, and does not make the projection
envelope a compiler artifact.

Suggested binding language for C4-A: "Tier 1 source citation is evidence
bootstrapping only; the derived branch-intention evidence packet remains
proof-local and non-canonical regardless of which Tier 1 artifact it was derived
from."

**NB-3 (precision — `assumed_condition_source` as required field):**

C1-D's expanded `premise_set` shape introduces a new field:
```json
"assumed_condition_source": "explicit_proof_request"
```

The R209 concept proof used `assumed_condition: true/false` without this source
qualifier. The addition is correct and important — it makes explicit that the
condition flip is a proof-harness request, not a reported observation. However,
C1-D presents it without stating whether it is optional or required.

C4-A should make `assumed_condition_source` a required field in the source-backed
proof matrix, with allowed values limited to `explicit_proof_request` (for
purely hypothetical flips) and `execution_summary_observation` (for dry-runs
where the actual condition is known from a proof-owned execution summary). This
prevents a future proof from leaving the condition source implicit, which could
be misread as inferring the condition from live runtime context.

---

## Verdict

```text
PASS with 3 non-blocking notes
11/11 PASS, no blockers
C4-A may accept design and authorize a source-backed proof authorization review,
with NB-1/NB-2/NB-3 resolved as binding constraints on that authorization.
```

The source/evidence boundary is correctly designed. All new reference shapes carry
explicit non-canonical labels and authority blocks. The tier model cleanly
separates concept-proof legacy artifacts from the preferred emitted evidence path.
No existing report/result/receipt/CompatibilityReport/cache surface is opened. The
governing principle and forbidden promotion paths carry through from R209 without
drift.

---

## Mandatory Notes for C4-A

**Required before source-backed proof authorization opens:**

| Note | Required C4-A action |
|------|---------------------|
| NB-1a | Choose preferred source artifact type for `source_branch_intention_ref`: SemanticIRProgram JSON vs `.igapp` contract JSON |
| NB-1b | Specify minimum digest convention for `input_snapshot_ref` and `premise_set_ref` |
| NB-2 | Record binding Tier 1 authority ceiling: read-only structural citation only; no promotion to canonical compiler output |
| NB-3 | Make `assumed_condition_source` a required field; specify allowed values (`explicit_proof_request`, `execution_summary_observation`) |

---

[Agree]
- The tier model is a clean architectural contribution: it separates concept
  proof legacy (Tier 0), preferred source evidence (Tier 1/2), and closed
  surfaces (Tier 3/4) in a single table without ambiguity.
- `"canonical": false` as an explicit field on `source_branch_intention_ref`
  is the right structural choice — non-canonicality is asserted, not implied.
- `assumed_condition_source` is a positive addition over the R209 design.
- C2-P1 correctly identifies that no current artifact fully records the
  structured ref + snapshot + premise + digest chain — this is an honest gap
  analysis, not a claim of existing support.
- The forbidden `source_kind` list on `source_branch_intention_ref` exactly
  mirrors the closed report/result/receipt/API surfaces from R209.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1: C4-A must choose source artifact type and digest convention before
  authorizing the source-backed proof route.
- NB-2: Explicit Tier 1 authority ceiling should be recorded as binding policy.
- NB-3: `assumed_condition_source` should be required (not optional) in the
  source-backed proof matrix, with enumerated allowed values.

[Sharper Question]
- When the source-backed proof derives a `source_branch_intention_evidence_packet`
  from a proof-owned SemanticIR JSON, what makes that derivation proof-local
  rather than a SemanticIR schema extension? The answer is the digest + `canonical:
  false` pattern — but C4-A should make this derivation rule explicit to prevent
  future cards from treating a SemanticIR-derived packet as a schema change.

[Route]
- accept with notes — C4-A should accept C1-D and C2-P1 and authorize a
  source-backed proof authorization review, with NB-1/NB-2/NB-3 resolved as
  binding constraints.

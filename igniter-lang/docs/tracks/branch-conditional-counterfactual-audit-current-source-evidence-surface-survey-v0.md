# Branch Conditional Counterfactual Audit Current Source Evidence Surface Survey v0

Card: S3-R210-C2-P1
Agent: [Research Agent #1]
Role: research-agent
Track: branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0
Route: UPDATE
Depends on: S3-R209-C5-S
Status: done
Date: 2026-05-30

## Role And Neighbors

Assigned track: read-only source evidence surface survey for future Level 2
counterfactual dry-run projections.

Affected neighbor roles:
- Compiler/Grammar Expert: compiler, TypeChecker, SemanticIR, and if_expr
  proof artifact boundaries.
- Bridge/Runtime owners: RuntimeSmoke, proof RuntimeMachine,
  CompilerResult/CompilationReport, CompatibilityReport, cache, receipt, and
  report authority boundaries.
- Research Agent lanes: branch-intention, counterfactual audit, and release
  harness proof-summary traceability.

## Current Horizon

- R209 accepted proof-local Level 2 dry-run concept evidence only.
- R210 C1-D defines the preferred next move as source/evidence-backed, not
  report/result-backed.
- Current evidence is split across Level 1 branch-intention summaries,
  if_expr compiler/SemanticIR proofs, proof-owned .igapp contract JSON, and
  runtime smoke/evaluator summaries.
- No current emitted artifact records the full source branch intention,
  input snapshot, premise set, and no-authority envelope together.
- Report/result/receipt/cache/CompatibilityReport authority remains closed.

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round209-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-v0.md`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/branch_conditional_counterfactual_audit_concept_proof_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/out/branch_conditional_if_expr_v0_implementation_proof_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/semanticir_branch_shape_model.json`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/branch_conditional_if_expr_runtime_evaluator_proof_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json`
- `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/out/branch_conditional_if_expr_release_harness_delta_summary.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- targeted `rg` scans for `if_expr`, `branch_conditional`, `compiler_release_acceptance`, and `CompatibilityReport`.

## Candidate Source Evidence Map

| Surface | Path | Current available fields | Useful for | Missing for source-backed Level 2 | Authority status |
| --- | --- | --- | --- | --- | --- |
| Level 1 branch-intention proof summary | `experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/...summary.json` | `if_expr_id`, `intention_source`, condition actual value/source, branch labels/roles, evaluated flag, expr kind, resolved type, static refs, assumption refs, non-execution guarantee, authority flags | Strongest existing branch-intention-shaped evidence | source path/digest, emitted artifact derivation, structured `source_branch_intention_ref`, frozen `input_snapshot_ref`, digest-addressed `premise_set_ref` | Proof-local only; no report/API/runtime authority |
| Level 2 dry-run summary | `experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/...summary.json` | projection summaries, bare `source_branch_intention_ref`, projected branch/value/failure presence, isolation and authority clean checks | Accepted envelope/disclaimer precedent | detailed premise set in summary, structured source refs, source digest, input snapshot object | Proof-local only; no authority |
| R210 source/evidence design | `docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-design-v0.md` | target shapes for `source_branch_intention_ref`, `input_snapshot_ref`, `premise_set`, allowed/forbidden source kinds | Normative local design guidance for next proof | not evidence, no generated artifacts | Design-only |
| if_expr implementation proof summary | `experiments/branch_conditional_if_expr_v0_implementation_proof/out/...summary.json` | TypeChecker if_expr acceptance, OOF-IF diagnostics, typed if_expr shape, SemanticIR shape, deps, nested cases | Compiler-backed shape and diagnostic evidence | branch role/intention, observed condition value, input snapshot, premise set, no-authority envelope | Compiler proof evidence only |
| SemanticIR branch shape model | `experiments/branch_conditional_if_expr_semantics_proof_v0/out/semanticir_branch_shape_model.json` | modeled `if_expr`, condition, then/else branches, resolved type, deps | Static shape sketch for source derivation | emitted canonical artifact link, branch roles, input snapshot, premise set | Modeled proof data only |
| Proof-owned if_expr .igapp contract JSON | `experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/rs-if-proof-v0/igapps/**/contracts/*.json` | contract JSON with `if_expr`, condition, `then_branch`, `else_branch` | Read-only static branch structure source for a future proof-local derivation | intention descriptor, source digest/ref, input snapshot, premise set, authority block | Proof-owned artifact; not production schema authority |
| Runtime smoke consumer summary | `experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/out/...summary.json` | load/evaluate result shape, `compatibility_report_status`, outputs, trusted/load/eval status keys | Actual selected-path smoke context and closed-surface evidence | latent branch evidence, structured source refs, input snapshot, premise set | Smoke evidence only; not counterfactual authority |
| Runtime evaluator proof summaries | `experiments/branch_conditional_if_expr_runtime_evaluator_proof_v0/out/...summary.json`, `experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0/out/...summary.json` | selected-branch-only laziness, condition then selected branch evaluation order, supported expression kinds, no public integration | Confirms non-selected branch must not be live-evaluated | source evidence refs and result/report/counterfactual envelope | Internal/proof-local runtime evidence only |
| Release harness summaries | `experiments/compiler_release_acceptance_harness_v0/out/...summary.json`, `experiments/branch_conditional_if_expr_release_harness_delta_v0/out/...summary.json` | release-scope status and non-claims; release delta PASS 39/39 | Guard against public/release overclaiming | no source branch evidence, no dry-run projection inputs | Release evidence boundary only |
| `CompilerResult` source | `lib/igniter_lang/compiler_result.rb` | public result key filtering, ok/refusal/strict terminal shapes, optional runtime smoke payload | Identifies closed result boundary and future risk | no branch-intention or premise-set fields | Closed for Level 2 source authority |
| `CompilationReport` source | `lib/igniter_lang/compilation_report.rb` | parse/runtime/internal/profile validation report helpers | Identifies closed report boundary and no current branch/counterfactual fields | all Level 2 source fields | Closed for Level 2 source authority |
| CompatibilityReport proof/docs references | targeted `rg` across docs/experiments | report-only/load-readiness precedents, runtime smoke compatibility status fields | Closed-surface context | no branch-intention or dry-run source packet | Closed; must not become Level 2 authority |

## Field Gap Summary

`source_branch_intention_ref`:
- Current Level 1 summaries have the useful core: `if_expr_id`, branch labels,
  branch roles, evaluated flags, condition evidence, static refs, and authority
  disclaimers.
- Current Level 2 summaries use a bare string ref such as
  `if:risk_gate_true/latent_else`.
- Missing for a source-backed proof: structured `kind`, `source_kind`,
  `source_path`, `source_digest`, `if_expr_id`, `branch_label`,
  `branch_role`, `derivation`, `canonical:false`, and an evidence trace to the
  exact proof-owned compiler/SemanticIR artifact.

`input_snapshot_ref`:
- Current runtime smoke and evaluator summaries prove selected-path behavior,
  but do not expose a frozen input snapshot object suitable for Level 2 source
  evidence.
- Missing: proof-local input packet path, digest, `mutable:false`, source kind,
  and explicit `authority:false`.

`premise_set`:
- R209 concept proof requires a premise set and asserts it exists, but the
  compact summary does not expose a digest-addressed `premise_set_ref`.
- Missing: explicit premise-set object/ref containing assumed condition source,
  input snapshot ref, assumption refs, dry-run-only policy, and no-authority
  flags.

## Unsafe Or Closed Surfaces

Do not use these as source authority for Level 2 counterfactual projections:
- `CompilerResult.report`, `CompilerResult.public_result`, runtime smoke fields,
  or CLI/API result output.
- `CompilationReport` diagnostics, stages, persisted report paths, or refusal
  reports.
- CompatibilityReport fields, load/evaluation readiness, runtime trusted status,
  or temporal/descriptor report-only metadata.
- Receipt, cache, dependency tracker, call trace, Ledger/TBackend, or runtime
  observation surfaces.
- Proof-owned .igapp manifests/contracts as production authority. They may be
  read as proof-local static branch structure only.
- Release harness summaries as feature support claims. They are useful only as
  non-claim and closed-surface guards.
- Spark, external API, public CLI/API widening, production runtime, or public
  docs claims.

## Explicit Answers

Does any current emitted artifact already record enough branch-intention source
evidence?

No. Existing artifacts and summaries provide strong pieces: branch-intention
proof data, compiler/SemanticIR if_expr shape, proof-owned contract JSON, and
selected-branch runtime evidence. None records the full structured
`source_branch_intention_ref` plus frozen `input_snapshot_ref`, explicit
`premise_set`, digest trace, and no-authority envelope.

Are current proof summaries enough for a source-backed proof?

They are enough to seed the next proof and cite accepted behavior, but not
enough by themselves to close a source-backed proof. The next proof should
derive a new proof-local branch-intention evidence packet from an existing
proof-owned SemanticIR/contract JSON artifact and freeze it with a digest.

Can execution summaries be used without result/report authority?

Yes, narrowly. They can be cited as read-only proof evidence for actual selected
branch behavior or input/output smoke context if frozen and digest-addressed.
They must not become `CompilerResult`, `CompilationReport`, CompatibilityReport,
receipt, cache, or runtime authority.

Do report/result/receipt/cache authority remain closed?

Yes. This survey found no accepted opening for report/result/receipt/cache
authority in Level 2 counterfactual dry-run projections.

Do Spark/API/CLI remain out of scope?

Yes. Spark, public API/CLI exposure, release/demo claims, and production
runtime behavior remain out of scope for this lane.

## Safest Next Proof-Local Route

Recommended next route for C4-A:

`branch-conditional-counterfactual-audit-level2-source-backed-proof-v0`

Bounded proof shape:
1. Read one proof-owned if_expr contract JSON or SemanticIR artifact from the
   current branch-conditional proof outputs.
2. Compute a digest and derive a proof-local
   `source_branch_intention_evidence_packet`.
3. Read a frozen proof-local input snapshot fixture and compute its digest.
4. Build an explicit `premise_set` object with no-authority flags.
5. Emit a Level 2 dry-run projection that references only those proof-local
   evidence refs.
6. Preserve the R209 isolation envelope and closed-surface scans.

Do not route through `CompilerResult`, `CompilationReport`, CompatibilityReport,
CLI/API output, release harness result, receipt, cache, runtime observation,
Spark, or production data.

## Command Matrix

Read-only evidence commands used:

| Command | Result |
| --- | --- |
| `rg "if_expr\|branch_conditional\|compiler_release_acceptance\|CompatibilityReport\|compatibility_report" igniter-lang/docs igniter-lang/experiments -g "*.md" -g "*.json"` | PASS, broad evidence scan |
| `find igniter-lang/experiments -path '*compiler_release*summary.json' -maxdepth 5 -type f` | PASS, release summary inventory |
| `find igniter-lang/experiments -path '*branch_conditional*summary.json' -maxdepth 5 -type f` | PASS, branch proof summary inventory |
| `ls igniter-lang/docs/tracks \| rg 'branch-conditional\|counterfactual\|if-expr\|release.*harness\|compatibility'` | PASS, related track inventory |
| `ruby -rjson -e ... branch_conditional_if_expr_release_harness_delta_summary.json` | PASS, release delta summary sampled |
| `ruby -rjson -e ... compiler_release_acceptance_harness_summary.json` | PASS, release harness status sampled |
| `ruby -rjson -e ... branch_conditional_if_expr_runtime_evaluator_proof_summary.json` | PASS, runtime evaluator summary sampled |

No code/proof test was required or run; this was a read-only survey plus this
track doc.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Research Agent

[D] Decisions:
- Current evidence is sufficient to design a source-backed proof, but not enough
  to claim one already exists.
- No existing emitted artifact fully records structured source_branch_intention_ref,
  input_snapshot_ref, premise_set, digest trace, and no-authority envelope.
- Result/report/receipt/cache/CompatibilityReport authority remains closed.

[R] Recommendations:
- Authorize a narrow proof-local source-backed Level 2 route that derives a
  branch-intention evidence packet from proof-owned if_expr SemanticIR/contract
  JSON plus a frozen input snapshot fixture.
- Keep CompilerResult, CompilationReport, CompatibilityReport, receipts, cache,
  CLI/API, Spark, and production data out of the source-authority path.

[S] Signals:
- Level 1 branch-intention summary is the strongest current intention evidence.
- if_expr compiler and SemanticIR proofs provide branch shape and diagnostic
  evidence.
- Runtime smoke/evaluator summaries are useful only as closed-surface and
  selected-path context.

[T] Tests / Proofs:
- Read-only survey commands PASS; no executable proof required.

[Files] Changed:
- igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md

[Q] Open Questions:
- Should the next proof derive source_branch_intention evidence from
  SemanticIRProgram JSON, proof-owned .igapp contract JSON, or both?
- What minimum digest/ref convention should C4-A require for the input snapshot
  and premise set?

[X] Rejected:
- Treating CompilerResult, CompilationReport, CompatibilityReport, release
  harness summaries, receipts, cache, Spark, or production runtime output as
  Level 2 counterfactual source authority.

[Next] Proposed next slice:
- branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
```

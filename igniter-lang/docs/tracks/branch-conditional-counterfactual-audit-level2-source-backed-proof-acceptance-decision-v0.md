# Branch Conditional Counterfactual Audit Level 2 Source-Backed Proof Acceptance Decision v0

Card: S3-R211-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0  
Route: UPDATE  
Status: done / accepted-source-backed-proof-local-level2-evidence  
Date: 2026-05-30

Depends on:
- S3-R211-C2-I
- S3-R211-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-level2-source-backed-proof-pressure-v0.md`
- `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json`
- `igniter-lang/docs/tracks/stage3-round210-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`

Additional local read:

```bash
git show --name-only --oneline --no-renames 23071c42
```

---

## Decision

Decision:

```text
accept proof-local source-backed Level 2 counterfactual dry-run proof
accept SB-1..SB-15 / 61 checks PASS
accept C3-X pressure verdict: PASS 15/15, no blockers, 1 informational note
accept generated output as source-backed proof-local Level 2 counterfactual dry-run evidence only
do not promote source-backed projection envelope to canonical schema/report/API/runtime surface
keep live runtime lazy and public/runtime/report/cache/API/Spark authority closed
```

R211 closes the next maturity step after R209/R210: Level 2 projection evidence
is no longer only hand-authored concept-fixture evidence. It is now backed by
proof-owned SemanticIR-shaped source artifacts, SHA-256 digest-addressed refs,
frozen input snapshots, and explicit premise sets.

The governing principle remains:

```text
Runtime is lazy.
Audit is aware.
Dry-run, if ever accepted, must be isolated.
Evidence must be sourced before it can be explained.
```

---

## Accepted Changed Files

C2-I primary commit:

```text
23071c42 docs(igniter-lang): document S3-R211-C2-I Level 2 source-backed proof concept
```

Accepted changed files:

| File | Acceptance status |
| --- | --- |
| `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md` | Accepted proof track doc. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb` | Accepted experiment-local source-backed proof harness. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json` | Accepted proof summary, 61/61 PASS. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/input_snapshot_empty_v0.json` | Accepted proof-local frozen input snapshot artifact. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/input_snapshot_risk_gate_v0.json` | Accepted proof-local frozen input snapshot artifact. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/semanticir_escape_v0.json` | Accepted proof-owned SemanticIR-shaped source artifact. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/semanticir_nested_if_v0.json` | Accepted proof-owned SemanticIR-shaped source artifact. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/semanticir_risk_gate_v0.json` | Accepted proof-owned SemanticIR-shaped source artifact. |
| `igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/source_artifacts/semanticir_tbackend_v0.json` | Accepted proof-owned SemanticIR-shaped source artifact. |

No `lib/**`, spec chapter, PROP-032, RuntimeSmoke, proof RuntimeMachine,
report/result/receipt/CompatibilityReport, public API/CLI, Spark, or accepted
R209/R210 evidence file change is accepted.

---

## Command Matrix Result

Accepted C2-I command matrix:

```text
ruby -c igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
=> PASS branch_conditional_counterfactual_audit_level2_source_backed_proof_v0
=> checks_total=61 checks_pass=61 checks_fail=0
```

Accepted proof summary:

```text
status: PASS
checks_total: 61
checks_pass: 61
checks_fail: 0
```

C3-X pressure result:

```text
PASS -- 15/15 PASS, no blockers, 1 informational note
```

---

## SB Matrix Status

| ID | Result | Checks | Acceptance note |
| --- | --- | ---: | --- |
| SB-1 | PASS | 4 | Source artifacts loaded/read as proof-owned evidence only. |
| SB-2 | PASS | 5 | `source_branch_intention_evidence_packet` derived from source artifact with `canonical:false`. |
| SB-3 | PASS | 5 | `source_branch_intention_ref` structured and digest-addressed. |
| SB-4 | PASS | 4 | Frozen `input_snapshot_ref` digest-addressed and no-authority. |
| SB-5 | PASS | 5 | `premise_set_ref` digest-addressed with required `assumed_condition_source` and authority false fields. |
| SB-6 | PASS | 4 | Pure latent branch produces `projected_value`, not actual output. |
| SB-7 | PASS | 4 | Unresolved snapshot produces `projected_failure`, not actual failure. |
| SB-8 | PASS | 3 | Effect/escape/external IO refused with no side effect. |
| SB-9 | PASS | 3 | `tbackend_read` refused; no live Ledger/TBackend read. |
| SB-10 | PASS | 3 | Nested `if_expr` projection remains lazy inside isolated dry-run. |
| SB-11 | PASS | 4 | Execution-summary citation remains actual-path read-only context only. |
| SB-12 | PASS | 3 | Hand-authored fixture is Tier 0 legacy fallback only, not sole authority. |
| SB-13 | PASS | 3 | Forbidden vocabulary scan passes. |
| SB-14 | PASS | 5 | Source/digest chain is complete and stable. |
| SB-15 | PASS | 6 | Closed-surface scan passes. |

Total:

```text
checks_total: 61
checks_pass: 61
checks_fail: 0
```

---

## Source Artifact Status

Accepted source artifact posture:

- Tier 1 primary source is proof-owned SemanticIR-shaped JSON under the
  experiment `out/source_artifacts/` directory.
- Four SemanticIR-shaped source artifacts are accepted for proof-local source
  derivation.
- Two frozen input snapshots are accepted as proof-local input evidence.
- All six source artifact digests independently match on-disk SHA-256 content,
  per C3-X verification.
- These artifacts are proof-owned evidence, not SemanticIR schema, not `.igapp`
  artifact schema, not production artifact, and not public API.

Accepted source artifact digests:

```text
semanticir_risk_gate_v0.json     sha256:1b163b2e67cd401af0c861b807d6c9b4c9dfaaf5ff3fd01f30546c7f8e32a2ce
semanticir_nested_if_v0.json     sha256:7882d992c5f06b32952cc589c6af8d1b124882ab63bfb656b0c2dd2d058fea2e
semanticir_tbackend_v0.json      sha256:b28add45d22fba8c5c3d8f2454c9a388b319df98fafbf0ca79d3e5126afd2a9b
semanticir_escape_v0.json        sha256:0e6832f7ee17f4c2ff5af3a10690d45d4860706d47cb9ab2f53df7b10347d246
input_snapshot_risk_gate_v0.json sha256:5cb2abf582b3ef817eb0fc9ef19e59e0ea58dc51abad3a786683a3440a9818af
input_snapshot_empty_v0.json     sha256:8946dda58df33247104aee916d69b447cc3488ac5368236c00b9a39af3e4cec7
```

---

## Digest Chain Status

Accepted:

- all source refs use `sha256:<hex>`;
- source artifact on-disk digests match summary digests;
- `source_branch_intention_ref.source_digest` matches artifact digest;
- `input_snapshot_ref.digest` matches snapshot artifact digest;
- `premise_set_digest` is stable on recompute;
- `projection_digest` is stable on recompute.

Accepted projection digests:

```text
proj_a_risk_gate_then_branch sha256:d586b79e53f3cee91f2cf07fc97c380df9b34dd86aceb55f9ecab79c1daf9c61
proj_b_unresolved_snapshot   sha256:1b5c2a1d43452dc0ad5647b7a97ef998b58def8cc51e865a139ed4e9ab721d0b
proj_c_nested_if_expr        sha256:e015a96e45d80aa84558f215a12ceddf043649f0bd3a9b5276a76456ab915abd
proj_d_tbackend_refused      sha256:e9ed0cf9652d9b13360af39f7e8dcbe0049493e94757770d691f2e501ad331d8
proj_e_escape_refused        sha256:0e9817701b3bac80d006e5139f8e79c919a65c1dfbb6ef43a2fb5ac0dac827ce
```

---

## Evidence Ref Status

Accepted `source_branch_intention_ref` status:

- structured;
- digest-addressed;
- `canonical:false`;
- `derivation: proof-local`;
- source kind derived from proof-owned SemanticIR-shaped artifact;
- authority fields false.

Accepted `input_snapshot_ref` status:

- frozen;
- `mutable:false`;
- digest-addressed;
- authority fields false;
- empty snapshot also frozen and no-authority.

Accepted `premise_set` status:

- explicit;
- digest-addressed;
- includes `assumed_condition`;
- includes required `assumed_condition_source`;
- uses `explicit_proof_request` for the source-backed proof;
- authority fields false;
- assumptions-shaped refs remain proof-local labels only.

Accepted execution-summary citation status:

- R209 summary cited only as actual-path read-only context;
- `latent_execution:false`;
- `report_authority:false`;
- `runtime_authority:false`;
- not latent branch evidence;
- not report/result/receipt/cache authority.

---

## Projection Envelope Status

Accepted maximum claim:

```text
Proof-local source-backed Level 2 counterfactual dry-run concept evidence:
branch-intention evidence derived from proof-owned SemanticIR-shaped source
artifacts with SHA-256 digest-addressed refs, frozen input snapshots, and
explicit premise_sets, evaluated inside an experiment-local isolated projection
envelope with no-authority disclaimers.
```

Binding non-equivalences:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
source evidence from proof-owned SemanticIR-shaped artifacts != canonical schema
source_branch_intention_ref != CompilerResult or CompilationReport field
dry_run_projection != public_runtime_support
Level2_source_backed_proof != public_counterfactual_support
Tier 0 hand-authored fixtures are legacy fallback only; not primary source authority
Assumptions-shaped premise refs are proof-local labels only; not PROP-032 branch syntax or receipt assumption_refs
```

Generated output may be called only:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

It must not be called public/runtime/report/API support.

---

## Refusal And Vocabulary Status

Accepted `tbackend_read` status:

- `tbackend_read` produces `projected_failure`;
- no live Ledger/TBackend read occurs;
- `tbackend_read` remains refused in dry-run projection;
- any non-refusal behavior requires a separate temporal/runtime gate.

Accepted forbidden vocabulary status:

- projection fields are clear;
- projection field values are clear;
- source artifacts are clear;
- C3-X rg found `latent execution` only in an execution-summary citation
  metadata note in negative disambiguation context.

Informational note accepted:

```text
Citation metadata note fields may name forbidden terms only in a negative
disambiguation context. They remain forbidden as positive projection field
names, projection values, canonical vocabulary, public claims, or feature
labels.
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is source-backed proof-local Level 2 evidence accepted? | Yes. Accepted. |
| May generated output be called source-backed proof-local Level 2 counterfactual dry-run evidence only? | Yes. |
| Is this public/runtime/report/API support? | No. |
| Does live runtime remain lazy? | Yes. Non-selected branch live evaluation remains closed. |
| Does report/result/receipt/cache authority remain closed? | Yes. |
| Do Spark/API/CLI remain closed? | Yes. |

---

## Next Route

Immediate status handoff:

```text
Card: S3-R211-C5-S
Agent: [Status Curator]
Role: status-curator
Track: stage3-round211-status-curation-v0
Route: UPDATE
Depends on:
- S3-R211-C1-A
- S3-R211-C2-I
- S3-R211-C3-X
- S3-R211-C4-A
```

Recommended next Main Line route after C5-S:

```text
Card: S3-R212-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0
Route: UPDATE
Depends on:
- S3-R211-C5-S
```

Goal:

```text
Design-only boundary for documenting the accepted source-backed Level 2
proof-local evidence vocabulary: what may be named in internal docs/status,
what remains non-canonical, and how to explain source-backed Level 2 without
claiming public runtime/report/API support or live non-selected branch
evaluation.
```

Rationale:

R211 proves the source-backed evidence chain. The next safe step is not runtime
integration. It is a narrow vocabulary/spec boundary so future agents and
readers can distinguish:

- Level 1 branch intention;
- Level 2 isolated dry-run projection;
- Level 2 source-backed proof-local evidence;
- public/runtime/report/API support, which remains closed.

---

## Remaining Closed Surfaces

Remain closed after R211:

- live implementation;
- `lib/**`;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- proof RuntimeMachine changes;
- live non-selected branch evaluation;
- effect execution;
- external IO;
- persistence;
- Ledger/TBackend live reads/writes;
- `tbackend_read` non-refusal behavior;
- dependency/cache authority;
- `CompilationReport`, `CompilerResult`, receipt, `CompatibilityReport`
  mutation;
- `.igapp` artifact schema or goldens;
- spec-body promotion;
- public API/CLI;
- release evidence rewrite or public demo/stable/production/all-grammar claims;
- Spark data, fixtures, ids, integration, or demo behavior;
- production behavior.

---

## Compact Handoff

R211 accepts source-backed proof-local Level 2 counterfactual dry-run evidence:
61/61 checks PASS and C3-X 15/15 PASS. The proof derives branch-intention
evidence from proof-owned SemanticIR-shaped artifacts, uses SHA-256
digest-addressed refs, frozen input snapshots, explicit premise sets, and
no-authority projection envelopes. This is not public/runtime/report/API support.
Recommended next route is a design-only vocabulary/spec boundary before any
runtime, report, or public surface is considered.

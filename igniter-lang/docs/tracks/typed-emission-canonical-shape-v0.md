# Track: Typed Emission Canonical Shape v0

> [!IMPORTANT]
> Stale / superseded as current blocker state. This track records the S3-R2 canonical-shape slice, not the current production path.
> Current truth: S3-R5-C4 (`orchestrator-emit-typed-switch-v0`) switched `CompilerOrchestrator` to `emit_typed`; Stage 1 and Stage 2 close candidates passed after the switch.
> Keep this document as historical evidence for the blocker-clearance chain only.

Card: S3-R2-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/typed-emission-canonical-shape-v0`
Status: done
Date: 2026-05-08

---

## Goal

Resolve the first typed-emission blocker from
`typed-emission-main-path-parity-v0`: canonical identity and core compute JSON
shape for `SemanticIREmitter#emit_typed`.

This slice does not switch `CompilerOrchestrator` to `emit_typed`.

---

## Decisions

[D] Production typed emission should use source-hash public identities:

```text
semanticir/<source_hash_16>
compilation_report/<source_hash_16>
```

not typed-program structural identities:

```text
semanticir/typed/<typed_hash>
compilation_report/typed_<typed_hash>
```

Reason: `emit_typed` is intended to become the production main path. Its public
artifact identity should remain stable for the same source unless/until the
language explicitly versions artifact identity differently.

[D] TypeChecker-local dependency evidence should not appear inside nested ExprIR
nodes. Typed emission now strips `deps` recursively from expressions while
preserving the canonical node-level `deps` field on compute nodes.

[D] Existing typed-surface proof checks were updated to assert the new
source-hash identity mode instead of the old `semanticir/typed/` prefix.

---

## Code Change

Updated:

```text
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
```

Changed `emit_typed` identity helpers:

```text
typed_program_id(typed_program)              -> program_id(typed_program)
typed_compilation_report_id(typed_program)  -> compilation_report_id(typed_program)
```

Changed typed compute lowering:

```text
expr: decl.fetch("expr")
```

to:

```text
expr: semantic_expr(decl.fetch("expr"))
```

where `semantic_expr` removes TypeChecker-local `deps` recursively.

---

## Parity Result

Before this slice:

```text
package_facade_add: FAIL
blocked_items: 9
```

After this slice:

```text
PASS typed_emission_main_path_parity
verdict: blocked
safe_to_switch_production_path: false
cases_run: 5
package_facade_add: PASS
invariant_valid: FAIL
olap_point: FAIL
stream_fold: FAIL
history_access: FAIL
sparkcrm_bihistory: NOT_COMPARABLE
ledger_tbackend_descriptor: NOT_COMPARABLE
blocked_items: 7
```

[S] `package_facade_add` now reaches parity under the comparison harness.

[S] Remaining blockers are no longer the core Add identity/shape blocker; they
are Stage 2 source-path integration blockers:

```text
invariant_valid: typed_expected_nodes_missing
olap_point: typed_path_error
stream_fold: parse_exception
history_access: report_shape_delta + typed_expected_nodes_missing
sparkcrm_bihistory: not_source_comparable
ledger_tbackend_descriptor: not_source_comparable
```

---

## Proofs

```text
ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

PASS, verdict blocked, `package_facade_add: PASS`.

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
```

PASS. Legacy parsed emission goldens are unchanged.

```text
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
```

PASS after updating typed identity expectations/goldens.

```text
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
```

PASS.

---

## Verdict

[D] Improved, still blocked.

The first blocker is resolved:

```text
canonical typed identity + core compute JSON shape -> Add parity PASS
```

The orchestrator should still not switch to `emit_typed` because Stage 2
source-level surfaces remain non-parity-safe.

---

## Handoff

```text
Card: S3-R2-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/typed-emission-canonical-shape-v0
Status: done

[D] Decisions
- Chose source-hash public identity for production typed emission.
- Removed TypeChecker-local nested `expr.deps` from typed SemanticIR expressions.
- Did not switch CompilerOrchestrator.

[S] Shipped / Signals
- `package_facade_add` parity improved from FAIL to PASS.
- Parity blocked_items dropped from 9 to 7.
- Typed-surface proofs now assert source-hash identity instead of `semanticir/typed/`.

[T] Tests / Proofs
- ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb -> PASS, verdict blocked
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden -> PASS
- ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb -> PASS
- ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb -> PASS
- ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb -> PASS
- ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb -> PASS
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS

[R] Risks / Recommendations
- Switching orchestrator remains unsafe until invariant, OLAP, stream, and
  history source-path blockers are resolved.
- Next work should focus on source-level Stage 2 lowering parity, not identity.

[Next] Suggested next slice
- typed-emission-stage2-source-lowering-parity-v0: carry invariant nodes,
  OLAP access, stream fold, and history temporal access through the common
  parser/classifier/typechecker/emit_typed path.
```

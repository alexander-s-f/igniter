# Invariant Severity Proof v0

Card: S2-R3-C4-P
Role: `[Igniter-Lang Research Agent]`
Track: `invariant-severity-proof-v0`
Status: done
Date: 2026-05-07
Depends on: none

## Goal

Create the first executable proof for PROP-025 invariant severity levels.

This is a proof-local Stage 2 fixture. It does not change parser syntax,
classifier ownership, TypeChecker ownership, RuntimeMachine production code, or
Stage 1 close behavior.

## Horizon

Igniter-Lang is an Epistemic Contract Language where contract outputs are
trusted only through explicit evidence.

PROP-025 extends invariant behavior from binary pass/fail into severity-aware
runtime/report outcomes:

```text
error  -> block trusted output
warn   -> allow output with warning diagnostic
soft   -> allow output as uncertain (~T)
metric -> record metric observation without changing output trust
```

## Fixture

Experiment:

```text
igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
```

The proof uses a synthetic `MedicationDoseReview` contract and a hand-authored
SemanticIR-like fixture with four invariant nodes:

```text
contraindicated_interaction_block
  severity: error
  label: CG-INTERACTION-01
  effect: block_trusted_output

major_interaction_acknowledgement
  severity: warn
  label: CG-INTERACTION-02
  effect: attach_warning
  overridable_with: documented_justification

renal_confidence_gate
  severity: soft
  label: CG-RENAL-CONF-01
  effect: promote_to_uncertain

latency_metric
  severity: metric
  label: PERF-DOSE-01
  effect: record_metric
```

Generated proof artifacts:

```text
experiments/invariant_severity_proof/summary.json
experiments/invariant_severity_proof/golden/semantic_ir_program.json
experiments/invariant_severity_proof/golden/compilation_report.json
experiments/invariant_severity_proof/golden/error_blocks.json
experiments/invariant_severity_proof/golden/warn_allows.json
experiments/invariant_severity_proof/golden/soft_uncertain.json
experiments/invariant_severity_proof/golden/metric_records.json
```

## Decisions

[D] Kept syntax proof-local. Parser grammar for invariant declarations is not
changed in this slice.

[D] Included `soft` because PROP-025 specifies it clearly enough for a bounded
runtime/report fixture.

[D] Modeled severity as explicit `invariant_node.severity` plus output effect
metadata. The proof checks that compilation/report output preserves severity
and coverage.

[D] Kept runtime behavior proof-local. The production RuntimeMachine target is
to evaluate invariant nodes from SemanticIR and emit typed diagnostics and
observations with the same behavior.

[D] Kept metric invariant non-blocking even when violated. It records a metric
observation and leaves the contract output trusted.

## Proven Outcomes

`error_blocks`

```text
status: blocked
trusted_output: false
output: null
blocking_diagnostics[0].category: invariant_error
observation: failure_observation
```

`warn_allows`

```text
status: ok
trusted_output: true
output.warnings[0].category: invariant_warning
observation: warning_observation
```

`soft_uncertain`

```text
status: ok
trusted_output: true
output.uncertainty.kind: uncertain
output.uncertainty.type_promotion: T -> ~T
observation: soft_observation
```

`metric_records`

```text
status: ok
trusted_output: true
metrics[0].status: violated
observation: metric_observation
```

## Proof Output

```text
PASS invariant_severity_proof
compile.invariant_nodes_have_severity: ok
compile.output_tracks_warn_soft_metric_sources: ok
runtime.error_blocks_trusted_output: ok
runtime.warn_allows_with_warning: ok
runtime.soft_promotes_uncertain: ok
runtime.metric_records_without_output_effect: ok
observations.error_failure: ok
observations.warn_warning: ok
observations.soft_observation: ok
observations.metric_observation: ok
report.invariant_coverage_present: ok
error.status: blocked
warn.warnings: 1
soft.uncertainty: T -> ~T
metric.observations: 1
summary: igniter-lang/experiments/invariant_severity_proof/summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Proof-Local vs Target

Proof-local:

```text
hand-authored SemanticIR-like fixture
synthetic runtime evaluator
synthetic MedicationDoseReview input cases
golden output/report JSON
```

Language/compiler target:

```text
parser syntax for invariant severity/label/overridable_with
classifier ownership for invariant declarations
TypeChecker validation for severity and override legality
SemanticIR invariant_node emission
RuntimeMachine invariant evaluator and observation packet emission
CORE caller checks for unhandled warnings and ~T uncertainty
```

## Gaps

[R] Compiler/Grammar should decide the source syntax surface for invariant
severity before parser acceptance work starts.

[R] TypeChecker needs OOF ownership for invalid invariant metadata, especially
`overridable_with` on `severity: error`.

[R] Bridge/Runtime needs a future RuntimeMachine slice for observation packet
shape and caller handling of warnings or uncertain outputs.

## Changed Files

```text
docs/tracks/invariant-severity-proof-v0.md
experiments/invariant_severity_proof/invariant_severity_proof.rb
experiments/invariant_severity_proof/summary.json
experiments/invariant_severity_proof/golden/compilation_report.json
experiments/invariant_severity_proof/golden/error_blocks.json
experiments/invariant_severity_proof/golden/metric_records.json
experiments/invariant_severity_proof/golden/semantic_ir_program.json
experiments/invariant_severity_proof/golden/soft_uncertain.json
experiments/invariant_severity_proof/golden/warn_allows.json
```

## Handoff

```text
Card: S2-R3-C4-P
[Igniter-Lang Research Agent]
Track: invariant-severity-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Kept the fixture proof-local and syntax-free.
- Proved error/warn/soft/metric severity behavior with explicit observations.
- Preserved Stage 1 close candidate behavior.

[R] Recommendations:
- Compiler/Grammar: define source syntax and OOF ownership for invalid severity metadata.
- Bridge Agent: map proof-local observations into RuntimeMachine ObsPacket shape.
- Runtime target: add invariant_node evaluator after syntax/type ownership is settled.

[S] Signals:
- `:error` blocks trusted output.
- `:warn` allows trusted output with warning diagnostic.
- `:soft` allows output as uncertain `T -> ~T`.
- `:metric` records an observation without blocking or changing output.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[Files] Changed:
- igniter-lang/docs/tracks/invariant-severity-proof-v0.md
- igniter-lang/experiments/invariant_severity_proof/

[Q] Open Questions:
- Should Stage 2 require parser syntax for invariant severity before RuntimeMachine extraction?
- Which OOF codes own unhandled warnings and `~T` misuse in caller contracts?

[X] Rejected:
- No parser changes in this slice.
- No production RuntimeMachine extraction in this slice.
- No History/BiHistory file edits.

[Next] Proposed next slice:
- invariant-severity-parser-and-typechecker-ownership-v0
```

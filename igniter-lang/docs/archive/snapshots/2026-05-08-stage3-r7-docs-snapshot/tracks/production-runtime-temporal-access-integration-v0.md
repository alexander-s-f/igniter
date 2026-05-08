# Production Runtime Temporal Access Integration v0

Card: `S2-R5-C3-P`
Role: `[Igniter-Lang Research Agent]`
Track: `production-runtime-temporal-access-integration-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R4-C1-P`

## Goal

Define the production RuntimeMachine integration boundary for temporal access
without editing parser/typechecker or implementing a production RuntimeMachine
adapter.

This slice starts from the proven experiment-level
`SemanticIRTemporalAccessEvaluator` and moves the reusable runtime helper to
`igniter-lang/lib`.

## Library Boundary

[D] Added reusable library file:

```text
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

Primary library namespace:

```text
IgniterLang::TemporalAccessRuntime
```

Compatibility shim:

```text
igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb
```

The shim preserves current proof constants:

```ruby
require_relative "../../lib/igniter_lang/temporal_access_runtime"

TemporalAccessRuntime = IgniterLang::TemporalAccessRuntime unless Object.const_defined?(:TemporalAccessRuntime, false)
```

This keeps proof output strings such as
`TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator` unchanged.

## Reusable API

The reusable boundary exposes:

```text
IgniterLang::TemporalAccessRuntime::Canonical
IgniterLang::TemporalAccessRuntime::Option
IgniterLang::TemporalAccessRuntime::AxisTypeError
IgniterLang::TemporalAccessRuntime::Capabilities
IgniterLang::TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator
IgniterLang::TemporalAccessRuntime::MemoryBackend
```

`SemanticIRTemporalAccessEvaluator` API:

```ruby
evaluate(access_node, temporal_inputs:, inputs:)
```

Required `access_node` shape:

```text
kind: temporal_access_node
access: point
source_ref: <temporal_input_node.name>
axis: valid_time | bitemporal
```

Supported routes:

```text
axis: valid_time | single
  -> backend.read_as_of(subject, as_of)
  -> history_access_observation
  -> evidence link rel: selected_append

axis: bitemporal
  -> backend.bihistory_at(history_ref, vt:, tt:, node_name:)
  -> bihistory_access_observation
  -> evidence link rel: selected_event
```

Both routes preserve canonical `Option[T]`:

```json
{ "kind": "some", "value": "..." }
{ "kind": "none" }
```

## Capability Requirements

[D] Production RuntimeMachine should treat temporal access as ESCAPE and require
explicit capability authorization before evaluation.

Capability map:

| Semantic axis | Capability | Current proof bridge |
|---|---|---|
| `valid_time` / `single` | `history_read` | already used by `history_type_proof` |
| `bitemporal` | `bitemporal_read` | SparkCRM pressure used `bihistory_read`; current proof still passes through `history_read` in some classified fixtures |

Library signal:

```text
IgniterLang::TemporalAccessRuntime::Capabilities.for_axis("valid_time")
  -> ["history_read"]

IgniterLang::TemporalAccessRuntime::Capabilities.for_axis("bitemporal")
  -> ["history_read", "bitemporal_read"]
```

[R] The `history_read` entry on bitemporal access is a compatibility bridge for
existing proof fixtures. The production classifier/typechecker should converge
on explicit `bitemporal_read` for bitemporal access, while allowing migration
from older `history_read` metadata during Stage 2 package extraction.

## Production RuntimeMachine Contract

### Load-time checks

When `RuntimeMachine.load(.igapp/)` sees `temporal_access_node`, it should:

```text
1. Resolve its source_ref to exactly one temporal_input_node.
2. Normalize axis: single -> valid_time.
3. Derive required capabilities:
   valid_time  -> history_read
   bitemporal  -> bitemporal_read
4. Check RuntimeContract/TBackend descriptor advertises those capabilities.
5. Check the selected backend adapter implements the required read method.
6. Add temporal access requirements to CompatibilityReport.backend_check.
```

Load should block, not degrade silently, when a required capability or backend
method is missing.

### Evaluate-time behavior

At evaluation, RuntimeMachine should:

```text
1. Resolve input values for time refs:
   time_ref | as_of_ref
   valid_time_ref
   transaction_time_ref
2. Render templated store/history refs from runtime inputs.
3. Call SemanticIRTemporalAccessEvaluator with the chosen TBackend adapter.
4. Store result under access_node.name.
5. Append access observation to EvaluationResult.observations.
6. Append selected evidence links to EvaluationResult.evidence_links.
```

The evaluator result shape remains:

```json
{
  "kind": "temporal_access_evaluation",
  "node": "current_count",
  "axis": "valid_time",
  "result": { "kind": "some", "value": 9 },
  "observation": { "kind": "history_access_observation" },
  "evidence_links": [
    { "rel": "selected_append", "from": "obs/...", "to": "obs/..." }
  ]
}
```

## TBackend Adapter Contract

Production adapters should satisfy this minimal contract:

```text
supports_capability?("history_read")      -> true | false
supports_capability?("bitemporal_read")   -> true | false

read_as_of(subject, as_of)
  -> [Option[T], history_access_observation]

bihistory_at(history_ref, vt:, tt:, node_name:)
  -> [Option[T], bihistory_access_observation]
```

Observation requirements:

```text
history_access_observation:
  kind: history_access_observation
  observation_id
  subject
  as_of
  selected_append_ref
  result
  option_encoding
  temporal.axis: valid_time

bihistory_access_observation:
  kind: bihistory_access_observation
  observation_id
  history_ref
  node
  axis: bitemporal
  valid_time
  transaction_time
  selected_event_ref
  result
  option_encoding
```

Error/diagnostic requirements:

```text
missing capability       -> temporal_access.capability_missing
missing backend method   -> temporal_access.backend_contract_missing
missing source_ref       -> temporal_access.source_ref_missing
unsupported axis/access  -> temporal_access.unsupported_shape
bad axis value           -> temporal_access.axis_type_mismatch
missing runtime input    -> temporal_access.input_missing
```

These can initially be RuntimeMachine evaluation errors. Parser/typechecker OOF
ownership remains out of scope for this slice.

## Proof Signals

History proof signal:

```text
history.loader=TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator
history.output={"kind"=>"some", "value"=>9}
history.obs_kind=history_access_observation
history.link_rel=selected_append
history.option_encoding={"none"=>{"kind"=>"none"}, "some"=>{"kind"=>"some", "value"=>"<value>"}}
```

SparkCRM BiHistory proof signal:

```text
bihistory.loader=TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator
bihistory.nodes=schedule_at,off_schedule_at,day_off_config_at
bihistory.obs_count=24
bihistory.obs_kind=bihistory_access_observation
bihistory.negative_rules=OOF-BT2,OOF-BT3,OOF-BT4
```

Capability helper signal:

```text
cap.valid_time=history_read
cap.bitemporal=history_read,bitemporal_read
```

## Proof Output

History proof:

```text
PASS history_type_proof
history.append_seed_observations: ok
parser.hand_authored_history_parsed_program: ok
classifier.history_read_escape: ok
typechecker.history_at_option_integer: ok
semanticir.temporal_input_node: ok
semanticir.temporal_access_node: ok
assembler.history_igapp: ok
runtime.load_history_igapp_trusted: ok
runtime.evaluate_as_of_2026_05_03: ok
runtime.evaluate_as_of_2026_05_06: ok
runtime.output_links_selected_append_observation: ok
runtime.temporal_access_node_loader_valid_time: ok
negative.missing_as_of_oof_h1: ok
compilation.positive_report_ok: ok
option.encoding: some={"kind":"some","value":value} none={"kind":"none"}
summary: igniter-lang/experiments/history_type_proof/history_type_proof_summary.json
```

SparkCRM BiHistory proof:

```text
PASS sparkcrm_bihistory_fixture
seed.synthetic_bihistory_events: ok
option.canonical_some: ok
option.canonical_none: ok
decision.snapshot_blocks_requested_window: ok
corrected.snapshot_frees_requested_window: ok
correction.report_links_prior_and_corrected_events: ok
dispatch.original_explanation_preserved: ok
runtime.temporal_access_node_loader_bitemporal: ok
negative.missing_vt_oof_bt2: ok
negative.missing_tt_oof_bt3: ok
negative.wrong_axis_type_oof_bt4: ok
safety.synthetic_only: ok
decision.requested_window: blocked/busy
corrected.requested_window: available/available
correction.changed_slots: 1
summary: igniter-lang/experiments/sparkcrm_bihistory_fixture/summary.json
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

Syntax/direct require:

```text
ruby -c igniter-lang/lib/igniter_lang/temporal_access_runtime.rb -> Syntax OK
ruby -c igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb -> Syntax OK
ruby -I igniter-lang/lib -e 'require "igniter_lang/temporal_access_runtime"; ...' -> library_require: ok
ruby -e 'require_relative "igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime"; ...' -> experiment_shim: ok
```

## Remaining Adapter Gaps

[R] Production RuntimeMachine still needs a real TBackend adapter descriptor
and capability check API. `MemoryBackend` is reference behavior, not the
adapter contract implementation.

[R] RuntimeMachine does not yet route general `.igapp/` evaluation through
`IgniterLang::TemporalAccessRuntime::SemanticIRTemporalAccessEvaluator`.

[R] Canonical bitemporal capability naming needs one Compiler/Grammar decision:
`bitemporal_read` is recommended here, while older docs/fixtures mention
`bihistory_read` or reuse `history_read`.

[R] Parser/typechecker OOF implementation for missing refs, wrong axes, and
capability declarations remains separate and should not be mixed into runtime
integration.

## Changed Files

```text
igniter-lang/docs/tracks/production-runtime-temporal-access-integration-v0.md
igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

## Handoff

```text
Card: S2-R5-C3-P
[Igniter-Lang Research Agent]
Track: production-runtime-temporal-access-integration-v0
Status: done

[D] Decisions
- Moved reusable temporal access runtime helper to
  IgniterLang::TemporalAccessRuntime under igniter-lang/lib.
- Kept the experiment temporal_access_runtime.rb file as a compatibility shim.
- Defined RuntimeMachine load/evaluate integration contract for
  temporal_access_node.
- Defined capability requirements for history_read and bitemporal_read.
- Kept production RuntimeMachine implementation, parser, and typechecker out of scope.

[S] Shipped / Signals
- History and BiHistory proofs still use TemporalAccessRuntime through the old
  top-level constant while code now lives in lib.
- valid_time route emits history_access_observation + selected_append link.
- bitemporal route emits bihistory_access_observation + selected_event link.
- Capability helper exposes valid_time and bitemporal requirement sets.

[T] Tests / Proofs
- ruby -c igniter-lang/lib/igniter_lang/temporal_access_runtime.rb -> Syntax OK
- ruby -c igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb -> Syntax OK
- ruby -I igniter-lang/lib -e 'require "igniter_lang/temporal_access_runtime"; ...' -> library_require: ok
- ruby -e 'require_relative "igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime"; ...' -> experiment_shim: ok
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Production TBackend adapter descriptor/capability API remains to be implemented.
- RuntimeMachine still needs a real temporal_access_node resolver hook.
- Compiler/Grammar should settle bitemporal_read vs bihistory_read naming.
- Do not mix parser/typechecker OOF implementation into the runtime integration slice.

[Next] Suggested next slice
- runtime-machine-temporal-access-hook-v0:
  add a proof-local RuntimeMachine resolver hook that delegates temporal_access_node
  evaluation to IgniterLang::TemporalAccessRuntime and checks backend capabilities.
```

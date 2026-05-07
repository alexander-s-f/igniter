# Option Encoding Normalization v0

Card: S2-R2-C1-B
Role: `[Igniter-Lang Research Agent]`
Track: `option-encoding-normalization-v0`
Status: done
Date: 2026-05-07

## Goal

Normalize the active History proof `Option[T]` runtime encoding to the
canonical shape from `temporal-option-and-bihistory-shape-v0`:

```json
{ "kind": "some", "value": "V" }
```

```json
{ "kind": "none" }
```

This unblocks the next History parser acceptance and SparkCRM BiHistory fixture
work by removing the old proof-local encoding.

## Decisions

[D] `Option[T]` output in `history_type_proof` now uses:

```text
Some(V) -> { "kind": "some", "value": V }
None    -> { "kind": "none" }
```

[D] No parser acceptance, BiHistory, range access, aggregate access, or
TBackend adapter behavior was added in this card.

[D] The old proof-local shape was removed from active History proof docs and
goldens rather than retained as a parallel compatibility mode.

## Runtime Signals

The History proof still evaluates the same two `History[Integer]` projections:

```text
2026-05-03T10:00:00Z -> { "kind": "some", "value": 7 }
2026-05-06T10:00:00Z -> { "kind": "some", "value": 9 }
```

Each runtime output still links the selected append observation:

```text
runtime.output_links_selected_append_observation: ok
```

## Proof Output

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
negative.missing_as_of_oof_h1: ok
compilation.positive_report_ok: ok
option.encoding: some={"kind":"some","value":value} none={"kind":"none"}
summary: igniter-lang/experiments/history_type_proof/history_type_proof_summary.json
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

## Active Old-Shape Sweep

The active History proof scope was checked for the old shape:

```text
experiments/history_type_proof/
docs/tracks/history-type-point-access-proof-v0.md
docs/tracks/history-type-proof-v0.md
docs/tracks/history-type-proof-planning-v0.md
```

No remaining active matches for the old `{ some: value }` / `{ none: true }`
proof encoding were found.

## Changed Files

```text
docs/tracks/option-encoding-normalization-v0.md
docs/tracks/history-type-point-access-proof-v0.md
docs/tracks/history-type-proof-v0.md
docs/tracks/history-type-proof-planning-v0.md
experiments/history_type_proof/history_type_proof.rb
experiments/history_type_proof/history_type_proof_summary.json
```

## Handoff

```text
Card: S2-R2-C1-B
[Igniter-Lang Research Agent]
Track: option-encoding-normalization-v0
Status: done

[D] Decisions
- Canonical Option[T] encoding is { "kind":"some","value":V } | { "kind":"none" }.
- History proof behavior is unchanged except for runtime JSON shape.
- No parser acceptance or BiHistory work was added.

[S] Shipped / Signals
- Updated history_type_proof runtime output, assertions, summary, and .igapp output.
- Updated active History proof docs to the canonical Option[T] shape.
- Old proof-local Option shape removed from active history proof scope.

[T] Tests / Proofs
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
- old-shape rg sweep over active History proof scope -> no matches

[R] Risks / Recommendations
- History parser acceptance can now rely on the canonical Option[T] output shape.
- SparkCRM BiHistory fixture should use the same Option[T] encoding from the start.

[Next] Suggested next slice
- history-type-parser-acceptance-v0
```

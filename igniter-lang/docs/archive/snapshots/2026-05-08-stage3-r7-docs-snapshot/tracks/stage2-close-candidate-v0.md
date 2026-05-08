# Stage 2 Close Candidate v0

Card: S2-R14-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `stage2-close-candidate-v0`
Status: done
Date: 2026-05-07

## Goal

Implement the Stage 2 close candidate runner and machine-readable close evidence
packet.

This is an orchestration proof. It adds no language semantics and does not edit
parser, classifier, typechecker, SemanticIR, assembler, or RuntimeMachine
behavior.

## Runner

New command:

```text
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

The runner:

- checks the R13 package skeleton preconditions;
- runs direct public facade smoke through `IgniterLang.compile`;
- executes required Stage 2 proof scripts;
- preserves Stage 1 regression by invoking `stage1_close_candidate`;
- writes `igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json`;
- exits non-zero if any required precondition, facade smoke, surface, or proof
  fails.

## Required Checks

| Surface | Evidence |
|---------|----------|
| package facade | direct `IgniterLang.compile` + production compiler CLI/API proof |
| invariant severity | invariant runtime observation proof |
| OLAPPoint | `olap_point_proof` |
| stream fold | `stream_t_proof` |
| History[T] | `history_type_proof` |
| BiHistory[T] | `sparkcrm_bihistory_fixture` |
| Ledger descriptor | metadata-only Ledger TBackend descriptor proof |
| Stage 1 regression | `stage1_close_candidate` |

## Evidence Packet

Output:

```text
igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
```

Top-level evidence includes:

```text
kind: stage2_close_candidate
status: PASS | FAIL
verdict: stage2_close_candidate | blocked
timestamp
facade.entrypoint
facade.facade_version
facade.libs_loaded
facade.files_loaded
preconditions
package_facade_smoke
surface_checks
proofs_run
fixture_set
deferred_gaps
close_candidate_signals
```

`deferred_gaps` are governance evidence only. They do not fail the candidate
unless a deferred gap is incorrectly claimed as closed.

## Proof Output

Stage 2 close candidate:

```text
PASS stage2_close_candidate
verdict: stage2_close_candidate
package_facade: PASS
invariant_runtime_observations: PASS
olap_point: PASS
stream_fold: PASS
history_bihistory_temporal_access: PASS
ledger_tbackend_descriptor: PASS
stage1_regression: PASS
summary: igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
```

JSON shape smoke:

```text
stage2_close_candidate PASS stage2_close_candidate
proofs_run=8
facade_version=0.1.0.pre.stage2
libs_loaded=11
deferred_gaps=5
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
```

## Decisions

[D] The close candidate delegates to existing proofs instead of reimplementing
their internal assertions.

[D] Direct facade evidence is in-process and uses `IgniterLang.compile` on the
minimal Add source fixture, writing to `/private/tmp`.

[D] Ledger TBackend evidence is explicitly recorded as descriptor/metadata-only;
no production Ledger adapter binding is implied.

[D] The runner reports loaded compiler library files from `$LOADED_FEATURES` so
the close JSON has concrete package boundary evidence.

## Remaining Deferred Gaps

[R] Production Ledger/Durable TBackend binding remains deferred.

[R] OLAP scatter/gather, rollup, and distributed execution remain deferred.

[R] Runtime invariant observation persistence remains proof-backed, not
production-integrated.

[R] OOF-I1, OOF-I3, and OOF-I5 remain deferred by Stage 2 governance.

[R] Gem release readiness remains deferred: final metadata, CI, RubyGems release
policy, and gem-native package specs are not part of this runner.

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R14-C1-P
Track: stage2-close-candidate-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Implemented Stage 2 close candidate as an orchestration proof over existing proofs.
- Added direct `IgniterLang.compile` package facade smoke without changing compiler/runtime libs.
- Recorded Ledger descriptor as metadata-only, not production backend binding.
- Preserved Stage 1 regression as a required check.

[S] Signals:
- `stage2_close_candidate.json` reports verdict `stage2_close_candidate`.
- Surface checks PASS for package facade, invariant observations, OLAP, stream fold, History/BiHistory, Ledger descriptor, and Stage 1 regression.
- Evidence packet includes facade version, loaded libs/files, proofs_run, fixture_set, and deferred_gaps.

[T] Tests / Proofs:
- `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` -> PASS
- `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` -> PASS
- JSON shape smoke -> `proofs_run=8`, `facade_version=0.1.0.pre.stage2`, `deferred_gaps=5`

[R] Risks:
- The candidate depends on existing proof scripts and their command stability.
- Stage 2 close evidence is proof-local; it is not a production runtime/backend certification.
- The generated JSON has a timestamp and will update on each runner execution.

[Files] Changed:
- `igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb`
- `igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json`
- `igniter-lang/docs/tracks/stage2-close-candidate-v0.md`

[Q] Open Questions:
- Should R15 close decision archive this exact JSON snapshot, or regenerate it during formal close?

[Next] Proposed next slice:
- R15 Meta Expert close decision: review gem build, Stage 2 close candidate PASS, Stage 1 PASS, and record CLOSE / CLOSE WITH DEFERRED GAPS.
```

# Track: Stage 2 Close Candidate Planning v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/stage2-close-candidate-planning-v0`
Card: S2-R13-C2-P
Status: done
Date: 2026-05-07

---

## Goal

Design the Stage 2 close candidate proof before implementation.

This is a planning slice only. It defines the candidate runner checks, fixture
set, JSON packet shape, and the follow-on R14 implementation card. It does not
create `experiments/stage2_close_candidate/` and does not edit compiler,
parser, typechecker, RuntimeMachine, or package code.

---

## Readiness Inputs

Primary close-readiness source:

- `docs/meta-proposals/META-EXPERT-009-stage2-close-readiness-critical-path-v0.md`

Existing close-runner pattern:

- `experiments/stage1_close_candidate/stage1_close_candidate.rb`

Current Stage 2 state:

- `docs/current-status.md`
- `docs/tracks/compiler-package-boundary-v0.md`
- `docs/tracks/runtime-smoke-extraction-v0.md`
- `docs/tracks/runtime-invariant-violation-observations-v0.md`
- `docs/tracks/ledger-tbackend-adapter-descriptor-v0.md`

---

## Close Candidate Preconditions

R14 should treat the R13 packaging skeleton as a precondition, not as work to
perform inside the close candidate:

1. `igniter-lang/lib/igniter_lang.rb` loads through `ruby -I igniter-lang/lib`.
2. `IgniterLang.compile` is the public compiler facade.
3. `IgniterLang::CompilerOrchestrator` remains behind the facade.
4. Package version metadata exists and can be reported as `facade_version`.
5. The CLI entrypoint path is package-shaped enough to prove it shares the
   facade boundary.

If any precondition is absent, the R14 runner should emit JSON with
`status: "FAIL"` and `verdict: "blocked"`, then exit non-zero. It should not
patch package files to make the precondition pass.

---

## Exact Stage 2 Candidate Checks

The R14 runner should be an orchestrator like the Stage 1 close candidate. It
should call existing proofs and public APIs; it should not reach into
experiment-local helper classes except by executing proof scripts.

### 1. Package Facade

Purpose: prove that the packageable compiler boundary is the single public
entrypoint for close-candidate compilation.

Checks:

- `ruby -I igniter-lang/lib -e 'require "igniter_lang"'` succeeds.
- `IgniterLang.respond_to?(:compile)` is true.
- `IgniterLang::CompilerOrchestrator` is defined.
- The facade exposes a version value after R13 packaging skeleton work.
- Direct `IgniterLang.compile(source, output_path: ...)` succeeds on a minimal
  source fixture and writes outside the repo, for example under
  `/private/tmp/igniter_lang_stage2_close_candidate/`.
- `production_compiler_cli_proof.rb` remains PASS, proving the CLI and direct
  Ruby API share the same compiler facade shape.

Required proof command:

```text
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
```

Minimal source fixture:

```text
igniter-lang/experiments/source_to_semanticir_fixture/add.ig
```

### 2. Invariant Runtime Observations

Purpose: prove the Stage 2 invariant severity path remains closed through
parser/typechecker/emitter/runtime observation evidence.

Checks:

- PINV/TINV invariant nodes still compile as `invariant_node`.
- Runtime violations emit `invariant_violation_observation` with nested
  `invariant_violation_node`.
- Compile-time JSON does not invent compile-time violation nodes.
- Severity behavior remains covered:
  - `error` blocks trusted output.
  - `warn` records a warning.
  - `soft` promotes uncertainty.
  - `metric` records metric evidence.

Required proof command:

```text
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
```

### 3. OLAP Point

Purpose: prove the minimal OLAP point primitive remains closed across grammar,
parser, TypeChecker, SemanticIR, and proof execution.

Checks:

- `olap_point` declaration parsing succeeds.
- `dims_record` AST shape is preserved.
- TypeChecker accepts the minimal OLAP point shape.
- SemanticIR contains the OLAP point boundary shape.
- Existing OLAP proof output remains unchanged, including the point measure
  evidence already tracked by the proof.

Required proof command:

```text
ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
```

Minimal source fixture:

```text
igniter-lang/experiments/olap_point_proof/revenue_point.ig
```

### 4. Stream Fold

Purpose: prove the Stage 2 stream surface remains closed across parser,
classifier, TypeChecker, SemanticIR, and runtime proof behavior.

Checks:

- `fold_stream` path remains accepted for the bounded window fixture.
- Stream OOF guards remain enforced by the existing stream proof:
  - missing window rejected
  - direct stream arithmetic rejected
  - stream escape from fold rejected
- SemanticIR stream lowering remains represented in the fixture evidence.

Required proof command:

```text
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
```

Minimal source fixture:

```text
igniter-lang/experiments/stream_t_proof/stream_integer_window.ig
```

### 5. History and BiHistory Temporal Access

Purpose: remove ambiguity between the valid-time `history_read` path and the
bitemporal `bihistory_read` path by proving both existing temporal fixtures.

Checks:

- History point access remains PASS for `history_read` / valid-time access.
- SparkCRM BiHistory fixture remains PASS for `bihistory_read` / bitemporal
  access.
- RuntimeMachine temporal hook evidence remains available through proof-local
  load/evaluate checks.
- Negative axis checks remain present for missing valid time, missing
  transaction time, and wrong-axis access.

Required proof commands:

```text
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb
ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
```

Minimal source/fixture set:

```text
igniter-lang/experiments/history_type_proof/history_integer_point_access.ig
igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
```

### 6. Ledger TBackend Descriptor Evidence

Purpose: record that the bridge to a production Ledger-backed TBackend is still
descriptor-only, while proving the descriptor contract itself remains coherent.

Checks:

- Descriptor fixture remains PASS.
- Descriptor reports `hook_methods` for `read_as_of` and `bihistory_at`.
- Descriptor reports capabilities `history_read` and `bihistory_read`.
- Missing histories produce diagnostic load blocking evidence.
- The packet explicitly records this as metadata-only, not as real Ledger or
  Durable backend binding.

Required proof command:

```text
ruby igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb
```

### 7. Stage 1 Regression

Purpose: prove Stage 2 close evidence did not regress the Stage 1 close
candidate.

Required proof command:

```text
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

---

## Minimal Fixture Set

The close candidate should avoid creating new language fixtures unless one of
the existing proofs cannot expose the needed evidence.

| Surface | Fixture / proof source | Reason |
|---------|------------------------|--------|
| package facade | `experiments/source_to_semanticir_fixture/add.ig` | smallest direct facade compile smoke |
| CLI facade identity | `experiments/production_compiler_cli/production_compiler_cli_proof.rb` | proves CLI and Ruby API share boundary |
| invariant | `experiments/invariant_severity_proof/invariant_severity_proof.rb` | already covers severity + runtime observations |
| OLAP | `experiments/olap_point_proof/revenue_point.ig` | minimal `olap_point` and `dims_record` path |
| stream | `experiments/stream_t_proof/stream_integer_window.ig` | minimal bounded `fold_stream` path |
| History | `experiments/history_type_proof/history_integer_point_access.ig` | valid-time `history_read` path |
| BiHistory | `experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb` | bitemporal `bihistory_read` path |
| Ledger descriptor | `experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb` | records final adapter gap without real backend binding |
| Stage 1 regression | `experiments/stage1_close_candidate/stage1_close_candidate.rb` | existing close baseline |

---

## Target JSON Shape

R14 should write:

```text
igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
```

Target schema:

```json
{
  "kind": "stage2_close_candidate",
  "format_version": "0.1.0",
  "track": "stage2-close-candidate-v0",
  "stage": "stage2",
  "status": "PASS",
  "verdict": "stage2_close_candidate",
  "timestamp": "2026-05-07T00:00:00Z",
  "facade": {
    "entrypoint": "IgniterLang.compile",
    "facade_version": "0.0.0",
    "load_path": "igniter-lang/lib",
    "libs_loaded": [
      "igniter_lang",
      "igniter_lang/compiler_orchestrator",
      "igniter_lang/diagnostics",
      "igniter_lang/compiler_result",
      "igniter_lang/compilation_report"
    ]
  },
  "preconditions": [
    {
      "id": "package_skeleton",
      "status": "PASS",
      "summary": "R13 package skeleton is present enough for close-candidate proof."
    }
  ],
  "surface_checks": [
    {
      "id": "package_facade",
      "status": "PASS",
      "evidence": {
        "direct_api_compile": "PASS",
        "cli_shared_facade": "PASS"
      }
    },
    {
      "id": "invariant_runtime_observations",
      "status": "PASS",
      "evidence": {
        "compile_time_node": "invariant_node",
        "runtime_violation_observation": "invariant_violation_observation",
        "severities": ["error", "warn", "soft", "metric"]
      }
    },
    {
      "id": "olap_point",
      "status": "PASS",
      "evidence": {
        "declaration": "olap_point",
        "ast": "dims_record"
      }
    },
    {
      "id": "stream_fold",
      "status": "PASS",
      "evidence": {
        "operator": "fold_stream",
        "oof_guards": ["missing_window", "direct_stream_arithmetic", "stream_escape"]
      }
    },
    {
      "id": "history_bihistory_temporal_access",
      "status": "PASS",
      "evidence": {
        "history_capability": "history_read",
        "bihistory_capability": "bihistory_read"
      }
    },
    {
      "id": "ledger_tbackend_descriptor",
      "status": "PASS",
      "evidence": {
        "binding": "metadata_only",
        "hook_methods": ["read_as_of", "bihistory_at"]
      }
    },
    {
      "id": "stage1_regression",
      "status": "PASS"
    }
  ],
  "proofs_run": [
    {
      "id": "production_compiler_cli",
      "label": "Production compiler CLI proof",
      "command": ["ruby", "igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb"],
      "status": "PASS",
      "exit_status": 0,
      "checks": [],
      "stdout": [],
      "stderr": []
    }
  ],
  "fixture_set": [
    "igniter-lang/experiments/source_to_semanticir_fixture/add.ig",
    "igniter-lang/experiments/olap_point_proof/revenue_point.ig",
    "igniter-lang/experiments/stream_t_proof/stream_integer_window.ig",
    "igniter-lang/experiments/history_type_proof/history_integer_point_access.ig"
  ],
  "remaining_deferred_gaps": [
    {
      "id": "production_tbackend_adapter_binding",
      "status": "deferred",
      "summary": "Ledger/Durable adapter descriptor exists, but no real production backend package binding is closed."
    },
    {
      "id": "olap_distributed_execution",
      "status": "deferred",
      "summary": "OLAP scatter/gather, rollup, and distributed execution remain out of scope."
    },
    {
      "id": "invariant_persistence",
      "status": "deferred",
      "summary": "Runtime invariant observations are proof-backed, but production persistence is not closed."
    },
    {
      "id": "deferred_invariant_oofs",
      "status": "deferred",
      "summary": "OOF-I1, OOF-I3, and OOF-I5 remain deferred by Stage 2 governance."
    }
  ],
  "close_candidate_signals": [
    {
      "id": "stage2_surfaces_closed_in_proof",
      "status": "closed_in_proof",
      "summary": "Invariant, OLAP, stream, History/BiHistory, and package facade checks are all PASS."
    },
    {
      "id": "public_facade_used",
      "status": "closed_in_proof",
      "summary": "The candidate uses IgniterLang.compile for direct package facade evidence."
    }
  ]
}
```

Status rules:

- `status` is `PASS` only when every precondition, surface check, and proof run
  is `PASS`.
- `verdict` is `stage2_close_candidate` only when `status` is `PASS`.
- `verdict` is `blocked` when any required check fails.
- `remaining_deferred_gaps` are reported for governance, but do not fail the
  runner unless a gap is incorrectly claimed as closed.

---

## R14 Implementation Card Recommendation

```text
Card: S2-R14-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: stage2-close-candidate-v0
Status: open
Depends on: S2-R13-C2-P and R13 packaging skeleton

Goal:
Implement the Stage 2 close candidate runner and JSON evidence packet.

Read first:
- igniter-lang/docs/tracks/stage2-close-candidate-planning-v0.md
- igniter-lang/docs/meta-proposals/META-EXPERT-009-stage2-close-readiness-critical-path-v0.md
- igniter-lang/docs/current-status.md
- igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
- igniter-lang/lib/igniter_lang.rb

Scope:
- Create igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb.
- Use Open3 orchestration in the same style as Stage 1 close candidate.
- Add direct public facade compile smoke through IgniterLang.compile.
- Execute existing proofs for package facade, invariant, OLAP, stream,
  History/BiHistory, Ledger descriptor, and Stage 1 regression.
- Write igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json.
- Do not edit compiler/parser/typechecker/runtime code to make the runner pass.
- Do not create new production TBackend bindings.

Acceptance:
- ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb -> PASS
- stage2_close_candidate.json has verdict = "stage2_close_candidate"
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
- JSON records facade_version, libs_loaded, proofs_run, fixture_set, and
  remaining_deferred_gaps.

Deliver:
- Track doc: igniter-lang/docs/tracks/stage2-close-candidate-v0.md
- Stage 2 close candidate runner
- stage2_close_candidate.json
- Compact handoff with Card + [D]/[S]/[T]/[R]/[Next]
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R13-C2-P
Track: stage2-close-candidate-planning-v0
Status: done

[D] Decisions:
- Stage 2 close candidate should be an orchestration proof, not an implementation
  or repair pass.
- R13 packaging skeleton is a hard precondition; R14 should report blocked if it
  is absent.
- The temporal close check should include both History (`history_read`) and
  BiHistory (`bihistory_read`) to avoid capability-name ambiguity.
- Ledger TBackend evidence should be recorded as metadata-only descriptor proof,
  not as real backend binding.

[S] Signals:
- Existing Stage 1 close runner shape can be reused for Stage 2.
- Minimal Stage 2 fixture set exists across package facade, invariant, OLAP,
  stream, History/BiHistory, and descriptor proofs.
- Target JSON schema is explicit enough for R14 to implement without deciding
  close semantics during implementation.

[T] Tests / Proofs:
- Not run; this was a planning-only documentation slice.

[R] Risks:
- If R13 package version/bin/gemspec work is incomplete, R14 should fail as
  blocked rather than filling the gap.
- Calling only proof scripts preserves boundedness but means R14 depends on
  existing proof output conventions.
- Ledger descriptor PASS must not be misread as production Ledger/Durable
  adapter completion.

[Next] Implement S2-R14-C1-P: stage2-close-candidate-v0 runner and JSON packet.
```

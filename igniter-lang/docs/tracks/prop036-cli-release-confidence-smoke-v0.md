# PROP-036 CLI Release Confidence Smoke v0

Card: S3-R54-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-cli-release-confidence-smoke-v0
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - compiler/assembler refusal vocabulary remains relevant, no ask.
- [Igniter-Lang Bridge Agent] - caller/package surface confidence is relevant, no platform bridge requested.

---

## Scope

Exercise the already release-ready bounded PROP-036 CLI transport from a caller
perspective, without widening behavior or changing code.

Read:

- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/tracks/prop036-cli-release-readiness-docs-sync-v0.md`
- `igniter-lang/docs/discussions/prop036-cli-release-readiness-docs-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round53-status-curation-v0.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/prop036_cli_profile_source_b3_b6_implementation_proof_summary.json`

This card did not edit CLI/API/compiler behavior and did not mutate existing
`.igapp` golden fixtures. Smoke outputs were written under:

```text
/tmp/igniter_lang_prop036_cli_release_confidence_smoke/
```

---

## Fixture / Artifact Paths Used

```text
source:
  /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig

valid finalized compiler profile source:
  /Users/alex/dev/projects/igniter/igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json

malformed JSON input:
  /Users/alex/dev/projects/igniter/igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/invalid_json.json

semantic-invalid source:
  /Users/alex/dev/projects/igniter/igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/unfinalized_source.json
```

---

## Command Matrix

All commands were run from `/Users/alex/dev/projects/igniter`.

| Case | Command | Result |
| --- | --- | --- |
| no-flag legacy compile | `/Users/alex/.rbenv/versions/3.2.2/bin/ruby -I /Users/alex/dev/projects/igniter/igniter-lang/lib /Users/alex/dev/projects/igniter/igniter-lang/bin/igc compile /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_prop036_cli_release_confidence_smoke/legacy_no_flag.igapp` | PASS |
| valid profile source path | `/Users/alex/.rbenv/versions/3.2.2/bin/ruby -I /Users/alex/dev/projects/igniter/igniter-lang/lib /Users/alex/dev/projects/igniter/igniter-lang/bin/igc compile /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_prop036_cli_release_confidence_smoke/valid_profile_source.igapp --compiler-profile-source /Users/alex/dev/projects/igniter/igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json` | PASS |
| bad path preflight refusal | `/Users/alex/.rbenv/versions/3.2.2/bin/ruby -I /Users/alex/dev/projects/igniter/igniter-lang/lib /Users/alex/dev/projects/igniter/igniter-lang/bin/igc compile /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_prop036_cli_release_confidence_smoke/bad_path.igapp --compiler-profile-source /tmp/igniter_lang_prop036_cli_release_confidence_smoke/does_not_exist.json` | PASS |
| malformed JSON preflight refusal | `/Users/alex/.rbenv/versions/3.2.2/bin/ruby -I /Users/alex/dev/projects/igniter/igniter-lang/lib /Users/alex/dev/projects/igniter/igniter-lang/bin/igc compile /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_prop036_cli_release_confidence_smoke/malformed_json.igapp --compiler-profile-source /Users/alex/dev/projects/igniter/igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/invalid_json.json` | PASS |
| semantic profile-source refusal | `/Users/alex/.rbenv/versions/3.2.2/bin/ruby -I /Users/alex/dev/projects/igniter/igniter-lang/lib /Users/alex/dev/projects/igniter/igniter-lang/bin/igc compile /Users/alex/dev/projects/igniter/igniter-lang/experiments/source_to_semanticir_fixture/add.ig --out /tmp/igniter_lang_prop036_cli_release_confidence_smoke/semantic_unfinalized.igapp --compiler-profile-source /Users/alex/dev/projects/igniter/igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/unfinalized_source.json` | PASS |

Summary artifact for this smoke:

```text
/tmp/igniter_lang_prop036_cli_release_confidence_smoke/prop036_cli_release_confidence_smoke_summary.json
```

---

## Observed Results

```text
no_flag_legacy_compile:
  exitstatus: 0
  stdout: compiler_result JSON, status ok
  stderr: empty
  .igapp emitted: yes
  manifest.compiler_profile_id: absent

valid_profile_source_path:
  exitstatus: 0
  stdout: compiler_result JSON, status ok
  stderr: empty
  .igapp emitted: yes
  manifest.compiler_profile_id:
    compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7

bad_path_preflight_refusal:
  exitstatus: 1
  stdout: empty
  stderr: "compiler profile source path not found"
  .igapp emitted: no
  OUT.compilation_report.json emitted: no

malformed_json_preflight_refusal:
  exitstatus: 1
  stdout: empty
  stderr: "compiler profile source file must contain valid JSON"
  .igapp emitted: no
  OUT.compilation_report.json emitted: no

semantic_profile_source_refusal:
  exitstatus: 1
  stdout: compiler_result JSON, status assembler_refused
  stderr: empty
  .igapp emitted: no
  OUT.compilation_report.json emitted: yes
  diagnostic:
    add: compiler_profile_source.unfinalized: status="draft"
```

---

## Release-Confidence Verdict

R53 package-surface readiness survives caller-style smoke for the exact bounded
surface:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

The no-flag legacy path still omits `compiler_profile_id`. The valid bounded
path transports an already-finalized standalone source artifact and emits the
expected `compiler_profile_id` in the manifest. CLI preflight refusals stay
outside the compiler path and do not emit `.igapp` or compilation reports.
Semantic source refusal remains inside the existing compiler/assembler path and
uses qualified `compiler_profile_source.*` vocabulary.

---

## Non-Authorizations Preserved

This smoke does not authorize or implement:

- inline JSON;
- named/generated profile-source lookup;
- env/config/sidecar lookup;
- profile discovery, defaulting, or finalization;
- loader/report or CompatibilityReport status;
- `.ilk`, receipts, signing, or dispatch migration;
- RuntimeMachine, Gate 3 widening, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production behavior.

---

## Release-Engineering Notes

No blocker found.

Non-blocking note: this card used `/tmp` smoke output rather than checking
tracked proof directories. That keeps existing proof artifacts untouched while
still exercising the current workspace CLI surface.

---

## Handoff

```text
Card: S3-R54-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-cli-release-confidence-smoke-v0
Status: done

[D] Decisions
- Treated this as caller/release-confidence smoke, not a new proof semantics
  implementation.
- Reused the finalized standalone source artifact plus existing B3/B5 inputs.
- Wrote only temporary smoke outputs under /tmp.

[S] Signals
- PASS for no-flag legacy compile.
- PASS for valid --compiler-profile-source PATH.json transport.
- PASS for bad-path and malformed-JSON preflight refusals.
- PASS for semantic unfinalized source refusal through compiler/assembler path.
- R53 package-surface release-readiness survives caller-style smoke.

[T] Tests / Checks
- Ran the five-command matrix above.
- Summary written to:
  /tmp/igniter_lang_prop036_cli_release_confidence_smoke/prop036_cli_release_confidence_smoke_summary.json

[R] Risks / Recommendations
- No release-engineering blocker found for the exact R52/R53 bounded surface.
- Keep all non-authorized input shapes and runtime/production surfaces closed.

[Next]
- If Architect wants package-release automation confidence next, run a separate
  release-engineering card around installed executable/gem context, not CLI
  semantics widening.
```

# Track: PROP-036 CLI Profile Source B3-B6 Implementation Proof v0

Card: S3-R50-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-cli-profile-source-b3-b6-implementation-proof-v0
Status: done
Date: 2026-05-15

Depends on:
- S3-R50-C1-A

---

## Goal

Implement only the authorized CLI transport shape:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

The CLI reads exactly the provided JSON file, requires the top-level value to be
an object/hash, and passes that object unchanged as `compiler_profile_source:`
to `IgniterLang.compile`.

No RuntimeMachine, Ledger/TBackend, CompatibilityReport, loader/report,
dispatch migration, cache, or production behavior was touched.

---

## Implementation

Updated:

- `igniter-lang/lib/igniter_lang/cli.rb`

Added:

- optional `--compiler-profile-source PATH.json`;
- usage string:

  ```text
  Usage: igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
  ```

- preflight refusals before `IgniterLang.compile` for missing path, not found,
  non-file path, unreadable path, invalid JSON, top-level non-object JSON, and
  unsupported extra arguments;
- unchanged no-flag behavior: no profile source is loaded or defaulted.

Not changed:

- `IgniterLang.compile`
- `CompilerOrchestrator`
- `Assembler`
- `bin/igc`
- `bin/igniter-lang`
- production compiler experiment CLI

---

## Proof Artifacts

Added:

- `igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/prop036_cli_profile_source_b3_b6_implementation_proof.rb`
- `igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/prop036_cli_profile_source_b3_b6_implementation_proof_summary.json`

Proof summary:

```text
status: PASS
cases: 12/12 PASS
forbidden_exact_token_hits: 0
scanner_self_test_bare_forbidden_token_fails: true
scanner_self_test_qualified_source_validation_allowed: true
legacy_no_flag_manifest_omits_compiler_profile_id: true
valid_profile_source_manifest_emits_compiler_profile_id: true
invalid_profile_source_no_igapp: true
```

---

## Case Matrix

| Case | Blocker | Result | Evidence |
|------|---------|--------|----------|
| `B4.legacy_no_flag` | B4 | PASS | exit 0; compiler_result stdout; stderr empty; `.igapp` emitted; manifest omits `compiler_profile_id` |
| `valid_profile_source_success` | B2/B4 support | PASS | exit 0; compiler_result stdout; stderr empty; manifest emits source `compiler_profile_id` |
| `B3.missing_profile_path` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B3.profile_path_not_found` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B3.profile_path_not_regular_file` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B3.unreadable_path` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B3.invalid_json` | B3 | PASS | preflight stderr one line; stdout empty; no raw file contents; no report; no `.igapp` |
| `B3.top_level_not_object` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B3.unsupported_extra_argument` | B3 | PASS | preflight stderr one line; stdout empty; no report; no `.igapp` |
| `B5.wrong_kind` | B5 | PASS | compiler/orchestrator/assembler refusal path; report exists; `.igapp` absent; reason includes `compiler_profile_source.wrong_kind` |
| `B5.unfinalized_status` | B5 | PASS | compiler/orchestrator/assembler refusal path; report exists; `.igapp` absent; reason includes `compiler_profile_source.unfinalized` |
| `B5.runtime_authority_requested` | B5 | PASS | compiler/orchestrator/assembler refusal path; report exists; `.igapp` absent; reason includes `compiler_profile_source.runtime_authority_forbidden` |

---

## Command Matrix

All commands were run from repository root: `/Users/alex/dev/projects/igniter`.

| # | Command | Result | Notes |
|---|---------|--------|-------|
| 1 | `ruby -c igniter-lang/lib/igniter_lang/cli.rb` | PASS | Syntax OK |
| 2 | `ruby -c igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/prop036_cli_profile_source_b3_b6_implementation_proof.rb` | PASS | Syntax OK |
| 3 | `ruby igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/prop036_cli_profile_source_b3_b6_implementation_proof.rb` | PASS | `cases=12/12`; `forbidden_exact_token_hits=0`; scanner self-tests true |
| 4 | `ruby -rjson -e 'forbidden = %w[absent_legacy present_verified mismatch malformed missing_required runtime_ready evaluation_ready gate3_authorized runtime_authority production_ready]; root = ARGV.fetch(0); input = File.join(root, "inputs"); files = Dir.glob(File.join(root, "**", "*.json")).reject { |path| path.start_with?(input) }.sort; hits = []; walk = lambda do |value, path, file|; case value; when Hash; value.each do |k, v|; hits << [file, "key", (path + [k]).join("."), k] if forbidden.include?(k); walk.call(v, path + [k], file); end; when Array; value.each_with_index { |v, i| walk.call(v, path + [i], file) }; else; hits << [file, "value", path.join("."), value] if forbidden.include?(value); end; end; files.each { |file| walk.call(JSON.parse(File.read(file)), [], file) }; puts "json_files=#{files.length}"; puts "exact_forbidden_hits=#{hits.length}"; hits.each { |hit| puts hit.join(":") }; exit(hits.empty? ? 0 : 1)' igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out` | PASS | `json_files=22`; `exact_forbidden_hits=0` |

---

## B6 Scan Surface

The proof scanner covers:

- every captured stdout stream;
- every captured stderr stream;
- proof summary JSON;
- every proof-local `.igapp/**/*.json`;
- every proof-local `OUT.compilation_report.json`;
- excludes proof input fixtures under `out/inputs/`.

The adversarial scanner self-test proves:

- a bare forbidden token fails the scanner;
- qualified `compiler_profile_source.*` validation terms pass only as source
  validation vocabulary.

Allowed qualified terms recorded in the summary:

- `compiler_profile_source.wrong_kind`
- `compiler_profile_source.unfinalized`
- `compiler_profile_source.runtime_authority_forbidden`

---

## Blocker Status Recommendation

Recommendation after C2-I evidence:

| Blocker | Recommendation | Evidence |
|---------|----------------|----------|
| `PROP036-CLI-B3` | ready to close after C3-X pressure review | 7/7 preflight refusal cases PASS |
| `PROP036-CLI-B4` | ready to close after C3-X pressure review | no-flag legacy case PASS; manifest omits `compiler_profile_id` |
| `PROP036-CLI-B5` | ready to close after C3-X pressure review | 3/3 semantic refusal cases PASS through existing assembler/orchestrator path |
| `PROP036-CLI-B6` | ready to close after C3-X pressure review | forbidden exact-token scan 0 hits; adversarial scanner self-test PASS |

Still open:

- `PROP036-CLI-B9` pressure review must run after this implementation proof.

Already closed by prior decisions:

- `PROP036-CLI-B1`
- `PROP036-CLI-B7`
- `PROP036-CLI-B8`

`PROP036-CLI-B2` remains satisfied by the approved explicit path shape.

---

## Handoff

```text
Card: S3-R50-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-cli-profile-source-b3-b6-implementation-proof-v0
Status: done

[D] Decisions
- Implemented only the authorized --compiler-profile-source PATH.json shape.
- B3 preflight errors refuse before IgniterLang.compile and write no JSON
  report or .igapp output.
- B5 semantic source errors intentionally use the existing
  compiler/orchestrator/assembler refusal path.

[S] Shipped / Signals
- Updated IgniterLang::CLI transport.
- Added proof-local matrix and summary JSON.
- Added this track document.

[T] Tests / Proofs
- 4/4 command matrix PASS.
- Proof matrix: 12/12 cases PASS.
- B6 exact forbidden-token scan: 0 hits.
- Scanner self-test: bare forbidden token fails; qualified source-validation
  vocabulary allowed.

[R] Risks / Recommendations
- Recommend B3/B4/B5/B6 ready to close after required C3-X pressure review.
- B9 remains open.

[Q] Open questions
- None for this bounded implementation proof.
```

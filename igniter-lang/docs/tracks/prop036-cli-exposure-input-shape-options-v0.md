# PROP-036 CLI Exposure Input Shape Options v0

Card: S3-R45-C1-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-cli-exposure-input-shape-options-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future compiler-profile
  refusal vocabulary and source-object semantics.
- `[Igniter-Lang Bridge Agent]` may later consume this for package/CLI caller
  surface mapping.

## Goal

Design CLI input-shape options for future `compiler_profile_source` exposure
without implementing CLI behavior.

This track does not authorize implementation.

## Inputs Read

```text
igniter-lang/docs/gates/prop036-cli-api-exposure-authorization-review-v0.md
igniter-lang/docs/tracks/prop036-ruby-facade-profile-source-exposure-v0.md
igniter-lang/docs/tracks/prop036-post-cli-api-exposure-regression-chain-v0.md
igniter-lang/docs/discussions/prop036-cli-api-profile-source-pressure-v0.md
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/bin/igc
```

Additional evidence read for generated artifact viability:

```text
igniter-lang/docs/tracks/minimal-compiler-profile-finalization-proof-v0.md
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json
```

## Current CLI Shape

Current `igc` delegates to `IgniterLang::CLI.run(ARGV)`.

Current CLI accepts only:

```text
igc compile SOURCE --out OUT.igapp
```

`IgniterLang::CLI.run` calls:

```ruby
IgniterLang.compile(source_path: source_path, out_path: out_path)
```

It does not expose `compiler_profile_source`, profile paths, inline JSON, config,
discovery, finalization, loader/report status, CompatibilityReport, runtime, or
production behavior.

## Comparison Matrix

| Option | Caller ergonomics | Refusal behavior | JSON artifacts written | Negative-token scan surface | Discovery/defaulting risk | Implementation complexity | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Explicit path to source JSON file, e.g. `--compiler-profile-source path.json` | Good for CLI users once a standalone finalized artifact exists. Easy to script and inspect. | CLI must refuse missing file, unreadable file, invalid JSON, non-object JSON, and invalid source object before `.igapp` output. Existing assembler refusal can handle source-shape invalidity after parse. | On success: normal `.igapp` JSON with manifest `compiler_profile_id`. On invalid profile input: compilation/refusal report only, no `.igapp`. No loader-status report. | Must scan CLI output dir, refusal reports, manifests, summaries, and stderr/stdout JSON if any. | Low if the flag is explicit and no default path/config/env lookup exists. | Medium: path parse + JSON parse + error mapping + regression scan. | Best future CLI shape, but not authorized yet. |
| Inline JSON string, e.g. `--compiler-profile-source-json '{"kind":...}'` | Poor for humans; awkward shell quoting; easy to leak into shell history/logs. | CLI must refuse malformed JSON and invalid source before artifact output. Error messages risk echoing large user input. | Same success/refusal shape as path option, but risk of embedding snippets in reports. | Larger: scan reports/stdout/stderr for accidental raw JSON echoes and forbidden vocabulary. | Low for discovery/defaulting, but high for accidental data exposure/noisy reports. | Medium-high: quoting, parse errors, redaction, tests across shells. | Not recommended. |
| No CLI support yet / Ruby facade only | Good for programmatic callers; poor for CLI-only users. | Existing Ruby facade and assembler/orchestrator refusals remain authoritative. CLI no-flag remains legacy optional. | No new CLI JSON artifacts beyond current compile outputs. | Current C4 scan already covers Ruby facade + production CLI outputs: 88 files, 0 exact hits. | Lowest. No path/config/env/default surface. | None. | Recommended hold until CLI source artifact and refusal contract are pinned. |
| Named generated profile-source artifact, e.g. `--compiler-profile-source @stage3-proof-default` or generated artifact ref | Potentially excellent if there is a stable generator/registry. | Would need artifact resolution refusal: unknown name, stale artifact, malformed artifact, generator mismatch. | Adds generator/registry output and likely provenance JSON. | Largest: generated artifact, registry/refusal, compile output, reports. | Medium-high unless registry lookup rules are explicit and offline/local-only. | High: needs generator/registry authority and naming lifecycle. | Not ready. No standalone supported artifact exists yet. |

## Generated Artifact Evidence

The finalization proof emits a valid `compiler_profile_id_source` example inside:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json
```

That is evidence of shape, not a standalone caller artifact contract. Current
proofs also embed equivalent source objects in summary JSON. There is no
dedicated file such as:

```text
out/compiler_profile_source.json
```

and no stable generator command intended for external CLI callers.

Therefore a named generated artifact CLI option is premature.

## Recommended Shape

Recommendation: **hold CLI implementation for now**.

When CLI exposure is authorized, prefer:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

where `PATH.json` is a standalone, already-finalized
`compiler_profile_id_source` object.

Do not implement inline JSON as the first CLI surface. Do not implement
discovery/defaulting. Do not infer a profile from source path, environment,
config file, cwd, package descriptor, or profile registry.

## Proposed Future CLI Contract

Allowed future behavior:

```text
No flag:
  legacy_optional
  -> compile as today
  -> manifest.compiler_profile_id absent

--compiler-profile-source PATH.json:
  CLI reads exactly PATH.json
  CLI parses JSON into an object
  CLI passes object unchanged to IgniterLang.compile(..., compiler_profile_source:)
  assembler/orchestrator validation remains authoritative for source shape
```

Rejected future behavior for first CLI card:

```text
--compiler-profile-source-json JSON
--compiler-profile-source-name NAME
--compiler-profile default
auto-discovery from cwd
auto-discovery from source sidecar
ENV-based profile selection
config-file profile selection
profile finalization inside CLI
loader/report status emission
CompatibilityReport profile section
```

## Refusal Contract For Future Path Option

The implementation card must define these refusal paths before code:

| Condition | Recommended CLI status | Artifact behavior | Notes |
| --- | --- | --- | --- |
| Missing `SOURCE` / `--out` | Existing usage refusal | No `.igapp` | Preserve current CLI behavior. |
| Flag present without path | CLI argument refusal | No `.igapp` | Usage text should mention the missing path. |
| Path does not exist | CLI argument/input refusal | No `.igapp` | Do not search fallback locations. |
| Path unreadable | CLI argument/input refusal | No `.igapp` | Do not retry as cwd-relative alternatives beyond the provided path semantics. |
| Invalid JSON | CLI parse refusal | No `.igapp` | Do not emit loader status `malformed`. |
| JSON is not object/hash | Existing compiler profile source refusal or CLI preflight refusal | No profiled `.igapp` | Prefer passing object-only to compile; if preflighted, use compiler-profile-source vocabulary. |
| Source object invalid | Existing `assembler_refused` path | No profiled `.igapp` | Reuse `compiler_profile_source.*` reasons. |
| No flag | Success or normal source OOF | Legacy manifest with no `compiler_profile_id` | Must remain legacy optional. |

## Exact JSON Artifacts To Expect

For future path-based CLI:

Success with valid profile source:

```text
OUT.igapp/manifest.json
OUT.igapp/semantic_ir_program.json
OUT.igapp/compilation_report.json
OUT.igapp/contracts/*.json
OUT.igapp/diagnostics.json
OUT.igapp/requirements.json
OUT.igapp/compatibility_metadata.json
OUT.igapp/classified_ast.json
OUT.igapp/projections.json
CLI proof summary JSON
```

Failure before compile or during assembler validation:

```text
OUT.compilation_report.json
CLI proof summary JSON
```

No loader status report, CompatibilityReport profile section, `.ilk`, receipt,
signing artifact, RuntimeMachine report, cache artifact, or production artifact
should be added by the first CLI exposure card.

## Negative-Token Scan Surface

Any future CLI implementation must scan all written JSON/refusal artifacts for
exact forbidden tokens:

```text
absent_legacy
present_verified
mismatch
malformed
missing_required
runtime_ready
evaluation_ready
gate3_authorized
runtime_authority
production_ready
```

Allowed substring false positives must be documented separately. Existing
allowed examples:

```text
compiler_profile_source.id_digest_mismatch
compiler_profile_source.slot_order_mismatch
runtime_authority_granted=false
compiler_profile_source.runtime_authority_forbidden
```

These are source-validation/check vocabulary, not loader-status or
runtime-readiness fields.

## Option Details

### Option A: Explicit Path To Source JSON

[D] This is the recommended future input shape.

Caller ergonomics:

- Good for shell workflows.
- Auditable: the caller can inspect the exact finalized source object.
- Composable with future generator commands without binding CLI compile to the
  generator.

Refusal behavior:

- CLI owns file/path/JSON parse refusals.
- Assembler/orchestrator remains authoritative for source-object semantic
  refusal.
- Invalid source must refuse before profiled `.igapp` output.

JSON artifacts:

- Success: ordinary `.igapp` plus top-level `manifest.compiler_profile_id`.
- Failure: refusal report only.

Risk:

- Low if no default path, sidecar search, env var, config lookup, or discovery
  is introduced.

Complexity:

- Medium.

Implementation blockers:

- Decide exact flag name.
- Decide parse-refusal report shape.
- Decide stdout/stderr wording.
- Add negative scan over all new outputs.
- Preserve no-flag legacy optional behavior.

### Option B: Inline JSON String

[X] Not recommended for first CLI exposure.

Caller ergonomics:

- Poor due to shell escaping and large structured input.
- High chance of accidental log/shell-history exposure.

Refusal behavior:

- Must handle shell-truncated strings, parse failures, non-object JSON, and
  invalid source object.

JSON artifacts:

- Same as path option, but reports risk echoing raw input.

Risk:

- No discovery/defaulting risk, but higher leakage/noise risk.

Complexity:

- Medium-high because tests must cover quoting/redaction behavior.

### Option C: No CLI Support Yet / Ruby Facade Only

[D] This is the recommended immediate state.

Caller ergonomics:

- Best for programmatic callers who already hold the finalized object.
- Not sufficient for CLI-only users.

Refusal behavior:

- Already proven: Ruby facade invalid source refuses through existing
  assembler/orchestrator path.

JSON artifacts:

- Already scanned post-C3: 88 JSON files, 0 exact forbidden-token hits.

Risk:

- Lowest.

Complexity:

- None.

### Option D: Named Generated Profile-Source Artifact

[X] Not ready.

Caller ergonomics:

- Could be excellent if there were a stable generator or registry.

Current evidence:

- The finalization proof shows the source object shape, but does not produce a
  standalone caller artifact file or a stable generator command.

Risk:

- Without a generator/registry authority, this invites discovery/defaulting by
  another name.

Complexity:

- High.

Implementation blockers:

- Standalone generated artifact contract.
- Generator command/proof.
- Artifact naming and freshness rules.
- Refusal vocabulary for unknown/stale/generated artifact mismatch.
- Negative scan across generator + compile outputs.

## Blockers Before Implementation Authorization

1. Choose exact CLI shape. Recommended: explicit path to source JSON.
2. Create or designate a standalone finalized `compiler_profile_id_source` JSON
   artifact contract. Current summaries are evidence, not caller artifacts.
3. Define CLI path/parse refusal wording without loader-status vocabulary.
4. Define no-flag legacy optional proof acceptance.
5. Define invalid-source refusal acceptance: no `.igapp`, existing
   `assembler_refused` / `compiler_profile_source.*` path.
6. Define all JSON/refusal artifacts that must be scanned.
7. Require exact forbidden-token scan to return 0 hits.
8. Require pressure review for path/file authority widening.
9. Keep profile finalization/discovery/defaulting outside CLI compile.
10. Keep loader/report, CompatibilityReport, golden migration, `.ilk`, receipts,
    signing, dispatch migration, RuntimeMachine, Ledger/TBackend, cache, and
    production behavior out of scope.

## Recommendation

Recommendation: **explicit hold for implementation now**.

Recommended future implementation shape, once blockers are closed:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

Do not implement inline JSON, named generated profile lookup, discovery, or
defaulting as the first CLI surface.

## Handoff

```text
Card: S3-R45-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-cli-exposure-input-shape-options-v0
Status: done

[D] Decisions
- Immediate recommendation is hold: no CLI implementation yet.
- Future CLI exposure should prefer explicit path to a standalone finalized `compiler_profile_id_source` JSON file.
- Inline JSON is not recommended.
- Named generated artifact is not ready because no standalone generated source artifact/generator contract exists.
- Ruby facade only remains the safest current public surface.

[S] Signals
- Current CLI has only `compile SOURCE --out OUT.igapp`.
- C3 Ruby facade already transports caller-supplied finalized source objects.
- C4 regression proves current outputs remain clean: 88 JSON files, 0 exact forbidden-token hits.

[T] Tests / Proofs
- Design-only card; no code/proof command required.
- Evidence read from C2 authorization, C3 implementation, C4 regression, CLI source, `bin/igc`, and finalization proof output.

[R] Recommendation
- Before CLI authorization, close the standalone source artifact contract, parse/refusal wording, no-flag legacy proof, invalid-source no-artifact proof, and full negative scan acceptance.

[Files] Changed
- `igniter-lang/docs/tracks/prop036-cli-exposure-input-shape-options-v0.md`

[Q] Open Questions
- Should a future generator emit a standalone `compiler_profile_id_source.json`, and what command owns it?
- Should CLI parse/path refusals live as CLI argument errors only, or produce `CompilationReport` JSON when `--out` is available?

[X] Rejected
- Inline JSON as first CLI profile-source input.
- Named generated profile lookup before a generator/artifact contract exists.
- Any discovery/defaulting/env/config/sidecar behavior.

[Next] Proposed next slice
- Architect decision: either hold CLI, or authorize a path-based CLI design card that first creates the standalone source artifact contract and refusal matrix.
```

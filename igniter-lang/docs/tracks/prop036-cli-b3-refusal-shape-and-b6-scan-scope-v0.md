# Track: PROP-036 CLI B3 Refusal Shape And B6 Scan Scope v0

Card: S3-R46-C2-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-cli-b3-refusal-shape-and-b6-scan-scope-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

---

## Goal

Resolve `PROP036-CLI-B3` path/parse refusal shape and make the
`B3 -> B6` scan-surface dependency executable before any CLI implementation is
requested.

This track does not authorize implementation.

---

## Sources Read

```text
docs/gates/prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md
docs/tracks/prop036-cli-exposure-input-shape-options-v0.md
docs/discussions/prop036-cli-exposure-design-pressure-v0.md
lib/igniter_lang/cli.rb
experiments/production_compiler_cli/production_compiler_cli.rb
experiments/production_compiler_cli/production_compiler_cli_proof.rb
```

Supplemental local context read because the named CLI files delegate to these
current report builders:

```text
lib/igniter_lang/compiler_orchestrator.rb
lib/igniter_lang/compiler_result.rb
lib/igniter_lang/compilation_report.rb
lib/igniter_lang/diagnostics.rb
lib/igniter_lang/assembler.rb
```

---

## Current Behavior Snapshot

Current package CLI:

```text
igc compile SOURCE --out OUT.igapp
```

Current argument/usage refusal:

```text
exit: non-zero
stdout: empty
stderr: usage or argument message
artifacts: none
```

Current compiler/orchestrator refusal after `SOURCE` and `--out` are accepted:

```text
exit: non-zero
stdout: public compiler_result JSON
stderr: empty unless process-level failure occurs
artifacts: OUT.compilation_report.json
igapp directory: absent
```

Examples already proven by `production_compiler_cli_proof`:

```text
OOF source -> non-zero exit
OOF source -> OUT.compilation_report.json
OOF source -> no OUT.igapp
OOF stdout -> compiler_result JSON
diagnostics -> category/location/stages/warnings preserved
```

---

## Compared Options

| Option | Shape | Strength | Risk | Verdict |
| --- | --- | --- | --- | --- |
| Stderr/exit-code only for all path/parse refusals | Any missing path, unreadable path, invalid JSON, non-object JSON exits with stderr and writes no report | Smallest artifact surface; matches current CLI usage errors | Loses machine-readable report even for compiler source parse/refusal that already has report behavior | Too broad |
| `OUT.compilation_report.json` for all path/parse refusals when `--out` exists | CLI preflight writes report JSON for profile-source path/JSON problems | Machine-readable for every failure | Requires inventing pseudo-compilation reports before compilation starts; risks loader/status vocabulary leakage and fake `stages` semantics | Rejected |
| Hybrid | CLI-owned argument/profile-source file/JSON preflight is stderr-only; compiler/orchestrator refusals keep existing compiler_result/report behavior | Preserves current behavior, avoids fake reports, defines B6 surface precisely | Requires future implementation to classify refusal before invoking compile | Recommended |

---

## Recommended B3 Refusal Shape

[D] Use the hybrid model.

Rule:

```text
Before IgniterLang.compile is called:
  CLI preflight refusals are process-level input refusals.
  They write no CompilationReport and no .igapp.
  They emit stderr only and exit non-zero.

After IgniterLang.compile is called:
  compiler/orchestrator/assembler refusals keep the existing compiler_result
  stdout + OUT.compilation_report.json behavior.
```

Why:

```text
The compiler profile source path is CLI transport input. A missing profile file
or invalid JSON file is not a compilation stage failure. Writing a synthetic
CompilationReport there would blur argument validation, source parsing, loader
status, and compiler diagnostics.
```

---

## Exact Refusal Classes And Cases

### B3-A: Existing Usage / Argument Refusal

Cases:

```text
unknown command
missing SOURCE
missing --out
missing OUT path
--compiler-profile-source present without PATH
unsupported extra flag or trailing argument after the accepted option set
```

Artifact behavior:

```text
no OUT.igapp
no OUT.compilation_report.json
no profile-source report JSON
```

stdout/stderr:

```text
stdout: empty
stderr: stable usage/refusal text
exit: non-zero
```

Recommended future usage line:

```text
Usage: igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Recommended specific message for missing profile path:

```text
igc: missing --compiler-profile-source path
```

### B3-B: Compiler Profile Source Path Refusal

Cases:

```text
PATH does not exist
PATH is a directory or not a regular readable file
PATH cannot be read
```

Artifact behavior:

```text
no OUT.igapp
no OUT.compilation_report.json
no profile-source report JSON
```

stdout/stderr:

```text
stdout: empty
stderr: one stable line
exit: non-zero
```

Recommended message templates:

```text
igc: compiler profile source path not found: PATH
igc: compiler profile source path is not readable: PATH
igc: compiler profile source path is not a file: PATH
```

Message constraints:

```text
do not search fallback paths
do not echo file contents
do not mention loader status
do not use bare forbidden B6 tokens
```

### B3-C: Compiler Profile Source JSON Parse Refusal

Cases:

```text
file bytes are not valid JSON
parsed JSON value is not an object/hash
```

Artifact behavior:

```text
no OUT.igapp
no OUT.compilation_report.json
no profile-source report JSON
```

stdout/stderr:

```text
stdout: empty
stderr: one stable line
exit: non-zero
```

Recommended message templates:

```text
igc: compiler profile source JSON parse failed: PATH
igc: compiler profile source JSON must be an object: PATH
```

Message constraints:

```text
do not echo raw JSON
do not echo parser backtrace
do not use the bare token "malformed"
do not use the bare token "missing_required"
do not emit JSON to stdout/stderr
```

### B3-D: Compiler Profile Source Semantic Refusal

Cases:

```text
parsed JSON object is passed unchanged to IgniterLang.compile
assembler/orchestrator rejects the object as invalid compiler_profile_id_source
```

Examples currently owned by assembler validation:

```text
compiler_profile_source.malformed
compiler_profile_source.wrong_kind
compiler_profile_source.unfinalized
compiler_profile_source.unsupported_namespace
compiler_profile_source.malformed_id
compiler_profile_source.slot_order_mismatch
compiler_profile_source.id_digest_mismatch
compiler_profile_source.runtime_authority_forbidden
compiler_profile_source.dispatch_migration_forbidden
```

Artifact behavior:

```text
OUT.compilation_report.json is written
OUT.igapp is absent
```

stdout/stderr:

```text
stdout: compiler_result JSON with non-ok status
stderr: empty
exit: non-zero
```

Important distinction:

```text
Qualified `compiler_profile_source.*` source-validation reasons are allowed.
Bare loader-status vocabulary is not allowed.
```

### B3-E: Source File / Source Parse Refusal

Cases:

```text
SOURCE cannot be read after SOURCE/--out are accepted
SOURCE parses with Igniter-Lang parse errors
SOURCE compiles to OOF/refusal
```

Artifact behavior:

```text
OUT.compilation_report.json is written by the compiler/orchestrator path
OUT.igapp is absent
```

stdout/stderr:

```text
stdout: compiler_result JSON with non-ok status
stderr: empty unless the process itself fails
exit: non-zero
```

This preserves the current compiler behavior. B3 does not convert source parse
failure into stderr-only behavior.

---

## Artifact Behavior Summary

| Refusal class | Calls `IgniterLang.compile`? | stdout | stderr | `OUT.compilation_report.json` | `OUT.igapp` |
| --- | --- | --- | --- | --- | --- |
| Usage / argument | no | empty | text | no | no |
| Profile source path | no | empty | text | no | no |
| Profile source JSON parse | no | empty | text | no | no |
| Profile source semantic validation | yes | compiler_result JSON | empty | yes | no |
| Source read / source parse / OOF | yes | compiler_result JSON | empty | yes | no |
| Success | yes | compiler_result JSON | empty | no external refusal report; report inside `.igapp` | yes |

---

## B3 -> B6 Scan-Surface Mapping

Recommended forbidden exact tokens:

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

Scan rule:

```text
Scan every artifact or stream that a CLI proof records or writes. The scan is
exact-token based; qualified source-validation strings such as
`compiler_profile_source.malformed` and
`compiler_profile_source.id_digest_mismatch` are not bare loader-status tokens,
but must be documented as allowed qualified source-validation vocabulary.
```

Mapping:

| Scenario | Files / streams to scan |
| --- | --- |
| No-flag legacy success | `OUT.igapp/**/*.json`, stdout compiler_result JSON, proof summary JSON |
| Valid `--compiler-profile-source` success | `OUT.igapp/**/*.json`, stdout compiler_result JSON, proof summary JSON |
| Usage / missing flag path | stderr text, proof summary JSON |
| Profile source path not found | stderr text, proof summary JSON |
| Profile source not readable / not a file | stderr text, proof summary JSON |
| Invalid JSON | stderr text, proof summary JSON |
| JSON value not object | stderr text, proof summary JSON |
| Invalid compiler_profile_id_source object | `OUT.compilation_report.json`, stdout compiler_result JSON, proof summary JSON |
| Source parse / source OOF refusal | `OUT.compilation_report.json`, stdout compiler_result JSON, proof summary JSON |

B6 must fail if any of these appear as bare status/readiness/authority tokens in
CLI-written JSON, stdout JSON, stderr text, or proof summary JSON.

B6 must also fail if CLI path/JSON preflight adds any new JSON refusal artifact
without adding it to the scan list.

---

## Acceptance Tests / Proofs For Future Implementation

Future implementation authorization should require a proof matrix with at least:

| ID | Case | Expected |
| --- | --- | --- |
| B3-1 | no flag, valid source | exit zero; legacy `.igapp`; no `manifest.compiler_profile_id` |
| B3-2 | valid profile source path, valid source | exit zero; `.igapp`; `manifest.compiler_profile_id` present |
| B3-3 | `--compiler-profile-source` without path | non-zero; stdout empty; stderr message; no report; no `.igapp` |
| B3-4 | profile source path missing | non-zero; stdout empty; stderr message; no report; no `.igapp` |
| B3-5 | profile source path is directory or unreadable | non-zero; stdout empty; stderr message; no report; no `.igapp` |
| B3-6 | profile source JSON invalid | non-zero; stdout empty; stderr message; no report; no `.igapp` |
| B3-7 | profile source JSON array/string/null | non-zero; stdout empty; stderr message; no report; no `.igapp` |
| B3-8 | profile source object wrong kind | non-zero; stdout compiler_result JSON; `OUT.compilation_report.json`; no `.igapp`; reason uses `compiler_profile_source.*` |
| B3-9 | profile source object requests runtime authority | non-zero; stdout compiler_result JSON; `OUT.compilation_report.json`; no `.igapp`; reason uses `compiler_profile_source.runtime_authority_forbidden` |
| B3-10 | invalid `.ig` source with valid profile source path | non-zero; stdout compiler_result JSON; `OUT.compilation_report.json`; no `.igapp` |
| B6-1 | all above outputs | forbidden exact-token scan PASS |
| B6-2 | scanner fixture with injected bare `present_verified` | forbidden exact-token scan FAIL |
| B6-3 | scanner fixture with qualified `compiler_profile_source.id_digest_mismatch` | allowed qualified source-validation string documented |

Proof summary should include:

```text
kind
format_version
track
status
cases
commands
exitstatus
stdout_shape
stderr_text
artifact_paths
scan_surface
forbidden_token_scan
allowed_qualified_source_validation_terms
```

---

## Exact Blockers Before Implementation Authorization

Implementation authorization must remain held until these closure bars exist:

1. `PROP036-CLI-B1`: standalone finalized
   `compiler_profile_id_source` caller artifact contract is defined or proven by
   a named document/proof and, if proof-based, a dedicated JSON file that can be
   used as `PATH.json`.
2. `PROP036-CLI-B2`: first CLI shape remains exactly
   `--compiler-profile-source PATH.json`; no inline JSON, named lookup, config,
   env, sidecar, discovery, or defaulting.
3. `PROP036-CLI-B3`: this hybrid refusal shape is accepted or superseded by an
   explicit Architect decision.
4. `PROP036-CLI-B4`: no-flag legacy proof matrix is specified:
   `igc compile SOURCE --out OUT.igapp` remains unchanged and emits no
   `manifest.compiler_profile_id`.
5. `PROP036-CLI-B5`: invalid semantic profile source proof matrix is specified:
   parsed object invalidity refuses before profiled `.igapp` output and uses
   existing `assembler_refused` / `compiler_profile_source.*` vocabulary.
6. `PROP036-CLI-B6`: scan implementation plan is specified exactly from this
   `B3 -> B6` map, including stderr text and proof summary JSON for CLI
   preflight refusals.
7. `PROP036-CLI-B7`: public caller-facing docs card is landed or explicitly
   routed with a pre-implementation closure decision; dev-contract wording alone
   must not be silently treated as public docs.
8. `PROP036-CLI-B8`: transport-only facade/orchestrator contract location is
   landed or explicitly accepted as closed by a gate; future validation widening
   cannot be inferred from CLI transport.
9. `PROP036-CLI-B9`: runtime-pressure review is run after implementation shape
   is proposed and before implementation is accepted as complete.
10. The implementation card must explicitly preserve all non-authorizations:
    no loader/report status, no CompatibilityReport profile section, no `.ilk`,
    no receipt/signing, no dispatch migration, no RuntimeMachine binding, no
    Gate 3 widening, no Ledger/TBackend, no BiHistory, no stream/OLAP production
    executor, no production cache, no production behavior.

---

## Non-Authorizations

This track does not authorize:

```text
editing lib/igniter_lang/cli.rb
editing bin/igc
adding --compiler-profile-source
path loading in CLI
JSON parsing in CLI
profile finalization
profile discovery/defaulting
loader/report implementation
CompatibilityReport profile section
.igapp golden migration
.ilk changes
CompilationReceipt links
signing
compiler dispatch migration
RuntimeMachine binding
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP production executor
production cache
production behavior
```

---

## Handoff

```text
Card: S3-R46-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: prop036-cli-b3-refusal-shape-and-b6-scan-scope-v0
Status: done

[D] Decisions
- Recommend hybrid B3 refusal shape.
- CLI-owned profile-source argument/path/JSON preflight refuses with stderr only,
  non-zero exit, and no artifacts.
- Compiler/orchestrator/assembler refusals keep existing compiler_result stdout
  plus OUT.compilation_report.json behavior.

[S] Signals
- B6 scan surface is now executable because each B3 class maps to exact streams
  and artifacts.
- Qualified `compiler_profile_source.*` source-validation vocabulary remains
  distinct from bare loader-status/runtime-readiness tokens.

[T] Tests / Proofs
- Documentation-only design.
- No code or proof implementation run.

[R] Risks / Recommendations
- Do not allow a future implementation to introduce a JSON preflight refusal
  artifact without updating B6.
- Do not treat dev-contract wording for B7/B8 as public docs unless a gate says
  so explicitly.

[Next]
- Close B1 artifact contract shape, then request a bounded CLI implementation
  card only after B3/B6/B7/B8 closure bars are satisfied.
```

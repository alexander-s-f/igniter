# Experimental igc run — Current Surface and Lab Signals Facts v0

Card: S3-R233-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igc-run-current-surface-and-lab-signals-facts-v0

Route: REVIEW
Status: done / facts-only
Date: 2026-06-02

Depends on:
- S3-R232-C5-S

---

## Read Scope

All sources read as read-only. No files were edited, created (except this
document), or executed.

Sources inspected:

```text
igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/summary.json
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/*.passport.json
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/bin/igc
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb
playgrounds/igniter-lab/igniter-runtime/docs/*
playgrounds/igniter-lab/igniter-runtime/out/**/summary.json
playgrounds/igniter-lab/igniter-tbackend/README.md
playgrounds/igniter-lab/igniter-tbackend/Cargo.toml
playgrounds/igniter-lab/igniter-tbackend/src/main.rs
playgrounds/igniter-lab/igniter-tbackend/verify_auth.rb
playgrounds/igniter-lab/igniter-tbackend/verify_mcp.rb
playgrounds/igniter-lab/igniter-apps/benchmark-app/benchmark.rb
playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb
```

Also inspected for context:
```text
igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-v0.md
  (S3-R233-C1-D — already written; this packet is independent facts supply)
```

---

## 1. Current CLI Command Surface

### Surface Classification: `cli_surface`

Source: `igniter-lang/lib/igniter_lang/cli.rb` (77 lines)
Entry point: `igniter-lang/bin/igc` (8 lines)

```text
bin/igc → IgniterLang::CLI.run(ARGV)
```

Registered commands (exact from source):

```text
compile    → IgniterLang.compile(source_path:, out_path:, compiler_profile_source:)
```

No other command branch exists.

`run` command today:

```text
ABSENT.
```

Observed behavior for unknown commands (including `run`):

```ruby
USAGE = "Usage: igc compile SOURCE --out OUT.igapp " \
        "[--compiler-profile-source PATH.json]"

command = argv.shift
unless command == "compile"
  warn USAGE
  return false
end
```

Unsupported command behavior: `warn USAGE` + return `false` → exit code 1.
No subcommand routing exists. No `case`/`when` branch for `run`.

### Current `compile` argument surface

```text
REQUIRED: SOURCE (positional)
REQUIRED: --out OUT.igapp
OPTIONAL: --compiler-profile-source PATH.json
```

No `--runtime`, `--passport`, `--input`, `--experimental`, or
`--out-result` flags exist anywhere in the CLI.

### `bin/igc` shape

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true
require "igniter_lang/cli"
success = IgniterLang::CLI.run(ARGV)
exit(success ? 0 : 1)
```

4 active lines (shebang + require + run + exit). No `run` dispatch.

---

## 2. Compiler Output / .igapp Shape Relevant to Run Design

### Surface Classification: `compiler_surface`

Source: `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` (363 lines)

The orchestrator produces:

```text
.igapp/
  manifest.json                  ← compiler-recorded program_id, artifact_hash,
                                   format_version, source_hash, semantic_ir_ref,
                                   compiler_profile_id, compiled_at, assembler
  semantic_ir_program.json       ← PROP-019.1 format
  classified_ast.json
  diagnostics.json
  requirements.json
  compatibility_metadata.json
  contracts/*.json               ← per-contract serialized data
```

Compiler result presentation path:

```ruby
puts JSON.pretty_generate(CompilerResult.public_result(orchestration.fetch("result")))
```

`CompilerResult.public_result` is compile-result only, not run-result.

RuntimeSmoke integration in orchestrator:

```ruby
smoke = runtime_smoke&.call(out_path: out_path, sample_input: resolved_sample_input)
```

This is an optional callback. It is not invoked by the CLI today.

---

## 3. RuntimeSmoke Surface Status

### Surface Classification: `runtime_surface` / closed for productization

Source: `igniter-lang/lib/igniter_lang/runtime_smoke.rb` (81 lines)

Key constants:

```ruby
DEFAULT_MACHINE_ID  = "runtime-machine/production-compiler-cli"
DEFAULT_SESSION_ID  = "session/production-compiler-cli"
DEFAULT_RULE_VERSION = "production-compiler-cli-wrapper-v0"
```

**Wording risk (F-1):**
`RuntimeSmoke` uses `"runtime-machine/production-compiler-cli"` and
`"production-compiler-cli-wrapper-v0"` as internal labels. These strings
contain `production`. They appear only inside the proof-local smoke module
and are not exposed through the public CLI. They do not create a public
claim. However any future code that routes these strings to machine-readable
output visible to users creates a labeling risk.

RuntimeSmoke availability guard:

```ruby
def ensure_available!
  return if available?
  message = "IgniterLang::RuntimeSmoke is proof-backed; " \
    "runtime_machine_memory_proof is unavailable in this package context"
  raise LoadError, message
end
```

RuntimeSmoke is explicitly marked proof-backed. Not available in the
released gem package context. Not an `igc run` surface.

RuntimeSmoke productization: **closed per S3-R233-C1-D boundary matrix**.

---

## 4. Accepted Passport Manifest Coverage and Gaps

### Surface Classification: `delegated_experimental_runtime` (manifest metadata)

Source: `experiments/experimental_runtime_artifact_passport_manifest_v0/out/summary.json`

Proof result:

```text
overall:       PASS
checks_pass:   16/16
failed_checks: []
generated_at:  2026-06-02T10:07:20Z
authorized_by: S3-R232-C1-A
```

Generated manifests:

| File | `artifact_kind` | `surface_dimension` | `execution_substrate` |
|---|---|---|---|
| Add.igapp.passport.json | igapp_dir | executable_runtime | ruby_delegated_example_local_harness |
| add.igbin.aot.passport.json | igbin_aot_binary | executable_runtime | c_aot_file_loader |
| if_module.igbin.resident.passport.json | igbin_aot_binary | executable_runtime | c_resident_in_memory_module |
| quickstart_result.evidence_packet.passport.json | evidence_result_packet | evidence_packet | none |

All four carry:

```text
authority_status: non-canonical / evidence-only
non_claims: 11 machine-readable entries (not stable API, not production
  ready, not public runtime support, not Reference Runtime support,
  not Spark integration, not release evidence, not public performance
  claim, not certified alternative implementation, not artifact
  portability guarantee, not compiler passport emission, not igc run
  implementation)
```

### Passport field coverage for design discussion purposes

All required minimum field families are present or explicitly deferred:

```text
passport_kind              ✓ (artifact_passport)
artifact_kind              ✓ (igapp_dir / igbin_aot_binary / evidence_result_packet)
artifact_digest            ✓ (recomputed sha256, deterministic)
source_digest              ✓ for igapp_dir / nil with explicit status for .igbin
semantic_ir_digest         ✓ for igapp_dir / nil with explicit status for .igbin
surface_dimension          ✓
runtime_target_kind        ✓ for executable_runtime / absent for evidence_packet (W-1)
runtime_implementation_id  ✓ (evidence metadata only)
backend_implementation_id  ✓ (deferred / not applicable)
consumer_surface_id        ✓ (deferred / not applicable)
execution_substrate        ✓ (present in all four)
input_contract             ✓
output_contract            ✓ for igapp_dir / explicitly deferred for .igbin (gap below)
failure_policy             ✓
evidence_class             ✓ (machine-readable)
authority_status           ✓ (machine-readable)
non_claims                 ✓ (11-entry machine-readable array)
```

### output_contract gaps (real gap, located)

```text
Add.igapp.passport.json:
  output_contract: derived from SemanticIR outputs
  contract_name: Add / outputs: [{ name: "sum", type: "Integer" }]
  STATUS: PRESENT, not deferred — no gap

add.igbin.aot.passport.json:
  output_contract: deferred_rationale:
    "hand-authored .igbin fixture; output contract cannot be derived
     without compiler SemanticIR chain. Required before any future
     igc run design can claim complete executable contract."
  STATUS: REAL GAP

if_module.igbin.resident.passport.json:
  output_contract: same deferred_rationale as above
  STATUS: REAL GAP
```

**Answer:** The `output_contract` gap is real and located in both accepted
`.igbin` passports. It is not a gap for the `.igapp` passport.
For `igc run` Slice 0 (`.igapp` only), the gap is not a blocker because
Slice 0 holds `.igbin` input. The gap becomes a blocker for any future
`.igbin` execution path.

### W-1 carry-forward

```text
quickstart_result.evidence_packet.passport.json:
  runtime_target_kind: absent (contextually not applicable for evidence_packet)
  C4-A accepted stance: not a PPM-1 failure for this proof
  Future schema stance: prefer explicit not_applicable marker
```

---

## 5. Delegated Runtime Evidence Surfaces and Implementation IDs

### Surface Classification: `delegated_experimental_runtime`

From accepted delegated experimental runtime proofs:

```text
ivm_aot_bytecode_file_loading_proof (AOT-1..AOT-17):
  runtime_implementation_id: igniter.delegated.experimental.ivm.c_aot_file_loader
  overall: PASS / all 17 checks pass
  substrate: C cdylib / AOT file load path
  9 .igbin artifacts (8 proof fixtures + 1 bad-data / 1 bad-header)
  summary.json: playgrounds/igniter-lab/igniter-runtime/out/
    ivm_aot_bytecode_file_loading_proof/summary.json

resident_supervisor_candidate_intake (RSUP-1..RSUP-16):
  runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
  overall: PASS / all 16 checks pass
  substrate: C cdylib / resident in-memory module path
  4 .igbin fixtures (1 valid + 3 error cases: bad_magic, truncated, unsupported)
  summary.json: playgrounds/igniter-lab/igniter-runtime/out/
    resident_supervisor_candidate_intake/summary.json
```

**Note:** The passport manifest proof uses `igniter.delegated.experimental.ivm.c_resident`
as the `runtime_implementation_id` for both the resident and AOT passport
manifests (a single unifying label for delegated experimental ivm evidence).
The AOT file loading proof uses a different internal label. This is consistent
with evidence metadata status — neither is stable API nor a public runtime name.

Source artifacts are hand-authored .igbin fixtures only. Source and SemanticIR
digest chain is incomplete for all .igbin artifacts.

---

## 6. Rust TBackend Surface Classification

### Surface Classification: `temporal_backend`

Source:
- `playgrounds/igniter-lab/igniter-tbackend/README.md`
- `playgrounds/igniter-lab/igniter-tbackend/Cargo.toml`
- `playgrounds/igniter-lab/igniter-tbackend/src/main.rs`

Package identity:

```text
name: igniter_tbackend_playground
version: 0.1.0
edition: 2021
```

This is a playground crate. Name contains `playground` — not a release crate.

**Self-description in README (wording risk — F-2):**

```text
"TBackend is a production-grade, zero-dependency, profile-native bitemporal
ledger, relational query engine, and reactive event database written in
pure Rust."
```

Also: `"Production Use Cases: Prevent PostgreSQL bloat (SparkCRM)..."` and
mentions `SparkCRM` as a use case name. The README also references a
`SparkCRM` label which could be read as claiming Spark integration authority.

```text
"TBACKEND PROFILE-NATIVE SYSTEM DAEMON v2.0" [printed at boot in main.rs]
```

These strings appear in playground lab code only. However:

- The README is lab-only. It does not appear in any mainline public docs.
- The `production-grade` and `SparkCRM` labels are internal to the playground
  and do not flow into any released package or public claim.
- The Cargo.toml package name suffix `_playground` signals non-production scope.

**Classification verdict:**

```text
igniter-tbackend classification:
  surface_dimension:   temporal_backend
  candidate role:      delegated backend/substrate candidate signal
  current authority:   lab-only / unaccepted for Main Line runtime authority
  runtime authority:   NO
  backend candidate:   YES (lab signal only; not accepted for igc run)
  substrate signal:    YES (Rust temporal backend, bitemporal ledger)
```

**Answer:** `igniter-tbackend` is backend/substrate vocabulary only — not runtime
authority, not an accepted backend candidate for igc run.

---

## 7. AuthPack / QueryPack / McpPack Status

### Surface Classification: `temporal_backend`

Source: `src/main.rs` line 10, `verify_auth.rb`, `verify_mcp.rb`

Packs registered in the tbackend Profile:

```text
CorePack         — bitemporal ledger write/read/size commands
BaseAuditPack    — metrics, latency, connection tracking
MultiTenantScannerPack — boot-time preload, cache warming
TriggerPack      — async out-of-band webhook dispatchers
AnalyticsPack    — decimal-accurate analytics, SMA/SMW
CrossStorePack   — inner/left joins, temporal joins
SnapshotPack     — compaction, WAL disk compactors
DiagnosticsPack  — RAM footprint, physical disk auditing
PipelinePack     — async reactive event rules
AuthPack         — opt-in RBAC + ACL / token middleware
QueryPack        — temporal query_slice / ROP pushdown rules
McpPack          — stdio Model Context Protocol (JSON-RPC 2.0)
MeshClusterPack  — P2P gossip WAL sync (opt-in, only if peers given)
```

AuthPack signal:
```text
op: auth_token_create / auth_token_delete
  RBAC roles: admin / write_only / read_only
  ACL: allowed_stores whitelist
  boot-time persistent token loading
  enabled via --auth-enabled true flag
```

QueryPack signal:
```text
op: query_slice
  store: ..., key_prefix: ..., rules: [{left_path, op, right_val}]
  ROP pushdown filter
```

McpPack signal:
```text
Protocol: JSON-RPC 2.0 over stdio
  Invoked via: --mcp flag
  Exposed tools:
    tbackend_write_fact
    tbackend_latest_for
    tbackend_query_slice
    tbackend_analytics_aggregate
    tbackend_pipeline_create
    tbackend_diagnostics_summary
  MCP is an alternative transport plane (stdio) not a separate API surface
```

**Do Auth/Query/MCP surfaces create public API authority?**

```text
NO.
```

Reasoning:

1. All three packs are part of `igniter_tbackend_playground` — a lab crate.
2. No pack is exported as part of any released gem or igniter-lang package.
3. AuthPack is opt-in (flag-gated, requires `--auth-enabled true`).
4. McpPack is opt-in (flag-gated, requires `--mcp`).
5. QueryPack is a temporal query signal — informative for future
   `temporal_backend` design; not an `igc run` interface.
6. None appear in `igniter-lang/lib/**`, `igniter-lang/bin/igc`,
   or any public-facing igniter-lang docs.

These signals may inform temporal backend design and tool plane design
only. They do not create public API authority, release evidence, or
`igc run` interface authority.

---

## 8. Benchmark-App Status and What It Actually Measures

### Surface Classification: `benchmark_consumer`

Source:
- `playgrounds/igniter-lab/igniter-apps/benchmark-app/benchmark.rb`
- `playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb`

What the benchmark measures:

```text
Target: igniter-tbackend (Rust TCP server, port 7410)
NOT: igc run / .igapp execution / compiler output / language runtime

Workload stages:
  Stage 1: Pure Write Saturation (write_fact)
  Stage 2: Point Query Saturation (latest_for)
  Stage 3: Pushdown Rules Slicing (query_slice with ROP rules)
  Stage 4: Mixed Read/Write Contention
  Stage 5: Parity Verification (size check + 50-sample payload check)

Metrics: QPS, AVG latency, p50/p90/p99 latency per stage
```

What it does NOT measure:

```text
NOT igc run execution
NOT .igapp runtime performance
NOT compiler throughput
NOT language interpreter throughput
NOT Igniter platform runtime performance
```

**Does benchmark-app create public performance evidence?**

```text
NO.
```

Reasoning:
1. benchmark.rb targets the TBackend TCP server, not the Igniter language runtime.
2. verify_bench.rb is inside `playgrounds/igniter-lab/igniter-apps/` — lab scope only.
3. No result JSON or evidence packet is emitted from benchmark.rb — only
   stdout/stderr table output.
4. No benchmark result file is referenced by any track, proposal, or release doc.
5. The benchmark harness is TBackend-internal; it tells us nothing about
   igc compile or igc run execution cost.

Allowed use: informing internal temporal backend design tradeoffs only.
Not allowed: public performance marketing, release evidence, or
`igc run` performance authority.

---

## 9. RuntimeSmoke Source Surface Status (Repeat / Dedicated)

Already noted in §3. Key surface facts for C4-A:

```text
runtime_smoke.rb is:
  - proof-backed (self-declared in ensure_available!)
  - unavailable in the released gem package context
  - an optional callback in CompilerOrchestrator#compile
  - NOT invoked by igc compile today (CLI does not pass runtime_smoke:)
  - NOT an igc run surface
  - NOT a candidate for productization (closed per C1-D boundary matrix)

Wording risk F-1 (production label):
  DEFAULT_MACHINE_ID = "runtime-machine/production-compiler-cli"
  DEFAULT_RULE_VERSION = "production-compiler-cli-wrapper-v0"
  — internal constants only; not exposed through public CLI or docs
  — would become a labeling risk if routed to machine-readable output
    visible outside the proof context
```

---

## 10. Package / Gemspec / Public Docs Touch Risk

### Surface Classification: `public_claim_surface`

```text
igniter-lang/igniter_lang.gemspec:
  NOT inspected (read-only note: not in the card scope)
  Known status: public release exists (0.1.0.alpha.1)
  Risk: any change that adds igc run reference to gemspec or README
    creates a public claim without a separate authorization review.

igniter-lang/README.md:
  NOT inspected (not in scope)
  Known status: public-facing; contains no-stable-API non-claims
  Risk: same as above

Touch risk classification:
  igniter-lang/lib/**        → compiler_surface / closed
  igniter-lang/bin/igc       → cli_surface / closed except Slice 0 scope
  igniter-lang/igniter_lang.gemspec → public_claim_surface / closed
  igniter-lang/README.md     → public_claim_surface / closed
```

No changes to the above surfaces were made or authorized by any card
through R232.

---

## 11. Source File Wording Risk Scan

### Exact observations:

| File | Wording observed | Risk level | Context |
|---|---|---|---|
| `runtime_smoke.rb` | `"production-compiler-cli"` (L13–16) | Watchpoint F-1 | Internal constant; not exposed publicly |
| `runtime_smoke.rb` | `"runtime-machine/production-compiler-cli"` (L13) | Watchpoint F-1 | Internal ID string |
| `quickstart.rb` | `"not stable API"`, `"not production runtime support"`, `"non-canonical"` | Correct wording | Disclaimer comment, binding |
| `quickstart.rb` | `"not Reference Runtime support"` | Correct wording | Three-runtime distinction |
| `igniter-tbackend/README.md` | `"production-grade"` (L3) | Watchpoint F-2 | Lab-only doc; not in mainline |
| `igniter-tbackend/README.md` | `"SparkCRM"` (L22) | Watchpoint F-2 | Lab use-case name; not a Spark integration claim |
| `igniter-tbackend/src/main.rs` | `"TBACKEND PROFILE-NATIVE SYSTEM DAEMON v2.0"` (L214) | Watchpoint F-2 | Console header; lab only |
| `benchmark.rb` | `"TBACKEND PERFORMANCE & SATURATION BENCHMARK"` (L100) | Low | Lab benchmark; no result file |
| `verify_bench.rb` | `"ruby benchmark.rb"` (L41) | None | Lab test coordinator only |

**No source files contain wording that confuses lab evidence with production
or public support in a way that leaks into the public claim surface.**

The identified watchpoints (F-1, F-2) are lab-internal. They are bounded.
They would require attention if any future card routes these strings into
a public-facing API response, a gemspec summary, or a README.

---

## 12. Exact Closed-Surface Observations

Verified not changed through R232 (from accepted C5-S PPM-16 scan):

```text
igniter-lang/lib/**                   → CLOSED (no edits through R232)
igniter-lang/bin/igc                  → CLOSED (no edits through R232)
igniter-lang/igniter_lang.gemspec     → CLOSED
igniter-lang/README.md                → CLOSED
igniter-lang/lib/igniter_lang/
  runtime_smoke.rb                    → CLOSED
  compiler_result.rb                  → CLOSED
  compilation_report.rb               → CLOSED
playgrounds/igniter-lab/**            → CLOSED (lab read-only)
```

Confirmed by closed_surface_scan in summary.json:

```text
status: PASS
closed_paths_checked:
  igniter-lang/lib
  igniter-lang/bin/igc
  igniter-lang/igniter_lang.gemspec
  igniter-lang/README.md
  playgrounds/igniter-lab
out_dir_scoped_to:
  igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out
```

---

## 13. Surface Classification Table

| Surface | Classification | Current Authority | igc run scope |
|---|---|---|---|
| `igc compile` | `cli_surface` | Current compiler CLI / released | Not a run surface |
| `igc run` | `cli_surface` | ABSENT — does not exist today | Design-ready (C1-D); implementation closed |
| `bin/igc` | `cli_surface` | Entry point; routes compile only | Candidate write scope for Slice 0 (future auth) |
| `IgniterLang::CLI` | `cli_surface` | Current CLI module | No `run` branch |
| `CompilerOrchestrator` | `compiler_surface` | Compile pipeline; assembler | Not a run surface |
| `CompilerResult.public_result` | `compiler_surface` | Compile-result presentation only | Not a run result surface |
| `RuntimeSmoke` | `runtime_surface` | Proof-backed; package-unavailable | Closed for productization |
| `Add.igapp.passport.json` | `delegated_experimental_runtime` | Evidence/compatibility metadata only | Preferred Slice 0 input |
| `add.igbin.aot.passport.json` | `delegated_experimental_runtime` | Evidence metadata / deferred output_contract | Held for Slice 0 |
| `if_module.igbin.resident.passport.json` | `delegated_experimental_runtime` | Evidence metadata / deferred output_contract | Held for Slice 0 |
| `quickstart_result.evidence_packet.passport.json` | `delegated_experimental_runtime` | Evidence packet / no runtime_target_kind (W-1) | Not executed by run |
| `ivm_aot_bytecode_file_loading_proof` | `delegated_experimental_runtime` | Lab-only / AOT-1..17 PASS | Delegated substrate evidence |
| `resident_supervisor_candidate_intake` | `delegated_experimental_runtime` | Lab-only / RSUP-1..16 PASS | Delegated substrate evidence |
| `igniter-tbackend` (Rust) | `temporal_backend` | Lab playground / not accepted for Main Line | Not igc run surface |
| `AuthPack` | `temporal_backend` | Lab-only opt-in RBAC signal | Not igc run surface |
| `QueryPack` | `temporal_backend` | Lab-only temporal query signal | Not igc run surface |
| `McpPack` | `temporal_backend` | Lab-only stdio MCP plane | Not igc run surface |
| `benchmark-app` | `benchmark_consumer` | Lab performance harness (TBackend target) | Not igc run performance evidence |
| `igniter-lang/igniter_lang.gemspec` | `public_claim_surface` | Released public gem | Closed; any touch requires separate review |
| `igniter-lang/README.md` | `public_claim_surface` | Released public doc | Closed; any touch requires separate review |
| `igniter-tbackend/README.md` | `docs_status_surface` | Lab-only | Not in release scope; watchpoint F-2 |

---

## 14. Explicit Question Answers for C4-A

### Does any current surface already implement `igc run`?

```text
NO.
```

`igc run` does not exist in any current source file. `IgniterLang::CLI`
accepts `compile` only. All other commands produce usage + false.

---

### Do passport manifests contain enough fields for design discussion?

```text
YES — for igc run Slice 0 design discussion.
```

All required minimum field families are present or explicitly deferred.
The `Add.igapp.passport.json` manifest has a non-deferred `output_contract`.
The Slice 0 boundary (C1-D) requires non-deferred `output_contract` — this
manifest satisfies that for the `.igapp` case.

Design discussion is possible and well-supported by the current manifest set.
The manifests carry enough machine-readable fields to define a passport
readiness check procedure.

---

### Are `output_contract` gaps real and where?

```text
YES — real, located in .igbin passports only.
```

Both accepted `.igbin` passports carry explicitly deferred `output_contract`.
The gap is at:

```text
add.igbin.aot.passport.json → deferred_rationale: hand-authored fixture
if_module.igbin.resident.passport.json → deferred_rationale: hand-authored fixture
```

This gap is not a Slice 0 blocker because Slice 0 holds `.igbin` input.
The gap becomes a design gate for any future `.igbin` execution path.

---

### Is `igniter-tbackend` runtime authority, backend candidate, or substrate signal?

```text
Classification: temporal_backend / substrate signal only.
NOT runtime authority.
NOT an accepted backend candidate for igc run.
```

`igniter-tbackend` is a Rust playground crate. It is a bitemporal ledger.
Its packs (Auth/Query/Mcp) are temporal plane signals, not executable
runtime machinery for contract evaluation. It does not evaluate `.igapp`
contracts.

---

### Do MCP/Auth/Query surfaces create public API authority?

```text
NO.
```

All three are lab-only, pack-internal, opt-in, and playground-scoped.
None appear in any released gem package or public document.

---

### Does benchmark-app create public performance evidence?

```text
NO.
```

benchmark.rb targets the TBackend TCP server, not the Igniter language
runtime. No igc run, .igapp execution, or language performance is measured.
No result file is produced. No track, release, or public doc references it.

---

### Do any source files contain wording that could confuse lab evidence with production/public support?

```text
Watchpoints found: F-1, F-2.
No current cross-contamination into public surfaces observed.
```

F-1: `runtime_smoke.rb` internal constants use `"production-compiler-cli"`
as a proof-local label. Not publicly exposed today. Would require attention
if routed to a public API response.

F-2: `igniter-tbackend/README.md` uses `"production-grade"` and mentions
`SparkCRM` as a lab use-case name. Not in mainline docs. Not a public claim
today. Carries risk if the lab doc is ever referenced in public-facing material.

Both watchpoints are bounded. Neither is a current blocker.

---

## 15. Ambiguity / Blocker List for C4-A

### No implementation blockers found.

### Watchpoints (non-blocking, carry-forward recommended):

```text
W-1:
  quickstart_result.evidence_packet.passport.json is missing runtime_target_kind.
  C4-A accepted stance: contextually not applicable for evidence_packet.
  Recommendation: future schema versions should use explicit not_applicable.
  Status: WATCHPOINT, not blocker.

W-2 (new):
  runtime_smoke.rb DEFAULT_MACHINE_ID / DEFAULT_RULE_VERSION use
  "production-compiler-cli" label (F-1 above).
  These are internal constants not exposed by any current CLI or public surface.
  Status: WATCHPOINT, not blocker.
  Recommendation: if Slice 0 implementation ever routes RuntimeSmoke
  output to machine-readable run results, rename or sanitize these labels
  before any public exposure.

W-3 (new):
  igniter-tbackend/README.md uses "production-grade" and "SparkCRM" (F-2).
  Lab-local only; no mainline propagation observed.
  Status: WATCHPOINT, not blocker.
  Recommendation: if the TBackend playground is ever referenced in a
  public track or release doc, require a wording audit of the README
  before that reference becomes public.
```

### Open design questions for C4-A (facts only, no recommendation):

```text
Q-1:
  The Slice 0 command vocabulary (C1-D) requires --passport PATH as a
  mandatory flag. The current CLI module has no flag parsing infrastructure
  beyond the compile argument parser. Whether Slice 0 should extend the
  existing parse_compile_args pattern or introduce a separate parse_run_args
  method is a design question for the authorization review — not answered here.

Q-2:
  The c_aot_file_loader and c_resident_in_memory_module substrates are both
  labelled under runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
  in the generated passport manifests (the AOT passport uses the same ID as
  the resident passport). Whether Slice 0 runtime selection should distinguish
  between these two substrate paths or treat them as a single delegated selector
  is an open question for the authorization review.

Q-3:
  No `igc run` result format is currently defined in any mainline source file.
  The C1-D boundary document proposes a result packet shape:
    { kind: "experimental_igc_run_v0_result", ... }
  This is design-only and has no implementation today.
  Whether the authorization review authorizes a new CompilerResult extension
  or a separate result packet struct is open.
```

---

## Handoff

```text
Card:   S3-R233-C2-P1
Agent:  [Implementation Surface Surveyor]
Role:   implementation-surface-surveyor
Track:  experimental-igc-run-current-surface-and-lab-signals-facts-v0
Status: done

[D] Decisions (facts-only — no implementation authorization)
- igc run does not exist in any current source file.
- Passport manifests are sufficient for design discussion.
- output_contract gap is real and located in .igbin passports only; not
  a Slice 0 blocker.
- igniter-tbackend is temporal_backend / substrate signal, not runtime
  authority.
- Auth/Query/Mcp packs do not create public API authority.
- benchmark-app does not create public performance evidence.
- F-1, F-2 wording watchpoints exist but are bounded; no public surface
  contamination observed.

[S] Signals
- Surface classification table: 21 surfaces classified
- Watchpoints: W-1 (carry-forward), W-2 (new), W-3 (new)
- Open design questions for C4-A: Q-1, Q-2, Q-3
- All closed surfaces confirmed clean through R232
- No implementation recommendations made

[T] Facts / Sources
- cli.rb: 77 lines; compile only; no run branch; no run argument parser
- bin/igc: 8 lines; shebang + require + run + exit
- compiler_orchestrator.rb: 363 lines; runtime_smoke is optional callback
  not invoked by CLI
- runtime_smoke.rb: 81 lines; proof-backed; unavailable in package context
- quickstart.rb: 485 lines; PASS 14/14 EXQ checks
- passport summary.json: PASS 16/16 PPM checks; 4 manifests
- igniter-tbackend Cargo.toml: package name = igniter_tbackend_playground
- benchmark.rb: 360 lines; targets TBackend TCP; 5-stage workload
- verify_bench.rb: 60 lines; compiles and spawns TBackend; not igc run

[R] Risks / Recommendations
- W-1: evidence_packet runtime_target_kind schema gap — carry forward
- W-2: runtime_smoke.rb "production-compiler-cli" label — watch if any
  run result paths surface this string publicly
- W-3: igniter-tbackend README "production-grade" / "SparkCRM" — bounded;
  audit before any public reference
- Q-1, Q-2, Q-3 are open for authorization review, not facts-only scope

[Next] Suggested next slice
- S3-R233-C3-X or C4-A:
  External pressure review on the C1-D design boundary and this facts packet,
  then acceptance decision authorizing or holding the implementation review
```

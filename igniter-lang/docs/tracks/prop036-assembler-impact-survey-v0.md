# Track: PROP-036 Assembler Impact Survey v0

Card: S3-R42-C1-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop036-assembler-impact-survey-v0`
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Architect Supervisor / Codex]`,
`[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Meta Expert]`

---

## Goal

Survey the real compiler/assembler implementation surface for adding top-level
`compiler_profile_id` to `.igapp/manifest.json`, without changing code.

Produce an impact map (files, tests, goldens, risks) and a ready/not-ready
recommendation for C3-A authorization.

---

## Source Evidence Read

| Document | Card |
|----------|------|
| `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md` | S3-R34-C5-P |
| `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md` | S3-R35-C3-A |
| `docs/tracks/prop036-assembler-field-design-plan-v0.md` | S3-R38-C4-P1 |
| `docs/tracks/prop036-artifact-hash-ordering-proof-v0.md` | S3-R37-C5-P |

Implementation code read (no edits):

| File | Purpose |
|------|---------|
| `lib/igniter_lang/assembler.rb` | Primary assembler — `build_artifact`, `Canonical.hash` |
| `lib/igniter_lang/compiler_orchestrator.rb` | Orchestrator — wires assembler into compile pipeline |
| `experiments/runtime_machine_memory_proof/compiled_program.rb` | Loader — reads `manifest.json`, exposes `artifact_hash` |

---

## Exact Change Surface — Assembler Only

### Primary file: `lib/igniter_lang/assembler.rb`

One method: **`build_artifact`** (lines 121–184).

Current structure:

```ruby
def build_artifact(case_name, report, semantic_ir)
  # ... build contracts, requirements, etc.

  artifact_material = {                              # line 131
    "semantic_ir_program"    => semantic_ir,
    "contracts"              => contracts,
    "compilation_report"     => report,
    "requirements"           => requirements,
    "diagnostics"            => diagnostics,
    "classified_ast"         => classified_ast,
    "compatibility_metadata" => compatibility_metadata
  }
  artifact_hash = Canonical.hash(artifact_material) # line 140 — HASH POINT
  # ...
  manifest = {                                       # line 144
    "kind"                 => "igapp_manifest",
    "format_version"       => "0.1.0",
    # compiler_profile_id ABSENT HERE
    "artifact_hash"        => artifact_hash,
    ...
  }
end
```

Required change per PROP-036 §7 and assembler field design plan [D]:

```ruby
def build_artifact(case_name, report, semantic_ir, compiler_profile_id: nil)
  # ...

  artifact_material = {
    "semantic_ir_program"    => semantic_ir,
    "contracts"              => contracts,
    "compilation_report"     => report,
    "requirements"           => requirements,
    "diagnostics"            => diagnostics,
    "classified_ast"         => classified_ast,
    "compatibility_metadata" => compatibility_metadata,
    "compiler_profile_id"    => compiler_profile_id   # ADD BEFORE HASH (§7 ordering)
  }
  artifact_hash = Canonical.hash(artifact_material)   # hash covers profiled material

  manifest = {
    "kind"                => "igapp_manifest",
    "format_version"      => "0.1.0",
    "compiler_profile_id" => compiler_profile_id,     # TOP-LEVEL MANIFEST FIELD
    "artifact_hash"       => artifact_hash,
    ...
  }
end
```

Ordering invariant enforced: `compiler_profile_id` enters `artifact_material`
**before** `Canonical.hash` is called. Post-hash annotation is forbidden per
PROP-036 §7.

### Secondary file: `lib/igniter_lang/compiler_orchestrator.rb`

`CompilerOrchestrator#compile` calls:

```ruby
assembled = @assembler.assemble_artifacts(
  case_name: ...,
  report: report,
  semantic_ir: semantic_ir,
  target_dir: out_path
)
```

If `build_artifact` gains a `compiler_profile_id:` keyword, both call sites
(`assemble_case` and `assemble_artifacts`) need to thread it through. The
orchestrator interface (`compile`) would also need a `compiler_profile_id:`
keyword to forward it.

**Scope question for the authorization card:** Is the `compiler_profile_id`
value a proof-local constant baked into the assembler, or a parameter threaded
from the orchestrator? The design plan [D] says the assembler "receives" a
finalized `CompilerProfile`. No `CompilerProfile` finalization logic exists in
`lib/` yet. The simplest assembler-only card would accept `compiler_profile_id`
as a keyword parameter and pass it through from the call site.

### Optional: `lib/igniter_lang/cli.rb` (bin/igc)

The `igc` CLI calls `CompilerOrchestrator`. If `compiler_profile_id` must flow
from CLI invocation, `cli.rb` needs a flag. If the field is a build-time
constant or a test-mode hardcoded value, `cli.rb` is not touched.

---

## Artifact Hash Impact

Adding `compiler_profile_id` to `artifact_material` before hashing will change
`artifact_hash` for every assembled artifact. This is the intentional hash churn
documented in the design plan.

`Canonical.hash` uses `JSON.generate(Canonical.normalize(value))` →
`Digest::SHA256.hexdigest`. Sorting is by key. Adding `"compiler_profile_id"` as
a key changes the canonical JSON, changing the digest.

Consequence: every proof script that calls `Assembler#assemble_case` or
`Assembler#assemble_artifacts` will produce new `artifact_hash` values in its
output manifests.

---

## Golden Fixtures Inventory

### Tier 1 — Hand-crafted legacy fixtures (`fixtures/`)

Do NOT regenerate. Must be preserved as `absent_legacy` under `legacy_optional`
rollout policy.

| File | Notes |
|------|-------|
| `fixtures/add.igapp/manifest.json` | Older schema — no `kind`, `format_version`, `semantic_ir_ref`, etc. |
| `fixtures/availability_projection.igapp/manifest.json` | Older schema, escape fragment |
| `fixtures/polymorphic_add.igapp/manifest.json` | Different schema with specialization fields |

None of these should be touched by the assembler-only implementation card.

### Tier 2 — Assembler-generated artifacts in `experiments/*/out/` (29 manifests)

These are written by proof scripts that call `IgniterLang::Assembler.new`. They
are regenerated by re-running the relevant proof scripts.

An assembler-only implementation card **should not regenerate these** unless the
card is also scoped as `artifact-hash-profile-id-golden-migration-v0` (a
separate slice per the design plan [D]).

| Experiment | Manifests | Proof script |
|------------|-----------|-------------|
| `igapp_assembler_proof` | `add`, `claim_evidence`, `evidence_linked_alert` | `igapp_assembler_proof.rb` |
| `temporal_assembler_boundary` | `history_valid`, `bihistory_valid` | `temporal_assembler_boundary.rb` |
| `runtime_cache_proof_local_memoization` | `history_valid`, `bihistory_valid` | `runtime_cache_proof_local_memoization.rb` |
| `runtime_compatibility_report_temporal_load_check` | `history_valid`, `bihistory_valid` | `runtime_compatibility_report_temporal_load_check.rb` |
| `runtime_smoke_post_switch_full_coverage` | `bihistory_bitemporal`, `core_add_compute`, `history_single_axis`, `invariant_severity`, `olap_point`, `stream_fold` | `runtime_smoke_post_switch_full_coverage.rb` |
| `temporal_runtime_load_guard` | `bihistory_valid`, `history_valid` + 3 variants | `temporal_runtime_load_guard.rb` |
| `executor_approval_token_report_proof` | `history_single_axis` | `executor_approval_token_report_proof.rb` |
| `executor_boundary_cache_key_contract` | `bihistory_bitemporal`, `core_add`, `history_single_axis` | `executor_boundary_cache_key_contract.rb` |
| `history_type_proof` | `history_integer_point_access` | `history_type_proof.rb` |
| `production_compiler_cli` | `add` | `production_compiler_cli.rb` |

**Total: 29 generated manifests across 10 proof experiments.**

---

## Proof / Test Commands Needed After Implementation

The following proof scripts must be re-run and pass after assembler change:

```text
# Primary assembler proof — must emit compiler_profile_id in manifest and PASS
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb

# Temporal assembler — uses same Assembler class
ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb

# All proof scripts that call Assembler.new.assemble_case:
ruby igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb
ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb
ruby igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb
ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb
ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb

# Stage close candidate (runs multiple checks including igapp_assembler)
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb

# Existing PROP-036 proofs (must still pass — they use synthetic material)
ruby igniter-lang/experiments/prop036_loader_status_report_proof/prop036_loader_status_report_proof.rb
ruby igniter-lang/experiments/prop036_artifact_hash_ordering_proof/prop036_artifact_hash_ordering_proof.rb
```

The `prop036_loader_status_report_proof` and `prop036_artifact_hash_ordering_proof`
use synthetic manifest material only and are unaffected by assembler changes.
They must still pass as a regression check.

---

## Cross-Dependency: `compiler_profile_id_manifest_boundary` Experiment

`experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb`
reads:

```ruby
CORE_MANIFEST = ROOT / "igniter-lang/experiments/igapp_assembler_proof/out/add.igapp/manifest.json"
```

It computes the hash delta between a manifest without `compiler_profile_id`
(baseline from the real `add.igapp`) and a manifest with the field added. After
the assembler change re-generates `add.igapp/manifest.json` with
`compiler_profile_id`, this experiment's baseline shifts. It should be re-run
and its output is expected to change (the delta proof still holds; the baseline
just moves).

---

## Files Touched by an Assembler-Only Implementation Card

| File | Change | Required |
|------|--------|----------|
| `lib/igniter_lang/assembler.rb` | Add `compiler_profile_id:` kwarg to `build_artifact`, `assemble_case`, `assemble_artifacts`; include in `artifact_material` before hash; add to manifest | YES |
| `lib/igniter_lang/compiler_orchestrator.rb` | Thread `compiler_profile_id:` from `compile` to `assemble_artifacts` | Conditional — only if parameter flows from caller, not baked |
| `lib/igniter_lang/cli.rb` | Add `--compiler-profile-id` flag | Conditional — only if needed for CLI invocation |
| `experiments/*/out/*/manifest.json` | Re-generated by proof script re-runs (golden churn) | Out of scope for assembler-only; separate golden-migration card |
| `fixtures/*.igapp/manifest.json` | MUST NOT be touched | Preserved as absent_legacy |

**No other `lib/` files need changes.** Classifier, TypeChecker, Parser,
SemanticIREmitter are not involved.

---

## Open Design Questions for Authorization Card

Before C3-A can open an implementation card, the following must be resolved:

**Q1 — Origin of `compiler_profile_id` value:**
The assembler needs a value to emit. Options:

1. **Proof-local constant**: The implementation card uses a hardcoded
   `"compiler_profile_unified/sha256:proof000000000000000000000"` for initial
   emission. Golden migration can use the real profile id once CompilerProfile
   finalization exists.
2. **Parameter from orchestrator**: `compiler_profile_id` is threaded from the
   orchestrator or CLI, but requires the orchestrator interface to change.
3. **Profile finalization in-place**: The Assembler computes its own profile id
   from some profile object. No `CompilerProfile` finalization logic exists in
   `lib/` yet — this would significantly expand scope.

[R] Option 1 (proof-local constant) is the minimal assembler-only scope. It
proves the manifest field exists and enters hash material, without requiring
CompilerProfile finalization logic.

**Q2 — Legacy policy: omit or nil?**
Should the assembler omit `compiler_profile_id` from `artifact_material` when it
is nil (legacy mode), or include it as `nil` (present but null)? Including `nil`
changes hash material relative to omitting. The design plan implies the field is
always emitted when the assembler is "profile-aware." For a proof-local card, a
non-nil constant is simplest.

**Q3 — Ordering with the manifest's own dict:**
The PROP-036 design requires `compiler_profile_id` be **above** `artifact_hash`
in the manifest JSON. `Canonical.normalize` sorts all keys alphabetically, so
`compiler_profile_id` (c) sorts before `artifact_hash` (a)... wait — no.
Alphabetically: `a` < `c`, so `artifact_hash` sorts before `compiler_profile_id`
in the canonical JSON output. However, this does not affect correctness: the
ordering constraint (§7) is about what enters hash material, not the key order
in the emitted manifest file. Both fields will be present in the emitted manifest
regardless of sort order.

**Q4 — `assemble_artifacts` vs `assemble_case`:**
Both public methods call `build_artifact`. Both need to accept and forward
`compiler_profile_id`. The authorization card should confirm both call sites.

---

## Risk Table

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| R-1 | No `CompilerProfile` finalization in `lib/`. Without it, `compiler_profile_id` value must be a proof-local constant or a call-site parameter. Scope expands significantly if CompilerProfile finalization is required. | Medium | Authorization card must name Option 1 (proof-local constant) or explicitly authorize CompilerProfile finalization. |
| R-2 | `compiler_profile_id_manifest_boundary` experiment uses `igapp_assembler_proof/out/add.igapp/manifest.json` as its baseline. After assembler change, that file changes; the boundary experiment must be re-run and its expected-output commentary updated. | Low | Name this experiment in the post-implementation verification matrix. |
| R-3 | `executor_approval_token_report_proof` uses `manifest.fetch("artifact_hash")` for `artifact_ref` computation. If hash changes, the proof's output changes. The proof itself is self-consistent (it re-derives from the new manifest), so it should still PASS — but any downstream check comparing old golden output will drift. | Low | Treat `executor_approval_token_report_proof` output as non-golden (re-generated each run). |
| R-4 | 29 generated manifests in `experiments/*/out/` are committed and read by downstream proofs. Without a golden-migration card, these remain stale after the assembler change. Downstream proofs that load these stale manifests may see old `artifact_hash` values. | Medium | The assembler-only card must NOT commit stale generated manifests. Downstream proofs should be re-run and their outputs regenerated as part of post-implementation verification. |
| R-5 | 3 hand-crafted fixtures in `fixtures/` use an older manifest schema without `kind`, `format_version`, or `semantic_ir_ref`. These must remain inspectable under `absent_legacy`. No assembler code reads or validates these fixtures directly; they are safe. | Low | Confirm `absent_legacy` policy in loader card. |
| R-6 | CompilerOrchestrator interface change: if `compiler_profile_id` is passed from `compile(...)`, the orchestrator's public API changes. Callers of `CompilerOrchestrator#compile` (e.g., CLI, `production_compiler_cli` experiment) must be updated. | Low | Acceptable for assembler-only card if Option 1 (baked constant) is chosen. If Option 2 (threaded parameter), name all callers explicitly. |

---

## Recommendation

**READY — with conditions on the authorization card.**

The assembler change surface is precisely identified and narrow:

- **One primary file**: `lib/igniter_lang/assembler.rb`, method `build_artifact`
- **One secondary file**: `lib/igniter_lang/compiler_orchestrator.rb` (interface
  threading, only if parameter approach is chosen)
- **Zero lib/ test files** (no spec framework used in igniter-lang lib)
- **Zero non-assembler lib/ files** (Parser, Classifier, TypeChecker, SemanticIREmitter unchanged)
- **Zero production golden fixture changes** in `fixtures/` (absent_legacy preserved)

Before C3-A opens the implementation card, the card must resolve:

1. **Q1** — State where `compiler_profile_id` value comes from. Recommend Option 1
   (proof-local constant: `"compiler_profile_unified/sha256:proof000000000000000000000"`)
   to keep scope minimal. The constant can be updated to a real profile id when
   CompilerProfile finalization lands.

2. **Name the post-implementation verification matrix** — at minimum:
   - `igapp_assembler_proof.rb` must PASS with `compiler_profile_id` present in manifest
   - `temporal_assembler_boundary.rb` must PASS
   - PROP-036 proofs (`prop036_loader_status_report_proof.rb`,
     `prop036_artifact_hash_ordering_proof.rb`) must still PASS (unchanged)

3. **Explicitly exclude golden migration** — the card must state it does NOT
   commit new generated manifest files in `experiments/*/out/`. Downstream proof
   re-runs regenerate those files but their committed copies remain stale until
   a separate `artifact-hash-profile-id-golden-migration-v0` card is authorized.

4. **Confirm `legacy_optional` is preserved** — the manifest field is emitted
   when the assembler has a profile id; legacy behavior (proof-local constant =
   always present) is acceptable for the initial card. The loader/report card
   handles `absent_legacy` for existing artifacts.

5. **Cite all four blocker authorities**: PROP-036, S3-R35-C3-A acceptance
   decision, `prop036-loader-status-report-proof-v0` (C5-P loader proof), and
   `prop036-artifact-hash-ordering-proof-v0` (hash-ordering proof).

---

## Handoff

```text
Card: S3-R42-C1-P1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-assembler-impact-survey-v0
Status: done

[D] Decisions
- Primary change surface: lib/igniter_lang/assembler.rb, build_artifact method
- compiler_profile_id must enter artifact_material before Canonical.hash (§7 ordering)
- Secondary change: compiler_orchestrator.rb if parameter approach chosen
- 29 generated manifests would churn; golden migration is a separate card
- 3 hand-crafted fixtures in fixtures/ must not be touched (absent_legacy)
- No CompilerProfile finalization logic exists in lib/ — origin question must be
  resolved in authorization card

[S] Shipped / Signals
- Impact survey track doc: docs/tracks/prop036-assembler-impact-survey-v0.md
- Full file inventory, proof script matrix, risk table

[T] Tests / Proofs
- No code changed. Documentation-only survey.
- Post-implementation proof matrix named in track doc.

[R] Risks / Recommendations
- R-1: compiler_profile_id value origin must be named before card opens
- R-4: 29 generated manifests will be stale without golden-migration card
- Recommend Option 1 (proof-local constant) to keep assembler-only card minimal

[Next] Suggested authorization card
- C3-A: assembler-compiler-profile-id-field-v0
  - assembler-only surface
  - cites PROP-036, S3-R35-C3-A, C5-P loader proof, hash-ordering proof
  - uses proof-local compiler_profile_id constant
  - verifies igapp_assembler_proof.rb PASS
  - does NOT regenerate committed experiment goldens
```

---

## Non-Authorizations Preserved

This survey card does not authorize:

- assembler implementation;
- `.igapp` manifest mutation;
- loader implementation;
- golden migration;
- compiler dispatch migration;
- RuntimeMachine binding;
- production signing;
- production behavior changes.

# Track: PROP-036 Source Contract Code Surface Survey v0

Card: S3-R42-C5-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop036-source-contract-code-surface-survey-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Research Agent]`, `[Architect Supervisor / Codex]`

---

## Goal

Map the minimal code surface needed to support the selected
`compiler_profile_id` source contract, without implementing it.

This track does not implement assembler code, orchestrator changes, loader
behavior, runtime binding, compiler dispatch migration, or any artifact
mutation.

---

## Inputs Read

- `docs/gates/prop036-assembler-field-implementation-authorization-review-v0.md`
- `docs/tracks/prop036-compiler-profile-id-source-contract-v0.md` (C4-P1, untracked)
- `docs/tracks/prop036-assembler-implementation-contract-v0.md`
- `docs/tracks/prop036-assembler-field-design-plan-v0.md`
- `docs/tracks/prop036-artifact-hash-ordering-proof-v0.md`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `experiments/compiler_profile_spec_and_rule_unification/compiler_profile_spec_and_rule_unification.rb`
- `experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb`
- `experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb`

C4-P1 (`prop036-compiler-profile-id-source-contract-v0`) was found untracked
in this session (written by Compiler/Grammar Expert, status: done). This
survey proceeds with that track's decisions already in hand and maps the
assembler code surface against those decisions.

---

## C3-A Status

The C3-A decision (`prop036-assembler-field-implementation-authorization-review-v0.md`)
is **hold-redirect**. The assembler implementation is not authorized. The
authorized next card is:

```text
prop036-compiler-profile-id-source-contract-v0
```

C4-P1 has completed that card. The next blocker is:

```text
minimal-compiler-profile-finalization-proof-v0
```

C3-A must remain on hold until that proof passes and all C4-P1 blockers close.

---

## Real Assembler Code Surface

### Entry Points

`lib/igniter_lang/assembler.rb` exposes two public entry points that reach
`build_artifact`:

```ruby
# Entry point 1: standalone proof-local assembly (reads from golden_dir)
def assemble_case(case_name)
  report      = read_json(@golden_dir / "#{case_name}.compilation_report.json")
  semantic_ir = read_json(@golden_dir / "#{case_name}.semantic_ir.json")
  artifact = build_artifact(case_name, report, semantic_ir)
  write_artifact(case_name, artifact)
  artifact_summary(case_name, artifact)
end

# Entry point 2: called by CompilerOrchestrator
def assemble_artifacts(case_name:, report:, semantic_ir:, target_dir:)
  artifact = build_artifact(case_name, report, semantic_ir)
  target = Pathname.new(target_dir)
  write_artifact_to(target, artifact)
  artifact_summary_for_target(case_name, artifact, target)
end
```

### Change Point: `build_artifact` (private)

`build_artifact` at lines 121–184 is the only method that must change.

The current structure is:

```ruby
def build_artifact(case_name, report, semantic_ir)
  # ... build component hashes ...

  artifact_material = {
    "semantic_ir_program"    => semantic_ir,
    "contracts"              => contracts,
    "compilation_report"     => report,
    "requirements"           => requirements,
    "diagnostics"            => diagnostics,
    "classified_ast"         => classified_ast,
    "compatibility_metadata" => compatibility_metadata
    # compiler_profile_id ABSENT — this is the only change point
  }
  artifact_hash = Canonical.hash(artifact_material)   # ← hash is computed here

  manifest = {
    "kind"           => "igapp_manifest",
    "format_version" => "0.1.0",
    "artifact_hash"  => artifact_hash,
    # compiler_profile_id must also appear here (top-level manifest field)
    # ...
  }
end
```

The hash-ordering invariant requires:

```text
1. compiler_profile_id is added to artifact_material  ← BEFORE Canonical.hash
2. Canonical.hash(artifact_material)                   ← unchanged call
3. compiler_profile_id also placed in manifest         ← top-level, after hash
```

The forbidden order remains:

```text
Canonical.hash(artifact_material)    ← hash first
manifest["compiler_profile_id"] = x ← add after hash — FORBIDDEN
```

### Compiler Orchestrator Touch Point

`lib/igniter_lang/compiler_orchestrator.rb` calls the assembler via:

```ruby
@assembler.assemble_artifacts(
  case_name:   case_name,
  report:      report,
  semantic_ir: semantic_ir,
  target_dir:  target_dir
)
```

This call site is the natural injection point for providing the finalized
source object (or the derived id string) to the assembler.

---

## C4-P1 Source Contract Decisions

C4-P1 made the following binding decisions relevant to the assembler code
surface:

[D] The authoritative source is:

```text
frozen CompilerProfile descriptor
  → minimal CompilerProfile finalization
  → derived compiler_profile_id
  → assembler receives finalized source object
```

[D] A keyword parameter may be used only as a transport mechanism after the
caller has produced a finalized source object. It is not an authority source
by itself.

[D] A proof-local constant is allowed only in proof-local experiments. It
must not be used for production-like assembler output.

[D] The assembler should receive a `compiler_profile_id_source` object:

```json
{
  "kind": "compiler_profile_id_source",
  "format_version": "0.1.0",
  "status": "finalized",
  "profile_namespace": "compiler_profile_unified",
  "compiler_profile_id": "compiler_profile_unified/sha256:2944e573270aa56fca51cea3",
  "descriptor_digest": "compiler_profile_descriptor/sha256:6ee9c9c82ee1604b98a07f75",
  "finalization_payload_digest": "sha256:...",
  "profile_kind": "Stage3ProofCompilerProfileSpec",
  "slot_order": ["core", "oof_registry", "fragment_registry", "escape_boundary",
                 "contract_modifiers", "temporal", "stream", "olap",
                 "invariant", "assumptions", "evidence_observation", "pipeline"],
  "dispatch_migration_authorized": false,
  "runtime_authority_granted": false
}
```

[D] The assembler validates the source object shape; it does not perform
finalization derivation itself. Derivation lives in the finalization layer
(next card: `minimal-compiler-profile-finalization-proof-v0`).

---

## Three Source Options (Survey Reference)

| Option | C4-P1 verdict | Assembler code surface |
| --- | --- | --- |
| **A: raw keyword string** | Transport only; not authority source | Assembler accepts `compiler_profile_id: String`; validates format but cannot verify origin. C4-P1 rejects this as authority source. |
| **B: frozen descriptor object** | Descriptor is valid input upstream; prefix mapping needed | Descriptor-based derivation produces `compiler_profile_descriptor/sha256:...` prefix — does not match accepted `compiler_profile_unified/sha256:...` shape without finalization logic. |
| **C: full unified profile object** | Accepted when derivation is guarded against dispatch proximity | Correct prefix; but derivation belongs in finalization layer, not assembler. Dispatch proximity risk if not explicit. |
| **Finalized source object** (C4-P1 recommended) | Authoritative | Assembler validates source object shape; extracts `compiler_profile_id`; no derivation in assembler. |

---

## Recommended Path

Per C4-P1, the assembler implementation card should receive a finalized
`compiler_profile_id_source` object.

The keyword parameter transports the finalized source object (or the derived
id string extracted from it) from the caller to the assembler, but it is not
the authority source.

[D] Assembler-side refusal behavior governs. These are source-construction
refusals, not loader status values:

| Condition | Assembler-side result | Reason code |
| --- | --- | --- |
| No source object; profile-aware path | refuse build | `compiler_profile_source.missing` |
| Source object not a hash | refuse build | `compiler_profile_source.malformed` |
| `kind` ≠ `compiler_profile_id_source` | refuse build | `compiler_profile_source.wrong_kind` |
| `status` ≠ `finalized` | refuse build | `compiler_profile_source.unfinalized` |
| `profile_namespace` ≠ `compiler_profile_unified` | refuse build | `compiler_profile_source.unsupported_namespace` |
| `compiler_profile_id` malformed | refuse build | `compiler_profile_source.malformed_id` |
| `dispatch_migration_authorized: true` | refuse build | `compiler_profile_source.dispatch_migration_forbidden` |
| `runtime_authority_granted: true` | refuse build | `compiler_profile_source.runtime_authority_forbidden` |
| No source object; `legacy_optional` path | omit field | (no refusal) |

`AssemblyRefused` is the only refusal mechanism. No loader status semantics.

---

## Code Surface Map (Finalized Source Object)

| File | Method | Change type |
| --- | --- | --- |
| `lib/igniter_lang/assembler.rb` | `build_artifact` | Add `compiler_profile_source: nil` keyword; validate source object; extract `compiler_profile_id`; inject into `artifact_material` before `Canonical.hash`; inject top-level in manifest |
| `lib/igniter_lang/assembler.rb` | `assemble_case` | Add `compiler_profile_source: nil` keyword; thread through to `build_artifact` |
| `lib/igniter_lang/assembler.rb` | `assemble_artifacts` | Add `compiler_profile_source: nil` keyword; thread through to `build_artifact` |
| `lib/igniter_lang/assembler.rb` | _(new private)_ | `validate_compiler_profile_source!(source)` — validates shape per C4-P1 schema; raises `AssemblyRefused` on any refusal condition |
| `lib/igniter_lang/compiler_orchestrator.rb` | `compile` | Obtain finalized source object; pass as `compiler_profile_source:` to `assemble_artifacts` |

No other lib/ files change.

No golden fixtures change in the assembler-only card (`legacy_optional`;
existing artifacts remain `absent_legacy`).

No loader, CompatibilityReport, RuntimeMachine, Gate 3, Ledger, TBackend,
CompilationReceipt, `.ilk`, signing, or compiler dispatch files change.

---

## Implementation Risk List

| Risk | Severity | Mitigation |
| --- | --- | --- |
| **Hash ordering violation**: `compiler_profile_id` injected into `artifact_material` after `Canonical.hash` is called | Critical | Implementation card must carry hash-ordering proof as hard requirement; proof matrix must include `post_hash_annotation_blocked` case |
| **Source object validation skipped**: assembler accepts any hash as source without validating `kind`, `status`, `namespace`, `dispatch_migration_authorized`, `runtime_authority_granted` | Critical | `validate_compiler_profile_source!` must run before `artifact_material` is built; C4-P1 refusal table must be the implementation contract |
| **Raw string accepted as authority**: bare `compiler_profile_id:` keyword accepted without a finalized source object behind it | High | C4-P1 explicitly forbids this; implementation card must require finalized source object on the profile-aware path |
| **Finalization proof not yet available**: `minimal-compiler-profile-finalization-proof-v0` does not exist yet; assembler-only card may be blocked until it passes | High | Do not open `assembler-compiler-profile-id-field-v0` until the finalization proof passes all C4-P1 blockers |
| **Dispatcher proximity via unified profile object**: orchestrator assembles or passes a full `compiler_profile_unified` hash including `dispatch_mode` and `slot_assignments` | High | The finalization layer must produce a `compiler_profile_id_source` object that does not carry live dispatch state; `dispatch_migration_authorized: false` guard must fail on any truthy value |
| **Legacy fixture churn**: assembler-only card accidentally regenerates Tier 2 experiment goldens because `legacy_optional` not preserved | Medium | Implementation card must explicitly state `legacy_optional`; `assemble_case` without a source object must produce an artifact without the field |
| **Tier 1 fixture mutation**: hand-crafted `.igapp` fixtures in `fixtures/*.igapp` mutated by side effect | High | Implementation card must state Tier 1 fixtures are never touched; no retroactive mutation |
| **Loader status leakage**: assembler emits `present_verified` or other loader status values to express source refusals | Medium | Only `AssemblyRefused` is permitted; no loader status implementation in assembler-only card |

---

## Exact Blockers Before C4-I Implementation

[R] No implementation card may start until:

1. `minimal-compiler-profile-finalization-proof-v0` exists, passes, and
   produces a finalized source object matching the C4-P1 `compiler_profile_id_source`
   shape.
2. The finalization proof rejects missing, malformed, wrong-kind, unfinalized,
   namespace, malformed-id, dispatch-migration, and runtime-authority cases.
3. C3-A explicitly names `assembler-compiler-profile-id-field-v0` as the
   implementation surface and states `assembler-only`.
4. C3-A confirms the finalized source object is the assembler authority source
   (keyword transport of source object or derived id is allowed; raw string
   authority is not).
5. C3-A preserves `legacy_optional`.
6. C3-A preserves `present_verified != runtime ready`.
7. C3-A carries the hash-ordering proof as a hard implementation requirement.
8. C3-A states loader/report/status implementation is out of scope.
9. C3-A states CompatibilityReport, receipt links, signing, `.ilk`, compiler
   dispatch migration, RuntimeMachine, Gate 3, Ledger, TBackend, and runtime
   execution authority are out of scope.
10. C3-A either forbids real `.igapp`/golden mutation or names exact migrated
    fixtures and expected hash churn.

---

## Remaining Separate Surfaces

| Surface | Status after this survey |
| --- | --- |
| `minimal-compiler-profile-finalization-proof-v0` | Next blocker; not yet started |
| `assembler-compiler-profile-id-field-v0` (C4-I) | Blocked until finalization proof closes C4-P1 blockers and C3-A re-authorizes |
| `loader-compiler-profile-status-report-v0` | Blocked until separately authorized |
| `artifact-hash-profile-id-golden-migration-v0` | Blocked unless exact fixture list and hash churn are authorized |
| `compilation-receipt-manifest-link-v0` | Blocked until manifest ordering is stable |
| CompilerProfile finalization lib/ class | Blocked; experiment-only objects exist today |
| Compiler dispatch migration | Blocked; out of scope |
| RuntimeMachine binding | Blocked; out of scope |
| production signing | Blocked; out of scope |

---

## Non-Authorizations

This survey does not authorize:

- assembler implementation;
- compiler orchestrator changes;
- loader implementation;
- CompatibilityReport changes;
- `.igapp` manifest or golden mutation;
- `.ilk` changes;
- CompilationReceipt links;
- artifact signing;
- compiler dispatch migration;
- RuntimeMachine binding;
- RuntimeMachine execution authority;
- Gate 3 widening;
- Ledger or TBackend binding;
- production behavior.

---

## Handoff

```text
Card: S3-R42-C5-P1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-source-contract-code-surface-survey-v0
Status: done

[D] Decisions
- C4-P1 (prop036-compiler-profile-id-source-contract-v0) found untracked in
  this session; survey aligns with its decisions.
- Finalized source object (compiler_profile_id_source) is the assembler
  authority source per C4-P1.
- Keyword parameter is transport only; raw string authority is forbidden.
- Code-surface map: 4 assembler method changes + 1 orchestrator call-site
  change. validate_compiler_profile_source! (new private) guards source shape.
- 8 implementation risks identified; hash ordering violation and source
  validation skip are Critical.
- assembler-compiler-profile-id-field-v0 is blocked until
  minimal-compiler-profile-finalization-proof-v0 passes.

[S] Shipped / Signals
- Added this code-surface survey track doc.
- No code, manifests, or goldens changed.

[T] Tests / Proofs
- Documentation-only survey; no proof scripts run.

[R] Risks / Recommendations
- Do not open assembler-only implementation until finalization proof closes
  all C4-P1 blockers.
- validate_compiler_profile_source! must enforce C4-P1 refusal table including
  dispatch_migration_authorized: false and runtime_authority_granted: false.
- AssemblyRefused is the only allowed refusal mechanism; no loader status
  semantics.

[Next]
- Open minimal-compiler-profile-finalization-proof-v0.
- Reconsider assembler-compiler-profile-id-field-v0 only after finalization
  proof passes and C3-A re-authorizes.
```

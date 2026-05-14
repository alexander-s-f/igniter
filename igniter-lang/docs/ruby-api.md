# Igniter-Lang Ruby API

Status: caller-facing API guide
Last updated: 2026-05-14

This page documents the current public Ruby facade for the proof compiler.

The Ruby facade is not the CLI. CLI profile-source flags, path loading, inline
JSON parsing, profile discovery, and profile defaulting remain closed unless a
later gate authorizes them.

---

## `IgniterLang.compile`

```ruby
IgniterLang.compile(
  source_path: source_path,
  out_path: out_path,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil
)
```

`source_path:` points to the Igniter-Lang source file to compile.

`out_path:` points to the output `.igapp` directory.

`sample_input:`, `sample_input_resolver:`, and `runtime_smoke:` preserve the
existing proof-compiler behavior.

`compiler_profile_source:` is optional and defaults to `nil`.

---

## Compiler Profile Source

`compiler_profile_source: nil` is the default and preserves `legacy_optional`
behavior. Assembled manifests omit `compiler_profile_id`.

The only supported caller shapes are:

```text
nil
already-finalized compiler_profile_id_source Hash-like object
```

To emit `compiler_profile_id`, pass an already-finalized
`compiler_profile_id_source` Hash-like object. The facade does not build this
object.

In the current proof model, a finalized source has these required fields:

- `kind: "compiler_profile_id_source"`
- `format_version: "0.1.0"`
- `status: "finalized"`
- `profile_namespace: "compiler_profile_unified"`
- `compiler_profile_id`
- `descriptor_digest`
- `finalization_payload_digest`
- `profile_kind`
- `slot_order`
- `slot_assignments`
- `dispatch_migration_authorized: false`
- `runtime_authority_granted: false`

Example shape, shortened for readability:

```json
{
  "kind": "compiler_profile_id_source",
  "format_version": "0.1.0",
  "status": "finalized",
  "profile_namespace": "compiler_profile_unified",
  "compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "descriptor_digest": "compiler_profile_descriptor/sha256:<24 lowercase hex chars>",
  "finalization_payload_digest": "sha256:<64 lowercase hex chars>",
  "profile_kind": "Stage3ProofCompilerProfileSpec",
  "slot_order": [
    "core",
    "oof_registry",
    "fragment_registry",
    "escape_boundary",
    "contract_modifiers",
    "temporal",
    "stream",
    "olap",
    "invariant",
    "assumptions",
    "evidence_observation",
    "pipeline"
  ],
  "slot_assignments": {
    "core": {
      "implementation_id": "core_language.proof_compiler_adapter.v0",
      "pack_name": "CoreLanguagePack"
    }
  },
  "dispatch_migration_authorized": false,
  "runtime_authority_granted": false
}
```

The example truncates `slot_assignments`. A valid finalized source must carry
the finalized slot assignments needed by the compiler-profile-source validation
path.

---

## Invalid Caller Assumptions

Do not pass:

- a file path;
- a raw JSON string;
- a raw `compiler_profile_id` string;
- an unfinalized descriptor;
- a source object that grants runtime authority;
- a source object that authorizes compiler dispatch migration.

Invalid non-nil sources are refused by the existing compiler-profile-source
validation path before profiled artifact output.

---

## Transport-Only Facade

`IgniterLang.compile` treats `compiler_profile_source:` as transport-only. It
forwards the value unchanged to `CompilerOrchestrator#compile`.

The facade does not validate, finalize, discover, infer, load, parse, normalize,
or default compiler profile sources. Validation and refusal are owned by the
orchestrator/assembler compiler-profile-source path.

Changing accepted source shapes is a public API contract change. A future card
that widens orchestrator/assembler validation must explicitly review whether the
Ruby facade should expose that widened shape to callers.

Future orchestrator/assembler validation widening does not automatically close
the facade/API review requirement.

---

## Non-Authorized Surfaces

`compiler_profile_source` and `compiler_profile_id` do not grant or implement:

- CLI profile source flags;
- path loading;
- inline JSON parsing;
- profile discovery, defaulting, or finalization in the facade;
- loader/report status;
- CompatibilityReport compiler-profile section;
- `.igapp` golden migration;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- RuntimeMachine authority;
- Gate 3 authority;
- Ledger or TBackend authority;
- BiHistory production execution;
- stream or OLAP production executors;
- production cache;
- production behavior.

Runtime readiness remains governed by separate runtime compatibility, approval,
capability, and execution-scope gates.

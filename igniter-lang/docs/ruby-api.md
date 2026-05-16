# Igniter-Lang Ruby API

Status: caller-facing API guide
Last updated: 2026-05-16

This page documents the current public Ruby facade for the proof compiler.

R52 adds one bounded caller-facing CLI exception for transporting an
already-finalized compiler profile source from a JSON file:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

All other CLI profile-source input shapes, inline JSON parsing, profile
discovery, profile defaulting, and profile finalization remain closed.

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

## Ruby Facade Invalid Caller Assumptions

For the Ruby facade, do not pass:

- a file path;
- a raw JSON string;
- a raw `compiler_profile_id` string;
- an unfinalized descriptor;
- a source object that grants runtime authority;
- a source object that authorizes compiler dispatch migration.

Invalid non-nil sources are refused by the existing compiler-profile-source
validation path before profiled artifact output.

---

## CLI Compiler Profile Source Transport

The only authorized CLI compiler-profile-source shape is:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

`PATH.json` must point to an already-finalized
`compiler_profile_id_source` JSON object. The CLI does not build, finalize,
normalize, discover, infer, or default this object.

The CLI owns only transport preflight:

- path exists;
- path is a regular file;
- file is readable;
- file contains valid JSON;
- the top-level JSON value is an object.

When preflight succeeds, the CLI parses the JSON object and passes it unchanged
as `compiler_profile_source:` to `IgniterLang.compile`. Semantic validation of
the source object remains owned by the existing compiler/orchestrator/assembler
compiler-profile-source path.

### No-Flag Legacy Behavior

This command preserves legacy behavior:

```text
igc compile SOURCE --out OUT.igapp
```

No profile source is loaded, discovered, defaulted, or inferred. For valid
source, the CLI emits `.igapp` output and the manifest omits
`compiler_profile_id`.

### Valid Bounded Profile Source

With a valid finalized source object:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

the CLI emits `.igapp` output for valid source, stdout remains compiler-result
JSON, stderr is empty, and the assembled manifest contains the
`compiler_profile_id` from the source object.

### CLI Preflight Refusals

CLI preflight refusals happen before `IgniterLang.compile` runs.

Preflight refusal shape:

- exit is non-zero;
- stdout is empty;
- stderr contains one stable line;
- `OUT.compilation_report.json` is absent;
- `OUT.igapp` is absent;
- no profile-source report JSON is emitted.

Preflight refusal cases include missing path token, path not found, non-file
path, unreadable path, invalid JSON, top-level non-object JSON, and unsupported
extra arguments.

As accepted by the R52 readiness decision, the edge case:

```text
--compiler-profile-source --some-flag
```

treats `--some-flag` as the path token and may refuse as path-not-found. This is
standard Unix argument behavior and does not widen authority.

### Semantic Profile-Source Refusals

If `PATH.json` passes CLI preflight but the object is semantically invalid, the
existing compiler/orchestrator/assembler path refuses it.

Semantic refusal shape:

- exit is non-zero;
- stdout is compiler-result JSON;
- `OUT.compilation_report.json` exists;
- `OUT.igapp` is absent;
- refusal reasons use qualified `compiler_profile_source.*` vocabulary.

Known semantic refusal families include:

- `compiler_profile_source.wrong_kind`
- `compiler_profile_source.unfinalized`
- `compiler_profile_source.runtime_authority_forbidden`

These are source-validation terms, not loader-status or runtime-readiness
vocabulary.

### Still Rejected CLI Shapes

The bounded CLI transport does not authorize:

- `--compiler-profile-source-json JSON`;
- `--compiler-profile-source-name NAME`;
- `--compiler-profile default`;
- inline JSON;
- raw `compiler_profile_id` strings;
- named/generated profile lookup;
- environment/config/sidecar discovery;
- profile source discovery/defaulting/finalization in CLI.

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

- CLI profile-source shapes beyond
  `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
- path loading outside the bounded R52 CLI transport;
- inline JSON parsing;
- profile discovery, defaulting, or finalization in the CLI or facade;
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

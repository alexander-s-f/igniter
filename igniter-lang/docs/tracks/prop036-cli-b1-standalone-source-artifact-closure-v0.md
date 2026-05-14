# PROP-036 CLI B1 Standalone Source Artifact Closure v0

Card: S3-R46-C1-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-cli-b1-standalone-source-artifact-closure-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future source-object semantic
  and refusal vocabulary changes.
- `[Igniter-Lang Bridge Agent]` may later consume the caller artifact contract
  for CLI/package documentation.

## Goal

Define the exact closure criterion for `PROP036-CLI-B1` before any CLI
implementation is requested.

This track does not implement code, does not mutate proof outputs, and does not
authorize CLI implementation.

## Inputs Read

```text
igniter-lang/docs/gates/prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md
igniter-lang/docs/tracks/prop036-cli-exposure-input-shape-options-v0.md
igniter-lang/docs/discussions/prop036-cli-exposure-design-pressure-v0.md
igniter-lang/docs/tracks/minimal-compiler-profile-finalization-proof-v0.md
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json
```

## B1 Restatement

`PROP036-CLI-B1` currently says:

```text
Standalone source artifact contract:
Define or prove a standalone finalized `compiler_profile_id_source` JSON
artifact contract. Current proof summary JSON is evidence only, not a caller
artifact contract.
```

The missing piece is the closure bar: what concrete artifact/doc/proof must
exist before B1 can be marked closed.

## Current Evidence Is Not Enough

The minimal finalization proof summary contains:

```json
{
  "finalized_source_example": {
    "kind": "compiler_profile_id_source",
    "format_version": "0.1.0",
    "status": "finalized",
    "profile_namespace": "compiler_profile_unified",
    "compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
    "descriptor_digest": "compiler_profile_descriptor/sha256:0a2b4b79dda5d9657e6642b3",
    "finalization_payload_digest": "sha256:a3829357ff3d34d23a82f5b7fbe22018fa66ef88efa5dd9bd04ab10f4fe4d8d4",
    "profile_kind": "Stage3ProofCompilerProfileSpec",
    "slot_order": ["..."],
    "slot_assignments": {"...": "..."},
    "dispatch_migration_authorized": false,
    "runtime_authority_granted": false
  }
}
```

That proves the source shape exists. It is not a caller artifact contract
because:

- it is embedded inside a proof summary rather than emitted as the file a CLI
  caller would pass as `PATH.json`;
- the path is not named as a stable caller artifact path;
- there is no proof that the standalone file alone validates;
- there is no artifact-level negative-token scan;
- there is no documented file ownership or regeneration command;
- there is no statement that CLI may read exactly that file shape and no other
  profile/discovery source.

## Closure Form Options

| Closure form | Strengths | Weaknesses | Verdict |
| --- | --- | --- | --- |
| Dedicated proof output file at a stable path | Concrete caller-like artifact; easy for future CLI proof to consume; makes B1 machine-checkable. | Needs a proof update later to emit/validate the file. | Required. |
| Normative docs/spec shape only | Good for semantics and review; no generated file churn. | Too easy to self-assert closure; not enough for CLI `PATH.json` behavior. | Insufficient alone. |
| JSON schema-like contract | Good validation checklist; can clarify required/forbidden fields. | If not paired with a real artifact, still not caller-like. No schema runner exists today. | Useful support, not sufficient alone. |
| Generator command + output path | Strong long-term story; gives users a way to obtain artifacts. | Too broad for B1; risks pulling finalization/generation into CLI scope too early. | Defer beyond B1. |
| Combination: artifact + docs | Concrete and reviewable; avoids generator overreach; closes artifact contract and semantic contract together. | Requires both proof output and doc update in a future implementation/proof card. | Recommended Stage 3 closure. |

## Recommended Closure Criterion

`PROP036-CLI-B1` is closed only when **both** of these exist:

1. A dedicated proof-owned standalone JSON artifact at a stable path:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

2. A track/spec-style contract section documenting that file as a standalone
caller artifact:

```text
kind: compiler_profile_id_source
format_version: 0.1.0
status: finalized
profile_namespace: compiler_profile_unified
compiler_profile_id: compiler_profile_unified/sha256:<24+ lowercase hex>
descriptor_digest: compiler_profile_descriptor/sha256:<24+ lowercase hex>
finalization_payload_digest: sha256:<64 lowercase hex>
profile_kind: Stage3ProofCompilerProfileSpec
slot_order: exact canonical slot order
slot_assignments: object keyed by the canonical slot order
dispatch_migration_authorized: false
runtime_authority_granted: false
```

The closure proof must show:

- the file is generated by a named proof command;
- the file is valid standalone JSON;
- the top-level JSON value is an object/hash;
- the file validates with the same source validation used by the finalization
  proof/assembler source contract;
- the file's `compiler_profile_id` is derived from the documented finalization
  payload rule;
- the file contains no loader-status or runtime-readiness exact tokens;
- the file does not contain a nested summary wrapper such as
  `finalized_source_example`;
- the source object is usable as the future CLI `--compiler-profile-source
  PATH.json` payload without requiring discovery, defaulting, or lookup.

## Required Artifact Contract

The future standalone file must contain only the source object, not the proof
summary:

```json
{
  "kind": "compiler_profile_id_source",
  "format_version": "0.1.0",
  "status": "finalized",
  "profile_namespace": "compiler_profile_unified",
  "compiler_profile_id": "compiler_profile_unified/sha256:<24+ lowercase hex>",
  "descriptor_digest": "compiler_profile_descriptor/sha256:<24+ lowercase hex>",
  "finalization_payload_digest": "sha256:<64 lowercase hex>",
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

The example above abbreviates `slot_assignments`; the real artifact must include
all canonical slots.

## Required Proof Command

B1 closure must name a command. Recommended command:

```text
ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb
```

Future B1-closing proof output must include:

```text
out/compiler_profile_source.stage3_proof.json
out/minimal_compiler_profile_finalization_summary.json
```

and the summary must explicitly record:

```text
standalone_artifact_path
standalone_artifact_valid: true
standalone_artifact_exact_forbidden_token_hits: 0
```

## What Counts As Not Closed

`PROP036-CLI-B1` is not closed by:

- an embedded example inside `minimal_compiler_profile_finalization_summary.json`;
- a Markdown code block only;
- a schema-like table only;
- an untracked local JSON file;
- a generated file without a documented command;
- a generated file whose top-level JSON is a wrapper/summary rather than the
  source object itself;
- an artifact that requires CLI discovery, registry lookup, env/config lookup,
  sidecar search, or defaulting to locate;
- a generator command that also changes CLI behavior;
- a file that has not been validated by the source validator;
- a file that contains exact loader-status or runtime-readiness tokens;
- any claim that source-shape docs alone are sufficient.

## Rejected Closure Forms

[X] **Normative docs/spec shape only**: useful but not enough. The CLI path
contract needs a real caller-like JSON file.

[X] **JSON schema-like contract only**: useful as supporting material, but does
not prove the exact artifact a caller will pass.

[X] **Generator command as B1 closure**: too broad for this blocker. A generator
may come later, but B1 should close with a proof-owned static artifact contract
first.

[X] **Proof summary as artifact**: summary files are evidence envelopes, not
caller payloads.

## Risks

- If B1 closes without a standalone artifact, a future CLI implementation may
  parse arbitrary proof-summary shape instead of the intended source object.
- If B1 closes with docs only, the implementation gate can be passed by
  self-assertion rather than a machine-checkable file.
- If B1 requires a full generator now, scope may expand into finalization
  product design, profile discovery, or registry lookup too early.
- If the artifact path is not stable, future negative scans and CLI proof
  fixtures will drift.

## Recommendation

Recommended Stage 3 B1 closure form:

```text
artifact + docs
```

Specifically:

```text
Artifact:
  igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json

Command:
  ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb

Docs:
  A B1 closure track that records the standalone artifact contract, validation
  result, exact forbidden-token scan result, and remaining non-authorizations.
```

Implementation authorization for CLI remains held until B1 plus B2-B9 are
closed by their own criteria.

## Handoff

```text
Card: S3-R46-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-cli-b1-standalone-source-artifact-closure-v0
Status: done

[D] Decisions
- B1 should close through artifact + docs, not docs alone.
- The required artifact should be a standalone top-level `compiler_profile_id_source` JSON file.
- Recommended future path: `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`.
- Existing proof summary evidence is not enough to close B1.

[S] Signals
- Current finalization proof proves source shape but embeds it in a summary.
- No stable standalone caller artifact exists yet.
- Generator/registry work is broader than B1 and should be deferred.

[T] Tests / Proofs
- Design-only card; no commands run and no proof outputs mutated.
- Evidence read from C3-A, C1-P1, C4-X pressure, finalization proof track, and finalization summary JSON.

[R] Recommendation
- Open a B1 closure implementation/proof card that emits and validates the standalone artifact, updates its summary, and runs the negative-token scan.

[Files] Changed
- `igniter-lang/docs/tracks/prop036-cli-b1-standalone-source-artifact-closure-v0.md`

[Q] Open Questions
- Should the eventual standalone artifact be committed as a golden-like fixture, regenerated proof output, or both?
- Should a future user-facing generator command be proposed after B1 closes?

[X] Rejected
- Closing B1 with a Markdown example only.
- Closing B1 with the existing summary JSON only.
- Requiring a full generator command as the B1 closure itself.
- Any CLI implementation or path loading in this slice.

[Next] Proposed next slice
- B1 closure proof: emit `compiler_profile_source.stage3_proof.json`, validate it standalone, scan it, and document exact output.
```

# Track: Compiler Profile Auditable Build Receipt v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-auditable-build-receipt-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prove a proof-local `CompilationReceipt` shape so the system can explain what it
compiled, which profile foundation it used, which stages ran, which requirements
and diagnostics were produced, and which authority it does not grant.

This slice is intentionally not a production audit trail, not a signed receipt,
and not a `.igapp` format change.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_auditable_build_receipt/compiler_profile_auditable_build_receipt.rb
igniter-lang/experiments/compiler_profile_auditable_build_receipt/out/compilation_receipt.add.json
igniter-lang/experiments/compiler_profile_auditable_build_receipt/out/compiler_profile_auditable_build_receipt_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_auditable_build_receipt/compiler_profile_auditable_build_receipt.rb
```

Result:

```text
PASS compiler_profile_auditable_build_receipt
```

The runner first executes:

```text
compiler_profile_preflight_chain_index
production_compiler_cli_proof
```

Then it builds a receipt for the `add.ig` compiled `.igapp` output.

---

## Receipt Shape

The proof-local receipt includes:

| Field | Purpose |
|---|---|
| `source` | Source path, manifest source hash, recomputed source digest. |
| `compiler_profile_id` | Unified profile identity from the profile/pack proof chain. |
| `compiler_profile_preflight` | Indexed proof chain used to justify the profile foundation. |
| `compile_command` | CLI and direct Ruby API facade evidence. |
| `stages` | Parse, classify, typecheck, emit, assemble, runtime smoke evidence. |
| `packs_and_rules` | Slot assignments, ordered registries, strict registries. |
| `diagnostics` | Diagnostics emitted for the compilation. |
| `warnings` | Warnings emitted for the compilation. |
| `requirements` | Requirements derived for the artifact. |
| `artifact` | `.igapp` manifest refs, contract index, declared artifact hash, manifest digest. |
| `compatibility` | Compatibility metadata and runtime smoke evidence. |
| `authority` | Explicit statement that the receipt does not authorize runtime execution. |
| `receipt_policy` | Deterministic, machine-readable, hashable, safe-to-show, proof-local. |

---

## Key Decision

[D] An auditable build receipt should be an explanation artifact, not a process
log.

The receipt records deterministic evidence that can be checked later:

```text
source digest
compiler_profile_id
profile preflight evidence
stage outcomes
pack/rule ownership model
diagnostics and warnings
requirements
artifact refs and hashes
authority boundary
```

[D] The receipt should be safe to show and hashable, but this proof does not
claim it is signed or production-persistent.

[D] The receipt preserves the same authority boundary as the profile work:

```text
compiler profile + receipt => compiler understanding evidence
compiler profile + receipt != runtime execution authority
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `inputs.preflight_command_passed` | Profile preflight chain passed before receipt creation. |
| `inputs.compiler_proof_command_passed` | Production compiler CLI/API proof passed before receipt creation. |
| `receipt.has_compiler_profile_id` | Receipt includes the unified compiler profile id. |
| `receipt.source_digest_matches_manifest` | Source digest recomputes to the manifest source hash. |
| `receipt.includes_parse_to_assemble_stages` | Receipt explains parse through assemble. |
| `receipt.includes_packs_rules_requirements_diagnostics` | Receipt includes the key explainability surfaces. |
| `receipt.artifact_hash_declared_and_manifest_digest_present` | Receipt preserves declared artifact hash and adds manifest digest evidence. |
| `receipt.authority_does_not_grant_runtime` | Receipt does not authorize runtime execution. |
| `receipt.policy_machine_readable_hashable_safe_to_show` | Receipt declares the intended audit-friendly policy. |
| `receipt.not_signed_or_production_audit` | Proof does not overclaim signing or production persistence. |

---

## Receipt Preview

```json
{
  "kind": "proof_local_compilation_receipt",
  "program_id": "semanticir/e9664d5446df4e46",
  "compiler_profile_id": "compiler_profile_unified/sha256:2944e573270aa56fca51cea3",
  "artifact": {
    "fragment_class": "core",
    "artifact_hash": "sha256:0a39c880326db497a7a6a8298f2e6d99dffc40cd084c15cf47d081b77deaaac8",
    "manifest_digest": "sha256:e790e93b01b075d5ddacf0476e477c198db616904d5e0ceb6d841ce7e34a0bde"
  },
  "authority": {
    "proves_compiler_understanding": true,
    "authorizes_runtime_execution": false,
    "is_signed_receipt": false,
    "is_production_audit_trail": false
  }
}
```

---

## Recommendation

[R] Treat `CompilationReceipt` as the natural sibling of `.igapp` manifest and
CompatibilityReport in the future production architecture.

[R] The next design slice should specify where receipts live:

```text
.igapp/compilation_receipt.json
external signed receipt bundle
.ilk metadata layer
or all of the above with different authority levels
```

[R] Production receipt design should define:

```text
canonical JSON rules
receipt digest rules
redaction policy
signature/key-management boundary
retention policy
relationship to artifact_hash
relationship to CompatibilityReport
```

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-auditable-build-receipt-v0
Status: done

[D] Decisions:
- Auditable build receipt is an explanation artifact, not a process log.
- Receipt proves compiler/build evidence only; it does not authorize runtime execution.
- Proof-local receipt keeps declared artifact hash and adds separate manifest digest evidence.

[S] Signals:
- Receipt can combine source hash, profile id, profile preflight, stages,
  pack/rule ownership, diagnostics, requirements, artifact refs, and authority boundary.
- The shape is machine-readable, hashable, and safe-to-show in proof-local form.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_auditable_build_receipt/compiler_profile_auditable_build_receipt.rb -> PASS

[R] Risks:
- Production receipt must not overclaim signing/persistence until key management
  and retention policy are designed.
- Relationship between manifest `artifact_hash`, receipt digest, signed surface,
  and `.ilk` metadata needs a formal proposal.

[Next]
- Draft `compilation-receipt-authority-and-storage-v0`: choose receipt storage
  surfaces and define digest/signature/redaction policy.
```

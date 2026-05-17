# PROP-038 Contract Digest Shape Proof Boundary Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R69-C0-O`
Authority: orientation only, not canon

---

## Purpose

Keep the R69 `contract_digest` shape-policy proof visibly separated from:

```text
live validator implementation
recompute-match integrity proof
compile refusal
public/report surfacing
persisted artifacts
loader/report or CompatibilityReport authority
runtime or production behavior
```

This map does not authorize code, semantics, gates, proposals, implementation,
compile refusal, public output, report surfacing, loader/report behavior,
CompatibilityReport behavior, runtime behavior, or production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-validation-policy-decision-v0.md
igniter-lang/docs/tracks/prop038-contract-digest-validation-policy-design-v0.md
igniter-lang/docs/discussions/prop038-contract-digest-validation-policy-pressure-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-contract-digest-validation-policy-decision-v0.md
```

Decision status:

```text
accepted-authorized-proof-local-shape-policy
```

Accepted policy:

```text
hybrid
```

Meaning:

```text
current live validator remains prop038_24_plus
no live contract_digest validation is added now
future contract_digest validation proceeds through:
  1. shape-only proof
  2. recompute-match proof
implementation remains held
```

---

## Allowed R69 Proof-Local Output Surfaces

The next allowed route is proof-local only:

```text
prop038-contract-digest-shape-policy-proof-v0
```

Allowed value:

```text
exercise Phase 1 shape-only matrix
produce summary JSON under an experiment directory
prove diagnostics/policy behavior without changing live compiler behavior
preserve current validator/compiler behavior
```

Expected proof-local surface class:

```text
igniter-lang/experiments/<contract-digest-shape-policy-proof>/
igniter-lang/experiments/<contract-digest-shape-policy-proof>/out/<summary>.json
igniter-lang/docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md
```

This map does not name exact paths as authority. Future C1-P1 should follow the
main card/gate when naming concrete proof files.

---

## Forbidden Live-Code Surfaces

R69 proof-local work must not edit:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/diagnostics.rb
parser / classifier / TypeChecker / SemanticIR emitter
assembler / .igapp artifact writers
RuntimeMachine / temporal / Gate 3 surfaces
loader/report or CompatibilityReport surfaces
```

Current live validator behavior:

```text
descriptor_digest shape-only
finalization_payload_digest shape-only full64
contract_digest ignored/deferred
```

Proof-local evidence must not be mistaken for a changed validator.

---

## Shape-Only vs Recompute-Match

### Shape-Only Proof

Shape-only answers:

```text
Does contract_digest match the selected reference format?
```

R69 Phase 1 shape-only cases:

```text
valid_short_contract_digest
valid_full_contract_digest
missing_contract_digest
contract_digest_wrong_namespace
contract_digest_too_short
contract_digest_non_hex
contract_digest_uppercase_hex
unsupported_digest_policy
```

Shape-only does not answer:

```text
Does the digest match canonical contract material?
Is the canonicalization algorithm correct?
Is the declared digest a durable identity?
Should a mismatch refuse compilation?
```

### Recompute-Match Proof

Recompute-match answers:

```text
Does declared contract_digest match a recomputed hash of canonical contract
material excluding contract_digest?
```

Recompute-match remains held until after shape-only proof acceptance and a
separate route.

Do not mix shape-only proof outputs with recompute-match claims.

---

## Report-Only And Refusal Boundaries

Even if future digest diagnostics exist, the current boundary is:

```text
contract_digest diagnostics remain report-only
compile refusal remains closed
```

Shape-policy proof must preserve:

```text
existing 13-case validator matrix remains PASS
R67 report-only integration remains unchanged
public result remains unchanged
compile_refusal_authorized=false
no .igapp mutation
no refusal report creation
```

Forbidden implication:

```text
contract_digest_invalid => compiler pass_result error
contract_digest_invalid => CompilerResult.refusal
contract_digest_invalid => public CLI/API failure
contract_digest_invalid => loader/report or CompatibilityReport status
```

Current safe reading:

```text
shape-policy proof demonstrates candidate policy behavior only.
It does not create compiler authority.
```

---

## Candidate Diagnostics, Not Implementation Authority

R68 accepted these as future diagnostic candidates for proof-local work:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_recompute_unavailable
compiler_profile_contract.contract_digest_mismatch
```

For R69 shape-only proof, relevant candidate names are:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
```

Still not live-validator authority:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_recompute_unavailable
compiler_profile_contract.contract_digest_mismatch
```

Still not top-level compiler diagnostics:

```text
report["diagnostics"] += compiler_profile_contract.*
IgniterLang::Diagnostics.compiler_profile_contract.*
```

If later integrated, the intended nested location remains:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

That future placement itself still requires the appropriate implementation gate.

---

## Proof Acceptance Questions

Before accepting any R69 shape-policy proof, check:

```text
1. Did it stay proof-local?
2. Did it avoid editing live validator/compiler files?
3. Did it exercise the 8 Phase 1 shape-only cases?
4. Did it preserve the existing 13-case validator matrix?
5. Did it preserve R67 report-only behavior?
6. Did it avoid recompute-match assertions?
7. Did it avoid new public output, persisted report, sidecar, or .igapp mutation?
8. Did it keep compile_refusal_authorized=false?
9. Did it mark contract_digest_* diagnostics as proof candidates, not live code?
10. Did it produce a compact summary JSON suitable for Architect review?
```

---

## Future Route Separation

Recommended sequencing remains:

```text
R69: shape-only proof-local policy evidence
later: Architect acceptance/hold for shape proof
later: recompute/canonicalization proof route
later: optional PROP-038 errata after proofs stabilize vocabulary
later: optional implementation authorization
much later: optional compile-refusal gate, if ever
```

No step should skip directly from R69 proof-local evidence to live validator code
without a separate Architect decision.

---

## Return Summary

R69 may prove `contract_digest` shape policy, but only as proof-local evidence.
It must not mutate the live validator, compiler, reports, public output,
`.igapp`, loader/report, CompatibilityReport, runtime, or production surfaces.

The compact rule:

```text
prove shape policy locally; do not implement digest authority
```

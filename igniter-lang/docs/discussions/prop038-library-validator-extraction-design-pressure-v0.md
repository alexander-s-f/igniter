# Discussion: PROP-038 Library Validator Extraction Design Pressure v0

Card: S3-R64-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-library-validator-extraction-design-pressure-v0

Depends on: S3-R64-C1-P1 delivered

Question:

Is the Option B library validator design boundary exact enough to authorize
implementation without risk of scope creep? Are descriptor digest, short-vs-full
digest policy, and diagnostic placement resolved with no ambiguity? Is the
contract input ownership decision correctly non-public? Are the hold reasons
sufficient to prevent unauthorized surfaces from being opened by an overly broad
authorization? Can C3-A authorize the bounded Option B extraction from this card
alone?

Context:
- R63-C3-A (gate): Accepted R63 proof-local implementation; closed R62 Option A;
  authorized S3-R64-C1-P1 design-only; held all library validator implementation
- R64-C1-P1: Implementation Agent — design-only track proposing
  `CompilerProfileContractValidator.validate(contract, digest_reference_policy:
  :prop038_24_plus)`; internal/non-integrated/non-refusal; string-key Hash return
  with `compiler_integrated: false`, `compile_refusal_authorized: false`;
  diagnostics local; descriptor digest = shape only; 8 blockers B1-B8 requiring
  C3-A authorization; exact write boundary stated

---

## Scope Check 1 — Boundary Is Exact Enough To Authorize Without Scope Creep

The design names a single future file:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

The exact API signature is specified:

```ruby
module IgniterLang
  module CompilerProfileContractValidator
    module_function
    def validate(contract, digest_reference_policy: :prop038_24_plus)
      # returns string-key Hash
    end
  end
end
```

The exact return shape is specified with all seven keys:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": false,
  "diagnostics": [...],
  "diagnostic_codes": [...],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

The explicit write boundary restricts implementation to:

```text
- igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
- igniter-lang/experiments/compiler_profile_contract_proof/
- igniter-lang/docs/tracks/<future-track>.md
```

The avoid list names prohibited surfaces by class name:
`CompilerOrchestrator`, `CompilationReport`, `CompilerResult`,
`IgniterLang::Diagnostics`, assembler, CLI/API, `.igapp`, loader/report,
CompatibilityReport, RuntimeMachine.

The loading path is restricted to proof/spec code only:

```ruby
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"
```

No top-level `require_relative` in `igniter-lang/lib/igniter_lang.rb` for
the first extraction.

Boundary assessment: this is the most precisely scoped design card in the R58–R64
chain. Every dimension of the future implementation is pinned: file path, module
name, method signature, return shape, loading path, and write surface. An
implementation agent cannot widen scope without explicitly violating a stated
constraint. ✓

---

## Scope Check 2 — No Implementation-By-Implication; B1-B8 Require Explicit C3-A Authorization

The design track is explicitly labeled design-only:

```text
This track does not authorize or perform implementation.
```

All eight blockers require explicit C3-A sign-off before any code is written:

```text
[B1] C3-A must explicitly authorize creating
     igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb.
```

B1 is a meta-blocker: even the file creation requires authorization. This means
the design card itself cannot be mistaken for an implementation authorization.
The remaining B2–B8 each resolve a distinct policy question that must be answered
before implementation begins.

No code appears in the design track. The Ruby and JSON blocks are proposed future
shapes, not existing code. No `rg` output shows the file existing:

```text
no existing CompilerProfileContractValidator
```

The design track's `rg` inspection commands confirm current state and do not
produce any implementation output. ✓

---

## Scope Check 3 — B1 Descriptor Digest: Resolved Correctly As Shape-Only, Recomputation Out Of Scope

The design decision for descriptor digest input material:

```text
Do not recompute descriptor_digest in the first library validator.
```

Four sub-questions are listed that must be resolved before recomputation can be
considered:

```text
- exact descriptor object/material;
- canonical serialization;
- whether the digest excludes any digest field;
- caller ownership of descriptor material;
- diagnostic code for digest mismatch if needed.
```

The validation scope for descriptor digest in Option B is exactly:

```text
compiler_profile_descriptor/sha256:<24+ lowercase hex>
```

This is shape-only: the format pattern, not the computed value. An implementation
agent validating this shape cannot accidentally implement descriptor material
discovery or finalization because no recomputation code path is described.

R62-C2-X NB-1 asked whether B1 severity should be scoped between proof-local and
persisted contexts. This is now resolved: the design explicitly places descriptor
digest recomputation outside Option B and enumerates what must be decided before
it can enter. ✓

---

## Scope Check 4 — B2 Short-Vs-Full Digest Policy: Explicit And Tiered

The design states the default policy:

```text
Default policy: :prop038_24_plus
```

With the three-tier mapping:

```text
descriptor_digest:          24+ lowercase hex accepted
contract_digest:            24+ lowercase hex accepted [if shape-checked later]
finalization_payload_digest: full 64-character SHA-256
```

The rationale is correctly non-durable:

```text
Do not use full-64-only policy in Option B because no durable, persisted,
report, receipt, .ilk, .igapp, loader/report, or production-facing output is
being created.
```

The `:prop038_24_plus` symbol is machine-readable and can appear verbatim in
the implementation's `validate` signature. An implementation agent can apply
this policy from the design document without any ambiguity about which digest
fields accept short references.

The design uses "if shape-checked later" for `contract_digest`, correctly
flagging that Option B does not validate `contract_digest` format at all in the
first extraction. See NB-1 below for the non-blocking note on this gap. ✓

---

## Scope Check 5 — B7 Diagnostic Placement: Local To Validator, Not Centralized

The design decision:

```text
Keep compiler_profile_contract.* diagnostic construction local to
CompilerProfileContractValidator.
```

The rationale is sound:

```text
IgniterLang::Diagnostics currently enriches compiler diagnostics with
compiler report categories such as parser/classifier/typechecker/assembler;
moving contract diagnostics there would imply report-layer ownership;
Option B is internal object validation, not compiler report integration.
```

The private module helper pattern is shown:

```ruby
def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    "message" => message,
    "path" => path
  }
end
```

This resolves R62-C2-X NB-2, which noted that B7 diagnostic placement was
implied but not explicitly stated. The design now names the placement decision
and provides the helper pattern.

An implementation agent reading this design cannot centralize diagnostics in
`IgniterLang::Diagnostics` without violating the explicit decision. ✓

---

## Scope Check 6 — Contract Input Ownership: Explicit And Non-Public

The design decision:

```text
The caller owns the contract object.
```

The six prohibited input-widening behaviors are named:

```text
- read JSON paths;
- parse inline JSON;
- discover default profiles;
- finalize descriptors;
- derive a contract from compiler_profile_source;
- derive compiler_profile_source from a contract;
- call IgniterLang.compile;
- widen CLI or Ruby facade inputs.
```

The first caller for implementation:

```text
the existing experiment remains the caller and continues to build proof-local
contract objects
```

This means the library validator's first caller is still internal to the
`experiments/` directory. No public API surface is opened. No CLI flag is added.
No facade widening occurs.

The design also states what the validator must NOT do:
- reads files;
- builds or finalizes contracts;
- projects `compiler_profile_id_source`;
- calls the compiler, orchestrator, assembler, or report layer;
- writes `.igapp`, reports, receipts, `.ilk`, sidecars, or goldens.

The prohibition list is comprehensive. ✓

---

## Scope Check 7 — Non-Integrated And Non-Refusal: Machine-Asserted In Return Shape

The design's non-integration guarantee is expressed in two fields of the return
object:

```json
"compiler_integrated": false,
"compile_refusal_authorized": false
```

These fields will be machine-asserted in the proof parity requirement:

```text
same non-authorization flags
```

The design states these flags must remain false in the proof output after
extraction. This means:

1. An implementation agent cannot add compiler integration without those fields
   becoming true — which would fail the parity proof.
2. An implementation agent cannot add compile refusal without the same failure.

The parity proof is the enforcement mechanism for the non-integration and
non-refusal constraints. If C3-A authorizes Option B extraction and requires parity
proof, the machine-asserted flags are the functional equivalent of a test that
prevents unauthorized integration. ✓

---

## Scope Check 8 — Proof Parity And Fixture/Spec Policy: Exact And Unambiguous

The parity requirement is stated precisely:

```text
same 13 cases
same expected diagnostic codes
same PASS status
same non-authorization flags
```

The 13-case matrix is provided with case names and expected diagnostic codes:

| Case | Expected |
| --- | --- |
| `valid_contract` | valid |
| `missing_required_slot` | `compiler_profile_contract.missing_required_slot` |
| `duplicate_strict_key` | `compiler_profile_contract.duplicate_strict_key` |
| `duplicate_fragment_class_owner` | `compiler_profile_contract.duplicate_strict_key` |
| `rule_cycle` | `compiler_profile_contract.rule_cycle` |
| `missing_rule_reference` | `compiler_profile_contract.missing_rule_reference` |
| `missing_after_rule_reference` | `compiler_profile_contract.missing_rule_reference` |
| `wrong_kind` | `compiler_profile_contract.wrong_kind` |
| `unsupported_format_version` | `compiler_profile_contract.unsupported_format_version` |
| `descriptor_digest_invalid` | `compiler_profile_contract.descriptor_digest_invalid` |
| `finalization_payload_digest_invalid` | `compiler_profile_contract.finalization_payload_digest_invalid` |
| `runtime_authority_forbidden` | `compiler_profile_contract.runtime_authority_forbidden` |
| `dispatch_migration_forbidden` | `compiler_profile_contract.dispatch_migration_forbidden` |

The fixture/spec policy is explicit:

```text
experiment parity proof only
```

The four authorized future files are named exactly. The absence of a spec
directory is confirmed:

```text
no igniter-lang/spec directory exists in this workspace
```

No spec fixtures, no golden migrations, no production-facing test infrastructure
is authorized. The proof script switches from local `validate_contract` to the
library validator and keeps output in the same `out/` directory. ✓

---

## Scope Check 9 — Forbidden Surfaces: Comprehensive Hold Lists

The design contains two hold lists. The first (B1-B8 blockers) prevents
implementation authorization. The second is an explicit hold list for the
authorization itself:

```text
Hold implementation if C3-A requires any of the following in the same slice:
- report-only compiler integration;
- compile refusal;
- public API or CLI contract input;
- descriptor digest recomputation from external material;
- full-64-only digest references;
- new diagnostic vocabulary;
- CompilationReport or CompilerResult output;
- IgniterLang::Diagnostics centralization;
- .igapp, receipt, .ilk, sidecar, loader/report, or CompatibilityReport output;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.
```

The hold list covers all the surfaces that were held in R62-C3-A and R63-C3-A.
No new surfaces have been opened. No surfaces have been accidentally unblocked by
the design decisions.

The non-authorizations are correctly carried forward from the R63 proof into the
design boundary. ✓

---

[Agree]

1. **Boundary is exact and implementable.** The design provides file path, API
   signature, return shape, loading path, write surface, and prohibited surfaces
   at sufficient precision for a future implementation card to proceed without
   design ambiguity.

2. **B1 (descriptor digest) is correctly scoped.** Shape validation only;
   recomputation deferred; four sub-questions listed that must be resolved before
   recomputation enters scope. R62-C2-X NB-1 is closed.

3. **B2 (short-vs-full digest) is correctly tiered.** `:prop038_24_plus` is the
   right default for non-persisted internal validation. `finalization_payload_digest`
   retains full 64-char. The policy is machine-readable and usable verbatim in
   the implementation signature.

4. **B7 (diagnostic placement) is explicitly resolved.** Local to validator,
   not `IgniterLang::Diagnostics`. Private helper pattern provided. R62-C2-X NB-2
   is closed.

5. **Contract input ownership is unambiguous.** Eight prohibited behaviors are
   named. The first caller is the experiment. No public input is created.

6. **Non-integration and non-refusal are machine-asserted.** The return shape
   carries `compiler_integrated: false` and `compile_refusal_authorized: false`
   which must survive parity proof — functioning as a machine-enforced constraint
   against unauthorized integration.

7. **The proof parity matrix is complete.** All 13 cases with expected diagnostic
   codes are listed. No new diagnostics are introduced. The extraction cannot
   drift from proof behavior.

8. **Hold lists are comprehensive.** Every surface held in prior gates is
   explicitly listed. No surface was accidentally unlocked by the design
   decisions.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect authorization decision.

---

## NB-1 (Non-Blocking): `contract_digest` Format Not Validated In Option B

The design correctly notes for contract digest:

```text
Do not add contract_digest mismatch validation unless C3-A explicitly authorizes
a diagnostic vocabulary addition.
```

The consequence: the library validator will NOT validate that `contract_digest`
matches a 24+ hex format. The existing proof has no `contract_digest_invalid` case.
The `descriptor_digest_invalid` case validates the descriptor digest format; the
`finalization_payload_digest_invalid` case validates the finalization digest format;
but there is no corresponding `contract_digest_invalid` case.

The "if shape-checked later" language in the digest section correctly signals
this. The `:prop038_24_plus` policy description says `contract_digest` accepts
24+ lowercase hex "if shape-checked later" — which means the library validator
in first extraction simply does not check `contract_digest` format at all.

This is correct proof parity: the current proof script also does not assert a
`contract_digest_invalid` case. Proof parity is maintained.

The gap is intentional and correctly documented. It should be surfaced to C3-A so
the authorization decision explicitly acknowledges that `contract_digest` format
validation is deferred. If C3-A wants `contract_digest_invalid` in the library
validator, it must also authorize the diagnostic code and add a proof case — which
would be a vocabulary expansion beyond proof parity.

No action required before authorization. Correctly deferred. C3-A should confirm
awareness of the gap when authorizing B2/B4.

---

## Verdict

**Proceed.**

All nine scope checks pass. The Option B library validator extraction design is
exact, non-ambiguous, and correctly bounded. Descriptor digest is scoped to shape
validation only (B1 resolved, R62-C2-X NB-1 closed). Short-vs-full digest policy
is machine-readable as `:prop038_24_plus` with correct tiering (B2 resolved).
Diagnostic placement is explicitly local to the validator (B7 resolved, R62-C2-X
NB-2 closed). Contract input ownership prohibits all public input widening.
Non-integration and non-refusal are machine-asserted in the parity proof. The
13-case parity matrix is complete. All held surfaces from prior gates remain held.

One non-blocking note: `contract_digest` format is not validated in Option B and
no `contract_digest_invalid` proof case exists. This is correct proof parity and
intentionally deferred, but C3-A should acknowledge the gap explicitly when
authorizing B2 and B4.

No blockers. One non-blocking note.

---

[Route]

**Verdict: proceed.**

No blockers. One non-blocking note (NB-1).

**Recommended Architect decision (C3-A):**

1. Authorize bounded Option B library validator extraction with proof-parity only.
   Confirm all eight blockers B1-B8 are satisfied by the design.

2. Confirm B1: descriptor digest = shape validation only, no recomputation. The
   four open sub-questions (exact descriptor material, canonical serialization,
   digest exclusion, caller ownership) remain held for a future gate.

3. Confirm B2/B4: `:prop038_24_plus` digest reference policy for Option B.
   Acknowledge NB-1: `contract_digest` format is not validated in first extraction.
   If `contract_digest_invalid` diagnostic is wanted, a separate gate must add the
   diagnostic code and proof case.

4. Confirm B5: diagnostics remain local to `CompilerProfileContractValidator`,
   not centralized in `IgniterLang::Diagnostics`.

5. Confirm B6: caller supplies already-materialized contract Hash; no path
   loading, discovery, finalization, or public input widening authorized.

6. Confirm B7: proof parity is required — same 13 cases, same diagnostic codes,
   same `compiler_integrated: false` and `compile_refusal_authorized: false`.

7. Confirm B8: no compiler integration and no compile refusal in Option B.

8. Hold implementation if any surface in the design's hold list is requested in
   the same slice: report-only integration, compile refusal, public API/CLI,
   descriptor digest recomputation, new diagnostic vocabulary,
   `IgniterLang::Diagnostics` centralization, `.igapp`/receipt/`.ilk`,
   RuntimeMachine, Gate 3, or production behavior.

**For R65:**
- If C3-A authorizes Option B, the implementation card can write
  `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` and
  update the proof script to call it.
- If C3-A holds Option B pending a digest design sub-card, a narrow
  contract-digest-format design card should precede the implementation card.
- No compiler integration work opens from this design card.

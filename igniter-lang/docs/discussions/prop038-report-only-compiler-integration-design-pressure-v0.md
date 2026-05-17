# Discussion: PROP-038 Report-Only Compiler Integration Design Pressure v0

Card: S3-R66-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-report-only-compiler-integration-design-pressure-v0

Depends on: S3-R66-C1-P1 delivered

Question:

Does the design keep report-only strictly separate from compile refusal? Is
contract input ownership exact enough to prevent public API/CLI widening? Are
report/output options concrete and bounded? Is the orchestrator insertion point
explicit enough for a bounded implementation card? Are fixture/golden consequences
identified before any artifact mutation? Are descriptor digest and `contract_digest`
questions resolved or correctly held? Are loader/report, CompatibilityReport,
`.igapp`, RuntimeMachine, Gate 3, runtime, and production still closed? Can C3-A
authorize bounded implementation from this design card alone?

Context:
- R65-C3-A (gate): Accepts library validator extraction; explicitly holds compiler
  integration; routes next lane to design-only report integration planning; lists
  7 questions that must be resolved before any implementation
- R65-C4-S (curation): Confirms R65 closure; recommends
  `prop038-report-only-compiler-integration-design-v0` as next lane
- R66-C1-P1: Implementation Agent — design-only track; proposes internal provider
  pattern + in-memory `CompilationReport` annotation (Option A); 7-option table
  with clear hold/reject reasons; 10 blockers B1-B10 for C3-A authorization; exact
  write surfaces named; no code changed

---

## Scope Check 1 — Report-Only Is Strictly Separated From Compile Refusal

The design states five hard rules:

```text
invalid compiler_profile_contract => report field only
invalid compiler_profile_contract != compile refusal
invalid compiler_profile_contract must not change pass_result
invalid compiler_profile_contract must not change stages
invalid compiler_profile_contract must not block assembly
```

The validator result retains hardcoded non-refusal fields:

```json
{
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

The report attachment adds only:

```json
{
  "report_only": true
}
```

Explicitly prohibited terms from the design:

```text
CompilationReport.internal_error
CompilerResult.refusal
AssemblyRefused
report["pass_result"] = "error"
stage values "error" or "skipped" caused by contract validation
```

The five-rule hard separation plus the prohibited-term list is precise enough that an
implementation agent cannot accidentally create compile refusal without violating at
least one named constraint. The zero-change mandate on `pass_result`, `stages`, and
assembler execution covers all three paths through which report enrichment could
accidentally become compilation failure.

The insertion point design reinforces this:

```text
report = maybe_attach_compiler_profile_contract_validation(report, context)
return refusal(report, ...) unless report.pass_result == "ok"
```

The contract validation attachment runs before the existing refusal check; because the
attachment must not change `pass_result`, a previously-ok report stays ok after
attachment. ✓

---

## Scope Check 2 — Contract Input Ownership Is Exact And Non-Public

The design proposes:

```ruby
CompilerOrchestrator.new(compiler_profile_contract_provider: provider)
```

Where the provider is called:

```ruby
compiler_profile_contract_provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

And must return `Hash | nil`.

The design explicitly prohibits:

```ruby
IgniterLang.compile(..., compiler_profile_contract: ...)
```

```text
--compiler-profile-contract   (CLI flag)
```

Constructor injection to `CompilerOrchestrator` is internal — it does not appear in
any public Ruby facade or CLI surface. The `IgniterLang.compile` call site does not
change. The recommended first caller is a proof-local harness, not a CLI consumer.

The rules governing the orchestrator are exhaustive:

```text
does not read paths for the contract;
does not parse inline JSON;
does not discover, default, infer, or finalize profiles;
does not derive a contract from compiler_profile_source;
does not derive compiler_profile_source from a contract.
```

The provider model correctly preserves the Option B decision that the caller owns
the already-materialized contract Hash. The orchestrator remains a transport; the
provider owns the contract's provenance. ✓

See NB-1 below for a non-blocking note on the provider callable interface.

---

## Scope Check 3 — Report/Output Options Are Concrete, Bounded, And Correctly Triaged

The 7-option decision table is comprehensive:

| Option | Recommendation | Reason |
| --- | --- | --- |
| A: Internal `CompilationReport` field | **Recommended** | Smallest surface; no persistence; no public output; no golden migration |
| B: Persisted success `.compilation_report.json` | Hold | New persisted artifact requires output/golden policy |
| C: Sidecar JSON | Hold | New artifact surface; output location policy unresolved |
| D: `compile(...)` keyword | Hold | Public API widening risk |
| E: Public facade/CLI input | Reject | Explicitly closed |
| F: Assembler/`.igapp` integration | Reject | Crosses into compile-path and closed surface |
| G: `IgniterLang::Diagnostics` centralization | Hold | Previously held; implies report-layer ownership |

Option A is self-contained: it produces no persisted artifact, adds no public
output, and changes nothing about the observable behavior of a compile operation
from any caller that reads only `CompilerResult.public_result`.

The recommended `CompilationReport` field shape is specified:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": false,
  "diagnostics": [],
  "diagnostic_codes": [],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false,
  "report_only": true
}
```

The `report_only: true` field is added by the report attachment helper
(`CompilationReport.with_compiler_profile_contract_validation`) and is not part of
the raw validator output, preserving the validator's accepted result shape. ✓

The six options that are not Option A are correctly triaged: two are rejected with
explicit reasoning; four are held. No option is silently ignored. ✓

See NB-2 below for a non-blocking note on `compiler_integrated: false` semantics
in the report context.

---

## Scope Check 4 — Orchestrator Insertion Point Is Explicit And Correctly Placed

The design specifies the insertion point with four bounded conditions:

```text
after CompilationReport.enrich(...)
after semantic_ir is available
before `return refusal(...) unless report.pass_result == "ok"`
before assembler receives compiler_profile_source
```

The pseudo-code confirms the ordering:

```text
parse/classify/typecheck/emit complete
report = CompilationReport.enrich(...)
semantic_ir = compilation.fetch("semantic_ir")
report = maybe_attach_compiler_profile_contract_validation(report, context)
return refusal(report, ...) unless report.pass_result == "ok"
assemble_artifacts(... compiler_profile_source: compiler_profile_source)
```

This ordering matches PROP-038's validation order:

```text
compiler_profile_contract_validated
→ finalizes_to_compiler_profile_id_source
→ source_transported_and_validated_by_compiler_profile_source
```

Contract validation is after full compilation context is available (parsed,
classified, typechecked, emitted, enriched) and before assembler execution — which
is the correct PROP-038 sequence.

The design also correctly limits scope for failure paths:

```text
parse failures should not invoke the contract provider in the first implementation;
classifier/typechecker/emitter failure paths may attach only if C3-A explicitly
authorizes validation on failed compilation reports;
recommended first implementation validates only on the normal post-emit report path.
```

This means the first implementation is conservative: contract validation is a
report-path annotation on successful compile context only. ✓

The insertion point resolves the third item from the R65-C3-A gate's required-
design list ("orchestrator insertion point after contract input ownership is
resolved"). ✓

---

## Scope Check 5 — Fixture/Golden Consequences Are Identified; No Mutation Authorized

The design names the proof policy explicitly:

```text
new proof-local orchestrator report-only experiment, no golden migration
```

The fixture boundary is exact:

```text
Do NOT update:
- .igapp goldens
- CLI golden output
- production spec fixtures
- loader/report fixtures
- CompatibilityReport fixtures
```

The write surface for proof is new:

```text
igniter-lang/experiments/prop038_report_only_compiler_integration/
```

This is a new experiment directory (not an existing golden or fixture directory).
No existing test fixture or golden is mutated.

The required proof cases are specified:

1. valid contract attaches `compiler_profile_contract_validation.valid=true`;
2. invalid contract attaches `valid=false` and diagnostics;
3. invalid contract still returns compile status `ok` when program otherwise compiles;
4. public result remains unchanged;
5. no `.igapp` manifest changes;
6. no refusal report is written because of contract validation;
7. provider nil preserves legacy behavior and does not attach the field.

These 7 cases directly machine-assert the hard separation rules from Scope Check 1.
Case 3 is the pivotal one: it proves that an invalid contract + otherwise-compilable
program produces `status=ok`, preventing any future implementation from collapsing
the report-only boundary. ✓

---

## Scope Check 6 — Descriptor Digest And `contract_digest` Correctly Held

**Descriptor digest:**

Decision:

```text
Continue validator behavior: descriptor digest shape-only.
```

The design provides the correct rationale:
- orchestrator receives a contract object, not descriptor material;
- descriptor material ownership remains unresolved;
- canonical descriptor serialization remains unresolved;
- recomputation would require new diagnostics and proof cases.

Pattern unchanged from R65:

```text
compiler_profile_descriptor/sha256:<24+ lowercase hex>
```

Five sub-questions still explicitly blocked before durable output. ✓

**`contract_digest`:**

Decision:

```text
Keep contract_digest format/mismatch diagnostics deferred.
```

The design routes correctly: if C3-A wants `contract_digest` validation before
report-only integration, redirect to a separate digest diagnostic design card.
This avoids coupling the report-only integration with a new diagnostic vocabulary
expansion. ✓

Both decisions carry forward the R65 acceptances without reopening any previously
settled digest question. ✓

---

## Scope Check 7 — All Forbidden Surfaces Remain Closed

**Write surface — do-not-write list:**

```text
igniter-lang/lib/igniter_lang.rb              → do not write ✓
igniter-lang/lib/igniter_lang/cli.rb           → do not write ✓
igniter-lang/lib/igniter_lang/compiler_result.rb → do not write (first impl) ✓
igniter-lang/lib/igniter_lang/diagnostics.rb   → do not write ✓
igniter-lang/lib/igniter_lang/assembler.rb     → do not write ✓
parser, classifier, TypeChecker, SemanticIR    → do not write ✓
.igapp outputs/goldens                         → do not write ✓
loader/report, CompatibilityReport             → do not write ✓
RuntimeMachine, runtime, Gate 3, production    → do not write ✓
```

**Compiler result surface:**

```text
Do not change CompilerResult.
```

Public CLI output strips the internal `"report"` field. Because `CompilerResult`
is unchanged and the validation result lives only in the internal `CompilationReport`
field, the validation result is invisible to any public consumer. ✓

**`IgniterLang::Diagnostics`:**

Not in write surfaces. Diagnostics remain local to the validator. ✓

**Candidate options F and E rejected:**

Option F (assembler/`.igapp` integration) is rejected. Option E (public facade/CLI)
is rejected. Neither appears anywhere in the recommended write surface. ✓

**R65-C3-A non-authorization list cross-check:**

R65-C3-A held: compiler integration, report-only behavior, compile refusal,
parser/TypeChecker/SemanticIR/assembler/.igapp changes, CLI/API widening,
profile discovery/finalization, path loading, public facade widening, golden
migration, loader/report, CompatibilityReport, `IgniterLang::Diagnostics`,
`CompilerOrchestrator`/`CompilationReport`/`CompilerResult` changes, `.ilk`,
receipts, signing, dispatch migration, RuntimeMachine/Gate 3, Ledger/TBackend,
BiHistory, stream/OLAP, cache, production behavior.

The design opens exactly two of these: `CompilerOrchestrator` and
`CompilationReport` — by authorizing internal constructor injection and an
in-memory report field, respectively. All other surfaces from the R65-C3-A hold
list remain closed. The design explicitly names them in the do-not-write list. ✓

---

## Scope Check 8 — R65-C3-A Required Design Questions Are All Resolved

R65-C3-A required seven questions resolved before any implementation. Checking:

| R65-C3-A required | R66-C1-P1 resolution | Status |
| --- | --- | --- |
| Contract input ownership without public API/CLI widening | Internal provider on `CompilerOrchestrator` constructor; no facade/CLI change | ✓ resolved |
| Report/output location | Option A: in-memory `CompilationReport` field; no persistence | ✓ resolved |
| Orchestrator insertion point | After report enrichment, before assembler; failure-path policy stated | ✓ resolved |
| Fixture/golden policy | New proof-local experiment; no golden mutation; 7 proof cases | ✓ resolved |
| Descriptor digest material for integrated behavior | Shape-only continues; 5 blocked sub-questions named | ✓ held correctly |
| `contract_digest` format/mismatch | Deferred; redirect path if wanted before integration | ✓ held correctly |
| Explicit separation report-only vs compile refusal | 5 hard rules + prohibited term list | ✓ resolved |

All seven are answered. ✓

---

[Agree]

1. **Hard separation between report-only and compile refusal is precise.** Five
   rules, a prohibited-term list, and an insertion point that structurally prevents
   refusal from occurring collectively make this the clearest boundary drawn in the
   R57–R66 lane.

2. **Contract input ownership is non-public and cleanly bounded.** Constructor
   injection to `CompilerOrchestrator` is the correct internal surface. The
   forbidden list (no facade, no CLI, no derivation from `compiler_profile_source`,
   no path loading) exhaustively prevents API widening.

3. **The 7-option table is the right tool for this decision.** Options E and F are
   rejected with clear reasoning. Options B–D and G are correctly held rather than
   silently omitted. This pattern prevents future card authors from "re-discovering"
   a route that was already evaluated.

4. **Insertion point is correctly placed per PROP-038 validation order.** After
   report enrichment and before assembler matches
   `compiler_profile_contract_validated → finalizes_to_compiler_profile_id_source`.
   The parse-failure exclusion for the first implementation is conservative and
   correct.

5. **Fixture/golden consequences are fully identified.** New experiment directory,
   no golden mutation, 7 required proof cases that directly machine-assert the
   report-only boundary. Case 3 (invalid contract + ok compilation = ok status)
   is particularly important as a standing guard against future refusal creep.

6. **All seven R65-C3-A design questions are resolved.** The design card does what
   it was authorized to do.

7. **Exactly two previously-held surfaces are opened by this design** (`CompilerOrchestrator`
   and `CompilationReport` for non-public internal annotation). All other surfaces
   from the R65-C3-A hold list remain explicitly closed.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect authorization decision.

---

## NB-1 (Non-Blocking): Provider Callable Interface And Exception Handling Unspecified

The design shows the provider called as:

```ruby
compiler_profile_contract_provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

Two design questions are left open that the implementation card will need to resolve
without further architectural guidance:

**Interface type**: The design does not specify whether the provider must be a
`Proc`, a `lambda`, or any object responding to `call`. Ruby duck-typing makes this
flexible, but it affects how the orchestrator documents the expectation and how
proof harnesses construct the provider.

**Exception handling**: The design does not address what happens if the provider
raises. Options include: (a) propagate — treat as compile-time internal error;
(b) rescue and treat as `nil` — skip annotation silently; (c) rescue and attach
an error annotation. Option (b) is the safest for report-only behavior (no
influence on compile outcome), but it also hides provider bugs. Option (a) is
more discoverable but risks turning a provider failure into a compile failure,
which contradicts the report-only boundary.

Recommended resolution for the implementation card: `rescue => nil` (treat
provider exception as no contract provided), and document this behavior in the
proof case "provider nil preserves legacy behavior." If C3-A wants provider
exceptions to surface as internal errors, that requires explicit authorization.

No action required before C3-A authorization. The implementation card can resolve
this within the authorized boundary.

---

## NB-2 (Non-Blocking): `compiler_integrated: false` Is Semantically Ambiguous In Report Context

The validator result hardcodes `compiler_integrated: false`. When this result is
attached to an in-memory `CompilationReport` — running inside the compiler
orchestrator — the field is logically ambiguous:

- **Reading 1** (current intent): "this validation does not affect compile outcome
  (status, stages, refusal)." Under this reading, `compiler_integrated: false` is
  still correct in report-only context because the validation result does not drive
  any compile decision.

- **Reading 2** (surface reading): "this validator was not called from within the
  compiler." Under this reading, the field will be false even though the validator
  is now executing inside `CompilerOrchestrator`, which is misleading.

The design correctly chooses not to change the validator result ("the validator
result itself should not be changed unless C3-A explicitly authorizes it") and adds
`report_only: true` as report-layer metadata. This is the right decision for the
first integration boundary.

C3-A should confirm that Reading 1 is the intended interpretation — i.e.,
`compiler_integrated: false` means "does not drive compile outcome" rather than
"is not called from within the compiler." This framing should be carried into the
proof cases: the relevant assertion is that the compile status is unchanged, not
that `compiler_integrated` changes value.

A future gate, when/if the validator result becomes influence on compile outcomes,
should explicitly authorize flipping this field and updating the proof assertions.

No action required before C3-A authorization.

---

## Verdict

**Proceed.**

All eight scope checks pass. The design resolves all seven R65-C3-A required
questions. Report-only is precisely separated from compile refusal via five hard
rules, a prohibited-term list, and a structurally non-refusal insertion point. Contract
input ownership is non-public — constructor injection only, no facade/CLI change.
The 7-option table provides a durable decision record. The orchestrator insertion
point is correctly placed per PROP-038 validation order. Fixture/golden consequences
are fully identified with a new experiment directory and seven required proof cases.
Descriptor digest and `contract_digest` are correctly held. Exactly two previously-held
surfaces are opened (`CompilerOrchestrator` constructor + `CompilationReport` field);
all other surfaces remain closed.

Two non-blocking notes: NB-1 on provider callable interface and exception handling
(implementation card can resolve within authorized boundary); NB-2 on
`compiler_integrated: false` semantic ambiguity in report context (C3-A should
confirm Reading 1 is the intended interpretation).

No blockers.

---

[Route]

**Verdict: proceed.**

No blockers. Two non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Authorize bounded report-only compiler integration implementation (Candidate A
   only). Confirm all ten blockers B1-B10 are satisfied by the design.

2. Confirm B2/B3: internal provider on `CompilerOrchestrator` constructor; in-memory
   `CompilationReport` field only; no `CompilerResult` change; no persisted artifact.

3. Confirm B4/B5: insertion point after report enrichment, before assembler;
   invalid contract validation cannot alter `pass_result`, `stages`, assembler
   execution, or compile status.

4. Confirm B6/B7: descriptor digest remains shape-only; `contract_digest` format
   and mismatch validation remain deferred.

5. Confirm B8/B9: proof-local experiment scope only; no `.igapp`, CLI, public-
   result, loader/report, CompatibilityReport, or production golden/fixture mutation;
   `CompilerResult` and public CLI output unchanged.

6. Confirm B10: `IgniterLang::Diagnostics` centralization remains held.

7. Acknowledge NB-1: implementation card may resolve provider interface type and
   exception-handling policy (recommended: `rescue => nil`) within the authorized
   boundary without further design.

8. Confirm NB-2: `compiler_integrated: false` means "does not drive compile
   outcome" — not "is not called from within the compiler" — and this interpretation
   should be machine-asserted by proof case 3 (invalid contract + otherwise-ok
   program = ok status, field stays false).

9. Hold options B–D and G (persisted report, sidecar, compile keyword,
   `IgniterLang::Diagnostics`) pending their respective design cards if wanted.
   Reject options E and F (public facade/CLI, assembler/`.igapp`) for this lane.

10. Do not open compile refusal, loader/report, CompatibilityReport, CLI/API
    widening, production goldens, runtime, Gate 3, or any surface beyond
    `CompilerOrchestrator` constructor + `CompilationReport` field + proof
    experiment from this authorization.

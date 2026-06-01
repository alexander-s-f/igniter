# Delegated Experimental Runtime IVM FFI Bytecode Acceleration Pressure v0

Card: S3-R227-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-01

Depends on:
- S3-R227-C1-A
- S3-R227-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md` (C2-I)
- `playgrounds/igniter-runtime/out/ivm_ffi_bytecode_acceleration_proof/summary.json` (verified)
- `igniter-lang/docs/tracks/stage3-round226-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md` (R226-C4-A)

Mainline git status: one untracked file only (`igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-proof-v0.md` — the authorized track doc). No tracked files modified.

Playground output confirmed: `librunner.dylib`, `summary.json`.

---

## Verified Proof State

From summary JSON and track doc:

```text
Toolchain:     cc → librunner.dylib (build_success: true)
ABI:           8-byte instruction {int32_t opcode; int32_t arg}
               execute_bytecode(instructions, count, inputs, error_code) → int32_t
Serialization: l<l< little-endian pack

Parity verified:
  Add:                    Ruby→42,  Native→42   ✓
  GT true  (10>5):        Ruby→true,   Native→1 ✓
  GT false  (3>7):        Ruby→false,  Native→0 ✓
  Branch (flag=true):     Ruby→42,  Native→42   ✓
  Branch (flag=false):    Ruby→99,  Native→99   ✓ (non-selected silent)
  OP_UNSUPPORTED selected:   → error code 3 (fail-closed)    ✓
  OP_UNSUPPORTED non-selected: → jumped over, returns 100     ✓
  NULL / malformed input:    → error code 6                   ✓

Benchmark (informational, 20k iterations + 1k warmup):
  Ruby IVM:  0.0158s  (~1,267k iter/s)
  Native FFI: 0.0131s (~1,532k iter/s)
  Rough speedup: ~1.2x
  Bottleneck: Fiddle serialization overhead identified

R226 regression: 15/15 BCP PASS
overall: PASS (16/16)
```

---

## Risk Matrix

| Risk | Probability | Severity | Fence | Residual |
| --- | --- | --- | --- | --- |
| lib/**, bin/igc, gemspec, or README changed | Zero | Critical | FFI-15 PASS; `igniter_lang_lib_changed:false`, `bin_igc_changed:false`; mainline git: only untracked track doc | Zero |
| R223/R225/R226 evidence mutated | Zero | Critical | FFI-14 PASS; quickstart_result.json and BCP summary intact; FFI-13 PASS: R226 15/15 | Zero |
| Public performance claims from benchmark | Very low | High | FFI-12 PASS; `benchmark_policy: "informational proof-local timing measurements only"`; track doc NOTE explicitly labels hardware-dependency; `rough_speedup_x` in JSON naming; no "production performance," "benchmark guarantee," or "fast enough" wording | Very low |
| Reference Runtime / public runtime authority created | Very low | Critical | FFI-16 PASS; `non_claims` all false; `evidence_class: "native acceleration research evidence only"` | Very low |
| Native boundary is opaque or irreversible | Very low | Medium | FFI-2 PASS: 8-byte struct documented in C typedef and Ruby pack format; ABI labeled non-canonical, not public API, not stable; librunner.dylib is under playground out/ only | Very low |
| Ruby→int vs Native→bool representation mismatch misread as failure | Very low | Low | FFI-5/6: Ruby IVM returns `true`/`false`, native returns `1`/`0`; semantically correct; standard C integer truth | Very low |
| `closed_surface_scan` missing gemspec/RuntimeSmoke fields | Low | Low | R226 summary included gemspec; R227 does not; however mainline git clean confirms no tracked file changes; FFI-3/15 confirm no mainline changes | Very low — git confirms |
| AOT file loading recommendation leads to scope creep | Low | Medium | C2-I recommends AOT `.igbin`/`.igapp` file loading; this is a logical research extension; playground-only if pursued; see AN-1 | Low — AN-1 below |
| Three consecutive research rounds without TTEU forward movement | Medium | Low | R226-C3-X AN-1 named three options (B: helper, C: Runtime Spec still pending); see AN-1 | Low — C4-A must choose |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside authorized write scope | FFI-15 PASS; mainline git: one untracked track doc only; playground nested repo: `examples/ivm_ffi_bytecode_acceleration_proof.rb`, `lib/ivm/runner.c`, `out/ivm_ffi_bytecode_acceleration_proof/` all playground-local | Scope matches C1-A authorization exactly. `librunner.dylib` under `out/`. | ✅ PASS |
| Native boundary and ABI understandable and reversible | FFI-2 PASS; ABI: 8-byte `{opcode, arg}` struct, `l<l<` pack, int32 input array, int32 return; labeled `proof-local narrow 8-byte instruction + flat int32 stack/slots`; `librunner.dylib` is playground-only | Documented. Reversible by deleting playground files; no mainline entanglement. | ✅ PASS |
| Native execution parity proven against Ruby IVM oracle | FFI-4..FFI-8 all PASS; `parity_status: "verified_correctness_parity"`; five parity cases confirmed | Real parity, not asserted. Ruby IVM used as source-of-truth oracle. | ✅ PASS |
| Branch / lazy semantics survive native execution | FFI-7: flag=true → 42 in both; FFI-8: flag=false → 99 in both (non-selected silent); OP_JMP_UNLESS in supported opcodes | Jump semantics replicated in C. Non-selected silence preserved in native runner. | ✅ PASS |
| Unsupported selected/non-selected behavior remains honest | FFI-9: OP_UNSUPPORTED selected → error 3, halt; FFI-10: unselected OP_UNSUPPORTED → jumped over, returns 100; FFI-11: NULL → error 6; `unsupported_policy` field in JSON | Same invariant from R226 reproduced in C layer. No silent widening. | ✅ PASS |
| Benchmark wording avoids public performance claims | FFI-12 PASS; `benchmark_policy` field; track doc NOTE label; `rough_speedup_x: 1.2` labeled explicitly as rough; warmup/iteration context recorded; Fiddle bottleneck honestly named | No forbidden phrases found. Research-signal framing is honest. | ✅ PASS |
| Accepted R223/R225/R226 evidence immutable | FFI-13 PASS (BCP 15/15); FFI-14 PASS (quickstart_result.json intact) | All prior evidence anchors confirmed intact. | ✅ PASS |
| lib/**, bin/igc, RuntimeSmoke, gemspec, public docs closed | FFI-3/15 PASS; mainline git clean; surface scan confirms lib and bin unchanged | Confirmed. Note: R227 surface scan omits gemspec field (present in R226 JSON); compensated by git clean confirmation. | ✅ PASS |

---

## Benchmark Wording Assessment

The 1.2x speedup observation is labeled as:
- `rough_speedup_x: 1.2` (the "rough" qualifier is in the JSON key name itself)
- "local measurement," "proof-local timing," "rough comparison," "research signal" — all allowed wording per C1-A
- Track doc NOTE explicitly states hardware/scheduling dependency and "not public performance guarantees"
- The analysis (Fiddle overhead as bottleneck) is honest and useful context

The 1.2x figure with Fiddle overhead acknowledged is actually a *conservative* research signal. The research insight (AOT file loading would eliminate transition overhead) is sound and non-promotional. ✅ PASS.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Is C2-I evidence enough for C4-A acceptance? | Yes. 16/16 FFI checks pass, parity verified, benchmark wording conformant, all closed surfaces confirmed. |
| May generated outputs be called native acceleration research evidence only? | Yes. `evidence_class: "native acceleration research evidence only"` is correct and binding. |
| Does any wording risk imply public runtime or performance claims? | No. Benchmark wording is correctly hedged. `rough_speedup_x` naming, research-signal framing, Fiddle overhead acknowledgment, and the four `non_claims` all false confirm no overclaim. |
| What exact next route should C4-A choose? | See AN-1. C4-A must now choose between: continuing acceleration research (AOT file loading), shifting to TTEU (reusable helper, Options B from R226-C3-X), or formalizing (Runtime Specification input slice, Option C). |

---

## Non-Blocking Acceptance Note

**AN-1 — IVM playground corpus is mature; C4-A must now name a direction shift or explicit continuation.**

R225 proved adapter fit. R226 proved branch/comparison hardening. R227 proves native acceleration with correctness parity. Three consecutive rounds of playground research have produced a solid IVM foundation. The C2-I recommendation (AOT bytecode file loading) is a logical acceleration continuation.

However, the reusable helper (Option B from R226-C3-X) and Runtime Specification input slice (Option C) remain unaddressed from R224-C1-D and R226-C3-X respectively. These were not wrong to defer — adapter hardening and FFI acceleration produced meaningful evidence. But they are now three rounds overdue for a sequencing decision.

C4-A's choice now:

| Route | Focus | Value delivered | What's addressed |
| --- | --- | --- | --- |
| AOT file loading research | Acceleration depth | Eliminate Fiddle overhead; benchmark with real file I/O | R227 C2-I recommendation |
| Reusable helper extraction | TTEU / developer UX | Examples share runtime load/eval logic; reduces duplication | R224-C1-D (pending since R224) |
| Runtime Specification input slice | Normative formalization | Captured semantics from R225-R227 enter spec layer | R226-C3-X Option C |

If C4-A chooses AOT, it should name why acceleration depth takes priority over TTEU at this stage. If C4-A chooses reusable helper or spec slice, it should note that AOT remains available later. **Neither choice is wrong**, but the choice must be explicit.

---

## Verdict

```text
PASS

C2-I IVM FFI Bytecode Acceleration Proof: 16/16 FFI PASS — accept
No blockers
1 non-blocking acceptance note (AN-1: three rounds of playground research
  completed; C4-A must now name direction: AOT acceleration / reusable helper
  / Runtime Specification input slice)
C4-A HOLD: release; proceed to final acceptance decision
```

---

## Recommendation for S3-R227-C4-A

```text
Card: S3-R227-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I IVM FFI Bytecode Acceleration Proof (16/16 FFI PASS)
- Native C runner (librunner.dylib) under playground out/ only
- Parity: verified_correctness_parity across Add, GT, branch, unsupported
- evidence_class: "native acceleration research evidence only" (binding)
- Benchmark: informational only; rough_speedup_x 1.2x; Fiddle overhead noted

Note for acceptance record (AN-1):
  IVM playground corpus is now mature (R225: adapter, R226: hardening,
  R227: native acceleration). C4-A must explicitly choose next direction:
    AOT file loading:       deepen acceleration research
    Reusable helper:        TTEU / developer ergonomics (R224-C1-D pending)
    Runtime Spec slice:     formalize semantics from playground proofs
  The chosen route must be named in C4-A; not auto-routed to AOT.

Keep closed regardless of chosen route:
- lib/** changes
- bin/igc, gemspec, README, public docs
- RuntimeSmoke productization
- Reference Runtime implementation
- igc run (implementation)
- public runtime / stable API / production / Spark / release claims
- public performance claims
```

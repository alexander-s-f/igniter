# Delegated Experimental Runtime IVM AOT Bytecode File Loading Pressure v0

Card: S3-R228-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-ivm-aot-bytecode-file-loading-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-01

Depends on:
- S3-R228-C1-A
- S3-R228-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0.md` (C2-I)
- `playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json` (verified)
- `igniter-lang/docs/tracks/stage3-round227-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-acceptance-decision-v0.md` (R227-C4-A)

Mainline git status: clean — no tracked files modified outside playground.

Playground output directory confirmed: `add.igbin`, `gt.igbin`, `if.igbin`,
`bad_header.igbin`, `bad_data.igbin`, `unsupported_sel.igbin`,
`unsupported_unsel.igbin`, `timing_if.igbin`, `timing_warmup.igbin`,
`librunner.dylib`, `summary.json`.

---

## Verified Proof State

From summary JSON and track doc:

```text
Format:   .igbin — 16-byte header + N×8-byte instructions
          magic="IGB\x00", version=1, count, padding=0
          File size check: exactly 16 + 8×count

Static checks:  bad magic → err 11  ✓
                bad version → err 12  ✓
                truncated → err 14  ✓
                invalid opcode → err 17 (AOT pre-execution scan)  ✓
                out-of-bounds jump → err 4  ✓

Parity (Ruby IVM oracle vs file-backed native):
  Add:                   42=42   ✓
  GT true (10>5):         1=1   ✓
  GT false (3>7):         0=0   ✓
  Branch (flag=true):    42=42   ✓
  Branch (flag=false):   99=99   ✓ (non-selected silent)
  OP_UNSUPPORTED selected:   → error 3 (fail-closed)  ✓
  OP_UNSUPPORTED non-selected: → jumped over, returns 100  ✓

Benchmark (informational, 20k iter + 1k warmup):
  Ruby IVM:       0.0138s  (~1,445k iter/s)
  Native file:    0.1961s  (~101k iter/s)
  rough_speed_ratio: 0.1  (Ruby is ~10× faster per-iteration)
  Research insight: file I/O per-iteration is the bottleneck;
                    load-once-then-execute-from-memory is the fix

R227 regression: 16/16 FFI PASS
overall: PASS (17/17)
```

---

## Risk Matrix

| Risk | Probability | Severity | Fence | Residual |
| --- | --- | --- | --- | --- |
| lib/**, bin/igc, gemspec modified | Zero | Critical | AOT-16 PASS; mainline git clean (no output excluding playground untracked) | Zero |
| .igbin files escape playground out/ | Zero | High | All fixtures confirmed under `out/ivm_aot_bytecode_file_loading_proof/`; AOT-2 PASS | Zero |
| R223/R225/R226/R227 evidence mutated | Zero | Critical | AOT-14 PASS: R227 16/16; AOT-15 PASS: prior evidence verified intact | Zero |
| Malformed file behavior silently succeeds | Zero | High | AOT-11/AOT-12 PASS; error codes 11/12/14/17/4 tested with real fixture files (`bad_header.igbin`, `bad_data.igbin`); fixtures exist on disk | Zero |
| Benchmark overclaims native speed | Zero | High | AOT-13 PASS; `rough_speed_ratio: 0.1` — Ruby is faster; research insight honest (file I/O bottleneck); NOTE label; no "production performance" or "faster runtime claim" language | Zero |
| Reference Runtime / public runtime authority | Very low | Critical | AOT-17 PASS; `evidence_class: "native AOT bytecode file loading research evidence only"` | Very low |
| summary JSON missing machine-readable closed-surface scan / non-claims | Low | Low | R226/R227 summaries had `closed_surface_scan` and `non_claims` fields; R228 does not; compensated by git clean and AOT-16/17 checks | Low — see AN-1 |
| Infinite acceleration research continues silently | Medium | Medium | C1-A explicitly flagged "do not silently continue infinite acceleration research"; C2-I recommends memory-cached module system; TTEU options B/C still pending since R224 | Medium — see AN-2 |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside authorized write scope | AOT-16 PASS; mainline git clean; playground nested repo: new untracked proof file + out/ directory only | Scope matches C1-A authorization exactly. | ✅ PASS |
| Bytecode file format understandable and reversible | AOT-1 PASS; Section 2 documents format completely; labeled proof-local/non-canonical/not-public-API; all .igbin files under playground out/ | Format is minimal, documented, and fully reversible (delete playground files). Static-check error codes are clear. | ✅ PASS |
| Native file loading bounded to playground out/ | AOT-2 PASS; all .igbin artifacts confirmed under `out/ivm_aot_bytecode_file_loading_proof/` by directory listing | Confirmed. No .igbin outside playground scope. | ✅ PASS |
| Native execution parity proven against Ruby IVM | AOT-4..AOT-8 PASS; `parity_status: "verified_correctness_parity"`; five parity cases with concrete values | Real parity, not asserted. Add, GT×2, branch×2 all match. | ✅ PASS |
| Branch / lazy semantics survive file-backed execution | AOT-7: flag=true → 42; AOT-8: flag=false → 99 (non-selected silent) | JMP_UNLESS / JMP relative semantics preserved in file-backed path. | ✅ PASS |
| Unsupported and malformed file behavior honest | AOT-9/10 PASS: unsupported fixtures (`unsupported_sel.igbin`, `unsupported_unsel.igbin`) present; AOT-11/12 PASS: malformed fixtures (`bad_header.igbin`, `bad_data.igbin`) present; specific error codes tested | Real fixture files, not asserted. Error codes are distinct and specific (11/12/14/17/4). | ✅ PASS |
| Benchmark avoids public performance claims | AOT-13 PASS; `rough_speed_ratio: 0.1` (Ruby faster — correctly labeled as informational); NOTE label; bottleneck analysis honest; no forbidden phrases | The file-per-iteration benchmark correctly reveals the I/O bottleneck rather than claiming native speed. This is a stronger research signal than a faster number would have been. | ✅ PASS |
| Accepted R223/R225/R226/R227 evidence immutable | AOT-14 PASS (R227 16/16); AOT-15 PASS | All prior anchors intact. | ✅ PASS |
| lib/**, bin/igc, RuntimeSmoke, gemspec, public docs closed | AOT-16 PASS; mainline git clean | Confirmed from both check and git. | ✅ PASS (see AN-1) |

---

## Research Signal Assessment

The benchmark result (0.1× — Ruby 10× faster in this test) is actually the most valuable finding in this round. It is not a failure; it is an architectural truth. Opening the file, reading it, parsing the header, allocating, and executing on every single iteration is I/O-bound. The research insight — "AOT files must be loaded once into memory and then executed repeatedly from cache" — is correct and well-stated.

This finding closes the file-loading question. The next question (memory-cached load-once / execute-many) does not require another proof round to be understood. C4-A now has enough information to make a sequencing choice.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Is C2-I evidence enough for C4-A acceptance? | Yes. 17/17 AOT checks pass. Parity verified. Format documented. Malformed file behavior tested with real fixtures. Benchmark is honestly labeled. |
| May outputs be called AOT bytecode file-loading research evidence only? | Yes. `evidence_class: "native AOT bytecode file loading research evidence only"` is correct and binding. |
| Does any wording risk public runtime or performance claims? | No. The benchmark shows Ruby is faster in this configuration, which is honest. No overclaim wording found. |
| What exact next route should C4-A choose? | See AN-2. C1-A explicitly said: "do not silently continue infinite acceleration research." C4-A must now choose among acceleration continuation (memory-cache module), TTEU shift (reusable helper), Runtime Specification input slice, or experimental igc run design-only. |

---

## Non-Blocking Acceptance Notes

**AN-1 — Summary JSON is missing `closed_surface_scan` and `non_claims` machine-readable fields.**

R226 and R227 summaries included explicit `closed_surface_scan` and `non_claims` JSON objects. R228 summary does not. The evidence is still sufficient (AOT-16/AOT-17 PASS, mainline git clean, track doc statement), but the machine-readable signal is weaker.

Future AOT/acceleration proofs should include these fields for consistency with the R226/R227 summary contract. This is especially important as the playground research corpus grows.

**AN-2 — C1-A explicitly warned against infinite acceleration research; C4-A must now choose a direction.**

C1-A included this sequencing note:

> "This is an acceleration-depth closure slice. If C2-I succeeds, C4-A should explicitly choose whether to shift next toward reusable helper / experimental use, Runtime Specification input, experimental igc run design-only, or more AOT hardening. Do not silently continue infinite acceleration research."

C2-I recommends a memory-cached module system as the next step. This is technically sound but represents a fifth consecutive playground research round (R225: adapter, R226: hardening, R227: FFI parity, R228: AOT file loading). The reusable helper and Runtime Specification input slice remain unaddressed from R224-C1-D and R226-C3-X respectively.

What R228 actually settled: file I/O per-execution is slow; load-once-then-execute is the right architecture. This insight is captured. Further acceleration research on caching yields diminishing returns unless there is a specific product question it answers.

C4-A's explicit choice now:

| Route | Status | TTEU impact | What question it answers |
| --- | --- | --- | --- |
| Memory-cached AOT supervisor | New | Low direct | Can load-once+execute-many eliminate I/O bottleneck? |
| Reusable helper extraction | Pending since R224 | High | Can examples share runtime load/eval logic? |
| Runtime Specification input slice | Pending since R226 | Medium indirect | What semantics do R225-R228 contribute to the spec? |
| Experimental `igc run` design-only | Mentioned in C1-A | High later | What does a user-facing runtime command look like? |

All four are safe to open. C4-A must name one. Choosing memory-cached AOT is not wrong, but it requires an explicit reason why acceleration depth takes priority over TTEU at this stage.

---

## Verdict

```text
PASS

C2-I IVM AOT Bytecode File Loading Proof: 17/17 AOT PASS — accept
No blockers
2 non-blocking acceptance notes:
  AN-1: summary JSON missing closed_surface_scan / non_claims fields
  AN-2: C1-A explicitly warned against infinite acceleration research;
        C4-A must now choose among memory-cached AOT / reusable helper /
        Runtime Specification / igc run design-only
C4-A HOLD: release; proceed to final acceptance decision
```

---

## Recommendation for S3-R228-C4-A

```text
Card: S3-R228-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I IVM AOT Bytecode File Loading Proof (17/17 AOT PASS)
- .igbin format: 16-byte header + N×8-byte instruction records (binding)
- evidence_class: "native AOT bytecode file loading research evidence only" (binding)
- parity_status: "verified_correctness_parity" (binding)
- Key research finding: file I/O per-iteration is the bottleneck;
  load-once-then-execute-from-cache is the architectural answer (captured)

Note for acceptance record (AN-1):
  Future acceleration proof summaries should include closed_surface_scan
  and non_claims machine-readable fields matching R226/R227 contract.

Resolve AN-2 — choose one direction explicitly:
  A: Memory-cached AOT supervisor (continue acceleration depth)
     → requires explicit reason why this takes priority over TTEU
  B: Reusable helper extraction (TTEU, pending since R224-C1-D)
     → developer ergonomics, reduces examples duplication
  C: Runtime Specification input slice (pending since R226)
     → formalize R225-R228 playground semantics
  D: Experimental igc run design-only (mentioned in C1-A)
     → sketch user-facing runtime boundary before implementation

The acceleration research corpus is now mature. C4-A must name one.

Keep closed regardless of chosen route:
- lib/** changes
- bin/igc, gemspec, README, public docs
- RuntimeSmoke productization
- Reference Runtime implementation
- igc run (implementation)
- public runtime / stable API / production / Spark / release claims
- public performance claims
```

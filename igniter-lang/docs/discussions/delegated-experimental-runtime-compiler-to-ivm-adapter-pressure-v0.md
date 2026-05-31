# Delegated Experimental Runtime Compiler To IVM Adapter Pressure v0

Card: S3-R225-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R225-C1-A
- S3-R225-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md` (C2-I)
- `playgrounds/igniter-runtime/out/compiler_to_ivm_adapter_proof/summary.json` (verified)
- `igniter-lang/docs/tracks/stage3-round224-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-boundary-and-packaging-decision-v0.md` (R224-C4-A, via status curation)

Digest independently verified:

```text
semantic_ir_program.json SHA256:
  264b0b4043e294a52cc90e99eddd17098481d4e71d09390a357888ceef8aa62b  ✓ matches recorded
```

Mainline git status: clean — no tracked files modified outside playground.

---

## Verified Proof Pipeline

```text
R223 Add.igapp / semantic_ir_program.json (sha256: 264b0b40…)
  → playground adapter
  → IVM AST (binary_op +)
  → IVM bytecode: LOAD_REF "a" / LOAD_REF "b" / ADD / RET  (4 opcodes)
  → IVM execution: {a:19, b:23} → 42 ✓

Lazy branch (if_expr / JMP):
  → OP_JMP_UNLESS + OP_JMP relative jumps verified
  → non-selected else branch did not fire (AIP-7 PASS)
  → lazy branch semantics: verified

Unsupported nodes (fail-closed):
  stdlib.integer.gt  → UnsupportedNodeError  ✓
  field_access       → UnsupportedNodeError  ✓
```

---

## Risk Matrix

| Risk | Probability | Severity | C2-I fence | Residual |
| --- | --- | --- | --- | --- |
| R223 quickstart artifacts mutated | Zero | Critical | AIP-2 PASS; AIP-10 PASS; SHA256 independently verified matching; mainline git status clean | Zero |
| Adapter results labeled as public/Reference Runtime support | Very low | Critical | AIP-12 PASS; `evidence_class: "adapter-fit evidence only"` in JSON; non_claims: reference_runtime_support:false, public_runtime_support:false, stable_api_guarantee:false; three-runtime wording in track doc | Very low |
| Signed / tamper-evident / AT-10 / fully-bitemporal overclaim | Very low | High | AIP-9 PASS: "no overclaiming statements used in any active code path or summary outputs"; track doc uses "valid-time observation-shaped traces, not tamper-evident, signed, or AT-10-compliant" | Very low |
| Lazy branch not proven — silently omitted | Zero | High | AIP-7 PASS: non-selected else branch verified not to fire; AIP-8 PASS: OP_JMP_UNLESS and OP_JMP verified; lazy_branch_status: "verified" in JSON | Zero |
| lib/** or bin/igc changed | Zero | Critical | AIP-11 PASS; closed_surface_scan: igniter_lang_lib_changed:false, bin_igc_changed:false; mainline git status clean (independently verified) | Zero |
| Unsupported nodes fake-supported | Zero | High | AIP-6 PASS: field_access in selected-path correctly raises UnsupportedNodeError; stdlib.integer.gt in unsupported_nodes list; gap matrix explicit | Zero |
| source_igapp_sha256 ≠ semantic_ir_program_sha256 ambiguity | Low | Low | Both record the same digest (semantic_ir_program.json); the .igapp is a directory so file-level digest is appropriate; independently verified correct | Low — see AN-1 |
| FFI/C bytecode acceleration as next route diverges from TTEU priority | Medium | Medium | C2-I recommends FFI acceleration; R224-C1-D recommended reusable helper for TTEU; both are valid but they serve different goals | Medium — see AN-2 |
| igc run, RuntimeSmoke productization, Reference Runtime opened | Zero | Critical | AIP-11/AIP-12 PASS; closed surfaces confirmed; mainline clean | Zero |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside playground-only write scope | AIP-11 PASS; mainline git status clean; writes: `playgrounds/igniter-runtime/**` + mainline track doc only | Scope exactly matches C1-A authorization. | ✅ PASS |
| R223 quickstart artifacts not mutated | AIP-2 PASS; AIP-10 PASS; SHA256 independently verified on disk: `264b0b40…` matches; quickstart_result.json reads overall:PASS with no rewrites | Immutability confirmed from both the proof and independent digest verification. | ✅ PASS |
| `.igapp` / SemanticIR source evidence is real and digest-recorded | AIP-1 PASS; `source_igapp_sha256` and `semantic_ir_program_sha256` both recorded as `264b0b40…` (see AN-1); source path recorded; independently verified | Digest is real and correct. The .igapp path is the actual R223 output, not a synthetic fixture. | ✅ PASS (see AN-1) |
| Adapter support/gap matrix is explicit | Section 2 table: supported = literal, ref, binary_op(+), if_expr, apply(stdlib.integer.add); unsupported = stdlib.integer.gt, field_access; both unsupported nodes raise UnsupportedNodeError; `unsupported_nodes` in summary JSON | No fake support. Gap matrix is exact and machine-readable. | ✅ PASS |
| IVM execution result is real executable evidence | AIP-5 PASS: `execution_status:ok`, `actual_output:42`, `expected_output:42`; 4-opcode bytecode confirmed; not just mapping evidence | Real end-to-end execution: bytecode compiled from adapted AST, executed in IVM stack machine, returned 42. | ✅ PASS |
| Lazy branch semantics proven (not silently omitted) | AIP-7 PASS: non-selected else branch (rs_if6_non_selected_no_fire) did not fire, no apply-trace observations emitted; AIP-8 PASS: OP_JMP_UNLESS + OP_JMP verified in disassembly; `lazy_branch_status: "verified"` | Lazy branch is genuinely proven with IVM jump semantics. Non-selected branch silence is verified by absence of apply-trace observations. This is stronger than just recording a fixture gap. | ✅ PASS |
| Valid-time / observation wording avoids overclaims | AIP-9 PASS; track doc uses "valid-time observation-shaped traces, not tamper-evident, signed, or AT-10-compliant security/audit authorities"; non_claims in JSON all false; C1-A demo-text carve-out applied correctly | No forbidden overclaim wording found in result packet or track doc. | ✅ PASS |
| Closed surfaces stayed closed | AIP-11 PASS; RuntimeSmoke, CompilerResult, CompilationReport, gemspec, README, public docs — all unchanged; mainline git status clean | Confirmed from both the proof scan and independent git verification. | ✅ PASS |
| Next route: does C2-I recommendation match TTEU priority? | C2-I recommends FFI/C bytecode acceleration (performance-focused); R224-C1-D recommended reusable helper (TTEU-focused, developer ergonomics); neither is wrong but they serve different goals; C4-A must choose explicitly | Divergence is non-blocking for proof acceptance but requires C4-A to name a preferred sequencing. See AN-2. | ⚠️ See AN-2 |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Is C2-I evidence enough for C4-A acceptance? | Yes. 12/12 AIP checks pass, lazy branch verified, gap matrix explicit, all closed surfaces confirmed, digest independently verified. |
| May generated outputs be called adapter-fit evidence only? | Yes. `evidence_class: "adapter-fit evidence only"` is correct. Not Reference Runtime, not public runtime support. |
| Did runtime momentum change? | Yes — materially. AIP proof now shows: (1) compiler-emitted `.igapp` adapts to IVM bytecode without mainline changes, (2) lazy branch semantics work with IVM JMP opcodes, (3) the Add path produces 42 end-to-end through a new execution substrate. This is more than TTEU improvement; it validates the delegated runtime architecture. |
| What exact next route should C4-A choose? | See AN-2. C4-A must choose between FFI acceleration (C2-I recommendation) and reusable helper (R224-C1-D recommendation). Both are valid; C4-A names the preferred sequencing. |

---

## Non-Blocking Acceptance Notes

**AN-1 — `source_igapp_sha256` and `semantic_ir_program_sha256` record the same value.**

Both fields in the summary JSON contain `264b0b40…`, which is the SHA256 of `semantic_ir_program.json`. The `.igapp` is a directory, so recording the digest of its key content file (`semantic_ir_program.json`) is appropriate. The independently verified digest is correct.

Future adapter proofs should clarify this in the field description: either record a manifest-level `.igapp` digest separately, or document explicitly that `source_igapp_sha256` represents the `semantic_ir_program.json` digest when the `.igapp` is a directory.

This does not affect the validity of AIP-1.

**AN-2 — Next-route divergence: C2-I recommends FFI acceleration; R224-C1-D recommended reusable helper.**

C2-I recommends a playground-only FFI/C bytecode acceleration research pass as the next route. R224-C1-D recommended a reusable helper extraction (still pending from R224). These serve different goals:

- **FFI/C acceleration**: tests performance of the IVM execution path outside Ruby; playground-only; advances runtime architecture knowledge; does not improve developer ergonomics or reduce examples duplication; adds C/Rust toolchain complexity
- **Reusable helper** (R224-C1-D): reduces code duplication for developer examples; directly improves TTEU; playground/examples-only; addresses the AN-1 from R224-C3-X (adapter/normalizer fate)

Both are safe. Neither opens mainline or public API surfaces.

The IVM adapter proof gives new information: adapter fit is confirmed, lazy branch works, the bytecode substrate is viable. C4-A is now in a better position to choose:

- Option A: FFI acceleration next — prioritizes runtime architecture proof depth before helper ergonomics
- Option B: Reusable helper next — prioritizes TTEU and developer ergonomics, deferring FFI to after helper shape is proven
- Option C: Runtime Specification input slice — absorb IVM adapter learnings into a normative spec layer before more playground work
- Option D: IVM negative proof / broader fixture coverage — prove what contracts the IVM adapter cannot yet handle

**C4-A must name one ordering explicitly.** The IVM adapter proof does not automatically pick FFI acceleration.

---

## Verdict

```text
PASS

C2-I Compiler-to-IVM Adapter Proof: 12/12 AIP PASS — accept
No blockers
2 non-blocking acceptance notes (AN-1: dual-digest field clarification;
  AN-2: C4-A must choose next-route sequencing explicitly)
C4-A HOLD: release; proceed to final acceptance decision
```

The adapter proof is high-quality and materially advances runtime architecture understanding. Lazy branch semantics are genuinely proven (not fixture-gapped). The gap matrix is honest. All closed surfaces confirmed.

---

## Recommendation for S3-R225-C4-A

```text
Card: S3-R225-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I compiler-to-IVM adapter proof (12/12 AIP PASS)
- IVM execution: {a:19,b:23} → 42 via adapted bytecode
- Lazy branch status: verified (OP_JMP_UNLESS / OP_JMP)
- evidence_class: "adapter-fit evidence only" (binding)
- source SHA256: 264b0b4043e294a52cc90e99eddd17098481d4e71d09390a357888ceef8aa62b

Note for acceptance record (AN-1):
- source_igapp_sha256 and semantic_ir_program_sha256 record the same value
  (semantic_ir_program.json digest); acceptable for directory .igapp;
  future proofs should document this or record manifest-level digest distinctly

Resolve AN-2 — name one next-route ordering explicitly:
  Option A: FFI/C bytecode acceleration (C2-I recommendation)
            → playground-only; performance-focused; adds toolchain complexity
  Option B: Reusable helper extraction (R224-C1-D recommendation)
            → TTEU-focused; developer ergonomics; addresses R224-C3-X AN-1
  Option C: Runtime Specification input slice
            → absorb IVM learnings into normative layer
  Option D: IVM negative proof / broader fixture coverage
            → prove current adapter gaps before acceleration or extraction

Keep closed:
- igc run (implementation)
- RuntimeSmoke productization
- Reference Runtime implementation
- Runtime Specification implementation (unless Option C chosen)
- lib/** changes
- gemspec / README / public docs
- public runtime / stable API / production / Spark / release claims
```

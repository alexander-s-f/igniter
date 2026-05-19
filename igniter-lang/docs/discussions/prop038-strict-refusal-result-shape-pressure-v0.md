# PROP-038 Strict Refusal Result Shape Pressure v0

Card: S3-R80-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-strict-refusal-result-shape-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`

Inputs reviewed:

- `docs/tracks/strict-refusal-result-shape-and-nonpersisting-path-design-v0.md` (S3-R80-C1-P1)
- `docs/tracks/prop038-public-result-and-diagnostics-proof-surface-survey-v0.md` (S3-R80-C2-P1)

---

## Question

Does the strict-refusal result-shape and non-persisting path design (C1-P1)
correctly define `refused` status, public key-set, nested diagnostics isolation,
and non-persisting orchestrator path without authorizing implementation? Does the
public result and diagnostics proof-surface survey (C2-P1) ground these design
decisions in current code facts, and are the two cards consistent with each
other?

---

## Scope Checks

[1] Design does not authorize implementation or live compile refusal.

C1-P1 states implementation is not authorized. `refused` status requires explicit
`CompilerResult` authority (blocker #2). The non-persisting path is described as
a design candidate only. C2-P1 is read-only; no code was edited. Both cards carry
comprehensive non-authorization sections. Check: PASS.

[2] `refused` status is design-only and requires explicit `CompilerResult`
authority.

C1-P1 names `refused` as the accepted status vocabulary and explicitly places
`CompilerResult` authority as blocker #2. The design does not authorize mutating
`report["pass_result"]`; that field remains `"ok"` in baseline compile. `refused`
appears only in the internal result shape design sketch, not in live code.
Check: PASS.

[3] `CompilerResult` is held for a later implementation gate.

C1-P1 lists thirteen explicit blockers before implementation authorization.
Blocker #2 is "Explicit `CompilerResult` authority if result shape changes."
No `CompilerResult` constructor or method is added in this round. Check: PASS.

[4] Public key-set is explicit and consistent between C1-P1 and C2-P1.

C1-P1 names a 12-key allowlist for the strict-refusal public result shape:
`kind`, `format_version`, `status`, `program_id`, `source_path`, `source_hash`,
`grammar_version`, `stages`, `igapp_path`, `contracts`, `compilation_report_path`
(null for non-persisting path), `diagnostics`, `warnings`. Six negative
assertions accompany the allowlist: `report`, `compiler_profile_contract_validation`,
`strict_refusal`, `wrapper_evidence`, `compile_refusal_authorized`, and raw nested
validators are all explicitly forbidden from public exposure.

C2-P1 maps the current observed public key sets from
`production_compiler_cli_summary.json` (success: 15 keys; OOF/refusal: 13 keys)
and confirms `public_result` is `result.reject { |key, _value| key == "report" }`,
a deny-one filter with no whitelist. C2-P1 raises this as a future assertion
requirement, and C1-P1 addresses it by defining an explicit allowlist for
strict-refusal shape. The two cards are consistent on key-set design intent.
Check: PASS.

[5] Nested diagnostics isolation is explicit, with proof assertions required.

C1-P1 states that nested validation diagnostics remain under
`report["compiler_profile_contract_validation"]["diagnostics"]`, are not appended
to `report["diagnostics"]`, are not consumed by `Diagnostics.errors` or
`Diagnostics.warnings`, and that a single wrapper diagnostic may appear in the
public `diagnostics` field with its evidence confined to the nested location.
Five named proof assertions are required for this policy.

C2-P1 independently confirms the current four code facts that enforce this
isolation: not appended to `report["diagnostics"]`, not consumed by
`Diagnostics.errors`, hidden from public result by `public_result` stripping
`report`, and `.igapp/compilation_report.json` written from `report_for_assembly`
captured before PROP-038 annotation. The two cards are consistent on nested
diagnostics isolation. Check: PASS.

[6] Malformed strict requirement policy is decided, not left open.

C1-P1 closes the R79-C4-A blocker (#2 from R79): malformed strict requirement
produces `configuration_error` status, not a refusal. The reason code is
`compiler_profile_contract_refusal.strict_requirement_malformed` (design-only).
This is the first card to resolve this question; it does so explicitly.
Check: PASS.

[7] Non-persisting path is clean: no `.compilation_report.json` sidecar, no
assembly, no call to `#refusal`.

C1-P1 states explicitly: "The strict-refusal path does not call
`CompilerOrchestrator#refusal`. It does not write a `.compilation_report.json`
sidecar. It does not call `Assembler.assemble_artifacts`." These three
prohibitions are stated as non-authorization design rules. Required proof
assertion #4 is: "No `.compilation_report.json` written, no `.igapp/` written."
Check: PASS.

[8] Existing `CompilerOrchestrator#refusal` is unchanged for all current paths.

C1-P1 states: "Unchanged. Ordinary parse/oof/assembler/runtime-smoke refusal
still uses it." C2-P1 confirms the current sidecar report behavior of `#refusal`
with the code path `write_json(report_path, report)`. Both cards are consistent
that `#refusal` is not modified by the design. Check: PASS.

[9] `report_for_assembly` and `.igapp` boundaries are protected.

C1-P1 states: "The `report_for_assembly = report` capture line must not change."
Four `.igapp` policy closures are listed: no strict/refusal fields in
`.igapp/compilation_report.json`, manifest unchanged, `.igapp` not written for
strict refusal, `Assembler.assemble_artifacts` not called for strict refusal.
Check: PASS.

[10] All forbidden surfaces remain closed.

Both cards carry preserved-closed-surfaces sections. The combined list covers
live compiler/orchestrator behavior changes, live compile refusal, public API/CLI
widening, `CompilerResult` changes, persisted reports or sidecars, parser,
TypeChecker, SemanticIR, assembler, `.igapp`, loader/report,
CompatibilityReport, diagnostics centralization, dispatch migration,
RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, and
production behavior. No forbidden surface is opened by either card. Check: PASS.

[11] Proof matrix is strong enough for future implementation review.

C1-P1 defines six required proof categories: (1) strict-refusal result shape and
status, (2) public key-set exact assertion, (3) nested diagnostics isolation,
(4) non-persisting path with no-sidecar proof, (5) legacy/report-only unchanged
behavior, (6) public API/CLI non-widening. C2-P1 provides a 7-anchor existing
proof matrix showing which current proofs cover which regression surfaces. The
combined proof requirement is sufficiently explicit and layered. Check: PASS.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 2
```

All eleven scope checks pass.

---

## Non-Blocking Notes

NB-1: C2-P1 asks which proof owns the canonical public key-set assertion (Q7:
`prop038_report_only_compiler_integration`, `production_compiler_cli_proof`, or
a future strict-refusal proof). C1-P1 implicitly routes this to the future
strict-refusal proof by including a public key-set assertion in required proof
category #2 and naming it as a strict-refusal proof requirement. C4-A should
confirm that the future strict-refusal proof is the canonical owner of this
assertion, and that `production_compiler_cli_proof` remains the regression anchor
only for current OOF/error refusal public shape.

NB-2: C2-P1 Q2 asks whether `compilation_report_path` should be omitted from the
non-persisting strict-refusal public result or kept with a non-persisting evidence
shape. C1-P1 resolves this by keeping the field present with a `null` value in the
internal result shape (design sketch shows `compilation_report_path: null`). C4-A
should confirm that `compilation_report_path: null` is the accepted approach (field
present, null value) rather than field omission, and that this null-present
convention is intentional design vocabulary for non-persisting paths.

---

## [Agree]

- The strict-refusal result shape is correctly separated from `report["pass_result"]`
  mutation; `pass_result` correctly remains `"ok"` in baseline compile.
- Malformed strict requirement policy is now decided (`configuration_error`); this
  closes the longest-standing open blocker in the R79-C4-A list.
- The non-persisting path design cleanly breaks from `CompilerOrchestrator#refusal`
  with three explicit prohibitions (no `#refusal` call, no sidecar, no assembler
  call).
- The 12-key public result allowlist is the correct design response to C2-P1's
  code-fact finding that `public_result` is a deny-one filter.
- The nested diagnostics policy (one wrapper in public, evidence stays nested) is
  the appropriate minimal exposure model given the existing isolation invariants.
- `program_id: semantic_ir_ref` for strict refusal is the correct design stance —
  it avoids conflating contract digest identity with program identity.
- The 13 blockers in C1-P1 correctly carry forward all 14 R79-C4-A required
  items with appropriate scoping.

## [Challenge]

None. Both cards are internally consistent and consistent with each other.
No scope leak, vocabulary collision, or forbidden surface implication was found.

## [Missing]

- The `configuration_error` internal result shape is not sketched as completely
  as the `refused` shape in C1-P1. Future implementation cards should ensure the
  malformed-requirement path has an equally explicit internal result shape (stages,
  `igapp_path`, `compilation_report_path`, `diagnostics` content). This is a
  future design gap, not a blocker for C4-A acceptance.

## [Sharper Question]

Which proof is the canonical owner of the strict-refusal public key-set assertion:
the future `prop038_strict_refusal_proof` (implied by C1-P1 category #2), or
`production_compiler_cli_proof` (C2-P1 Q7)? C4-A should name the owner explicitly
to prevent two proofs asserting the same surface with potential future divergence.

## [Route]

route: implementation authorization design gate — open `prop038-strict-refusal-result-shape-and-nonpersisting-path-decision-v0.md` as the C4-A gate after C4-A architect review.

---

## Handoff

Card: S3-R80-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-strict-refusal-result-shape-pressure-v0
Status: done

[D] Decisions

- Pressure review of C1-P1 (strict-refusal result shape and non-persisting path
  design) and C2-P1 (public result and diagnostics proof-surface survey) completed.
- All 11 scope checks pass.
- No blockers found.
- Two non-blocking notes routed to C4-A: NB-1 (canonical owner of public key-set
  assertion), NB-2 (null-present vs omit convention for `compilation_report_path`
  on non-persisting path).

[S] Shipped / Signals

- Added this discussion document.

[T] Tests / Proofs

- Read-only review. No code run or experiments changed.

[R] Risks / Recommendations

- C1-P1 correctly names 13 blockers. All must remain unresolved until explicitly
  closed by subsequent design and implementation gates.
- The `configuration_error` path internal result shape should be specified as
  concretely as the `refused` path before implementation authorization.
- `public_result` deny-one filter risk noted in C2-P1 is addressed by C1-P1's
  allowlist design; C4-A gate should confirm the allowlist approach is the
  accepted implementation requirement.

[Next] Suggested next slice

- C4-A should accept C1-P1 design, confirm NB-1 (proof owner) and NB-2
  (null-present convention), and authorize only the next design route toward
  implementation authorization. No implementation card may open directly from R80.

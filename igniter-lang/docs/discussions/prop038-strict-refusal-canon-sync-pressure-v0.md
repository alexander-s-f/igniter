# prop038-strict-refusal-canon-sync-pressure-v0

Card: S3-R85-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: canon-pressure
Track: prop038-strict-refusal-canon-sync-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-20

---

## Inputs Read

- `igniter-lang/docs/tracks/prop038-strict-refusal-canon-sync-v0.md` (C1-P1)
- `igniter-lang/docs/tracks/prop038-strict-refusal-regression-and-canon-map-v0.md` (C2-P1)
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md` (S3-R84-C1-A)
- `igniter-lang/docs/tracks/stage3-round84-status-curation-v0.md` (S3-R84-C2-S)
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md` (after C1 sync)
- `igniter-lang/docs/current-status.md` (after C1 sync)
- `igniter-lang/docs/tracks/README.md` (after C1 sync)
- `igniter-lang/docs/gates/README.md`

---

## Scope Checks

### 1. R84 accepted live internal foundation is accurately stated

**Baseline from R84-C1-A**:

- status: `accepted-live-internal-foundation`
- Accepts R83 bounded internal-only strict-refusal implementation as live internal
  foundation
- Internal constructor/test seam only; orchestrator-level decision path is
  authority; validator output remains evidence; `compile_refusal_authorized: false`
  is nested report-only marker; `report.pass_result == "ok"` invariant holds for
  strict terminal paths; `refused`/`configuration_error` share exact 13-key
  public key-set; non-persisting, no sidecar, no report, no `.igapp`

**C1 (PROP-038 §10.4 after sync)**:

```text
internal strict requirement source
  -> orchestrator-level strict requirement decision path
  -> report-only compiler_profile_contract_validation evidence
  -> non-persisting strict terminal CompilerResult when selected
```

Matches R84-C1-A accepted live internal foundation exactly. ✓

**C2 (regression/canon map — "Accepted Canon" section)**:

```text
internal strict requirement source
  -> orchestrator strict decision path
  -> report-only PROP-038 validation evidence
  -> non-persisting strict terminal result when selected
```

Matches R84-C1-A. ✓

**current-status.md (after C1 sync)**:

```text
R84 accepts that implementation as the live internal foundation;
R85 syncs PROP-038 canon text to R84 without widening behavior;
```

Both lines are accurate. ✓

**tracks/README.md (after C1 sync)**:

Entry for `prop038-strict-refusal-canon-sync-v0` describes the sync correctly,
naming internal-only strict source, validator-as-evidence,
`compile_refusal_authorized: false`, `report.pass_result == "ok"`, exact 13-key
terminal key-set, non-persisting terminal paths, and closed public/runtime
surfaces. ✓

**Result: PASS**

---

### 2. No doc claims public API/CLI exposure

**C1 "Non-Authorization Preserved" section** explicitly lists:

```text
public API/CLI widening
```

C1 also states: "This is a docs-only canon sync. It does not ... authorize public
exposure." ✓

**C2 "Protected Closed Surfaces" section** explicitly lists:

```text
public API/CLI widening;
IgniterLang.compile signature changes
```

C2 "Recommendation" states: "should not be used to open public API/CLI, loader/report,
CompatibilityReport, runtime, or production behavior without a separate gate." ✓

**PROP-038 §10.4 "Closed surfaces"** after sync:

```text
public Ruby API;
CLI;
```

Both explicitly listed. ✓

**Changed docs list (C1)**: no `igniter_lang.rb`, no `cli.rb`, no `bin/` file.
Only four docs changed: `PROP-038-compiler-profile-contract-v0.md`,
`current-status.md`, `tracks/README.md`, and the canon-sync track itself. ✓

**Result: PASS**

---

### 3. No doc claims loader/report, CompatibilityReport, RuntimeMachine/Gate 3, runtime, or production authority

**C1 "Non-Authorization Preserved" section** enumerates:

```text
loader/report or CompatibilityReport behavior;
RuntimeMachine, Gate 3, runtime, or production behavior
```

**C2 "Protected Closed Surfaces" section** enumerates:

```text
env/config/manifest/default/generated strict source lookup;
loader/report strict source or status;
CompatibilityReport strict source or status;
RuntimeMachine or Gate 3 widening;
Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior
```

**PROP-038 §10.4 "Closed surfaces"** lists all explicitly:

```text
loader/report strict source or status;
CompatibilityReport strict source or status;
...
RuntimeMachine, Gate 3, runtime, and production behavior
```

**PROP-038 §16 "Explicit Excluded Surfaces"** retains the full exclusion list
including `CompatibilityReport`, `loader/report`, `RuntimeMachine / Gate 3
widening`, `Ledger/TBackend`, `BiHistory`, `stream/OLAP production execution`,
`cache`, and `production behavior`. ✓

None of C1, C2, or the synced PROP text introduce any of these surfaces.

**Result: PASS**

---

### 4. No doc claims persisted reports/sidecars/`.igapp` for strict terminal paths

**C1**: "strict terminal paths are non-persisting/no-sidecar/no-report/no-`.igapp`" ✓

**C1 "Non-Authorization Preserved"**: "persisted reports or sidecars; `.igapp` mutation" ✓

**C2 "Accepted Canon" terminal status table**:

| Status | Persistence |
| --- | --- |
| `refused` | no sidecar, no report path, no `.igapp` |
| `configuration_error` | no sidecar, no report path, no `.igapp` |

✓

**PROP-038 §10.4**: "strict terminal paths are non-persisting, with no sidecar,
no report write, no `.igapp`, and no assembler call" ✓

**C2 proof case table**: `strict_digest_mismatch_refused` and
`strict_malformed_configuration_error` both show `igapp: no`, `sidecar: no` ✓

All documents are consistent. No persistence language appears in connection with
strict terminal paths.

**Result: PASS**

---

### 5. Validator remains evidence, not authority

**C1 drift fix D2** explicitly makes this boundary clear in PROP-038:

```text
contract_digest diagnostics alone do not authorize refusal
orchestrator-level strict requirement decision path is authority
validator output is evidence, not authority
```

**C2 "Accepted Canon"**: "Validator remains evidence, not authority: nested
`compile_refusal_authorized: false` remains preserved." ✓

**PROP-038 §10.4**: "`CompilerProfileContractValidator` output is evidence, not
authority; nested `compile_refusal_authorized: false` remains a report-only
marker" ✓

The `compile_refusal_authorized: false` flag's position is consistently described
as nested under `compiler_profile_contract_validation.diagnostics`, never at the
public top level. Raw validator diagnostics placement under
`compiler_profile_contract_validation.diagnostics` (not top-level) is preserved
throughout. ✓

**Result: PASS**

---

### 6. Proof anchors are clear and future expansion guards are actionable

**C2 "Regression Anchors" table** names 10 anchors, each with a "why it stays in
chain" rationale:

| Anchor | Coverage |
| --- | --- |
| `prop038_strict_refusal_live_implementation_proof` | Primary: strict terminal behavior, ordinary preservation, non-persisting construction |
| `compiler_profile_contract_proof` | Validator namespace and contract matrix; validator-as-evidence boundary |
| `prop038_contract_digest_shape_policy_proof` | Digest shape/policy diagnostic surface |
| `prop038_contract_digest_recompute_match_proof` | Recompute mismatch/unavailable and fail-open baseline |
| `prop038_contract_digest_report_only_integration_proof` | Nested diagnostics isolation, report-only invariants |
| `prop038_report_only_compiler_integration` | Live report-only integration; invalid contract still compiles/assembles |
| `prop038_strict_mode_refusal_trigger_proof` | Historical proof-local trigger/evidence model; wrapper diagnostic intent |
| `prop038_strict_refusal_result_shape_proof` | R81 target result shape and key-set baseline |
| `production_compiler_cli_proof` | Public CLI output/exit/report behavior remains closed and stable |
| `igapp_assembler_proof` | Artifact shape and assembler boundary unchanged |

Coverage is complete for the canonical proof chain through R84.

**C2 "Future Expansion Guard Checklist"** lists 14 specific re-proof requirements.
All are concrete and mechanical: named keys, named paths, named callers,
named behaviors. A future expansion agent can directly check each item.

**C2 "Expansion Risks" table** identifies 8 specific expansion vectors with
concrete failure modes (e.g., constructor seam becoming user-facing authority,
loader vocabulary leaking into compiler result surfaces). Risk language is precise
rather than vague.

The one mild gap: C2 did not independently re-run any proof commands; it reads the
accepted R83/R84 summary as canon. This is correct for a read-only canon map
(not a re-verification track) but means the map cannot confirm current code state
independently. This is a non-blocking observation consistent with C2's assigned
scope.

**Result: PASS**

---

### 7. Status and indexes do not contradict the gate chain

**Reconstructed gate chain from R83–R85**:

```text
R83-C1-A: authorized-bounded-internal-only-implementation
R83-C2-I: done (16 cases / 46 checks / 0 failed; 11 commands PASS)
R83-C3-X: proceed (10/10 checks; 1 non-blocking note)
R84-C1-A: accepted-live-internal-foundation
R84-C2-S: done
R85-C1-P1: done (canon sync)
R85-C2-P1: done (regression/canon map)
```

**current-status.md** records all R83–R84 cards with correct statuses:

```text
S3-R83-C1-A: authorized-bounded-internal-only-implementation ✓
S3-R83-C2-I: done; 16 cases / 46 checks / 0 failed; 11 commands PASS ✓
S3-R83-C3-X: proceed; 10/10 checks; no blockers; 1 non-blocking note ✓
S3-R84-C1-A: accepted-live-internal-foundation ✓
S3-R84-C2-S: done ✓
```

The R85 entry reads: "R85 syncs PROP-038 canon text to R84 without widening
behavior" — accurate and non-widening.

**tracks/README.md** correctly lists both R85 C1 and the acceptance decision with
accurate status labels and summaries.

**gates/README.md** records `prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
as `accepted-live-internal-foundation` at S3-R84-C1-A. C1 noted this file already
reflected R84 accurately and was not edited — correct.

No contradictions found between any status entry and the corresponding gate chain
document.

**Result: PASS**

---

### 8. PROP-038 stale language was replaced correctly

C1 identified four drift points:

- **D1**: Stale "compile refusal remains closed" replaced with the
  internal-only/public-closed distinction. The synced text names the boundary
  precisely: internal foundation is accepted; public/runtime/production refusal
  remains closed. ✓
- **D2**: Authority split made explicit. The orchestrator is authority; validator
  is evidence. ✓
- **D3**: R84 properties canonized in PROP-038 §10.4. All 13 properties from the
  R84 acceptance decision appear in §10.4. ✓
- **D4**: Proof evidence updated in §15 to cite R74 validator implementation and
  R83/R84 strict-refusal evidence. ✓

No new semantics were introduced beyond what R84 already accepted. All four drift
fixes are backward-looking (recording accepted decisions), not forward-looking
(authorizing future behavior).

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: Ch5/Ch7 spec wording not synced

C1 identifies this gap and correctly defers it:

```text
Ch5/Ch7 spec wording for internal strict refusal: Not changed here;
optional future spec sync if agents start routing from spec chapters
instead of PROP/status.
```

This is not a blocker. The PROP-038 proposal and status chain are the authoritative
canon source for the current round. Spec chapters are not routed from in the R85
scope. Future spec sync would require a separate focused round.

### NB-2: C2 is a read-only canon map; no independent proof re-run

C2 explicitly states: "This card did not rerun the matrix; it reads the accepted
command matrix and current summary as canon."

This is appropriate for the canon map's assigned scope. C2's purpose is to
document the accepted canon for future expansion decisions, not to re-verify the
live implementation. The R83-C3-X pressure review (the most recent independent
verification) is already in the gate chain.

If a future round needs fresh independent code verification, it should assign a
dedicated re-proof or regression card — not rely on the canon map alone.

### NB-3: `production_compiler_cli_proof` and `igapp_assembler_proof` anchors not re-run

These two anchors in C2's regression map are cited as stabilizing "public CLI
output/exit/report behavior" and "artifact shape and assembler boundary" — both
important guards against accidental public expansion. C2 did not re-run them.
This is consistent with C2's read-only scope and the round's docs-only intent.

If a future expansion card opens public CLI or assembler surfaces, these two
proofs must be explicitly included in that card's acceptance criteria.

---

## Summary

| Check | Result |
| --- | --- |
| 1. R84 accepted live internal foundation accurately stated in all docs | PASS |
| 2. No doc claims public API/CLI exposure | PASS |
| 3. No doc claims loader/report, CompatibilityReport, RuntimeMachine/Gate 3, runtime, or production authority | PASS |
| 4. No doc claims persisted reports/sidecars/`.igapp` for strict terminal paths | PASS |
| 5. Validator remains evidence, not authority; `compile_refusal_authorized: false` nested | PASS |
| 6. Proof anchors named, rationale clear, expansion guard checklist actionable | PASS |
| 7. Status/indexes consistent with gate chain; no contradictions | PASS |
| 8. PROP-038 stale language replaced correctly; no new semantics beyond R84 | PASS |

```text
checks: 8/8 PASS
blockers: 0
non-blocking notes: 3
  NB-1: Ch5/Ch7 spec wording not synced — acknowledged in C1, correctly deferred
  NB-2: C2 is read-only canon map; no independent proof re-run — correct for scope
  NB-3: production_compiler_cli_proof and igapp_assembler_proof not re-run — correct for scope
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 3 (all correctly scoped, none require action before C4-A)
```

---

## Recommendation For C4-A

The R85 C1 canon sync and C2 regression/canon map are clean.

**On C1 (canon sync)**:

The four drift points are correctly identified and fixed. PROP-038 now accurately
records the R84 accepted live internal foundation in §9.5, §10.3, §10.4, and §15.
The stale absolute "compile refusal remains closed" language is replaced with the
precise internal-only/public-closed split. No code was touched. No new authority
was created. All forbidden surfaces remain closed.

The changed-doc list (four docs only) is consistent with a docs-only canon sync.
The non-touched `gates/README.md` was correctly left alone because it already
reflected R84 accurately.

**On C2 (regression/canon map)**:

The map is a suitable compact canon/regression reference for the R84 accepted
internal-only PROP-038 strict-refusal foundation. The 10 regression anchors, 8
expansion risk entries, and 14-item expansion guard checklist are all clear and
actionable. The map correctly identifies itself as not an implementation
authorization.

**C4-A may**:

1. Accept both C1 and C2.
2. Record accepted canon sync scope (four docs) and accepted regression map.
3. Confirm PROP-038 §10.4 now reflects R84 correctly.
4. Name the next strategic route from the R84-authorized candidates — no candidate
   is forced open by R85.

**C4-A should not**:

- Open any public API/CLI, loader/report, CompatibilityReport, RuntimeMachine,
  Gate 3, runtime, production, persisted-report, sidecar, or `.igapp` surface
  based on this round.
- Authorize any new implementation based on this canon sync.
- Treat the regression/canon map as an implementation authorization.

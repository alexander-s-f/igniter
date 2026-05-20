# Track: PROP-038 Strict Refusal Spec Chapter Sync v0

Card: S3-R86-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-strict-refusal-spec-chapter-sync-v0`
Route: UPDATE
Status: done
Date: 2026-05-20

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Synchronize Ch5/Ch7 or equivalent spec chapters with the R84 accepted
internal-only strict-refusal foundation, without adding new semantics or
implementation authority.

This is a docs-only spec sync. It does not edit code, authorize public API/CLI,
loader/report, CompatibilityReport, RuntimeMachine/Gate 3, runtime, or
production behavior.

---

## Inputs Read

- `docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch7-runtime.md`
- `docs/language-spec.md`

---

## Changed Docs

| Path | Change |
| --- | --- |
| `docs/spec/ch5-compiler-pipeline.md` | Added PROP-038/R84 strict terminal compiler boundary, corrected the "CompilationReport always written" implication, added assembler skip rule for strict terminals, and added C-11 conformance case. |
| `docs/spec/ch7-runtime.md` | Added a non-runtime boundary section stating PROP-038 strict refusal produces no loadable `.igapp`, no sidecar/report artifact, no RuntimeMachine load/evaluate path, and no CompatibilityReport/runtime authority. |
| `docs/language-spec.md` | Updated index freshness and Ch5/Ch7 status notes for PROP-038 strict refusal as internal compiler foundation / non-runtime boundary. |
| `docs/tracks/prop038-strict-refusal-spec-chapter-sync-v0.md` | This handoff track. |

---

## Drift Points Found And Fixed

### D1. Ch5 implied every successful report writes and then assembles

Previous Ch5 pipeline text said:

```text
CompilationReport always written
Assemble skips if pass_result != "ok"
```

That missed the R84 strict terminal exception. Ch5 now states:

```text
CompilationReport produced for decision/report evidence
PROP-038 internal strict terminal, if selected:
  non-persisting CompilerResult refused | configuration_error
  no sidecar, no report write, no .igapp, no assembler call
```

Ch5 also records that strict terminal paths keep:

```text
report.pass_result == "ok"
```

while assembly is skipped by the internal orchestrator strict requirement
decision path.

### D2. Ch5 lacked the accepted R84 authority split

Ch5 now records:

```text
internal strict requirement source
  -> orchestrator-level strict requirement decision path
  -> report-only compiler_profile_contract_validation evidence
  -> non-persisting strict terminal CompilerResult when selected
```

and explicitly separates validator evidence from authority:

```text
CompilerProfileContractValidator output != refusal authority
compile_refusal_authorized: false remains nested report-only evidence
```

### D3. Ch7 had no runtime boundary for PROP-038 strict refusal

Ch7 now states that PROP-038 strict refusal is not a RuntimeMachine surface:

- no loadable `.igapp`;
- no sidecar/report artifact;
- no `RuntimeMachine.load`;
- no `RuntimeMachine.evaluate`;
- no CompatibilityReport strict source or status;
- no runtime/production authority.

### D4. `language-spec.md` index was stale

The index now names PROP-038 as a Ch5/Ch7 source for this boundary and records
that public/runtime/production refusal remains closed.

---

## Canon After Sync

Compiler chapter canon:

```text
R84 strict refusal = internal compiler/orchestrator terminal path
```

Runtime chapter canon:

```text
R84 strict refusal != RuntimeMachine load/evaluate capability
```

Closed surfaces preserved:

```text
public API/CLI
env/config/manifest/default/generated strict source lookup
loader/report strict source or status
CompatibilityReport strict source or status
persisted refusal reports
sidecars
.igapp mutation
RuntimeMachine / Gate 3
runtime / production
```

---

## Remaining Spec Gaps

| Gap | Status |
| --- | --- |
| Ch6 SemanticIR / CompilationReport chapter may later mention nested `compiler_profile_contract_validation` evidence. | Optional future sync only; R86 did not need Ch6 because strict terminal authority is orchestrator/result, not SemanticIR. |
| Public API/CLI strict source semantics | Closed; requires separate design/gate if ever opened. |
| Loader/report or CompatibilityReport strict status | Closed; requires separate design/gate if ever opened. |
| Runtime/production strict refusal | Closed; requires separate design/gate if ever opened. |
| `docs/spec/README.md` index freshness | Not changed; Ch5/Ch7 and `language-spec.md` now carry the necessary R84 sync. |

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- new live behavior;
- public API/CLI widening;
- loader/report behavior;
- CompatibilityReport behavior;
- RuntimeMachine/Gate 3 behavior;
- runtime behavior;
- production behavior.

---

## Recommendation For C4-A

Recommendation:

```text
accept sync
```

Reason:

- Ch5 now reflects the internal-only strict terminal compiler path;
- Ch7 now blocks accidental runtime/load interpretation;
- the language spec index points to the updated boundary;
- no behavior, authority, public exposure, loader/report surface,
  CompatibilityReport surface, runtime, or production surface was widened.

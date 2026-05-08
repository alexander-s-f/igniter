# Discussion: Typed Emission and Temporal Loader Pressure

Card: S3-R5-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: meta-expert
Track: typed-emission-and-temporal-loader-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Are we now safe to treat typed emission + temporal manifest index as the Stage 3
execution artifact path, or are there hidden public behavior / loader risks?

## Context

S3-R5 closed four tracks in sequence:

- **C1** `temporal-assembler-manifest-contract-index-v0` — `manifest.fragment_summary`
  and `manifest.contract_index` emitted per PROP-022A errata. Cache proof now
  prefers `manifest.contract_index` as primary metadata source.
- **C2** `temporal-runtime-load-guard-v0` — `load_accept_evaluate_refuse` policy
  specified and proved in a proof-local `GuardedRuntimeMachine`. Load validates
  `manifest.contract_index`; evaluate refuses TEMPORAL without executor.
- **C3** `bihistory-source-fixture-parity-gate-v0` — BiHistory source fixture
  added. `sparkcrm_bihistory` moved from `NOT_COMPARABLE` to measured FAIL. 
  `typed_source_blocked_items: 0`. `orchestrator_switch_gate: PROCEED`.
- **C4** `orchestrator-emit-typed-switch-v0` — THE SWITCH. 
  `@emitter.emit_typed(typed)` is now the production path. Stage 1/2 close
  candidates PASS. Release gate PASS; artifact/checksum built.

Evidence baseline recorded before the switch:

```text
safe_to_switch_production_path: false
typed_source_blocked_items: 0
legacy_parity_delta_items: 14
orchestrator_switch_gate: PROCEED
```

The switch gate was PROCEED despite `safe_to_switch_production_path: false`
because the 14 legacy delta items were all parsed-OOF → typed-ok cases, not
valid-to-different regressions. One exception: `invariant_valid` — "typed path
lowers invariant_node; parsed legacy shape differs" (see Challenge section).

---

## [Agree]

**The emit_typed switch decision is well-supported.**

The parity harness shows `typed_source_blocked_items: 0`. The switch gate
`PROCEED` was issued with correct reasoning: the 14 legacy delta items are
cases where the typed path succeeds where the parsed path OOFed. That is the
expected and correct behavior — typed emission is strictly more capable for
Stage 2+ surfaces. Stage 1/2 close candidates both PASS after the switch.
Release gate PASS with artifact/checksum built.

**BiHistory source fixture parity gate closes the NOT_COMPARABLE risk.**

`sparkcrm_bihistory` was the one case that could not be measured before C3.
C3 produced a fixture, moved it to measured FAIL (parsed-OOF, as expected),
and confirmed `typed_source_blocked_items: 0`. This was the correct blocker
gate before allowing the orchestrator switch to proceed.

**`manifest.contract_index` load-time dispatch is structurally sound.**

C1 implemented the dual-index manifest: ContractIR = canonical semantic source;
`manifest.contract_index` = load-time dispatch projection. The cache proof now
uses `manifest.contract_index` as the primary metadata source and falls back to
contract files as validation. The invariant (index agrees with contract file) is
proved for the temporal case. This is the right abstraction — it separates
load-time dispatch from semantic authority.

**C2 load/evaluate guard policy is well-specified.**

`load_accept_evaluate_refuse` is the correct policy for the current milestone:
temporal artifacts may be loaded for inspection and compatibility reporting
without requiring a temporal executor. Machine-readable in
`compatibility_metadata.runtime_execution`. The negative cases (6 variants)
are all covered in the proof-local harness.

---

## [Challenge]

### C-1. Production RuntimeMachine does not enforce C2 guard policy

C2 is proof-local. The `GuardedRuntimeMachine` is a fixture in
`experiments/temporal_runtime_load_guard/`. The production `RuntimeMachine`
(if it exists or when it is introduced) has no binding to this guard logic.
No production RuntimeMachine code was changed in C2; the track explicitly
says so.

Consequence: if a temporal `.igapp/` artifact is handed to the production
`CompiledProgram.load_igapp` path, there is no enforced guard. The
machine-readable `runtime_execution.guard_policy` field exists in
`compatibility_metadata.json` but nothing reads it and refuses evaluation
based on it in production.

This is not a regression from before C2 — it is a gap that C2 intentionally
scoped out. But the gap is now explicitly named and unowned.

### C-2. `invariant_valid` delta is a shape difference, not a pure OOF signal

The parity baseline lists `invariant_valid` as FAIL with signal:
"typed path lowers invariant_node; parsed legacy shape differs."

This is distinct from the other 13 FAIL cases (which are clean parsed-OOF →
typed-ok). `invariant_valid` suggests the typed path produces a *different
shape* — not that the parsed path OOFs and the typed path succeeds cleanly.
The `safe_to_switch_production_path: false` verdict may partially reflect this
case.

If a caller was consuming the parsed-path SemanticIR shape for `invariant_node`
and now receives the typed-path shape, behavior changes. The switch is still
correct (typed path is the canonical Stage 3 path), but this specific case was
not explicitly discharged — it was grouped with the OOF cases under "legacy
delta."

### C-3. OOF category shift is an observable public behavior change

Before the switch: unresolved-symbol packages reached `classifier_oof`.
After the switch: they reach `typechecker_oof`.

This is documented and expected. But `compilation_report.json` consumers who
inspect `category` will see a different value for the same input. No migration
note exists in the track. If any downstream tool or test fixture outside of the
proof harness checks `.category == "classifier_oof"`, it will silently break.

### C-4. Spec-lag: `ch4-fragment-classification.md` still says `"core | escape | oof"`

This was identified in the agent-role-optimization discussion (off-track) as an
existing gap. S3-R5 does not close it. The production orchestrator now emits
typed output for TEMPORAL sources; the spec chapter still has no mention of
`TEMPORAL` as a fragment class. Any agent reading `ch4` gets wrong information
about the fragment class hierarchy.

The meta-expert lens observation: Stage 3 activity (PROP-028, C1, C2, C4) has
added material language surface that is not reflected in `docs/spec/`. The
`spec-lag` constraint (META-EXPERT-012: spec may not lag more than one stage)
is now in tension with the current spec state.

---

## [Missing]

### M-1. `invariant_valid` delta not explicitly discharged

The baseline groups `invariant_valid` as a "legacy parity delta item" alongside
pure OOF cases. There is no explicit analysis of what the typed-path
`invariant_node` shape looks like vs the parsed-path shape, nor whether any
existing consumer of that shape is broken.

Needed: a comparison of the `invariant_node` SemanticIR output before/after
the switch, or an explicit statement that no consumer of this shape exists
outside the parity harness.

### M-2. Production RuntimeMachine load path not bound to C2 guard

There is no track or proposal that binds `compatibility_metadata.runtime_execution`
to any production enforcement. The field exists in the manifest; nothing reads it
in production. This means the guard policy is a contract that only the proof-local
fixture honors.

Needed: a track that either (a) wires the production load path to check
`runtime_execution.guard_policy` before allowing evaluate, or (b) explicitly
declares that the production RuntimeMachine does not load TEMPORAL artifacts
at all yet (so the gap is bounded).

### M-3. `oof-category shift` has no migration note or external surface scan

No document records that `category: "classifier_oof"` may appear in existing
tooling, fixtures, or consumer code, and that it now becomes `"typechecker_oof"`
for unresolved-symbol packages. The track calls it expected and moves on.

Needed: an explicit surface scan or assertion that no consumer outside the
proof harness inspects this category field, or a migration note if they do.

### M-4. `runtime_smoke` + temporal contracts: not explicitly tested after switch

The `runtime_smoke` runner exists to catch broad regressions. After the
emit_typed switch, `runtime_smoke` may receive contracts with `temporal_nodes`
in their SemanticIR output. Whether the runtime smoke runner understands
`temporal_nodes` or OOFs/crashes on them is not addressed in C4.

Needed: a smoke regression confirmation that `runtime_smoke` handles temporal
contracts after the switch, or an explicit scope statement that temporal
contracts are excluded from the smoke runner.

---

## [Sharper Question]

Not: "Is the Stage 3 artifact path complete?"

The sharper question is:

> **Which of the four gaps (C2 production guard, invariant_valid delta,
> category shift surface, runtime_smoke + temporal) is a blocking risk for
> Stage 3 close, and which can be deferred to a later lane?**

Proposed triage:

| Gap | Block Stage 3 close? | Proposed disposition |
|-----|----------------------|---------------------|
| Production RuntimeMachine not bound to C2 guard | No, if production RM does not load TEMPORAL yet | Bound: open `runtime-load-guard-production-v0` before any production temporal loading |
| `invariant_valid` typed vs parsed shape delta | Low risk if no external consumer; needs explicit scan | Discharge in next Research Agent slice: compare shapes, confirm no external consumer |
| `classifier_oof` → `typechecker_oof` category shift | No, if no external consumer; same scan scope | Discharge with `invariant_valid` scan |
| `runtime_smoke` + temporal contracts | Unclear — needs verification | Should be checked in next regression pass |

None of these are immediately blocking the current state (release gate passes,
Stage 1/2 close candidates pass). But all four should be explicitly discharged
before a Stage 3 close proposal is made.

---

## [Route]

→ **PROP** (language surface): `ch4-fragment-classification.md` spec-lag is
not a research track — it requires Compiler/Grammar Expert to author a
`spec-sync-vN` document. Route to C/G Expert via `spec-sync-v0` track
(Intervention 1 from agent-role-optimization-v0 discussion).

→ **track**: Open `invariant-typed-shape-discharge-v0` for Research Agent.
Scope: compare `invariant_node` SemanticIR output on typed vs parsed path;
confirm no external consumer checks the shape; discharge the baseline ambiguity.
Also confirms `oof-category-shift` surface in same pass.

→ **track**: Open `runtime-load-guard-production-v0` when the production
RuntimeMachine begins to load `.igapp/` artifacts. Scope: bind
`compatibility_metadata.runtime_execution.guard_policy` to the production
load path. Scope-gated: not needed until production RM is introduced.

→ **review**: `runtime_smoke` + temporal contract coverage should be confirmed
in the next round regression pass, not as a separate track. If failure is
observed, route to Research Agent.

---

## Compact Summary

| Signal | Verdict | Confidence |
|--------|---------|------------|
| emit_typed switch evidence | Safe — stage gates pass, delta is OOF→ok | High |
| BiHistory parity gate | Closed — `typed_source_blocked_items: 0` | High |
| `manifest.contract_index` dispatch | Structurally sound; proof validates index-contract agreement | High |
| C2 guard policy | Well-specified; proof-local only; production gap is named and scoped | Medium |
| `invariant_valid` delta | Not fully discharged; shape difference not pure OOF | Low-Medium |
| `oof-category-shift` external surface | Not scanned; low risk but undischarged | Low |
| `runtime_smoke` + temporal | Not verified post-switch | Low-Medium |
| `ch4` spec-lag | Active gap; PROP-028 not reflected | High (blocked artifact) |

Overall: typed emission + temporal manifest index are structurally sound as the
Stage 3 artifact path. Four gaps should be discharged before a Stage 3 close
proposal, but none are currently blocking the landed state.

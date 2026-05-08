# Track: Spec Stage 3 Sync and Doc Compaction Plan v0

Card: S3-R5-C7-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: `igniter-lang/spec-stage3-sync-and-doc-compaction-plan-v0`
Status: done
Date: 2026-05-08

Lifecycle policy: META-EXPERT-012

---

## Goal

Produce a technical consolidation plan that maps S3-R1..R5 evidence to
specific spec chapter updates and doc compaction actions.

This card does NOT perform spec rewrites. It builds the checklist that
authorizes and scopes them.

---

## I. Inputs Read

```text
docs/meta-proposals/META-EXPERT-012  — lifecycle/actualization policy
docs/spec/ch4-fragment-classification.md
docs/spec/ch5-compiler-pipeline.md
docs/spec/ch6-semanticir.md
docs/spec/ch7-runtime.md
docs/tracks/temporal-semanticir-access-node-v0.md          (S3-R3-C2)
docs/tracks/runtime-temporal-cache-contract-v0.md          (S3-R3-C3)
docs/tracks/temporal-assembler-boundary-v0.md              (S3-R4-C1)
docs/tracks/prop-022a-temporal-manifest-errata-v0.md       (S3-R4-C2)
docs/tracks/temporal-requirements-from-escape-boundaries-v0.md (S3-R4-C3)
docs/tracks/typed-emission-stage2-switch-decision-v0.md    (S3-R4-C4)
docs/tracks/stage3-round4-and-round5-status-curation-v0.md (S3-R5-C6)
docs/proposals/PROP-028-temporal-fragment-class-v0.md
docs/current-status.md
```

---

## II. Spec Backlog by Chapter

### Ch4 — Fragment Classification

Current spec: S2-close snapshot. Three fragment classes only: CORE, ESCAPE, OOF.

**Gaps (require spec content addition):**

| Item | Evidence | Priority |
|------|----------|----------|
| CH4-1: TEMPORAL as 4th fragment class | PROP-028 §2.1 | HIGH |
| CH4-2: Fragment order: OOF > TEMPORAL > STREAM > CORE | PROP-028 §2.1 | HIGH |
| CH4-3: node_fragment_class / value_fragment_class distinction | PROP-028 §2.2 | HIGH |
| CH4-4: TEMPORAL propagation rules (history_read, bihistory_read triggers) | S3-R2-C2, S3-R3-C2 | HIGH |
| CH4-5: Construct table rows: History[T], BiHistory[T] → TEMPORAL | S3-R2-C2 | HIGH |
| CH4-6: Named escape vocabulary: bi_temporal → now normalized to TEMPORAL | PROP-028 §2.1 | MEDIUM |
| CH4-7: STREAM as distinct class (PROP-023 was proven in Stage 2) | PROP-023 | MEDIUM |
| CH4-8: ClassifiedProgram shape: fragment_class now includes "temporal" | S3-R2-C2 | MEDIUM |

**Status/index updates only:**

| Item | Action |
|------|--------|
| CH4-S1: Source PROPs line | Add PROP-028 |
| CH4-S2: Status line | "Stage 3 extension: TEMPORAL class proven through TypeChecker + SemanticIR" |

**Stale sections in ch4:** None. Content is correct for Stage 2; just incomplete.

---

### Ch5 — Compiler Pipeline

Current spec: Stage 2 close. Shows `emit(ClassifiedProgram + TypedProgram)`.
Orchestrator switched to `emit_typed(TypedProgram)` in S3-R5-C4.

**Gaps (require spec content change):**

| Item | Evidence | Priority |
|------|----------|----------|
| CH5-1: 5.2 emit row: input = TypedProgram (not ClassifiedProgram+TypedProgram) | S3-R5-C4 | HIGH |
| CH5-2: Note that emit_typed is production path since S3-R5-C4 | S3-R4-C4, S3-R5-C4 | HIGH |
| CH5-3: Legacy emit(parsed) retained for Stage 1 comparison only | S3-R5-C4 | MEDIUM |
| CH5-4: TEMPORAL path: History[T]/BiHistory[T] reads → TEMPORAL nodes in SemanticIR | S3-R3-C2 | MEDIUM |

**Status/index updates only:**

| Item | Action |
|------|--------|
| CH5-S1: Status line | Add: "emit_typed production path: PASS (S3-R5-C4); PROP-026/027 closed" |
| CH5-S2: Source PROPs | Add PROP-026, PROP-027, PROP-028 |

**Stale sections in ch5:** None structurally stale. §5.4 conformance cases
("⚠️ OOF rejection at parse time — non-blocking gap") has been partially
addressed by PROP-026 (parser hardening spec closed); can be updated to reflect
closed status.

---

### Ch6 — SemanticIR and CompilationReport

Current spec: Stage 2 body. Two actively stale sections identified.

**🔴 STALE sections (must be corrected before spec is shared with new agents):**

```text
§6.4 "Current status: assembler experiment not yet implemented.
       Blocked on Slice 0 (golden file migration)."

  → STALE since Stage 2. Assembler A1–A6 all PASS (S2-R9).
    Temporal assembler also PASS (S3-R4-C1). Must be removed.

§6.5 "Golden File Migration Gate"

  → STALE. Gate was cleared in Stage 2 (source_to_semanticir_fixture PASS).
    This entire section describes a resolved blocker.
    Action: replace with "Gate: CLEARED (S2-R8)" and collapse.
```

**Gaps (require spec content addition):**

| Item | Evidence | Priority |
|------|----------|----------|
| CH6-1: temporal_input_node shape in ContractIR | S3-R3-C2 | HIGH |
| CH6-2: temporal_access_node shape in ContractIR | S3-R3-C2 | HIGH |
| CH6-3: ContractIR: fragment_class now includes "temporal" | S3-R3-C2 | HIGH |
| CH6-4: temporal_nodes section in assembled contract files | S3-R4-C1 | HIGH |
| CH6-5: PROP-022A manifest shape: fragment_summary, contract_index, guard_policy | S3-R5-C1 | HIGH |
| CH6-6: requirements.json: temporal.axes, coordinate_refs, capabilities.required_caps | S3-R4-C1/C3 | MEDIUM |
| CH6-7: compatibility_metadata.guard_policy in assembler output | S3-R5-C2 | MEDIUM |
| CH6-8: Assembler A4 expansion: list temporal_nodes, requirements.temporal.* | S3-R4-C1 | MEDIUM |

**Status/index updates only:**

| Item | Action |
|------|--------|
| CH6-S1: Status line | "Stage 3: temporal_input/access_node + PROP-022A manifest PASS; stale §6.4/6.5 cleared" |
| CH6-S2: Source PROPs | Add PROP-022A, PROP-028 |

---

### Ch7 — RuntimeMachine

Current spec: Stage 2 body. One actively stale section identified.

**🔴 STALE sections:**

```text
§7.6 "Not yet proven:
  🔴 evaluate with stdlib operators (numeric.add, fold, map, filter)
     — operator lookup returns nil; RuntimeMachine.evaluate not yet connected"

  → STALE since Stage 2. stdlib kernel proven (PROP-013, S2-R5 area).
    RuntimeMachine.evaluate proven with full stdlib operators.
    This must be updated to ✅ PASS with evidence pointer.
```

**Gaps (require spec content addition):**

| Item | Evidence | Priority |
|------|----------|----------|
| CH7-1: TEMPORAL cache key contract | S3-R3-C3, S3-R4-C5 | HIGH |
|        CORE key: hash(contract_ref, canonical_non_temporal_inputs) | | |
|        TEMPORAL History key: hash(contract_ref, inputs, as_of) | | |
|        TEMPORAL BiHistory key: hash(contract_ref, inputs, valid_time, tx_time) | | |
| CH7-2: Freshness states: fresh / stale / unknown / provisional | S3-R3-C3 | HIGH |
| CH7-3: Temporal load guard semantics | S3-R5-C2 | HIGH |
|        load: TEMPORAL contract accepted for inspection | | |
|        evaluate: refused until runtime executor + TBackend binding | | |
|        guard_policy sourced from compatibility_metadata | | |
| CH7-4: RuntimeMachineHook: temporal capability check at load time | S2-R7, S3-R2-C2 | MEDIUM |
|        history_read / bihistory_read capability names | | |
| CH7-5: TEMPORAL evaluation lifecycle (future, gated) | S3-R5-C2 | LOW |

**Status/index updates only:**

| Item | Action |
|------|--------|
| CH7-S1: Status line | "Stage 3: temporal load guard + proof-local cache contract PASS; stdlib proven in Stage 2" |
| CH7-S2: §7.6 proven section | Replace 🔴 stdlib gap with ✅ PASS + add temporal proof-local evidence |
| CH7-S3: Source PROPs | Add PROP-028, S3-R3-C3 cache contract reference |

---

## III. Spec-Lag Score (META-EXPERT-012 §VIII)

```text
Chapter   Stage last touched   S3 evidence unwritten   Lag score
────────  ───────────────────  ──────────────────────  ──────────
ch4       Stage 2 close        8 items (HIGH×5)         HIGH
ch5       Stage 2 close        4 items (HIGH×2)         MEDIUM
ch6       Stage 2 close        2 STALE + 8 items (H×4)  CRITICAL
ch7       Stage 2 close        1 STALE + 5 items (H×3)  HIGH
```

**Action threshold**: ≥3 HIGH items in any chapter triggers spec-sync track.
All four chapters exceed the threshold.

Recommended ordering: ch6 (CRITICAL — stale sections actively mislead agents),
ch4 (TEMPORAL class foundational to all other chapters), ch7 (cache + load guard),
ch5 (emit_typed path — lowest relative lag).

---

## IV. Doc Compaction Plan

### A. Stale-marker candidates (do not archive yet; mark in file header)

Per META-EXPERT-012 §VI: a document that is stage-closed and whose content has
been superseded by a newer track should carry a stale marker until a full round
has elapsed (archivation criterion B).

| Document | Reason for stale marker | Action |
|----------|------------------------|--------|
| `spec/ch6-semanticir.md §6.4–6.5` | Assembler "not yet implemented" / golden gate — both cleared in S2 | **Add inline ⚠️ STALE comment** in §6.4 and collapse §6.5 to one line |
| `spec/ch7-runtime.md §7.6` | stdlib "not yet connected" — PASS in S2 | **Update §7.6** proven section: remove 🔴, add ✅ |
| `tracks/typed-emission-main-path-parity-v0.md` | S3-R1-C3; blocked verdict superseded by S3-R5-C4 switch | **Add stale header** noting superseded by typed-emission-stage2-switch-decision-v0 |
| `tracks/typed-emission-canonical-shape-v0.md` | S3-R2-C1; 7 blockers now resolved by S3-R5-C4 | **Add stale header** |
| `tracks/typed-emission-stage2-source-lowering-parity-v0.md` | S3-R3-C1; 11 legacy deltas note resolved by Option B adoption | **Add stale header** |
| `discussions/temporal-fragment-and-cache-key-pressure-discussion-v0.md` | S3-R2-X1; all routes closed by S3-R3-C3, S3-R4-C5 | **Status: complete — routed** (no stale marker needed; discussions close-with-route) |
| `discussions/temporal-manifest-and-cache-boundary-pressure-v0.md` | S3-R3-X1; routed to S3-R4-C1, S3-R4-C2 — both done | **Status: complete — routed** |

### B. Rotation candidates (status change, not file move)

Per META-EXPERT-012 §VI: track documents after `done` status and one full round
elapsed are rotation candidates (status: `closed`; no physical archive yet).

| Document | Current status | Proposed rotation | Earliest eligible round |
|----------|---------------|-------------------|------------------------|
| `typed-emission-main-path-parity-v0.md` | done/blocked | closed (superseded) | S3-R6 |
| `typed-emission-canonical-shape-v0.md` | done/blocked | closed (superseded) | S3-R6 |
| `typed-emission-stage2-source-lowering-parity-v0.md` | done/blocked | closed (superseded) | S3-R6 |
| `temporal-cache-key-proof-v0.md` | done | closed (content absorbed into S3-R4-C5) | S3-R6 |
| S2-era stage curation tracks (R9–R15) | done | archive candidate | already eligible |

### C. Proposals index cleanup

| Item | Current | Target |
|------|---------|--------|
| PROP-028 Status | `proposal` | Should update to `implementation-partial` once classifier + typechecker + SemanticIR proofs PASS |
| PROP-022A | Not yet in proposals/README.md | Add as errata entry |
| PROP-022 through PROP-025 | `proposal` | Verify current implementation state; update status if PASS proven |

### D. Signal Ledger (stale, already marked)

`signal-ledger-index.md` carries stale banner from debt-clearance commit.
No further action in this card. A signal-ledger refresh track is a S3-R6
optional task for `[Archive/Form Expert]`.

---

## V. Recommended Cards

### Card: spec-ch4-temporal-fragment-sync-v0

```text
Role: [Compiler/Grammar Expert]
Type: spec update
Priority: HIGH
Depends on: PROP-028 (formal proposal text)
Scope:
  - Add §4.8 TEMPORAL Fragment Class (or expand §4.1)
  - Add TEMPORAL to 4-class hierarchy table
  - Add node_fragment_class / value_fragment_class distinction
  - Update construct classification table: History[T]/BiHistory[T] → TEMPORAL
  - Update propagation rules §4.6 with TEMPORAL propagation
  - Update named escape vocabulary: bi_temporal normalization
  - Update ch4 status + source PROPs lines
Acceptance: ch4 accurately reflects PROP-028 §2.1–2.3 and S3-R2-C2 evidence
```

### Card: spec-ch6-semanticir-temporal-sync-v0

```text
Role: [Compiler/Grammar Expert]
Type: spec update (+ stale section removal)
Priority: CRITICAL
Scope:
  - Remove §6.4 "Current status: assembler experiment not yet implemented"
  - Collapse §6.5 to one line: "Gate: CLEARED (S2-R8)"
  - Add temporal_input_node shape to §6.3 ContractIR
  - Add temporal_access_node shape to §6.3 ContractIR
  - Add PROP-022A manifest shape: fragment_summary, contract_index, guard_policy
  - Update assembler A4 list: temporal_nodes, requirements.temporal.*
  - Update ch6 status + source PROPs lines
Acceptance: no STALE sections remain; temporal node shapes match S3-R3-C2 golden
```

### Card: spec-ch7-runtime-temporal-cache-sync-v0

```text
Role: [Research Agent] (implementation read) + [Compiler/Grammar Expert] (spec write)
Type: spec update (+ stale section fix)
Priority: HIGH
Scope:
  - Replace §7.6 🔴 stdlib gap with ✅ PASS
  - Add §7.7 TEMPORAL Cache Key Contract (from S3-R3-C3, S3-R4-C5)
    CORE key schema / TEMPORAL History key / TEMPORAL BiHistory key
    Freshness states: fresh / stale / unknown / provisional
  - Add §7.8 Temporal Load Guard (from S3-R5-C2)
    accept-for-inspection / evaluate-refuse / guard_policy source
  - Add RuntimeMachineHook mention in §7.2 load semantics
  - Update ch7 status + source PROPs lines
Acceptance: no STALE sections remain; cache key schemas match S3-R4-C5 proof
```

### Card: spec-ch5-emit-typed-sync-v0

```text
Role: [Compiler/Grammar Expert]
Type: spec update (minimal)
Priority: MEDIUM
Scope:
  - Update §5.2 table: emit row input = TypedProgram only
  - Add emit_typed note: production path since S3-R5-C4
  - Note legacy emit(parsed) retained for Stage 1 comparison
  - Update §5.4: parser OOF gap partially closed by PROP-026
  - Update ch5 status + source PROPs lines
Acceptance: §5.2 emit interface matches CompilerOrchestrator.rb emit_typed call
```

### Card: parity-track-stale-header-sweep-v0

```text
Role: [Archive/Form Expert] or [Status Curator]
Type: stale marker pass (no content change)
Priority: LOW (can batch with next round curation)
Scope:
  - typed-emission-main-path-parity-v0: add superseded-by header
  - typed-emission-canonical-shape-v0: add superseded-by header
  - typed-emission-stage2-source-lowering-parity-v0: add superseded-by header
  - temporal-cache-key-proof-v0: add absorbed-into header (S3-R4-C5)
  - discussions/temporal-fragment-and-cache-key-pressure-discussion-v0: Status → complete — routed
  - discussions/temporal-manifest-and-cache-boundary-pressure-v0: verify Status = complete — routed
Acceptance: all listed docs carry accurate lifecycle headers; no content changed
```

---

## VI. What Is NOT in Scope for Any of These Cards

```text
❌  Ch8 (stdlib) — no S3 evidence changes it; leave as-is
❌  Ch9 (stage2-reserved) — placeholder; leave as-is
❌  Ch1, Ch2, Ch3 — no S3 evidence changes these chapters
❌  Actual spec rewrite of ch4-ch7 — this card is a plan only
❌  Archiving any files — no archivation criteria are met yet
    (Archivation criterion B: superseded + ≥1 full round elapsed → S3-R6 at earliest)
❌  Parser coordinate syntax for History[T]/BiHistory[T]
    — no parser implementation in PROP-028; not a spec chapter concern yet
❌  Ledger/TBackend production binding
    — Gate 3 closed; no spec chapter needed until gate opens
```

---

## VII. Debt Register Update (META-EXPERT-012 §VIII)

Items now formally registered in the spec-backlog:

```text
[SPEC-DEBT-01]  ch4: TEMPORAL class — PROP-028    → card: spec-ch4-temporal-fragment-sync-v0
[SPEC-DEBT-02]  ch6: stale §6.4–6.5 + temporal    → card: spec-ch6-semanticir-temporal-sync-v0
[SPEC-DEBT-03]  ch7: stale §7.6 + cache/guard      → card: spec-ch7-runtime-temporal-cache-sync-v0
[SPEC-DEBT-04]  ch5: emit_typed production path     → card: spec-ch5-emit-typed-sync-v0
[SPEC-DEBT-05]  parity tracks: stale headers        → card: parity-track-stale-header-sweep-v0
[SPEC-DEBT-06]  PROP-028 status: proposal → impl-partial (pending formal acceptance ceremony)
[SPEC-DEBT-07]  PROP-022A: add to proposals/README.md index
```

These items are now the authoritative backlog. Status Curator should add them
to `current-status.md` spec-backlog section at next round curation.

---

## Handoff

```text
[Meta Expert]
Card: S3-R5-C7-S
Status: done

[D] Decisions:
- All four spec chapters (ch4–ch7) exceed the 3-HIGH lag threshold → all require sync cards.
- ch6 is CRITICAL: stale §6.4–6.5 actively mislead agents about assembler status.
- ch7 is HIGH: stale §7.6 claims stdlib operators unconnected — PASS since Stage 2.
- ch4 is the foundational dependency: TEMPORAL class must be in ch4 before other chapters
  can reference it cleanly.
- ch5 change is minimal (emit_typed row + note).
- Three parity tracks (main-path, canonical-shape, source-lowering) are superseded by
  S3-R5-C4 switch decision; stale headers authorized, archivation not yet eligible.
- Discussions temporal-fragment-and-cache-key + temporal-manifest-and-cache-boundary
  are complete-routed; no new stale markers needed.
- No archivation actions authorized in this card (criterion B: ≥1 full round needed).

[S] Signals:
- 7 spec-debt items formally registered: SPEC-DEBT-01..07
- 4 spec sync cards defined with scope and acceptance criteria
- 1 stale sweep card defined for parity tracks
- ch6 CRITICAL status surfaced

[R] Risks:
- Until ch6 stale sections are removed, new Research Agents may read
  "assembler not yet implemented" and attempt redundant proof work.
- Until ch4 TEMPORAL section is written, proposals referencing TEMPORAL must
  cite PROP-028 directly; no spec chapter anchor exists.

[Next]:
- Architect/Supervisor: authorize one or more spec sync cards above.
- Highest priority: spec-ch6-semanticir-temporal-sync-v0 (remove CRITICAL stale sections).
- Second priority: spec-ch4-temporal-fragment-sync-v0 (TEMPORAL class foundation).
- Low-cost quick win: ch6 §6.4–6.5 stale removal can be done standalone
  in 15-20 lines by any [Compiler/Grammar Expert] without a full sync card.
```

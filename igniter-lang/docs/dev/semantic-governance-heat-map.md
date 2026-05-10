# Semantic / Governance Heat Map

Status: living document
Card: S3-R30-C4-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: semantic-governance-heat-map-v0
Date: 2026-05-10
Supersedes: nothing (new document)

> Cross-layer drift index — where Covenant postulate meets Spec chapter, PROP,
> and compiler pipeline reality.
> Use alongside [canonical-semantic-model.md](canonical-semantic-model.md).
> This map does not invent semantics; it records observed gaps from landed evidence.

---

## Legend

### Pipeline status symbols

| Symbol | Meaning |
|--------|---------|
| ✅ | implemented (closed stage / production compiler path) |
| ⚙️ | experiment-pass (proof + golden anchor; Stage 3, not in a closed stage) |
| 🟡 | proposal only (PROP written; no proof) |
| 🔴 | spec_candidate (covenant / spec mention; no PROP and no proof) |
| 🚫 | explicitly gated or closed (Architect decision required to open) |
| — | not applicable to this pipeline stage |

### Debt-type codes

| Code | Meaning |
|------|---------|
| `none` | No visible gap at current scope |
| `impl` | Spec / PROP / golden anchor exists; pipeline stages or runtime enforcement incomplete |
| `gov` | Covenant commitment present (receipts, enforcement, audit trail); no compiler expression yet |
| `sem` | Concept named in Covenant or spec; no PROP, no grammar definition |
| `sem/gov` | No formal definition **and** an unmet covenant commitment coexist |
| `impl/gov` | PROP + proof exist at compile-time stages; runtime enforcement absent |

### Column abbreviations

`P` = Covenant postulates · `Parse` = Parser · `Class` = Classifier ·
`TC` = TypeChecker · `SIR` = SemanticIR · `RT` = Runtime · `Au` = Golden anchor

---

## Domain 1 — Core Contract Shape

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| Contract (pure, unmodified) | P1, P2 | ch1, ch2 | PROP-001, PROP-014 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | none |
| `pure` modifier (explicit) | P1, P2 | ch10 | PROP-031 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | ✅ | ✅ | impl |
| `observed` modifier | P4, P7, P11–13 | ch10 | PROP-031 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | ⚙️† | ✅ | impl/gov |
| `effect` modifier | P4, P17, P19 | ch10, ch12 | PROP-031, PROP-035 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | 🔴 | ⚙️ | impl/gov |
| `privileged` modifier | P9 | ch10, ch12 | PROP-031, PROP-034 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | 🔴 | ⚙️ | impl/gov |
| `irreversible` modifier | P17, P19 | ch10, ch12 | PROP-031, PROP-035 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | 🔴 | ⚙️ | impl/gov |
| `escape NAME` declaration | P4, P7, P28 | ch10 | PROP-031 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | 🔴 | ✅ | impl |
| `escape_boundaries` (SIR field) | P7 | ch10 | PROP-031 | — | — | — | ⚙️ | 🔴 | ✅ | impl |

† `observed` RT is ⚙️ for restricted Phase 1 TEMPORAL paths only (signed addendum scope).
  No Effect Surface enforcement. `effect`/`privileged`/`irreversible` RT is 🔴 — no runtime
  enforcement exists without PROP-035.

---

## Domain 2 — Epistemic Declarations

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| `assumptions {}` block | P22, P27, P28 | Gap-H | PROP-032‡ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem/gov |
| `uses assumptions NAME` | P22 | Gap-H | PROP-032‡ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem/gov |
| Epistemic state machine (no-upward-coercion guard) | P11, P13, ESM | ch10 (partial) | Gap-H / TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| Synthetic world marker (`:synthetic` mode) | P12, P23 | Gap-H | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem/gov |
| `constraints {}` block | P25, P27, P28 | Gap-J | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem/gov |
| `uses constraints NAME` | P25 | Gap-J | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem/gov |
| PostAudit receipt pattern | P26 | Gap-N | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |

‡ PROP-032 queue conflict: proposals/README.md reserves PROP-032 for `via profile binding`;
  canonical-semantic-model.md and agent-context.md assign PROP-032 to the assumptions block.
  This conflict is unresolved as of R29. See §Governance Issues below.

---

## Domain 3 — Effect Surface

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| Effect Surface (full declaration) | P4, P7, P9, P15, P17, P19, P21 | ch12 | PROP-035 (queued) | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| Receipt (production shape) | P8, P27 | ch12 | PROP-008 (partial), PROP-035 | — | — | — | — | ⚙️ | ⚙️§ | impl/gov |
| Authority as typed value | P9 | ch12 | PROP-035 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| `UnknownExternalOutcome` vs `ObservedFailure` | P15 | ch12 | PROP-035 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| Compensation declaration | P17 | ch12 | PROP-035 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| `audit:` field in decision receipt | P26 | Gap-N | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |

§ Receipt golden anchor covers FFI-level descriptors only (PROP-008). Authority,
  compensation, and audit reference fields are absent; those gates on PROP-035.

---

## Domain 4 — Temporal Read

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| `as_of: DateTime` parameter | P3 | ch9 | PROP-022 (closed) | ✅ | ✅ | ✅ | ✅ | ⚙️ | ✅ | impl |
| `History[T]` read | P3, P5 | ch9 | PROP-022 (closed), PROP-028 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | ⚙️∥ | ✅ | impl |
| `BiHistory[T]` read | P3, P5 | ch9 | PROP-022 (closed), PROP-028 | ⚙️ | ⚙️ | ⚙️ | ⚙️ | 🚫 | ✅ | impl |
| `temporal_input_node` (SIR node) | P3 | ch9 | PROP-028 | — | — | — | ⚙️ | ⚙️ | ✅ | impl |
| `temporal_access_node` (SIR node) | P3 | ch9 | PROP-028 | — | — | — | ⚙️ | ⚙️ | ✅ | impl |
| TEMPORAL parser coordinate syntax | P3 | ch9 | PROP-028 | 🟡 | — | — | — | — | 🔴 | impl |

∥ `History[T]` RT is ⚙️ for restricted Phase 1 live-read only (signed addendum scope,
  valid_time, MemoryBackend or explicit non-Ledger backend). BiHistory RT is 🚫 (Phase 2 closed).

---

## Domain 5 — Form Constructor + Loop Class

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| `form NAME -> TypeTarget` | P27, P28 | Gap-I | TBD | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem |
| Loop class: `finite_by_collection` | P14, P28 | ch13 | PROP-036+ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem |
| Loop class: `finite_by_fuel` | P14 | ch13 | PROP-036+ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem |
| Loop class: `convergent_by_metric` | P14 | ch13 | PROP-036+ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem |
| Loop class: `alive_by_liveness` (service loop) | P14, P28 | ch13 | PROP-036+ | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | sem |

Loop classes are the only domain where **no PROP has been numbered**. PROP-036+ is a
placeholder only. The Managed Recursion Doctrine in the Covenant makes strong commitments
(stoppable / observable / bounded) with zero compiler expression.

---

## Domain 6 — OOF Code Registry

For OOF codes, Parser column is omitted (OOFs are detected in Classifier, propagated by
TypeChecker). `Au` = golden anchor file exists.

| OOF | Triggers on | P | PROP | Class | TC | Au | Debt |
|-----|------------|---|------|-------|----|----|----|
| OOF-M1 | `pure` contract body with `escape`-class node | P4, P7 | PROP-031 | ⚙️ | ⚙️ | ✅ | none |
| OOF-P1 | Unresolved compute / output symbol | P2 | PROP-018, PROP-020 | ✅ | ✅ | ✅ | none |
| OOF-S2 | `stream` declared without `window` | P14 | PROP-023 | ✅ | ✅ | ✅ | none |
| OOF-S4 | Stream value used directly (no `fold_stream`) | P14 | PROP-023 | ✅ | ✅ | ✅ | none |
| OOF-CE4 | `ConfidenceLabel` used where `Bool` expected | P11 | PROP-025 | ✅ | ✅ | ✅ | none |
| OOF-OS2 | `EvidenceLinkedAlert` output missing signal/claim refs | P22 | PROP-025 | ✅ | ✅ | ✅ | none |
| OOF-I1 | `@bitemporal` invariant on non-bitemporal type | P14 | PROP-025 (deferred) | 🔴 | 🔴 | 🔴 | impl |
| OOF-I3 | `~T` invariant shape violation | P14 | PROP-025 (deferred) | 🔴 | 🔴 | 🔴 | impl |
| OOF-I5 | (deferred invariant condition, TBD) | P14 | PROP-025 (deferred) | 🔴 | 🔴 | 🔴 | impl |
| OOF-P28 (unnamed) | Unnamed block carrying semantic consequence | P28 | TBD | 🔴 | 🔴 | 🔴 | gov |
| OOF-ESM (coercion) | `assumed → observed` upward coercion without review | ESM | Gap-H | 🔴 | 🔴 | 🔴 | sem/gov |
| OOF (undeclared assumption) | Constraint used without enclosing `assumptions {}` | P22 | PROP-032+ | 🔴 | 🔴 | 🔴 | sem/gov |

OOF-I1/I3/I5: PROP-025 addendum required; no new PROP ID needed. These are the only OOF
gaps where the authorizing PROP already exists.

OOF-P28 / OOF-ESM / OOF-undeclared-assumption: no PROP exists; each needs a formal
gap analysis → PROP before a golden anchor can be created.

---

## Domain 7 — Composition + Evidence

| entity | P | Spec | PROP | Parse | Class | TC | SIR | RT | Au | Debt |
|--------|---|------|------|-------|-------|----|-----|----|----|------|
| `output … evidence [refs]` syntax | P6, P20, P27 | ch10 §10.5 | PROP-033 (queued) | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🔴 | sem |
| Contract composition algebra (`>>`, `\|\|`, …) | P20 | ch10 | PROP-002 (proposal) | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | 🔴 | sem |
| Profile System (compile-time policy gate) | P10 | ch11 | PROP-034 (queued) | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |
| `via profile` binding | P10 | ch11 | PROP-032‡ (queue conflict) | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | 🔴 | gov |

---

## Domain 8 — Governance Layer

| entity | P / Axiom | Spec | PROP / Doc | Debt |
|--------|-----------|------|------------|------|
| PROP Governance Filter (V-2) | Axiom 2, P27 | — (Covenant) | Covenant §PROP-Gov-Filter | gov |
| P28 OOF enforcement gap table | P28 | — | TBD (assigned to Compiler/Grammar Expert) | gov |
| META-EXPERT-013 §VI ↔ PROP Governance Filter reconciliation | Axiom 2, P27 | — | META-EXPERT-013 + Covenant | gov |
| startup_time freshness override validator | P27, Axiom 2 | — (design track R29) | — | impl |
| V-3 (`observed + temporal → temporal`) dedicated golden | P3, P4 | ch9, ch10 | PROP-031, PROP-028 | impl |
| PROP-032 queue conflict (see §Governance Issues) | P10, P22 | — | proposals/README.md | gov |

---

## Governance Issues

### GI-1 — PROP-032 Queue Conflict (HIGH)

`proposals/README.md` reserves PROP-032 for `via profile binding` (depends: PROP-031, Stage 3,
priority: high). `canonical-semantic-model.md` and `agent-context.md` both assign PROP-032 to
the `assumptions {}` block (Gap-H).

These assignments are mutually exclusive. Until resolved, neither Gap-H nor `via profile` can
proceed to authoring without risk of a number collision.

**Blocking:** assumptions block authoring, `via profile` authoring, PROP-033 onwards.

**Recommended resolution:** Assign PROP-032 to `assumptions {}` (Gap-H, higher governance
priority per Four Axes of Honesty); renumber `via profile binding` to PROP-033; shift
`output evidence syntax` to PROP-034 and the Profile System to PROP-035 (or keep
PROP-035 for Effect Surface and find a later slot). Requires Architect decision.

### GI-2 — Effect Surface Coverage Gap (CRITICAL)

PROP-035 (Effect Surface) is queued but not authored. Seven postulates (P4, P7, P9, P15, P17,
P19, P21) commit to Effect Surface semantics. Until PROP-035 lands, `effect`, `privileged`,
and `irreversible` modifiers have no runtime enforcement, receipts lack authority and
compensation fields, and the failure taxonomy (P15) has no compiler expression.

This is the single highest-leverage open gap in the language.

### GI-3 — Managed Recursion Doctrine Has Zero Compiler Expression (HIGH)

The Covenant's Managed Recursion Doctrine (P14) commits the language to loop classes:
stoppable / observable / bounded. No PROP has been numbered. `finite_by_collection`,
`finite_by_fuel`, `convergent_by_metric`, and `alive_by_liveness` are all 🔴 across all
stages with a placeholder PROP-036+ that does not yet exist as a file.

### GI-4 — P28 Enforcement Not Codified (MEDIUM)

Postulate 28 (No Unnamed Block May Carry Semantic Identity) is Covenant-governing. The
Covenant lists five construct types subject to it (`escape`, loop class, `assumptions {}`,
`constraints {}`, `invariant`). No OOF code exists for P28 violations. The P28 enforcement
gap table is a R30 carry item assigned to Compiler/Grammar Expert.

### GI-5 — Epistemic State Machine Has No Compiler Gate (MEDIUM)

The Covenant's Epistemic State Machine defines typed transitions and explicitly forbids
upward coercion (`assumed → observed`, `simulated → executed`). No OOF code, no TypeChecker
guard, and no PROP exists for this. The `observed` modifier exists as a classifier fragment
class but does not enforce epistemic transition validity.

---

## Debt Summary

### By debt type

| debt_type | Entity count | Hotspot |
|-----------|-------------|---------|
| `gov` | 15 | Effect Surface (PROP-035) — blocks 7 postulates; highest single leverage |
| `sem/gov` | 7 | assumptions (Gap-H), constraints (Gap-J), synthetic markers, epistemic coercion, unnamed-block OOF |
| `sem` | 7 | form (Gap-I), loop classes ×4, evidence syntax (PROP-033), composition algebra (PROP-002) |
| `impl/gov` | 5 | `observed`/`effect`/`privileged`/`irreversible` modifiers + receipt production shape |
| `impl` | 10 | History[T] parser+runtime, BiHistory[T] runtime, OOF-I1/I3/I5, startup_time validator, V-3 golden |
| `none` | 9 | core contract, `pure` modifier, OOF-P1/S2/S4/CE4/OS2, as_of, OOF-M1 |

### By domain heat

| domain | 🔴 gaps | ⚙️ partial | ✅ full | Highest debt |
|--------|---------|-----------|--------|--------------|
| Core Contract Shape | runtime enforcement (5 modifiers) | 5 modifiers | 1 entity | impl/gov |
| Epistemic Declarations | 7 full | 0 | 0 | sem/gov |
| Effect Surface | 5 full + 3 fields | 1 (receipt FFI shape) | 0 | gov (critical) |
| Temporal Read | 1 (parser syntax) | 5 | 1 (as_of compiler) | impl |
| Form + Loop | 5 full | 0 | 0 | sem |
| OOF Registry | 3 deferred + 3 new | 2 (OOF-M1) | 6 | impl / sem/gov |
| Composition + Evidence | 4 full | 0 | 0 | sem / gov |
| Governance Layer | 4 open | 0 | 0 | gov |

---

## R31 Recommendations

Priority ordering is by governance leverage × current proof readiness.

### R31-1 — PROP-032 Queue Conflict Resolution (prerequisite)

Resolve GI-1 before any authoring work on assumptions, `via profile`, or evidence syntax.
Route as an Architect decision with the proposal/README.md renumbering. This unblocks R31-2
and R31-3.

### R31-2 — assumptions {} Block: Proposal + Minimal Fixture (HIGH)

Once PROP-032 is assigned to Gap-H, ask `[Igniter-Lang Compiler/Grammar Expert]` to author
the PROP (grammar, fragment class, classifier detection, TypeChecker propagation) and ask
`[Igniter-Lang Research Agent]` to create the minimum golden fixture: one positive case
(declared assumption flows to evidence) + one OOF case (contract body reads undeclared
assumption).

This closes the most visible CSM anchor gap (rated HIGH in R30 CSM recommendations).

### R31-3 — OOF-I1 / OOF-I3 / OOF-I5 Closure (HIGH, low-effort)

No new PROP needed — these are addenda to the already-accepted PROP-025. A focused
experiment pass in `igniter-lang/experiments/` would close three golden anchor gaps in the
CSM. Assign to `[Igniter-Lang Research Agent]`.

### R31-4 — P28 Enforcement Gap Table (MEDIUM)

Assign to `[Igniter-Lang Compiler/Grammar Expert]`. Enumerate all construct types subject
to P28, identify which currently compile without an OOF, and draft OOF codes for each.
Feeds the governance filter reconciliation (GI-4) and blocks eventual `form` / loop class
work.

### R31-5 — Effect Surface PROP-035: Scoped Authoring (MEDIUM)

Effect Surface (GI-2) is the highest-leverage governance gap but also the widest. Recommend
a bounded scope: author PROP-035 for the Effect Surface declaration shape only (`effect_surface
{ }` contract-level field, escape_boundaries wire-up, authority reference slot). Leave
compensation, timeout taxonomy, and audit reference as deferred §N.N addenda to keep the
first PROP tractable.

### R31-6 — V-3 Golden Anchor (LOW, small)

Add one golden file `observed_temporal_contract.semantic_ir.json` to
`contract_modifiers_proof/golden/` proving that `observed` + `History[T]` body classifies
as `temporal`. Bundle with the next PROP-031-touching track or startup_time validator work.
Closes the last CSM follow-up from R29.

### R31-7 — constraints {} Block and Gap-J Gap Analysis (LOW)

After assumptions (R31-2), open a discussion track on Gap-J to establish the grammar and
fragment class for `constraints {}` before authoring a PROP. Gap-J depends on Gap-H
ordering being settled in the type system.

### R31-8 — Managed Recursion Doctrine: Gap Analysis Track (BACKLOG)

Loop classes (PROP-036+) are entirely unspecified. Recommend a scoped research track to
enumerate the five loop class variants, identify the compiler surface required (new
fragment class? OOF? spec chapter?), and produce a gap analysis before any PROP is
authored. No implementation authorization implied.

---

## Maintenance Rule

> When a new entity is added to the compiler, add a row here and update the CSM.
> When a new PROP changes a status, update the affected rows.
> When a governance issue is resolved, remove or close the §Governance Issues entry.
> This map is evidence-based. Do not add rows for ideas that have no covenant or
> spec anchor. Do not promote status without a landed golden anchor.

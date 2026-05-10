Card: S3-R30-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r30-decision-heatmap-and-assumptions-pressure-v0

Question:
Did R30 authorize only a bounded production durable audit implementation, if it
authorized anything? Did the heat map and Covenant enforcement rule reduce context
debt rather than create new canon drift? Did PROP-032 stay as the single Language
Lane PROP and avoid opening forms/loops/constraints/Effect Surface?

Context:
- S3-R30-C1-A: `phase1-production-durable-audit-implementation-authorization-decision-v0.md`
  — Status: `approved-bounded-implementation`. 9 authorized surfaces; comprehensive
  explicit non-authorization list (production deployment, HSM/KMS, Ledger,
  Phase 2, BiHistory, stream/OLAP, production cache, broad RuntimeMachine binding,
  general write/replay/compact/subscribe, gate3_authorized widening). Requires
  follow-up Architect review before production deployment or broader binding. Two
  required tightening items carried forward: (a) all non-default freshness policies
  requiring expires_at, (b) proof-local freshness authority fixture patterns.
- S3-R30-C2-P: `startup-time-freshness-override-validator-v0.md` — 28/28 PASS,
  12/12 invariant checks. D1: all non-default policies require expires_at (stricter
  than R29 design). D2: `freshness_policy_format_invalid` (new code for unrecognized
  format_version / wrong kind). D3: `direct_override_seconds` non-nil → explicit
  refusal. gate3_authorized: false in all outputs. Proof-local only; no Ledger,
  Phase 2, online lookup, production signing.
- S3-R30-C3-P: `observed-temporal-precedence-golden-r30-v0.md` — V-3 golden
  anchored via hand-authored parsed AST (json_source: pattern, matching
  temporal_semanticir_access_node approach). 25/25 PASS. classifier check
  `classifier.temporal_precedence_over_modifier: ok` confirmed. CSM secondary
  anchor for observed modifier row noted as required documentation follow-up.
  No grammar added; no existing proofs altered.
- S3-R30-C4-P: `semantic-governance-heat-map-v0.md` — New index at
  docs/dev/semantic-governance-heat-map.md. 8 domains, 50+ entities, evidence-based
  status symbols. Key findings: GI-1 (PROP-032 queue conflict, blocking);
  GI-2 (Effect Surface, critical, 7 postulates committed); GI-3 (Managed Recursion,
  zero compiler expression); GI-4 (P28 enforcement not codified); GI-5 (ESM no
  compiler gate). Doc-only; maintenance rule states "Do not promote status without
  a landed golden anchor."
- S3-R30-C5-P: `covenant-promise-enforcement-path-rule-v0.md` — Covenant Promise
  Enforcement Registry added to language-covenant.md. 5 statuses: enforced /
  planned PROP / spec_candidate / doctrine-only / partial. All 28 postulates
  assigned. P28 per-surface table: only invariant naming currently enforced;
  escape declaration naming = Unknown (OQ-P28-1 routed to Compiler/Grammar Expert).
  P27 = doctrine-only (correct: enforcement mechanism is PROP Governance Filter,
  not compiler). OQ-Filter-1 added: Governance Filter vs META-EXPERT-013 §VI
  source-of-truth requires Architect decision. Doc-only.
- S3-R30-C6-P: `prop032-assumptions-block-draft-r30-v0.md` — PROP-032
  `assumptions {}` block drafted (PROP-032-assumptions-block-v0.md). Draft-only:
  no classifier implementation, no parser change, no golden files. GI-1 resolved
  in PROP header by asserting PROP-032 = assumptions {} with renumbering table
  (via profile binding → PROP-033; output evidence syntax → PROP-034;
  profile declarations → PROP-035; Effect Surface → TBD). New sixth fragment
  class `epistemic` proposed (precedence: oof > temporal > escape > epistemic >
  core). OOF-A1 two-stage pipeline (Classifier → TypeChecker) mirrors OOF-M1.
  11 explicit non-goals including no constraints, no form, no ESM enforcement.

---

## Scope Item Review

| Item | Source | Finding | Status |
|------|--------|---------|--------|
| Authorization scope exactness | C1-A | 9 authorized surfaces; comprehensive non-auth list; follow-up review required before deployment | PASS |
| No Ledger widening | C1-A, C2-P | Explicit non-auth; invariant checks confirm no Ledger access | PASS |
| No Phase 2 widening | C1-A, C2-P | Explicit non-auth; invariant checks confirm no Phase 2 access | PASS |
| No BiHistory widening | C1-A | Explicit non-auth; BiHistory RT remains 🚫 in heat map | PASS |
| No stream/OLAP widening | C1-A | Explicit non-auth; heat map keeps stream/OLAP out of scope | PASS |
| No production cache widening | C1-A | Explicit non-auth; proof-local only throughout | PASS |
| Startup validator does not create ambient policy leak | C2-P | Fail-closed 28/28; D1 stricter; D3 API guard; no online lookup; gate3_authorized: false | PASS |
| Heat map does not promote spec_candidate to implemented | C4-P | PROP-032 domain rows remain 🔴; legend distinguishes ✅/⚙️/🟡/🔴/🚫; maintenance rule explicit | PASS |
| One stale heat map row (startup freshness validator) | C4-P vs C2-P | C4-P authored before C2-P landed; Domain 8 shows `impl` debt for startup_time validator post-28/28 PASS | ⚠️ NB |
| One stale heat map row (V-3 golden) | C4-P vs C3-P | C4-P authored before C3-P landed; Domain 8 shows `impl` debt for V-3 golden post-C3-P PASS | ⚠️ NB |
| Covenant enforcement statuses explicit | C5-P | 28/28 postulates assigned; Unknown used for escape naming (honest); `partial` for P28 | PASS |
| P11/P12 not overstated as enforced | C5-P | Both = planned PROP (PROP-035 needed for full enforcement); correct | PASS |
| PROP-032 is draft-only | C6-P | No classifier implementation, no parser change, no golden files confirmed | PASS |
| PROP-032 is assumptions-only | C6-P | 11 explicit non-goals; no constraints, form, loops, ESM enforcement, Effect Surface | PASS |
| GI-1 resolution authority | C6-P | Queue conflict resolved in PROP header, not by Architect decision; proposals/README.md still stale | ⚠️ NB |
| `epistemic` fragment class as new language surface | C6-P | New sixth fragment class introduced in draft; requires implementation authorization before Classifier work begins | ⚠️ NB |
| D1/D2/D3 not in R29 design track | C2-P | startup-time-freshness-override-interface-v0.md now out of sync with implementation; flagged as Q1/Q2 follow-up | ⚠️ NB |
| OQ-Filter-1 / P-31 open | C5-P | Governance Filter vs META-EXPERT-013 §VI precedence unresolved; both must be consulted by PROP authors | ⚠️ NB |

---

## Risk Table

| Risk | Severity | Owner | Notes |
|------|----------|-------|-------|
| Heat map two stale rows (startup freshness + V-3) | Low | Meta Expert | Both are improvements, not regressions. Stale rows show `impl` where status should be ⚙️. No spec drift; only delayed credit. |
| proposals/README.md renumbering unapplied | Low–Medium | Meta Expert / Architect | GI-1 self-resolved by PROP card without Architect co-sign. Until README is patched, PROP-033 slot is ambiguous — a parallel author could create a collision. |
| D1/D2/D3 codes not in R29 design track | Low | Research Agent / Meta Expert | Both new codes are more restrictive (fail-closed). No ambient policy leak. Design track just lags implementation. |
| `epistemic` fragment class: no implementation authorization gate | Medium | Compiler/Grammar Expert | New language surface (sixth fragment class + precedence shift) requires the same implementation authorization pattern as PROP-031 did. PROP-032 is draft status — acceptable to introduce the concept. Classifier implementation should NOT begin without an explicit authorization gate equivalent to what PROP-031 received. |
| OQ-Filter-1 unresolved (PROP Governance Filter vs META-EXPERT-013 §VI) | Medium | Architect | P-31 from pre-production checklist. Dual authority on PROP acceptance. Every PROP author in R31+ is exposed to this ambiguity. |
| C1-A tightening item (b) unresolved | Low | Implementation Agent | C1-A item 5 required defining "accepted/rejected proof-local authority fixture patterns." C2-P proof-local authority validation accepts any non-blocked authority_ref. Honest about the gap (proof comment). Not a blocker, but must be locked before any production signer implementation. |

---

## Pre-Production Checklist Update

| Item | Prev status | R30 disposition |
|------|-------------|-----------------|
| P-28: Architect production durable audit implementation authorization | open (R29) | ✅ **CLOSED** — C1-A issued; `approved-bounded-implementation` |
| P-29: startup_time override proof-local validator | open (R29) | ✅ **CLOSED** — C2-P 28/28 PASS |
| P-30: V-3 temporal+observed dedicated proof golden | open (R29) | ✅ **CLOSED** — C3-P 25/25 PASS |
| P-31: META-EXPERT-013 §VI + PROP Governance Filter reconciliation | open (R29) | **still open** — OQ-Filter-1 routes to Architect |
| P-32: PROP-032 (assumptions block) draft | open (R29) | ✅ **CLOSED** (draft status) — C6-P PROP-032 drafted |
| P-33 (new): proposals/README.md GI-1 renumbering applied | — | **open** — carry from C6-P; proposals/README.md not yet updated |
| P-34 (new): Heat map stale rows corrected (startup validator + V-3) | — | **open** — C4-P predates C2-P and C3-P |
| P-35 (new): R29 design track amended for D1/D2/D3 new failure codes | — | **open** — Q1/Q2 flagged by C2-P |
| P-36 (new): PROP-032 `epistemic` fragment class implementation authorization gate | — | **open** — before Compiler/Grammar Expert begins Classifier implementation |

---

[Agree]
- C1-A authorization is the most tightly constructed gate decision in this project
  so far: 9 explicitly named authorized surfaces, a comprehensive non-authorization
  list that names every excluded domain by name (Ledger, Phase 2, BiHistory,
  stream/OLAP, production cache, HSM/KMS, broad RuntimeMachine, gate3_authorized),
  and a mandatory follow-up Architect review before production deployment. No
  silent fallback path is visible.
- C2-P (startup validator) closes the C-1 challenge from S3-R29-X1-S: D1 makes
  the policy stricter (all non-default require expires_at), not looser. D3
  explicitly refuses any direct_override_seconds bypass attempt. The 28 refusal
  cases and 12 invariant checks establish a proof-verifiable fail-closed contract.
  gate3_authorized: false in all outputs; no policy surface leak created.
- C3-P closes P-30 cleanly. V-3 is now golden-anchored with a named check
  (`classifier.temporal_precedence_over_modifier: ok`). The json_source: bypass
  for unparseable History[T] grammar follows established precedent and is clearly
  labeled as provisional.
- C5-P (Covenant enforcement registry) is the right answer to the
  "enforced vs. aspirational" ambiguity that S3-R29-X1-S flagged. Using `partial`
  for P28 (enforced for invariant, unknown/pending for all others) is honest and
  avoids the trap of marking it `enforced` based on one of five surfaces. The
  five-status vocabulary is minimal and sufficient.
- C6-P PROP-032 is strictly draft-only with 11 explicit non-goals. The OOF-A1
  two-stage pipeline mirrors OOF-M1 — a proven pattern.

[Challenge]
- C-1: The heat map (C4-P) was authored before both C2-P and C3-P landed in
  the same round. Domain 8 carries two stale `impl` debt entries: the startup
  freshness validator (now 28/28 PASS, should be ⚙️) and V-3 golden (now
  25/25 PASS, should be ⚙️). These are not spec drift — they are stale credits.
  But a reader consulting the heat map tomorrow will see two open items that
  are already closed. This creates false residual pressure for R31 prioritization.

- C-2: GI-1 (PROP-032 queue conflict) is declared resolved in C6-P's PROP header
  rather than by an Architect decision card. The heat map (C4-P) explicitly states
  GI-1 "requires an Architect decision." The PROP card for PROP-032 makes the
  resolution decision unilaterally. proposals/README.md still carries the old
  assignment. Until an Architect card or a Meta Expert curation pass updates the
  README, the old PROP-032 slot (`via profile binding`) remains in the queue.
  A second PROP author reading proposals/README.md could draft a collision.

- C-3: C2-P introduces two new failure codes (D2 `freshness_policy_format_invalid`,
  D3 `direct_seconds_override_rejected`) that are not in the R29 design spec
  (`startup-time-freshness-override-interface-v0.md`). Both codes are strictly more
  restrictive (fail-closed paths, not bypasses). C1-A §5 tightening item (b) is
  partially answered but not fully closed: proof-local authority fixture patterns
  are described implicitly in C2-P but not formalized in the design spec. The design
  track is now behind the implementation.

- C-4: `epistemic` as the sixth Classifier fragment class is a new language surface.
  PROP-031 introduced five fragment classes after going through the full PROP
  lifecycle (proposal → acceptance criteria → experiment-pass). PROP-032 is at
  draft status. The `epistemic` class changes the `contract_fragment_for` precedence
  chain, requires Classifier and SemanticIR Emitter changes, and adds a new node
  kind (`uses_assumptions`). This is not implementation-authorization-size work —
  but it is enough that a Compiler/Grammar Expert beginning Classifier implementation
  before PROP-032 reaches the standard authorization gate would be outside the
  established lifecycle. The PROP-032 prerequisite section explicitly lists
  Classifier implementation as a Compiler/Grammar Expert task. The gate should be
  explicit.

[Missing]
- M-1: A same-round amendment to the heat map (C4-P) acknowledging C2-P and C3-P
  completion. Either C4-P should have been authored after C2-P and C3-P, or a
  targeted amendment should update Domain 8 rows in the same round they are closed.
  Neither happened in R30.
- M-2: An Architect co-sign or Meta Expert README patch for GI-1. The proposals/README.md
  renumbering is not a PROP-level governance decision — it is a queue maintenance
  decision. But because the queue was previously authoritative and the conflict was
  named a blocking governance issue, a resolution document from an initiator role
  (Architect, Meta Expert, or the user) is the clean close.
- M-3: An addendum or amendment to `startup-time-freshness-override-interface-v0.md`
  incorporating D1 (all non-default require expires_at) and the two new failure codes
  (D2/D3). The design track should remain the reference document for the production
  implementation team; it must not lag the proof.
- M-4: An explicit implementation authorization gate for PROP-032 before Classifier
  implementation begins. The PROP draft is the correct first artifact. The missing
  piece is a card or handoff note that says: "PROP-032 Classifier implementation may
  not begin until [PROP-032 acceptance criteria are reviewed / Architect decision /
  META-EXPERT-013 §VI acceptance gate]." The PROP acceptance criteria exist (§11, 9
  criteria) but the trigger for implementation to start is not yet defined.

[Sharper Question]
- Does the PROP-032 `epistemic` fragment class need Architect co-sign before
  Classifier implementation begins, or does the standard META-EXPERT-013 §VI
  acceptance criteria check (which PROP-032 §11 documents) constitute the
  authorization gate?

[Route]
- PROCEED (non-blockers only)
- P-28 through P-30, P-32 CLOSED in R30.
- P-31 (Governance Filter vs META-EXPERT-013 §VI) — route to Architect: OQ-Filter-1.
- P-33 through P-36 are new open items; none block R31 from starting.
- R31 recommendation below.

---

## Verdict

**PROCEED** — no blocking conditions for R31.

P-28, P-29, P-30, and P-32 are all closed by R30. The authorization decision is
bounded and explicit. The startup validator is fail-closed with 28/28 PASS. V-3 is
golden-anchored. PROP-032 is draft-only.

Four non-blocker items (NB-1 through NB-4 in the risk table) should be resolved
in R31 before PROP-032 Classifier implementation work begins.

## R31 Recommendation

**Priority 1 — Governance closure (prerequisite for R31 PROP work):**

1. [Architect or Initiator] Decide OQ-Filter-1: which is the primary PROP
   acceptance authority — Covenant PROP Governance Filter or META-EXPERT-013 §VI?
   Route P-31. Until resolved, PROP-032 §11 acceptance criteria have dual
   authority ambiguity. (Closes P-31.)

2. [Meta Expert] Apply proposals/README.md GI-1 renumbering (via profile
   binding → PROP-033; output evidence syntax → PROP-034; profile declarations →
   PROP-035; Effect Surface → TBD or PROP-036). This enforces the GI-1 resolution
   made in C6-P's PROP header. (Closes P-33.)

**Priority 2 — Documentation sync (small, can run in parallel):**

3. [Research Agent or Meta Expert] Amend `startup-time-freshness-override-interface-v0.md`
   with D1 (all non-default policies require expires_at) and D2/D3 new failure codes.
   (Closes P-35.)

4. [Meta Expert] Update heat map Domain 8 rows: startup_time freshness validator
   → ⚙️ (C2-P 28/28 PASS); V-3 golden → ⚙️ (C3-P 25/25 PASS). Also update CSM
   observed modifier row to cite secondary anchor
   `observed_temporal_precedence.classified.json` (V-3 temporal path). (Closes P-34.)

**Priority 3 — PROP-032 implementation gate:**

5. [Compiler/Grammar Expert] Answer OQ-P28-1: is an unnamed `escape` declaration
   currently a parse error? This is a prerequisite for PROP-035 scoping and feeds
   the P28 per-surface enforcement table. (Referenced in C5-P OQ-P28-1.)

6. [Architect or META-EXPERT-013 §VI process] Establish the explicit
   implementation authorization gate for PROP-032. The PROP-032 §11 acceptance
   criteria are the gate content; the trigger (who reviews, what constitutes
   acceptance) must be stated before Classifier implementation begins.
   (Closes P-36.)

**Priority 4 — PROP-032 proof cycle (R31 core work):**

7. [Compiler/Grammar Expert] Classifier implementation: `uses_assumptions` node
   kind, `assumption_registry` construction, OOF-A1 detection, `epistemic`
   fragment class, `assumption_refs` field. Prerequisite: items 1 and 6 above.

8. [Research Agent] Fixture authoring: 3 hand-authored parsed AST JSONs
   (assumption_basic + epistemic_only_pure + oof_a1_undeclared_assumption) and
   proof runner for `assumptions_proof` experiment. Prerequisite: item 7 above.

9. [Research Agent] OOF-I1/I3/I5 closure — PROP-025 addendum + targeted
   fixtures. No new PROP needed; low effort; closes 3 CSM anchor gaps.

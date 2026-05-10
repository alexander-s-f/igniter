Card: S3-R31-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r31-bounded-audit-and-governance-pressure-v0

Question:
Did R31 authorize only a bounded production durable audit implementation? Did the
governance authority decision close the split-authority gap without inviting new
implementation scope? Did the map sync capture all round-internal closures? Does
PROP-032 remain gated-only until its explicit Phase 1 gate passes?

Context:
- S3-R31-C1-P: `phase1-production-durable-audit-bounded-implementation-v0` —
  29/29 PASS, 5/5 invariant checks. Surfaces 1, 2, 3, and 8 of the C1-A
  9-surface scope: schema validation, signer abstraction, append-only store,
  excluded-surface regression. Four surfaces open as blockers (B-A restart
  rebuild, B-B traversal/reader, B-C appender/reader role boundary, B-D full
  regression matrix). All proof classes live entirely inside the proof script.
  gate3_authorized: false; production_durable_audit: false in all proof-local
  outputs. D1: five fields excluded from canonical record_hash (self-referential,
  signature-derived, and compliance_posture). D2: compliance_posture always
  derived at validate time; caller value overwritten. D3: proof_local_ storage
  forces production_durable_audit: false. D4: format_version "0.1.0" refused.
  Two open design questions flagged: Q1 (D1 canonical hash algorithm not in
  design spec), Q2 (compliance_posture stored vs re-derived model unspecified).
- S3-R31-C2-A: `prop-governance-authority-decision-v0` — OQ-Filter-1 closed.
  Covenant is normative; META-EXPERT-013 is operational. No consolidated
  document needed. Explicit: PROP-032 implementation NOT authorized. Explicit
  non-authorization list mirrors C1-A (Ledger, Phase 2, BiHistory, stream/OLAP,
  production cache, HSM/KMS, RuntimeMachine, write/replay/compact/subscribe).
  Three required follow-up docs: META-EXPERT-013 update, Covenant OQ-Filter-1
  close, current-status update.
- S3-R31-C3-S: `r31-governance-map-sync-v0` — Heat map Domain 2 (assumptions
  sem/gov → gov; PROP: all 🔴 → all 🟡; debt type upgraded). Domain 7 PROP
  numbers shifted. Domain 8 startup_time + V-3 rows: impl → none. GI-1 closed
  in §Governance Issues. Pre-check: proposals/README.md and CSM were already
  current; no edits required to those. Documentation only.
- S3-R31-C4-P: `startup-freshness-design-amendment-d1-d2-d3-v0` — R29 design
  track amended to match R30 validator: D1 (all non-default require expires_at),
  D2 (freshness_policy_format_invalid), D3 (direct_seconds_override_rejected).
  Proof-local boundary maintained. P-35 closed.
- S3-R31-C5-P: `prop032-assumptions-implementation-gate-review-v0` — Gate
  review card; no compiler code written. Three gate decisions: G-1 (OQ-3
  evidence list out of Classifier scope; PROP-033 owns), G-2 (OQ-Filter-1
  does not block implementation; C2-A later confirmed), G-3 (P28 enforcement
  clause §P28-AC-1 added as mandatory gate criterion). Phase 1 gate SATISFIED
  (all 13 items verified). Phase 2/3/4 blocked on Phase 1 golden files. Allowed
  next implementation card template produced.
- S3-R31-C6-A: `compiler-profile-architecture-direction-v0` — Profile–Baseline–
  Pack adopted as post-POC target direction; current compiler remains proof
  compiler; no rewrite authorized; migration requires later plan and authorization.
- S3-R31-C7-P: `compiler-pack-shadow-profile-proof-v0` — Shadow profile proof
  PASS (13/13 checks). dispatch_mode: "shadow_no_dispatch"; no CompilerKernel
  implementation; no .igapp changes; native_pack_migration_authorized: false.
  AssumptionsPack labeled "proposed shadow only" — explicitly "does not imply
  PROP-032 implementation authorization." epistemic fragment class appears in
  FragmentRegistry as future-shaped candidate.

---

## Scope Item Review

| Item | Source | Finding | Status |
|------|--------|---------|--------|
| Bounded audit implementation scope | C1-P | 29/29 PASS; 5 invariant checks confirm no Ledger, Phase 2, HSM/KMS, production cache, gate widening | PASS |
| No Ledger widening | C1-P | `schema.ledger_storage_refused` + `store.ledger_storage_identity_refused` + `excluded.no_ledger_adapter` all PASS | PASS |
| No Phase 2 widening | C1-P | `excluded.no_phase2_surfaces` + `invariant.no_phase2_access` PASS | PASS |
| No BiHistory widening | C1-P, C2-A | Explicit non-auth; proof scope has no BiHistory reference | PASS |
| No stream/OLAP widening | C1-P, C2-A | Explicit non-auth; no stream/OLAP in proof | PASS |
| No production cache | C1-P | In-memory proof-local store only; no persistent/production cache | PASS |
| No concrete HSM/KMS onboarding | C1-P | `invariant.no_hsm_kms_onboarding` PASS; ProofLocalSigner only | PASS |
| No broad RuntimeMachine binding | C1-P | All classes inside proof script; no lib/ changes | PASS |
| No general write/replay/compact/subscribe | C1-P | Mutation refused (`audit.store.mutation_not_authorized`); no subscribe surface | PASS |
| Governance authority split-authority gap | C2-A | Covenant normative, META-EXPERT-013 operational; clear precedence; no new lifecycle doc | PASS |
| PROP-032 implementation not authorized by C2-A | C2-A | Explicit statement; no parser/classifier/typechecker/SemanticIR/OOF-A1 authorized | PASS |
| PROP-032 Phase 1 gate passed explicitly | C5-P | 13/13 gate items satisfied; G-1/G-2/G-3 resolved; Phase 1 implementation card may now be issued | PASS |
| PROP-032 draft-only before gate | C5-P | Gate review card (no code); Phase 1 gate SATISFIED as of C5-P; Classifier implementation now authorized per gate | PASS |
| C1-P surface numbering vs C1-A surface list | C1-P | C1-P claims "surfaces 1–4" but delivers surfaces 1, 2, 3, and 8 from C1-A numbering; surface 4 (restart rebuild) is B-A (open) | ⚠️ NB |
| C1-P D1 canonical hash not in design spec | C1-P | Five excluded fields discovered during implementation; Q1 flagged; no design amendment yet | ⚠️ NB |
| C1-P Q2 compliance_posture storage model unresolved | C1-P | Stored but excluded from hash; re-derived at validate; two possible states if stored ≠ derived | ⚠️ NB |
| C3-S missed C2-A closure of OQ-Filter-1 | C3-S | Map sync card authored without C2-A; Domain 8 "Governance Filter ↔ META-EXPERT-013" row still shows gov debt; C2-A's required follow-up docs not yet landed | ⚠️ NB |
| C2-A required follow-up docs not yet applied | C2-A | META-EXPERT-013 update, Covenant OQ-Filter-1 close, current-status update — all carry items | ⚠️ NB |
| C7-P `epistemic` in FragmentRegistry | C7-P | Registered as "required" and owned by AssumptionsPack in shadow proof; PROP-032 still at `proposal` status; shadow proof is descriptive only | ⚠️ NB |
| C6-A no-rewrite constraint | C6-A | Current compiler stays proof compiler; migration requires later authorization; explicit; no new production surfaces opened | PASS |

---

## Risk Table

| Risk | Severity | Owner | Notes |
|------|----------|-------|-------|
| C1-P surface numbering error ("1–4" vs actual 1/2/3/8) | Low | Meta Expert or Research Agent | Causes no spec drift — B-A through B-C explicitly enumerate open surfaces. Risk is reader confusion if someone consults C1-P to determine what remains open without reading the blocker list. A one-line errata note in C1-P or status curation is sufficient. |
| C1-P D1 canonical hash excluded fields undocumented | Medium | Research Agent | Same class of gap as R30 startup freshness D1/D2/D3. The R31 C4-P pattern (design amendment track) is the established fix. Five excluded fields define the canonical hash algorithm; without a design spec amendment, a future production implementation team has only the proof script as the specification. |
| C1-P Q2 compliance_posture stored vs re-derived | Medium | Implementation Agent | Two states (stored vs derived) could diverge if the store serializes the record and the validator re-derives on read. The proof always re-derives and ignores the stored value — but the design doesn't specify whether the stored value should be stripped, kept as-informational, or treated as an error if different from derived. Before restart rebuild (B-A) or traversal/reader (B-B) are implemented, this needs to be locked. |
| OQ-Filter-1 closure not reflected in heat map or Covenant | Low–Medium | Meta Expert | C2-A explicitly closes OQ-Filter-1 and lists three required follow-up docs. C3-S ran before C2-A landed (same-round sequencing) and missed the closure. Heat map Domain 8 still shows one `gov` debt for "Governance Filter ↔ META-EXPERT-013 reconciliation." This is informational only — the decision is made — but the map shows stale open status. |
| META-EXPERT-013 §VI not updated for Covenant authority | Low–Medium | Compiler/Grammar Expert | C2-A item 1: META-EXPERT-013 must note the Covenant is normative. Every future PROP card may consult META-EXPERT-013 §VI as the primary acceptance reference without seeing the updated authority chain. Until updated, the chain in C2-A is document-only and not operationally visible. |
| C7-P `epistemic` as "required" in FragmentRegistry | Low | Research Agent | AssumptionsPack owns `epistemic` in the shadow proof as a future-shaped candidate. If PROP-032 is substantially modified or rejected, this shadow proof becomes stale. The explicit "proposed shadow only" label and no-dispatch constraint contain the risk. No production effect. Monitor for consistency if PROP-032 design changes in R32. |
| B-A/B-B/B-C: three surfaces still open | Informational | Implementation Agent | Restart rebuild, traversal/reader, appender/reader role boundary — all three must close before the follow-up Architect review can authorize production deployment. Not a blocker for R32 to continue the implementation track; these are the designated remaining surfaces. |

---

## Pre-Production Checklist Update

| Item | Prev status | R31 disposition |
|------|-------------|-----------------|
| P-31: META-EXPERT-013 §VI + PROP Governance Filter reconciliation | open (R30) | ✅ **CLOSED** — C2-A; Covenant normative, META-EXPERT-013 operational |
| P-33: proposals/README.md GI-1 renumbering | open (R30) | ✅ **CLOSED** — pre-check confirms already applied before C3-S |
| P-34: Heat map stale rows (startup validator + V-3) | open (R30) | ✅ **CLOSED** — C3-S updated Domain 8 both rows to `none` |
| P-35: R29 design track D1/D2/D3 amendment | open (R30) | ✅ **CLOSED** — C4-P design amendment landed |
| P-36: PROP-032 epistemic implementation authorization gate | open (R30) | ✅ **CLOSED** — C5-P Phase 1 gate SATISFIED; C2-A confirms gate discipline |
| P-37 (new): C1-P D1 canonical hash excluded fields — design spec amendment | — | **open** — Q1 flagged in C1-P; no amendment track yet |
| P-38 (new): C1-P Q2 compliance_posture storage model — locked before B-A/B-B | — | **open** — unresolved design question |
| P-39 (new): Heat map Domain 8 OQ-Filter-1 row and Covenant OQ-Filter-1 close — update for C2-A | — | **open** — C3-S did not incorporate C2-A (same-round) |
| P-40 (new): META-EXPERT-013 §VI Covenant authority note — C2-A follow-up item 1 | — | **open** — carry from C2-A |

---

[Agree]
- C1-P bounded implementation is correctly scoped. The five invariant checks
  (`no_production_durable_audit_in_proof_local`, `no_ledger_access`, `no_phase2_access`,
  `no_hsm_kms_onboarding`, `format_version_1_0_0_required`) are a proof-verifiable
  scope guarantee — not just assertions in prose. 29/29 cases with 5/5 invariant
  checks is the correct structure for a bounded proof.
- C2-A's two-layer authority model (Covenant normative, META-EXPERT-013 operational)
  is the right shape. No third document needed. The precedence rule is simple:
  "If they appear to conflict, the Covenant controls." This eliminates the class of
  PROP acceptance disputes that OQ-Filter-1 was generating.
- C5-P produced the first fully-specified, phase-gated implementation authorization
  for a Language Lane PROP. G-1 (evidence list out of scope), G-2 (OQ-Filter-1
  non-blocking), and G-3 (P28 enforcement clause added) are all sound decisions that
  advance scope discipline rather than widen it. The epistemic guard insertion point
  is specified at line-level precision.
- C4-P closes P-35 using the exact same pattern as C1-P D1/D2/D3 established for
  startup freshness. Design tracks tracking proof decisions is now a repeatable
  pattern — good.
- C7-P shadow profile proof is correctly labeled throughout: shadow, no dispatch,
  no runtime authorization, no .igapp changes. The AssumptionsPack "proposed shadow
  only" label with explicit "does not imply PROP-032 implementation authorization"
  is the right hedge for a draft-PROP surface appearing in a forward-looking proof.

[Challenge]
- C-1: C1-P claims "surfaces 1–4" but covers surfaces 1, 2, 3, and 8 from C1-A's
  numbered scope. Surface 4 (restart rebuild) is explicitly open as B-A. This is a
  labeling error, not a scope error — the blocker table correctly names B-A/B-B/B-C
  as open. But anyone reading only the abstract ("implements surfaces 1–4") will
  conclude surfaces 4–7 are not yet started, which is partially wrong: surface 5
  (startup freshness validator) was done in R30-C2-P. A reader consulting C1-P for
  the implementation audit trail gets a misleading count.

- C-2: C1-P D1 (canonical hash algorithm with five excluded fields) was discovered
  during implementation and is not in any design document. The proof script is
  currently the specification for the hash algorithm. The same pattern occurred with
  startup freshness D1/D2/D3, which took C4-P to close. The bounded audit
  implementation track now has an undocumented hash algorithm decision that must be
  resolved before B-B (traversal/reader) or B-A (restart rebuild) are implemented —
  both of those surfaces will recompute hashes and need to agree on the canonical
  form.

- C-3: C1-P Q2 is a latent state conflict in the stored audit record: compliance_posture
  is stored in the record but always re-derived at validate time, with the stored value
  silently overwritten. In a proof-local in-memory store this is transparent. In a
  real append-only store, the stored record contains a compliance_posture value that
  may differ from what the validator re-derives (e.g., if storage identity changes
  after writing). The design must explicitly say: (a) stored compliance_posture is
  informational/cache only, or (b) stored compliance_posture is not written to the
  record at all, or (c) mismatch between stored and derived compliance_posture is
  itself an audit violation. The current proof silently enforces (a) by re-deriving,
  but the choice is not documented.

- C-4: C3-S (map sync) and C2-A (governance decision) ran in the same round. C3-S
  was authored before C2-A landed and missed the OQ-Filter-1 closure. The heat map
  Domain 8 "META-EXPERT-013 §VI ↔ PROP Governance Filter reconciliation" row still
  shows `gov` debt. Three required follow-up documents from C2-A (META-EXPERT-013
  update, Covenant OQ-Filter-1 close, current-status update) are all open carry
  items. This is the third consecutive round (R30, R31, R31) where a curation card
  missed a same-round resolution due to authoring order. The pattern suggests that
  round-close status curation should run last, after all other cards in the round.

[Missing]
- M-1: A design amendment track for C1-P D1 (canonical hash algorithm excluded
  fields) and resolution of Q2 (compliance_posture storage model). The pattern is
  now established from C4-P: a Research Agent reads the proof track, confirms the
  implementation decision, and produces a single-section amendment to the relevant
  design document. The design document is the production reference, not the proof
  script.

- M-2: A meta-expert curation card that applies the three C2-A follow-up items:
  (1) META-EXPERT-013 §VI gets "Covenant is normative; cite and defer to it" note;
  (2) Covenant OQ-Filter-1 receives a resolution pointer to the gate document;
  (3) current-status.md records P-31 closed and the authority hierarchy decision.
  These are documentation-only edits but operationally important: PROP-032 Phase 1
  implementation will consult META-EXPERT-013 §VI, and it must not see the old
  ambiguous authority.

- M-3: Round-close ordering discipline. In R30, C4-P heat map predated C2-P
  (startup validator) and C3-P (V-3 golden), causing two stale rows. In R31, C3-S
  map sync predated C2-A (governance decision), causing the same class of miss.
  A single recommended ordering note in the operating model or rounds discipline
  would prevent this: "Status curation and map sync cards run after all decision
  and implementation cards in the same round."

[Sharper Question]
- In the bounded audit implementation track, is compliance_posture stored
  in the serialized audit record intentional (as a read-time cache) or should
  it be excluded from the persisted record entirely — only derived at validate time
  from the live record fields?

[Route]
- PROCEED (non-blockers only)
- P-31/P-33/P-34/P-35/P-36 all CLOSED in R31.
- P-37 through P-40 are new open items; none block R32 from issuing the PROP-032
  Classifier implementation card or continuing bounded audit surfaces.
- B-A/B-B/B-C remain open; must close before follow-up Architect production
  deployment review.
- R32 recommendation below.

---

## Verdict

**PROCEED** — no blocking conditions for R32.

R31 closed P-31 through P-36. The bounded audit implementation track is healthy at
29/29 PASS with three explicit open surfaces remaining. PROP-032 Phase 1 gate is
satisfied and implementation may begin. The governance authority chain is clean.

Four non-blockers (P-37 through P-40) should be resolved early in R32, with P-37
and P-38 prioritized before B-A (restart rebuild) begins, because both affect the
canonical hash and compliance_posture semantics that restart rebuild will depend on.

## R32 Recommendation

**Priority 1 — Resolve hash/posture design gaps before B-A:**

1. [Research Agent] Design amendment track for C1-P: document D1 (five excluded
   fields from canonical record_hash; algorithm is `null_derived_fields →
   canonical_json → SHA-256`) and resolve Q2 (compliance_posture storage model:
   stored-as-informational vs not-stored vs mismatch-is-violation). Must land
   before restart rebuild (B-A). (Closes P-37, P-38.)

**Priority 2 — Close same-round coordination gaps (documentation):**

2. [Compiler/Grammar Expert] META-EXPERT-013 §VI amendment: add note that the
   Covenant PROP Governance Filter is the normative acceptance authority; cite
   C2-A gate document as the authority reference. (Closes P-40.)

3. [Meta Expert] Single-card sync: (a) update heat map Domain 8 "Governance Filter
   ↔ META-EXPERT-013" row to `none` citing C2-A; (b) add Covenant OQ-Filter-1
   resolution pointer to the gate document; (c) current-status.md P-31 close.
   (Closes P-39.)

**Priority 3 — PROP-032 Phase 1 Classifier implementation:**

4. [Compiler/Grammar Expert + Research Agent] Issue PROP-032 Phase 1 Classifier
   implementation card per C5-P template. Scope: `uses_assumptions` node kind,
   `assumption_registry` build, OOF-A1 detection, `epistemic` fragment class
   guard, `assumption_refs` field. Coordinate SemanticIR `assumption_refs: []`
   golden file regeneration in same atomic card. §P28-AC-1 parse-error fixture
   required for experiment-pass eligibility. Phase 1 gate is SATISFIED per C5-P.

**Priority 4 — Bounded audit surfaces B-A/B-B/B-C (after P-37/P-38 closed):**

5. [Implementation Agent] Restart rebuild proof (B-A) — surface 4 of C1-A. Depends
   on P-37 (hash algorithm design locked) and P-38 (compliance_posture storage model
   resolved).

6. [Implementation Agent] Audit traversal / reader proof (B-B) — surface 6 of C1-A.
   Depends on P-38 (compliance_posture model locked).

7. [Implementation Agent] Appender / reader role boundary proof (B-C) — surface 7
   of C1-A. May run in parallel with B-B.

8. [Implementation Agent] Post-implementation full regression matrix (B-D) — surface
   9 of C1-A. Must include all existing matrix commands + all new audit proofs.
   Gate before follow-up Architect production deployment review.

**Note on round-close ordering (advisory):**
Consider establishing a round discipline rule: decision (A) and implementation (P)
cards must complete before status curation (S) and map sync cards in the same round.
Three consecutive rounds have had same-round ordering misses. A single note in the
operating model would close this class of stale-row errors without adding ceremony.

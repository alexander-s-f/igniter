Card: S3-R32-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r32-durable-audit-prop032-and-compiler-profile-pressure-v0

Question:
Did R32 authorize only a bounded production durable audit implementation? Did
PROP-032 Phase 1 Classifier stay within its gate scope and keep evidence-list
validation out? Did the governance sync correctly close all open carry items? Does
compiler_profile_id remain an understanding-only authority with no .igapp migration
and no runtime binding?

Context:
- S3-R32-C1-P: `durable-audit-hash-and-posture-design-amendment-v0.md` —
  Design amendment only; no code. D1: five excluded fields from canonical
  record_hash formally documented (chain.record_hash, signature.signature_value,
  signature.signed_payload_hash, record_id, compliance_posture). Corrects R31
  heading that said "four fields" while the table listed five. D2: compliance_posture
  is stored (auditor-visible snapshot) + derived (authoritative) + mismatch-checked
  (readers/rebuild refuse on mismatch with `audit.record.compliance_posture_mismatch`).
  D3: reader/rebuild implications stated: verify chain+signature first, derive
  posture, compare to stored, refuse rebuild on mismatch, never auto-repair.
  Explicit non-authorization: production deployment, Ledger, Phase 2, BiHistory,
  stream/OLAP, production cache, HSM/KMS, write/replay/compact/subscribe.
  Closes P-37 and P-38. Unblocks B-A/B-B/B-C.
- S3-R32-C2-S: `r32-governance-authority-sync-v0.md` — Curation only. Applies
  all three S3-R31-C2-A follow-up docs: (1) META-EXPERT-013 §VI updated with
  Covenant-first authority note + PROP-032/033/034 queue routing; (2) Covenant
  OQ-Filter-1 marked resolved by S3-R31-C2-A with gate document link; (3) heat
  map Domain 8 authority-split row closed; (4) current-status.md and
  tracks/README.md updated; (5) agent-context.md updated. Closes P-39/P-40.
  Explicit non-authorization: same excluded surfaces as C1-A/C2-A.
- S3-R32-C3-P: `prop032-assumptions-phase1-classifier-implementation-v0.md` —
  Phase 1 only. Gate reference: S3-R31-C5-P (Phase 1 gate satisfied). Changes:
  classifier.rb updated (assumption_registry, uses_assumptions branch, assumption_refs
  on contracts, epistemic fragment class guard after escape before oof fallback,
  OOF-A1 detection). New experiments/assumptions_proof/ directory: 3 fixtures,
  classified goldens, assumptions_proof.rb. No TypeChecker/SemanticIR changes.
  No parser grammar changes. Command matrix: 4 proofs PASS after classifier change
  (assumptions_proof, classifier_pass_proof, contract_modifiers_proof,
  temporal_semanticir_access_node). Evidence-list validation confirmed NOT
  done: epistemic_only_pure fixture carries a future PROP-033-only evidence name
  and Classifier emits no OOF for it. Existing programs do not gain empty
  assumption_refs or assumption_registry fields. PROP-032 not promoted to
  experiment-pass yet (Phase 1 only; Phase 2 gate unblocked by Phase 1 goldens).
- R31-SHADOW: `compiler-profile-authority-boundary-v0.md` — 9/9 PASS.
  compiler_profile_id proves compiler understanding only: authorized surfaces are
  "assembled by a known profile" and "fingerprint-comparable by loaders." Explicitly
  does NOT prove: runtime executor approval, Gate 3, live TBackend binding, Ledger
  read/write/replay, cache key policy, guard_policy. Decision table for 6 cases
  (CORE match, legacy absent, mismatch, TEMPORAL metadata-only, TEMPORAL
  Ledger-backed no approval, TEMPORAL Ledger-backed Gate 3 closed) all correctly
  refuse TEMPORAL execution without full approval+gate+backend chain.
  `compiler_profile_never_authorizes_execution` and `no_backend_or_ledger_calls`
  checks PASS. No .igapp manifest changes.
- R32-SHADOW: compiler profile manifest PROP draft, BootstrapDescriptorKernel,
  self-assembly profile sketch, source lowering target, chain closure index — all
  background-foundation, proof-local, dispatch_mode: shadow, no .igapp changes, no
  runtime execution authority, no production deployment.

---

## Scope Item Review

| Item | Source | Finding | Status |
|------|--------|---------|--------|
| Durable audit hash/posture amendment closed P-37/P-38 | C1-P | Five excluded fields documented with rationale; compliance_posture storage model locked (stored+derived+mismatch-checked); reader/rebuild implications specified | PASS |
| Restart rebuild proof (B-A) landed | — | Not landed in R32; C1-P amendment unblocks it; B-A still open | N/A — open |
| No production deployment | C1-P, C2-S | Explicit non-authorization in both C1-P and C2-S | PASS |
| No Ledger widening | C1-P, C3-P, shadow | C1-P non-auth; PROP-032 Phase 1 is Classifier-only; shadow profiles prove no Ledger calls | PASS |
| No Phase 2 widening | C1-P | Explicit non-auth; shadow TEMPORAL decision table shows Phase 2 still blocked | PASS |
| No BiHistory widening | All | No BiHistory surface referenced or changed in R32 | PASS |
| No stream/OLAP production executor | Shadow | StreamPack and OLAPPack modeled as descriptors only; no execution | PASS |
| No production cache | C1-P, C3-P | Neither card touches cache surfaces | PASS |
| No concrete HSM/KMS | C1-P | Explicit non-auth; shadow proofs reference proof-local signer only | PASS |
| No broad RuntimeMachine binding | Profile authority | `compiler_profile_never_authorizes_execution` PASS; 6 TEMPORAL cases refuse correctly | PASS |
| No .igapp manifest migration | Manifest PROP draft | Draft explicitly "does not update `.igapp` fixtures"; requires PROP number + assembler card before any real change | PASS |
| PROP-032 evidence-list validation stayed out | C3-P | Confirmed: epistemic_only_pure includes PROP-033-only evidence name; no OOF fires; "Evidence-list validation remains PROP-033 scope" | PASS |
| PROP-032 Phase 1 gate authority respected | C3-P | References S3-R31-C5-P gate; changes only authorized Phase 1 surfaces (classifier.rb + assumptions_proof fixtures) | PASS |
| PROP-032 not promoted to experiment-pass | C3-P | Explicit: "Do not promote PROP-032 to experiment-pass yet; CSM, Heat Map, Covenant registry, proposal lifecycle should wait for full pipeline proof" | PASS |
| Governance sync applied all C2-A follow-up docs | C2-S | 5 documents updated; P-39/P-40 closed; round-order improved (C2-S after C3-P in same round) | PASS |
| Compiler profile manifest draft floating without PROP number | Shadow | Draft correctly acknowledges PROP-033 = via profile binding and does not claim that slot; but no PROP number assigned for this feature | ⚠️ NB |
| Shadow proof chain depth (10+ chained proofs) | All shadow | Each shadow proof "refreshes" upstream proofs; no production effect, but one changed assumption invalidates downstream; no index lists required regeneration order | ⚠️ NB |
| "Four fields" heading vs five-field table in R31 C1-P | C1-P amendment | Correctly caught and resolved: "This amendment treats the five-field table as the actual implementation decision and removes the ambiguity" | PASS |

---

## Risk Table

| Risk | Severity | Owner | Notes |
|------|----------|-------|-------|
| B-A (restart rebuild) still open | Medium | Implementation Agent | P-37/P-38 now closed; path clear. But each round that passes without B-A increases distance from the compliance posture proof that B-A should verify against. The mismatch-check requirement (D2/D3) in C1-P is new — the eventual restart rebuild proof must include an explicit mismatch-detection case, not just a happy-path rebuild. |
| Compiler profile manifest draft without PROP number | Low–Medium | Architect / Meta Expert | `compiler-profile-manifest-prop-draft-v0.md` is a substantive draft proposing `compiler_profile_id` participation in artifact hash material. Without a formal PROP number it cannot enter the acceptance gate, but it could be referenced by future tracks as if it were canonical. The PROP-033/034/035 queue is already assigned; the manifest PROP needs a slot beyond that (likely PROP-036 or assigned after Effect Surface). |
| Shadow proof chain: chained refresh calls | Low | Research Agent | Seven or more background-foundation proofs form a dependency chain (`igniter_lang_self_assembly_profile_sketch` refreshes `compiler_profile_preflight_chain_index` refreshes earlier proofs). A change to any upstream proof requires regenerating all downstream ones. No index documents the required order or lists which proofs depend on which. Acceptable at shadow scale, but should be documented before any real migration begins. |
| PROP-032 Phase 2 not yet started | Informational | Compiler/Grammar Expert | Phase 1 goldens exist (assumption_basic.classified.json, epistemic_only_pure.classified.json, oof_a1_undeclared_assumption.classified.json). Phase 2 TypeChecker gate (from S3-R31-C5-P) requires these goldens — they are now present. Phase 2 is unblocked but not started. Not a blocker; informational for R33 routing. |
| Existing programs: `assumption_refs`/`assumption_registry` absence | Low | Compiler/Grammar Expert | C3-P intentionally omits these fields from programs without assumptions at Phase 1. The Phase 3 SemanticIR will add `assumption_refs: []` as a default field, triggering a golden file regeneration event (documented in gate review). The asymmetry between Phase 1 classified output (absent field) and Phase 3 semantic_ir output (empty field) is intentional and documented. Not a risk now; should be verified during Phase 3 card. |

---

## Pre-Production Checklist Update

| Item | Prev status | R32 disposition |
|------|-------------|-----------------|
| P-37: C1-P D1 canonical hash excluded fields | open (R31) | ✅ **CLOSED** — C1-P five-field algorithm documented with rationale |
| P-38: C1-P Q2 compliance_posture storage model | open (R31) | ✅ **CLOSED** — C1-P D2: stored+derived+mismatch-checked; D3: reader/rebuild rules |
| P-39: Heat map Domain 8 OQ-Filter-1 row + Covenant close | open (R31) | ✅ **CLOSED** — C2-S applied heat map + Covenant OQ-Filter-1 + current-status |
| P-40: META-EXPERT-013 §VI Covenant authority note | open (R31) | ✅ **CLOSED** — C2-S updated META-EXPERT-013 §VI with Covenant-first note |
| B-A: Restart rebuild proof (surface 4 of C1-A) | open (R31) | **still open** — C1-P unblocks; proof card not yet issued |
| B-B: Audit traversal / reader proof (surface 6 of C1-A) | open (R31) | **still open** |
| B-C: Appender / reader role boundary proof (surface 7 of C1-A) | open (R31) | **still open** |
| B-D: Post-implementation full regression matrix (surface 9 of C1-A) | open (R31) | **still open** |
| P-41 (new): Compiler profile manifest PROP number assignment | — | **open** — draft exists; PROP number needed before acceptance gate |
| P-42 (new): PROP-032 Phase 2 TypeChecker OOF-A1 propagation | — | **open** — Phase 1 goldens now exist; Phase 2 gate unblocked |

---

[Agree]
- C1-P closes both P-37 and P-38 using the pattern established by C4-P in R31
  (Research Agent reads the proof track, confirms the implementation decision,
  amends the design document). The five-field algorithm is now correctly
  documented with per-field rationale. The compliance_posture model is well-
  specified: stored (auditor snapshot), derived (authoritative), mismatch-checked
  (failure code). Critically, the "never auto-repair" rule in D3 is the right
  position for an append-only audit system — silent repair would be a correctness
  hole in the audit chain.
- C2-S closes P-39 and P-40 correctly. The round-ordering improvement is notable:
  C2-S applied C2-A follow-ups in the same round as the Classifier implementation
  card, avoiding the stale-row pattern that plagued R30/R31 curation. The five
  updated files (META-EXPERT-013, Covenant, heat map, current-status, agent-context)
  are the complete set listed in C2-A §Required Follow-Up Docs.
- C3-P Phase 1 Classifier is correctly bounded. The evidence-list check is the
  critical test: `epistemic_only_pure` deliberately includes a future PROP-033-only
  evidence name, and the proof confirms zero OOF fires for it. This is stronger
  than an assertion — it is a golden-file-anchored regression test that will catch
  any future accidental evidence-list validation from creeping into Phase 1 code.
- The compiler_profile_id authority boundary (R31-SHADOW) uses a decision table
  structure that forces every case to be explicit about what is and is not granted.
  Having `temporal.ledger_backed_still_requires_approval` and
  `temporal.ledger_backed_gate3_closed_refuses` as named checks means the boundary
  is proof-verifiable, not just prose.
- The compiler profile manifest PROP draft correctly declines to claim PROP-033
  and notes the queue conflict. The migration order (6 steps) and the implementation
  cards list are appropriately sequenced — no step assumes the previous is done
  without a formal card.

[Challenge]
- C-1: B-A (restart rebuild) is the critical missing proof for the durable audit
  implementation track. C1-P correctly states it "unblocks" restart rebuild, but
  four rounds have now passed since C1-A was issued without B-A landing. Each
  additional round increases the distance between the hash/posture design (now
  in C1-P amendment) and the implementation proof that would validate it. The
  restart rebuild proof specifically needs to exercise the new mismatch-check
  requirement (D2/D3) — a case where stored compliance_posture ≠ derived
  compliance_posture should refuse cursor rebuild with
  `audit.record.compliance_posture_mismatch`. If B-A is deferred much further,
  the mismatch check becomes an undocumented assumption with no proof coverage.

- C-2: The compiler profile manifest PROP draft (`compiler-profile-manifest-prop-draft-v0.md`)
  proposes that `compiler_profile_id` must participate in artifact hash material
  before signing. This is a one-way ratchet: once the field participates in the
  hash, ALL existing `.igapp` golden files must be regenerated (since artifact_hash
  will change). The draft lists this in the migration order (step 4: "Regenerate
  artifact hashes and goldens intentionally"), but it does not flag this as a
  production-breaking change for anyone consuming `.igapp` artifacts today. The
  draft is floating without a PROP number, which means it cannot be rejected or
  constrained by the acceptance gate — it exists as an implicitly growing design
  assumption in the shadow proof chain.

- C-3: C3-P intentionally omits empty `assumption_refs` and `assumption_registry`
  fields from programs without assumptions at Phase 1. This was the correct
  decision to avoid golden file regeneration in Phase 1. But the Phase 3 SemanticIR
  card (when it lands) will add `assumption_refs: []` as a default field to every
  `contract_ir`. At that point, ALL existing `.semantic_ir.json` golden files will
  need regeneration — not just the new assumptions proof goldens. C5-P (R31)
  documented this as a "golden file regeneration event" requiring an "atomic card."
  The risk is that the TypeChecker and SemanticIR implementation cards for PROP-032
  might be split across rounds, leaving a half-migrated state where some goldens
  have `assumption_refs` and some do not. The atomic-card requirement should be
  explicit in the Phase 3 implementation card template.

[Missing]
- M-1: A B-A (restart rebuild) implementation card. P-37/P-38 are both closed;
  the hash algorithm and compliance_posture model are documented; D3 specifies
  exactly what restart rebuild must do. The prerequisites are fully met. The card
  just needs to be issued. It should include an explicit case for the mismatch-check
  failure path (`audit.record.compliance_posture_mismatch` fires during rebuild
  when stored posture ≠ derived posture).

- M-2: A PROP number decision for the compiler profile manifest feature. The draft
  track exists, the proposal model is clear, the proof chain is built. But without
  a PROP number it cannot enter the formal acceptance lifecycle. Given the current
  queue (PROP-033 = via profile binding, PROP-034 = output evidence syntax,
  PROP-035 = profile/authority declarations, Effect Surface after that), the
  manifest PROP likely lands at PROP-036 or later. An Architect decision card or
  Meta Expert curation pass should assign the number and add it to proposals/README.md.
  Until that happens, the manifest draft will continue accumulating proof-local
  design decisions (hash participation, loader policy, migration order) that cannot
  be formally challenged or rejected.

- M-3: A dependency map (or index entry) for the shadow proof chain. The
  background-foundation tracks form a tree with `igniter_lang_self_assembly_profile_sketch`
  at the top. If any node is modified, the regeneration order must be known. The
  `compiler-profile-chain-closure-index-v0.md` (R33) may address this — but it
  should also document which proofs are mutual dependencies vs. independent.

[Sharper Question]
- When restart rebuild (B-A) runs the mismatch-check case, does it refuse cursor
  rebuild and preserve the stored record as-is (append-only guarantee), or does it
  refuse the entire rebuild and mark the store as corrupt? The C1-P D3 rule says
  "never auto-repair or overwrite stored posture during rebuild" — but it does not
  specify whether the rebuild cursor stops at the mismatched record or aborts the
  full scan.

[Route]
- PROCEED (non-blockers only)
- P-37/P-38/P-39/P-40 all CLOSED in R32.
- B-A/B-B/B-C/B-D still open; B-A is now fully unblocked.
- PROP-032 Phase 2 TypeChecker gate unblocked by Phase 1 goldens.
- Compiler profile manifest PROP number assignment needed before acceptance gate.
- R33 recommendation below.

---

## Verdict

**PROCEED** — no blocking conditions for R33.

All four core R32 pre-production checklist items (P-37 through P-40) are closed.
PROP-032 Phase 1 Classifier is implemented with all required gates satisfied and
no scope creep (no TypeChecker/SemanticIR changes, no evidence-list validation,
no PROP promotion). compiler_profile_id remains compiler-understanding-only as
proven by the authority boundary proof. No widening into any excluded surface.

Two new items (P-41/P-42) and B-A are the primary R33 targets.

## R33 Recommendation

**Priority 1 — Restart rebuild proof (now unblocked):**

1. [Implementation Agent] B-A restart rebuild proof: verify hash/chain first,
   derive compliance_posture, compare to stored, refuse rebuild on mismatch with
   `audit.record.compliance_posture_mismatch`. Must include explicit mismatch case.
   Clarify in the card whether rebuild cursor stops at mismatch or aborts full scan
   (answers the Sharper Question above). (Surface 4 of C1-A.)

**Priority 2 — PROP-032 Phase 2 TypeChecker:**

2. [Compiler/Grammar Expert] PROP-032 Phase 2 TypeChecker: OOF-A1 propagation
   from classified `oof_log` → `type_errors`; `assumption_refs` passthrough;
   strength range check (§5.5). Phase 2 gate unblocked by Phase 1 goldens from
   C3-P. Include Phase 3 SemanticIR in the same card if possible (atomic golden
   regeneration is required for SemanticIR anyway). (Closes P-42.)

**Priority 3 — PROP number for manifest feature:**

3. [Architect / Meta Expert] Assign PROP number for compiler_profile_id manifest
   feature. Likely PROP-036 (after Effect Surface, which may need PROP-035 or
   PROP-036 depending on queue). Update proposals/README.md. Once numbered, the
   draft can enter the formal acceptance gate. (Closes P-41.)

**Priority 4 — Remaining bounded audit surfaces (in parallel with Priority 1/2):**

4. [Implementation Agent] B-B audit traversal / reader proof (surface 6 of C1-A).
   Note: reader must re-derive compliance_posture for every returned record (D3).

5. [Implementation Agent] B-C appender / reader role boundary proof (surface 7
   of C1-A). May run in parallel with B-B.

6. [Implementation Agent] B-D post-implementation full regression matrix (surface
   9 of C1-A). Must pass before follow-up Architect production deployment review.

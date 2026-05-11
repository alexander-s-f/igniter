# Discussion: R36 B-E Deployment, PROP-032 Experiment-Pass, PROP-036/037 Authoring, and Mundane Pressure

Card: S3-R36-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r36-deployment-prop032-prop036-prop037-mundane-pressure-v0
Date: 2026-05-11

---

## Context

Seven R36 items reviewed, including one R35 sidecar that received a disposition in R36.

| Track / Gate | Card | Role | Status |
|---|---|---|---|
| `durable-audit-b-e-deployment-review-decision-v0` (gate) | S3-R36-C1-A | Architect Supervisor | approved-restricted-phase1-production-durable-audit-deployment-scope |
| `prop032-assumptions-experiment-pass-decision-v0` (gate) | S3-R36-C2-A | Architect Supervisor | experiment-pass |
| `stage3-round36-status-preflight-sync-v0` | S3-R36-C3-S | Meta Expert | done |
| `prop037-external-progression-proposal-authoring-v0` | S3-R36-C4-P | Compiler/Grammar Expert | done |
| `prop036-loader-status-report-proof-v0` | S3-R36-C5-P | Compiler/Grammar Expert | done |
| `mundane-stdlib-and-oof-signal-extraction-v0` | S3-R36-C6-P | Research Agent | done |
| `mundane-application-pressure-analysis-v0` (R35 sidecar) | S3-R35-SIDECAR | Architect Supervisor | routed-pressure-specimen |

---

## Scope Item Review

| Item | Scope check | Result | Notes |
|------|-------------|--------|-------|
| B-E did not authorize Ledger / Phase 2 / BiHistory / cache / broad RuntimeMachine | C1-A explicit exclusions list: Ledger adapter, Ledger reads/writes/replay/compact/subscribe, Phase 2, BiHistory, stream/OLAP, production cache, broad RuntimeMachine, broad query/analytics, production authority registry, concrete HSM/KMS, .igapp/.ilk changes, Gate 3 widening, TBackend binding | PASS | Exclusion list is comprehensive and explicit |
| Production durable audit scope is explicit and bounded | C1-A has 8 named authorized surfaces, each with its own "may/must not" sub-sections; 7 required follow-up items before operational rollout | PASS | Authorization ≠ operational go-live; see Risk R-1 |
| PROP-032 experiment-pass did not absorb PROP-033 evidence validation or runtime receipts | C2-A explicit exclusions: "PROP-033 evidence-list validation", "treating parsed evidence [...] names as validated compiler evidence", "runtime receipt propagation", "runtime injection of assumption values"; `evidence [...]` named as "present but unvalidated" | PASS | The downstream agent warning is explicit |
| PROP-037 proposal did not authorize parser / runtime / fragment class | C4-P non-auth in handoff: "no parser, TypeChecker, SemanticIR, RuntimeMachine, Ledger/TBackend, durable queue/checkpoint, production execution, ProgressionPack migration, or new PROGRESSION fragment class" | PASS | `external_event` vocabulary question from C4-A answered: closed vocabulary at v0 level; extension via profile/runtime sub-specialization |
| PROP-036 loader-status proof did not mutate real .igapp / goldens or production loader | C5-P: "proof uses synthetic in-memory manifests only"; proof output carries `real_manifest_mutation: false`, `production_loader_implementation: false`; `scope.no_real_manifest_mutation` and `scope.no_production_loader` PASS checks explicit | PASS | |
| Mundane pressure extraction stayed non-canonical | C6-P explicit non-canon statement; S3-R35-SIDECAR disposition: "not canon", "not implementation evidence"; no parser/stdlib/runtime/Effect Surface authorization; follow-up cards are extraction/fixture/design only | PASS | |
| Status sync removed R35 stale planning state | C3-S before/after table: PROP-036 accepted, PROP-037 assigned, PROP-038+ managed recursion, PROP-032 experiment-pass, B-E deployment scope approved; C2-S supersession note added | PASS | |
| C2-A follow-up items 3 + 4 (heat map + Ch2) | C3-S updated current-status.md and tracks/README.md; no confirmation that heat map assumptions rows or Ch2 source grammar sync were applied | **NB** | P-50 added; see Risk R-2 |
| Temporal audit pressure specimens disposed | S3-R35-SIDECAR covered mundane-application-pressure-v0/; temporal-audit-pressure-v0/ specimens (3 files committed in R35) have no disposition track | **NB** | P-52 added; see Risk R-3 |
| Deployment implementation card scheduled | C1-A authorizes scope; requires 7 follow-up items before operational rollout; no R36 card names or schedules this deployment card | **NB** | P-51 added; see Risk R-1 |

---

## Risk Table

| # | Risk | Severity | Owner |
|---|------|----------|-------|
| R-1 | C1-A authorizes the restricted deployment scope but requires 7 concrete follow-ups before operational rollout (production storage identity config, signer abstraction config, startup rebuild behavior, appender/reader role wiring, refusal code export, rollback/disable procedure, post-deployment smoke proof). No R36 card schedules this follow-up deployment implementation card. Without a named R37 card, the authorized scope will sit "approved-in-principle" with no operational path. This is the same floating-assumption risk that was resolved for compiler profile by assigning a PROP number. | Medium | Architect / Implementation Agent |
| R-2 | C2-A follow-up items 3 and 4 are not confirmed applied. Item 3: heat map — "update assumptions rows from partial/proof to experiment-pass where appropriate." Item 4: Ch2 source surface — "add bounded source grammar for `assumptions {}` and `uses assumptions NAME`." C3-S updated current-status.md and tracks/README.md but does not mention heat map or Ch2 edits. If these were applied by C2-A or another R36 card, there is no cross-reference. If they were not applied, the heat map and Ch2 reflect a stale PROP-032 status. | Low | Meta Expert |
| R-3 | Three temporal audit pressure specimen files (`igniter-financial-audit-time-travel-v1.ig`, `igniter-logistics-what-if-simulation-v1.ig`, `igniter-patient-medical-history-v1.ig`) were committed at the end of R35 under `experiments/pressure-specimens/temporal-audit-pressure-v0/`. The S3-R35-SIDECAR disposition covers only `mundane-application-pressure-v0/`. C6-P reads only mundane specimens. The temporal audit specimens currently have no disposition track — no explicit "non-canonical, route via extraction" statement, no analysis, no named route. Unlike the mundane specimens which are now formally labeled and extraction-mapped, the temporal specimens are unaddressed. | Low | Meta Expert / Architect |
| R-4 | PROP-037 is now authored-pending-review but has no acceptance gate in R36. C4-P handoff says "Architect/Meta review can accept, amend, or defer PROP-037." Without an R37 acceptance card, the proposal will remain in limbo the same way PROP-036 did between authoring (R34-C5-P) and acceptance (R35-C3-A). That was one round. If R37 does not include a PROP-037 acceptance card, P-47 pattern repeats. | Low | Architect |
| R-5 | C5-P's 8-item implementation blocker list (before any PROP-036 implementation card) slightly extends C3-A's 7-item list — C5-P adds item 8: "keep compiler dispatch migration and RuntimeMachine binding out of scope unless separately authorized." This is appropriate defensive expansion. However the blocker count difference (7 in C3-A vs 8 in C5-P) could confuse a future card author who counts items from C3-A and misses the C5-P addition. The next design/proof card should cite both C3-A and C5-P as the blocker authority. | Low | Compiler/Grammar Expert |

---

## Pre-Production Checklist Update

| Item | Status | Closed by |
|------|--------|-----------|
| P-47: PROP-032 experiment-pass governance decision | ✅ **closed** | S3-R36-C2-A — accepted for bounded compiler surface; OOF-A1/P28/TASSUMP-1 accepted; PROP-033 excluded |
| P-48: C4-A doc sync — proposals/README.md + current-status.md + PROP-037 assignment | ✅ **closed** | S3-R36-C3-S (current-status, tracks/README, supersession note) + S3-R36-C4-P (proposals/README PROP-037 authored-pending-review) |
| P-49: C2-S curation stale on PROP-036/PROP-037 | ✅ **closed** | S3-R36-C3-S — supersession note added to C2-S; before/after table reconciled |
| P-50 (NEW): C2-A follow-up items 3 + 4 — heat map assumptions rows and Ch2 source grammar bounded sync for `assumptions {}` | 🔲 open | Meta Expert; confirm whether applied by C2-A or pending |
| P-51 (NEW): Deployment implementation card — C1-A authorizes scope; 7 required follow-ups must be delivered in a named deployment card before operational rollout | 🔲 open | Architect / Implementation Agent |
| P-52 (NEW): Temporal audit pressure specimen disposition — `temporal-audit-pressure-v0/` specimens lack a disposition track; need explicit non-canonical labeling and extraction route comparable to S3-R35-SIDECAR | 🔲 open | Meta Expert / Architect |

---

## [Agree]

- **C1-A B-E authorization scope is explicit and correctly staged.** The eight authorized surfaces are each bounded with "may" and "must not" clauses. The hard firewall on concrete HSM/KMS is correct: signing abstraction boundary is authorized; concrete provider onboarding is a separate card. The required follow-up list (7 items) correctly converts the authorization into a checklist for the deployment implementation card rather than implying operational readiness. The "approved-restricted-phase1-production-durable-audit-deployment-scope" status phrase itself signals bounded scope. The 12 excluded surfaces (including Ledger, Phase 2, BiHistory, broad RuntimeMachine, stream/OLAP) are all confirmed closed.

- **C2-A PROP-032 experiment-pass is correctly bounded.** The accepted surface is precise: named compiler pipeline stages (parser, classifier, typechecker, SemanticIR), named OOF codes, named SemanticIR shape. The `evidence [...]` parsed-but-unvalidated note is the most important safety: downstream agents are explicitly told the AST field is present but has no semantic authority until PROP-033. The full Stage 3 regression note from R35 is addressed as "non-blocking for this experiment-pass" with a follow-up requirement before downstream implementation depends on PROP-032 beyond the assumptions experiment.

- **C3-S preflight sync is thorough and correctly non-authorizing.** Before/after table covers all six stale-to-current transitions. The supersession note on C2-S prevents future agents from using stale R36 recommendations. The decision not to edit proposals/README.md (because it was already correct) is verified, not assumed. C3-S's discovery of already-landed C1-A and C2-A gate evidence and syncing to the later authority rather than the stale C2-S recommendations is the correct operating model.

- **C4-P PROP-037 authoring is correctly scoped.** The `external_event` vocabulary decision answers the C4-A follow-up question with a clear model: top-level vocabulary is closed at v0; `external_event` is the extension point for profile/runtime specialization; a new top-level `source_kind` needs a later proposal. This is the right conservative posture. OOF-PR5 severity as error for service/infinite progression (with explicit carve-out for softer profile-specific rules requiring authorization) is correct. The implementation blockers section lists decisions that must follow acceptance rather than being made in the authoring card.

- **C5-P PROP-036 loader proof is correctly constrained.** Five status cases cover the full PROP-036 status vocabulary. The `future_missing_required` case carries an explicit `model_scope: "future_policy_model_only"` and `profile_required_rollout_authorized: false` — correctly modeling the policy without authorizing rollout. The 15 PASS checks include `scope.no_real_manifest_mutation`, `scope.no_production_loader`, `scope.non_authorizations_preserved`. The `present_verified` not-runtime-ready firewall is verified in the matrix.

- **C6-P mundane signal extraction is non-canonizing and high-signal.** The extraction table clearly separates OOF candidates (3 named with OOF-MA1/MA2/MA3 codes) from stdlib pack candidates, type vocabulary drift, syntax pressure, and future proposal items. The follow-up cards are specifically extraction/fixture/design — not implementation. The non-canon statement is front-loaded. The profile preset pressure (external agents defaulting to bitemporal/evidence-heavy because no lightweight preset exists) is a useful language-ergonomics signal that needs a profile proposal lane, not a spec change.

---

## [Challenge]

- **C2-A follow-up items 3 and 4 are unconfirmed.** C2-A lists four follow-up docs to sync: (1) current-status.md, (2) tracks/README.md, (3) heat map assumptions rows to experiment-pass, (4) Ch2 source grammar bounded sync. C3-S confirms items 1 and 2 were applied. But C3-S does not mention the heat map or Ch2. Neither C1-A, C4-P, C5-P, nor C6-P mention applying these edits. If they were applied by the same round as C2-A authoring (possible if C2-A applied its own follow-ups), there is no cross-reference in any R36 track. If they were not applied, the heat map and Ch2 have stale PROP-032 state. This is not a scope hazard — it's a doc debt gap — but it is the second consecutive round where C2-A-style follow-up items are only partially confirmed.

- **C1-A authorized scope but has no named deployment card.** The authorization decision is the gate. But C1-A explicitly requires 7 items before "operational rollout." None of these 7 items are delivered by any R36 card. Without a named R37 deployment implementation card, the authorization result is "approved scope, zero operational path." The pattern from PROP-036 suggests this can sit for multiple rounds without progress unless a card is explicitly scheduled. P-51 tracks this, but P-51 without a named owner and card in R37 will drift.

- **Temporal audit pressure specimens have no disposition.** The S3-R35-SIDECAR track addresses mundane application pressure specimens. Three temporal audit pressure specimen files committed in R35 (`temporal-audit-pressure-v0/`) are not addressed by any R36 track. C6-P reads from `mundane-application-pressure-v0/` only. The temporal specimens are in the repo without an explicit "non-canonical, route via extraction" statement. Until they receive a disposition analogous to S3-R35-SIDECAR, they are technically undisposed repository artifacts.

---

## [Missing]

- **No R36 card for the full Stage 3 language regression matrix.** C2-A flags the R35 pressure non-blocker: "before any downstream implementation depends on PROP-032 beyond the assumptions experiment, rerun a broad Stage 3 regression matrix that includes temporal, stream, classifier, typechecker, SemanticIR, and assumptions fixtures together." This is now a named follow-up requirement from an experiment-pass gate, which gives it more weight than the original R34 non-blocker. No R36 card provides or schedules this matrix.

- **PROP-037 acceptance gate not in R36.** PROP-037 is now authored-pending-review. The pattern from PROP-036 (authored R34-C5-P, accepted R35-C3-A) was one round. If R37 does not include a PROP-037 acceptance card, the proposal enters limbo.

- **No explicit confirmation that proposals/README.md PROP-037 update is consistent with C3-S's verified state.** C3-S verified proposals/README.md with PROP-037 as "assigned numbering-only." Then C4-P updated proposals/README.md to "authored-pending-review." C3-S found the file correct before C4-P ran. The cumulative state after both operations should be correct (PROP-037 authored-pending-review, PROP-038+ managed recursion placeholder), but neither C3-S nor C4-P explicitly confirms the final proposals/README.md state after both operations.

---

## [Sharper Question]

- **For C1-A:** The authorized deployment scope includes "signing abstraction boundary" and "production deployment with a configured signer abstraction only if it rejects nil/no-op/stub/local-test identities." Does the deployment implementation card need to provide a proof that the configured signer satisfies these requirements before deployment authorization is considered operational? Or is the C1-A authorization itself sufficient for the deployment card to proceed without a separate signer acceptance test?

- **For C2-A:** The experiment-pass accepted `grammar_version: "assumptions-v0"` as a parser output tag. As PROP-032 evolves (PROP-033 evidence validation, potential future amendments), does `grammar_version` need to be versioned at the proposal level, or is it the parser's internal tracking? If PROP-033 adds evidence validation to the assumptions pipeline, must the grammar_version advance to "assumptions-v1" or remain "assumptions-v0" until a parser grammar change?

- **For C4-P:** PROP-037 defines `external_event` as the extension point where profiles/runtimes specialize `source_ref`, `payload_type`, authority, and capability metadata. Does a profile-level specialization of `external_event` require a PROP errata, a new proposal, or can it happen through the profile/capability descriptor system without formal language governance? The answer determines whether `http_listener.on_request` needs its own PROP before production use.

---

## [Route]

**R37 recommendation (priority order):**

1. **[Meta Expert] P-50 + P-52**: Confirm or apply C2-A follow-up items 3 and 4 (heat map assumptions rows to experiment-pass; Ch2 bounded source grammar for `assumptions {}` / `uses assumptions NAME`). Also author a temporal audit pressure specimen disposition track (comparable to S3-R35-SIDECAR) for `temporal-audit-pressure-v0/`. Both are doc/curation only.

2. **[Architect / Implementation Agent] P-51 deployment card**: Open a deployment implementation card citing C1-A as authorization. Must provide all 7 required follow-ups: production storage identity config, signer abstraction config with refusal behavior, startup rebuild verification, appender/reader role wiring, refusal code export, rollback/disable procedure, post-deployment smoke proof. Must not widen excluded surfaces. Concrete HSM/KMS provider onboarding requires a separate provider onboarding addendum.

3. **[Architect / Meta Expert] PROP-037 acceptance gate**: PROP-037 is authored-pending-review. Issue acceptance, conditional-acceptance, hold, or rejection. Must confirm whether the closed v0 `source_kind` set and OOF-PR5 error severity are the correct initial shape. Acceptance should not authorize parser, SemanticIR, RuntimeMachine, or production execution.

4. **[Compiler/Grammar Expert] Full Stage 3 language regression matrix**: Named by C2-A as a non-blocking follow-up requirement before downstream PROP-032 implementation. Should cover temporal, stream, classifier, typechecker, SemanticIR, and assumptions fixtures together. Required before any PROP-032-adjacent implementation card that uses assumptions as a dependency.

5. **[Compiler/Grammar Expert] PROP-036 next design/proof card**: `prop036-artifact-hash-ordering-proof-v0` — prove using synthetic/proof-local material that `compiler_profile_id` participates in hash material before signing. Must not mutate real `.igapp` goldens or production artifact output. Must cite both C3-A and C5-P as blocker authority (8-item list).

6. **[Compiler/Grammar Expert] Mundane OOF fixture planning**: `mundane-oof-fixture-plan-v0` — design minimal OOF fixtures for OOF-MA1 (ambient context in pure), OOF-MA2 (pure-with-escape), OOF-MA3 (filesystem metadata as pure). No compiler implementation yet.

---

## Verdict

**PROCEED — non-blockers only.**

R36 correctly closed all primary scope items. B-E authorization scope is explicit with 12 named exclusions and a 7-item operational follow-up requirement. PROP-032 experiment-pass correctly excludes PROP-033 and treats `evidence [...]` as parsed-but-unvalidated. PROP-037 stays proposal-only with no parser/runtime/fragment class authority. PROP-036 loader proof used synthetic manifests with `real_manifest_mutation: false` confirmed. Mundane signal extraction is non-canonical with a structured extraction backlog. R35 stale state is superseded by C3-S with an explicit before/after reconciliation table.

Three non-blocker gaps: C2-A heat map and Ch2 follow-ups unconfirmed (P-50), no named deployment implementation card (P-51), temporal audit pressure specimens undisposed (P-52). Production deployment remains pending the 7-item C1-A follow-up delivery.

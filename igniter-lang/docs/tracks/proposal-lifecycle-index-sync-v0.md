# Track: Proposal Lifecycle Index Sync v0

Card: S3-R6-C8-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: `igniter-lang/proposal-lifecycle-index-sync-v0`
Status: done
Date: 2026-05-08

Lifecycle policy: META-EXPERT-012

---

## Goal

Synchronize proposal lifecycle/index state with landed Stage 2/3 evidence.
Update `proposals/README.md` and individual PROP file status headers.

No files moved to `accepted/` — that directory is Stage 1 only.

---

## Inputs Read

```text
docs/proposals/README.md                                     (current state)
docs/proposals/PROP-022..025                                 (Stage 2 PROPs)
docs/proposals/PROP-026..028                                 (Stage 2/3 PROPs)
docs/proposals/PROP-022A-temporal-manifest-errata-v0.md     (Stage 3 errata)
docs/meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md  (close authority)
docs/proposals/accepted/README.md                            (accepted/ scope)
experiments/stage2_close_candidate/stage2_close_candidate.json
docs/tracks/temporal-assembler-manifest-contract-index-v0.md (S3-R5-C1)
docs/tracks/prop-022a-temporal-manifest-errata-v0.md         (S3-R4-C2)
```

---

## Evidence Summary

### Stage 2 Close Authority (META-EXPERT-009.1)

META-EXPERT-009.1 records:

```text
"Language model (PROP-022 through PROP-027) fully closed in proof."
```

stage2_close_candidate.json confirms:

```text
✅ History[T] / BiHistory[T]       PROP-022
✅ stream T                        PROP-023
✅ OLAPPoint[T,Dims]               PROP-024
✅ Invariant severity              PROP-025
✅ Parser OOF hardening            PROP-026
✅ Production compiler CLI         PROP-027
✅ TBackend descriptor             PROP-008 (descriptor only)
```

### Stage 3 Partial Implementation (PROP-028)

PROP-028 TEMPORAL fragment class has accumulated substantial implementation:

```text
S3-R2-C2  Classifier + TypeChecker TEMPORAL boundary  ✅
S3-R3-C2  temporal_input_node + temporal_access_node   ✅
S3-R3-C3  CORE vs TEMPORAL cache key proof             ✅
S3-R4-C1  Assembler: temporal nodes → .igapp/          ✅
S3-R4-C5  Proof-local runtime cache                   ✅
S3-R5-C1  manifest.contract_index + fragment_summary   ✅
S3-R5-C2  RuntimeMachine load guard                   ✅
Parser coordinate syntax                               ⏳ not settled
Production runtime execution                          🚫 guarded (Gate 3)
```

Status: `implementation-partial` — majority of the compile pipeline proven;
two open items remain (parser syntax, production execution).

### Stage 3 PROP-022A (Temporal Manifest Errata)

PROP-022A errata spec written in S3-R4-C2; manifest implementation proven in S3-R5-C1.
File existed in `proposals/` but was absent from the README table.

Status: `experiment-pass`

### Stage 1 Deferred Gap: production_compiler_assembly

The Stage 1 deferred gap `production_compiler_assembly` was resolved in Stage 2:
- PROP-027: production compiler CLI + diagnostics contract written and experiment PASS
- S2-R13: compiler packaging skeleton with `IgniterLang::VERSION`, `bin/igc`, package CLI
- S3-R3-C4: `bin/release-gate` PASS; local `.gem/.sha256` built

The gap register entry is now marked RESOLVED in proposals/README.md.

---

## Decisions

[D] Stage 2 PROP status vocabulary: `closed` — consistent with PROP-026/027 precedent.
    Rationale: META-EXPERT-009.1 says "fully closed in proof"; `closed` matches
    the term used at Stage 2 close and is already in the lifecycle enum.

[D] Stage 3 PROP-028 status: `implementation-partial`.
    Rationale: majority of compiler pipeline proven; parser syntax and production
    runtime remain open. Not `closed` because the full authorized scope is not PASS.
    Not `proposal` because substantial implementation evidence exists.

[D] PROP-022A status: `experiment-pass`.
    Rationale: errata PROPs have a narrower scope than full PROPs; manifest
    implementation PASS qualifies as experiment-pass for an errata.
    Not `closed` because formal acceptance ceremony for errata requires
    the amending PROP-028 to close first.

[D] PROP-008 (TBackend) stays `proposal`.
    Rationale: descriptor fixture PASS covers only Part 1 of the TBackend
    contract. The full contract (append, replay, snapshot, subscribe) requires
    Gate 3. Marking closed would be misleading.

[D] `accepted/` remains Stage 1 only. No files moved.
    Rationale: accepted/README.md is explicit: "Frozen effective: 2026-05-06;
    Authorized by: META-EXPERT-007." Stage 2/3 PROPs live in proposals/
    with appropriate status headers.

[D] proposals/README.md restructured into three sections:
    Stage 2 Closed | Stage 3 Active | Stage 2+ Open proposals.
    Rationale: flat single table mixed closed and open PROPs, making status
    ambiguous. Three sections give unambiguous routing.

[D] Lifecycle vocabulary added to proposals/README.md:
    proposal → experiment-pass → implementation-partial → closed
    This is the canonical status enum for proposals/ directory.

---

## Changes Applied

### File status header updates

| File | Before | After |
|------|--------|-------|
| PROP-022 | `proposal` | `closed` + Closed: date + Stage 3 extensions note |
| PROP-023 | `proposal` | `closed` + Closed: date |
| PROP-024 | `proposal` | `closed` + Closed: date |
| PROP-025 | `proposal` | `closed` + Closed: date |
| PROP-026 | `closed` | unchanged (already correct) |
| PROP-027 | `closed` | unchanged (already correct) |
| PROP-028 | `proposal` | `implementation-partial` + evidence block |
| PROP-022A | `proposal errata` | `experiment-pass` + Proven: date + track evidence |

### proposals/README.md restructuring

Before: single "Active Intake (Stage 2+)" table with mixed statuses.

After:
- "Stage 2 — Closed" section: PROP-022..027
- "Stage 3 — Active" section: PROP-028, PROP-022A
- "Stage 2+ — Open Proposals" section: PROP-002/005/005.1/007/008/010/016/017
- Deferred Gaps Register: Stage 1 gap marked RESOLVED; Stage 2 gaps listed
- Lifecycle vocabulary: status enum defined

---

## Remaining Proposal Lifecycle Debt

```text
[PROP-DEBT-01]  PROP-008: partial sub-scope (descriptor) has no formal sub-status.
                When Gate 3 opens, a new errata or PROP-008.1 should capture
                TBackend live binding. Current `proposal` status is correct but
                note the descriptor precedent.

[PROP-DEBT-02]  PROP-028: needs formal close when parser coordinate syntax PASS
                and/or production runtime execution authorized.
                Gate: parser-syntax proposal written + experiment PASS.

[PROP-DEBT-03]  PROP-022A: needs formal close when PROP-028 closes.
                Gate: PROP-028 closure + PROP-022A spec chapter anchor confirmed.

[PROP-DEBT-04]  PROP-002/005/005.1/007/010/016/017: no experiment evidence.
                These are deferred Stage 2+ proposals with no current authorization.
                They require explicit Architect authorization before any experiment
                track is opened. Do not start experiments without governance card.

[PROP-DEBT-05]  No PROP-029 proposal doc yet. PROP-029 is in "Queued" state.
                The proposals/README.md queued table has been updated to reflect
                that PROP-022/025 (depends_on) are now `closed`.

[PROP-DEBT-06]  PROP-026/027 status: `closed` in README and file headers.
                Both experiments PASS. These could be further designated
                `spec-absorbed` once ch4/ch6 spec sync cards execute. No action
                needed now; current `closed` is accurate.
```

---

## Handoff

```text
[Meta Expert]
Card: S3-R6-C8-S
Status: done

[D] Decisions: 7 — see §Decisions above.

[S] Changes:
- PROP-022/023/024/025: Status: proposal → closed (Stage 2 PASS, META-EXPERT-009.1)
- PROP-028: Status: proposal → implementation-partial + evidence block
- PROP-022A: Status: proposal errata → experiment-pass + Proven: date + track refs
- PROP-026/027: already closed; verified unchanged.
- proposals/README.md: 3-section structure; lifecycle vocabulary; deferred gap register;
  PROP-022A added to index; Stage 1 gap marked RESOLVED.

[R] Risks:
- PROP-002/005/007/010/016/017 are still `proposal` with no clear path forward.
  Do not confuse them with active Stage 3 work. They are deferred/backlog PROPs.
- PROP-008 partial scope could mislead a TBackend agent. The inline note
  "descriptor fixture PASS; live binding gated" in the table should prevent this.

[Next]:
- SPEC-DEBT-06 (proposals/README.md → proposals/accepted sync) can now be
  considered done for Stage 2 PROPs (they stay in proposals/ with `closed` status).
- SPEC-DEBT-07 (add PROP-022A to proposals/README.md) is now done.
- Next proposal lifecycle action: when PROP-028 parser syntax proposal is written,
  update PROP-028 from implementation-partial → closed and PROP-022A to closed.
```

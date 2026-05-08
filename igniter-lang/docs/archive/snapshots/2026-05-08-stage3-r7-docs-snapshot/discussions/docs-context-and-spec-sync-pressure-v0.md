# Discussion: Docs, Context, and Spec Sync Pressure

Card: S3-R6-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: docs-context-and-spec-sync-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Will a fresh agent starting from `agent-context` / `current-status` / `spec`
now avoid reconstructing the whole project from scratch?

## Trigger Context

C3–C8 have landed as of S3-R6:

```text
S3-R6-C3-P  spec-ch6-semanticir-temporal-sync-v0        done
S3-R6-C4-P  spec-ch4-temporal-fragment-sync-v0          done
S3-R6-C5-P  spec-ch7-runtime-temporal-cache-sync-v0     done
S3-R6-C6-P  spec-ch5-emit-typed-sync-v0                 done
S3-R6-C7-S  parity-track-stale-header-sweep-v0          done
S3-R6-C8-S  proposal-lifecycle-index-sync-v0            done
```

S3-R6-C1 (`runtime-compatibility-report-temporal-load-check-v0`) and
S3-R6-C2 have not yet landed. The trigger "after C1–C8 land" was interpreted
as: review now against C3–C8 because those are the doc-facing tracks.

---

## Evidence Base

Files read for this review:

```text
igniter-lang/AGENTS.md
igniter-lang/roles/README.md
igniter-lang/roles/*.md
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/spec/ch4-fragment-classification.md
igniter-lang/docs/spec/ch5-compiler-pipeline.md
igniter-lang/docs/spec/ch6-semanticir.md
igniter-lang/docs/spec/ch7-runtime.md
igniter-lang/docs/tracks/parity-track-stale-header-sweep-v0.md
igniter-lang/docs/tracks/spec-stage3-sync-and-doc-compaction-plan-v0.md
igniter-lang/docs/tracks/proposal-lifecycle-index-sync-v0.md
```

---

## [Agree]

**Spec chapters ch4–ch7 are now accurate for Stage 3.**

All four chapters carry `Status: synced … (2026-05-08)`. The content matches
the evidence:

| Chapter | Key addition | Evidence pointer |
|---------|-------------|-----------------|
| ch4 | TEMPORAL as 4th class; node/value split; OOF-TM1–9; BiHistory rules; construct table | S3-R2-C2, PROP-028 |
| ch5 | `emit_typed` as production path; legacy parsed emitter scoped; conformance cases C-1–C-10; public behavior delta table | S3-R5-C4 |
| ch6 | `temporal_input_node`/`temporal_access_node` shapes; `manifest.fragment_summary + contract_index`; `requirements.json` from `escape_boundaries`; `compatibility_metadata.runtime_execution`; L-T1–L-T6 load gates | S3-R4-C1, S3-R5-C1/C2 |
| ch7 | CORE/TEMPORAL/BiHistory cache key schemas; freshness states; `load_accept_evaluate_refuse` guard; L-T1–L-T6 evaluate refusals | S3-R3-C3, S3-R4-C5, S3-R5-C2 |

A fresh agent reading these chapters will get correct Stage 3 information —
no stale "assembler not yet implemented" or "stdlib not yet connected" text
remains. The CRITICAL stale sections from ch6 §6.4–6.5 and ch7 §7.6 are gone.

**`agent-context.md` is clean and well-structured.**

The file successfully does what it claims: compact map, do-not-reread guards,
current horizon diagram, active gates, source-of-truth hierarchy, conflict
rule, ownership reminders, proof budget table. A fresh agent reading it will
understand what is production (`emit_typed`), what is proof-local (temporal
load/cache), and what is closed (TBackend Gate 3, TEMPORAL evaluate).

**Role profiles reflect the three interventions from `agent-role-optimization-v0`.**

All three targeted interventions have landed:

| Intervention | Status |
|-------------|--------|
| C/G Expert: spec stewardship paragraph added | ✅ `compiler-grammar-expert.md` §Spec Stewardship present |
| Research Agent: status consolidation removed | ✅ "not round-close status by default" in profile |
| External Pressure Reviewer: `runtime-pressure` lens added to allowed list | ✅ present in `external-pressure-reviewer.md` and `roles/README.md` neighbor map |

**Parity stale headers done.**

Four tracks now carry `[!IMPORTANT]` stale headers with accurate
current-truth pointers (to S3-R5-C4 and S3-R4-C4). Agents will not mistake
the old blocked verdict or 11-delta state as current Stage 3 truth.

**AGENTS.md is stable and not confused.**

Identity list, write boundary, handoff shape, and non-goal list are correct.
No archaeology trip needed to understand agent identity or workspace rules.

---

## [Challenge]

### C-1. `current-status.md` has no S3-R6 section

S3-R6 C3–C8 have all landed. `current-status.md` still shows Round 5 as the
latest completed round. "Last updated: 2026-05-08" on the file is accurate for
today, but a fresh agent reading the scoreboard sees:

```text
Round 5 landed:
  S3-R5-C1 ... ✅
  ...
Active PROPs: PROP-028 + PROP-022A ...
```

No mention of the six S3-R6 tracks that closed. The scoreboard implies the
spec chapters were never synced. An agent that trusts `current-status.md`
as the authoritative round picture will be confused:

- ch4 says "synced 2026-05-08" but current-status says ch4 has a spec-sync
  card in the recommended next movement list, not in landed evidence.
- ch6 says "synced 2026-05-08" but current-status does not show
  `spec-ch6-semanticir-temporal-sync-v0` as having landed.

This is a one-round lag. Under the conflict rule (`current-status.md` vs
latest track: prefer latest track for exact evidence), a careful agent will
not be broken. But the lag is visible and creates unnecessary reading work.

**Severity**: medium — the source-of-truth hierarchy resolves it, but the
Status Curator pass should have happened before this X1-S discussion fires.

### C-2. `agent-context.md` "Current Next Movement" list is partly stale

The "Current Next Movement" section lists 8 items:

```text
1. runtime-compatibility-report-temporal-load-check-v0
2. descriptor-compatibility-package-consumption-v0
3. typed-emission-post-switch-baseline-v0
4. runtime-temporal-executor-gate3-request-v0
5. gem-release-ci-wiring-v0
6. syntax-thresholds-and-constants-prop-v0
7. syntax-external-pure-helper-signatures-prop-v0
8. invariant-persistence-boundary-v0
```

Items 1–8 reflect the S3-R5 round-close state. S3-R6 C3–C8 completed the
spec sync and stale-header sweep — but this list does not reflect that any
spec-sync work was done. A fresh agent reading this list might believe the
spec chapters are still unsynced and that a spec-sync card is still pending.

The more significant gap: item 3 (`typed-emission-post-switch-baseline-v0`)
is now more urgent than it looks — after the emit_typed switch, this is
the track that would discharge the `invariant_valid` shape delta (see C-3).
The list ordering does not reflect the post-switch urgency.

### C-3. `invariant_valid` shape delta is unresolved and not visible in spec

ch5 §5.7 lists conformance case C-8:

```text
C-8  invariant severity source -> typed path emits invariant lowering
```

This implies the typed path correctness for invariant lowering is confirmed.
It is not. The parity baseline shows:

```text
invariant_valid: FAIL
baseline_signal: "typed path lowers invariant_node; parsed legacy shape differs"
```

This is not a pure parsed-OOF vs typed-ok case — it is a **shape difference**
case. Whether any consumer of the parsed-path `invariant_node` shape is broken
by the typed-path shape was not confirmed before the orchestrator switch. The
`invariant-typed-shape-discharge-v0` track (routed from S3-R5-X1-S) has not
landed.

Consequence: ch5 C-8 implies a conformance guarantee that has not been
discharged. A fresh agent writing a new invariant-related proof track will
read "typed path emits invariant lowering" and assume this is proven correct —
not that it is a shape-delta case pending explicit discharge.

**Severity**: medium — the parity baseline record exists, but ch5 does not
qualify C-8 as open/unverified.

### C-4. `spec-entrypoint-sync-v0` still shows as open in current-status

```text
S3-R1-C... spec-entrypoint-sync-v0: open
```

This item has been carried open from S3-R1 through S3-R6 without progress
or formal deferral. A fresh agent reads this and sees an open task with no
explanation of why it never landed. Is it blocked? Deprioritized? Replaced
by other work?

Without a status update (either "deferred — blocked on parser syntax canon"
or "merged into spec-stage3-sync plan" or "closed — no longer needed"),
this becomes a perpetual open question that wastes archaelogy time.

### C-5. S3-R6-C1 and C2 not reflected anywhere

The trigger says "Run after C1-C8 land." C1
(`runtime-compatibility-report-temporal-load-check-v0`) and C2 are not yet
done. There is no track document for them, no status in `current-status.md`,
and no note in `agent-context.md` that they are still pending vs. that they
were intentionally dropped or rescheduled.

A fresh agent assigned to "do the next available S3-R6 track" has no way to
know that C1 and C2 are still open without scanning the "Current Next
Movement" list in `agent-context.md` and cross-referencing with landed tracks.
That scan is archaeology-level work.

---

## [Missing]

### M-1. Status Curator pass for S3-R6

`current-status.md` needs a Round 6 section. At minimum:

```text
Round 6 landed:
  S3-R6-C3-P: spec-ch6-semanticir-temporal-sync-v0  ✅ ch6 synced: temporal nodes + manifest + guard
  S3-R6-C4-P: spec-ch4-temporal-fragment-sync-v0    ✅ ch4 synced: TEMPORAL as 4th class + OOF-TM rules
  S3-R6-C5-P: spec-ch7-runtime-temporal-cache-sync-v0 ✅ ch7 synced: cache key schema + load guard
  S3-R6-C6-P: spec-ch5-emit-typed-sync-v0           ✅ ch5 synced: emit_typed production path
  S3-R6-C7-S: parity-track-stale-header-sweep-v0    ✅ stale headers on 4 superseded parity/cache tracks
  S3-R6-C8-S: proposal-lifecycle-index-sync-v0      ✅ PROP status headers updated
```

Without this, the scoreboard contradicts the file system.

### M-2. `agent-context.md` "Current Next Movement" refresh

After the Round 6 Status Curator pass, `agent-context.md` "Current Next
Movement" should be updated to reflect:

- spec-sync cards (C3–C8) are complete — not in the pending queue
- `typed-emission-post-switch-baseline-v0` / `invariant-typed-shape-discharge-v0`
  is now a higher priority (C-3 above)
- C1 (`runtime-compatibility-report-temporal-load-check-v0`) and C2 are
  still open; should be explicit in the movement list

### M-3. ch5 §5.7 C-8 qualification

Case C-8 ("invariant severity source → typed path emits invariant lowering")
should carry a note:

```text
C-8  invariant severity source -> typed path emits invariant lowering
     ⚠️ shape parity with parsed path not yet discharged — see
        parity baseline (typed_emission_main_path_parity) and
        invariant-typed-shape-discharge-v0 routing from S3-R5-X1-S
```

Or: the `invariant-typed-shape-discharge-v0` track should land before C-8 is
stated as a conformance case without qualification.

### M-4. `spec-entrypoint-sync-v0` disposition

This item needs one of:
- **deferred**: note why (blocked on parser syntax canon, not current priority)
- **merged**: note that it was absorbed into the spec-stage3-sync plan
- **closed**: note explicitly if no longer needed

It should not remain an open open item with no status through S3-R7.

---

## [Sharper Question]

Not: "Is the doc context now safe for fresh agents?"

The spec chapters are accurate and the role profiles are correct. The question
is resolved at the spec level.

The sharper question is:

> **Does `current-status.md` still provide the fastest accurate start for a
> fresh agent, or does the one-round lag mean the agent will spend time
> resolving contradictions between the scoreboard and the file system?**

Proposed answer: the one-round lag is the primary remaining risk. It is
low-cost to fix (Status Curator mode, Meta Expert, one card) and high-value
because `current-status.md` is the document most agents read first after
`agent-context.md`. Every agent that reads a stale scoreboard and cross-
references with file dates will spend 10–20 minutes in unnecessary archaeology
before trusting the spec chapters.

The archaeology trips that the S3-R6 sync was designed to prevent will still
happen — just for the round-lag reason rather than the spec-lag reason.

---

## [Route]

→ **track** → Meta Expert (Status Curator mode): `s3-r6-status-curation-v0`
  Scope: add Round 6 section to `current-status.md`; update
  `agent-context.md` Current Next Movement; formally mark
  `spec-entrypoint-sync-v0` as deferred/merged/closed.
  Priority: HIGH — this is the only remaining blocker for full fresh-agent
  safety.

→ **track** → Research Agent: `invariant-typed-shape-discharge-v0` (already
  routed from S3-R5-X1-S — confirm it is still in the queue and has not been
  silently deferred).

→ **track** → Compiler/Grammar Expert (if Research Agent confirms shape
  discharge): add C-8 qualification note to ch5 §5.7 or update C-8 status
  after discharge evidence lands.

→ **backlog**: S3-R6-C1 (`runtime-compatibility-report-temporal-load-check-v0`)
  and C2 remain open. These are not doc-context issues, but they should be
  listed explicitly in `current-status.md` as open round work, not just in
  `agent-context.md` next-movement.

---

## Compact Summary

| Surface | Verdict | Severity |
|---------|---------|----------|
| spec ch4 | ✅ synced — TEMPORAL class, OOF-TM rules, BiHistory, construct table accurate | — |
| spec ch5 | ✅ synced — emit_typed path; C-8 invariant case ⚠️ unqualified | LOW |
| spec ch6 | ✅ synced — temporal nodes, manifest index, guard policy; CRITICAL stale sections gone | — |
| spec ch7 | ✅ synced — cache key schemas, freshness states, load guard | — |
| parity stale headers | ✅ done | — |
| role profiles | ✅ all 3 interventions landed | — |
| agent-context.md | ✅ accurate current horizon, gates, ownership | — |
| current-status.md | ⚠️ one round behind — S3-R6 C3–C8 not in scoreboard | MEDIUM |
| agent-context next movement | ⚠️ stale — spec-sync done but list not updated | LOW |
| invariant_valid shape delta | ⚠️ unresolved — ch5 C-8 unqualified | MEDIUM |
| spec-entrypoint-sync-v0 | ⚠️ perpetually open — needs disposition | LOW |
| S3-R6-C1, C2 | ⏳ not yet landed — invisible unless next-movement list is read | LOW |

Overall: **the spec layer is safe**. A fresh agent will get correct language
information from ch4–ch7. The primary remaining risk is the scoreboard lag —
`current-status.md` needs a Status Curator pass before the next round starts.

# Discussion: Phase 1 Production Audit Scope and Registry Ownership Pressure v0

Card: S3-R25-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `phase1-production-audit-scope-and-registry-ownership-pressure-v0`
Status: complete — PROCEED (non-blockers only)
Date: 2026-05-10

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Is the 25-command regression matrix complete and honest? Is the Architect scope
decision design-only with no implementation authorization? Does the production
durable audit scope keep all excluded surfaces closed? Do the registry ownership
options avoid accidentally choosing production signing or binding?

---

## Context

- `docs/tracks/phase1-post-r24-regression-rerun-v0.md` (S3-R25-C1-P):
  25/25 PASS; expands from 23 to 25 commands by adding R24 durability fixtures;
  worktree note: two nondeterministic artifacts restored; non-authorization
  explicit
- `docs/gates/phase1-production-durable-audit-scope-decision-v0.md` (S3-R25-C2-A):
  `status: approved-for-design-only`; 7 design areas permitted; 15+ surfaces
  explicitly non-authorized; 7 implementation blockers listed before
  authorization can proceed
- `docs/tracks/production-registry-ownership-options-v0.md` (S3-R25-C3-P):
  three options compared (package-owned, gate document store, external authority
  service); recommended default: gate document store + generated content-addressed
  registry index; no implementation, signing, or Ledger binding

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| 25-command regression matrix complete and honest | 25 commands individually listed; R24 fixtures 24 + 25 added; prior 23-command chain remains green; nondeterministic artifacts noted and restored correctly; non-authorization block covers all excluded surfaces | ✅ complete and honest |
| Architect scope decision is design-only; no implementation authorization | C2-A `status: approved-for-design-only`; safe status phrase names "design only"; non-authorization block: 15+ surfaces; "Implementation authorization requires a later Architect decision" + 7 blockers | ✅ design-only; implementation not authorized |
| Production durable audit scope does not imply Ledger / Phase 2 / writes / replay / compact / subscribe / production cache / BiHistory / stream / OLAP | C2-A non-authorization: all named; §4 "replay" explicitly scoped to "audit-reader verification of persisted audit records only, not Ledger replay"; "The signed Gate 3 live-read addendum remains unchanged" | ✅ all excluded |
| Registry ownership options do not accidentally choose production signing / key management / production binding | C3-P non-authorization: no storage implementation, signing choice, key management, package edits, RuntimeMachine integration, or Ledger binding; recommended option (gate document store) has lowest implementation complexity and no signing dependency; all three options note signing/key management must stay separate | ✅ design-only; no binding chosen |

---

## [Agree]

**A-1: C1-P's 25-command regression matrix is the most complete and honestly
structured record in the Gate 3 Phase 1 chain to date.**
Each command is individually listed, named by surface, and results are per-row.
The "prior 23-command chain: still PASS" line provides continuity verification.
The worktree note is exemplary: it explicitly names the two nondeterministic
artifacts, states that they were restored to checked-in contents with scoped
patches, and names the unrelated untracked gate document that was left untouched.
This level of worktree hygiene transparency is correct — it distinguishes "PASS
for the logic check" from "the artifacts are deterministic."

**A-2: C2-A's `approved-for-design-only` structure is correctly bounded at every
level.**
The safe status phrase opens with design-only explicitly. The non-authorization
block covers implementation, production deployment, production signing execution,
key management, Ledger adapter, Phase 2, BiHistory, stream/OLAP, production
cache, writes/replay/compact/subscribe, runtime authority registry service
implementation, and broadening `gate3_authorized: true`. The 7-blocker list
before implementation authorization is comprehensive and includes pressure review
(blocker 2) — meaning this discussion satisfies one of the listed conditions if
it returns PROCEED.

**A-3: C2-A §4 "Retention and Replay Semantics" correctly scopes the word
"replay" to audit verification, not Ledger operations.**
The section states explicitly: "This does not authorize runtime replay operations
or Ledger replay. Replay here means audit-reader verification of persisted audit
records only." This prevents the most likely misreading of the term. The
non-authorization block additionally closes "Ledger reads, writes, replay,
compact, subscribe" as distinct entries. The scoping is layered correctly.

**A-4: C2-A §6 "Audit Reader Role" correctly separates the audit reader from
the executor write/append authority.**
"The audit reader must not be able to perform live reads, Ledger reads/writes,
replay, compact, subscribe, or policy authorization." This is the minimum
required separation for any production audit surface that operates alongside an
authorized live-read executor. The design mandate, if followed, prevents the
audit reader from being elevated to an authorization or write surface.

**A-5: C3-P's recommendation for gate document store + generated content-addressed
index is the correct Phase 1 default.**
The recommendation matches the existing Phase 1 authority model: the signed Gate
3 addendum is already a gate document; the authority_ref URI already points into
the gate document namespace; content-addressed refs are already defined (S3-R22-C2-P).
The gate document store recommendation preserves human/agent inspectability,
avoids coupling registry ownership to runtime or Ledger packages, keeps signing
separate, and can later be consumed by package-owned validators or served by an
external authority service without changing the source of truth.

**A-6: C3-P correctly identifies the risk of package-owned registry.**
"Can look like runtime self-authorization if bundled too closely with
`TemporalExecutor`." This is precisely the risk that drove the Phase 1 separation
between the `gate3_authorized` honor-system and the executor's own guard chain.
Making a package the authority source for that same honor-system would recreate
the coupling at the package level. The recommendation correctly restricts
package-owned code to read-only cache/validator status.

**A-7: C2-A implementation blocker 1 (25-command regression rerun) is closed
by C1-P in the same round.**
C2-A blocker 1: "post-R24 regression rerun expanded to 25 commands." C1-P
delivers 25/25 PASS. The sequence within R25 (C1 before C2) is correct — the
regression runs before the scope decision is signed. This is the right ordering:
the Architect sees the green regression before approving design-only work.

---

## [Challenge]

**C-1 (Low): C1-P's nondeterministic artifacts signal a known fragility in the
regression harness.**
C1-P §Worktree Note: two artifacts regenerated on rerun and required restoration:

- `stage2_close_candidate.json` — likely contains timestamps or session IDs
- `phase1_tamper_evident_store.jsonl` — contains UUIDs (`storage_identity`) and ISO8601 `created_at` timestamps

The worktree patch approach is correct for a proof rerun that prioritizes logic
verification over artifact stability. However, the canonical regression matrix
now permanently includes two commands whose artifacts cannot be verified for
content stability without a patch step. A future regression framework should
either:

1. Make these outputs fully deterministic (fixed seeds, no wall-clock timestamps
   in committed artifacts), or
2. Explicitly declare them as non-committed artifacts and exclude them from
   git-state verification.

Non-blocking; the PASS verdicts for the logic checks are correct.

---

**C-2 (Low): C2-A's §4 "ordered audit replay" for audit verification differs
from but could be confused with stream/OLAP replay semantics.**
The design scope permits "ordered audit replay" and "idempotent read-back
verification" as mechanisms for an audit reader to re-traverse the record chain.
This is semantically distinct from Ledger replay (re-executing events to rebuild
state) and OLAP replay (re-querying historical query results). The clarification
exists in the text, but an implementer reading only the heading "Retention and
Replay Semantics" could conflate the concepts. The design track should adopt a
term distinct from "replay" for the audit-reader verification pass — for example,
"chain verification" or "audit traversal."

Non-blocking; the text is correct; naming could be sharper.

---

**C-3 (Low — open design questions not yet answered): C3-P poses six Architect
questions without answers.**
The six questions about freshness SLA, CI vs manual index generation, immutable
anchor preference, external service receipt exposure, and package authority
prohibition are left open. These are the right questions, but until they are
answered, the registry ownership recommendation cannot be implemented:

- Q1 (source of truth: gate document store?) — answered implicitly by C3-P
  recommendation but not by an Architect decision record
- Q2 (freshness SLA) — unanswered; critical for caller policy correctness
- Q3 (CI vs manual index generation) — unanswered; determines who controls
  revocation publishing
- Q4 (immutable anchor: commit SHA vs release digest vs both) — unanswered
- Q5 (external service receipt exposure requirement) — unanswered
- Q6 (package authority prohibition) — unanswered

Non-blocking for R25; the design track depends on these answers.

---

**C-4 (Low): C1-P cites `stage3-round24-status-curation-v0.md` as an implicit
reviewed input (mentioned in C2-A's reviewed inputs) but it is not independently
verifiable in this review.**
This is the same pattern as S3-R20-X1-S C-2 and S3-R24-X1-S C-4. Status
curation tracks are context documents; the substantive evidence (25/25 PASS
regression, prior pressure review PROCEED) is verifiable. Non-blocking.

---

## [Missing]

**M-1: No Architect decision record answers C3-P's six open questions.**
The registry ownership options track correctly stops at analysis and questions.
An Architect decision answering at minimum Q1 (source of truth), Q2 (freshness
SLA), and Q3 (index generation ownership) is required before the production
durable audit design track can make binding assumptions about registry behavior.

**M-2: C2-A blocker 3 ("registry ownership decision or explicit statement that
audit persistence can proceed without registry ownership coupling") is not yet
closed.**
C3-P's options analysis and recommendation address the landscape, but a binding
Architect decision on registry source of truth has not been issued. The design
track for production durable audit would need to either:
(a) wait for the registry ownership decision, or
(b) explicitly state that the production durable audit design is decoupled from
registry ownership and can proceed independently.
Neither (a) nor (b) has been recorded yet.

**M-3: No decision on deterministic artifact policy for the regression harness.**
C1-P's worktree note surfaces the need for a policy decision, but no track is
assigned to resolve it. The two problematic fixtures are `stage2_close_candidate`
and `phase1_observation_tamper_evidence_shape`.

---

## [Sharper Question]

> Given that C2-A approves design work for production signing boundary selection
> (§1), does that permission allow the design track to choose a signing algorithm
> and key model, or only to compare options?

The boundary matters: "compare and select" (C2-A language) suggests a selection
is permitted, but "production signing is not enabled by this decision" (also
C2-A) suggests selection cannot be treated as authorization. The design track
should produce a recommendation, not an implementation commitment — and should
explicitly state that signing execution requires a later Architect decision even
after the algorithm is named.

This is not a gap in the current R25 documents; it is the critical scoping
question for the R26 design track.

---

## [Route]

**PROCEED — non-blockers only.**

All four scope items confirmed. The 25-command regression is complete and honest.
The Architect scope decision is firmly design-only with 7 implementation blockers
preserving the gate. Production durable audit scope keeps all excluded surfaces
closed, including explicit disambiguation of "replay" to audit-reader
verification. Registry ownership analysis recommends the safest option (gate
document store) without implementing any binding.

Five low-severity non-blocking observations:

| # | Item | Type |
|---|---|---|
| C-1 | Nondeterministic regression artifacts require patch restoration | regression harness fragility; determinism policy needed |
| C-2 | "Ordered audit replay" terminology could be confused with stream/OLAP replay | naming note; recommend "chain verification" or "audit traversal" in design track |
| C-3 | C3-P's six Architect questions unanswered | design dependency; needed before production audit design can bind on registry |
| C-4 | Stage3-round24 status curation not independently verifiable | citation gap (carried pattern) |

Updated pre-production checklist:

| # | Item | Status after R25 | Note |
|---|---|---|---|
| P-1 | Durable observation persistence | design scope approved (C2-A §1–7); implementation not yet authorized | |
| P-2 | Production authority registry — durable storage, revocation, receipts | options analyzed (C3-P); Architect ownership decision still open (M-1, M-2) | |
| P-3 | Production signing | design scope approved (C2-A §1); signing execution not authorized | |
| P-4 | `signed_addendum_ref` content-addressed | ✅ CLOSED | |
| P-5 | End-to-end invocation fixture | ✅ CLOSED | |
| P-6 | `LEGACY_ALIASES` deprecation signal | ✅ CLOSED | |
| P-7 | Phase 2 Ledger adapter addendum | open — separate Architect decision | |
| P-8 | Full regression matrix rerun | ✅ CLOSED — 25/25 PASS (C1-P); determinism policy still open | |
| P-9 | Tamper evidence / storage identity | ✅ CLOSED | |
| P-10 | Production registry ownership decision | open — C3-P options analyzed; Architect answers to C3-P Q1–Q6 needed | |
| P-11 | `format_version` enforcement | design scope approved (C2-A §3); implementation not yet authorized | |
| P-12 | Restart rebuild algorithm | design scope approved (C2-A §2); implementation not yet authorized | |
| P-13 | Production durable audit Architect scope decision | ✅ CLOSED — C2-A `approved-for-design-only` | Implementation blockers 2–7 still open |
| P-14 | Nondeterministic regression artifact policy | open — M-3 above; C1-P worktree note | |

**R26 recommendation:**

| Priority | Track | Rationale |
|---|---|---|
| High | `phase1-production-durable-audit-v0` (design only) | C2-A approved; delivers signing model, rebuild algorithm, format enforcement, retention semantics, storage identity, audit reader role, compliance language, error codes; must NOT assume implementation authorization |
| Medium | Architect registry ownership decision | Answers C3-P Q1–Q6; required for C2-A blocker 3; unblocks P-10 |
| Low | Deterministic artifact policy for regression harness | Resolves C-1 and M-3; small scope |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | Regression matrix incomplete or masks failures | High | ✅ closed — 25/25 individually listed; nondeterministic artifacts noted and restored |
| R-2 | Architect scope decision authorizes implementation | High | ✅ closed — `approved-for-design-only`; 7 implementation blockers; non-authorization 15+ surfaces |
| R-3 | Production durable audit scope implies Ledger | High | ✅ closed — C2-A non-authorization explicit; "Ledger reads, writes, replay, compact, subscribe" all closed |
| R-4 | Production durable audit scope implies Phase 2 | High | ✅ closed — C2-A non-authorization: "Phase 2"; "Ledger adapter or package binding" |
| R-5 | BiHistory / stream / OLAP opened by design scope | High | ✅ closed — C2-A non-authorization; "BiHistory or transaction-time reads; stream/OLAP production executors" |
| R-6 | Write / replay / compact / subscribe opened | High | ✅ closed — C2-A non-authorization; §4 explicitly scopes "replay" to audit-reader only |
| R-7 | Production cache opened | High | ✅ closed — C2-A non-authorization; C3-P non-authorization |
| R-8 | Registry ownership options choose production binding | High | ✅ closed — C3-P: no implementation, signing choice, key management, package edits, Ledger binding |
| R-9 | Registry options choose package-owned as authority source | Medium | ✅ noted and mitigated — C3-P recommends package-only as read-only cache/validator; identifies self-authorization risk |
| R-10 | Nondeterministic regression artifacts undermine PASS verdict | Low | open — C-1 above; PASS verdicts correct; artifact determinism policy needed |
| R-11 | "Replay" in C2-A §4 confused with Ledger/OLAP replay | Low | open — C-2 above; text is clear; naming could be sharper in design track |
| R-12 | C3-P Architect questions unanswered; design track blocked | Low | open — C-3 above; M-1, M-2; P-10 open |
| R-13 | Status curation citation not independently verifiable | Low | open (carried pattern) — substantive evidence is verifiable |
| R-14 | C2-A "compare and select" signing boundary treated as authorization | Low | open — sharper question above; design track must clarify recommendation ≠ execution authorization |
| R-15 | `audit_ready_not_persisted` naming ambiguity | Low | open (carried) — pre-production naming amendment |
| R-16 | `gate3_authorized` honor-system | Low | open (inherent) — Phase 1 structural limitation |
| R-17 | `git_commit: workspace-current` placeholder | Low | open (carried) — CI must supply real SHA |

**All eight high risks and the medium risk closed. Nine low-severity items: five
new from R25 and four carried.**

---

## Handoff

```text
Card: S3-R25-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: phase1-production-audit-scope-and-registry-ownership-pressure-v0
Status: complete — PROCEED (non-blockers only)

[D] Decisions
- C1-P 25/25 PASS: honest expansion of matrix; worktree hygiene exemplary.
- C2-A approved-for-design-only: firmly bounded; 7 implementation blockers;
  "replay" scoped to audit-reader verification; audit reader separated from
  executor authority. C2-A blocker 2 (pressure review) satisfied by this PROCEED.
- C3-P gate document store recommendation is the correct Phase 1 default;
  package-owned risk correctly identified; six Architect questions define
  remaining design dependency.
- P-13 closed; P-14 added to checklist.

[Agree]
- All scope items confirmed.
- C2-A design-only structure correctly bounded at every level.
- C3-P recommendation matches existing Phase 1 authority model.
- C2-A blocker 1 (25-command rerun) closed by C1-P in same round.

[Challenge]
- C-1 (Low): nondeterministic artifacts; determinism policy needed.
- C-2 (Low): "replay" terminology; use "audit traversal" in design track.
- C-3 (Low): C3-P six Architect questions unanswered; P-10 open.
- C-4 (Low): status curation citation (carried pattern).

[Route]
- PROCEED — non-blockers only.
- Pre-production checklist P-1..P-14.
- C2-A blocker 2 (pressure review) satisfied.

[R26 recommendation]
- High: phase1-production-durable-audit-v0 design track (C2-A scope).
- Medium: Architect registry ownership decision (C3-P Q1–Q6).
- Low: Deterministic artifact policy for regression harness.
```

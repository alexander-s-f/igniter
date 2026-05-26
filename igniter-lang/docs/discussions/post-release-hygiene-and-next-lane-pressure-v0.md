# Post Release Hygiene And Next Lane Pressure v0

Card: S3-R186-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: post-release-hygiene-and-next-lane-pressure-v0

Context:
- Write access: none
- Canon authority: none

---

## Inputs Read

| File | Card | Role |
| --- | --- | --- |
| `igniter-lang/docs/tracks/compiler-release-process-hygiene-lessons-v0.md` | S3-R186-C1-P1 | Hygiene lesson packet |
| `igniter-lang/docs/tracks/post-release-next-compiler-language-lane-options-v0.md` | S3-R186-C2-P1 | Next-lane options recommendation |
| `igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md` | S3-R185-C4-S | R185 status curation |
| `igniter-lang/docs/tracks/compiler-release-execution-acceptance-decision-v0.md` | S3-R185-C3-A | Release execution acceptance decision |

---

## Question

Are the S3-R186 post-release hygiene lesson packet (C1-P1) and next-lane
recommendation (C2-P1) complete enough, claim-safe, free of accidental release
re-authorization, and sound as the basis for a Portfolio acceptance decision —
with Spark remaining out of scope, closed surfaces preserved, and the recommended
`if_expr` design route correctly bounded as design/proof planning only?

---

## Scope Checks

| # | Check | Result | Notes |
| --- | --- | --- | --- |
| SC-1 | C1-P1 does not execute release commands, publish, yank, tag, push, or edit release docs/code | PASS | Closed surfaces section explicit; card opens no new command |
| SC-2 | C1-P1 lessons cover all three C2-X NB items from R185 | PASS | NB-1 → HR-1; NB-2 → HR-3; NB-3 → HR-2 |
| SC-3 | C1-P1 HR rules are internally consistent (no rule contradicts another) | PASS | HR-1 names accepted smoke SHA as the expected SHA in approval text — consistent with SHA-gate-before-publish ordering in HR-6 |
| SC-4 | C1-P1 does not accidentally authorize a second release execution | PASS | Closed Surfaces section explicitly lists release execution, publish, tag creation, push, signing, deployment |
| SC-5 | C2-P1 does not open a second release route or version/tag/push/publish authorization | PASS | "Should another release route remain closed? Yes." is explicit |
| SC-6 | C2-P1 public claims remain bounded to accepted alpha availability wording | PASS | Carries exact allowed wording; "not stable / not production / not public demo" attached |
| SC-7 | C2-P1 recommended next dispatch (S3-R187-C1-D) does not smuggle implementation authority | PASS | Dispatch card says "Do not implement code. Do not authorize implementation." and lists closed surfaces explicitly |
| SC-8 | C2-P1 options matrix does not imply implementation authorization by including a surface in the table | PASS | All deferred/not-now options are clearly labeled; "Implementation touches..." risk column is present and prevents scope creep by inclusion |
| SC-9 | Spark remains out of release scope in both C1-P1 and C2-P1 | PASS | C1-P1 Closed Surfaces: "Spark integration"; C2-P1 Explicit Answers closed surfaces and options matrix: "Spark integration and Spark public evidence claims" |
| SC-10 | Closed surfaces are consistent across C1-P1, C2-P1, C3-A, and C4-S | PASS | All four docs carry consistent closed-surfaces enumeration; no surface appears closed in one and open in another |
| SC-11 | C1-P1 HR-1 approval wording template is a recommendation for future releases, not a retroactive gate on R185 | PASS | "R185 remains accepted and requires no incident/yank/tag remediation" explicit; NB items are codified as future rules |
| SC-12 | C1-P1 compact future-release checklist (PRE-AUTH / EXECUTION / POST) is actionable and self-contained | PASS | All 20+ checklist items are concrete and verifiable; no vague references |
| SC-13 | C2-P1 options matrix is sound: recommended option does not exceed design/proof planning authority | PASS | "Open branch/conditional if_expr design/proof planning" — no implementation in option scope or dispatch scope |
| SC-14 | C2-P1 correctly carries the "pause release lane" recommendation without leaving an ambiguous re-entry path | PASS | "No second release route should open without a fresh Portfolio/user decision that names the target, version/tag/publish boundary, evidence delta, and public wording" |
| SC-15 | C1-P1 non-blocking cleanup suggestions (#1–5) are labeled non-blocking and do not authorize action | PASS | "These are non-blocking" explicit; suggestions do not open cards or grant authority |

All 15 scope checks: **PASS**. No blockers.

---

## [Agree]

- C1-P1 HR-1 through HR-9 form a coherent, non-redundant rule packet. Each rule
  is traceable to a specific R185 observation: HR-1 to NB-1 compressed approval,
  HR-2 to NB-3 prerelease listing, HR-3 to NB-2 install command scope, HR-4–HR-9
  to C2-P1/C4-A structural observations. No rule contradicts another.

- C1-P1 correctly treats R185 as accepted with no remediation required, and
  positions the HR rules as prospective-only. The boundary between "R185 is
  closed" and "future releases should do X" is clean throughout.

- C2-P1 correctly identifies `if_expr` as the highest-value next non-release
  lane. The evidence base is sound: accepted alpha exclusion with existing
  machine-visible harness evidence (`OOF-TY0 Unsupported expression kind:
  if_expr`), a clear language/compiler semantics question, and no confounding
  release-readiness dependency.

- C2-P1 options matrix is well-constructed: it includes a risk/why-not-now
  column that prevents later readers from cherry-picking a deferred option as
  implicitly authorized. Profile finalization/discovery/defaulting is correctly
  marked "Defer" with claim-drift risk noted — this is the right call given the
  easy conflation with the accepted `PATH.json` transport.

- The four input docs (C1-P1, C2-P1, C3-A, C4-S) are mutually consistent. The
  C3-A three-NB decisions flow cleanly into C1-P1 HR rules. The C4-S handoff
  recommendation ("return to compiler/language feature lane or run a short
  post-release hygiene round") aligns with C2-P1 exactly.

- Spark is closed in both planning cards with no ambiguous edge case. None of
  the seven options in C2-P1 opens a Spark path.

---

## [Challenge]

- C1-P1 HR-9 defines 33 required receipt fields. It does not specify what to do
  when a required field is absent. HR-1 says "future pressure reviews should
  treat compressed approval as a non-blocking note at best only if every other
  gate passed." But HR-9 does not say whether absent required receipt fields
  constitute a gate failure, a HOLD, or a non-blocking note. A future execution
  card could mark `approval_exact_enough: false` and an evaluator would not know
  from HR-9 alone whether this is a hard abort or a pressure review flag. C1-P1
  would be stronger if it stated explicitly: "If `approval_exact_enough: false`,
  treat as HOLD before irreversible commands unless the three conditions from
  HR-1 are all met."

- C2-P1 lists "Pause and observe release feedback" as a background option, but
  does not specify what evidence or time threshold would trigger an active
  response to such feedback (e.g., a user bug report on RubyGems, or a yank
  request from a downstream consumer). The current framing is correct for the
  post-alpha posture, but the gap means a future agent receiving release feedback
  may not know which route to activate. This is not a blocker for C3-X
  acceptance, but a future card should pre-specify the feedback response route.

---

## [Missing]

- **Commit message hygiene lesson absent:** The C2-X NB-3 note about commit
  `dcdb0ae6` having a mislabeled message (message said "C2-I" but contained C1-A
  content) was assessed as non-blocking in C2-X. C1-P1 does not include a
  corresponding hygiene rule about commit message accuracy during release
  preparation. This is a minor gap — the issue had no scope impact — but a
  future release template could include: "Verify commit messages match actual
  file content before creating the local tag." Not a blocker.

- **`igc --help` non-zero exit behavior not formalized:** The post-publish sync
  noted that `igc --help` exits non-zero because the CLI prints usage for
  non-`compile` invocations. C1-P1 does not capture this as a lesson. A future
  regression note could say: "CLI usage check in isolation must use `igc compile`
  not `igc --help` to obtain exit 0." Not a blocker given E-7 in R185 used
  `compile` and passed.

- **No explicit sequencing constraint between C1-P1 hygiene round and C2-P1
  recommended dispatch:** C2-P1 correctly marks the hygiene round as "Optional
  support, not primary lane" and says it should not block the `if_expr` design
  lane. But it does not say whether C1-P1 must be accepted before S3-R187-C1-D
  opens, or whether they can run in parallel. This is a minor operational gap —
  both are read-only/docs-only — and Portfolio can decide at dispatch time. Not
  a blocker.

---

## [Sharper Question]

> Does C1-P1 HR-1's required approval template supersede or merely supplement
> C2-P1's execution boundary plan requirements for future releases — and who
> decides when a future approval is "exact enough" to proceed past HOLD?

The current answer implied by C1-P1 is: the pressure reviewer evaluates
`approval_exact_enough` at C?-X time and flags it. But the boundary between
"non-blocking note" (as in R185) and "hard HOLD" depends on context. C1-P1 says
"prefer a HOLD before irreversible commands if approval does not name package,
version, SHA, tag, and publish scope" — which is a preference, not a gate. A
future authorization card should encode this preference as a binding gate
condition.

---

## [Route]

Proceed.

- All 15 scope checks PASS.
- No blockers.
- Two non-blocking notes:
  - **NB-1:** C1-P1 HR-9 + HR-1 interaction leaves `approval_exact_enough:
    false` disposition ambiguous — future execution authorization card should
    encode HR-1's "prefer HOLD" as a binding gate condition.
  - **NB-2:** Commit message hygiene lesson and `igc --help` non-zero exit
    behavior are absent from C1-P1 — minor omissions given both had no scope
    impact in R185; future template cleanup may add them.

Portfolio C4-A may accept both C1-P1 and C2-P1 and dispatch S3-R187-C1-D as
recommended. The hygiene lesson packet (C1-P1) is sound as a reference document
and does not require amendment before dispatch.

---

## Compact Pressure Verdict

```text
card:           S3-R186-C3-X
track:          post-release-hygiene-and-next-lane-pressure-v0
verdict:        proceed
checks:         15/15 PASS
blockers:       none
non-blocking:   2

NB-1: C1-P1 HR-1 + HR-9 interaction: approval_exact_enough: false disposition
      left ambiguous — future execution authorization card should encode
      HR-1 "prefer HOLD" as a binding gate condition rather than a preference.

NB-2: Commit message hygiene lesson and igc --help non-zero exit not captured
      in C1-P1 HR rules — minor omissions with no R185 scope impact;
      optional template cleanup only.

acceptance recommendation:
  Portfolio C4-A may accept C1-P1 and C2-P1 and open S3-R187-C1-D
  (branch/conditional if_expr scope-and-semantics design) as recommended.
  Hygiene round does not need to complete before dispatch.

closed surfaces:
  release execution, second release route, RubyGems publish, gem yank,
  tag creation, git push, signing, deployment, stable/production/demo/
  all-grammar claims, if_expr implementation, profile finalization/
  discovery/defaulting, Spark, runtime, API/CLI widening.
```

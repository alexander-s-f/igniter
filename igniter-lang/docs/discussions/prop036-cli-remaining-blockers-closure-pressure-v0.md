# Discussion: PROP-036 CLI Remaining Blockers Closure Pressure v0

Card: S3-R51-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-remaining-blockers-closure-pressure-v0

Depends on: S3-R51-C1-A delivered

Question:

Does the Architect formal closure gate for B3/B4/B5/B6/B9 cite the correct
evidence for each blocker? Does it resolve the R49 B2 citation gap? Does it
avoid implying new implementation authorization or production readiness? Are all
nine blocker statuses accounted for with named authorities? Is B9 correctly
closed by citing this review chain?

Context:
- C1-A (Architect Supervisor): Formally closes B3/B4/B5/B6/B9; cites R50
  proof summary (12/12 PASS, 0 forbidden hits, self-test true×2); cites
  S3-R50-C3-X pressure verdict (proceed, 9/9 scope checks); B2 dual-cited
  via R45 + R50; full blocker table B1–B9 with per-blocker gate authorities;
  exhaustive non-authorization section; no production readiness claim
- R50-C2-I: 12/12 proof cases; forbidden_exact_token_hits=0;
  scanner_self_test flags both true; legacy/valid/invalid behavior proven
- S3-R50-C3-X: Verdict proceed; nine scope checks pass; B9 satisfied by review;
  NB-1 (flag-as-path edge case) non-blocking
- R46-C4-A: Governing closure criteria for B3/B6
- R47-C3-A: Amendments 1/2/3 — B1 validation chain, B6 adversarial
  scanner self-test, B8-C deferral authority
- S3-R49-C1-A, S3-R47-C3-A: Prior gate authorities for B1/B7/B8

---

## Five Scope Checks

### Check 1 — Gate authority is correct

**Result: PASS.**

`prop036-cli-remaining-blockers-formal-closure-decision-v0.md` is in
`docs/gates/`, issued by `[Architect Supervisor / Codex]` with
`role: architect-supervisor`. ✓

`Gate > TrackClaim` is preserved: B3/B4/B5/B6/B9 are closed by an Architect
gate document citing verified proof evidence, not by the implementation track
or pressure review acting alone.

### Check 2 — Evidence citations match R50 outputs without overclaim

**Result: PASS.**

Every figure cited in C1-A's Closure Summary is verified against the R50
proof summary JSON and the R50-C3-X discussion document:

| Claim in C1-A | Source | Match |
|---|---|---|
| `cases: 12/12 PASS` | R50 proof summary `cases` array | ✓ |
| `commands: 4/4 PASS` | R50 C2-I command matrix | ✓ |
| `forbidden_exact_token_hits: 0` | R50 proof summary field | ✓ |
| `scanner_self_test_bare_forbidden_token_fails: true` | R50 proof summary field | ✓ |
| `scanner_self_test_qualified_source_validation_allowed: true` | R50 proof summary field | ✓ |
| `S3-R50-C3-X verdict: proceed` | C3-X route section | ✓ |
| `scope checks: 9/9 PASS` | C3-X nine scope checks | ✓ |
| `B9: satisfied by S3-R50-C3-X` | C3-X B9 Assessment section | ✓ |

The per-blocker closure sections (B3–B6) restate only evidence already in the
R50 proof summary. No new evidence is claimed. No metric is inflated.

### Check 3 — R49 NB-1 B2 citation gap is resolved

**Result: PASS.**

R49-C2-X NB-1 flagged that R49-C1-A recorded B2 as "satisfied by the existing
design route" with no gate path citation. C1-A resolves this with a dual
citation in the blocker table:

```text
B2: satisfied | S3-R45-C3-A / preserved by S3-R50-C1-A
```

Both citations are accurate:
- R45-C3-A is the gate that approved the `--compiler-profile-source PATH.json`
  design route (the original B2 satisfaction).
- R50-C1-A explicitly states "PROP036-CLI-B2 remains satisfied by the approved
  shape `--compiler-profile-source PATH.json`" — confirming the R50 bounded
  implementation stayed within the approved shape.

A future reader of C1-A can trace B2's authority without consulting session
context. The R49 documentation gap is closed. ✓

### Check 4 — No new implementation authorization or production readiness implied

**Result: PASS.**

The decision opens with: "This decision does not authorize new implementation."
The non-authorization section explicitly lists 20+ prohibited surfaces,
including "new CLI implementation," "widening the CLI surface," and the
complete list of held surfaces from R50 onward.

Critically, the gate adds a clause absent from prior decisions:

> "This decision also does not claim production readiness. It closes the named
> PROP-036 CLI blocker package only."

This correctly separates two distinct governance milestones:
- **blocker package closed** — achieved by this decision
- **production/release ready** — requires a future gate

The "Next Allowed Boundary" section reinforces this: "a future Architect
decision may decide whether the bounded CLI transport should move from
blocker-closed to next implementation or release-readiness work." ✓

### Check 5 — Full blocker table is complete with named authorities

**Result: PASS.**

All nine blockers are present in the formal table with per-blocker closure
authority:

| Blocker | Status | Cited authority |
|---|---|---|
| B1 | closed | S3-R49-C1-A ✓ |
| B2 | satisfied | S3-R45-C3-A / S3-R50-C1-A ✓ |
| B3 | closed | S3-R51-C1-A ✓ |
| B4 | closed | S3-R51-C1-A ✓ |
| B5 | closed | S3-R51-C1-A ✓ |
| B6 | closed | S3-R51-C1-A ✓ |
| B7 | closed | S3-R47-C3-A ✓ |
| B8 | closed | S3-R47-C3-A ✓ |
| B9 | closed | S3-R51-C1-A citing S3-R50-C3-X ✓ |

No blocker is missing. No blocker claims closed status without a named gate
document. The table is mechanically auditable. ✓

---

[Agree]

1. **The gate correctly closes all five remaining blockers with traced evidence.**
   B3/B4/B5/B6 each have a dedicated section naming the proof case, the
   required criteria, and the summary fields that satisfy them. The gate does
   not collapse the evidence into a single "proof passed" claim.

2. **B9 is closed by the correct mechanism.** R45 defined B9 as a process
   requirement (run runtime-pressure review after implementation boundary,
   before acceptance). S3-R50-C3-X is exactly that review. The gate cites the
   review record and accepts its verdict. B9 closure is structurally sound and
   does not require a separate artifact or proof matrix.

3. **The R49 NB-1 B2 citation gap is resolved.** The dual citation in the
   blocker table provides a traceable authority chain for B2 without
   re-litigating its closure. Future readers are not dependent on session
   context.

4. **The non-authorization section is the most comprehensive in the chain.**
   Adding the explicit "does not claim production readiness" clause is the
   correct boundary-setting for a milestone that closes a named blocker package
   without authorizing the next implementation or release phase.

5. **The R50 C3-X NB-1 acceptance is properly handled at gate level.**
   The Architect accepting the flag-as-path edge case as non-blocking is the
   appropriate place for that decision — a gate can resolve non-blocking notes
   from pressure reviews, and the reasoning given is sound.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

Nothing required before this decision is accepted.

---

[NB-1 — Non-blocking: "Next Allowed Boundary" is open-ended]

The "Next Allowed Boundary" section correctly holds the production/release
milestone behind a future gate, but it describes the next decision only in
general terms: "may decide whether the bounded CLI transport should move from
blocker-closed to next implementation or release-readiness work."

A future card opening the next phase would benefit from a named gate shape —
e.g., "production readiness review gate" or "explicit implementation
authorization upgrade for the current `cli.rb` transport." This makes R52's
orientation card unambiguous about what question the next Architect decision
must answer.

This is orientation guidance only and does not affect the validity of the
current closure decision.

---

[Sharper Question]

With B1–B9 fully closed, the PROP-036 CLI blocker package is done. The
remaining governance question is: what form should the production/release
readiness gate take? Specifically — does the next gate review only the current
bounded transport (`--compiler-profile-source PATH.json`) for production
promotion, or does it first require a wider CLI surface review (B2 widening,
CompatibilityReport, loader/report) before any production decision? The answer
shapes whether R52 is a short promotion gate or a new implementation cycle.

---

[Route]

**Verdict: proceed.**

No blockers. All five scope checks pass. The gate correctly closes B3/B4/B5/B6/B9
with gate authority, mirrors R50 evidence without overclaim, resolves the R49
B2 citation gap, keeps implementation and production readiness as separate future
milestones, and accounts for all nine blockers with named authorities. NB-1
is orientation guidance only.

**The full PROP-036 CLI blocker package B1–B9 is formally closed as of
S3-R51-C1-A.**

**For R52:**
The next round's C1-A question is the production/release readiness decision
for the already-bounded CLI transport. That gate must address:
- whether the current `cli.rb` transport is ready for production promotion
  as-is, or requires additional review;
- whether any surfaces from the non-authorization list are being re-opened or
  left strictly closed for this release;
- explicit production/release authorization or a hold with a named next step.

The bounded transport itself is not a blocker question — that work is done.
The next open question is production authority.

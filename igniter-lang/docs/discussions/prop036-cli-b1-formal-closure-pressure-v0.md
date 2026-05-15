# Discussion: PROP-036 CLI B1 Formal Closure Pressure v0

Card: S3-R49-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-b1-formal-closure-pressure-v0

Depends on: S3-R49-C1-A delivered

Question:

Does the Architect B1 closure decision cite gate authority rather than track
self-assertion? Does it avoid implying CLI implementation readiness? Are
remaining blockers explicitly named? Is the artifact evidence confined to what
R48 actually proved without overclaim? Does implementation remain structurally
held?

Context:
- C1-A (Architect Supervisor): Formal B1 closure gate; status
  `approved-b1-formally-closed-implementation-held`; evidence read from
  R48-C1-I proof and R48-C2-X pressure review; six-point closure basis;
  exhaustive non-authorization section; remaining blockers: B3/B4/B5/B6/B9
- R48-C1-I (Research Agent): Emitted standalone artifact at stable path;
  proof 27/27 PASS; all 5 required summary fields; validation via
  `finalization_and_assembler_source_contract`; forbidden-token hits: 0;
  assembler regression 19/19 PASS
- R48-C2-X (External Pressure Reviewer): Independent verification of all
  B1 criteria; verdict `proceed`; no blockers; NB-1: formal Architect gate
  acceptance still pending
- R47-C3-A (Architect): Amendment 1 — `standalone_artifact_valid: true` must
  mean validation via the same source-contract path, not JSON shape alone;
  Amendment 2 — B6 requires adversarial scanner self-test; Amendment 3 —
  B8-C deferral requires explicit Architect gate record

---

## Five Scope Checks

### Check 1 — Closure cites gate authority, not track self-assertion

**Result: PASS.**

`prop036-cli-b1-formal-closure-decision-v0.md` is in `docs/gates/`, issued by
`[Architect Supervisor / Codex]` with `role: architect-supervisor`. The document
is a gate record, not a track recommendation.

The closure basis lists six items, each pointing at verifiable artifact or
summary evidence — no item reads "the Research Agent concluded" or "the track
recommends." The gate decision independently names the artifact path, the
validation-chain path, the required summary fields, the forbidden-token count,
the proof matrix result, and the pressure verdict. These are the inputs to the
gate, not the gate citing itself.

`Gate > TrackClaim` is correctly maintained: B1 is closed by an Architect gate
document, not by the R48-C1-I track alone.

### Check 2 — Closure does not imply CLI implementation readiness

**Result: PASS.**

The gate title encodes the hold explicitly:
`approved-b1-formally-closed-implementation-held`.

The decision body states: "This decision does not authorize CLI implementation."

The "Next Allowed Boundary" section states: "Any such card must still explicitly
authorize implementation before touching CLI code, path loading, or JSON
parsing." The word `must` is binding. The phrase "may focus on" in the same
sentence is correctly permissive for further blocking-closure work, not for
implementation.

No sentence in C1-A asserts "CLI is now ready" or "implementation may begin"
or "blockers are substantially clear." The implementation hold is preserved at
the title level, the body level, and the non-authorization section level.

### Check 3 — Remaining blockers are explicitly named

**Result: PASS.**

C1-A names the remaining open blockers as an explicit list:

```text
PROP036-CLI-B3
PROP036-CLI-B4
PROP036-CLI-B5
PROP036-CLI-B6
PROP036-CLI-B9
```

The gate records which blockers are formally closed before or by this decision:
B1, B7, B8. It does not claim B3/B4/B5/B6/B9 are close or nearly closed. The
list is structurally complete: every blocker in the original B1–B9 package is
accounted for.

### Check 4 — No path loading / JSON parsing / runtime authority authorized

**Result: PASS.**

The non-authorization section of C1-A explicitly lists, without qualification:

```text
CLI implementation
CLI flags
path loading
JSON parsing in CLI
profile finalization, discovery, inference, or defaulting in CLI/API
loader/report implementation
CompatibilityReport compiler-profile section
.igapp golden migration
.ilk
CompilationReceipt links
signing
compiler dispatch migration
RuntimeMachine binding
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP production executors
production cache
production behavior
```

This list matches the non-authorization language of R47-C3-A and extends it
with "Gate 3 widening." No surface is missing. No qualifier weakens the
prohibition (no "until B3 closes" or "except for design purposes").

### Check 5 — Artifact evidence not overstated beyond R48 proof

**Result: PASS.**

Every claim in C1-A's "Accepted B1 Evidence" section is directly traceable to
R48-C1-I output or R48-C2-X independent verification:

| Claim in C1-A | Source in R48 |
| --- | --- |
| `artifact.kind=compiler_profile_id_source` | R48-C1-I proof output + C2-X independent read |
| `artifact.status=finalized` | R48-C1-I proof output + C2-X independent read |
| `artifact.wrapper=false` | C2-X independent read |
| `slot_count=12` | C2-X independent read (12 canonical slots) |
| `runtime_authority_granted=false` | R48-C1-I + C2-X (matches V6/V7 checks) |
| `dispatch_migration_authorized=false` | R48-C1-I + C2-X |
| All 5 required summary fields | R48-C1-I summary output, C2-X verified |
| `validation_path=finalization_and_assembler_source_contract` | R47-C3-A Amendment 1 requirement, R48-C1-I summary |
| `forbidden_hits=0` | R48-C1-I + C2-X independent scan |
| `27/27 PASS + 19/19 PASS` | R48-C1-I command matrix |
| Pressure verdict `proceed`, no blockers | R48-C2-X verdict |

C1-A adds no new evidence claim that exceeds what R48 produced. The gate
decision is a precise synthesis of existing evidence, not a widening of it.

C1-A explicitly cites R47-C3-A Amendment 1 by name and confirms it is
satisfied: "`standalone_artifact_valid: true` is not a JSON-only,
field-presence-only, or top-level-shape-only check. It is tied to the same
compiler-profile-source validation path used by the finalization proof and
assembler source contract." This is the exact Amendment 1 requirement — the
gate restates it as satisfied, not paraphrases it away.

---

[Agree]

1. **The gate structure is correct.** An Architect gate document in `docs/gates/`
   issued by `[Architect Supervisor / Codex]` is the appropriate authority
   carrier for a formal blocker closure. The evidence chain
   `C1-I → C2-X → C1-A` follows the expected track → pressure → gate pattern
   and no step self-authorizes.

2. **The closure basis is precise and traceable.** Six closure items, each
   naming a checkable artifact property. The gate recites R47-C3-A Amendment 1
   verbatim and confirms it is satisfied. No imprecise or aspirational language
   in the closure section.

3. **The implementation hold is expressed redundantly.** It appears in the
   document status field, the decision body, and the non-authorization section.
   Redundant encoding of the hold reduces the risk of the gate being misread
   as authorization after B1 is removed from the open-blocker list.

4. **The non-authorization list is exhaustive.** It covers the full R47-C3-A
   surface inventory and adds "Gate 3 widening." No common drift path (path
   loading, JSON parsing, runtime authority) is absent.

5. **The remaining-blockers list is explicit and enumerated.** B3/B4/B5/B6/B9
   are named individually. No fuzzy "remaining blockers remain open" without
   identification.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

Nothing required for the B1 closure decision itself.

---

[NB-1 — Non-blocking: B2 status recorded without gate citation]

C1-A contains the phrase:

> "PROP036-CLI-B2 remains satisfied by the existing design route, but this
> decision does not re-open or re-authorize it."

This is accurate but informal. The gate does not cite the document path that
carries B2 closure authority
(`prop036-cli-exposure-design-and-blocker-tracking-decision-v0.md` or
`prop036-cli-blocker-closure-criteria-decision-v0.md`). A future reader of
C1-A in isolation cannot trace B2's formal status without knowing to look at
the R45/R46 gate chain.

This is not a blocker on B1 closure — C1-A is not a B2 closure decision.
But the B2 parenthetical adds an untraced status claim to a gate document.
Future decisions that enumerate closed/open blockers should cite the authorizing
gate path for each closed blocker, not just name it as satisfied.

---

[Sharper Question]

With B1/B7/B8 formally closed, the remaining five blockers
(B3/B4/B5/B6/B9) are the CLI implementation gate. Is a consolidated blocker
closure card for B3/B4/B5/B6 the correct next shape, or should B6's adversarial
scanner self-test (C3-A Amendment 2) be separated into its own track first given
the additional fixture complexity it requires?

---

[Route]

**Verdict: proceed.**

No blockers. All five scope checks pass. The Architect gate correctly closes B1
with gate authority, mirrors the R48 evidence without overclaim, holds
implementation explicitly, names the remaining five blockers, and prohibits every
forbidden surface. The NB-1 B2 citation gap is documentation debt only — it does
not affect the validity of B1's formal closure.

For R50:
- Recommended next shape: single CLI implementation card bundling B3/B4/B5/B6
  closure proofs, with B6 adversarial scanner self-test as a named sub-deliverable
  per C3-A Amendment 2.
- B9 may follow the implementation card, as its criteria depend on B3/B6 surface
  being defined.
- B2 gate citation debt may be resolved in a status curation pass, not a new
  gate.

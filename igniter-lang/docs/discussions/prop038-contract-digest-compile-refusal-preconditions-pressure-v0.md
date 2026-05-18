# Discussion: PROP-038 Contract Digest Compile-Refusal Preconditions Pressure v0

Card: S3-R75-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-contract-digest-compile-refusal-preconditions-pressure-v0

---

## Purpose

Pressure-review the PROP-038 `contract_digest` compile-refusal preconditions
design before Architect decision.

---

## Inputs Read

- `igniter-lang/docs/tracks/prop038-contract-digest-compile-refusal-preconditions-design-v0.md` (S3-R75-C1-P1)
- `igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md` (S3-R74-C3-A)
- `igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md` (S3-R71-C3-A)
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`

---

## Scope Checks

### Check 1 — Design does not enable compile refusal

**Pass.**

C1-P1 is unambiguous on three independent levels:

**Scope statement:** "This track is design-only. It does not enable compile
refusal, edit code, change compiler/orchestrator behavior, widen public API/CLI
behavior, mutate `.igapp` artifacts, or centralize diagnostics."

**Non-Authorization Preserved:** explicitly lists "enabling compile refusal" as
a non-authorization item among 14 named non-authorizations.

**Blockers table:** 9 items all marked "Not met" and all required before any
refusal implementation authorization. The minimum gate rule states:

```text
No compile refusal may be authorized until explicit-contract strict mode,
compiler status semantics, and user-facing diagnostics are designed and accepted.
```

No code was changed. The design cannot enable refusal by design review alone.

---

### Check 2 — Five distinct vocabulary layers remain separate

**Pass.**

C1-P1 Vocabulary Separation table explicitly assigns each layer a distinct
meaning and current status:

| Layer | Current Status |
| --- | --- |
| Contract-object invalidity | Live in validator result |
| Report-only validation diagnostics | Live, in-memory, no compile effect |
| Compiler compile refusal | **Closed. Not authorized.** |
| Loader/report status | Separate vocabulary; not opened here |
| Runtime/production readiness | Separate runtime gates; not opened here |

The core rule is stated directly:

```text
compiler_profile_contract.* diagnostic != compile refusal
```

The design explains: "The diagnostic may become evidence for a future refusal
decision only after a separate compiler/orchestrator gate defines the refusal
mode, source, status, user-facing wording, and proof matrix."

This correctly separates evidence from authorization. A validator diagnostic
becoming evidence for a possible future refusal does not authorize that refusal.

---

### Check 3 — Refusal candidates are justified and not over-broad

**Pass.**

The Refusal Candidate Matrix covers all four digest codes with appropriate
restrictiveness gradations:

| Code | Classification | Condition Required |
| --- | --- | --- |
| `contract_digest_invalid` | Conditional candidate | Explicit strict mode + Hash contract + user-facing wording |
| `contract_digest_policy_unsupported` | Conditional candidate | Explicit public policy selection exists |
| `contract_digest_mismatch` | Strongest conditional candidate | Explicit strict mode + recompute succeeds + stable |
| `contract_digest_recompute_unavailable` | **Hold by default** | Explicit fail-closed strict mode + wording + operational recovery |

No candidate is "open" or "authorized" — all four are gated behind conditions
that do not currently exist.

The classification hierarchy is correct from a refusal-pressure lens:

- `contract_digest_mismatch` is correctly identified as the strongest future
  candidate: shape is valid, recomputation succeeded, declared identity
  contradicts canonical material — this is a genuine identity contradiction
  rather than a configuration or capability issue.

- `contract_digest_recompute_unavailable` is correctly held as "Hold by
  default": an internal canonicalizer failure should not silently break compiles
  for callers who have no visibility into canonicalization logic. The design
  requires a fail-closed operational policy and user recovery story before this
  could ever be opened.

The scope is explicitly not over-broad: "Initial refusal consideration should
be limited to digest diagnostics. Broader PROP-038 contract-object invalidity
requires a separate gate." This correctly prevents `missing_required_slot`,
`rule_cycle`, `runtime_authority_forbidden`, and the other structural codes from
being swept into a future refusal decision through this design path.

---

### Check 4 — Nil/non-Hash/provider-error paths remain legacy/no-field

**Pass.**

C1-P1 Explicit Supply Requirement section provides an explicit stance for every
current report-only provider path:

| Path | Future Precondition Stance |
| --- | --- |
| No provider | Must remain non-refusal |
| Provider returns nil | Must remain non-refusal unless separate explicit required-profile source exists |
| Provider returns non-Hash | Must remain non-refusal unless separately authorized |
| Provider raises | Must remain non-refusal unless fail-closed provider policy separately authorized |
| Validator raises | Must remain non-refusal unless separately authorized |

All five paths require separate explicit authorization before they can ever
become refusal. The design states: "Future refusal must not reinterpret these
current legacy paths as refusal. This prevents report-only provider plumbing
from silently becoming a compile gate."

This is the correct pattern for refusal-pressure: the report-only plumbing (the
provider constructor-injection) was added in R67 as a non-refusal path. Allowing
any nil/exception path to drift into refusal without a separate gate would
silently change compile behavior for existing callers. The explicit five-row
stance prevents that.

---

### Check 5 — Proof requirements are strong enough before any future implementation

**Pass.**

C1-P1 Required Proof Matrix defines three distinct proof layers plus a command
matrix:

**Baseline Legacy Proof (5 required cases):**

| Case | Expected |
| --- | --- |
| No provider | Compile result unchanged |
| Nil provider | Compile result unchanged; no validation field |
| Non-Hash provider | Compile result unchanged; no validation field |
| Provider exception | Compile result unchanged; no validation field |
| Validator exception | Compile result unchanged unless explicit fail-closed authorized |

This layer requires proving that all legacy paths survive unchanged. It must
exist even before a refusal mode is opened.

**Report-Only Preservation Proof (4 required cases):**
All four digest codes in report-only mode — compile status unchanged in each.
This layer ensures the accepted R71/R74 invariants survive any future
orchestrator changes made to enable a strict mode.

**Strict-Mode Refusal Proof (6 required cases, only if strict mode authorized):**
Explicitly gated: "Future refusal proof commands must be added only after a
refusal design gate authorizes a proof-local refusal model." The six cases
cover: valid digest success, mismatch refusal, malformed digest refusal,
unsupported policy, recompute unavailable, and unrelated structural diagnostic
(the last case prevents future scope creep — a structural error must not become
refusal unless a broader contract invalidity gate opens).

**Boundary Proof (7 required checks):**
Covers: top-level diagnostics, `CompilerResult`, assembler, `.igapp`,
loader/report, `IgniterLang::Diagnostics`, runtime/production.

**Command Matrix:**
6 current regression commands that must remain PASS. These are the existing
accepted proof suite — any future refusal implementation must not regress them.

The proof matrix is layered correctly: legacy proof and report-only preservation
are required even before refusal opens; strict-mode proof is gated; boundary
checks are categorical.

---

### Check 6 — No forbidden surfaces implied

**Pass.**

Physical status of the design card: no code changed, no experiments run.

Public API And CLI Shielding section explicitly lists six paths that must not
silently enable refusal:

```text
default compile behavior
implicit provider presence
environment discovery
.igapp manifest side effects
loader/report interpretation
runtime readiness checks
```

Any caller-visible entry point for future refusal must receive separate
authorization for six named attributes (source shape, strictness mode, diagnostic
wording, default behavior, failure status, compatibility policy).

C1-P1 Non-Authorization Preserved lists: no code implementation, no compile
refusal, no compiler/orchestrator changes, no public API/CLI widening, no
`CompilerResult`, no persisted reports, no parser/TypeChecker/SemanticIR/
assembler/`.igapp`, no loader/report, no CompatibilityReport, no
`IgniterLang::Diagnostics`, no RuntimeMachine/Gate 3/production.

---

### Check 7 — Explicit source requirement is precise enough

**Pass.**

C1-P1 Required Evidence section item 1 ("Explicit source") lists five possible
future sources without authorizing any:

```text
internal orchestrator option
accepted public API option
accepted CLI flag
accepted manifest/profile policy
accepted gate-controlled profile requirement
```

And explicitly states: "This track does not choose or authorize any of those
sources."

This is the correct design stance: enumerate the design space, commit to none.
Any future refusal implementation that tries to piggyback on an existing path
(e.g., "use the provider plumbing" or "check the manifest") would still need to
show which named source was authorized and by which gate.

---

### Check 8 — Blocker list is complete and actionable

**Pass.**

The 9 blockers are each genuinely unmet and each correctly named:

| Blocker | Why genuinely unmet |
| --- | --- |
| No accepted strict profile/contract requirement source | Correct — no such source authorized anywhere in the R57–R74 gate chain |
| No compiler/orchestrator refusal status design | Correct — `compiler_orchestrator.rb` is still untouched; no refusal status model exists |
| No user-facing diagnostic wording design | Correct — the accepted vocabulary is proof/design vocab, not user-facing compiler messages |
| No accepted fail-open/fail-closed policy for recompute unavailable | Correct — this requires an operational decision not yet made |
| No proof-local strict-mode refusal matrix | Correct — strict mode has never been modeled in any proof script |
| No authorization to change compiler/orchestrator behavior | Correct — closed since R66 |
| No authorization to change public API/CLI behavior | Correct — closed since R64 |
| No authorization to change `CompilerResult` | Correct — closed since R62 |
| No authorization to write refusal reports or persisted sidecars | Correct — closed since R62 |

All 9 are genuine blockers that a future implementation gate would need to
explicitly close before compile refusal could be authorized.

---

## Non-Blocking Notes

None.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: none
```

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- all 8 scope checks pass;
- compile refusal remains firmly closed: the design does not enable it, does not
  authorize it, and requires 9 blocking conditions to be met before any future
  gate could open it;
- five vocabulary layers (contract-object invalidity, report-only diagnostics,
  compiler refusal, loader/report, runtime readiness) are kept explicitly
  separate with current-status annotations;
- `contract_digest_mismatch` is correctly identified as the strongest future
  refusal candidate without opening it; `contract_digest_recompute_unavailable`
  is correctly held as the weakest candidate;
- all five nil/non-Hash/provider-error legacy paths are explicitly protected
  with "Must remain non-refusal unless separately authorized" stances;
- proof matrix is three-layered: legacy preservation (required before refusal),
  report-only preservation (required before refusal), strict-mode refusal
  (gated, only after separate design authorization);
- the design correctly bounds refusal to digest diagnostics only and explicitly
  gates broader contract-object invalidity refusal separately;
- no code was changed; no forbidden surfaces were implied.

Recommended next route:

```text
hold compile-refusal implementation; optionally open a separate design card for
strict profile/contract requirement source and user-facing refusal wording.
```

This matches the C1-P1 recommendation exactly and is appropriate: the
preconditions are now documented, the blockers are explicit, and the next step
only opens if Architect decides to invest in a strict-mode design.

---

## Handoff

```text
Card: S3-R75-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-contract-digest-compile-refusal-preconditions-pressure-v0
Status: done

[D] Decisions
- All 8 scope checks pass.
- Compile refusal correctly held closed with 9 named blockers all unmet.
- Vocabulary separation verified across all five distinct layers.
- Refusal candidate hierarchy verified: mismatch strongest, recompute_unavailable
  held by default, all four codes conditional only.
- Nil/non-Hash/provider-error paths protected with five explicit stances.
- Proof matrix is three-layered and correctly gated.

[S] Signals
- The design is a clean preconditions record. It correctly describes where the
  project is (no refusal, no refusal design) and what must happen before any
  refusal gate could open.
- No leaked authority paths identified.

[T] Tests / Proofs
- Review-only. No code or experiments were run or edited.

[R] Recommendation
- C3-A: accept; compile refusal remains closed; hold implementation; optionally
  open separate strict-mode source and wording design if Architect chooses.
```

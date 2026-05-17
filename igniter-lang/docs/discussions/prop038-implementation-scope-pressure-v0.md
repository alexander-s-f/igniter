# Discussion: PROP-038 Implementation Scope Pressure v0

Card: S3-R62-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-implementation-scope-pressure-v0

Depends on: S3-R62-C1-P1 delivered

Question:

Are candidate write surfaces exact enough for an implementation decision? Does
the survey avoid granting implementation authority by implication? Is the
recommended first implementation mode conservative enough? Are digest input and
short-vs-full reference questions handled before code? Are report-only versus
compile-refusal boundaries explicit? Are persistence, fixture, and golden impacts
explicit? Is missing-`after` coverage placed in the right future proof layer? Are
loader/report, CompatibilityReport, dispatch, runtime, Gate 3, production,
Ledger/TBackend, BiHistory, stream/OLAP, and cache still closed?

Context:
- R61-C3-A (gate): Accepted PROP-038 as proposal-only; held implementation;
  authorized scope survey only; required exact write surfaces, recommended first
  boundary, and blocker list before any code authorization
- R62-C1-P1: Implementation Agent — survey-only; no code or experiment edits;
  10-row write-surface table (A–J); 8 policy blockers (B1–B8); recommended
  first boundary is proof-local only; report-only and refusal-capable held

---

## Scope Check 1 — Candidate Write Surfaces Are Exact Enough

The survey provides a 10-row write-surface options table (Options A through J).
Each row names an exact candidate:

| Option | Write surface | Recommendation |
|---|---|---|
| A | `igniter-lang/experiments/compiler_profile_contract_proof/` | **Best first boundary** |
| B | New `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | Good second step |
| C | `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | Hold |
| D | `igniter-lang/lib/igniter_lang/compilation_report.rb` | Hold |
| E | `igniter-lang/lib/igniter_lang/diagnostics.rb` | Optional with B/C/D only |
| F | `igniter-lang/lib/igniter_lang/compiler_result.rb` | Do not use |
| G | `igniter-lang/lib/igniter_lang/assembler.rb` | Do not use |
| H | `igniter-lang/lib/igniter_lang.rb` | Do not use |
| I | `igniter-lang/lib/igniter_lang/cli.rb` | Do not use |
| J | `.igapp`, goldens, receipts, `.ilk`, signing | Do not use |

Every option names either a specific file path or a specific artifact surface.
No option is described only as a category or a vague area. ✓

The recommendations are clearly tiered: A first, B second, C/D held, E optional
only with B/C/D authorization, F–J excluded. This gives an implementation
authorization card an exact set of permitted surfaces to pick from. ✓

**Critical blocking observation for Options C and D** is correctly stated:

> "no current contract input; report schema and persistence location unresolved;
> may create public behavior if exposed through `CompilationReport` or
> `CompilerResult`; insertion point is ambiguous until contract input ownership
> is resolved."

This correctly identifies why report-only compiler integration needs more than
"validator passes" — it requires a contract input path that doesn't currently
exist in the compiler's public API. ✓

---

## Scope Check 2 — Survey Does Not Grant Implementation Authority By Implication

The track opens with: "This track edits no code and no experiments. It prepares
an implementation authorization boundary only." ✓

The handoff states explicitly:
- "No implementation performed."
- "No code edited."
- "No experiments edited."
- "Candidate write surfaces are mapped."

The survey's recommendation is phrased in future-authorized terms: "authorize
edits only under `igniter-lang/experiments/compiler_profile_contract_proof/`" —
"authorize" is future-tense, not self-authorization. ✓

The blocker list (B1–B8) is structured as preconditions to a future
authorization card, not as work items within this survey. B3 explicitly says
"Authorize one first behavior" — correctly framing the authorization as a
separate Architect decision. ✓

No writing-surface option in the table implies it is currently authorized. Every
"recommended" option is phrased as a future authorization recommendation. ✓

---

## Scope Check 3 — Recommended First Implementation Mode Is Conservative

The survey recommends "proof-local only" (Option A) with the verdict:

```text
recommended first implementation boundary
```

The proof-local boundary constrains:
- edits only to the existing proof experiment directory;
- no production compiler behavior;
- no public API or CLI widening;
- no artifact or golden mutation.

The four-mode comparison is correctly calibrated:

| Mode | Verdict |
|---|---|
| Proof-Local Only | **Recommended first boundary** |
| Report-Only Compiler Integration | Hold until input/output policy resolved |
| Compile-Refusal Capable | Not ready |
| Hold For More Design | Not necessary if first card is proof-local |

The "Compile-Refusal Capable" verdict correctly anchors to the acceptance gate:
"acceptance decision explicitly holds implementation." ✓

The escalation ladder is clear:
```text
proof-local first
  -> report-only only after report schema approval
  -> refusal only after dedicated gate
```

This is the most conservative appropriate starting point: it closes the
missing-`after` coverage gap (which is a genuine proof-completeness need) without
touching any production compiler behavior. ✓

**The "Report-Only Compiler Integration" hold rationale is the most important
finding in the survey.** It identifies a structural gap not visible from the
PROP alone: the current compiler receives only `compiler_profile_source`
(finalized source), not a `compiler_profile_contract` object. For report-only
integration to work without API widening, the orchestrator would need either:
1. a new internal contract input (requires widening decision);
2. contract construction from the finalized source (requires business logic);
3. or the validation to run before compiler invocation (proof-local pattern).

Option 3 is what Option A implements. The survey correctly concludes that
without resolving contract-input ownership first, Options C and D cannot
be safely authorized. ✓

---

## Scope Check 4 — Digest Questions Are Handled Before Code

**Descriptor Digest Input Material (B1):**

The survey identifies four open sub-questions:
1. Exact object/material computed over by `descriptor_digest`
2. Canonical serialization rules
3. Whether `descriptor_digest` itself is excluded from the hashed material
4. Whether the source is the descriptor object, contract projection, or finalized profile descriptor payload

Required before implementation authorization: "Define descriptor_digest canonical
input material exactly."

This is more specific than PROP-038 §9.1 (which only says the digest "identifies
the canonical compiler profile descriptor") and responds correctly to R61-C2-X
NB-1. ✓

**Short-Vs-Full Digest Reference Policy (B2):**

Open state: PROP-038 accepts 24+ hex for descriptor and contract digests; proof
uses short references; durable storage may need full 64-character.

Recommended policy:
- proof-local: keep PROP-038-compatible 24+ validation
- persisted/durable: prefer full 64-character SHA-256 unless gate approves short

This directly resolves R61-C2-X NB-2 at the policy level. ✓

Both B1 and B2 are listed as blockers before implementation authorization. The
proof-local Option A could keep short references, but the survey explicitly gates
durable output on B2 resolution. ✓

**Ordering concern (see NB-1).** B1 (descriptor digest input material) has four
open sub-questions but the survey provides no recommended answer for any of them
— it only says "Define exactly." For the proof-local first card (Option A), the
proof already uses proof-local projection behavior that works without a normative
input definition. So B1 is technically a blocker only before persisted or
compiler-integrated behavior. The survey does not distinguish B1 severity between
proof-local and persisted contexts. This could be clarified in the authorization
card scope: B1 is a blocker for persisted/integrated behavior, not necessarily
for extending the proof-local experiment itself if the proof-local approach keeps
the existing projection logic. Non-blocking for the scope survey itself.

---

## Scope Check 5 — Report-Only Versus Compile-Refusal Boundaries Are Explicit

The survey provides a dedicated "Report-Only Versus Compile-Refusal" policy
blocker (B3) with a three-level recommended policy:

```text
first implementation: proof-local only
second step: report-only only after report schema approval
refusal: hold for a dedicated gate
```

The "Compile-Refusal Capable" comparison section gives a four-item blocker list
specific to that mode:
- acceptance decision explicitly holds implementation
- refusal behavior is a new compiler behavior
- digest material, length, diagnostic placement, report shape, and insertion
  point are unresolved
- would risk unauthorized widening if contract input is public

This is not just "refusal is not allowed" — it explains WHY each blocker exists.
A future gate for refusal authorization will know exactly what must be resolved
first. ✓

The "Report-Only Compiler Integration" hold blockers are also specific:
- no authorized contract input surface
- report schema and persistence location undecided
- may create public behavior through `CompilationReport` or `CompilerResult`
- insertion point ambiguous until contract input ownership is resolved

These four blockers correctly map to exactly the right set of policy decisions
that must precede any report-only compiler integration card. ✓

---

## Scope Check 6 — Persistence, Fixture, And Golden Impacts Are Explicit

**Persistence / Output Location (B4):**

Options listed: proof summary only, compilation report metadata, sidecar, receipt,
`.ilk`, `.igapp`, or none.

Required: "Choose whether there is no persisted output, proof summary only,
compilation report metadata, sidecar, receipt, `.ilk`, `.igapp`, or none."

Recommended: "first implementation should use proof summary only; do not mutate
`.igapp` or goldens." ✓

**Fixture / Golden Policy (B5):**

Open questions: "whether future fixtures live in experiments only or production
specs; whether any golden output must be updated."

Required: "Authorize fixture location and explicitly state whether golden mutation
is allowed."

Recommended: "proof-local fixtures only for first card; no golden migration." ✓

Both B4 and B5 are blocker-level items. The recommendations for both align
with the proof-local Option A boundary — no artifact mutation for the first card.
The write-surface table Option J ("`.igapp`, goldens, receipts, `.ilk`, signing")
is marked "Do not use" for first implementation. ✓

---

## Scope Check 7 — Missing-`after` Coverage Is In The Right Layer

The survey addresses missing-`after` coverage in two places:

**Existing Proof section:**
> "It still needs explicit missing-`after` `missing_rule_reference` coverage
> before or with first implementation authorization."

**Policy Blockers (B6):**
> Required: "Add proof-local missing-`after` `missing_rule_reference` coverage."
> Recommended placement: "`igniter-lang/experiments/compiler_profile_contract_proof/`
> in a future authorized proof-local implementation card."

The placement is correct: the experiment directory (Option A) is the right layer.
Not the production validator (Option B), not the orchestrator (Option C). ✓

The timing is correctly phrased as "before or with first implementation
authorization" — meaning it can be done in the same first proof-local card rather
than requiring a separate proof round. The R61-C2-X NB-1 concern about the
before-direction-only test is addressed at the right granularity: it belongs in
the same first card, not in a separate future round. ✓

---

## Scope Check 8 — All Forbidden Surfaces Remain Closed

The "Preserved Closed Surfaces" section names every required surface:

- parser, TypeChecker, SemanticIR changes ✓
- assembler or `.igapp` changes ✓
- CLI/API widening ✓
- profile discovery/defaulting/finalization ✓
- golden migration ✓
- loader/report ✓
- CompatibilityReport ✓
- `.ilk`, receipts, signing ✓
- dispatch migration ✓
- RuntimeMachine / Gate 3 widening ✓
- Ledger/TBackend ✓
- BiHistory ✓
- stream/OLAP ✓
- cache ✓
- production behavior ✓

The write-surface table reinforces this: Options G (assembler), H (public Ruby
facade), I (CLI), and J (artifacts/signing) are all marked "Do not use" or "Do
not use for first implementation." ✓

The "Not candidates" list for compiler/orchestrator insertion points explicitly
excludes: parser, classifier, TypeChecker, SemanticIR emitter, assembler, CLI,
public Ruby facade. ✓

---

## Additional Integrity Check: Blocker Table Is Well-Formed

The 8-blocker list (B1–B8) covers distinct concerns without overlap:

| Blocker | Layer | Distinct from others? |
|---|---|---|
| B1 Descriptor digest input material | Spec completeness | ✓ (NB-1 from R61-C2-X) |
| B2 Short-vs-full digest policy | Implementation policy | ✓ (NB-2 from R61-C2-X) |
| B3 Report-only vs. refusal | Compiler behavior authorization | ✓ (scope decision) |
| B4 Output location | Persistence policy | ✓ (artifact layer) |
| B5 Fixture/golden policy | Test infrastructure | ✓ (spec layer) |
| B6 Missing-`after` coverage | Proof completeness | ✓ (NB-1 from R60-C2-X) |
| B7 Diagnostic namespace placement | Code architecture | ✓ (validator design) |
| B8 Orchestrator insertion point | Integration architecture | ✓ (requires B3 first) |

B1 and B2 are the most urgent because they block even the proof-local first card
(a proof that uses incorrect digest input assumptions or wrong reference-length
policy is building on a specification gap). B3 must be resolved to authorize any
card. B4 and B5 are required before any output changes. B6 belongs in the same
first card. B7 and B8 are relevant only for compiler integration (Options C/D),
which is held pending B3/B4/B8 resolution.

The blockers correctly reference the accepted PROP-038 gate as the authority that
"explicitly holds implementation" (B3) — preventing a future card from treating
the scope survey as implicit authorization. ✓

---

[Agree]

1. **Write surfaces are precise and actionable.** Ten specific file paths or
   artifact surfaces, each with a clear recommendation tier. The authorization
   card can reference this table directly.

2. **Proof-local first boundary is correct.** It closes the missing-`after` gap
   (genuine proof-completeness need) without touching any production compiler
   behavior or requiring contract input API decisions.

3. **The contract-input structural gap is the most important finding.** Identifying
   that report-only integration requires contract input ownership to be resolved
   first prevents a future card from attempting premature compiler integration
   under the assumption that report-only is simply "less risky than refusal."

4. **All eight policy blockers are distinct and correctly layered.** B1/B2 for spec
   gaps, B3 for behavior authorization, B4/B5 for output policy, B6 for proof
   completeness, B7/B8 for integration architecture.

5. **Missing-`after` placement is exactly right.** Same first card as Option A,
   proof experiment only. No separate proof round needed.

6. **All forbidden surfaces are closed and cross-referenced.** Both in the
   "Preserved Closed Surfaces" list and in the write-surface table's "Do not use"
   recommendations.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

[NB-1 — Non-blocking: B1 severity not distinguished between proof-local and persisted contexts]

The survey lists "Define descriptor_digest canonical input material exactly" as a
blocker (B1) without specifying whether it must be resolved before a proof-local
card or only before persisted/compiler-integrated behavior.

For the proof-local first card (Option A), the existing proof experiment already
uses a proof-local projection method for `descriptor_digest` that works without a
normative input definition. Extending the proof experiment (adding missing-`after`
coverage, adjusting short/long reference handling) does not require resolving B1
unless the extension introduces new digest comparison behavior that wasn't in the
existing proof.

For Options B, C, D (compiler integration modes, all held), B1 is a genuine
blocker because those paths would compute or verify digests against real compiler
objects.

Recommendation for the authorization card: scope B1 as a blocker for persisted/
compiler-integrated behavior, and note that the proof-local Option A can proceed
with the existing proof-local projection approach unless the proof explicitly
tests digest input material correctness.

Non-blocking for the scope survey. The authorization card should address this
scoping.

---

[NB-2 — Non-blocking: B7 diagnostic namespace placement lacks a recommended answer for the proof-local case]

B7 asks whether diagnostics remain local to a validator or are centralized in
`IgniterLang::Diagnostics`. The recommended policy says "proof-local validator
first; optional production helper only when an integrated validator is authorized."

For the proof-local Option A first card, this means diagnostics stay inside the
proof experiment script — consistent with how the existing proof works. This is
the right answer but it is implied rather than stated. A future authorization card
might ask "where do the `compiler_profile_contract.*` diagnostic constructors
live?" and the answer from B7 is "inside the proof script for the first card."

Non-blocking. The authorization card should make this explicit.

---

## Verdict

**Proceed.**

All eight scope checks pass. The write-surface table provides exact file paths
with clearly tiered recommendations. The survey does not grant any implementation
authority. The recommended first boundary (proof-local, Option A) is the most
conservative appropriate choice and correctly identifies the structural gap that
blocks report-only integration. Both digest policy questions (B1, B2) are named
as blockers, directly resolving the R61-C2-X NB-1 and NB-2 follow-through.
Report-only versus compile-refusal is stated as a three-level escalation with
exact blockers at each level. Persistence, fixture, and golden impacts all have
recommended policies (proof summary only; no golden mutation). Missing-`after`
coverage is placed correctly in the same first proof-local card. All forbidden
surfaces are named in both the closed-surface list and the write-surface table.

Two non-blocking notes: NB-1 (B1 descriptor digest severity not scoped between
proof-local and persisted contexts — authorization card should clarify); NB-2
(B7 diagnostic placement implies proof-local but should be stated explicitly in
the authorization card).

---

[Route]

**Verdict: proceed.**

No blockers.

**Recommended Architect decision (C3-A):**

1. Accept the R62 implementation scope survey as the precondition record for
   any future implementation authorization. The 10-row write-surface table and
   8-blocker list are sufficiently precise for an authorization decision.

2. Authorize only a first proof-local implementation card:
   - permitted surfaces: `igniter-lang/experiments/compiler_profile_contract_proof/`
     (Option A);
   - must include missing-`after` `missing_rule_reference` coverage (B6);
   - must not touch production compiler paths, CLI, public Ruby facade,
     assembler, `.igapp`, goldens, receipts, or any closed surface;
   - keep diagnostics inside the proof script (B7 for proof-local context);
   - short digest references (24+ hex) remain valid for proof-local output (B2
     proof-local arm).

3. Hold report-only compiler integration until B3, B4, B8 (and minimally B1 for
   digest correctness) are resolved in a separate authorization decision.

4. Hold compile-refusal capability until a dedicated gate explicitly authorizes
   refusal behavior.

5. Before the first proof-local card is written, resolve:
   - B2: explicitly confirm that proof-local summaries may keep 24+ hex
     references and that durable/persisted outputs will require full 64-character
     references;
   - B1: clarify that the proof-local projection approach is sufficient for the
     first card, deferring normative descriptor digest input material specification
     to the report-only or compiler-integration authorization card (NB-1).

6. Before any report-only compiler integration authorization:
   - resolve B1 (descriptor digest input material);
   - decide B3 (report-only behavior authorized, with report schema location);
   - decide B4 (output location — report field vs. sidecar vs. proof-local
     summary);
   - decide B8 (orchestrator insertion point after contract input ownership is
     resolved).

7. All other surfaces (loader/report, CompatibilityReport, dispatch, Gate 3,
   runtime, Ledger/TBackend, BiHistory, stream/OLAP, cache, production) remain
   closed.

**For R63:**
- If C3-A authorizes the first proof-local card, R63 runs that card under
  Option A scope only.
- The authorization decision should state whether B1 applies to the first card
  or only to later integration cards (NB-1).
- No report-only or refusal-capable compiler work opens from R62.

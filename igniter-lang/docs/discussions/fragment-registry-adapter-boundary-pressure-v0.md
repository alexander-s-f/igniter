# Fragment Registry Adapter Boundary Pressure v0

Card: S3-R145-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Route: UPDATE
Track: fragment-registry-adapter-boundary-pressure-v0
Status: complete
Date: 2026-05-22

---

## Goal

Pressure-review the S3-R145 adapter boundary design (C1/C2) for hidden
implementation, authority drift, live classifier behavior drift, and accidental
public/runtime surface widening.

---

## Evidence Read

- `docs/tracks/fragment-registry-adapter-implementation-boundary-design-v0.md`
  (S3-R145-C1-P1)
- `docs/tracks/fragment-registry-adapter-evidence-and-risk-map-v0.md`
  (S3-R145-C2-P1)
- `docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md`
  (LANG-R144-P1)
- `docs/tracks/fragment-precedence-resolution-design-v0.md` (LANG-R143-D1)
- `docs/tracks/fragment-precedence-parity-proof-v0.md` (LANG-R142-P1)

No code was edited. No proof commands were run.

---

## Scope Checks

### Check 1 — C1/C2 stay design-only

**Question:** Do C1 and C2 authorize or imply any code writing, classifier
editing, or proof command execution?

**Evidence:**

C1 (implementation boundary design) states explicitly in the opening:

> "This is design-only. It does not edit code, specs, proposals, classifier
> behavior, diagnostics, reports, `.igapp`, PROP-036, PROP-038, runtime,
> production, or Spark behavior."

C1 handoff:

> "[T] No tests were run; this was a design-only track with no code changes."

C2 (evidence and risk map) states in the opening:

> "Assigned track: map evidence, code touchpoints, fixtures, and risk surfaces
> needed before any future fragment registry adapter implementation review."

C2 handoff:

> "[T] Read-only survey only. No tests were required; no code or golden files
> were changed."

C2's changed-files section is absent entirely — there are no changed files
because it is a read-only mapping track.

Both C1 and C2 carry identical closed-surfaces lists that include code
implementation, classifier edits, live dispatch, diagnostics, reports,
`.igapp`, PROP-036, PROP-038, public API/CLI, loader/report,
CompatibilityReport, and all runtime/production/Spark surfaces.

The candidate file name introduced by C1:

```text
lib/igniter_lang/fragment_registry_compatibility_adapter.rb
```

is design-only vocabulary. C1 states: "This file is not authorized by this
track."

**Verdict: PASS**

Both cards are design-only and read-only. No implementation is authorized or
implied.

---

### Check 2 — No live classifier dispatch authorized

**Question:** Does either card implicitly open live classifier dispatch? Does
any wording treat the adapter as already wired?

**Evidence:**

R144 (the proof preceding C1/C2) explicitly carries:

```text
held_live_dispatch: true
```

This flag appears in both the proof summary JSON and the proof matrix JSON, and
is verified by the R144 adapter proof command as a required assertion
(`checks << ["held_live_dispatch", ...]`).

C1's boundary design table states:

> "Does adapter belong in classifier? Conceptually yes, but implementation must
> remain held. First live candidate should be direct-require-only internal
> helper, not wired into `Classifier`."

C1's implementation blockers section requires:

> "classifier wiring is explicitly authorized or explicitly forbidden"

as a pre-condition for any implementation card. This is a blocker, not an
implied opening.

C1's recommendation section states:

> "Do not open classifier wiring, public/report carriers, `.igapp`, runtime, or
> production behavior from this design."

C2's evidence table marks "Live classifier adapter" as a candidate
implementation slice with a "non-authority observations, not implementation
requests" header. The table provides what would be needed for that slice; it
does not authorize it.

Neither C1 nor C2 alters the `contract_fragment_for` method or any classifier
dispatch path. The classifier touchpoint map in C2 is a survey, not a write
scope.

**Verdict: PASS**

Live classifier dispatch remains held. Neither C1 nor C2 authorizes classifier
wiring.

---

### Check 3 — No SemanticIR/report/`.igapp` mutation implied

**Question:** Does any C1/C2 wording imply that the adapter would flow
declaration-fragment presence data into SemanticIR, CompilationReport, or
`.igapp` artifact outputs?

**Evidence:**

C1's representation boundaries table for `declaration_fragment_presence`
classifies:

| Candidate | Status |
| --- | --- |
| `classified_contract` field | Held — "Would mutate goldens/output shape." |
| `CompilationReport` field | Held/rejected — "Would create report carrier and Bridge pressure." |
| `.igapp` manifest/contract artifact | Closed — "Requires assembler/manifest authority and PROP-036 review." |

C1's boundary design table:

> "Does adapter belong in report assembly? No. Reports may not become the source
> of classifier semantics or readiness."
>
> "Can it affect `.igapp`? No. `.igapp`/manifest/goldens remain closed."

C2's hidden mutation risk table explicitly names `.igapp` drift and report
leakage as risks, with required guards for each.

C2's missing evidence table (under "SemanticIR / Report / `.igapp` Parity")
calls out:

> "decision whether presence metadata belongs in SemanticIR at all;
> artifact hash impact analysis;
> assembler proof that selected fragment remains the current artifact driver;
> negative proof that no runtime/CompatibilityReport readiness is implied."

These are listed as missing evidence required before any implementation card,
not as authorized surfaces.

**Verdict: PASS**

SemanticIR, CompilationReport, and `.igapp` surfaces are explicitly closed in
C1 and correctly risk-mapped in C2. No mutation is implied.

---

### Check 4 — Stream and epistemic compatibility cases remain protected

**Question:** Do C1 and C2 preserve the R143/R144 compatibility resolution for
stream-stays-escape and epistemic+escape-stays-escape?

**Evidence:**

R143 established the key design resolution:

> "Keep current selected contract fragment as `escape`; model `stream` as
> declaration/node presence plus stream-specific metadata inside an
> escape-compatible bucket."
>
> "Keep current selected contract fragment as `escape`; preserve `epistemic` as
> declaration presence when assumptions are used."

R144 machine-proved both cases:

- `stream presence recorded → escape selected` PASS;
- `epistemic + escape presence recorded → escape selected` PASS;
- `epistemic-only → epistemic selected` PASS.

C1's required invariant checklist restates these as required proof assertions
for any future implementation card:

> "Stream selected fragment — Stream presence may not change selected fragment
> from `escape`."
>
> "Epistemic + escape selected fragment — Mixed epistemic + escape may not
> change selected fragment from `escape`."

C1's migration risks table names both as explicit risks:

> "Stream — Treating `stream` precedence as selected fragment would drift
> current `escape` bucket. Keep `stream` as presence; selected fragment
> `escape`."
>
> "Epistemic — Linear precedence would make mixed epistemic + escape select
> `epistemic`. Record epistemic presence while selected fragment remains
> `escape` when escape is present."

C2's compatibility behavior map independently confirms both, with references to
the golden files (`stream_ingress_escape.classified.json`,
`assumption_basic.classified.json`) as living proof anchors.

The adapter selection rule in C1/C2 both consistently encode the compatibility
bucketing:

```text
stream present -> escape (not stream)
escape present before epistemic present
```

**Verdict: PASS**

Stream and epistemic compatibility cases are explicitly protected in both C1
(as required invariants) and C2 (as live golden anchors and compatibility
behavior facts).

---

### Check 5 — OOF status-primary semantics remain protected

**Question:** Do C1 and C2 preserve the OOF status-primary / blocked /
non-loadable / non-capability semantics established in the R92–R99 chain?

**Evidence:**

C1's required invariant checklist:

> "OOF projection — OOF remains status-primary, blocked, non-loadable,
> non-capability."

C1's migration risks table:

> "OOF — OOF can look like fragment capability if modeled carelessly.
> Keep status-primary projection; blocked, non-loadable, non-capability."

C1's rejected-locations table explicitly rejects `CompilationReport / report
assembly` as an adapter location, with the reason "Would turn compiler semantics
into report behavior" — this prevents OOF status from leaking into report
carriers.

R144 PASS matrix (source evidence cited by both C1/C2):

> "OOF remains status-primary, blocked, non-loadable, non-capability — PASS"

C2's compatibility behavior map:

> "OOF must not become a capability. Status-primary, blocked, non-loadable,
> non-capability. — PASS"

C2's hidden mutation risk table:

> "OOF capability confusion — Adapter implemented with `oof` as loadable/
> capability fragment. Required guard: Keep OOF policy guard: blocked,
> non-loadable, non-capability."

The OOF policy guard threads consistently from R92 (shadow proof) through R142
(parity proof) through R143 (resolution design) through R144 (adapter proof)
and into C1/C2. The chain is unbroken.

**Verdict: PASS**

OOF status-primary semantics are protected in both C1 and C2, with consistent
guard language and R144 proof anchors.

---

### Check 6 — Public API/CLI, loader/report, CompatibilityReport, runtime, Spark, and production surfaces remain closed

**Question:** Do C1 or C2 imply any widening of public/runtime/production
surfaces — directly or by omission?

**Evidence:**

C1 closed-surfaces list explicitly names 18 closed surface categories, including:

```text
public API/CLI
loader/report
CompatibilityReport
`.igapp`, `.ilk`, manifest, sidecar, golden mutation
PROP-036 behavior mutation
PROP-038 behavior mutation
runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, deployment
```

C2 closed-surfaces list is substantively identical.

C1's boundary design table explicitly rejects `CompilerProfile / PROP-036
carrier` as an adapter location:

> "Would confuse adapter evidence with profile identity."

C1 explicitly rejects `PROP-038 validator`:

> "Would confuse fragment precedence with contract validation/refusal authority."

C1's implementation blockers section names:

> "Bridge pressure is completed before any report/public/manifest/runtime
> carrier opens."

This is a gate condition, not an implied opening.

C2's risk table covers `PROP-036/038 leakage` as a named risk:

> "Required guard: Namespace and report-only separation proof."

No C1 or C2 wording opens or implies any of the listed closed surfaces.

**Verdict: PASS**

All protected surfaces remain explicitly closed. The PROP-036 and PROP-038
separation guards are correctly restated. Bridge review remains a required
pre-condition before any public/runtime carrier can open.

---

## Non-Blocking Notes

**NB-1 — `FragmentRegistryPack` vocabulary alignment:**

C1 states:

> "FragmentRegistryPack owns declaration fragment vocabulary and rows."

The R96-A gate established that `OOFRegistryPack` in R91/R92 proof-local JSON
is a shadow artifact name only, and the forward vocabulary is "OOF registry
service" (kernel/support service, not optional language pack). The R99
design (LANG-R99-D1) restates this distinction explicitly as a blocker before
implementation authorization.

C1's use of `FragmentRegistryPack` in the ownership sentence is ambiguous: it
could mean a pack-as-owner of vocabulary rows (analogous to `InvariantPack`
owning `PINV-*` markers in the OOF registry model), or it could inadvertently
introduce `FragmentRegistryPack` as an optional language pack name parallel to
the shadow artifact name `OOFRegistryPack`.

The C4-A acceptance gate should confirm which interpretation is intended:

- If `FragmentRegistryPack` is pack-as-owner vocabulary (acceptable), a
  clarifying note matching the `InvariantPack`/`TemporalPack` precedent is
  sufficient.
- If `FragmentRegistryPack` is intended as service identity vocabulary, the
  preferred name should follow "fragment registry service" (kernel/support
  service), not `FragmentRegistryPack` (which risks implying optionality).

This is a vocabulary alignment note, not a blocker.

**NB-2 — First-slice surface recommendation divergence:**

C1 recommends:

> "direct-require-only internal helper near classifier/fragment registry
> boundary"

C2 recommends:

> "registry-data-only or proof-local helper first"

Both agree that live classifier dispatch is not the first step. However, the
precise first-slice surface diverges: C1 targets a helper file at the
classifier/fragment-registry boundary; C2 prefers a registry-data-only or
proof-local path that avoids any classifier-adjacent file.

The C4-A acceptance gate (or a future implementation authorization card) should
resolve this divergence explicitly before any implementation card opens.
Leaving both options open simultaneously could allow a future card to choose
the more ambitious C1 route (classifier-adjacent helper) without a clear gate
decision confirming that path over C2's preferred conservative first slice.

This is a design-alignment note, not a blocker.

**NB-3 — Classifier-parity scope for non-wired helpers:**

C1's required invariant checklist includes:

> "Current classifier parity — All observed classifier goldens keep current
> selected `fragment_class`."

C1's implementation blocker for classifier wiring requires:

> "byte-for-byte current classifier output parity"

However, C1 also envisions a first implementation slice that is a
"direct-require-only internal helper" that is "not called by `Classifier` in
the first implementation slice unless a separate classifier wiring gate
authorizes it." If the helper is never wired into the compiler pipeline at all
in the first slice, the byte-for-byte classifier output parity requirement is
trivially satisfied (because the helper cannot affect classifier output). This
creates a risk: a future implementation card could interpret the parity
requirement as weaker than intended for classifier-unwired helpers, deferring
all golden checks.

The implementation card should be explicit on this point: even for a
classifier-unwired helper, the proof matrix should include a full classifier
regression pass to confirm that introducing the new file does not accidentally
change classifier behavior via a load-path side effect or shared state.

This is a proof-scope note, not a blocker.

---

## Verdict

```text
proceed-with-notes
```

6/6 scope checks PASS. No blockers. Three non-blocking notes for C4-A and
any future implementation authorization card to address:

- NB-1: `FragmentRegistryPack` vocabulary alignment (pack-as-owner vs. service
  identity).
- NB-2: First-slice surface recommendation divergence between C1 and C2.
- NB-3: Classifier-parity scope for classifier-unwired helpers.

---

## Exact Blockers Before Implementation Authorization

The following must be satisfied before any implementation card may open (carried
forward from C1's implementation blockers list, no new blockers added by this
review):

1. Architect opens a specific implementation card with exact write scope.
2. Implementation target surface explicitly named: proof-local helper,
   direct-require-only internal helper, registry-data-only, or another surface
   — with the C1/C2 divergence resolved.
3. R144 parity remains accepted.
4. Required invariant checklist converted to executable proof assertions.
5. Root require policy explicit: new helper file must not be required from
   `lib/igniter_lang.rb`.
6. Classifier wiring explicitly authorized or explicitly forbidden for the first
   slice.
7. Output/golden mutation policy explicit.
8. PROP-036 and PROP-038 non-mutation restated in the implementation card.
9. Bridge pressure completed before any report/public/manifest/runtime carrier
   opens.

Additional blockers before classifier wiring (if that route is ever opened):

- byte-for-byte current classifier output parity (full golden regression, not
  just selected fragment counts);
- no change to `contract_fragment_for` semantics unless proven equivalent;
- no `declaration_fragment_presence` field added to `classified_contract`
  without golden update authority;
- parser/typechecker/SemanticIR/assembler regression matrix defined.

---

[Agree]
- C1 and C2 are cleanly design-only and read-only. The two-card structure
  (implementation-boundary design + evidence/risk map) correctly separates
  semantic design authority (C1) from evidence mapping (C2).
- R142 → R143 → R144 adapter proof chain is solid. The two-layer model
  (declaration presence / selected fragment) correctly resolves the R142 HOLD
  cases without live classifier mutation.
- Stream and epistemic compatibility guards are explicit, machine-proved in
  R144, and restated as required invariants in C1.
- OOF status-primary protection threads consistently from R92 through C1/C2.
- All forbidden surfaces are explicitly closed in both cards.

[Challenge]
- `FragmentRegistryPack` vocabulary in C1 is ambiguous relative to the
  established "OOF registry service" / "fragment registry service"
  kernel-vs-optional-pack distinction. C4-A should confirm the intended
  reading before this term propagates.

[Missing]
- Explicit resolution of C1/C2 first-slice divergence (NB-2).
- Classifier-parity scope statement for non-wired helper files (NB-3).
- Neither item blocks the design track; both belong in the implementation
  authorization card.

[Sharper Question]
- When the implementation authorization card opens, will the first slice be
  (a) a direct-require-only internal helper at the classifier/fragment-registry
  boundary that is never called from the compiler pipeline, or (b) a
  registry-data-only update with no new helper file at all? The answer drives
  the proof matrix structure: (a) requires a full classifier regression to rule
  out load-path side effects; (b) requires a different parity surface (registry
  data non-dispatch). Resolving this before the card opens prevents ambiguity
  in the proof scope.

[Route]
- implementation-authorization-review (after the 9 blockers above are
  satisfied, beginning with Architect opening a specific card with exact write
  scope)

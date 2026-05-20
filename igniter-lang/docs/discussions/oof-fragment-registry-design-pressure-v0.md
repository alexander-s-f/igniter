# oof-fragment-registry-design-pressure-v0

Card: LANG-R94-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Track: oof-fragment-registry-design-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/tracks/oof-fragment-registry-ownership-and-canon-semantics-design-v0.md` (LANG-R93-D1)
- `igniter-lang/docs/gates/oof-fragment-registry-shadow-proof-decision-v0.md` (S3-R92-C4-A)
- `igniter-lang/docs/tracks/oof-fragment-registry-shadow-proof-v0.md` (S3-R92-C1-P1)
- `igniter-lang/docs/tracks/oof-fragment-registry-semantics-review-v0.md` (S3-R92-C2-P1)
- `igniter-lang/docs/discussions/oof-fragment-registry-shadow-proof-pressure-v0.md` (S3-R92-C3-X)
- `igniter-lang/docs/tracks/stage3-round92-status-curation-v0.md` (S3-R92-C5-S)
- `igniter-lang/docs/tracks/compiler-pack-shadow-profile-proof-v1.md` (LANG-R91)

---

## Scope Checks

### 1. Write scope is design-only; no code, spec, proposal, canon, or runtime surfaces touched

R92-C4-A authorized only a design-only follow-up route:

```text
Track: oof-fragment-registry-ownership-and-canon-semantics-design-v0
Type: design-only / no implementation / no spec/canon mutation / no live registry / no compiler dispatch
```

R93-D1 delivers a single track document at:

```text
igniter-lang/docs/tracks/oof-fragment-registry-ownership-and-canon-semantics-design-v0.md
```

The R93-D1 handoff section explicitly states:

> Docs-only track; no tests run. No specs, proposals, canon, code, runtime,
> public surfaces, or fixtures edited.

R93-D1's closed-surface list covers:

- specs, proposals, or canon edits;
- compiler/runtime implementation;
- live `OOFRegistry` or `FragmentRegistry` behavior;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator, or dispatch changes;
- public OOF code renames, deletions, promotions, or diagnostic wording changes;
- public API or CLI widening;
- loader/report compiler-profile status;
- CompatibilityReport changes;
- `.igapp` or golden mutation;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend binding;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec/data work or Spark production integration.

The design track is a single markdown file. The evidence-read section lists only existing
docs/tracks and gates (all read-only). No lib/, spec/, proposal, experiments/, gate, or
production file was created or modified.

**Result: PASS**

---

### 2. Kernel service vs. pack-owned descriptor distinction is correctly drawn without optional-pack authority drift

The core risk: if `OOFRegistryPack` were treated as an ordinary optional language pack,
any profile that omitted it would lose the cross-pack uniqueness, alias collision, and
public-stability guarantees. The registry could silently become incomplete without error.

R93-D1 draws the distinction explicitly:

| Concept | Design stance |
| --- | --- |
| registry owner | kernel/support service |
| descriptor owner | pack or support boundary |
| validation scope | complete active compiler profile |
| alias policy | registry-level collision and replacement policy |
| stability policy | descriptor-level field, validated by registry |
| optionality | descriptors may be pack-populated; registry service is not optional |

The "optionality" row is the key anti-drift guard: descriptor entries may be
pack-populated, but the registry service itself is not optional. This prevents a missing
pack from silently voiding cross-pack invariants.

The descriptor ownership rule is precise:

> Each OOF descriptor has exactly one owning pack or support boundary.
> The registry service owns uniqueness, alias resolution, public stability, and
> profile-level exclusion rules.

This correctly separates local pack authority (owns a descriptor entry) from kernel
authority (owns the registry-level invariants). No optional pack can claim registry
authority by installing its own descriptors.

The equivalent rule for the fragment registry is consistent:

> Each fragment row names a fragment owner, but precedence, projection guards, and
> current/candidate/non-fragment classification are validated by the registry service
> as one profile-level table.

R92-C2-P1 semantics review recommended "kernel service data populated by pack-owned
entries" for both registries. R92-C4-A adopted that as the forward design direction.
R93-D1 implements it faithfully.

**Result: PASS**

---

### 3. OOF status-primary / secondary projection is properly bounded; no OOF capability or loadability implied

The core risk: any wording that models `oof` as a first-class fragment class could imply
a loadable OOF artifact, OOF runtime mode, or OOF execution capability, none of which
exist or are authorized.

R93-D1 states the required invariant explicitly:

```text
oof_fragment_projection => blocked / non-loadable / status-only
```

It adds a separate forbidden-inference note:

```text
oof in a fragment registry row does not mean the compiler supports an OOF
execution mode, OOF runtime mode, or OOF-loadable artifact.
```

The design consequences are bounded and self-consistent:

- `oof` may be present in registry data so summaries can explain ownership and precedence.
- `oof` must not become a loadable `SemanticIRProgram` fragment class.
- `oof` must dominate precedence candidates because rejection beats all loadable fragment
  summaries.
- `oof_as_both` from R92 remains only a proof-local modeling vehicle; it is not canon.

The forward vocabulary is `status-primary / secondary fragment projection`, not the
weaker `oof_as_both` phrase from C1-P1. R93-D1 explicitly states: "Any future canon text
should use the stricter phrase `status-primary / secondary fragment projection`."

This implements R92-C4-A's semantic clarification exactly:

> Use the C2/C3 pressure clarification as the forward design reference:
> oof is status-primary with a secondary fragment projection candidate.
> The C1 `oof_as_both` model is accepted only as proof-local modeling evidence.
> It is not canon.

The secondary projection is constrained to summarize blocked programs — not to create
a loadable class or an execution mode. The non-authority framing is structurally complete.

**Result: PASS**

---

### 4. Guarded non-fragment classes (`olap`, `progression`) are properly protected

The core risk: calling either `olap` or `progression` a "candidate fragment" rather
than a "guarded non-fragment" could be interpreted as an implicit promotion step,
especially if future routes use that language as evidence for a fragment authorization.

R93-D1 is explicit on both:

`olap` treatment:

```text
owner surface only / guarded non-fragment class
```

> OLAP diagnostics and ownership may appear in OOF descriptor ownership.
> `olap` is not promoted to a fragment class by this design.
> Any future OLAP fragment proposal needs separate evidence and authorization.

`progression` treatment:

```text
pipeline metadata / guarded non-fragment class
```

> Progression-related rows may document pipeline ownership or descriptor pressure.
> `progression` is not a language fragment class.
> No PROGRESSION fragment semantics are opened by this route.

The required future registry invariant is stated:

```text
guarded_non_fragment != candidate_fragment
```

This is the right separation. It ensures that a "guarded non-fragment" entry in the
registry can represent ownership and descriptor pressure without becoming a stepping stone
toward fragment promotion. Promotion requires "separate evidence and authorization" for
`olap` and is unambiguously blocked for `progression` ("pipeline metadata").

These stances are consistent with R92-C1-P1, R92-C2-P1, and R92-C4-A. No escalation
or scope drift is introduced.

**Result: PASS**

---

### 5. Profile-contract diagnostic exclusion is preserved

The risk: if `compiler_profile_contract.*` or `compiler_profile_contract_refusal.*`
diagnostics were absorbed into OOF, they would change the public diagnostic authority
of PROP-038 strict-terminal paths, merge report-only profile validation into language
OOF ownership, and break the accepted PROP-038 vocabulary separation proven in R69–R74.

R93-D1 states the separation:

```text
compiler_profile_contract.* and compiler_profile_contract_refusal.* remain
outside the OOF namespace.
```

Required separation rules in the design:

- profile-contract diagnostics are nested contract/report validation material;
- strict-terminal wrapper diagnostics remain internal strict-refusal material;
- neither namespace becomes an OOF alias, OOF descriptor, or top-level OOF
  diagnostic by this design;
- OOFRegistry validation should contain an explicit exclusion check for those
  namespaces before any live implementation is considered.

The design explicitly closes this surface rather than simply silently omitting it.
The phrase "OOFRegistry validation should contain an explicit exclusion check" means
that even at implementation time, the exclusion must be machine-asserted, not just
documented.

This is consistent with:
- R92-C1-P1 check `descriptor.profile_contract_diagnostics_excluded` PASS;
- R92-C2-P1 recommendation that neither namespace should be included in
  `strict_registries.oof_descriptors`;
- R92-C4-A closing the surface in the "Not Authorized" section;
- R92-C3-X scope check 5 (PASS) confirming the machine-verified exclusion.

**Result: PASS**

---

### 6. Candidate precedence adopts the C4-A `escape > epistemic` resolution

R92-C3-X identified as NB-1 that C1's proof-local ordering used `epistemic > escape`
while C2 and C0-O both recommended `escape > epistemic`. R92-C4-A resolved this by
explicitly superseding C1's ordering:

> Use this non-canon reference ordering for the next design route:
> oof > temporal > stream > escape > epistemic > core
> This supersedes the C1 proof-local ordering where `epistemic` appeared before
> `escape`.

R93-D1 adopts this exact ordering:

```text
oof > temporal > stream > escape > epistemic > core
```

The rationale is correctly stated:

> `escape > epistemic` is the safer R92-forward reference because a contract
> combining escape behavior with assumptions remains escape-level, while assumption
> references preserve epistemic provenance.
> `epistemic > core` keeps assumptions-only contracts visible without changing
> CORE value semantics.

The non-canon label is maintained:

```text
candidate / non-canon / design reference only
```

The forbidden-use clause is present:

> This ordering must not be used to change classifier behavior, assembler summaries,
> manifests, `.igapp` output, specs, or reports without a separate authorization.

R92-C3-X NB-1 is fully resolved by R92-C4-A and correctly implemented in R93-D1.

**Result: PASS**

---

### 7. Descriptor policy blocker list is complete and actionable before implementation

The risk: an under-specified blocker list could allow a future implementation card
to claim all blockers are "addressed" while leaving critical design gaps open (e.g.,
alias collision policy, projection guard proof, exact write scope).

R93-D1 lists 11 explicit blockers before implementation:

1. pressure review of this design route;
2. exact future write scope;
3. byte-for-byte diagnostic/report/golden parity strategy;
4. uniqueness and alias collision policy;
5. descriptor lifecycle and source-authority policy;
6. public-code stability promotion policy;
7. final treatment of `PINV-*` and `TINV-*` as descriptors, markers, or support metadata;
8. explicit `oof` projection guard proof;
9. explicit guarded non-fragment policy for `olap` and `progression`;
10. explicit exclusion proof for `compiler_profile_contract.*`,
    `compiler_profile_contract_refusal.*`, and runtime helper diagnostics;
11. Architect decision narrowly authorizing any implementation slice.

These match R92-C4-A's "Required Proof Before Implementation" list closely:

> completed ownership/canon-semantics design route;
> pressure review of that design;
> exact write-scope proposal;
> byte-for-byte diagnostic/report/golden parity strategy;
> explicit treatment of PINV-*/TINV-*;
> explicit exclusion of profile-contract diagnostics from OOF;
> explicit conflict handling for fragment precedence and projection guards;
> Architect decision that narrowly authorizes an implementation slice.

Every R92-C4-A required item is covered in the R93-D1 list. No required blocker is
silently omitted. The list includes items that require future proof work (items 8–10),
so acceptance of this design route alone cannot satisfy them — they require dedicated
proof cards.

Blocker 1 ("pressure review of this design route") is being satisfied by this card.
All remaining blockers remain open.

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: `PINV-*` / `TINV-*` treatment is deferred without a recommended path

R93-D1 correctly names the `PINV-*` / `TINV-*` question as a blocker before
implementation ("final treatment of `PINV-*` and `TINV-*` as descriptors, markers, or
support metadata"). However, the design does not recommend a path or frame the
tradeoffs.

From R92 evidence, three options are available:

- **Proof markers only**: keep them outside any public registry, never emitted by
  live compiler; simplest boundary.
- **Descriptor entries with `proof_only` stability**: include in the OOF registry data
  model as `proof_only` descriptors; broader coverage, lower authority risk.
- **Support metadata**: model them as invariant/contract metadata outside the OOF
  descriptor schema entirely.

None of these requires a decision in R93. C4-A should note that a short design
question (or an addendum to a future proof card) should resolve this before the
implementation blocker list can be closed. The current deferral is correct behavior for
the R93 scope; the note is for C4-A.

---

### NB-2: `OOFRegistryPack` shadow-boundary vocabulary should be anchored consistently in future routes

R92-C1-P1 used `OOFRegistryPack` as a proof-local support boundary name. R93-D1 says
this name "may remain a shadow support boundary name" but the semantics should be
"registry service populated by packs, not an ordinary optional language pack."

This is correct. However, future proof or design cards that reference R91/R92
shadow-profile data may encounter `OOFRegistryPack` in the JSON outputs and mistake it
for a language pack entry with optional-pack semantics. The design-vs-proof-local
distinction is subtle.

C4-A may want to note in the acceptance decision that `OOFRegistryPack` in R91/R92
proof-local JSON is a shadow artifact name, and that the forward canonical vocabulary
is "OOF registry service" (kernel/support service, not optional pack). A one-line
clarification in the acceptance gate would prevent future proof card authors from
regressing to pack-optional semantics.

Not a blocker for R93-D1 acceptance. The design itself is correctly scoped.

---

### NB-3: Descriptor schema "needs" list lacks explicit ordering for resolution sequencing

R93-D1 names 8 descriptor schema needs (explicit uniqueness scope, alias collision
policy, status-transition policy, message stability granularity, source authority field,
non-OOF exclusion registry, descriptor lifecycle, pack install interaction). These are
correctly positioned as pre-implementation requirements.

However, not all 8 are equally blocking, and some could be resolved in parallel while
others are sequentially dependent. For example:

- uniqueness scope + alias collision policy + descriptor lifecycle are tightly coupled
  and need to be resolved together;
- message stability granularity is probably separable;
- pack install interaction is relevant only when a live registry module is being scoped.

C4-A may optionally add sequencing guidance ("resolve as a set" vs. "separable")
to the acceptance decision if a future design or proof card needs to tackle these
incrementally. This avoids a situation where a future card claims "some schema needs
are resolved" and uses that as partial authorization evidence.

Not a blocker for R93-D1 acceptance.

---

## Summary

| Check | Result |
| --- | --- |
| 1. Write scope: design-only, single doc, no code/spec/canon/runtime | PASS |
| 2. Kernel service vs pack-owned descriptor — no optional-pack authority drift | PASS |
| 3. OOF status-primary / secondary projection — no capability or loadability implied | PASS |
| 4. Guarded non-fragment classes (`olap`, `progression`) properly protected | PASS |
| 5. Profile-contract diagnostic exclusion preserved and machine-asserted forward | PASS |
| 6. Candidate precedence adopts C4-A `escape > epistemic` resolution | PASS |
| 7. Descriptor policy blocker list is complete and actionable | PASS |

```text
checks: 7/7
blockers: 0
non-blocking notes: 3
  NB-1: PINV-*/TINV-* treatment deferred; C4-A should add a recommended resolution
        path (proof markers / descriptor entries / support metadata) to the gate
  NB-2: OOFRegistryPack shadow-name vocabulary — C4-A may add one clarifying line
        anchoring it as a proof artifact, not a language pack entry
  NB-3: Descriptor schema needs lack sequencing; C4-A may add grouping guidance
        to prevent partial-resolution claims
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 3
```

---

## Recommendation For C4-A

The R93 OOF/Fragment registry ownership and canon-semantics design (LANG-R93-D1) is
well-formed, grounded in R92 evidence, implements R92-C4-A's semantic clarifications
faithfully, and satisfies the pressure-review scope:

- design-only single-doc track, no code/spec/canon/runtime touched ✓
- kernel service vs pack-owned descriptor distinction cleanly drawn ✓
- OOF status-primary / secondary projection properly bounded ✓
- `olap` and `progression` guarded without fragment promotion ✓
- profile-contract diagnostics explicitly excluded and forward-machine-asserted ✓
- `escape > epistemic` candidate ordering adopted per C4-A NB-1 resolution ✓
- 11-blocker pre-implementation checklist complete and actionable ✓

Recommend C4-A:

1. **Accept** LANG-R93-D1 as the design-posture record for OOF/Fragment registry
   ownership and canon semantics. No implementation is authorized.

2. **Add a note on NB-2** in the acceptance gate clarifying that `OOFRegistryPack`
   in R91/R92 JSON proof outputs is a shadow artifact name, and that the forward
   canonical vocabulary is "OOF registry service (kernel/support service, not optional
   pack)." One sentence is sufficient.

3. **Add guidance on NB-1** (PINV-*/TINV-* treatment path) in the gate: either
   nominate a preferred option (proof markers only is the most conservative and
   lowest-risk recommendation) or explicitly defer to a targeted design card before
   the implementation authorization review.

4. **Optionally address NB-3** by noting which descriptor schema needs are coupled
   (uniqueness scope + alias collision policy + descriptor lifecycle) vs. separable
   (message stability granularity), so a future proof or design card can tackle them
   incrementally without risking partial-authorization claims.

5. **Route the next bounded slice** per the R93-D1 recommendation:
   - The highest-value next route is a policy proof that machine-tests the remaining
     open items: alias collision, projection guard invariant, and profile-contract
     exclusion. A short proof-only card targeting those three areas would close the
     most critical pre-implementation blockers (items 8–10 in R93-D1's list) while
     keeping implementation held.
   - The fallback route is `oof-fragment-registry-policy-proof-v0` as named by
     R93-D1, staying proof-only, modeling collision/alias, projection, guarded
     non-fragment, and exclusion policies without live compiler behavior.

6. **Preserve all blocked surfaces** as listed in R92-C4-A, R93-D1, and this review.

No implementation is authorized by this review.

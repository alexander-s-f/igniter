# OOF/Fragment Registry Implementation Boundary Pressure v0

Card: LANG-R100-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Route: UPDATE
Track: oof-fragment-registry-implementation-boundary-pressure-v0
Status: complete
Date: 2026-05-20

---

## Goal

Pressure-test the R99 implementation-boundary design before any implementation
authorization review. Do not authorize implementation.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-implementation-boundary-design-v0.md` (R99 / LANG-R99-D1)
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md` (R95 / LANG-R95-P1)
- `docs/tracks/pinv-tinv-lifecycle-and-registry-classification-design-v0.md` (R97 / LANG-R97-D1)
- `docs/gates/oof-fragment-registry-policy-proof-acceptance-decision-v0.md` (R96 / LANG-R96-A)
- `docs/gates/pinv-tinv-lifecycle-classification-acceptance-decision-v0.md` (R98 / LANG-R98-A)
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`

No tests or broad proof commands were run.

---

## Scope Checks

### Check 1 — Write scope is truly isolated

**Question:** Does the candidate write scope avoid touching any
compiler-integration, public API/CLI, loader/report, CompatibilityReport,
spec/canon, runtime, or production surface?

**Evidence:**

R99 names three candidate future paths:

| Path | Purpose |
| --- | --- |
| `lib/igniter_lang/oof_fragment_registry.rb` | Pure data validation, no compiler integration, no public API, no CLI, no report writes. |
| `lib/igniter_lang/oof_fragment_registry_data.rb` | Optional frozen proof-derived sample data only. Requires explicit separate authorization. |
| `experiments/oof_fragment_registry_implementation_boundary_proof/` | Proof-local parity harness. No live compiler output changes. |

R99 also names an explicit exclusion list of 13 live-compiler and public paths,
including all compiler passes, orchestrator, report, result, CLI, lib entry
point, spec and proposal directories, and existing golden fixtures.

The first implementation slice requires isolated validation library plus
proof-local harness only (Phase 1 + Phase 2 from the implementation-boundary
map). Phases 3–6 remain held.

**Verdict: PASS**

The write scope is truly isolated. The exclusion list is specific and leaves no
ambiguous path into compiler behavior, public surfaces, or production code.

**NB-1 (non-blocking):** `lib/igniter_lang/oof_fragment_registry_data.rb` is
described as optional and requires explicit separate authorization, but R99
does not name the precise authority required (design acceptance vs. Architect
gate). The implementation card should resolve this by stating whether
`oof_fragment_registry_data.rb` is in or out of the first authorized slice, and
if in, which gate authorizes it. Without that explicit statement the optional
path could be added informally alongside the library without a gate boundary.

---

### Check 2 — Parity plan and command matrix

**Question:** Is the parity plan strong enough to prove no live output changes?
Does the command matrix cover all affected surfaces?

**Evidence:**

R99 lists 14 parity requirements, covering:

- parser / classifier / TypeChecker / SemanticIR / CompilationReport outputs;
- `.igapp` manifests and contract artifacts;
- public `CompilerResult` key sets;
- CLI/API behavior;
- loader/report and CompatibilityReport fields (must add none);
- runtime calls and production behavior (must add none);
- diagnostic renames, deletions, wording changes (must make none);
- profile-contract namespace exclusion;
- PINV-*/TINV-* non-emission.

The candidate command matrix covers 8 commands:

- syntax check for isolated library;
- registry validation and closed-surface proof (proof-local harness);
- classifier parity;
- TypeChecker golden parity;
- SemanticIR/report parity;
- `.igapp` parity;
- PINV/TINV support metadata non-emission and invariant OOF parity;
- PROP-038 nested diagnostic separation.

R99 correctly notes:

> "The exact command list must be selected by the future implementation card
> based on changed files."

This is the correct posture. A candidate matrix that includes all surfaces is
better than a fixed matrix that may miss new changed files.

**Verdict: PASS**

The parity requirements are comprehensive, covering all 14 surface categories.
The command matrix is candidate but spans the correct proof surface.

**NB-2 (non-blocking):** The command matrix is explicitly marked candidate
only. The implementation card must pin the exact set, including any additional
commands required by any new files introduced. The recommendation is that the
implementation card treat the R99 candidate matrix as a floor, not a ceiling.
Any file changed that touches a compiler pass, report, or public surface must
add its corresponding proof command regardless of whether R99 listed it.

---

### Check 3 — support_markers / OOF descriptors / fragment_rows separation

**Question:** Are the three registry buckets cleanly separated? Do PINV-*/TINV-*
stay out of `oof_descriptors`? Is vocabulary correct relative to the R96–R98
authority chain?

**Evidence:**

R99 defines four top-level keys:

```json
{
  "oof_descriptors": [],
  "fragment_rows": [],
  "support_markers": { "invariant_support_markers": [] },
  "excluded_namespaces": []
}
```

Separation invariants required by R99:

- support marker codes must not collide with OOF descriptor codes;
- support markers are not OOF aliases;
- support markers are non-public and cannot be emitted diagnostics;
- `PINV-*` / `TINV-*` stay out of `oof_descriptors`.

R98-A accepted R97's classification explicitly:

> "Recommended future registry bucket, if modeled: `support_markers.invariant_support_markers`. Not: `oof_descriptors`."

R99's registry shape correctly places PINV-*/TINV-* in
`support_markers.invariant_support_markers` with `lifecycle_state:
support_metadata_current` and `public_code_stability: non_public_support_marker`.

The R92 shadow proof JSON that placed PINV-*/TINV-* in
`oof_descriptors.shadow_registry.json` is correctly characterized in R99 as
proof-local historical evidence only, not the forward live-registry shape. This
is consistent with R98-A's explicit statement on that point.

Fragment rows carry separate required shape fields from OOF descriptors:
`applies_to`, `classification_kind`, `value_flow_notes`, `precedence_candidate`,
`canonical_status`, `loadable`, `capability`. The schema fields do not overlap
in a way that could cause silent misclassification.

R99 also names three required special fragment rows:

- `oof`: status-primary/secondary projection; blocked, non-loadable, status-only,
  capability-free.
- `olap`: guarded non-fragment, no precedence, non-loadable.
- `progression`: guarded non-fragment, no precedence, non-loadable.

This matches R96-A's clarification on `guarded_non_fragment != candidate_fragment`
and R93's design posture.

Forward vocabulary `OOF registry service` (kernel/support vocabulary, not
optional pack) is preserved. R99 explicitly names this in the blockers list as
a confirmation requirement.

**Verdict: PASS**

The three-bucket separation is clean and correctly reflects the R96–R98
authority chain. No vocabulary drift detected.

---

### Check 4 — Absent optional pack behavior

**Question:** Is the behavior when an optional pack is absent defined clearly
enough to prevent silent validation gaps?

**Evidence:**

R99 names absent optional pack behavior as a blocker:

> "absent optional pack behavior defined:
> - registry service is not optional;
> - absent pack descriptors are inactive, not silently missing from validation;"

This is a correct principle statement. It establishes:

1. The registry service itself is not optional — it must always be present.
2. When a pack that owns descriptors is absent, those descriptors become
   inactive, not silently dropped without trace.

The difference matters: silent missing could allow a validation pass to succeed
without checking the absent pack's descriptors at all, creating a false PASS.
Inactive status should produce a distinct validation outcome that records
"descriptors from absent pack X are not validated" rather than quietly skipping.

R99 does not yet define the validation result shape for inactive descriptors in
machine-testable terms. The blockers list acknowledges this as requiring
"validation result shape defined" including "internal-only result object; no
top-level `report["diagnostics"]`; no `CompilerResult` field; no public API/CLI
output."

**Verdict: PASS**

The principle is correctly stated and the gap (machine-testable inactive-descriptor
result shape) is explicitly listed as a blocker before authorization.

**NB-3 (non-blocking):** The absent-pack behavior principle is stated at the
design level but the implementation card must machine-assert it. Concretely: the
proof-local harness should include at least one case where a pack is absent and
assert that the validation result records inactive descriptors rather than
producing a PASS with no trace of the absent pack. Without that machine assertion
the absent-pack principle remains design prose only.

---

### Check 5 — Source-authority gates

**Question:** Are the source-authority transitions explicit and correctly bounded?
Does implementation code preserve the rule that it cannot promote any lifecycle
state by itself?

**Evidence:**

R99 defines six source-authority transitions:

| Transition | Required authority |
| --- | --- |
| proof-only marker → support metadata | Design or Architect acceptance |
| support metadata → public OOF descriptor | Proposal/spec/gate |
| candidate OOF descriptor → current OOF descriptor | Proposal/spec/gate + implementation authorization |
| compatibility alias → removed/deprecated | Proposal/spec/gate |
| guarded non-fragment → fragment class | Proposal/spec/gate + full closure proof |
| excluded namespace → OOF namespace | Separate Architect decision |

R99 states explicitly:

> "Implementation code must not promote any lifecycle state by itself."

This rule correctly prevents a validator implementation from implicitly advancing
a descriptor from `oof_descriptor_candidate` to `oof_descriptor_current` by
emitting it from the registry service without a prior gate decision.

The six transitions are correctly layered. The most conservative (proof-only →
support metadata) requires only design acceptance (consistent with R97/R98
chain). The most consequential (guarded non-fragment → fragment class) requires
a full proposal/spec/gate plus closure proof, consistent with R96-A's
`guarded_non_fragment != candidate_fragment` invariant.

No hidden promotion path is visible in R99's design. The candidate write scope
(`lib/igniter_lang/oof_fragment_registry.rb`) is explicitly scoped to pure data
validation of supplied registry hashes, which are read-only relative to lifecycle
state.

**Verdict: PASS**

Source-authority gates are explicit, correctly layered, and consistent with the
R92–R98 authority chain.

---

## Verdict

```text
PASS — implementation authorization review may open after remaining blockers.
```

### Blockers Closed by This Pressure Review

R99's blocker list item 1:

> "pressure review of this R99 implementation-boundary design"

This review satisfies that blocker.

### Remaining Blockers Before Implementation Authorization Review

The following 9 blockers from R99's list remain open after this review:

1. **Exact future file write scope** — implementation card must confirm whether
   `oof_fragment_registry_data.rb` is in or out of the first slice and name the
   gate authority required to include it (see NB-1 above).

2. **Decision on support_markers in first slice or deferred** — must be explicit:
   implement `support_markers.invariant_support_markers` in the first slice, or
   defer and preserve R98 classification without a live registry bucket.

3. **Proof-local fixture data migration note** — R92 shadow proof JSON uses the
   historical `oof_descriptors.shadow_registry.json` shape with PINV-*/TINV-*
   in `oof_descriptors`. Implementation card must state: migrate to R98 forward
   shape, or retain historical JSON as-is with a migration-deferred annotation.

4. **Byte-for-byte parity plan and pinned command matrix** — candidate matrix
   must be finalized to exact commands; any new file changed must add its
   corresponding proof command (see NB-2 above).

5. **Source-authority transition rules accepted by Architect** — R99 states
   the gates; the authorization card must accept them explicitly, not just
   inherit them by reference.

6. **Absent optional pack behavior machine-asserted** — proof-local harness
   must include at least one absent-pack case with asserted inactive-descriptor
   outcome, not silent skip (see NB-3 above).

7. **Validation result shape defined** — internal-only result object; no
   top-level `report["diagnostics"]`; no `CompilerResult` field; no public
   API/CLI output. Must be explicit in the implementation design or authorization
   card.

8. **Confirmation `OOF registry service` vocabulary is kernel/support, not
   `OOFRegistryPack`** — must appear as an explicit binding statement in the
   authorization gate, not just repeated design prose.

9. **Architect implementation authorization gate** — no implementation may
   proceed without a separate Architect decision that explicitly names the
   authorized first slice.

---

## Non-Blocking Notes

**NB-1:** `lib/igniter_lang/oof_fragment_registry_data.rb` is optional in R99 but lacks a named gate authority for inclusion. Implementation card should explicitly resolve whether it is in or out of the first authorized slice and which gate is required.

**NB-2:** Command matrix is candidate only. Implementation card must pin the exact commands and treat the R99 matrix as a floor, adding commands for any new files that touch compiler, report, or public surfaces.

**NB-3:** Absent-pack behavior is stated as a principle. The proof-local harness must machine-assert it with at least one inactive-descriptor case to prevent the principle from remaining design prose only.

---

## Recommendation

```text
PASS — no blockers found in R99 design itself.
Blocker 1 (pressure review) from R99's list is now satisfied.
9 blockers remain before implementation authorization review.
Recommended next route: implementation authorization review card after the
9 remaining blockers are addressed.
```

Suggested next route (if Architect opens it):

```text
oof-fragment-registry-implementation-boundary-authorization-review-v0
```

Route type:

```text
architecture-authorization-review only
no implementation until authorization gate accepts
```

---

[Agree]
- R99's write scope is genuinely isolated. The 13-path exclusion list is
  specific enough to close accidental compiler-integration paths.
- The parity requirement set (14 items) is comprehensive and covers all surfaces
  that could drift from a registry library introduction.
- The three-bucket separation (oof_descriptors / fragment_rows /
  support_markers.invariant_support_markers) correctly reflects R96–R98 authority
  chain. PINV-*/TINV-* are correctly kept out of oof_descriptors.
- Source-authority gates are correctly layered. The rule "implementation code
  must not promote any lifecycle state by itself" is the right constraint.
- OOF registry service vocabulary (kernel/support, not optional pack) is
  preserved consistently.

[Challenge]
- None. R99 correctly holds implementation, presents candidate write scope as
  candidate only, and names the blockers accurately.

[Missing]
- Machine-testable absent-pack inactive-descriptor result shape (NB-3).
- Explicit gate authority for `oof_fragment_registry_data.rb` optional path (NB-1).
- Pinned (not candidate) command matrix (NB-2).
- These are gaps for the implementation card, not blockers for this pressure review.

[Sharper Question]
- When the implementation card opens, will `support_markers.invariant_support_markers`
  be in or out of the first slice? The answer changes the proof matrix
  significantly, because absent-pack behavior must be asserted for both OOF
  descriptors and support markers if both are modeled.

[Route]
- implementation-authorization-review after 9 remaining blockers are addressed

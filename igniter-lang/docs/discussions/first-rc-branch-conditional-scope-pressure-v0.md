# First RC Branch Conditional Scope Pressure v0

Card: S3-R164-C3-X
Agent: [Igniter-Lang Pressure Reviewer]
Role: pressure-reviewer
Track: first-rc-branch-conditional-scope-pressure-v0
Route: UPDATE
Depends on: S3-R164-C2-D
Date: 2026-05-24

---

## Question

Does the S3-R164-C2-D first-RC branch/conditional scope disposition correctly
bound the language-readiness claim, avoid unnecessary stall, resolve the
HOLD/RC terminology ambiguity, produce non-claims wording adequate to protect
the chosen route, make the scope machine-visible in the harness, and keep
POC/demo messaging honest?

---

## Evidence Read

- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md`
  (S3-R164-C2-D)
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-decision-v0.md`
  (S3-R160-C3-A)
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
  (S3-R162-C1-A)
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md`
  (S3-R163-C2-I)
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`

---

## Challenge Review

### CH1: Whether narrowing first RC would overclaim language readiness

**Verdict: no overclaim if non-claims wording is preserved.**

The C2-D recommended disposition is:

```text
first_rc_excludes_branch_conditional_if_expr
```

The proposed required wording names the exclusion by specific construct (`if_expr`),
states no claim is made for branch or conditional expression support, confirms the
TypeChecker does not support it, and labels it a post-RC lane. This is a credible
non-claim shape.

The covered first-RC surfaces are enumerated concretely:

- baseline Add-style compile
- boolean gate/conjunction
- integer arithmetic
- mixed-type multi-input contract
- POC-derived synthetic contract
- parse/typecheck/refusal corpus
- PROP-036 profile-source transport/refusal cases
- CLI/API/load-path smoke
- artifact normalization and closed-surface scan

This list is bounded and accurate. The harness `feature_coverage` already records
`branch_conditional_if_expr` as:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "hold",
  "reason": "TypeChecker does not support if_expr; requires new semantics per C1-A NB-1"
}
```

The machine-readable exclusion is present. The risk noted in C2-D — "medium if
future docs say 'language RC' without listing excluded features" — is real but
addressable. The accepted R160 non-claims template must be carried forward
verbatim. See NB-4 for a wording strengthening recommendation.

**No overclaim detected in the disposition itself.**

---

### CH2: Whether waiting for branch/conditional support would stall release unnecessarily

**Verdict: Option B would be an unnecessary stall; Option A is the proportionate response.**

The harness evidence after R163 closure is:

| Metric | Value |
| --- | --- |
| Command matrix | 14/14 PASS |
| Failed checks | 0 |
| Hold reasons | 1 (`branch_conditional_if_expr_unsupported`) |
| Semantic profile qualified diagnostic | resolved (R163) |
| Top-level status | HOLD |

All compiler surfaces outside `if_expr` are proven. The normalization passes
via two-run stability. The closed-surface scan returns zero hits. The
`compatibility_metadata.json` shape checks pass across all five positive corpus
entries. The PROP-036 profile-source transport/refusal cases are covered.

Branch/conditional `if_expr` requires:

- new parser semantics for conditional expression parsing
- TypeChecker support for the `if_expr` AST node
- likely SemanticIR and/or assembler adaptations
- design, authorization, implementation, proof, and harness rerun

This is a separate language-feature lane, not a small harness patch. The R160
harness design explicitly anticipated this outcome:

> "branch/conditional coverage is required if supported by already accepted
> behavior, otherwise first RC is HOLD unless Portfolio accepts narrower scope."

Portfolio has the explicit authority granted by R160 to narrow first-RC scope.
Using that authority for a feature the TypeChecker actively rejects with
`OOF-TY0 Unsupported expression kind: if_expr` is proportionate and within the
design-time mandate.

**Option B would convert a bounded first-RC exercise into a language-feature
expansion milestone with no clear timeline.**

---

### CH3: Whether keeping HOLD while calling evidence "RC" is too ambiguous

**Verdict: real ambiguity exists; it is manageable with a binding gate condition,
but must be explicitly required, not assumed.**

This is the sharpest challenge point. C2-D notes:

> "current proof-local harness remains HOLD"
> "a later accepted scope-aware harness/evidence route may treat
> `branch_conditional_if_expr_unsupported` as an expected out-of-scope condition
> instead of a HOLD, but only after Portfolio accepts the narrower first-RC
> boundary"

The word "may" is the problem. If Portfolio accepts Option A and the next
authorization review opens RC evidence gathering without first requiring the
harness to be updated to reflect the narrower scope, the evidence will be
produced by a harness with `"status": "HOLD"` while simultaneously being
labeled "official RC evidence." This is terminologically contradictory.

The correct sequence is:

```text
1. Portfolio accepts Option A → S3-R164-C3-A
2. Scope-aware RC evidence authorization review opens
3. Authorization review REQUIRES as a binding gate condition:
   harness must be updated to reflect
   branch_conditional_if_expr_unsupported → out_of_scope_excluded
   with status: PASS (if no other holds remain)
   BEFORE any harness output is labeled official RC evidence
4. Harness update authorized (proof-local scope only)
5. Harness rerun → new summary with status: PASS
6. THEN official RC evidence gathering opens
```

Steps 3 and 4 must be binding gates in the authorization review, not
implementation details left to the later implementer's discretion. If the
authorization review skips this or bundles it informally, the HOLD/RC
ambiguity becomes live.

**NB-1 captures this as a required gate condition for C3-A.**

---

### CH4: Whether non-claims wording can protect the chosen route

**Verdict: wording is sufficient; one strengthening recommended.**

The C2-D required non-claims wording is:

```text
First RC excludes branch/conditional `if_expr`. The release-candidate scope
does not claim branch or conditional expression support. Any source requiring
`if_expr` remains unsupported by the current TypeChecker and is outside this
RC. Branch/conditional support remains a post-RC language/compiler design and
proof topic.
```

This wording:

- names the exclusion by construct ✓
- says "does not claim" explicitly ✓
- addresses "any source requiring" (covers compilation attempts) ✓
- labels it post-RC ✓

One gap: it does not explicitly say branch/conditional is not authorized now.
"Remains a post-RC topic" is accurate but passive. A future agent reading the
wording might infer it could be authorized as a side channel or fast-follow.
Recommended addition (see NB-4 wording):

```text
No branch/conditional implementation is authorized by this RC scope decision.
```

Additionally, the machine-readable `non_claims` array in the harness summary
currently does not include a branch/conditional-specific entry. The scope-aware
harness update should add one. See NB-3.

**Non-claims wording is adequate to protect the route with the recommended
addition. The wording does not overclaim and does not leave silent gaps that
an RC audience would reasonably fill with assumptions.**

---

### CH5: Whether the harness can make the selected scope machine-visible

**Verdict: yes, with a required schema addition.**

The current harness `feature_coverage` array already provides the natural
location for the scope change. Under Option A + scope-aware harness update,
the entry would change from:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "hold",
  "reason": "TypeChecker does not support if_expr..."
}
```

to:

```json
{
  "feature": "branch_conditional_if_expr",
  "status": "out_of_scope",
  "reason": "excluded from first RC scope by Portfolio decision [S3-R164-C3-A]; post-RC language design lane"
}
```

Additionally, the `release_scope` block currently contains:

```json
"claimed_surfaces": [...],
"public_claims_authorized": false,
"production_runtime_authorized": false
```

A companion `excluded_features` array should be added:

```json
"excluded_features": ["branch_conditional_if_expr"],
"exclusion_basis": "S3-R164-C3-A Portfolio acceptance of Option A"
```

This makes the exclusion independently verifiable from the machine-readable
summary without requiring prose inspection. It also provides a citation anchor
for any future downstream agent that reads the RC evidence packet and asks
"why is if_expr not covered?"

The `hold_reasons` array would become empty once the scope-aware update is
applied, enabling `"status": "PASS"` at the top level — the correct result for
a harness run where no HOLD or FAIL conditions remain.

**All required changes are harness-level metadata updates. No compiler, library,
or CLI changes are involved.**

---

### CH6: Whether POC/demo messaging remains honest

**Verdict: POC baseline is clean; demo remains closed; no dishonesty introduced.**

The R157 POC corpus (4 contracts: `ChannelSignalScore`, `OrderReadinessGate`,
`EconomicsShadowMargin`, `FulfillmentAttentionTrace`) contained only integer
addition (`+`) and boolean AND (`&&`). None contained `if_expr`. The POC
corpus does not create a branch/conditional expectation.

The harness negative corpus (parse_refusal, type_mismatch, unresolved_symbol)
and profile-source refusal cases all PASS. The R163 fix confirmed that the
`semantic_profile_wrong_kind` case produces the qualified
`compiler_profile_source.wrong_kind` diagnostic. These are TypeChecker-level
and assembler-level refusals — distinct from the TypeChecker `OOF-TY0` error
that `if_expr` produces. The error classes do not create confusion.

The harness non_claims array already includes:

```text
"no_public_demo_claim: public demo claims not authorized by C1-A"
"no_official_rc_evidence: generated outputs are proof-local harness evidence only"
```

Under Option A, public demo remains closed regardless. No POC document, harness
output, or track promotes `if_expr` as a near-term or imminent feature. The
TypeChecker error is actively recorded in the harness summary.

One forward-looking note (NB-5): when the scope-aware harness update changes
the feature status to `out_of_scope`, the wording of the `hold_reasons` entry
disappears. Any downstream RC evidence summary should preserve a visible
`excluded_features` entry (see CH5) so that the absence of branch/conditional
evidence in the RC corpus is never silently explained away by count alone.

**POC/demo messaging is honest. No new dishonesty risk is introduced by
Option A.**

---

## Non-Blocking Notes

### NB-1: HOLD → PASS transition must be a binding gate in the authorization review

The ambiguity identified in CH3 must be resolved by a binding condition in
the next authorization review
(`compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0`),
not left as an implementation detail.

Required gate condition for C3-A to include in the authorization review scope:

```text
The harness must be updated to reflect
branch_conditional_if_expr_unsupported as out_of_scope_excluded
(not HOLD) with the Portfolio decision basis cited
BEFORE any harness run output is labeled official RC evidence.
The updated harness must re-run and produce status: PASS before
official RC evidence gathering is authorized.
```

If this gate condition is missing from the authorization review, the HOLD/RC
ambiguity described in CH3 will recur as a live problem at the point evidence
is gathered.

### NB-2: Add `release_scope.excluded_features` to harness machine-readable schema

As identified in CH5, the scope-aware harness update should add an
`excluded_features` array under `release_scope`:

```json
"excluded_features": ["branch_conditional_if_expr"],
"exclusion_basis": "S3-R164-C3-A Portfolio acceptance of Option A"
```

This should be a required output of the scope-aware harness update, not
optional. C3-A should state this as a required schema addition when the
authorization review's write scope is defined.

### NB-3: Add `no_branch_conditional_claim` to machine-readable `non_claims` array

The current harness `non_claims` array does not include a branch/conditional
specific entry. The scope-aware harness update should add:

```text
"no_branch_conditional_claim: first RC scope explicitly excludes
branch/conditional if_expr; no branch or conditional expression
support is claimed; post-RC language design lane only"
```

This makes the non-claim machine-readable and independently verifiable
alongside `release_scope.excluded_features`.

### NB-4: Strengthen the non-claims wording template with an authorization prohibition

The C2-D wording "post-RC language/compiler design and proof topic" is correct
but passive. The following sentence should be added to the required non-claims
wording:

```text
No branch/conditional implementation is authorized by this RC scope decision.
```

Full recommended wording:

```text
First RC excludes branch/conditional `if_expr`. The release-candidate scope
does not claim branch or conditional expression support. Any source requiring
`if_expr` remains unsupported by the current TypeChecker and is outside this
RC. Branch/conditional support remains a post-RC language/compiler design and
proof topic. No branch/conditional implementation is authorized by this RC
scope decision.
```

### NB-5: RC evidence label protection must be explicit in the authorization review

When the authorization review opens official RC evidence gathering, the
authorization scope must explicitly require:

```text
No harness run output, summary file, or track document may use the phrase
"official RC evidence" or "release-candidate evidence" until:
- the scope-aware harness update is authorized and implemented;
- the harness is re-run under the updated scope;
- the re-run produces status: PASS with branch_conditional_if_expr
  recorded as out_of_scope_excluded, not hold.
```

This prevents an implementer from re-running the current HOLD harness and
calling the output RC evidence by inference from the authorization review text.

---

## Verdict

**proceed with non-blockers.**

The S3-R164-C2-D Option A recommendation is:

- proportionate to the harness evidence (`14/14 PASS`, `0 failed_checks`, one
  HOLD from a TypeChecker `OOF-TY0` that is not an implementation failure);
- consistent with the R160 design-time authority granted to Portfolio to narrow
  first-RC language scope when a feature is not yet supported;
- honest: the proposed non-claims wording names the exclusion, covers compilation
  attempts, and labels the feature as post-RC;
- machine-visible: the harness `feature_coverage` already records the exclusion
  as HOLD; the scope-aware update will convert it to `out_of_scope` with a
  Portfolio decision citation;
- not overclaiming: the listed first-RC covered surfaces are accurate and
  bounded; POC/demo messaging remains closed.

No blockers prevent C3-A from accepting Option A.

Five non-blocking notes (NB-1 through NB-5) must be carried as binding inputs
to the next authorization review:

- NB-1: harness HOLD → PASS transition must be a mandatory gate condition in
  the authorization review before any output is labeled RC evidence;
- NB-2: `release_scope.excluded_features` array must be a required schema
  addition in the scope-aware harness update;
- NB-3: `no_branch_conditional_claim` entry must be added to the machine-readable
  `non_claims` array;
- NB-4: non-claims wording should be strengthened with an explicit authorization
  prohibition sentence;
- NB-5: RC evidence label protection must be stated explicitly in the
  authorization review scope, not left to implementer inference.

---

## Acceptance Recommendation for C3-A

**Accept Option A.**

Accept `first_rc_excludes_branch_conditional_if_expr` as the first-RC scope
disposition. Open the scope-aware RC evidence authorization review as the next
route.

The authorization review must carry NB-1 through NB-5 as binding gate
conditions, with NB-1 (HOLD → PASS gate) and NB-5 (RC evidence label
protection) as the highest priority.

Do not authorize:

- implementation of branch/conditional `if_expr`;
- official RC evidence gathering before the scope-aware harness update is
  authorized, implemented, and re-run with `status: PASS`;
- public demo or release claims;
- any widening of the closed surfaces enumerated in S3-R164-C2-D.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
implementation
parser changes
TypeChecker changes
SemanticIR changes
classifier, assembler, or compiler changes
official RC evidence gathering
release execution
public release or public demo claims
public analyzer/tracer/visualizer implementation or command/UI
public API/CLI widening
root require changes
loader/report
CompilationReport, CompilerResult, or CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work
```

# Track: MeaningDiff and Acceptance Semantics v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/meaning-diff-and-acceptance-semantics-v0
Status: done
Date: 2026-05-06
Pressure source: human-agent review loop, schema evolution (PROP-017), policy freshness (operation-action-result-v0)

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — acceptance fixture criteria in §Part 6.
- `[Igniter-Lang Bridge Agent]` — package implications in §Part 7.

---

## Part 1: MeaningDiff Domain

**[D] A MeaningDiff describes what changed in a contract's declared meaning — not its bytes, not its AST.**

Eight semantic dimensions are tracked:

```text
MeaningDiff = {
  artifact_before_ref: ArtifactRef
  artifact_after_ref:  ArtifactRef
  diff_layers:         Collection[DiffLayer]
  risk_declarations:   Collection[RiskDecl]
  generated_at:        Timestamp
  diff_hash:           String    -- content hash of all DiffLayer entries
}

DiffLayer = one of:

  IntentDiff          { before: String | nil, after: String | nil }
    -- Contract-level intent annotation changed.

  InputOutputDiff     { added: Collection[PortDelta], removed: Collection[PortDelta],
                        type_changed: Collection[TypeChangeDelta] }
    -- Input/output ports added, removed, or retyped.

  AssumptionDiff      { added: Collection[String], removed: Collection[String] }
    -- Declared assumptions (pre-conditions) changed.

  EffectRightDiff     { added: Collection[EffectRight], removed: Collection[EffectRight] }
    -- ESCAPE or TBackend write rights added or removed.
    -- Adding an EffectRight is HIGH RISK. See §Part 4.

  EvidenceRequirementDiff { before: EvidenceReqSet, after: EvidenceReqSet }
    -- Required trust_class or lifecycle for input observations changed.

  ExpectedReceiptDiff { added: Collection[ReceiptKind], removed: Collection[ReceiptKind] }
    -- Receipts the contract is expected to emit changed.

  SchemaBoundaryDiff  { before: SchemaBoundary, after: SchemaBoundary }
    -- schema_version or schema_ref on read nodes changed.

  TrustBoundaryDiff   { before: TrustBoundarySet, after: TrustBoundarySet }
    -- trust_class requirements or scoped_by bindings changed.
```

**[D] A MeaningDiff with zero DiffLayer entries is a null diff.** It signals the contracts are semantically identical. It is valid and useful (confirms stability).

---

## Part 2: Diff Layers — Source vs SemanticIR vs SemanticImage

Three diff targets. Each answers a different question:

```text
Layer           Answers                                 When to use
-----------     -----------------------------------     ----------------------
Source diff     Did the source text change?             Pre-parse review gate
SemanticIR diff Did the compiled meaning change?        Post-compile review gate
SemanticImage   Did the runtime-observable behaviour    Deployment review gate
diff            (inputs, outputs, receipts) change?
```

**[D] Human review is always over the SemanticIR diff, not the source diff.** A source diff may rename a variable without changing meaning. A SemanticIR diff catches semantic changes regardless of textual form.

**[D] AcceptanceReceipt references the SemanticIR artifact hash, not the source file hash.** This prevents accepting a stale source refactor as a semantic acceptance.

---

## Part 3: AcceptanceReceipt

```text
AcceptanceReceipt = Obs[:platform_observation, AcceptRecord]
AcceptRecord = {
  receipt_kind:           :acceptance
  accepted_artifact_ref:  ArtifactRef   -- SemanticIR artifact hash
  review_projection_ref:  ObsId         -- the MeaningDiff that was reviewed
  runtime_verification_ref: ObsId | nil -- verification run receipt (required for staging+)
  reviewer_authority_ref: ObsId         -- who accepted (human or review contract)
  accepted_scope:         AcceptanceScope
  effective_time:         Timestamp
  expires_at:             Timestamp | nil  -- nil = does not expire
  diff_hash:              String           -- must match review_projection_ref.diff_hash
}
lifecycle: :audit   (acceptance is permanent evidence)
links:
  { rel: "authorized_by",  ref: reviewer_authority_ref }
  { rel: "caused_by",      ref: review_projection_ref }
  { rel: "applies_to",     ref: accepted_artifact_ref }
```

**[D] `diff_hash` on the AcceptanceReceipt must equal `MeaningDiff.diff_hash` at acceptance time.** If the artifact was recompiled between review and acceptance, the diff_hash will not match — OOF-MD2 (stale review).

---

## Part 4: Acceptance Scopes

```text
AcceptanceScope =
  | :review_only    -- may be discussed and consumed by review surfaces only
  | :fixture        -- accepted for use in test fixtures and parser proofs
  | :staging        -- accepted for staging environment deployment
  | :production     -- accepted for production deployment

Scope promotion rules:
  :review_only -> :fixture       requires: reviewer_authority_ref (any)
  :fixture     -> :staging       requires: runtime_verification_ref (staging run)
  :staging     -> :production    requires: runtime_verification_ref (staging run)
                                 + separate production_gate_ref (policy-gated)

Demotion: any scope can be demoted by a RevocationReceipt.
```

**[D] `runtime_verification_ref` is required for `:staging` and `:production` scope.** Nil `runtime_verification_ref` at these scopes → OOF-MD3.

**[D] `:review_only` acceptance is NOT sufficient to deploy or execute a contract.** A contract accepted at `:review_only` may be discussed and compared but not run — OOF-MD1 if executed without a higher-scope acceptance.

---

## Part 5: Freshness Rule and Effect-Right Correction Rule

### Freshness rule

```text
A MeaningDiff used as review_projection_ref in an AcceptanceReceipt is fresh if:
  review_projection_ref.diff_hash == accepted_artifact_ref.semantic_ir_hash_at_review

A diff is stale if the artifact was recompiled after the diff was generated.
Stale diff -> OOF-MD2 (stale review). A fresh diff must be generated and re-reviewed.

freshness_ttl: same session only (v0 default).
Cross-session diff reuse is always stale.
```

### Effect-right addition requires full cycle

**[D] Adding an EffectRight (ESCAPE write, TBackend mutation, external bridge call) requires:**

```text
1. A MeaningDiff with EffectRightDiff.added non-empty.
2. A ProposalReceipt (new formal proposal, not an inline change).
3. Reviewer review of the EffectRightDiff layer explicitly.
4. runtime_verification_ref covering the new effect right in a sandboxed run.
5. AcceptanceReceipt at :staging minimum (never :review_only or :fixture).

Missing any step -> OOF-MD4 (effect-right change without full diff + acceptance).
```

**[D] Removing an EffectRight follows the same cycle** — removal may silence a safety check. It requires explicit review, not just a source deletion.

---

## Part 6: OOF Rules and SemanticIR Gates

### OOF Rules

```text
OOF-MD1: Contract executed with only :review_only acceptance.
  No :fixture, :staging, or :production AcceptanceReceipt present.
  -> Runtime gate: execution blocked.

OOF-MD2: Stale review — diff_hash mismatch.
  AcceptanceReceipt.diff_hash != MeaningDiff.diff_hash at current artifact hash.
  -> Acceptance invalidated. Fresh diff + review required.

OOF-MD3: Staging/production acceptance without runtime_verification_ref.
  accepted_scope in [:staging, :production] and runtime_verification_ref is nil.
  -> Compile error (Pass 1): verification_ref is required at these scopes.

OOF-MD4: Effect-right addition without MeaningDiff + full acceptance cycle.
  A new EffectRight appears in the compiled artifact with no EffectRightDiff
  in the review_projection_ref, or no AcceptanceReceipt at :staging+.
  -> Deployment gate: blocked.

OOF-MD5: Prose-only acceptance.
  AcceptanceReceipt.review_projection_ref is nil (no MeaningDiff was reviewed).
  -> Compile error: review_projection_ref is required on all AcceptanceReceipts.

OOF-MD6: Missing reviewer authority.
  AcceptanceReceipt.reviewer_authority_ref is nil.
  -> Compile error: reviewer_authority_ref is required.

OOF-MD7: Cross-session diff reuse.
  review_projection_ref was generated in a different session than the acceptance.
  -> OOF-MD2 (treated as stale): session boundary invalidates diff freshness.
```

### SemanticIR Gates

```text
G-MD1: AcceptanceReceipt.review_projection_ref must be non-nil.
G-MD2: AcceptanceReceipt.diff_hash must equal MeaningDiff.diff_hash at artifact time.
G-MD3: AcceptanceReceipt at :staging/:production must carry runtime_verification_ref.
G-MD4: AcceptanceReceipt.reviewer_authority_ref must be non-nil.
G-MD5: EffectRightDiff.added non-empty -> accepted_scope must be :staging or :production.
G-MD6: AcceptanceReceipt.accepted_artifact_ref must reference a valid SemanticIR artifact hash.
```

---

## Part 7: Research and Bridge Acceptance Criteria

### Research Agent fixture: `meaning-diff-acceptance-fixture-v0`

```text
Positive path:
  1. ContractV1 compiled -> SemanticIR artifact A1.
  2. ContractV2 compiled (adds one EffectRight) -> SemanticIR artifact A2.
  3. MeaningDiff(A1, A2): EffectRightDiff.added = [:external_api_write],
     InputOutputDiff: one new output port.
  4. ProposalReceipt for the EffectRightDiff.
  5. MeaningDiff reviewed by authority.
  6. RuntimeVerificationReceipt from sandboxed staging run.
  7. AcceptanceReceipt:
     accepted_scope: :staging
     diff_hash: matches MeaningDiff.diff_hash
     runtime_verification_ref: step 6
     reviewer_authority_ref: step 5 authority

Negative cases:
  N1: AcceptanceReceipt with nil review_projection_ref -> OOF-MD5.
  N2: accepted_scope: :staging, runtime_verification_ref: nil -> OOF-MD3.
  N3: Artifact recompiled after review; diff_hash mismatch -> OOF-MD2.
  N4: EffectRight added, accepted at :fixture scope -> OOF-MD4.
  N5: reviewer_authority_ref nil -> OOF-MD6.
```

### Bridge implications

```text
BR-MD1: MeaningDiff packets must be routed to review surfaces only.
  They must not be consumed by action authorization or deployment gate endpoints
  without an AcceptanceReceipt at the required scope.

BR-MD2: AcceptanceReceipt.accepted_scope must be forwarded in all deployment metadata.
  A bridge adapter that drops accepted_scope enables OOF-MD1 downstream.

BR-MD3: EffectRightDiff change events must trigger a review workflow notification
  in the host system (Spark or other). The bridge adapter is responsible for
  routing EffectRightDiff.added events to the appropriate review channel.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/meaning-diff-and-acceptance-semantics-v0
Status: done

[D] Decisions:
- MeaningDiff covers 8 semantic dimensions: intent, inputs/outputs, assumptions,
  effect rights, evidence requirements, expected receipts, schema boundary, trust boundary.
- Human review is always over SemanticIR diff, not source diff.
- AcceptanceReceipt references SemanticIR artifact hash (not source hash).
- diff_hash on AcceptanceReceipt must match MeaningDiff.diff_hash at acceptance time.
  Cross-session diff reuse is always stale (OOF-MD2).
- Four acceptance scopes: :review_only, :fixture, :staging, :production.
  :review_only cannot authorize execution (OOF-MD1).
  :staging/:production require runtime_verification_ref (OOF-MD3).
- Effect-right addition (or removal) requires full cycle:
  MeaningDiff + ProposalReceipt + explicit review + staging+ AcceptanceReceipt.
  Missing any step -> OOF-MD4.
- Prose-only acceptance (nil review_projection_ref) -> OOF-MD5.
- 7 OOF rules: OOF-MD1..7. 6 SemanticIR gates: G-MD1..6.

[Files] Changed:
- igniter-lang/docs/tracks/meaning-diff-and-acceptance-semantics-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Next]:
- [Research Agent]: meaning-diff-acceptance-fixture-v0 per §Part 7.
- [Compiler/Grammar Expert]: meaning-diff-grammar-v0
  Add MeaningDiff, AcceptanceReceipt as recognized type names in stdlib.
  Consider adding an `accept` declaration keyword to the contract DSL
  for inline acceptance scope annotation.
```

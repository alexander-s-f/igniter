# Track: OSINT Logical Inference Contract Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/osint-logical-inference-contract-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track strengthens the OSINT theoretical model by testing logical
inference as a contract layer in Igniter-Lang.

The guiding question:

```text
Are Prolog-like ideas useful for Igniter-Lang OSINT?
```

Answer:

```text
Yes, as bounded provenance-aware inference.
No, as full Prolog embedded into CORE.
```

The useful direction is closer to Datalog / stratified logic programming:
facts, rules, queries, unification-like matching, derivation traces, and proof
trees, all bounded by explicit source scope, time, and evidence links.

Safety boundary:

- synthetic/public-source style facts only;
- no real sensitive data, private targets, credential workflows, intrusion,
  doxxing, evasion, or operational abuse;
- inference output is not automatically truth;
- every inferred claim must carry evidence and rule trace links.

## Source Horizon

- `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`
- `igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`
- `igniter-lang/docs/proposals/PROP-003-grammar-fragment-classification-v0.md`
- `igniter-lang/docs/proposals/PROP-013-stdlib-fold-aggregate-v0.md`
- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`

## Compact Claim

[D] Logical inference is useful when it is an explicit contract layer:

```text
SourceObservation
  -> ClaimFact
  -> EvidenceFact
  -> InferenceRule
  -> Query
  -> DerivedClaim
  -> ProofTrace
  -> ConfidenceAssessment
  -> FactCheckSnapshot
```

[D] Prolog's best ideas for Igniter-Lang:

- declarative facts and rules;
- query as a first-class request for derivation;
- unification/pattern matching over structured facts;
- proof search that can explain how an answer was derived;
- rule-driven contradiction detection;
- separation of knowledge base from query.

[X] Prolog features that should not enter CORE v0:

- unbounded backtracking;
- recursive rules without static bounds;
- `cut` / procedural control as hidden semantics;
- dynamic assertion/retraction of facts during proof;
- negation-as-failure as truth;
- closed-world assumptions applied silently;
- side-effecting predicates;
- arbitrary term generation that can make search infinite.

## Proposed Layer

Call the pressure layer:

```text
InferenceContract
```

It is not a separate language. It is a restricted contract kind over typed
facts and bounded rule evaluation.

```text
InferenceContract = {
  contract_id,
  fact_scope,
  temporal_scope,
  rule_set_ref,
  query_ref,
  max_derivation_depth,
  max_result_count,
  negation_policy,
  provenance_policy,
  output_kind
}
```

CORE candidate only if:

- `fact_scope` is finite and bounded;
- `rule_set` is finite;
- rules are range-restricted;
- recursion is absent or statically bounded by a declared depth;
- negation is stratified or disallowed;
- every output links to source facts and rule applications;
- query result count has an explicit bound.

Otherwise:

- controlled solver/search may be ESCAPE with receipt;
- unbounded proof search is OOF.

## Vocabulary

### ClaimFact

```text
ClaimFact = {
  fact_id,
  claim_ref,
  subject_ref,
  predicate,
  object_value,
  valid_time,
  source_observation_refs,
  claim_status
}
```

### EvidenceFact

```text
EvidenceFact = {
  fact_id,
  evidence_link_ref,
  source_ref,
  target_ref,
  relation,
  strength,
  temporal_alignment
}
```

### InferenceRule

```text
InferenceRule = {
  rule_id,
  head_pattern,
  body_patterns,
  guards,
  negation_policy,
  provenance_requirements,
  output_claim_kind,
  safety_class
}
```

### Query

```text
Query = {
  query_id,
  target_pattern,
  temporal_scope,
  max_results,
  max_depth,
  required_evidence_policy
}
```

### RuleApplication

```text
RuleApplication = {
  application_id,
  rule_ref,
  matched_fact_refs,
  produced_claim_ref,
  variable_bindings,
  guard_results,
  status
}
```

### ProofTrace

```text
ProofTrace = {
  trace_id,
  query_ref,
  derived_claim_ref,
  rule_application_refs,
  source_fact_refs,
  evidence_link_refs,
  depth,
  status
}
```

### DerivationReceipt

```text
DerivationReceipt = {
  receipt_id,
  inference_contract_ref,
  query_ref,
  output_claim_refs,
  proof_trace_refs,
  boundedness_evidence,
  status
}
```

## Synthetic OSINT Example

Reuse the synthetic station-status scenario:

```text
claim-001: station/fixture-east-17 status online at 09:00 from direct source A
claim-002: station/fixture-east-17 status online at 09:10 from derivative repeat
claim-003: station/fixture-east-17 status offline at 09:20 from direct source B
```

We want inference rules that derive:

```text
repeated_claim_is_not_corroboration
conflicting_status_detected
assessment_status_conflicted
```

## Rule Sketches

These are semantic sketches, not final syntax.

### Rule 1: Independent Support

```text
Rule independent_support:
  head:
    IndependentSupport(subject, predicate, value, source_a, source_b)
  body:
    ClaimFact(c1, subject, predicate, value, source_a, kind: source_claim)
    ClaimFact(c2, subject, predicate, value, source_b, kind: source_claim)
    source_a != source_b
    not DerivativeOf(source_b, source_a)
  output_claim_kind: analyst_inference
```

Pressure:

- `not DerivativeOf(...)` cannot be naive negation-as-failure.
- It must be stratified over known derivative links or become unknown.

### Rule 2: Repetition Is Weak Support

```text
Rule derivative_repeat:
  head:
    RepeatedClaim(subject, predicate, value, repeated_claim)
  body:
    ClaimFact(repeated_claim, subject, predicate, value, source_r, kind: repeated_claim)
    EvidenceFact(ev, source_r, _, relation: repeats)
  output_claim_kind: analyst_inference
```

Pressure:

- repeated claim is represented;
- it is not counted as independent evidence.

### Rule 3: Contradiction

```text
Rule conflicting_status:
  head:
    Contradiction(subject, predicate, value_a, value_b)
  body:
    ClaimFact(c1, subject, predicate, value_a, source_a, kind: source_claim)
    ClaimFact(c2, subject, predicate, value_b, source_b, kind: source_claim)
    value_a != value_b
    overlaps(c1.valid_time, c2.valid_time)
  output_claim_kind: contradiction
```

Pressure:

- contradiction requires typed predicate domain;
- not every different value is contradiction unless predicate says it is
  mutually exclusive over overlapping time.

### Rule 4: Corrected Assessment

```text
Rule conflicted_assessment:
  head:
    AssessedStatus(subject, conflicted)
  body:
    Contradiction(subject, status, _, _)
  output_claim_kind: analyst_assessment
```

Pressure:

- the result is an inferred assessment, not a source fact;
- it must link to the contradiction proof trace.

## Expected Inference Output

```text
InferenceContract = {
  contract_id: inference/osint-station-status@1
  fact_scope:
    source_observations: 3
    claims: 3
    evidence_links: 5
  temporal_scope: 2026-05-06T09:00:00Z..2026-05-06T09:35:00Z
  rule_set_ref: rule_set/osint-basic-claim-reasoning@1
  query_ref: query/assess-station-status@1
  max_derivation_depth: 4
  max_result_count: 10
  negation_policy: :stratified_known_facts_only
  provenance_policy: :proof_trace_required
}
```

Expected derived claims:

| Derived output | Kind | Trust status | Required proof |
|----------------|------|--------------|----------------|
| `RepeatedClaim(station, status, online, claim-002)` | analyst inference | weak support only | claim-002 + repeat evidence |
| `Contradiction(station, status, online, offline)` | contradiction | direct conflict | claim-001 + claim-003 + overlap rule |
| `AssessedStatus(station, conflicted)` | analyst assessment | evidence-linked inference | contradiction proof trace |

Expected derivation receipt:

```text
DerivationReceipt = {
  receipt_id: derivation/osint-station-status@1
  inference_contract_ref: inference/osint-station-status@1
  query_ref: query/assess-station-status@1
  output_claim_refs:
    - claim/derived/repeated-online-weak-support
    - claim/derived/status-contradiction
    - claim/derived/status-conflicted
  proof_trace_refs:
    - proof_trace/repeated-online-weak-support
    - proof_trace/status-contradiction
    - proof_trace/status-conflicted
  boundedness_evidence:
    fact_count: 11
    rule_count: 4
    max_depth: 4
    max_result_count: 10
  status: :ok
}
```

## Why Prolog Helps

Prolog's mental model is useful because OSINT analysis naturally asks:

```text
What can be derived from these facts and rules?
Why did the system derive it?
Which source facts supported it?
Which rule introduced the inference?
What would change if a claim is corrected?
```

Useful imports:

- `fact`: maps to `ClaimFact`, `EvidenceFact`, source descriptors;
- `rule`: maps to `InferenceRule`;
- `query`: maps to `Query` / `InferenceContract`;
- `unification`: maps to typed pattern matching over claim records;
- `proof tree`: maps to `ProofTrace`;
- `backtracking`: maps to bounded search over finite fact collections;
- `failure`: maps to `Result` / `FailureObservation`, not silent false.

## Why Full Prolog Is Dangerous

Full Prolog conflicts with Igniter-Lang's core invariants:

- unbounded search violates CORE boundedness;
- negation-as-failure can turn missing evidence into falsehood;
- cut changes meaning procedurally and hides proof alternatives;
- dynamic fact assertion/retraction conflicts with observation immutability;
- closed-world reasoning conflicts with public-source uncertainty;
- side-effecting predicates blur inference and ESCAPE;
- source provenance is not built into ordinary Prolog facts.

[D] If Prolog inspires Igniter-Lang, it should inspire a proof-carrying,
bounded, temporal, provenance-aware inference subset.

## Negative Cases

### LOGIC-1: Repetition Derives Independent Corroboration

```text
rule_result: IndependentSupport(station, status, online, src-001, src-002)
source_relation: src-002 repeats src-001
```

Expected:

```text
status: :blocked
diagnostic: inference.derivative_repeat_not_independent_support
```

### LOGIC-2: Negation As Failure Becomes Truth

```text
query: no_contradiction(station)
known_facts: contradiction source not loaded
negation_policy: negation_as_failure
```

Expected:

```text
status: :blocked
diagnostic: inference.negation_as_failure_not_truth
```

### LOGIC-3: Unbounded Proof Search

```text
rule_set: recursive_reachable_without_depth_bound
max_derivation_depth: null
```

Expected:

```text
status: :blocked
fragment_class: OOF
diagnostic: inference.unbounded_search_oof
```

### LOGIC-4: Derived Claim Without Proof Trace

```text
derived_claim_ref: claim/derived/status-conflicted
proof_trace_ref: null
```

Expected:

```text
status: :blocked
diagnostic: inference.proof_trace_missing
```

### LOGIC-5: Closed World Assumption Hidden

```text
claim: "station has no outage reports"
fact_scope: only two sources
closed_world_assumption: implicit
```

Expected:

```text
status: :blocked
diagnostic: inference.closed_world_assumption_undeclared
```

## What Current Igniter-Lang Handles

- Bounded collections and folds can model small finite fact sets.
- Observation links can represent source provenance and proof trace inputs.
- Failure observations can block missing proof traces or unsafe inference.
- CORE / ESCAPE / OOF already rejects unbounded loops and hidden ambient
  effects.
- OSINT tracks already provide Claim, SourceObservation, EvidenceLink,
  ContradictionReport, ConfidenceAssessment, FactCheckSnapshot, and
  CorrectionReceipt pressure.

## Where It Breaks Or Lacks Capability

- No first-class rule/fact/query layer exists yet.
- No typed unification or pattern matching over Claim records is formalized.
- No stratified negation policy exists.
- No bounded proof-search semantics exists.
- No ProofTrace / DerivationReceipt shape is canon.
- Contradiction depends on typed predicate semantics, which are still open.
- Confidence should consume inference proof traces but not become truth.

## Concrete Research Fixture Request

Please implement a standalone fixture proof:

```text
track_request: osint_logical_inference_contract_fixture_v0
suggested_dir: igniter-lang/experiments/osint_logical_inference_contract_fixture/
inputs:
  - synthetic station-status SourceObservation records from OSINT fixture
  - ClaimFact records for online/offline/repeated claims
  - EvidenceFact records for supports/repeats/contradicts
  - rule_set/osint-basic-claim-reasoning@1 with 4 rules
  - query/assess-station-status@1
  - max_derivation_depth: 4
  - max_result_count: 10
outputs:
  - derived repeated-claim weak-support claim
  - derived contradiction claim/report
  - derived conflicted assessment claim
  - ProofTrace for each derived output
  - DerivationReceipt with boundedness evidence
  - negative diagnostics LOGIC-1..LOGIC-5
checker:
  - validates finite fact/rule/query bounds
  - validates repeated claim is not independent support
  - validates contradiction proof uses two direct claims and temporal overlap
  - validates every derived claim has ProofTrace
  - rejects negation-as-failure as truth
  - rejects unbounded recursive search
safety:
  - synthetic public-source style facts only
  - no real sensitive data, private targets, intrusion, doxxing, evasion,
    credentials, or operational abuse
```

Proof acceptance:

- all derived outputs carry proof traces;
- derivation receipt records bounds;
- repeated claim remains weak/derivative;
- contradiction is derived by typed rule and overlapping valid time;
- unbounded or unsafe logical constructs are blocked.

## Compiler Questions

1. Should Igniter-Lang add an `InferenceContract` kind, or model inference as
   ordinary contracts over collections?
2. Should the safe subset be Datalog-like with range-restricted rules?
3. Can typed unification be a CORE primitive if all types are structural and
   all terms are finite?
4. Is recursion always OOF in v0, or can bounded recursion with max depth be
   ESCAPE?
5. Should stratified negation be allowed, or should v0 require explicit
   `Unknown` instead of negation?
6. How are proof traces represented in SemanticIR: rule application nodes,
   observation links, or separate derivation receipts?
7. What type information must predicates carry to detect contradictions?
8. Should a solver-style inference engine be a TBackend/ESCAPE adapter with
   proof certificates, or can a small evaluator be RuntimeMachine CORE?

## Bridge Candidates

- `InferenceRuleProfile` for package/UI display of rule head, body, guards,
  provenance requirements, and safety class.
- `ProofTraceProfile` for derived claims, matched facts, rule applications,
  variable bindings, and evidence links.
- `DerivationReceiptProfile` for boundedness evidence, query refs, rule set
  refs, and output claim refs.
- `LogicalContradictionDiagnostic` for typed predicate conflicts and temporal
  overlap.
- `InferenceSafetyDiagnostic` for unbounded search, unsafe negation,
  derivative repetition misuse, and missing proof traces.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/osint-logical-inference-contract-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Prolog ideas are useful as bounded provenance-aware inference, not as full
  Prolog embedded in CORE.
- Recommended direction is Datalog-like: finite facts, finite rules,
  range-restricted matching, bounded query results, proof traces, and
  derivation receipts.
- Rejected unbounded backtracking, cut, dynamic fact mutation,
  negation-as-failure as truth, hidden closed-world assumptions, and
  side-effecting predicates for CORE.

[R] Recommendations:
- Research Agent should implement the synthetic OSINT logical inference
  fixture with ProofTrace and DerivationReceipt outputs.
- Compiler/Grammar Expert should formalize InferenceContract, typed
  unification, stratified/unknown negation, and bounded proof search.
- Bridge Agent should draft rule/proof/derivation diagnostic profiles.

[S] Signals:
- OSINT needs logical inference because claims become useful through
  explainable derivation, contradiction, and correction.
- ProofTrace is the bridge between Prolog-like reasoning and Igniter-Lang's
  observation evidence spine.
- Confidence must consume proofs but must not become truth.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/osint_logical_inference_contract_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/osint-logical-inference-contract-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- InferenceContract vs ordinary contract over collections?
- Typed unification CORE primitive or compiler lowering?
- Stratified negation vs explicit Unknown-only v0?
- RuntimeMachine CORE evaluator vs ESCAPE solver with proof certificate?

[X] Rejected:
- Full Prolog as CORE.
- Negation-as-failure as truth.
- Unbounded proof search.
- Derived claims without proof traces.
- Hidden closed-world assumptions over public-source evidence.

[Next] Proposed next slice:
- Research Agent: implement `osint_logical_inference_contract_fixture_v0`.
- Compiler/Grammar Expert: formalize bounded inference contract semantics.
- Bridge Agent: draft proof trace and derivation receipt bridge profiles.
```

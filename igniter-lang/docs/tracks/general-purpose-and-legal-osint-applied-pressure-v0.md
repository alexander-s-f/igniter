# Track: General Purpose And Legal OSINT Applied Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/general-purpose-and-legal-osint-applied-pressure-v0.md`
Status: done
Card: `S3-R14-C10-P`
Slice state: done on 2026-05-09
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`

## Frame

This track evaluates the applied/product pressure from the V2 general-purpose
fixtures:

1. HTTP API client as a general-purpose baseline.
2. `AgentKnowledgeMesh` as distributed agent memory/context.
3. `ClarityDuelEngine` as OSINT/fact-check/discussion system.
4. `LegalAdvocateOSINT` as rights-preserving legal/anti-corruption system.

Authority boundary:

- treat all examples as pressure specimens, not canon;
- do not promote syntax to spec;
- do not authorize implementation;
- do not treat legal/OSINT outputs as legal advice, verdicts, accusations, or
  external action authorization;
- keep public/synthetic/lawful inputs only.

Source horizon:

- `playgrounds/docs/external/External Pressure Reviewer V2 Cross Test - 2.md`
- `igniter-lang/docs/agent-orchestra-pattern.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/applied-pressure-directions.md`
- prior Spark CRM, OSINT, truth-system, and human-agent pressure tracks as
  indexed through `value-index.md`.

## Compact Claim

The V2 fixture set pressures two different meanings of "general purpose":

```text
general-purpose baseline:
  can call external services, parse JSON, handle errors, and emit receipts

epistemic general-purpose platform:
  can model knowledge, evidence, conflict, authority, human review,
  temporal correction, public explanation, and lawful accountability
```

[D] The examples do not yet prove Igniter-Lang is a general-purpose language.
They do prove that its strongest platform direction is broader than business
workflow DSL: it is a candidate platform for auditable external IO, agent
knowledge, OSINT truth systems, and rights-preserving review processes.

## Applied Pressure Map

| Lane | What it tests | Strong signal | Main gap |
|------|---------------|---------------|----------|
| HTTP API client | ordinary external IO baseline | contracts + receipts can wrap request/response flows | live HTTP/JSON primitives and capability-gated FFI are not proven as language/runtime core |
| AgentKnowledgeMesh | distributed agent memory and inference | facts need authority refs, evidence, BiHistory, merge receipts | knowledge assertion/inference/conflict semantics are still product/proposal pressure |
| ClarityDuelEngine | OSINT fact-check + public argument | adversarial claims need evidence bundles, rebuttal traces, contradiction handling | "nullification" must be reframed as review-safe claim weakening, not rhetorical victory |
| LegalAdvocateOSINT | legal/anti-corruption rights-preserving analysis | legal domain needs strict authority, human rights safeguards, audit, and non-rewrite correction | legal safety gates, jurisdiction policy, and human/legal review authority are not formalized |

## Lane 1: HTTP API Client Baseline

The external specimen models:

```text
HttpRequest
  -> external http_perform_request
  -> HttpResponse | ApiError
  -> ApiCallReceipt
  -> History/BiHistory log
```

### Required Capabilities

- external IO / FFI boundary with capability gates;
- HTTP request/response structural values;
- JSON serialize/deserialize primitives;
- result/error typing;
- timeout/retry policy as explicit runtime policy;
- receipt generation for every external call;
- evidence hash/content hash for request and response;
- redaction policy for headers, body, tokens, and personally sensitive fields;
- temporal log of calls and responses.

### Pressure Signal

This is the baseline test every "general-purpose" claim must pass:

```text
Can Igniter-Lang safely express a common API client without turning all IO into
ambient host code?
```

[S] It pressures `ESCAPE` more than `CORE`. HTTP is not language semantics; it
is an effect boundary with typed request/response values and receipts.

### Missing

- canonical `HttpRequest`, `HttpResponse`, `JsonValue`, `Result[T,E]` package
  or stdlib shape;
- live external IO runtime approval distinct from metadata-only descriptors;
- secret/redaction policy for headers and payloads;
- deterministic replay story for external responses;
- fixture proving external IO can be refused, simulated, replayed, and audited.

## Lane 2: AgentKnowledgeMesh

The specimen models:

```text
AuthorityRef
  -> FactAssertion
  -> BiHistory[FactAssertion]
  -> inference
  -> conflict detection
  -> context merge receipt
```

### Required Capabilities

- knowledge assertions with source evidence;
- authority refs tied to agent role and context;
- role trust and borrowed-lens provenance;
- temporal validity and transaction/known time;
- bounded inference and proof traces;
- conflict detection over facts and predicates;
- merge receipts for distributed contexts;
- human review for unresolved conflicts or authority escalation.

### Pressure Signal

This lane says an agent platform cannot rely on chat history as memory. It
needs typed, temporal, evidence-bearing assertions.

Useful minimal model:

```text
AgentObservation
  -> KnowledgeAssertion
  -> InferenceTrace
  -> ConflictReport
  -> MergeReceipt
```

[D] `AuthorityRef` is not enough by itself. It must include role, lens, context
level, authority boundary, and source evidence. Otherwise it becomes a badge,
not trust.

### Missing

- first-class `KnowledgeAssertion` vs `Claim` relationship;
- bounded inference model beyond external pure functions;
- conflict semantics for equal subject/predicate with incompatible objects;
- authority weighting without turning authority into truth;
- durable agent-context merge/replay semantics;
- audit shape for "why did this agent know this at that time?"

## Lane 3: ClarityDuelEngine

The specimen models:

```text
OpponentPosition
  -> OSINTBundle
  -> FactCheckResult
  -> RebuttalStep
  -> DuelReceipt / NullificationReceipt
```

### Required Capabilities

- claim decomposition and evidence bundles;
- source provenance and lawful collection policy;
- contradiction reports;
- argument/rebuttal traces linked to evidence;
- confidence/caveat separation from truth;
- human review before public-facing claims;
- publication receipts and redaction policy;
- agent role boundaries for "duel master" or reviewer.

### Pressure Signal

The useful part is not "annul an opponent." The useful part is structured,
auditable disagreement:

```text
position
  -> claims
  -> evidence
  -> contradictions
  -> rebuttal trace
  -> review-safe clarity report
```

[D] For Igniter-Lang, this lane should be reframed from rhetorical
`nullification` to evidence-backed `PositionAssessment`:

- supported;
- weakened;
- contradicted;
- unverifiable;
- superseded;
- needs human review.

### Missing

- typed `ArgumentTrace` or `RebuttalTrace` that cannot omit evidence;
- adversarial-source handling without enabling abuse workflows;
- public explainability format with citations and caveats;
- safety gate for allegations, personal claims, and high-impact publication;
- authority rule preventing an automated agent from declaring final public
  truth.

## Lane 4: LegalAdvocateOSINT

The specimen models:

```text
LegalOSINTBundle
  -> LegalNorm
  -> OvertonShift
  -> HumanRightsImpact
  -> LegalArgument
  -> LegalAdvocacyReceipt
```

### Required Capabilities

- lawful legal/public-source collection boundary;
- jurisdiction, citation, and document provenance;
- legal norms as time-indexed claims, not timeless strings;
- authority refs for lawyer, court, regulator, human reviewer, or civic actor;
- human rights impact assessment with caveats and review;
- temporal correction and audit of legal claims;
- explicit non-advice / review-required boundary;
- public explainability with citations and redaction;
- high-impact action gates.

### Pressure Signal

Legal/anti-corruption systems are the hardest pressure lane because the cost of
false clarity is high. The language must make it difficult to:

- twist facts;
- erase contrary evidence;
- launder model output into legal authority;
- overstate confidence;
- publish accusations without review;
- confuse advocacy drafting with legal adjudication.

[D] The "Overton window" idea should be treated as a monitored
`NormShiftClaim`, not as a moral detector. It requires:

- a historical norm baseline;
- evidence of public/legal discourse shift;
- jurisdiction and time scope;
- counter-evidence;
- human/legal review before action.

### Missing

- legal safety policy types;
- jurisdiction-aware citation and redaction;
- high-impact report gate semantics;
- human/legal reviewer authority receipts;
- "not legal advice" / "draft for review" artifact state;
- rights-impact assessment that preserves caveats and dissenting evidence.

## Cross-Lane Capability Demands

### Language Pressure

- `JsonValue`, structural HTTP request/response types, and typed `Result[T,E]`.
- `EvidenceBundle` with independent vs derivative source separation.
- `Claim`, `KnowledgeAssertion`, and `LegalNormClaim` relationship.
- `AuthorityRef` with role, lens, context, and authority boundary.
- `ConflictReport`, `ContradictionReport`, and `PositionAssessment`.
- `HumanReviewPacket`, `AnalystDecision`, `AcceptanceReceipt`,
  `OverrideReceipt`.
- `CorrectionReceipt` and `UpdateReceipt` for temporal report changes.
- Citation/redaction policy as mandatory on public-facing artifacts.

### Runtime Pressure

- capability-gated external IO / FFI.
- runtime refusal for unapproved live HTTP or legal/OSINT collection.
- replay/simulation mode for external responses.
- receipt emission for every external call, assertion, merge, report,
  override, and publication.
- temporal cache keys over `as_of` / transaction time.
- audit-preserving compaction for source observations and receipts.
- compatibility reports that can say "loadable for inspection, not executable"
  for live IO and high-impact actions.

### Product Pressure

- HTTP client dashboard: calls, errors, latency, receipts, redacted payloads.
- Agent knowledge dashboard: assertions, conflicts, merge trace, authority map.
- Clarity report UI: contested claims, evidence bundles, caveats, correction
  timeline, human review status.
- Legal advocate UI: jurisdiction, cited sources, rights impact, review queue,
  draft/report state, dissenting evidence.
- Public explainability exports that preserve citations without leaking unsafe
  data.

### Safety / Legal Pressure

- lawful collection policy for every source.
- private data and personal-claim redaction.
- no doxxing, harassment, credential collection, evasion, exploit guidance, or
  unauthorized targeting.
- no automated legal advice or final legal conclusion.
- high-impact publication gate with human/legal review.
- override receipts must include scope, reason, authority, evidence, and
  caveats.
- adversarial and corruption-related claims require stricter evidence
  thresholds and review.

### Agent-Orchestra Pressure

- every agent output should record role, borrowed lens, context level,
  authority boundary, and route expectation.
- agent assertions are observations, not canon.
- "external reviewer" and "legal advocate" cannot claim Architect, court, or
  human authority.
- handoff/route should become a first-class observation for distributed
  knowledge systems.
- multi-agent merges require conflict reports, not silent consensus.

## Why This Proves / Does Not Yet Prove General-Purpose Igniter-Lang

### What It Proves As Pressure

The fixture set proves useful breadth:

- ordinary IO workflows need the same contract/evidence/receipt spine;
- distributed agent memory naturally wants `BiHistory`, authority refs, and
  conflict reports;
- OSINT/fact-check systems need claim/evidence/correction semantics;
- legal/rights systems need stronger authority and human-review gates;
- all lanes reuse explicit time, observations, receipts, diagnostics, and
  trust boundaries.

[S] This is a strong signal that Igniter-Lang can become a platform language,
not just a business-rule DSL.

### What It Does Not Prove Yet

It does not yet prove:

- real HTTP execution;
- JSON parsing/serialization in the production runtime;
- safe live external IO;
- production TBackend history for knowledge/assertion stores;
- bounded inference in the language/runtime;
- legal safety enforcement;
- public report generation;
- UI/product viability;
- general-purpose ergonomics for ordinary developers.

[D] The correct verdict:

```text
General-purpose as pressure: yes.
General-purpose as proven implementation: not yet.
Best next proof: capability-gated HTTP + JSON fixture with receipts,
then a synthetic knowledge/conflict fixture.
```

## Spark CRM And OSINT Comparison

Spark CRM and the V2 fixtures share the same trust pattern.

| Spark CRM | V2 general/legal OSINT | Shared demand |
|-----------|------------------------|---------------|
| vendor lead signal | HTTP/API response or source observation | external IO with receipts |
| idempotency key | content hash / evidence hash | reproducible identity |
| schedule/off_schedule drift | claim/legal norm correction | temporal correction |
| why-not reason | contradiction/caveat/rebuttal | explainable diagnostics |
| actor/action authority | agent/legal authority ref | scoped authority |
| operation request/execution receipt | review/override/publication receipt | action accountability |
| tenant scope | jurisdiction/watchlist/context scope | scoped facts |

Difference:

- Spark pressure asks whether the system can run operational workflows safely.
- OSINT/legal pressure asks whether the system can make public truth claims
  responsibly.

The second is higher risk and should have stricter review gates.

## Missing Capability List

Priority missing capabilities:

1. Capability-gated external IO profile for HTTP/JSON with redaction and replay.
2. Canonical `JsonValue` and typed HTTP request/response/result shapes.
3. EvidenceBundle semantics with independent corroboration vs derivative
   repetition.
4. AuthorityRef v0: role, lens, context level, authority boundary, key/proof
   ref, and route.
5. KnowledgeAssertion / Claim unification or separation rule.
6. ConflictReport and PositionAssessment types.
7. Human review / override / publication authority receipts.
8. Temporal correction for reports and claims, including prior-report
   preservation.
9. Legal/high-impact safety policy with jurisdiction/citation/redaction.
10. Public explainability artifact shape that is evidence-linked and
    redaction-safe.
11. Bounded inference/proof trace for knowledge systems.
12. Agent-context merge receipts with conflict detection.

## Suggested Next Slices By Priority

### P0: General-Purpose Baseline

1. `external-http-json-capability-pressure-v0`
   Define the minimum language/runtime capability profile for HTTP + JSON:
   request, response, error, redaction, replay, receipt, and refusal cases.

2. `external-http-json-fixture-v0`
   Synthetic or loopback fixture proving one GET-like response, one error, one
   redacted header/body case, and one unapproved capability refusal.

### P1: Agent Knowledge Platform

3. `agent-knowledge-assertion-conflict-pressure-v0`
   Formal pressure map for `KnowledgeAssertion`, `AuthorityRef`, conflict
   reports, and merge receipts.

4. `agent-knowledge-conflict-fixture-v0`
   Synthetic fixture with two agents asserting conflicting facts, an inference
   trace, and a merge receipt that refuses silent consensus.

### P2: Truth / OSINT Product

5. `truth-systems-evidence-bundle-semantics-v0`
   Define evidence bundles, derivative repetition, independent corroboration,
   citation/redaction policy, and OOF gates.

6. `clarity-position-assessment-fixture-v0`
   Convert the duel/nullification idea into a review-safe
   `PositionAssessment` fixture with evidence, rebuttal trace, contradiction,
   caveats, and human review.

### P3: Legal / Rights-Preserving Safety

7. `legal-osint-safety-boundary-pressure-v0`
   Define legal-domain safety: no legal advice, jurisdiction scope, human/legal
   review, rights impact caveats, publication gates.

8. `legal-norm-shift-claim-fixture-v0`
   Synthetic "norm shift" fixture using public-style legal claims, historical
   baseline, counter-evidence, rights-impact assessment, and human review.

### P4: Agent Orchestra Integration

9. `agent-orchestra-authorityref-profile-v0`
   Map role, context, lens, authority, and route into an `AuthorityRef` /
   `AgentObservation` profile.

10. `agent-lens-knowledge-merge-fixture-v0`
    Prove that borrowed lenses are preserved in knowledge assertions and merge
    receipts.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/general-purpose-and-legal-osint-applied-pressure-v0.md
Status: done

[D] Decisions
- Treat V2 examples as applied/product pressure, not canon syntax.
- HTTP client is the right baseline for general-purpose IO, but it mainly
  pressures ESCAPE/FFI/runtime capability gates.
- AgentKnowledgeMesh, ClarityDuelEngine, and LegalAdvocateOSINT pressure the
  epistemic platform layer: authority, evidence, conflict, review, correction,
  public explainability, and safety.
- Legal/anti-corruption use cases require stricter high-impact review and
  should never be automated legal advice or public accusation machinery.

[S] Shipped / Signals
- Mapped four lanes and separated language, runtime, product, safety/legal, and
  agent-orchestra pressure.
- Identified why the examples are strong pressure for platform breadth but do
  not yet prove implemented general-purpose Igniter-Lang.
- Prioritized next slices from HTTP/JSON baseline through knowledge conflict,
  truth-system semantics, legal safety, and agent authority profiles.

[T] Tests / Proofs
- Documentation-only applied pressure slice; no executable tests run.

[R] Risks / Recommendations
- Risk: jumping to legal/OSINT products before proving capability-gated
  HTTP/JSON will make the platform look magical instead of real.
- Risk: rhetorical `nullification` language can become unsafe; reframe as
  evidence-backed `PositionAssessment`.
- Recommendation: prove external HTTP/JSON refusal/replay/receipt first, then
  agent knowledge conflict, then legal OSINT safety.

[Next] Suggested next slice
- `external-http-json-capability-pressure-v0` followed by
  `external-http-json-fixture-v0`.
```

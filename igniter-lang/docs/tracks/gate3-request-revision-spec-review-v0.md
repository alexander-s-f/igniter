# Track: Gate 3 Request Revision Spec Review v0

Card: S3-R12-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `gate3-request-revision-spec-review-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Review the revised Gate 3 request for semantic/spec consistency after
S3-R12-C1 lands, without editing the request.

Reviewed request:

```text
docs/gates/runtime-temporal-executor-gate3-request-v0.md
```

Revision evidence:

```text
docs/tracks/runtime-temporal-executor-gate3-request-revision-v0.md
```

---

## Verdict

[D] Ready for Architect review.

No semantic/spec blocker remains in the revised request. The S3-R11-X1 HOLD
items are resolved:

- authority ref is now a gate-opening precondition, not a post-approval task;
- AT-10 is unconditional;
- AT-12 is added and semantically acceptable;
- Ch7 sync is correctly routed as post-approval work.

This verdict does not open Gate 3. It only says the revised request is coherent
enough for Architect Supervisor decision.

---

## Authorization Boundary Check

[S] The revised request does not authorize parser syntax changes.

Evidence:

- Section III defers parser coordinate syntax to a future proposal.
- Section VII explicitly marks parser coordinate syntax as not in request.
- No grammar, keyword, or source syntax change is described as authorized.

[S] The revised request does not authorize new SemanticIR node kinds.

Evidence:

- The request relies on existing TEMPORAL artifacts and already-emitted
  metadata.
- It does not add node kinds beyond current `temporal_input_node` /
  `temporal_access_node` and assembled temporal artifact metadata.

[S] The revised request does not authorize BiHistory production evaluation.

Evidence:

- The request scope is `History[T] valid_time only`.
- BiHistory is explicitly excluded in Section III and Section VII.
- AT-7 requires any BiHistory artifact reaching the executor to refuse.
- Recommendation condition 2 keeps BiHistory deferred.

[S] The revised request does not authorize stream or OLAP executors.

Evidence:

- Section III excludes stream executor and OLAP executor.
- Section VII repeats stream/OLAP executor as separate lanes.

[S] The revised request does not authorize production cache.

Evidence:

- Section III excludes production RuntimeMachine memoization/cache.
- Q4 asks for a decision and Section VI recommends deferral.
- AT-6 authorizes cache-key validation before cache/backend access, not cache
  operation.

---

## AT-10 Review

[D] AT-10 is semantically precise enough for Architect review.

AT-10 now requires every authorized live `History[T]` read to emit a structured
observation record. It correctly separates:

- emission requirement: mandatory before/with live read;
- persistence requirement: proof-local / later track;
- formal observation kind registration: still a named implementation/spec gap.

[R] Implementation should not treat "closest available PROP-005 envelope kind"
as a permanent name. The executor implementation record should name the exact
temporary observation kind it uses and route a later observation-kind registry
or Ch7/PROP-005 sync if needed.

This is not a blocker for Architect review.

---

## AT-12 Review

[D] AT-12 is semantically precise enough for Architect review.

The TEMPORAL executor must check `fragment_class` on every incoming artifact and
refuse CORE artifacts before evaluation. This is coherent with the scope model:
CORE contracts should be evaluated by the normal RuntimeMachine path, not by
the TEMPORAL executor under Gate 3.

[R] Implementation should generalize the same guard pattern for all out-of-scope
artifacts that reach the TEMPORAL executor:

```text
CORE      -> gate-scope-exclusion refusal
STREAM    -> gate-scope-exclusion refusal
OLAP      -> gate-scope-exclusion refusal
BiHistory -> gate-scope-exclusion refusal
```

The request already excludes STREAM/OLAP/BiHistory elsewhere, so this is an
implementation clarity recommendation rather than a hold.

---

## Terminology Check

[S] `History[T]`, `valid_time`, and `as_of` terminology is consistent.

The request uses:

- `History[T] valid_time only` for the authorization scope;
- `read_as_of(as_of: DateTime)` for the TBackend read call;
- `same inputs + different as_of` for cache-key evidence;
- `history_read` for the required capability.

[S] BiHistory terminology is also precise:

- `BiHistory[T]` / bitemporal evaluation is excluded;
- physical `at(vt:, tt:)` serving proof is named as the prerequisite for any
  later two-axis gate;
- descriptor `bihistory_read` is not treated as physical serving proof.

No terminology correction is required.

---

## Ch7 Sync Routing

[D] Ch7 sync is correctly routed as post-approval work.

The request does not pretend Ch7 already contains the approved Gate 3
enforcement contract. It says that if Gate 3 is approved,
`spec-ch7-gate3-approval-sync` should be routed to close the lag between Ch7
baseline semantics and PROP-030 enforcement ordering.

This is the right ordering:

```text
Architect decision first -> then Ch7 sync with accepted gate semantics
```

---

## Spec-Lag List

[R] Ch7 Runtime:

- Current Ch7 documents baseline `load_accept_evaluate_refuse`.
- If Gate 3 is approved, sync Ch7 with:
  - approval-token validation ordering;
  - Gate 3 state check;
  - `runtime_enforced: true`;
  - AT-1 through AT-12;
  - post-refusal no-live-call invariant.

[R] PROP-030 / authority format:

- If Gate 3 is approved, record the authority ref format, issuance process, and
  revocation mechanism in the Architect decision record and/or a PROP-030
  errata.

[R] Observation envelope:

- AT-10 requires emission now, but the exact live temporal read observation kind
  is not formally registered. Route a small observation-kind sync after the
  implementation chooses the concrete envelope name.

[R] CompatibilityReport composition:

- The request correctly names `compatibility-report-composition-v0` as pending
  before live eval. This is not a request-review blocker, but it is a
  pre-live-evaluation requirement.

---

## Required Edits

[D] No request edits required from this review.

No typo-level edit was applied.

---

## Handoff

```text
Card: S3-R12-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: gate3-request-revision-spec-review-v0
Status: done

[D] Decisions
- Verdict: ready for Architect review.
- Revised request does not authorize parser syntax, new SemanticIR nodes,
  BiHistory production evaluation, stream/OLAP executor, or production cache.
- AT-10 and AT-12 are semantically acceptable.
- Ch7 sync is correctly post-approval.

[S] Signals
- History[T] / valid_time / as_of terminology is consistent.
- BiHistory exclusion is explicit and tied to missing physical at(vt:, tt:)
  serving proof.
- Production cache remains deferred; cache-key validation remains required.

[T] Tests / Proofs
- Documentation review only.
- `git diff --check` recommended for this track doc.

[R] Risks / Recommendations
- Post-approval Ch7 sync required if Architect opens Gate 3.
- Authority format belongs in the decision record and/or PROP-030 errata.
- Implementation should name exact refusal reasons for out-of-scope artifacts
  hitting TemporalExecutor.

[Next] Suggested next slice
- Architect Supervisor decision record, or redirect with scope changes.
```

## Files Changed

```text
igniter-lang/docs/tracks/gate3-request-revision-spec-review-v0.md
```

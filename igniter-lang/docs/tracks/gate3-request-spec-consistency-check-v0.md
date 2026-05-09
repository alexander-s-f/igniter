# Track: Gate 3 Request Spec Consistency Check v0

Card: S3-R11-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `gate3-request-spec-consistency-check-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Check the Gate 3 request shape against current language specs and PROPs for
semantic consistency, without implementing parser, runtime, executor, or
package changes.

---

## Inputs Reviewed

- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/operating-model.md`
- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/proposals/PROP-030-executor-approval-token-contract-v0.md`
- `docs/spec/ch6-semanticir.md`
- `docs/spec/ch7-runtime.md`
- `docs/discussions/gate3-request-readiness-pressure-v0.md`
- `docs/tracks/executor-approval-token-report-proof-v0.md`
- `docs/tracks/guarded-runtime-executor-approval-enforcement-v0.md`
- `docs/tracks/executor-boundary-cache-key-contract-v0.md`
- `docs/tracks/compatibility-report-package-descriptor-consumption-v0.md`

---

## Primary Finding

[D] No actual Gate 3 request artifact exists yet.

`runtime-temporal-executor-gate3-request-v0` is routed by discussion/status
documents, but no proposal or track document with that request is present under
`docs/`. Therefore this slice can validate the required request shape, not an
existing request text.

[R] The missing request artifact is the only hard blocker found in this check.
The current specs and PROPs are coherent enough to draft it, provided the
required edits below are included before Architect review.

---

## Spec Consistency Notes

### PROP-028 TEMPORAL fragment/cache semantics

[S] Alignment:

- `History[T]` and `BiHistory[T]` are TEMPORAL reads.
- TEMPORAL nodes require TBackend capability but produce CORE-typed values.
- The containing contract remains TEMPORAL.
- No `fold_temporal` exists or should be introduced.
- CORE cache key is `hash(contract, inputs)`.
- TEMPORAL cache key is `hash(contract, inputs, temporal_coordinates)`.
- CORE-shaped keys for TEMPORAL contracts are semantic faults.

[R] Required request wording:

```text
Gate 3 does not change parser syntax or fragment classification.
Gate 3 only requests production evaluation authority for already-emitted
TEMPORAL artifacts that passed Parser -> Classifier -> TypeChecker ->
SemanticIREmitter.emit_typed -> Assembler.
```

### PROP-030 ExecutorApprovalToken

[S] Alignment:

- `ExecutorApprovalToken` is necessary but insufficient.
- The token is not authority by itself; it must reference a recorded authority
  decision and still be checked against Gate 3 state.
- `.igapp` may declare approval requirements but must not self-authorize.
- CompatibilityReport may report token validity but must not grant permission.

[R] Required request wording:

```text
Evaluation requires:
capabilities -> ExecutorApprovalToken -> Gate 3 open -> TEMPORAL cache key
schema -> artifact guard policy.
```

The request must also state that all refusal checks happen before executor,
TBackend, Ledger, or cache calls.

### Ch6 SemanticIR temporal metadata

[S] Alignment:

- `temporal_input_node` and `temporal_access_node` are the canonical temporal
  SemanticIR nodes.
- Assembled contracts carry `temporal_nodes`.
- `manifest.fragment_summary` and `manifest.contract_index` are the load-time
  projections used for temporal dispatch.
- `requirements.json` is derived from `escape_boundaries` and temporal nodes.
- `compatibility_metadata.guard_policy` remains
  `load_accept_evaluate_refuse` before Gate 3.

[R] Required request wording:

```text
Gate 3 uses existing assembled metadata:
manifest.contract_index.<contract>.temporal.cache_key_schema_hint
contracts/<contract>.json.temporal_nodes
requirements.json.required_tbackend_caps
compatibility_metadata.runtime_execution.guard_policy
```

Do not describe Gate 3 as adding new parser declarations or new SemanticIR
node kinds.

### Ch7 Runtime load/evaluate boundary

[S] Alignment:

- Current Ch7 allows TEMPORAL load for inspection.
- Current Ch7 refuses TEMPORAL evaluate without approved runtime support.
- Production cache remains disabled.
- Ledger/TBackend live binding remains out of scope until explicit approval.

[R] Spec-lag note:

Ch7 is correct for the baseline `load_accept_evaluate_refuse` boundary, but it
does not yet list the PROP-030 approval-token refusal matrix or the complete
production check ordering from the S3-R10 proofs. A Gate 3 request should carry
that ordering explicitly and should route a later `spec-ch7-gate3-approval-sync`
if the request is accepted.

---

## Terminology Check

[D] Use precise temporal terms:

| Term | Precise meaning |
| --- | --- |
| `History[T]` | single-axis valid-time temporal source |
| `as_of` | explicit valid-time coordinate for `History[T]` |
| `BiHistory[T]` | bitemporal source with valid-time and transaction-time axes |
| `vt` / `valid_time` | valid-time coordinate for `BiHistory[T]` |
| `tt` / `transaction_time` | transaction-time coordinate for `BiHistory[T]` |
| `history_read` | canonical capability for `History[T]` read |
| `bihistory_read` | canonical capability for `BiHistory[T]` read |

[R] Avoid ambiguous request phrases:

- Do not use `as_of/Tt` as the only description of BiHistory keys.
- Do not call `bitemporal_read` canonical; it is at most a compatibility alias.
- Do not say temporal reads produce TEMPORAL values; they produce CORE-typed
  values from TEMPORAL nodes.

---

## Syntax / Parser Authorization Check

[D] Gate 3 must not authorize source syntax changes.

Allowed by a Gate 3 request:

- production runtime evaluation authority for already-compiled TEMPORAL
  artifacts, if all approval and enforcement conditions pass;
- production enforcement of token, capability, cache-key, and guard checks;
- TBackend read binding scoped to the requested temporal operation.

Not allowed by a Gate 3 request:

- parser support for new coordinate syntax;
- new keywords or grammar reservations;
- `fold_temporal`;
- changing `History[T]` / `BiHistory[T]` type syntax;
- changing entrypoint/section syntax status.

---

## Exclusion Consistency Check

[S] The expected exclusions do not contradict current specs if they are framed
as Gate 3 scope restrictions, not language rejections.

Safe exclusions:

- production stream executor;
- production OLAP executor/scatter-gather;
- production runtime cache/memoization;
- Ledger write, append, compact, subscribe, and replay;
- parser/runtime changes for entrypoint or section;
- self-issued approval tokens;
- capability-flag-only authorization;
- evaluation without valid `ExecutorApprovalToken`;
- BiHistory evaluation, if the request chooses a restricted History-only
  opening.

[R] If BiHistory is excluded, the request must say:

```text
BiHistory[T] remains a language-supported TEMPORAL surface, but production
BiHistory evaluation is outside this Gate 3 opening and requires a later
physical serving proof.
```

That avoids contradicting PROP-028, Ch6, and current proofs.

---

## Required Edits Before Gate 3 Request Review

[R] Author the missing request document.

Recommended path:

```text
docs/proposals/PROP-031-runtime-temporal-executor-gate3-request-v0.md
```

or, if the supervisor wants a non-PROP gate artifact:

```text
docs/tracks/runtime-temporal-executor-gate3-request-v0.md
```

[R] The request must include:

1. authorization scope:
   - History-only valid-time, or History + BiHistory;
2. explicit exclusions list;
3. no parser/syntax authorization statement;
4. dependency list:
   - PROP-028;
   - PROP-030;
   - Ch6 temporal metadata;
   - Ch7 load/evaluate boundary;
   - S3-R9/S3-R10 proof tracks;
5. production check ordering:
   - capabilities;
   - approval token;
   - Gate 3 state;
   - TEMPORAL cache key schema;
   - artifact guard;
6. `runtime_enforced: true` requirement before live evaluation;
7. authority registry / revocation / signature requirement;
8. CompatibilityReport composition requirement;
9. audit/persistence requirement for approval and refusal outcomes;
10. implementation owner per acceptance condition.

[R] If the request includes BiHistory production evaluation, it must add a
blocking acceptance item for physical `at(vt:, tt:)` serving proof. If it does
not include that proof, choose History-only scope.

[R] If the request cites Ch7 as fully sufficient, edit that claim. Ch7 is a
baseline runtime boundary; PROP-030 and S3-R10 tracks provide the stricter
Gate 3 approval/enforcement layer.

---

## Blockers

[R] Blocker before approval: missing Gate 3 request artifact.

[R] Blocker inside the request unless explicitly scoped away: BiHistory
physical serving proof.

[R] Blocker before live evaluation: production RuntimeMachine enforcement of
the approval/Gate3/cache/guard ordering with `runtime_enforced: true`.

No parser, grammar, SemanticIR node-shape, or cache-key semantic blocker was
found for drafting the request.

---

## Handoff

```text
Card: S3-R11-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: gate3-request-spec-consistency-check-v0
Status: done

[D] Decisions
- No Gate 3 request artifact exists yet; only routed pressure exists.
- Current PROP-028/PROP-030/Ch6/Ch7 materials are coherent enough to draft it.
- Gate 3 must not authorize parser or syntax changes.
- History and BiHistory terminology must stay axis-precise.

[S] Signals
- Ch6 temporal metadata aligns with the required request shape.
- Ch7 baseline load/evaluate boundary aligns, but Gate 3 approval ordering must
  come from PROP-030 + S3-R10 proofs.
- Expected exclusions are spec-consistent when framed as scope restrictions.

[T] Tests / Proofs
- Documentation consistency review only.
- `git diff --check` recommended for this track doc.

[R] Risks / Recommendations
- Author the missing request artifact before Architect review.
- Choose History-only or History+BiHistory scope explicitly.
- Route a later Ch7 sync if Gate 3 approval semantics are accepted.

[Next] Suggested next slice
- runtime-temporal-executor-gate3-request-v0: author the actual request with
  scope, exclusions, check ordering, authority, and acceptance conditions.
```

## Files Changed

```text
igniter-lang/docs/tracks/gate3-request-spec-consistency-check-v0.md
```

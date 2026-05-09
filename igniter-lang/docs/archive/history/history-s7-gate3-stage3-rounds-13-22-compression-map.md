# History-S7 Gate 3 Stage 3 R13-R22 Compression Map

Card: S3-R22-C4-S
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `gate3-stage3-rounds-13-22-compression-v0`
Status: done
Date: 2026-05-09

---

## Boundary

This is a compact archaeology map for the Gate 3 journey from S3-R13 through
S3-R22. It compresses landed status/maps/tracks into a durable memory layer.

It does not rewrite gate decisions, specs, proposals, runtime code, or active
status maps. It does not authorize new behavior.

Source layer:

- [agent-context.md](../../agent-context.md)
- [current-status.md](../../current-status.md)
- [gates/README.md](../../gates/README.md)
- round status tracks R13-R22
- named proof/pressure tracks linked below

---

## Final Compressed State

Gate 3 reached:

```text
SIGNED-APPROVED-RESTRICTED-PHASE1-LIVE-READ
```

Only this narrow scope is signed:

```text
IgniterLang::TemporalExecutor::Phase1
History[T] valid_time read
single explicit as_of coordinate
MemoryBackend or explicitly named non-Ledger Phase 1 backend
caller supplies gate3_authorized: true only with signed addendum evidence
```

Still closed:

```text
Phase 2
Ledger adapter / Ledger package binding
BiHistory / transaction-time
stream / OLAP executors
production cache
writes / replay / compact / subscribe
durable audit / production storage
production authority registry
production signing / key management
```

---

## R13-R22 Map

| Round | Compression | Primary artifacts |
|-------|-------------|-------------------|
| R13 decision | Gate 3 moves from ready-for-review to `approved-restricted-phase1`. Implementation may begin for History[T] valid_time via abstract/non-Ledger TBackend, but live reads remain blocked. | [stage3-round13-status-curation-v0.md](../../tracks/stage3-round13-status-curation-v0.md), [gate3-decision-record-v0.md](../../gates/gate3-decision-record-v0.md), [gate3-decision-safety-pressure-v0.md](../../discussions/gate3-decision-safety-pressure-v0.md) |
| R14 pre-live prep | Phase 1 authority URI wording, proof-local preflight, scope exclusion, composed-report preflight, Ch7 sync, and safety pressure land. The round closes with pre-live blockers still open: ordering, AT-2, AT-9, regression. | [stage3-round14-status-curation-v0.md](../../tracks/stage3-round14-status-curation-v0.md), [runtime-temporal-executor-phase1-preflight-v0.md](../../tracks/runtime-temporal-executor-phase1-preflight-v0.md), [temporal-scope-exclusion-runtime-fixture-v0.md](../../tracks/temporal-scope-exclusion-runtime-fixture-v0.md), [runtime-report-enforcement-preflight-v0.md](../../tracks/runtime-report-enforcement-preflight-v0.md), [spec-ch7-gate3-approval-sync-v0.md](../../tracks/spec-ch7-gate3-approval-sync-v0.md) |
| R15 blocker closure | Ordering is fixed to token-before-gate; AT-2 composed report integration closes; AT-9 authority_ref exact-match proof passes; pre-live regression chain passes 17/17. Lib-prep may proceed, but live reads remain blocked. | [stage3-round15-status-curation-v0.md](../../tracks/stage3-round15-status-curation-v0.md), [runtime-report-enforcement-order-amendment-v0.md](../../tracks/runtime-report-enforcement-order-amendment-v0.md), [runtime-temporal-executor-composition-integration-v0.md](../../tracks/runtime-temporal-executor-composition-integration-v0.md), [executor-approval-authority-ref-proof-v0.md](../../tracks/executor-approval-authority-ref-proof-v0.md), [phase1-prelive-regression-chain-v0.md](../../tracks/phase1-prelive-regression-chain-v0.md) |
| R16 lib-prep | `IgniterLang::TemporalExecutor::Phase1` lands in `lib/` with proof-local targeted PASS 17/17 and default blocked state. Async-order issue leaves C2/C3 stale and requires R17 repair. | [stage3-round16-status-curation-v0.md](../../tracks/stage3-round16-status-curation-v0.md), [runtime-temporal-executor-lib-prep-v0.md](../../tracks/runtime-temporal-executor-lib-prep-v0.md), [phase1-lib-prep-regression-chain-v0.md](../../tracks/phase1-lib-prep-regression-chain-v0.md), [runtime-temporal-executor-lib-boundary-spec-sync-v0.md](../../tracks/runtime-temporal-executor-lib-boundary-spec-sync-v0.md) |
| R17 repair + pressure | Post-C1 regression rerun passes 14/14; Ch7 lib-boundary sync rerun lands; safety pressure says PROCEED for proof-local Phase 1 and routes addendum draft plus cleanup. | [stage3-round17-status-curation-v0.md](../../tracks/stage3-round17-status-curation-v0.md), [phase1-lib-prep-regression-chain-rerun-v0.md](../../tracks/phase1-lib-prep-regression-chain-rerun-v0.md), [runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0.md](../../tracks/runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0.md), [runtime-temporal-executor-lib-prep-safety-pressure-v0.md](../../discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md) |
| R18 draft + guards | Live-read addendum is drafted but not signed. Proof-local docstrings, canonical scope-exclusion aliasing, and backend identity guard land. Safety pressure finds no hidden live path but requires post-R18 regression and addendum guard-order amendment before signature. | [stage3-round18-status-curation-v0.md](../../tracks/stage3-round18-status-curation-v0.md), [gate3-live-read-decision-addendum-v0.md](../../gates/gate3-live-read-decision-addendum-v0.md), [temporal-executor-proof-local-docstring-amendment-v0.md](../../tracks/temporal-executor-proof-local-docstring-amendment-v0.md), [runtime-temporal-scope-exclusion-reason-alias-v0.md](../../tracks/runtime-temporal-scope-exclusion-reason-alias-v0.md), [phase1-backend-identity-guard-v0.md](../../tracks/phase1-backend-identity-guard-v0.md), [gate3-live-read-addendum-pre-signature-pressure-v0.md](../../discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md) |
| R19 pre-signing repair | Post-R18 regression passes 15/15 and records backend identity observation. Addendum guard order is amended to match implementation. Pressure says PROCEED to Architect signature review; status remains draft-not-signed. | [stage3-round19-status-curation-v0.md](../../tracks/stage3-round19-status-curation-v0.md), [phase1-r18-cleanup-regression-rerun-v0.md](../../tracks/phase1-r18-cleanup-regression-rerun-v0.md), [gate3-live-read-addendum-pre-signature-pressure-v0.md](../../discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md), [gate3-live-read-decision-addendum-v0.md](../../gates/gate3-live-read-decision-addendum-v0.md) |
| R20 signature + post-signature proof | Architect signs the restricted live-read addendum. First post-signature fixture passes 10/10 and proves signing is policy-only: caller status changes, executor behavior and exclusions do not widen. Pressure says PROCEED. | [stage3-round20-status-curation-v0.md](../../tracks/stage3-round20-status-curation-v0.md), [gate3-live-read-decision-addendum-v0.md](../../gates/gate3-live-read-decision-addendum-v0.md), [gate3-first-post-signature-fixture-v0.md](../../tracks/gate3-first-post-signature-fixture-v0.md), [gate3-post-signature-runtime-pressure-v0.md](../../discussions/gate3-post-signature-runtime-pressure-v0.md) |
| R21 audit / registry shaping | Audit-ready envelope proof passes 10/10, explicitly not persisted. Authority registry shape passes 11/11, proof-local only, no signing/keys/executor calls. Pressure routes production checklist without implying durable audit or production signing. | [stage3-round21-status-curation-v0.md](../../tracks/stage3-round21-status-curation-v0.md), [compatibility-report-persistence-audit-v0.md](../../tracks/compatibility-report-persistence-audit-v0.md), [gate3-authority-registry-shape-v0.md](../../tracks/gate3-authority-registry-shape-v0.md), [phase1-post-signature-audit-registry-pressure-v0.md](../../discussions/phase1-post-signature-audit-registry-pressure-v0.md) |
| R22 end-to-end + content address | End-to-end proof passes 9/9: registry check -> caller authorization -> Phase1 executor -> audit-ready envelope. Content-addressed addendum ref proof passes 9/9; path-only evidence becomes non-compliant. Pressure closes P-4/P-5 and adds P-8 post-R22 regression rerun. | [stage3-round22-status-curation-v0.md](../../tracks/stage3-round22-status-curation-v0.md), [phase1-end-to-end-invocation-fixture-v0.md](../../tracks/phase1-end-to-end-invocation-fixture-v0.md), [phase1-addendum-content-address-ref-v0.md](../../tracks/phase1-addendum-content-address-ref-v0.md), [phase1-e2e-and-content-address-pressure-v0.md](../../discussions/phase1-e2e-and-content-address-pressure-v0.md) |

---

## Reusable Process Pattern

Gate 3 R13-R22 crystallized this reusable pattern:

```text
request
-> decision
-> proof
-> pressure
-> signature
-> post-signature fixture
-> audit/registry hardening
-> end-to-end/content-address proof
```

Concrete reading:

| Pattern step | Gate 3 instance | Lesson |
|--------------|-----------------|--------|
| Request | R11/R12 Gate 3 request and revision package | A request prepares evidence; it does not authorize behavior. |
| Decision | R13 `approved-restricted-phase1` | A decision may authorize implementation while still blocking live use. |
| Proof | R14/R15 pre-live proofs and R16 lib-prep | Proofs must close named acceptance conditions, not just demonstrate happy paths. |
| Pressure | X1 reviews at R13/R14/R17/R18/R19/R20/R21/R22 | Pressure is a safety loop that routes blockers and confirms non-widening. |
| Signature | R20 signed addendum | Signature changes policy state only inside exact scope. |
| Post-signature fixture | R20 C2 | Always prove that signing did not silently change runtime behavior. |
| Audit/registry hardening | R21 | After authorization, make evidence export and caller authority explicit before production. |
| E2E/content-address proof | R22 | Compose registry, caller, executor, audit, and content identity before productionizing. |

---

## Invariants Preserved

[D] Caller policy and executor guard are separate.

[D] `gate3_authorized: true` is never executor self-authorization.

[D] Backend identity check blocks Ledger-like/proxy/unmarked backends before
read paths.

[D] `runtime.temporal_scope_exclusion` is the canonical refusal family for
out-of-scope temporal execution.

[D] Audit-ready is not durable audit.

[D] Registry shape is not production registry/signing/key management.

[D] Path-only signed-addendum evidence is not sufficient after R22.

---

## Future Agents: Read First

For Gate 3 / Phase 1 work after R22, read in this order:

1. [agent-context.md](../../agent-context.md)
2. [current-status.md](../../current-status.md)
3. [gates/README.md](../../gates/README.md)
4. [gate3-live-read-decision-addendum-v0.md](../../gates/gate3-live-read-decision-addendum-v0.md)
5. [stage3-round22-status-curation-v0.md](../../tracks/stage3-round22-status-curation-v0.md)
6. [phase1-end-to-end-invocation-fixture-v0.md](../../tracks/phase1-end-to-end-invocation-fixture-v0.md)
7. [phase1-addendum-content-address-ref-v0.md](../../tracks/phase1-addendum-content-address-ref-v0.md)
8. [compatibility-report-persistence-audit-v0.md](../../tracks/compatibility-report-persistence-audit-v0.md)
9. [gate3-authority-registry-shape-v0.md](../../tracks/gate3-authority-registry-shape-v0.md)

Do not start from the whole R13-R22 track stack unless the assigned card asks
for archaeology or regression repair.

---

## Next Routes Preserved

From the R22 close state:

1. `phase1-post-r22-regression-rerun-v0`
2. `durable-observation-persistence-v0`
3. `gate3-authority-registry-v1`
4. production compliance amendment rejecting `git_commit: workspace-current`
   outside proof-local mode
5. `gate3-production-signing-v1` only after registry ordering is defined

---

## Handoff

Card: S3-R22-C4-S
Agent: `[Igniter-Lang Archive/Form Expert]`
Role: archive-form-expert
Track: `gate3-stage3-rounds-13-22-compression-v0`
Status: done

[D] Gate 3 R13-R22 compressed into a compact archaeology map.

[S] Source layer is bounded to current maps, status tracks, gate index, and
named proof/pressure tracks.

[T] No specs, gate decisions, runtime code, or active status maps were changed.

[R] Future Gate 3 agents should start from the read-first list above, not from
the full historical stack.

[Next] Use this map as the compression layer before R23 regression, durable
persistence, authority registry v1, or production signing work.

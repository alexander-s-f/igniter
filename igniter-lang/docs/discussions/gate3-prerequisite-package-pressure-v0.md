# Discussion: Gate 3 Prerequisite Package Pressure

Card: S3-R9-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: gate3-prerequisite-package-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Is the S3-R9 Gate 3 prerequisite package coherent enough to prepare a Gate 3
opening request, or do silent authorization/staleness/enforcement risks remain
that would make any Gate 3 request unsound?

## Context: S3-R9 C2–C4 Summary

**C2** `PROP-030-executor-approval-token-contract-v0` (Compiler/Grammar Expert)

- Defines `ExecutorApprovalToken` as the canonical approval object for Gate 3
- Authority source: recorded/signed Architect decision
- Token binds: gate (`tbackend_gate3`), scope (`temporal_evaluate`), artifact
  ref, contract refs, capability refs, issued_at/expires_at, revocation status,
  evidence_ref, token_hash/signature
- Defines 3 load-time approval refusals (L-AT1..L-AT3)
- Defines 13 runtime approval refusals (`runtime.executor_approval_*` + Gate 3
  closed + TEMPORAL cache schema mismatch)
- Gate 3 invariant: valid token + Gate 3 closed → `runtime.temporal_gate3_closed`
- Status: `proposal` — not implemented; Gate 3 not opened

**C3** `executor-boundary-cache-key-contract-v0` (Research Agent)

Proves TEMPORAL executor boundary must read `cache_key_schema_hint` from
`manifest.contract_index` and construct TEMPORAL-shaped keys. CORE-shaped keys
for TEMPORAL contracts refuse with `executor.cache_key_schema_mismatch` (L-T5
style). All 10 proof cases PASS:

```text
core.requested_core_key_accepted                  ok
history.temporal_key_includes_valid_time          ok
history.core_shaped_key_refused_l_t5              ok
history.silent_staleness_prevented                ok
bihistory.temporal_key_includes_vt_and_tt         ok
bihistory.core_shaped_key_refused_l_t5            ok
bihistory.silent_staleness_prevented              ok
```

**C4** `guarded-runtime-c2-profile-consistency-v0` (Research Agent)

Cross-checks S3-R8 C2 positive executor profiles against GuardedRuntimeMachine.
Both systems refuse evaluation for `claimed_executor_live_binding` and
`approved_executor_placeholder` profiles. Reason codes differ — the mapping is
explicit and accepted as intentionally lossy (GuardedRuntimeMachine predates the
approval-token/Gate 3 policy layer). All 12 proof cases PASS.

| CompatibilityReport reason | GuardedRuntimeMachine reason | Alignment |
|----------------------------|------------------------------|-----------|
| `runtime.temporal_executor_approval_missing` | `runtime.temporal_execution_not_implemented` | mapped |
| `runtime.temporal_gate3_closed` | `runtime.temporal_execution_not_implemented` | mapped |

---

## Evidence Base

```text
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/value-index.md
igniter-lang/docs/proposals/PROP-030-executor-approval-token-contract-v0.md
igniter-lang/docs/tracks/prop-030-executor-approval-token-contract-v0.md
igniter-lang/docs/tracks/executor-boundary-cache-key-contract-v0.md
igniter-lang/docs/tracks/guarded-runtime-c2-profile-consistency-v0.md
igniter-lang/docs/discussions/stage3-round8-pre-gate3-pressure-v0.md
```

---

## [Agree]

**PROP-030 resolves the undefined-term problem from S3-R8-X1-S.**

S3-R8-X1-S C-3 named "explicit executor approval" as a placeholder concept
with no production definition. PROP-030 now provides that definition:
`ExecutorApprovalToken` is a stable, scope-bound, expiry-and-revocation-aware
object backed by an authority record. The token is not a capability flag, not
a config entry, and not self-issued by the artifact — it is an explicit
authority contract.

The authority source ownership table (§2) is the right design:

```text
.igapp     → declares requirements; cannot self-authorize
config     → carries token ref; cannot be the authority source
report     → validates and reports; cannot grant permission
token      → canonical runtime contract; scoped and bounded
authority  → recorded Architect decision; must exist
```

This is the correct layering. It prevents the class of attacks where capability
flags or config entries can bypass the authorization layer.

**The PROP-030 refusal surface is complete and correctly ordered.**

The 13 runtime refusal codes cover the full space of token lifecycle failure:
missing, malformed, invalid signature, untrusted authority, expired, revoked,
wrong gate/scope/artifact/contract/capability, missing evidence, Gate 3 closed,
and TEMPORAL cache schema mismatch. The ordering rule (approval check before
executor call; Gate 3 closed even with valid token; cache schema check before
cache read/write) is correctly specified.

This ordering is important: it prevents a valid-token bypass of Gate 3 and a
CORE-shaped cache key bypass of the temporal coordinates requirement.

**C3 closes the silent staleness gap at the executor boundary.**

The PROP-028 §5.3 silent staleness scenario is now proved with real artifacts at
the executor layer:

```text
same inputs + different as_of → CORE key collides → TEMPORAL key is different
```

The proof uses three real artifacts (CORE Add, History, BiHistory) assembled from
the production compiler and reads `cache_key_schema_hint` from each artifact's
`manifest.contract_index`. This is the correct chain: the compiler assembles the
hint → the executor reads the hint → the executor constructs the right key shape.

**C4 validates report/runtime consistency for the previously untested profiles.**

The S3-R8-X1-S C-6 gap ("C2 profiles not validated against GuardedRuntimeMachine")
is now closed. Profiles 3 and 4 from C2 are confirmed: both systems refuse
evaluation, and the reason code mapping is explicitly documented rather than
silently assumed.

**The prerequisite package from S3-R8-X1-S is largely addressed:**

| S3-R8-X1-S prerequisite | Status after S3-R9 |
|--------------------------|-------------------|
| Executor approval token defined (blocking) | ✅ PROP-030 drafted |
| Cache key construction tested at executor boundary (HIGH) | ✅ C3 PASS |
| CompatibilityReport enforcement production-bound | ⚠️ still `report_only: true`, `runtime_enforced: false` |
| C2 profiles validated against GuardedRuntimeMachine (medium) | ✅ C4 PASS |

---

## [Challenge]

### C-1. `runtime_enforced: false` is still the state after S3-R9

Both PROP-030 and C4 acknowledge this explicitly:

- PROP-030 §5: "CompatibilityReport remains report-only until a future runtime
  proof binds the report decision to RuntimeMachine enforcement."
- C4 handoff: "A future RuntimeMachine executor slice should either preserve this
  mapping or add first-class approval/Gate 3 refusal fields to the guarded
  runtime layer."

The entire approval token and report shape machinery is correct but not enforced
by any production code. All proofs use `runtime_enforced: false` and
`report_only: true`. A production RuntimeMachine today could ignore every one of
the PROP-030 refusal codes and attempt TEMPORAL evaluation without consequence.

This is the correct state for a proposal-stage gate. The question is whether a
Gate 3 opening request can be written and evaluated before enforcement is proved,
or whether enforcement proof is a prerequisite to the request.

**Severity**: HIGH at Gate 3 opening. The request cannot say "authorize TEMPORAL
evaluation" while enforcement is still report-only. Enforcement must be
production-bound before any live TEMPORAL evaluation is attempted.

### C-2. GuardedRuntimeMachine reason code mapping is intentionally lossy

The C4 track accepts the lossy mapping as explicit. But the practical implication
is: if a production RuntimeMachine executor is built with GuardedRuntimeMachine as
its reference, it will have two generic refusal codes
(`temporal_execution_not_implemented`) where PROP-030 defines 13 specific ones.

The consequence: a production RuntimeMachine built from the current
GuardedRuntimeMachine reference cannot distinguish "approval missing" from "gate
closed" from "capabilities insufficient." A diagnostic tool or operator reading
the refusal would not know which condition to fix.

PROP-030's ordered refusal surface exists precisely to make failures diagnosable.
If the production runtime collapses that surface back to a single generic code,
the benefit of the specification is lost.

This is a **design fork**: either GuardedRuntimeMachine is updated to carry
first-class approval/Gate 3 codes (and becomes the trusted reference for
production), or the production RuntimeMachine is built from PROP-030 directly
and the GuardedRuntimeMachine mapping is acknowledged as a test-harness artifact.
Neither path is defined. The Gate 3 request must choose.

### C-3. Token validation matrix not yet proved for all 13 refusal cases

PROP-030 §8 recommends `executor-approval-token-report-proof-v0` to prove the
full token validation matrix. This track has not landed. The 13 runtime refusal
codes are defined but none are proved for token-level conditions:

```text
runtime.executor_approval_malformed         — not proved
runtime.executor_approval_signature_invalid — not proved
runtime.executor_approval_authority_untrusted — not proved
runtime.executor_approval_expired           — not proved
runtime.executor_approval_revoked           — not proved
runtime.executor_approval_wrong_gate        — not proved
runtime.executor_approval_wrong_scope       — not proved
runtime.executor_approval_artifact_mismatch — not proved
runtime.executor_approval_contract_mismatch — not proved
runtime.executor_approval_capability_mismatch — not proved
runtime.executor_approval_evidence_missing  — not proved
```

Only the first (`approval_missing`) is proven indirectly, via C4.

An implementation built from PROP-030 without these proof cases has no tested
behavior for expired tokens, revoked tokens, or scope mismatches. Each of those
is a real production failure mode. An expired token that is not refused is a
post-Gate-3 authorization bypass.

### C-4. Token issuance and revocation process not defined

PROP-030 defines the `ExecutorApprovalToken` shape but does not define:

- who is authorized to create a token (beyond "Architect Supervisor")
- how `token_hash` is computed (no canonical serialization rule specified)
- how a revocation is issued and propagated to RuntimeMachine instances
- what happens to in-flight evaluations when a token is revoked mid-operation
- how `authority_ref` is verified — is it a key fingerprint, a URL, a git
  commit hash of the decision record?

Without at least the first two being defined, a Gate 3 opening request that
includes a real token would have no unambiguous validation rule. The reviewer
asks: what is the hash input? What is the canonical authority identifier?

**Severity**: medium for the Gate 3 request document. These can be addressed in
the request itself, but they cannot be left as open design questions.

### C-5. C3 proof uses only single-contract artifacts; mixed bundles untested

The executor-boundary cache-key proof tests three single-contract `.igapp/`
artifacts. A production use case may bundle CORE and TEMPORAL contracts in one
`.igapp/` (e.g., an Add helper contract alongside a HistoryAxesTest contract).

The `manifest.contract_index` is per-contract, so by design the correct key
shape should be derivable for each contract independently. But the proof doesn't
verify that a mixed bundle doesn't allow a TEMPORAL contract's key to be
misread as CORE due to index traversal error.

**Severity**: low — per-contract indexing should handle this. But a single
mixed-bundle test case would close this explicitly.

---

## [Missing]

### M-1. Enforcement proof as a Gate 3 opening prerequisite

The current-status and PROP-030 both acknowledge that `runtime_enforced: false`
must become `true` before any live TEMPORAL evaluation. But neither document
makes this a named prerequisite with a track. DOC-DEBT-02 in current-status
notes "PROP-030 token report proof, guarded runtime approval enforcement" as
follow-ups — but these are listed as debt items, not as requirements for the
Gate 3 opening request.

Needed: the Gate 3 opening request must explicitly name:

```text
Before FIRST live TEMPORAL evaluation:
  RuntimeMachine must enforce CompatibilityReport.evaluation_readiness
  RuntimeMachine must enforce ExecutorApprovalToken validation
  runtime_enforced: true in all relevant report dimensions
```

If this is not in the Gate 3 request, the Architect Supervisor approving it
cannot know whether enforcement is assumed or deferred.

### M-2. GuardedRuntimeMachine upgrade decision as part of Gate 3 request

The C4 lossy mapping gap needs a resolution before the Gate 3 request is
written. Two paths:

**Path A**: Update GuardedRuntimeMachine to carry first-class approval/Gate 3
refusal codes before the request. GuardedRuntimeMachine becomes the testable
reference for all PROP-030 refusal codes.

**Path B**: Explicitly state in the Gate 3 request that production RuntimeMachine
must be implemented from PROP-030 directly, and that GuardedRuntimeMachine is
retained as a legacy test harness only (mapping intentional, not normative).

Path B is lower cost and correct in spirit — GuardedRuntimeMachine is already
proof-local and predates the policy layer. Path A is higher fidelity but adds
a track. Either path is acceptable; unresolved is not.

### M-3. Token validation matrix as a Gate 3 request proof attachment

The 11 unproved token refusal cases from PROP-030 should be proved before the
Gate 3 request is submitted to Architect Supervisor, not after. The request
should include a summary evidence pointer to a proof that covers at minimum:
expired, revoked, wrong artifact, wrong capability.

These are not complex proofs — each is one case in an extended
`runtime_compatibility_report_temporal_load_check`. Adding them before the
request ensures the Architect is reviewing a gate with tested behavior, not
a gate with specified-but-untested behavior.

---

## [Sharper Question]

Not: "Is the prerequisite package complete?"

The package is coherent. The conceptual design is sound. The sharper question is:

> **What must be in the Gate 3 opening request for Architect Supervisor to be
> able to evaluate it as a complete safety proposal — not a progress report?**

A Gate 3 opening request that says "prerequisites are done" without addressing
enforcement commitment, GuardedRuntimeMachine path, and token proof coverage
would leave the Architect with open design questions at review time. Those
questions would either block the decision or result in a gate that opens with
underspecified safety guarantees.

The three M items above are what make the request reviewable by Architect
Supervisor as a complete proposal:

1. **Enforcement commitment** (M-1): explicit statement that `runtime_enforced:
   true` is required before any live evaluation, and who is responsible for
   building that enforcement.
2. **GuardedRuntimeMachine path decision** (M-2): Path A or Path B stated
   explicitly — not left to implementation teams to guess.
3. **Token proof coverage** (M-3): at minimum expired, revoked, wrong artifact,
   wrong capability cases proved before the request is submitted.

---

## [Route]

→ **PROCEED to Gate 3 request prep.** The prerequisite package is coherent.
  No silent bugs remain in the current proof state. Gate 3 is correctly
  closed. The S3-R8-X1-S blocking prerequisites are addressed at the
  conceptual level. The remaining gaps are not new production risks — they
  are specification and enforcement clarity gaps that belong in the Gate 3
  request document.

→ **track** → Research Agent: `executor-approval-token-report-proof-v0`
  Scope: extend `runtime_compatibility_report_temporal_load_check` with
  at minimum: expired token, revoked token, wrong artifact, wrong capability.
  Complete the 11 unproved PROP-030 token refusal cases.
  Priority: **required before Gate 3 request submission to Architect**.

→ **decision** (not a track) → Architect Supervisor: choose Path A or Path B
  for GuardedRuntimeMachine reason code resolution before Gate 3 request
  is drafted. The implementers cannot resolve this — it is a design contract
  that the request author (Meta Expert + C/G Expert) must settle first.

→ **track** (optional before Gate 3 request) → Research Agent: one mixed-bundle
  (CORE + TEMPORAL contracts) case in `executor_boundary_cache_key_contract`
  to close C-5. Low cost; closes an explicit gap in the proof.

→ **Gate 3 request** (when M-1, M-2, M-3 are resolved): author as a joint
  Compiler/Grammar Expert + Meta Expert document that includes enforcement
  commitment text, GuardedRuntimeMachine disposition, token proof summary
  pointer, and explicit Architect decision prompt. Do not open Gate 3 from
  any other artifact.

---

## Risk Table

| Risk | Evidence | Severity | Gate 3 blocking? | Status |
|------|----------|----------|-----------------|--------|
| `runtime_enforced: false` — no production enforcement of approval or report | PROP-030, C4 | HIGH | **YES** | must be addressed in Gate 3 request |
| GuardedRuntimeMachine reason codes are intentionally lossy — no first-class approval/Gate-3 refusal | C4 | Medium | **Design decision required** | Path A or B must be chosen before request |
| 11 token validation matrix cases unproved (expired, revoked, wrong artifact, etc.) | PROP-030 §8 missing | Medium | **YES (for request quality)** | route: `executor-approval-token-report-proof-v0` |
| Token issuance/revocation/hash process not defined | PROP-030 §4 open | Medium | Yes for reviewability | must be in Gate 3 request text |
| C3 cache-key proof uses only single-contract artifacts | C3 scope | Low | No | optional: add mixed-bundle case |
| BiHistory smoke uses single domain fixture | S3-R8-C1 | Low | No | acceptable for current milestone |

**Overall: PROCEED to Gate 3 request prep.** The conceptual prerequisites are
complete and coherent. Three items (enforcement commitment, GuardedRM path
decision, token proof coverage) belong in the Gate 3 request, not in
prerequisite tracks. The request cannot be submitted to Architect Supervisor
without resolving these — but they do not block writing the request. Writing the
request is the right forcing function.

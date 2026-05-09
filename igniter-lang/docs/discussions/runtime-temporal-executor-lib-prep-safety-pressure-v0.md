# Discussion: Runtime Temporal Executor Lib-Prep Safety Pressure

Card: S3-R17-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: runtime-temporal-executor-lib-prep-safety-pressure-v0
Date: 2026-05-09
Status: complete — routed

---

## Question

Did `IgniterLang::TemporalExecutor::Phase1` enter `lib/` with its eight scope
guarantees intact — no live-read authorization, `gate3_authorized: false`
default, no Ledger path, no production cache, BiHistory/stream/OLAP refused,
authority_ref decision-record based, token-before-gate ordering, observation
emission not persistence — and did the post-C1 regression chain confirm no
behavior drift?

## Context: S3-R16-C1 + S3-R17-C1/C2

**S3-R16-C1** `runtime-temporal-executor-lib-prep-v0`

Extracts proof-local `Phase1TemporalExecutor` from `experiments/` into
`lib/igniter_lang/temporal_executor.rb` as `IgniterLang::TemporalExecutor::Phase1`.
Standalone (no experiment dependency). `gate3_authorized: false` default. Guard
order: `approval_token → gate_state → scope → cache_key → kernel`. AT-9 uses
`GATE3_AUTHORITY_REF` constant (exact URI from gate decision record). AT-10
observations appended unconditionally to in-memory `@observations`. 17/17
proof harness checks PASS.

**S3-R17-C1** `phase1-lib-prep-regression-chain-rerun-v0`

Post-C1 regression: 14/14 PASS across S3-R7..R10 base chain, S3-R13..R15
pre-live fixtures, S3-R16 targeted proof, Stage 1, and Stage 2. Key signal:
`at5.gate_closed.token_stage_passed_first: ok` explicitly verifies the canonical
ordering.

**S3-R17-C2** `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0`

Ch7 updated post-C1 to record the lib boundary. Ch7 now names:
`gate3_authorized: false` as the required construction default; the canonical
guard order `approval_token → gate_state → scope → TEMPORAL cache-key schema →
execution kernel`; the composed CompatibilityReport requirement; the exact
`authority_ref` match rule.

---

## Scope-Item Closure Check

### 1. Did Phase1 become live-read authorization?

- S3-R16-C1 non-authorization: "Live reads from any non-proof-local backend" ❌
- S3-R17-C1: "This is not live-read authorization. Live reads remain blocked until a separate Architect addendum."
- S3-R17-C2 Ch7: "Phase1 exists but live reads remain blocked."
- Remaining-items R1: `gate3-live-read-decision-addendum-v0` is explicitly required before any non-proof live reads.

**Verdict: ✅ No live-read authorization. The addendum requirement is stated and named.**

### 2. gate3_authorized: false default

- S3-R16-C1: "Phase1.new(backend:, gate3_authorized: false)" — default blocks at construction, not at call time.
- S3-R17-C1 regression: `gate_closed.blocked_at_gate_state: ok` / `gate_closed.no_live_operations: ok`
- S3-R17-C2 Ch7: default recorded as required construction rule.

**Verdict: ✅ Default is false; mis-construction blocks.**

### 3. No Ledger adapter/package path reachable

- AT-8 coverage: "No writes, no stream, no OLAP in lib/" ✅
- S3-R16-C1 ships `MemoryBackend`-based logic; no Ledger package required in lib/ file.
- Regression: `no_live_operations` checks PASS for all blocked paths.

**Verdict: ✅ No Ledger package code in lib/. See C-1 below for one nuance.**

### 4. No production cache

- S3-R16-C1 AT-1: "MemoryBackend only" — no cache store implemented.
- R4 explicitly defers production cache binding to Phase 2 addendum.
- No `cache_call_attempted` in any proof output.

**Verdict: ✅ Production cache absent.**

### 5. BiHistory / stream / OLAP remain refused

- AT-7 ✅: `bihistory_kernel.blocked_bihistory: ok` / `at7.bihistory.blocked: ok`
- AT-12 ✅: `core_fragment_kernel.blocked_core: ok` / `at12.core_fragment.blocked: ok`
- S3-R14-C3 scope exclusion fixture: STREAM, OLAP, BiHistory, Ledger write/replay all `runtime.temporal_scope_exclusion` — still PASS in regression chain.

**Verdict: ✅ Excluded. See C-2 below for reason code alias issue.**

### 6. Authority_ref exact match is decision-record based

- S3-R16-C1: `GATE3_AUTHORITY_REF` is the exact URI from `gate3-decision-record-v0.md §Authority Registry`.
- `check_approval_token` requires exact match; missing, stale, or self-issued refs refused with `AUTHORITY_UNTRUSTED`.
- Regression: `wrong_authority_ref.blocked_authority: ok` / `at9.wrong_authority.refused: ok`

**Verdict: ✅ Exact URI match enforced. See C-3 for scope of what this guarantees.**

### 7. Ordering is token-before-gate

- S3-R16-C1 guard order (from S3-R15-C1-P amendment): `approval_token → gate_state → scope → cache_key → kernel`
- Regression signal: `at5.gate_closed.token_stage_passed_first: ok` — this check name is explicit proof that the token stage runs and passes before the gate check fires.
- S3-R17-C2 Ch7: canonical order recorded as the lib boundary spec.

**Verdict: ✅ S3-R14-X1-S C-1 ordering conflict is closed. Token-before-gate is confirmed in the lib/ implementation and in the post-C1 regression.**

### 8. Observation emission not treated as persistence

- AT-10 implementation: `temporal_live_read_observation` appended unconditionally to `@observations` (in-memory array only).
- No persistence call in lib/. R3 explicitly flags persistence as a separate future gap.
- Regression: `at10.happy_path.observation_emitted: ok`
- S3-R16-C1 explicitly: "@observations is in-memory only."

**Verdict: ✅ Emission is unconditional; persistence is separately deferred.**

---

## [Agree]

**All eight scope items are confirmed closed for proof-local Phase 1 use.**

The regression chain (14/14 PASS) provides the strongest signal: no existing
proof in the S3-R7..R16 chain is broken by the lib-prep boundary. The guard
order fix from S3-R15-C1-P is confirmed in `token_stage_passed_first: ok`,
which closes the last open finding from S3-R14-X1-S (C-1). AT-9 URI comparison
is confirmed in `wrong_authority_ref.blocked_authority: ok`, which closes S3-R14-X1-S C-4.

**The `gate3_authorized: false` default is the correct lib-level gate mechanism.**

The default makes authorization opt-in, not opt-out. An instance constructed
without an explicit `gate3_authorized: true` will refuse live reads regardless
of what the backend supports or what token is presented. This means the safe
state is the default state — consistent with the gate decision record's
"Phase 1 live reads blocked until pre-live conditions pass" requirement.

**AT-2 is satisfied in lib/ via `compose_report`.**

S3-R14-X1-S C-2 flagged that AT-2 was deferred in the experiment executor. The
lib-prep track resolves this: `compose_report` builds a minimal
CompatibilityReport-shaped hash for every evaluation path (both blocked and
ready). Regression: `at2.happy_path.report_composed: ok` and
`happy_path.compatibility_report_present: ok`. AT-2 is now met at the lib/
boundary.

**Ch7 spec records the lib boundary correctly.**

S3-R17-C2 updates Ch7 with the exact guard order, the `gate3_authorized: false`
default, the composed-report requirement, and the AT-9 authority match rule.
The spec is no longer just describing the pre-gate3 boundary — it now names
the approved Phase 1 implementation surface. This closes the post-gate spec-lag
flagged as a post-gate backlog item in prior reviews.

**R1 through R8 are correctly identified as non-blocking for proof-local use.**

The lib-prep track's remaining-items list is accurate and conservative: none of
R1–R8 block proof-local use of the lib/ class. Each is correctly categorized
(R1 for non-proof live reads, R2 for Phase 2 signing, R3 for audit persistence,
R4 for real adapter binding, R5 for BiHistory separate gate, R6 for authority
registry, R7 for class consolidation, R8 for dedicated lib-prep regression).

---

## [Challenge]

### C-1. Backend parameter is unconstrained — no code-level guard against Ledger-backed adapters

The lib/ class signature is:

```text
Phase1.new(backend:, gate3_authorized: false)
```

The `backend:` parameter accepts any object that responds to `read_as_of`. No
type check, no class constraint, and no check of the backend's identity against
a Phase 2 Architect addendum. The lib/ code itself calls no Ledger package —
AT-8 is correct. But if someone passes a Ledger-backed adapter that implements
`read_as_of`, the lib/ class would call it once all guards pass.

The non-authorization is documented but not enforced:

- "Live Ledger adapter binding" is listed as not authorized
- R4 says "TBackend adapter production binding — MemoryBackend is proof-local only"

Neither of these creates a code-level guard. The Phase 1 Ledger exclusion is
**policy**, not **enforcement**.

For current proof-local use (proof harnesses pass `MemoryBackend`), this is
safe. No production Ledger adapter exists that implements the expected interface.
But as the project moves toward Phase 2 (real adapter binding), the absence of
a backend identity check creates a path where a developer could skip the Phase 2
addendum requirement by passing a real Ledger backend to a Phase 1 instance.

**Severity**: medium for current Phase 1 proof-local; high if Phase 2 adapter
binding begins without a backend identity guard added. The lib/ class should
eventually carry a guard that either (a) checks the backend against an allowed
backends registry, or (b) verifies the backend class identity against the
Phase 2 addendum before permitting non-MemoryBackend reads.

### C-2. Lib/ uses non-canonical reason codes — not reconciled with runtime.temporal_scope_exclusion

S3-R17-C2 notes explicitly:

> The current lib class also exposes proof-local narrower reason codes such as
> `runtime.non_temporal_not_covered` and `runtime.temporal_executor_bihistory_excluded`;
> reconcile canonical aliases before any production/live-read route.

The canonical reason code established by PROP-030A (S3-R13) and proved by
S3-R14-C3 is:

```text
runtime.temporal_scope_exclusion
```

The lib/ class uses:

| Lib/ reason code | Canonical code | Scenario |
|-----------------|---------------|----------|
| `runtime.temporal_executor_bihistory_excluded` | `runtime.temporal_scope_exclusion` | BiHistory at executor |
| `runtime.temporal_executor_core_refusal` (assumed) | `runtime.temporal_scope_exclusion` | CORE fragment at executor |
| `runtime.non_temporal_not_covered` | `runtime.temporal_scope_exclusion` | Non-TEMPORAL fragment |

This divergence means:
- The scope exclusion fixture (S3-R14-C3) proves `runtime.temporal_scope_exclusion` is emitted for all excluded surfaces
- The lib/ class emits different codes for the same conditions
- These would not match in any tooling that inspects reason codes

The semantic is correct (exclusion happens); the codes are inconsistent. Any
future diagnostic, alerting, or compliance tooling that keys on reason codes
would need to handle both sets, which creates fragmentation.

**Severity**: low for proof-local Phase 1; medium before any production/live-read
route. The reconciliation referenced in S3-R17-C2 should happen before the
lib/ class is called in any non-proof context that would surface these codes to
operators.

### C-3. GATE3_AUTHORITY_REF as a source-readable constant provides proof-local authorization only

The AT-9 check uses:

```text
GATE3_AUTHORITY_REF = "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09"
```

This constant is embedded in `lib/igniter_lang/temporal_executor.rb`. Anyone
who reads the source can construct a token that passes AT-9 by including the
exact URI as `authority_ref`. In a proof harness or development context, this
is intentional and correct. But it means:

- The AT-9 check provides **source-code-parity verification**, not
  **cryptographic authorization**.
- Any token that embeds the correct URI string passes AT-9, regardless of who
  issued it.
- "Who issued it" cannot be verified without a production signing scheme (not
  yet defined, deferred to Phase 2).

This is not a regression from the prior state — proof-local AT-9 has always been
this way. The gate decision record's S3-R13-X1-S amendment added the permission
to hardcode the URI for Phase 1. But the implication should be named clearly:
the AT-9 check in lib/ is a development-mode gate, not a production authorization
check.

**Severity**: low — correctly limited to proof-local use. No production signing
exists yet. The concern is that "Phase1 in lib/" sounds more production-ready
than "Phase1 in experiments/," which could mislead callers about the security
guarantees of AT-9. R2 (production signing) must land before any non-proof
deployment.

### C-4. @observations in-memory array — callers may mistake it for a durable audit record

AT-10 emission appends to `@observations` (in-memory). The `observations` reader
exposes this array. The track documents this as "in-memory only." But:

- A caller who stores the executor instance and calls `executor.observations` will
  get the in-memory list — which looks like an audit trail.
- If the executor instance is garbage-collected or reset, the observations are
  lost permanently.
- There is no `cleared_since`, `durable_after`, or similar signal to indicate
  that the array is ephemeral.

The risk: a caller implementing AT-10 compliance verification against
`executor.observations` would pass the compliance check, then the instance is
reset, and the "audit trail" disappears. The compliance check was real; the
durability was illusory.

**Severity**: low — correctly documented as in-memory only. R3 defers persistence.
But the `observations` reader should carry a clear in-code docstring marking it
as `# proof-local only; not durable; not an audit receipt` to prevent misuse
in production contexts.

---

## [Missing]

### M-1. No backend identity guard for Phase 2 boundary enforcement

The current lib/ class carries the Phase 2 boundary as documentation only:
"MemoryBackend is proof-local only; real adapter requires Phase 2 addendum."
A code-level guard would check the backend's class or identity against an
allowed-backends list before permitting `gate3_authorized: true` to enable reads.

This guard does not need to exist today. But it should be a named pre-Phase-2
requirement: "before any Phase 2 adapter binding is attempted, add a
backend identity check to `Phase1#check_backend_scope` (or equivalent) that
verifies the backend class against the Architect addendum."

### M-2. Reason code alias table is not referenced from lib/ code

The reconciliation of `runtime.temporal_executor_bihistory_excluded` →
`runtime.temporal_scope_exclusion` is noted in S3-R17-C2 as a risk but is not
tracked in any PROP, spec errata, or pending track. It should be explicitly
routed as a named pre-live item.

---

## [Sharper Question]

Not: "Is the lib-prep boundary correctly scoped?"

It is. Scope, ordering, exclusions, default, authority_ref, and observation
emission are all correct for proof-local Phase 1.

The sharper question is:

> **What is the specific authorization event that causes `gate3_authorized: true`
> to be passed by a legitimate caller in a non-proof context — and is that event
> described anywhere?**

For proof harnesses: the harness explicitly sets `gate3_authorized: true` because
it is testing the authorized path. Correct.

For a future non-proof caller (e.g., a RuntimeMachine integration, an application
using the igniter-lang gem): what is the signal that tells the caller "you may
now pass `gate3_authorized: true`"? The answer from the current documents is:
"when R1 (`gate3-live-read-decision-addendum-v0`) is issued by the Architect."
But R1 does not yet exist, and even when it does, the lib/ class has no mechanism
to verify that R1 exists before accepting `gate3_authorized: true`.

The `gate3_authorized` parameter is currently a developer honor system. The
gate decision record and R1 create the policy; the lib/ class does not enforce
the policy against the policy documents. This is acceptable for Phase 1. But it
should be clearly stated: "the lib/ Phase1 class does not self-authorize. The
caller is responsible for ensuring they hold a valid Architect decision before
passing `gate3_authorized: true`."

---

## [Route]

→ **PROCEED for proof-local Phase 1 use.** All eight scope items are confirmed.
The regression chain is green. The token-before-gate ordering is verified. AT-9
URI comparison is verified. No live-read authorization occurred.

→ **AMEND** (documentation, before any non-proof use):
  Add a code-level docstring to the `observations` reader in
  `lib/igniter_lang/temporal_executor.rb`:
  ```ruby
  # Proof-local only. In-memory, not durable. Not an audit receipt.
  # See compatibility-report-persistence-audit-v0 for future durable persistence.
  ```
  Add a similar docstring to `GATE3_AUTHORITY_REF`:
  ```ruby
  # Phase 1 proof-local authority URI from gate3-decision-record-v0.md.
  # Not a cryptographic token; source-code-parity verification only.
  # Replace with production signing before any non-proof deployment.
  ```

→ **track** (required before Phase 2 adapter binding):
  `phase1-backend-identity-guard-v0` — add a backend identity check to
  `Phase1` that validates the backend class against an allowed-backends
  registry before permitting `gate3_authorized: true` to enable reads.
  This closes C-1. Must land before any Phase 2 addendum.

→ **track** (required before any production/live-read route):
  `runtime-temporal-scope-exclusion-reason-alias-v0` — define canonical
  aliases mapping `runtime.temporal_executor_bihistory_excluded`,
  `runtime.temporal_executor_core_refusal`, and `runtime.non_temporal_not_covered`
  to `runtime.temporal_scope_exclusion`, or consolidate to the canonical code
  in the lib/ class. Must land before reason codes surface to operators.
  Route to Compiler/Grammar Expert.

→ **track** (R1, gated on Architect addendum):
  `gate3-live-read-decision-addendum-v0` — Architect document explicitly
  opening Phase 1 live reads for non-proof contexts. Live reads in any
  non-proof context must not proceed until this exists.

→ **backlog** (Phase 2, not blocking Phase 1):
  R2 (production signing), R3 (observation persistence), R4 (real adapter
  binding), R5 (BiHistory separate gate), R6 (authority registry), R7
  (Phase1 vs Phase1TemporalExecutorWithReport consolidation), R8 (dedicated
  lib-prep regression fixture with isolated setup).

---

## Risk Table

| Risk | Severity | Proof-local Phase 1 blocker? | Pre-production / Phase 2 blocker? |
|------|----------|------------------------------|-----------------------------------|
| Live-read authorization occurred | — | **NONE ✅** | — |
| `gate3_authorized: false` default absent | — | **CONFIRMED ✅** | — |
| Ledger adapter path in lib/ code | — | **NONE IN LIB CODE ✅** | — |
| Production cache exists | — | **ABSENT ✅** | — |
| BiHistory/stream/OLAP not refused | — | **REFUSED ✅** | — |
| authority_ref not decision-record based | — | **DECISION-RECORD URI ✅** | — |
| Ordering gate-before-token | — | **CLOSED ✅ (`token_stage_passed_first: ok`)** | — |
| Observations treated as durable | — | **IN-MEMORY ONLY ✅** | — |
| Backend parameter unconstrained; Ledger adapter passable | Medium | No | Yes — needs backend identity guard before Phase 2 |
| Reason codes non-canonical (bihistory_excluded ≠ scope_exclusion) | Low | No | Medium — must reconcile before operators see codes |
| GATE3_AUTHORITY_REF source-readable; not cryptographic | Low | No (by design) | High — R2 production signing required |
| @observations reader needs docstring (in-memory, not durable) | Low | No | Low — prevent misuse |
| gate3_authorized honor system (no R1 enforcement in lib/) | Low | No | Medium — caller responsibility must be documented |
| R7: Phase1 vs Phase1TemporalExecutorWithReport unresolved | Low | No | Low — code clarity |
| Post-C1 regression chain | — | **14/14 PASS ✅** | — |

**Overall: PROCEED for proof-local Phase 1. Two pre-Phase-2 tracks required
(backend identity guard, reason code alias reconciliation). Two docstring
amendments recommended before any non-proof callers use the lib/ class.**

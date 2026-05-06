# Memory TBackend — Lifecycle Golden Fixtures v0

Status: implementation track
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Depends on: `proposals/PROP-008-tbackend-contract-v0.md`,
             `proposals/PROP-009-semantic-image-resume-compatibility-v0.md`,
             `proposals/PROP-009.1-resume-ordering-errata.md`,
             `proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md`,
             `proposals/PROP-011-runtime-machine-lifecycle-v0.md`

---

## Purpose

The `:memory` TBackend is the reference implementation (PROP-008). It is:
- In-process, synchronous, deterministic
- The baseline for conformance testing (PROP-007)
- The first target for end-to-end lifecycle testing (PROP-011)

This document provides **golden fixtures**: typed, annotated test scenarios
for the full lifecycle (boot → load → evaluate → checkpoint → resume).
Each fixture is a canonical input/output pair that any conformant
`:memory` TBackend implementation must satisfy.

---

## Fixture Format

Each fixture has:

```text
FIXTURE-<n>: <name>
Input:   typed record
Expect:  ordered list of observations emitted (kind, subject, lifecycle, key fields)
Invariant: which formal rule is being tested
```

---

## FIXTURE-001: Boot — Clean Session

```text
FIXTURE-001: boot_clean_session
Invariant: PROP-011 §Step 1; BootReceipt emitted after all descriptors

Input: BootInputs {
  axiom_version:  "1.0.0"
  runtime_config: RuntimeContract { fragment: :core_only, grants_by_default: false }
  backend_binding: TBackendDescriptor {
    backend_kind: :memory,
    version: "0.1.0"
    capabilities: TBackendCaps {
      read_as_of: true, append_atomic: true, replay_enabled: true,
      snapshot_enabled: true, compact_enabled: true, subscribe_enabled: true,
      consistency: :strong
    }
  }
  session_id:  "session-001"
  started_at:  Timestamp("2026-05-05T10:00:00Z")
}

Expect (in order):
  [1] Obs[:platform_observation, AxiomDescriptor]
        subject: "axiom://1.0.0"
        lifecycle: :durable
  [2] Obs[:platform_observation, RuntimeContract]
        subject: "runtime://session-001"
        lifecycle: :durable
  [3] Obs[:platform_observation, TBackendDescriptor]
        subject: "backend://memory/session-001"
        lifecycle: :durable
  [4] Obs[:verification_observation, VerificationReport]
        subject: "verify://session-001"
        lifecycle: :audit
        payload.trust_level: :trusted
  [5] Obs[:platform_observation, BootReceipt]
        subject: "boot://session-001"
        lifecycle: :durable
        payload.status: :ready

Assert:
  - seq_ids: [1] < [2] < [3] < [4] < [5]
  - All obs carry links: [observed_under: [1].id, observed_under: [2].id]
  - All obs carry links: [produced_in: "session-001"]
  - backend.read(subject: "boot://session-001", as_of: Timestamp("2026-05-05T10:00:01Z"))
      -> Some(BootReceipt { status: :ready })
```

---

## FIXTURE-002: Boot — Untrusted Backend (Blocked)

```text
FIXTURE-002: boot_untrusted_backend_blocked
Invariant: PROP-011 §Step 1; trust_level :untrusted -> status :blocked; halt

Input: same as FIXTURE-001 except VerificationSuite returns:
  VerificationReport { trust_level: :untrusted,
    failures: [CheckResult { check_id: "cap.default_deny", outcome: :failure,
                              severity: :critical }] }

Expect (in order):
  [1] Obs[:platform_observation, AxiomDescriptor]  (lifecycle: :durable)
  [2] Obs[:platform_observation, RuntimeContract]  (lifecycle: :durable)
  [3] Obs[:platform_observation, TBackendDescriptor] (lifecycle: :durable)
  [4] Obs[:verification_observation, VerificationReport]
        payload.trust_level: :untrusted
        lifecycle: :audit
  [5] Obs[:platform_observation, BootReceipt]
        payload.status: :blocked
        lifecycle: :durable

Assert:
  - NO LoadReceipt emitted after [5]
  - NO EvaluationReceipt emitted
  - backend contains exactly 5 observations
```

---

## FIXTURE-003: Load — CORE Contracts

```text
FIXTURE-003: load_core_contracts
Invariant: PROP-011 §Step 2; descriptor_obs per contract; ClassifiedAST emitted

Precondition: FIXTURE-001 completed (session-001 in :ready state)

Input: LoadInputs {
  session_id: "session-001"
  source: ContractSource { kind: :inline, ref: "
    contract Add do
      input  :a, Integer
      input  :b, Integer
      compute :sum, ->(a, b) { a + b }
      output :sum
    end
  "}
  classify_options: FragmentClassifyOptions { strict_oof: true, escape_allow: [] }
}

Expect (in order):
  [6] Obs[:descriptor_observation, ContractDescriptor]
        subject: "contract://Add"
        lifecycle: :durable
        payload.fragment_class: :core
        payload.escape_set: []
  [7] Obs[:platform_observation, ClassifiedAST]
        subject: "classified://session-001/load-1"
        lifecycle: :durable
        payload.contracts: ["Add"]
        payload.oof_count: 0
  [8] Obs[:platform_observation, LoadReceipt]
        subject: "load://session-001/1"
        lifecycle: :durable
        payload.status: :loaded
        payload.contracts_loaded: 1

Assert:
  - seq_ids: [6] < [7] < [8]
  - [6] links: [observed_under: AxiomDescriptor.id, produced_in: "session-001"]
```

---

## FIXTURE-004: Load — OOF Contract Rejected

```text
FIXTURE-004: load_oof_contract_rejected
Invariant: PROP-011 §Step 2; OOF rejected at Pass 0; status :rejected

Precondition: FIXTURE-001 completed

Input: LoadInputs {
  session_id: "session-001"
  source: ContractSource { kind: :inline, ref: "
    contract AmbientTime do
      compute :now, -> { Time.now }  -- ambient clock: OOF (Law 6)
      output :now
    end
  "}
  classify_options: FragmentClassifyOptions { strict_oof: true }
}

Expect (in order):
  [6] Obs[:failure_observation, OOFConstruct]
        subject: "contract://AmbientTime/now"
        lifecycle: :session
        payload.reason_code: "compile.oof_construct"
        payload.status: :rejected
  [7] Obs[:platform_observation, LoadReceipt]
        subject: "load://session-001/1"
        lifecycle: :durable
        payload.status: :rejected
        payload.contracts_loaded: 0

Assert:
  - NO descriptor_observation emitted for AmbientTime
  - machine remains in :loading state; may accept subsequent LoadInputs
```

---

## FIXTURE-005: Evaluate — Simple CORE Computation

```text
FIXTURE-005: evaluate_core_add
Invariant: PROP-011 §Step 3; value_observation emitted; EvaluationReceipt last

Precondition: FIXTURE-001 + FIXTURE-003 completed

Input: EvaluationRequest {
  session_id:   "session-001"
  contract_ref: "Add"
  inputs:       { a: 3, b: 4 }
  temporal_ctx: TemporalCtx { as_of: Timestamp("2026-05-05T10:01:00Z") }
  options:      EvaluationOptions { observation_emit: :all, dry_run: false }
}

Expect (in order):
  [9]  Obs[:value_observation, Integer]
         subject: "contract://Add/sum"
         lifecycle: :session
         payload: Some(7)
         temporal.as_of: Timestamp("2026-05-05T10:01:00Z")
  [10] Obs[:platform_observation, EvaluationReceipt]
         subject: "eval://session-001/1"
         lifecycle: :session
         payload.status: :ok
         payload.output_obs_ids: [[9].id]
         payload.temporal_ctx.as_of: Timestamp("2026-05-05T10:01:00Z")

Assert:
  - [9] content_hash is deterministic: same inputs + same Tt -> same hash
  - backend.read(subject: "contract://Add/sum",
                 as_of: Timestamp("2026-05-05T10:01:00Z"))
      -> Some(7)
  - backend.read(subject: "contract://Add/sum",
                 as_of: Timestamp("2026-05-05T10:00:59Z"))  -- before evaluation
      -> None
```

---

## FIXTURE-006: Evaluate — Missing TemporalCtx (OOF)

```text
FIXTURE-006: evaluate_missing_temporal_ctx
Invariant: PROP-011 §Step 3; no TemporalCtx -> OOF -> failure_observation

Precondition: FIXTURE-001 + FIXTURE-003 completed

Input: EvaluationRequest {
  session_id:   "session-001"
  contract_ref: "Add"
  inputs:       { a: 1, b: 2 }
  temporal_ctx: nil   -- MISSING
}

Expect:
  [9] Obs[:failure_observation, MissingTemporalCtx]
        subject: "eval://session-001/missing_temporal_ctx"
        lifecycle: :session
        payload.reason_code: "constraint.missing_temporal_ctx"
        payload.status: :rejected

Assert:
  - NO value_observation emitted
  - NO EvaluationReceipt emitted
  - backend contains exactly 9 observations (8 from prior fixtures + 1 failure)
```

---

## FIXTURE-007: Checkpoint — Full Sequence

```text
FIXTURE-007: checkpoint_full_sequence
Invariant: PROP-011 §Step 4; snapshot -> flush -> SemanticImage -> compact -> receipt

Precondition: FIXTURE-001 + FIXTURE-003 + FIXTURE-005 completed

Input: CheckpointPolicy {
  scope:            :after_session
  snapshot_slices:  []     -- no named slices in this simple session
  compact_eligible: true
  retain_local:     false
}

Expect (in order):
  [11] Obs[:platform_observation, FlushResult]
         subject: "flush://session-001/after_session"
         lifecycle: :session
         payload.flushed_count: 2      -- [9] and [10] are :session; flushed
         payload.persisted_count: 8    -- obs [1]..[8] are :durable; persisted
         payload.checkpointed: true
  [12] Obs[:platform_observation, SemanticImage]
         subject: "image://session-001"
         lifecycle: :audit
         payload.session_id: "session-001"
         payload.observation_count: 10   -- [1]..[10]
         payload.checkpoint.as_of: Timestamp("2026-05-05T10:01:00Z")
         payload.checkpoint.seq_id: 10
  [13] Obs[:platform_observation, CompactionReceipt]
         subject: "compact://memory/plan-1"
         lifecycle: :durable
         payload.removed_count: 2         -- :local obs (none in this session)
         payload.preserved_count: 12      -- all :durable + :audit including [12]
  [14] Obs[:platform_observation, CheckpointReceipt]
         subject: "checkpoint://session-001/1"
         lifecycle: :durable
         payload.semantic_image: [12].id
         payload.flush_result: [11].id
         payload.compaction_receipt: [13].id
         payload.seq_id: 12

Assert:
  - seq_ids: [11] < [12] < [13] < [14]
  - [12].id ∈ backend implicit preserve set
  - [12] content_hash = hash_content(
      AxiomDescriptor.content_hash
      ++ RuntimeContract.content_hash
      ++ obs_hash_over([1]..[10])
      ++ checkpoint_id
    )
  - backend.read(subject: "image://session-001",
                 as_of: Timestamp("2026-05-05T10:01:01Z"))
      -> Some(SemanticImage { ... })
```

---

## FIXTURE-008: Resume — Trusted

```text
FIXTURE-008: resume_trusted
Invariant: PROP-009.1 canonical order; CompatibilityReport after Boot(B);
           GATE-1; ResumeStatus :trusted -> proceed

Precondition: FIXTURE-007 completed (session-001 checkpointed)

Input: ResumeRequest {
  prior_image_ref:  [12].id          -- session-001 SemanticImage
  session_id:       "session-002"
  runtime_config:   same RuntimeContract as session-001
  backend_binding:  same TBackendDescriptor (same :memory backend)
  requested_as_of:  Timestamp("2026-05-05T10:05:00Z")
  intent:           :continue
  verification_run: true
}

Expect (in order):
  -- Boot group (session-002)
  [15] Obs[:platform_observation, AxiomDescriptor]      lifecycle: :durable
  [16] Obs[:platform_observation, RuntimeContract]       lifecycle: :durable
  [17] Obs[:platform_observation, TBackendDescriptor]    lifecycle: :durable
  [18] Obs[:platform_observation, BootReceipt]
         payload.status: :ready
  -- Verification group
  [19] Obs[:verification_observation, VerificationReport]
         payload.trust_level: :trusted
         lifecycle: :audit
  -- Compatibility gate
  [20] Obs[:platform_observation, CompatibilityReport]
         subject: "resume://session-002/compatibility"
         lifecycle: :audit
         payload.resume_status: :trusted
         payload.reproducibility.level: :full
  -- Load from checkpoint
  [21] Obs[:platform_observation, LoadReceipt]
         payload.status: :loaded

Assert:
  - seq_ids: [15] < [16] < [17] < [18] < [19] < [20] < [21]   -- GATE-1
  - NO LoadReceipt or EvaluationReceipt before [20]
  - [20].payload.checks: all 11 dimensions :compatible
  - session-002 can now evaluate contracts under Tt("2026-05-05T10:05:00Z")
```

---

## FIXTURE-009: Resume — Blocked (Untrusted Verification)

```text
FIXTURE-009: resume_blocked_untrusted
Invariant: PROP-009 §trust_level :untrusted -> :blocked; GATE-1 still applies

Precondition: FIXTURE-007 completed

Input: ResumeRequest {
  prior_image_ref:  [12].id
  session_id:       "session-003"
  runtime_config:   RuntimeContract { grants_by_default: true }  -- ESCAPE violation
  backend_binding:  TBackendDescriptor { backend_kind: :memory }
  requested_as_of:  Timestamp("2026-05-05T10:05:00Z")
  intent:           :continue
  verification_run: true
}

Expect (in order):
  [15] Obs[:platform_observation, AxiomDescriptor]
  [16] Obs[:platform_observation, RuntimeContract]
  [17] Obs[:platform_observation, TBackendDescriptor]
  [18] Obs[:platform_observation, BootReceipt] { status: :degraded }
  [19] Obs[:verification_observation, VerificationReport]
         payload.trust_level: :untrusted
         payload.failures: [cap.default_deny: :critical]
  [20] Obs[:platform_observation, CompatibilityReport]
         payload.resume_status: :blocked
         payload.blocked_dimensions: [:trust_level]
  [21] Obs[:failure_observation]
         payload.reason_code: "constraint.resume_incompatible"
         payload.status: :rejected
         links: [{ rel: :caused_by, ref: [20].id }]

Assert:
  - NO LoadReceipt after [21]
  - NO EvaluationReceipt
  - backend for session-003 contains exactly 7 observations ([15]..[21])
```

---

## FIXTURE-010: Temporal Read — as_of Isolation

```text
FIXTURE-010: temporal_read_as_of_isolation
Invariant: PROP-008 §read; as_of = :latest is OOF; explicit as_of required

Precondition: FIXTURE-005 completed (value "7" at Timestamp("2026-05-05T10:01:00Z"))

Input A (CORE read):
  backend.read(subject: "contract://Add/sum",
               as_of: Timestamp("2026-05-05T10:01:00Z"))
Expected A: Some(7)

Input B (before evaluation):
  backend.read(subject: "contract://Add/sum",
               as_of: Timestamp("2026-05-05T09:59:00Z"))
Expected B: None

Input C (OOF — no as_of):
  backend.read(subject: "contract://Add/sum")
Expected C:
  Obs[:failure_observation]
    reason_code: "constraint.missing_as_of"
    status: :rejected
  return: None (never payload)

Assert:
  - A and B demonstrate temporal isolation: same subject, different as_of, different result
  - C demonstrates Law 6 enforcement: ambient read is always OOF
```

---

## FIXTURE-011: Lifecycle Promotion — Local Linked to Failure

```text
FIXTURE-011: lifecycle_promotion_local_to_session
Invariant: PROP-010 DR-1; :local obs linked as failure evidence -> promoted to :session

Setup:
  During evaluation, a :local intermediate observation [X] is produced.
  Evaluation fails: Obs[:failure_observation] carries links: [evidence: [X].id]
  flush(:after_evaluation) runs.

Expect:
  [X] lifecycle field: :local -> :session  (promoted)
  Obs[:platform_observation, LifecyclePromotion]
    subject: "lifecycle://promote/[X].id"
    lifecycle: :session
    payload: { obs_id: [X].id, from: :local, to: :session, reason: :open_failure_link }

Assert:
  - [X] NOT discarded by flush
  - [X].lifecycle = :session in backend after flush
  - LifecyclePromotion observation emitted (not silent)
```

---

## FIXTURE-012: Compaction — Window Boundary

```text
FIXTURE-012: compact_window_boundary
Invariant: PROP-010 DR-2 + PROP-008 compact; window obs compacted after boundary receipt

Setup:
  3 :window lifecycle observations [W1, W2, W3] appended
  TemporalWindow { detail_retain: "0s" }  -- immediate for test
  BoundaryReceipt produced: [BR]
  compact(policy { strategy: :fact_gc, before_seq: W3.seq_id + 1 })

Expect:
  [W1] lifecycle: :compacted; payload: :hashed; content_hash preserved
  [W2] lifecycle: :compacted; payload: :hashed; content_hash preserved
  [W3] lifecycle: :compacted; payload: :hashed; content_hash preserved
  [BR] lifecycle: :audit; payload: :present (NOT compacted)
  Obs[:platform_observation, CompactionReceipt]
    payload.removed_count: 3
    payload.new_baseline_cursor: ReplayCursor { anchor: :seq_id,
                                                position: BR.seq_id }

Assert:
  - W1.ObsId still resolvable (returns stub with content_hash)
  - W1.content_hash == original_content_hash  (content-address stable)
  - backend.read(W1.subject, as_of: W1.temporal.as_of) -> None (payload gone)
    but W1.id -> compacted stub
  - [BR] NOT in removed set (lifecycle: :audit, in GC roots)
```

---

## Implementation Notes

**`:memory` TBackend data structure (reference):**

```text
MemoryTBackend = {
  observations : OrderedMap[ObsId, ObsPacket]    -- seq_id order
  seq_counter  : Int                              -- monotonic
  index_by_subject: Map[SubjectRef, List[ObsId]] -- for read(as_of)
  index_by_kind   : Map[ObsKind, List[ObsId]]
  subscriptions   : Map[SubscriptionId, SubHandle]
  snapshots       : Map[SnapshotId, SnapshotPayload]
  gc_roots        : Set[ObsId]                   -- SemanticGCRoots
}
```

**`read(subject, as_of)` algorithm:**

```text
candidates = index_by_subject[subject]
             .filter { |id| obs[id].temporal.as_of <= as_of }
             .sort_by { |id| obs[id].temporal.as_of }
             .last
return candidates.map { |id| obs[id].payload }.first_some
```

**`compact` algorithm:**

```text
for each obs in observations where obs.seq_id <= policy.before_seq:
  if obs.id ∈ gc_roots: skip
  if obs.lifecycle ∈ [:durable, :audit]: skip
  if obs.id ∈ policy.preserve: skip
  obs.payload = :hashed
  obs.lifecycle = :compacted
```

---

## Fixture Coverage Map

| Fixture | Step | Invariant tested |
|---------|------|-----------------|
| 001 | Boot | Clean boot; observation order; seq_id ordering |
| 002 | Boot | Untrusted verification → :blocked; halt |
| 003 | Load | CORE contracts; descriptor_obs; ClassifiedAST |
| 004 | Load | OOF rejection at Pass 0; no descriptor_obs |
| 005 | Evaluate | CORE computation; value_obs; temporal isolation |
| 006 | Evaluate | Missing TemporalCtx → OOF; Law 6 |
| 007 | Checkpoint | Full sequence; SemanticImage before compact |
| 008 | Resume | Trusted; GATE-1 ordering; all dimensions :compatible |
| 009 | Resume | Blocked (untrusted); GATE-1 still holds |
| 010 | TBackend.read | as_of isolation; OOF ambient read |
| 011 | Lifecycle | DR-1 promotion; :local → :session; not silent |
| 012 | Compact | DR-2 boundary; :compacted stubs; content-address stable |

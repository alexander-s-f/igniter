Card: S3-R26-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/deterministic-regression-artifact-policy-v0
Status: done
Date: 2026-05-10

---

# Track: Deterministic Regression Artifact Policy v0

## Purpose

Define and implement the minimal policy for nondeterministic proof artifacts in
the regression harness. Resolves S3-R25-X1-S C-1 and M-3 (P-14 on the pre-
production checklist).

---

## Source Signals

- `docs/discussions/phase1-production-audit-scope-and-registry-ownership-pressure-v0.md`
  (S3-R25-X1-S, C-1 and M-3)
- `experiments/phase1_observation_tamper_evidence_shape/` (S3-R24-C3-P)
- `experiments/stage2_close_candidate/` (stage2-close-candidate-v0)

---

## Problem Statement (from S3-R25-X1-S C-1)

Two regression harness artifacts regenerate non-identically on every rerun and
required worktree patch restoration in the S3-R25-C1-P regression rerun:

| Artifact | Nondeterministic field | Source |
|----------|----------------------|--------|
| `phase1_observation_tamper_evidence_shape/out/phase1_tamper_evident_store.jsonl` | `storage_identity` (UUID) | `SecureRandom.uuid` at store init |
| `stage2_close_candidate/stage2_close_candidate.json` | `timestamp` | `Time.now.utc.iso8601` at summary build |

Because `storage_identity` is included in the hash computation for `record_hash`
and `previous_record_hash`, a new UUID on each run makes every line of the JSONL
different — including the 64-character SHA256 strings — even when the underlying
proof data is identical.

---

## Decisions

### [D] Two-tier policy

**Tier 1 — Deterministic by construction (preferred):** Replace runtime-entropy
sources with proof-time constants. Proof semantics are unchanged; the constant
demonstrates the same invariant as a random value would, and the output is stable
across reruns.

**Tier 2 — Volatile annotation (where Tier 1 is impractical):** Keep the
runtime value (it may carry genuine informational value, e.g., "when did this run
finish") but declare it non-comparable via `"_volatile_fields": [<field-names>]`
in the summary JSON. Regression tooling must skip comparison of declared volatile
fields.

### [D] Fix 1 (Tier 1): tamper-evidence JSONL — replace UUID with deterministic constant

`SecureRandom.uuid` in `TamperEvidentObservationStore#initialize` is replaced
with a module-level constant:

```ruby
PROOF_STORAGE_IDENTITY = "proof-local/phase1-tamper-evidence-shape/#{PROOF_AS_OF}"
```

This eliminates the only runtime-entropy source in the file. All hashes
(`record_hash`, `previous_record_hash`) are SHA256 over deterministic content and
are now also stable. Two consecutive reruns produce byte-for-byte identical JSONL.

The semantic of `storage_identity` (binding records to one log) is preserved: all
records in one proof run still share the same fixed string. Production stores must
use a runtime-generated UUID or infrastructure-bound identity — this constant is
explicitly proof-local.

### [D] Fix 2 (Tier 2): stage2 summary — annotate timestamp as volatile

`Time.now.utc.iso8601` is kept (it records actual run time, which is useful for
audit trails). A single key is added to the summary:

```ruby
"_volatile_fields" => ["timestamp"]
```

This is a no-op for the proof's own checks (none check the timestamp value) and
communicates to regression tooling that `timestamp` must be excluded from
content-stability comparison.

### [D] No change to proof semantics

Both proofs are PASS/FAIL determined by check results, not artifact content.
Neither change affects what is checked, what is blocked, or what constitutes a
passing proof. The JSONL chain checks (`chain.second_links_to_first`,
`integrity.r1_hash_verifiable`, `integrity.r2_hash_verifiable`) all pass with
the fixed constant.

---

## Policy Definition

### Rule 1 — Proof-time constants over runtime entropy (Tier 1)

Proof artifacts committed to the regression harness MUST NOT contain fields
produced by:

- `SecureRandom.uuid` / `SecureRandom.hex` / `Random.urandom`
- `Time.now` / `Process.clock_gettime` without a fixed proof constant overriding it
- Any other runtime-entropy source

**Compliant pattern:**

```ruby
PROOF_AS_OF            = "2026-05-10T00:00:00Z"   # frozen constant
PROOF_STORAGE_IDENTITY = "proof-local/proof-name/#{PROOF_AS_OF}"  # derived constant
```

### Rule 2 — Volatile annotation (Tier 2)

If a field genuinely requires a wall-clock or runtime value (e.g., `timestamp`
recording when the proof ran), declare it in `_volatile_fields`:

```json
{
  "status": "PASS",
  "timestamp": "2026-05-10T09:37:41Z",
  "_volatile_fields": ["timestamp"],
  ...
}
```

Regression tooling MUST skip equality comparison for fields listed in
`_volatile_fields`. The `status`, `checks`, `verdict`, and all boolean check
fields MUST remain comparable (they must not appear in `_volatile_fields`).

### Rule 3 — What counts as a committed regression artifact

An artifact is a "committed regression artifact" if it is:

- Written to `experiments/*/out/*.json` or `experiments/*/out/*.jsonl`, AND
- Git-tracked (not in `.gitignore`), AND
- Named by any step in the regression matrix

Artifacts that are regenerated fresh on every run and not git-tracked are exempt
from this policy.

### Rule 4 — Production semantics preserved at the class level

The determinism fix applies to proof fixtures only. Class-level implementations
(`TamperEvidentObservationStore`, any future production store) MUST use runtime
UUIDs or infrastructure-bound identity. The proof-local override happens at the
module constant level, not inside the class.

---

## Shipped

- `experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb`
  — `require "securerandom"` removed; `PROOF_STORAGE_IDENTITY` constant added;
    `SecureRandom.uuid` → `PROOF_STORAGE_IDENTITY` (1 source line changed)
- `experiments/stage2_close_candidate/stage2_close_candidate.rb`
  — `"_volatile_fields" => ["timestamp"]` added to summary hash (1 line added)

---

## Proof Results

**Tamper-evidence (23/23 PASS, artifact now stable):**

```bash
ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb
# 23/23 PASS
```

**Stability verification (two consecutive runs produce identical JSONL):**

```bash
ruby .../phase1_observation_tamper_evidence_shape.rb > /dev/null
cp .../out/phase1_tamper_evident_store.jsonl /tmp/run1.jsonl
ruby .../phase1_observation_tamper_evidence_shape.rb > /dev/null
diff /tmp/run1.jsonl .../out/phase1_tamper_evident_store.jsonl
# → (no output — files identical)
# IDENTICAL across two runs
```

**Stage2 (all surfaces PASS, annotation inert):**

```bash
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
# PASS stage2_close_candidate
# verdict: stage2_close_candidate
# package_facade: PASS / invariant_runtime_observations: PASS / olap_point: PASS
# stream_fold: PASS / history_bihistory_temporal_access: PASS
# ledger_tbackend_descriptor: PASS / stage1_regression: PASS
```

---

## Remaining Artifact Survey (for future regression harness owners)

Known committed artifacts and their determinism status after this track:

| Artifact | Deterministic? | Volatile fields | Notes |
|----------|---------------|-----------------|-------|
| `phase1_tamper_evident_store.jsonl` | ✅ after this track | none | All hashes stable |
| `stage2_close_candidate.json` | ✅ except `timestamp` | `timestamp` | Logic checks all stable |
| `phase1_observation_tamper_evidence_shape_summary.json` | ✅ | none | All boolean; no entropy |
| `temporal_executor_lib_prep_summary.json` | ✅ | none | All boolean + string constants |
| `stage1_close_candidate` | ✅ | none | Compiler output; deterministic |

Artifacts not checked in this track (lower urgency, no known nondeterminism):

- All other `experiments/*/out/*.json` summaries — likely stable (content-addressed
  IDs, boolean checks, fixed-constant inputs)
- `phase1_end_to_end_invocation_fixture` — uses `PROOF_AS_OF` pattern; likely stable

---

## Recommendation for Future Regression Reruns

1. **Before committing a new proof artifact**: run the proof twice and `diff` the
   outputs. Any diff that isn't explained by `_volatile_fields` is a violation.

2. **For new proofs that require UUIDs/nonces** (e.g., storage identity, request
   nonce): define a `PROOF_<NAME>` constant and use it throughout the proof.
   Document in a comment that production callers must use runtime entropy.

3. **For proofs where runtime values are informational** (elapsed time, run
   timestamp): add `"_volatile_fields"` to the summary JSON rather than removing
   the field.

4. **Regression matrix step**: add a `diff`-based stability check alongside the
   existing PASS/FAIL check for any artifact in the matrix. Suggested command:

   ```bash
   ruby proof.rb && ruby proof.rb && diff out/artifact_run1 out/artifact_run2
   ```

   This makes instability a first-class failure mode in the matrix, not a
   post-hoc worktree restoration step.

---

## Non-Authorization

This track does not authorize:

- Any change to Gate 3 authorization state
- Production durable audit implementation
- Ledger or Phase 2 adapter binding
- Any change to proof semantics or what constitutes PASS

---

## Handoff

```text
Card: S3-R26-C3-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/deterministic-regression-artifact-policy-v0
Status: done

[D] Decisions
- Two-tier policy: Tier 1 (deterministic by construction) preferred; Tier 2 (_volatile_fields annotation) for genuinely informational runtime values
- Fix 1: SecureRandom.uuid → PROOF_STORAGE_IDENTITY constant in tamper-evidence proof; JSONL now byte-stable across reruns
- Fix 2: "_volatile_fields": ["timestamp"] added to stage2 summary; no change to timestamp value
- Policy rules 1-4 defined; production semantics preserved at class level

[S] Shipped
- experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb (SecureRandom.uuid → PROOF_STORAGE_IDENTITY)
- experiments/stage2_close_candidate/stage2_close_candidate.rb (_volatile_fields annotation)

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb
- result: PASS (23/23)
- stability: diff of two consecutive runs → no diff (IDENTICAL)
- command: ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
- result: PASS (all 7 surfaces)

[R] Risks
- No production behavior changed; fixes are proof-fixture-local only
- _volatile_fields is a convention; enforcement requires regression tooling to respect it
- Remaining artifacts not surveyed in depth; spot-checks recommended before next major regression rerun

[Q] Open questions
- Q1: Should _volatile_fields be enforced by a lint script in the regression matrix?
  Currently a convention; a small validator could check that status/checks/verdict never appear in _volatile_fields.

[Next] Suggested next slice
- Full regression matrix rerun (26-command) to confirm no new nondeterminism introduced
- phase1-production-durable-audit-v0 design track (C2-A scope, high priority per R26 recommendation)
- Architect registry ownership decision (C3-P Q1-Q6, medium priority)
```

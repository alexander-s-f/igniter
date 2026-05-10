Card: S3-R27-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/volatile-fields-lint-and-artifact-stability-survey-v0
Status: done
Date: 2026-05-10

---

# Track: Volatile Fields Lint and Artifact Stability Survey v0

## Purpose

Enforce the deterministic regression artifact policy (S3-R26-C3-P) with a
validator script. Survey all committed proof summary artifacts for remaining
nondeterminism. Complete `_volatile_fields` annotation coverage across all
scripts that emit a `timestamp` field.

---

## Source Signals

- `docs/tracks/deterministic-regression-artifact-policy-v0.md` (S3-R26-C3-P)
- `experiments/stage2_close_candidate/` (already fixed in S3-R26-C3-P)
- `experiments/phase1_observation_tamper_evidence_shape/` (PROOF_STORAGE_IDENTITY fix in S3-R26-C3-P)

---

## Findings: Artifact Survey

All committed `experiments/**/*.json` and `experiments/**/*.jsonl` summary files
were surveyed for `timestamp` fields and `_volatile_fields` coverage.

### Before This Track

| Artifact | `timestamp`? | `_volatile_fields`? | Status |
|----------|-------------|---------------------|--------|
| `stage2_close_candidate/stage2_close_candidate.json` | ✅ | ✅ (from S3-R26) | Already fixed |
| `phase1_tamper_evident_store.jsonl` | — | — | Byte-stable (PROOF_STORAGE_IDENTITY from S3-R26) |
| `typed_emission_main_path_parity/typed_emission_main_path_parity.json` | ✅ | ❌ | **Missing** |
| `temporal_cache_key_proof/temporal_cache_key_proof.json` | ✅ | ❌ | **Missing** |
| `gem_native_package_boundary_specs/gem_native_package_boundary_specs.json` | ✅ | ❌ | **Missing** |
| `release_gate/release_gate.json` | ✅ | — | Static authored file; no generator script; timestamp fixed at authoring time |
| All other summary JSONs (≈ 36 files) | ❌ | — | No entropy source; stable by construction |

### After This Track

All three missing annotations applied (Tier 2). All committed summary artifacts
with a `timestamp` field now declare it in `_volatile_fields`.

---

## Decisions

### [D] Three scripts receive Tier 2 annotation

`typed_emission_main_path_parity.rb`, `temporal_cache_key_proof.rb`, and
`gem_native_package_boundary_specs.rb` each carry a `timestamp` field that
records when the proof ran. These are genuinely informational (useful for
identifying which run produced a given artifact). Tier 1 (frozen constant) is
not appropriate here — there is no hash computation over `timestamp`, and no
evidence that a fixed proof-date constant would carry semantic meaning for these
proofs. Tier 2 (`_volatile_fields` annotation) is correct per the policy.

### [D] `release_gate/release_gate.json` — no action

`release_gate/release_gate.json` contains a `timestamp` but has no generator
script. It is a manually-committed release decision document. Its timestamp is
frozen at authoring time (2026-05-08T11:16:25Z) and will not change across
regression reruns. No annotation or fix needed.

### [D] Validator scope: artifacts with both `status` and `_volatile_fields`

The validator reads `experiments/**/*.json` files (excluding `golden/`,
`fixtures/`, `classified/`, `.igapp/`). It only acts on files that have both
a `status` key and a `_volatile_fields` key — this avoids false positives from
golden/fixture files and non-summary JSONs. The validator is intentionally
permissive about files that have `timestamp` but no `_volatile_fields` (that
is a human authoring check, not a machine-enforceable policy, because some
files like `release_gate.json` are correctly unannotated).

### [D] Protected fields enforced by validator

`status`, `verdict`, and `checks` must not appear in `_volatile_fields`.
These are the fields that regression tooling uses to determine pass/fail
equivalence. Declaring them volatile would silently allow regressions to pass.

---

## Shipped

- `experiments/volatile_fields_lint/volatile_fields_lint.rb`
  — Validator script; PASS when `_volatile_fields` is valid for all annotated
    artifacts; FAIL and lists violations otherwise.
- `experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb`
  — `"_volatile_fields" => ["timestamp"]` added (1 line)
- `experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb`
  — `"_volatile_fields" => ["timestamp"]` added (1 line)
- `experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb`
  — `"_volatile_fields" => ["timestamp"]` added (1 line)
- `experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json`
  — Regenerated with `_volatile_fields`
- `experiments/temporal_cache_key_proof/temporal_cache_key_proof.json`
  — Regenerated with `_volatile_fields`
- `experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.json`
  — Regenerated with `_volatile_fields`

---

## Proof Results

**Validator (0 violations, 4 artifacts checked):**

```bash
ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
# volatile_fields_lint: PASS (4 artifact(s) with _volatile_fields — no violations)
```

**Two-consecutive-run diff survey (all IDENTICAL excluding declared volatile fields):**

```bash
# typed_emission_main_path_parity — IDENTICAL
ruby .../typed_emission_main_path_parity.rb && cp .../typed_emission_main_path_parity.json /tmp/r1.json
ruby .../typed_emission_main_path_parity.rb
diff <(python3 -c "import json; d=json.load(open('/tmp/r1.json')); [d.pop(k,None) for k in d.get('_volatile_fields',[])]; print(json.dumps(d,sort_keys=True))") \
     <(python3 -c "import json; d=json.load(open('.../typed_emission_main_path_parity.json')); [d.pop(k,None) for k in d.get('_volatile_fields',[])]; print(json.dumps(d,sort_keys=True))")
# → (no output — IDENTICAL)

# temporal_cache_key_proof — IDENTICAL
# gem_native_package_boundary_specs — IDENTICAL
# stage2_close_candidate — IDENTICAL
# phase1_tamper_evident_store.jsonl — IDENTICAL (byte-stable, no volatile fields needed)
```

---

## Artifact Stability Table (Complete, Post-Track)

| Artifact | Stable? | Volatile fields | Notes |
|----------|---------|-----------------|-------|
| `phase1_tamper_evident_store.jsonl` | ✅ byte-stable | none | All hashes over deterministic content (S3-R26) |
| `stage2_close_candidate.json` | ✅ | `["timestamp"]` | Logic checks stable; timestamp volatile (S3-R26) |
| `typed_emission_main_path_parity.json` | ✅ | `["timestamp"]` | Proof result stable; timestamp volatile (this track) |
| `temporal_cache_key_proof.json` | ✅ | `["timestamp"]` | Cache semantics stable; timestamp volatile (this track) |
| `gem_native_package_boundary_specs.json` | ✅ | `["timestamp"]` | Package checks stable; timestamp volatile (this track) |
| `release_gate/release_gate.json` | ✅ | none (static) | Manually authored; timestamp frozen at authoring |
| `phase1_observation_tamper_evidence_shape_summary.json` | ✅ | none | All boolean; no entropy |
| `temporal_executor_lib_prep_summary.json` | ✅ | none | All boolean + string constants |
| `stage1_close_candidate.json` | ✅ | none | Compiler output; deterministic |
| All other summary JSONs (≈ 33 files) | ✅ | none | No timestamp field; boolean/string checks only |
| Golden/fixture/classified JSONs (≈ 80+ files) | ✅ | n/a | Static inputs; not regenerated by proof scripts |

---

## Recommendation for Regression Matrix

1. **Add validator to matrix as a lint step** (before proof reruns):

   ```bash
   ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
   ```

   This catches any future annotation violation before reruns produce
   unexplained diffs.

2. **Before committing a new proof that writes a JSON summary**: check whether
   the script has a `timestamp` field. If yes, add `"_volatile_fields" =>
   ["timestamp"]` in the same commit as the script.

3. **Diff pattern for annotated summaries**:

   ```bash
   ruby proof.rb && cp out/summary.json /tmp/r1.json
   ruby proof.rb
   python3 -c "
   import json, sys
   r1 = json.load(open('/tmp/r1.json'))
   r2 = json.load(open('out/summary.json'))
   vf = r1.get('_volatile_fields', [])
   for k in vf: r1.pop(k, None); r2.pop(k, None)
   sys.exit(0 if r1 == r2 else 1)
   "
   ```

4. **The validator does not catch unannotated `timestamp` fields** — it only
   validates annotations that exist. Human review (or a separate lint that
   flags `Time.now` in experiment scripts) is needed to catch newly-added
   timestamps that lack annotation. The audit command:

   ```bash
   grep -rn "Time\.now" igniter-lang/experiments/ --include="*.rb"
   ```

   Any result that isn't already annotated in `_volatile_fields` is a
   candidate violation.

---

## Non-Authorization

This track does not authorize:

- Any change to Gate 3 authorization state
- Production durable audit implementation
- Any change to proof semantics or what constitutes PASS

---

## Handoff

```text
Card: S3-R27-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/volatile-fields-lint-and-artifact-stability-survey-v0
Status: done

[D] Decisions
- Three scripts annotated Tier 2: typed_emission_main_path_parity, temporal_cache_key_proof, gem_native_package_boundary_specs
- release_gate.json: static authored file; timestamp fixed; no action needed
- Validator scope: only files with both status and _volatile_fields; protected fields: status/verdict/checks
- All other summary JSONs (~33): no timestamp field; stable by construction

[S] Shipped
- experiments/volatile_fields_lint/volatile_fields_lint.rb (new validator)
- experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb (_volatile_fields)
- experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb (_volatile_fields)
- experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb (_volatile_fields)
- Three committed summary JSONs regenerated with _volatile_fields

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
- result: PASS (4 artifacts checked, 0 violations)
- diff survey: typed_emission / temporal_cache_key / gem_native_package / stage2_close_candidate — IDENTICAL (excl. volatile fields)
- diff survey: phase1_tamper_evident_store.jsonl — IDENTICAL (byte-stable)

[R] Risks
- Validator does not catch unannotated Time.now fields; periodic grep audit recommended
- _volatile_fields is a convention; enforcement requires regression tooling to respect it
- release_gate.json has timestamp without annotation; rationale documented; watch if a new script regenerates it

[Q] Open questions
- Q1: Should the validator also detect Time.now usage in experiment scripts and require _volatile_fields coverage?
  Would require parsing Ruby source; currently out of scope. A grep-based pre-commit hook is sufficient.

[Next] Suggested next slice
- Add volatile_fields_lint to the 26-command regression matrix as a mandatory first step
- phase1-production-durable-audit-v0 design track (C2-A scope, high priority per R26 recommendation)
- Architect registry ownership decision (C3-P Q1-Q6, medium priority)
```

# Track: Migration Replacement Image Formalization v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/migration-replacement-image-formalization-v0
Status: done
Date: 2026-05-06
Depends on: PROP-009, PROP-017, runtime-machine-migration-replacement-image-v0

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — receives formal field list, link rels,
  lifecycle, and proof targets. Next proof slice must match this spec.
- `[Igniter-Lang Bridge Agent]` — remains blocked. No package integration
  until replacement image semantics are stable.

---

## Current Horizon

The Research Agent proof (`runtime-machine-migration-replacement-image-v0`)
produced an identity migration path that runs to a trusted second
CompatibilityReport. Three questions were left open: lifecycle observation
kind, `replaces` vs `supersedes` link semantics, and multi-hop migration
shape. This track resolves all three and adds two additional decisions
(image_id derivation, OOF rules).

---

## Part 1: Replacement SemanticImage Field Specification

### 1-A. Required fields (must be present; missing → OOF-MR1)

```text
image_id            : String   -- content hash; see derivation rule §1-E
session_id          : String   -- the migration session that produced this image
produced_at         : Timestamp

-- carried forward from old image (must match)
axiom_descriptor    : ObsId
runtime_contract    : ObsId
backend_descriptor  : ObsId
contract_descriptors: Collection[ObsId]

-- updated by migration
schema_version      : SemVer   -- the NEW contract schema_version
schema_fingerprint  : Hash     -- the NEW contract schema_fingerprint
observation_count   : Integer  -- count of observations in the NEW session
observation_hash    : Hash     -- hash over new session's obs log

-- migration provenance (required on replacement images)
replaces_image_id   : String   -- image_id of the old SemanticImage
migration_receipt_ref: ObsId   -- the audit receipt_observation
```

### 1-B. Optional fields (may be absent; presence checked by checker)

```text
checkpoint          : CheckpointRef    -- if a checkpoint was emitted
replay_cursors      : Collection[ReplayCursor]
projections         : Collection[ProjectionRef]
receipts            : Collection[ObsId]
verification_report : Option[ObsId]
migration_chain     : Collection[String]  -- image_ids of all prior images
                                           -- in this migration sequence
```

### 1-C. Derived fields (not stored; computed on demand)

```text
hop_count  = migration_chain.length + 1   -- total hops including this one
is_direct  = hop_count == 1               -- true for single-hop migrations
chain_root = migration_chain.first ?? replaces_image_id
             -- the original image_id before any migration
```

### 1-D. Forbidden fields (must not appear; present → OOF-MR2)

```text
-- These belong to normal session images, not migration-produced images.
-- Their presence on a replacement image is a semantic contract violation.

fragment_report     -- migration images do not re-classify AST
                    -- (AST classification happened at compile time)

-- Any field that implies the image was produced by normal evaluation
-- without a preceding migration receipt is forbidden on replacement images:
-- specifically, a replacement image must not be emitted WITHOUT
-- migration_receipt_ref being set.
```

**[D] `migration_receipt_ref` absence is the primary OOF marker.**
A SemanticImage that claims `replaces_image_id` but has no
`migration_receipt_ref` is OOF-MR1.

---

### 1-E. image_id Derivation for Replacement Images

The standard `image_id` from PROP-009 is:

```text
image_id = hash_content(
  axiom_descriptor_hash
  ++ runtime_contract_hash
  ++ observation_hash
  ++ checkpoint.checkpoint_id  (or empty if no checkpoint)
)
```

**[D] Replacement images use the same hash formula** but with updated inputs:
- `observation_hash` reflects the NEW session's observations
- `schema_fingerprint` is now part of the canonical image content

The canonical hash input is extended:

```text
replacement_image_id = hash_content(
  axiom_descriptor_hash
  ++ runtime_contract_hash
  ++ observation_hash           -- new session's observations
  ++ checkpoint_id_or_empty
  ++ schema_fingerprint         -- NEW: included to differentiate versions
  ++ migration_receipt_ref      -- NEW: ties image to migration evidence
)
```

**[D] `schema_fingerprint` is included in `image_id` for replacement images.**
Two images from the same session but different schema versions must have
different `image_id` values. This prevents a stale image from passing the
fingerprint check of a newer contract.

---

## Part 2: Link Semantics

### 2-A. `replaces` link

```text
rel: "replaces"
ref: old_semantic_image.image_id
```

**Meaning:** The replacement image **supersedes** the old image for the
purposes of resume decisions. The old image is not deleted; it is demoted.
Any future CompatibilityReport must evaluate the replacement image, not the
old one.

**Who carries it:**
- The replacement `SemanticImage` packet (`platform_observation`) carries
  `{ rel: "replaces", ref: old_image_id }` in its links.
- The replacement image payload also sets `replaces_image_id`.

**[D] `replaces` is mandatory on every replacement image packet.**

---

### 2-B. `supersedes` link

`supersedes` is **not used** for replacement images.

**[D] `supersedes` is reserved for observation-level demotions** —
when a newer value_observation invalidates an older one for the same
subject/contract. It is an obs-to-obs link, not an image-to-image link.

`replaces` is the correct rel for image-to-image continuity replacement.
Using `supersedes` on a SemanticImage packet would conflate two distinct
semantic operations.

**[X] `supersedes` must not appear on replacement SemanticImage packets.**

---

### 2-C. `caused_by` link

```text
rel: "caused_by"
ref: migration_receipt_observation.id
```

**Meaning:** The replacement image was produced as a direct consequence
of the migration receipt. The causal chain is:

```text
old_image
  -> schema_check:migrating CompatibilityReport
  -> intent_observation
  -> migration execution
  -> receipt_observation (audit)
  -> replacement_image  [caused_by: receipt_observation]
                        [replaces: old_image]
```

**[D] `caused_by` on the replacement image points to the migration receipt,
not to the intent observation and not to the CompatibilityReport.**
The receipt is the terminal evidence of migration completion. The intent
and CompatibilityReport are intermediate; the receipt is sufficient.

---

### 2-D. `produced_by` and `produced_in` links

```text
rel: "produced_by"
ref: migration_contract_descriptor_obs_id

rel: "produced_in"
ref: migration_session_id
```

**Meaning:** Standard provenance links from PROP-005/PROP-009.
The replacement image was produced by the migration contract, in the
migration session.

**[D] Both are required on replacement image packets.** They preserve
the full provenance chain for TBackend audit queries:
"which migration contract produced this image?"

---

### 2-E. `migration_receipt_ref` (payload field, not a packet link)

In the replacement image **payload** (not the packet link list):

```text
migration_receipt_ref: ObsId   -- the audit receipt_observation id
```

This duplicates the `caused_by` link information inside the payload,
enabling serialized image documents to be self-contained without
requiring packet link traversal.

**[D] Both the packet link and the payload field must be present.
Checker must verify both.**

---

## Part 3: Lifecycle of the Replacement SemanticImage

### 3-A. Observation kind

```text
Obs[:platform_observation, ReplacementSemanticImage]
```

**[D] Replacement images use the same `platform_observation` kind
as normal SemanticImages.** They are structurally the same type.
The `replaces_image_id` and `migration_receipt_ref` fields distinguish
them semantically.

A new distinct obs kind (`migration_image_observation`) is rejected:
- Would require new kind handling in all TBackend adapters
- The semantics are already fully expressed by the fields and links
- Checker rules on field presence are sufficient to distinguish

**[X] No new obs kind for replacement images.**

### 3-B. Is the replacement image an audit observation?

```text
[D] The replacement SemanticImage itself is NOT :audit lifecycle.
    Its lifecycle is :session (same as normal SemanticImages).

    The migration RECEIPT that caused it IS :audit lifecycle.

    Audit responsibility: migration_receipt → audit
    Session continuity:   replacement_image → session
```

Why session, not audit?

- A SemanticImage's retention is governed by TBackend compact semantics
  (PROP-008: most recent SemanticImage is in the implicit preserve set).
- If replacement images were `:audit`, they would be retained forever
  even after newer migrations superseded them. This creates unbounded
  growth in the preserve set.
- The migration RECEIPT is :audit because it records the irreversible
  act of migration. The image is a state snapshot, not an act record.

**[D] SemanticImage lifecycle is always `:session`.
Migration receipt lifecycle is always `:audit`.
These are invariants, not per-migration choices.**

### 3-C. Checkpoint observation

```text
[D] A replacement SemanticImage MAY include a checkpoint,
    but is not required to.

The identity migration proof does not include a checkpoint on the
replacement image. This is acceptable: the replacement image is produced
immediately after the migration receipt, and the next normal session
evaluation may produce a checkpoint.

If a checkpoint IS included, it follows normal CheckpointRef rules
(PROP-009 §CheckpointRef). It is not a migration-specific checkpoint.
```

### 3-D. Migration lifecycle summary

```text
lifecycle:
  migration_receipt_observation  -> :audit   (mandatory, fixed)
  replacement_semantic_image     -> :session  (mandatory, fixed)
  migration_intent_observation   -> :local    (per PROP-017 Part 4)
  intermediate compute obs       -> inherits from new contract node lifecycle
```

---

## Part 4: Trust Rules

### 4-A. When may the replacement image produce a trusted CompatibilityReport?

```text
TRUSTED after migration if AND ONLY IF:
  [T-1] replacement_image.schema_fingerprint
          == loaded_schema_descriptor.schema_fingerprint
  [T-2] replacement_image.migration_receipt_ref is present and valid
  [T-3] migration_receipt.links contains { rel: "replaces", ref: old_image_id }
  [T-4] replacement_image.replaces_image_id == old_image.image_id
  [T-5] All non-schema CompatibilityReport dimensions are :compatible
         (runtime_check, backend_check, observation_check from PROP-009)
```

**[D] T-1 is the primary trust gate.** The schema_check outcome is:

```text
fingerprint_match == true  (new schema == replacement image schema)
  -> schema_check.decision = :trusted
  -> overall = max_severity(all checks)
  -> if all :trusted -> CompatibilityReport.overall = :trusted
```

**[D] T-2 through T-4 are integrity gates.** A replacement image that
satisfies T-1 but fails T-2/T-3/T-4 must not be trusted — it may be
a forged or incomplete image.

The checker must verify T-2, T-3, T-4 before accepting the
fingerprint match as sufficient for trust.

### 4-B. When must it remain provisional or blocked?

```text
PROVISIONAL after migration if:
  - T-1 passes but T-5 has a :downgrade on a non-schema dimension.
  - Example: replacement image schema matches but TBackend consistency
    downgraded between sessions.

BLOCKED after migration if:
  - T-1 fails: replacement image schema_fingerprint != loaded schema.
    (The migration did not fully update the schema — should not occur
    in a correct migration contract, but must be detected.)
  - T-2/T-3/T-4 fail: provenance chain is broken.
  - Any non-schema dimension is :blocked.
```

**[D] A failed post-migration fingerprint match is OOF-MR3.**
It means the migration contract did not produce the correct schema version.
The replacement image must be rejected. The session must be blocked.

---

## Part 5: Multi-Hop Migration Semantics

### 5-A. Problem statement

A contract may evolve through multiple versions:

```text
v1.0.0 -> v1.1.0 -> v2.0.0
```

An old session image at v1.0.0 cannot directly migrate to v2.0.0
if no direct `migration "C" from "1.0.0" to "2.0.0"` exists.
The migration graph has two edges:
- `1.0.0 -> 1.1.0`
- `1.1.0 -> 2.0.0`

The question is: does the system produce **one image per hop** or
**one final image with a chain**?

### 5-B. Decision: one image per hop

**[D] Multi-hop migration produces one replacement SemanticImage per hop.**

```text
old_image (v1.0.0)
  -> migration (1.0.0 -> 1.1.0)
  -> replacement_image_A (v1.1.0)
       replaces_image_id: old_image.image_id
       migration_chain: []
  -> migration (1.1.0 -> 2.0.0)
  -> replacement_image_B (v2.0.0)
       replaces_image_id: replacement_image_A.image_id
       migration_chain: [old_image.image_id]
```

**Rationale:**
- Each intermediate image is independently auditable.
- Each hop has its own migration_receipt linking to the specific
  migration contract that produced it.
- Checker can validate each hop independently without loading the
  full chain in memory.
- Avoids a monolithic "chain image" that conflates multiple migrations.

**[X] Rejected: one final image with a chain field only.**
A single final image with `migration_chain` referencing intermediate
image_ids is insufficient: if the intermediate migration_receipts are
compacted away, the audit trail breaks. Each hop must be independently
checkpointable.

### 5-C. Path selection: shortest path in migration DAG

**[D] RuntimeMachine selects the shortest path in the migration DAG.**

```text
migration_graph edges: [
  (1.0.0, 1.1.0),
  (1.1.0, 2.0.0),
  (1.0.0, 2.0.0)   -- if a direct migration exists
]

shortest_path(1.0.0, 2.0.0):
  if direct edge exists: [(1.0.0, 2.0.0)]           -- 1 hop
  else: [(1.0.0, 1.1.0), (1.1.0, 2.0.0)]            -- 2 hops
```

**[D] Shortest path is hop count (graph edges), not semantic complexity.**
Policy-selected paths (e.g., always use full-body migration rather than
shortcut) are deferred to a future MigrationPolicy declaration.

**[X] Rejected: policy-selected path in v0.**
Policy selection requires a MigrationPolicy language construct not yet
defined. Shortest path is a safe, deterministic default.

### 5-D. `migration_chain` field semantics

```text
migration_chain on replacement_image_B:
  [old_image.image_id]         -- the original image
  -- NOT: [old_image.image_id, replacement_image_A.image_id]
  -- The direct predecessor is in replaces_image_id.
  -- migration_chain lists all images BEFORE the direct predecessor.
```

```text
migration_chain on replacement_image_C (v3.0.0, three hops):
  [old_image.image_id, replacement_image_A.image_id]
  replaces_image_id: replacement_image_B.image_id
```

**Invariant:** `chain_root = migration_chain.first ?? replaces_image_id`
is always the original pre-migration image.

`chain_depth = migration_chain.length + 1` gives total hops.

---

## Part 6: OOF Rules for Bad Migration Continuity

```text
OOF-MR1: Replacement image missing required provenance fields.
  A SemanticImage with replaces_image_id but no migration_receipt_ref,
  or with migration_receipt_ref but no replaces_image_id.
  -> compile-time: cannot be caught (runtime artifact)
  -> runtime: CompatibilityReport.schema_check = :blocked
  -> checker: must flag missing field as fixture failure

OOF-MR2: Forbidden fields on replacement image.
  A replacement SemanticImage carrying fragment_report or other
  fields that imply normal evaluation without migration provenance.
  -> runtime: reject as malformed replacement image

OOF-MR3: Post-migration fingerprint mismatch.
  After migration execution, the replacement image's schema_fingerprint
  does not match the loaded schema descriptor.
  -> runtime: CompatibilityReport.schema_check = :blocked
  -> meaning: the migration contract produced the wrong schema version
  -> this is a migration contract defect, not a schema change

OOF-MR4: Broken chain (hop gap).
  replacement_image_B.replaces_image_id = id_X, but id_X does not
  exist in TBackend and is not replacement_image_A.image_id.
  -> runtime: CompatibilityReport.schema_check = :blocked
  -> checker: migration_chain continuity check required

OOF-MR5: Cycle in migration chain.
  replacement_image.migration_chain contains replacement_image.image_id
  (self-reference), OR any image_id appears twice in the chain.
  -> runtime: blocked immediately; equivalent to OOF-S4 at runtime

OOF-MR6: `supersedes` link on replacement image packet.
  A replacement SemanticImage packet carrying { rel: "supersedes" }
  instead of { rel: "replaces" }.
  -> checker: flag as wrong link rel; must use "replaces"

OOF-MR7: Replacement image emitted without migration receipt.
  A session that sets schema_fingerprint to the new fingerprint without
  a preceding migration_receipt (no :migrating CompatibilityReport,
  no receipt_observation).
  -> runtime: CompatibilityReport schema_check sees fingerprint mismatch
     but no migration path executed. Treated as :blocked, not :migrating.
  -> meaning: cannot silently upgrade schema by emitting a new image.
```

---

## Open Questions (Narrowed)

[Q-1] **Migration receipt in TBackend preserve set.**
Migration receipts are `:audit` lifecycle. PROP-008 compact semantics
preserve `:audit` observations by default. But must the specific
`migration_receipt_ref` also be explicitly in the preserve set of the
replacement image?
**Recommendation: yes.** The checker should verify that
`migration_receipt_ref` is not compactable as long as any
replacement image referencing it exists.

[Q-2] **Checker scope for `migration_chain` integrity.**
The `packet_builder_check.rb` currently checks golden fixtures.
Chain integrity (OOF-MR4) requires TBackend presence checks, which
are not in the current :memory proof scope.
**Recommendation: check `migration_chain` field shape in fixtures;
defer TBackend presence check to a file-backed TBackend proof slice.**

[Q-3] **Multi-hop proof target.**
The current proof is identity single-hop (one migration, one replacement).
Should the next Research Agent slice add a two-hop proof, or is single-hop
sufficient before package integration?
**Recommendation: single-hop is sufficient for the next package bridge slice.
Two-hop is needed before a general MigrationDecl DSL is released.**

---

## Proof Targets for Research Agent

The following checks must appear in the next proof slice or become
part of the existing `runtime_machine_memory_proof.rb`:

```text
[P-1] replacement_image.migration_receipt_ref is present and non-nil
[P-2] replacement_image.replaces_image_id == old_image.image_id
[P-3] replacement_image_packet.links includes { rel: "replaces", ref: old_image.image_id }
[P-4] replacement_image_packet.links includes { rel: "caused_by", ref: migration_receipt.id }
[P-5] replacement_image_packet.links does NOT include { rel: "supersedes" }
[P-6] replacement_image.schema_fingerprint == loaded_schema_descriptor.schema_fingerprint
[P-7] second CompatibilityReport.schema_check.decision == :trusted
[P-8] second CompatibilityReport.overall == :trusted
[P-9] replacement_image.migration_chain is present (may be [] for single-hop)
[P-10] OOF-MR3 negative test: forged replacement image with wrong fingerprint
        -> CompatibilityReport.schema_check == :blocked
```

P-1 through P-8 may already be implied by the current proof checks.
The packet_builder_check.rb must verify P-3, P-4, P-5 explicitly.
P-9 and P-10 are new.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/migration-replacement-image-formalization-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: implement P-1 through P-10 checks in
  proof and checker; update golden fixtures to match field spec.
- [Igniter-Lang Bridge Agent]: remains blocked pending Research Agent
  proof update.

[D] Decisions:
- Replacement image field set: 10 required, 6 optional, 3 derived, 1 forbidden
  (fragment_report), 1 critical absence rule (migration_receipt_ref = OOF-MR1).
- image_id derivation: same formula as PROP-009 plus schema_fingerprint
  and migration_receipt_ref in the canonical hash input.
- "replaces" link: mandatory on replacement image packets. Image-to-image.
- "supersedes" link: forbidden on replacement image packets. Reserved
  for obs-to-obs demotions only.
- "caused_by" link: points to migration_receipt, not intent or CR.
- "produced_by" / "produced_in": both required on replacement image packets.
- migration_receipt_ref: required in BOTH packet links (caused_by) and payload field.
- Replacement image lifecycle: :session (same as normal). NOT :audit.
  Migration receipt lifecycle: :audit (unchanged).
- Multi-hop: one replacement image per hop. Not one final image with a chain.
- Path selection: shortest path in migration DAG. Policy-selection deferred.
- migration_chain field: lists all pre-predecessor images (not the direct
  predecessor, which is in replaces_image_id).
- Trust: T-1 (fingerprint match) + T-2/T-3/T-4 (provenance chain integrity)
  + T-5 (all non-schema checks compatible) required for trusted post-migration CR.
- 7 OOF-MR rules defined. OOF-MR3 (post-migration fingerprint mismatch)
  is the most dangerous and must have a negative proof test.

[R] Recommendations:
- Research Agent: add OOF-MR3 negative test (P-10) to proof. This is the
  most important safety property: migration cannot silently produce
  wrong-schema images.
- Research Agent: update packet_builder_check.rb to verify P-3, P-4, P-5
  (link presence and correct rel values).
- Update golden fixtures to include migration_chain: [] on the current
  single-hop replacement image.
- Do NOT implement two-hop migration in proof until single-hop fixtures
  are formally verified.

[S] Signals:
- The current proof already satisfies T-1 and most of T-2/T-3/T-4 implicitly.
  The gap is formal checker coverage of P-5 (no "supersedes") and P-9
  (migration_chain shape).
- PROP-017 migration_chain DAG acyclicity (OOF-S4) and OOF-MR5 (runtime
  cycle detection) are the same rule at different stages. The checker can
  cover OOF-MR5 in fixture validation without needing a full DAG traversal.
- The "replaces vs supersedes" question is now resolved: they operate at
  different semantic levels (image vs observation) and must not be mixed.

[T] Tests / Proofs:
- P-1 to P-10 as listed in §Proof Targets.
- Existing proof must remain passing after fixture field additions.
- Checker must add link rel validation (not just link presence).

[Files] Changed:
- igniter-lang/docs/tracks/migration-replacement-image-formalization-v0.md [NEW]
- igniter-lang/docs/README.md [updated]
- igniter-lang/docs/agent-motion.md [updated]

[Q] Open Questions (narrowed to 3):
- Q-1: migration_receipt_ref in TBackend preserve set — explicit or implicit?
- Q-2: migration_chain TBackend presence check scope (fixture vs proof).
- Q-3: Two-hop proof timing — before or after bridge integration?

[X] Rejected:
- "supersedes" for image-to-image links. Obs-to-obs only.
- One final image with migration_chain only (no per-hop images). Breaks audit.
- Policy-selected migration paths in v0. Shortest path is the safe default.
- Distinct obs kind for replacement images. Field/link discipline is sufficient.
- :audit lifecycle for replacement SemanticImages. They are session continuity
  artifacts, not act records. Receipts carry the audit obligation.
- Post-migration fingerprint mismatch as provisional. Must be :blocked.

[Next] Proposed next slices:
1. [Research Agent]: migration-replacement-image-checker-v0
   Update proof and packet_builder_check.rb to cover P-1 through P-10.
   Add golden fixture fields: migration_chain, link rel validation.
   Add OOF-MR3 negative test.

2. [Compiler/Grammar Expert]: migration-multihop-semantics-v0
   Define two-hop migration graph, path selection rules, and
   chain integrity verification. Requires single-hop proof stable first.

3. [Bridge Agent] (blocked until 1 completes):
   schema-migration-bridge-profile-v0
   Carry replacement image field spec into package bridge profile.
```

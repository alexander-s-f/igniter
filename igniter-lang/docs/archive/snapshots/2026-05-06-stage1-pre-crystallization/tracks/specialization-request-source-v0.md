# Track: Specialization Request Source v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/specialization-request-source-v0
Status: done
Date: 2026-05-06
Resolves: Q-1 from polymorphic-add-classifier-v0
Depends on: PROP-012, PROP-016, polymorphic-add-classifier-v0

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — this track resolves the blocker
  for implementing the classifier proof. After this track, the Research
  Agent may implement `polymorphic-add-classifier-proof-v0` against a
  concrete specialization request format.
- `[Igniter-Lang Bridge Agent]` — no action. Bridge only sees
  monomorphized ContractIRs in the loaded artifact; the request source
  is a compile-time concern only.

---

## Problem Statement

`Add[Integer]` and `Add[Float]` are accepted specializations of
`contract Add[T: Additive]`. The classifier (Pass 1) requires a
`specialization_requests` list as input alongside `ClassifiedProgram`.
Without this list, the compiler does not know which concrete types
to instantiate the generic contract for.

The question is: **who produces this list, and how?**

---

## Option Evaluation

### Option A — Build Manifest (explicit list at compiler entrypoint)

```text
The compiler CLI or API accepts a build manifest alongside source:

  igniterc compile add.ig --specialize "Add[Integer]" --specialize "Add[Float]"

or via a manifest file:

  specialize.json: [
    { "contract": "Add", "type_args": { "T": "Integer" } },
    { "contract": "Add", "type_args": { "T": "Float"   } }
  ]
```

| Criterion | Score | Notes |
|-----------|-------|-------|
| Reproducibility | ✅ High | Same manifest → same artifact deterministically |
| Artifact determinism | ✅ High | artifact_hash includes manifest inputs |
| Compiler complexity | ✅ Low | Pass 1 receives a static list; no scanning required |
| Agent inspectability | ✅ High | Manifest is a first-class visible artifact |
| Dead-code bloat | ✅ None | Compiler produces only what is requested |
| RuntimeMachine simplicity | ✅ Unchanged | Loads only monomorphized ContractIRs |

**Risk:** Forgetting to declare a needed specialization → OOF-SP1 at
load time (requested contract not in artifact). But this is a build
config error, not a compiler design flaw.

---

### Option B — Call Sites Trigger Specialization

```text
Every use of Add[Integer] in source (inside another contract or def)
triggers a specialization request automatically:

  contract Foo {
    compute result = Add[Integer]{ a: 1, b: 2 }
  }
  -> compiler sees Add[Integer] call -> adds to specialization set
```

| Criterion | Score | Notes |
|-----------|-------|-------|
| Reproducibility | ✅ High | Same source → same specialization set |
| Artifact determinism | ✅ High | Deterministic scan |
| Compiler complexity | ❌ High | Requires call-site scanning in Pass 0 or Parse; cross-contract dependency tracking |
| Agent inspectability | ⚠️ Medium | Implicit; must infer which contracts triggered which specializations |
| Dead-code bloat | ✅ None | Only specializations that are actually called |
| RuntimeMachine simplicity | ✅ Unchanged | Still receives monomorphized artifact |

**Risk 1:** The `polymorphic_add.ig` fixture has **no call sites** —
there is no `Add[Integer]{...}` inside the fixture file. With Option B,
zero specializations would be generated.

**Risk 2:** Call-site specialization requires scanning across module
boundaries (a contract in module A may call `Add[Integer]` defined in
module B). This is a whole-program analysis, not a per-file compile.

**Risk 3:** Circular dependency: if `Add[Integer]` calls a trait method
that itself needs another specialization, the scan may be non-terminating
without a fixpoint algorithm.

**[D] Option B is unworkable for the current fixture.** The fixture is
a library-style generic definition with no call sites in the source file.
Option B requires a whole-program analysis that is out of scope for v0.

---

### Option C — Impl Declarations Implicitly Create All Specializations

```text
Every (trait, type) pair in ImplEnv automatically generates a specialization:

  impl Additive[Integer] using stdlib.numeric.add
  impl Additive[Float]   using stdlib.numeric.add
  -> compiler creates Add[Integer] and Add[Float] automatically
```

| Criterion | Score | Notes |
|-----------|-------|-------|
| Reproducibility | ✅ High | ImplEnv is deterministic |
| Artifact determinism | ✅ High | Same impls → same specializations |
| Compiler complexity | ✅ Low | Single pass over ImplEnv; cross with generic contracts |
| Agent inspectability | ⚠️ Medium | Implicit; specializations derived not declared |
| Dead-code bloat | ❌ High | Every (trait, type) pair × every generic contract using that trait = combinatorial explosion |
| RuntimeMachine simplicity | ✅ Unchanged | |

**Risk 1 — combinatorial bloat:** If a program has 3 traits × 10 impls each
and 5 generic contracts, Option C produces up to 50 specializations whether
or not they are ever used.

**Risk 2 — cross-trait combinations:** A contract `Foo[T: Additive, U: Ordered]`
with 10 Additive impls and 8 Ordered impls would generate 80 specializations
automatically. Only a few may ever be needed.

**Risk 3 — unrelated impls:** An impl in one module for a type in another
module (cross-module) would automatically generate specializations for every
generic contract importing that trait. This leaks specialization intent
across module boundaries.

**[D] Option C is unworkable for v0 due to dead-code bloat and
cross-module leakage.** It conflates "impl existence" with "usage intent".
These are separate concerns.

---

### Option D — Hybrid: Explicit Manifest with Optional Call-Site Inference

```text
v0 uses explicit manifest (Option A).
v1 may layer call-site inference on top (Option B with whole-program analysis).
Option C (impl coverage) is permanently rejected.

The v0 manifest may be derived by tooling (e.g., a scanner that reads
call sites and emits a candidate manifest), but the compiler always
reads from the explicit manifest — never implicit.
```

| Criterion | Score | Notes |
|-----------|-------|-------|
| All of Option A | ✅ | Identical to Option A for v0 |
| Future extensibility | ✅ High | v1 can add inference as a manifest generator |
| Backward compatibility | ✅ | A manifest is always required; inference is additive |

---

## Decision

**`[D] Option A (explicit build manifest) for v0.**

Rationale:

1. **The fixture has no call sites.** Option B fails on the immediate fixture.
   Option C generates unused specializations. Only Option A works for a
   library-style generic definition.

2. **Artifact determinism.** The `CompiledProgram.artifact_hash` (PROP-012)
   must be reproducible. A manifest is a stable, hashable input to the
   compiler. Call-site scanning and impl coverage are not guaranteed
   deterministic across compiler versions.

3. **Compiler simplicity.** Pass 1 receives `ClassifiedProgram + SpecManifest`.
   No cross-contract scanning, no fixpoint algorithms, no module boundary
   traversal. The manifest is the complete, explicit input.

4. **Agent inspectability.** A manifest is a first-class visible artifact.
   An agent can read `specialize.json` to know exactly what was compiled.
   Implicit specialization (B, C) requires reverse-engineering the compiler's
   reasoning.

5. **No dead code.** Only what is declared is compiled. Option C may produce
   50+ unused specializations; Option A produces exactly what the build author
   specified.

---

## Minimal Manifest Shape

### Inline form (compiler CLI / API)

```text
specialization_requests: [
  { contract: "Add", type_args: { "T": "Integer" } },
  { contract: "Add", type_args: { "T": "Float"   } }
]
```

### File form (`specialize.json` or embedded in `manifest.json`)

```json
{
  "kind": "specialization_manifest",
  "grammar_version": "polymorphic-v0",
  "module": "Lang.Examples.PolymorphicAdd",
  "specializations": [
    {
      "contract": "Add",
      "type_args": { "T": "Integer" },
      "requested_by": "build"
    },
    {
      "contract": "Add",
      "type_args": { "T": "Float" },
      "requested_by": "build"
    }
  ]
}
```

### Field definitions

| Field | Required | Description |
|-------|----------|-------------|
| `contract` | yes | Name of the generic contract to specialize |
| `type_args` | yes | Map of type parameter name → concrete type string |
| `requested_by` | no | Provenance tag: `"build"` \| `"test"` \| `"inferred"` |

`requested_by` is informational only. It does not affect compilation.
It allows tooling to annotate manifest entries that were generated by
a call-site scanner vs. declared manually.

### Where the manifest lives

```text
v0: passed as an argument to the classifier/typechecker entry point.
    In the proof script: a hardcoded Ruby hash / local JSON fixture.
    In the compiler CLI: --spec-manifest specialize.json

v0 .igapp/ artifact: the specialization manifest is embedded in manifest.json
    under the key "specializations". This makes it part of the artifact
    and covered by artifact_hash.
```

**[D] The specialization manifest is an input to the compiler, not
a compiler output.** It is authored by the build system, developer,
or a manifest-generating tool. The compiler consumes it and validates it.

**[D] The manifest is included in `artifact_hash` computation.**
Two compilations of the same source with different manifests produce
different artifacts (and different `artifact_hash` values). This is correct:
the set of compiled specializations is part of the artifact's semantic identity.

---

## OOF / Rejection Rules for Specialization Requests

```text
OOF-SP1: Missing specialization at load time.
  A caller requests Add[Integer] at runtime but the artifact does not
  contain a ContractIR for "Add[Integer]".
  -> RuntimeMachine.load: rejected with constraint.load_contract_not_found.
  -> This is a build error: update the manifest and recompile.

OOF-SP2: Specialization request for non-generic contract.
  manifest entry: { contract: "SimpleAdd", type_args: { "T": "Integer" } }
  but SimpleAdd has no type_params.
  -> compile error: OOF-TY4 (from classifier-v0 table).
  -> Halt before TypedProgram.

OOF-SP3: Invalid concrete type (not a known TypeDecl or primitive).
  manifest entry: { contract: "Add", type_args: { "T": "Banana" } }
  -> compile error: "Banana" is not a primitive and not in TypeEnv.
  -> Halt at type substitution (Pass 1).

OOF-SP4: Type satisfies no trait bound.
  manifest entry: { contract: "Add", type_args: { "T": "String" } }
  -> Pass 1: ImplEnv[("Additive", "String")] not found.
  -> OOF-TY1 (from classifier-v0 table): missing impl.
  -> Compile error. Not emitted to SemanticIR.

OOF-SP5: Duplicate specialization request.
  manifest contains two entries for { contract: "Add", type_args: { "T": "Integer" } }.
  -> compiler deduplicates and emits a warning (OOF-TY5 from classifier-v0).
  -> Only one ContractIR is emitted.
  -> Not a compile error; build warning.

OOF-SP6: Type parameter name mismatch.
  manifest entry: { contract: "Add", type_args: { "X": "Integer" } }
  but Add's type_param is named "T", not "X".
  -> compile error: unknown type parameter name.
  -> Halt at Pass 1 before substitution.

OOF-SP7: Empty specialization manifest for a program with generic contracts.
  A program contains generic contracts but the manifest has no entries.
  -> compile warning: "Generic contracts present but no specializations requested.
     No ContractIR will be emitted for: Add."
  -> The artifact is valid (no type errors), but contains no loadable
     generic specializations. RuntimeMachine.load succeeds (empty contract set
     for the generic).
  -> This is a likely build configuration error. Warning only, not error.
```

---

## Effect on Artifact Structure

With Option A, the `.igapp/` artifact gains:

```text
add.igapp/
  manifest.json           -- includes "specializations" key
  semantic_ir.json        -- generic contract Add is NOT in contracts[]
  contracts/
    Lang.Examples.PolymorphicAdd.Add[Integer].json  -- monomorphized
    Lang.Examples.PolymorphicAdd.Add[Float].json    -- monomorphized
  specialization_manifest.json  -- the input manifest, archived for audit
  classified_ast.json
  requirements.json
  diagnostics.json
```

**[D] `semantic_ir.json` does NOT include the generic `Add` template
as a loadable ContractIR.** The generic template may appear in
`classified_ast.json` as a `ClassifiedContract` for inspection, but it
is not a deployable contract. Only `Add[Integer]` and `Add[Float]`
appear in `contracts/`.

**[D] `specialization_manifest.json` is archived in the `.igapp/`
artifact.** This records the build intent for audit. An agent can inspect
it to understand why certain specializations were or were not compiled.

---

## Effect on artifact_hash

```text
artifact_hash = hash_content(
  program_id                              -- hash of SemanticIR
  ++ language_version
  ++ grammar_version
  ++ axiom_descriptor_ref
  ++ hash_content(contracts ordered by contract_id)
  ++ hash_content(classified_ast)
  ++ hash_content(specialization_manifest)   -- NEW: manifest is part of identity
)
```

**[D] `specialization_manifest` content is included in `artifact_hash`.**
Two compilations of the same source with different manifests produce
different `artifact_hash` values. This is required for determinism: the
artifact's identity depends on what was compiled, not just the source.

---

## Proof Target for Research Agent

The classifier proof (`polymorphic-add-classifier-proof-v0`) must:

```text
[M-1] Accept a hardcoded specialization_requests list as proof input:
      specialization_requests = [
        { "contract" => "Add", "type_args" => { "T" => "Integer" } },
        { "contract" => "Add", "type_args" => { "T" => "Float"   } }
      ]

[M-2] Validate each request against ClassifiedProgram:
      - contract exists and is_generic (OOF-SP2 gate)
      - type_arg names match type_params (OOF-SP6 gate)
      - concrete types are known primitives or TypeDecl entries (OOF-SP3 gate)

[M-3] Pass the validated request list to Pass 1 (TypedProgram).

[M-4] Negative test for OOF-SP4 (Add[String]):
      Add { "contract" => "Add", "type_args" => { "T" => "String" } }
      to the request list and verify OOF-TY1 is raised.

[M-5] Negative test for OOF-SP2:
      Add { "contract" => "SimpleAdd", "type_args" => { "T" => "Integer" } }
      (where SimpleAdd is not generic) and verify OOF-TY4 is raised.
      (SimpleAdd does not exist in this fixture; can be a synthetic test.)

[M-6] Verify OOF-SP5 deduplication:
      Add "Add[Integer]" twice; verify only one ContractIR is emitted.
```

The proof script is the implementation target. No manifest file format is
required for the proof — the hardcoded Ruby hash is sufficient.
The manifest file format is a compiler tooling concern for a later slice.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/specialization-request-source-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: Q-1 is now resolved. May implement
  polymorphic-add-classifier-proof-v0 using M-1 through M-6 above.
- [Igniter-Lang Bridge Agent]: no action.

[D] Decisions:
- v0 uses explicit build manifest (Option A). No implicit specialization.
- Option B (call-site inference) rejected for v0: unworkable for library-style
  generic definitions with no call sites in the source file.
- Option C (impl coverage) permanently rejected: combinatorial dead-code
  bloat and cross-module leakage.
- Hybrid (Option D): Option A for v0; call-site inference may be added
  as a manifest-generator tool in v1, not as a compiler mechanism.
- Manifest shape: list of { contract, type_args } entries. type_args is a
  map from type parameter name (string) to concrete type (string).
- Manifest is archived in .igapp/ artifact as specialization_manifest.json.
- specialization_manifest content is included in artifact_hash computation.
- Generic contract template (Add) is NOT a loadable ContractIR in the artifact.
  It appears only in classified_ast.json for inspection.
- OOF-SP1 through OOF-SP7 are the rejection rules. OOF-SP4 (Add[String])
  and OOF-SP3 (unknown type) are compile errors. OOF-SP5 (duplicate) and
  OOF-SP7 (empty manifest) are warnings only.

[R] Recommendations:
- Research Agent: use a hardcoded Ruby hash for specialization_requests in
  the proof script. No manifest file format needed in the proof.
- Do not implement call-site scanning in the classifier. Pass 1 receives
  the validated list and performs substitution only.
- The `requested_by` field is informational only; do not key logic on it.
- OOF-SP7 (empty manifest warning) should be emitted even in the proof
  script to verify the warning path.

[S] Signals:
- The current fixture (polymorphic_add.ig) has exactly two impl declarations:
  Additive[Integer] and Additive[Float]. The natural manifest for this fixture
  is exactly two specialization requests. There is no ambiguity.
- Option A aligns perfectly with PROP-012's artifact determinism principle:
  artifact_hash is a function of explicit inputs, not implicit compiler
  reasoning. The manifest is the explicit input.
- The archived specialization_manifest.json in .igapp/ closes the audit loop:
  an agent inspecting the artifact always knows what was built and why.

[T] Tests / Proofs:
- M-1 through M-6 as listed in §Proof Target.
- Positive: Add[Integer] and Add[Float] produce ContractIRs, no errors.
- Negative OOF-SP4: Add[String] → OOF-TY1, no ContractIR emitted.
- Negative OOF-SP2: non-generic contract → OOF-TY4.
- Deduplication: duplicate Add[Integer] → one ContractIR, one warning.

[Files] Changed:
- igniter-lang/docs/tracks/specialization-request-source-v0.md  [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Q] Open Questions:
- None blocking. Q-1 is resolved.
- Future (not blocking v0): Should the manifest format be standardized as
  a JSON Schema? Recommendation: yes, in the compiler tooling track.
- Future (not blocking v0): Should v1 call-site inference emit a candidate
  manifest for developer review before compilation? Recommendation: yes —
  inference is a manifest generator, not a compiler mechanism.

[X] Rejected:
- Option B (call-site triggering): unworkable for library-style generics;
  requires whole-program analysis out of scope for v0.
- Option C (impl coverage): combinatorial dead-code bloat; cross-module leakage.
- Implicit specialization of any kind in the compiler.
- Generic template as a loadable ContractIR in the artifact.
- Dynamic specialization at RuntimeMachine load time.

[Next] Proposed next slice:
- [Research Agent]: polymorphic-add-classifier-proof-v0
  Implement ClassifiedProgram + TypedProgram as a standalone Ruby script.
  Use hardcoded specialization_requests (M-1 format).
  Verify M-1 through M-6. All tests must pass before SemanticIR emission work.
```

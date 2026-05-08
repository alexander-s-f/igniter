# Discussion: Temporal Manifest and Cache Boundary Pressure

Card: S3-R3-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: compiler-grammar-expert
Track: temporal-manifest-and-cache-boundary-pressure-v0
Date: 2026-05-08
Status: complete — routed

Trigger: after S3-R3 C2 (temporal-semanticir-access-node-v0) and C3
(runtime-temporal-cache-contract-v0) landed.

---

## Question

Does TEMPORAL survive the full path:
`Classifier → TypeChecker → SemanticIR → Assembler/.igapp/ → RuntimeMachine contract`?

---

## Context

**C2 (S3-R3-C2-P) delivered:**
- `SemanticIREmitter#emit_typed` now lowers typed History/BiHistory reads into
  `temporal_input_node` + `temporal_access_node` with `node_fragment_class:
  temporal`, `value_fragment_class: core`, coordinate refs, and capability names.
- `escape_boundaries` carry `history_read` / `bihistory_read` per temporal
  contract.
- Contract-level `fragment_class: "temporal"` in `semantic_ir.json`. Proof
  PASS, goldens checked.
- Explicitly out of scope: parser syntax, RuntimeMachine cache, assembler
  manifest. Three open [Q] marks left in the track.

**C3 (S3-R3-C3-P) delivered:**
- Formal CORE vs TEMPORAL cache key schemas with axis-level granularity.
- Freshness state machine: `fresh / stale / unknown / provisional`.
- Load/evaluate phase split contract.
- `temporal_cache_key_proof` PASS with collision-detection evidence.
- Explicitly out of scope: no assembler change, no production memoization.

**Code verified against current `lib/igniter_lang/assembler.rb`:**
- Last change: S2-R9 (no assembler edits in S3-R1, S3-R2, or S3-R3).

---

## [Agree]

**The classifier-to-SemanticIR segment is properly closed.**

`fragment_class: "temporal"` propagates correctly through Classifier →
TypeChecker → `SemanticIREmitter#emit_typed` → `semantic_ir.json`. The
individual `contract_ir` inside SemanticIR carries the right fragment class,
coordinate refs, and capability names. This is a clean formal boundary:
Compiler/Grammar Expert owns this segment and C2 proves it.

**The cache key contract is formally sound.**

C3's CORE vs TEMPORAL key schema is correct: temporal coordinates are explicit
key material, not derived from input hash, not ambient. The load/evaluate phase
split — load verifies capability, evaluate constructs the concrete key — is the
right architecture. The `unknown` → reject default is the right safe posture.
`provisional` as a distinguished trust mark (not a synonym for `fresh`) is
specifically correct for TEMPORAL semantics where temporal coordinates can shift
meaning even within a session.

**Both tracks correctly named what they did not do.**

C2 left three explicit open questions about the assembler. C3 listed seven
explicit `[X] Not Implemented Yet` items. This is good discipline — the scope
boundary is visible, not implicit.

---

## [Challenge]

### Challenge 1: `contract_file` in assembler would crash on temporal nodes — verified

`Assembler#contract_file` (assembler.rb:181–214) processes all nodes via:

```ruby
compute_nodes = contract_ir.fetch("nodes").map do |node|
  {
    "type_tag" => type_name(node.fetch("type")),
    ...
    "expression" => compat_expr(node.fetch("expr"))
  }
end
```

**`temporal_input_node` has no `"expr"` key.** `node.fetch("expr")` raises
`KeyError` in Ruby. The contract cannot be assembled.

Additionally, `temporal_input_node` carries a temporal type annotation:

```json
{ "constructor": "History", "element_type": "String" }
```

`type_name` calls `type.fetch("name")` (assembler.rb:255). The key `"name"` is
absent in temporal type annotations — this raises a second `KeyError`.

**Consequence:** Any attempt to run the assembler against a TEMPORAL SemanticIR
produces a runtime error before any manifest is written. The chain does not
merely produce wrong output — it stops entirely.

This is not a design question. It is a crash that will block any Stage 3 work
that requires a deployable `.igapp/` bundle from a TEMPORAL contract.

### Challenge 2: Manifest-level `fragment_class` collapses TEMPORAL to `"mixed"` — verified

`Assembler#build_artifact` (assembler.rb:124):

```ruby
fragment_class = contracts.map { |c| c.fetch("fragment_class") }.uniq == ["core"] ? "core" : "mixed"
```

This binary collapse produces `"mixed"` for any non-CORE contract, including
TEMPORAL. The `igapp_manifest` emits `fragment_class: "mixed"`.

If RuntimeMachine determines the cache strategy from the manifest-level
`fragment_class`, it reads `"mixed"` and cannot identify a TEMPORAL contract.
It would apply CORE key schema — exactly the staleness bug PROP-028 requirement
#7 and the C3 contract were designed to prevent.

The individual contract IR inside `.igapp/` does carry `fragment_class:
"temporal"` correctly. But no specification states which field RuntimeMachine
must read: manifest-level or contract-IR-level. C3 says:
`load(.igapp/) -> read fragment_class / temporal axes from manifest or
ContractIR` — the "or" is an unresolved hedge, not a specification.

### Challenge 3: `requirements_for` is still hardcoded — not derived from SemanticIR escape_boundaries

`Assembler#requirements_for` (assembler.rb:260–291) returns a static hash
identical for every compiled contract, regardless of whether the contract is
CORE, TEMPORAL, or mixed. It does not read from `escape_boundaries` in the
SemanticIR, despite C2 having established `escape_boundaries` as the canonical
source of temporal capability evidence.

After C2, the SemanticIR carries:

```json
"escape_boundaries": [
  {
    "name": "history_read",
    "required_caps": ["history_read"],
    "produces": ["history_access_observation"]
  }
]
```

The assembler ignores this. `requirements.json` in the bundle always says
`read_as_of: true`, `required_caps: []` — independently of actual contract
content. RuntimeMachine consulting `requirements.json` cannot distinguish a
contract that genuinely requires temporal access from one that does not.

### Challenge 4: The C3 cache key contract has no corresponding assembler artifact schema

C3 defines a `runtime_cache_key` JSON shape and a `runtime_cache_entry`
envelope. It also defines that RuntimeMachine at load-time must verify that the
backend/cache adapter supports the required fragment/key schema. But:

- There is no `cache_contract` section defined for `.igapp/` manifests.
- There is no mechanism for the assembler to emit "this contract requires
  TEMPORAL key schema" into a bundle field that a RuntimeMachine can read
  before evaluation begins.

The load/evaluate separation designed in C3 requires load-time information to
be present in the bundle. That information currently has no home in the bundle
format.

---

## [Missing]

### M1. No proof that `temporal_input_node` passes through the Assembler

Neither C2 nor C3 ran the Assembler against a TEMPORAL SemanticIR. C2 proved
`Classifier → TypeChecker → SemanticIR#emit_typed`. C3 proved cache key
schemas. The segment `SemanticIR → Assembler → .igapp/` has not been exercised
by any Stage 3 proof. The crash in Challenge 1 is latent but not yet a measured
proof failure because the assembler has not been asked to process temporal nodes.

### M2. No specification of which `.igapp/` field carries the fragment class for RuntimeMachine

C3 uses "manifest or ContractIR" as a hedge. Needed: a single authoritative
answer. The two candidates have different consequences:

| Source | Contains "temporal"? | Requires assembler change? |
|--------|---------------------|---------------------------|
| `igapp_manifest.fragment_class` | No ("mixed") | Yes |
| Individual contract IR inside bundle | Yes | No |

If the answer is "individual contract IR", the manifest collapse is a
presentation issue, not a correctness issue — but it still means RuntimeMachine
must parse deeper into the bundle before it can dispatch the right cache schema.

If the answer is "manifest", the assembler must be changed before any
TEMPORAL `.igapp/` bundle can be trusted.

### M3. Assembler is not a compiler-grammar-expert surface — but the gap is a language boundary gap

The assembler question (what format temporal nodes take in `.igapp/`) is
formally a boundary question: what is the contract between SemanticIR and the
assembled artifact? That boundary is PROP-022A territory (`.igapp/` assembler
contract). C2 explicitly left three open questions about exactly this boundary.
These questions need an answer before the assembler can be updated correctly.

### M4. Temporal coordinate identification in evaluate-time key construction

C3 states: "Evaluate-time key construction must use SemanticIR/runtime metadata
to know which coordinates are temporal. It must not rely only on field names
like `as_of` when `temporal_input_node` / temporal access metadata is
available."

This is the right principle. But the RuntimeMachine currently has no mechanism
to carry `temporal_input_node` metadata from load-time to evaluate-time. The
C3 contract design requires this channel but does not specify it as an artifact.
If RuntimeMachine re-reads from the bundle at evaluate-time, that is
inefficient but correct. If it uses a pre-built index, the index format is
unspecified.

---

## [Sharper Question]

Not: "Does TEMPORAL survive the full path?"

The answer is clearly: **yes through SemanticIR, no at the assembler boundary**.

The sharper question is:

> **Which of the three assembler gaps is the minimal gate for production
> TEMPORAL `.igapp/` bundles?**
>
> 1. `contract_file` crash on temporal nodes (Challenge 1) — hard blocker;
>    must fix before any temporal assembly can proceed.
> 2. Manifest-level `fragment_class` collapse to "mixed" (Challenge 2) —
>    depends on whether RuntimeMachine reads manifest or contract IR; needs a
>    specification decision before implementation.
> 3. `requirements_for` hardcoded regardless of `escape_boundaries` (Challenge
>    3) — needed for correct capability negotiation at load-time; can be
>    deferred if RuntimeMachine reads directly from SemanticIR escape_boundaries.
>
> Gate 1 is non-negotiable and independent of the specification decision.
> Gates 2 and 3 depend on whether RuntimeMachine reads from the manifest surface
> or from the deeper SemanticIR/contract-IR surface.

---

## [Route]

| Route | What | Owner | Priority |
|-------|------|-------|----------|
| `track` | `temporal-assembler-boundary-v0`: fix `contract_file` to handle `temporal_input_node` and `temporal_access_node` without crashing; define how temporal nodes become capability/requirements in `.igapp/` | Research Agent + Compiler/Grammar Expert | **blocker** for any temporal assembly |
| `PROP` or PROP-022A errata | Specify `.igapp/` manifest field for TEMPORAL fragment class and temporal axes; resolve "manifest or ContractIR" for RuntimeMachine load-time dispatch | Compiler/Grammar Expert | prerequisite for RuntimeMachine load |
| `track` | `temporal-requirements-from-escape-boundaries-v0`: derive `requirements_for` from SemanticIR `escape_boundaries` instead of hardcoded hash | Research Agent | prerequisite for correct load-time capability negotiation |
| `track` | `runtime-cache-proof-local-memoization-v0` (already proposed in C3 handoff) | Research Agent | can start only after assembler boundary track lands |
| `backlog` | Temporal coordinate metadata channel from load to evaluate in RuntimeMachine | Research Agent | deferred until after local memoization proof |

---

## Path Verdict

```text
Classifier                         ✅ fragment_class: temporal — PASS (PROP-028 C2)
TypeChecker                        ✅ typed temporal reads — PASS (PROP-028 C2)
SemanticIREmitter#emit_typed       ✅ temporal_input_node / temporal_access_node — PASS (C2)
Cache key contract                 ✅ CORE vs TEMPORAL schema — PASS (C3)
─────────────────────────────────────────────────────────────────────────
Assembler#contract_file            ❌ crash on temporal nodes — KeyError on "expr" and "name"
Assembler manifest fragment_class  ❌ collapse to "mixed" — specification gap
Assembler requirements_for         ❌ hardcoded, ignores escape_boundaries
.igapp/ manifest cache contract    ❌ no field for cache key schema at load time
RuntimeMachine load → cache schema ?? depends on specification decision (manifest vs contract-IR)
```

TEMPORAL does **not** survive the full path. The chain is broken at the
Assembler boundary. C2 and C3 close the language and contract-design segments
correctly. The assembler boundary remains an explicit open gate before
production temporal `.igapp/` bundles are possible.

---

## Summary for Architect Supervisor intake

C2 and C3 are correct and should be accepted as-is. They close exactly what
they claimed. The open assembler boundary was anticipated — C2 left three
explicit open questions, C3 listed seven `[X]` items.

The immediate gate is:

1. **`temporal-assembler-boundary-v0`** — fix the crash in `contract_file` for
   temporal nodes. This is a hard prerequisite for any temporal assembly.

2. **Specification decision** — which `.igapp/` field carries `fragment_class`
   for RuntimeMachine load dispatch: manifest-level or contract-IR-level. This
   decision determines whether the manifest collapse to `"mixed"` is a
   correctness bug or an acceptable omission.

Neither gate requires new language semantics. They are implementation and
specification work in the compiler/assembler + runtime contract layers.

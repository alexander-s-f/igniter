# Discussion: Temporal Fragment and Cache Key Pressure

Card: S3-R2-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: meta-expert
Track: temporal-fragment-and-cache-key-pressure-discussion-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Do PROP-028 + temporal-cache-key-proof close the silent staleness class well
enough, or is there still a hidden runtime/capability gap before implementation?

---

## Context

- PROP-028 (TEMPORAL fragment class) is authorized. 7 requirements defined in
  `docs/meta-proposals/external-review-response-2026-05-07.md`.
- `temporal-cache-key-proof` is referenced as a companion artifact but does not
  exist as an experiment at review time.
- The silent staleness class: if RuntimeMachine adds memoization without `as_of`
  in the cache key for TEMPORAL contracts, cached results become stale at a
  different `as_of` — no crash, wrong answer.
- Code inspected: `lib/igniter_lang/assembler.rb`,
  `lib/igniter_lang/classifier.rb`, `lib/igniter_lang/compiler_orchestrator.rb`,
  `lib/igniter_lang/temporal_access_runtime.rb`.

---

## [Agree]

**PROP-028 requirements 1–6 — classifier semantics are correct and sufficient.**

The four-level hierarchy (`OOF > TEMPORAL > STREAM > CORE`), node-level vs
contract-level fragment class distinction, and the "no fold_temporal" principle
are well-scoped requirements for the Compiler/Grammar Expert. They are bounded
to classifier/typechecker/semanticir-emitter and do not leak into runtime.

**Requirement #7 (cache key) is a correct pre-emptive signal.**

Identifying `hash(contract_name, inputs, as_of)` as a separate key shape for
TEMPORAL contracts is the right defensive requirement. Without it, a future
memoization layer will produce stale results silently.

**Temporal access hook + capability check — already proven.**

`RuntimeMachineHook` with `history_read`/`bihistory_read` capability check at
load-time is real, executable protection. These capability names will become
correct anchors for PROP-028 requirement #5 (AST node kinds → fragment class
table).

---

## [Challenge]

### Challenge 1: PROP-028 requirement #7 is a runtime requirement inside a compiler PROP

The 7 requirements mix two different ownership levels:

- Requirements 1–6 → Classifier/TypeChecker/SemanticIR — owned by
  Compiler/Grammar Expert (PROP-028).
- Requirement #7 → RuntimeMachine cache key enforcement — owned by Research
  Agent (Runtime lane).

Requirement #7 states: "RuntimeMachine must check `fragment_class` before
building the cache key." But PROP-028 is a language/compiler PROP. If
requirement #7 lives only inside PROP-028 without an explicit Runtime track, it
ends up in a dead zone: written in a PROP, but assigned to no one for
implementation.

Precedent: this is exactly how OOF-I1/I3/I5 became deferred gaps — recorded
in PROP-025, runtime side deferred without a separate track.

### Challenge 2: `temporal-cache-key-proof` does not exist

The card formulates the question as "PROP-028 + temporal-cache-key-proof." The
experiment `temporal-cache-key-proof` does not exist as a file or as an
authorized track. The question cannot receive a "yes, closed" answer — there is
no proof. Either this is a requested artifact (requires a track) or the concept
is implied as "proven via history_type_proof." This needs to be clarified before
PROP-028 implementation starts.

### Challenge 3: `requirements_for` in assembler.rb is hardcoded — not derived from fragment class

Code finding (`lib/igniter_lang/assembler.rb:260`):

```ruby
def requirements_for
  {
    "temporal" => { "requires_as_of" => true, ... },
    "required_tbackend_caps" => { "read_as_of" => true, ... }
  }
end
```

This is a static hash. Every `.igapp/` bundle receives the same `requirements`
regardless of whether the contract is CORE, ESCAPE, or TEMPORAL. The assembler
does not read the contract's `fragment_class` when generating `requirements`.

After PROP-028: TEMPORAL contracts must carry `temporal_axis`,
`required_as_of`, and `cache_key_dimensions` in the manifest. CORE contracts
must not. The current assembler architecture does not support this distinction.
PROP-028 requirements do not mention the assembler at all.

### Challenge 4: Assembler collapses fragment class to `"core"` vs `"mixed"` — no path for `"temporal"`

Code finding (`lib/igniter_lang/assembler.rb:124`):

```ruby
fragment_class = contracts.map { |c| c.fetch("fragment_class") }.uniq == ["core"] ? "core" : "mixed"
```

When the classifier starts emitting `"temporal"` as a fragment class (PROP-028
requirement), the assembler will fold it into `"mixed"`. RuntimeMachine, reading
the `.igapp/` manifest, will see `fragment_class: "mixed"`, not `"temporal"`,
and cannot make the correct cache key decision. The silent staleness bug
survives even if PROP-028 classifier requirements are fully implemented.

---

## [Missing]

### M1. `.igapp/` manifest schema for temporal fragment class is undefined

PROP-028 requirements say the classifier should emit `"temporal"`. But there is
no requirement for how `"temporal"` propagates into the `.igapp/` manifest and
which field RuntimeMachine should read. The current path breaks at the
assembler:

```
classifier → "temporal" fragment class
  → semanticir_emitter → semantic_ir.json (fragment_class: "temporal" per contract)
  → assembler → classified_ast.json (fragment_class: "mixed" ← collapse here)
  → manifest.json → ??? (no field for temporal axes or cache key schema)
  → RuntimeMachine.load → reads ??? → decides cache key schema
```

PROP-028 closes only the first two steps.

### M2. `as_of` identification in cache key construction is underspecified

Requirement #7: `TEMPORAL cache key = hash(contract_name, inputs, as_of)`. But
how does RuntimeMachine know *which* input is `as_of`? Options:

- By name (convention: input named `:as_of`)
- By type annotation (`DateTime` → as_of)
- By `temporal_input_node` presence in semantic IR

If convention-based: the convention needs specification. If semantic-IR-based:
`temporal_input_node` already exists and this is the correct answer — but
PROP-028 requirements do not state this explicitly.

### M3. No separation between "cache key schema" and "capability check"

Capability check (`history_read` present in backend) is a load-time check.
Cache key construction is an evaluate-time concern. Both are currently attributed
to RuntimeMachine without phase separation. If PROP-028 requirement #7 is
implemented without this separation, the result will likely be a single block of
logic mixing load-time and evaluate-time concerns, which creates fragility.

---

## [Sharper Question]

Not: *"Do PROP-028 + temporal-cache-key-proof close the silent staleness class?"*

The correct question is:

> **Who owns the three separate steps needed to close the silent staleness class?**
>
> 1. Classifier: "this is TEMPORAL"
>    → PROP-028 (Compiler/Grammar Expert) — authorized
>
> 2. Assembler: emit `fragment_class: temporal` + `temporal_axes` into manifest
>    → not in PROP-028 requirements, no owner assigned
>
> 3. RuntimeMachine cache key: reads manifest + decides cache schema
>    → no Runtime track, no owner assigned
>
> Until steps 2 and 3 have explicit owners, the silent staleness class is not
> formally closed.

---

## [Route]

| Route | What | Owner |
|-------|------|-------|
| `PROP` | Add requirement #8 to PROP-028: assembler emits `fragment_class: temporal` and `temporal_axes` into manifest for TEMPORAL contracts | Compiler/Grammar Expert |
| `track` | Open `temporal-cache-key-proof-v0` (Runtime lane): prove RuntimeMachine.evaluate for TEMPORAL uses cache key with `as_of`; negative fixture for CORE without `as_of` | Research Agent |
| `backlog` | Formalize `as_of` identification via `temporal_input_node` in semantic IR — likely already the right answer, needs explicit statement in PROP-028 § | Compiler/Grammar Expert (add to PROP-028) |
| `review` | Scope decision: is assembler `fragment_class` collapse fix part of PROP-028 implementation or a separate track? | Architect Supervisor |

---

## Summary for Architect Supervisor intake

PROP-028 requirements 1–6 are ready for Compiler/Grammar Expert authorship as
written. Requirement #7 must either:

- Be explicitly transferred to a Runtime lane track
  (`temporal-cache-key-proof-v0`), or
- Be accepted as a cross-PROP requirement with explicit verification gate before
  any Stage 3 memoization work starts

The assembler `fragment_class` collapse (Challenge 3 + 4) is the most
implementation-critical finding: it makes PROP-028 classifier work insufficient
on its own for closing the staleness class. This needs a scope decision before
PROP-028 implementation begins.

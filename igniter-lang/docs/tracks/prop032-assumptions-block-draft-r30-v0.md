# Track: PROP-032 Assumptions Block Draft (R30)

Card: S3-R30-C6-P (Compiler/Grammar Expert)
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: `compiler-grammar-expert`
Track: `prop032-assumptions-block-draft-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Draft PROP-032 for the `assumptions {}` block — the language primitive for
epistemic provenance. This is the single active Language Lane PROP for the R30
cycle, authorized by S3-R30-C6-P.

---

## Sources Read

- `igniter-lang/docs/dev/canonical-semantic-model.md` — Gap-H status + CSM anchor gap
- `igniter-lang/docs/dev/semantic-governance-heat-map.md` — GI-1 queue conflict (PROP-032), Domain 2
- `igniter-lang/docs/tracks/semantic-governance-heat-map-v0.md` — handoff notes and GI-1 resolution recommendation
- `igniter-lang/docs/language-covenant.md` — P22 (Assumption Visibility), P27 (Accountability), P28 (Unnamed Blocks), Four Axes of Honesty, Epistemic State Machine
- `igniter-lang/docs/proposals/README.md` — queue conflict source; renumbering required
- `igniter-lang/docs/proposals/PROP-031-contract-modifiers-v0.md` — PROP format, two-stage OOF pipeline, classifier/typechecker pattern

---

## Decisions

### D1 — PROP-032 = assumptions {} (GI-1 resolved)

The `proposals/README.md` queue had PROP-032 assigned to `via profile binding`.
This PROP asserts PROP-032 = `assumptions {}` (Gap-H). The renumbering required:

- `via profile binding` → PROP-033
- `output evidence syntax` → PROP-034
- `profile declarations / authority resolution` → PROP-035
- `Effect Surface` → TBD (PROP-036 or beyond)

`proposals/README.md` should be updated by the Meta Expert or Architect in the
next curation pass. The PROP document itself carries the queue note in its header.

### D2 — `epistemic` is a new first-class fragment class

Rather than folding assumption declarations into `escape` or `core`, PROP-032
introduces `epistemic` as the sixth classifier fragment class. Rationale:

1. The Four Axes of Honesty define epistemic honesty as orthogonal to effect
   honesty. A separate fragment class makes the axis visible in the classifier.
2. A `pure contract` that only uses assumptions (no external I/O) should not
   become `escape`. Folding it in would conflate effect character with epistemic
   character.
3. Precedence: `oof > temporal > escape > epistemic > core`. A contract with
   both escape and epistemic declarations retains `fragment_class: "escape"`.
   `assumption_refs` is still populated regardless of fragment class.

### D3 — Module-scoped, at most one `assumptions {}` block per module

Assumptions are module-scoped (visible to all contracts in the file). One
`assumptions {}` block per module; multiple named assumptions inside it.
Cross-module sharing is deferred. Multiple blocks would introduce name-collision
design questions that are not needed for the minimum viable proof.

### D4 — OOF-A1 follows the established two-stage pipeline (Classifier → TypeChecker)

Pattern mirrors OOF-M1 from PROP-031:
- Classifier: detects undeclared assumption reference → appends to `oof_log`,
  sets `fragment_class: "oof"`
- TypeChecker: propagates to `type_errors`, sets `status: "blocked"`
- SemanticIR Emitter: returns `nil` for blocked contracts

### D5 — Evidence propagation is name-trace only in this PROP

`assumption_refs` in `contract_ir` and receipt is a list of names — the record
of what the contract declared. Full evidence chain OOF enforcement (missing
citations, lineage validation) is deferred to PROP-033. PROP-032 only establishes
the wire: the name flows end-to-end.

### D6 — Grammar requires `uses assumptions NAME` for all assumption access

A contract that references `homophily.strength` in a compute expression without
a prior `uses assumptions homophily` declaration triggers OOF-A1. This enforces
P28 (explicit naming) at the contract dependency level. Silent use of assumptions
does not compile.

---

## Deliverables

### Primary: `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`

| Section | Content |
|---------|---------|
| Queue Note | GI-1 resolution; renumbering table |
| §1 Purpose | Problem statement; example; non-goals table |
| §2 Grammar | New productions; backward compat guarantee; kind vocabulary |
| §3 Semantics | Module scope, naming invariant, uses-assumptions contract, strength, evidence |
| §4 Pipeline Shapes | Parser / Classifier / TypeChecker / SemanticIR AST deltas with JSON examples |
| §5 Classifier | New `epistemic` fragment class; precedence; assumption registry; OOF-A1; strength range |
| §6 TypeChecker | OOF-A1 propagation; passthrough rules |
| §7 SemanticIR | `assumption_registry` top-level; `assumption_refs` on contract_ir |
| §8 Evidence + Receipt | Evidence list; receipt `assumption_refs` field |
| §9 Covenant | P22 (direct implementation); P27 (PROP Gov Filter answer: more legible); P28 (grammar + OOF-A1 enforcement) |
| §10 Non-Goals | 11 explicit deferrals |
| §11 Acceptance Criteria | 9 criteria per META-EXPERT-013 §VI |
| §12 Fixture Plan | Summary of minimum fixtures (detail below) |
| §13 Open Questions | 5 open questions (OQ-1..OQ-5) |

### Secondary: this track document

---

## Fixture Plan for Research Agent

The minimum proof fixture set consists of two hand-authored parsed AST fixtures
and one experiment runner. This follows the same pattern as `contract_modifiers_proof`
and `temporal_semanticir_access_node`.

### Recommended experiment location

Either:
- New directory: `igniter-lang/experiments/assumptions_proof/`
- Extension: `igniter-lang/experiments/contract_modifiers_proof/` (if scope is narrow)

Recommendation: **new directory** — `assumptions_proof` — because:
1. It introduces a new pipeline stage shape (`assumption_registry` at program level)
2. It introduces a new fragment class (`epistemic`) that the classifier must support
3. The grammar and classifier changes are non-trivial extensions, not modifier-level additions

### Fixture 1: `assumption_basic.parsed_ast.json` (POSITIVE)

Hand-authored parsed AST for:

```igniter
assumptions {
  assumption homophily {
    kind      :heuristic
    statement "People with similar beliefs interact more often."
    strength  0.70
  }
}

observed contract ScoreInteraction {
  input a_id: String
  input b_id: String
  uses assumptions homophily
  escape interaction_read
  read a: Signal from "signals/{a_id}" lifecycle: :local
  read b: Signal from "signals/{b_id}" lifecycle: :local
  compute score = 0.70
  output score: Decimal[4] evidence [a, b, homophily]
}
```

**Expected pipeline outputs:**

| Stage | Key assertions |
|-------|----------------|
| Parser | `assumptions: [{ kind: "assumption_decl", name: "homophily", ... }]` |
| Classifier | `assumption_registry: [{ name: "homophily", ... }]`; contract has `assumption_refs: ["homophily"]`; `fragment_class: "escape"` (escape > epistemic); `uses_assumptions:homophily` node has `fragment_class: "epistemic"` |
| TypeChecker | `status: "accepted"`, `assumption_refs: ["homophily"]`, `type_errors: []` |
| SemanticIR | `assumption_registry` at top level; `contract_ir.assumption_refs: ["homophily"]` |

**Named proof checks required:**
- `parser.assumptions_block_present`
- `classifier.assumption_registry_built`
- `classifier.contract_assumption_refs`
- `classifier.uses_assumptions_epistemic_fragment`
- `classifier.contract_fragment_class_escape_not_overridden` (escape > epistemic)
- `typechecker.accepted`
- `semanticir.assumption_registry`
- `semanticir.contract_ir_assumption_refs`

### Fixture 2: `oof_a1_undeclared_assumption.parsed_ast.json` (NEGATIVE — OOF-A1)

Hand-authored parsed AST for:

```igniter
pure contract ScoreRisk {
  input value: Integer
  uses assumptions undeclared_heuristic
  compute result = value
  output result: Integer
}
```

Note: no `assumptions {}` block in the parsed program (empty `assumptions: []`).

**Expected pipeline outputs:**

| Stage | Key assertions |
|-------|----------------|
| Classifier | `oof_log: [{ rule: "OOF-A1", node: "uses_assumptions:undeclared_heuristic", ... }]`; `fragment_class: "oof"` |
| TypeChecker | `status: "blocked"`, `type_errors: [{ rule: "OOF-A1", ... }]` |
| SemanticIR | contract returns `nil` (not emitted) |

**Named proof checks required:**
- `classifier.oof_a1_fires`
- `classifier.oof_a1_fragment_class_oof`
- `typechecker.oof_a1_blocked`
- `semanticir.oof_a1_no_ir`

### Fixture 3 (optional — precedence): `epistemic_only_pure.parsed_ast.json` (POSITIVE)

A `pure contract` that uses assumptions but has no escape declarations. Proves
that `epistemic` fragment class is assigned correctly when escape is absent:

```igniter
assumptions {
  assumption recency_bias {
    kind      :heuristic
    statement "Recent events are weighted higher."
    strength  0.80
  }
}

pure contract ScoreRecency {
  input event_age_days: Integer
  uses assumptions recency_bias
  compute weighted = event_age_days
  output weighted: Integer
}
```

**Expected:**
- `fragment_class: "epistemic"` on the contract (no escape, no temporal)
- `assumption_refs: ["recency_bias"]`
- `status: "accepted"`

**Named proof check:**
- `classifier.epistemic_fragment_class_pure_contract`

### Proof runner structure

```ruby
POSITIVE_CASES = {
  "assumption_basic" => {
    json_source: "assumption_basic.parsed_ast.json",
    expected_contracts: [{ name: "ScoreInteraction", modifier: "observed",
                           fragment_class: "escape", assumption_refs: ["homophily"] }],
    expected_assumption_registry: [{ name: "homophily" }],
    sample_input: { "a_id" => "sig-001", "b_id" => "sig-002" }
  },
  "epistemic_only_pure" => {
    json_source: "epistemic_only_pure.parsed_ast.json",
    expected_contracts: [{ name: "ScoreRecency", modifier: "pure",
                           fragment_class: "epistemic", assumption_refs: ["recency_bias"] }],
    expected_assumption_registry: [{ name: "recency_bias" }],
    sample_input: { "event_age_days" => 5 }
  }
}.freeze

NEGATIVE_CASES = {
  "oof_a1_undeclared_assumption" => {
    json_source: "oof_a1_undeclared_assumption.parsed_ast.json",
    expected_oof_code: "OOF-A1",
    expected_contract: "ScoreRisk",
    sample_input: { "value" => 42 }
  }
}.freeze
```

### Prerequisite: Classifier implementation

Before the Research Agent can create goldens, the Classifier must support:

1. `uses_assumptions` node kind in `classify_contract` body loop
2. `assumption_registry` construction from `parsed_program["assumptions"]`
3. OOF-A1 detection (name lookup against registry)
4. `epistemic` fragment class in `classified_decl` and `contract_fragment_for`
5. `assumption_refs` field on classified and typed contracts

The SemanticIR Emitter must support:
1. `assumption_registry` emission at program level
2. `assumption_refs` field on `contract_ir`

These are Compiler/Grammar Expert implementation tasks, not Research Agent tasks.
The Research Agent's role is: hand-author the parsed AST fixtures and run the
proof runner after the classifier/emitter support is in place.

---

## CSM Update Required

After PROP-032 reaches `experiment-pass`, update `canonical-semantic-model.md`:

| Row | Current status | New status | New golden_anchor |
|-----|---------------|-----------|------------------|
| `assumptions {}` block | `spec_candidate` | `experiment-pass` | `assumptions_proof/golden/assumption_basic.classified.json` |
| `uses assumptions NAME` | `spec_candidate` | `experiment-pass` | `assumptions_proof/golden/assumption_basic.classified.json` |

Also update the Missing Anchor Log: remove the two `assumptions` entries.

Also update the Heat Map Domain 2: change `🔴` to `⚙️` for both rows.

---

## Handoff

```text
Card: S3-R30-C6-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-block-draft-v0
Status: done

[D] Decisions
- GI-1 resolved: PROP-032 = assumptions {}. Renumbering table in PROP header.
  proposals/README.md needs a curation pass to apply the renumbering.
- New epistemic fragment class (sixth). Precedence: oof > temporal > escape > epistemic > core.
  Does not override escape/temporal; assumption_refs populated regardless.
- Module-scoped, at most one assumptions {} block. Cross-module deferred.
- OOF-A1 two-stage pipeline (Classifier → TypeChecker), mirrors OOF-M1 pattern.
- Evidence propagation is name-trace only. Full OOF enforcement deferred to PROP-033.
- Draft only: no classifier implementation, no parser change, no golden files.

[S] Shipped / Signals
- igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md: 13 sections, 9 acceptance criteria
- igniter-lang/docs/tracks/prop032-assumptions-block-draft-r30-v0.md: this file
- Covenant interactions: P22 (direct), P27 (PROP gov filter: more legible), P28 (grammar + OOF-A1)
- GI-1 queue conflict: resolved in PROP header with renumbering table

[T] Tests / Proofs
- Draft only. No executable proof. No compiler changes.
- Fixture plan specified for Research Agent (3 fixtures, named checks, runner structure).

[R] Risks / Recommendations
- proposals/README.md queue table is now stale. The renumbering (PROP-033..035 shift)
  should be applied in the next Meta Expert curation pass before any new PROP is
  authored in that range.
- Classifier implementation is a prerequisite for the Research Agent fixture work.
  The Research Agent cannot generate golden files until the Classifier supports
  uses_assumptions nodes, assumption_registry, OOF-A1, and epistemic fragment class.
- OQ-3 (undeclared name in evidence list: OOF-A1 vs OOF-P1) needs resolution before
  the TypeChecker implementation. Recommend OOF-A1 for evidence-list lookups that
  name an assumption-registry key.

[Next] Suggested next slice
- R31: [Meta Expert] proposals/README.md curation — apply renumbering from GI-1 resolution
- R31: [Compiler/Grammar Expert] Classifier implementation — uses_assumptions node,
  assumption_registry, OOF-A1, epistemic fragment class
- R31: [Research Agent] Fixture authoring — 3 hand-authored parsed AST JSONs + proof runner
- R31: [Research Agent] OOF-I1/I3/I5 closure (PROP-025 addendum, no new PROP)
- R31: [Meta Expert] CSM + Heat Map updates after experiment PASS
```

# Primitive Surface Fixture Evaluator Guide

File under test:

```text
primitive_surface_fixture.ig
```

This fixture is intentionally hypothetical future Igniter-Lang syntax. It is a
pressure artifact only and is not claimed to parse with the current compiler.

---

## Suggested Blind Prompt

Give only `primitive_surface_fixture.ig` to the participant and ask:

```text
You are seeing a program in an unfamiliar language.

1. Explain what the program does.
2. Identify the main data structures and values.
3. Explain how arrays, maps, sets, and operators appear to work.
4. Explain how Alice, Bob, and Cara are represented.
5. Explain where execution appears to start.
6. Explain which constructs feel familiar and which feel language-specific.
7. Identify any syntax that is ambiguous or should not become canon without proof.
```

---

## Expected High-Level Understanding

The program is a compact daily dispatch planner. It:

- defines `Employee`, `DispatchTask`, and `Assignment`
- creates named employee entities and task fixtures
- uses arrays for teams/tasks/assignments
- uses a hash map for region labels and summary counters
- uses sets for skills and tags
- matches employees to tasks by region and skill
- scores candidate assignments using ordinary arithmetic
- filters, maps, flat-maps, reduces, and sorts collections
- exposes `plan_today` as the apparent entrypoint
- asserts expected summary totals

The test goal is not algorithmic complexity. It tests whether primitive syntax
looks familiar while still suggesting contract-backed typing and lowering.

---

## Construct Status Table

| Construct | Status | Note |
|-----------|--------|------|
| `module`, `type`, `contract`, `output`, invariant severity | canon | Existing source/kernel and Stage 2 surfaces |
| ordinary operators `+ - * == > >= &&` | canon | Existing expression grammar/kernel pressure |
| record literal `Type { field: value }` | canon-ish pressure | Structural record construction is expected, but exact constructor spelling still needs care |
| `Array[T]` / `[a, b]` | canon | Array literal exists in kernel; `Array[T]` as user-facing alias over `Collection[T]` is pressure |
| `HashMap[K,V]` / `{ k => v }` | pressure | Map type exists as `Map[K,V]`; `HashMap` name and `=>` literal are not canon |
| `Set[T]` / `#{ ... }` | pressure | Useful primitive surface; no canon set literal/type spelling |
| `section` | pressure | Organizational grouping only; no namespace semantics proven |
| `entity` | proposal | Stage 3 idea for identity/lifecycle; not canon |
| `entrypoint` | proposal | Stage 3 review lane; not canon |
| fixture-level `let` values | pressure | Useful data fixture surface; not canon top-level declaration |
| method-chain `.map/.filter/.reduce/.sort_by` | pressure | Familiar collection sugar; lowering must be typed and diagnostic-friendly |
| `in` set membership | pressure | Familiar operator; no canon lowering yet |
| `some`, `none`, `.unwrap`, `.is_some` | pressure | Option ergonomics; type exists, exact API surface not canon |
| `assert` section | non-canon experiment | Test/spec fixture convenience only |

---

## Comprehension Scoring Sketch

Score each dimension from 0 to 2:

```text
0 -- missed or wrong
1 -- partially understood
2 -- clearly understood
```

Dimensions:

1. Overall purpose.
2. Structural data comprehension.
3. Instance/entity comprehension.
4. Array comprehension.
5. Map/hash comprehension.
6. Set and membership comprehension.
7. Collection pipeline comprehension.
8. Entrypoint comprehension.
9. Invariant/assertion comprehension.
10. Ability to distinguish primitive surface from contract substrate.

Maximum score: 20.

---

## Ambiguities To Watch

Useful signals include:

- whether `entity` reads as persistent identity or just object instantiation
- whether `section` reads as grouping or namespace
- whether `{ k => v }` is clearer than `{ key: value }` for maps
- whether `#{ ... }` reads as set syntax or as Ruby-like novelty
- whether method chains hide contract graph identity too much
- whether `Array[T]` should be canonical or lowered to `Collection[T]`
- whether top-level fixture `let` values need a dedicated `fixture` construct
- whether `assert` belongs in language, tests, or evaluator-only syntax

---

## Recommendation

Prioritize next review for:

1. `entity` versus structural value construction
2. map literal spelling
3. set literal spelling
4. collection method-chain lowering
5. `entrypoint` as the visible start surface

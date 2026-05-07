# Academic Sorting Structures Fixture v0

File under test:

```text
academic_sorting_structures.ig
```

This is hypothetical future Igniter-Lang syntax. It is not claimed to parse with
the current compiler.

---

## Suggested Blind Prompt

Give only `academic_sorting_structures.ig` to the participant and ask:

```text
You are seeing a program in an unfamiliar language.

1. Explain what the program does.
2. Identify the main data structures.
3. Explain how List is represented.
4. Identify the sorting algorithms.
5. Explain how correctness is checked.
6. Explain how termination or recursion safety appears to work.
7. Identify anything confusing or ambiguous in the syntax.
```

---

## Expected High-Level Understanding

The program defines a small academic sorting library:

- generic ordered values via `trait Ordered[T]`
- an `Ordering` variant
- a generic algebraic list `List[T] = nil | cons`
- `Length`
- `InsertSorted`
- `InsertionSort`
- `Split`
- `Merge`
- `MergeSort`
- `SortStrategy`, which chooses insertion sort for small lists and merge sort
  otherwise
- `SortProof`, a receipt recording sortedness, permutation check, algorithm, and
  stats

It tests whether readers understand structural recursion, generic constraints,
algebraic data types, invariants, termination measures, and proof/evidence
surface in a classic algorithmic setting.

---

## Concepts Covered

| Concept | Surface in fixture |
|---------|--------------------|
| generic trait | `trait Ordered[T]` |
| variant / ADT | `variant List[T]`, `variant Ordering` |
| recursive structure | `ConsCell[T]` contains `tail: List[T]` |
| structural recursion | `decreases Length(xs).n` |
| pattern matching | `match xs { nil -> ... cons cell -> ... }` |
| generic contracts | `contract MergeSort[T where Ordered[T]]` |
| correctness invariant | `is_sorted`, `same_multiset` |
| proof receipt | `receipt SortProof[T]` |
| strategy selection | `SortStrategy` chooses based on length |
| complexity stats | `SortStats` |

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
2. ADT/List comprehension.
3. Generic/trait comprehension.
4. Insertion sort comprehension.
5. Merge sort comprehension.
6. Correctness invariant comprehension.
7. Termination/decreases comprehension.
8. Evidence/proof receipt comprehension.
9. Strategy selection comprehension.
10. Ability to identify ambiguity.

Maximum score: 20.

---

## Ambiguities To Watch

Participants may reasonably ask:

- whether `variant` is a first-class language feature or a profile over `type`
- whether `nil` and `cons` are constructors in scope automatically
- whether `compare(...)` is resolved from `Ordered[T]`
- whether `decreases` is a compiler proof obligation or documentation
- whether repeated calls like `Split(xs)` and `MergeSort(...)` are memoized or
  re-evaluated
- whether `let` creates a graph node equivalent to `compute`
- whether `SortProof` is trusted or recomputed by the runtime
- whether `same_multiset` is decidable for every `T`

These are useful signals for general-purpose language pressure.

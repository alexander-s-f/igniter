module Lab.Fixtures.AcademicSortingStructures

profile academic_core {
  fragment: :core
  recursion: structural
  termination: required
  evidence: required
  backend: :memory
}

trait Ordered[T] {
  compare(left: T, right: T) -> Ordering
}

variant Ordering {
  less: Unit
  equal: Unit
  greater: Unit
}

variant List[T] {
  nil: Unit
  cons: ConsCell[T]
}

type ConsCell[T] {
  head: T
  tail: List[T]
}

type Pair[A, B] {
  first: A
  second: B
}

type SortStats {
  input_size: Integer
  comparisons: Integer
  moves: Integer
  max_depth: Integer
}

type SortResult[T] {
  values: List[T]
  stats: SortStats
}

receipt SortProof[T] {
  input_ref: EvidenceRef
  result_ref: EvidenceRef
  sorted_check: Bool
  permutation_check: Bool
  algorithm: Symbol
  stats: SortStats
}

type EvidenceRef {
  id: String
  kind: Symbol
  hash: String
}

contract Length[T](xs: List[T]) -> n: Integer using academic_core {
  match xs {
    nil -> let n = 0
    cons cell -> let n = 1 + Length(cell.tail).n
  }

  output n: Integer = n
    evidence [xs]
}

contract InsertSorted[T where Ordered[T]](x: T, xs: List[T]) -> result: List[T] using academic_core {
  decreases Length(xs).n

  match xs {
    nil ->
      let result = cons(ConsCell[T] { head: x, tail: nil })

    cons cell ->
      let order = compare(x, cell.head)

      let result = if order == :greater {
        cons(ConsCell[T] {
          head: cell.head,
          tail: InsertSorted(x, cell.tail).result
        })
      } else {
        cons(ConsCell[T] { head: x, tail: xs })
      }
  }

  invariant preserves_count: Length(result).n == Length(xs).n + 1
    severity :error

  output result: List[T] = result
    evidence [x, xs]
}

contract InsertionSort[T where Ordered[T]](xs: List[T]) -> sorted: List[T], stats: SortStats, proof: SortProof[T] using academic_core {
  decreases Length(xs).n

  match xs {
    nil ->
      let sorted = nil
      let stats = SortStats {
        input_size: 0,
        comparisons: 0,
        moves: 0,
        max_depth: 0
      }

    cons cell ->
      let tail_sorted = InsertionSort(cell.tail)
      let sorted = InsertSorted(cell.head, tail_sorted.sorted).result
      let stats = SortStats {
        input_size: tail_sorted.stats.input_size + 1,
        comparisons: tail_sorted.stats.comparisons + Length(tail_sorted.sorted).n,
        moves: tail_sorted.stats.moves + Length(tail_sorted.sorted).n + 1,
        max_depth: tail_sorted.stats.max_depth + 1
      }
  }

  let proof = SortProof[T] {
    input_ref: evidence_ref(xs),
    result_ref: evidence_ref(sorted),
    sorted_check: is_sorted(sorted),
    permutation_check: same_multiset(xs, sorted),
    algorithm: :insertion_sort,
    stats: stats
  }

  invariant output_sorted: is_sorted(sorted)
    severity :error

  invariant output_permutation: same_multiset(xs, sorted)
    severity :error

  output sorted: List[T] = sorted
    evidence [xs, proof]

  output stats: SortStats = stats
    evidence [xs]

  output proof: SortProof[T] = proof
    evidence [xs, sorted]
}

contract Split[T](xs: List[T]) -> halves: Pair[List[T], List[T]] using academic_core {
  decreases Length(xs).n

  match xs {
    nil ->
      let halves = Pair[List[T], List[T]] { first: nil, second: nil }

    cons one ->
      match one.tail {
        nil ->
          let halves = Pair[List[T], List[T]] {
            first: cons(ConsCell[T] { head: one.head, tail: nil }),
            second: nil
          }

        cons two ->
          let rest = Split(two.tail).halves
          let halves = Pair[List[T], List[T]] {
            first: cons(ConsCell[T] { head: one.head, tail: rest.first }),
            second: cons(ConsCell[T] { head: two.head, tail: rest.second })
          }
      }
  }

  invariant split_preserves_count: Length(halves.first).n + Length(halves.second).n == Length(xs).n
    severity :error

  output halves: Pair[List[T], List[T]] = halves
    evidence [xs]
}

contract Merge[T where Ordered[T]](left: List[T], right: List[T]) -> result: List[T], comparisons: Integer using academic_core {
  decreases Length(left).n + Length(right).n

  match left {
    nil ->
      let result = right
      let comparisons = 0

    cons lcell ->
      match right {
        nil ->
          let result = left
          let comparisons = 0

        cons rcell ->
          let order = compare(lcell.head, rcell.head)

          let merged_tail = if order == :greater {
            Merge(left, rcell.tail)
          } else {
            Merge(lcell.tail, right)
          }

          let result = if order == :greater {
            cons(ConsCell[T] { head: rcell.head, tail: merged_tail.result })
          } else {
            cons(ConsCell[T] { head: lcell.head, tail: merged_tail.result })
          }

          let comparisons = merged_tail.comparisons + 1
      }
  }

  invariant merge_sorted_when_inputs_sorted: !is_sorted(left) || !is_sorted(right) || is_sorted(result)
    severity :error

  invariant merge_preserves_count: Length(result).n == Length(left).n + Length(right).n
    severity :error

  output result: List[T] = result
    evidence [left, right]

  output comparisons: Integer = comparisons
    evidence [left, right]
}

contract MergeSort[T where Ordered[T]](xs: List[T]) -> sorted: List[T], stats: SortStats, proof: SortProof[T] using academic_core {
  decreases Length(xs).n

  let size = Length(xs).n

  let small_case = size <= 1

  let sorted = if small_case {
    xs
  } else {
    let halves = Split(xs).halves
    let left_sorted = MergeSort(halves.first)
    let right_sorted = MergeSort(halves.second)
    Merge(left_sorted.sorted, right_sorted.sorted).result
  }

  let stats = if small_case {
    SortStats {
      input_size: size,
      comparisons: 0,
      moves: size,
      max_depth: 0
    }
  } else {
    let halves = Split(xs).halves
    let left_sorted = MergeSort(halves.first)
    let right_sorted = MergeSort(halves.second)
    let merged = Merge(left_sorted.sorted, right_sorted.sorted)

    SortStats {
      input_size: size,
      comparisons: left_sorted.stats.comparisons + right_sorted.stats.comparisons + merged.comparisons,
      moves: left_sorted.stats.moves + right_sorted.stats.moves + size,
      max_depth: max(left_sorted.stats.max_depth, right_sorted.stats.max_depth) + 1
    }
  }

  let proof = SortProof[T] {
    input_ref: evidence_ref(xs),
    result_ref: evidence_ref(sorted),
    sorted_check: is_sorted(sorted),
    permutation_check: same_multiset(xs, sorted),
    algorithm: :merge_sort,
    stats: stats
  }

  invariant output_sorted: is_sorted(sorted)
    severity :error

  invariant output_permutation: same_multiset(xs, sorted)
    severity :error

  output sorted: List[T] = sorted
    evidence [xs, proof]

  output stats: SortStats = stats
    evidence [xs]

  output proof: SortProof[T] = proof
    evidence [xs, sorted]
}

contract SortStrategy[T where Ordered[T]](xs: List[T]) -> result: SortResult[T], proof: SortProof[T] using academic_core {
  let n = Length(xs).n

  let chosen = if n <= 16 {
    InsertionSort(xs)
  } else {
    MergeSort(xs)
  }

  let result = SortResult[T] {
    values: chosen.sorted,
    stats: chosen.stats
  }

  invariant chosen_result_sorted: is_sorted(result.values)
    severity :error

  invariant chosen_result_permutation: same_multiset(xs, result.values)
    severity :error

  output result: SortResult[T] = result
    evidence [xs, chosen.proof]

  output proof: SortProof[T] = chosen.proof
    evidence [xs, result]
}

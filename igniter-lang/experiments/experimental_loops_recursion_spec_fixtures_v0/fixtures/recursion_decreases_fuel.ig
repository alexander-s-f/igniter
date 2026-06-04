-- Proof-local specification fixture only.
-- Evidence class: proof-local specification fixture.
-- Authority: Ch13 / future PROP-039+ input only.
-- This is not parser, TypeChecker, SemanticIR, runtime, or public support.

module Experimental.LoopsRecursion.RecursionDecreasesFuel

recursive contract FactorialFuel(n: Integer, acc: Integer) -> result: Integer
  decreases fuel
  max_steps 100
{
  if n == 0 {
    output acc
  } else {
    recur(n: n - 1, acc: acc * n)
  }
}

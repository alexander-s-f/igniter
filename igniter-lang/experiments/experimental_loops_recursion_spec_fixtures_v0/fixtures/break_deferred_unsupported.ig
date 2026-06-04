-- Proof-local negative specification fixture only.
-- Evidence class: deferred source pressure.
-- Source-level break remains deferred by R247/R248.
-- This fixture does not claim parser, TypeChecker, or runtime behavior.

module Experimental.LoopsRecursion.BreakDeferredUnsupported

contract BreakDeferredUnsupportedFixture(as_of: DateTime) {
  input claims: Collection[Claim]

  for BreakDeferredLoop claim in claims max_steps: claims.count {
    break
  }

  output expected_future_pressure: String =
    "break remains deferred and unsupported by this slice"
}

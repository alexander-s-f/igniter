-- Proof-local negative specification fixture only.
-- Evidence class: future diagnostic pressure.
-- Postulate 28 requires semantic loop blocks to be named.
-- This fixture does not claim enforcement is implemented.

module Experimental.LoopsRecursion.UnnamedLoopRobustness

contract UnnamedLoopRobustnessFixture(as_of: DateTime) {
  input claims: Collection[Claim]

  for claim in claims max_steps: claims.count {
    compute reviewed_claim = ReviewClaim(claim, as_of)
  }

  output expected_future_pressure: String =
    "unnamed loop should become a future diagnostic fixture"
}

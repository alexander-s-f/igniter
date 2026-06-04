-- Proof-local negative specification fixture only.
-- Evidence class: proof-local specification fixture.
-- Expected wording anchor: Ch8 OOF-L6.
-- This fixture does not mint a new OOF registry code.

module Experimental.LoopsRecursion.SourceLevelNowProhibited

contract SourceLevelNowProhibitedFixture {
  compute invalid_time = now()

  output expected_refusal: String =
    "source-level now() prohibited; use TemporalCtx.as_of or tick.time"
}

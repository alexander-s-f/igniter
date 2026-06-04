-- Proof-local specification fixture only.
-- Evidence class: proof-local specification fixture.
-- Authority: Ch13 / future PROP-039+ input only.
-- This is not parser, TypeChecker, SemanticIR, runtime, or public support.

module Experimental.LoopsRecursion.BoundedLocalCollectionLoop

contract BoundedLocalCollectionLoopFixture(as_of: DateTime) {
  input claims: Collection[Claim]

  for ClaimLoop claim in claims max_steps: claims.count {
    compute reviewed_claim = ReviewClaim(claim, as_of)
  }

  output fixture_note: String =
    "bounded local loop input only; not fold_stream; not runtime support"
}

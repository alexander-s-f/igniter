-- Proof-local specification fixture only.
-- Evidence class: proof-local specification fixture.
-- Authority: PROP-037 progression descriptor input only.
-- This is not parser, TypeChecker, SemanticIR, runtime, or public support.

module Experimental.LoopsRecursion.ServiceLoopClockTickTime

service contract ServiceLoopClockTickTimeFixture()
  heartbeat every 5.seconds
  checkpoint every 1.minute
  cancellation required
  max_step_latency 2.seconds
{
  loop TickLoop tick in clock.every(5.seconds) {
    compute explicit_as_of = tick.time
    compute event_identity = tick.event_id
  }
}

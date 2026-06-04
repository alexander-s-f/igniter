# Clock Every Non-Stream Evidence Note

Evidence class: proof-local specification fixture.

`clock.every` is represented here as a PROP-037 progression `source_kind` /
source binding for service liveness. It is not treated as `Stream[DateTime]`.

This note preserves the accepted separation:

- `fold_stream` remains a PROP-023 stream/window bounded fold surface.
- bounded local loops and recursion remain Ch13 / future PROP-039+ input.
- service-loop source binding remains PROP-037 progression descriptor input.
- no parser, TypeChecker, SemanticIR, runtime, API, CLI, package, public
  runtime, Reference Runtime, production, performance, certification, or
  portability claim is made.

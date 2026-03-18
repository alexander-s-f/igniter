## [Unreleased]

## [0.2.0] - 2026-03-18

- Complete the `arbor` to `igniter` rename across runtime, docs, examples, console setup, and shipped signatures.
- Strengthen compile-time validation for proc signatures, composition input mappings, node ids, and node paths.
- Refine runtime semantics with a dedicated invalidation object, stricter execution lifecycle events, and explicit `execution_failed` signaling.
- Make composition resolution eager and reliable so parent composition nodes fail when child executions fail.
- Add structured error context with graph, node, path, and source location metadata.
- Expand introspection with stable node ids, invalidation details, richer explain output, and machine-readable execution/result/event payloads.
- Add diagnostics reports with structured, text, and markdown summaries for successful and failed executions.
- Add runnable example scripts plus smoke-tested quick-start examples and refresh the public documentation.

- Rename the gem and top-level namespace from `arbor` to `igniter`.
- Replace the legacy prototype with the v2 core runtime, compiler, DSL, and extensions.
- Add typed inputs, composition, auditing, reactive subscriptions, and introspection.

## [0.1.0] - 2025-08-03

- Initial release

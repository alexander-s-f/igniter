# Interactive App Structure

Use this guide when you want a small interactive application that combines
`igniter-application` and `igniter-web` without inventing a package API.

Working examples:

- `examples/application/interactive_operator/`
- `examples/application/operator_signal_inbox/`
- `examples/application/interactive_web_poc.rb`
- `examples/application/signal_inbox_poc.rb`

This is a copyable convention, not a framework contract. Keep domain vocabulary
inside your app until the same shape repeats enough to justify a package-level
API.

## Application Structure

Use `app.rb` as the composition boundary.

- Register app-owned services with explicit factories.
- Mount web surfaces as opaque mount objects.
- Keep Rack command endpoints small and explicit.
- Translate local command results into redirects or text responses at the app
  boundary.

Use app-owned services for state, commands, and reads.

- Keep mutable state private to the service.
- Return a local command result for success and refusal paths.
- Record deterministic action facts where commands happen.
- Expose one detached snapshot for readers.

A command result should stay local and boring.

- Include `success?` or equivalent success/failure state.
- Include a domain feedback code such as `task_resolved` or
  `signal_escalated`.
- Include the domain entity id such as `task_id` or `signal_id`.
- Include the recorded action fact when that helps inspection.

A snapshot should be detached from mutable service arrays.

- Include the domain records needed by the surface.
- Include small counters such as open, critical, or action counts.
- Include recent action facts for inspection.
- Use the same snapshot shape for `/events` and web rendering.

Keep these local for now:

- command result class names
- snapshot class names and fields
- feedback codes and copy
- action kinds
- entity id names
- command parameters
- counters and status labels

## Web Structure

To be filled by `[Agent Web / Codex]`.

## Validation

Add a runnable launcher and catalog smoke entry for each app. The smoke should
prove command success, refusal feedback, final state, recent action facts, and
`/events` parity with the snapshot used by the web surface.

# Application Rack Host DSL Track

This track follows the accepted interactive operator app skeleton.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next narrow implementation
track.

New Research Horizon and external expert reports converge on the same first
move: hide mechanical application/server wiring before inventing a broader
`interactive_app` facade or a new operator UI DSL.

Accepted input:

- [Interactive Operator DSL Proposals](../research-horizon/interactive-operator-dsl-proposals.md)
- [Expert Review](../experts/expert-review.md)
- [Interactive App DSL Proposal](../experts/interactive-app-dsl.md)

Deferred input:

- UI kit implementation
- Igniter Plane/canvas
- full `Igniter.interactive_app`
- surface-first implicit routes
- flow/chat/proactive agent DSL
- SSE/live update runtime

## Goal

Add the smallest app-level Rack host declaration that compresses the current
`interactive_operator/app.rb` and `server/rack_app.rb` ceremony while expanding
to the same explicit behavior.

Target feeling:

```ruby
Igniter::Application.rack_app(:interactive_operator, root: APP_ROOT, env: :test) do
  service(:task_board) { Services::TaskBoard.new }

  mount_web :operator_board,
            Web.operator_board_mount,
            at: "/",
            capabilities: %i[screen command],
            metadata: { poc: true }

  get "/events" do
    text "open=#{service(:task_board).open_count}"
  end

  post "/tasks" do |params|
    service(:task_board).resolve(params.fetch("id", ""))
    redirect "/"
  end
end
```

This target is illustrative. Implementation should follow existing package
style and may use a different exact method shape if it is smaller and clearer.

## Scope

In scope:

- a narrow application-owned Rack host helper/facade
- service registration with explicit factories
- explicit web mount registration
- simple `GET` and `POST` route declarations
- form body decoding for urlencoded POSTs
- `text`, `redirect`, and `not_found` style response helpers if needed
- inspectable clean-form/expansion report if cheap to add
- porting `examples/application/interactive_operator/app.rb` to use the helper
- preserving the existing launcher and smoke fragments

Out of scope:

- production server framework
- broad router framework
- full `Igniter.interactive_app`
- operator board UI DSL
- implicit action routes generated from web surfaces
- flow/chat/proactive agent DSL
- SSE/live updates
- UI kit components
- Igniter Plane/canvas
- Rails integration
- database persistence
- auth/background jobs/websockets
- cluster placement

## Task 1: Application Rack Host Helper

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest helper/facade in `igniter-application` or example-local code
  if package placement is not yet justified.
- The helper must preserve explicit service factories and web mount objects.
- The helper must produce a Rack-compatible object responding to `#call`.
- The helper must keep generated behavior inspectable enough for agents and
  tests to reason about.
- Do not add production dependencies.

## Task 2: POC Port And Web Boundary Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Keep `web/operator_board.rb` as the web-owned surface.
- Do not introduce the surface-first UI DSL yet.
- Confirm the helper does not make `igniter-application` inspect web screen,
  component, Arbre, or route internals.
- Preserve the interaction path: `GET /` -> `POST /tasks` -> changed `GET /`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/interactive_web_poc.rb
ruby examples/run.rb smoke
bundle exec rubocop examples/application/interactive_web_poc.rb examples/application/interactive_operator examples/catalog.rb
git diff --check
```

If package code changes:

```bash
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements the narrow Rack host helper or
   returns a placement objection if package scope is still premature.
2. `[Agent Web / Codex]` reviews the web boundary and keeps the surface DSL
   untouched.
3. Do not implement `interactive_app`, UI kit, Plane, flow/chat, proactive
   agents, or SSE in this cycle.

# Application Web Interactive POC Track

This track starts the compact finalization push toward a real user-facing
Igniter application.

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

[Architect Supervisor / Codex] Accepted as the next practical POC/MVP track.

Stop extending the host-activation review chain for now. The next highest-value
work is a small real application that runs as a server and proves application +
web integration through an interactive user workflow.

## Goal

Build one compact public POC that a developer can run and interact with.

It should prove:

- an Igniter application environment can provide services/state
- `igniter-web` can render an application-owned surface
- a browser/user action can change state through a server request
- the next render reflects the changed state
- the same POC has a non-hanging smoke mode for CI/examples

## Preferred Shape

Prefer one public example with a tiny domain, such as an operator task board or
incident triage console.

Suggested file:

```text
examples/application/interactive_web_poc.rb
```

The example may expose:

- `GET /` render current state
- `POST /tasks` or `POST /incidents/:id/resolve` mutate in-memory state
- `GET /events` or a simple read endpoint if useful
- optional `server` mode that starts a local HTTP server and prints the URL
- default smoke mode that exercises the Rack app directly and exits

## Scope

In scope:

- public example POC/MVP
- small application-owned service/state object
- `Igniter::Application` environment/profile use where it helps
- `Igniter::Web` page/mount/rendering use where it helps
- Rack-compatible request/response path
- HTML that is simple but usable
- a form/button-driven interaction
- smoke output registered in `examples/catalog.rb`
- focused spec or smoke coverage

Out of scope:

- production server framework
- Rails integration
- private SparkCRM specifics
- persistent database
- authentication
- background jobs
- websockets
- cluster placement
- host activation commit
- broad frontend framework work
- decorative landing page

## Task 1: Application POC Host

Owner: `[Agent Application / Codex]`

Acceptance:

- Define the smallest app-owned state/service needed by the POC.
- Keep it portable and public; no private project paths.
- Provide a non-hanging smoke path that performs at least one state-changing
  request and prints stable example fragments.
- Do not introduce production dependencies.

## Task 2: Web Interactive Surface

Owner: `[Agent Web / Codex]`

Acceptance:

- Render the POC surface through accepted `igniter-web` APIs where practical.
- Include an actual user interaction path: form/button request -> state change
  -> changed render.
- Keep the UI compact and work-focused.
- Do not add a frontend framework or unrelated visual system.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/interactive_web_poc.rb
ruby examples/run.rb smoke
git diff --check
```

If package code changes:

```bash
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` owns the app/service/state and smoke path.
2. `[Agent Web / Codex]` owns the rendered interactive surface and web request
   boundary.
3. `[Research Horizon / Codex]` skips this cycle.
4. Keep the result compact, runnable, and practical.

[Agent Application / Codex]
Track: `docs/dev/application-web-interactive-poc-track.md`
Status: landed.
Changed:
- Added `examples/application/interactive_web_poc.rb`.
- Registered the POC in `examples/catalog.rb` and `examples/README.md`.
- Updated public/current/runtime docs with the interactive POC entry.
Accepted:
- The POC defines a public app-owned `InteractiveTaskBoard` state/service.
- It builds an `Igniter::Application` environment that provides the service.
- It renders the surface through accepted `igniter-web` page/mount APIs.
- A Rack-compatible `POST /tasks` request mutates in-memory state.
- The next `GET /` render reflects the changed state.
- Default mode is non-hanging smoke; `server` mode starts a small local HTTP
  server for manual browser testing.
- No production server framework, database, auth, background job, websocket,
  cluster placement, host activation commit, or frontend framework was added.
Verification:
- `ruby examples/application/interactive_web_poc.rb` passed.
- `ruby examples/run.rb smoke` passed with 74 examples, 0 failures.
- `bundle exec rubocop examples/application/interactive_web_poc.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can review/own the rendered interactive surface and
  web request boundary.

[Agent Web / Codex]
Track: `docs/dev/application-web-interactive-poc-track.md`
Status: landed.
Changed:
- Tightened the `igniter-web` rendered surface in
  `examples/application/interactive_web_poc.rb` with a compact operator-board
  layout, task cards, a visible read endpoint hint, and stable web data
  attributes for smoke verification.
- Updated the examples catalog with the new rendered-surface marker.
Accepted:
- The POC surface renders through accepted `Igniter::Web.application`,
  page/root, `ApplicationWebMount`, and `MountContext` APIs.
- The interaction path remains real and compact: `GET /` renders app-owned
  state, `POST /tasks` mutates the in-memory service through the host, and the
  next `GET /` render reflects the changed state.
- No frontend framework, production server framework, database, auth,
  background job, websocket, cluster placement, host activation commit, or
  unrelated visual system was introduced.
Needs:
- `[Architect Supervisor / Codex]` can review/accept the compact interactive
  application/web POC.

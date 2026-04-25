# Interactive Operator DSL Proposals

Status: proposal for `[Architect Supervisor / Codex]` review.

Date: 2026-04-25.

Customer: project owner.

Source example:

- `examples/application/interactive_operator/`

## Problem

The current interactive operator POC is functionally useful. It proves that an
app-local service can own state, `igniter-web` can render an operator surface,
and a Rack host can expose read and command endpoints.

The friction is ceremony. The developer's intent is spread across:

- application assembly in `app.rb`
- service state in `services/task_board.rb`
- rendered web surface in `web/operator_board.rb`
- manual Rack routing in `server/rack_app.rb`
- Rack boot wiring in `config.ru`

That split is valuable as a clean form, but it is too verbose as the first
authoring interface. The desired developer experience is a compact DSL that can
express the same app, keep package boundaries visible, and expand into the
current explicit structure when needed.

## Current POC Shape

Today the example says:

- create `Services::TaskBoard`
- build an `Igniter::Application` kernel
- register a manifest
- provide `:task_board`
- build an `Igniter::Web` mount
- mount it at `/`
- create an application environment
- bind the mount to the environment
- route `GET /` to the web surface
- route `GET /events` to a text read endpoint
- route `POST /tasks` to a command that mutates the board
- expose the result as a Rack app

This is a good expansion target. It is not the ideal authoring surface.

## ActiveAdmin-Like North Star

For this iteration, intentionally push the design toward an ActiveAdmin-like
ideal before narrowing it back down.

ActiveAdmin is valuable here not because Igniter should become CRUD/admin
software, but because it proves a useful authoring posture:

- one compact application-facing declaration
- strong defaults
- readable domain words
- mount/action/page configuration close together
- low ceremony for common flows
- escape hatches into explicit Ruby
- generated runtime wiring that developers rarely need to hand-write

The desired feeling is:

```text
declare the operator application, not the plumbing
```

Igniter's version should remain application-first rather than resource-first.
The core unit is not a Rails model. It is an application surface backed by
services, contracts, commands, queries, sessions, and future agents.

## Design Goal

Make this possible in a compact, readable, extensible form:

```ruby
module InteractiveOperator
  App = Igniter.operator_app :interactive_operator,
                             root: __dir__,
                             env: :test do
    service :task_board, Services::TaskBoard

    surface :operator_board, at: "/", title: "Operator task board" do
      metric :open_tasks do
        task_board.open_count
      end

      collection :tasks, from: :task_board do
        item_title(&:title)
        item_status(&:status)

        action :resolve,
               label: "Resolve",
               only_if: ->(task) { task.status == :open } do |task|
          task_board.resolve(task.id)
          redirect_to surface(:operator_board)
        end
      end
    end

    endpoint :events, at: "/events", format: :text do
      "open=#{task_board.open_count}"
    end
  end
end
```

This is the ideal orientation, not the accepted implementation plan. The
compact form should be pleasant for humans and agents. The expanded form should
remain boring, inspectable Ruby.

## Non-Goals

- Do not build a hidden production server framework.
- Do not put `igniter-web` ownership inside `igniter-application`.
- Do not make every app depend on Rack.
- Do not collapse application, web, runtime, host, and future cluster concepts
  into one god DSL.
- Do not make ActiveAdmin-style CRUD the central model; borrow the authoring
  ergonomics, not the domain assumptions.
- Do not hide state mutation behind implicit controller callbacks.

## ActiveAdmin-Like Vocabulary Experiments

The following sketches deliberately search for the best application-level
authoring shape. They are allowed to be ambitious because this document is a
proposal, not a package API.

### Variant 1: Operator App

This variant optimizes for the current example.

```ruby
Igniter.operator_app :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard

  board :tasks, service: :task_board, at: "/" do
    title "Operator task board"
    subtitle "Interactive Igniter POC"

    metric :open_tasks, &:open_count

    item do
      title(&:title)
      status { |task| task.status == :resolved ? "Resolved" : "Awaiting operator" }

      action :resolve, if: ->(task) { task.status == :open } do |task|
        task_board.resolve(task.id)
      end
    end
  end

  endpoint :events, at: "/events", as: :text do
    "open=#{task_board.open_count}"
  end
end
```

Strength:

- most ActiveAdmin-like
- reads as a product feature, not as transport wiring
- excellent for examples and quick internal tools

Risk:

- `board`, `item`, and `metric` may be too operator-specific for core
- can hide the web/server boundary if promoted too early

### Variant 2: Application Register

This variant borrows ActiveAdmin's "register a thing, then customize it"
feeling, but the registered thing is an application surface rather than a
database resource.

```ruby
Igniter.application :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard

  register :operator_board, type: :surface, at: "/" do
    uses :task_board

    index title: "Operator task board" do
      stat :open_tasks, value: -> { task_board.open_count }

      list :tasks, value: -> { task_board.tasks } do
        column :title
        column :status

        action :resolve, method: :post, visible: ->(task) { task.status == :open } do |task|
          task_board.resolve(task.id)
          redirect_to :operator_board
        end
      end
    end
  end

  endpoint :events, at: "/events" do
    text "open=#{task_board.open_count}"
  end
end
```

Strength:

- closer to ActiveAdmin's mental model
- easy to grow with `register :flow`, `register :contract`, `register :agent`
- keeps the app as the top-level scope

Risk:

- `register` may feel generic and less Igniter-native
- can drift toward framework-style global registries

### Variant 3: App Routes Plus Mounts

This variant stays closest to the current implementation while still feeling
DSL-first.

```ruby
Igniter.app :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard

  mount :operator_board, at: "/" do
    web Web.operator_board_mount
    capabilities :screen, :command
    metadata poc: true
  end

  route :events, get: "/events" do
    text "open=#{task_board.open_count}"
  end

  route :resolve_task, post: "/tasks" do
    task_board.resolve(params.fetch("id", ""))
    redirect "/"
  end
end
```

Strength:

- compact app/server wrapper
- clear transport behavior
- easiest first implementation

Risk:

- less elegant than the ActiveAdmin-like ideal
- still asks the user to think in routes too early

### Variant 4: Surface-First With Implicit Routes

This is the most polished target: actions declared inside the surface generate
the command routes, while the clean form still exposes them.

```ruby
Igniter.operator_app :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard

  surface :operator_board, at: "/" do
    title "Operator task board"
    stat :open_tasks, value: -> { task_board.open_count }

    collection :tasks, value: -> { task_board.tasks } do
      row do
        primary(&:title)
        state(&:status)

        action :resolve, on: :member, only_if: :open? do |task|
          task_board.resolve(task.id)
          refresh
        end
      end
    end
  end

  feed :events, at: "/events", as: :text do
    "open=#{task_board.open_count}"
  end
end
```

Strength:

- closest to the desired user experience
- keeps command declaration near the visible affordance
- best for future Human <-> AI Agent operator screens

Risk:

- generated routes must be explainable
- implicit command paths need stable naming and collision rules
- too much magic unless `clean_form` is excellent

## ActiveAdmin-Like Principles For Igniter

- Top-level declarations should read like application inventory.
- Common behavior should have defaults, but defaults must be inspectable.
- Every implicit route/action must be nameable and explainable.
- Service access should feel local inside the app scope.
- Domain words should beat transport words when describing user intent.
- Transport words should remain available when the app crosses a boundary.
- Blocks should accept plain Ruby for escape hatches.
- The compact form must never be the only source of truth.
- The expanded clean form is the contract with agents, tests, and supervisors.

## First Implementable Slice: Hide Configuration And Rack Wiring

After the ActiveAdmin-like north star is explored, the first implementable slice
can still be narrower than the full user-facing UI DSL. Do not touch the page
authoring DSL in `examples/application/interactive_operator/web/operator_board.rb`
until the application-level orientation is clearer.

The first move should hide only the configuration and server wrapping currently
spread across:

- `examples/application/interactive_operator/app.rb`
- `examples/application/interactive_operator/server/rack_app.rb`

This means the developer still writes the current web surface:

```ruby
mount = Web.operator_board_mount
```

But the app and Rack wrapping become compact.

Implementation-slice target shape:

```ruby
module InteractiveOperator
  APP_ROOT = File.expand_path(__dir__)

  def self.build
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
  end
end
```

This is not the ideal final syntax. It is the first safe compression boundary:

```text
current app/server ceremony -> compact app host declaration
```

Not:

```text
current page DSL -> new operator UI DSL
```

### What Moves Under The Hood

From `app.rb`:

- `Igniter::Application.build_kernel`
- `kernel.manifest`
- `kernel.provide`
- `kernel.mount_web`
- `Igniter::Application::Environment.new`
- app wrapper object with `#call`

From `server/rack_app.rb`:

- mount binding
- Rack method/path dispatch
- form body decoding
- text response helper
- redirect response helper
- not-found response helper

### What Stays Explicit

- service names
- service factories
- web mount object
- mount path
- mount capabilities
- command/query routes
- command mutation body
- redirect target

This keeps the example honest. The DSL hides mechanical configuration, not the
application behavior.

### Clean-Form Expansion

The compact declaration must expand to the current explicit shape:

```ruby
board = Services::TaskBoard.new
kernel = Igniter::Application.build_kernel
kernel.manifest(:interactive_operator, root: APP_ROOT, env: :test)
kernel.provide(:task_board, -> { board })

mount = Web.operator_board_mount
kernel.mount_web(:operator_board, mount, at: "/", capabilities: %i[screen command], metadata: { poc: true })

environment = Igniter::Application::Environment.new(profile: kernel.finalize)
rack_app = Server::RackApp.new(environment: environment, mount: mount)
```

And the generated Rack app must still behave like:

```ruby
case [request_method, path]
in ["GET", "/"]
  bound_mount.rack_app.call(env)
in ["GET", "/events"]
  text_response(...)
in ["POST", "/tasks"]
  params = decode_form_body(env)
  ...
else
  not_found
end
```

### Why This Is The Best First Slice

- It targets the ceremony the customer called out most directly.
- It leaves the existing `igniter-web` DSL untouched.
- It does not require deciding the final operator UI vocabulary.
- It creates reusable infrastructure for future DSLs and REPL clean-form
  expansion.
- It can be tested by comparing the behavior of the generated Rack app against
  the current `Server::RackApp`.

### Suggested Supervisor Decision For First Slice

Accept a narrow track for configuration/server wrapping only.

Potential track name:

```text
Application Rack Host DSL Track
```

Track boundary:

- package or example-local helper may hide app/server ceremony
- no new user UI DSL
- no changes to `web/operator_board.rb`
- no production server
- no new dependency
- no hidden async, websocket, cluster, auth, database, or job behavior

## Proposal A: Full Application Facade

Provide one top-level authoring facade for the common interactive app case. In
the ActiveAdmin-like orientation, this facade should feel closer to declaring an
application surface than wiring a server.

Example:

```ruby
Igniter.operator_app :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard

  surface :operator_board, at: "/", title: "Operator task board" do
    stat :open_tasks, value: -> { task_board.open_count }

    collection :tasks, value: -> { task_board.tasks } do
      row do
        primary(&:title)
        state(&:status)
        action(:resolve, only_if: ->(task) { task.status == :open })
      end
    end
  end

  action :resolve, member_of: :tasks do |task|
    task_board.resolve(task.id)
    refresh :operator_board
  end

  feed :events, at: "/events", as: :text do
    "open=#{task_board.open_count}"
  end
end
```

What it compresses:

- kernel creation
- manifest registration
- service provider registration
- web mount creation
- mount registration
- environment creation
- mount binding
- simple Rack dispatch
- form/action URL binding

Strength:

- best developer experience
- closest to ActiveAdmin's useful compactness
- easiest to explain in guides
- ideal for demos, examples, and small operator apps

Risk:

- highest chance of becoming a cross-package god object
- may blur ownership between app, web, server, and host layers
- could become hard to support once apps need non-web surfaces or distributed
  placement

Supervisor filter:

- Accept only if the facade compiles to package-owned builders.
- Reject if it requires `igniter-application` to depend directly on
  `igniter-web`.

## Proposal B: Layered DSL Behind The Facade

Keep package-local DSLs separate behind the ActiveAdmin-like facade. The public
orientation may feel like one app declaration, while the implementation expands
into application, web, and host-owned pieces.

Example:

```ruby
application = Igniter::Application.define :interactive_operator, root: __dir__, env: :test do
  service :task_board, Services::TaskBoard
end

surface = Igniter::Web.surface(:operator_board, at: "/") do
  root title: "Operator task board" do
    board = service(:task_board)

    metric :open_tasks, board.open_count

    board.tasks.each do |task|
      card id: task.id, state: task.status do
        h2 task.title
        status task.status
        action :resolve_task, params: { id: task.id } if task.status == :open
      end
    end
  end
end

rack_app = Igniter::Application.rack_host(application) do
  mount surface, at: "/", capabilities: %i[screen command], metadata: { poc: true }

  action :resolve_task, post: "/tasks" do |params|
    task_board.resolve(params.fetch("id"))
    redirect "/"
  end

  query :events, path: "/events" do
    "open=#{service(:task_board).open_count}"
  end
end
```

What it compresses:

- application builder ceremony
- manual mount profile wiring
- manual Rack `case` statement
- manual form action strings

What it preserves:

- `Igniter::Application` owns services and environment
- `Igniter::Web` owns surface rendering
- a Rack adapter owns transport
- each layer can be used without the other layers

Strength:

- best match for current package boundaries
- lower risk than one facade
- easier to implement incrementally
- lets future REPL tooling compose the same parts

Risk:

- slightly more verbose than the dream DSL
- may still feel like three mini DSLs unless guide examples are polished

Supervisor filter:

- This is the recommended base direction.
- Graduate as package-local sugar only after clean-form expansion is specified.

## Proposal C: Example-Local ActiveAdmin-Like Mini DSL

Before adding package API, create an example-local ActiveAdmin-like DSL in
`examples/application/interactive_operator/` and use it to pressure-test the
shape aggressively.

Example:

```ruby
module InteractiveOperator
  App = OperatorApp.define :interactive_operator do
    service :task_board, Services::TaskBoard

    board :tasks, at: "/", service: :task_board do
      title "Operator task board"
      count :open, &:open_count

      item do
        title(&:title)
        status(&:status)
        action :resolve, if: :open?
      end
    end

    feed :events do
      "open=#{task_board.open_count}"
    end
  end
end
```

Strength:

- safest first experiment
- can be thrown away
- maximizes learning about the ideal vocabulary
- reveals which parts are generic and which are just demo-specific
- avoids freezing a public API too early

Risk:

- too domain-specific if promoted directly
- may hide the actual package seams from contributors

Supervisor filter:

- Good as a pre-track experiment.
- Do not promote `board`, `tasks`, or `operator_app` vocabulary into core until
  at least one other app shape validates it.

## Proposal D: REPL/Draft Authoring Mode

Use the compact DSL as a draft language that can preview, explain, and
materialize clean form.

Example:

```ruby
ig.interactive_app :interactive_operator do
  service :task_board, Services::TaskBoard
  surface(:operator_board) { ... }
  action(:resolve) { ... }
end

ig.preview :interactive_operator
ig.explain :interactive_operator
ig.clean_form :interactive_operator
ig.write_files :interactive_operator, dry_run: true
```

Strength:

- aligns with the DSL/REPL research track
- useful for humans and agents
- creates an explicit bridge from compact form to files
- supports "pre-development" without hidden mutation

Risk:

- requires a stable intermediate representation
- could expand scope into generators, live reload, and server control too soon

Supervisor filter:

- Keep this as research until package-local DSL sugar exists.
- First artifact should be read-only `explain` or `clean_form`, not live
  mutation.

## Recommended Path

Use the ActiveAdmin-like variants as the north star for application-level
authoring. The strongest orientation is Variant 4: surface-first with implicit
routes, backed by excellent clean-form expansion.

Adopt the first implementable slice only after the north star is understood. It
is narrower than Proposal B: hide only application configuration and Rack host
wrapping while leaving the current web surface DSL untouched.

Keep Proposal B as the broader architectural direction, with Proposal C as a
possible safe experiment later and Proposal D as the future authoring
interface.

Do not start with Proposal A as a public API. It is the right kind of
north-star experience, but it should be assembled from lower-level
package-owned DSLs after the seams are proven.

The intended progression:

1. Preserve the current explicit POC as the clean form.
2. Explore the ActiveAdmin-like app-level vocabulary hard enough to find the
   ideal developer-facing orientation.
3. Hide app/server configuration ceremony behind a compact Rack host
   declaration.
4. Add clean-form expansion/explain output for that app/server declaration.
5. Extract repeated generic concepts into package-local DSL helpers.
6. Only later commit to user-facing UI DSL vocabulary.
7. Later expose a top-level `operator_app` or `interactive_app` facade if the
   composition proves stable.

## Candidate Package Ownership

`igniter-application` may own:

- compact app profile definition
- service registration sugar
- manifest defaults
- environment creation helpers
- mount declarations as abstract capabilities

`igniter-web` may own:

- surface/page/screen DSL
- action binding inside rendered UI
- semantic web components
- mount binding to `MountContext`

Rack or host adapter may own:

- `GET`/`POST` dispatch
- form param decoding
- redirect/text/html response helpers
- conversion from app profile + mounts + commands to a Rack app

No package should own all three layers permanently.

## Clean-Form Expansion Requirement

Any compact DSL must be able to expand to something equivalent to:

```ruby
board = Services::TaskBoard.new

kernel = Igniter::Application.build_kernel
kernel.manifest(:interactive_operator, root: APP_ROOT, env: :test)
kernel.provide(:task_board, -> { board })

mount = Web.operator_board_mount
kernel.mount_web(:operator_board, mount, at: "/", capabilities: %i[screen command], metadata: { poc: true })

environment = Igniter::Application::Environment.new(profile: kernel.finalize)
rack_app = Server::RackApp.new(environment: environment, mount: mount)
```

This matters because agents, tests, docs, and supervisors need the boring form
for review.

## Acceptance Criteria For A First Track

- Current `interactive_operator` behavior can be expressed with less ceremony.
- The document keeps an explicit ActiveAdmin-like north star for app-level
  authoring.
- The POC can still be read as app/service/web/server seams.
- `GET /`, `GET /events`, and `POST /tasks` remain explicit in the expanded
  form.
- `web/operator_board.rb` remains unchanged in the first iteration.
- The first iteration hides `app.rb` and `server/rack_app.rb` ceremony only.
- No new production dependency is introduced.
- No hidden server, database, auth, job system, websocket, or cluster behavior
  appears.
- The compact DSL can produce an explain/clean-form report.
- `igniter-application` does not take a direct dependency on `igniter-web`.

## Open Questions For Supervisor

- Should the first accepted work be docs-only, or an example-local mini DSL?
- Which ActiveAdmin-like vocabulary is the best north star: `operator_app`,
  `application/register`, `app/routes`, or `surface-first`?
- Should command/query routing live in `igniter-application`, `igniter-web`, or
  a small Rack host adapter?
- Should `screen`, `command`, and `query` become shared interaction vocabulary,
  or stay package-local for now?
- How much of ActiveAdmin's compactness should Igniter borrow without becoming
  Rails/resource/CRUD-first?
- What is the smallest "clean-form expansion" artifact that helps both humans
  and AI agents?

## Handoff Request

```text
[Research Horizon / Codex]
Track: docs/research-horizon/interactive-operator-dsl-proposals.md
Status: proposal / needs supervisor filter
Changed:
- Added DSL proposals for compacting examples/application/interactive_operator.
Core idea:
- Push the app-level authoring target toward an ActiveAdmin-like north star.
- Keep Igniter application-first, not Rails/resource/CRUD-first.
- Use clean-form expansion to make implicit routes/actions inspectable.
Recommended graduation:
- Supervisor should review the north-star vocabulary, then consider a narrow
  Application Rack Host DSL Track as the first implementation slice.
Risks:
- Hidden cross-package coupling, premature public API, unclear server ownership,
  and copying ActiveAdmin's domain assumptions instead of only its ergonomics.
Needs:
- [Architect Supervisor / Codex] accept / reject / defer / narrow.
```

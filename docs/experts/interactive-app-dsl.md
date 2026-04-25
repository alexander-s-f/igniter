# Interactive Agent App DSL — Proposal

Date: 2026-04-25.
Author: external expert review.
Target: `igniter-application` + `igniter-web` + `igniter-agents`.

---

## 1. Design Principles

These principles are derived from studying Igniter's existing architecture and
the ActiveAdmin/Arbre DSL style the project owner prefers.

**Principle 1 — Declare the application, not the plumbing.**
The top-level DSL should read as application inventory. Services, agents,
surfaces, flows. Not kernel creation, manifest registration, environment
wrapping, and Rack dispatch.

**Principle 2 — Domain words beat transport words.**
`surface`, `flow`, `chat`, `stat`, `action` rather than `controller`,
`route`, `middleware`, `handler`, `endpoint`.

**Principle 3 — Blocks all the way down.**
Every declaration accepts a block for customization. No hash-heavy option
signatures. Composition by nesting, not by parameter accumulation.

**Principle 4 — Services feel local inside the app scope.**
Inside any block in the app, `tasks` calls the task service. No `app.service(:tasks).call`. The context is implicit.

**Principle 5 — Agents are peers, not add-ons.**
An agent is declared at the same level as a service or surface. It has a name.
It can be referenced as `agent(:coordinator)` from anywhere in the app.

**Principle 6 — Every compact form expands to boring Ruby.**
Any `Igniter.interactive_app` block must be able to produce the equivalent
explicit package-level declarations. This is not optional — it is the contract
with tests, agents, and human reviewers.

**Principle 7 — Strong defaults, all defaults inspectable.**
If an action generates a route, the route is named and can be queried.
If a surface has an implicit refresh endpoint, it is documented.
No implicit behavior that cannot be printed out.

**Principle 8 — Minimum required surface, maximum optional depth.**
A minimal app surface with no custom DSL at all should be a valid starting
point. The DSL adds power, it does not require ceremony.

---

## 2. Top-Level DSL Reference

### 2.1 `Igniter.interactive_app`

The root declaration. Returns a compiled app object that responds to `rack_app`
and can be handed to Rack.

```ruby
App = Igniter.interactive_app :app_name, root: __dir__, env: :production do
  # service, agent, surface, flow, endpoint declarations
end

# config.ru
run App.rack_app
```

Options:

| Option | Type | Default | Purpose |
|--------|------|---------|---------|
| `root:` | String | `__dir__` | App root for asset/config resolution |
| `env:` | Symbol | `:production` | `:test`, `:development`, `:production` |
| `name:` | Symbol | (first arg) | Override app name |

---

### 2.2 `service`

Registers a stateful service available throughout the app scope.

```ruby
service :tasks,    Services::TaskManager
service :sessions, Services::SessionStore
service :users,    Services::UserStore

# With factory block
service :tasks do
  Services::TaskManager.new(capacity: 1000)
end
```

Inside any DSL block within the app, the service is accessible by its name:

```ruby
# Inside surface, flow, agent, endpoint blocks:
tasks.all
sessions.active_count
users.find(id)
```

---

### 2.3 `agent`

Declares a proactive agent actor available in the app.

```ruby
agent :coordinator, Agents::Coordinator

# With configuration block
agent :coordinator, Agents::Coordinator do
  wakeup every: 30                           # wake every 30 seconds
  wakeup every: 300, if: :has_critical?     # conditional wakeup
  tools  SearchTool, PlanTool, CreateTaskTool
  channel :primary                           # output channel binding
end
```

Agent DSL inside the declaration block:

| Keyword | Purpose |
|---------|---------|
| `wakeup every: N` | Schedule periodic wakeup in seconds |
| `wakeup every: N, if: callable` | Conditional periodic wakeup |
| `tools *classes` | Register tool classes with the agent |
| `channel :name` | Bind agent output to a named channel |

Agents are referenced in other DSL blocks as `agent(:name)`:

```ruby
action :ask_agent do |task|
  agent(:coordinator).cast(:assign, task_id: task.id)
end
```

---

### 2.4 `surface`

Declares a web-rendered operator surface at a given path.

```ruby
surface :workspace, at: "/"
surface :detail,    at: "/tasks/:id"
surface :settings,  at: "/settings"

# Inline definition
surface :workspace, at: "/" do
  title "Workspace"
  subtitle "Interactive operator view"

  zone :header do ... end
  zone :main   do ... end
  zone :footer do ... end
end

# Reference to extracted definition
surface :workspace, at: "/", definition: Surfaces::WorkspaceSurface
```

Navigation from actions:

```ruby
redirect surface(:workspace)
redirect surface(:detail, id: task.id)
refresh :workspace          # re-render the named surface in place
```

---

### 2.5 `zone`

Layout region within a surface. Composes to a `ViewZone` Arbre component.

```ruby
zone :header
zone :main,    layout: :columns
zone :sidebar, layout: :stack
zone :footer

zone :main, layout: :columns do
  # collection, chat, stat, arbitrary Arbre blocks
  collection :tasks, value: -> { tasks.all } do ... end
  chat :thread, with: :coordinator
end
```

Layout options: `:stack` (default), `:columns`, `:grid`, `:split`.

---

### 2.6 `stat`

A live metric display in a zone header or dashboard.

```ruby
stat :pending,      label: "Pending tasks",    value: -> { tasks.pending_count }
stat :active_agent, label: "AI Status",        value: -> { agent(:coordinator).status_label }
stat :sessions,     label: "Active sessions",  value: -> { sessions.active_count }

# With color coding
stat :critical, label: "Critical", value: -> { tasks.critical_count },
               color: -> (v) { v > 0 ? :red : :green }
```

---

### 2.7 `collection`

A list of items from a service, with row-level display and actions.

```ruby
collection :tasks, value: -> { tasks.all } do
  # Empty state message
  empty "No tasks yet."

  # Row definition
  row do
    primary(&:title)                              # main display text
    secondary(&:description)                      # supporting text
    badge(:priority, &:priority)                  # colored badge
    state(&:status)                               # status indicator

    # Member actions
    action :complete, label: "Done", if: -> (t) { t.status == :pending } do |task|
      tasks.complete(task.id)
      refresh :workspace
    end

    action :analyze, label: "Ask AI" do |task|
      agent(:coordinator).cast(:analyze, task_id: task.id)
      notify "Agent is analyzing this task"
    end

    action :view_detail, label: "Details", navigate: :detail    # navigates to surface
  end
end
```

Row display keywords:

| Keyword | Purpose |
|---------|---------|
| `primary(&:method)` | Main item display text |
| `secondary(&:method)` | Secondary supporting text |
| `badge(:name, &:method)` | Colored badge (enum display) |
| `state(&:method)` | Status indicator with semantic colors |
| `action :name, ...` | Member-level action button |

Action options:

| Option | Type | Purpose |
|--------|------|---------|
| `label:` | String | Button text |
| `if:` | Proc/Symbol | Visibility condition |
| `navigate:` | Symbol | Navigate to named surface instead of block |
| `method:` | Symbol | HTTP method, default `:post` |

Action block receives the collection item. Available in block: all services,
`redirect`, `refresh`, `notify`, `agent(:name)`.

---

### 2.8 `chat`

An AI conversation area bound to a named agent.

```ruby
chat :thread, with: :coordinator do
  placeholder "Ask about your tasks..."
  streaming true                                    # stream partial tokens
  history   true                                    # show conversation history
  max_turns 50                                      # cap history display

  context -> { tasks.pending.first(5) }             # inject context into each message

  # Custom action buttons beside the chat input
  actions do
    action :clear, label: "Clear history"
    action :export, label: "Export transcript"
  end
end
```

Chat options:

| Option | Default | Purpose |
|--------|---------|---------|
| `with:` | required | Named agent to talk to |
| `streaming:` | `true` | Stream partial tokens |
| `history:` | `true` | Display conversation history |
| `placeholder:` | `"Message..."` | Input placeholder text |
| `context:` | `nil` | Proc injected as context on each message |
| `max_turns:` | `100` | Max history turns to display |

---

### 2.9 `flow`

A wizard-style sequential interaction. Declares named steps with user input
collection and a terminal action.

```ruby
flow :new_task, at: "/tasks/new" do
  title "Create New Task"

  step :details do
    title "Task Details"
    ask :title,       "What needs to be done?",  required: true
    ask :priority,    "Priority?",               type: :choice,
        options: { "Low" => :low, "Medium" => :medium, "High" => :high }
    ask :description, "Notes?",                  type: :textarea, required: false
  end

  step :ai_setup do
    title "AI Assistance"
    ask :ai_mode, "How should AI help?", type: :choice, options: {
      "Plan automatically"  => :auto,
      "Available on-demand" => :manual,
      "No AI"               => :none
    }
  end

  step :confirm do
    title "Review & Create"
    summary -> (answers) { "Task: #{answers[:title]} · #{answers[:priority]}" }

    on :submit do |answers|
      task = tasks.create!(**answers.slice(:title, :priority, :description))
      agent(:coordinator).cast(:plan, task_id: task.id) if answers[:ai_mode] == :auto
      redirect surface(:workspace)
    end
  end
end
```

`flow` generates:
- One surface per step with the ask fields rendered
- A progress indicator across steps
- Back/Next navigation
- A final step with a configurable submit action

---

### 2.10 `step` (inside `flow`)

A single wizard step.

```ruby
step :step_name do
  title "Step Title"
  subtitle "Optional supporting text"

  ask :field_name, "Question?", type: :text      # default
  ask :field_name, "Question?", type: :textarea
  ask :field_name, "Question?", type: :choice, options: { "Label" => :value }
  ask :field_name, "Question?", type: :multi,   options: %w[a b c]
  ask :field_name, "Question?", type: :toggle,  label: "Enable feature"
  ask :field_name, "Question?", type: :date
  ask :field_name, "Question?", required: false

  # Optional: agent-assisted suggestion for this step
  suggest with: :coordinator, context: -> { tasks.pending.map(&:title) }
end
```

`suggest` adds an "AI suggest" button that calls the named agent and fills the
ask fields with suggested values. The user reviews and accepts.

---

### 2.11 `endpoint`

An HTTP endpoint for queries, SSE feeds, or webhook receivers.

```ruby
# Simple text query
endpoint :status, at: "/status" do
  "pending=#{tasks.pending_count}"
end

# SSE feed
endpoint :events, at: "/events", format: :sse do
  on :connect do
    emit :snapshot, { pending: tasks.pending_count, total: tasks.all.size }
  end

  on :tick, every: 5 do
    emit :update, { pending: tasks.pending_count, agent: agent(:coordinator).status_label }
  end
end

# Webhook receiver
endpoint :agent_callback, at: "/webhooks/agent", method: :post do |params|
  agent(:coordinator).deliver(params[:event], params[:payload])
  { ok: true }
end
```

---

### 2.12 `action` (top-level, in `flow step`)

A named mutation that can be referenced by collection actions.

```ruby
# Top-level named action (referenced in collection rows)
action :resolve_task do |params|
  tasks.resolve(params.fetch(:id))
  redirect surface(:workspace)
end

# Inside flow step confirm block
on :submit do |answers|
  tasks.create!(**answers)
  redirect surface(:workspace)
end
```

---

## 3. Full Example App

A complete interactive agent application with task management, proactive AI
coordinator, and onboarding wizard. Single-file compact form.

```ruby
# app.rb
module TaskAssistant
  App = Igniter.interactive_app :task_assistant, root: __dir__ do

    # ── Services ────────────────────────────────────────────────────────────
    service :tasks,    Services::TaskManager
    service :sessions, Services::SessionManager

    # ── Agents ──────────────────────────────────────────────────────────────
    agent :coordinator, Agents::Coordinator do
      wakeup every: 60, if: -> { tasks.has_pending? }
      tools  SearchTool, PlanTool, CreateTaskTool
    end

    # ── Surfaces ─────────────────────────────────────────────────────────────
    surface :workspace, at: "/" do
      title "Task Assistant"
      subtitle "AI-powered work coordination"

      zone :header do
        stat :pending,  label: "Pending",    value: -> { tasks.pending_count }
        stat :active,   label: "In Progress", value: -> { tasks.active_count }
        stat :ai_state, label: "AI",          value: -> { agent(:coordinator).status_label }
      end

      zone :main, layout: :columns do
        collection :task_list, value: -> { tasks.all } do
          empty "No tasks yet — create one to get started."

          row do
            primary(&:title)
            secondary(&:description)
            badge(:priority, &:priority)
            state(&:status)

            action :complete, label: "Done",
                              if: -> (t) { t.status == :pending } do |task|
              tasks.complete(task.id)
              refresh :workspace
            end

            action :plan, label: "Plan with AI",
                          if: -> (t) { t.status == :pending } do |task|
              agent(:coordinator).cast(:plan, task_id: task.id)
              notify "Coordinator is planning this task"
            end

            action :archive, label: "Archive",
                             if: -> (t) { t.status == :completed } do |task|
              tasks.archive(task.id)
              refresh :workspace
            end
          end
        end

        chat :ai_thread, with: :coordinator do
          placeholder "Ask about your tasks, request plans, delegate work..."
          streaming true
          context -> { tasks.pending.first(5) }

          actions do
            action :clear,  label: "Clear"
            action :export, label: "Export"
          end
        end
      end

      zone :footer do
        endpoint :status_inline, format: :text do
          "#{tasks.pending_count} pending · #{tasks.completed_count} done"
        end
      end
    end

    # ── Flows ────────────────────────────────────────────────────────────────
    flow :new_task, at: "/tasks/new" do
      title "New Task"

      step :details do
        title "What needs to be done?"
        ask :title,       "Task name",    required: true
        ask :priority,    "Priority",     type: :choice, options: {
          "Low"      => :low,
          "Medium"   => :medium,
          "High"     => :high,
          "Critical" => :critical
        }
        ask :description, "Notes",        type: :textarea, required: false

        suggest with: :coordinator,
                prompt: "Suggest task details based on:",
                context: -> { tasks.pending.map(&:title).first(5) }
      end

      step :ai_mode do
        title "AI Assistance"
        ask :ai_assist, "How should AI help with this task?", type: :choice, options: {
          "Plan and track automatically" => :auto,
          "Available when I ask"         => :manual,
          "No AI for this task"          => :none
        }
      end

      step :confirm do
        title "Create Task"
        summary -> (a) { "#{a[:title]} · #{a[:priority]} priority" }

        on :submit do |answers|
          task = tasks.create!(**answers.slice(:title, :priority, :description))

          if answers[:ai_assist] == :auto
            agent(:coordinator).cast(:plan, task_id: task.id)
          end

          redirect surface(:workspace)
        end
      end
    end

    # ── Endpoints ────────────────────────────────────────────────────────────
    endpoint :events, at: "/events", format: :sse do
      on :connect do
        emit :snapshot, {
          pending:   tasks.pending_count,
          active:    tasks.active_count,
          completed: tasks.completed_count,
          agent:     agent(:coordinator).status_label
        }
      end

      on :tick, every: 5 do
        emit :update, {
          pending: tasks.pending_count,
          agent:   agent(:coordinator).status_label
        }
      end
    end

  end
end

# config.ru
# require_relative "app"
# run TaskAssistant::App.rack_app
```

---

## 4. Clean-Form Expansion

Every compact declaration must expand to explicit package-level code. This
ensures agents, tests, and reviewers can always inspect the real wiring.

The compact form:

```ruby
App = Igniter.interactive_app :task_assistant do
  service :tasks, Services::TaskManager
  agent   :coordinator, Agents::Coordinator
  surface :workspace, at: "/"
end
```

Expands to approximately:

```ruby
# igniter-application layer
kernel = Igniter::Application.build_kernel
kernel.manifest(:task_assistant, root: APP_ROOT, env: :production)
kernel.provide(:tasks, -> { Services::TaskManager.new })

# igniter-agents layer
agent_registry = Igniter::Agents::Registry.new
agent_registry.register(:coordinator, Agents::Coordinator)

# igniter-web layer
workspace_mount = Igniter::Web.mount(:workspace,
  path: "/",
  application: Igniter::Web.application { root title: "Workspace" do ... end }
)
kernel.mount_web(:workspace, workspace_mount, at: "/", capabilities: %i[screen command])

# host / rack adapter layer
environment = Igniter::Application::Environment.new(
  profile: kernel.finalize,
  agents: agent_registry.finalize
)
rack_app = Igniter::Application::RackHost.new(environment: environment, mounts: [workspace_mount])
```

The compact form is sugar. The expanded form is the truth. The DSL must always
be able to produce the expanded form on demand:

```ruby
App.clean_form          # print the expanded Ruby to stdout
App.explain             # print a table of services, agents, surfaces, routes
App.rack_app            # returns the Rack app
App.environment         # returns the Application::Environment
App.agent(:coordinator) # returns the agent process reference
```

---

## 5. In-Block Context

Inside any DSL block (`surface`, `flow`, `step`, `collection`, `action`,
`endpoint`), the following are available without qualification:

| Name | Returns |
|------|---------|
| `<service_name>` | The registered service instance (e.g., `tasks`) |
| `agent(:name)` | The named agent process reference |
| `surface(:name)` | The named surface (for redirect/refresh) |
| `redirect surface(:x)` | Navigate to a surface |
| `refresh :surface_name` | Re-render a surface in place |
| `notify "message"` | Flash a notification to the current user |
| `params` | Decoded request parameters (in action/endpoint blocks) |
| `session` | Current user session |
| `flow` | Current flow answers (in step blocks) |

---

## 6. Escape Hatches

The DSL should never trap the developer. Every layer has an escape hatch:

**Surface escape**: Drop to raw Arbre in any `zone`:

```ruby
zone :main do
  # Plain Arbre — full igniter-web component vocabulary
  div class: "custom-layout" do
    h1 tasks.pending_count.to_s
    tasks.pending.each do |task|
      view_action_node label: task.title, href: "/tasks/#{task.id}"
    end
  end
end
```

**Collection escape**: Use `raw_items` for full control:

```ruby
collection :custom, raw: true do |ctx|
  board = ctx.service(:tasks)
  board.grouped_by_priority.each do |priority, items|
    h2 priority.to_s.capitalize
    items.each { |item| para item.title }
  end
end
```

**Agent escape**: Use `agent.ref` to access the raw `Igniter::AI::Agent`
process reference:

```ruby
action :debug_agent do
  raw_ref = agent(:coordinator).ref
  state   = raw_ref.state
  text "Agent state: #{state.inspect}"
end
```

**Route escape**: Declare explicit routes bypassing the surface DSL:

```ruby
route get: "/health" do
  { status: :ok, pending: tasks.pending_count }.to_json
end

route post: "/webhooks/agent" do |params|
  agent(:coordinator).deliver_raw(params)
  [200, {}, ["ok"]]
end
```

---

## 7. The Agent Class Pattern

Agent classes receive a `context` object inside their handlers that exposes the
app's services. This is the bridge between the agent actor and the application
state.

```ruby
class Agents::Coordinator < Igniter::AI::Agent
  provider :anthropic
  model "claude-sonnet-4-6"

  system_prompt "You are a proactive work coordinator."

  tool PlanTool
  tool CreateSubtaskTool

  # Triggered by wakeup scheduler
  on :wakeup do
    pending = context.tasks.pending.first(5)
    next if pending.empty?

    proposal = complete(
      "Review these pending tasks and suggest the most urgent one to tackle: " \
      "#{pending.map { |t| "- #{t.title} (#{t.priority})" }.join("\n")}"
    )

    broadcast :suggestion, content: proposal, task_ids: pending.map(&:id)
  end

  # Triggered by action :plan from a surface
  on :plan do |task_id:|
    task = context.tasks.find(task_id)
    next unless task

    plan = complete(
      "Create a step-by-step action plan for: #{task.title}\n" \
      "Priority: #{task.priority}\n" \
      "Context: #{task.description}"
    )

    context.tasks.attach_plan(task_id, plan)
    broadcast :plan_ready, task_id: task_id, plan: plan
  end

  # Handles chat messages from the chat zone
  on :message do |content:|
    context_summary = context.tasks.pending.first(3).map { |t|
      "- #{t.title} (#{t.priority})"
    }.join("\n")

    complete("#{content}\n\nCurrent pending tasks:\n#{context_summary}")
  end
end
```

---

## 8. Component Vocabulary Alignment

The DSL keywords map to existing `igniter-web` component classes:

| DSL keyword | `igniter-web` component |
|-------------|------------------------|
| `zone` | `ViewZone` |
| `chat` | `ViewChatNode` |
| `stat` | (new: `ViewStatNode`) |
| `collection` + `row` | `ViewNode` with `ViewActionNode` |
| `action` | `ViewActionNode` |
| `ask` | `ViewAskNode` |
| `flow` + `step` | (new: `ViewFlowScreen` + `ViewStepNode`) |
| `stream` | `ViewStreamNode` |
| `compare` | `ViewCompareNode` |

The existing `view_screen`, `view_zone`, `view_chat_node`, `view_ask_node`,
`view_action_node`, `view_stream_node`, `view_compare_node` are already present
in `igniter-web`. The DSL is a compact authoring surface over these components,
not a replacement for them.

---

## 9. Package Boundary Compliance

The `Igniter.interactive_app` facade must not create direct package coupling:

```
igniter-application
  → owns: Igniter.interactive_app entry point
  → owns: service declaration + registry
  → owns: Rack host adapter + route dispatch
  → delegates surface/flow/zone/chat to igniter-web
  → delegates agent/wakeup/tools to igniter-agents
  → does NOT import igniter-web or igniter-agents directly
  → uses a registration protocol (capability tokens / mount descriptors)

igniter-web
  → owns: surface, zone, collection, chat, flow, step, ask DSL
  → produces: Igniter::Web::Mount objects
  → does NOT know about services or agents by name
  → receives context via MountContext (existing pattern)

igniter-agents
  → owns: agent declaration, wakeup scheduler, tools registration
  → produces: Igniter::Agents::AgentProfile objects
  → does NOT know about web surfaces by name
  → communicates via broadcast / channel / mailbox

Rack host adapter (igniter-application or thin gem)
  → owns: GET/POST/SSE dispatch
  → owns: form decoding, redirect, text, JSON response helpers
  → owns: mount binding from app profile + web mounts + agent refs
```

---

## 10. Recommended Implementation Order

**Phase 1 — Hide ceremony (no new DSL)**
- Implement `Igniter::Application.rack_app` that wraps `build_kernel` +
  `Environment` + Rack dispatch in one declaration.
- Add `mount_web`, `get`, `post`, `text`, `redirect` to the rack_app block.
- Target: compress `app.rb` + `server/rack_app.rb` into one block.

**Phase 2 — Surface-first (igniter-web)**
- Add `surface` as a first-class declaration in `Igniter::Web`.
- Add `zone`, `collection`, `stat`, `chat` as surface-level DSL keywords.
- Add `action` inside `collection row` with implicit route generation.
- Target: compress `web/operator_board.rb` into `surface :workspace, at: "/" do`.

**Phase 3 — Flow (igniter-web)**
- Add `flow`, `step`, `ask`, `suggest`, `summary`, `on :submit` DSL.
- Generate step surfaces and step navigation automatically.
- Target: wizard authoring in 20-30 lines.

**Phase 4 — Proactive agent wakeup (igniter-agents)**
- Add `wakeup every: N, if: condition` to agent declarations.
- Add `broadcast :event, payload` to agent handlers.
- Add `channel :name` for output binding.
- Target: proactive agent that pushes to surface without manual wiring.

**Phase 5 — Facade (igniter-application)**
- Introduce `Igniter.interactive_app` as a top-level facade.
- Wire service, agent, surface, flow, endpoint declarations together.
- Add `clean_form`, `explain`, `rack_app`, `environment` to the returned object.
- Target: entire app declarable in one file.

---

## 11. Open Questions

1. **Where does `flow` live?** In `igniter-web` (it renders steps) or in a
   separate `igniter-flows` package? The session semantics suggest tight
   coupling with agent sessions.

2. **How does `broadcast` reach the surface?** SSE? WebSocket? Shared memory?
   The answer depends on the hosting topology (single process vs cluster).

3. **Is `context` in agent handlers an app-provided object or an Igniter
   standard API?** If the app injects it, agents are reusable across apps.
   If Igniter provides it, agents are tighter to the framework.

4. **What is the clean session model for `flow` steps?** A flow is a
   long-lived interaction. Its state needs to survive across requests. Where
   does the flow state live? The session service? The agent session? A
   dedicated `Igniter::Web::FlowSession`?

5. **When does `suggest` call the agent?** On page load? On button press?
   The UX matters as much as the implementation.

6. **How does `refresh :workspace` work across requests?** A POST that
   responds with a redirect (303) is the simplest. Turbo/HTMX partial
   replacement is better UX but adds a frontend dependency.

These questions should be resolved during Phase 2-3 prototyping, not in
advance. The DSL vocabulary proposed here is deliberately implementation-neutral
at the transport and session layer.

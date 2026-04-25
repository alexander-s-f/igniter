# Expert Review — Igniter As An Interactive Agent Platform

Date: 2026-04-25.
Perspective: distributed systems architect / interactive agent platform designer.
Subject: Igniter gem and its evolution toward a rich interactive agent environment.

---

## 1. Executive Summary

Igniter is one of the more architecturally disciplined Ruby projects I have
reviewed. The contracts-as-validated-dependency-graphs model is mature, the
compile-time vs runtime boundary is sharp, and the package split shows genuine
attention to coupling.

The project is at a pivot point. The original value proposition — "validated
dependency graphs with caching and invalidation" — is proven and complete. The
emerging value proposition — "a platform for rich interactive agent virtual
environments" — is real and exciting, but the authoring experience has not yet
caught up with the ambition.

The primitives exist. Agents, surfaces, flows, sessions, LLM executors, tool
registries, cluster mesh, distributed contracts — all present. What is missing
is a **first-class authoring surface for interactive agent applications** that
makes the relationship between these primitives obvious and the ceremony
invisible.

This document is a full assessment with concrete recommendations.

---

## 2. What Igniter Is (From The Outside)

An outside expert sees four layers:

**Layer 1 — Contracts (mature)**
A validated dependency graph engine. Inputs flow through compute nodes to
outputs. Compile-time graph validation. Runtime lazy resolution with TTL
caching, coalescing, and incremental dataflow. This is the kernel. It works
well and is internally consistent.

**Layer 2 — Application (partial)**
A hosting layer for contracts and services. Application kernel, environment,
service registry, web mounts, capsule model. The concepts are right but the
authoring experience requires wiring five files manually.

**Layer 3 — Agents (emerging)**
An actor runtime for long-lived proactive processes. Agent lifecycle, session
semantics, mailboxes, supervision, tool loops, LLM executors. The model is
solid on paper. The developer-facing integration is still in flight.

**Layer 4 — Cluster (research)**
Distributed mesh, gossip, Raft consensus, cluster routing. Present but not the
immediate user-facing concern.

The user of Igniter today interacts primarily with Layer 1 and partially with
Layer 2. The vision described in the research horizon is about making Layer 3
the primary interaction point — with Layer 1 as the execution engine underneath
and Layer 2 as the hosting glue.

---

## 3. The Core Vision: Interactive Agent Virtual Environment

The emerging use case is not chat. It is not request-response. It is:

> Long-lived proactive agents inhabiting a rich interactive environment where
> human and AI work together on tasks, workflows, and goals across time.

This is a qualitatively different application shape from:
- A chatbot (stateless Q&A)
- A RAG pipeline (retrieve + generate)
- A workflow engine (sequential steps)
- An admin dashboard (CRUD + data tables)

It is closer to:
- An intelligent operating environment (like an IDE, but for work)
- A proactive digital colleague (initiates, tracks, proposes, acts)
- A wizard-plus-agent hybrid (structured guidance + open-ended AI)
- A live observation surface (real-time state, agent status, task progress)

Igniter's architecture is genuinely well-suited for this. The contract graph
provides the reactive backbone. The agent runtime provides the proactive actors.
The web surface provides the rendering layer. The cluster mesh provides
distribution. The missing piece is the **authoring glue** that makes defining
one of these environments feel like a creative act, not an infrastructure task.

---

## 4. Architectural Strengths

**4.1 Compile-Time Validation**
The compile-before-execute contract model is one of Igniter's strongest
properties. For an interactive agent environment where sessions are long-lived
and state is persistent, knowing at boot time that the graph is valid is
extremely valuable. This should be preserved at all cost.

**4.2 Explicit Dependency Declarations**
`depends_on:`, `with:`, `input:`, `output:` — everything is declared. For
agent applications where data provenance and traceability matter, this is
essential. Agents need to know what they depend on.

**4.3 Session Semantics**
The agent session model (lifecycle_state, phase, continuable?, terminal?,
routed?) maps well onto interactive workflows. A wizard step, an agent
consultation, a long-running background task — all of these are session states.

**4.4 The Arbre Surface**
`igniter-web` using Arbre is the right choice. Arbre's block-based composition
is readable, Ruby-native, and testable. The current operator board example
proves it works end-to-end. The component vocabulary (view_screen, view_zone,
view_chat_node, view_stream_node, view_ask_node, view_action_node) maps
directly to interactive agent UI primitives.

**4.5 Zero Production Dependencies**
This discipline means Igniter can be embedded anywhere. For interactive agent
apps that may run in unusual hosting environments (edge, embedded in larger
systems), this matters.

**4.6 The Research Horizon Process**
The research horizon / supervisor gate / track graduation workflow is unusual
and disciplined. It prevents premature commitment to half-proven ideas. The
interaction kernel report, agent handoff protocol, and runtime observatory
graph are excellent examples of "think before coding" discipline.

---

## 5. Friction Points And Gaps

**5.1 Five Files For A Hello World Agent App**
The current interactive operator example requires:
- `services/task_board.rb` — state
- `web/operator_board.rb` — surface
- `server/rack_app.rb` — routing
- `app.rb` — assembly
- `config.ru` — boot

For a production app this split is correct and clean. As the first authoring
experience, it is a significant barrier. The research horizon document on
interactive operator DSL proposals already identifies this clearly.

**5.2 No First-Class Flow/Wizard Primitive**
Wizards are one of the highest-value interactive patterns for human-AI
collaboration. A multi-step structured interaction where the agent guides the
user through a decision is fundamentally different from open-ended chat.
Igniter has the building blocks (await, session, agent tool loop) but no
declarative surface for authoring a flow.

**5.3 Agent-Surface Coupling Is Manual**
Today, to connect an agent to a web surface, a developer must manually wire:
- the agent process
- the web mount
- the session query surface
- the operator API endpoint

There is no declarative "this surface talks to this agent" binding.

**5.4 No Reactive Push To Browser**
The current POC uses polling (GET /events). For a rich interactive environment,
server-sent events or WebSocket push are essential. An agent completing a task
should immediately update the operator surface. Today this requires manual
plumbing.

**5.5 DSL Vocabulary Is Not Yet Settled**
The research horizon has multiple competing proposals (operator_app, application,
board, surface, collection, etc.) without a clear winner. This is appropriate
for research but needs resolution before the authoring experience can stabilize.

**5.6 The "Proactive Agent" Story Is Incomplete**
An agent that wakes up, decides to do something, and pushes a result to the
surface — this is the core of the interactive agent vision. The actor runtime
supports it. The application layer does not yet have a compact way to declare
a proactive agent with its wakeup conditions, observation scope, and output
binding to a surface.

---

## 6. The Recommended Mental Model

The interactive agent application should be understood as:

```
Interactive App
├── Services          (durable state, owned by the app)
├── Contracts         (computation graphs, owned by igniter-contracts)
├── Agents            (proactive actors, owned by igniter-agents)
│   ├── lifecycle     (when to wake, when to sleep, what triggers)
│   ├── tools         (what agents can do)
│   └── output        (where results go)
└── Surfaces          (what users see, owned by igniter-web)
    ├── zones          (layout regions)
    ├── collections    (data lists with actions)
    ├── chat           (agent conversation areas)
    ├── stats          (live metrics)
    └── flows          (wizard sequences)
```

The application is the composition. Everything else is a named piece within it.

---

## 7. Proposed Application Skeleton

Below is the recommended file structure for a real Igniter interactive agent
application. It works at two scales: compact (single file) and expanded (full
directory structure). The authoring experience starts compact and expands as
the app grows.

### 7.1 Compact Form (Small App)

Everything in one file. Suitable for examples, prototypes, and small tools.

```
my_app/
├── app.rb          # Entire app in one Igniter.interactive_app block
└── config.ru       # Two-line Rack boot
```

### 7.2 Expanded Form (Real App)

```
my_app/
├── app.rb                          # Top-level app declaration (thin)
├── config.ru                       # Rack boot
│
├── agents/
│   ├── base_agent.rb               # Shared agent capabilities and tools
│   ├── coordinator_agent.rb        # Primary proactive orchestrator
│   └── specialist_agent.rb         # Domain-specific agent
│
├── contracts/
│   ├── task_workflow.rb             # Business logic as igniter contracts
│   ├── onboarding.rb
│   └── reporting.rb
│
├── services/
│   ├── task_service.rb              # Mutable state containers
│   ├── session_service.rb
│   └── user_service.rb
│
├── surfaces/
│   ├── dashboard_surface.rb         # Primary operator view
│   ├── detail_surface.rb            # Item detail view
│   └── settings_surface.rb
│
└── flows/
    ├── onboarding_flow.rb           # Wizard/step sequences
    └── new_project_flow.rb
```

### 7.3 The app.rb Pattern

The top-level `app.rb` should read as **application inventory**, not as
infrastructure wiring. It declares what exists and how the pieces relate:

```ruby
# app.rb — compact single-file app
module MyApp
  App = Igniter.interactive_app :my_app do
    service :tasks,    Services::TaskService
    service :sessions, Services::SessionService

    agent :coordinator, Agents::Coordinator

    surface :workspace, at: "/"
    flow    :new_task,  at: "/tasks/new"

    endpoint :stream, at: "/stream", format: :sse
  end
end
```

Or expanded with inline definitions:

```ruby
# app.rb — with inline surface definitions
module MyApp
  App = Igniter.interactive_app :my_app do
    service :tasks,    Services::TaskService
    service :sessions, Services::SessionService

    agent :coordinator, Agents::Coordinator do
      wakeup every: 30, if: -> { tasks.has_pending? }
      tools  SearchTool, PlanTool, CreateTaskTool
    end

    surface :workspace, at: "/" do
      # ... surface DSL inline
    end

    flow :new_task, at: "/tasks/new" do
      # ... flow DSL inline
    end

    endpoint :stream, at: "/stream", format: :sse do
      # ... SSE stream DSL inline
    end
  end
end
```

And the two-line config.ru:

```ruby
# config.ru
require_relative "app"
run MyApp::App.rack_app
```

### 7.4 The Agent Pattern

```ruby
# agents/coordinator_agent.rb
class Agents::Coordinator < Igniter::AI::Agent
  provider :anthropic
  model "claude-sonnet-4-6"

  system_prompt <<~PROMPT
    You are a proactive work coordinator. You monitor tasks, identify bottlenecks,
    and help users make progress. You have access to task management tools.
  PROMPT

  tool SearchTool
  tool CreateTaskTool
  tool AssignTaskTool
  tool PlanTool

  on :assign do |task_id:|
    task = context.tasks.find(task_id)
    plan = complete("Plan work breakdown for: #{task.title}")
    context.tasks.attach_plan(task_id, plan)
  end

  on :wakeup do
    pending = context.tasks.pending.first(5)
    return if pending.empty?

    proposal = complete("Suggest next action for: #{pending.map(&:title).join(", ")}")
    broadcast :suggestion, content: proposal, tasks: pending.map(&:id)
  end
end
```

### 7.5 The Service Pattern

```ruby
# services/task_service.rb
module Services
  class TaskService
    Task = Struct.new(:id, :title, :priority, :status, :plan, keyword_init: true)

    def initialize
      @tasks = []
      @sequence = 0
    end

    def all          = @tasks.map(&:dup)
    def pending      = all.select { |t| t.status == :pending }
    def pending_count = pending.size
    def has_pending? = pending_count > 0

    def create!(title:, priority: :medium, **_rest)
      @sequence += 1
      task = Task.new(id: "task-#{@sequence}", title: title, priority: priority, status: :pending)
      @tasks << task
      task.dup
    end

    def complete(id)
      task = @tasks.find { |t| t.id == id.to_s }
      return false unless task
      task.status = :completed
      true
    end

    def attach_plan(id, plan_text)
      task = @tasks.find { |t| t.id == id.to_s }
      return false unless task
      task.plan = plan_text
      true
    end
  end
end
```

### 7.6 The Surface Pattern

```ruby
# surfaces/dashboard_surface.rb
module Surfaces
  def self.workspace_surface
    Igniter::Web.surface(:workspace, at: "/") do
      title "Workspace"

      zone :header do
        stat :pending, label: "Pending", value: -> { tasks.pending_count }
        stat :total,   label: "Total",   value: -> { tasks.all.size }
        stat :agent,   label: "AI Status", value: -> { coordinator.status_label }
      end

      zone :main, layout: :columns do
        collection :tasks, value: -> { tasks.all } do
          row do
            primary(&:title)
            badge(:priority, &:priority)
            state(&:status)

            action :complete, label: "Done", if: -> (t) { t.status == :pending } do |task|
              tasks.complete(task.id)
              refresh :workspace
            end

            action :ask_agent, label: "Analyze" do |task|
              coordinator.cast(:assign, task_id: task.id)
              notify "Agent is analyzing this task"
            end
          end
        end

        chat :ai_thread, with: :coordinator do
          placeholder "Ask about your tasks..."
          streaming true
          context -> { tasks.pending.first(3) }
        end
      end
    end
  end
end
```

### 7.7 The Flow Pattern

```ruby
# flows/new_task_flow.rb
module Flows
  def self.new_task_flow
    Igniter::Web.flow(:new_task, at: "/tasks/new") do
      title "New Task"

      step :details do
        title "Task Details"
        ask :title,       "What needs to be done?",   required: true
        ask :priority,    "Priority?",                 type: :choice,
            options: { "Low" => :low, "Medium" => :medium, "High" => :high, "Critical" => :critical }
        ask :description, "Context or notes?",         type: :textarea, required: false
      end

      step :agent_mode do
        title "AI Assistance"
        ask :ai_assist, "How should AI help?", type: :choice, options: {
          "Auto-plan immediately"  => :auto,
          "Available on-demand"    => :manual,
          "No AI for this task"    => :none
        }
      end

      step :confirm do
        title "Review"
        summary -> (answers) { "Creating: #{answers[:title]} (#{answers[:priority]})" }

        on :submit do |answers|
          task = tasks.create!(**answers.slice(:title, :priority, :description))
          coordinator.cast(:assign, task_id: task.id) if answers[:ai_assist] == :auto
          redirect surface(:workspace)
        end
      end
    end
  end
end
```

---

## 8. Package Ownership Map

The interactive agent app authoring surface should not create new
cross-package coupling. Each layer owns its piece:

| Concept | Package | DSL Owner |
|---------|---------|-----------|
| `service` declaration | `igniter-application` | `Igniter::Application::DSL` |
| `agent` declaration | `igniter-agents` | `Igniter::Agents::DSL` |
| `surface`, `zone`, `collection`, `chat`, `stat` | `igniter-web` | `Igniter::Web::DSL` |
| `flow`, `step`, `ask` | `igniter-web` | `Igniter::Web::FlowDSL` |
| `endpoint`, `feed` | Rack host adapter | `Igniter::Application::RackHost` |
| `Igniter.interactive_app` facade | `igniter-application` | delegating to above |

The facade (`Igniter.interactive_app`) lives in `igniter-application` and
composes the other packages via delegation. It does not own the DSLs it
exposes — it delegates to the package that owns each piece.

---

## 9. Key Recommendations

**9.1 Accept The "Application Rack Host DSL" Track (narrow)**
The research horizon proposal to hide app/server ceremony behind a compact
`Igniter::Application.rack_app` declaration is the right first slice. It does
not touch the web surface DSL, does not create new cross-package coupling, and
can be tested by comparing behavior against the current explicit form.

**9.2 Introduce `Igniter.interactive_app` As A Facade**
After the narrow slice proves out, promote the facade. The facade should
delegate surface definitions to `igniter-web`, agent declarations to
`igniter-agents`, and service registration to `igniter-application`. It should
compile to the same explicit clean form.

**9.3 Add A `flow` Primitive To `igniter-web`**
Wizard/step flows are one of the highest-value interaction patterns for
human-AI collaboration. The `flow` + `step` + `ask` vocabulary maps cleanly
onto the existing session and agent session model. This should be a first-class
DSL in `igniter-web`.

**9.4 Add `chat` Zone To `igniter-web`**
A chat zone that binds to a named agent is the single most important component
for interactive agent surfaces. It should support streaming, context injection,
and action callbacks from the agent side.

**9.5 Add Proactive Agent Wakeup DSL**
An agent declaration should be able to declare its wakeup conditions
(`wakeup every: N, if: condition`) and its output binding to the surface
(`broadcast :event, payload`). This closes the loop between the agent actor
runtime and the web surface.

**9.6 Add SSE Feed Support**
Server-sent events from agents and services to the browser should be a
first-class primitive. The `endpoint :name, format: :sse` + `emit :event` DSL
is readable and implementable with Rack chunked responses.

**9.7 Build One Real Reference App**
The most valuable next artifact is not a new framework feature — it is a
real interactive agent application built in Igniter that:
- Has at least one proactive agent
- Has at least one wizard flow
- Has a live-updating surface
- Has at least one LLM-powered tool loop

This reference app should be the target that pulls the DSL into existence.
The companion/examples application already described in the product track is
the right candidate.

---

## 10. Strategic Diagnosis

Igniter is in an unusual and valuable position. It has:
1. A mature execution kernel (contracts)
2. A coherent application hosting model
3. A working actor runtime
4. A rendering layer with the right primitives
5. A research process that prevents premature commitment

What it lacks is the **authoring surface** that makes all of this feel like
one coherent platform for building interactive agent environments.

The research horizon already identifies this gap. The interactive operator DSL
proposals document is particularly lucid. The recommendations there (Variant 4
surface-first with implicit routes, Proposal B layered DSL) align with this
external assessment.

The strategic move is:
1. Build the narrow Application Rack Host DSL (hide ceremony without new magic)
2. Add `flow` + `chat` to `igniter-web` as first-class surfaces
3. Add proactive agent wakeup declaration to `igniter-agents`
4. Compose these into `Igniter.interactive_app` facade
5. Build the reference app that validates the composition

The DSL details are documented separately in `interactive-app-dsl.md`.

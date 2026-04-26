# Igniter — Strategic Expert Report

Date: 2026-04-26.
Perspective: expert in distributed agent systems, enterprise architecture, and AI-native platforms.
Subject: Igniter strategic analysis — current state, unique position, path to significance.

---

## 1. Visionary Perspective

### 1.1 The Paradigm Shift Igniter Can Own

We are at an inflection point in software development. Not because LLMs arrived —
but because **the shape of the application itself is changing**.

The classical enterprise application is a request/response machine: a request comes
in, business logic executes, a response goes back. Everything is synchronous,
atomic, and lives for under a second. Rails was the perfect tool for that shape.

The new enterprise application is something different. It is:

> Long-lived, proactive, interactive processes where humans and AI agents
> collaborate on tasks that unfold over minutes, hours, or days.

It is an incident-management system where an agent monitors infrastructure and
initiates a conversation with the on-call engineer. It is an onboarding platform
where an agent walks a new employee through a forty-step wizard and can pause for
three days while someone signs a document. It is a compliance workflow where an
agent and a human conduct an audit together, every step logged and verifiable.

**Igniter is the only Ruby framework designed for this new application shape.**

Not Rails — Rails has no agent runtime, no long-lived sessions, no capsule supply
chain. Not an LLM wrapper — those have no contracts, no compile-time validation,
no enterprise-grade delivery guarantees. Igniter occupies a unique position.

The question is not whether the world needs this kind of tool. It clearly does.
The question is **whether Igniter will be the one to claim that position first
and convincingly.**

### 1.2 What "Significant Enterprise Project" Actually Means

Significant does not mean popular. Significant means:

1. **Unique niche**: a domain where no worthy alternative exists
2. **Trust**: enterprise buys what it believes in — audit trails, explicit
   contracts, refusal-first design, receipt chains
3. **Productivity**: developers must be able to build things that are painful to
   build without Igniter
4. **Reference customers**: one compelling case study is worth more than a hundred
   GitHub stars

Igniter already has the architectural foundation for #1. Capsule Transfer lays
the groundwork for #2. The authoring experience is not yet at the level of #3.
#4 has not started.

---

## 2. Idea, Model, Amplification

### 2.1 The Igniter Core Is a Rare Thing

Contracts as validated dependency graphs are not just a technical feature.
This is **a different way of thinking about business logic**.

In most frameworks, business logic lives as procedural code: do A, then B, then C.
Dependencies are ignored until a production incident reveals them. Igniter says:
declare the dependency graph first. The compiler validates it before anything runs.
The runtime executes only what is needed, with caching and invalidation built in.

This is not "yet another way to write business logic." This is **compile-time
safety for business rules** — something that did not exist in the Ruby ecosystem
before.

```
Contracts Kernel
├── Compile-time: graph validated before execution
├── Runtime: lazy resolution, only necessary nodes
├── Cache: TTL + coalescing + fingerprinting
└── Zero production deps: embeds anywhere
```

### 2.2 Three Levels of Value Proposition

Igniter operates at three independent levels, and this is a strength:

**Level 1: Contracts Kernel (embed mode)**
Embeds into any Ruby project. No dependencies. Validated dependency graphs for
business logic. The value: predictability and debuggability. The buyer: the
developer who is tired of "why did this compute incorrectly."

**Level 2: Application Platform (agent-native apps)**
A full runtime for interactive agent applications. The capsule model, the Ignite
lifecycle, web surfaces, proactive agents. The value: build sophisticated
human-AI applications without endless glue code. The buyer: the team building
a SaaS product with AI assistants.

**Level 3: Enterprise Supply Chain (capsule transfer)**
Verifiable, auditable, refusal-first delivery of applications between hosts.
Receipt chain, activation evidence, compliance gates. The value: enterprise-grade
deployment under agent supervision. The buyer: a CTO or DevOps lead in a
regulated industry.

Three levels, three independent entry points. A developer starts with Level 1.
A company grows into Level 2. An enterprise demands Level 3.

### 2.3 Amplification Through Agent-as-First-Class-Citizen

The central idea that must run through all of Igniter:

> An agent is not an API call. An agent is a participant in the system with the
> same standing as a user or a service.

This means:
- An agent can initiate a conversation (proactive wakeup)
- An agent can request structured input (pending input)
- An agent can wait (await in distributed contracts)
- An agent can be verified (activation evidence)
- An agent can be delivered (capsule transfer)

No other Ruby framework thinks about agents in these terms. This is a genuine
competitive advantage.

---

## 3. Perspective Development

### 3.1 Where Igniter Stands Today — an Honest Map

```
MATURE (production-ready, impressive):
├── Contracts kernel — DSL, compile, runtime, cache, coalescing
├── Diagnostics — text/markdown/structured formatters
├── Extensions — saga, differential, provenance, invariants
└── Transfer Chain — 14 steps, end-to-end verified

SOLID (working, needs polish):
├── AI/LLM/Tool/Skill system — canonical Igniter::AI::* namespace
├── Actor system — Agent/Supervisor/Registry/StreamLoop
├── Server/Mesh — static/dynamic/gossip, Prometheus SD, K8s probes
└── Capsule Activation — dry-run + commit-readiness verified

EMERGING (POC-level, exciting but incomplete):
├── Interactive web surfaces — igniter-web, Arbre, POC board accepted
├── Ignite lifecycle — bootstrap/join/detach/re-ignite skeleton
├── Flow/Session model — FlowSessionSnapshot, PendingInput landed
└── Application::Kernel/Profile/Environment — prototype exists

DESIGN PHASE (docs-only, not yet implemented):
├── Activation Evidence & Receipt (current active track)
├── Activation Commit (Phase 3, blocked until evidence shapes defined)
└── Enterprise Orchestration (Phase 6, vision only)
```

### 3.2 Three Critical Gaps

**Gap #1: Developer Experience**

Today, a hello-world interactive application requires five files, an understanding
of four packages, and thirty minutes of documentation reading. This is not
acceptable for adoption.

The goal: one file, one `Igniter.interactive_app` block, two lines in `config.ru`.
The architecture makes this possible. What is missing is an authoring facade on
top of the already-correct primitives.

**Gap #2: Showcase / Reference Application**

Igniter has no publicly available, impressive example that can be shown to a
prospective user with the words "look, this is what it does."

`examples/companion` is the right candidate. But it must be not a stub but a
genuine working application: a proactive agent, a wizard flow, live updates,
and LLM integration. This is not an additional feature — it is a **marketing
artifact**.

**Gap #3: The Enterprise Story Is Unfinished**

Capsule Transfer is ready. Activation review is ready. But there is no document
that speaks directly to the enterprise buyer: "here is how Igniter solves your
compliance, audit, and agent-supervised deployment problem." Phase 6 (Enterprise
Orchestration) remains seven lines in a roadmap.

### 3.3 Trajectory to Significance

```
2026 Q2: Foundation Complete
├── Evidence & Receipt track closed
├── Activation Commit (Phase 3) opened and scoped
└── interactive_app facade — POC shipped

2026 Q3: Showcase Moment
├── examples/companion — full reference application
├── Igniter.interactive_app public API stable
├── SSE/WebSocket push (first class)
└── Enterprise Orchestration vision document

2026 Q4: Enterprise Credibility
├── Capsule Transfer — Phase 4 (activation receipt)
├── First real adoption case — companion/home-lab → production
├── Compliance story documented
└── MCP Adapter package (AI tooling integration)

2027: Meaningful Position
├── Capsule marketplace concept
├── Multi-tenant capsule delivery
└── Agent-supervised compliance gates (regulatory)
```

---

## 4. Recommendations

### 4.1 PRIORITY #1: Make `Igniter.interactive_app` Real

This is the highest-priority technical decision. Not because it is technically
difficult — but because without it the project remains invisible to potential
users.

What is needed:
```ruby
# This is what a developer should write
App = Igniter.interactive_app :my_app do
  service :tasks, Services::TaskService

  agent :coordinator, Agents::Coordinator do
    wakeup every: 60, if: -> { tasks.has_pending? }
  end

  surface :workspace, at: "/"
  endpoint :stream, at: "/stream", format: :sse
end

# And in config.ru:
run App.rack_app
```

This facade is already outlined in `expert-review.md`. The primitives already
exist. Only a thin delegation layer is missing.

Acceptance criterion: `examples/companion/app.rb` fits on one screen.

### 4.2 PRIORITY #2: `examples/companion` as a Real Application

`examples/companion` must become the flagship reference application. Not a smoke
test, not a stub — a working, impressive application:

- A proactive agent (monitors tasks, initiates dialogue)
- A wizard flow (multi-step structured interaction)
- Live updates (SSE push, not polling)
- An LLM-powered tool loop (real calls to Anthropic or OpenAI)
- Capsule packaging and transfer demonstration

This must be the answer to the question: "Can you show Igniter in action?" —
"Yes. Run `ruby examples/companion/app.rb`."

Without this artifact there is no adoption. Without adoption there is no
significance.

### 4.3 PRIORITY #3: SSE/WebSocket as First Class, Not an Afterthought

The current interactive POC uses polling (GET /events). This is not acceptable
for production. When a proactive agent completes a task, the user must see it
immediately — not after a five-second polling interval.

The recommended model:
```ruby
endpoint :stream, at: "/stream", format: :sse do
  emit :task_created, from: :tasks
  emit :agent_message, from: :coordinator
  emit :suggestion, from: :coordinator
end
```

Rack chunked response with Arbre rendering on the client side is achievable
without external dependencies. This is the critical missing piece for a genuinely
"live" feel.

### 4.4 PRIORITY #4: Enterprise Vision Document

A dedicated document is needed — or a concise landing-page version — that answers
the enterprise buyer's core question:

"Why Igniter, rather than Rails + Sidekiq + custom agents + CI/CD?"

The answer exists, but it is scattered across fifty documents:

- **Validated delivery**: capsule transfer with receipt chain — not a git push,
  not a docker pull, but a verifiable chain of custody
- **Compliance-ready**: activation evidence, refusal-first design, all operations
  through an explicit adapter with an idempotency key
- **Agent-supervised**: agents participate in delivery as reviewers, not merely
  as executors
- **Zero prod deps**: embeds in any enterprise environment without vendor lock-in
- **Audit trail**: transfer receipt + activation receipt = two independent
  lifecycle witnesses

This narrative needs to be written once, and written well.

### 4.5 PRIORITY #5: Stop Stretching Development Across Endless Design Tracks

The current process — research, supervisor gate, track opened, docs-only design,
then implementation — is correct and disciplined. But there is a real risk:
too much design phase, too few shipped features.

The specific problem: the interactive web POC stalled at "repeatability synthesis."
That is good work. But where is the next implementation slice? Where is SSE?
Where is the `flow` primitive?

Recommendation: every completed design track must produce at least one
implementation slice within **two weeks**. If it does not, the question must
be asked: "What were we designing this for?"

### 4.6 PRIORITY #6: Choose and Lock the Public Namespace

The documentation uses several competing terms for the same concepts:
`surface` / `board` / `operator` / `screen` — all appear. `flow` / `wizard`
/ `composition` — all appear.

Before v1 this is tolerable. But stable documentation is a prerequisite for
adoption. A decision on key public API terms must be made and committed to:

| Concept | Final term |
|---------|-----------|
| Root DSL | `Igniter.interactive_app` |
| User-facing screen | `surface` |
| Long-lived process | `flow` |
| Agent interaction | `chat` |
| Structured input | `ask` |
| User command | `action` |
| Real-time stream | `stream` |

---

## 5. Insights and Ideas

### 5.1 "Rails for Agent Applications" Is the Right Pitch — But Incomplete

"Rails for agent applications" is an understandable positioning, and it is right
in spirit. But Rails was powerful not only because of its API. Rails was powerful
because of **conventions that made bad decisions impossible**.

Igniter must do the same. Examples of Rails-like decision-making on behalf of the
developer:

- By default, capsule transfer — not a bare git push. Not because it is a
  "feature," but because it is **the right way**.
- By default, activation — with an evidence packet and a receipt. Not because it
  is "enterprise," but because **that is what a serious tool should do**.
- By default, sessions are long-lived and durable. Not because of "distributed
  systems," but because **that is how modern applications work**.

Conventions over Configuration. That is precisely what made Rails a success story.

### 5.2 The Contracts Compiler as the Project's Hidden Secret

Compile-time validation of dependency graphs is technically difficult to
overstate. It is what makes Igniter a quality gate for business logic.

But this compiler need not be used only for contracts. Capsule dependency graphs?
The same compiler. Flow session graphs? The same compiler. Agent tool dependency
graphs — where agent A depends on agent B? The same compiler.

**Idea**: "Universal Graph Compiler" — one compiler for all DAG structures in
Igniter. This is not additional work; it is recognizing what already exists.
The marketing angle: "All of Igniter is validated dependency graphs at every
layer."

### 5.3 Agent-as-Reviewer — an Unexploited Differentiator

In Capsule Transfer, agents in future phases will act not only as executors
(delivering files) but as **reviewers** — verifying activation evidence, checking
the adapter capability map, signing off on the commit.

This pattern can be extended across all of Igniter:

- **Contracts**: an agent-reviewer can verify the graph before it runs
- **Application boot**: an agent checks the provider lifecycle report before the
  app becomes active
- **Deployment**: an agent verifies capsule evidence before the activation commit

The **"Agent-as-Reviewer" pattern** is a uniquely Igniter idea that does not
exist anywhere else. It must become a named, documented pattern.

### 5.4 The "One Process" Test

For every Igniter feature, apply a simple test: can all of this run in **a single
Ruby process**, without a cluster, without Docker, without network dependencies?

If yes — correct. If no — too many dependencies have been introduced.

`ruby examples/companion/app.rb` must launch a complete application — with an
agent, a web surface, and LLM integration — in a single process. That is what
"zero production dependencies" looks like in practice.

### 5.5 Capsule Marketplace as the Long-Term Business Model

The Phase 6 roadmap mentions "internal app marketplaces." This deserves deeper
attention.

Capsule + transfer receipt + activation receipt = **a verifiable artifact that
can be published, discovered, transferred, and installed**. This is an app store
for enterprise Ruby applications.

The analogy: the Shopify App Store, but for agent-native enterprise applications.
Every capsule in the marketplace carries:
- A manifest (what it does, what it requires)
- A transfer history (where it came from)
- An activation receipt (where it is running)
- Compliance evidence (what it has passed through)

This is not speculation — it is Phase 6, and the foundation is being built now.

### 5.6 MCP Adapter as an Immediate Enterprise Bridge

The dev docs already contain `mcp-adapter-package-spec.md`. MCP (Model Context
Protocol) is currently what unifies the AI tooling ecosystem.

The play: if Igniter contracts can be exposed as MCP tools, then any Claude,
GPT, or external agent can call an Igniter contract as a tool. This means:

- Instant integration with the AI tooling ecosystem
- Contracts become "callable business logic" for external agents
- A capsule with an MCP manifest becomes a publishable enterprise toolset

This is a high-priority bridge feature for enterprise adoption.

### 5.7 The Discipline Advantage

One of the most underappreciated advantages of Igniter is **development
discipline**. Refusal-first design. Explicit evidence. Docs-only tracks before
implementation. A supervisor gate before every significant decision.

In a world where AI agents can generate code at indefinite speed, this discipline
is a value, not an overhead. It is what separates "sketches" from "a serious
framework."

This must be part of the public story: **"Igniter was designed with the same
rigor that enterprise systems themselves demand."**

---

## 6. Diagnosis and Final Conclusion

### 6.1 What Is Working

Igniter has the right architectural DNA:
- Compile-time validation (rare in Ruby)
- Refusal-first design (a sign of mature thinking)
- Zero production dependencies (discipline)
- Agent as a first-class participant (differentiation)
- Capsule supply chain (enterprise readiness)

This is not "yet another sketch." This is an architecturally mature project
with the right principles. That is a strong foundation.

### 6.2 What Is Holding Back Growth

**Invisible**: no public showcase. A developer cannot look at this and immediately
understand its value.

**Too spread**: too many open fronts simultaneously. Contracts, Application, Web,
Agents, Cluster, Capsule Transfer, Ignite lifecycle, Credentials, DTO layer, MCP
Adapter — all are in design or early implementation at the same time.

**No "aha moment"**: there is no simple path from "installed the gem" to "I
understand why this exists" in fifteen minutes.

### 6.3 The Path to Significance

**The formula**: one killer showcase + compact authoring DX + completed enterprise
story = Igniter occupies a unique niche that nobody else holds.

Specifically:

1. **`Igniter.interactive_app` facade** — right now, the architecture allows it
2. **`examples/companion` as flagship** — a real working application, not a smoke
   test
3. **SSE push as first class** — table stakes for any interactive application
4. **Enterprise Vision document** — one document that answers the buyer's question
5. **Evidence & Receipt track** — close it; this unblocks Phases 3 through 6

After these five steps, Igniter is no longer "yet another Ruby framework." It is:

> The only Ruby platform for enterprise-grade, agent-native, interactive
> applications with a verifiable supply chain and compile-time validated
> business logic.

No one else occupies this position. The window is open. The question is whether
there will be enough focus and velocity to claim it before the window closes.

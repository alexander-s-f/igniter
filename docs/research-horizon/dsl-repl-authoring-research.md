# DSL And REPL-Like Authoring For Igniter

Status: customer-directed research hypothesis.

Date: 2026-04-25.

Customer: project owner.

This document studies a compact developer-facing DSL and REPL-like workflow for
Igniter in both pre-development and interactive live-development modes.

## Goal

Give application developers a way to work with Igniter that is:

- compact
- expressive
- low-boilerplate
- inspectable
- friendly to pre-development design
- friendly to live interactive development
- suitable for contracts, flows, capsules, operator surfaces, and future agents

The target feeling:

```text
small surface first, promotion path later
```

A developer should be able to sketch a contract, flow, capsule, web surface, or
operator workflow quickly, inspect the generated clean form, then promote it
into explicit files/classes when it stabilizes.

## ActiveAdmin As Reference

ActiveAdmin is a good reference, but not a template to copy blindly.

What is valuable:

- it creates useful admin surfaces with little ceremony
- it gives developers a DSL while producing a business-facing interface
- it provides strong defaults with escape hatches
- it uses Arbre for Ruby-authored views
- it lets small resource declarations grow into custom pages/actions/forms

ActiveAdmin's own stated goals are close to this pattern:

- quickly create good-looking administration interfaces
- build a DSL for developers and an interface for businesses
- allow deep customization

What Igniter should not copy:

- CRUD/resource-first assumptions as the central model
- Rails-only shape as the core runtime assumption
- controller/resource inheritance as the primary interaction vocabulary

Igniter's center is different:

- contracts
- sessions
- flows
- capsules
- operator actions
- streams
- agents
- distributed runtime plans

## Arbre As Reference

Arbre is useful because it keeps views as Ruby objects for longer. That gives:

- composition
- inheritance
- encapsulation
- custom semantic components
- testable object-oriented UI building

This matches Igniter's existing frontend direction:

- Ruby-authored UI
- operator/admin surfaces
- semantic components
- HTML-first with optional progressive JS
- compact DSL over explicit page/context/handler objects

## Existing Igniter Anchors

Igniter already has pieces of this path:

- Human Sugar DSL Doctrine
- contract class DSL
- `Igniter::Contracts.with { ... }`
- `Igniter::Application.blueprint`
- application capsule DSL
- `Igniter::Web.application`
- `root`, `page`, `screen`, `command`, `stream`, `webhook`
- Arbre-backed page/component authoring
- `bin/console` / app console direction
- MCP adapter package for tooling

The next research question is how to unify the authoring experience without
creating a giant framework.

## Two Modes

### 1. Pre-Development Mode

Pre-development means sketching, modeling, and inspecting before committing to
file structure or runtime behavior.

Developer wants to ask:

- what contract shape do I need?
- what inputs/outputs exist?
- what pending interactions exist?
- what capsule imports/exports will be required?
- what operator actions should exist?
- what web surface would expose this?
- what clean form does this DSL expand into?

Output should be:

- read-only report
- generated clean form preview
- suggested files/classes
- warnings and missing decisions
- optional example scaffold plan

No hidden mutation by default.

### 2. Interactive Live-Development Mode

Live-development means working inside a console/REPL with a loaded app/runtime
context.

Developer wants to:

- define or edit a draft contract
- run it with sample inputs
- inspect graph/profile/session state
- start a flow
- resume a flow
- preview a web surface
- query operator state
- inspect capsule readiness
- generate a report or clean form

The important thing: live mode should remain explicit about what is draft,
what is persisted, and what is running.

## REPL-Like Shape

Ruby already has IRB, a standard interactive read-eval-print loop. Igniter
should not replace Ruby's REPL. It should provide a domain context inside it.

Possible command shape:

```bash
bin/igniter console
bin/igniter console --app apps/operator
bin/igniter console --capsule operator
bin/igniter console --profile dev
```

Inside:

```ruby
ig.contract :price_quote do
  input :amount, type: :numeric
  compute :tax, from: :amount do |amount:|
    amount * 0.2
  end
  output :tax
end

ig.run :price_quote, amount: 100
ig.explain :price_quote
ig.clean_form :price_quote
```

For application/capsules:

```ruby
ig.capsule :operator do
  import :incident_runtime, kind: :service
  export :operator_console, kind: :web_surface
end

ig.inspect_capsule :operator
ig.handoff :operator
ig.activation_readiness :operator, host: :local
```

For interaction surfaces:

```ruby
ig.screen :plan_review, intent: :human_decision do
  ask :notes, as: :textarea
  action :approve, run: Contracts::ApprovePlan
  stream :agent_activity
end

ig.surface_manifest :plan_review
ig.flow_from_surface :plan_review
```

## DSL Design Rules

### Sugar Compiles To Clean Form

Every compact DSL must expand to:

- clean Ruby objects
- serializable reports
- explicit package-owned values
- inspectable configuration

A developer should be able to run:

```ruby
ig.expand_last
ig.clean_form
ig.diff_clean_form
```

### Defaults Are Allowed, Hidden Runtime Is Not

Good defaults:

- names from symbols/classes
- default layout profile
- common operator surface shape
- common flow/session metadata
- inferred output readers

Forbidden defaults:

- hidden package loading
- hidden cluster placement
- hidden route activation
- hidden host wiring mutation
- hidden AI provider calls
- hidden execution of contracts from a manifest

### Promotion Path

The DSL should support growth:

```ruby
ig.contract :price_quote do
  input :amount
  output :amount
end
```

can become:

```ruby
class PriceQuote < Igniter::Contract
  define do
    input :amount
    output :amount
  end
end
```

and later:

```ruby
app/contracts/price_quote.rb
spec/igniter/price_quote_spec.rb
```

### Reports Before Mutation

Pre-development commands should prefer:

- plan
- preview
- explain
- validate
- clean form
- handoff
- readiness

over:

- write
- activate
- mount
- boot
- route
- execute remote work

Mutation should be explicit:

```ruby
ig.write_plan(plan)
ig.materialize(plan, commit: true)
```

### REPL Results Should Be Objects

Console commands should return rich objects, not only formatted text.

Good:

```ruby
result = ig.run(:price_quote, amount: 100)
result.to_h
result.output(:tax)
```

Also good:

```ruby
ig.render(result)
ig.markdown(result)
ig.explain(result)
```

## Possible API Layers

### Draft Layer

Ephemeral objects for REPL/pre-development:

- draft contract
- draft screen
- draft capsule
- draft flow
- draft operator lane

They can be inspected and promoted, but are not automatically runtime state.

### Report Layer

Read-only outputs:

- expansion report
- clean form report
- validation report
- capsule report
- surface report
- activation readiness/plan report

### Runtime Layer

Explicit execution:

- run local contract
- start flow
- resume flow
- inspect session
- query operator state

### Materialization Layer

Explicit file writes:

- write contract class
- write capsule layout
- write example
- write spec stub

This should be dry-run-first.

## ActiveAdmin Lesson For Igniter

ActiveAdmin's best lesson:

```text
make common things one block, keep customization reachable
```

For Igniter:

```ruby
Igniter.app :research_ops do
  contract :summarize_case do
    input :notes
    output :summary
  end

  flow :plan_review do
    ask :clarification
    action :approve_plan
    stream :agent_activity
  end

  operator :console do
    surface :plan_review
    lane :manual_review
  end
end
```

But the clean form must remain available:

```ruby
profile = Igniter::Application.build_profile(...)
manifest = profile.manifest
surface = Igniter::Web.surface_manifest(...)
```

## REPL Commands Worth Exploring

```ruby
ig.help
ig.status
ig.profile
ig.packs
ig.contracts
ig.contract(:name)
ig.run(:name, **inputs)
ig.explain(:name)
ig.graph(:name)
ig.clean_form(:name)
ig.expand(dsl_block)
ig.validate(draft)
ig.promote(draft)
ig.preview_surface(:name)
ig.start_flow(:name)
ig.resume_flow(session_id, event:)
ig.sessions
ig.operator_query
ig.capsule(:name)
ig.capsule_report(:name)
ig.handoff_manifest(:name)
ig.activation_readiness(:name)
ig.activation_plan(:name)
```

## Key Research Question

Can Igniter offer one coherent `ig` console object that spans contracts,
application, web, capsules, and operator workflows without violating package
ownership?

Possible answer:

- yes, if `ig` is a facade over explicitly loaded packages
- yes, if unavailable capabilities report "pack not loaded"
- yes, if every operation returns package-owned objects/reports
- no, if `ig` becomes a global mutable runtime that silently loads everything

## Risks

### Giant God DSL

Avoid by keeping each keyword owned by a package and exposing installed
capabilities.

### Hidden Runtime Behavior

Avoid by separating draft, report, runtime, and materialization layers.

### REPL State Confusion

Avoid by making draft state visible:

```ruby
ig.drafts
ig.clear_drafts
ig.persisted?
ig.runtime?
```

### Too Much Magic For Agents

Avoid by keeping clean form first-class and machine-friendly.

### Too Much Ceremony For Humans

Avoid by allowing compact sugar where repeated boilerplate is obvious.

## Recommendation

Treat ActiveAdmin as a strong UX reference for Ruby DSL ergonomics, especially
its developer DSL plus business-facing UI split. Do not copy its CRUD/resource
center.

Recommended next artifact:

- `dsl-repl-authoring-examples.md`

It should compare:

- clean form
- compact DSL
- REPL session
- generated report
- promotion path

Do not implement yet.


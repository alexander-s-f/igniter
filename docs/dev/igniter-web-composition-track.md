# Igniter Web Composition Track

This note defines the composition layer for `igniter-web`.

It builds on:

- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [Igniter Web DSL Sketch](./igniter-web-dsl-sketch.md)

## Status

This is now part of the active `igniter-web` implementation track.

The core idea:

- agents, flows, and developers should describe screen intent
- `igniter-web` should compose that intent into a valid view structure
- rendering should happen after composition, not before it

## Why This Exists

Agent-managed screens need guardrails.

If an agent only receives a catalog of components, it can assemble something
that is technically valid but structurally awkward:

- unrelated panels at the same hierarchy level
- action controls buried inside content
- repeated nested cards
- missing primary user path
- chat, audit, and form surfaces fighting for the same visual role

The composer gives Igniter a screen grammar.

## Layer Model

```text
ScreenSpec
  -> Composer + CompositionPolicy
  -> ViewGraph
  -> Arbre/Page rendering
```

`ScreenSpec`
: Declarative authoring shape. It describes intent, capabilities, data, streams,
actions, and agent affordances.

`Composer`
: Turns a screen spec into an organized graph with zones such as summary, main,
aside, and footer.

`CompositionPolicy`
: Validates the graph and reports missing or suspicious structure.

`ViewGraph`
: A normalized intermediate representation. It should be inspectable,
serializable, testable, and later renderable.

## Intended DSL

```ruby
screen :plan_review, intent: :human_decision do
  title "Plan review"

  show :plan_summary
  show :risk_panel
  compare :current_plan, :proposed_plan

  decide do
    approve with: Contracts::ApprovePlan
    revise with: Contracts::RequestRevision
  end

  chat with: Agents::ProjectLead
  compose with: :decision_workspace
end
```

The developer describes what the screen means.
The composer decides how the pieces fit.

## Initial Implementation Scope

The first implementation should stay intentionally small:

- `Igniter::Web::ScreenSpec`
- `Igniter::Web::Composer`
- `Igniter::Web::CompositionPreset`
- `Igniter::Web::CompositionPolicy`
- `Igniter::Web::CompositionResult`
- `Igniter::Web::CompositionFinding`
- `Igniter::Web::ViewGraph`
- `Igniter::Web::ViewNode`
- `Igniter::Web::ViewGraphRenderer`

Initial composer behavior:

- place screen summary and subject data in `summary`
- place primary content, fields, comparisons, progress, and timelines in `main`
- place chat and agent companion surfaces in `aside`
- place actions in `footer`
- emit findings when the declared intent has no primary path

Initial renderer behavior:

- render a complete Arbre HTML document
- preserve screen, preset, zone, and node identity through `data-ig-*`
  attributes
- delegate screen, zone, and node markup to semantic Arbre components
- specialize common node kinds such as action, chat, stream, ask, and compare
- keep visual output deliberately plain while the component vocabulary matures

## Application Mount Direction

`igniter-web` should provide web-owned mount objects before asking
`igniter-application` for a registry.

Current web-side shape:

- `Igniter::Web::ApplicationWebMount`
- `Igniter::Web::MountContext`
- exposes `name`, `path`, `rack_app`, and `to_h`
- can carry an optional `Igniter::Application::Environment`
- keeps Arbre, page, screen, and component details in `igniter-web`

## Composition Presets

Start with named preset objects. They are policy and layout hints, not hard
themes.

First presets:

- `:decision_workspace`
- `:operator_console`
- `:wizard_operator_surface`
- `:live_process`

Presets should influence placement and validation, but the internal graph should
remain explicit and inspectable.

Initial preset responsibilities:

- zone order
- preferred zones for component kinds
- policy hints such as `requires_action`, `step_first`, or
  `prefers_live_surface`

## Policy Direction

Good policies should catch structural mistakes before rendering.

Examples:

- `:human_decision` screens should include at least one action
- `:collect_input` screens should include at least one input or field
- `:live_process` screens should include a stream, timeline, progress, or chat
- destructive actions should later require confirmation metadata
- agent-facing screens should declare audience or capability constraints

The goal is not to make the first policy exhaustive.
The goal is to create the feedback loop early.

## Agent Tool Direction

Agents should eventually operate through a constrained view tool, not raw HTML.

Example shape:

```ruby
ViewTool.compose(
  intent: :human_decision,
  include: [:plan_diff, :risk_panel, :approve_action, :chat],
  audience: :operator
)
```

The tool should return either:

- a valid `ViewGraph`
- or structured findings with suggestions

That gives agents a repair loop without letting them invent arbitrary UI.

# Schema Rendering Authoring

This guide captures the current public authoring story for `Igniter::Frontend`
schemas.

Use it when you want to define a page as persisted JSON-like data and render it
through `Igniter::SchemaRendering::Renderer`.

## Mental Model

A view schema is:

- a persisted `page`
- with one or more named `actions`
- and a `layout` tree made of supported node types

Today the most useful node families are:

- layout nodes: `stack`, `grid`, `section`, `card`
- content nodes: `heading`, `text`, `notice`
- form nodes: `form`, `fieldset`, `input`, `textarea`, `select`, `checkbox`, `actions`, `submit`

The runtime now treats `notice`, `fieldset`, and `actions` as first-class schema
nodes, so authors can describe semantic blocks directly instead of encoding those
shapes indirectly through lower-level containers.

## Minimal Shape

```ruby
{
  id: "daily-checkin",
  version: 1,
  kind: "page",
  title: "Daily Check-in",
  actions: {
    save_checkin: {
      method: "post",
      path: "/views/daily-checkin/submissions"
    }
  },
  layout: {
    type: "stack",
    children: [
      { type: "heading", level: 1, text: "Daily Check-in" },
      { type: "text", text: "A schema-driven page." },
      {
        type: "form",
        action: "save_checkin",
        children: [
          { type: "input", name: "summary", label: "Summary", required: true },
          {
            type: "actions",
            children: [
              { type: "submit", label: "Save" }
            ]
          }
        ]
      }
    ]
  }
}
```

## Recommended Patterns

### 1. Use `notice` for operator guidance

`notice` is a good fit for:

- framing the task before the form starts
- small coaching prompts
- warnings or reminders

```ruby
{ type: "notice", message: "Keep answers short and concrete.", tone: "info" }
```

### 2. Use `fieldset` for meaningful groups

`fieldset` gives the page a cleaner semantic structure and keeps related inputs
together.

```ruby
{
  type: "fieldset",
  legend: "Session",
  description: "Core session details.",
  children: [
    { type: "input", name: "duration_minutes", label: "Duration", value_type: "integer" },
    { type: "textarea", name: "notes", label: "Notes" }
  ]
}
```

### 3. Use `actions` to group submits

Even with one submit button, `actions` is worth using because it matches the semantic
shape the renderer already understands.

```ruby
{
  type: "actions",
  children: [
    { type: "submit", label: "Save Review" }
  ]
}
```

## Action Styles

Two useful patterns exist today:

### Contract-backed form

Use `type: "contract"` when submission should immediately trigger workflow logic.

```ruby
actions: {
  submit_checkin: {
    type: "contract",
    target: "Companion::Dashboard::TrainingCheckinSubmissionContract",
    method: "post",
    path: "/views/training-checkin/submissions"
  }
}
```

### Lightweight persisted form

If `type` is omitted, the runtime treats it as `store_submission`.

```ruby
actions: {
  save_review: {
    method: "post",
    path: "/views/weekly-review/submissions"
  }
}
```

This is a good default for:

- lightweight surveys
- reflection forms
- MVP admin inputs

## Canonical Examples

The current canonical executable examples live in the schema rendering specs:

- [schema_rendering_runtime_spec.rb](/Users/alex/dev/projects/igniter/spec/igniter/schema_rendering_runtime_spec.rb:1)
- [schema_rendering_page_spec.rb](/Users/alex/dev/projects/igniter/spec/igniter/schema_rendering_page_spec.rb:1)

They cover the current supported authoring styles:

- persisted schemas with validation and patching
- contract-backed submissions
- lightweight stored submissions
- rendering with values, errors, and notices

## Practical Guidance

- Prefer `stack` at the top level unless you already know you want a two-column grid.
- Use `section` for softer grouping and `card` when the block should feel more prominent.
- Keep labels short and task-oriented; put nuance into `description`, `notice`, or muted `text`.
- Use `value_type` only where normalization matters, such as integers, floats, and booleans.
- If a form will likely grow, introduce `fieldset` early instead of waiting for the layout to become messy.

## Current Boundary

The schema runtime is now good at:

- persisted page definitions
- semantic form grouping
- shared rendering through `Igniter::Frontend::Tailwind`
- contract-backed or store-only submissions

It is not yet trying to be:

- a general CMS
- a full survey engine
- a full low-code app builder

# Product Track

This note captures the current applied product direction for Igniter.

The goal is simple: stop proving capabilities only through internal architecture
work and start exercising them through something that feels like a real product.

## Current Recommendation

The strongest near-term applied track is:

- build a small operator-facing assistant product on top of the current app stack
- make it exercise real orchestration, sessions, tools, skills, and operator follow-up
- keep distributed routing and `ignite` as follow-on capabilities, not day-one complexity

In other words:

- first prove Igniter as a useful single-stack product runtime
- then expand it into a multi-app and later multi-node story

That product track now has two distinct consumers:

- public flagship: `examples/companion`
- private downstream adopter: `playgrounds/home-lab`

The intended relationship is:

- `companion` is the public proving ground
- `home-lab` is the private personalized assistant
- useful ideas should usually be proven in `companion` first, then selectively adopted in `home-lab`

## Why This Track

This is the best current consumer because it directly exercises what Igniter is
already unusually strong at:

- validated contract execution
- long-lived `AgentSession` lifecycle
- operator-facing orchestration and follow-up
- tool-loop and skill runtime semantics
- portable app mounting and explicit app-to-app access

It also helps reveal architectural weaknesses honestly:

- if runtime contracts are too vague, the product will feel brittle
- if operator surfaces are too ad hoc, workflows will feel fragmented
- if app boundaries are weak, the stack will become muddy quickly
- if frontend/template failures are opaque, product iteration will slow down fast
- if large Arbre pages cannot be split into partials, product surfaces will become
  harder to evolve than the runtime beneath them

## Recommended Shape

The most useful first product is an `assistant + operator desk` style stack.

Suggested shape:

- `main` app
  - owns the end-user interaction surface
  - owns contracts, agents, tools, and skills for the core assistant workflow
- `operator` or `dashboard` app
  - owns runtime visibility, follow-up handling, approval, and session drill-down
  - consumes explicit APIs from `main` through `provide + access_to + App.interface(...)`

This keeps the product honest:

- one app owns the domain/runtime behavior
- one app owns the operator and observability surface
- cross-app access stays explicit

## Dual-Consumer Loop

### `examples/companion`

`companion` should be treated as the public flagship Igniter app.

Its mission:

- demonstrate Igniter capabilities through real and interesting assistant workflows
- act as an additional integration and product-level test surface
- become a stronger and more compelling assistant product than `OpenClaw`

That means `companion` should not be only a toy demo. It should be where we:

- try bold but reusable ideas
- pressure-test end-user and operator workflows
- expose the best public examples of contracts, agents, tools, skills, routing, and operator follow-up

### `playgrounds/home-lab`

`home-lab` should be treated as a private personalized downstream product.

Its role:

- carry personal workflows and private integrations
- explore personalized assistant behavior that should not live in the public repo
- selectively adopt ideas already proven useful in `companion`

This keeps the relationship healthy:

- public ideas are exercised in the open
- private specialization stays private
- core Igniter only absorbs what proves generally useful

## Security And Credential Bias

For the assistant product track, the current safe bias should stay explicit:

- external provider credentials are node-local by default
- multi-node behavior should prefer routing to a credential-owning node over copying secrets to more nodes
- local cluster simulation must not accidentally normalize shared credentials just because all replicas run from one checkout
- any future cross-node secret propagation should be policy-driven, auditable, and tied to stronger trust/admission semantics

This matters especially for:

- `companion`
- `home-lab`
- future `ignite`-driven cluster bring-up

The current implementation bias should stay aligned with the shared app layer:

- use `Igniter::App::Credentials::Credential`
- use `Igniter::App::Credentials::CredentialPolicy`
- prefer shared policy types such as:
  - `Igniter::App::Credentials::Policies::LocalOnlyPolicy`
  - `Igniter::App::Credentials::Policies::EphemeralLeasePolicy`
- keep product-specific credential behavior as adaptation on top of that shared
  contract, not as a separate ad hoc DTO model

The short version is:

- prove assistant and cluster behavior without assuming secret fan-out as the default convenience path

## Working Cycle

Recommended cycle:

1. develop and pressure-test ideas in `companion`
2. let `companion` reveal what is genuinely reusable
3. selectively port the proven parts into `home-lab` when they are useful there

Practical rule:

- `companion` is a valid place for proactive exploration
- `home-lab` should usually move by explicit pull, not by automatic sync
- if a feature only makes sense for one person's setup, it should probably stay in `home-lab`
- if a feature clarifies or strengthens Igniter itself, it should usually be proven in `companion` first

## First Practical Slice

The first applied slice should stay intentionally small:

1. user asks the assistant to do multi-step work
2. agent enters deferred or interactive flow when needed
3. tool calls and skill execution become visible through operator/runtime surfaces
4. an operator can `reply`, `approve`, `complete`, or `handoff`
5. the user-facing app continues from the same execution-owned truth

That is already enough to pressure-test:

- `AgentInteractionContract`
- `tool_runtime`
- `Skill::RuntimeContract`
- `agent_result_contract`
- `orchestration_action_result`

## Second Slice

Once the first slice feels coherent, expand to a more realistic stack:

- separate domain app from operator/dashboard app more explicitly
- add one real external tool integration
- add at least one approval-required workflow
- add a durable restored execution path, not only live in-memory work

This is where Igniter starts to prove that its contracts and operator runtime are
not only nice abstractions, but actually usable product infrastructure.

## Later Slices

Only after the single-stack product feels real should the track pull in the
more distributed parts:

- routed remote agents
- `ignite`-based bring-up and expansion
- multi-node workers or capability-routed execution

## Immediate UX/Frontend Backlog

Two product-adjacent platform gaps now need to stay explicit while `companion`
grows:

- detailed dev-quality stack traces for frontend/template failures
- first-class Arbre template partials for breaking large pages into reusable sections

These are not cosmetic extras. They are part of keeping the product track
healthy as pages become more stateful, more visual, and more deeply connected to
runtime contracts.

Another adjacent foundation line now matters for product health too:

- move product/runtime contracts away from ad hoc `Hash` DTOs and toward a
  canonical immutable DTO layer with defaults and declared fields
- keep UI-facing transport projections flexible where needed, but avoid letting
  large app/runtime surfaces depend on nil-tolerant hash juggling as the long-term shape

Those are important, but they are not the right first product proof.

## Planning Rule

When the roadmap offers a choice between:

- another internal convergence pass
- or a small applied slice that exercises the same capability in a real product

prefer the applied slice unless the architecture is still clearly unstable.

When the applied track offers a choice between:

- proving an idea in the public flagship
- or implementing it first only in the private project

prefer proving it in `companion` first unless the idea is clearly personal-only.

# Companion

`examples/companion` is the public flagship assistant app for Igniter.

Its job is not only to demonstrate APIs in isolation, but to exercise Igniter
as a real product runtime:

- assistant-facing workflows
- operator-facing follow-up and visibility
- contracts, agents, tools, and skills in one stack
- portable multi-app composition through explicit app boundaries

The current slice is intentionally small, but honest:

- `main` owns the assistant-side API surface
- `dashboard` owns the operator desk
- one shared overview API feeds the operator surface
- one shared note flow proves cross-app persistence and explicit app-to-app access
- one real assistant request flow now opens a durable operator follow-up
- one real operator completion loop now closes that request back into a finished brief

This is the starting point, not the finished vision.

## Bootstrapping

```bash
cd examples/companion
bundle install
ruby bin/demo
bin/console
bin/start
bin/dev
bin/dev-cluster
```

`bin/dev` also writes per-node logs to `var/log/dev/*.log`.
`bin/dev-cluster` starts a local multi-replica cluster simulation from the same
directory by using the `dev-cluster` environment profile.

Then open:

- API status: `http://127.0.0.1:4567/v1/home/status`
- assistant requests API: `http://127.0.0.1:4567/v1/assistant/requests`
- operator desk: `http://127.0.0.1:4567/dashboard`
- assistant lane: `http://127.0.0.1:4567/dashboard/assistant`
- cluster view: `http://127.0.0.1:4567/dashboard/cluster`

## Local Credentials

`Companion` now supports a local gitignored credentials file for external API keys:

1. copy [`/Users/alex/dev/projects/igniter/examples/companion/apps/main/config/credentials.local.example.yml`](/Users/alex/dev/projects/igniter/examples/companion/apps/main/config/credentials.local.example.yml) to `examples/companion/apps/main/config/credentials.local.yml`
2. put your real keys there
3. start `Companion` normally

That file is ignored by git, and `Igniter::App` loads it during app build via
the new credentials loader. By default existing shell env vars still win, so a
locally exported `OPENAI_API_KEY` will not be overwritten accidentally.

The assistant lane now supports a local runtime mode switch:

- `manual` keeps the current operator follow-up flow
- `ollama` tries to auto-draft a briefing locally and falls back to manual if the model is not ready yet
- model-aware prompt profiles now adapt draft posture for lanes like `qwen3`, `qwen2.5-coder`, and `gpt-oss`
- the assistant lane also includes a `Model Lab` for side-by-side comparisons across several local models
- assistant requests are now scenario-aware, with presets like `Technical Rollout`, `Incident Triage`, `Research Synthesis`, and `Executive Update`
- completed briefings now keep the scenario shape alongside the prompt package, so Companion can stay grounded in the kind of work it is doing
- `Incident Triage` now has a first real scenario-specific lane with structured context like affected system, urgency, symptoms, and an operator checklist carried through the request lifecycle
- `Research Synthesis` now has a parallel structured lane with evidence inputs like sources, decision focus, and constraints, so Companion can build decision-ready synthesis briefs instead of generic summaries
- `Technical Rollout` now has its own structured lane with target environment, change scope, verification plan, and rollback plan, so rollout briefs carry real execution gates instead of vague implementation advice
- delivery routing now shows which external channel is currently preferred and whether credentials are actually ready

That gives `Companion` three honest product lanes already:

- incident stabilization
- research-to-decision synthesis
- technical rollout planning

All three lanes now also share a first-class artifact input layer, so requests can carry URLs, files, logs, and notes as explicit evidence instead of hiding everything inside one large text prompt.
- the operator desk can now push notes, orchestration follow-ups, runtime nodes, runtime signals, and snapshot preview data directly into the assistant lane as prefilled evidence
- completed briefings now support reverse operator actions like `Save as Note`, `Promote to Rollout`, and `Re-open as Manual Action`, so assistant output can become the next working slice instead of a dead-end result
- Companion now keeps lightweight evaluation memory from real operator actions, so the assistant lane can surface which scenarios, models, and outcome paths are actually getting used
- completed briefings also support explicit quick feedback like `Useful`, `Too Verbose`, `Too Slow`, and `Wrong Lane`, so evaluation memory is no longer only implicit
- the dashboard now includes a live `Cluster View` with a graph projection over stack nodes, mounted apps, assistant requests, and follow-ups, plus a small in-browser rewind buffer for recent snapshots
- external delivery now supports `simulate` and `live` modes for the selected channel
- credential policy is now first-class in the runtime surface, with a conservative `local_only` default for external API secrets
- prompt packages are now prepared as explicit handoff artifacts for the selected external delivery lane rather than pretending the local model is the final production brain

Current local default bias is `qwen2.5-coder:latest`, because it has shown the
best interactive behavior so far in the Companion model lab.

That makes it safe to point Companion at a model that is still downloading: the
workflow stays usable while runtime readiness catches up.

Local cluster mode also starts:

- replica-1: `http://127.0.0.1:4568/dashboard`
- replica-2: `http://127.0.0.1:4569/dashboard`

## Local Cluster Persistence

`Companion` keeps local cluster persistence separate per node even when all
replicas run from the same repo checkout.

- single-node mode uses `examples/companion/var`
- `bin/dev-cluster` uses `examples/companion/var/dev-cluster/nodes/<node>`
- each node gets its own execution stores and note store
- replicas do not share one SQLite file

That means the local cluster imitation is honest about the default storage
boundary: one node, one local persistence root.

## Current Direction

Use Companion to evolve the public assistant product in thin vertical slices
rather than copying a whole production-shaped system up front.

Good next moves are:

1. richer assistant workflows beyond the first briefing loop
2. stronger operator drill-down and action history inside the desk
3. one useful tool or skill slice that materially improves assistant output quality
4. one restored execution path visible as a first-class product behavior

Only after those feel coherent should Companion pull in deeper distributed
capabilities like routed remote agents or `ignite`-driven expansion.

## Design Rule

Companion should aim to become better and more capable than `OpenClaw`, but it
should do that by making Igniter's strengths tangible:

- explicit runtime contracts
- durable sessions
- operator-visible orchestration
- app portability
- later, trustworthy distributed execution

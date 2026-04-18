# Package Map

This is the current package ownership map for the monorepo.

## Root

Root should stay thin:

- umbrella gem wiring
- load-path/package registration
- top-level onboarding docs
- stack entrypoints that intentionally stay cross-package

## Packages

- `igniter-core` — contract/model/compiler/runtime kernel
- `igniter-ai` — AI runtime pack: providers, executors, skills, transcription, AI agents
- `igniter-sdk` — SDK registry plus generic agents, channels, tools, and data packs
- `igniter-extensions` — public `igniter/extensions/*` activation entrypoints
- `igniter-app` — app runtime/profile, stack scaffolds, generators
- `igniter-server` — HTTP server and transport layer
- `igniter-cluster` — mesh, routing, trust, replication, distributed runtime
- `igniter-rails` — Rails integration surface
- `igniter-frontend` — human-authored web UI surface
- `igniter-schema-rendering` — schema-driven rendering surface

## Placement Heuristics

- Put code in `core` only if it still makes sense in embedded mode.
- Put code in `sdk` if it is reusable and optional.
- Put code in `extensions` if it exists mainly as a public activation/patch entrypoint.
- Put code in `app` if it shapes single-node runtime behavior or scaffold conventions.
- Put code in `server` if it is transport/HTTP hosting.
- Put code in `cluster` if the network is part of the execution model.
- Put package-specific user docs next to the package README.

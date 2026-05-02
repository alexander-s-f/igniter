# Package Map

This is the target ownership map for the new runtime family.

## Root

Root should stay thin:

- umbrella gem wiring
- load-path/package registration
- top-level onboarding docs
- cross-package entrypoints that are intentionally thin

## Runtime Pillars

- `igniter-contracts`
  canonical embedded kernel: DSL, compile/runtime spine, profiles, execution,
  diagnostics, extension seams
- `igniter-extensions`
  packs, language additions, tooling, operational behavior, and domain behavior
  over `igniter-contracts`
- `igniter-application`
  contracts-native local runtime host: config, providers, services, loaders,
  schedulers, host adapters, boot lifecycle
- `igniter-ai`
  provider-neutral AI execution: request/response envelopes, provider clients,
  credentials-aware configuration, fake/live/recorded modes, transcripts,
  usage, errors, and replay seams
- `igniter-agents`
  agent runtime semantics over contracts and AI: agent definitions, runs,
  turns, traces, tool-call evidence, and single-turn assistant execution
- `igniter-hub`
  local capsule catalog discovery and transfer bundle metadata; applications
  still install through `igniter-application` transfer APIs
- `igniter-cluster`
  contracts-native distributed runtime: remote execution, routing, admission,
  placement, peer registry, topology, distributed diagnostics
- `igniter-store`
  experimental contract-native hot fact engine: immutable facts, time-travel,
  access paths, reactive invalidation, retention/compaction, StoreServer
  transport, and future hot/cold sync experiments
- `igniter-companion`
  experimental typed Record/History facade over `igniter-store`; owns
  app-facing Store/History ergonomics and pressure from Companion manifests,
  while avoiding core persistence API promises

## Planned Runtime Packages

- richer agent memory/context, handoff, human gates, contracts-first tool
  execution, and supervisor vocabulary
- stable contract persistence capability may still graduate later through
  `igniter-extensions` / `igniter-application` / future `igniter-persistence`;
  current `igniter-store` and `igniter-companion` remain pressure packages, not
  final public persistence API

## Current Supporting Packages

- `igniter-mcp-adapter`
  MCP adapter over contracts-native tooling and host integration
- `igniter-web`
  supporting web/UI package; active, but not a runtime pillar

## Supporting Lanes

- `legacy`
  reference-only implementation material until deletion
- adapter packages
  MCP, HTTP, IDE, transport, protocol, and external integration surfaces
- framework/plugin packages
  Rails and other host-specific integrations
- frontend packages
  human-authored UI surfaces

## Placement Heuristics

- Put code in `igniter-contracts` if it defines canonical embedded graph
  semantics, service execution protocols, or kernel extension seams.
- Put code in `igniter-extensions` if it is optional behavior, tooling, or
  domain vocabulary over the contracts kernel. Language-changing DSL packs such
  as observable branching, formulas, scaling, and scoring primitives also live
  here.
- Put code in `igniter-application` if it is about local runtime hosting,
  providers, services, boot, config, loading, or scheduling.
- Put early contract-persistence experiments in `igniter-extensions` when they
  add optional contract DSL/semantics, or in `igniter-application` when they
  are app-host/back-end boundary behavior. Do not promote a separate package
  until the target plan has repeated implementation evidence.
- Put code in `igniter-cluster` if the network is part of the execution model.
- Put immutable fact log, time-travel, access path, retention, StoreServer,
  sync-hub, and transport-backend experiments in `igniter-store`; do not put
  contract business logic execution there.
- Put app-facing generated Record/History classes, receipts, manifest-to-store
  facades, and Companion pressure adapters in `igniter-companion`; do not put
  core DSL promotion there.
- Put provider clients, model envelopes, transcripts, usage, and replay seams in
  `igniter-ai`.
- Put agent loops, run state, tool policy, memory/context, handoff, and human
  gates in `igniter-agents`.
- Put capsule catalog discovery and bundle metadata in `igniter-hub`; keep
  verification, intake, apply, receipts, and installed-capsule registries in
  `igniter-application`.
- Put transport and protocol work in adapter packages unless it is truly a
  cluster semantic concern.
- Touch legacy packages only for reference, parity, migration, or retirement
  cleanup.
- Put package-specific user docs next to the package README.

## Explicit Non-Goals

- do not treat `server` as a primary runtime pillar
- do not treat stack orchestration as the default local app model
- do not keep growing legacy packages as if they were still the target

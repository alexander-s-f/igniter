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
  packs, tooling, operational behavior, and domain behavior over
  `igniter-contracts`
- `igniter-application`
  contracts-native local runtime host: config, providers, services, loaders,
  schedulers, host adapters, boot lifecycle
- `igniter-cluster`
  contracts-native distributed runtime: remote execution, routing, admission,
  placement, topology, distributed diagnostics

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
  semantics or kernel extension seams.
- Put code in `igniter-extensions` if it is optional behavior, tooling, or
  domain vocabulary over the contracts kernel.
- Put code in `igniter-application` if it is about local runtime hosting,
  providers, services, boot, config, loading, or scheduling.
- Put code in `igniter-cluster` if the network is part of the execution model.
- Put transport and protocol work in adapter packages unless it is truly a
  cluster semantic concern.
- Touch legacy packages only for reference, parity, migration, or retirement
  cleanup.
- Put package-specific user docs next to the package README.

## Explicit Non-Goals

- do not treat `server` as a primary runtime pillar
- do not treat stack orchestration as the default local app model
- do not keep growing legacy packages as if they were still the target

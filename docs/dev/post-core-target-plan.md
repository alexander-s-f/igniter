# Post-Core Target Plan

This note resets the design target after the migration foundations landed.

It intentionally reframes the work away from:

- "how do we preserve `igniter-core`?"
- "how do we rename or wrap the old kernel?"

and toward:

- "what should exist if `igniter-core` and `igniter-legacy` disappeared?"

That is the right design question because Igniter does not currently promise
backward compatibility, and the monorepo still has a rare chance to replace
weak or accidental structure rather than preserving it.

## Decision

Treat `igniter-core` and `igniter-legacy` as:

- frozen compatibility/reference layers
- parity fixtures for tests and migration examples
- temporary packaging/runtime shims while the new architecture matures

Do **not** treat them as the place where the next architecture should keep
growing.

Practical rule:

- no new product architecture should be designed "on top of core"
- no new feature should land in legacy first and migrate later
- only retirement, compatibility, and parity work should touch legacy

## Primary Design Questions

From here on, design should start with these questions:

1. What is required for the canonical contracts DSL to stand on its own?
2. What is required for `Application` to stand on its own?
3. What is required for `Cluster` to stand on its own?
4. Where should the old model be replaced rather than ported?

These questions are stronger than "how do we keep old entrypoints working?"
because they force a target architecture instead of a compatibility maze.

## Target Package Graph

The target shape should be:

- `igniter-contracts`
  canonical embedded kernel: DSL, model, compile/runtime spine, reports,
  hooks, extension seams
- `igniter-extensions`
  behavioral, operational, tooling, and domain packs over the contracts kernel
- `igniter-app`
  contracts-native application runtime/profile
- `igniter-cluster`
  contracts-native distributed runtime
- adapter packages
  transport, tooling, IDE, MCP, and other integration surfaces

Legacy packages remain only as reference fixtures until deletion.

## Track 1: Canonical Contracts DSL

The embedded kernel should be designed as if legacy did not exist.

Questions to answer:

- which DSL forms are canonical?
- which current contracts seams are still missing for embedded usage?
- which compile/runtime concepts belong in the base kernel versus packs?
- which old behaviors were accidental implementation details rather than
  meaningful public semantics?

Design rule:

- prefer sharpening the contracts model now over preserving old embedded APIs
- if a DSL shape feels compromised by history, redesign it while the surface is
  still pre-v1

Expected output:

- one canonical contracts-first entrypoint story
- one canonical DSL/runtime story
- one explicit list of embedded-kernel capabilities that belong in
  `igniter-contracts`

## Track 2: Contracts-Native Application

`Application` should not be treated as "core plus boot glue".

It should be redesigned as a host/runtime profile over `igniter-contracts` and
`igniter-extensions`.

Questions to answer:

- what is the minimal application runtime contract?
- what are the first-class seams for config, boot, host adapters, loaders,
  schedulers, diagnostics, and service registration?
- which old `app` concepts are essential?
- which old `app` behaviors were just convenience wrappers over the old core?

Target idea:

- `Application` becomes a contracts-native composition/runtime host
- packs and profiles stay explicit
- boot lifecycle is modeled directly instead of patched through legacy globals

Expected output:

- a target `Application` object model
- a target package boundary for `igniter-app`
- a migration list from old app runtime semantics to new app runtime semantics

## Track 3: Contracts-Native Cluster

`Cluster` should not be rebuilt as "server/core plus distributed patches".

It should be designed as a distributed runtime layer over explicit contracts
execution and explicit packs.

Questions to answer:

- what is the minimal remote execution contract?
- what is the routing contract?
- how should capabilities participate in routing and admission?
- what parts of consensus/replication/projection are essential cluster
  semantics versus old implementation artifacts?

Target idea:

- `Cluster` owns network/distribution concerns directly
- contracts remain the executable graph abstraction
- routing, capabilities, replication, and remote execution are explicit cluster
  layer seams, not hidden behavior inside the embedded kernel

Expected output:

- a target `Cluster` substrate model
- a strict line between contracts kernel and distributed runtime
- a clear list of which old cluster behaviors should be dropped, redesigned, or
  rebuilt as packs/services

## Stop-Doing List

To make this reset real, stop doing the following:

- stop treating `igniter-core` as the place where new architecture should land
- stop using `igniter-legacy` as a new long-term product layer
- stop solving architecture questions by adding wrappers over old semantics
  first
- stop preserving weak public shapes just because they existed before the
  contracts rewrite

Allowed exceptions:

- compatibility shims
- migration examples
- parity comparisons
- retirement cleanup

## Immediate Sequencing

The next design sequence should be:

1. freeze legacy/core as reference-only architecture
2. define the canonical contracts DSL/runtime target
   see [Embed Target Plan](./embed-target-plan.md)
3. define the contracts-native `Application` target
   see [Application Target Plan](./application-target-plan.md)
4. define the contracts-native `Cluster` target
5. only then continue package deletion and final cleanup

This order matters because deletion without a strong target just moves the
ambiguity somewhere else.

## Success Criteria

This reset is successful when all of these are true:

- `igniter-contracts` is clearly the canonical embedded kernel
- `Embed` is clearly understood as the foundation operating mode
- `igniter-app` has a target model that does not assume legacy core semantics
- `igniter-cluster` has a target model that does not assume legacy core
  semantics
- legacy survives only as reference/compatibility material
- deleting `igniter-core` becomes cleanup, not architecture

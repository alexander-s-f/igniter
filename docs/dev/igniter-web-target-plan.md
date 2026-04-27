# Igniter Web Target Plan

This note defines the current public target for `igniter-web`.

## Thesis

`igniter-web` should be the contracts-first web layer for Igniter applications.
It should make app-owned state visible and operable without turning Igniter into
a CRUD-first Rails clone.

The primary surfaces are:

- dashboards
- operator workspaces
- command/refusal flows
- chats and streams when they are backed by explicit app contracts
- receipt, report, and event review screens

## Ownership

`igniter-web` owns:

- mounted web surfaces
- request handling for example/review surfaces
- screen composition primitives
- `MountContext`
- surface structure and surface manifest metadata

It does not own:

- application boot
- provider or service registration
- contract registration
- app mutation policy
- production deployment behavior
- cluster placement

Those remain application, host, or cluster concerns.

## Current Proof

The current proof comes from Lense, Chronicle, Scout, and Dispatch. Each app
mounts one web surface, renders from an app-owned snapshot, exposes `/events`,
and emits `/report` or `/receipt` evidence.

Public review path:

- [Enterprise Verification](../guide/enterprise-verification.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)

## Extraction Rule

Keep repeated web shapes local until the showcase portfolio proves a stable
abstraction. Public package APIs should be promoted only when they preserve
clear ownership between application state, command handling, and web rendering.

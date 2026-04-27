# Igniter Dev

Use this section for public contributor-facing architecture, package boundaries,
and current design constraints.

Internal cycle history, agent handoffs, research horizon material, external
expert reports, and legacy deep references live under `playgrounds/docs/` and
are not part of the public documentation surface.

## Canonical Dev Docs

- [Current Runtime Snapshot](./current-runtime-snapshot.md)
- [Architecture](./architecture.md)
- [Execution Model](./execution-model.md)
- [Module System](./module-system.md)
- [Package Map](./package-map.md)
- [Data Ownership](./data-ownership.md)
- [Embed Target Plan](./embed-target-plan.md)
- [Application Target Plan](./application-target-plan.md)
- [Application And Web Integration](./application-web-integration.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Cluster Target Plan](./cluster-target-plan.md)
- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [MCP Adapter Package](./mcp-adapter-package-spec.md)
- [Document Rotation](./document-rotation.md)

## Package And Layer Boundaries

- [Core](../guide/core.md)
- [App](../guide/app.md)
- [Cluster](../guide/cluster.md)
- [SDK](../guide/sdk.md)

## Public Docs Rule

- Keep user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep public architecture and placement decisions in `docs/dev/`.
- Keep private research, expert analysis, handoff history, and agent working
  tracks in `playgrounds/docs/`.
- Prefer updating a package README and guide index before writing new deep
  public prose.
- Rotate stale public docs into `playgrounds/docs/` once their accepted content
  has been compressed into guide, dev, example, or package reference.

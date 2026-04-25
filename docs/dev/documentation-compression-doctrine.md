# Documentation Compression Doctrine

This doctrine captures the accepted minimum from the expert documentation
compression methodology.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Source:

- [Documentation Compression Methodology](../experts/documentation-compression.md)

## Decision

[Architect Supervisor / Codex] Accepted as a process reference, narrowed for
immediate use.

Documentation is treated as a cache:

- active context should stay small
- decisions and rules must remain findable
- status should not stack indefinitely
- history should move cold instead of staying in the active path

## Content Types

- Decision `[D]`: durable choice with rationale.
- Rule `[R]`: current constraint or instruction.
- Status `[S]`: current state, valid for the active cycle.
- History `[H]`: true record, but cold unless auditing or debugging.

## Active Rules

- Active indexes should stay compact enough for agents to read first.
- New status blocks should replace or compress older status blocks.
- Track acceptance should leave a short supervisor note, not a full replay.
- Repeated boundaries should move to [Constraint Sets](./constraints.md).
- Long rationale belongs in reference, history, research, or expert documents.

## Deferred

- YAML front-matter rollout
- compression linter
- line-up generator
- automated history compression
- mass rewrite of existing historical documents
- research expiry automation

## Supervisor Notes

[Architect Supervisor / Codex]

Accepted now:

- Use the taxonomy as review vocabulary.
- Keep [Active Tracks](./tracks.md) compact.
- Apply compression manually when a public active document grows beyond its
  working purpose.

Deferred:

- The expert proposal to compress `tracks-history.md` immediately. It is useful,
  but lower priority than keeping the active path small while the POC is still
  moving.

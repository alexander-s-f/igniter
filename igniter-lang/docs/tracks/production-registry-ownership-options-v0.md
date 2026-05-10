# Track: Production Registry Ownership Options v0

Card: S3-R25-C3-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `production-registry-ownership-options-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Analyze ownership options for production authority registry storage before any
implementation.

Source:

```text
igniter-lang/docs/tracks/phase1-durable-registry-storage-semantics-v0.md
```

This track does not implement storage, choose production signing, or bind to
Ledger.

---

## Required Semantics

Any owner must preserve the R24 registry requirements:

- stable storage identity;
- query by `authority_ref`;
- active/revoked/superseded lookup by effective time;
- receipt chain verification;
- content-addressed decision ref verification;
- revocation/supersession effective time;
- no direct `active -> superseded` in v0 unless a future transaction emits
  paired revocation and supersession receipts.

---

## Comparison Table

| Option | Storage identity | Query API | Deployment dependency | Revocation latency | Signing/key relationship | Failure modes | Agent/human inspectability |
|---|---|---|---|---|---|---|---|
| Package-owned registry | Package namespace plus versioned store id, e.g. `igniter-authority-registry/<env>` | Local/library API, possibly CLI; easy typed API for runtime callers | App/package deployment and data migration | Low if deployed locally; can be stale across nodes | Must not own signing keys by default; should consume signed decision refs later | Version skew, app-local stale copy, accidental coupling to runtime package, migration drift | Good for agents if JSON/receipts exported; moderate for humans unless CLI/docs are strong |
| Gate document store | Canonical docs/gates store plus content-addressed refs | File/content lookup by authority_ref index; static generated index possible | Git/release artifact distribution | Medium/high; revocations wait for document publication and rollout | Natural source for signed decisions; still not key management | Path/content drift, branch ambiguity, slow revocation propagation, local checkout staleness | Excellent for humans and agents; strongest reviewability and audit trail |
| External authority service | Service identity, endpoint, schema version, environment id | Network API: `lookup(authority_ref, at:)`, chain verification endpoint | Service availability, authn/authz, network, rollout | Lowest if highly available; supports centralized revocation | Can integrate with signing later, but should keep signing subsystem separate | Outage, split-brain/cache staleness, credential failures, opaque policy bugs | Good if it exposes receipts and content refs; poor if it becomes black-box |

---

## Option Notes

### Package-Owned Registry

Benefits:

- easiest integration with RuntimeMachine callers;
- deterministic local query path;
- can ship typed schemas and validators near package code;
- works offline if registry snapshot is packaged.

Risks:

- can look like runtime self-authorization if bundled too closely with
  `TemporalExecutor`;
- stale packages may carry stale revocation state;
- migration/version skew can affect authority decisions;
- package ownership may blur Phase 1 registry with Phase 2 Ledger/package work.

Best use:

- local cache or read-only snapshot of an authoritative registry;
- package-level validator for registry entry and receipt shape.

Not ideal as sole authority for Phase 1 production because revocation latency
depends on deployment cadence.

### Gate Document Store

Benefits:

- preserves Architect decision visibility;
- content-addressed addendum refs fit naturally;
- easy for humans and agents to inspect;
- git/release history gives a clear audit surface;
- lowest implementation complexity for Phase 1 production design.

Risks:

- revocation latency depends on publishing and caller refresh;
- raw filesystem path must not be sufficient;
- branch/local checkout ambiguity must be controlled by commit or release
  artifact identity;
- query API likely needs a generated index to avoid ad hoc document parsing.

Best use:

- default Phase 1 production design source of authority;
- canonical decision/ref store with generated registry index artifact.

### External Authority Service

Benefits:

- strongest revocation latency model;
- centralizes status lookup and effective-time policy;
- can later support production signing verification and online revocation;
- can return receipt chains and content refs in one API.

Risks:

- adds availability and credential dependencies;
- can become opaque if receipts/content refs are not exposed;
- must handle cache consistency carefully;
- bigger operational surface than Phase 1 currently needs.

Best use:

- later production or multi-node deployments needing low-latency revocation;
- not the first default unless Architect explicitly prioritizes online
  revocation over inspectability/simplicity.

---

## Recommended Default

[R] Recommend **gate document store + generated content-addressed registry
index** as the Phase 1 production design default.

Reasoning:

- best matches the signed-addendum authority model already used in Phase 1;
- preserves human/agent inspectability;
- keeps production signing/key management separate;
- avoids coupling registry ownership to runtime packages or Ledger packages;
- can still produce a queryable artifact:

```text
docs/gates/*
  -> generated registry index
  -> query by authority_ref
  -> content-addressed decision refs
  -> receipt chain verification
```

Package-owned code may later consume this index as a read-only validator/cache.
An external authority service may later serve the same index and receipts when
revocation latency or multi-node deployment demands it.

---

## Architect Questions

[Q] Should Phase 1 production registry source of truth be the gate document
store, with package/runtime consumers restricted to read-only generated indexes?

[Q] What freshness SLA is required for revocation: release-time, deploy-time,
startup-time, per-invocation, or online?

[Q] Should a production registry index be generated in CI from signed gate docs,
or manually curated by Architect/Meta Expert?

[Q] What immutable anchor should production prefer: git commit SHA, release
artifact digest, or both?

[Q] If an external service is later introduced, must it expose full transition
receipts and content-addressed decision refs for offline audit?

[Q] Should any package-owned registry store be prohibited from being the
authority source and limited to cache/validator status?

---

## Non-Authorization

This track does not authorize:

- storage implementation;
- production signing mechanism;
- key management;
- production authority service;
- RuntimeMachine integration;
- package edits;
- Ledger binding;
- Phase 2 Ledger adapter;
- BiHistory/stream/OLAP/writes/replay/compact/subscribe;
- production cache;
- durable audit.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/production-registry-ownership-options-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Compared package-owned registry, gate document store, and external authority service.
- Recommended Phase 1 default: gate document store plus generated content-addressed registry index.
- Production signing/key management remains a separate decision.

[R] Recommendations:
- Use package-owned registry only as read-only validator/cache unless Architect explicitly assigns authority ownership.
- Defer external authority service until revocation latency or multi-node deployment requires it.
- Preserve full receipt/content-ref inspectability for agents and humans.

[S] Signals:
- R24 storage semantics remain the required baseline for all options.
- No implementation or Ledger binding was introduced.

[T] Tests / Proofs:
- git diff --check -- igniter-lang/docs/tracks/production-registry-ownership-options-v0.md

[Files] Changed:
- igniter-lang/docs/tracks/production-registry-ownership-options-v0.md

[Q] Open Questions:
- Architect should decide registry source of truth, freshness SLA, index generation owner, immutable anchor, and whether package ownership may ever be authoritative.

[X] Rejected:
- No storage implementation, production signing choice, key management, package edits, RuntimeMachine integration, or Ledger binding.

[Next] Proposed next slice:
- Architect decision record for Phase 1 production registry ownership and freshness SLA.
```

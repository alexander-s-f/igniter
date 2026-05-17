# Org Architect Top-Level Doc Slice Initialization

Status: done
Card: `S3-R62-C0-O`
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Date: 2026-05-17

---

## Executive Summary

The org sidecar is initialized as a separate process-memory lane under
`igniter-lang/docs/org/`.

The central invariant is accepted:

```text
Org sidecar supports the main Architect Supervisor, but does not become a
second authority center.
```

The first slice created compact orientation files only. It did not edit
compiler/runtime implementation, language semantics, active gates, proposals,
current status, or archives.

---

## Created / Updated

```text
igniter-lang/docs/org/README.md
igniter-lang/docs/org/current-map.md
igniter-lang/docs/org/reports/org-architect-top-level-doc-slice-initialization-v0.md
igniter-lang/docs/org/memory-contracts/operational-contract-memory-v0.md
igniter-lang/docs/org/indexes/README.md
```

---

## Findings

### F1 - Sidecar boundary is already compatible with cards

`docs/cards/README.md` defines `-O` as organization/orchestration sidecar, and
`docs/cards/S3/S3.md` names R62 as including C0-O without allowing code unless
C3-A opens a bounded card.

Impact: the Org Architect Supervisor can run in parallel without disturbing
the compiler/profile critical path.

### F2 - Documentation density justifies a separate process-memory lane

The docs layer contains hundreds of tracks plus many discussions, gates, and
proposals. Without a compact org map, new agents will keep rediscovering the
same route through broad reads.

Impact: sidecar work should optimize maps and return only high-signal deltas.

### F3 - Role profiles and instance memory should be separate

Role profiles are stable operating contracts. Active agent instances also need
a small mutable memory for lane, personalization, recent handoff, hazards, and
return-report rules.

Impact: operational-contract memory is useful, but it must never override the
canonical role profile or authority docs.

---

## Risks

| Risk | Status | Mitigation |
| --- | --- | --- |
| second authority center | visible | keep `docs/org/` report-only |
| context bloat inside org docs | visible | compact path-indexed files only |
| stale instance memory | expected | use refresh/expiry fields |
| accidental archive mutation | blocked | no move/delete in this slice |
| takeover of C1-C4 compiler cards | blocked | C0-O marked sidecar only |

---

## Recommendation

Continue.

Next useful org slice:

```text
Operational-contract memory pilot:
  choose one role instance,
  fill one compact memory file from a recent handoff,
  validate that it improves refresh without changing authority.
```

Do not expand into archive movement, gate edits, or active status mutation until
the main Architect Supervisor explicitly opens that work.

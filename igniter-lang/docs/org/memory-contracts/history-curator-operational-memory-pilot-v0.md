# History Curator Operational Memory Pilot v0

Status: pilot
Owner: [Org Architect Supervisor]
Role memory target: `history-curator`
Date: 2026-05-17
Authority: non-authority example only

---

## Filled Memory

```yaml
kind: operational_contract_memory
format_version: "0.1"
status: pilot
owner_role: "history-curator"
agent_name: "[Igniter-Lang History Curator]"
agent_instance_id: "pilot"
base_role_profile: "igniter-lang/roles/history-curator.md"
borrowed_lenses:
  - "archive-form-expert inheritance"
route_state:
  route: UPDATE
  stage: "S3"
  active_round: "n/a"
  active_cards: []
lane:
  name: "documentation-lifecycle"
  current_objective: "Compress bounded history source sets and plan safe movement/link lifecycle."
  mode: "long-running-sidecar"
authority_boundary:
  may_write:
    - "igniter-lang/docs/archive/history/ when assigned"
    - "bounded movement/link ledgers when assigned"
    - "non-authority recommendations and indexes"
  must_not_write:
    - "compiler/runtime implementation"
    - "docs/gates/"
    - "docs/proposals/"
    - "docs/spec/ unless explicitly assigned"
    - "docs/current-status.md unless explicitly assigned"
    - "source files outside assigned source set"
  may_decide:
    - "history classification"
    - "rotation recommendation"
    - "movement/link precondition list"
  must_not_decide:
    - "canon promotion"
    - "implementation authorization"
    - "actual move/delete without explicit approval"
    - "active gate/proposal/status authority"
recent_handoff:
  last_card: "not bound to a live card in this pilot"
  last_output: "igniter-lang/docs/archive/history/"
  current_status: "History reports exist; movement remains recommendation-first."
  next_expected_return: "compact report, classification table, rotation recommendations, no-move anchors"
known_hazards:
  - id: "bounded-source-set"
    note: "History Curator must read only the assigned folder/layer/source set."
    mitigation: "Start from AGENTS, role, agent-context, current-status, then named sources only."
  - id: "no-move-default"
    note: "Compression and movement planning do not authorize file movement."
    mitigation: "Mark move/delete as recommendation unless card explicitly says to perform it."
  - id: "canon-history-confusion"
    note: "Old docs can look authoritative because they are public and detailed."
    mitigation: "Classify as accepted_canon, implemented, superseded_history, research_unrealized, rejected, parked, and/or value."
  - id: "lineup-before-redirect"
    note: "Movement/link lifecycle should create compact summaries before redirecting or moving."
    mitigation: "Coordinate with Line Up Summarizer and verify exact source paths remain protected."
  - id: "current-map-protection"
    note: "current-status and agent-context are active maps, not archive targets."
    mitigation: "Do not edit them unless assigned by Architect Supervisor."
neighbor_awareness:
  nearby_roles:
    - "[Igniter-Lang Archive/Form Expert]"
    - "[Igniter-Lang Line Up Summarizer]"
    - "[Igniter-Lang Meta Expert]"
  parallel_cards: []
  avoid_overlap:
    - "canon decisions"
    - "Line Up summary authorship unless assigned"
    - "active status/gate/proposal mutation"
return_report_rules:
  return_when:
    - "movement approval needed"
    - "canon/history conflict appears"
    - "public/private risk appears"
    - "high-value old signal would be lost without hoisting"
    - "archive/source set is too broad for current card"
  stay_local_when:
    - "classification table update"
    - "rotation recommendation"
    - "bounded no-move ledger"
refresh_policy:
  reread_on:
    - "new source set"
    - "stage boundary"
    - "documentation-metabolism changes"
    - "role profile changes"
    - "authority conflict"
    - "current-status or active card conflict"
    - "long pause"
  expires_after: "source-set close or stage boundary"
evidence_refs:
  - "igniter-lang/roles/history-curator.md"
  - "igniter-lang/docs/archive/README.md"
  - "igniter-lang/docs/archive/history/README.md"
  - "igniter-lang/docs/dev/documentation-metabolism.md"
  - "igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md"
  - "igniter-lang/docs/org/memory-contracts/operational-contract-memory-v0.md"
last_updated: "2026-05-17"
```

---

## Pilot Verdict

Useful.

History Curator memory should emphasize:

- bounded source-set read discipline;
- no-move/no-delete as the default;
- classification before rotation;
- Line Up before redirect;
- explicit Architect approval before actual movement.
- stale refresh on authority/current-status/card conflict or long pause.

This is a strong candidate for role-instance memory because the role often runs
long Stage-level cycles where stale context and broad rereads are likely.

---

## Non-Authority Note

This pilot is not an approval to move, delete, or archive files. It is only a
worked example of operational memory for a future process decision.

# Operational-Contract Memory v0

Status: draft
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Scope: schema proposal only, no automation

---

## Purpose

Operational-contract memory separates stable role authority from mutable
agent-instance context.

```text
role profile = canonical stable contract
instance memory = compact mutable working memory for one active agent instance
```

This prevents two failures:

- retraining every agent instance from broad history;
- letting an instance's local habit override role/gate/proposal authority.

---

## Non-Authority Rule

Operational memory must not override:

```text
AGENTS.md
roles/*.md
docs/current-status.md
docs/agent-context.md
docs/cards/*
docs/gates/*
docs/proposals/*
```

If memory conflicts with an authority source, the authority source wins and the
memory must be refreshed or marked stale.

---

## Draft Shape

```yaml
kind: operational_contract_memory
format_version: "0.1"
status: active | stale | retired
owner_role: "<role profile id>"
agent_name: "<display agent name>"
agent_instance_id: "<optional stable chat/session label>"
base_role_profile: "igniter-lang/roles/<role>.md"
borrowed_lenses:
  - "<temporary lens, if any>"
route_state:
  route: INIT | UPDATE | IN_FLIGHT_REFRESH | STALE_REFRESH | CLOSE
  stage: "S3"
  active_round: "R62"
  active_cards:
    - "S3-R62-C0-O"
lane:
  name: "<compiler/profile/runtime/org/docs/etc>"
  current_objective: "<one sentence>"
  mode: "long-running-sidecar | card-bound | discussion | proof | implementation"
authority_boundary:
  may_write:
    - "<paths or doc layers>"
  must_not_write:
    - "<protected paths or authority layers>"
  may_decide:
    - "<local report-only decisions>"
  must_not_decide:
    - "<gates, implementation, semantics, etc>"
recent_handoff:
  last_card: "<card id>"
  last_output: "<path>"
  current_status: "<compact status>"
  next_expected_return: "<what to report back>"
known_hazards:
  - id: "<short hazard id>"
    note: "<compact note>"
    mitigation: "<what to check before acting>"
neighbor_awareness:
  nearby_roles:
    - "<role>"
  parallel_cards:
    - "<card id>"
  avoid_overlap:
    - "<scope to avoid>"
return_report_rules:
  return_when:
    - "authority risk"
    - "context risk"
    - "decision needed"
    - "stage report"
  stay_local_when:
    - "background observation"
    - "non-authority process note"
refresh_policy:
  reread_on:
    - "stage boundary"
    - "long pause"
    - "route changes to UPDATE"
    - "conflict with current-status or card file"
  expires_after: "<stage | round | date | card close>"
evidence_refs:
  - "<path>"
last_updated: "YYYY-MM-DD"
```

---

## Required Fields

Minimum viable memory:

```text
kind
format_version
status
owner_role
base_role_profile
route_state
lane
authority_boundary
recent_handoff
known_hazards
return_report_rules
refresh_policy
evidence_refs
last_updated
```

---

## Safety Rules

1. Keep memory compact. Prefer paths and one-line claims.
2. Do not store secrets, credentials, private personal material, or raw chat
   dumps.
3. Do not store absolute paths outside this repository unless the card names an
   external workspace.
4. Mark memory stale after a stage boundary, long pause, or authority conflict.
5. Instance memory may specialize behavior, but cannot widen authority.
6. Borrowed lenses are additive and temporary. They do not replace the base
   role.
7. If multiple instances of the same role exist, each instance may have its own
   memory, but shared role facts must be promoted to the role profile or a map
   only through explicit approval.

---

## Suggested Storage

If approved later:

```text
igniter-lang/docs/org/memory-contracts/
  operational-contract-memory-v0.md     # schema

igniter-lang/docs/org/indexes/
  role-instance-memory-index.md         # optional index

igniter-lang/docs/org/memory/
  <role-id>/<agent-instance-id>.md       # optional future instance files
```

This slice does not create the future `memory/` directory. Automation and
instance files require a separate card.

---

## Validation Questions

Before adopting:

```text
1. Does this reduce onboarding rereads?
2. Does it keep authority sources clear?
3. Can a stale instance self-detect that its memory is old?
4. Can parallel instances avoid stepping on each other?
5. Is the memory small enough to paste into a handoff?
```

Current recommendation: pilot with one non-authority role before making this a
standard across the orchestra.

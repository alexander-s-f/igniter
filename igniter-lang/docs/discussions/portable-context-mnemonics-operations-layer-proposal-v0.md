# Shadow Proposal: Portable Context Mnemonics — Operations Layer v0

Card: Shadow-MN-R1-C5-SP
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: shadow-proposal
Initiator: user
Track: portable-context-mnemonics-operations-layer-proposal-v0

Shadow status: exploration only. This document does not create canon,
does not author accepted grammar syntax, and does not authorize
parser/tooling work. It is a design proposal for review and pressure,
not an implementation instruction.

Depends on:
- Shadow-MN-R1-C1-P1 (grammar options)
- Shadow-MN-R1-C2-P1 (reconstruction proof)
- Shadow-MN-R1-C3-X  (comprehension pressure)
- Shadow-MN-R1-C4-SP (compressed authority graph)

---

## Motivation

C4-SP established the compressed authority graph: state assertions carry
typed authority markers `[AUTH/CLOSED/HELD/EVIDENCE/OPEN]`, making the
invariant `evidence != closure != authorization` syntactically encoded
rather than a rule-to-remember.

This proposal extends the same principle one level up:

> **Operations also carry authority markers.**
> "Who authorized this action?" is as important as "who authorized this
> state."

The extension covers:
- read / find / check (observe)
- write / update (mutate)
- conditional branching on carrier types
- sequential and parallel dispatch
- self-context bootstrap and update
- structural guards on protected surfaces

The grammar remains a **protocol, not a program**: it encodes *what*,
*authorized by whom*, and *under what condition* — not *how*.

---

## Core Principle: Operations Carry Authority

```text
READ   path              → SELF       — observe; no authority required
FIND   scope WHERE cond  → var        — observe; no authority required
CHECK  assertion         → bool       — observe; no authority required

WRITE  path[AUTH:ref]  ← content      — mutate; authority required
UPDATE target[AUTH:ref][scope=s] ← v  — mutate; authority required

CALL   agent[AUTH:ref](args)          — dispatch; authority required
ROUTE  card → agent[AUTH:ref]         — dispatch; authority required
```

A mutating operation without `[AUTH:...]` is **structurally invalid** —
the same way a state assertion without a carrier cannot claim `[CLOSED]`.

---

## Three Operation Classes

### OBSERVE — non-mutating, authority-free

```text
READ   path                        → SELF | var
FIND   scope WHERE predicate       → SELF | var
CHECK  assertion                   → bool
```

An agent may freely read any reachable document, find by pattern, or
check any state assertion. Observation produces no side effects and
requires no authorization.

Examples:

```text
READ  seed/external-pressure-reviewer     → SELF
READ  docs/gates/prop036-cli-blocker-closure-criteria-decision-v0.md → var:gate
FIND  docs/gates/** WHERE recent(7d)      → var:recent-gates
FIND  experiments/** WHERE contains("compiler_profile_source") → var:refs
CHECK B1[CLOSED:*]                        → bool
CHECK impl[HELD:*]                        → bool
```

### MUTATE — state-changing, authority required

```text
WRITE  path[AUTH:ref]    ← content
UPDATE target[AUTH:ref][scope=s] ← content
  scope: working-memory | context | protected
DELETE path[AUTH:ref]
```

Write and update require an explicit authority carrier. The carrier type
constrains who may issue the operation:

| Carrier | Who may issue |
| --- | --- |
| `[AUTH:SELF]` | agent updating its own working memory only |
| `[AUTH:track-ref]` | agent producing a track output |
| `[AUTH:gate-ref]` | Architect-level decision only |

`scope=protected` is never writable by `[AUTH:SELF]` alone. An authority
field, a gate-level decision, or a canon document requires `[AUTH:gate-ref]`.

Examples:

```text
WRITE  docs/discussions/my-review.md[AUTH:card-ref] ← review_content
UPDATE self.context[AUTH:SELF][scope=working-memory] ← new_state
```

### DISPATCH — control transfer, authority required

```text
CALL   agent[AUTH:ref](args)
ROUTE  card-id → agent[AUTH:ref]
DELEGATE task[AUTH:ref] → agent
```

Dispatching work to another agent is a control-transfer mutation. It
carries an authority marker identifying which gate or card initiated
the routing.

Examples:

```text
ROUTE  S3-R49-C1 → agent:CompilerGrammarExpert[AUTH:ArchSup]
CALL   request_formal_gate[AUTH:SELF](subject=B1)
```

---

## Conditional Branching on Carrier Types

Conditionals check **carrier type**, not bare values. This is the key
extension from C4-SP: the same authority-structural reasoning that governs
state assertions also governs control flow.

### Basic form

```text
IF   subject[carrier-type]  → operation
     subject[carrier-type]  → operation
     _                      → fallback
```

`*` matches any valid authority source. `_` is the catch-all.

### Authority-aware branching

```text
CHECK B1
  IF [CLOSED:*]    → READ ?B1; proceed
  IF [EVIDENCE]    → CALL request_formal_gate[AUTH:SELF](subject=B1); HOLD
  IF [OPEN]        → FIND B1-closure-criteria; WRITE progress[AUTH:SELF]
  IF no_carrier    → STOP; WRITE drift-alert[AUTH:SELF]
```

```text
CHECK impl
  IF [HELD:*]      → STOP; !perform_cli_impl
  IF [AUTH:*]      → READ impl-spec; proceed
  IF [OPEN]        → HOLD; request_impl_auth
```

### Branching on carrier class

```text
IF carrier_type == AUTH      → trust; act immediately
   carrier_type == EVIDENCE  → verify; request_gate before acting
   carrier_type == HELD      → stop; do not proceed
   carrier_type == DEFERRED  → read deferral-path; check conditions
   no_carrier                → treat as evidence; do not act on as auth
```

This makes the `evidence != closure != authorization` invariant
executable: the branch structure itself enforces it.

---

## Sequential and Parallel Control Flow

### SEQ — ordered steps, each depending on the prior

```text
SEQ name {
  step1
  THEN step2
  THEN step3
  EACH step: CHECK result[carrier] → proceed | STOP
}
```

Example — round dispatch chain:

```text
SEQ chain-R49 {
  DISPATCH C1[AUTH:ArchSup] → agent:CompilerGrammarExpert
  THEN CHECK C1-result[CLOSED:*] → proceed | STOP
  THEN DISPATCH C2[AUTH:ArchSup] → agent:ResearchAgent
  THEN CHECK C2-result[CLOSED:*] → proceed | STOP
  THEN DISPATCH C3[AUTH:ArchSup] → agent:ExternalReviewer
}
```

### PARALLEL — concurrent steps, joined before continuing

```text
PARALLEL name {
  ALL [item1, item2, item3] → operation(each)
  THEN join → next_step
}
```

Example — verify all open blockers before requesting implementation auth:

```text
PARALLEL verify-open-blockers {
  ALL [B3, B4, B5, B6, B9] → CHECK each[CLOSED:*]
  THEN
    IF all_pass → ROUTE impl-auth-request[AUTH:ArchSup]
    IF any_fail → COLLECT failures; WRITE blocker-report[AUTH:SELF]
}
```

---

## Self-Context Bootstrap and Update

The "read your role seed and update yourself" instruction is a recurring
agent operation. In the authority graph it looks like this:

### Update working memory from seed

```text
SEQ update-from-seed {
  READ  seed/my-role-name[AUTH:project-canon] → var:seed_content
  CHECK seed_content
    IF [AUTH:*]   → UPDATE self.context[AUTH:SELF][scope=working-memory]
                      ← var:seed_content
    IF [EVIDENCE] → READ var:seed_content; !UPDATE self.authority
    IF no_carrier → STOP; flag_unverified_seed
  !UPDATE self.authority[scope=protected]
}
```

Three invariants encoded structurally:
1. Working memory may be updated freely by the agent itself
2. Authority scope is **never** self-updated — requires gate-ref
3. Unverified seeds are flagged, not silently accepted

### Full agent bootstrap

```text
BOOTSTRAP role-name {

  SEQ init {
    READ  seed/role-name[AUTH:project-canon]    → var:role
    READ  docs/discussions/README.md             → var:index
    FIND  docs/gates/** WHERE recent(14d)        → var:recent-gates
    READ  docs/current-status.md                 → var:status
    UPDATE self.context[AUTH:SELF][scope=working-memory] ← {
      role:         var:role
      discussion-index: var:index
      recent-gates: var:recent-gates
      status:       var:status
    }
  }

  CHECK self.context
    IF loaded   → READ current-card; proceed
    IF partial  → FIND missing-context WHERE self.context; retry init
    IF empty    → STOP; flag_bootstrap_failed

  GUARD {
    !WRITE  canon/**            (until=[AUTH:gate-ref])
    !UPDATE self.authority      (always)
    READ    **                  (always free)
  }
}
```

---

## Structural Guards on Protected Surfaces

`GUARD` blocks declare what an agent **structurally cannot do** regardless
of other instructions. They travel with the agent's context and cannot
be overridden except by a matching `[AUTH:gate-ref]` operation.

```text
GUARD agent-invariants {
  !WRITE  lib/igniter_lang/cli.rb     (until=impl[AUTH:ArchSup])
  !WRITE  bin/igc                     (until=impl[AUTH:ArchSup])
  !WRITE  docs/spec/**                (until=[AUTH:gate-ref])
  !UPDATE self.authority[scope=protected]   (always)
  !ROUTE  impl-authorization[AUTH:< ArchSup]
  READ    **                          (always free)
}
```

`!ROUTE impl-authorization[AUTH:< ArchSup]` means: implementation
authorization may only be dispatched by an authority equal to or above
Architect level. Any agent attempting `ROUTE impl-auth[AUTH:SELF]` is
structurally blocked.

---

## Lazy Expansion Anchors on Operations

Operations may carry the same `?key → path` expansion anchors defined
in C4-SP:

```text
WRITE docs/discussions/my-review.md[AUTH:card-ref] {
  ?template  → docs/discussions/templates/discussion-card.md
  ?prior     → docs/discussions/prop036-cli-api-profile-source-pressure-v0.md
} ← review_content
```

An agent performing the WRITE can lazily expand `?template` only if it
needs the template. The anchor does not block the operation — it enriches
it on demand.

---

## Complete Example: PROP-036 CLI Pressure Review Bootstrap

```text
BOOTSTRAP external-pressure-reviewer[AUTH:project-canon] {

  SEQ read-context {
    READ  seed/external-pressure-reviewer           → var:role
    READ  docs/gates/prop036-cli-blocker-closure-criteria-decision-v0.md
                                                    → var:gate-r46
    READ  docs/gates/prop036-b7-b8-docs-and-criteria-precision-review-v0.md
                                                    → var:gate-r47
    FIND  docs/discussions/** WHERE shadow=false
          ORDER BY date DESC LIMIT 5                → var:recent-discussions
    UPDATE self.context[AUTH:SELF][scope=working-memory] ← {
      role:    var:role
      gate-r46: var:gate-r46
      gate-r47: var:gate-r47
      recent:  var:recent-discussions
    }
  }

  CHECK current-card
    IF [ASSIGNED:*] → SEQ execute-review {
        READ  current-card-scope                    → var:inputs
        CHECK each input[CLOSED:*] | [EVIDENCE]
        WRITE discussion-doc[AUTH:card-ref] ← review
        UPDATE docs/discussions/README.md[AUTH:card-ref] ← index-entry
      }
    IF no_carrier   → STOP; WRITE drift-note[AUTH:SELF]

  GUARD {
    !WRITE  canon/**           (until=[AUTH:gate-ref])
    !WRITE  lib/**             (until=impl[AUTH:ArchSup])
    !UPDATE self.authority     (always)
    READ    **                 (always free)
  }
}
```

---

## The Protocol / Program Boundary

The grammar remains mnemonic because it encodes **intentions with
authority**, not implementations.

```text
Protocol (this grammar):
  WRITE docs/ruby-api.md[AUTH:C1-P1] ← content
  → who authorized, what target, what content — agent decides how

Program (out of scope):
  open("docs/ruby-api.md", "w") { |f| f.write(content) }
  → exact implementation, no authority semantics
```

The moment the grammar describes *how* — it becomes code and loses
portability. As long as it describes *what, by whom, and under what
condition* — it remains a high-density mnemonic operable without
unpacking.

---

## Complete Operations Grammar Summary

```text
── OBSERVE (authority-free) ──────────────────────────
READ   path                        → SELF | var
FIND   scope WHERE predicate       → SELF | var
CHECK  assertion                   → bool

── MUTATE (authority required) ───────────────────────
WRITE  path[AUTH:ref]             ← content
UPDATE target[AUTH:ref][scope=s]  ← content
DELETE path[AUTH:ref]

── DISPATCH (authority required) ─────────────────────
CALL   agent[AUTH:ref](args)
ROUTE  card → agent[AUTH:ref]
DELEGATE task[AUTH:ref] → agent

── CONTROL FLOW ──────────────────────────────────────
IF   subject[carrier]  → op
     subject[carrier]  → op
     _                 → fallback

SEQ  name { step THEN step THEN step }
PARALLEL name { ALL [items] → op THEN join → next }
EACH item IN [list] → op(item)

── GUARDS ────────────────────────────────────────────
GUARD { !WRITE target (until=condition)
        !UPDATE scope  (always)
        READ **        (always free)  }

── BOOTSTRAP ─────────────────────────────────────────
BOOTSTRAP role[AUTH:ref] { SEQ init {...} CHECK ... GUARD {...} }
```

---

## Levels of the Full System (C4-SP + C5-SP)

| Level | From | Encodes | Answers |
| --- | --- | --- | --- |
| State Graph | C4-SP | `B1[CLOSED:R47]` | authorized? by whom? |
| Operations | C5-SP | `READ / WRITE / CHECK` | what to do? allowed? |
| Control Flow | C5-SP | `IF / SEQ / PARALLEL` | in what order? condition? |
| Guards | C5-SP | `!WRITE / GUARD` | structurally forbidden? |
| Bootstrap | C5-SP | `BOOTSTRAP / UPDATE self` | how to initialize context? |

Each level is operationally closed. Each level carries authority markers.
Expansion is lazy. The grammar remains a protocol — not a program.

---

## Non-Authorization

This shadow proposal does not authorize:

- Igniter-Lang syntax or spec changes
- Parser or tooling implementation
- Changes to any gate, track, or canonical document
- Canonical mnemonic standardization without Architect review
- Implementation of any PROP-036 surface or CLI behavior

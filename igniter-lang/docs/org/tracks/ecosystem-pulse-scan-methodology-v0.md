# Ecosystem Pulse Scan Methodology v0

Status: active practice
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-22
Track: ecosystem-pulse-scan-methodology-v0

---

## Purpose

Ecosystem Pulse Scan is a lightweight recurring practice for looking outside
Igniter without turning outside projects into authority.

The goal is not to build a catalog of projects. The goal is to keep Igniter
oriented inside a fast-moving ecosystem, notice useful pressure early, and
convert outside signals into bounded insights, experiments, or explicit no-op
decisions.

Short form:

```text
look outward -> extract pressure -> compare to our coordinates -> decide one
bounded consequence
```

---

## Trigger

Run an Ecosystem Pulse Scan when:

- a project shows unusually fast adoption, strong narrative, or practical
  overlap with Igniter, Spark CRM, Ruby Framework, or the agent-orchestration
  lanes;
- a user or agent notices a tool/pattern that feels adjacent to our work;
- a portfolio lane needs market/ecosystem orientation before choosing a route;
- our internal patterns risk becoming too self-referential.

Do not run it so frequently that it becomes background noise. A pulse scan is a
strategic sensemaking act, not a news feed.

---

## Scope

Allowed:

- read public project materials;
- summarize positioning, architecture claims, onboarding shape, and operating
  model;
- compare the project against Igniter's current architecture and governance;
- extract practices worth adopting, testing, or rejecting;
- recommend one bounded follow-up.

Not allowed:

- treating outside project claims as canon;
- authorizing implementation from ecosystem admiration alone;
- importing terminology without mapping it to our authority model;
- turning the scan into a feature backlog dump;
- broad competitive anxiety;
- copying runtime/product surfaces into Igniter without a gate.

---

## Scan Shape

Every scan should fit this outline unless there is a clear reason to deviate:

```text
1. Snapshot
2. What It Is
3. Why It Is Growing
4. Architecture Lens
5. Our Coordinate Match
6. Useful Pressure
7. What To Adopt
8. What To Avoid
9. One Bounded Consequence
10. No-Op Decision, if appropriate
```

### 1. Snapshot

Capture only high-signal facts:

- project URL;
- visible traction indicators;
- active development signals;
- primary audience;
- install/onboarding promise;
- core claim.

Use current public sources when facts can change.

### 2. What It Is

Name the category in plain words:

```text
runtime platform
developer tool
governance method
agent memory system
workflow planner
framework
library
research prototype
```

Avoid accepting the project's self-description as the only category.

### 3. Why It Is Growing

Look for the emotional and practical reasons:

- simpler onboarding;
- strong demo loop;
- clear promise;
- ecosystem timing;
- visual/product polish;
- useful automation;
- existing tool integration;
- community narrative.

This section may include creative interpretation. Mark interpretation as such.

### 4. Architecture Lens

Classify the project across these axes:

| Axis | Questions |
| --- | --- |
| Runtime | Does it execute work, agents, tools, workflows, or code? |
| Governance | Does it define authority, review, gates, or decision rights? |
| Memory | Does it preserve reusable context or trajectories? |
| Coordination | Does it route agents, tasks, goals, or dependencies? |
| UX | Does it reduce user friction or create a strong demo experience? |
| Safety | Does it address trust, permissions, data leakage, or audit? |
| Portability | Can it work outside its native tool/ecosystem? |

### 5. Our Coordinate Match

Compare against our system map:

```text
Igniter-Lang: language/compiler/profile architecture
Igniter Ruby Framework: package/runtime/application adoption
Spark CRM: applied business pressure and migration path
Org/Portfolio: orchestration, memory, documentation, dispatch
```

The scan must answer:

```text
Is this adjacent to our runtime, our governance, our UX, our memory, or our
market narrative?
```

### 6. Useful Pressure

Useful pressure is a question that changes how we think.

Examples:

- "Is our onboarding too hard?"
- "Do we need a lite/full mode split?"
- "Do we need a visible verification log?"
- "Is our authority model stronger than our product surface?"
- "Are we solving governance while users first need flow?"

Avoid collecting generic admiration.

### 7. What To Adopt

Adoption may be conceptual, not implementation.

Allowed adoption levels:

```text
wording
onboarding pattern
document shape
demo shape
role/lane practice
proof idea
UX promise
runtime idea for later
```

Each adopted idea must have a bounded owner or remain explicitly parked.

### 8. What To Avoid

Name risks and non-fit:

- too broad surface area;
- authority drift;
- hidden runtime claims;
- product promises without proof;
- dependency/tool lock-in;
- copying terms that mean different things in our system;
- increasing documentation/process weight.

### 9. One Bounded Consequence

Every scan should end with exactly one primary consequence:

```text
open a small card
amend an onboarding doc
add a pressure question
create a comparison note
park as no-op
schedule deeper scan
```

If there are many ideas, choose one and list the rest as parked.

### 10. No-Op Decision

No-op is a valid outcome.

Use no-op when:

- the project is impressive but not relevant to the current horizon;
- the idea is already covered by an existing Igniter pattern;
- adoption would widen scope without improving decisions;
- the scan produced orientation but no action.

---

## Output Format

Default output is compact:

```text
Title:
Source:
Date:
Scan Type: quick | standard | deep
Verdict: adopt-one | monitor | no-op | deeper-scan

Snapshot:
What It Is:
Useful Pressure:
Our Delta:
Adopt:
Avoid:
Bounded Consequence:
Parked Ideas:
```

For routine scans, prefer a short discussion/report in:

```text
igniter-lang/docs/org/reports/
```

For scans that directly affect active compiler/profile/runtime authority, route
to the relevant supervisor before creating any main-lane card.

---

## Pilot Finding: Agent Orchestra DNA

The Agent Orchestra DNA repository is not accepted as a portable full-system
package based on current pilots.

Observed result:

```text
Works strongly inside Igniter, where culture, authority, roles, and history were
co-evolved.
Works partially as reusable principles.
Did not reliably bootstrap the full system in Spark CRM or other projects.
Multi-agent authority drift appeared quickly even with cards, documents, and
subordination rules.
```

Current conclusion:

```text
Do not treat Agent Orchestra DNA as a solved portable product.
Treat it as a source of extracted patterns.
```

Useful extracted patterns:

- bounded cards;
- supervisor packets;
- Fast Lane for practical app work;
- current map over full history;
- authority/pressure separation;
- portfolio letters;
- compact return reports.

Rejected for now:

- assuming a new project can import the whole orchestra as-is;
- requiring strict Igniter-style process in product/application teams;
- over-documenting before local work culture stabilizes.

Spark CRM current posture:

```text
Fast Lane is the accepted working approach for now.
It is softer, more operational, and better suited to product delivery pressure.
```

---

## Pilot Scan: Ruflo

Ruflo is a useful reference point because it appears to grow as a runtime/product
platform for agent orchestration, while Igniter's orchestration practice is
currently stronger as governance, authority, and proof discipline.

Preliminary coordinate split:

```text
Ruflo: runtime platform, MCP/tools, swarm coordination, memory, onboarding,
       federation, UI.

Igniter orchestration: authority, bounded cards, pressure review, proof matrix,
                       decision records, portfolio supervision.
```

Useful pressure from Ruflo:

- define lite/full onboarding modes;
- make the first-run promise clearer;
- separate Current Map, Operating Guide, and Verification Log;
- evolve portfolio letters as a lightweight cross-supervisor communication
  protocol;
- learn from goal-to-plan UX without copying runtime scope.

Non-adoption:

```text
Do not copy runtime/MCP/swarm tooling into Igniter from this scan.
Do not let market excitement override gate discipline.
```

Bounded consequence:

```text
Adopt Ecosystem Pulse Scan as a recurring portfolio practice.
No runtime implementation authorized.
```

---

## Future Role Candidate

If this practice proves useful, create a dedicated role:

```text
Role: Ecosystem Pulse Analyst
Scope: external orientation, adjacent-project scans, adoption/no-op proposals
Authority: pressure and recommendation only
Cannot: authorize implementation, canon, product scope, or dependency adoption
Reports to: Portfolio Architect Supervisor
```

The role should preserve creative judgment. It must not become a crawler,
catalog maintainer, or hype aggregator.

---

## Operating Rule

The practice succeeds only if it returns with sharper judgment.

Good scan:

```text
one outside signal -> one useful pressure -> one bounded consequence
```

Bad scan:

```text
many links -> many features -> no decision
```


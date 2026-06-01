# Experimental App Consumer Todolist Intake Routing v0

Skill: IDD Agent Protocol
Status: routing-note / candidate-intake-recommended
Date: 2026-06-01

Context:
- `playgrounds/igniter-apps/todolist` exists as a small executable app
  playground.
- It consumes `playgrounds/igniter-tbackend` through the compiled Rust/Magnus
  extension.
- It is useful runtime-productization evidence, but it is not compiler-backed
  `.igapp` execution and not public runtime authority.

---

## Surface Observed

Files observed:

```text
playgrounds/igniter-apps/todolist/todo.rb
playgrounds/igniter-apps/todolist/lib/temporal_store.rb
playgrounds/igniter-apps/todolist/lib/repl.rb
playgrounds/igniter-apps/todolist/lib/ui.rb
playgrounds/igniter-apps/todolist/todo.wal
```

Read-only checks run:

```text
ruby -c todo.rb
ruby -c lib/temporal_store.rb
ruby -c lib/repl.rb
ruby -c lib/ui.rb
ruby todo.rb list
ruby todo.rb history 0fad0186
```

Observed behavior:

```text
CLI and REPL shell exist.
Todo facts persist through WAL replay.
Active todo listing works.
History view reconstructs revisions with causation links.
UI presents an app-level temporal/audit experience, not just runtime internals.
```

---

## Classification

Current classification:

```text
delegated experimental app consumer candidate
playground-only evidence
non-canonical
not compiler-backed app proof yet
not Reference Runtime support
not public runtime support
not stable API
```

This is different from the IVM/resident-supervisor lane:

```text
IVM/resident supervisor: runtime execution architecture candidate
todolist: application consumer / experimental executable UX candidate
```

Both are valuable. They should not be collapsed into one authority lane.

---

## Product Signal

The todolist app is a strong productization signal because it shows:

```text
user-facing executable flow
durable temporal state
replayable WAL state
causation history
time-travel UI vocabulary
small CLI/REPL surface
```

This moves closer to experimental use than pure opcode, bytecode, or benchmark
proofs.

---

## Gaps And Risks

Authority gaps:

```text
not emitted by Igniter-Lang compiler
not loaded from .igapp
not running through accepted Runtime Specification
not Reference Runtime
not packaged
not public API/CLI
```

Portability gaps:

```text
hardcoded local path to playgrounds/igniter-tbackend/target/release
requires prebuilt Rust extension
WAL fixture is local binary state, not generated proof output
no artifact passport
```

Semantic gaps:

```text
valid_time can be stored on facts
current query path appears transaction-time oriented
time-travel wording may overstate full bitemporal semantics
todo display uses fact revision ids more prominently than stable todo keys
```

These are not blockers for intake. They are exactly why intake is needed.

---

## Recommended Intake Route

Recommended future card:

```text
Card: S3-R230-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: delegated-experimental-app-consumer-todolist-surface-intake-v0

Route: UPDATE
Depends on:
- S3-R229-C5-S

Goal:
Produce a bounded surface/facts packet for the todolist app playground as a
delegated experimental app consumer candidate, without accepting it as
mainline runtime, Reference Runtime, public runtime support, stable API, or
compiler-backed app execution.
```

Why C2-P1 shape:

```text
This is a surface/facts packet, not implementation.
It should inventory what the app actually does before a supervisor decision.
It should be paired with an architect decision only if Main Line wants to route
app-consumer proof next.
```

Expected survey questions:

```text
What runtime/backend does todolist consume?
What commands are executable and read-only safe?
What writes happen and where?
What semantics are real: transaction_time, valid_time, causation, replay?
What is hardcoded or non-portable?
What would be required for .igapp-backed execution?
What should be forbidden from public wording?
```

Closed surfaces:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
gemspec
README / public docs
RuntimeSmoke
CompilerResult / CompilationReport
Reference Runtime
stable API
production/public runtime claims
release
Spark
```

---

## Implementation Surface Surveyor Map

Role:

```text
Implementation Surface Surveyor
```

Best agent fit:

```text
Codex or Gemini-style analysis agent
```

Why:

```text
The role needs broad file/context reading, exact surface inventory, and
discipline around "what exists" vs "what is authority".
It should not creatively extend implementation during the survey.
```

Recommended agent assignment:

```text
Primary: Codex, when the survey is tied to Main Line governance or exact cards.
Secondary: Gemini-style Research/Analysis Agent, when the slice is large,
incomplete, or needs reverse-engineering from partial code.
Avoid: Claude Implementation Agent unless the card is already narrow and
implementation-bound, because this role rewards restraint more than creativity.
```

Role responsibilities:

```text
read surfaces
classify executable paths
classify write paths
identify source/artifact/runtime boundaries
separate evidence from authority
name portability blockers
produce compact facts packet
recommend next route
```

Role non-authority:

```text
does not accept implementation
does not authorize mainline changes
does not widen public claims
does not decide product semantics
does not implement fixes during survey
```

Good card labels:

```text
C2-P1 surface facts packet
C2-P1 implementation surface survey
C2-P1 candidate intake facts
```

---

## Next-Line Recommendation

Do not interrupt the R229/R230 resident-supervisor runtime sequence.

Instead:

```text
Keep resident supervisor intake as the primary runtime architecture next move.
Add todolist app-consumer intake as a companion surface survey.
Use todolist to pressure-test experimental executable UX and portability.
Do not promote todolist to public/runtime authority.
```

If a single next route must be chosen:

```text
resident supervisor intake first
todolist surface intake second
artifact passport minimum third
experimental igc run design-only fourth
```

If the goal is market-window demo learning:

```text
todolist intake may run in parallel as C2-P1 because it is no-code/read-only
surface survey work and does not mutate authority.
```

---

## Non-Claims

This note does not authorize:

```text
code edits
playground commits
mainline implementation
igc run
Reference Runtime
public runtime support
stable API
production readiness
public demo
release execution
Spark integration
```

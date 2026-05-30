# Agent Platform Operating Model

Status: active
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-30

---

## Purpose

This document records the practical division of labor between agent platforms
used in Igniter work.

It is an operating model, not a permanent quality ranking. Platform behavior may
change with client updates, model updates, context-window handling, and product
limits. The goal is to route work to the platform shape that currently behaves
best for that slice.

Current operating split:

```text
Codex:
  control plane, long-horizon continuity, governance, cards, status,
  architecture, cross-project memory, system management

Claude:
  short-run implementation and external pressure review, strongest when the
  task is crisp and bounded

Gemini:
  broad-context reconstruction, semantic reverse engineering, large one-pass
  analysis from partial code or incomplete evidence
```

---

## Current Assignment Policy

Default assignment:

Codex:

- preferred roles: Portfolio Architect Supervisor, Lang Supervisor, Framework
  Supervisor, Research Agents, Status Curator, Meta, Archive, History;
- primary value: long-running line control, planning, memory, governance, and
  cross-project coherence.

Claude:

- preferred roles: Implementation Agent, External Pressure Reviewer;
- primary value: crisp implementation, short-run review, creative first passes,
  and outside-view pressure.

Gemini:

- preferred roles: Context Recovery / Reverse Engineering Analyst,
  large-slice Research Agent;
- primary value: meaning recovery from partial code, broad context analysis,
  and behavior reconstruction.

Current active exception:

```text
Implementation Agent: Claude
External Pressure Reviewer: Claude
All other default Main Line agents: Codex
Gemini 3.5: optional analysis/reconstruction worker, not default long-run owner
```

---

## Codex Profile

Use Codex when the task needs:

- stable long-running line ownership;
- compact card slicing and round routing;
- authority boundaries and closed-surface discipline;
- cross-project view;
- status curation and memory;
- medium/long research;
- operating-system thinking;
- synthesis across many rounds.

Observed strengths:

- keeps the main line coherent over many rounds;
- rarely drifts semantically;
- recovers from interruptions and context transitions well;
- keeps track of authority, dependencies, and next route;
- good for supervisor/control-plane work.

Observed risks:

- may over-quantize tasks into smaller slices;
- may need an explicit push toward practical implementation after long
  governance/proof sequences;
- formatting drift can happen when the required card shape is not made explicit.

Operating guard:

```text
Codex should own the line.
Codex should not endlessly shrink the next step when a practical bounded move
is already safe.
```

---

## Claude Profile

Use Claude when the task needs:

- sharply bounded implementation;
- a fresh external review;
- creative first pass;
- short-run code iteration;
- critique from outside the current Codex control plane.

Observed strengths:

- excellent first 2-3 implementation/review iterations;
- strong code production when the scope is crisp;
- useful creative pressure and outside-view analysis;
- good at finding issues when the card is clear.

Observed risks:

- stronger semantic drift after about 4-5 iterations;
- medium/long-running continuity is weaker;
- creative expansion can leave the main line if the card is underspecified;
- context-window failure can look like a plan/subscription issue, even when the
  actual issue is context overflow;
- may need archival/restart rather than continued prompting when the context
  window is saturated.

Operating guard:

```text
Claude is a burst specialist.
Use one fresh instance per card when possible.
Do not expect multi-round continuity from the same Claude thread.
```

Recommended Claude card guard:

```text
Context Budget Guard:
- Treat this as a fresh single-card run.
- Do not reconstruct full project history.
- Read only listed files unless blocked.
- Do not recursively expand scope.
- If more context is needed, stop and report exact missing inputs.
- Keep output compact.
- Do not continue into the next card.
```

When Claude turns red or stalls:

```text
First suspect context-window saturation, not subscription exhaustion.
Archive/restart the thread and provide a compact onboarding card.
```

---

## Gemini Profile

Use Gemini when the task needs:

- very broad one-pass analysis;
- reconstruction of behavior from partial code;
- semantic recovery when context is incomplete;
- reverse engineering of "what this code appears to mean";
- broad comparison or summarization across a large slice.

Observed strengths:

- good at understanding partial systems from incomplete evidence;
- can recover and describe behavior from code with surprisingly high accuracy;
- useful for broad context scans in one iteration;
- good analysis worker when the output is a packet, not a long-running line.

Observed risks:

- code writing is usable but currently weaker than Codex and Claude;
- medium-term continuity degrades after about 5-7 iterations;
- may drift even after correctly reconstructing its own previous code;
- not reliable as the owner of a long multi-round lane.

Operating guard:

```text
Gemini is a wide-context analyst.
Use it for reconstruction and broad analysis, then route the result through
Codex/Portfolio before it becomes authority or implementation.
```

Recommended Gemini card guard:

```text
Large-Slice Analysis Guard:
- Produce one compact reconstruction packet.
- Separate observed behavior from inference.
- Do not implement unless explicitly authorized.
- Do not continue into follow-up design unless routed.
- End with uncertainties and exact files/evidence used.
```

---

## Routing Rules

Prefer this routing:

- Portfolio decision / authority: Codex.
  Authority and route ownership stay in the control plane.
- Round/card slicing: Codex.
  Include full card code inside `text` fences.
- Status curation: Codex.
  Keep current-status compact; avoid narrative bloat.
- Long research / cross-project synthesis: Codex.
  Gemini may provide a broad packet first.
- Broad reverse engineering: Gemini.
  Useful when code is partial or semantics are unclear.
- Implementation: Claude.
  Use crisp one-card scope, exact write surface, and proof matrix.
- External pressure review: Claude.
  Use a fresh thread, short context, and explicit checks.
- Long-running pressure/review lane: Codex.
  Claude should not be asked to carry long continuity.
- Emergency production observation: Codex.
  Use a domain-specific worker only with a tight read-only card.

---

## Failure Modes And Recovery

### Context Saturation

Symptom:

```text
context window > 100%
agent red / stuck / refuses to continue
```

Recovery:

```text
archive thread
start duplicate fresh instance
give compact onboarding card
do not paste the full history
```

### Creative Drift

Typical with Claude after several iterations or with under-bounded cards.

Recovery:

```text
stop the thread
route through Portfolio
restart with one-card scope and explicit exclusions
```

### Over-Quantization

Typical with Codex when proof/governance pressure is high.

Recovery:

```text
ask for practical route
name the bounded implementation/review target
separate "proof quality" from "market speed"
```

### Wide-Slice Drift

Typical with Gemini after several iterations.

Recovery:

```text
keep Gemini output as analysis packet
do not ask it to carry the next lane
route the packet back through Codex/Portfolio
```

---

## Synergy Model

The intended shape is:

```text
Codex = control plane
Claude = burst implementation / burst pressure
Gemini = wide-context reconstruction
```

The platforms are strongest in combination:

- Codex preserves the long line and authority boundaries.
- Claude creates strong short-run code and critique when scoped tightly.
- Gemini reconstructs meaning from large or incomplete context.

The supervisor should treat platform choice as part of dispatch design, not as
an afterthought.

---

## Card Formatting Rule

When slicing cards for agents, every dispatchable card must be wrapped as a full
copy-paste block, including the `Card:` line:

```text
Card: S3-R214-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: example-track-v0

Route: REVIEW
...
```

Do not place `Card:` outside the fenced block. Agents may miss the card code if
the header is outside the copy-paste region.

---

## Authority Rule

Platform selection does not change authority.

```text
Claude Implementation Agent does not gain Architect authority.
Gemini analysis does not become canon by itself.
Codex supervisor decisions still need explicit card boundaries.
```

All outputs still flow through the normal card, track, pressure, decision, and
status-curation process.

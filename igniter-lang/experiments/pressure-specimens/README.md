# Language Pressure Specimens

**Purpose**  
This directory contains **hypothetical application specimens** designed specifically to pressure-test Igniter Lang.

These are **not** production-ready implementations, reference architectures, or final solutions.  
They are engineered thought-experiments created to:

- Push the language to its limits across complex, real-world domains
- Validate expressiveness, contract honesty, and syntactic clarity
- Stress-test alignment with the [Language Covenant](../docs/language-covenant.md)
- Demonstrate Forms, Profiles, External Progression, Epistemic State Machine, Effect Surface, Assumptions/Constraints, PostAudit and other emerging language features
- Serve as living artifacts for External Pressure Review and language evolution

### Status / Authority

Pressure specimens are **non-canonical** by default.

They do not authorize:

- parser syntax
- type-system changes
- runtime behavior
- stdlib implementation
- Effect Surface implementation
- production capability binding

Their lifecycle is:

```text
specimen -> pressure analysis -> extracted signal -> proposal/spec track -> implementation only after explicit gate
```

When a specimen produces useful pressure, it should be routed through a track
document instead of being left as an ambiguous experiment.

Current routed analyses:

- `docs/tracks/mundane-application-pressure-analysis-v0.md` — disposition and signal extraction route for `mundane-application-pressure-v0`.

### Philosophy

> "We develop the language by attacking it with the hardest possible problems — not by starting with hello-world and todo lists."

Each specimen is a **deliberate pressure point** on the design.  
The more ambitious and safety-critical the domain — the more valuable the specimen.

### Structure & Naming

- One self-contained `.ig` file per specimen
- Filename format: `igniter-<domain>-<scenario>-vN.ig`
- Each file contains:
    - Full module with `profile`
    - Types, assumptions, constraints
    - Contracts (including service progression where applicable)
    - Invariants, receipts, evidence chains
    - Section `WHAT THIS PROVES` — explicit mapping to Covenant postulates and language features under test

### Current Specimens

- `igniter-swarm-rescue-orchestrator-v1.ig` — Multi-drone rescue swarm with real-time decision-making under uncertainty (current focus)
- (next: news clarity duel, censorship-resistant mesh, political simulation, etc.)

### How to Use These Specimens

1. Read them as **design probes**, not code to run.
2. Use them during External Pressure Review sessions.
3. Treat every awkwardness, missing primitive, or ugly form as a **feature request** for the language.
4. They serve as input for compiler spec, Form System evolution, and runtime model.
5. Do not promote syntax or semantics from a specimen without a named proposal/spec track.

### Related Documents

- [Language Covenant](../docs/language-covenant.md) — governing philosophy
- [Contracts + Forms Research](../docs/) — current language theory
- [Agent Orchestra Pattern](../roles/) — how these specimens are reviewed

---

*These specimens are the primary mechanism through which Igniter Lang evolves from a promising idea into a truly honest, auditable, and agent-native general-purpose language.*

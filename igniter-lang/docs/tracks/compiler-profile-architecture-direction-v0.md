# Track: Compiler Profile Architecture Direction v0

Card: S3-R31-C6-A
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: compiler-profile-architecture-direction-v0
Status: done
Date: 2026-05-10

---

## Goal

Formally record the architectural direction discovered from the
Profile–Baseline–Pack pattern analysis, without authorizing a compiler rewrite.

---

## Sources

- `igniter-lang/docs/inbox/profile-baseline-pack-pattern-analysis.md`
- `packages/igniter-contracts`
- `packages/igniter-extensions`
- current igniter-lang compiler shape

---

## Decision

Adopt Profile–Baseline–Pack as the target direction for the next compiler
architecture, after the current POC compiler reaches a logical closure.

The current compiler remains the proof compiler. It should continue to close
the present Gate 3 / durable audit / PROP-032 proof path before any large
pack-based migration begins.

---

## Delivered

Created:

- `igniter-lang/docs/dev/compiler-profile-architecture-direction.md`

The document records:

- current compiler = POC / semantic wind tunnel
- future compiler = profile-assembled compiler platform
- target components: `CompilerKernel`, `CompilerPack`, `CompilerManifest`,
  `CompilerProfile`, `CompilerEnvironment`, pass registries, OOF registry,
  fragment registry
- open design questions:
  - ordered rule precedence
  - `.igapp` `compiler_profile_id`
  - greenfield packs before full migration
  - multiple implementations per capability
- non-goals and excluded surfaces

---

## Handoff

```text
Card: S3-R31-C6-A
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: compiler-profile-architecture-direction-v0
Status: done

[D] Decisions
- Profile–Baseline–Pack is accepted as post-POC target architecture.
- Current compiler remains proof compiler; no rewrite now.
- New language surfaces may be designed with future pack boundaries in mind.
- Implementation requires a later migration plan and explicit authorization.

[S] Shipped / Signals
- Added docs/dev/compiler-profile-architecture-direction.md.
- Recommended no-code research slice:
  compiler-pack-boundary-report-v0.

[T] Tests / Proofs
- Documentation-only direction record. No code or proof changes.

[R] Risks / Recommendations
- Do not start pack migration during current Gate 3 / durable audit pressure.
- Route a no-code pack-boundary report to evaluate decomposition and scope.
- Resolve ordered-rule precedence and compiler_profile_id before implementation.
```


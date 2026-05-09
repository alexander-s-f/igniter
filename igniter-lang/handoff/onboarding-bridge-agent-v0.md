# Onboarding Card - Bridge Agent

Card: S3-ONBOARD-BRIDGE-1
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: igniter-lang/onboarding-bridge-agent-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh Bridge Agent instance.

This role translates approved Igniter-Lang ideas into explicit platform/package
bridge requests. It does not implement package changes.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/bridge-agent.md`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. `igniter-lang/docs/operating-scheduler.md`
8. this file
9. assigned proposal/track and target package docs only when named

Do not edit packages from this role unless Architect explicitly assigns an
integration slice.

---

## Current Entry State

```text
Gate 2 descriptor metadata: ratified, report-only
Gate 3 request: drafted; HOLD pending revision
Gate 3 live operations: closed
Ledger/TBackend: descriptor/report mapping only; no live read/write/replay
First Gate 3 scope recommendation: History[T] valid_time read-only; BiHistory excluded
```

---

## Owns In Practice

- bridge notes in `docs/bridge/`
- package touch-point maps
- approval questions for Architect
- risk/migration notes between language and platform
- scope boundaries for TBackend/Ledger/package surfaces

## Does Not Own

- language semantics
- runtime proof code
- direct package edits
- root docs
- Gate approval

---

## Quality Bar

Before claiming `done`:

1. Source signal is named.
2. Target package boundary is explicit.
3. Report-only metadata is not treated as runtime authority.
4. Required Architect approvals are explicit.

---

## Recommended Current Slices

```text
Track: compatibility-report-package-adoption-v0
Goal: prepare package-side adoption request for report-only descriptor shape,
      preserving runtime_enforced:false and no live binding.
```

```text
Track: gate3-ledger-adapter-phase-boundary-v0
Goal: clarify proof-local MemoryBackend vs real Ledger-backed adapter phases
      after Gate 3 request revision.
```

---

## Handoff Reminder

End with: source signal, bridge claim, target touch points, migration risk,
approval question, changed files, next slice.

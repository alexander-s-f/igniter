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
Gate 3 Phase 1: signed-approved-restricted live read (R20)
Phase 1 production durable audit: bounded implementation authorized (S3-R30-C1-A)
Ledger/TBackend Phase 2: closed; real Ledger adapter/package binding requires separate Architect addendum
Still closed: BiHistory, stream/OLAP production executor, production cache, broad RuntimeMachine binding,
              concrete HSM/KMS onboarding, production deployment
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
Track: production-durable-audit-package-boundary-map-v0
Goal: map the bounded audit implementation touch points to package/platform
      boundaries without authorizing Ledger, Phase 2, or deployment.
```

```text
Track: ledger-adapter-phase2-boundary-v0
Goal: keep the real Ledger-backed TBackend adapter as a separate future Gate
      addendum; do not infer it from Phase 1 audit authorization.
```

---

## Handoff Reminder

End with: source signal, bridge claim, target touch points, migration risk,
approval question, changed files, next slice.

# Track: PROP-036 Compiler Profile ID Manifest Proposal v0

Card: S3-R34-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-compiler-profile-id-manifest-proposal-v0`
Status: done
Proposal lifecycle at card close: authored-pending-review (track done did not imply accepted; S3-R35-C3-A later accepted proposal-only)
Date: 2026-05-11

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`,
`[Architect Supervisor / Codex]`

---

## Goal

Author the formal PROP-036 document for `compiler_profile_id` manifest identity,
using the Architect numbering decision and prior compiler-profile promotion
packet as source evidence.

---

## Source Evidence

Read:

- `docs/gates/compiler-profile-manifest-prop-number-decision-v0.md`
- `docs/tracks/compiler-profile-manifest-prop-review-ready-v0.md`
- `docs/tracks/compiler-profile-manifest-prop-promotion-v0.md`
- `docs/tracks/compiler-profile-shadow-chain-dependency-index-v0.md`
- `docs/proposals/README.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/dev/canonical-semantic-model.md`
- `docs/dev/semantic-governance-heat-map.md`

Also consulted the profile manifest boundary and Architect routing tracks for
field-shape and authority firewall details.

---

## Decision

[D] PROP-036 is now authored as:

```text
docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md
```

[D] The proposal uses the Architect decision only as numbering authority. It
does not treat numbering as approval or implementation authorization.

[D] The manifest authority source is the unified compiler profile id:

```text
compiler_profile_unified/sha256:<digest>
```

Ordered-rule profile ids remain supporting evidence / transition diagnostics,
not the canonical manifest authority in this proposal.

[D] The hard authority firewall is preserved:

```text
compiler_profile_status.present_verified
  does not imply
runtime_evaluation_readiness.ready
```

---

## Shipped

[S] Added PROP-036 proposal text with:

- top-level `compiler_profile_id` field shape;
- `legacy_optional` and future `profile_required` rollout policy;
- loader status vocabulary:
  `absent_legacy`, `present_verified`, `mismatch`, `malformed`,
  `missing_required`;
- CompatibilityReport policy and reason codes;
- artifact hash/signing ordering;
- `CompilerProfile` vs `CompilationReceipt` separation;
- explicit non-authorizations;
- implementation blockers before code cards.

[S] Updated `docs/proposals/README.md`:

- PROP-036 moved from queued numbering-only slot to authored Stage 3 proposal.
- Queue keeps PROP-033..035 unchanged.
- Managed recursion/service loops remain `PROP-037+` placeholder only.

---

## Non-Authorizations Preserved

PROP-036 does not authorize:

- `.igapp` manifest mutation;
- `.ilk` format mutation;
- assembler implementation;
- loader implementation;
- RuntimeMachine binding;
- CompatibilityReport implementation changes;
- artifact hash/golden migration;
- CompilationReceipt manifest links;
- compiler dispatch migration;
- parser syntax;
- runtime execution authority;
- Gate 3 widening;
- Ledger, Phase 2, BiHistory live execution, stream/OLAP production executors,
  production cache, or production deployment.

---

## Implementation Blockers

Before any code card, the proposal requires:

1. PROP-036 acceptance by the owning governance flow.
2. Explicit Architect/supervisor authorization for the implementation card.
3. A single named surface per card:
   - `assembler-compiler-profile-id-field-v0`
   - `loader-compiler-profile-status-report-v0`
   - `artifact-hash-profile-id-golden-migration-v0`
   - `compilation-receipt-manifest-link-v0`
4. Proof that `compiler_profile_id` changes artifact hash material before
   assembler/golden migration is accepted.
5. Separate loader/report tests for absent legacy, present verified, mismatch,
   malformed, and missing-required states.
6. Stable manifest ordering before receipt links.
7. No migration from `legacy_optional` to `profile_required` until migration
   evidence exists.

---

## Tests / Proofs

[T] Docs-only proposal authoring. No runtime/compiler proof was run because the
card explicitly forbids implementation and `.igapp` mutation.

Sanity checks:

```text
rg "PROP-036" igniter-lang/docs/proposals/README.md
rg "compiler_profile_id" igniter-lang/docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md
```

---

## Handoff

```text
Card: S3-R34-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/prop036-compiler-profile-id-manifest-proposal-v0
Status: done

[D] Decisions
- Authored PROP-036 as compiler_profile_id manifest identity.
- Preserved Architect numbering-only authority.
- Chose unified compiler profile id as the manifest authority source.
- Preserved the firewall: present_verified is not runtime-ready.

[S] Shipped / Signals
- Added PROP-036 proposal text.
- Updated proposals README from queued numbering-only to authored proposal.
- Listed explicit non-authorizations and code-card blockers.

[T] Tests / Proofs
- Docs-only; no compiler/runtime tests run.
- Sanity rg checks are sufficient for this non-code card.

[R] Risks / Recommendations
- Do not open assembler/loader/golden migration until PROP-036 is accepted and
  a separate implementation card is authorized.
- Keep CompilationReceipt links blocked until manifest ordering is stable.
- Keep compiler dispatch migration separate from manifest identity.

[Next] Suggested next slice
- Governance review/acceptance decision for PROP-036, then a narrowly scoped
  report-only loader status proof or assembler field proof if authorized.
```

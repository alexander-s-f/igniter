# Track: Compiler Profile Contract Bridge Surface Review v0

Card: S3-R57-C2-P1
Agent: `[Igniter-Lang Bridge Agent]`
Role: bridge-agent
Track: `compiler-profile-contract-bridge-surface-review-v0`
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Implementation Agent]`

---

## Scope

Review future bridge/reporting implications of compiler-profile contract
boundary design without creating loader/report schema, CompatibilityReport
schema, package changes, runtime behavior, CLI behavior, dispatch migration, or
production authorization.

This is a design-pressure report only.

---

## Inputs Read

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/bridge-agent.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/operating-model.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/gates/compiler-profile-obligation-coverage-proof-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-obligation-coverage-proof-v0.md`
- `igniter-lang/docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-contract-formalization-options-v0.md`
- Provisional neighbor context observed from
  `igniter-lang/docs/tracks/compiler-profile-contract-boundary-v0.md`; treated
  as draft context, not as independent authorization.

---

## Current Horizon

- R56 accepts obligation coverage as proof-local, report-only, and output-only.
- Accepted obligation statuses are `covered`, `missing_slot`,
  `unsupported_surface`, and `profile_not_supplied`.
- PROP-036 allows compiler-profile manifest identity as compiler understanding,
  not runtime authority.
- Loader/report and CompatibilityReport compiler-profile surfaces remain closed.
- R57 boundary work is design-only; implementation remains held.

---

## Design Pressure

The bridge pressure is not "how do packages load compiler profiles?" yet. The
pressure is how future report surfaces can carry compiler-understanding evidence
without collapsing four separate layers:

```text
compiler_profile_source.*
  -> compiler_profile_obligation.*
  -> compiler_profile_contract.*
  -> loader/report status vocabulary
```

The report bridge must preserve this invariant:

```text
profile transport != profile coverage != runtime readiness
```

---

## Future Loader / Report Needs

Future loader/report surfaces would need obligation coverage only as
report-facing evidence. They would need:

- the manifest-level profile identity and rollout interpretation from PROP-036;
- the obligation coverage result produced after detected program surfaces are
  known;
- the artifact or SemanticIR evidence references that explain which surfaces
  were detected;
- the required slot list derived from those surfaces;
- the supplied profile slot evidence, when a finalized profile source exists;
- a reasoned distinction between `absent_legacy`, `present_verified`,
  `mismatch`, `malformed`, and `missing_required` loader/report status and
  `covered`, `missing_slot`, `unsupported_surface`, and `profile_not_supplied`
  obligation status;
- explicit non-authority flags showing no runtime, dispatch, production, or
  Gate 3 authority follows from the report.

They must not need a full compiler contract object yet. They also must not treat
an obligation report as loader acceptance.

---

## Future CompatibilityReport Needs

Future CompatibilityReport surfaces would need obligation coverage as one
compiler-profile evidence dimension, not as the readiness verdict.

The future report would need enough data to say:

- what compiler profile the artifact claims or supplies;
- whether the profile identity was absent, verified, mismatched, malformed, or
  required-missing under a stated rollout policy;
- whether the program's detected surfaces were covered by the supplied profile
  slots;
- which surfaces or slots caused report-only warning/blocking diagnostics;
- where the evidence links live;
- that `runtime_enforced` remains false unless a separate future gate changes
  it;
- that runtime readiness still depends on runtime compatibility, approval
  tokens, Gate 3 scope, executor/backend readiness, and other non-profile
  checks.

CompatibilityReport must not merge compiler-profile status into
`runtime_evaluation_readiness.ready`.

---

## Bridge / Report Implication Table

| Signal | Origin | Future loader/report implication | Future CompatibilityReport implication | Must not imply |
| --- | --- | --- | --- | --- |
| `manifest.compiler_profile_id` / profile ref | PROP-036 / finalized source transport | Report the artifact's compiler-understanding identity and compare expected vs declared profile under a rollout policy. | Safe as compiler-profile identity metadata with reason codes. | Surface coverage, dispatch migration, runtime readiness, signing completeness. |
| `present_verified` | PROP-036 loader/report vocabulary | Means manifest profile identity matched the expected profile under the active policy. | May become a compiler-profile identity status only. | Covered SemanticIR surfaces, valid contract schema, load/evaluate readiness. |
| Detected surfaces | R56 obligation proof | Explain which program surfaces were observed from existing artifact evidence. | Safe as report evidence for coverage diagnostics. | Parser or runtime support for future/unknown surfaces. |
| Required slots | R56 surface -> slot rules | Show what compiler-profile slots the detected surfaces require. | Safe as diagnostic detail for coverage status. | That supplied slot handlers exist or execute. |
| Supplied slots / slot order | Finalized profile source | Compare profile slots to required slots for obligation coverage. | Safe as compiler-understanding metadata. | Pack loading, current compiler dispatch order, runtime capability. |
| `covered` | R56 obligation vocabulary | Report-only coverage success for selected detected surfaces. | May become a positive evidence item. | Loader acceptance, compile acceptance, runtime readiness, production authority. |
| `missing_slot` | R56 obligation vocabulary | Report a profile-present coverage gap. | May become warning/blocking metadata only if a later gate defines severity. | Compile refusal or load refusal by default. |
| `unsupported_surface` | R56 detector guard | Report that the detector saw a surface it cannot map. | Safe as diagnostic uncertainty. | A new language feature, parser support, or runtime support. |
| `profile_not_supplied` | R56 obligation vocabulary | Report that no supplied profile could be compared; required slots may still be shown as evidence. | Safe as report-only profile absence detail. | Same thing as loader `missing_required` or contract `missing_required_slot`. |
| `compiler_profile_contract.*` diagnostics | Future contract proof/design | Keep as compiler-only semantic contract validation vocabulary until separately authorized. | Should not appear as loader/report statuses unless explicitly adapted later. | Loader refusal, CompatibilityReport readiness, runtime authority. |
| Output-only flags | R56 proof / gate decision | Carry forward as report disclaimers if exposed. | Safe guardrail metadata. | That the report controls execution. |

---

## Vocabulary Boundary

### Compiler-Only Vocabulary

Keep these compiler-side unless a later gate defines a report adapter:

- `compiler_profile_source.*`
- `compiler_profile_obligation.*`
- `compiler_profile_contract.*`
- slot ownership terms such as `slot_order`, `slot_assignments`, strict
  registry ownership, ordered rule references, rule cycles, pack refs, and
  finalization payload digests.

These terms answer compiler-understanding questions. They should not become
loader/report statuses by direct copy.

### Loader / Report-Facing Vocabulary

Loader/report-facing language should stay at interpretation level:

- `absent_legacy`
- `present_verified`
- `mismatch`
- `malformed`
- `missing_required`
- evidence refs;
- policy name such as `legacy_optional` or future `profile_required`;
- non-authority flags;
- summarized coverage status, if a later gate opens it.

The report layer may refer to compiler evidence, but it should not become the
owner of compiler contract validation.

---

## Why Green Profile Identity Is Not Coverage Or Readiness

`present_verified` only says the manifest profile id matched an expected
profile identity under the active loader/report policy. It does not prove that
the emitted SemanticIR surfaces were checked against profile slots.

A manifest profile match is even narrower: it names compiler understanding for
the artifact. It does not carry the full obligation report, contract schema,
strict registries, ordered rules, pack handler availability, or runtime
capability checks.

Therefore:

```text
present_verified
  != obligation covered
  != compiler_profile_contract valid
  != runtime_evaluation_readiness.ready
```

Runtime readiness remains separately governed by load/eval compatibility,
runtime gate state, approval token state, executor/backend scope, cache-key
rules, TBackend/Ledger gates, and production authorization.

---

## Safe Report-Only Fields If A Later Gate Opens Them

Safe only as report metadata:

- `kind`
- `format_version`
- `case`
- `profile_ref`
- `manifest_profile_id`
- `expected_profile_id`
- `rollout_policy`
- `profile_identity_status`
- `obligation_status`
- `detected_surfaces`
- `required_slots`
- `supplied_slots`
- `missing_slots` for profile-present comparison failures
- `unsupported_surface_refs`
- `artifact_refs`
- `semantic_ir_refs`
- `profile_source_ref`
- `profile_authority.compiler_understanding_only`
- `runtime_authority_granted: false`
- `dispatch_migration_authorized: false`
- `output_only` flags
- `evidence_refs`
- `reason_code`
- `warnings`
- `non_authorization`

These fields are safe only when the carrier states report-only semantics and
does not make them execution gates.

---

## Forbidden Implications

The following implications must remain forbidden:

- `present_verified` implies obligation coverage.
- `covered` implies loader acceptance.
- `covered` implies compile success or compile refusal policy.
- `missing_slot` implies compile refusal without a separate enforcement gate.
- `profile_not_supplied` is equivalent to loader `missing_required`.
- manifest profile match implies valid `compiler_profile_contract`.
- slot presence implies handler availability or live dispatch.
- slot order implies current compiler dispatch migration.
- pack refs imply pack loading.
- any compiler-profile report implies RuntimeMachine load/evaluate readiness.
- any compiler-profile report grants Gate 3, executor/backend, Ledger/TBackend,
  stream/OLAP, cache, production, CLI, `.igapp`, `.ilk`, signing, or receipt
  authority.

---

## Recommendation To C1 / C3 / C4

[R] C1 / Compiler boundary:
Keep the compiler-profile contract boundary as a compiler-understanding design.
The next safe step remains proof-local validation of contract vocabulary and
ordering. Do not reuse loader/report terms as contract diagnostics.

[R] C3 / Loader-report bridge:
If loader/report work is later opened, request a separate report-only adapter
that consumes identity status plus obligation coverage evidence. That adapter
should carry explicit non-authority flags and should not define runtime
readiness.

[R] C4 / CompatibilityReport:
If CompatibilityReport work is later opened, add only a report-only
compiler-profile evidence dimension. It must preserve separate fields for
identity status, obligation coverage status, evidence refs, and
non-authorization. `runtime_enforced` should remain false unless a later
Architect decision explicitly changes it.

---

## Non-Authorization

This track does not authorize:

- loader/report implementation;
- loader/report schema;
- CompatibilityReport implementation;
- CompatibilityReport schema;
- compiler implementation;
- compiler dispatch migration;
- pack loading;
- CLI or Ruby API changes;
- `.igapp`, `.ilk`, receipt, signing, or golden changes;
- RuntimeMachine or Gate 3 widening;
- production runtime, production cache, stream/OLAP execution, Ledger/TBackend,
  BiHistory, or package changes.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/compiler-profile-contract-bridge-surface-review-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Implementation Agent

[D] Decisions:
- Treated this as bridge/report pressure only, not schema or implementation.
- Split future report needs into identity status, obligation coverage evidence,
  and non-authorization flags.
- Kept compiler-only vocabularies separate from loader/report vocabulary.

[R] Recommendations:
- C1: keep compiler-profile contract proof-local and compiler-owned.
- C3: open a separate report-only adapter only if Architect approves
  loader/report work.
- C4: keep any future CompatibilityReport compiler-profile section
  report-only with `runtime_enforced: false`.

[S] Signals:
- R56 accepted obligation coverage as output-only/report-only with 18 checks
  passing.
- PROP-036 explicitly states `present_verified` does not imply runtime
  readiness.
- R57 boundary pressure shows `missing_slot`, `missing_required_slot`, and
  `missing_required` must remain separate.

[T] Tests / Proofs:
- Documentation-only slice.
- No code, package, loader/report, CompatibilityReport, `.igapp`, CLI, or
  runtime changes.

[Files] Changed:
- `igniter-lang/docs/tracks/compiler-profile-contract-bridge-surface-review-v0.md`

[Q] Open Questions:
- Should a later gate define a report-only adapter from
  `compiler_profile_obligation.*` to loader/report vocabulary?
- Should a later CompatibilityReport section expose raw compiler vocabulary or
  only summarized report vocabulary?

[X] Rejected:
- Treating `present_verified` as surface coverage.
- Treating profile coverage as runtime readiness.
- Promoting compiler contract diagnostics into loader/report statuses directly.

[Next] Proposed next slice:
- Architect decision on whether to open a report-only loader/report adapter
  design, after compiler-profile contract proof direction is settled.
```

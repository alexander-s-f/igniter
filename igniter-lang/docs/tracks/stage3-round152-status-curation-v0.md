# Stage 3 Round 152 Status Curation

Card: S3-R152-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round152-status-curation-v0
Status: done
Date: 2026-05-23

---

## Summary

R152 is closed as a status-curation round.

The Lang Supervisor accepts the source-mode/static-data boundary design with
status `accepted-proof-only-next`. Static data remains a design/proof candidate
only; it is not compiler authority, internal library data, generated index,
public discovery/defaulting, manifest identity, report/artifact state, runtime
authority, Spark fixture/spec authority, or production behavior.

Current next-route pointer:

```text
compiler-profile-source-mode-static-data-boundary-proof-v0
```

That route is proof-only. It does not authorize implementation, public surfaces,
report/artifact work, Spark integration, runtime, production, or demo work.

## Evidence Read

- `compiler-profile-source-mode-static-data-boundary-design-v0.md`
- `../discussions/compiler-profile-source-mode-static-data-boundary-pressure-v0.md`
- `../gates/compiler-profile-source-mode-static-data-boundary-decision-v0.md`
- `stage3-round151-status-curation-v0.md`
- `../current-status.md`

## R152 Outcome

| Card | Output | Status |
|------|--------|--------|
| S3-R152-C1-D | Source-mode/static-data boundary design | done |
| S3-R152-C2-X | Source-mode/static-data pressure review | proceed; 7/7 checks PASS; no blockers |
| S3-R152-C3-A | Lang Supervisor decision | accepted-proof-only-next |
| S3-R152-C4-S | Status curation | done |

Boundary status:

- accepted, not held;
- design accepted as architecture boundary;
- implementation not authorized;
- next route is proof-only.

## Accepted Boundary Status

Accepted statuses:

- static data: design/proof candidate only;
- proof fixture static data: allowed only as future synthetic proof-local data;
- internal library static data: not authorized;
- generated index: not authorized;
- future profile assembly input: design relationship only;
- `profile_candidate`: internal source mode owning selected pack set/order and
  aggregate conflict policy;
- `pack_descriptor_candidate`: internal source mode owning row identity,
  provenance, and row-local claims;
- `finalized_internal`: internal assembly state only, not PROP-036 identity;
- adapter helper evidence: prior compatibility/proof-local evidence only, not
  classifier authority;
- PROP-036 and PROP-038: inputs only, not widened authority;
- Spark pressure: external applied pressure only.

## Required Carry-Forward Notes

The next proof-only route must carry the C2-X/C3-A proof requirements:

- use a minimal non-trivial synthetic static-data shape with at least one pack
  descriptor row, one profile candidate reference to the selected pack, and one
  pack-row ownership conflict or duplicate ownership rejection case;
- restate relevant closed-surface assertions from prior internal profile
  assembly/source-mode gates explicitly;
- name exact PROP-036 vocabulary tokens for negative scans:
  `compiler_profile_id`, `compiler_profile_id_source`,
  `compiler_profile_source`, `profile_source`, `profile finalization`,
  `manifest identity`, `default profile`, `named profile`,
  `profile discovery`.

## Role Hygiene Note

`compiler-profile-architect` is not a standing Igniter-Lang role.

For R152/R153 routing, treat it as a borrowed lens / specialization label for
compiler-profile architecture work. Standing-role ownership remains with the
assigned Igniter-Lang role on the actual card.

## Spark Pressure Disposition

Spark remains external applied pressure only.

R152 does not authorize Spark access, Spark fixture creation, Spark spec
pressure, Spark integration, compiler changes derived from Spark, production
integration, or demo work.

Portfolio review is required before any later route opens Spark-derived
fixtures/specs, implementation, public/report/artifact exposure, runtime,
production, or demo behavior.

## Exact Next Allowed Boundary

```text
Card: S3-R153-C1-P1
Track: compiler-profile-source-mode-static-data-boundary-proof-v0
Route: UPDATE
Mode: proof-only
```

Allowed write scope:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/**
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
```

The proof route must not request implementation acceptance. It may recommend a
later decision card only after proof results are recorded.

## Closed Surfaces

R152 does not authorize:

- implementation;
- root require;
- classifier wiring or live classifier dispatch;
- `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, report, or `.igapp` edits;
- `ClassifiedProgram` schema changes;
- public API/CLI;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport changes;
- manifest, sidecar, artifact hash, or golden migration;
- shared fixtures;
- generated indexes;
- internal library static data;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

## Demo-Shadow Note

R152 preserves later demo usefulness as a note only. No demo lane, demo fixture,
demo artifact, Spark demo, production-facing scenario, or public narrative
artifact is opened by this round.

---

## Round Receipt

```text
round: S3-R152
line: compiler-mainline / source-mode-static-data-boundary
status: closed
closed_by: S3-R152-C4-S
  doc: igniter-lang/docs/tracks/stage3-round152-status-curation-v0.md
decision: accepted-proof-only-next
boundary_status: accepted
next_route: compiler-profile-source-mode-static-data-boundary-proof-v0
next_route_card: S3-R153-C1-P1
next_route_mode: proof_only
role_hygiene: compiler-profile-architect_is_not_standing_role
spark_pressure_status: applied_pressure_only
implementation_authorized: no
public_surface_authorized: no
report_artifact_authorized: no
spark_integration_authorized: no
runtime_production_authorized: no
demo_work_authorized: no
```

---

## Handoff

[D] R152 accepts the source-mode/static-data boundary design and opens only the
bounded proof route next.

[S] Static data remains a design/proof candidate only. Profile/pack source-mode
authority remains internal. `finalized_internal` remains internal-only.
PROP-036/PROP-038 and Spark are inputs, not widened authority.

[T] Status docs only. No code or tests were run by this status-curation card.

[R] Do not open implementation, public surfaces, report/artifact work, Spark
integration, runtime, production, or demo work from R152.

[Next] Run `compiler-profile-source-mode-static-data-boundary-proof-v0` as
S3-R153-C1-P1, proof-only.

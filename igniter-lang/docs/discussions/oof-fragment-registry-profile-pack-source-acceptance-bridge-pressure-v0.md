# OOF/Fragment Registry Profile/Pack Source Acceptance Bridge Pressure v0

Card: LANG-R120-X
Agent: `[Igniter-Lang Bridge Agent]`
Role: bridge-agent
Mode: discussion
Track: `oof-fragment-registry-profile-pack-source-acceptance-bridge-pressure-v0`
Route: UPDATE
Depends on: LANG-R119-D1
Status: complete
Date: 2026-05-21

---

## Question

Do the LANG-R119 source-acceptance preconditions contain hidden bridge, public,
report, compatibility, `.igapp`, PROP-036, PROP-038, runtime, or production
leakage before any implementation authorization review?

---

## Inputs Read

- `igniter-lang/roles/base-role.md`
- `igniter-lang/roles/bridge-agent.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/discussions/README.md`
- `igniter-lang/docs/tracks/oof-fragment-registry-profile-pack-source-acceptance-preconditions-design-v0.md`
  (LANG-R119-D1)
- `igniter-lang/docs/gates/oof-fragment-registry-source-authority-model-acceptance-decision-v0.md`
  (LANG-R118-A)
- `igniter-lang/docs/tracks/oof-fragment-registry-source-authority-precedence-proof-v0.md`
  (LANG-R117-P1)
- `igniter-lang/docs/tracks/oof-fragment-registry-source-authority-design-v0.md`
  (LANG-R116-D1)
- `igniter-lang/docs/tracks/oof-fragment-registry-profile-pack-source-mode-proof-v0.md`
  (LANG-R115-P1)

No code, package, compiler, runtime, report, `.igapp`, or fixture files were
edited.

---

## Verdict

```text
proceed-with-nonblockers
```

R119 is safe to proceed to Architect implementation authorization review as a
precondition packet. It does not itself authorize implementation, does not change
`SOURCE_ACCEPTED_MODES`, and does not open public/report/runtime surfaces.

No blocker amendments are required.

Two non-blocking wording amendments are recommended before or inside the
Architect review to reduce future misread risk.

---

## Bridge Pressure Matrix

| Surface | R119 pressure result | Verdict |
| --- | --- | --- |
| Internal helper result shape | R119 keeps the extension inside `oof_fragment_registry_source_validation`, nested under source-envelope validation, with no new public result family. It also requires source authority validation before nested registry validation. | PASS |
| Public API / CLI | R119 explicitly forbids public API/CLI source-shape widening and says no new public API/CLI result keys. | PASS |
| Loader / report | R119 explicitly forbids loader/report writes, sidecars, loader reports, and status behavior. Loader/report review is only a future bridge requirement if that surface is separately opened. | PASS |
| CompatibilityReport | R119 keeps CompatibilityReport closed and requires separate Bridge review before registry source evidence could become report-only metadata or readiness evidence. | PASS |
| `.igapp` / manifest | R119 forbids `.igapp/manifest.json` changes, `compiler_profile_id` derivation/rewrite, assembler field changes, `.igapp`, `.ilk`, golden, or sidecar mutation. | PASS |
| PROP-036 | R119 correctly separates `profile_candidate` from compiler profile identity. It forbids loader/report `present_verified`, profile discovery/defaulting/finalization, and public Ruby/CLI widening. | PASS |
| PROP-038 | R119 forbids `CompilerProfileContractValidator` behavior changes, `compiler_profile_contract_validation.diagnostics` shape changes, strict-refusal trigger/result changes, and promotion of `compiler_profile_contract.*` diagnostics into OOF descriptors. | PASS |
| Runtime / production | R119 keeps RuntimeMachine, Gate 3, Ledger/TBackend, cache, signing, production, and Spark behavior closed. | PASS |
| `SOURCE_ACCEPTED_MODES` | R119 repeatedly states `SOURCE_ACCEPTED_MODES` must not change without explicit Architect authority. | PASS with NB-2 wording improvement |

---

## Internal Helper Result Shape

R119's candidate result shape is bridge-safe because it is internal-only:

```text
result.kind: oof_fragment_registry_source_validation
result.source_mode: profile_candidate | pack_descriptor_candidate
result.valid: true | false
result.diagnostics: []
result.source_authority: { ... }
result.registry_validation: <nested existing registry validation result or null>
result.closed_surface_assertions: { ... all closed surfaces false ... }
```

Safe properties:

- it does not create a public helper result family;
- diagnostics stay under source-envelope helper output;
- nested registry validation is not run until source authority and aggregation
  pass;
- `closed_surface_assertions` document non-authority instead of creating
  report-facing readiness metadata.

Bridge caution:

`closed_surface_assertions` must remain internal validation payload unless a
separate report/CompatibilityReport gate opens a carrier. R119 already says this
in substance; NB-1 suggests making the future-acceptance wording sharper.

---

## Leakage Findings

### Public API / CLI

No leakage found.

R119 explicitly forbids:

- new public API/CLI result keys;
- caller-facing source shape;
- public Ruby API or CLI source-shape widening;
- profile loading via public paths.

### Loader / Report

No leakage found.

R119 does not define loader/report behavior. It only says future Bridge review
must define accepted input source, report fields, legacy/no-source behavior, and
status vocabulary if that surface is later opened.

That is correct: it keeps loader/report as a future closed candidate, not an
implicit consumer of the helper result.

### CompatibilityReport

No leakage found.

R119 asks a future bridge review to decide whether registry source evidence is
report-only metadata, readiness evidence, or excluded. Until then,
CompatibilityReport stays closed.

### `.igapp` / Manifest

No leakage found.

R119 explicitly blocks:

- `.igapp/manifest.json` change;
- `compiler_profile_id` derivation or rewrite;
- assembler field changes;
- artifact/golden mutation.

### PROP-036

No leakage found.

R119 uses the right allowed/forbidden wording split:

Allowed:

```text
profile_candidate is an internal source-envelope candidate for OOF/fragment
registry provenance.
```

Forbidden:

```text
profile_candidate is the compiler_profile_id source for artifacts.
```

This prevents profile/pack source authority from becoming manifest profile
identity.

### PROP-038

No leakage found.

R119 blocks:

- validator behavior mutation;
- report-only integration mutation;
- strict-refusal mutation;
- `compiler_profile_contract.*` diagnostics becoming OOF descriptors;
- compiler profile contract validity becoming OOF source authority.

This preserves the R115/R116/R117 exclusion of
`compiler_profile_contract.*` and `compiler_profile_contract_refusal.*`.

### Runtime / Production

No leakage found.

R119 does not route RuntimeMachine, Gate 3, Ledger/TBackend, production cache,
signing, Spark behavior, or deployment surfaces.

---

## Blocker Amendments

None.

R119 can proceed to an Architect implementation authorization review as a
precondition/design packet, provided the review itself does not authorize
`SOURCE_ACCEPTED_MODES` changes without naming exact write scope and proof
requirements.

---

## Non-Blocking Amendments

### NB-1: Clarify "accepted candidate modes" wording

R119 says:

```text
Accepted candidate modes do not require a new public helper result family.
```

This is understandable in context, but a future reader could misread
"accepted candidate modes" as already accepted live helper modes.

Suggested replacement:

```text
If a future Architect gate accepts `profile_candidate` or
`pack_descriptor_candidate`, that acceptance does not require a new public helper
result family.
```

This is non-blocking because R119 repeatedly states implementation remains held.

### NB-2: Split pre-review and post-authorization `SOURCE_ACCEPTED_MODES` checks

R119's parity assertion says:

```text
SOURCE_ACCEPTED_MODES changed only by the authorized implementation card;
```

Before authorization, the safer bridge wording is:

```text
Pre-authorization review assertion:
SOURCE_ACCEPTED_MODES remains unchanged.

Post-authorization implementation proof assertion, if an Architect gate opens the
mode transition:
SOURCE_ACCEPTED_MODES changed only inside the named authorized implementation
card and only for the modes named by that gate.
```

This avoids implying that the authorization review itself may silently perform or
assume the mode transition.

---

## Exact Blocker Amendments If Any

```text
none
```

If the Architect wants a stricter gate posture, NB-1 and NB-2 can be promoted to
wording requirements inside the implementation authorization review, but they do
not require holding R119.

---

## SOURCE_ACCEPTED_MODES

This pressure review does not authorize changing `SOURCE_ACCEPTED_MODES`.

Current fixed point remains:

```text
SOURCE_ACCEPTED_MODES = proof_fixture caller_supplied
SOURCE_HELD_MODES     = profile_candidate pack_descriptor_candidate
```

Any future change requires explicit Architect implementation authorization that
names:

- exact modes moved;
- exact write scope;
- exact helper result behavior;
- parity/proof matrix;
- preserved closed public/report/runtime surfaces.

---

## [Agree]

- R119 correctly treats profile/pack candidate acceptance as a future
  implementation-authorization question, not a proof consequence.
- The internal helper result shape is bridge-safe if it remains internal-only.
- PROP-036 and PROP-038 non-mutation conditions are explicit and sufficient for
  pre-authorization review.
- Loader/report, public API/CLI, CompatibilityReport, `.igapp`, runtime, and
  production surfaces remain closed.

## [Challenge]

- The phrase "Accepted candidate modes" should be future-qualified to avoid
  sounding like live helper acceptance already happened.
- The parity assertion about `SOURCE_ACCEPTED_MODES` should distinguish the
  pre-authorization invariant from a post-authorization implementation proof.

## [Missing]

- No blocker is missing for bridge safety.
- A future Architect review still needs exact write scope, exact proof commands,
  and explicit mode-transition authority before implementation.

## [Sharper Question]

What is the smallest implementation authorization that can move exactly one or
both held source modes while proving no public/report/compatibility/manifest/
PROP/runtime behavior changes?

## [Route]

```text
review
```

Proceed to Architect implementation authorization review with NB-1/NB-2 as
non-blocking wording notes. Do not implement and do not change
`SOURCE_ACCEPTED_MODES` from this discussion.

# Track: Semantic Domain Reconciliation v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Reconcile the completed practical Igniter-Lang tracks with the formal
corrections from the Compiler/Grammar Expert.

This is not a new theory track and not a package bridge. It is a compact
alignment slice: decide how `observable-contract-language-v0`,
`observable-spine-v0`, and `failure-observation-v0` should absorb the strongest
corrections from `META-001` and `PROP-001` without losing their practical
clarity.

## Source Horizon

- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/proposals/META-001-compiler-grammar-expert-entry.md`
- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/proposals/PROP-002-contract-composition-algebra-v0.md`
- `igniter-lang/docs/agent-motion.md`

## Compact Claim

[D] Accept `PROP-001` as the formal anchor for the three completed practical
tracks, while preserving those tracks as practical research slices.

The practical tracks remain useful because they describe product pressure,
bridge candidates, and human/agent ergonomics. `PROP-001` now owns the formal
terms:

```text
V   values
T   types
Tt  explicit temporal context
C   contracts as named finite DAGs
Expr decidable expression subset
O   observations as semantic values
F   failures as failure observations
```

Future practical tracks should cite this semantic domain rather than redefining
contract, observation, temporal context, or failure status from scratch.

## Accepted Corrections

### Law 3 / Law 6 Temporal Reconciliation

[D] Accept the C/G Expert correction.

Restated Law 3:

```text
The default core is a finite, stratified dependency graph parameterized over an
explicit temporal context Tt. Each evaluation at a fixed Tt is a closed
computation.
```

Practical implication:

- `as_of`, rule version, replay cursor, and causal clock do not make the graph
  open-world by themselves.
- They are part of `Tt`.
- `eval(G, Tt, inputs)` is deterministic at fixed `G`, `Tt`, and inputs.
- Temporal forks are different evaluations, not hidden mutation of one graph.

### Observation Envelope Field Groups

[D] Accept the Identity / Provenance / Policy split.

Errata for `observable-spine-v0`:

| Group | Fields | Meaning |
|-------|--------|---------|
| Identity | `observation_id`, `space`, `kind`, `subject` | Determines same observation |
| Provenance | `producer`, `observed_at`, `content_hash` | Determines lineage/re-emission |
| Policy | `privacy`, `links`, `capabilities` | Determines allowed interpretation/use |

Practical implication:

- Same identity + different provenance = re-emission or refreshed evidence.
- Same payload + different identity = different observation.
- Policy fields are required for safe use, but they should not define identity.

### Failure Status

[D] Accept the two-dimensional formal model from `PROP-001`.

Canonical formal shape:

```text
computation_status: :ok | :failed | :rejected | :blocked
service_level:      :nominal | :degraded
```

Compatibility note:

- `failure-observation-v0` flat statuses remain readable as a practical v0
  shorthand.
- Future packets should prefer the 2D model.
- A bridge may expose a derived `status` for older consumers:
  - `failed` -> `computation_status: :failed, service_level: :nominal`
  - `rejected` -> `computation_status: :rejected, service_level: :nominal`
  - `blocked` -> `computation_status: :blocked, service_level: :nominal`
  - `degraded` -> `computation_status: :ok, service_level: :degraded`

Practical implication:

- Degraded health is not a failed computation.
- A blocked action can be the correct safe result.
- A computation may fail while the service level remains nominal.

### Reason Codes

[D] Accept the split between closed core reason codes and open platform
extensions.

Closed core:

- reason families from `failure-observation-v0`
- core computation status semantics
- required diagnostic/link shape

Open platform extension:

- `platform_code`
- package-specific subcodes
- debug artifact refs
- advisory operator labels

Rule:

```text
Platform extensions may refine explanation, but they may not change core
failure semantics.
```

Practical implication:

- Package Agent can later map Ledger/Durable diagnostics into the envelope
  without making package-specific codes part of the language core.
- Compiler/Grammar Expert can reason about the closed core.

## Deferred Or Rejected Corrections

[R] Do not rewrite completed tracks into formal notation.

Reason:

- They are useful as historical practical slices.
- Their tone is product/agent/bridge oriented.
- Full rewrite would hide the research progression.

[R] Use errata sections or reconciliation notes for corrections.

Recommended errata placement:

- `observable-contract-language-v0`: add a short "Formal Errata" noting Law 3
  is parameterized by `Tt`.
- `observable-spine-v0`: add a short "Formal Errata" separating required fields
  into Identity / Provenance / Policy.
- `failure-observation-v0`: add a short "Formal Errata" replacing flat status
  with canonical 2D status while keeping flat status as compatibility shorthand.

[X] Do not push these corrections into packages yet.

Reason:

- No bridge proposal is approved.
- Package Agent should wait for a dedicated bridge track.

## Bridge Impact

These corrections affect the next bridge candidate:

```text
bridge-observation-envelope-v0
```

Bridge must now map:

- Ledger/Durable packet identity into `Identity`
- receipt/fact/diagnostic producer and hashes into `Provenance`
- redaction/capability/no-grant rules into `Policy`
- failure flat statuses into `computation_status x service_level`
- package-specific diagnostic codes into advisory `platform_code`

Bridge should not:

- make Ledger packet shape the language envelope
- make package codes core reason codes
- treat degraded health as failed computation
- grant capabilities through approval or remediation packets

## Questions For Compiler/Grammar Expert

[Q] In `PROP-002`, should failure composition accumulate all failures or stop at
the first failed dependency in the core?

[Q] Should service-level degradation compose monotonically under parallel
composition, or should it be scoped to the producer/platform observation?

[Q] Does the Identity / Provenance / Policy split need a formal equivalence
relation now, or can that wait for bridge work?

[Q] Should `links` live under Policy formally, or should there be a fourth
Relation group? Practical spine currently keeps links required for safe use.

## Next Slice Recommendation

[R] Next practical slice: `track-errata-application-v0`.

Purpose:

- Apply compact errata sections to the three completed practical tracks.
- Do not rewrite them.
- Keep each errata section under ~20 lines.
- Point forward to `PROP-001` and this reconciliation track.

[R] Next formal slice remains `PROP-002-contract-composition-algebra-v0`, owned
by `[Igniter-Lang Compiler/Grammar Expert]`.

[R] Package Agent remains blocked from package work until a bridge proposal is
approved.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/semantic-domain-reconciliation-v0
Status: done

[D] Decisions:
- Accept `PROP-001` as the formal anchor for completed practical tracks.
- Restate Law 3 as a finite stratified graph parameterized by explicit temporal
  context `Tt`; each fixed `Tt` evaluation is closed.
- Split observation envelope required fields into Identity, Provenance, and
  Policy groups.
- Adopt formal two-dimensional failure status:
  `computation_status x service_level`.
- Split reason codes into closed core semantics and open advisory platform
  extensions.

[R] Recommendations:
- Add compact errata sections to the three completed practical tracks rather
  than rewriting them.
- Keep `bridge-observation-envelope-v0` waiting until the errata and `PROP-002`
  are reviewed.
- Package Agent should continue waiting for approved bridge notes.

[S] Signals:
- Practical tracks and `PROP-001` align cleanly once temporal context and
  failure status are made explicit.
- The observation envelope remains useful, but its field groups need sharper
  names before bridge work.
- The failure model is now stronger: blocked/degraded are no longer confused
  with failed/rejected computation.

[Q] Open Questions:
- Should failure composition accumulate or short-circuit in the core?
- Should service-level degradation compose globally or stay platform-scoped?
- Should `links` remain Policy or become a separate Relation group formally?

[X] Rejected:
- Rewriting completed tracks destructively.
- Promoting corrections directly into packages.
- Treating package-specific reason codes as core language semantics.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/track-errata-application-v0.md`
```

# Compiler Release Official First-RC Evidence Gathering Authorization Review v0

Card: S3-R167-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-official-first-rc-evidence-gathering-authorization-review-v0
Route: UPDATE
Status: done
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/practical-rc-ledger-spark-crosslane-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-scope-aware-harness-update-acceptance-prep-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-scope-aware-update-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`

---

## Decision

Decision:

```text
authorize official first-RC evidence gathering as a bounded next evidence card
```

The next card may gather official first-RC evidence because the prior blockers
are now closed or explicitly scoped:

- R162 semantic profile-source diagnostic condition is closed by the later
  follow-up and reflected in the current harness summary;
- R164 branch/conditional `if_expr` scope is explicitly narrowed out of first
  RC;
- R165 scope-aware harness update reran and reached `PASS`;
- R166 Portfolio accepted the scope-aware harness update and authorized this
  authorization-review route.

This decision does not gather official RC evidence itself. It authorizes only a
fresh bounded evidence-gathering card with explicit output labels and a separate
evidence packet.

This decision does not authorize release execution, public release/demo claims,
compiler behavior changes, Spark integration, Ruby Framework changes, signing,
deployment, or production behavior.

---

## Accepted Precondition Evidence

Accepted current harness state:

- harness status: `PASS`;
- command matrix entries: `14`;
- failed checks: `[]`;
- hold reasons: `[]`;
- release scope: `repo_local_compiler_rc`;
- claimed surfaces:
  - `repo_local_compiler_cli_positive_compile`;
  - `repo_local_compiler_cli_refusal`;
  - `repo_local_compiler_api_positive_compile`;
  - `repo_local_load_path_smoke`;
  - `proof_local_runtime_smoke`;
- excluded features: `branch_conditional_if_expr`;
- exclusion basis:
  `S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr`;
- non-claim present:
  `no_branch_conditional_claim`;
- semantic profile-source refusal now includes qualified diagnostic:
  `compiler_profile_source.wrong_kind`.

Important label status:

```text
The existing R165/R166 harness outputs remain proof-local / pre-RC evidence.
They are accepted as preconditions, but they are not retroactively renamed as
official first-RC evidence.
```

---

## Authorized Next Card Boundary

Authorized next card:

```text
Card: S3-R168-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-official-first-rc-evidence-gathering-v0
Route: UPDATE
Depends on:
- S3-R167-C1-A
- S3-R167-C3-S

Goal:
Run a fresh bounded official first-RC evidence gathering pass under the narrowed
scope-aware PASS harness and produce a machine-readable evidence packet.
```

If the user chooses to extend R167 instead of starting R168, the same boundary
may be used as `S3-R167-C4-I`; do not replace the already planned `S3-R167-C3-S`
status-curation card.

---

## Allowed Write Scope

Allowed write scope for the next evidence card:

```text
igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/**
igniter-lang/docs/tracks/compiler-release-official-first-rc-evidence-gathering-v0.md
```

Allowed read/reuse scope:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
igniter-lang/lib/**
igniter-lang/bin/igc
```

The next card may create a wrapper/collector in the new official evidence
experiment directory that invokes the existing harness or copies/verifies its
freshly generated output. It must not mutate compiler/library behavior.

The next card must not mutate:

```text
igniter-lang/lib/**
igniter-lang/bin/**
igniter-lang/docs/proposals/**
existing POC output directories
existing golden fixtures outside the authorized evidence output directory
Spark CRM files
Ruby Framework package files
```

If the existing harness requires a small harness-local parameter to emit into a
separate output directory, that must be held for a new authorization review
unless the change is entirely inside the new official evidence experiment
wrapper. Default stance: do not edit the existing harness runner.

---

## Required Command Matrix

The next evidence card must run and record at minimum:

```text
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
ruby -rjson -e '<verify official evidence packet shape>'
```

The evidence packet must also record:

- command matrix entry count;
- pass/fail status for every command matrix entry;
- positive corpus count;
- negative/refusal corpus count;
- artifact check count;
- failed check count;
- hold reason count;
- closed-surface scan result;
- generated artifact manifest;
- whether existing pre-RC output was relabeled. Expected: `false`.

Status precedence remains:

```text
FAIL > HOLD > PASS
```

Any failed check must produce top-level `FAIL`. Any non-empty hold reason must
produce top-level `HOLD` unless a stronger `FAIL` is present.

---

## Required Official Evidence Packet Shape

The next card must produce a machine-readable packet under:

```text
igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/
```

Required summary file:

```text
official_first_rc_evidence_summary.json
```

Required top-level fields:

```json
{
  "kind": "official_first_rc_evidence",
  "format_version": "0.1.0",
  "status": "PASS|HOLD|FAIL",
  "authorization": "S3-R167-C1-A",
  "track": "compiler-release-official-first-rc-evidence-gathering-v0",
  "evidence_label": "official_first_rc_evidence",
  "source_harness": {
    "track": "compiler-release-acceptance-harness-scope-aware-update-v0",
    "summary_path": "igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json",
    "summary_sha256": "sha256:..."
  },
  "release_scope": {
    "scope": "repo_local_compiler_rc",
    "claimed_surfaces": [],
    "excluded_features": ["branch_conditional_if_expr"],
    "exclusion_basis": "S3-R164-C4-A Portfolio acceptance of first_rc_excludes_branch_conditional_if_expr",
    "public_claims_authorized": false,
    "production_runtime_authorized": false
  },
  "command_matrix": [],
  "proof_artifacts": {},
  "failed_checks": [],
  "hold_reasons": [],
  "non_claims": []
}
```

The packet may include additional fields, but it must preserve the required
fields above.

---

## Official Evidence Label Rules

Outputs from the next card may be called:

```text
official first-RC evidence
```

only if all are true:

- the next card runs after this authorization;
- the evidence packet is freshly produced under
  `compiler_release_official_first_rc_evidence_v0`;
- top-level status is `PASS`;
- failed checks are empty;
- hold reasons are empty;
- `branch_conditional_if_expr` remains in `release_scope.excluded_features`;
- `no_branch_conditional_claim` remains present;
- public claims are still unauthorized;
- production runtime is still unauthorized.

The existing R165/R166 harness output remains:

```text
scope-aware harness update evidence
pre-RC release-readiness evidence
```

It must not be relabeled in place.

---

## Explicit Answers

Can generated outputs from the next card be called official first-RC evidence?

```text
Yes, but only after the authorized next card completes a fresh run and produces
a PASS evidence packet under the new official evidence output directory.
```

Does branch/conditional `if_expr` remain excluded?

```text
Yes. It remains excluded from first RC by S3-R164-C4-A. No branch/conditional
implementation or support claim is authorized.
```

Does release execution remain closed?

```text
Yes. Release execution remains closed.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Do Spark/Ruby evidence sources authorize anything in Lang?

```text
No. Spark/Ruby evidence remains non-authorizing context only for this card.
```

---

## Closed Surfaces

This decision does not authorize:

- release execution;
- public release or demo claims;
- public API/CLI widening;
- branch/conditional implementation;
- parser changes;
- TypeChecker changes;
- SemanticIR changes;
- assembler changes;
- compiler/library behavior changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration
  outside the authorized evidence output directory;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework package implementation, docs sync, release, or compatibility
  claims;
- RuntimeMachine/Gate 3 widening;
- Ledger/TBackend production binding;
- BiHistory, stream/OLAP, cache, signing, deployment, or production behavior.

---

## Compact Receipt

```text
card: S3-R167-C1-A
track: compiler-release-official-first-rc-evidence-gathering-authorization-review-v0
status: done
decision: authorize_bounded_official_first_rc_evidence_gathering_next
authorized_next_card: S3-R168-C1-I
authorized_next_track: compiler-release-official-first-rc-evidence-gathering-v0
current_harness_status: PASS
current_command_matrix_entries: 14
current_failed_checks: 0
current_hold_reasons: 0
branch_conditional_if_expr: excluded_from_first_rc
existing_outputs_relabel_authorized: no
fresh_official_evidence_output_required: yes
release_execution_authorized: no
public_claims_authorized: no
compiler_behavior_changes_authorized: no
spark_ruby_authority: non_authorizing_context_only
```

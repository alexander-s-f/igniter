# Track: PROP-036 CLI Closure Criteria Precision Addendum Prep v0

Card: S3-R47-C2-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-cli-closure-criteria-precision-addendum-prep-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

---

## Goal

Prepare exact wording for a possible minor Architect addendum to the R46
PROP-036 CLI blocker closure criteria.

This is docs/design preparation only. It does not edit gate documents, implement
CLI behavior, or authorize CLI implementation.

---

## Sources Read

```text
docs/gates/prop036-cli-blocker-closure-criteria-decision-v0.md
docs/discussions/prop036-cli-blocker-closure-criteria-pressure-v0.md
docs/tracks/prop036-cli-b1-standalone-source-artifact-closure-v0.md
docs/tracks/prop036-cli-b3-refusal-shape-and-b6-scan-scope-v0.md
docs/tracks/prop036-cli-b7-b8-docs-completion-bar-v0.md
```

---

## Current State

`S3-R46-C4-A` is already a strong closure-criteria decision:

- B1 requires a stable standalone profile-source artifact.
- B3 adopts the hybrid refusal model.
- B6 maps scan surfaces to B3 scenarios.
- B7 requires caller-facing Ruby API docs.
- B8 requires public transport-only wording plus source-level visibility landed
  or explicitly deferred.
- CLI implementation remains held.

`S3-R46-C5-X` found no blockers, but routed three precision notes:

1. B6 scanner self-test is not binding in the gate.
2. B8-C deferral authority is unspecified.
3. B1 validation-chain specificity is missing from the gate wording.

---

## Recommendation

[R] Add a minor Architect addendum now, before implementation authorization.

Reason:

```text
All three notes are small wording gaps in the governing gate, not new design
work. Waiting until implementation authorization would force the future gate to
interpret track-level evidence instead of relying on binding closure criteria.
```

This can be a compact addendum that amends only B1, B6, and B8-C. It should not
reopen B2/B3/B4/B5/B7/B9, and it should not authorize CLI code.

---

## Proposed Addendum Wording

Suggested title:

```text
PROP-036 CLI Closure Criteria Precision Addendum v0
```

Suggested status:

```text
approved-precision-addendum-implementation-held
```

Suggested decision text:

```text
This addendum clarifies S3-R46-C4-A without changing the approved CLI design
route. It tightens closure evidence for PROP036-CLI-B1, PROP036-CLI-B6, and
PROP036-CLI-B8-C. CLI implementation remains held.
```

### Amendment 1: B6 Scanner Self-Test

Add to `PROP036-CLI-B6 — Negative-Token Scan Surface`:

```text
The B6 proof must include an adversarial scanner self-test.

Required self-test cases:

1. Inject a bare forbidden token, for example `present_verified`, into a
   scanner fixture or controlled proof-local output. The scanner must report
   FAIL for that injected surface.

2. Include a qualified compiler-profile-source validation string, for example
   `compiler_profile_source.id_digest_mismatch` or
   `compiler_profile_source.malformed`, in a scanner fixture or controlled
   proof-local output. The scanner may report PASS only if the proof summary
   records that qualified `compiler_profile_source.*` strings are allowed
   source-validation vocabulary and are not loader-status vocabulary.

The proof summary must record:

  scanner_self_test_bare_forbidden_token_fails: true
  scanner_self_test_qualified_source_validation_allowed: true
  allowed_qualified_source_validation_terms

B6 is not closed by a clean scan over real outputs alone. The scanner must prove
that it can fail on an injected bare forbidden token.
```

Rationale:

```text
This imports R46 C2-P1 B6-2/B6-3 into the binding gate. It prevents a future
proof from passing with a scanner that traverses the right files but cannot
detect a forbidden token.
```

### Amendment 2: B8-C Deferral Authority

Replace the deferral branch of `PROP036-CLI-B8` item 3 with:

```text
Source-level visibility may be deferred only by an explicit Architect decision
or gate document that names the deferral path and states that B8 relies on
public Ruby API docs plus dev-contract wording instead of a source comment for
this phase.

A Research Agent, Compiler/Grammar Expert, Implementation Agent, or docs track
may recommend deferral, but a track recommendation alone does not close B8-C.

The closing evidence must record the exact gate/decision document path that
authorized the deferral.
```

Keep:

```text
Silent absence of a source comment does not close B8.
```

Rationale:

```text
This removes the self-assertion path where any track could claim to be a
"named docs/governance card." Deferring source-level visibility is an authority
choice because it changes what counts as enough evidence to close B8.
```

### Amendment 3: B1 Validation Chain

Add to `PROP036-CLI-B1 — Standalone Source Artifact Contract` item 4:

```text
`standalone_artifact_valid: true` must mean the standalone artifact was validated
by the same compiler-profile-source validation path used by the finalization
proof and assembler source contract. It is not satisfied by JSON
well-formedness, top-level object shape, or field-presence checks alone.

The proof summary must record the validation path, for example:

  standalone_artifact_validation_path: finalization_and_assembler_source_contract

and the closing track must state that the standalone file validates as a
`compiler_profile_id_source` payload suitable for future
`--compiler-profile-source PATH.json` use without discovery, defaulting, or
lookup.
```

Rationale:

```text
This imports R46 C1-P1's validation-chain specificity into the binding gate and
prevents a superficial "valid JSON object" check from closing B1.
```

---

## Resulting Closure Bar

If the proposed addendum is accepted:

| Blocker | Additional precision |
| --- | --- |
| B1 | `standalone_artifact_valid: true` must be tied to the same source validation path used by finalization / assembler source contract, not JSON-only validation |
| B6 | Scanner must prove detection with injected bare forbidden token and document qualified `compiler_profile_source.*` allowance |
| B8-C | Deferral of source-level visibility requires explicit Architect gate/decision; track self-assertion is not enough |

No other closure criteria change.

---

## Recommendation: Timing

[D] Addendum needed now.

Why now:

- It is small and does not require implementation.
- It converts R46 pressure notes into binding gate text.
- It reduces future implementation-authorization ambiguity.
- It does not block the independent B7/B8 public docs card; it only clarifies
  how B8-C deferral can be accepted.

Acceptable alternative if the supervisor wants fewer gates:

```text
Defer until implementation authorization only if the implementation-authorization
gate explicitly rereads this track and imports the three precision clauses before
accepting any closure claim for B1, B6, or B8-C.
```

Research recommendation remains:

```text
Prefer addendum now.
```

---

## Non-Authorizations

This track does not authorize:

```text
editing gate docs
editing lib/igniter_lang/cli.rb
editing bin/igc
adding --compiler-profile-source
path loading in CLI
JSON parsing in CLI
profile finalization
profile discovery/defaulting
loader/report implementation
CompatibilityReport profile section
.igapp golden migration
.ilk changes
CompilationReceipt links
signing
compiler dispatch migration
RuntimeMachine binding
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP production executor
production cache
production behavior
CLI implementation authorization
```

---

## Handoff

```text
Card: S3-R47-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: prop036-cli-closure-criteria-precision-addendum-prep-v0
Status: done

[D] Decisions
- Recommend a minor Architect addendum now, before implementation authorization.
- Scope the addendum to B1 validation-chain specificity, B6 scanner self-test,
  and B8-C deferral authority only.

[S] Signals
- R46 gate is strong but still leaves three future self-assertion paths.
- The fixes are wording-only and do not require code or proof changes yet.

[T] Tests / Proofs
- Documentation-only preparation.
- No code or proof commands run.

[R] Recommendation
- Architect should adopt the proposed wording as a small precision addendum.
- If not adopted now, the future implementation-authorization gate must import
  these three clauses before accepting B1/B6/B8-C closure.

[Next]
- Open Architect decision card for
  `prop036-cli-closure-criteria-precision-addendum-v0`.
```

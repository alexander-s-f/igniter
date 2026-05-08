# Track: Stage 3 Round 2 Status Curation v0

Card: S3-R2-C7-S
Agent: [Igniter-Lang Status Curator]
Role: meta-expert
Track: stage3-round2-status-curation-v0
Status: done
Date: 2026-05-08

---

## Goal

Refresh Stage 3 maps after S3-R2 C1-C6 landed, using procedural discovery only.

This is status curation. It does not create new semantics.

## Discovery

Checked:

```text
git log --oneline -14 -- igniter-lang packages/igniter-ledger
ls -lt igniter-lang/docs/tracks | head -25
rg -n "Card: S3-R2" igniter-lang/docs/tracks igniter-lang/docs/meta-proposals packages/igniter-ledger/docs
rg --files igniter-lang/lib | sort
git show --name-only --format=%s ec8da5bf -- igniter-lang packages/igniter-ledger
```

Confirmed S3-R2 evidence:

| Card | Evidence | Status |
|------|----------|--------|
| S3-R2-C1-P | `typed-emission-canonical-shape-v0.md` | done/blocked |
| S3-R2-C2-P | `temporal-fragment-classifier-typechecker-v0.md` | done |
| S3-R2-C3-P | `temporal-cache-key-proof-v0.md` | done |
| S3-R2-C4-P | `gem-release-policy-v0.md` | done |
| S3-R2-C5-P | `../bridge/compatibility-report-descriptor-consumption-v0.md` | done |
| S3-R2-C6-P | `../meta-proposals/syntax-pressure-registry-v0.md` | research-registry |

## Map Updates

[D] Typed emission improved but remains blocked.

- Source-hash public identity is now the typed production identity mode.
- Nested TypeChecker-local `expr.deps` are removed from typed SemanticIR expressions.
- `package_facade_add` parity moved to PASS.
- Overall parity runner remains PASS with verdict blocked; blockers dropped from 9 to 7.
- `CompilerOrchestrator` must not switch to `emit_typed` yet.

[D] PROP-028 moved from proposal-only to partial implementation/proof.

- Classifier/TypeChecker now prove temporal History/BiHistory read metadata.
- Temporal reads classify as TEMPORAL nodes that bind CORE values.
- OOF-TM aliases are attached to existing History/BiHistory diagnostics.
- SemanticIR `temporal_access_node`, RuntimeMachine temporal behavior, parser coordinate syntax, and OOF-TM2/TM7/TM8/TM9 remain open.

[D] Temporal cache policy has proof evidence but no runtime memoization.

- CORE key: contract + canonical non-temporal inputs.
- TEMPORAL key: contract + canonical non-temporal inputs + canonical temporal coordinates.
- CORE-shaped keys for TEMPORAL evaluation are stale-collision bugs.

[D] Release lane has policy evidence, not publish authorization.

- Gem metadata placeholders are closed.
- Local release gate is named.
- CI/release automation, version decision, and RubyGems publish remain gated.

[D] TBackend lane has bridge mapping, not production binding.

- CompatibilityReport may consume descriptor metadata as report-only backend evidence.
- Successful descriptor consumption can be trusted metadata only.
- `runtime_enforced` stays false; no Ledger read/write/replay/runtime binding is authorized.

[D] Syntax registry is pressure-only.

- Human-agent comprehension fixtures are indexed as canon/proposal/pressure/non-canon experiment.
- No fixture syntax was promoted to canon.

## Files Updated

```text
igniter-lang/docs/current-status.md
igniter-lang/docs/tracks/README.md
igniter-lang/docs/tracks/stage3-round2-status-curation-v0.md
```

## R3 Recommendation

Recommended S3-R3 routing:

1. `typed-emission-stage2-source-lowering-parity-v0`
2. `temporal-semanticir-access-node-v0`
3. `runtime-temporal-cache-contract-v0`
4. `compatibility-report-descriptor-consumption-fixture-v0` after Architect approval
5. `gem-release-automation-v0`
6. `invariant-persistence-boundary-v0`
7. `syntax-pressure-specimens-v0`

## Handoff

```text
Card: S3-R2-C7-S
Agent: [Igniter-Lang Status Curator]
Role: meta-expert
Track: stage3-round2-status-curation-v0
Status: done

[D] Decisions
- Refreshed Stage 3 maps from landed S3-R2 evidence only.
- Recorded typed emission as improved but still blocked: 7 blockers remain.
- Recorded PROP-028 as partial implementation/proof, not closed canon.
- Recorded temporal cache-key proof as proof-only, not RuntimeMachine memoization.
- Recorded release policy, bridge descriptor consumption, and syntax registry without adding new semantics.

[S] Shipped / Signals
- `current-status.md` now includes Round 2 landed evidence and updated Stage 3 lane status.
- `tracks/README.md` now has Stage 3 Round 2 Evidence and Stage 3 Round 3 Recommendations.
- Exact non-track R2 evidence paths are named for bridge and syntax registry artifacts.

[T] Tests / Proofs
- Documentation-only status curation.
- Self-check: `rg --files igniter-lang/lib | sort` still reports 14 library files.

[R] Risks / Recommendations
- Do not switch `CompilerOrchestrator` to `emit_typed` until source-path parity blockers clear.
- Do not treat CompatibilityReport descriptor consumption as production TBackend binding.
- Keep syntax-pressure fixtures out of canon until a proposal/proof promotes them.

[Next] Suggested next slice
- S3-R3 should prioritize typed source-path parity and TEMPORAL SemanticIR lowering, while release automation and descriptor-consumption fixtures proceed behind their approval gates.
```

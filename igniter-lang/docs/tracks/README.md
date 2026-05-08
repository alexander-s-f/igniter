# Igniter-Lang Tracks

Status: active index
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-08

---

## Purpose

Track documents are slice evidence, not the global project log.

New agents should start from `docs/README.md`, `docs/operating-model.md`,
`docs/current-status.md`, and the assigned track only.

---

## Current Navigation

| Need | Start here |
|------|------------|
| Current language state | `../current-status.md` |
| Process / handoff rules | `../operating-model.md` |
| Canonical spec | `../spec/` |
| Proposal queue | `../proposals/README.md` |
| Historical archaeology | `../archive/` or git history |

---

## Stage 3 Round 4 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `typed-emission-stage2-switch-decision-v0.md` | done | Meta Expert governance decision: Option B adopted — typed emission becomes sole Stage 2+ lowering path; switch gate = BiHistory source fixture parity PASS + stage2_close_candidate post-switch; next cards C5+C6 defined |

---

## Stage 3 Round 3 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `typed-emission-stage2-source-lowering-parity-v0.md` | done/blocked | typed source blockers dropped to 0; parity runner PASS with verdict blocked; `legacy_parity_delta_items=11`, `blocked_items=13`, `safe_to_switch_production_path=false` |
| `temporal-semanticir-access-node-v0.md` | done | typed History/BiHistory lower to `temporal_input_node` + `temporal_access_node`; fragment/capability/coordinate refs preserved; no parser syntax, cache, or production TBackend binding |
| `runtime-temporal-cache-contract-v0.md` | done | RuntimeMachine cache key/entry/freshness/observation contract defined from proof; no production memoization, cache store, or manifest change |
| `gem-release-automation-v0.md` | done | `bin/release-gate` PASS; gemspec, gem-native boundary, Stage 1, Stage 2, artifact build all PASS; local `.gem` and `.sha256` built; publish not attempted |
| `compatibility-report-descriptor-consumption-fixture-v0.md` | done | proof-local descriptor consumption fixture PASS; trusted/provisional/blocked cases covered; `runtime_enforced=false`; Gate 2 package exposure and Gate 3 production binding remain closed |
| `../meta-proposals/syntax-pressure-specimens-v0.md` | research-fixtures | Field Supply Watch v3 and Primitive Surface specimens/guides added as pressure artifacts only; no parser/spec/proposal/runtime changes |
| `../discussions/temporal-manifest-and-cache-boundary-pressure-v0.md` | complete — routed | S3-R3-X1 pressure: TEMPORAL survives through SemanticIR but not assembler boundary; `contract_file` temporal-node crash and manifest/requirements gaps routed |
| `stage3-round3-status-curation-v0.md` | done | S3-R3 map sync and R4 prep — this track |

## Stage 3 Round 2 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `typed-emission-canonical-shape-v0.md` | done/blocked | source-hash public identity and canonical compute JSON shape fixed; `package_facade_add` parity PASS; overall verdict still blocked with 7 remaining source-path blockers |
| `temporal-fragment-classifier-typechecker-v0.md` | done | PROP-028 first implementation boundary: History/BiHistory reads classify as TEMPORAL nodes that bind CORE values; TypeChecker preserves temporal metadata; SemanticIR/runtime/parser syntax still open |
| `temporal-cache-key-proof-v0.md` | done | proof-local CORE vs TEMPORAL cache-key model PASS; CORE-shaped keys for temporal evaluation are stale-collision bugs; no RuntimeMachine memoization added |
| `gem-release-policy-v0.md` | done | gem metadata placeholders closed; local release gate named; RubyGems publish requires Architect approval and human owner; CI/release automation still open |
| `../bridge/compatibility-report-descriptor-consumption-v0.md` | done | report-only bridge proposal: CompatibilityReport may consume descriptor metadata as backend evidence with `runtime_enforced: false`; no Ledger read/write/replay/runtime binding |
| `../meta-proposals/syntax-pressure-registry-v0.md` | research-registry | comprehension fixtures indexed as canon/proposal/pressure/non-canon experiment; no fixture syntax promoted to canon |
| `stage3-round2-status-curation-v0.md` | done | S3-R2 map sync and R3 prep — this track |

## Stage 3 Round 1 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `stage3-governance-opening-v0.md` | done | Stage 3 formally OPEN (2026-05-08); META-EXPERT-011; 5 lanes authorized; PROP-028 authorized; R1 cards issued |
| `../proposals/PROP-028-temporal-fragment-class-v0.md` | proposal | TEMPORAL fragment class proposal written; OOF > TEMPORAL > STREAM > CORE; cache key semantics specified |
| `typed-emission-main-path-parity-v0.md` | blocked | parity runner PASS with verdict blocked; do not switch orchestrator to `emit_typed` yet; 9 blocked items recorded |
| `../archive/snapshots/2026-05-07-stage2-close/README.md` | done | Stage 2 close snapshot archived as cold archaeology context |
| `../meta-proposals/axiomatic-and-system-forming-ideas-lens-v0.md` | research-note | АИ/СОИ captured as soft Stage 3 design lens, not spec/canon and not a hard gate |
| `stage3-round1-status-curation-v0.md` | done | S3-R1 map sync and R2 prep — this track |

## Stage 2 Round 15 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md` | decision | Stage 2 formally CLOSED WITH DEFERRED GAPS on 2026-05-07; close candidate PASS, 8 proofs, 7 surface checks, 5 deferred gaps |
| `gem-native-package-boundary-specs-v0.md` | done | installed gem require/compile/igc proof PASS from isolated gem home; 7 checks PASS, 4 release-readiness gaps remain |
| `../meta-proposals/human-agent-comprehension-synthesis-v0.md` | research-synthesis | comprehension pressure synthesized; routes Stage 3 syntax experiments without canon promotion |
| `future-syntax-pressure-formalization-v0.md` | done | formal grammar questions extracted from pressure fixtures; no parser changes and no canon promotion |
| `stage2-round15-status-curation-v0.md` | done | R15 map sync and Stage 3 intake prep — this track |

## Stage 2 Round 14 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `stage2-close-candidate-v0.md` | done | close candidate runner PASS; JSON status `PASS`, verdict `stage2_close_candidate`, proofs_run=8, surface_checks=7, deferred_gaps=5 |
| `packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md` | done | package-side metadata-only descriptor implemented; targeted package spec 9 examples, 0 failures |
| `stage2-round14-status-curation-v0.md` | done | R14 map sync — this track |

## Stage 2 Round 13 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `compiler-packaging-skeleton-v0.md` | done | prerelease gem skeleton, `IgniterLang::VERSION`, package CLI, and `bin/igc`; gem build/install and installed `igc compile` smokes PASS |
| `stage2-close-candidate-planning-v0.md` | done | planning-only R14 close runner design; target JSON schema, proof list, fixtures, and deferred gaps defined |
| `ledger-tbackend-adapter-descriptor-package-plan-v0.md` | done | package-side descriptor-only implementation plan; no runtime/Ledger operation binding authorized |
| `stage2-round13-status-curation-v0.md` | done | R13 map sync — this track |

## Stage 2 Round 12 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-smoke-extraction-v0.md` | done | `IgniterLang::RuntimeSmoke` extracted; CLI uses reusable callback; production compiler, assembler, and Stage 1 proofs PASS |
| `compiler-package-boundary-v0.md` | done | direct API, CLI, and load-path proof share `IgniterLang.compile(...)`; no gemspec/bin/version release packaging yet |
| `ledger-tbackend-adapter-descriptor-v0.md` | done | metadata-only Ledger descriptor fixture PASS; descriptor hash, registry hash, and missing-history diagnostics proven |
| `runtime-invariant-violation-observations-v0.md` | done | invariant violations emit runtime observation records linked to source `invariant_node`; invariant proof and Stage 1 PASS |
| `stage2-round12-status-curation-v0.md` | done | R12 map sync — this track |

## Stage 2 Round 11 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `packageable-compiler-api-v0.md` | done | top-level `IgniterLang.compile(...)` facade added; CLI delegates to facade; production compiler, SemanticIR, assembler, and Stage 1 proofs PASS |
| `invariant-severity-semanticir-lowering-v0.md` | done | typed invariants lower to `invariant_node`; output effect propagation and invariant coverage preserved; invariant proof PASS |
| `tbackend-ledger-bridge-conformance-v0.md` | done | docs-only Ledger-backed TBackend conformance map; descriptor-first, metadata-only package slice recommended |
| `stage2-round11-status-curation-v0.md` | done | R11 map sync — this track |

## Stage 2 Round 10 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `compiler-orchestrator-v0.md` | done | lib/igniter_lang/compiler_orchestrator.rb extracted |
| `stream-semanticir-surface-lowering-v0.md` | done | stream SemanticIR lowering PASS; stream_t_proof PASS |
| `production-tbackend-adapter-fixture-v0.md` | done | proof-local AdapterRegistry + CompatibilityReport persistence |
| `invariant-severity-parser-impl-v0.md` | done | PINV-1..4 + TINV-1..3 PASS; +3 typechecker cases |
| `stage2-round10-map-and-role-profile-refresh-v0.md` | done | R10 map sync — this track |

## Stage 2 Round 9 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-assembler-module-v0.md` | done | lib/igniter_lang/assembler.rb extracted; Stage 1 goldens PASS; CLI PASS |
| `production-tbackend-adapter-shape-v0.md` | done | Docs-only: TBackend adapter shape spec; no code changes |
| `semanticir-stage2-surface-lowering-v0.md` | done | OLAP SemanticIR lowering in emitter; olap_point_proof PASS; stage1 PASS |
| `stage2-round9-map-refresh-v0.md` | done | R9 map sync — this track |

## Stage 2 Round 8 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-semanticir-emitter-module-v0.md` | done | `lib/igniter_lang/semanticir_emitter.rb` extracted; source→SemanticIR golden PASS |
| `olap-point-typechecker-semanticir-v0.md` | done | OOF-O2..O5; `olap_access_node`; explicit `dims_record`; OLAP proof PASS |
| `stream-oof-s3-typechecker-v0.md` | done | ESCAPE-in-fold TypeChecker rule; stream OOF-S1..S5 all proven |
| `production-runtime-machine-temporal-access-integration-v0.md` | done | RuntimeMachine load/evaluate proof-local hook integration; TBackend adapter still future |

## Stage 2 Round 7 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-typechecker-module-v0.md` | done | lib/igniter_lang/typechecker.rb extracted; typechecker_proof + CLI PASS |
| `stream-oof-s2-classifier-v0.md` | done | OOF-S2 missing-window classifier rule; golden PASS; semanticir golden PASS |
| `runtime-machine-temporal-access-hook-proof-v0.md` | done | RuntimeMachineHook wired in history+bihistory proofs; both PASS |
| `olap-point-parser-implementation-v0.md` | done | revenue_point.ig parses live; olap_points[]; dims_record; parser spec 61 PASS |
| `stage2-round7-map-refresh-v0.md` | done | R7 map sync — this track |

## Stage 2 Round 6 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `extract-classifier-module-v0.md` | done | lib/igniter_lang/classifier.rb extracted |
| `stream-classifier-escape-propagation-v0.md` | done | SC-1/2/3 ESCAPE propagation; semanticir goldens 6→9 |
| `runtime-machine-temporal-access-hook-v0.md` | done | RuntimeMachineHook spec + smoke |
| `olap-point-parser-typechecker-boundary-v0.md` | done | Grammar spec: dims_record, OOF-O1..5; olap_point_proof 21 PASS |

---

## igniter-lang/lib — Current State (14 files)

```text
igniter_lang.rb           (R11/R13) — package facade; exposes VERSION + compile
igniter_lang/version.rb   (R13) — prerelease package version
igniter_lang/cli.rb       (R13) — thin package CLI for igc compile
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7/R10) — parser + stream + olap_point + invariant
temporal_access_runtime.rb (R5–R7) — MemoryBackend + RuntimeMachineHook
runtime_smoke.rb          (R12) — reusable proof-backed RuntimeSmoke callback
classifier.rb             (R6/R7) — ParsedProgram→ClassifiedProgram; OOF-S1/2
typechecker.rb            (R7/R8/R10) — TypedProgram boundary; stream OOF-S3; OLAP OOF-O2..O5; TINV-1..3
semanticir_emitter.rb     (R8/R9/R10/R11) — SemanticIR emitter; OLAP/stream/invariant lowering added
assembler.rb              (R9) — .igapp/ assembler boundary
compiler_orchestrator.rb  (R10) — NEW; compiler pass orchestration spine
```

---

## Stage 3 Round 4 Recommendations

| Candidate | Purpose | Role | Status |
|-----------|---------|------|--------|
| `temporal-assembler-boundary-v0` | Fix/define assembler handling for `temporal_input_node` and `temporal_access_node`; decide capability/requirements artifact shape before temporal `.igapp/` bundles | Research Agent + Compiler/Grammar Expert | blocker |
| `prop-022a-temporal-manifest-errata-v0` | Specify whether RuntimeMachine reads TEMPORAL fragment/axes from manifest or ContractIR; resolve manifest `mixed` collapse pressure | Compiler/Grammar Expert | prerequisite |
| `temporal-requirements-from-escape-boundaries-v0` | Derive `.igapp/requirements.json` capability requirements from SemanticIR `escape_boundaries` instead of the hardcoded assembler hash | Research Agent | recommended |
| `typed-emission-stage2-switch-decision-v0` | Decide whether parsed legacy Stage 2 emission must reach parity or whether typed emission becomes the sole Stage 2 lowering path | Meta Expert + Research Agent | recommended |
| `runtime-cache-proof-local-memoization-v0` | Implement proof-only RuntimeMachine cache store from the cache contract, including stale/unknown/provisional negatives | Research Agent | recommended |
| `descriptor-package-exposure-gate2-v0` | Ask/record Architect Gate 2 decision for metadata-only package exposure; do not infer production binding | Bridge Agent | gated |
| `gem-release-ci-wiring-v0` | Wire `bin/release-gate` into CI or preserve release artifacts/checksum under an approved release record; publish remains gated | Research Agent | optional |
| `syntax-pressure-review-results-v0` | Run/review S3-R3 pressure specimens and route successful signals back to the syntax registry before any PROP work | Archive/Form Expert | research |
| `invariant-persistence-boundary-v0` | Production RuntimeMachine invariant observation persistence boundary remains open from Stage 3 intake | Research Agent | authorized |
| `ai-soi-proposal-review-template-v0` | Add a lightweight optional АИ/СОИ prompt for Stage 3 proposal/research review | Meta Expert / Archive-Form Expert | optional |

---

## Handoff Template

```text
Card:
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track:
Status:

[D] Decisions
- ...

[S] Shipped / Signals
- ...

[T] Tests / Proofs
- ...

[R] Risks / Recommendations
- ...

[Next] Suggested next slice
- ...
```

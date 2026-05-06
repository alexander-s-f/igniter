# Igniter-Lang Research Index

Status: active research index

## Claim

Igniter-Lang should be explored as a separate language ecosystem, not as an
implementation detail of the current Igniter platform.

## Active Tracks

| Track | Status | Purpose |
|------|--------|---------|
| [tracks/observable-contract-language-v0.md](tracks/observable-contract-language-v0.md) | proposal | Completed first axiom slice for "everything observable, everything contract" |
| [tracks/observable-spine-v0.md](tracks/observable-spine-v0.md) | proposal | Completed minimal observation envelope and packet-kind spine |
| [tracks/failure-observation-v0.md](tracks/failure-observation-v0.md) | proposal | Completed structured failure packet model over the observation spine |
| [tracks/semantic-domain-reconciliation-v0.md](tracks/semantic-domain-reconciliation-v0.md) | done | Reconciled practical tracks with META-001 and PROP-001 formal corrections |
| [tracks/track-errata-application-v0.md](tracks/track-errata-application-v0.md) | done | Applied compact formal errata to completed practical tracks |
| [tracks/temporal-contracts-and-projections-v0.md](tracks/temporal-contracts-and-projections-v0.md) | done | Defined named slices, projection horizons, live/reproducible projections, and action semantics |
| [tracks/runtime-contracts-and-execution-environments-v0.md](tracks/runtime-contracts-and-execution-environments-v0.md) | done | Defined runtime contracts, execution environments, guarantees, and result meaning status |
| [tracks/bridge-observation-envelope-runtime-evidence-v0.md](tracks/bridge-observation-envelope-runtime-evidence-v0.md) | done | Extended bridge vocabulary with runtime evidence, meaning status, and runtime links |
| [tracks/bridge-observation-envelope-package-mapping-v0.md](tracks/bridge-observation-envelope-package-mapping-v0.md) | done | Mapped current package facts, projections, pins, decisions, and runtime session packets to bridge profiles |
| [tracks/runtime-machine-lifecycle-v0.md](tracks/runtime-machine-lifecycle-v0.md) | done | Defined Runtime Machine boot/load/evaluate/checkpoint/resume lifecycle, semantic image, TBackend adapters, compatibility, and CORE/ESCAPE boundary |
| [tracks/runtime-machine-executable-proof-plan-v0.md](tracks/runtime-machine-executable-proof-plan-v0.md) | done | Planned the minimal executable proof for :memory TBackend boot/load/evaluate/checkpoint/resume on a toy CORE contract |
| [tracks/runtime-machine-proof-packet-fixtures-v0.md](tracks/runtime-machine-proof-packet-fixtures-v0.md) | done | Extracted structural golden ObsPacket, SemanticImage, CompatibilityReport, negative evidence, and result summary artifacts from the memory proof |
| [tracks/runtime-machine-proof-packet-builder-check-v0.md](tracks/runtime-machine-proof-packet-builder-check-v0.md) | done | Added a standalone structural checker for memory proof golden artifacts and candidate packet-builder outputs |
| [tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md](tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md) | done | Added standalone sidecar profiles that emit candidate fixture directories accepted by the packet-builder checker |
| [tracks/runtime-machine-proof-sidecar-profile-modes-v0.md](tracks/runtime-machine-proof-sidecar-profile-modes-v0.md) | done | Defined full-log and selected-profile comparison modes for sidecar candidate artifacts |
| [tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md](tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md) | done | Defined selected-profile admission rules for external candidates and Ruby FFI as contractable ESCAPE proof |
| [tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md](tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md) | done | Added a standalone raw external candidate normalizer fixture that emits selected-profile artifacts and passes the checker |
| [tracks/memory-tbackend-lifecycle-golden-fixtures-v0.md](tracks/memory-tbackend-lifecycle-golden-fixtures-v0.md) | proposal | Golden lifecycle fixture spec for conformant :memory TBackend boot/load/evaluate/checkpoint/resume/read/compact behavior |
| [tracks/add-igapp-devkit-fixture-v0.md](tracks/add-igapp-devkit-fixture-v0.md) | done | Defined the first hand-authored `.igapp/` artifact and RuntimeMachine load/evaluate/checkpoint proof target |
| [tracks/ffi-ruby-contractable-proof-v0.md](tracks/ffi-ruby-contractable-proof-v0.md) | done | Proved Ruby host calls as ESCAPE contracts: FFIRequirement, CapabilityGate, call discipline (intent→check→call→receipt/failure), evidence links |
| [tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md](tracks/runtime-machine-ffi-ruby-receipt-fixtures-v0.md) | done | Added executable FFI read/write/failure golden receipt fixtures and checker coverage |
| [tracks/runtime-machine-schema-check-standalone-fix-v0.md](tracks/runtime-machine-schema-check-standalone-fix-v0.md) | done | Restored standalone RuntimeMachine proof by moving schema_check to loaded_schema_descriptor and adding trusted/provisional schema checks |
| [tracks/runtime-machine-schema-migration-fixture-v0.md](tracks/runtime-machine-schema-migration-fixture-v0.md) | done | Added standalone schema_check:migrating fixture with MigrationDescriptor, intent, and audit receipt evidence |
| [tracks/runtime-machine-migration-replacement-image-v0.md](tracks/runtime-machine-migration-replacement-image-v0.md) | done | Extended schema migration proof to emit a replacement SemanticImage and prove a second trusted CompatibilityReport |
| [tracks/source-fixture-parser-acceptance-harness-v0.md](tracks/source-fixture-parser-acceptance-harness-v0.md) | partial | Started source fixture parser harness: `.ig` source fixtures parse to ParsedProgram JSON; `.igapp` comparison still pending |
| [tracks/polymorphic-add-devkit-fixture-v0.md](tracks/polymorphic-add-devkit-fixture-v0.md) | done | Added polymorphic Add pressure fixture with expected ParsedProgram shape, specialization rules, and no runtime overloads |
| [tracks/polymorphic-add-parser-pressure-map-v0.md](tracks/polymorphic-add-parser-pressure-map-v0.md) | done | Grammar/parser delta map for PROP-016 surface: trait, impl, contract_shape, generic contract header; separated parser vs semantic vs monomorphization work |
| [tracks/polymorphic-add-classifier-v0.md](tracks/polymorphic-add-classifier-v0.md) | done | ClassifiedProgram/TypedProgram/SemanticIR boundary for PROP-016: trait env, impl coherence, T substitution, implements check, monomorphization, Add[String] rejection |
| [tracks/migration-replacement-image-formalization-v0.md](tracks/migration-replacement-image-formalization-v0.md) | done | Formal replacement SemanticImage field spec, link rels (replaces/caused_by), lifecycle, trust rules, multi-hop one-image-per-hop, and 7 OOF-MR rules |
| [tracks/migration-replacement-image-checker-v0.md](tracks/migration-replacement-image-checker-v0.md) | done | Updated RuntimeMachine proof/checker for replacement image P-1..P-10, migration_chain [], no supersedes, and OOF-MR3 negative |
| [tracks/specialization-request-source-v0.md](tracks/specialization-request-source-v0.md) | done | Resolves Q-1: explicit build manifest (Option A) selected for v0; Options B/C rejected; manifest shape, OOF-SP1–7, artifact_hash impact, and proof targets M-1–6 defined |
| [tracks/spark-tenant-and-pipeline-formalization-v0.md](tracks/spark-tenant-and-pipeline-formalization-v0.md) | done | Resolves CG-1/2/3: fail-fast pipelines as Result.flat_map+StepObservation; TenantScope as typed value; ScopedFactRead; CardinalityBound; 8 OOF-PL/TS/CB rules; RA-1/RA-2 fixture targets |
| [tracks/spark-pipeline-grammar-v0.md](tracks/spark-pipeline-grammar-v0.md) | done | Grammar delta: pipeline/step/scoped_by/cardinality/tenant_free keywords; ParsedProgram node shapes; SemanticIR lowering; 7 OOF-PG rules; RA availability fixture target |
| [tracks/spark-pipeline-parser-acceptance-v0.md](tracks/spark-pipeline-parser-acceptance-v0.md) | done | Parser acceptance: pipeline/step/scoped_by/cardinality/schema_version/tenant_free parse cleanly; :dot_dot lexer token; OOF-PG3/PG5 at parse time; grammar_version: spark-pipeline-v0 |
| [tracks/decimal-idempotency-retention-formalization-v0.md](tracks/decimal-idempotency-retention-formalization-v0.md) | done | Decimal[scale:S] as v0 base type; IdempotencyKey content-addressed CORE value; three duplicate suppression receipts; two-phase RetentionReceipt; BoundaryReopenReceipt; 14 OOF rules; SemanticIR gates G-1..G-6 |
| [tracks/operation-action-result-types-and-transition-semantics-v0.md](tracks/operation-action-result-types-and-transition-semantics-v0.md) | done | ActionPolicyProjection vs ExecutableActionCheck; RequestReceipt/ExecutionReceipt/NoOpReceipt; subject_before/after evidence; policy_hash freshness; 7 OOF-OA rules; 5 SemanticIR gates; ESCAPE bridge receipt discipline |
| [tracks/decimal-grammar-v0.md](tracks/decimal-grammar-v0.md) | done | Decimal[N] compact type annotation; parse_type_ref structured node { kind, name, params:[Integer] }; grammar_version decimal-v0; OOF-DM5/6; operator signatures add/sub/mul/div/compare; fixture decimal_contract.ig |
| [tracks/observation-trust-classes-and-simulation-loop-semantics-v0.md](tracks/observation-trust-classes-and-simulation-loop-semantics-v0.md) | done | trust_class field on ObsPacket (5 classes); evidence satisfaction table; simulation loop SC-1..5 CORE criteria; Intervention typing; ComparisonReport review-only; 9 OOF-TR/SL rules; 6 SemanticIR gates |
| [tracks/claim-evidence-confidence-typing-v0.md](tracks/claim-evidence-confidence-typing-v0.md) | done | Claim stdlib type; 5 SourceProvenance classes; EvidenceLink rel+strength vocabulary; ConfidenceAssessment (label≠truth); ContradictionReport+CorrectionReceipt; FactCheckSnapshot; 8 OOF-CE rules; 6 SemanticIR gates |
| [tracks/meaning-diff-and-acceptance-semantics-v0.md](tracks/meaning-diff-and-acceptance-semantics-v0.md) | done | MeaningDiff 8-dimension domain; 3 diff layers (source/SemanticIR/SemanticImage); AcceptanceReceipt 4 scopes; diff_hash freshness; effect-right full cycle; 7 OOF-MD rules; 6 SemanticIR gates |
| [tracks/osint-product-types-and-alert-gates-v0.md](tracks/osint-product-types-and-alert-gates-v0.md) | done | Watchlist/CollectionPolicy/SourceReliability/ReputationSignal/EvidenceLinkedAlert/DailyBrief/SafeActionPolicy; 4-way separation (confidence/severity/truth/actionability); 9 OOF-OS rules; 8 SemanticIR gates |
| [tracks/polymorphic-add-parser-acceptance-v0.md](tracks/polymorphic-add-parser-acceptance-v0.md) | done | Added parser acceptance for polymorphic_add.ig: trait, impl using, contract_shape, generic contract header, and implements |
| [tracks/polymorphic-add-classifier-proof-v0.md](tracks/polymorphic-add-classifier-proof-v0.md) | done | Added stdlib-only classifier/type proof for polymorphic Add with Add[Integer]/Add[Float] accepted and Add[String] OOF-TY1 |
| [tracks/polymorphic-add-semanticir-emission-proof-v0.md](tracks/polymorphic-add-semanticir-emission-proof-v0.md) | done | Added SemanticIR emission proof for monomorphic Add[Integer]/Add[Float] with no generic ContractIR or unresolved trait calls |
| [tracks/polymorphic-add-igapp-fixture-v0.md](tracks/polymorphic-add-igapp-fixture-v0.md) | done | Packaged polymorphic Add into a .igapp fixture with explicit specialization manifest and monomorphic ContractIRs only |
| [tracks/polymorphic-add-runtime-load-boundary-v0.md](tracks/polymorphic-add-runtime-load-boundary-v0.md) | blocked | Probed current RuntimeMachine load boundary: .igapp parses/validates but load_program blocks on descriptor-ref shape and evaluator lacks stdlib.numeric.add |
| [tracks/polymorphic-add-runtime-loader-normalization-v0.md](tracks/polymorphic-add-runtime-loader-normalization-v0.md) | done | Normalized RuntimeMachine .igapp load boundary for polymorphic Add: descriptor refs, specialization manifest, metadata-only generic templates, and stdlib.numeric.add |
| [tracks/bridge-observation-envelope-implementation-plan-v0.md](tracks/bridge-observation-envelope-implementation-plan-v0.md) | done | Planned metadata-only packet builders for RuntimeMachine, TBackendAdapter, SemanticImage, Checkpoint, Resume, and CompatibilityReport |
| [tracks/temporal-lifecycle-application-scenarios-v0.md](tracks/temporal-lifecycle-application-scenarios-v0.md) | done | Pressure-tested temporal lifecycle, retention, flush, semantic GC, boundaries, and reproducibility with Spark CRM technician dispatch |
| [tracks/temporal-lifecycle-boundary-fixtures-v0.md](tracks/temporal-lifecycle-boundary-fixtures-v0.md) | done | Defined concrete GeoSignal-to-boundary fixtures for snapshots, compacted stubs, audit trails, and downgrade/block cases |
| [tracks/spark-crm-applied-language-pressure-v0.md](tracks/spark-crm-applied-language-pressure-v0.md) | done | Created the first broad applied pressure map for Spark CRM dispatch, vendor lead intake, streams, diagnostics, schema drift, and neighbor proof/formal/bridge requests |
| [tracks/spark-crm-real-business-candidate-map-v0.md](tracks/spark-crm-real-business-candidate-map-v0.md) | done | Mapped sanitized real Spark CRM business processes into Igniter-Lang implementation candidates without public secrets, endpoints, provider URLs, or infrastructure details |
| [tracks/spark-technician-availability-fixture-pressure-v0.md](tracks/spark-technician-availability-fixture-pressure-v0.md) | done | Specified the first concrete Spark technician availability fixture with synthetic facts, expected observations, result table, why-not reasons, and tenant/time/status negative cases |
| [tracks/spark-lead-signal-boundary-pressure-v0.md](tracks/spark-lead-signal-boundary-pressure-v0.md) | done | Specified the second Spark operational fixture for normalized lead signals, idempotency, hourly rollups, Decimal bid totals, retention receipts, duplicate handling, and late-signal boundary pressure |
| [tracks/spark-lead-signal-boundary-fixture-v0.md](tracks/spark-lead-signal-boundary-fixture-v0.md) | done | Added executable synthetic Spark lead-signal boundary fixture with admitted observations, idempotency evidence, exact Decimal rollup, duplicate suppression, late-boundary block, and retention receipts |
| [tracks/spark-operation-action-lifecycle-pressure-v0.md](tracks/spark-operation-action-lifecycle-pressure-v0.md) | done | Specified the third Spark operational pressure slice for actor/order/schedule context, visible vs executable action policy, request/execution receipts, duplicate pending request behavior, and optional bridge receipts |
| [tracks/spark-operation-action-lifecycle-fixture-v0.md](tracks/spark-operation-action-lifecycle-fixture-v0.md) | done | Added executable synthetic Spark operation action lifecycle fixture with visible policy, fresh executable check, request/execution receipts, duplicate pending no-op, and bridge capability cases |
| [tracks/sandbox-simulation-world-modeling-pressure-v0.md](tracks/sandbox-simulation-world-modeling-pressure-v0.md) | done | Opened the sandbox/world-modeling lane with a synthetic discrete-event digital-twin fixture: WorldModel, AssumptionSet, ParameterSet, Intervention, ScenarioRun, observation-kind trust boundaries, ModelValidityReport, and ComparisonReport |
| [tracks/sandbox-simulation-world-modeling-fixture-v0.md](tracks/sandbox-simulation-world-modeling-fixture-v0.md) | done | Added executable synthetic sandbox simulation fixture with WorldModel, assumptions, baseline/intervention ScenarioRuns, comparison report, validity report, and trust-boundary negatives |
| [tracks/human-agent-readable-contracts-pressure-v0.md](tracks/human-agent-readable-contracts-pressure-v0.md) | done | Opened the human-agent symbiosis lane with review-native contract authoring: IdeaDraft, IntentContract, ReviewProjection, MeaningDiff, AgentProposalObservation, HumanCorrectionReceipt, AcceptanceReceipt, and runtime verification |
| [tracks/human-agent-readable-contracts-fixture-v0.md](tracks/human-agent-readable-contracts-fixture-v0.md) | done | Added executable synthetic human-agent readable contracts fixture with IdeaDraft, IntentContract correction, ReviewProjection, MeaningDiff, RuntimeVerificationReceipt, AcceptanceReceipt, and HA-1..HA-5 negatives |
| [tracks/osint-fractal-traceability-pressure-v0.md](tracks/osint-fractal-traceability-pressure-v0.md) | done | Opened the OSINT-like traceability lane with synthetic source observations, claims, evidence links, confidence, contradiction, correction, fact-check snapshot, analyst decision, citation/redaction policy, and repeated-claim guardrails |
| [tracks/osint-fractal-traceability-fixture-v0.md](tracks/osint-fractal-traceability-fixture-v0.md) | done | Added executable synthetic OSINT traceability fixture with SourceObservation, Claim, EvidenceLink, ConfidenceAssessment, ContradictionReport, CorrectionReceipt, FactCheckSnapshot, AnalystDecision, Report, and OSINT negatives |
| [tracks/personal-osint-assistant-product-pressure-v0.md](tracks/personal-osint-assistant-product-pressure-v0.md) | done | Pressured Igniter-Lang with a lawful personal/business OSINT assistant product vision: watchlists, source collection, claim grouping, reputation drift, fact-check snapshots, evidence-linked alerts, safe action limits, and audit-ready reports |
| [tracks/personal-osint-assistant-product-fixture-v0.md](tracks/personal-osint-assistant-product-fixture-v0.md) | done | Added executable synthetic personal OSINT assistant product fixture with Watchlist, reliability view, brief, alert, drift, audit-ready report, and safe product negatives |
| [tracks/osint-logical-inference-contract-pressure-v0.md](tracks/osint-logical-inference-contract-pressure-v0.md) | done | Strengthened OSINT theory with a Prolog-inspired but Datalog-like bounded inference contract layer: ClaimFact, EvidenceFact, InferenceRule, Query, ProofTrace, DerivationReceipt, unsafe negation/search guardrails, and compiler/bridge requests |
| [tracks/osint-product-real-use-pressure-v0.md](tracks/osint-product-real-use-pressure-v0.md) | done | Pressure-tested the lawful OSINT assistant as a real product and general-purpose language vector across personal knowledge, reputation, vendor/customer/company, Spark vendor/lead signals, and home-lab awareness lanes |
| [tracks/compiler-first-product-pressure-v0.md](tracks/compiler-first-product-pressure-v0.md) | done | Pressure-tested whether the minimal compiler subset can still deliver value across OSINT daily brief, Spark lead/availability signal, and home-lab awareness alert; found normalized read-only evidence artifacts viable and prioritized missing primitives |
| [tracks/spark-technician-availability-fixture-v0.md](tracks/spark-technician-availability-fixture-v0.md) | done | Added executable synthetic Spark technician availability fixture with TenantScope, ScopedFactRead, StepObservation, snapshot, why-not reasons, and blocked negatives |

## Active Experiments

| Experiment | Status | Purpose |
|------------|--------|---------|
| [../experiments/runtime_machine_memory_proof/README.md](../experiments/runtime_machine_memory_proof/README.md) | done | runtime-machine-migration-replacement-image-v0: standalone memory proof, golden fixtures, checker, sidecar profiles, FFI receipt fixtures, PROP-017 schema checks, migration evidence, replacement SemanticImage, and trusted post-migration report |
| [../experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb](../experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb) | done | FFI Ruby receipt/failure fixture generator and checker |
| [../experiments/parser/igniter_lang_parser.rb](../experiments/parser/igniter_lang_parser.rb) | partial | Minimal recursive-descent parser for PROP-014/015 plus PROP-016 pressure surface; emits ParsedProgram JSON for add, availability_projection, and polymorphic_add |
| [../experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb](../experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb) | done | Standalone classifier/type proof over polymorphic_add ParsedProgram; stops before SemanticIR |
| [../experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb](../experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb) | done | Standalone SemanticIR emission proof for monomorphic polymorphic Add specializations |
| [../experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb](../experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb) | done | Passing RuntimeMachine boundary proof for polymorphic_add.igapp after loader normalization |
| [../experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb](../experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb) | done | Executable synthetic Spark technician availability fixture with positive snapshot and tenant/time/status negative cases |
| [../experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb](../experiments/spark_lead_signal_boundary_fixture/spark_lead_signal_boundary_fixture.rb) | done | Executable synthetic Spark lead-signal boundary fixture for rollup, idempotency, Decimal exactness, duplicate suppression, late-boundary block, and retention receipts |
| [../experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb](../experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb) | done | Executable synthetic Spark operation action lifecycle fixture for visible policy, executable authority, request/execution receipts, duplicate pending no-op, policy drift, and bridge capability cases |
| [../experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb](../experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb) | done | Executable synthetic sandbox simulation fixture for baseline/intervention ScenarioRuns, Synthetic/Counterfactual observations, comparison, model validity, and trust-boundary negatives |
| [../experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb](../experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb) | done | Executable synthetic human-agent readable contracts fixture for proposal, review projection, correction, meaning diff, runtime verification, scoped acceptance, and HA negatives |
| [../experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb](../experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb) | done | Executable synthetic OSINT traceability fixture for source-to-report lineage, derivative-repeat guardrails, contradiction, correction, confidence, snapshot, report, and OSINT negatives |
| [../experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb](../experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb) | done | Executable synthetic personal OSINT assistant product fixture for watchlists, reliability, daily brief, contradiction alert, drift, audit report, and safe product negatives |

## Active Proposals

See [proposals/README.md](proposals/README.md) for the full index.

| Proposal | Status | Author | Summary |
|----------|--------|--------|---------|
| [proposals/META-001](proposals/META-001-compiler-grammar-expert-entry.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Entry assessment + meta-corrections to existing tracks |
| [proposals/PROP-001](proposals/PROP-001-semantic-domain-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantic domain: V, T, Tt, C, Expr, O, F |
| [proposals/PROP-002](proposals/PROP-002-contract-composition-algebra-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Contract composition: >>, \|\|, branch, over, embed — algebraic laws + closure theorem |
| [proposals/PROP-003](proposals/PROP-003-grammar-fragment-classification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Fragment classification: CORE / ESCAPE / OOF; Pass 0 compiler; DSL keyword mapping |
| [proposals/PROP-004](proposals/PROP-004-type-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Structural types, temporal capabilities, Projection[T,horizon], Obs[kind,T], soundness |
| [proposals/PROP-005](proposals/PROP-005-bridge-observation-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal envelope: ObsPacket[kind,T], Identity/Provenance/Policy, Option[T] payload, package mappings |
| [proposals/PROP-004b](proposals/PROP-004b-axiom-layer-type-signatures-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-tier axiom stack: language built-ins, runtime contracts, platform observations |
| [proposals/PROP-006](proposals/PROP-006-runtime-contract-specification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | RuntimeContract: scheduler, clock, cache, storage, capability, distributed ESCAPE; conformance |
| [proposals/PROP-007](proposals/PROP-007-conformance-verification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Conformance verification: 5 check suites, trust levels, agent trust decision procedure |
| [proposals/PROP-008](proposals/PROP-008-tbackend-contract-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | TBackend[T]: read/append/replay/snapshot/compact/subscribe; reproducible resume; adapter classes |
| [proposals/PROP-009](proposals/PROP-009-semantic-image-resume-compatibility-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | SemanticImage; CompatibilityReport; ResumeStatus: trusted/provisional/downgraded/blocked |
| [proposals/PROP-010](proposals/PROP-010-temporal-lifecycle-retention-semantics-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | 6 lifecycle classes; flush; semantic GC roots; 5 downgrade rules (DR-1..DR-5); retention matrix |
| [proposals/PROP-011](proposals/PROP-011-runtime-machine-lifecycle-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Runtime Machine: boot/load/evaluate/checkpoint/resume — typed lifecycle using PROP-006..PROP-010 |
| [proposals/PROP-012](proposals/PROP-012-compilation-artifact-deployment-model-v0.md) | 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/decimal-idempotency-retention-formalization-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/operation-action-result-types-and-transition-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/decimal-grammar-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/observation-trust-classes-and-simulation-loop-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/claim-evidence-confidence-typing-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/meaning-diff-and-acceptance-semantics-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/osint-product-types-and-alert-gates-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-018-source-to-semanticir-minimal-pipeline-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-019-canonical-semanticir-envelope-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-020-classifier-pass-v0-formalization | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-019.1-semanticir-envelope-errata-v0 | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | proposals/PROP-021-typechecker-pass-v0-formalization | done |
| 2026-05-06 | `[Igniter-Lang Compiler/Grammar Expert]` | tracks/spark-pipeline-parser-acceptance-v0 | done |
| [proposals/PROP-013](proposals/PROP-013-stdlib-fold-aggregate-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Collection[T], Option[T], Result[T,E]; fold/map/filter/group_by/avg; TR-1 termination; aggregated_from links |
| [proposals/PROP-014](proposals/PROP-014-source-syntax-semanticir-boundary-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Minimal syntax kernel; ParsedProgram shape; 4-stage path to SemanticIR; OOF rejection rules; .igapp/ mapping |
| [proposals/PROP-015](proposals/PROP-015-grammar-module-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | def blocks (pure/non-recursive/inlined); TypeDecl (structural records); module/import; full v0 BNF; Add + Availability source files |
| [proposals/PROP-016](proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Generic contracts; traits (compile-time); impl coherence; contract_shape; implements structural; monomorphization; compile-time overload only; no unresolved overloads in SemanticIR |
| [proposals/PROP-017](proposals/PROP-017-schema-evolution-contract-migration-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Schema versioning; CompatibilityReport; MigrationReceipt; replacement SemanticImage; 5 migration strategies |
| [proposals/PROP-018](proposals/PROP-018-source-to-semanticir-minimal-pipeline-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | v0 source subset; parser AST shape; Pass 0/1 classifier gates; SemanticIR emission; OOF-P/DM/CE/OS/RT/MD unified; 5 conformance cases |
| [proposals/PROP-019](proposals/PROP-019-canonical-semanticir-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Freezes kind:semantic_ir_program; format_version; canonical inputs/outputs/nodes; contract_ref; resolved_type required; _fixture extension key; migration from two divergent shapes; bridge artifact_ref |
| [proposals/PROP-019.1](proposals/PROP-019.1-semanticir-envelope-errata-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Errata: OOF->CompilationReport (not SemanticIR); oof_log removed; 4-stage pipeline defined; stdlib monomorphic naming; assembler acceptance criteria A1..A6 |
| [proposals/PROP-020](proposals/PROP-020-classifier-pass-v0-formalization.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | ParsedProgram->ClassifiedProgram; SymbolTable two-scope; node classification rules; CORE/ESCAPE/OOF propagation; OOF-P1/P2/P4/CE4/OS2; diagnostics path shape; 5 conformance cases |
| [proposals/PROP-021](proposals/PROP-021-typechecker-pass-v0-formalization.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | ClassifiedProgram->TypedProgram; TypeEnv/ShapeEnv/OperatorEnv; annotation-driven resolution; Decimal scale arithmetic (mul=A+B, add=scales_equal); 7 OOF-TC rules; MonomorphizationPass deferred; 5 conformance cases |

## Active Bridge Notes

| Bridge Note | Status | Purpose |
|-------------|--------|---------|
| [bridge/README.md](bridge/README.md) | active index | Bridge Agent landing pad for approved language-to-platform requests |
| [bridge/bridge-agent-entry-v0.md](bridge/bridge-agent-entry-v0.md) | research | Initializes Bridge Agent presence and records current bridge pressure before package integration |
| [bridge/schema-compatibility-diagnostics-bridge-v0.md](bridge/schema-compatibility-diagnostics-bridge-v0.md) | proposal | First metadata-only bridge request for schema compatibility diagnostics |
| [bridge/schema-compatibility-diagnostics-package-touchpoint-map-v0.md](bridge/schema-compatibility-diagnostics-package-touchpoint-map-v0.md) | proposal | Architect-reviewable package target map for SchemaCompatibilityDiagnostic v0 |
| [bridge/schema-compatibility-diagnostics-igniter-contracts-plan-v0.md](bridge/schema-compatibility-diagnostics-igniter-contracts-plan-v0.md) | proposal | Architect-approved implementation plan for SchemaCompatibilityDiagnostic v0 in igniter-contracts |
| [bridge/schema-migration-bridge-profile-v0.md](bridge/schema-migration-bridge-profile-v0.md) | proposal | Single-hop migration evidence profile for SchemaCompatibilityDiagnostic v0 |
| [bridge/spark-availability-diagnostics-bridge-profile-v0.md](bridge/spark-availability-diagnostics-bridge-profile-v0.md) | proposal | Metadata-only diagnostics profile for the executable Spark availability fixture |
| [bridge/operation-diagnostics-and-receipts-bridge-profile-v0.md](bridge/operation-diagnostics-and-receipts-bridge-profile-v0.md) | proposal | Generic metadata-only operation action diagnostics and receipt profiles before package work |
| [bridge/lead-boundary-diagnostics-retention-bridge-profile-v0.md](bridge/lead-boundary-diagnostics-retention-bridge-profile-v0.md) | proposal | Metadata-only lead boundary diagnostics, rollup, Decimal, idempotency, and retention receipt profiles |
| [bridge/model-validity-and-scenario-comparison-bridge-profile-v0.md](bridge/model-validity-and-scenario-comparison-bridge-profile-v0.md) | proposal | Metadata-only simulation run diagnostics, model validity, scenario comparison, assumption diff, and review-only strategy profiles |
| [bridge/human-agent-review-approval-bridge-profile-v0.md](bridge/human-agent-review-approval-bridge-profile-v0.md) | proposal | Metadata-only human-agent proposal, review, meaning diff, correction, verification, and acceptance receipt profiles |
| [bridge/osint-claim-factcheck-correction-bridge-profile-v0.md](bridge/osint-claim-factcheck-correction-bridge-profile-v0.md) | proposal | Metadata-only OSINT-like source observation, claim trace, evidence, confidence, contradiction, fact-check snapshot, analyst decision, citation/redaction, and correction profiles |
| [bridge/osint-product-bridge-profiles-v0.md](bridge/osint-product-bridge-profiles-v0.md) | proposal | Metadata-only personal OSINT assistant product profiles aligned with VerificationReport custom metadata carrier semantics |
| [bridge/semanticir-verification-report-bridge-v0.md](bridge/semanticir-verification-report-bridge-v0.md) | proposal | Report-only SemanticIR proof result bridge into VerificationReport metadata and carrier manifest semantics |
| [bridge/compiler-pipeline-profile-bridge-v0.md](bridge/compiler-pipeline-profile-bridge-v0.md) | proposal | Unified report-only compiler pipeline profile family aligned with VerificationReport compiler_pipeline_profiles carrier semantics |
| [bridge/compiler-pipeline-profile-prop019-alignment-v0.md](bridge/compiler-pipeline-profile-prop019-alignment-v0.md) | proposal | PROP-019/019.1-aligned compiler_pipeline_profiles examples with canonical semantic_ir_program and separated CompilationReport diagnostics |

## Core Documents

| File | Purpose |
|------|---------|
| [../roles/README.md](../roles/README.md) | Role passports and neighbor map for Igniter-Lang agents |
| [bridge/README.md](bridge/README.md) | Bridge note index and Bridge Agent rules |
| [ecosystem-split-proposal.md](ecosystem-split-proposal.md) | Defines the Igniter vs Igniter-Lang split |
| [research-process.md](research-process.md) | Research lifecycle, document rotation, handoff protocol |
| [agent-motion.md](agent-motion.md) | Current multi-agent movement and handoff routing |
| [applied-pressure-directions.md](applied-pressure-directions.md) | Meta thesis: four applied pressure lanes for operational systems, human-agent symbiosis, OSINT-like traceability, and sandbox/simulation modeling |
| [modeling-methodologies-pressure.md](modeling-methodologies-pressure.md) | Meta thesis: modeling methodology taxonomy with Digital Twin and Agent-Based Modeling as priority simulation pressure lanes |
| [temporal-positioning.md](temporal-positioning.md) | Meta thesis: time, contracts, projections, and language positioning |
| [temporal-lifecycle.md](temporal-lifecycle.md) | Meta thesis: lifecycle classes for T, flush, semantic GC, retention, and boundary compaction |
| [axiomatic-contract-model.md](axiomatic-contract-model.md) | Meta thesis: language, runtime, distributed execution, and time as contract boundaries |
| [runtime-machine.md](runtime-machine.md) | Meta thesis: Runtime Machine lifecycle, TBackend, semantic image, and resume model |
| [compilation-deployment.md](compilation-deployment.md) | Meta thesis: compilation artifacts, deployment modes, native backend path, and contractable FFI |
| [current-status.md](current-status.md) | Compact fixed point for the current round: theory, devkit proof, fixtures, gaps, and next slices |
| [next-slices.md](next-slices.md) | Compact active planning note for the next agent slices and Package Agent decision |
| [language-position-report.md](language-position-report.md) | Meta thesis: language position, ECL paradigm, 7 blind spots, 7 insights, strategic assessment |
| [runtime-model-spec-questions-v0.md](runtime-model-spec-questions-v0.md) | Forward spec: variables (single-assignment), scoping (lexical 3-level), memory (value semantics/region), GC (evaluation+semantic), parallelism (structural DAG), self-hosting (Stage 0→5) |

## Research Vectors

- Observable Contract Language
- Everything Is Contract
- Organic Axiom Layer
- Agent-Friendly Language
- Human-Agent Symbiosis / Review-Native Contracts
- OSINT-Like Fractal Traceability
- Sandbox / Simulation / World Modeling
- Digital Twin Modeling
- Agent-Based Modeling
- Temporal Contract Semantics
- Projections / Slices / As-Of Views
- Contract Synthesis
- Igniter Bridge
- Formal Semantic Domain (PROP-001)
- Contract Composition Algebra (PROP-002)
- Grammar Fragment Classification (PROP-003)
- Type System v0 (PROP-004)
- Temporal Contract Semantics (PROP-004 + temporal-positioning.md)
- Projections / Slices / As-Of Views (Projection[T, horizon] — PROP-004)
- Bridge Observation Envelope (PROP-005)
- Axiom Layer Type Signatures (PROP-004b)
- Runtime Contract Specification (PROP-006)
- Conformance Verification (PROP-007)
- TBackend Contract (PROP-008)
- Semantic Image and Resume Compatibility (PROP-009)
- Temporal Lifecycle and Retention Semantics (PROP-010)
- Runtime Machine Lifecycle (PROP-011)
- Runtime Machine Executable Proof Plan (Research Agent track)
- Runtime Machine Memory Proof (Experiment)
- Runtime Machine Proof Packet Fixtures (Research Agent track)
- Runtime Machine Proof Packet Builder Check (Research Agent track)
- Runtime Machine Proof Sidecar Builder Profiles (Research Agent track)
- Runtime Machine Proof Sidecar Profile Modes (Research Agent track)
- Runtime Machine External Candidate and FFI Proof (Research Agent track)
- Runtime Machine External Candidate Normalizer Fixtures (Research Agent track)
- Runtime Machine Schema Check Standalone Fix (Research Agent track)
- Runtime Machine Schema Migration Fixture (Research Agent track)
- Runtime Machine Migration Replacement Image (Research Agent track)
- Migration Replacement Image Checker (DONE — P-1..P-10, migration_chain [], no supersedes, OOF-MR3 blocked)
- Add.igapp Devkit Fixture (Compiler/Grammar Expert track)
- Compilation and Deployment (compilation-deployment.md)
- Temporal Lifecycle (temporal-lifecycle.md)
- Runtime Machine Lifecycle (PROP-011)
- Compilation Artifact and Deployment Model (PROP-012)
- Igniter-Lang Position Report (language-position-report.md)
- Temporal Lifecycle (temporal-lifecycle.md)
- Axiomatic Contract Model (axiomatic-contract-model.md)
- Runtime Machine (runtime-machine.md)
- Compilation and Deployment (compilation-deployment.md)
- stdlib v0 (PROP-013: Collection, Option, Result, fold, temporal primitives)
- Source Syntax to SemanticIR Boundary (PROP-014: minimal grammar kernel)
- Grammar and Module System (PROP-015: def, TypeDecl, module/import, full v0 BNF)
- Polymorphic Add Parser Acceptance (DONE — polymorphic_add.ig -> ParsedProgram)
- Polymorphic Add Classifier Proof (DONE — TraitEnv/ImplEnv/ShapeEnv -> TypedProgram, Add[String] OOF-TY1)
- Polymorphic Add SemanticIR Emission Proof (DONE — Add[Integer]/Add[Float] ContractIR shapes, no unresolved trait calls)
- Polymorphic Add .igapp Fixture (DONE — explicit specialization manifest, generic metadata only, monomorphic loadable contracts)
- Polymorphic Add Runtime Load Boundary (BLOCKED — load_program descriptor refs shape; next operator blocker stdlib.numeric.add)
- Spark Technician Availability Fixture (DONE — synthetic TenantScope/ScopedFactRead/PipelineStep proof with why-not reasons)
- Parser Acceptance Harness (DONE — add.ig + availability_projection.ig → ParsedProgram, 61 specs)
- Polymorphic Add Devkit Fixture (DONE — trait/impl/contract_shape pressure fixture, monomorphic SemanticIR specializations, no unresolved RuntimeMachine overloads)
- FFI Ruby Contractable Proof (DONE — CapabilityGate + call discipline, 36 specs)
- ESCAPE Capability Algebra (QUEUED — proposal ID TBD)
- Contract Schema Evolution and Migration (QUEUED — PROP-017)
- Pattern Matching and Generics (QUEUED — post-PROP-016)
- Runtime Machine FFI Ruby Receipt Fixtures (QUEUED — research track)

## Experiments and Source Files

```text
igniter-lang/experiments/parser/
  igniter_lang_parser.rb     <- Lexer + recursive-descent Parser (PROP-014/015 grammar kernel)

igniter-lang/experiments/runtime_machine_memory_proof/
  runtime_machine_memory_proof.rb <- standalone RuntimeMachine proof with schema_check
  compiled_program.rb       <- .igapp loader extension that supplies schema_descriptor
  ffi_ruby_proof.rb         <- FFIRequirement, CapabilityGate, FFIAdapter (PROP-012 §FFI)

igniter-lang/source/
  add.ig                     <- canonical CORE source (module Lang.Examples.Add)
  availability_projection.ig <- ESCAPE source with window/defs/TBackend reads
  polymorphic_add.ig         <- polymorphic Add pressure fixture, not current parser acceptance
  polymorphic_add.parsed_program.expected.json <- expected future ParsedProgram shape

spec/igniter/
  parser_acceptance_spec.rb     <- 61 acceptance tests (ParsedProgram -> fixture compare path)
  ffi_ruby_contractable_spec.rb <- 36 FFI call-discipline tests
  add_igapp_devkit_spec.rb      <- 32 Add devkit tests
  availability_projection_igapp_spec.rb <- 29 window lifecycle tests
Total: 158 examples, 0 failures
```

## Review Cadence

The research agent should produce compact completed slices. `[Architect
Supervisor / Codex]` periodically reviews a complete slice and then either:

- approves the direction
- narrows the next experiment
- rejects a branch
- requests a bridge note back to Igniter platform

## Handoff Format

Use the template in [../handoff/HANDOFF_TEMPLATE.md](../handoff/HANDOFF_TEMPLATE.md).

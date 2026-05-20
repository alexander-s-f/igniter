# Compiler Pack Boundary Proof Fixture And OOF Survey v0

Card: S3-R90-C2-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Track: `compiler-pack-boundary-proof-fixture-and-oof-survey-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-20

---

## Role And Neighbor Awareness

Assigned track: no-code evidence survey for the R90 compiler pack boundary
report.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — pack, pass, fragment, and OOF
  ownership.
- `[Igniter-Lang Bridge Agent]` — future public API/CLI, loader/report,
  CompatibilityReport, package, and runtime bridge surfaces remain closed.

This survey changes no code and authorizes no implementation.

---

## Current Horizon

```text
R90 C0-O selected the existing compiler-pack-boundary-report-v0.md path.
C1 has landed the R90 addendum in that file.
The C1 report is descriptive/no-code and keeps S3-R31 as historical foundation.
C2 adds evidence pressure: proof fixtures, OOF families, fragments, report-only
and strict-terminal touchpoints mapped to candidate packs.
```

---

## Read Set

- `docs/org/tracks/compiler-pack-boundary-report-r90-file-boundary-v0.md`
- `docs/gates/compiler-mainline-next-axis-decision-v0.md`
- `docs/tracks/stage3-round89-status-curation-v0.md`
- `docs/tracks/compiler-mainline-touchpoint-and-proof-gap-survey-v0.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- selected proof summaries under `experiments/`
- current compiler/profile files discovered by:
  `rg "OOF-|fragment|compiler_profile_contract|strict_terminal|compiler_profile_id" igniter-lang/docs igniter-lang/experiments igniter-lang/lib -g "*.md" -g "*.json" -g "*.rb"`

No broad proof suite was run.

---

## C0 / C1 Boundary Check

S3-R90-C0-O chose:

```text
Option A: update compiler-pack-boundary-report-v0.md with a clearly marked R90 addendum section.
```

Selected report path:

```text
igniter-lang/docs/tracks/compiler-pack-boundary-report-v0.md
```

C1 has already landed a current R90 section at that path and preserved the
S3-R31 body as historical foundation. This C2 survey therefore does not rewrite
the C1 report. It supplies a separate evidence map for C3 pressure and C4
decision.

---

## Proof / Evidence Map

| Proof fixture / evidence source | Current owner surface | Candidate pack owner | Migration risk | Blocked surfaces touched | Evidence state |
| --- | --- | --- | --- | --- | --- |
| `classifier_pass_proof`, `typechecker_proof`, `source_to_semanticir_fixture`, `stage1_close_candidate`, `stage2_close_candidate` | Parser, Classifier, TypeChecker, SemanticIR, Assembler | `CoreLanguagePack` plus support registries | Critical: JSON/golden and pass ordering drift | broad compiler rewrites, `.igapp` migration | live compiler + proof fixtures |
| `parser_oof_hardening_stage2_proof` and parser OOF-PG gates | Parser syntax/error ownership | `CoreLanguagePack` / `PipelinePack` / `OOFRegistryPack` | High: parser precedence and public OOF code drift | parser rewrites, pipeline scheduler | live parser + proof-local evidence |
| `history_type_proof`, `sparkcrm_bihistory_fixture`, `temporal_semanticir_access_node`, `temporal_assembler_boundary` | TypeChecker, SemanticIR, Assembler temporal nodes | `TemporalPack` | Critical: temporal metadata could imply live read authority | RuntimeMachine, TBackend, Ledger, BiHistory production | live compiler + proof-local runtime |
| `temporal_runtime_load_guard`, `runtime_compatibility_report_temporal_load_check`, `temporal_executor_lib_prep`, `temporal_read_observation_proof` | Runtime/load guard and Phase 1 executor proofs | not a compiler pack; Runtime/Bridge lane | Critical: compiler pack names may be mistaken for runtime authorization | loader/report, CompatibilityReport, Gate 3, TBackend | proof-local / restricted runtime evidence |
| `stream_t_proof`, stream source fixtures, stream OOF-S checks | Parser, Classifier, TypeChecker, SemanticIR stream nodes | `StreamPack` | High: ingress/external boundary and fold semantics | production ingress, stream executor, TBackend read-inside-fold | live compiler + proof-local runner |
| `olap_point_proof`, OLAP source/typechecker/SemanticIR fixtures | Parser/TypeChecker/Emitter OLAP surfaces | `OLAPPack` | High: analytical metadata could imply executor/distributed OLAP | distributed scatter/gather, OLAP executor | live compiler + proof-local |
| `invariant_severity_proof`, invariant parser/typechecker/source fixtures | Parser/TypeChecker/Emitter invariant surface | `InvariantPack` | Medium-high: runtime observation/persistence confusion | invariant persistence, runtime enforcement | live compiler + proof-local observation |
| `contract_modifiers_proof`, `contract_modifiers_pack_native_boundary` | Parser/Classifier/TypeChecker/SemanticIR modifier propagation | `ContractModifiersPack` | Medium: small cross-pass surface but fragment widening touches escape | effect runtime, public effect authority | live compiler + proof-local pack descriptor |
| `assumptions_proof`, assumptions source-to-SemanticIR fixture | Parser/Classifier/TypeChecker/SemanticIR assumptions | `AssumptionsPack` | Medium-high: epistemic fragment and evidence-list validation split | PROP-033 evidence validation/runtime receipts | live compiler + proof-local |
| `claim_evidence`, `evidence_linked_alert`, confidence/bool negative fixtures | Classifier/TypeChecker/Emitter evidence checks | `EvidenceObservationPack` | Medium: evidence vs observation ownership still mixed | bridge receipts, runtime evidence validation | live compiler fixtures |
| `prop037_descriptor_oof_pr_proof`, progression descriptor/readiness proofs | Descriptor/report-only progression pressure | `PipelinePack` pressure only | High if treated as fragment/runtime pack too early | scheduler/materializer/durable queue/checkpoint | docs/proof-local only |
| `minimal_compiler_profile_finalization_proof`, `assembler_compiler_profile_id_field`, PROP-036 CLI/facade proofs | Profile source transport and assembler identity | profile source / `CompilerProfileContractPack` support boundary | High: public API/CLI and manifest/golden drift | profile discovery/defaulting, mandatory id, `.ilk`, signing | live bounded transport + proof-local |
| `compiler_profile_contract_proof`, validator coverage, digest shape/recompute/report-only proofs | `CompilerProfileContractValidator` and report-only validation | `CompilerProfileContractPack` support boundary | Critical: validator evidence could become refusal authority | compile refusal widening, loader/report, public diagnostics | live validator + report-only/proof-local |
| `prop038_report_only_compiler_integration` | `CompilationReport` nested validation annotation | compiler report support boundary | Critical: annotated report could leak into artifacts | `.igapp` mutation, persisted success reports | live report-only |
| `prop038_strict_refusal_live_implementation_proof` | `CompilerOrchestrator` + `CompilerResult.strict_terminal` | orchestrator/status boundary, not pack validator | Critical: internal strict terminal could become public strict mode | public API/CLI strict source, sidecars, `.igapp`, loader/report | live internal foundation |
| `compiler_pack_shadow_profile_proof`, `compiler_kernel_pack_registry_spike`, `compiler_kernel_ordered_rule_precedence` | Shadow pack/profile/kernel evidence | future kernel/profile support | Medium-high: proof-local can be mistaken for implementation | live dispatch, pack registry implementation | proof-local only |

---

## OOF Ownership Survey

| Code family | Current evidence / layer | Candidate owner | Survey note |
| --- | --- | --- | --- |
| `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-P28`, `OOF-TY0` | Parser, TypeChecker, SemanticIR emitter generic errors | `CoreLanguagePack` + `OOFRegistryPack` | Preserve public code/stage stability before registry migration. |
| `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5` | Parser pipeline gates | `PipelinePack` | Pipeline remains syntax/descriptor pressure only; no scheduler authority. |
| `OOF-DM3` | Parser Decimal scale | `CoreLanguagePack` or future numeric support | Do not split a numeric pack unless numeric surface expands. |
| `OOF-H*`, `OOF-BT*`, `OOF-TM*` | TypeChecker temporal/history checks plus compatibility aliases | `TemporalPack` | Keep compile-time temporal diagnostics separate from live TBackend read refusal. |
| `OOF-S1`, `OOF-S5` | Parser stream bounds | `StreamPack` | Parser ownership remains syntax-owned; no production ingress implication. |
| `OOF-S2`, `OOF-S4` | Classifier stream/window/direct-use checks | `StreamPack` | Classifier ownership must survive any pack split. |
| `OOF-S3` | TypeChecker fold body CORE restriction | `StreamPack` | Important cross-pack check: escape inside stream fold stays type-owned. |
| `OOF-O3`, `OOF-O4`, `OOF-O5`, warning `OOF-O2` | TypeChecker OLAP checks | `OLAPPack` | Parser-local OLAP syntax failures may currently surface as generic parser OOFs; avoid public code churn. |
| `OOF-IV*`, `OOF-I*`, `PINV-*`, `TINV-*` | Parser/TypeChecker invariant checks and proof vocabulary | `InvariantPack` | Runtime violation reporting/persistence remains separate. |
| `OOF-M1` | Classifier detects pure+escape, TypeChecker propagates | `ContractModifiersPack` | Best first optional pack candidate because ownership is narrow and proven. |
| `OOF-A1`, `TASSUMP-1` | Classifier/TypeChecker assumptions path | `AssumptionsPack` | Evidence-list validation remains PROP-033/out of scope. |
| `OOF-CE4`, `OOF-OS2`, `OOF-OS4` | Classifier/Emitter evidence/confidence fixtures | `EvidenceObservationPack` | Needs future split decision: evidence, observation, or combined pack. |
| `OOF-PR*` | PROP-037 descriptor proof/readiness work | `PipelinePack` pressure only | Not a compiler migration authority and not a PROGRESSION fragment class. |
| `OOF-RUNTIME-SMOKE` | Runtime smoke diagnostics helper | Runtime smoke boundary | Not an OOF registry seed for language packs. |
| `compiler_profile_contract.*` | Nested validator diagnostics | `CompilerProfileContractPack` support boundary | Not OOF; report-only evidence unless strict requirement selects terminal. |
| `compiler_profile_contract_refusal.*` | Strict terminal wrapper diagnostics | Orchestrator/status boundary | Internal-only terminal diagnostics; no public strict source. |

---

## Fragment Ownership Survey

| Fragment / status | Current evidence | Candidate owner | Survey note |
| --- | --- | --- | --- |
| `core` | Base contracts, computes, outputs, CORE-typed temporal read values | `CoreLanguagePack` | Stable baseline. |
| `escape` | External reads, stream ingress compatibility, modifier widening | `EscapeBoundaryPack` | Still a coarse trust-boundary bucket; do not split without FragmentRegistry proof. |
| `temporal` | History/BiHistory classifier/typechecker/SemanticIR/assembler proofs | `TemporalPack` | Compiler artifact class is accepted; runtime execution remains guarded/closed. |
| `stream` | Stream nodes and assembler precedence include stream; classifier history has escape interplay | `StreamPack` + `FragmentRegistryPack` | Needs registry proof before changing stream-vs-escape contract classification. |
| `epistemic` | PROP-032 assumptions implementation/proof path and Ch6 assumption metadata | `AssumptionsPack` | S3-R31 text saying "draft/no implementation" is historical only; R90 current section treats it as implemented surface. |
| `oof` | Classifier/typechecker/emitter blocked status and assembler refusal for OOF contracts | `OOFRegistryPack` / report status | Decide later whether this is fragment, status, or both; do not dispatch on it now. |
| `olap` | OLAPPoint proof and nodes; no accepted fragment class promotion | `OLAPPack` candidate | Keep as candidate owner, not current fragment class, unless later proposal opens it. |
| `progression` | PROP-037 explicitly excludes PROGRESSION fragment class | none in v0 | Keep progression metadata under `pipeline` for now. |

---

## Stale / Conflicting S3-R31 Assumptions To Update Or Guard

These are not C1 blockers if the R90 addendum remains the current section, but
they are pressure points for C3/C4 to ensure the historical S3-R31 body is not
misread as current canon.

| S3-R31 assumption | Current R90 state | Required handling |
| --- | --- | --- |
| `compiler-pack-boundary-report-v0.md` is only the S3-R31 report | C0-O selected the same file path with a current R90 addendum | Keep R90 section visibly current; preserve S3-R31 as historical foundation. |
| "Do not add `compiler_profile_id` to `.igapp` manifests yet" | Bounded PROP-036 source transport can emit `compiler_profile_id` when a valid `compiler_profile_source` is supplied; legacy no-flag still omits it | Rephrase as: no mandatory transition, no golden migration, no discovery/defaulting; bounded optional transport exists. |
| AssumptionsPack is "draft/spec-only" or "no implementation yet" | PROP-032 assumptions compiler path is implemented/proven; R90 table marks it implemented | Treat S3-R31 wording as stale history; current evidence is implemented compiler/proof surface, with PROP-033 still closed. |
| `compiler-pack-shadow-profile-proof-v0` is the next proof | R90 recommends refreshed `compiler-pack-shadow-profile-proof-v1` after current R84/R86/PROP-032 state | Use v1 naming or explicit update scope to avoid rerunning stale profile assumptions. |
| `epistemic` precedence candidate from S3-R31 | Current classifier has explicit `epistemic`, but precedence and registry ownership still need proof | Keep as FragmentRegistry open issue, not a settled install-order rule. |
| "Current assembler has no dedicated OLAP artifact" | Still broadly true, but R90 has post-switch smoke and OLAP compiler evidence | Keep OLAP executor/assembler extension closed; classify current evidence as compiler/proof only. |
| S3-R31 profile id manifest boundary proof includes future required policy | Current public/CLI path remains optional `compiler_profile_source`; missing profile id is not a compile refusal | Guard against treating proof-local required-profile policy as live behavior. |
| Old body talks about "POC closure" and future migration order | R90 is a design/report route, not POC closure or migration authorization | Keep migration order as historical strategy only; implementation remains held. |

---

## C1 / C3 / C4 Recommendations

To C1 / Compiler-Gravity:

- Keep the R90 addendum as current and S3-R31 as historical foundation.
- If refining the pack report, explicitly distinguish "bounded optional
  `compiler_profile_id` transport exists" from "mandatory profile id transition
  remains closed."
- Treat assumptions/epistemic as current implemented compiler evidence, with
  PROP-033 evidence validation still closed.

To C3 / Pressure:

- Pressure the report for three leakage risks:
  public strict source, loader/report readiness, and runtime authority from pack
  names.
- Check S3-R31 stale assumptions are not quoted as current canon in later
  recommendations.
- Check `compiler_profile_contract.*` remains nested evidence, while
  `compiler_profile_contract_refusal.*` remains internal strict terminal wrapper
  diagnostics only.

To C4 / Architect Decision:

- Accept the pack report only as design/report if C3 finds no authority leak.
- Route next to `compiler-pack-shadow-profile-proof-v1` or
  `oof-fragment-registry-shadow-proof-v0`; both should remain proof-only.
- Keep Ch6 sync as a separate docs/spec route unless C4 explicitly opens it.

---

## Closed Surfaces

This survey does not authorize:

- code edits;
- parser/classifier/TypeChecker/SemanticIR/assembler rewrites;
- live pack dispatch or pack registry implementation;
- profile-assembled compiler migration;
- public API/CLI widening or public strict source;
- profile discovery/defaulting/finalization;
- mandatory `compiler_profile_id` transition;
- `.igapp` golden or manifest migration;
- `.ilk`, receipts, signing, or production verification;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- compile refusal beyond the accepted internal-only strict terminal foundation;
- persisted strict terminal sidecars or reports;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory production evaluation, stream/OLAP executors,
  production cache, signing, or production behavior;
- progression scheduler/materializer/durable queue/checkpoint;
- Spark fixture/spec work or Spark production integration.

---

## Command Matrix

| Command / read | Result | Purpose |
| --- | --- | --- |
| `rg "S3-R90-C0|compiler-pack-boundary|compiler mainline|pack boundary" igniter-lang/docs -g "*.md"` | PASS | Located C0-O, R90 cards, and current pack report. |
| `sed -n ... compiler-pack-boundary-report-r90-file-boundary-v0.md` | PASS | Read selected R90 file boundary. |
| `sed -n ... compiler-mainline-next-axis-decision-v0.md` | PASS | Read R89 C4-A authorization and hold triggers. |
| `sed -n ... stage3-round89-status-curation-v0.md` | PASS | Read R89 closure packet and R90 handoff. |
| `sed -n ... compiler-mainline-touchpoint-and-proof-gap-survey-v0.md` | PASS | Read C2 prior touchpoint map. |
| `nl -ba ... compiler-pack-boundary-report-v0.md` | PASS | Read C1 R90 addendum and S3-R31 historical body. |
| `find igniter-lang/experiments -maxdepth 3 -type f -name '*summary.json'` | PASS | Built proof summary inventory. |
| `rg "OOF-|fragment|compiler_profile_contract|strict_terminal|compiler_profile_id" ...` | PASS | Located OOF, fragment, and profile touchpoints. |
| `ruby -rjson -e '<selected summary readout>'` | PASS | Sampled selected proof summary PASS states. |

No tests or broad proof commands were run.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-pack-boundary-proof-fixture-and-oof-survey-v0
Status: done
Card: S3-R90-C2-P1
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- C0-O selected compiler-pack-boundary-report-v0.md as the R90 report path.
- C1 has landed a current R90 addendum; S3-R31 remains historical foundation.
- Evidence maps cleanly to candidate packs, but pack ownership must remain
  descriptive until shadow-profile/registry proofs are explicitly opened.

[S]
- Strongest next proof routes: compiler-pack-shadow-profile-proof-v1 and
  oof-fragment-registry-shadow-proof-v0.
- Stale S3-R31 pressure: compiler_profile_id is no longer "not in .igapp" in
  all cases; bounded optional source transport can emit it, while mandatory
  transition remains closed.
- Assumptions/epistemic are current compiler evidence, not merely draft-only,
  while PROP-033 evidence validation remains closed.

[T]
- No code edited.
- No specs/proposals updated.
- No broad tests run.
- Track doc added only.

[R]
- C3 should pressure for authority leaks from public strict source,
  loader/report readiness, runtime authority, and historical S3-R31 wording.
- C4 should accept only as design/report unless C3 finds a blocker; then route a
  proof-only shadow profile or OOF/fragment registry slice.

[Next]
- [Q] Compiler/Grammar Expert: should `oof` be modeled as fragment, status, or
  both in the registry proof?
- [Q] Bridge Agent: keep public/API/CLI, loader/report, CompatibilityReport,
  and runtime bridge surfaces closed until a separate gate opens them.
```

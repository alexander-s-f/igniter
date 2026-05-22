# Compiler Pack Pass Boundary Ownership Map v0

Card: LANG-R140-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R139-P1, LANG-R138-D1  
Track: `compiler-pack-pass-boundary-ownership-map-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: proof/design ownership map for future `CompilerPack`
responsibility across compiler pass boundaries.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns final pack/pass semantics,
  ownership ambiguity resolution, and future formalization.
- `[Igniter-Lang Bridge Agent]` - must review before public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, production, or Spark
  surfaces open.

---

## Current Horizon

```text
R138 defines CompilerProfile as a frozen compiler-surface snapshot.
R138 defines CompilerPack as a declarative contribution unit.
R139 proves pure projection from R136 carrier map to migration model.
R140 maps future pack ownership per pass boundary without implementation.
```

---

## Read Set

- `docs/tracks/compiler-pack-profile-migration-design-v0.md`
- `docs/tracks/internal-profile-migration-projection-proof-v0.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `docs/tracks/oof-fragment-registry-shadow-proof-v0.md`
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md`
- `experiments/internal_profile_migration_projection/out/internal_profile_migration_projection.json`
- current file/proof anchors discovered with `rg --files`

---

## Ownership Map Artifact

Ownership map:

```text
igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json
```

Summary:

```text
igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map_summary.json
```

Digest:

```text
2342d159c833e5d0900cf4f4
```

Source projection digest:

```text
6d80b68b3a73231481759c9d
```

---

## Boundary Map

| Boundary | Candidate owner pack | Contribution type | Current implementation anchor | Proof/golden anchor | Ambiguity risk | Required parity proof before migration |
| --- | --- | --- | --- | --- | --- | --- |
| `parser` | `CoreLanguagePack` | syntax rule metadata and parser OOF ownership | `lib/igniter_lang/parser.rb` | parser OOF hardening, parsed AST goldens, contract modifiers parsed goldens | high parser precedence drift | byte-for-byte ParsedProgram and parser OOF golden parity |
| `classifier` | `CoreLanguagePack` | fragment assignment, OOF blocking, ClassifiedProgram metadata | `lib/igniter_lang/classifier.rb` | classifier pass proof, classified goldens, contract modifiers classified goldens | high fragment and OOF owner overlap | byte-for-byte ClassifiedProgram fragment and OOF parity |
| `typechecker` | `CoreLanguagePack` | type rule metadata, TypedProgram metadata, type OOF ownership | `lib/igniter_lang/typechecker.rb` | typechecker proof, typed goldens, classified fixtures | high shared type environment and cross-surface refs | byte-for-byte TypedProgram and type OOF golden parity |
| `semanticir` | `CoreLanguagePack` | lowering metadata, SemanticIR node shape, CompilationReport inputs | `lib/igniter_lang/semanticir_emitter.rb` | source-to-SemanticIR goldens, compilation reports, temporal SemanticIR goldens | critical SemanticIR/report JSON drift | byte-for-byte SemanticIRProgram and CompilationReport parity |
| `assembler` | `CoreLanguagePack` | artifact assembly metadata, requirements, manifest shape | `lib/igniter_lang/assembler.rb` | igapp assembler proof, temporal assembler boundary, profile-id assembler proof | critical `.igapp`/manifest/report-for-assembly drift | byte-for-byte `.igapp`, manifest, contracts, requirements, and report-for-assembly parity |
| `oof_registry` | `OOFRegistryPack` | descriptor owner/stage/alias/public-code lifecycle metadata | `lib/igniter_lang/oof_fragment_registry.rb` | OOF shadow descriptors, OOF policy model, source-input proof summary | critical OOF code drift and namespace leakage | public OOF code/message/stage/alias/exclusion namespace parity |
| `fragment_registry` | `FragmentRegistryPack` | fragment rows, precedence, guarded non-fragments, status projection metadata | `lib/igniter_lang/classifier.rb` | fragment shadow registry, OOF policy model, classified goldens | critical fragment precedence drift and OOF status confusion | fragment assignment, precedence, guarded non-fragment, and OOF status projection parity |

Secondary candidate packs are recorded in the JSON artifact. They are
responsibility pressure, not dispatch authorization.

---

## Hold Points

| Hold point | Trigger | Action |
| --- | --- | --- |
| `HP2 pack_ownership_ambiguity` | A pass contribution has multiple plausible pack owners. | Hold; produce ownership pressure table before implementation. |
| `HP3 fragment_precedence_ambiguity` | Fragment registry proof cannot preserve current classifier behavior. | Hold; no classifier adapter. |
| `HP4 oof_code_drift` | Registry data changes emitted diagnostic code, message, or stage. | Hold; no OOF registry migration. |
| `HP5 semanticir_report_drift` | Projection or adapter changes SemanticIR or CompilationReport goldens. | Hold; no pipeline adapter. |
| `HP6 prop038_leakage` | Profile migration tries to use validator diagnostics as authority. | Hold; route PROP-038 separation review. |

---

## Anti-Confusion And Closed Surfaces

The ownership map asserts it is not:

```text
dispatch plan
CompilerProfile
compiler_profile_id
.igapp
CompilationReport
loader report
CompatibilityReport
PROP-036 authority
PROP-038 authority
runtime readiness
production readiness
```

Still closed:

- no `lib/` edits;
- no root require;
- no compiler pipeline adapter;
- no public API/CLI;
- no loader/report;
- no CompatibilityReport;
- no `.igapp`, manifest, sidecar, or golden mutation;
- no PROP-036 or PROP-038 behavior mutation;
- no runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, or
  deployment behavior.

---

## Verification

Command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h { |k| [k, c(v[k])] }; when Array; v.map { |x| c(x) }; else v; end; end; own=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); projection=JSON.parse(File.read(ARGV[2])); digest=Digest::SHA256.hexdigest(JSON.generate(c(own)))[0,24]; projection_digest=Digest::SHA256.hexdigest(JSON.generate(c(projection)))[0,24]; required=%w[parser classifier typechecker semanticir assembler oof_registry fragment_registry]; boundaries=own.fetch("boundaries"); checks=[]; checks << ["kind", own["kind"] == "compiler_pack_pass_boundary_ownership_map"]; checks << ["digest", summary["ownership_map_digest"] == digest]; checks << ["source_projection", own.dig("source_projection", "digest") == projection_digest && summary["source_projection_digest"] == projection_digest]; checks << ["boundaries", required.sort == boundaries.map{|b| b["boundary"]}.sort]; checks << ["boundary_fields", boundaries.all?{|b| %w[candidate_owner_pack contribution_type current_implementation_anchor proof_golden_anchors ambiguity_risk required_parity_proof_before_migration].all?{|k| b.key?(k)}}]; checks << ["hold_points", %w[HP2 HP3 HP4 HP5 HP6].sort == own["hold_points"].map{|h| h["code"]}.sort]; checks << ["anti_confusion", own["anti_confusion_assertions"].values.all?(false)]; checks << ["closed", own["closed_surface_assertions"].values.all?(false)]; failed=checks.reject{|_, ok| ok}; puts failed.empty? ? "PASS compiler_pack_pass_boundary_ownership_map #{digest}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map_summary.json igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection.json
```

Output:

```text
PASS compiler_pack_pass_boundary_ownership_map 2342d159c833e5d0900cf4f4
```

R139 guard:

```text
PASS internal_profile_migration_projection 6d80b68b3a73231481759c9d
```

---

## Recommendation

```text
hold implementation
more proof next
```

Recommended next proof routes:

```text
oof_fragment_registry_parity_proof
fragment_precedence_parity_proof
semanticir_report_igapp_parity_plan
```

Bridge pressure is not needed until an external carrier is proposed.
Implementation review remains later.

---

## Changed Files

```text
igniter-lang/docs/tracks/compiler-pack-pass-boundary-ownership-map-v0.md
igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json
igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map_summary.json
```

---

## Handoff

[D] Added proof/design ownership map for parser, classifier, TypeChecker,
SemanticIR, assembler, OOF registry, and fragment registry boundaries.

[S] Every boundary now has candidate owner pack, contribution type, current
implementation anchor, proof/golden anchor, ambiguity risk, and required parity
proof before migration.

[T] PASS: ownership map digest, R139 projection digest, required boundaries,
required fields, HP2-HP6, anti-confusion, and closed-surface checks.

[R] Hold implementation. More proof next: OOF parity, fragment precedence
parity, then SemanticIR/report/`.igapp` parity planning.

[Next] Route OOF/Fragment parity proof before any live compiler-pack adapter
implementation review.

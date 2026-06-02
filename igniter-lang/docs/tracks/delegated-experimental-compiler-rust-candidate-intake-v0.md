# Delegated Experimental Compiler — Rust Candidate Intake v0

Card: S3-R235-C2-P1
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-compiler-rust-candidate-intake-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R234-C5-S
- lab-observation: playgrounds/igniter-lab/igniter-compiler

---

## Purpose

Read-only intake of the Rust `igniter-compiler` lab candidate as a
potential alternative experimental compiler candidate. Translates lab
observations into strict mainline evidence language.

This packet is research evidence only. It does not authorize any change
to mainline code, compiler authority, runtime authority, public docs, or
any public claim.

---

## [D] Decision — Recommendation

**Accept as lab candidate evidence with follow-up hardening required.**

The candidate compiles four of five standard `.ig` sources to `.igapp`
artifacts with correct fragment classes. The pipeline source
(`vendor_lead_pipeline`) compiles without error but emits an empty
contracts array — this is a structural gap, not a pipeline grammar gap.
The `--compiler-profile-source` flag is silently ignored. The
`compiled_at` timestamp is hardcoded. No Cargo tests exist.

These gaps must be resolved before any future intake decision or
portability comparison can rely on this candidate's output.

Exact recommendation:

```text
accept as lab candidate evidence
accept with follow-up hardening (see Gap Registry below)
do not hold / do not pause
do not route compiler passport/portability comparison yet
do not route official/reference compiler boundary survey yet
```

Closed by this intake:

```text
alternative experimental compiler candidate: lab-evidence-only
not Official Reference Implementation
not certified alternative implementation
not public compiler support
not stable API
not production-ready
not release evidence
not artifact portability guarantee
```

---

## [S] Summary — Compact

```text
Candidate: playgrounds/igniter-lab/igniter-compiler
Language: Rust, edition 2021
Version: 0.1.0 (Cargo.toml)
Pipeline: Lexer → Parser → Classifier → TypeChecker → Emitter → Assembler
Dependencies: serde, serde_json, blake3, sha2

Verifier result (ruby verify_compiler.rb, 2026-06-02):
  add                          PASS / fragment_class: core / golden match
  decimal_contract             PASS / fragment_class: core / no golden
  vendor_lead_pipeline         PASS (exit 0) / empty contracts (LAB GAP)
  availability_projection      PASS / fragment_class: escape / golden match
  tenant_availability_projection PASS / fragment_class: escape (no golden)

Cargo tests: zero (no #[test] annotations)
compiled_at: hardcoded "2026-05-06T00:00:00Z" (LAB GAP)
--compiler-profile-source: parsed, silently ignored (LAB GAP)
vendor_lead_pipeline contracts: empty array in semantic_ir_program (LAB GAP)
source_path: absolute local machine path embedded in artifact (LAB GAP)
Lab wording risk: verify_compiler.rb prints "100% compliant" (must not be read as authority)
```

---

## [T] Technical Intake

### Compiler Architecture

Six-stage pipeline implemented in Rust:

```text
1. Lexer (src/lexer.rs)
   Tokenizes .ig source into typed tokens.
   Supports: keywords, identifiers, string/int/float/bool/nil/symbol
   literals, operators, arrows, braces, brackets.
   Comments: -- line comments.
   No multi-line string support observed.

2. Parser (src/parser.rs)
   Produces SourceFile (kind: "parsed_program").
   Top-level declarations: module, import, trait, impl, contract_shape,
   contract (with modifiers: pure/observed/effect/privileged/irreversible),
   type, def/function, pipeline, olap_point, assumptions.
   Contract body: input, output, compute, read, snapshot, window, escape,
   stream, fold_stream, invariant, uses assumptions.
   Expressions: if_expr (with else required), binary ops, unary,
   field_access, index_access, call, lambda, array_literal, record_literal,
   symbol, slice_record.
   Grammar versioning: 0.1.0 / decimal-v0 / polymorphic-v0 /
   spark-pipeline-v0 / olap-point-v0 / assumptions-v0
   (inferred from source content, not declared).

3. Classifier (src/classifier.rs)
   Produces ClassifiedProgram (kind: "classified_program").
   Classifies nodes into fragment classes: core, escape, temporal,
   oof, epistemic.
   Cycle detection: DFS, flags OOF-P4.
   Stream window check: OOF-S2.
   Assumption registry build from parsed assumptions blocks.
   OOF rules surfaced: OOF-P0, OOF-P1, OOF-P4, OOF-S2, OOF-S4,
   OOF-CE4, OOF-A1, OOF-M1 (commented out), OOF-IV1, OOF-I4,
   OOF-IV2.
   Note: OOF-M1 (pure contract escape check) is explicitly commented
   out in classifier.rs:674-688 with a note about golden fixture
   matching. This may differ from mainline rule enforcement.

4. TypeChecker (src/typechecker.rs)
   Produces TypedProgram (kind: "typed_program").
   Type inference for compute expressions. Supports: literal, ref,
   binary_op, field_access, if_expr (OOF-IF1/IF2/IF3/IF4),
   call (history_at, bihistory_at, builtin functions), index_access
   (OLAPPoint slicing).
   Decimal arithmetic: scale tracking, scale mismatch detection (OOF-TC5),
   mul scales sum.
   Invariant effects: blocks/warns/uncertain/metric.
   Assumption strength validation: TASSUMP-1.
   Type errors surfaced: OOF-P1, OOF-IF1-4, OOF-TM1/3-6, OOF-TC5,
   OOF-IV3, OOF-I4, OOF-TY0, OOF-S3, OOF-CE4.

5. Emitter (src/emitter.rs)
   Produces EmitResult: semantic_ir (kind: "semantic_ir_program") +
   compilation_report (kind: "compilation_report").
   semantic_ir_program shape follows mainline PROP-019.1 envelope.
   Contract IR: inputs, outputs, nodes, escape_boundaries.
   Nodes emitted: compute, temporal_input_node, temporal_access_node
   (history_at/bihistory_at), stream_input_node, window_decl_node,
   fold_stream_node, invariant_node, assumption_ref_node.
   Map-reduce optimization pass: count/first/fold → map_reduce_aggregate.
   if_expr emitted as if_expr node with condition/then_branch/else_branch.

6. Assembler (src/assembler.rs)
   Writes .igapp directory with canonical file set.
   Artifact hash: SHA256 over canonical JSON of all assembled artifacts.
   Manifest includes: kind, format_version, format, program_id,
   artifact_hash, language_version, grammar_version, schema_version,
   compiled_at (HARDCODED), assembler, semantic_ir_ref,
   compilation_report_ref, source_hash, source_path, contracts,
   contract_refs, fragment_class, fragment_summary, contract_index,
   schema_descriptor, warnings, diagnostics.
   Requirements file: temporal, lifecycle, fragments, capabilities,
   required_tbackend_caps.
   Compatibility metadata: loader_shape hardcoded to
   "runtime_machine_memory_proof.prop0191_direct_v0".
   Contract files: input_ports, output_ports, compute_nodes,
   temporal_nodes, stream_nodes, type_signature, escape_set.
```

### Dependencies (Cargo.toml)

```text
serde      1.0  (derive feature)
serde_json 1.0
blake3     1.5
sha2       0.10

No network dependencies.
No runtime or gem dependencies.
```

### Build Status

```text
Pre-built release binary present at:
  playgrounds/igniter-lab/igniter-compiler/target/release/igniter_compiler

cargo build --release: not re-run (binary present, locally safe assumption).
No network access needed for build given Cargo.lock present.

Cargo tests: zero. No #[test] annotations found in any src/*.rs file.
```

### Verifier Design (verify_compiler.rb)

The verifier:
- Invokes the Rust binary for each of five standard sources.
- Checks exit code and parses JSON result.
- Checks manifest.json presence.
- Compares `fragment_class` against any available golden `.igapp` fixtures
  in `igniter-lang/fixtures/`.

**Critical wording**: Line 98 of verify_compiler.rb reads:

```ruby
puts "[+] ALL TESTS COMPLETED SUCCESSFULLY! Rust compiler is 100% compliant!"
```

This is **lab-agent wording**, not a mainline authority claim.
It must not be cited as compliance certification in any routing or
decision document. It asserts verifier-defined exit-0 behavior only
across a fixed five-source set with limited golden coverage.

---

## Support / Gap Matrix

| Feature | Status | Notes |
| --- | --- | --- |
| `add.ig` parse/classify/typecheck/emit | Supported | Golden match: fragment_class core |
| `decimal_contract.ig` (Decimal type, scale) | Supported | Decimal arithmetic, scale tracking, OOF-TC5 |
| `availability_projection.ig` | Supported | Golden match: fragment_class escape |
| `tenant_availability_projection.ig` | Supported (lab assertion) | No golden fixture for this source |
| `vendor_lead_pipeline.ig` compile (exit 0) | Exit 0 (lab) | See GAP-1 |
| `vendor_lead_pipeline` contracts emitted | **GAP** | Contracts array empty; pipeline bodies not classified |
| `if_expr` parsing | Supported | Parser produces IfExpr AST node |
| `if_expr` typechecking | Supported | OOF-IF1/2/3/4 enforced |
| `if_expr` emission | Supported | condition/then_branch/else_branch shape |
| `assumptions` block parsing | Supported | AssumptionDecl, uses assumptions |
| `assumptions` classification | Supported | OOF-A1, assumption_registry |
| `assumptions` typechecking | Supported | TASSUMP-1 strength validation |
| Temporal: History/BiHistory read | Supported (shape) | temporal_input_node, temporal_access_node |
| Temporal: history_at/bihistory_at | Supported (shape) | OOF-TM1/3-6 enforced |
| Temporal runtime execution | **Not supported** | Noted in compatibility_metadata |
| Stream: stream/fold_stream | Supported (shape) | stream_input_node, fold_stream_node |
| Stream: window declaration | Supported (shape) | window_decl_node |
| Invariants | Supported | invariant_node, OOF-IV1/3/I4, output_effect |
| OLAP points | Supported (shape) | olap_point_decl, OOF-O4/O5 |
| Polymorphic contracts | Supported (parse) | type_params in parser |
| Traits / impls | Supported (parse) | TraitDecl, ImplDecl in parser |
| Pipeline declarations | Parse: Supported | Classification/emission: not completed (GAP-1) |
| `--compiler-profile-source` flag | Parse: Supported | Applied: **GAP-2** |
| `compiled_at` | Present | **GAP-3**: hardcoded "2026-05-06T00:00:00Z" |
| `source_path` in artifacts | Present | **GAP-4**: absolute local machine path |
| `runtime_implementation_id` | Absent | Not in any emitted artifact |
| `compiler_profile_id` | Absent | Not in manifest or compatibility_metadata |
| `spec_version` | Absent | Not in manifest |
| Artifact digest in passport | Absent | No passport emission by this compiler |
| Cargo tests | **Absent** | Zero test annotations |
| OOF-M1 (pure contract escape) | Commented out | Disabled to match golden fixture behavior |

---

## Artifact Compatibility Matrix

| Artifact | Present | Shape vs. Mainline | Issues |
| --- | --- | --- | --- |
| `manifest.json` | ✓ | Matches expected fields | `compiled_at` hardcoded; `source_path` absolute |
| `semantic_ir_program.json` | ✓ | PROP-019.1 envelope preserved | `source_path` absolute; `contracts: []` for vendor_lead |
| `compilation_report.json` | ✓ | Matches expected shape | |
| `requirements.json` | ✓ | requirements shape present | |
| `diagnostics.json` | ✓ | diagnostics wrapper present | |
| `classified_ast.json` | ✓ | classified_program envelope present | |
| `projections.json` | ✓ | Stub: `{ "projections": [] }` | Always empty, no projection emission |
| `compatibility_metadata.json` | ✓ | loader_shape present | loader_shape hardcoded, not derived |
| `contracts/*.json` | ✓ (4 of 5) | contract_id, ports, nodes, type_signature | `vendor_lead_pipeline/contracts/` is empty |

### `compatibility_metadata` loader_shape stance

Hardcoded value:

```text
"runtime_machine_memory_proof.prop0191_direct_v0"
```

This value aligns with the mainline IVM proof loader shape by assertion
in assembler code, not by derivation from compiler profile or runtime
configuration. It is acceptable as an informational field for this lab
candidate but must not be treated as a verified compatibility claim.

### `semantic_ir_program` vs. mainline Ruby compiler output

The Rust lab candidate's `semantic_ir_program.json` follows the
PROP-019.1 envelope shape:

```text
kind: "semantic_ir_program"
format_version, program_id, grammar_version, source_hash, source_path,
module, compilation_report_ref, contracts: [array of contract_ir]
```

This shape is compatible with the RuntimeMachine memory proof loader
for the `add` case (confirmed by accepted Slice 0 proof in R234).

Differences from mainline Ruby compiler output that require attention:

```text
source_path: absolute local path (e.g. /Users/alex/dev/...) vs
             relative or normalized path in mainline artifacts
vendor_lead_pipeline contracts: [] (empty vs populated in mainline)
compiler_profile_id: absent
runtime_implementation_id: absent
```

---

## Gap Registry

### GAP-1: vendor_lead_pipeline emits empty contracts

**Observation**: `vendor_lead_pipeline.ig` parses without error. The
parser produces a PipelineDecl. The classifier iterates `parsed.contracts`
but `vendor_lead_pipeline.ig` declares only a `pipeline` top-level
construct, not a `contract`. The contracts array in the classified
program is empty. The semantic_ir_program has `"contracts": []`.

The verifier exit-0 check only verifies `manifest.json` presence and
checks the status field of the JSON result — it does not verify that
contracts were emitted.

This is a structural gap in the classifier/emitter: pipeline bodies are
not classified into contracts. It is not a parse failure.

**Severity**: Medium. Affects completeness of pipeline-pattern sources
but does not break compile flow for contract-pattern sources.

**Required for portability comparison**: Yes. Pipeline sources must
produce populated contract IR to be meaningful.

### GAP-2: --compiler-profile-source read but not applied

**Observation**: In `main.rs`, the `--compiler-profile-source` flag is
parsed into a `profile_source: Option<Value>` variable. It is then
passed to `run_compiler` as `_profile_source`. The underscore prefix is
a Rust convention for explicitly unused variables. The value is never
applied to any emitted artifact.

The `compiler_profile_id` field is absent from the manifest and
compatibility_metadata. No behavior change occurs when the flag is
provided.

**Severity**: Medium. The flag exists in the interface but has no effect.
Any future compiler passport or profile comparison would require this
to be implemented.

### GAP-3: compiled_at hardcoded

**Observation**: In `assembler.rs:81`:

```rust
manifest.insert("compiled_at".to_string(), Value::String("2026-05-06T00:00:00Z".to_string()));
```

Every artifact produced by this compiler carries the same `compiled_at`
timestamp regardless of actual compilation time.

**Severity**: Low for research purposes. High for portability or artifact
identity comparison. Hardcoded timestamps make artifact deduplification
and audit impossible.

**Wording risk**: A hardcoded `compiled_at` could be misread as evidence
that an artifact was compiled on a specific date.

### GAP-4: source_path embeds absolute local machine path

**Observation**: The `source_path` field in `manifest.json`,
`semantic_ir_program.json`, and other artifacts contains the full
absolute path of the compilation machine:

```text
"/Users/alex/dev/projects/igniter/igniter-lang/source/add.ig"
```

The mainline Ruby compiler emitter normalizes this:
`source_path` is trimmed to remove local prefixes. The Rust compiler
emitter (`emitter.rs:133-135`) applies some trimming
(`trim_start_matches("igniter-lang/")`) for the display path but
the raw `source_path` in the assembler is passed directly from
the command-line argument.

**Severity**: Medium. Embeds lab machine identity into artifacts.
Not portable across machines.

### GAP-5: No Cargo tests

**Observation**: Zero `#[test]` annotations found in any source file.
The verifier (`verify_compiler.rb`) is a Ruby integration script, not a
Rust unit/integration test suite.

**Severity**: Low for lab candidate intake. Would need to be addressed
before any formal alignment comparison.

### GAP-6: OOF-M1 commented out

**Observation**: In `classifier.rs:674-688`, the pure-contract escape
check (OOF-M1) is explicitly disabled with a comment:

```rust
// Escape checks on pure contract (bypassed to match golden escape fragment class)
```

This means the classifier does not emit OOF-M1 for pure contracts that
declare escape capabilities, despite the rule existing in the OOF grammar.

**Severity**: Medium. Behavioral divergence from expected rule
enforcement. The golden fixture match justification is circular: the
golden was produced by the lab compiler itself (or shaped to match it).
The mainline behavior for OOF-M1 must be verified independently.

### GAP-7: No runtime_implementation_id in artifacts

**Observation**: The emitted artifacts contain no `runtime_implementation_id`
field. According to the accepted candidate intake policy (R229-C4-A),
candidate artifacts should declare their runtime implementation identity.

**Severity**: Low for this intake. Required before any portability
comparison or runtime integration.

---

## Wording Risk Register

| Location | Wording | Risk level | Interpretation |
| --- | --- | --- | --- |
| `verify_compiler.rb:98` | "Rust compiler is 100% compliant!" | High | Lab-agent assertion only. Not a compliance certification. Passes verifier-defined exit-0 test on 5 sources. |
| `classifier.rs:129` | `"classifier-pass-executable-proof-v0"` | Low | Proof-local label. Not a mainline proof. |
| `typechecker.rs:111` | `"typed-pass-executable-proof-v0"` | Low | Proof-local label. Not a mainline proof. |
| `assembler.rs:82` | `"igapp-assembler-proof-stage1-v0"` | Low | Proof-local label. |
| `compatibility_metadata.json` | `loader_shape: "runtime_machine_memory_proof.prop0191_direct_v0"` | Medium | Hardcoded assumption. Not verified at build time. |
| `manifest.json` | `compiled_at: "2026-05-06T00:00:00Z"` | Medium | Hardcoded date. Not actual compilation timestamp. |

---

## Closed Surface Scan

The following claims are not created by this intake:

```text
Official Reference Implementation: closed
certified alternative implementation: closed
public compiler support: closed
stable API: closed
production-ready: closed
release evidence: closed
artifact portability guarantee: closed
compiler passport emission (by this lab compiler): closed
runtime_implementation_id authority: closed
compiler_profile_id: closed (not implemented in candidate)
public performance claims: closed
Spark integration: closed
igc run implementation widening: closed
.igbin execution: closed
RuntimeSmoke productization: closed
Reference Runtime support: closed
README/public docs changes: closed
```

---

## [R] Routing — Exact Next

Recommended follow-up routes (not opened by this intake):

```text
Route A (required before portability comparison):
  Harden vendor_lead_pipeline emission (GAP-1) in lab candidate.
  This is a lab-internal change; does not require Main Line authorization.

Route B (required before profile comparison):
  Implement --compiler-profile-source application (GAP-2) in lab candidate.
  Lab-internal change.

Route C (required before artifact identity comparison):
  Fix compiled_at to use real timestamp (GAP-3) in lab candidate.
  Lab-internal change.

Route D (optional, required for portability):
  Add runtime_implementation_id to emitted artifacts (GAP-7).
  Lab-internal change. Requires agreement on runtime_implementation_id value.

Route E (if mainline alignment comparison is later authorized):
  experimental-runtime-artifact-passport-minimum-boundary-v0 survey
  (already tracked in Main Line as companion boundary).

Route F (if compiler portability survey is later authorized):
  Route a formal compiler passport / portability comparison against
  mainline Ruby compiler output shapes.
```

This intake does not open any of Routes A-F. Each requires a separate
authorization decision.

---

## Evidence Class

```text
This intake is lab candidate evidence only.

Classification:
  alternative experimental compiler candidate (lab, pre-v1)
  not Official Reference Implementation
  not certified alternative implementation
  not public compiler support
  not stable API
  not production-ready
  not release evidence
  not artifact portability guarantee
```

---

## Exact Handoff

No further action is authorized by this intake.

The next Main Line decision point related to this candidate would be:

```text
Card: S3-R236-C?-A (future, not yet dispatched)
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor

Goal:
Decide whether lab hardening of the Rust compiler candidate (GAP-1
through GAP-6) may be authorized and tracked as a bounded lab task,
and whether a future compiler portability comparison with the mainline
Ruby compiler output is warranted.

Depends on:
- delegated-experimental-compiler-rust-candidate-intake-v0 (this document)

Do not authorize:
- mainline code changes
- compiler replacement
- Official Reference Implementation status
- certified alternative implementation
- public compiler support
- stable API / production / release claims
```

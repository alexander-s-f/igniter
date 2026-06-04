# Experimental Loops/Recursion Current Surface Facts v0

Card: S3-R245-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-loops-recursion-current-surface-facts-v0
Route: REVIEW
Status: done / facts-only
Date: 2026-06-04

Depends on:
- S3-R245-C1-D

---

## Authority Notice

This is a facts-only surface packet.

It compares current canonical docs/source fixtures with current `igniter-lab`
compiler and VM surfaces. It does not accept canonical authority, certify lab
behavior, authorize implementation, widen `igc run`, or make public/runtime/
stable/reference/production/release/performance/portability claims.

Write scope for this card:

```text
igniter-lang/docs/tracks/experimental-loops-recursion-current-surface-facts-v0.md
```

No lab source, generated playground output, code, runtime/API/CLI/package,
public docs, RuntimeSmoke, CompilerResult, or CompilationReport file was edited.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-loops-recursion-pressure-and-spec-boundary-v0.md`
- `igniter-lang/docs/tracks/stage3-round244-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/source/loops_and_recursion.ig`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/tracks/prop037-*.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`
- `playgrounds/igniter-lab/igniter-compiler/Cargo.toml`
- `playgrounds/igniter-lab/igniter-compiler/src/**`
- `playgrounds/igniter-lab/igniter-vm/Cargo.toml`
- `playgrounds/igniter-lab/igniter-vm/src/**`
- `playgrounds/igniter-lab/igniter-compiler/verify_loops.rb`
- `playgrounds/igniter-lab/igniter-compiler/out/loops_and_recursion*.json`
- `playgrounds/igniter-lab/igniter-compiler/out/loops_and_recursion.igapp/**`

Read-only command run:

```text
ruby -c playgrounds/igniter-lab/igniter-compiler/verify_loops.rb
PASS: Syntax OK
```

No `cargo build`, `cargo run`, VM run, `verify_loops.rb` execution, or generated
output refresh was run because C2-P1 writes are limited to this facts track.

---

## Canonical Fixture Fact

`igniter-lang/source/loops_and_recursion.ig` exists.

Observed syntax:

```text
def factorial(n: Integer, acc: Integer) -> Integer decreases fuel { ... }

contract LoopTester {
  input pending_leads: Array[Integer]
  compute sum = 0

  loop ProcessLeads in pending_leads max_steps: 100 {
    compute sum = sum + item
  }

  loop tick in clock.every(5.seconds) {
    compute tick_time = tick.time
  }

  output sum: Integer
}
```

Classification of this fixture:

| Surface | Fact |
| --- | --- |
| Bounded collection loop | Present: `loop ProcessLeads in pending_leads max_steps: 100`. |
| Service loop / clock source | Present: `loop tick in clock.every(5.seconds)`. |
| Explicit tick binding | Present: `tick.time`. |
| Recursion with fuel marker | Present: `decreases fuel` on `factorial`. |
| `break` | Not present in the canonical fixture. |
| `now()` | Not present in the canonical fixture. |
| `fold_stream` | Not present in this fixture; governed separately by stream/window evidence. |

---

## PROP-037 Canonical Context

PROP-037 is proposal text for external progression and service liveness.

Facts from PROP-037:

```text
service loop is the surface
progression is the semantic substrate
```

PROP-037 separates:

- `Stream[T]` and `fold_stream` as bounded stream/window surfaces;
- local managed loops/recursion as Chapter 13-style local computation classes;
- `Progression` as runtime event/liveness obligations and metadata.

PROP-037 does not authorize parser syntax, TypeChecker changes, SemanticIR
changes, runtime scheduling, durable queues/checkpoints, Ledger/TBackend
binding, ProgressionPack migration, production execution, or a new
`PROGRESSION` fragment class.

---

## Lab Compiler Surface Facts

| Layer | Current fact |
| --- | --- |
| Lexer | Keywords include `loop`, `in`, `max_steps`, `decreases`, `fuel`, `clock`, `every`, `seconds`, `minutes`, `hours`, `break`. |
| Parser AST | `BodyDecl::Loop`, `BodyDecl::ServiceLoop`, `ClockInterval`, and `FunctionDecl.decreases` exist. |
| Parser loop path | Parses `loop Name in collection max_steps: N { ... }`; emits draft `OOF-L1` when `max_steps` is missing. |
| Parser service-loop path | Parses `loop tick in clock.every(N.seconds/minutes/hours) { ... }` into `ServiceLoop`. |
| Parser naming diagnostic | Draft `OOF-L3` exists for unnamed loops, though the current parser path obtains a name token before the empty-name check. |
| Parser `now()` diagnostic | Draft `OOF-L2` exists when `now` appears in a contract body expression path. |
| Parser `break` | `break` is lexed as a keyword, but no confirmed `BodyDecl` or VM compiler source-path use was found for source-level `break`. |
| Parser recursion marker | `decreases fuel` is parsed as `FunctionDecl.decreases = "fuel"`. |
| Classifier loop path | Classifies loops, records `max_steps`, registers `item` and singularized loop/collection variable names as CORE symbols. |
| Classifier service loop path | Classifies service loops as ESCAPE, records interval options, sets `required_capability = "clock_tick"` and `temporal_axis = "valid_time"`. |
| TypeChecker recursion check | Draft `OOF-L4` exists for recursive functions without `decreases fuel`. |
| TypeChecker `now()` checks | Draft `OOF-L2` exists for functions, contract nodes, and loop/service-loop body nodes. |
| TypeChecker loop body | Infers loop body compute nodes using `item` and singularized collection/loop variable types. |
| TypeChecker service loop body | Defines `ClockTick` with `time: Integer`; binds the service-loop name to `ClockTick`. |
| Emitter | Emits `kind: "loop"` nodes and `kind: "service_loop_node"` nodes. |
| Functions/recursion emission | Parser/typechecker support exists, but no current VM user-function recursion execution path was found. |

Observed lab compiler code has moved beyond the older pressure-return doc,
which still describes loop/service-loop/decreases/now as full gaps.

---

## Lab VM Surface Facts

| Surface | Current fact |
| --- | --- |
| Loop opcodes | `OP_LOOP_START`, `OP_LOOP_STEP`, `OP_LOOP_BREAK` exist. |
| Tick opcode | `OP_LOAD_TICK` exists. |
| Comparisons | `OP_EQ`, `OP_GT`, `OP_LT`, `OP_LE`, `OP_GE`, `OP_NE` exist. |
| Arrays/records | `OP_PUSH_ARRAY` and `OP_PUSH_RECORD` exist. |
| Calls | `OP_CALL` exists for VM-supported builtin-style functions. Unknown/unimplemented functions fail. |
| Fold/map/filter | `OP_MAP_REDUCE` and `OP_CALL` paths include array `filter`, `map`, `fold`/`reduce`, `sum`, `count`, `first`, `last`, `zip`, `range`. |
| Loop execution | VM maintains a `LoopFrame` stack with collection, index, and fuel. |
| Loop fuel failure | `OP_LOOP_STEP` fails with `OOF-L-FUEL: loop fuel exhausted`. |
| Tick failure | `OP_LOAD_TICK` fails with `OOF-SL1: service loop clock tick time unresolved` when no time is provided. |
| VM compiler loop path | VM compiler emits loop frame setup, `OP_LOOP_STEP`, loop body register writes, and back-edge jump for `kind: "loop"`. |
| VM compiler service path | VM compiler emits `OP_LOAD_TICK`, stores tick in a register named after the service-loop name, and compiles body nodes. |
| Source-level `break` | Opcode exists, but no confirmed source parser/emitter path for `break` was found. |
| User recursion execution | No current VM path was found that executes source-level recursive user functions such as `factorial`. |

Adjacent VM/runtime/stdlib/TBackend artifacts remain separate pressure surfaces.
They do not create canonical loops/recursion authority.

---

## Generated Output Facts

Existing generated outputs are read as loops/recursion pressure facts only.

There is an important inconsistency:

| Output | Current fact |
| --- | --- |
| `out/loops_and_recursion.compilation_report.json` | `pass_result: "oof"` with three `OOF-P1` diagnostics: unresolved `tick`, unresolved `item`, unresolved `Unknown.time`; stages `parse=ok`, `classify=ok`, `typecheck=oof`, `emit=skipped`. |
| `out/loops_and_recursion.igapp/compilation_report.json` | `pass_result: "ok"` with `parse=ok`, `classify=ok`, `typecheck=ok`, `emit=ok`. |
| `out/loops_and_recursion.igapp/semantic_ir_program.json` | Contains `kind: "loop"` for `ProcessLeads` and `kind: "service_loop_node"` for `tick`. |
| `out/loops_and_recursion.igapp/contracts/loop_tester.json` | Contract artifact includes `kind: "loop"` compute node for `ProcessLeads`; service-loop node is not present in this contract-local artifact. |

Implication:

```text
Generated outputs are stale or produced by different compiler states/paths.
They are useful pressure facts, but they are not conformance, certification, or
canonical behavior evidence.
```

---

## Behavior Classification

| Behavior | Classification |
| --- | --- |
| `fold_stream` parser/classifier/typechecker/VM array fold evidence | Existing bounded stream evidence; not arbitrary loop evidence. |
| `loop Name in coll max_steps: N` parser/classifier/typechecker/emitter code | Bounded loop draft pressure evidence. |
| `loop` VM opcodes/execution path | Bounded loop draft VM evidence. |
| `loop ProcessLeads` generated SemanticIR | Bounded loop generated pressure fact only. |
| `decreases fuel` parsing and OOF-L4 check | Recursion draft compiler pressure evidence. |
| Recursive function execution | Unsupported/unverified in VM; no user-recursion execution path found. |
| `loop tick in clock.every(...)` parser/classifier/typechecker/emitter code | Service-loop draft compiler pressure evidence. |
| `OP_LOAD_TICK` and `OOF-SL1` | Service-loop/tick draft VM pressure evidence. |
| `tick.time` in generated SemanticIR | Draft explicit temporal binding pressure fact. |
| `break` opcode | VM-adjacent draft pressure only; source-level path unverified. |
| `now()` OOF-L2 | Draft compiler diagnostic pressure; not accepted registry authority. |
| OOF-L/OOF-SL names | Draft diagnostic vocabulary only. |

---

## Stale or Ambiguous Areas

- `loops-and-recursion-pressure-package-return.md` says loops, service loops,
  `decreases fuel`, `now()` ban, tick binding, loop naming, and loop opcodes
  are full gaps. Current lab source contradicts that.
- C1-D says the standalone generated report records unresolved `item`/`tick`
  OOFs. That remains true for `out/loops_and_recursion.compilation_report.json`.
- The `.igapp` generated report contradicts the standalone report and records
  `pass_result=ok`.
- The `.igapp` SemanticIR includes service-loop evidence, but
  `contracts/loop_tester.json` omits the service-loop node.
- `break` is lexed and has a VM opcode, but source-level parser/emitter path is
  unverified.
- Recursion with `decreases fuel` is parsed and checked, but recursive execution
  is unsupported/unverified.
- Lab `chrono::Utc::now()` appears in VM pipeline/TBackend-adjacent Rust code,
  but this is not the Igniter source-level `now()` syntax in the fixture.

---

## Explicit Answers

Whether C2-P1 may run commands against lab packages:

```text
Only read-only commands or syntax/status checks are appropriate under this
card. Build/run commands such as cargo build, cargo run, or executing
verify_loops.rb would write target/out artifacts and should require separate
authorization if their generated outputs are needed as evidence.
```

Whether writes are limited to the facts track doc:

```text
Yes.
```

Whether lab source files remain read-only:

```text
Yes.
```

Whether generated outputs may be called loops/recursion pressure facts only:

```text
Yes. Existing generated outputs are pressure facts only, not conformance or
authority.
```

Whether adjacent VM/runtime/stdlib/TBackend artifacts remain separate:

```text
Yes.
```

Whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport may be edited:

```text
No.
```

Whether `igc run` Slice 1 widening remains closed:

```text
Yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/
portability claims remain closed:

```text
Yes.
```

Whether any mainline/canonical/public authority is created:

```text
No.
```

---

## Compact Current-Support / Gap Matrix

| Surface | Current support | Gap / caution |
| --- | --- | --- |
| Canon source fixture | Exists with bounded loop, service loop, and fuel recursion syntax | Not accepted as executable canon by itself |
| `fold_stream` | Existing bounded stream evidence in lab source and VM paths | Must not be used as arbitrary loop proof |
| Bounded loop syntax | Lexer/parser/classifier/typechecker/emitter support exists | Draft pressure only; generated outputs inconsistent |
| Bounded loop VM | Opcode and VM compiler/execution path exists | End-to-end canonical execution not proven by this card |
| Service loop syntax | Parser/classifier/typechecker/emitter support exists | Progression semantics still need spec route |
| Tick binding | `ClockTick.time`, `temporal_binding`, `OP_LOAD_TICK` exist | Tick unresolved failure remains possible; no progression receipt/checkpoint semantics |
| `decreases fuel` | Parser field and recursive-function missing-fuel diagnostic exist | No VM user-recursion execution path found |
| `now()` prohibition | Draft OOF-L2 in parser/typechecker paths | Registry placement remains draft |
| Loop naming | Draft OOF-L3 exists | Current parser path may not exercise empty-name check robustly |
| `break` | Lexer keyword and VM opcode exist | Source-level parser/emitter path unverified |
| OOF diagnostics | OOF-L1/L2/L3/L4 and VM OOF-L-FUEL/OOF-SL1 appear | OOF-L/OOF-SL registry remains unaccepted |
| Generated outputs | Existing `.igapp` output contains loop/service_loop SemanticIR | Standalone report contradicts `.igapp` report |

---

## Exact C4-A Evidence Notes

Recommend C4-A treat this packet as support for the C1-D route:

```text
accept loops/recursion pressure as specification input
keep lab implementation as frontier draft evidence only
open Runtime Specification / PROP-037+ input boundary next
hold implementation authorization
hold igc run widening
```

Evidence notes:

- Lab compiler source now has draft loop/service-loop/recursion diagnostics and
  lowering surfaces, so the old pressure-return "full gap" wording is stale.
- Lab VM source now has loop/tick opcodes and execution paths, but this is still
  VM draft evidence, not canonical runtime authority.
- Recursion is not executable evidence; it is parser/typechecker pressure only.
- Generated outputs conflict and should not be treated as conformance.
- No public/runtime/stable/reference/production/release/performance/
  portability authority is created.

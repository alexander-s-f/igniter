# Track: Source Fixture Parser Acceptance Harness v0

Status: partial
Slice state: partial on 2026-05-05
Owner: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Artifacts:
- `igniter-lang/source/add.ig`
- `igniter-lang/source/availability_projection.ig`
- `igniter-lang/experiments/parser/igniter_lang_parser.rb`

---

## Frame

This slice starts the first source-level devkit path:

```text
.ig source fixture
  -> ParsedProgram JSON
  -> future ClassifiedProgram / TypedProgram / SemanticIR comparison
  -> existing .igapp fixture acceptance target
```

It is not a full compiler and not a final grammar promise. It implements the
PROP-014/PROP-015 kernel far enough to parse the current source fixture pair.

---

## Source Fixtures

```text
igniter-lang/source/add.ig
igniter-lang/source/availability_projection.ig
```

Acceptance targets:

```text
igniter-lang/fixtures/add.igapp/
igniter-lang/fixtures/availability_projection.igapp/
```

---

## Current Parser Proof

The parser currently produces `ParsedProgram` JSON for both source fixtures:

```bash
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
```

Current output includes:

- module path
- imports
- contracts
- inputs/read/compute/window/snapshot/output declarations
- functions/defs
- expressions including calls, lambdas, blocks, field access, index access,
  arrays, records, binary ops
- `parse_errors: []`

---

## What This Proves

[S] The source syntax from PROP-014 and PROP-015 is concrete enough to parse the
two current fixture programs.

[S] `AvailabilityProjection` exercises the important grammar pressure points:

- module/import
- `def`
- typed params/return type
- `fold`, `range`, `filter`, `map`, `first`, `or_else`
- lambdas
- nested blocks
- record literals
- window lifecycle declarations
- ESCAPE read declarations

[S] The parser is already useful as an inspection tool for agents because it
emits JSON-shaped `ParsedProgram`.

---

## What It Does Not Prove Yet

[X] It does not classify CORE/ESCAPE/OOF.

[X] It does not typecheck.

[X] It does not lower to `SemanticIR`.

[X] It does not compare against `.igapp` artifact fixtures.

[X] It does not validate module imports against source files or TypeDecl
availability.

---

## Next Acceptance Step

The next slice should add a checker:

```text
source fixture
  -> ParsedProgram
  -> normalized parsed contract surface
  -> compare to .igapp contract/semantic_ir surface
```

Minimum checks:

- `Add` contract names, inputs, compute node, output match `add.igapp`.
- `AvailabilityProjection` contract name, inputs, reads, window, snapshot, and
  outputs match `availability_projection.igapp`.
- Parser errors are empty.
- The source fixture path and target `.igapp` path are recorded.

This should remain a devkit acceptance harness, not a real compiler claim.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/source-fixture-parser-acceptance-harness-v0.md
Status: partial

[D] Decisions:
- Source fixtures live under igniter-lang/source/.
- Parser experiment lives under igniter-lang/experiments/parser/.
- Parser output is ParsedProgram JSON only.
- .igapp fixtures remain the acceptance target.

[R] Recommendations:
- Add a parsed-surface-to-.igapp comparison checker next.
- Keep classifier/typechecker out until the parser surface is stable.
- Do not introduce more syntax before Add and AvailabilityProjection compare
  cleanly toward existing fixtures.

[S] Signals:
- The grammar kernel is viable enough to parse both fixture programs.
- AvailabilityProjection is a strong enough source fixture to pressure defs,
  lambdas, stdlib calls, window lifecycle, and ESCAPE reads.

[Q] Open Questions:
- Should parser diagnostics be plain JSON or ObsPacket-style failures?
- Should TypeDecls for SparkCRM.Types become a third source fixture now, or
  wait until typechecking?

[Next] Proposed next slice:
- source-fixture-parsed-surface-checker-v0
```

# Ch6: SemanticIR and CompilationReport

Source PROPs: PROP-019, PROP-019.1
Status: ✅ PASS — `--check-golden` PASS; negative `*.semantic_ir.json` absent; CompilationReport artifacts present
Proof: experiments/source_to_semanticir_fixture/ — golden check PASS (canonical + compilation_reports + negative_semanticir_absent)
Assembler: ✅ PASS — experiments/igapp_assembler_proof/ — A1-A6 all ok; assembled_add.igapp → RuntimeMachine.load → evaluate → trusted

---

## 6.1 CompilationReport (PROP-019.1 §Part 2)

**Always written**, regardless of success or failure.

```json
{
  "kind":              "compilation_report",
  "format_version":   "0.1.0",
  "program_id":       "report/<prefix16>",
  "source_path":      "source/add.ig",
  "source_hash":      "sha256:<hex>",
  "pass_result":      "ok | oof | error",
  "semantic_ir_ref":  "<program_id> | null",
  "diagnostics": [
    {
      "rule":     "OOF-P1",
      "severity": "error | warning",
      "message":  "Unresolved symbol: vendor_fetch",
      "node":     "compute:vendor",
      "path":     "contract:VendorLookup/compute:vendor",
      "line":     12
    }
  ]
}
```

**semantic_ir_ref**: non-null only when `pass_result == "ok"`.
Points to the `SemanticIRProgram.program_id`.

**Negative case fixtures**: must have ONLY `*.compilation_report.json` with
`pass_result: "oof"`. No `*.semantic_ir.json` for negative cases.

---

## 6.2 SemanticIRProgram (PROP-019.1 §Part 4)

**Only written when** `pass_result == "ok"`. Contains ONLY clean contracts.

```json
{
  "kind":                   "semantic_ir_program",
  "format_version":         "0.1.0",
  "program_id":             "semanticir/<prefix16>",
  "grammar_version":        "0.1.0",
  "source_hash":            "sha256:<hex>",
  "source_path":            "source/add.ig",
  "module":                 "Lang.Examples.Add",
  "compilation_report_ref": "<report_program_id>",
  "contracts":              [ <ContractIR> ]
}
```

**Removed from v0.1** (PROP-019.1 errata):
- `oof_log` — removed from SemanticIRProgram (top-level AND ContractIR)
- OOF diagnostics live in CompilationReport ONLY

---

## 6.3 ContractIR Shape (PROP-019 §ContractIR)

```json
{
  "kind":           "contract_ir",
  "name":           "Add",
  "fragment_class": "core | escape",
  "module":         "Lang.Examples.Add",
  "nodes": [
    { "kind": "input_node",   "name": "a",
      "type": "Integer" },
    { "kind": "input_node",   "name": "b",
      "type": "Integer" },
    { "kind": "compute_node", "name": "sum",
      "type": "Integer",
      "operator": "stdlib.integer.add",
      "arg_refs": ["a", "b"] },
    { "kind": "output_node",  "name": "result",
      "type": "Integer",
      "source_ref": "sum" }
  ],
  "resolution_order": ["a", "b", "sum", "result"]
}
```

**resolution_order** = topological sort of the dependency DAG.
This IS the Datalog stratification (PROP-001 §formal identity #4).

---

## 6.4 Assembler Acceptance Criteria A1–A6 (PROP-019.1 §Part 7)

The `.igapp/` assembler is accepted when:

```
A1  Reads CompilationReport; rejects (exit != 0) if pass_result != "ok"
A2  Locates SemanticIRProgram via compilation_report_ref;
    verifies kind == "semantic_ir_program"
A3  Iterates contracts; rejects if any fragment_class == "oof" (defensive)
A4  Writes .igapp/ directory:
      .igapp/manifest.json          — program_id, grammar_version, contract names
      .igapp/contracts/<Name>.json  — one ContractIR per contract
      .igapp/compilation_report.json — copied from CompilationReport
A5  RuntimeMachine loads .igapp/ via manifest.json →
    trusted CompatibilityReport (no OOF check needed: A3 guarantees clean)
A6  Negative: given pass_result: "oof" → refuses to write .igapp/; exit != 0
```

**Current status**: assembler experiment not yet implemented.
Blocked on Slice 0 (golden file migration). See current-status.md.

---

## 6.5 Golden File Migration Gate (PROP-019.1 §Part 6)

Existing `source_to_semanticir_fixture` golden files must be migrated:

```
1. Remove oof_log from SemanticIRProgram (top-level + ContractIR)
2. Add compilation_report_ref to SemanticIRProgram
3. Create companion *.compilation_report.json per fixture
4. Negative fixtures: remove *.semantic_ir.json;
   keep only *.compilation_report.json with pass_result: "oof"
5. Resolve stdlib.numeric.add → stdlib.integer.add (or float/decimal)
   in all positive-case SemanticIR golden files

Gate: source_to_semanticir_fixture.rb PASS on migrated files → Assembler unlocked
```

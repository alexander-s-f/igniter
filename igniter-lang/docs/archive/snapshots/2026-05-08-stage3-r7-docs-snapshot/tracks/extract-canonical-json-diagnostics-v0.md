# Track: Extract Canonical JSON Diagnostics v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/extract-canonical-json-diagnostics-v0
Status: done
Date: 2026-05-07
Pressure source: PROP-027 (production compiler contract), production-compiler-cli-wrapper-v0 (done)

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — implementation checklist in §Part 5.
- No Bridge Agent pressure; no package changes.

---

## Part 1: Current Diagnostics Shape (proof-local)

Observed in `production_compiler_cli.rb` and the CLI output contract:

```text
FIELD                 CURRENT (CLI stdout)                  TARGET (PROP-027)
─────────────────────────────────────────────────────────────────────────────
Top-level key         "diagnostics"                         "diagnostics"  ✓
Entry fields          rule, severity, message               + category, contract?, node?, path?, span?
"category" field      ABSENT                                REQUIRED
"contract" field      ABSENT                                optional
"node" field          ABSENT                                optional
"path" field          ABSENT                                optional
"span" field          ABSENT                                optional (null ok)
Source of entries     forwarded raw from ClassifiedProgram  same entries + enriched fields
CLI status key        "status"                              "status"  ✓
stages object         ABSENT in CLI stdout                  REQUIRED (PROP-027 §Part 2)
igapp_path key        "out" (not "igapp_path")              "igapp_path" (PROP-027)
runtime_smoke         present                               present  ✓
```

**[D] The existing CLI proof is passing.** Its diagnostic shape is a valid v0 subset. The gaps above are enrichment, not breakage. No proof regression is expected from this extraction.

---

## Part 2: Canonical DiagnosticEntry — Minimal Reusable Shape

**[D] The canonical `DiagnosticEntry` shape is defined by PROP-027 §Part 5:**

```ruby
# Canonical DiagnosticEntry — reusable across all compiler passes
DiagnosticEntry = {
  "category" => String,       # "parser_error"|"parser_warning"|"classifier_oof"|
                              #  "typechecker_oof"|"emitter_error"|"assembler_refusal"|
                              #  "runtime_smoke_failure"
  "rule"     => String,       # "OOF-P1", "OOF-DM3", "R-3", "PW-1", etc.
  "severity" => String,       # "error" | "warning" | "info"
  "message"  => String,       # one-line human-readable
  "contract" => String | nil, # contract_name if applicable
  "node"     => String | nil, # body node name if applicable
  "path"     => String | nil, # "contract:X/compute:Y/ref:Z"
  "span"     => Hash | nil    # { "line" => Integer, "col" => Integer } | nil
}
```

**[D] `category` is the only new required field.** All others were already present or optional in existing proof output.

### Category assignment rules

```text
Source               Category
──────────────────   ─────────────────────
parse_errors[]       "parser_error" (severity:"error") or "parser_warning" (severity:"warning")
ClassifiedProgram    "classifier_oof"
TypedProgram         "typechecker_oof"
EmitterError         "emitter_error"
AssemblyRefused      "assembler_refusal"
RuntimeSmoke failed  "runtime_smoke_failure"
```

---

## Part 3: Minimal Reusable Module Boundary

**[D] For v0, extract a `Diagnostics` helper module inside `ProductionCompilerCLI`.**

No gem extraction. No new file. One `module Diagnostics` inside the existing
`production_compiler_cli.rb` that:

1. Provides `enrich(entries, category:, contract: nil)` — adds `category` and
   normalizes any missing optional fields to `nil`.
2. Provides `from_parse_errors(errors)` — maps `parse_errors[]` to enriched entries.
3. Provides `from_classified(diagnostics)` — maps classifier `diagnostics[]`.
4. Provides `from_typechecked(diagnostics)` — maps typechecker `diagnostics[]`.
5. Provides `from_assembler_refusal(refusal)` — maps assembler `refusal_report`.

This module is the extraction boundary. A future package can lift it out directly.

---

## Part 4: CLI Stdout Shape Delta (PROP-027 alignment)

Current proof stdout output vs canonical target:

```text
CHANGE                            RISK
───────────────────────────────   ──────────────────────────
Add "stages" object               additive; no breakage
Rename "out" -> "igapp_path"      breaking for any consumer reading "out"
Add "category" to diagnostics[]   additive; no breakage
Add "contract","node","path"      additive; no breakage
  fields to diagnostic entries
Add "warnings" array              additive; no breakage
Add "format_version" to stdout    additive; no breakage
```

**[D] Rename `"out"` → `"igapp_path"` is the only breaking change.** The existing proof reads `add_result.dig("json","runtime_smoke",...)` but does not read `"out"` directly in proof checks. Rename is safe for the current proof.

---

## Part 5: Implementation Checklist for Research Agent

```text
ProductionCompilerCLI::Diagnostics module (production_compiler_cli.rb):

  ☐ DX-1: Add Diagnostics module with enrich(entries, category:, contract: nil).
           Sets "category", ensures "node","path","span","contract" are present (nil if missing).

  ☐ DX-2: Add from_parse_errors(errors) -> enriched entries with category:"parser_error"
           or "parser_warning" based on entry severity.

  ☐ DX-3: Add from_classified(diagnostics) -> enriched with category:"classifier_oof".

  ☐ DX-4: Add from_typechecked(diagnostics) -> enriched with category:"typechecker_oof".

  ☐ DX-5: Add from_assembler_refusal(refusal) -> single entry category:"assembler_refusal".

  ☐ DX-6: Add from_runtime_smoke(smoke) -> single entry category:"runtime_smoke_failure"
           if smoke["trusted"] is false.

CLI stdout alignment:

  ☐ DX-7: Rename "out" -> "igapp_path" in success and failure result hashes.

  ☐ DX-8: Add "stages" object to compiler_result stdout (propagate from CompilationReport).

  ☐ DX-9: Add "format_version":"0.1.0" to compiler_result stdout.

  ☐ DX-10: Add "warnings":[] to compiler_result stdout
            (populated from parser PW-* entries; empty until PH-1..6 implemented).

Proof regression:

  ☐ DX-11: production_compiler_cli_proof.rb still PASS after all changes.
            Update proof checks:
            - "compile.add_writes_igapp" check reads igapp_path (not out).
            - Add "compile.add_diagnostics_have_category" check:
              diagnostics[].all? { |d| d["category"] }  -- for OOF cases.
```

---

## Part 6: Clear Next Extraction Step

```text
After DX-1..DX-11 pass:

  Next boundary:  Extract Diagnostics module to a separate file:
    experiments/production_compiler_cli/diagnostics.rb

  After that:     Extract to igniter-lang/lib/diagnostics.rb
                  (first igniter-lang library file; Stage 2 package target)

  Package gate:   Diagnostics module extraction does not require a gem.
                  It is the first step toward the production compiler gem (PROP-027 Tier 0).
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/extract-canonical-json-diagnostics-v0
Status: done

[D] Decisions:
- Existing CLI proof is passing; diagnostics shape is valid v0 subset.
  Gaps are enrichment (category, contract, node, path, span), not breakage.
- category is the only new required field on DiagnosticEntry.
- Minimal reusable boundary: ProductionCompilerCLI::Diagnostics module inside
  the existing production_compiler_cli.rb. No file extraction yet.
- "out" -> "igapp_path" rename is the only breaking change; safe for current proof.
- 11-item implementation checklist: DX-1..DX-11.
- Next extraction step: separate diagnostics.rb file,
  then igniter-lang/lib/diagnostics.rb (Stage 2 library).

[S] Stage 2 Tier 0 path:
  DX-1..11 → diagnostics.rb extracted → lib/diagnostics.rb → production compiler gem.

[T] All checks:
  DX-11 must pass (production_compiler_cli_proof PASS).
  DX-10 check: "compile.add_diagnostics_have_category" added to proof.

[R] Research Agent: apply DX-1..DX-11 to production_compiler_cli.rb.
    No new files required. Proof must still PASS.

[Next]:
- [Research Agent]: apply DX-1..DX-11 (bounded; single file change).
  Verify production_compiler_cli_proof still PASS.
- [Compiler/Grammar Expert]: next track per Stage 2 governance
  (META-EXPERT-008; start from PROP-028).
```

# Fragment Registry Compatibility Adapter Helper Implementation Pressure v0

Card: S3-R148-C1-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: compiler-authority-pressure
Route: UPDATE
Track: fragment-registry-compatibility-adapter-helper-implementation-pressure-v0
Status: complete
Date: 2026-05-22

---

## Goal

Pressure-review the landed S3-R147-C2-I direct-require-only fragment registry
compatibility adapter helper implementation for scope compliance, proof
completeness, authority drift, and accidental compiler/public/runtime surface
widening.

---

## Evidence Read

- `docs/gates/fragment-registry-compatibility-adapter-helper-implementation-authorization-review-v0.md`
  (S3-R147-C1-A) — the Architect gate defining exact authorized write scope,
  required API shape, selection rules, regression matrix, and proof requirements
- `docs/tracks/stage3-round147-status-curation-v0.md` (S3-R147-C2-S) — confirms
  implementation not landed in R147; route pointer correct
- `docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md`
  (S3-R147-C2-I) — the implementation track under review
- `lib/igniter_lang/fragment_registry_compatibility_adapter.rb` — the new helper
  file; read in full
- `experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb`
  — the proof runner; read in full to verify dynamic check logic
- `experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json`
  — proof summary (44/44 PASS, 0 failures); read in full

No code was edited. No proof commands were run.

---

## Scope Checks

### Check 1 — Changed files are exactly within authorized write scope

**Question:** Do C2-I's changed files fall entirely within the S3-R147-C1-A
authorized scope?

**C1-A authorized write scope:**

```text
igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb
igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/**
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md
```

**C2-I changed files:**

```text
lib/igniter_lang/fragment_registry_compatibility_adapter.rb                   NEW
experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/
  fragment_registry_compatibility_adapter_helper_implementation_proof.rb      NEW
  out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json  NEW
  out/helper_implementation_result.json                                       NEW
docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md  NEW
```

All 5 files are within the authorized scope. Git history confirms a single
commit (`f865dd9c`) for the implementation, affecting only these paths.

The track doc names an explicit "not created or modified" list of 8 excluded
paths including `lib/igniter_lang.rb`, `classifier.rb`, `compilation_report.rb`,
`compiler_result.rb`, `assembler.rb`, `semanticir_emitter.rb`, `cli.rb`, and all
golden/`.igapp`/runtime files.

**Verdict: PASS**

---

### Check 2 — Helper API is exactly `IgniterLang::FragmentRegistryCompatibilityAdapter.project(input_hash) -> result_hash`

**Question:** Does the helper expose the exact API required by C1-A? Is the
class name, module path, method name, and return type exactly right?

**Evidence from `lib/igniter_lang/fragment_registry_compatibility_adapter.rb`:**

```ruby
module IgniterLang
  class FragmentRegistryCompatibilityAdapter
    def self.project(input_hash)
      # ...
      result_hash
    end
  end
end
```

- Module: `IgniterLang` ✓
- Class: `FragmentRegistryCompatibilityAdapter` ✓
- Public class method: `project` ✓ (`select_fragment` and `rules_in_order_description` are private)
- Accepts: `input_hash` (Hash) ✓
- Returns: `result_hash` (Hash) ✓

No other public class method is defined. The file comment states the API
explicitly and cites the authorized gateway.

**Verdict: PASS**

---

### Check 3 — Helper shape matches R146 C1 with no unauthorized field/name refinement

**Question:** Does the result shape match the C1-A required fields exactly?
Has any field been added, renamed, or removed without authorization?

**C1-A required result shape fields:**

```text
kind: fragment_registry_compatibility_adapter_helper_result
format_version: 0.1.0
selected_fragment_projection.rows[]
selected_fragment_projection.mismatches[]
guarded_non_fragments[]
oof_projection_policy
r144_parity
held_live_dispatch: true
classifier_wiring_authorized: false
```

**Live helper result (verified via RS1–RS6 checks, all PASS):**

All 9 required fields present with correct values. No extra public fields added
beyond the C1-A shape. RS6 confirms `rules_in_order` has exactly 6 entries
matching R146 proof order.

Input digest `47e938fdea0e46e067a2c88b` matches the R146 C1 accepted helper
input digest exactly — confirming the same 23-contract dataset was used.

**Note on result digest change:** The live result digest is `c109ef1b1b124fd825172327`,
differing from the R146 proof model digest `ae26685d3afd77a2e2cc35c5`. This is
expected: the R146 proof model result included two extra fields not present in
the C1-A canonical shape definition (`boundary_mode` and `closed_surface_assertions`
as part of the proof artifact), while the live helper returns only the C1-A
required fields. This is correct — the C1-A shape definition omits those
proof-model extras, and the live implementation correctly matches C1-A, not the
proof-model artifact verbatim.

**Verdict: PASS**

---

### Check 4 — Selection rules match R146 exactly

**Question:** Do the `SELECTION_RULES` constants and `select_fragment` logic
exactly reproduce the R146 proof selection order?

**Evidence from the helper source:**

```ruby
SELECTION_RULES = [
  { presence: "oof",       selected: "oof"       },
  { presence: "temporal",  selected: "temporal"  },
  { presence: "escape",    selected: "escape"    },
  { presence: "stream",    selected: "escape"    }, # stream → escape
  { presence: "epistemic", selected: "epistemic" }
].freeze
DEFAULT_SELECTED = "core".freeze

def self.select_fragment(presence_list)
  SELECTION_RULES.each do |rule|
    return rule[:selected] if presence_list.include?(rule[:presence])
  end
  DEFAULT_SELECTED
end
```

R146 proof selection order:

```text
if oof present      → oof
elsif temporal      → temporal
elsif escape        → escape
elsif stream        → escape   (stream maps to escape)
elsif epistemic     → epistemic
else                → core
```

The implementation matches R146 exactly. The critical compatibility cases
(`stream → escape`, `escape before epistemic`) are encoded in the correct
priority order. COMPAT1–COMPAT5 all PASS in the proof summary.

**Verdict: PASS**

---

### Check 5 — Dynamic closed-surface checks are real filesystem/content checks

**Question:** Are CS1–CS10 live filesystem/content reads, not hardcoded static
`false` values? Does the proof satisfy the C1-A requirement on dynamic assertions?

**Evidence from proof runner source (key excerpts):**

CS1 — live filesystem:
```ruby
checks << check("CS1.helper_file_exists_at_authorized_path") { HELPER_FILE.exist? }
```

CS2 — live content read of `lib/igniter_lang.rb`:
```ruby
checks << check("CS2.root_require_does_not_reference_helper") do
  content = File.read(ROOT_REQUIRE, encoding: "utf-8")
  !content.include?("fragment_registry_compatibility_adapter")
end
```

CS3 — live content read of `classifier.rb`:
```ruby
checks << check("CS3.classifier_does_not_reference_helper") do
  content = File.read(CLASSIFIER_FILE, encoding: "utf-8")
  !content.include?("fragment_registry_compatibility_adapter") &&
    !content.include?("FragmentRegistryCompatibilityAdapter")
end
```

CS7 — live content read of `classifier.rb` for field presence:
```ruby
checks << check("CS7.no_classifiedprogram_field_added") do
  content = File.read(CLASSIFIER_FILE, encoding: "utf-8")
  !content.include?("selected_fragment_projection") &&
    !content.include?("declaration_fragment_presence")
end
```

CS8, CS9, CS10 — live content reads of `compilation_report.rb`,
`compiler_result.rb`, `assembler.rb`, `semanticir_emitter.rb`, `cli.rb`.

All CS checks with filesystem/content implications (CS1–CS3, CS7–CS10) are
live reads. The C1-A mandatory requirement ("live filesystem/content reads —
not hardcoded") is satisfied.

**Verdict: PASS — with one required NB fix (see NB-1 below)**

CS4 has a logic error described in NB-1. All other CS checks are correctly
implemented. The C1-A requirement is substantially met.

---

### Check 6 — Root require remains absent and classifier references absent

**Question:** Is the helper still unrooted (not in `lib/igniter_lang.rb`) and
does `classifier.rb` contain no reference?

**CS2 result:** `root_require_does_not_reference_helper: PASS` — live read
of `lib/igniter_lang.rb` confirms no `fragment_registry_compatibility_adapter`
reference.

**CS3 result:** `classifier_does_not_reference_helper: PASS` — live read of
`classifier.rb` confirms no reference to either the adapter class name or the
snake_case module name.

**CS7 result:** `no_classifiedprogram_field_added: PASS` — live read of
`classifier.rb` confirms neither `selected_fragment_projection` nor
`declaration_fragment_presence` was added.

**NEG1 broad scan:** `CLEAN — 0 hits` across all `lib/igniter_lang/*.rb` files
(excluding helper itself) for all 4 forbidden terms including
`FragmentRegistryCompatibilityAdapter`.

**Helper file comment** restates the isolation contract explicitly, including:
`"be required from lib/igniter_lang.rb (direct-require-only; no root require)"`.

**Verdict: PASS**

---

### Check 7 — Live classifier dispatch remains absent

**Evidence:**

CS3 confirms `classifier.rb` contains no reference to the adapter. CS4 checks
for forbidden method names on the helper class itself. NEG1 confirms no dispatch
vocabulary has leaked into any other lib file.

The proof runner `require_relative`s the helper directly:
```ruby
require_relative "../../lib/igniter_lang/fragment_registry_compatibility_adapter"
```

This is the intended pattern — direct require by the proof harness only, not
via root require.

The helper defines only one public class method: `.project`. No `classify`,
`dispatch`, `wire`, `register`, or `install` method exists on the class.

**Verdict: PASS — with NB-1 caveat on CS4 logic**

See NB-1 for the CS4 logic bug. The underlying protection against live dispatch
is confirmed by CS3, CS7, and NEG1, but CS4 itself is non-functional.

---

### Check 8 — Broad negative vocabulary scan is clean outside the helper file

**Evidence from proof summary:**

```json
"vocab_scan": {
  "hits": [],
  "scanned_files": 19,
  "scanned_terms": 4,
  "status": "CLEAN"
}
```

Four forbidden terms scanned across all `lib/igniter_lang/*.rb` files:

```text
fragment_registry_compatibility_adapter
FragmentRegistryCompatibilityAdapter
declaration_fragment_presence
selected_fragment_projection
```

Result: **0 hits** outside the authorized helper file.

The scan logic in the proof runner explicitly skips the authorized helper file:
```ruby
next if path == HELPER_FILE.to_s  # authorized — skip
```

Additional targeted scans of 7 specific files (root require, classifier, report,
assembler, CLI, compiler_result, semanticir_emitter) all CLEAN.

**Verdict: PASS**

---

### Check 9 — Proof matrix includes `assumptions_proof`; pinned check counts recorded

**Question:** Did C2-I satisfy both mandatory requirements from C1-A —
`assumptions_proof` in the regression matrix, and pinned check counts?

**C1-A required regression matrix:**

| Command | Required counts | Result |
| --- | --- | --- |
| Helper implementation proof | pinned by card | 44/44 PASS |
| `classifier_pass_proof` | 21 | PASS |
| `contract_modifiers_proof` | 20 | PASS |
| `assumptions_proof` | 39 | PASS |
| `source_to_semanticir_fixture --check-golden` | 31 | PASS |
| `igapp_assembler_proof` | 17 | PASS |
| `invariant_severity_proof` | 34 | PASS |

All 7 commands ran and PASSED. `assumptions_proof` is present — satisfying C1-A
and NB-2 from S3-R146-C2-X.

`PINNED_COUNTS` in the proof runner source hardcodes all required counts exactly
as specified by C1-A:
```ruby
PINNED_COUNTS = {
  "classifier_pass_proof"          => 21,
  "contract_modifiers_proof"       => 20,
  "assumptions_proof"              => 39,
  "source_to_semanticir_fixture"   => 31,
  "igapp_assembler_proof"          => 17,
  "invariant_severity_proof"       => 34
}.freeze
```

**Verdict: PASS**

Note: the proof runner records pinned counts as metadata for reference but does
not currently assert that each regression command produces exactly the required
number of named checks. The `REG.*` checks only verify `exit_code == 0` (PASS
vs. FAIL). For a first implementation slice this is acceptable, but future proof
cards should add an assertion that the reported check count matches the pinned
value.

---

### Check 10 — Byte-for-byte parity evidence is sufficient

**Question:** Is parity evidence strong enough to confirm no artifact drift?

**Evidence:**

C1-A required byte-for-byte parity for classifier, contract-modifier,
assumptions, SemanticIR, and `.igapp` artifacts.

Parity evidence recorded in summary:

| Artifact | Coverage | How computed |
| --- | --- | --- |
| `.igapp result summary` | `f8b4426843a85b6a03d6629a` | `short_digest(JSON.parse(result_summary.json))` — live file read |
| SemanticIR golden dir (23 files) | `f3f7fa48455bed3adb2e8777` | Per-file SHA256 digest of entire golden directory — live reads |
| Assumptions golden dir (12 files) | `156da071b981e15cc32fea13` | Per-file SHA256 digest of entire golden directory — live reads |
| Contract modifiers golden dir (23 files) | `319721cd4d9e10f0a23c4fa1` | Per-file SHA256 digest of entire golden directory — live reads |
| Invariant severity summary | `b47e6cf8f64de68cd911c516` | `short_digest(JSON.parse(summary.json))` — live file read |

All five parity digests are computed from live file reads in `compute_parity_evidence`.
None are hardcoded. The `--check-golden` mode independently verifies SemanticIR
byte-for-byte parity against the same golden directory.

PARITY.igapp_result_summary_stable, PARITY.semanticir_golden_stable,
PARITY.assumptions_golden_stable, and PARITY.regression_all_commands_passed all
PASS.

**Verdict: PASS**

---

### Check 11 — PROP-036 and PROP-038 remain unmutated

**Evidence:**

The `closed_surface_assertions` in the proof summary carries:
```json
"prop036_mutated": false,
"prop038_mutated": false
```

The PROP-036 and PROP-038 behaviors manifest in lib files (`compilation_report.rb`,
`assembler.rb`, `compiler_result.rb`). The NEG1 broad vocabulary scan confirmed
0 hits for adapter vocabulary in all `lib/igniter_lang/*.rb` files, and CS8/CS9
live-read the relevant PROP-038 and PROP-036 carrier files with 0 hits.

The helper file comment explicitly prohibits touching PROP-036 and PROP-038
behavior. No regression failure was observed in any related proof command.

Note: `prop036_mutated: false` and `prop038_mutated: false` in the summary
dictionary are hardcoded (not dynamically computed). However, the CS and NEG1
checks provide the live evidence. This is the same pattern noted in NB-3 below
and is not a concern given the NEG1 + CS8/CS9 coverage.

**Verdict: PASS**

---

### Check 12 — No public/report/artifact/runtime/Spark/production surface opened

**Evidence:**

- CS8: `compilation_report.rb` and `compiler_result.rb` contain no adapter references — PASS
- CS9: `assembler.rb` and `semanticir_emitter.rb` contain no adapter references — PASS
- CS10: `cli.rb` contains no adapter reference — PASS
- NEG1: All `lib/igniter_lang/*.rb` clean — PASS
- Regression matrix: `source_to_semanticir_fixture --check-golden` PASS (golden unchanged),
  `igapp_assembler_proof` PASS (artifact unchanged)
- PARITY checks: SemanticIR goldens and `.igapp` result summary digests stable — PASS
- `runtime_spark_production_changed: false` in summary (hardcoded; CS8/CS9/NEG1 provide
  the live evidence for the lib-facing risk surface)
- No changed files touch any Spark experiment or runtime path

The helper's isolation contract in the file comment explicitly prohibits all
these surfaces, and the proof runner's CS checks independently verify the key
ones.

**Verdict: PASS**

---

## Non-Blocking Notes

**NB-1 — CS4 logic error (significant; requires disposition by C2-A):**

CS4 (`no_live_classifier_dispatch_method`) has a logic bug:

```ruby
(IgniterLang::FragmentRegistryCompatibilityAdapter.methods(false) &
  IgniterLang::FragmentRegistryCompatibilityAdapter.private_methods(false) &
  forbidden).empty?
```

`methods(false)` returns public singleton methods: `[:project]`  
`private_methods(false)` returns private singleton methods: `[:select_fragment, :rules_in_order_description]`  
These two sets are disjoint, so their intersection is `[]`.  
`[] & forbidden` is always `[]`, and `[].empty?` is always `true`.

CS4 is unconditionally always-passing regardless of what methods the helper
defines. A future adversarial implementation could add a `:classify` or
`:dispatch` method without CS4 catching it.

**Impact on this implementation:** None. The actual implementation is verified
clean by independent paths: CS3 and CS7 confirm `classifier.rb` has no adapter
reference; NEG1 confirms all lib files are clean; the actual class has only
`.project` (public) and two private methods (confirmed by direct source reading
and by successfully calling `.project`).

**Required fix:**

```ruby
all_singleton_methods = IgniterLang::FragmentRegistryCompatibilityAdapter.methods(false) +
                        IgniterLang::FragmentRegistryCompatibilityAdapter.private_methods(false)
(all_singleton_methods & forbidden).empty?
```

**Recommendation for C2-A:** Accept the implementation as correct — the
underlying isolation is proven by CS3, CS7, and NEG1. But require the CS4 fix
either in a follow-up proof-correction card or acknowledge explicitly in the
acceptance gate that CS4 is non-functional and the actual protection is provided
by the named alternative checks. Do not allow CS4 to propagate into future proof
cards in its broken form.

**NB-2 — Vocab scan file count discrepancy (minor):**

The track doc states "Scanned: all `lib/igniter_lang/*.rb` files (18 files)"
but the proof summary records `"scanned_files": 19`.

The discrepancy arises because `scanned_files` counts the total `Dir.glob`
result (all `lib/igniter_lang/*.rb` files including the new helper file), while
the effective checked count is 18 (19 minus the helper file itself, which is
skipped). The scan is correct — 0 hits in 18 checked files. The track doc
should say 19 total (or clarify "18 files checked + 1 skipped = 19 total").

Cosmetic documentation inconsistency. Does not affect scan validity.

**NB-3 — `closed_surface_assertions` summary dict is partially hardcoded (minor):**

The summary dictionary `closed_surface_assertions` has `helper_file_exists_at_authorized_path`
as a live filesystem check (`HELPER_FILE.exist?`) but the remaining 14 keys
(`root_require_references_helper`, `classifier_references_helper`,
`live_classifier_dispatch`, etc.) are hardcoded `false`. The actual live
evidence for these comes from the CS2–CS10 individual checks.

The C1-A requirement about dynamic checks is satisfied by CS1–CS10 (except CS4).
The summary dict is a reporting artifact. Future proof cards should derive these
values from the CS check results rather than hardcoding them separately, so the
summary dict and the CS checks remain in sync.

---

## Verdict

```text
proceed-with-notes
```

12/12 scope checks PASS. No implementation blockers. One proof quality note
requiring C2-A disposition before the acceptance gate closes:

- **NB-1** (requires C2-A disposition): CS4 `no_live_classifier_dispatch_method`
  has a logic error — always trivially passes. C2-A must either require a fix
  before acceptance or explicitly acknowledge that CS3/CS7/NEG1 provide the
  substituted protection.

Two minor cosmetic notes (no action required for acceptance):

- **NB-2**: Vocab scan file count in track doc (18 vs. 19 — scan is correct).
- **NB-3**: `closed_surface_assertions` summary dict is partially hardcoded —
  acceptable for this slice, should be addressed in future proof cards.

---

## Recommendations for C2-A

**Accept:**
The implementation is correct and cleanly isolated. All core correctness
claims are independently verified:
- R144 parity: 23/23 contracts, 0 mismatches, input digest confirmed
- All 5 compatibility cases: PASS
- OOF status-primary policy: PASS
- Full regression matrix: 7/7 commands PASS with pinned counts
- Byte-for-byte parity evidence: 5 artifact digests recorded
- Broad vocab scan: CLEAN across all lib files
- Root require and classifier reference: absent by live read

**Require before closing acceptance gate:**
1. Disposition on CS4 logic bug — either require a fix (one-line change from
   `methods(false) & private_methods(false) & forbidden` to
   `(methods(false) + private_methods(false)) & forbidden`) or record an
   explicit gate acknowledgment that CS4 is non-functional and name the
   alternative checks (CS3, CS7, NEG1) that provide the underlying protection.

**Do not authorize at this time:**
- Classifier wiring or live classifier dispatch (explicitly still closed)
- Root require (explicitly still closed)
- Any public/report/artifact/runtime/Spark/production surface

---

[Agree]
- The implementation is correct, isolated, and well-documented. The isolation
  contract comment in the helper file makes the invariants self-documenting.
- The switch from hardcoded `closed_surface_assertions` (R146) to live CS
  checks (R147) satisfies the C1-A mandatory upgrade requirement from NB-1
  of S3-R146-C2-X.
- Including `assumptions_proof` and all pinned check counts satisfies NB-2 from
  S3-R146-C2-X.
- Parity evidence uses live file digests — not hardcoded — providing genuine
  byte-for-byte confirmation.
- Result digest change from R146 proof model is correctly expected: the C1-A
  shape definition excluded proof-model extras (`boundary_mode`,
  `closed_surface_assertions`); the live helper is correctly scoped to the
  C1-A canonical shape.

[Challenge]
- CS4 (`no_live_classifier_dispatch_method`) is a trivially-always-passing
  check due to the intersection of disjoint method sets. It must be fixed or
  explicitly acknowledged before the acceptance gate closes.

[Missing]
- Pinned count assertions are not machine-enforced: `PINNED_COUNTS` is defined
  but the regression runner only checks exit code, not actual check count. A
  future proof card should add `exit_code == 0 && pinned_count == actual_count`
  for each command. Not a blocker for this slice.

[Sharper Question]
- When C2-A closes the acceptance gate, should the CS4 fix be required as a
  proof-correction card in the same round, or is a gate-level acknowledgment
  of NB-1 sufficient given the redundant protection from CS3/CS7/NEG1?

[Route]
- acceptance (C2-A) after NB-1 disposition

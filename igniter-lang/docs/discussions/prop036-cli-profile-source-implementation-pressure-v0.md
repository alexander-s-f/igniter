# Discussion: PROP-036 CLI Profile Source Implementation Pressure v0

Card: S3-R50-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-profile-source-implementation-pressure-v0

Depends on: S3-R50-C2-I delivered

Question:

Did C2-I follow the exact C1-A boundary? Are B3/B4/B5/B6 criteria genuinely
satisfied by the implementation evidence? Is the preflight refusal shape correct
per R46/R47? Is the B6 scanner self-test meaningful and does it prove exactly
what R47-C3-A Amendment 2 requires? Are any loader-status tokens present? Is any
profile discovery, defaulting, or finalization introduced? Are there runtime
authority, Gate 3, Ledger, or production implications? Does the implementation
satisfy B9 as defined in R45-C3-A?

Context:
- C1-A (Architect Supervisor): Authorizes bounded CLI transport:
  `--compiler-profile-source PATH.json`; `IgniterLang::CLI` only; 9 exact proof
  cases required; B6 adversarial scanner self-test required per R47-C3-A
  Amendment 2; explicit non-authorization list
- C2-I (Implementation Agent): Updated `cli.rb` only; proof 12/12 PASS;
  `forbidden_exact_token_hits=0`; scanner self-test both flags true;
  `legacy_no_flag_manifest_omits_compiler_profile_id=true`;
  `valid_profile_source_manifest_emits_compiler_profile_id=true`;
  `invalid_profile_source_no_igapp=true`; non-authorization section all false
- R46-C4-A: Governing B3/B6 closure criteria — hybrid refusal model, 7 required
  preflight cases, scan surface table, exact forbidden-token list
- R47-C3-A Amendment 2: B6 requires adversarial scanner self-test — injected bare
  forbidden token must fail; qualified `compiler_profile_source.*` must pass as
  source-validation vocabulary
- R45-C3-A B9 definition: "Run runtime-pressure review after the proposed
  implementation boundary and before any implementation card is accepted as
  complete"

---

## Independent Verification

### CLI source review

`cli.rb` was read directly. Key observations:

```ruby
def run(argv)
  ...
  compiler_profile_source = load_profile_source(profile_source_path) if profile_source_path
  orchestration = IgniterLang.compile(
    source_path: source_path,
    out_path: out_path,
    compiler_profile_source: compiler_profile_source
  )
  ...
rescue ArgumentError => e
  warn e.message
  false
end
```

When `profile_source_path` is nil (no flag), `load_profile_source` is never
called and `compiler_profile_source` is `nil`. No default, discovery, or sidecar
path is triggered. The no-flag path is structurally identical to the pre-C2-I
path. ✓

`load_profile_source` does only:
1. `path.exist?` check → "compiler profile source path not found"
2. `path.file?` check → "compiler profile source path must be a regular file"
3. `JSON.parse(path.read)` → "compiler profile source file must contain valid JSON"
4. `parsed.is_a?(Hash)` check → "compiler profile source JSON must be an object"
5. `Errno::EACCES` rescue → "compiler profile source path is not readable"
6. `JSON::ParserError` rescue → handled by point 3

No profile validation, no field inspection, no discovery. The parsed Hash is
returned and passed unchanged. ✓

`ArgumentError` is rescued by `run` and written to stderr via `warn`. The
caller sees a single stable line. No backtrace. ✓

### Files changed

Only `cli.rb` was modified. `bin/igc`, `IgniterLang.compile`,
`CompilerOrchestrator`, and `Assembler` were not touched. New files are under
the named proof directory only. No changes to `bin/igniter-lang` or the
production compiler experiment CLI. ✓

### Proof summary fields

All C1-A required summary fields are present in the proof summary JSON:
`kind`, `format_version`, `track`, `status`, `cases`, `commands`, `exitstatus`,
`stdout_shape`, `stderr_text`, `artifact_paths`, `scan_surface`,
`forbidden_exact_token_hits`, `scanner_self_test_bare_forbidden_token_fails`,
`scanner_self_test_qualified_source_validation_allowed`,
`allowed_qualified_source_validation_terms`,
`legacy_no_flag_manifest_omits_compiler_profile_id`,
`valid_profile_source_manifest_emits_compiler_profile_id`,
`invalid_profile_source_no_igapp`. ✓

The `non_authorizations` section in the summary explicitly records all forbidden
surfaces as `false` (not implemented). This is an additional integrity signal
not required by C1-A but consistent with the scope. ✓

---

## Scope Checks

### Check 1 — C1-A scope followed exactly

**Result: PASS.**

C1-A authorized: (a) `cli.rb` implementation; (b) proof directory output; (c)
track doc. C2-I touched exactly these three surfaces and nothing else.

C1-A explicitly prohibited changing `IgniterLang.compile`, `CompilerOrchestrator`,
`Assembler`, `bin/igc`, and `bin/igniter-lang`. None were changed.

C1-A prohibited adding profile source discovery, defaulting, inference, lookup,
sidecar loading, environment-variable loading, config loading, normalization, or
finalization. The CLI code contains no such paths. When the flag is absent,
`compiler_profile_source:` is `nil` — identical to today.

### Check 2 — B3 preflight refusal shape is correct

**Result: PASS.**

Seven refusal cases are required by R46-C4-A. All seven are present and verified
in the proof summary:

| Case | Exit | Stdout | Stderr line | No artifacts |
|---|---|---|---|---|
| `--compiler-profile-source` without path | 1 | empty | "--compiler-profile-source requires PATH.json" | ✓ |
| path not found | 1 | empty | "compiler profile source path not found" | ✓ |
| path not regular file | 1 | empty | "compiler profile source path must be a regular file" | ✓ |
| unreadable path | 1 | empty | "compiler profile source path is not readable" | ✓ |
| invalid JSON | 1 | empty | "compiler profile source file must contain valid JSON" | ✓ |
| JSON top-level not object | 1 | empty | "compiler profile source JSON must be an object" | ✓ |
| unsupported extra argument | 1 | empty | "unsupported argument for igc compile" | ✓ |

All seven cases: exit 1, stdout empty, one stable stderr line, no
`OUT.compilation_report.json`, no `OUT.igapp`, no profile-source report JSON.
No raw file contents echoed. No parser backtrace. No bare forbidden tokens. ✓

The stderr messages use `"compiler profile source ..."` prefix throughout — this
is a newly introduced stable vocabulary. None of the messages use any word from
the forbidden token list. ✓

### Check 3 — B4 legacy no-flag behavior unchanged

**Result: PASS.**

The proof summary records:
- `legacy_no_flag_manifest_omits_compiler_profile_id: true`
- `B4.legacy_no_flag`: exit 0; stdout `compiler_result_json`; stderr empty;
  `.igapp` emitted with full artifact set; manifest.json present

The CLI code path for no-flag is structurally nil-pass-through. `compiler_profile_source` is undefined (not `nil`-defaulted) when the flag is absent — the keyword argument is simply absent from the `compile` call, preserving the existing method signature behavior. ✓

### Check 4 — B5 semantic refusals use existing assembler path

**Result: PASS.**

Three B5 cases (`wrong_kind`, `unfinalized_status`, `runtime_authority_requested`)
all follow the assembler refusal path exactly as required:

| Case | Exit | Stdout | Stderr | Report | igapp |
|---|---|---|---|---|---|
| wrong_kind | 1 | compiler_result_json | empty | exists | absent |
| unfinalized_status | 1 | compiler_result_json | empty | exists | absent |
| runtime_authority_requested | 1 | compiler_result_json | empty | exists | absent |

Refusal reasons in diagnostic messages:
- `compiler_profile_source.wrong_kind: "compiler_profile_unified"` ✓
- `compiler_profile_source.unfinalized: status="draft"` ✓
- `compiler_profile_source.runtime_authority_forbidden` ✓

All three use qualified `compiler_profile_source.*` vocabulary, not bare
forbidden tokens. `invalid_profile_source_no_igapp: true` confirmed. ✓

The C1-A requirement "may use the existing compiler/orchestrator/assembler refusal
path only if C1-A permits it" is satisfied — C1-A explicitly listed this path
as permitted for B5.

### Check 5 — B6 scanner self-test is meaningful

**Result: PASS, with one structural note.**

The proof summary records:
```text
scanner_self_test_bare_forbidden_token_fails: true
scanner_self_test_qualified_source_validation_allowed: true
allowed_qualified_source_validation_terms:
  - compiler_profile_source.wrong_kind
  - compiler_profile_source.unfinalized
  - compiler_profile_source.runtime_authority_forbidden
```

The independent command 4 scan covers 22 JSON files in the proof output
directory (excluding proof inputs) and returns `exact_forbidden_hits=0`. ✓

R47-C3-A Amendment 2 required two self-test proofs:
1. Injected bare forbidden token fails the scanner → `scanner_self_test_bare_forbidden_token_fails: true` ✓
2. Qualified `compiler_profile_source.*` strings pass only as source-validation
   vocabulary → `scanner_self_test_qualified_source_validation_allowed: true` +
   `allowed_qualified_source_validation_terms` recorded ✓

Amendment 2 also required `scanner_self_test_bare_forbidden_token_fails: true`
recorded in proof summary — present. ✓

The scan surface covers all R46-C4-A required surfaces:
- stdout/stderr for all 12 cases ✓
- `OUT.igapp/**/*.json` for no-flag and valid-source cases (9 + 9 = 18 igapp files) ✓
- `OUT.compilation_report.json` for all three B5 cases ✓
- proof summary JSON ✓

### Check 6 — No loader-status vocabulary leaks

**Result: PASS.**

All B3 stderr lines were read directly from the proof summary JSON and contain
no forbidden tokens from the R46 list:
`absent_legacy`, `present_verified`, `mismatch`, `malformed`,
`missing_required`, `runtime_ready`, `evaluation_ready`, `gate3_authorized`,
`runtime_authority`, `production_ready`.

The words "valid" (appears in "contains valid JSON" and "compiler profile source
JSON must be an object") and "not found" are generic I/O error vocabulary with
no forbidden-list overlap.

The B5 qualified term `compiler_profile_source.runtime_authority_forbidden`
contains `runtime_authority` as a substring. The scanner correctly does not
match it because the scan uses exact JSON key/value matching
(`forbidden.include?(value)`), not substring search. The self-test confirms
the scanner correctly allows this qualified term. ✓

### Check 7 — No profile discovery/defaulting/finalization

**Result: PASS.**

The proof summary `non_authorizations.profile_source_discovery: false`,
`non_authorizations.profile_source_defaulting: false`,
`non_authorizations.profile_source_finalization_in_cli: false` all confirm
these were not implemented. Verified against the source code: no env variable
check, no config file read, no cwd discovery, no sidecar lookup. ✓

### Check 8 — No runtime authority / Gate 3 / Ledger / production implications

**Result: PASS.**

The proof summary `non_authorizations` confirms:
- `dispatch_migration: false` ✓
- `runtime_machine_binding: false` ✓
- `ledger_tbackend: false` ✓
- `production_behavior: false` ✓

The implementation adds a single flag-driven transport path. It cannot widen
into runtime authority through the existing assembler path — B5 cases prove the
assembler correctly refuses runtime-authority-granted=true objects. ✓

### Check 9 — No hidden golden migration or hidden artifacts beyond scope

**Result: PASS.**

The proof directory contains only:
- proof-local `.igapp/` outputs (under `out/`)
- proof-local `OUT.compilation_report.json` outputs (under `out/`)
- proof summary JSON (under `out/`)
- proof input fixtures (under `out/inputs/`)

No changes to existing `.igapp` golden fixtures outside the proof directory.
`bin/igc` and `bin/igniter-lang` are unchanged. ✓

---

[Agree]

1. **The transport implementation is exactly scoped.** The CLI adds one flag,
   loads one file, parses it as JSON, requires the top-level value to be an
   object, and passes the parsed object unchanged. No profile intelligence was
   added. The `load_profile_source` method reads and validates the file at the
   OS/JSON level only — it inspects no profile fields.

2. **The B3 hybrid refusal model is correctly implemented.** Preflight refusals
   happen before `IgniterLang.compile` is called and produce only stderr + non-zero
   exit. Post-preflight semantic refusals go through the assembler path and produce
   the existing `compiler_result` + `compilation_report.json` surface. The
   boundary between the two stages is clean in the source code.

3. **B6 adversarial scanner self-test satisfies R47-C3-A Amendment 2.** Both
   required proof cases are recorded: bare forbidden token failure, and qualified
   `compiler_profile_source.*` allowance. The independent scan independently
   confirms 0 exact forbidden hits across 22 proof-local JSON files.

4. **B4 legacy behavior is structurally unchanged.** When the flag is absent,
   the `if profile_source_path` guard prevents `load_profile_source` from
   being called at all. No default value is injected. The no-flag path is
   identical to the pre-implementation path at the call site.

5. **B5 refusals use the existing assembler path correctly.** Objects that
   pass CLI preflight but fail assembler validation follow the
   compiler_result/compilation_report path. The CLI adds no new refusal
   vocabulary for semantic failures — all reasons are qualified
   `compiler_profile_source.*` terms owned by the assembler.

6. **The non_authorizations section in the proof summary is a strong integrity
   signal.** Recording what was explicitly NOT done as machine-readable boolean
   fields makes future gate review mechanical rather than interpretive.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before B3/B4/B5/B6 formal closure review.

---

[NB-1 — Non-blocking: flag-as-path edge case]

The argument `--compiler-profile-source --some-flag` (where `--some-flag` is
passed as the path argument) is silently accepted as a path token and falls
through to path-not-found rather than triggering "--compiler-profile-source
requires PATH.json". This is standard Unix option-parser behavior and not a
security or authority issue. The B3 preflight refusal cases required by R46 do
not include this edge case. Documented here for completeness only — this is not
a blocker on any of B3–B6.

---

[B9 Assessment]

B9 is defined in R45-C3-A as:

> "Run runtime-pressure review after the proposed implementation boundary and
> before any implementation card is accepted as complete."

This card, S3-R50-C3-X, is exactly that review. All nine scope checks pass.
The implementation is within the C1-A boundary. B3/B4/B5/B6 criteria are
genuinely satisfied. No forbidden leaks, no discovery, no production
implications.

**B9 is satisfied by this pressure review.**

Formal closure of B9 should be bundled with B3/B4/B5/B6 in the next Architect
gate rather than left as a separate pending item — its closure criterion is met
when this review completes.

---

[Sharper Question]

With B3/B4/B5/B6/B9 evidence complete and pressure satisfied, the next gate
question is: does the Architect formally close all five blockers in one decision,
or does the gate decision close B3/B4/B5/B6 and simultaneously satisfy B9 by
citing this pressure review? The latter is the cleaner shape — one gate closes
the complete remaining blocker package and the review record is the cited
B9 evidence.

---

[Route]

**Verdict: proceed.**

No blockers. All nine scope checks pass. NB-1 is documentation only with no
authority or safety implications.

**B3/B4/B5/B6:** Evidence complete. Criteria satisfied. Ready for formal closure
review by a single Architect gate decision.

**B9:** Satisfied by this pressure review (S3-R50-C3-X). No separate gate
required. Formal closure should be bundled with B3/B4/B5/B6 in the next Architect
decision by citing this review as the B9 evidence record.

**For R51:**
Recommended shape: single Architect gate formally closing B3/B4/B5/B6/B9 by
citing the C2-I proof summary + this C3-X pressure verdict. After that gate, the
full PROP-036 CLI blocker package (B1–B9) is closed and the explicit
implementation authorization decision is the only remaining gate before CLI code
may be considered production-ready.

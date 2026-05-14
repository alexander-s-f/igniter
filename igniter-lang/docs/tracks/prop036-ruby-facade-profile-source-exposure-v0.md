# Track: PROP-036 Ruby Facade Profile Source Exposure v0

Card: S3-R44-C3-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-ruby-facade-profile-source-exposure-v0
Route: UPDATE
Status: done
Date: 2026-05-14

Depends on:
- S3-R44-C2-A approved-bounded-ruby-facade-exposure

---

## Goal

Expose caller-supplied finalized `compiler_profile_source` through the public
Ruby facade `IgniterLang.compile`, preserving nil legacy behavior.

Authorized surface: Ruby facade transport only.

No CLI flags, path-based profile source loading, inline JSON parsing, profile
finalization, discovery, defaulting, loader/report surface, CompatibilityReport
profile section, golden migration, RuntimeMachine binding, dispatch migration,
Ledger/TBackend, cache, or production behavior were implemented.

---

## Implementation

Updated:

- `igniter-lang/lib/igniter_lang.rb`

Change:

```ruby
def compile(
  source_path:,
  out_path:,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil,
  orchestrator: CompilerOrchestrator.new
)
```

The facade forwards `compiler_profile_source:` unchanged to
`CompilerOrchestrator#compile`. Nil remains the default and preserves the
legacy optional manifest behavior.

The facade does not finalize, discover, infer, load, normalize from a path, or
default a compiler profile source.

---

## Proof

Added:

- `igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb`
- `igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/out/prop036_ruby_facade_profile_source_exposure_summary.json`

Proof cases:

| Case | Result |
|------|--------|
| `F1.facade_signature_has_optional_keyword` | PASS |
| `F2.nil_source_preserves_legacy_manifest` | PASS |
| `F3.valid_source_emits_profile_id` | PASS |
| `F4.invalid_source_refuses_before_artifact_output` | PASS |
| `F5.invalid_source_uses_existing_refusal_path` | PASS |
| `F6.facade_forwards_source_object_unchanged` | PASS |
| `F7.existing_cli_compile_remains_legacy` | PASS |

Key observed outputs:

- Nil facade compile: `status=ok`, manifest has no `compiler_profile_id`.
- Valid source facade compile: `status=ok`, manifest has top-level
  `compiler_profile_id`.
- Invalid source facade compile: `status=assembler_refused`,
  `refused_facade.igapp` is not written, refusal report is written, and the
  refusal text contains the existing `compiler_profile_source.unfinalized`
  reason path.
- CLI compile path still succeeds without any profile field and without a new
  CLI input surface.
- Exact forbidden-token scan over newly written JSON/refusal artifacts: 0 hits.

---

## Command Matrix

All commands were run from repository root: `/Users/alex/dev/projects/igniter`.

| # | Command | Result | Notes |
|---|---------|--------|-------|
| 1 | `ruby -c igniter-lang/lib/igniter_lang.rb` | PASS | Syntax OK |
| 2 | `ruby -c igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` | PASS | Syntax OK |
| 3 | `ruby igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` | PASS | 7/7 checks PASS; exact forbidden-token hits: 0 |
| 4 | `ruby -rjson -e 'forbidden = %w[absent_legacy present_verified mismatch malformed missing_required runtime_ready evaluation_ready gate3_authorized runtime_authority production_ready]; files = Dir.glob(File.join(ARGV.fetch(0), "**", "*.json")).sort; hits = []; walk = lambda do |value, path, file|; case value; when Hash; value.each do |k, v|; hits << [file, "key", (path + [k]).join("."), k] if forbidden.include?(k); walk.call(v, path + [k], file); end; when Array; value.each_with_index { |v, i| walk.call(v, path + [i], file) }; else; hits << [file, "value", path.join("."), value] if forbidden.include?(value); end; end; files.each { |file| walk.call(JSON.parse(File.read(file)), [], file) }; puts "json_files=#{files.length}"; puts "exact_forbidden_hits=#{hits.length}"; hits.each { |hit| puts hit.join(":") }; exit(hits.empty? ? 0 : 1)' igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/out` | PASS | `json_files=29`; `exact_forbidden_hits=0` |

---

## Non-Authorization Check

The proof summary records these surfaces as false:

- `cli_profile_flags`
- `path_source_loading`
- `inline_json_parsing`
- `profile_finalization_in_facade`
- `profile_discovery_or_defaulting`
- `compatibility_report_profile_section`
- `runtime_machine_binding`
- `dispatch_migration`
- `ledger_tbackend`
- `production_behavior`

No edits were made to:

- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/bin/igniter-lang`

---

## Remaining Blockers

- CLI exposure remains blocked pending a separate authority decision covering
  exact input shape, parse/refusal wording, nil/no-flag behavior, and a fresh
  negative vocabulary scan.
- Path-based source loading remains blocked.
- Inline JSON parsing remains blocked.
- Profile finalization/discovery/defaulting in public caller surfaces remains
  blocked.
- Loader/report, CompatibilityReport, golden migration, `.ilk`, receipts,
  signing, dispatch migration, RuntimeMachine binding, Ledger/TBackend, cache,
  and production behavior remain blocked.

---

## Handoff

```text
Card: S3-R44-C3-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-ruby-facade-profile-source-exposure-v0
Status: done

[D] Decisions
- Added transport-only optional compiler_profile_source: nil keyword to
  IgniterLang.compile.
- Preserved nil legacy behavior; the facade does not create or alter profile
  sources.

[S] Shipped / Signals
- Updated igniter-lang/lib/igniter_lang.rb.
- Added proof script and summary JSON under the authorized experiment dir.
- Added this track document.

[T] Tests / Proofs
- 4/4 command matrix PASS.
- Ruby facade proof: 7/7 checks PASS.
- Exact forbidden-token JSON scan: 0 hits across 29 JSON artifacts.

[R] Risks / Recommendations
- Public Ruby API now transports caller-finalized compiler_profile_source.
- CLI/profile-file exposure remains intentionally blocked.

[Q] Open questions
- None for this bounded Ruby facade surface.
```

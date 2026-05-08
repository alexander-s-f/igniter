# Gem Release Automation v0

Card: S3-R3-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gem-release-automation-v0
Status: done
Date: 2026-05-08

## Goal

Add a package-local release gate for `igniter_lang` that prepares local release
evidence and artifacts but cannot publish without explicit Architect approval.

This slice adds automation only. It does not change
`IgniterLang::VERSION`, does not publish to RubyGems, and does not add any
`gem push` path.

## Release Command Shape

From the repository root:

```text
igniter-lang/bin/release-gate
```

From the package root:

```text
bin/release-gate
```

Optional artifact directory:

```text
igniter-lang/bin/release-gate --out /private/tmp/igniter_lang_release_gate
```

The default output directory is:

```text
/private/tmp/igniter_lang_release_gate
```

The release gate always writes its own proof summary:

```text
igniter-lang/experiments/release_gate/release_gate.json
```

## Gate Order

The gate runs:

```text
ruby -c igniter_lang.gemspec
ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

If every check passes, it builds:

```text
/private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem
/private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem.sha256
```

If any check fails, artifact build is skipped.

[D] Nested proof commands may refresh their own JSON summaries while running.
The release gate preserves and restores those canonical proof summaries, so the
release automation leaves `experiments/release_gate/release_gate.json` as the
single generated release-gate record for a failed or successful attempt.

## Publish Boundary

[D] The gate has no publish command and never invokes `gem push`.

[D] RubyGems publication remains a separate human action requiring explicit
Architect approval and RubyGems owner MFA.

[D] Version changes remain out of scope. This slice keeps:

```text
IgniterLang::VERSION = "0.1.0.pre.stage2"
```

## Release Checklist

Before publish approval:

```text
release_gate.status == PASS
gemspec_syntax == PASS
gem_native_package_boundary_specs == PASS
stage1_close_candidate == PASS
stage2_close_candidate == PASS
artifact.status == PASS
artifact.gem_path exists
artifact.checksum_path exists
artifact.sha256 recorded
publish.status == not_attempted
version policy explicitly accepted
Architect approval recorded
human RubyGems owner ready to publish with MFA
```

After publish approval, the human publish command remains outside this script:

```text
gem push /private/tmp/igniter_lang_release_gate/igniter_lang-<VERSION>.gem
```

That command is forbidden without explicit Architect approval.

## Current Proof Run

Command run:

```text
igniter-lang/bin/release-gate
```

Result:

```text
gemspec_syntax: PASS
gem_native_package_boundary_specs: PASS
stage1_close_candidate: PASS
stage2_close_candidate: PASS
gem_build_release_artifact: PASS
PASS release_gate
artifact: /private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem
checksum: /private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem.sha256
publish: not_attempted
summary: igniter-lang/experiments/release_gate/release_gate.json
```

The gate built the local artifact and checksum, then stopped before publish.
This is the desired release-prep behavior.

Stage 1 result:

```text
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
```

Stage 2 result:

```text
package_facade: PASS
invariant_runtime_observations: PASS
olap_point: PASS
stream_fold: PASS
history_bihistory_temporal_access: PASS
ledger_tbackend_descriptor: PASS
stage1_regression: PASS
```

Generated artifact path:

```text
/private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem
```

Generated checksum path:

```text
/private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem.sha256
```

Generated SHA256:

```text
9ded66145c36ce08dfd9b2717f12c44896d575f39e116ca59aa99ae11ca30860
```

## Changed Files

```text
igniter-lang/bin/release-gate
igniter-lang/experiments/release_gate/release_gate.json
igniter-lang/docs/tracks/gem-release-automation-v0.md
```

## Handoff

```text
Card: S3-R3-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gem-release-automation-v0
Status: done

[D] Decisions
- Added `bin/release-gate` as the package-local release gate.
- The gate runs syntax, gem-native package boundary, Stage 1, and Stage 2 checks before artifact build.
- The gate builds `.gem` plus `.sha256` only after all checks pass.
- The gate has no RubyGems publish path and records `publish.status = not_attempted`.
- Version stays `0.1.0.pre.stage2`.

[S] Shipped / Signals
- `ruby -c igniter-lang/bin/release-gate` passes.
- `igniter-lang/bin/release-gate` executed and stopped before publish.
- Package-local checks passed: gemspec syntax, gem-native package boundary, Stage 1, and Stage 2.
- Local `.gem` and `.sha256` artifacts were generated under `/private/tmp/igniter_lang_release_gate`.
- Release summary written to `igniter-lang/experiments/release_gate/release_gate.json`.

[T] Tests / Proofs
- `gemspec_syntax`: PASS.
- `gem_native_package_boundary_specs`: PASS.
- `stage1_close_candidate`: PASS.
- `stage2_close_candidate`: PASS.
- `gem_build_release_artifact`: PASS.

[R] Risks / Residuals
- `/private/tmp` is not durable storage; preserve or rebuild artifacts from the exact release commit before publish.
- Publish remains manual and approval-gated.

[Next]
- Retain the `.gem`, `.sha256`, and release gate JSON with Architect approval before any publish.
- Add CI wiring for `bin/release-gate` in a separate automation track if desired.
```

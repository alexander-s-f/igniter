# Experimental Use Current Surface And Gap Facts v0

Card: S3-R222-C2-P1
Skill: IDD Agent Protocol
Agent: Research Agent #1
Role: research-agent
Track: experimental-use-current-surface-and-gap-facts-v0
Route: UPDATE
Depends on: S3-R221-C5-S
Status: complete
Date: 2026-05-31

## IDD Classification

Mode: standard, compact facts packet.

Contract:

- collect current experimental-use surfaces and blockers;
- identify what a developer can do today;
- identify where the smallest credible productization slice likely lives;
- do not decide the route;
- do not make stable API, production, runtime-ready, public-demo, or Spark
  claims.

Authority rule:

```text
alpha availability != stable API promise
proof/runtime evidence != product runtime support
examples/workflows != production readiness
```

## Inputs Read

- `stage3-round221-status-curation-v0.md`
- `docs/current-status.md`
- `README.md`
- `docs/README.md`
- `docs/ruby-api.md`
- `RELEASE_NOTES.md`
- `igniter_lang.gemspec`
- `lib/igniter_lang.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `lib/igniter_lang/compiler_result.rb`
- `bin/igc`
- `source/*.ig`
- `experiments/` index scan

## Current Fixed Point

R221 closed the counterfactual audit report/API boundary round:

- `CompilerResult` remains closed to Option B/C fields;
- `CompilationReport` remains closed to projected values/failures;
- RuntimeSmoke output remains proof-context only;
- all report/API field and sidecar design routes remain held;
- Option D carrier remains held;
- counterfactual audit expansion pauses until an explicit new Portfolio card.

Experimental-use facts therefore should not reopen counterfactual report/API,
RuntimeSmoke carrier, Option D, runtime/evaluator, Spark, release, or production
authority.

## Current User-Visible Entrypoints

| Entrypoint | Current capability | Experiment blocker | Risk |
| --- | --- | --- | --- |
| RubyGems package | `igniter_lang 0.1.0.alpha.1` is published as alpha prerelease. | Package gives availability, not a guided experiment. | Overclaiming stable/production/public-demo readiness. |
| Executable | `bin/igc` / installed `igc` runs CLI. | CLI is compile-only. | Users may expect run/evaluate/dry-run support. |
| CLI no-profile compile | `igc compile SOURCE --out OUT.igapp`. | Needs a known-good source file and output policy. | Without curated examples, users may pick parser-only fixtures. |
| CLI profile-source compile | `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`. | Requires already-finalized `compiler_profile_id_source` JSON. | Users may expect discovery/defaulting/finalization. |
| Ruby facade | `IgniterLang.compile(source_path:, out_path:, ...)`. | Requires caller to supply paths and optional callbacks; no tutorial wrapper. | Looks more stable than current alpha/pre-v1 posture. |
| RuntimeSmoke callback | Optional proof-backed callback accepted by `IgniterLang.compile`. | Proof-context only; relies on proof RuntimeMachine experiment. | Easy to mistake for product runtime support. |
| Source fixtures | `source/add.ig` is a clear bounded CORE success seed. | Other source files mix parser-only, future, temporal, pipeline, or polymorphic pressure. | Users may infer all grammar/runtime support. |
| Experiments | Many proof harnesses under `experiments/`. | Not curated as a developer quickstart. | Proof evidence can be confused with public product API. |
| Examples directory | No `igniter-lang/examples/` directory present. | No obvious first runnable example. | Highest immediate friction for experimental use. |

## CLI Capability And Gaps

Current supported CLI shapes:

```text
igc compile SOURCE --out OUT.igapp
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

CLI facts:

- command must be `compile`;
- `--out OUT.igapp` is required;
- `--compiler-profile-source PATH.json` is optional;
- profile-source preflight requires path exists, file is regular/readable,
  JSON is valid, and top-level JSON is an object;
- CLI passes the parsed profile-source object unchanged to `IgniterLang.compile`;
- CLI prints `CompilerResult.public_result(...)` as JSON;
- CLI exits `0` only when orchestration status is `ok`.

CLI gaps for experimental use:

- no `igc run`;
- no evaluate command;
- no counterfactual/dry-run command;
- no profile-source generator/finalizer;
- no profile discovery/defaulting;
- no bundled example command transcript;
- no all-grammar support claim;
- no runtime-ready claim.

## Ruby API Capability And Gaps

Current Ruby facade:

```ruby
IgniterLang.compile(
  source_path: source_path,
  out_path: out_path,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil
)
```

Facts:

- facade delegates to `CompilerOrchestrator#compile`;
- `compiler_profile_source:` is transport-only;
- no profile-source discovery/defaulting/finalization occurs in the facade;
- `runtime_smoke:` is optional;
- invalid non-nil profile sources are refused later by the existing compiler /
  assembler validation path.

Experiment blockers:

- no one-file Ruby quickstart wrapper;
- no stable sample source/output convention;
- no clear boundary for when to use `runtime_smoke:`;
- no stable API promise before v1.

## Runtime / RuntimeSmoke Capability And Gaps

RuntimeSmoke facts:

- `RuntimeSmoke` directly requires the proof RuntimeMachine compiled-program
  experiment;
- `RuntimeSmoke.run` loads/evaluates/checkpoints/resumes a proof `.igapp`;
- success output includes load/evaluate/resume status, outputs, and `trusted`;
- blocked output includes `load_status: blocked`, an error, and `trusted: false`;
- `RuntimeSmoke.callback` can be supplied to `IgniterLang.compile`.

Gaps:

- RuntimeSmoke remains proof-context only;
- no product runtime command exists;
- no production RuntimeMachine binding is exposed for experimental users;
- no Ledger/TBackend/BiHistory/runtime readiness claim exists;
- no counterfactual runtime support exists;
- RuntimeSmoke must not be used as a carrier for Option B/C counterfactual
  evidence.

## Examples / Quickstart Posture

Current facts:

- `igniter-lang/examples/` is absent.
- `igniter-lang/source/add.ig` is the clearest bounded compiler success seed.
- `source/polymorphic_add.ig` is explicitly parser-only for polymorphism.
- `source/availability_projection.ig` includes ESCAPE/window/TBackend-like
  pressure and user-defined functions.
- `source/vendor_lead_pipeline.ig` is a parser acceptance fixture for pipeline
  syntax.
- Several `source/*.ig` files have companion parsed-program expected JSON files.
- `experiments/` contains many proof harnesses, but the directory is not a
  developer-facing quickstart.

Highest-friction gap:

```text
There is no curated examples/quickstart path that says:
  use this source,
  run this command,
  expect this output,
  here is what is not claimed.
```

## Package / Installation Posture

Current package facts:

- gem name: `igniter_lang`;
- version: `0.1.0.alpha.1`;
- executable: `igc`;
- required Ruby: `>= 3.1.0`;
- gem files include `lib/**/*.rb`, `bin/igc`, `README.md`, and
  `RELEASE_NOTES.md`;
- examples are not packaged because no `examples/` directory exists and the
  gemspec does not include examples;
- release notes record RubyGems publication, isolated install, require, and
  executable checks as PASS.

Package blockers for credible experiments:

- no packaged examples;
- no bundled quickstart source/output fixture;
- no `igc run`;
- no runtime support claim;
- no stable API claim;
- no profile finalizer/discovery/defaulting.

## Docs Wording Around Alpha / Stability

Current docs already say:

- `igniter_lang 0.1.0.alpha.1` is an alpha prerelease;
- it is not stable;
- it is not production-ready;
- it is not public demo-ready;
- all grammar support is not claimed;
- branch/conditional `if_expr` is excluded from first RC scope;
- profile finalization/discovery/defaulting are closed;
- Spark integration is out of scope;
- runtime / Ledger / TBackend / BiHistory readiness is not claimed;
- public API/CLI widening beyond accepted profile-source transport is not
  claimed.

Docs gap:

- the non-claims exist in release docs, but a new developer does not yet have a
  compact experimental quickstart that repeats them at the point of use.

## Surface / Capability / Blocker / Risk Table

| Surface | Current capability | Experiment blocker | Risk |
| --- | --- | --- | --- |
| `igc compile` | Bounded compile to `.igapp`. | Needs curated input/output path and expected JSON shape. | Users expect run/evaluate. |
| `--compiler-profile-source` | Transport of already-finalized source JSON. | No generator/finalizer/discovery. | Users expect profile creation. |
| `IgniterLang.compile` | Ruby compile facade. | No simple external sample script. | API stability overclaim. |
| RuntimeSmoke | Proof-backed optional smoke. | Proof-context only, no product runtime. | Runtime readiness overclaim. |
| `source/add.ig` | Best current success seed. | Not presented as quickstart example. | Buried among future/parser-only files. |
| `source/*.ig` domain fixtures | Useful language pressure and parser fixtures. | Mixed acceptance posture. | All-grammar support overclaim. |
| `experiments/` | Rich proof evidence. | Too large/noisy for first external experiment. | Proof harness treated as product API. |
| README / release notes | Alpha install and non-claims are present. | No step-by-step first experiment. | Readers see availability but not first success path. |
| Gem package | Published alpha install path. | No packaged examples. | Package availability mistaken for production readiness. |

## Smallest Productization Slice Likely Location

Facts point to the smallest credible slice living around:

```text
repo-local experimental quickstart / workflow around existing `igc compile`
```

Why this is the smallest likely slice:

- it uses the already accepted compile CLI;
- it can use `source/add.ig` or a copy of that bounded source;
- it does not require new runtime behavior;
- it does not require report/result/API fields;
- it does not require profile-source generation;
- it can keep outputs under example-local or temp `out/`;
- it can repeat alpha/pre-v1/non-production non-claims at point of use.

This is a fact-based likely location, not a route decision and not an
implementation authorization.

## Highest-Friction Steps Before Credible Experiment

1. Choose and label a first source fixture as compiler-accepted, not
   parser-only or future-pressure.
2. Provide an exact command line for local and/or installed `igc`.
3. Define where output goes and how to clean it.
4. Show expected success result shape without implying stable API.
5. Say explicitly that runtime/evaluate/dry-run/counterfactual support is not
   part of the experiment.
6. Repeat alpha/pre-v1/non-production/no-public-demo/no-Spark wording inside
   the quickstart boundary.
7. Avoid pulling in profile-source unless the experiment specifically needs it.
8. Keep examples out of gem/package changes unless a later package-boundary
   route authorizes that.

## Exact Facts Handoff For C3-X

C3-X should pressure these facts:

- Whether `source/add.ig` is correctly identified as the safest first compile
  seed.
- Whether absent `examples/` is the highest-friction experimental-use gap.
- Whether RuntimeSmoke is correctly held as proof-context only.
- Whether package availability is accurately separated from stable/production
  readiness.
- Whether profile-source transport is correctly described as already-finalized
  only.
- Whether source fixtures with parser-only/future-pressure semantics are fenced
  enough.
- Whether the likely productization slice is stated as fact-based, not
  authorization.

## Exact Facts Handoff For C4-A

C4-A can use this packet as current-surface facts only:

- developer-visible surfaces exist: RubyGems alpha, `igc compile`, Ruby facade;
- credible first experiment is blocked by missing curated quickstart more than
  missing compiler proof;
- runtime/product execution remains closed;
- report/result/API/counterfactual expansion remains paused after R221;
- examples are absent;
- package currently ships code, CLI, README, and release notes, not examples.

Held risk note:

```text
Any experimental-use route should preserve alpha/pre-v1/no-stable-API wording
and avoid runtime/report/API/Spark/release claims.
```

## Command Matrix

| Command / read | Result |
| --- | --- |
| `git status --short` | PASS; pre-existing untracked C1-D route-options file was present before this packet. |
| `sed -n` read of `stage3-round221-status-curation-v0.md` | PASS. |
| `sed -n` / `rg` read of `docs/current-status.md` | PASS; R221 pause and alpha status located. |
| `sed -n` read of `README.md`, `docs/README.md`, `docs/ruby-api.md`, `RELEASE_NOTES.md` | PASS. |
| `sed -n` read of `lib/igniter_lang.rb`, `lib/igniter_lang/cli.rb`, `compiler_orchestrator.rb`, `runtime_smoke.rb`, `compiler_result.rb` | PASS. |
| `sed -n` read of `igniter_lang.gemspec`, `bin/igc`, and selected `source/*.ig` | PASS. |
| `find igniter-lang -maxdepth 2 -type d -name examples` | PASS; no examples directory found. |
| `find igniter-lang/experiments ...` | PASS; proof/harness corpus exists but is not quickstart-curated. |

No executable proof was required or run. No code/runtime/report/API/public
surface was changed.

## Compact Handoff

[D] This packet records current experimental-use facts only. It does not decide
the route.

[S] Developers can currently compile through `igc` or `IgniterLang.compile`, but
there is no curated `examples/` quickstart.

[T] RuntimeSmoke remains proof-context only; no product runtime/evaluate/dry-run
surface exists.

[R] The smallest likely productization slice is a bounded repo-local
experimental quickstart around existing `igc compile`, with strict alpha/pre-v1
non-claims.

[Next] C3-X can pressure this facts packet; C4-A can decide whether to accept it
as current-surface facts for an experimental-use route.

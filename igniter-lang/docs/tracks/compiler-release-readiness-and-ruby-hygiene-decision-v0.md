# Compiler Release Readiness And Ruby Hygiene Decision v0

Card: S3-R159-C4-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-readiness-and-ruby-hygiene-decision-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md`
- `igniter-lang/docs/discussions/compiler-release-readiness-map-pressure-v0.md`
- `.agents/ruby-framework/tracks/ruby-framework-docs-and-examples-hygiene-v0.md`
- `.agents/ruby-framework/reports/s3-r159-c3-p1-ruby-framework-docs-and-examples-hygiene.md`
- `igniter-lang/docs/tracks/fractal-supervisor-packet-synthesis-v0.md`

---

## Portfolio Decision

Decision:

```text
accept compiler-release-readiness-map-v0
accept compiler-release-readiness-map-pressure-v0
accept Ruby Framework docs/examples hygiene cleanup
open compiler-release-acceptance-harness-design-v0 next as design-only
keep analyzer/tracer/visualizer implementation held
keep Spark sanitized pressure as fixture/design input only
keep Ruby Framework compiler-compatibility docs held until stable Lang export fixture
```

No implementation is authorized by this decision.

---

## Compiler Release Readiness Map

Portfolio accepts the release-readiness map.

Accepted position:

- `poc-mvp-live-touch-v0` is valid release-readiness seed evidence.
- It is not release-candidate evidence yet.
- It is not public demo readiness.
- It is not public release readiness.
- It is not production runtime readiness.
- It is not Spark integration readiness.

The map correctly identifies the next central need:

```text
compiler-release acceptance harness design
```

Required harness design focus:

- normalized artifact comparison policy;
- stable and excluded artifact fields;
- positive RC corpus requirements;
- negative/refusal corpus requirements;
- package/install/load-path/CLI smoke matrix;
- PASS/HOLD/FAIL summary shape;
- release documentation non-claims;
- closed-surface scan policy.

Release-candidate evidence gathering may not open yet. It must wait for the
acceptance harness design to be accepted.

---

## Pressure Review Acceptance

Portfolio accepts the pressure verdict:

```text
proceed - map is well-bounded with no blockers
```

The following non-blocking notes become mandatory inputs to the next design
card:

| ID | Required design answer |
| --- | --- |
| NB-1 | RC corpus must specify minimum language-feature diversity, not only module count. |
| NB-2 | `production_compiler_cli_proof` reuse/rerun policy must be binding. |
| NB-3 | RC docs need a normative non-claims wording template. |
| NB-4 | Warnings must be explicitly in-scope or deferred for RC result shape. |
| NB-5 | RC-wide negative scan token list must be declared explicitly. |

These notes are not blockers for accepting the map. They are blockers for any
later acceptance-harness closure if left unanswered.

---

## Analyzer / Tracer / Visualizer

Disposition:

```text
design-only acceptance-harness consideration allowed
implementation held
public command/UI/visualizer held
```

The analyzer/tracer/visualizer idea is accepted as the right long-term shape
for compiler acceptance and testing, but only after the harness design defines
what must be read, normalized, compared, summarized, and visualized.

It is not release-blocking as UI/tooling for the first compiler release
candidate.

---

## Spark Sanitized Pressure

Spark pressure remains accepted as sanitized fixture/design input only.

Accepted candidate families:

- `service_call_price_shadow_evidence`;
- `service_call_override_divergence_policy`;
- `lead_channel_seed_review_decision`;
- `orders_analytics_evidence_coverage`.

Decision:

```text
do not open separate Spark fixture creation in the next round
feed these candidates into the acceptance harness design as possible future fixtures
```

Not authorized:

- direct Spark code/data access for Igniter-Lang agents;
- Spark production integration;
- primary-ledger replacement;
- binding Spark to unfinished Igniter compiler/runtime behavior.

---

## Ruby Framework Docs / Examples Hygiene

Portfolio accepts Ruby Framework C3-P1.

Accepted cleanup:

- Ruby docs now distinguish published `0.5.2` gems from active/local/proof
  source lanes.
- `Igniter Lang Foundation` language is clarified as additive, report-only,
  metadata-only, and not a compiler/parser/runtime compatibility promise.
- Rails proof and prototype examples are marked as proof/prototype evidence,
  not production/release support surfaces.
- Ruby current status was updated from stale `0.5.1` wording to `0.5.2`.

Decision:

```text
Ruby docs/examples hygiene accepted
no additional Ruby docs pass required now
Ruby compiler-compatibility package-doc sync remains held
```

Ruby may reopen docs only after Igniter-Lang declares a stable
release-candidate export fixture, or if a separate support-only card requests a
public install smoke/documentation check.

Not authorized:

- gem release;
- tag or branch push;
- Ruby public API widening;
- example architecture rewrite;
- Igniter-Lang compiler release compatibility claim;
- Spark production adoption.

---

## Next Dispatch Recommendation

Use the classic unified round-file mode.

Recommended next round:

```text
R160 = C1-D -> C2-X -> C3-A -> C4-S
```

Recommended cards:

- `C1-D` Igniter-Lang Supervisor:
  `compiler-release-acceptance-harness-design-v0`, design-only.
- `C2-X` Igniter-Lang Pressure Reviewer:
  pressure-test the harness design for NB-1..NB-5, overclaim, normalization
  gaps, and closed-surface leakage.
- `C3-A` Portfolio Architect Supervisor:
  accept/hold the harness design and decide whether evidence-gathering may
  open next.
- `C4-S` Status Curator:
  curate R160 status.

Do not include a Ruby implementation/docs card in R160 unless the user
explicitly wants a support-only Ruby smoke/doc follow-up. Ruby should wait for
the Lang export fixture.

---

## Closed Surfaces

This decision does not authorize:

- code implementation;
- release execution;
- public release or public demo claims;
- analyzer/tracer/visualizer implementation;
- public analyzer/tracer command or UI;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or `CompatibilityReport` widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework release/tag/API changes;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

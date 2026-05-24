# Fractal Supervisor Packet Synthesis v0

Card: S3-R158-C5-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `fractal-supervisor-packet-synthesis-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

Top-level dispatch:

- `igniter-lang/docs/cards/S3/S3-R158.md`
- `igniter-lang/docs/cards/S3/R158/README.md`

Available packet-directory packet:

- `igniter-lang/docs/cards/S3/R158/org-architect-supervisor-packet.md`

Native supervisor artifacts read because not all packets landed in the packet
directory:

- `igniter-lang/docs/tracks/compiler-release-poc-acceptance-fractal-seed-v0.md`
- `.agents/ruby-framework/reports/s3-r158-c2-p1-ruby-framework-compiler-release-alignment.md`
- `.agents/ruby-framework/tracks/ruby-framework-compiler-release-alignment-fractal-seed-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-24-SPARK-FR158-C3-P1.md`
- `igniter-lang/docs/org/tracks/fractal-dispatch-protocol-observation-seed-v0.md`

---

## Portfolio Decision

Decision:

```text
accept available supervisor packets
accept POC/MVP live-touch as bounded local release-readiness seed evidence
open compiler release-readiness mapping next
route Spark pressure as sanitized fixture/design pressure only
keep Ruby Framework compiler-alignment held until a stable Lang export fixture exists
continue fractal dispatch selectively, not as the default
```

No implementation is authorized by this decision.

---

## POC/MVP Live Touch

Portfolio accepts the POC/MVP live-touch proof as:

- bounded local demo-lab evidence;
- compiler release-readiness seed evidence;
- proof that existing compile surfaces can produce inspectable `.igapp`
  artifacts and proof-local traces for a tiny coherent app.

Portfolio does not accept it as:

- release-candidate readiness;
- public demo readiness;
- public release claim;
- production runtime readiness;
- Spark integration readiness;
- loader/report or CompatibilityReport readiness.

The next allowed Igniter-Lang route is design/report only:

```text
compiler-release-readiness-map-v0
```

Required focus:

- convert POC evidence and recent compiler/package proof history into a first
  release-candidate boundary;
- define release evidence categories;
- define acceptance harness requirements;
- define artifact stability and normalization policy;
- include positive POC and future negative/refusal evidence classes;
- preserve all public/runtime/deployment closed surfaces.

---

## Analyzer / Tracer / Visualizer

The analyzer/tracer/visualizer idea is accepted as a valuable future direction,
but it should not open ahead of release-readiness mapping.

Disposition:

```text
recognized future acceptance-harness candidate
defer implementation
allow design-only consideration inside release-readiness mapping
```

Rationale:

- the POC artifacts are machine-readable enough to seed an acceptance harness;
- the stable field set, normalization policy, negative/refusal cases, and
  release comparison rules are not yet defined;
- opening visualization first would create attractive tooling momentum before
  the release boundary is clear.

---

## Spark Applied Pressure

Portfolio accepts Spark FR158 as sanitized applied pressure only.

Accepted fixture/design candidates:

- `service_call_price_shadow_evidence`;
- `service_call_override_divergence_policy`;
- `lead_channel_seed_review_decision`;
- `orders_analytics_evidence_coverage`.

Accepted Spark posture:

```text
legacy remains authority
ledgers provide evidence, explanation, shadow candidates, and future backend boundaries
Spark proceeds locally where business deadlines require it
Igniter receives sanitized pressure only
```

Spark remains unblocked for local work:

- ServiceCall explanation/review UI;
- Orders analytics read surfaces;
- LeadChannel review training rounds;
- MCP observability.

Not authorized:

- direct Spark code/data access for Igniter-Lang agents;
- Spark production integration;
- primary-ledger replacement;
- binding Spark to unfinished Igniter compiler/runtime behavior.

---

## Ruby Framework Alignment

Portfolio accepts Ruby Framework FR158.

Decision:

```text
no Ruby release action now
no package-doc sync now
hold until Igniter-Lang declares a stable release-candidate export fixture
```

Ruby `0.5.2` remains published/closed. Current docs do not overclaim compiler
release readiness. Future docs must keep compiler bridge language additive,
report-only, metadata-only, and not runtime-enforced until Lang provides a
stable export shape.

---

## Fractal Dispatch Result

Portfolio accepts the Org observation with an amendment from user experience.

Fractal seed dispatch was useful for testing delegation, but it was too complex
for routine human dispatch across several supervisors. The packet directory
worked conceptually, but only Org returned a packet in the expected directory;
Lang/Ruby/Spark returned useful native artifacts in their own surfaces.

Decision:

```text
fractal dispatch remains optional
default returns to unified round-file dispatch
use fractal only for rare multi-supervisor synthesis rounds
```

Operational rule:

- default: one top-level round file with full cards that the user can distribute;
- optional fractal: use only when supervisor autonomy is more valuable than
  dispatch simplicity;
- if used, packet directory is required but Portfolio may read native artifacts
  if packets are missing.

---

## Recommended Next Dispatch

Use the classic unified round-file style, not a new fractal round.

Recommended R159 shape:

```text
R159 = C1-D -> C2-X -> C3-A -> C4-S
```

Recommended cards:

- `C1-D` Igniter-Lang Supervisor:
  `compiler-release-readiness-map-v0`, design/report only.
- `C2-X` Igniter-Lang pressure review:
  pressure-test release map for overclaim, missing negative/refusal evidence,
  artifact stability gaps, and public/runtime/deployment leakage.
- `C3-A` Portfolio Architect Supervisor:
  accept/hold the release-readiness map and choose the next compiler-release
  route.
- `C4-S` Status Curator:
  curate R159 outcome.

Spark sanitized fixtures and Ruby export-fixture alignment should be referenced
as inputs to the release-readiness map, not opened as separate implementation
work in the same round.

---

## Closed Surfaces

This decision does not authorize:

- implementation;
- public release or public demo claims;
- production deployment;
- Spark production integration;
- direct Spark code/data access for Igniter-Lang agents;
- Ruby gem release, tag push, or API widening;
- public API/CLI widening;
- loader/report;
- CompatibilityReport;
- RuntimeMachine/Gate 3 widening;
- Ledger/TBackend production binding;
- BiHistory;
- stream/OLAP;
- cache;
- signing;
- deployment.

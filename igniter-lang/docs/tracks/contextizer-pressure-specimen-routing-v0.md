# Track: Contextizer Pressure Specimen Routing v0

Card: S3-R39-SIDECAR
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: contextizer-pressure-specimen-routing-v0
Status: routed-pressure-specimen
Date: 2026-05-12

---

## Goal

Prevent `Igniter.DocumentContextizer` from becoming a zombie pressure specimen by
assigning it an explicit status, route, and relationship to the existing
standalone `contextizer` utility.

---

## Sources Reviewed

Pressure specimen:

```text
igniter-lang/experiments/pressure-specimens/mundane-application-pressure-v0/igniter-document-contextizer.ig
```

Existing local utility, outside this repo:

```text
[GEM]/contextizer/README.md
[GEM]/contextizer/lib/contextizer.rb
[GEM]/contextizer/config/default.yml
[GEM]/contextizer/contextizer.gemspec
```

---

## Disposition

`igniter-document-contextizer.ig` is an **active pressure specimen**.

It is not:

- canon;
- parser authority;
- runtime authority;
- package creation authority;
- production deployment authority;
- Ledger/BiHistory authorization;
- LLM connector authorization.

The specimen contains external-agent language such as `production-ready` and
package-placement suggestions. Those are treated as pressure claims only.

---

## Legacy Utility Signal

The existing `[GEM]/contextizer` project is a Ruby CLI gem for
extracting project context into Markdown:

- detects language/framework signals;
- collects Git metadata, dependencies, filesystem structure, and selected source
  files;
- supports local project and public Git repository analysis;
- uses configurable providers and analyzers;
- outputs a single Markdown context report.

This is materially different from the external specimen:

| Existing `contextizer` utility | Igniter pressure specimen |
| --- | --- |
| CLI context extraction for software projects | agent/swarm document context pipeline |
| Markdown report output | typed `ContextSnapshot` / `KeyPoint` / receipts |
| analyzers/providers/renderers | contracts, validation, drift, publish, actualize |
| no Ledger requirement | claims Ledger/BiHistory-backed snapshots |
| practical utility sketch | language/product pressure sketch |

The bridge signal is strong: Igniter needs a future document/context pipeline,
but the current path should evolve from the practical CLI shape and the pressure
specimen together, not by promoting either one directly.

---

## Extracted Signals

[S] The project has a real recurring need for context compaction: large docs,
reviews, specs, pressure files, and project snapshots should become compact,
traceable context cards.

[S] The Line Up work and Contextizer idea are adjacent but not identical:

```text
Line Up Summarizer  -> human-readable memory card for repo documents
Contextizer         -> generalized extraction/context-packaging pipeline
DocumentContextizer -> future agent-facing document context product idea
```

[S] The existing CLI suggests useful implementation primitives:

- analyzers;
- providers;
- renderers;
- configuration profiles;
- filesystem/git/dependency providers;
- remote repository intake;
- Markdown report generation.

[S] The pressure specimen suggests future Igniter-Lang primitives:

- `ContextSnapshot`;
- drift detection;
- evidence links;
- quality validation;
- context actualization;
- publish-for-swarm surface;
- LLM connector as explicit escape capability.

---

## Friction / Gap Signals

[G] The specimen uses non-canonical syntax and concepts:

```text
phase
given
emit
validate { ... severity: ... }
DateTime?
Array[T]
Map[String, Any]
ContractRef[T]
History[ContextSnapshot] from "..."
now
LLMConnector
FactReceipt
```

[G] The specimen claims `BiHistory`/Ledger-like backing, but current Stage 3
boundaries keep Ledger, BiHistory, production cache, broad RuntimeMachine
binding, and production execution closed.

[G] The specimen uses ambient time (`now`) in helper logic. In current
Igniter-Lang doctrine, time must be explicit and non-ambient unless a future
capability/profile authorizes it.

[G] The phrase `production-ready` is unsafe inside a pressure specimen. It is now
explicitly marked as an external claim, not project authority.

---

## Candidate Future Routes

These are not authorized work items. They are candidate cards for later planning.

| Candidate | Route |
| --- | --- |
| `contextizer-lineup-bridge-analysis-v0` | compare Line Up summaries, existing CLI reports, and DocumentContextizer snapshots |
| `contextizer-utility-inventory-v0` | deeper inventory of `[GEM]/contextizer` package architecture |
| `document-contextizer-product-pressure-v0` | product/design report: document context, evidence, drift, quality, swarm publication |
| `context-snapshot-shape-proposal-v0` | proposal candidate for `ContextSnapshot` / `KeyPoint` shape, not runtime |
| `llm-connector-escape-boundary-pressure-v0` | escape capability design pressure for LLM calls |
| `contextizer-pack-shadow-boundary-v0` | future package/profile boundary exploration, no code |

---

## Non-Authorizations

This track does not authorize:

- compiling `igniter-document-contextizer.ig`;
- creating `packages/igniter-document-contextizer`;
- parser syntax from the specimen;
- stdlib implementation;
- LLM connector implementation;
- Ledger/BiHistory binding;
- runtime execution;
- production deployment;
- mutation of the external `[GEM]/contextizer` project.

---

## Handoff

```text
Card: S3-R39-SIDECAR
Agent: [Architect Supervisor / Codex]
Role: architect-supervisor
Track: contextizer-pressure-specimen-routing-v0
Status: done

[D] Decisions
- `Igniter.DocumentContextizer` is an active pressure specimen only.
- Existing `[GEM]/contextizer` is a practical CLI utility
  signal, not automatically part of Igniter-Lang.
- The specimen's "production-ready" language is external pressure, not authority.

[S] Signals
- Context compaction is a real product/agent-system need.
- The future route likely joins Line Ups, Contextizer CLI primitives, evidence
  links, drift detection, quality validation, and explicit LLM escape capability.

[T] Tests / Proofs
- Documentation-only routing.
- Read external README/gemspec/default config and specimen source.

[R] Risks / Recommendations
- Do not promote the specimen into canon or package form without a proposal/gate.
- Do not let `now`, Ledger/BiHistory claims, or LLM connector usage bypass
  current language/runtime boundaries.

[Next]
- Optional future sidecar: `contextizer-lineup-bridge-analysis-v0`.
```

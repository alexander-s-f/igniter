# Temporal Audit Pressure Specimens v0

Status: non-canonical pressure specimen
Card: S3-R37-C1-P
Track: prop032-assumptions-spec-sync-and-temporal-specimen-disposition-v0
Date: 2026-05-11

---

## Disposition

This directory is a pressure-specimen bundle only. It is not accepted syntax, not
implementation evidence, and not proof that any parser, SemanticIR, runtime,
ledger, receipt, profile, or production behavior exists.

These files may be read to extract pressure signals. They must not be cited as:

- canonical Igniter-Lang examples;
- parser fixtures;
- compiler proof fixtures;
- runtime receipt evidence;
- PROP-033 evidence-validation evidence;
- authorization for BiHistory, ledger, distributed agents, simulations, or
  production RuntimeMachine behavior.

## Inventory

| File | Pressure signal | Disposition |
|------|-----------------|-------------|
| `igniter-financial-audit-time-travel-v1.ig` | bitemporal financial audit, corrections, as-of reconstruction, receipt-shaped audit trail | extract temporal/audit pressure only |
| `igniter-patient-medical-history-v1.ig` | medical as-of views, correction history, recorded-by authority pressure | extract temporal/privacy/audit pressure only |
| `igniter-logistics-what-if-simulation-v1.ig` | forked what-if simulation over historical state | extract simulation + temporal fork pressure only |
| `igniter-projects.ig` | project/task workflow over History/BiHistory with emits/receipts | extract workflow and OOF pressure only |
| `igniter-agentgram.ig` | distributed agent coordination, LedgerStore/NetworkBackend/receipt/changefeed claims | research note only; no implementation evidence |
| `lexmesh/igniter-lexmesh-idea.md` | legal-history, precedent, replay, collision, simulation pressure | research note only; no implementation evidence |
| `lexmesh/README.md` | empty placeholder | no signal |

## Extracted Signals

- Temporal read pressure: `as_of`, `at(vt:, tt:)`, bitemporal correction, and
  historical reconstruction appear repeatedly.
- Audit pressure: examples want immutable correction trails, emitted events,
  receipt-shaped outputs, and authority/provenance links.
- Simulation pressure: what-if forks and replay are recurring user-facing needs,
  but no source grammar or runtime behavior is accepted here.
- Profile pressure: examples refer to `time: bitemporal`, `evidence: required`,
  `trust`, and `effects`; these remain descriptor/profile pressure, not Ch2
  source syntax.
- OOF pressure: future work may need diagnostics around implicit temporal scope,
  missing receipt provenance, undeclared authority, and replay/correction ambiguity.

## Routing

Future work may route the extracted signals to a bounded pressure-analysis card
or a future temporal/audit proposal discussion. Any such route must preserve the
existing gates:

- do not authorize PROP-033 evidence validation;
- do not authorize runtime receipt `assumption_refs`;
- do not authorize BiHistory runtime behavior beyond existing gates;
- do not authorize ledger/distributed-agent production behavior;
- do not treat the specimen syntax as canonical Ch2 grammar.

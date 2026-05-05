# Track: Observable Spine v0

Status: proposal
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Define the smallest observation packet model that can carry the first
Igniter-Lang axiom slice:

```text
Everything observable.
Everything contract.
```

This is not a grammar, parser, runtime, or storage implementation track. It is
a semantic spine track: identify the minimal packet shapes that let humans,
agents, compilers, runtimes, and bridge proposals talk about the same observed
meaning without leaking host-language noise.

## Source Horizon

Read-only sources used:

- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `docs/guide/igniter-lang-foundation.md`
- `docs/research/igniter-lang-convergence-report.md`
- `docs/research/project-status-horizon-report.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-algebra.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-theory.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-theory2.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-persistence.md`
- `playgrounds/docs/experts/igniter-lang/igniter-lang-temporal.md`
- `packages/igniter-ledger/docs/open-protocol.md`
- `packages/igniter-ledger-client/docs/tracks/ledger-client-result-models-v0.md`
- `packages/igniter-ledger/docs/tracks/contractable-receipt-ledger-sink-v0.md`
- `packages/igniter-durable-model/docs/manifest-glossary.md`

## Compact Claim

[D] Igniter-Lang should use one small observation envelope with a closed v0 set
of semantic packet kinds, not a separate packet schema for every subsystem.

The envelope is the language spine:

```text
contract meaning
-> observation envelope
-> optional platform packet, fact, receipt, diagnostic, or artifact
```

An observation packet is not a log line. It is a typed claim that a named
semantic thing was declared, observed, accepted, rejected, derived, redacted,
failed, or materialized under named constraints and time semantics.

Ledger facts, Durable Model descriptors, command intents, materializer status
packets, diagnostics, and agent receipts can all lower into this spine, but the
spine should stay independent of Ledger, Ruby, HTTP, WAL, SQL, or a specific
agent runtime.

## Observation Identity

[D] Observation identity is local, semantic, and content-aware. It must not
require one global runtime registry.

Minimal identity tuple:

```text
space + kind + subject_ref + occurrence_ref
```

- `space` names the authority that can mint the observation: project, package,
  contract, store, agent run, materializer run, compiler pass, or platform.
- `kind` names the packet kind.
- `subject_ref` names what the observation is about.
- `occurrence_ref` disambiguates this observation from other observations of
  the same subject: fact id, receipt id, run id, descriptor hash, event id,
  sequence/cursor, or content hash.

`observation_id` is the stable identifier derived from, or assigned alongside,
that tuple. The id is stable inside its `space`; cross-space meaning comes from
typed links, not from a central allocator.

Rules:

- Descriptor-like observations should be content-addressed when possible.
- Fact and receipt observations should reuse fact ids, receipt ids, or
  idempotency keys when available.
- Runtime value observations may use run-scoped occurrence ids.
- Redacted observations still need a stable `content_hash` over the canonical
  redacted payload or declared omission.
- `observed_at` never replaces semantic time such as `as_of` or valid time.

## Proposed Envelope

This pseudo-structure is **proposed as the v0 semantic envelope**, not as final
wire syntax:

```text
ObservationPacket {
  schema_version: 1
  kind: PacketKind
  observation_id: ObservationId
  space: ObservationSpace
  subject: SubjectRef
  status: ObservationStatus
  producer: ProducerRef
  observed_at: Timestamp
  content_hash: Hash
  privacy: PrivacyPolicy
  links: [ObservationLink]

  temporal?: TemporalContext
  payload?: PayloadOrRef
  constraints?: [ConstraintRef]
  diagnostics?: [DiagnosticSummary]
  capabilities?: CapabilitySummary
  actor?: ActorRef
  extensions?: Map
}
```

Required fields:

| Field | Why required |
|------|--------------|
| `schema_version` | Packet compatibility without assuming a public API forever |
| `kind` | Lets consumers understand the semantic role before reading payload |
| `observation_id` | Stable local identity for links, receipts, and replay |
| `space` | Names the minting authority and avoids global registry coupling |
| `subject` | Names what the observation is about |
| `status` | Distinguishes observed, accepted, rejected, blocked, failed, redacted |
| `producer` | Gives compiler/runtime/agent/platform provenance |
| `observed_at` | Records when the packet was produced |
| `content_hash` | Supports dedupe, parity, redaction, and materializer evidence |
| `privacy` | Makes redaction and retention part of semantics |
| `links` | Connects packets without hidden global state |

Optional fields are semantic, not decorative:

- `temporal` is required when meaning depends on `as_of`, valid time,
  transaction time, causal clock, rule version, replay cursor, or lag SLA.
- `payload` is optional because some packets are descriptor-only, hash-only, or
  redacted.
- `constraints` point to type, guard, invariant, deadline, consistency,
  capability, or privacy constraints used to interpret the observation.
- `diagnostics` carry compact summaries, not raw host stack dumps.
- `capabilities` summarize requested, granted, denied, or consumed authority.
- `actor` names an agent, human, system, compiler, runtime, or materializer when
  authorship matters.
- `extensions` may exist, but unknown extensions cannot change required v0
  meaning.

## Packet Kinds

[D] Use a small closed family for v0. Do not mirror every platform object as a
new packet kind.

| Kind | Covers | Notes |
|------|--------|-------|
| `descriptor_observation` | contracts, nodes, types, stores, histories, access paths, relations, projections, commands, effects, axioms, platform descriptors | Declares what exists or what shape a thing has |
| `value_observation` | inputs, outputs, constants, derived values, read results | Carries values or value hashes under contract/time context |
| `constraint_observation` | type checks, guards, invariants, policies, deadlines, cache rules, consistency, capability checks, privacy checks | Records satisfied, failed, waived, or unknown constraints |
| `fact_observation` | Ledger facts, history events, replay entries, compaction refs, provenance refs | Covers both Store[T] and History[T] evidence |
| `intent_observation` | command intent, effect plan, materializer plan, agent proposal, cleanup plan | Describes proposed action before external mutation |
| `receipt_observation` | write receipt, append receipt, materializer receipt, approval receipt, command activity receipt, agent tool receipt | Describes accepted/rejected/deduped/executed result |
| `failure_observation` | compiler rejection, runtime contract failure, diagnostic finding, blocked capability, failed parity check | Failure is first-class semantic output |
| `platform_observation` | axiom version, runtime version, backend descriptor, clock source, provider/model descriptor | Names opaque boundary that affected meaning |

[D] Dependency edges should be links, not a separate packet kind. A dependency
edge may be observed through a `descriptor_observation` when it is itself the
subject of review, but ordinary graph connectivity belongs in `links`.

[D] `history_observation`, `agent_evidence`, and `materializer_receipt` are not
top-level v0 kinds. They are `fact_observation`, `intent_observation`, or
`receipt_observation` with typed `subject`, `actor`, `temporal`, and
`capabilities` fields.

## Link Model

[D] Packets link through typed refs. A consumer may dereference links if it has
the data, but meaning must not require hidden process memory.

Proposed link shape:

```text
ObservationLink {
  rel: LinkRel
  ref: ObservationId | ExternalRef
  role?: Symbol
  required?: Boolean
}
```

Core link relations:

- `describes`: descriptor -> subject
- `depends_on`: output/value/intent -> input/value/descriptor
- `caused_by`: fact/receipt/failure -> prior fact/intent/receipt
- `derived_from`: materialized value/artifact -> source facts/descriptors
- `satisfies`: constraint/value/receipt -> required contract or constraint
- `violates`: failure -> constraint
- `observed_under`: value/fact/receipt -> temporal/platform/axiom context
- `materializes`: receipt/artifact -> descriptor or plan
- `redacts`: redacted packet -> redaction/privacy contract
- `supersedes`: newer descriptor/packet -> prior descriptor/packet

External refs may point to platform concepts without importing platform classes:

```text
contract://OrderTotal#output.total
store://tasks/key/t1
fact://tasks/fact_123
history://task_events/partition/t1
artifact://generated/contracts/reminder.rb#sha256:...
platform://ruby/3.3.0
agent-run://daily_companion/run_456
```

Missing optional links mean "not available." Missing required links make the
packet incomplete and should be reported as a `failure_observation` or
`constraint_observation`, not silently ignored.

## Temporal Model

[D] Every packet has `observed_at`; packets whose meaning depends on time also
carry `temporal`.

Proposed `TemporalContext`:

```text
TemporalContext {
  as_of?: TimeRef
  as_of_source?: :caller | :execution_context | :store_consistency |
                 :platform_clock | :replay
  valid_time?: TimeRange
  transaction_time?: Timestamp
  causal_clock?: ClockRef
  rule_version?: VersionRef
  replay?: {
    from?: CursorOrTime
    to?: CursorOrTime
    horizon?: CursorOrTime
    source?: Ref
  }
  freshness?: {
    lag_sla?: Duration
    observed_lag?: Duration
  }
}
```

Rules:

- `observed_at` is packet production time.
- `transaction_time` is when a store/system accepted a fact or receipt.
- `valid_time` is when the fact/value is true in the modeled world.
- `as_of` is the semantic read point used by a contract, query, relation,
  projection, or replay.
- `as_of_source` must be visible when `as_of` is implicit.
- `causal_clock` is optional in v0, but required for causal consistency claims.
- `rule_version` is required when temporal rules can change the result.
- `freshness` is required when eventual or lag-bounded data is accepted.

This keeps temporal reads observable without requiring a full distributed time
model in the language core.

## Failure Model

[D] A failure is an observation packet, not an exception side-channel.

Failure packets use `kind: failure_observation` and must include:

- `status`: `failed`, `rejected`, or `blocked`
- `subject`: the contract, node, descriptor, intent, or packet that failed
- `links`: at least one `violates`, `caused_by`, or `observed_under` link
- `diagnostics`: compact reason code, human summary, path, and remediation hint
- `privacy`: whether payloads, prompts, stack traces, or values were redacted
- `retryable`: in diagnostics or payload when a retry is meaningful

Failure payloads should prefer structured summaries:

```text
{
  reason_code: :constraint_unsatisfied
  path: "OrderTotal.total"
  expected: "Money >= 0"
  actual_policy: :redacted
  remediation: "Check discount rule version and price floor invariant"
}
```

Host stack traces, raw SQL errors, provider traces, and heap state are not v0
semantic fields. They may be referenced through a gated debug artifact if a
separate privacy/capability contract allows it.

## Agent And Materializer Model

[D] Agents and materializers use the same envelope. They do not get privileged
packet shapes.

Agent observations:

- agent proposal -> `intent_observation`
- agent tool call result -> `receipt_observation`
- agent refusal/block -> `failure_observation`
- agent run descriptor -> `descriptor_observation`
- model/provider boundary -> `platform_observation`

Agent packets should include:

- `actor`: agent id, role, run id, model/provider descriptor ref, and tool
  boundary when relevant
- `privacy`: prompt/input/output policy and redaction summary
- `links`: source observations used as evidence
- `capabilities`: requested, granted, denied, or consumed capabilities
- `payload`: proposal summary, patch/artifact ref, confidence when declared

Agent packets should not require raw prompt storage. Store prompt hashes,
redaction class summaries, source refs, and resulting artifacts/receipts by
default. Raw prompts need an explicit observation contract with retention,
privacy, and capability terms.

Materializer observations:

- materialization plan -> `intent_observation`
- parity check -> `constraint_observation`
- materialized artifact -> `receipt_observation`
- blocked approval/capability -> `failure_observation`
- source horizon -> links to descriptors/facts/spec lineage

Materializer packets should include:

- source refs and source horizon
- target artifact refs and content hashes
- parity/equivalence check refs
- write boundary and capability status
- execution status: review-only, dry-run, executed, rejected, or blocked

`execution_allowed: false` and `grants_capabilities: false` remain semantic
claims. A human approval observation may exist, but approval alone should not
equal capability consumption.

## Consumer Needs

| Consumer | Required fields they depend on |
|----------|--------------------------------|
| Humans | `subject`, `status`, compact `diagnostics`, `links`, `privacy`, summaries |
| Agents | `kind`, `subject`, `links`, `constraints`, `capabilities`, `temporal`, redaction policy |
| Compilers | descriptors, constraints, dependency links, failure packets, platform/axiom versions |
| Runtimes | value/fact/receipt ids, temporal context, idempotency/content hashes, capability status |
| Bridge consumers | schema version, kind, producer, payload/ref normalization, compatibility rules |

[D] Human readability is a semantic requirement, but raw verbose detail is not.
The packet should be compact by default and link outward to richer artifacts only
when capability and privacy policies allow it.

## Host-Noise Exclusions

[X] These stay outside the v0 packet unless wrapped by an explicit diagnostic or
debug artifact contract:

- host-language call stacks
- heap object ids, allocation graphs, and thread internals
- database query plans, index scan details, and connection pool state
- transport retries, socket timings, and adapter-specific backoff mechanics
- scheduler implementation details
- raw prompts, secrets, unredacted user data, provider chain-of-thought, and
  full tool transcripts
- raw generated files when a content hash and artifact ref are sufficient
- physical WAL frame format or compaction internals unless the packet subject is
  storage durability itself

The boundary is simple: include details that change semantic meaning or audit
responsibility; link or omit details that only explain host mechanics.

## Bridge Candidates

[R] Do not edit package docs or code from this track. Bridge through explicit
proposal docs after Architect review.

1. **Observation envelope bridge.** Map Ledger Open Protocol descriptors, facts,
   receipts, query/replay results, and subscription events into the v0 envelope
   without changing Ledger packet internals.

2. **Structured failure bridge.** Normalize existing diagnostics/readiness
   health packets into `failure_observation` and `constraint_observation`
   shapes with reason codes, path, remediation, privacy, and required links.

3. **Agent/materializer evidence bridge.** Align Companion materializer status,
   approval receipts, command activity receipts, and agent run evidence around
   `intent_observation` plus `receipt_observation` with redaction-safe payloads.

## Rejected Paths

[X] Many bespoke packet families. This makes every subsystem its own language
and defeats the spine.

[X] One untyped JSON blob. A generic envelope still needs a closed v0 kind
vocabulary and required fields.

[X] Global observation registry. Local identity plus typed links is enough for
v0 and works across process/package boundaries.

[X] Mandatory raw payload storage. Hash-only, ref-only, and redacted packets are
first-class.

[X] Treating `observed_at` as `as_of`. Packet production time and semantic read
time are different facts.

[X] Raw agent prompt capture as audit. Audit should preserve evidence and
responsibility without forcing unsafe data retention.

[X] Platform leakage. If the packet needs host internals to be meaningful, it is
not yet a semantic packet.

## Next Slice Recommendation

[R] Next slice: `failure-observation-v0`.

Purpose: prove the spine on one narrow, high-value case: a structured failure
packet for compiler findings, diagnostic health drift, blocked capabilities,
and materializer parity failures.

It should answer:

- What are the minimal reason codes?
- How are `violates`, `caused_by`, and `observed_under` links used?
- What does a remediation hint look like without becoming prose-only?
- Which current Igniter diagnostics could later lower into this shape?
- Which debug details remain gated artifacts rather than packet fields?

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/observable-spine-v0
Status: done

[D] Decisions:
- Use one observation envelope with a closed v0 semantic kind family.
- Observation identity is `space + kind + subject_ref + occurrence_ref`, with
  `observation_id` stable inside its minting space.
- Dependency edges are typed links, not a top-level packet kind.
- Agent and materializer evidence use ordinary intent/receipt/failure packets.
- `observed_at` is packet production time; semantic time lives in `temporal`.

[R] Recommendations:
- Run `failure-observation-v0` next as the smallest concrete proof of the spine.
- Keep bridge work explicit: observation envelope, structured failure, and
  agent/materializer evidence are candidates, not package edits.
- Treat privacy/redaction as required packet semantics, not implementation
  decoration.

[S] Signals:
- Ledger Open Protocol already converges on descriptors, facts, receipts,
  queries, subscriptions, provenance, `as_of`, and replay.
- Durable Model already uses report-only descriptors, command intents, activity
  receipts, materializer status packets, and health packets with no-grant
  semantics.
- Contractable receipt sink work shows observation/event receipts can persist
  as normal facts without importing the originating runtime.

[Q] Open Questions:
- Should v0 reserve a standard URI/ref grammar, or keep refs stringly typed
  until bridge pressure repeats?
- Which content-hash canonicalization is acceptable across Ruby, future DSLs,
  and non-Igniter clients?
- How much provider/model metadata is enough for agent reproducibility without
  leaking unsafe prompts or vendor-specific internals?

[X] Rejected:
- Many bespoke packet families.
- One untyped JSON blob.
- Global observation registry.
- Mandatory raw payload storage.
- Treating `observed_at` as `as_of`.
- Raw agent prompt capture as audit.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/failure-observation-v0.md`
```

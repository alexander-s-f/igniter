# Track: Spark CRM Applied Language Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Track id: `spark-crm-applied-language-pressure-v0`
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This slice pressure-tests Igniter-Lang against Spark CRM technician dispatch and
the adjacent marketing lead pipeline. It asks whether the current Epistemic
Contract Language spine can model real availability and dispatch work as:

```text
contracts + explicit time + observation evidence
  -> projections / slices
  -> FFI and vendor boundaries
  -> diagnostics and explainability
  -> schema evolution
```

This is not a compiler/runtime/package implementation slice. It writes no code
outside `igniter-lang/`.

## Source Horizon

Read sources used as pressure:

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/temporal-lifecycle-application-scenarios-v0.md`
- `igniter-lang/docs/tracks/temporal-lifecycle-boundary-fixtures-v0.md`
- `igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md`
- `igniter-lang/source/availability_projection.ig`
- `igniter-lang/docs/proposals/PROP-004-type-system-v0.md`
- `igniter-lang/docs/proposals/PROP-008-tbackend-contract-v0.md`
- `igniter-lang/docs/proposals/PROP-012-compilation-artifact-deployment-model-v0.md`
- `igniter-lang/docs/proposals/PROP-013-stdlib-fold-aggregate-v0.md`
- `igniter-lang/docs/proposals/PROP-017-schema-evolution-contract-migration-v0.md`
- `playgrounds/urgently/sparkcrm/app/services/api/marketing/executor_service.rb`
- `playgrounds/urgently/sparkcrm/app/contracts/api/marketing/availability_contract.rb`
- `playgrounds/urgently/sparkcrm/app/contracts/api/marketing/availability_steps.rb`
- `playgrounds/urgently/sparkcrm/app/models/employee/availability.rb`
- `playgrounds/urgently/sparkcrm/app/models/schedule.rb`
- `playgrounds/urgently/sparkcrm/app/models/off_schedule.rb`
- `playgrounds/urgently/sparkcrm/app/models/order.rb`
- `playgrounds/urgently/sparkcrm/app/models/trade_vendor.rb`

## Compact Claim

[D] Spark CRM exposes a useful applied fixed point:

```text
lead/vendor/telephony/geo signals
  + employees/technicians
  + schedules/off_schedules/orders/day_off_config
  + explicit time and tenant scope
  -> availability projection
  -> dispatch candidate set
  -> pinned decision
  -> assignment / notification / vendor receipts
```

[D] Igniter-Lang already has enough theory to name this domain. It does not yet
have enough language capability to make the whole system executable,
explainable, and migratable without relying on ambient Rails behavior.

[D] The central applied demand is not "compute available slots." The demand is:

```text
Can an operator or agent trust why this lead was accepted, why these
technicians were eligible or rejected, what time/rules/facts were visible, and
which effects actually happened?
```

## Domain Pressure Map

Spark CRM facts and signals can be made contract-addressable as follows:

| Spark surface | Contract pressure | Temporal/lifecycle pressure |
|---------------|-------------------|-----------------------------|
| `Employee` technician | `TechnicianProfile` with services, zones, status, tenant | `T.durable`, schema-versioned |
| `Schedule` | `ScheduleSlot` linked to order and technician | `T.durable`, read under `as_of` |
| `OffSchedule` | `OffScheduleBlock` with reason/source | `T.window` or `T.durable` |
| `day_off_config` JSON | `DayOffConfigVersion` | `T.durable`, migration-sensitive |
| `Order` | `OrderRequest` / `OrderBoundary` | `T.durable` then `T.audit` |
| Geo points | `GeoSignal` stream | `T.window` -> snapshot/stub |
| Ringba/vendor lead | `VendorLeadSignal` | `T.window` -> lead boundary |
| Telephony attempts | `TelephonyAttempt` / receipt | `T.audit` if action/failure-linked |
| Availability result | `AvailabilityProjection` | live or pinned projection |
| Assignment | `DispatchDecision` + `AssignmentReceipt` | `T.audit` |

The existing `availability_projection.ig` is a small positive signal: it uses
bounded `read`, window lifecycle, collection transforms, and snapshot output.
The real Spark pressure is wider: it mixes tenant-free reads, tenant-scoped
technician loops, vendor time zones, random response tokens, provider effects,
and legacy response compatibility.

## Scenario 1: Vendor Lead Intake

Real pipeline pressure from the marketing executor:

```text
params(trade, id, zip_code)
  -> validate
  -> find_trade
  -> find_vendor
  -> find_zip_code
  -> derive_current_time(vendor.time_zone)
  -> check_business_hours(vendor.start, vendor.stop)
  -> find_geo_bids
  -> excluded companies
  -> availability_mode
  -> locations
  -> availability
  -> bid/did/duration/upi response
```

What current Igniter-Lang can model:

- `params`, `TradeVendor`, `ZipCode`, `RingbaBid`, and response payloads as
  structural contracts.
- validation and lookup absence with `Result[T, E]` / `Option[T]`.
- `current_time` only when supplied by explicit `TemporalCtx`.
- ActiveRecord lookups as ESCAPE FFI reads with capability gates and receipts.
- response version drift with `schema_version`, `schema_fingerprint`, and
  `CompatibilityReport.schema_check`.

Where it breaks:

- The source surface has no settled fail-fast pipeline syntax. The current Ruby
  shape uses nested `bind` and step hashes; Igniter-Lang needs typed early exit
  plus trace observations.
- `Time.current.in_time_zone(vendor.time_zone)` is OOF unless the clock,
  timezone database version, and `as_of` are explicit.
- `Random.new.alphanumeric(8)` is an undeclared entropy effect unless modeled as
  ESCAPE with idempotency and receipt policy.
- Vendor/Ringba lead input is not just data. It is an external signal with
  source identity, retry/idempotency, privacy, and provider failure semantics.
- Decimal money-like fields (`bid`, thresholds) are not covered by the current
  base type set except through Float, which is risky for business responses.

Language capability demand:

```text
PipelineStep[In, Out, Err]
  -> Result[Out, Err]
  -> StepObservation
  -> first failure pins trace and halts downstream effects
```

## Scenario 2: Availability Across Tenants

Spark availability is not a single query. The service first finds candidate
locations without a tenant, then switches into each company tenant and reads
active technicians, schedules, off schedules, and `day_off_config`.

```text
Location(company, zone, zip)
  -> TechnicianProfile
  -> schedules_by_date(date window)
  -> off_schedules_by_date(date window)
  -> day_off_by_date(day_off_config, weekday)
  -> company.current_slots(date)
  -> available_slots
  -> threshold decision
```

What current Igniter-Lang can model:

- bounded collection reads and `fold`/`map`/`filter` from PROP-013;
- explicit `ProjectionHorizon` with `as_of`, `rule_version`, `fact_scope`, and
  optional `replay_cursor`;
- `AvailabilitySnapshot` and `DailyTechnicianBoundary` from the temporal
  lifecycle tracks;
- `TBackend.read` with explicit `as_of` and evidence links.

Where it breaks:

- Tenant scope is a convention in current tracks, not a formal type-level
  requirement. A missing or mixed `company_id` should be a compile/load-time
  blocker for dispatch projections.
- `ActsAsTenant.without_tenant` and `with_tenant(location.company)` are host
  control flow. In language terms they need scoped TBackend descriptors, not
  ambient globals.
- Nested reads over locations -> technicians -> dates can explode. Igniter-Lang
  needs bounded cardinality evidence or a query-plan diagnostic before calling
  it CORE-safe.
- `day_off_config` is JSON and therefore schema-sensitive. Its shape needs a
  versioned structural type and migration receipts.
- `availability_mode` branches (`same_day`, `tomorrow`, `always_bid`) combine
  policy, time, and action rights. `always_bid` must not silently bypass
  availability evidence.

Language capability demand:

```text
ScopedFactRead[T] =
  subject + as_of + tenant_scope + cardinality_bound + schema_version
```

## Scenario 3: Dispatch Decision And Why-Not Explainability

A dispatcher or agent does not only need "available_slots > threshold." It
needs candidate comparisons and rejected-candidate reasons.

```text
Order + CandidateTechnicians + AvailabilitySnapshots
  -> DispatchCandidate[order, technician]
  -> ranked candidate set
  -> DispatchDecision
  -> AssignmentReceipt
  -> NotificationReceipt / TelephonyReceipt / RouteReceipt
```

What current Igniter-Lang can model:

- live vs reproducible slices;
- `DispatchDecision` and audit lifecycle;
- FFI receipts for host effects;
- `SemanticImage` and `CompatibilityReport` as action/resume evidence;
- failure observations for rejected or failed paths.

Where it breaks:

- Ranking has no settled standard primitive: `argmax`, stable tie-breakers,
  weighted factors, and why-not reasons need evidence-linked outputs.
- A live slice cannot directly authorize assignment. The language needs a crisp
  live-to-pinned transition that captures `as_of`, rule version, fact scope, and
  source observations at decision time.
- Manual override is not just a branch. It is capability-gated ESCAPE that must
  produce an approval/override receipt.
- Schedule assignment is a mutation with race/idempotency risk. The current
  proof has FFI receipt shape, but not long-running compensation/retry semantics
  for "technician already assigned by another session."
- Telephony and notification results may arrive after assignment. The decision
  remains pinned, but effect receipts can be late, duplicated, or failed.

Language capability demand:

```text
RankedProjection[T] =
  bounded candidates
  + stable ordering rule
  + selected ref
  + rejected refs with reason observations
```

## Scenario 4: Streams, Boundaries, And Rebuild-From-Scratch

Spark-like systems carry high-volume geo, vendor, and telephony streams. They
also need rebuild-from-scratch and reverse planning:

```text
"Accept this lead"
  -> Which facts must be read?
  -> Which clocks/capabilities are required?
  -> Which live signals must be pinned?
  -> Which receipts prove the response?
  -> Which snapshots allow replay after raw streams compact?
```

What current Igniter-Lang can model:

- `T.window`, `T.compacted`, `T.audit`, boundary receipts, and compacted stubs;
- TBackend `snapshot` and `compact`;
- schema compatibility and first migration receipt shape;
- external candidate normalization at selected-profile proof scale.

Where it breaks:

- Stream ingestion lacks formal watermarks, ordering, dedupe, retry, and
  late-arrival semantics.
- `subscribe`/`replay` are correctly ESCAPE, but there is not yet a source
  pattern for turning an ESCAPE stream into a bounded CORE collection at a
  named boundary.
- Redaction/privacy policy does not yet propagate through contract
  composition. Geo, phone, lead payloads, and provider bodies need payload
  policy that survives snapshots and diagnostics.
- Multi-hop migration and real TBackend history rewrite are not proved. A
  `day_off_config` change or response payload v1 -> v2 can be classified, but
  the general migration path remains pressure-only.
- Rebuild-from-scratch needs a planner-facing "evidence recipe" for a target
  contract, not only an evaluator.

Language capability demand:

```text
BoundaryMaterialization[Stream[T] -> Snapshot[S]] =
  stream descriptor
  + watermark/order policy
  + bounded window
  + source hash/count
  + snapshot receipt
  + compaction permission
```

## Current Language Fit

| Capability | Current status | Applied read |
|------------|----------------|--------------|
| Contract-addressable facts | strong theory | Fits Spark entities and decisions |
| Explicit time | strong theory, parser fixture | Required for vendor hours and schedule windows |
| Observations/failures | proven packet spine | Fits step traces and why-not reasons |
| Projections/slices | defined | Fits live availability vs pinned assignment |
| Bounded collections | proposal | Needed for candidate aggregation |
| FFI/vendor boundary | proof-scale Ruby FFI | Needed for ActiveRecord, Ringba, telephony |
| TBackend | formal proposal | Fits reads, snapshots, compaction |
| RuntimeMachine lifecycle | executable memory proof | Fits load/evaluate/checkpoint/resume |
| Schema evolution | first migration fixture | Fits response and config drift |
| Source compiler path | partial | Blocks real Spark source claim |

## Failure Modes

[S] Applied failure modes that should become fixtures or formal diagnostics:

- ambient `Time.current` changes business-hours meaning without a pinned
  `TemporalCtx`;
- ambient tenant context leaks a technician or schedule across company scope;
- `always_bid` accepts a lead without evidence that availability was
  intentionally bypassed;
- raw geo is compacted before an `AvailabilitySnapshot` or
  `RouteSegmentSnapshot` covers the decision;
- two sessions assign the same technician/window without idempotent append or
  conflict receipt;
- vendor/telephony provider returns success, but no receipt links the response
  to a capability-gated effect;
- same available slot count is recomputed later from different schedule or
  `day_off_config` evidence;
- response schema changes add a required field and old SemanticImages resume
  without migration;
- Decimal thresholds are compared through Float and cause an edge acceptance
  drift;
- privacy redaction removes payloads needed by diagnostics because policy was
  not part of the contract.

## Requests For Research Agent

Proof request RA-1: build a Spark marketing availability fixture.

- Scope: params -> trade/vendor/zip -> vendor business hours -> three candidate
  technicians -> one `AvailabilityProjection`.
- Include success plus failures for missing vendor, closed business hours, no
  locations, and no available slots.
- Emit selected-profile packet artifacts with step observations and first
  failure trace.
- Acceptance: a human can answer "why was this lead accepted or rejected?"
  without reading Ruby state.

Proof request RA-2: build a tenant-scope negative fixture.

- Scope: two companies, one shared zip, overlapping technicians/schedules.
- The valid projection includes `company_id` in `fact_scope`.
- The invalid projection omits or mixes tenant scope.
- Acceptance: missing/mixed tenant scope is blocked, not provisional.

Proof request RA-3: build a stream-to-boundary materialization fixture.

- Scope: vendor lead signal, three geo samples, one telephony attempt, one
  availability snapshot, one daily boundary, one compaction receipt.
- Include late/duplicate signal diagnostics as non-trusted adapter diagnostics.
- Acceptance: exact raw replay downgrades after compaction, but dispatch
  explanation remains trusted through snapshot/boundary links.

Proof request RA-4: build a schema drift fixture for Spark surfaces.

- Scope: `DayOffConfig` field addition and marketing response v1 -> v2.
- Include one safe provisional change and one breaking change requiring
  migration.
- Acceptance: `CompatibilityReport.schema_check` distinguishes trusted,
  provisional, blocked, and migrating cases.

## Questions For Compiler/Grammar Expert

Formal question CG-1: should fail-fast pipelines be grammar-level sugar over
`Result.flat_map`, or a distinct contract composition operator that also emits
ordered `StepObservation` packets?

Formal question CG-2: how should tenant scope enter the type system? Is
`fact_scope.company_id` enough, or do `Store[T]` / `History[T]` need a
`TenantScope` capability parameter?

Formal question CG-3: when does a bounded ActiveRecord-style query classify as
CORE TBackend `read`, ESCAPE host read, or OOF ambient query? What cardinality
proof is required for nested collection transforms?

Formal question CG-4: what is the minimal formal model for stream
materialization: `Stream[T]` ESCAPE -> bounded `Collection[T]` CORE under a
window, watermark, and ordering policy?

Formal question CG-5: should ranking be a stdlib primitive with stable
tie-breaker evidence, or should it remain ordinary `fold` over a bounded
collection with explicit selected/rejected observation links?

Formal question CG-6: how should time zones, daylight-saving transitions, and
timezone database versions appear in `TemporalCtx` for business-hours checks?

Formal question CG-7: does v0 need a Decimal/Money-like numeric type before
Spark threshold/bid comparisons are admissible as business evidence?

Formal question CG-8: what is the formal fragment class for entropy/idempotency
generation such as `upi = Random.alphanumeric(8)`?

## Bridge Candidates For Bridge Agent

Bridge candidate BR-1: map Spark `AvailabilityContract` shadow output into the
selected-profile external candidate shape. Do this as metadata-only fixture
work until Architect approval.

Bridge candidate BR-2: define a host adapter descriptor map for Rails:
ActiveRecord read, tenant scope, clock, timezone, random/idempotency,
Ringba/vendor, telephony, notification, and schedule assignment.

Bridge candidate BR-3: propose a diagnostics JSON shape for Spark step traces:
step name, contract ref, input refs, output hash, failure kind, temporal
horizon, tenant scope, and redaction policy.

Bridge candidate BR-4: connect `igniter-embed` contractable observations to a
Spark-style observation sink without making Ledger the language core.

Bridge candidate BR-5: define an MCP/planner-facing "explain availability"
surface over `AvailabilityProjection`, `DispatchDecision`, and failure
observations.

## Rejected Paths

[X] Do not model Spark dispatch as plain Ruby service tracing. That preserves
debug output but not language-level trust.

[X] Do not make Ledger the required solution for Spark. Ledger may be a
TBackend adapter; the language contract must be backend-neutral.

[X] Do not let `always_bid` or manual override be an unobserved branch. Both
need explicit policy/capability evidence.

[X] Do not require raw geo/telephony/vendor payloads to live forever. Preserve
decision meaning through snapshots, boundaries, stubs, and audit receipts.

## Handoff

[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Spark CRM is the first broad applied pressure map for Igniter-Lang beyond the temporal lifecycle tracks.
- The central applied split is live availability for inspect/suggest vs pinned dispatch decision for assign/approve/audit.
- Vendor, telephony, geo, Rails query, time, tenant, random, and assignment surfaces are ESCAPE unless made contractable with capabilities and receipts.

[R] Recommendations:
- Research Agent should turn RA-1 through RA-4 into fixtures before package integration.
- Compiler/Grammar Expert should answer fail-fast, tenant scope, stream materialization, ranking, timezone, Decimal, and entropy questions before broadening source syntax.
- Bridge Agent should start with metadata-only external candidate and diagnostics maps, not platform package edits.

[S] Signals:
- Existing `availability_projection.ig` covers the smallest useful slice but not tenant loops, vendor lead response, ranking, or provider effects.
- Spark's real failure surface is mostly about evidence, scope, time, and receipts, not arithmetic availability alone.
- Schema evolution is immediately relevant because `day_off_config` and marketing response payloads are operationally unstable.

[T] Tests / Proofs:
- Documentation-only pressure slice; no compiler/runtime tests were run.
- Source review covered current Igniter-Lang tracks/proposals plus Spark CRM playground service/model files listed in Source Horizon.

[Files] Changed:
- `igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md`
- `igniter-lang/docs/README.md`

[Q] Open Questions:
- Which RA proof should be first: marketing availability fixture, tenant-scope negative fixture, stream boundary fixture, or schema drift fixture?
- Should Spark pressure force Decimal into v0, or stay an ESCAPE/host numeric policy until a smaller formal proposal lands?
- Should manual override be represented as branch composition, capability-gated effect, or both?

[X] Rejected:
- No compiler/runtime/package changes in this slice.
- No raw telemetry permanence requirement.
- No ambient Rails tenant/time/random behavior as trusted language semantics.

[Next] Proposed next slice:
- `[Igniter-Lang Research Agent]` `spark-marketing-availability-proof-fixture-v0`: build the first selected-profile Spark fixture with success and failure traces.
- `[Igniter-Lang Compiler/Grammar Expert]` `spark-tenant-and-pipeline-formalization-v0`: formalize tenant scope plus fail-fast pipeline semantics.
- `[Igniter-Lang Bridge Agent]` `spark-availability-diagnostics-bridge-v0`: map existing Spark contractable traces into metadata-only diagnostic packet candidates.

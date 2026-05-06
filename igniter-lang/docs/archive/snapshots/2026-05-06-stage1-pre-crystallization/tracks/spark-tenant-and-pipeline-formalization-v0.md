# Track: Spark Tenant and Pipeline Formalization v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/spark-tenant-and-pipeline-formalization-v0
Status: done
Date: 2026-05-06
Resolves: CG-1, CG-2, CG-3 from spark-crm-applied-language-pressure-v0
Depends on: PROP-013, PROP-004, availability_projection.ig

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — receives fixture targets for the
  technician availability and tenant-scope negative proofs (RA-1, RA-2).
- `[Igniter-Lang Bridge Agent]` — receives formal TenantScope descriptor
  shape for metadata-only adapter maps (BR-3).

---

## Question 1: Fail-Fast Pipelines (CG-1)

### Decision

**`[D] Fail-fast pipelines are grammar sugar over `Result.flat_map`,
with an additional mandatory `StepObservation` emission per step.**

They are NOT a distinct contract composition operator.

### Rationale

PROP-013 already defines `Result[T, E]` with `flat_map` semantics.
A fail-fast pipeline is exactly:

```text
step_1(params)
  .flat_map(step_2)
  .flat_map(step_3)
  ...
```

Where each step has type `In -> Result[Out, Err]`.
The first `Err` short-circuits the chain — downstream steps do not execute.

The distinction from plain `flat_map` is observational:

- Each step MUST emit a `StepObservation` before returning.
- A step that does not emit a `StepObservation` is OOF-PL1 (see §OOF).
- The first `Err` pins the trace and the pipeline halts — no downstream
  step observations are emitted.

### PipelineStep definition

```text
PipelineStep[In, Out, Err] = {
  step_id:   String          -- stable identifier, e.g. "find_vendor"
  input:     In
  output:    Result[Out, Err]
  obs:       StepObservation -- emitted before returning
  fragment:  :core | :escape -- never :oof
}

Fragment rule:
  If the step body is pure (CORE input, no TBackend, no FFI) -> :core
  If the step calls TBackend read or FFI                     -> :escape
  If the step calls ambient IO without declaration           -> OOF-PL1
```

### StepObservation definition

```text
StepObservation = Obs[:step_observation, StepRecord]

StepRecord = {
  step_id:       String
  pipeline_id:   String           -- identifies the containing pipeline
  step_index:    Integer          -- 0-based position in pipeline
  status:        :ok | :err
  input_refs:    Collection[ObsId] -- refs to input observations
  output_ref:    ObsId | nil      -- ref to output obs if :ok
  failure_ref:   ObsId | nil      -- ref to failure obs if :err
  temporal:      TemporalCtx
  tenant_scope:  TenantScope | nil
}

lifecycle: :session  (or :audit if step has audit: true on its FFI)
links:
  { rel: "produced_in",   ref: pipeline_session_id }
  { rel: "observed_under", ref: runtime_contract_ref }
  { rel: "caused_by",      ref: previous_step_obs_id } | nil (first step)
```

### First-failure trace semantics

```text
pipeline = [step_1, step_2, step_3]

Execution:
  step_1(params) -> Ok(v1) -> emit StepObservation(step_1, :ok)
  step_2(v1)     -> Err(e) -> emit StepObservation(step_2, :err, failure_ref: e_obs)
  step_3: NOT executed. No StepObservation emitted for step_3.

Trace record:
  PipelineTrace = {
    pipeline_id:       String
    steps_attempted:   [step_1_obs_id, step_2_obs_id]  -- only executed steps
    first_failure_ref: step_2_obs_id
    status:            :failed
    temporal:          TemporalCtx
    tenant_scope:      TenantScope | nil
  }
```

**[D] `PipelineTrace` is emitted as a `platform_observation` at pipeline
completion, regardless of success or failure.**

**[D] The first failure `StepObservation` with `status: :err` is the
canonical "why was this lead rejected" answer.** It must carry
`failure_ref` linking to the `failure_observation`.

### Source syntax (informative; not final grammar)

```text
pipeline VendorLeadIntake[VendorLeadParams, VendorLeadResponse, LeadError] {
  step find_vendor:       validate_and_find_vendor
  step check_hours:       check_business_hours
  step find_geo_bids:     query_geo_bids
  step compute_response:  build_response
}
```

This desugars to nested `flat_map` over `Result` with mandatory
`StepObservation` emission at each step boundary.

**[X] Rejected: distinct `pipeline` operator with separate runtime semantics.**
`Result.flat_map` is the correct primitive. Pipeline is syntactic sugar
plus observation discipline. A new operator would duplicate `Result` semantics
without adding meaning.

---

## Question 2: Tenant Scope in the Type System (CG-2)

### Decision

**`[D] Tenant scope enters as a first-class `TenantScope` value
passed explicitly to `ScopedFactRead` operations and recorded in
`ProjectionHorizon.fact_scope`.**

It is NOT an ambient global. It is NOT a capability parameter on `Store[T]`.
It is a typed value that must be present wherever tenant-scoped reads occur.

### TenantScope definition

```text
TenantScope = {
  company_id:    String          -- required; identifies the tenant
  scope_version: String          -- schema version of the tenant record
  source_ref:    ObsId           -- observation that established this scope
                                 -- (e.g. location lookup result)
  established_at: Timestamp      -- as_of when scope was established
}
```

**[D] `TenantScope.source_ref` is mandatory.** It links the scope to the
observation that proved the company identity. An ambient `company_id`
without a source observation is OOF-TS1.

### ScopedFactRead definition

```text
ScopedFactRead[T] = {
  subject:          String           -- TBackend subject key pattern
  as_of:            Timestamp        -- from TemporalCtx
  tenant_scope:     TenantScope      -- required for tenant-scoped reads
  cardinality_bound: CardinalityBound -- required for CORE classification
  schema_version:   String           -- expected schema version of T
  lifecycle:        LifecycleClass
}

-- The result is:
  Result[Collection[T], ScopedReadError]
  -- Ok: bounded collection at as_of under tenant_scope
  -- Err: scope mismatch, not found, schema mismatch, cardinality exceeded
```

Fragment classification of `ScopedFactRead`:

```text
tenant_scope present AND source_ref valid AND cardinality_bound set:
  -> ESCAPE (reads TBackend; bounded; tenant-safe)

tenant_scope absent OR source_ref absent:
  -> OOF-TS1 (missing tenant scope)

tenant_scope present but source_ref is for a different company_id:
  -> OOF-TS2 (mixed tenant scope)

cardinality_bound absent:
  -> OOF-TS3 (unbounded query)
```

### Why NOT `Store[T, TenantScope]` / `History[T, TenantScope]`

**[D] Parameterizing `Store[T]` with a `TenantScope` is rejected.**

Rationale:
- `Store[T, S]` creates a generic type parameter problem at the language
  level: every store operation becomes polymorphic over scope, which
  requires generics in the type system before they are stable.
- The current v0 grammar handles `TenantScope` as a plain typed value
  in the read declaration. This is simpler, checkable at Pass 0, and
  preserves the `read` keyword semantics.
- `Store[T, TenantScope]` also conflates the storage topology (TBackend)
  with the business authorization concept (tenant). These are separate.

**[D] `fact_scope.company_id` in `ProjectionHorizon` is the CORE
mechanism for recording which tenant a projection was computed under.**

```text
ProjectionHorizon.fact_scope = {
  company_id:   String | nil   -- nil only for cross-tenant projections
  scope_ref:    ObsId | nil    -- the TenantScope.source_ref
  scope_version: String | nil
}
```

A `ProjectionHorizon` with `fact_scope.company_id = nil` is valid ONLY for
cross-tenant aggregate projections that explicitly declare `tenant_free: true`.
Any other nil is OOF-TS1.

### Availability fixture read shape

```text
-- In source (informative):
read technician_profiles: Collection[TechnicianProfile]
  from "technician/{company_id}/{zone}"
  scoped_by company_scope
  cardinality 1..500
  lifecycle :durable

-- Desugars to:
ScopedFactRead[TechnicianProfile] {
  subject:          "technician/{company_id}/{zone}"
  as_of:            ctx.as_of
  tenant_scope:     company_scope       -- must be in scope, not ambient
  cardinality_bound: { min: 1, max: 500 }
  schema_version:   "technician-profile-v1"
  lifecycle:        :durable
}
```

---

## Question 3: CORE vs ESCAPE vs OOF for Nested Queries (CG-3)

### Decision framework

```text
A nested query is CORE-safe if:
  [C-1] Each TBackend read has an explicit as_of.
  [C-2] Each read has a TenantScope with a valid source_ref.
  [C-3] Each read has a statically-bounded cardinality_bound.
  [C-4] The reads form a DAG (no cycles in the read dependency graph).
  [C-5] The fold/map/filter over the result is CORE (PROP-013 TR-1).

A nested query is ESCAPE if:
  [E-1] It has a TenantScope but the scope came from a host FFI call
        (e.g. ActsAsTenant host) rather than a ScopedFactRead.
  [E-2] It reads from a TBackend with eventual consistency (not strong).
  [E-3] It uses an ESCAPE FFI for the inner loop read.

A nested query is OOF if:
  [O-1] It has no TenantScope (OOF-TS1).
  [O-2] It has no cardinality_bound (OOF-TS3).
  [O-3] It reads inside a fold body that itself reads TBackend without
        an explicit as_of (OOF-CB1: unbounded nested read).
  [O-4] The inner read's cardinality depends on the outer loop value
        without a declared bound (OOF-CB2).
```

### Cardinality bound definition

```text
CardinalityBound = {
  min: Integer        -- 0 = optional; >= 1 = required
  max: Integer        -- statically declared upper limit
  source: :declared   -- compiler-visible constant
       | :tbackend    -- TBackend query limit (e.g. LIMIT n)
       | :input       -- bounded by an input port cardinality
}

-- CORE-safe: source = :declared or :tbackend
-- ESCAPE: source = :input (depends on runtime input size)
-- OOF: no CardinalityBound at all
```

### The nested availability loop

The Spark availability pattern loops over locations → companies → technicians:

```text
-- Outer: locations (no tenant scope required; location lookup is cross-tenant)
locations: Collection[Location]
  cardinality 1..200

-- Inner: per company (tenant-scoped)
for each location in locations:
  company_scope = TenantScope {
    company_id:    location.company_id,
    source_ref:    locations_obs.id,
    established_at: ctx.as_of
  }
  technicians: ScopedFactRead[TechnicianProfile]
    scoped_by company_scope
    cardinality 1..500
```

**[D] The outer loop (locations) is CORE-safe if bounded.**
**[D] The inner loop (technicians per company) is ESCAPE** because it
performs a TBackend read inside a fold body. A fold whose body reads
TBackend escalates the fold to ESCAPE (PROP-013 fragment rule: "ESCAPE
if f contains TBackend read").

**[D] The inner read is NOT OOF as long as:**
- TenantScope is present with a valid source_ref
- CardinalityBound is declared
- as_of is from the outer TemporalCtx (same clock, not ambient)

### Cardinality evidence requirement

```text
For a nested query to avoid OOF-CB2:

  The inner read's cardinality_bound must be:
    (a) a statically declared constant, OR
    (b) a TBackend LIMIT that is statically declared in the read declaration.

  It must NOT be:
    (c) derived from the outer item's fields without a declared ceiling.
        Example: cardinality = location.technician_count  -- OOF if unbounded

  If (c): the compiler must find a declared max in the read declaration.
  If no max is declared: OOF-CB2.

[D] The compiler (Pass 1) must verify CardinalityBound.max is present
and is a literal Integer or a declared input port with Integer type.
Dynamic cardinality from a TBackend field is ESCAPE, not CORE.
```

---

## Minimal v0 Type Definitions

### PipelineStep

```text
PipelineStep[In, Out, Err] = Record {
  step_id:      String
  pipeline_id:  String
  step_index:   Integer
  input:        In
  output:       Result[Out, Err]
  obs:          StepObservation
  fragment:     :core | :escape
}
```

### StepObservation

```text
StepObservation = Obs[:step_observation, StepRecord]

StepRecord = Record {
  step_id:       String
  pipeline_id:   String
  step_index:    Integer
  status:        :ok | :err
  input_refs:    Collection[ObsId]
  output_ref:    ObsId | nil
  failure_ref:   ObsId | nil
  temporal:      TemporalCtx
  tenant_scope:  TenantScope | nil
}
lifecycle: :session (default) | :audit (if step.audit = true)
```

### TenantScope

```text
TenantScope = Record {
  company_id:     String
  scope_version:  String
  source_ref:     ObsId       -- mandatory
  established_at: Timestamp
}
```

### ScopedFactRead

```text
ScopedFactRead[T] = Record {
  subject:           String
  as_of:             Timestamp
  tenant_scope:      TenantScope
  cardinality_bound: CardinalityBound
  schema_version:    String
  lifecycle:         LifecycleClass
}
-- returns Result[Collection[T], ScopedReadError]
```

### CardinalityBound

```text
CardinalityBound = Record {
  min:    Integer        -- >= 0
  max:    Integer        -- > 0; statically declared
  source: :declared | :tbackend | :input
}
```

### PipelineTrace

```text
PipelineTrace = Obs[:platform_observation, PipelineTraceRecord]

PipelineTraceRecord = Record {
  pipeline_id:       String
  steps_attempted:   Collection[ObsId]   -- StepObservation ids, in order
  first_failure_ref: ObsId | nil
  status:            :ok | :failed
  temporal:          TemporalCtx
  tenant_scope:      TenantScope | nil
}
lifecycle: :session
links:
  { rel: "produced_in",    ref: session_id }
  { rel: "observed_under", ref: runtime_contract_ref }
```

---

## OOF Rules

```text
OOF-PL1: Step emits no StepObservation.
  A PipelineStep whose body does not emit a StepObservation before returning.
  -> compile error (Pass 0 fragment check: step_obs is required).

OOF-PL2: Downstream step executed after first failure.
  A step after a failed step is executed (no short-circuit).
  -> compile error: pipeline must be sequenced as flat_map chain.

OOF-TS1: Missing TenantScope on a tenant-scoped read.
  A ScopedFactRead without tenant_scope, OR with tenant_scope.source_ref = nil.
  -> compile error (Pass 1: ScopedFactRead validation).
  -> Also applies to ProjectionHorizon.fact_scope.company_id = nil without
     explicit tenant_free: true declaration.

OOF-TS2: Mixed TenantScope.
  A fold body that performs ScopedFactRead with company_id A on items
  that were read under company_id B (where A != B is detectable at compile time).
  -> compile error: tenant scope mismatch in nested read.
  -> If not detectable at compile time: runtime ScopedReadError (not OOF, but
     the read returns Err rather than silently mixing data).

OOF-TS3: Unbounded ScopedFactRead (no CardinalityBound).
  A ScopedFactRead without a declared cardinality_bound.
  -> compile error (Pass 1).

OOF-TS4: Ambient tenant context.
  A read that relies on an ambient host mechanism (e.g. ActsAsTenant.current)
  rather than an explicit TenantScope value.
  -> Pass 0 OOF: ambient host state is Law 6 violation unless declared
     as ESCAPE FFI with a TenantScope-producing receipt.

OOF-CB1: TBackend read inside fold body without explicit as_of.
  A ScopedFactRead inside a fold lambda that does not carry an explicit
  as_of from the enclosing TemporalCtx.
  -> compile error (Pass 1: as_of propagation check).

OOF-CB2: Dynamic cardinality with no declared ceiling.
  A ScopedFactRead whose cardinality_bound.max is derived from a runtime
  field without a declared Integer ceiling in the read declaration.
  -> compile error (Pass 1: cardinality bound must be a literal or declared input).
```

---

## Fixture Targets for Research Agent

### RA-1 target: Technician Availability Fixture

```text
Scope: one company, one technician, one date, one schedule, one off_schedule,
       one day_off_config block.

Required shape:
  1. TenantScope established from a locations read:
       TenantScope { company_id: "company-A", source_ref: locations_obs.id }
  2. ScopedFactRead[TechnicianProfile] scoped_by company_scope
       cardinality 1..50
  3. ScopedFactRead[ScheduleFact] scoped_by company_scope
       cardinality 1..500
  4. ScopedFactRead[OffScheduleBlock] scoped_by company_scope
       cardinality 0..500
  5. DayOffConfigVersion as typed structural input (not untyped JSON)
  6. compute_slots -> AvailabilitySnapshot (reuse availability_projection.ig shape)
  7. StepObservation for each pipeline stage
  8. PipelineTrace linking all step obs

Failure cases:
  F-1: missing TenantScope -> OOF-TS1 blocked at compile time
  F-2: no technicians found (ScopedFactRead returns Err) -> StepObservation(:err)
       -> pipeline halts; first_failure_ref = step 2 obs

Acceptance: A human can read PipelineTrace + StepObservations and answer
"Why was this technician available or unavailable?" without reading host state.
```

### RA-2 target: Tenant-Scope Negative Fixture

```text
Scope: two companies (A and B), one shared zip code, overlapping technicians.

Required shape:
  1. Valid projection: TenantScope { company_id: "company-A" }
       -> ScopedFactRead returns only company-A technicians.
  2. Invalid projection attempt 1: tenant_scope absent
       -> OOF-TS1. Blocked. Not provisional.
  3. Invalid projection attempt 2: tenant_scope.company_id = "company-A"
       but read key references company-B data.
       -> ScopedReadError at read time (Err returned, not silent data leak).

Acceptance: missing and mixed tenant scope are blocked or return Err.
No company-B data appears in company-A projection.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/spark-tenant-and-pipeline-formalization-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: RA-1 and RA-2 fixture targets defined above.
- [Igniter-Lang Bridge Agent]: TenantScope, ScopedFactRead, and
  PipelineTrace shapes available for metadata-only adapter maps (BR-3).

[D] Decisions:
- Fail-fast pipelines are grammar sugar over Result.flat_map with mandatory
  StepObservation per step. No distinct composition operator.
- PipelineTrace is emitted as platform_observation at pipeline completion.
  First failure pins the trace. Downstream steps do not execute.
- TenantScope is a typed value (not a capability parameter, not a Store[T, S]).
  It carries company_id, scope_version, source_ref (mandatory), and established_at.
- ScopedFactRead[T] requires: as_of, tenant_scope, cardinality_bound, schema_version.
  Missing any of these -> OOF at Pass 1.
- fact_scope.company_id in ProjectionHorizon records which tenant a projection
  was computed under. Nil requires explicit tenant_free: true declaration.
- Nested availability loops (locations -> technicians) are ESCAPE, not OOF,
  as long as TenantScope, CardinalityBound, and as_of are all present.
- A fold whose body performs a ScopedFactRead is ESCAPE (PROP-013 rule).
  It is not OOF as long as the three required fields are present.
- CardinalityBound.max must be a literal Integer or a declared input port.
  Dynamic cardinality from a TBackend field -> OOF-CB2.
- 6 OOF rules defined: OOF-PL1/PL2 (pipeline), OOF-TS1/TS2/TS3/TS4
  (tenant scope), OOF-CB1/CB2 (cardinality).
- Store[T, TenantScope] is rejected. TenantScope is a value, not a type
  parameter. Generic Store requires polymorphism before it is stable.

[R] Recommendations:
- Research Agent: implement RA-1 before RA-2. Availability is the clearest
  continuation of the existing fixture set. RA-2 depends on RA-1's TenantScope
  shape being established.
- Do not implement ambient tenant scope detection in the classifier.
  The source must declare the scope explicitly. OOF-TS1 is a compile error,
  not a warning.
- DayOffConfigVersion should be a versioned structural type (TypeDecl with
  schema_version field), not untyped JSON. This is required for
  CompatibilityReport.schema_check to detect shape drift.
- availability_projection.ig can be extended with a TenantScope input port
  rather than creating a new source file. This preserves the existing fixture.

[S] Signals:
- The existing availability_projection.ig is structurally correct but lacks
  TenantScope and CardinalityBound. Adding these as input declarations is
  additive and backward-compatible.
- PipelineStep + StepObservation is the minimal trace that answers
  "why was this lead accepted or rejected?" without Rails state.
- OOF-TS1 (missing tenant scope) being a compile error, not provisional,
  is the key safety property. It prevents ambient tenant leakage from
  ever being "good enough" at the language level.

[T] Tests / Proofs:
- RA-1 fixture: TenantScope established, ScopedFactRead bounded, pipeline
  succeeds, PipelineTrace emitted.
- RA-1 failure F-1: missing TenantScope -> OOF-TS1 at compile time.
- RA-1 failure F-2: no technicians -> Err result -> StepObservation(:err)
  -> PipelineTrace with first_failure_ref set.
- RA-2 fixture: valid projection (company-A only), blocked absent scope,
  ScopedReadError for cross-company read attempt.

[Files] Changed:
- igniter-lang/docs/tracks/spark-tenant-and-pipeline-formalization-v0.md [NEW]
- igniter-lang/docs/README.md [updated]
- igniter-lang/docs/agent-motion.md [updated]

[Q] Open Questions (not blocking v0):
- Q-1: Should TenantScope.source_ref point to the location read obs, or to
  a dedicated "scope establishment" observation? Recommendation: location
  read obs is sufficient. A dedicated scope obs is a later audit refinement.
- Q-2: Should PipelineStep have an explicit schema_version for its output type?
  Recommendation: yes, derived from the ContractDescriptor of the step.
  Deferred to pipeline grammar slice.
- Q-3: Should availability_projection.ig be extended in-place, or should a
  new SparkCRM.TenantAvailability source file be created?
  Recommendation: new file; preserves the existing fixture as a baseline.

[X] Rejected:
- Store[T, TenantScope]: generic type parameter on Store; requires polymorphism
  before stable.
- Ambient tenant scope (ActsAsTenant.current or similar): OOF-TS4; Law 6
  violation unless declared as ESCAPE FFI.
- Distinct pipeline operator: Result.flat_map + StepObservation is sufficient.
  A new operator duplicates semantics without adding meaning.
- Dynamic cardinality from TBackend fields without a declared ceiling: OOF-CB2.
- Treating mixed tenant scope as provisional: it is a compile error (OOF-TS2)
  when detectable, or a ScopedReadError at runtime. Never silently trusted.

[Next] Proposed next slices:
1. [Research Agent]: spark-technician-availability-fixture-v0
   Build RA-1 using TenantScope, ScopedFactRead, PipelineStep shapes above.

2. [Research Agent]: spark-tenant-scope-negative-fixture-v0
   Build RA-2: missing scope -> OOF-TS1; cross-company read -> ScopedReadError.

3. [Compiler/Grammar Expert]: spark-pipeline-grammar-v0
   Define source syntax for pipeline declarations (desugaring to flat_map).
   Extend the PROP-015/016 grammar to include pipeline and scoped_by keywords.
```

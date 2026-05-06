# Track: Spark Pipeline Grammar v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/spark-pipeline-grammar-v0
Status: done
Date: 2026-05-06
Depends on: PROP-014, PROP-015, spark-tenant-and-pipeline-formalization-v0
Resolves: CG-1 (pipeline syntax), CG-2 (scoped_by syntax), CG-3 (cardinality syntax)

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — receives ParsedProgram node shapes and
  SemanticIR pressure notes for the availability fixture proof.
- `[Igniter-Lang Bridge Agent]` — no action until fixture proof is stable.

---

## Guiding Principle

This grammar delta extends PROP-014/PROP-015 with the **minimum new keywords**
needed to express fail-fast pipelines and tenant-scoped reads. It introduces
no new runtime primitives. The desugaring target is already established:
`Result.flat_map` + `StepObservation` + `ScopedFactRead`.

---

## Part 1: Grammar Delta

### 1-A. New keywords and operators

```text
New keywords:
  pipeline  step  scoped_by  cardinality

New modifiers on existing keywords:
  read ... scoped_by <Ref>          -- tenant-scoped TBackend read
  read ... cardinality <Int>..<Int> -- statically-bounded collection read
  read ... tenant_free              -- explicit cross-tenant declaration

New top-level form:
  pipeline <Name>[<InType>, <OutType>, <ErrType>] { ... }

New body form inside pipeline:
  step <Name>: <def_or_contract_ref>
```

### 1-B. Pipeline declaration grammar

```text
PipelineDecl :=
  "pipeline" Name "[" TypeRef "," TypeRef "," TypeRef "]" "{" StepDecl+ "}"

-- Name           : pipeline identifier
-- TypeRef 1      : input type (In)
-- TypeRef 2      : output type (Out)
-- TypeRef 3      : error type (Err)

StepDecl :=
  "step" Name ":" StepRef

StepRef :=
  Name                     -- reference to a def in scope
  | Name "." Name          -- qualified ref (module.def)

-- A StepRef must resolve to a def or contract with signature:
--   (In_i) -> Result[Out_i, Err]
-- where Out_i becomes In_{i+1} for the next step.
```

### 1-C. Scoped read declaration grammar (extension of ReadDecl)

```text
-- Existing ReadDecl from PROP-014:
ReadDecl :=
  "read" Name ":" TypeRef
  "from" StringLit
  "lifecycle" LifecycleAtom

-- Extended ReadDecl (superset; all new clauses are optional except cardinality
-- when the read returns Collection[T]):
ReadDecl :=
  "read" Name ":" TypeRef
  "from" StringLit
  "lifecycle" LifecycleAtom
  ("scoped_by" Ref)?            -- NEW: tenant scope value; Ref resolves to TenantScope
  ("cardinality" IntLit ".." IntLit)?  -- NEW: [min, max] inclusive; required for Collection[T]
  ("schema_version" StringLit)? -- NEW: expected schema version of T
  ("tenant_free")?               -- NEW: explicit cross-tenant marker; suppresses OOF-TS1

LifecycleAtom := ":window" | ":durable" | ":session" | ":local" | ":audit"
```

### 1-D. Full grammar delta (BNF additions to PROP-015 §Grammar)

```text
-- Additions to TopLevelDecl
TopLevelDecl +=
  | PipelineDecl(name, in_type, out_type, err_type, steps)

-- Additions to BodyDecl
BodyDecl +=
  | ScopedReadDecl(name, type_ann, from, lifecycle,
                   scope_ref, cardinality, schema_version, tenant_free)

-- Additions to Stmt (inside def bodies)
-- No new statement forms. Pipelines are only top-level.
```

---

## Part 2: Source Examples

### 2-A. Fail-fast vendor lead intake pipeline

```text
-- VendorLeadPipeline.ig

module SparkCRM.Marketing

import SparkCRM.Types.{ VendorLeadParams, VendorLeadResponse, LeadError }
import SparkCRM.Steps.{
  validate_and_find_vendor,
  check_business_hours,
  query_geo_bids,
  build_response
}

pipeline VendorLeadIntake[VendorLeadParams, VendorLeadResponse, LeadError] {
  step find_vendor:       validate_and_find_vendor
  step check_hours:       check_business_hours
  step find_geo_bids:     query_geo_bids
  step compute_response:  build_response
}
```

### 2-B. Tenant-scoped availability read

```text
-- TenantAvailability.ig

module SparkCRM.Availability

import SparkCRM.Types.{
  TechnicianProfile, ScheduleSlotObservation,
  OffScheduleBlock, DayOffConfigVersion, AvailabilitySnapshot
}

contract TenantAvailabilityProjection {
  input technician_id: String
  input date: String
  input company_scope: TenantScope   -- passed explicitly; not ambient

  escape scoped_tbackend_read

  read technician: TechnicianProfile
    from "technician/{technician_id}"
    lifecycle :durable
    scoped_by company_scope
    cardinality 1..1
    schema_version "technician-profile-v1"

  read schedules: Collection[ScheduleSlotObservation]
    from "schedule/{technician_id}/{date}"
    lifecycle :durable
    scoped_by company_scope
    cardinality 0..500
    schema_version "schedule-slot-v1"

  read off_schedules: Collection[OffScheduleBlock]
    from "off_schedule/{technician_id}/{date}"
    lifecycle :window
    scoped_by company_scope
    cardinality 0..200
    schema_version "off-schedule-v1"

  read day_off_config: DayOffConfigVersion
    from "day_off_config/{technician_id}"
    lifecycle :durable
    scoped_by company_scope
    cardinality 0..1
    schema_version "day-off-config-v1"

  compute available_slots = compute_availability(
    technician, schedules, off_schedules, day_off_config, date
  )

  snapshot snap = build_snapshot(available_slots, technician_id, date)
    lifecycle :durable

  output available_slots: Collection[TimeSlot]  lifecycle :window
  output snap: AvailabilitySnapshot             lifecycle :durable
}
```

### 2-C. Cross-tenant location lookup (tenant_free)

```text
read locations: Collection[Location]
  from "location/{zone}/{zip}"
  lifecycle :durable
  tenant_free
  cardinality 1..200
  schema_version "location-v1"
```

---

## Part 3: ParsedProgram Node Shapes

These extend the `BodyDecl` and `TopLevelDecl` union from PROP-014.

### PipelineDecl node

```json
{
  "kind": "pipeline",
  "name": "VendorLeadIntake",
  "in_type":  "VendorLeadParams",
  "out_type": "VendorLeadResponse",
  "err_type":  "LeadError",
  "steps": [
    { "kind": "step", "name": "find_vendor",      "ref": "validate_and_find_vendor" },
    { "kind": "step", "name": "check_hours",      "ref": "check_business_hours" },
    { "kind": "step", "name": "find_geo_bids",    "ref": "query_geo_bids" },
    { "kind": "step", "name": "compute_response", "ref": "build_response" }
  ]
}
```

### ScopedReadDecl node (extension of ReadDecl)

```json
{
  "kind": "read",
  "name": "schedules",
  "type_annotation": "Collection[ScheduleSlotObservation]",
  "from": "schedule/{technician_id}/{date}",
  "lifecycle": "durable",
  "scoped_by": "company_scope",
  "cardinality": { "min": 0, "max": 500 },
  "schema_version": "schedule-slot-v1",
  "tenant_free": false
}
```

### ParsedProgram union extensions

```text
TopLevelDecl +=
  | PipelineDecl {
      name:     String
      in_type:  String     -- type annotation string
      out_type: String
      err_type: String
      steps:    [StepDecl]
    }

StepDecl = {
  name: String
  ref:  String    -- resolved at Classify; may be "module.fn" or "fn"
}

BodyDecl (ReadDecl extended) +=
  scoped_by:      String | nil    -- Ref name; nil = no scope
  cardinality:    { min: Int, max: Int } | nil
  schema_version: String | nil
  tenant_free:    Bool            -- default false
```

---

## Part 4: Classification Path (Pass 0)

### Pipeline classification

```text
For each PipelineDecl:
  1. Resolve each StepDecl.ref to a DefDecl in scope.
  2. Check step signature chain:
       step_i returns Result[Out_i, Err]
       step_{i+1} input must match Out_i
       -> type mismatch: OOF-PG1 (pipeline step type mismatch)
  3. Each step inherits fragment_class of its referenced def:
       any step is ESCAPE -> pipeline fragment_class = ESCAPE
       all steps are CORE -> pipeline fragment_class = CORE
  4. Record as ClassifiedPipeline with steps ordered by index.
  5. Tag each step with step_index (0-based).
```

### ScopedReadDecl classification

```text
For each ScopedReadDecl:
  1. If type_annotation contains "Collection[T]":
       cardinality must be present -> else OOF-TS3
       fragment_class: ESCAPE (reads TBackend with bounded collection)
  2. If scoped_by is present:
       resolve scoped_by ref -> must be type TenantScope in scope
       if not resolvable: OOF-PG2 (unresolved scope ref)
       mark as ScopedRead(scope_ref)
  3. If tenant_free = true AND scoped_by present:
       OOF-PG3 (conflicting tenant declarations)
  4. If tenant_free = false AND scoped_by absent:
       -> OOF-TS1 (missing tenant scope)
       UNLESS the enclosing contract declares tenant_free at contract level
  5. schema_version: if absent, emit warning; not a compile error in v0.
  6. escape_set: ScopedRead implicitly uses "scoped_tbackend_read" escape.
       The enclosing contract must declare this escape or be escalated to ESCAPE.
```

---

## Part 5: SemanticIR Lowering

### Pipeline → SemanticIR

```text
PipelineDecl lowers to a PipelineContractIR:

PipelineContractIR = {
  contract_id:    "module.PipelineName"
  kind:           :pipeline
  fragment_class: :core | :escape
  in_type:        TypeTag
  out_type:       TypeTag
  err_type:       TypeTag
  steps: [
    {
      step_id:      "pipeline_id/step_name"
      step_index:   Integer
      def_ref:      "module.def_name"    -- resolved operator
      fragment:     :core | :escape
    }
  ]
  -- Desugaring note (not in IR; conceptual only):
  -- execute = steps.reduce(Ok(input)) { |acc, step|
  --   acc.flat_map { |v|
  --     emit_step_obs(step, v)
  --     step.def_ref.call(v)
  --   }
  -- }
  -- emit PipelineTrace at end
}
```

**[D] Pipeline is not a callable contract in the normal sense.** It is a
composition descriptor. The RuntimeMachine executes it as a sequenced
flat_map chain. The IR carries the step list; the evaluator owns the loop.

### ScopedReadDecl → SemanticIR

```text
ScopedReadDecl lowers to a ScopedTBackendReadNode:

ScopedTBackendReadNode = {
  node_id:           String
  name:              String
  type_tag:          TypeTag
  subject_template:  String
  lifecycle:         LifecycleClass
  scope_ref:         String | nil       -- name of TenantScope input
  cardinality:       { min: Int, max: Int } | nil
  schema_version:    String | nil
  tenant_free:       Bool
  fragment:          :escape            -- always ESCAPE for TBackend reads
}
```

The existing plain `ReadDecl` lowers to a plain `TBackendReadNode` (PROP-014).
`ScopedReadDecl` lowers to the extended form above.

---

## Part 6: OOF Rules

```text
OOF-PG1: Pipeline step type mismatch.
  step_i output type Out_i does not match step_{i+1} input type.
  -> Classify error (Pass 0 step chain type check).

OOF-PG2: Unresolved scope ref in scoped_by.
  scoped_by "company_scope" but no binding named company_scope is in scope
  (not an input port, not a read result).
  -> Classify error (Pass 0 ref resolution).

OOF-PG3: Conflicting tenant declarations.
  scoped_by present AND tenant_free present on the same ReadDecl.
  -> Parse error (mutually exclusive; caught at Parse stage).

OOF-PG4: Step ref not a def.
  StepDecl.ref resolves to a ContractDecl rather than a DefDecl.
  In v0, pipeline steps must be def-level functions, not contracts.
  -> Classify error.

OOF-PG5: Pipeline with zero steps.
  A pipeline declaration with no step declarations.
  -> Parse error.

OOF-TS1: Missing tenant scope (carried from formalization-v0).
  A ScopedReadDecl with tenant_free=false and scoped_by=nil.
  -> Classify error (OOF-TS1; previously defined).

OOF-TS3: Missing cardinality on Collection[T] read.
  A ScopedReadDecl or ReadDecl whose type_annotation is Collection[T]
  but carries no cardinality clause.
  -> Classify error (OOF-TS3; previously defined).

OOF-CB2: Dynamic cardinality (carried from formalization-v0).
  cardinality max derived from a runtime field without a declared literal.
  -> In grammar: cardinality clause requires two IntLit; any non-literal
     expression is a parse/classify error.
```

---

## Part 7: SemanticIR Pressure Notes for Research Agent

The Research Agent availability fixture (`spark-technician-availability-fixture-v0`)
should target this SemanticIR shape:

### Contract node shape

```json
{
  "contract_id": "SparkCRM.Availability.TenantAvailabilityProjection",
  "fragment_class": "escape",
  "escape_set": ["scoped_tbackend_read"],
  "input_ports": [
    { "name": "technician_id", "type_tag": "String",      "lifecycle": "local" },
    { "name": "date",          "type_tag": "String",      "lifecycle": "local" },
    { "name": "company_scope", "type_tag": "TenantScope", "lifecycle": "local" }
  ],
  "read_nodes": [
    {
      "node_id": "node_technician",
      "name": "technician",
      "type_tag": "TechnicianProfile",
      "subject_template": "technician/{technician_id}",
      "lifecycle": "durable",
      "scope_ref": "company_scope",
      "cardinality": { "min": 1, "max": 1 },
      "schema_version": "technician-profile-v1",
      "tenant_free": false,
      "fragment": "escape"
    },
    {
      "node_id": "node_schedules",
      "name": "schedules",
      "type_tag": "Collection[ScheduleSlotObservation]",
      "subject_template": "schedule/{technician_id}/{date}",
      "lifecycle": "durable",
      "scope_ref": "company_scope",
      "cardinality": { "min": 0, "max": 500 },
      "schema_version": "schedule-slot-v1",
      "tenant_free": false,
      "fragment": "escape"
    }
  ],
  "compute_nodes": [
    {
      "node_id": "node_available_slots",
      "name": "available_slots",
      "type_tag": "Collection[TimeSlot]",
      "lifecycle": "window",
      "expression": {
        "kind": "apply",
        "operator": "user.SparkCRM.Availability.compute_availability",
        "operands": [
          { "kind": "ref", "name": "technician" },
          { "kind": "ref", "name": "schedules" },
          { "kind": "ref", "name": "off_schedules" },
          { "kind": "ref", "name": "day_off_config" },
          { "kind": "ref", "name": "date" }
        ]
      }
    }
  ],
  "output_ports": [
    { "name": "available_slots", "type_tag": "Collection[TimeSlot]",   "lifecycle": "window" },
    { "name": "snap",            "type_tag": "AvailabilitySnapshot",   "lifecycle": "durable" }
  ]
}
```

### StepObservation packet shape (for pipeline fixture)

```json
{
  "kind": "step_observation",
  "payload": {
    "step_id":      "VendorLeadIntake/find_vendor",
    "pipeline_id":  "SparkCRM.Marketing.VendorLeadIntake",
    "step_index":   0,
    "status":       "err",
    "input_refs":   ["obs/vendor_lead_params/..."],
    "output_ref":   null,
    "failure_ref":  "obs/failure/find_vendor/...",
    "temporal":     { "as_of": "2026-05-06T10:00:00Z" },
    "tenant_scope": null
  },
  "lifecycle": "session",
  "links": [
    { "rel": "produced_in",    "ref": "session/..." },
    { "rel": "observed_under", "ref": "runtime_contract/..." }
  ]
}
```

### Negative fixture: OOF-TS1 at classify time

When `company_scope` input is absent from the contract and `scoped_by
company_scope` appears on a read declaration, the classifier must emit:

```json
{
  "code": "OOF-TS1",
  "message": "ScopedFactRead missing tenant_scope: scoped_by ref 'company_scope' not in scope",
  "node": "node_technician",
  "stage": "classify"
}
```

This is a compile-time error, not a runtime failure observation.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/spark-pipeline-grammar-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: ParsedProgram node shapes (§Part 3) and
  SemanticIR pressure notes (§Part 7) are the implementation targets for
  spark-technician-availability-fixture-v0.
- [Igniter-Lang Bridge Agent]: ScopedReadDecl and StepObservation packet
  shapes are available for BR-3 (availability diagnostics adapter map).

[D] Decisions:
- pipeline keyword is a top-level declaration, not a contract modifier.
  Desugars to flat_map chain at evaluator level; does not introduce a new
  runtime primitive.
- step keyword names a pipeline step and references a def. Steps must
  be defs, not contracts (OOF-PG4), in v0.
- scoped_by clause on ReadDecl accepts a Ref to a TenantScope value
  in scope. It is NOT a capability parameter.
- cardinality clause is two IntLit (min..max). Both must be literal
  integers. Dynamic cardinality from runtime fields -> OOF-CB2 at parse.
- tenant_free is a marker; mutually exclusive with scoped_by (OOF-PG3).
- ScopedReadDecl always has fragment_class: ESCAPE (reads TBackend).
  The escape name is "scoped_tbackend_read"; the enclosing contract
  must declare it or be escalated to ESCAPE.
- schema_version on ReadDecl is informational in v0; absent = warning.
  Future: absent on durable reads = OOF when schema evolution is active.
- 7 OOF rules defined (OOF-PG1/2/3/4/5, OOF-TS1/3 carried from
  formalization-v0).
- Plain ReadDecl (PROP-014) is unchanged. ScopedReadDecl is a superset.
  Existing availability_projection.ig remains valid as written.

[R] Recommendations:
- Research Agent: the fixture proof does not need to parse source syntax.
  Use hand-authored ParsedProgram JSON matching §Part 3 shapes, then
  classify and produce SemanticIR. Parser acceptance of the new keywords
  is a separate later slice (like polymorphic-add-parser-acceptance-v0).
- Do not add scoped_by to the parser until the fixture proof validates
  the SemanticIR lowering. Grammar before fixture = wasted effort.
- When adding pipeline to the parser lexer: add "pipeline", "step",
  "scoped_by", "cardinality", "tenant_free" to the keyword table.
  No identifier character changes needed (all use existing [a-z_]).

[S] Signals:
- The grammar delta is minimal: 4 new keywords, 3 new clauses on ReadDecl,
  1 new top-level form. This is consistent with the PROP-015 philosophy
  of extending the minimum surface to make fixtures expressible.
- TenantAvailabilityProjection.ig (§2-B) is the primary source target for
  the Research Agent availability fixture. It is close to availability_projection.ig
  but adds TenantScope input, scoped_by clauses, and cardinality bounds.
- OOF-PG4 (step ref must be a def, not a contract) is important: it keeps
  the pipeline composition model flat. Contract-to-contract composition is
  a separate abstraction (PROP-002 contract algebra).

[T] Tests / Proofs:
- Parse acceptance (later slice): pipeline/step/scoped_by/cardinality keywords
  parse without error for §2-A and §2-B source examples.
- Classify positive: ScopedReadDecl with scoped_by company_scope resolves
  correctly; fragment_class = escape; escape_set = ["scoped_tbackend_read"].
- Classify negative OOF-TS1: scoped_by absent, tenant_free absent ->
  OOF-TS1 classify error.
- Classify negative OOF-TS3: Collection[T] read with no cardinality ->
  OOF-TS3 classify error.
- Classify negative OOF-PG1: step type mismatch in pipeline ->
  OOF-PG1 classify error.
- SemanticIR: ScopedTBackendReadNode present with scope_ref and cardinality.
  PipelineContractIR present with steps array ordered by index.

[Files] Changed:
- igniter-lang/docs/tracks/spark-pipeline-grammar-v0.md  [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Q] Open Questions (not blocking Research Agent):
- Q-1: Should pipeline steps be allowed to reference contracts (not just defs)?
  Recommendation: no in v0. Contract-level step composition requires contract
  algebra (PROP-002) to be revisited. Defs are sufficient for Spark steps.
- Q-2: Should schema_version absence be a warning or error for durable reads?
  Recommendation: warning in v0; error when PROP-017 schema_check is active.
- Q-3: Should ScopedReadDecl require an explicit escape declaration on the
  enclosing contract, or auto-escalate silently?
  Recommendation: auto-escalate with a warning. Silent ESCAPE escalation is
  already the rule for ReadDecl (PROP-014 §Classification Path).

[X] Rejected:
- Pipeline as a distinct runtime primitive. flat_map + StepObservation
  is the desugar target; no new evaluator construct.
- scoped_by as a capability parameter on Store[T]/History[T].
  TenantScope is a value, not a type parameter (formalization-v0 decision).
- Dynamic cardinality expressions. cardinality clause is two IntLit only.
- Pattern matching or guard expressions inside pipeline steps. Steps are
  def refs; branching lives inside the def body.
- tenant_free as a contract-level flag (only on individual ReadDecls).
  A contract that mixes scoped and cross-tenant reads must declare each
  explicitly. No blanket contract-level override.

[Next] Proposed next slices:
1. [Research Agent]: spark-technician-availability-fixture-v0
   Use hand-authored ParsedProgram JSON (§Part 3 shapes) to implement
   classifier and SemanticIR lowering. Do not parse source syntax yet.

2. [Compiler/Grammar Expert]: spark-pipeline-parser-acceptance-v0
   Add pipeline/step/scoped_by/cardinality to the parser grammar and lexer.
   Target: source examples §2-A and §2-B parse without error.
   Prerequisite: Research Agent fixture proof passing.

3. [Research Agent]: spark-tenant-scope-negative-fixture-v0
   Implement RA-2 (missing/mixed tenant scope -> OOF-TS1/ScopedReadError).
```

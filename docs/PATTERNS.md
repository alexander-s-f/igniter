# Igniter Patterns

This document collects recommended orchestration shapes that already have runnable examples in the repository.

The goal is not to introduce new primitives, but to show how the existing DSL composes into readable contracts.

## 1. Linear Derivation

Use this when the flow is a straight dependency chain with no routing or fan-out.

Example:

- [basic_pricing.rb](/Users/alex/dev/hotfix/igniter/examples/basic_pricing.rb)

Use:

- pricing
- totals
- normalization pipelines
- simple business formulas

Shape:

```ruby
input :order_total
input :country

compute :vat_rate, with: :country do |country:|
  country == "UA" ? 0.2 : 0.0
end

compute :gross_total, with: %i[order_total vat_rate] do |order_total:, vat_rate:|
  order_total * (1 + vat_rate)
end

output :gross_total
```

## 2. Stage Composition

Use this when one contract should orchestrate several bounded subgraphs.

Examples:

- [composition.rb](/Users/alex/dev/hotfix/igniter/examples/composition.rb)
- [ringcentral_routing.rb](/Users/alex/dev/hotfix/igniter/examples/ringcentral_routing.rb)

Use:

- reusable business stages
- transport shell + domain pipeline
- larger flows with clear internal boundaries

Guideline:

- keep the parent contract thin
- export child outputs explicitly
- read child diagnostics from the child execution, not from the parent by default

## 3. Scoped Domain Flow

Use this when the graph is still one contract, but a flat node list becomes hard to read.

Example:

- [marketing_ergonomics.rb](/Users/alex/dev/hotfix/igniter/examples/marketing_ergonomics.rb)

Use:

- routing
- validation
- pricing
- response shaping

Shape:

```ruby
scope :routing do
  map :trade_name, from: :service do |service:|
    ...
  end
end

namespace :validation do
  guard :zip_supported, with: :zip_code, in: %w[60601 10001], message: "Unsupported zip"
end
```

Guideline:

- use `scope` and `namespace` for readability first
- do not treat them as runtime boundaries

## 4. Declarative Routing

Use this when control flow depends on a selector value and should stay visible in the graph.

Examples:

- [ringcentral_routing.rb](/Users/alex/dev/hotfix/igniter/examples/ringcentral_routing.rb)

Use:

- vendor routing
- status routing
- country-specific flows
- mode-specific processing

Shape:

```ruby
branch :status_route, with: :telephony_status, inputs: {
  extension_id: :extension_id,
  telephony_status: :telephony_status,
  active_calls: :active_calls
} do
  on "CallConnected", contract: CallConnectedContract
  on "NoCall", contract: NoCallContract
  default contract: UnknownStatusContract
end
```

Guideline:

- keep branch contracts on a shared input interface
- let compile-time validation force interface consistency
- use explicit `export` from the branch node

## 5. Fan-Out With Stable Identity

Use this when a node should run the same child contract for many item inputs.

Examples:

- [collection.rb](/Users/alex/dev/hotfix/igniter/examples/collection.rb)
- [collection_partial_failure.rb](/Users/alex/dev/hotfix/igniter/examples/collection_partial_failure.rb)
- [ringcentral_routing.rb](/Users/alex/dev/hotfix/igniter/examples/ringcentral_routing.rb)

Use:

- technicians
- calls
- locations
- vendors
- external records

Shape:

```ruby
collection :technicians,
  with: :technician_inputs,
  each: TechnicianContract,
  key: :technician_id,
  mode: :collect
```

Guideline:

- feed `collection` an array of item input hashes
- choose a stable `key:`
- keep item logic in the child contract, not in a giant parent `compute`

## 6. Partial Failure Without Failing The Whole Execution

Use `mode: :collect` when you want item-level failures surfaced, but not promoted to parent execution failure.

Example:

- [collection_partial_failure.rb](/Users/alex/dev/hotfix/igniter/examples/collection_partial_failure.rb)

What to read:

- `result.summary`
- `result.items_summary`
- `result.failed_items`
- `contract.diagnostics_text`
- `contract.diagnostics_markdown`

Guideline:

- parent execution can still be `succeeded`
- collection summary may be `:partial_failure`
- diagnostics should be read at collection level, not only at execution status level

## 7. Nested Branch + Collection

Use this when routing chooses a stage, and that stage performs fan-out or per-item routing.

Example:

- [ringcentral_routing.rb](/Users/alex/dev/hotfix/igniter/examples/ringcentral_routing.rb)

Observed semantics:

- parent execution records top-level `branch_selected`
- collection item events belong to the selected child execution
- child diagnostics is usually the best place to inspect collection status

Guideline:

- inspect parent audit for high-level routing
- inspect child audit for item-level fan-out behavior

## 8. Async Resume Flow

Use this when a node cannot complete immediately and should suspend the execution.

Example:

- [async_store.rb](/Users/alex/dev/hotfix/igniter/examples/async_store.rb)

Use:

- external jobs
- long-running enrichment
- async pricing or classification

Guideline:

- model the slow step as a deferred node
- resume with store-backed execution restore
- keep downstream graph pure and resumable

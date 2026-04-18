# Branches v1

## Goal

`branch` introduces explicit conditional routing as a graph primitive.

The feature should make control flow:

- declarative
- visible at compile time
- visible in graph introspection
- visible in runtime diagnostics and events

It should avoid pushing routing logic into generic `compute` blocks or executors.

## DSL

### Basic form

```ruby
branch :delivery_strategy, with: :country do
  on "US", contract: USDeliveryContract
  on "UA", contract: LocalDeliveryContract
  default contract: DefaultDeliveryContract
end
```

### Exporting outputs

```ruby
branch :delivery_strategy, with: :country do
  on "US", contract: USDeliveryContract
  on "UA", contract: LocalDeliveryContract
  default contract: DefaultDeliveryContract
end

export :price, :eta, from: :delivery_strategy
```

### Nested result

```ruby
output :delivery_strategy
```

This should return a child result object, similar to composition.

## Why `default` and not `else`

`default` is preferred because:

- it is valid Ruby DSL syntax
- it is not a reserved keyword
- it reads clearly as a fallback branch
- it serializes more cleanly into schema-driven representations

## Scope of v1

Branches v1 should stay intentionally narrow.

Supported:

- exact-match branch selection
- `eq:` matcher shorthand
- `in:` membership matching
- `matches:` regexp matching
- one selector dependency
- child contracts as branch targets
- explicit fallback through `default`
- branch result as a composition-like nested result
- `export` from the selected branch

Not supported in v1:

- predicate lambdas
- multiple selectors
- executor targets
- node-level arbitrary targets
- implicit output merging

## Runtime Semantics

1. Resolve the selector dependency.
2. Match the selector value against declared `on` cases in order.
3. If no case matches, use `default`.
4. Instantiate and resolve the selected child contract.
5. Mark the branch node as succeeded only after the selected child contract succeeds.

If the selected child contract fails, the branch node fails.

Unselected branches must not execute.

Case matching remains ordered. The first matching `on` clause wins, so more specific
cases should appear before broader ones.

Matcher forms:

```ruby
branch :delivery_strategy, with: :country do
  on "US", contract: USDeliveryContract
  on in: %w[CA MX], contract: NorthAmericaContract
  on matches: /\A[A-Z]{2}\z/, contract: InternationalContract
  default contract: DefaultDeliveryContract
end
```

## Compile-Time Validation

The compiler should validate:

- branch name uniqueness
- selector dependency existence
- at least one `on` case
- exactly one `default`
- unique exact values across `on` and `in:` cases
- each case has a valid contract
- the default has a valid contract
- `in:` uses a non-empty array
- `matches:` uses a regexp
- exported outputs exist across all possible branch contracts

The last point is important:

If the contract exports `price` from a branch, then every possible branch contract must expose `price`.

## Result Semantics

The branch node should behave similarly to composition:

- nested result available via `output :branch_name`
- child outputs re-exportable through `export`

This keeps branch consistent with the existing composition mental model.

## Graph Model

Branches v1 should introduce a dedicated node kind:

- `:branch`

Suggested internal shape:

```ruby
BranchNode.new(
  name: :delivery_strategy,
  selector: :country,
  cases: [
    { match: "US", contract: USDeliveryContract },
    { match: "UA", contract: LocalDeliveryContract }
  ],
  default_contract: DefaultDeliveryContract
)
```

This should not be modeled as a normal compute node.

## Events

Branches v1 should add a specific runtime event:

- `branch_selected`

Suggested payload:

```ruby
{
  selector: :country,
  selector_value: "US",
  matcher: :eq,
  matched_case: "US",
  selected_contract: "USDeliveryContract"
}
```

This should improve observability and diagnostics without forcing users to infer branch choice from child execution state.

## Introspection

### Graph text / Mermaid

Branch nodes should render distinctly from compute and composition nodes.

The graph should show:

- selector dependency
- available branch cases
- default contract

### Plan

Before execution:

- branch node is blocked on selector resolution
- available branches are visible as candidates

After execution:

- selected branch is visible in runtime state or diagnostics

### Diagnostics

Diagnostics should surface:

- selector value
- selected branch case
- selected child contract

## Error Model

Suggested runtime error:

- `Igniter::BranchSelectionError`

Used for:

- invalid branch configuration reaching runtime
- missing match if a branch somehow has no `default`

In a well-validated graph, this error should be rare.

## Future Extensions

Possible later additions:

- predicate matching
- branch-to-executor targets
- schema-driven branch authoring
- branch-aware collections

These should not be part of v1.

# Examples

These scripts are intended to be runnable entry points for new users.
Each one can be executed directly from the project root with `ruby examples/<name>.rb`.
For higher-level guidance on when to use each style, see [PATTERNS.md](/Users/alex/dev/hotfix/igniter/docs/PATTERNS.md).

## Available Scripts

### `basic_pricing.rb`

Run:

```bash
ruby examples/basic_pricing.rb
```

Shows:

- defining a basic contract
- lazy output resolution through `result`
- selective recomputation after `update_inputs`

Expected output:

```text
gross_total=120.0
updated_gross_total=180.0
```

### `composition.rb`

Run:

```bash
ruby examples/composition.rb
```

Shows:

- nested contracts through `compose`
- returning child results through an output
- serializing composed output values with `result.to_h`

Expected output:

```text
pricing={:pricing=>{:gross_total=>120.0}}
```

### `diagnostics.rb`

Run:

```bash
ruby examples/diagnostics.rb
```

Shows:

- diagnostics text summary
- machine-readable `result.as_json`
- execution state visibility after a successful run

Expected output shape:

```text
Diagnostics PriceContract
Execution <uuid>
Status: succeeded
Outputs: gross_total=120.0
...
---
{:graph=>"PriceContract", ...}
```

### `async_store.rb`

Run:

```bash
ruby examples/async_store.rb
```

Shows:

- deferred executor output through `defer`
- file-backed pending execution store
- restore and resume flow through `resume_from_store`

Expected output shape:

```text
pending_token=quote-100
stored_execution_id=<uuid>
pending_status=true
resumed_gross_total=180.0
```

### `marketing_ergonomics.rb`

Run:

```bash
ruby examples/marketing_ergonomics.rb
```

Shows:

- ergonomic helpers `with`, `const`, `lookup`, `map`, matcher-style `guard`, `expose`
- success-side-effect shorthand via `on_success`
- structural grouping via `scope` and `namespace`
- pre-execution planning via `contract.explain_plan`
- a domain-style contract that stays compact without hiding the graph

Expected output shape:

```text
Plan MarketingQuoteContract
Targets: quote
...
---
response={:vendor_id=>"eLocal", :trade=>"HVAC", :zip_code=>"60601", :bid=>45.0}
outbox=[{:vendor_id=>"eLocal", :zip_code=>"60601"}]
```

### `collection.rb`

Run:

```bash
ruby examples/collection.rb
```

Shows:

- declarative fan-out via `collection`
- stable item identity via `key:`
- `CollectionResult` output surface
- per-item child contract results in `:collect` mode

Expected output shape:

```text
keys=[1, 2]
items={1=>{:key=>1, :status=>:succeeded, ...}, 2=>{:key=>2, :status=>:succeeded, ...}}
```

### `collection_partial_failure.rb`

Run:

```bash
ruby examples/collection_partial_failure.rb
```

Shows:

- `collection` in `mode: :collect`
- `CollectionResult#summary`
- `CollectionResult#items_summary`
- `CollectionResult#failed_items`
- diagnostics output for partial collection failure without failing the whole execution

Expected output shape:

```text
summary={:mode=>:collect, :total=>3, :succeeded=>2, :failed=>1, :status=>:partial_failure}
items_summary={1=>{:status=>:succeeded}, 2=>{:status=>:failed, ...}, ...}
failed_items={2=>{:type=>"Igniter::ResolutionError", ...}}
```

### `ringcentral_routing.rb`

Run:

```bash
ruby examples/ringcentral_routing.rb
```

Shows:

- top-level routing via `branch`
- nested fan-out via `collection`
- per-item nested routing via another `branch`
- `CollectionResult` summary on the selected child contract
- the practical boundary between parent diagnostics and child diagnostics

Expected output shape:

```text
Plan RingcentralWebhookContract
...
---
routing_summary={:extension_id=>62872332031, ...}
status_route_branch=CallConnected
child_collection_summary={:mode=>:collect, :total=>3, ...}
```

## Validation

These scripts are exercised by [example_scripts_spec.rb](/Users/alex/dev/hotfix/igniter/spec/igniter/example_scripts_spec.rb), so the documented commands and outputs stay aligned with the code.

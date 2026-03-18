# Examples

These scripts are intended to be runnable entry points for new users.
Each one can be executed directly from the project root with `ruby examples/<name>.rb`.

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

## Validation

These scripts are exercised by [example_scripts_spec.rb](/Users/alex/dev/hotfix/igniter/spec/igniter/example_scripts_spec.rb), so the documented commands and outputs stay aligned with the code.

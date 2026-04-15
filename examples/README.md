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
- trivial field extraction via `project`
- compact summary building via `aggregate`
- item input shaping via `collection map_inputs:` or `using:`
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

### `order_pipeline.rb`

Run:

```bash
ruby examples/order_pipeline.rb
```

Shows:

- `guard` — abort early when a precondition is not met
- `collection` — fan-out via `LineItemContract` per line item
- `branch` — route to domestic or international shipping strategy
- `export` — lift branch outputs (`shipping_cost`, `eta`) to the parent graph
- end-to-end pipeline: items → subtotal → shipping → grand total

Expected output shape:

```text
=== US Order ===
items_summary={:mode=>:collect, :total=>3, :succeeded=>3, :failed=>0, :status=>:succeeded}
order_subtotal=199.96
shipping_cost=0.0
eta=2-3 business days
grand_total=199.96

=== International Order (DE) ===
shipping_cost=29.99
eta=7-14 business days
grand_total=229.95

=== Out of Stock ===
error=Order cannot be placed: items are out of stock
```

### `distributed_server.rb`

Run:

```bash
ruby examples/distributed_server.rb
```

Shows:

- `correlate_by` — tag a contract class with correlation keys
- `Contract.start` — launch an execution that suspends at `await` nodes
- `Contract.deliver_event` — resume a suspended execution with an event payload
- `on_success` — callback that fires when the graph completes
- full lifecycle: submit → screening event → manager event → decision

Expected output shape:

```text
=== Step 1: Application submitted ===
pending=true
waiting_for=[:screening_completed]

=== Step 2: Background screening completed ===
still_pending=true

=== Step 3: Manager review completed ===
[callback] Decision reached: HIRED

=== Final result ===
success=true
decision={:status=>:hired, :note=>"Excellent system design skills"}
```

### `llm/tool_use.rb`

Run:

```bash
ruby examples/llm/tool_use.rb
```

Shows:

- chained LLM compute nodes (`classify → assess priority → draft response`)
- tool declaration with the class-level `tools` method
- conversation context with `Igniter::AI::Context` for multi-turn messages
- mock provider so the example runs offline without an API key

Expected output shape (with mock provider):

```text
=== Feedback Triage Pipeline ===
category=category: bug_report
priority=priority: high
response=We have logged this issue and will address it in the next release.

--- Diagnostics ---
...
```

### `agents.rb`

Run:

```bash
ruby examples/agents.rb
```

Shows:

- `Igniter::Agent` — stateful message-driven actor with `on` handlers and `schedule` timers
- `Igniter::Supervisor` — one_for_one supervision with restart budget
- `Igniter::Registry` — thread-safe lookup by name
- `Igniter::StreamLoop` — continuous contract tick-loop with hot-swap inputs

Expected output shape:

```text
=== Supervised agents ===
counter=8
after_reset=10
history=[10]

=== Registry lookup ===
named_counter=42

=== Stream loop ===
statuses_sample=[:alert, :normal]

log_entries=1
done=true
```

### `companion/bin/demo`

Run:

```bash
ruby examples/companion/bin/demo
```

Shows:

- `Igniter::Workspace` — root coordinator for `apps/*`
- `Igniter::App` — leaf apps under `apps/main` and `apps/inference`
- workspace-shaped voice assistant demo
- local end-to-end ASR → Intent → Chat → TTS pipeline using mock executors

### `companion_legacy/bin/demo`

Run:

```bash
ruby examples/companion_legacy/bin/demo
```

Shows:

- `Igniter::App` — unified entry point with `config_file`, `configure`, `register`, `schedule`
- `compose` + `export` — four-stage pipeline (ASR → Intent → Chat → TTS) wired as one graph
- Mock executors — runs end-to-end without hardware or API keys
- Turn-by-turn interactive loop with session history

For real Ollama inference:

```bash
COMPANION_REAL_LLM=1 ruby examples/companion_legacy/bin/demo
```

Expected output per turn:

```text
── Turn 1 ────────────────────────────────────────────
  [ASR mock]    → "Hello, are you there?"
  [Intent mock] → question
  [Chat mock]   → "I'd need a moment to look that up..."
  [TTS mock]    → synthesising 76 chars
  Heard:    "Hello, are you there?"
  Intent:   question (92%)
  Response: "I'd need a moment to look that up..."
  Audio:    4328 chars (Base64 WAV)
```

See [`companion/README.md`](companion/README.md) for the workspace layout and ESP32 firmware, and [`companion_legacy/README.md`](companion_legacy/README.md) for the older flat-layout deployment notes.

## Validation

These scripts are exercised by [example_scripts_spec.rb](/Users/alex/dev/hotfix/igniter/spec/igniter/example_scripts_spec.rb), so the documented commands and outputs stay aligned with the code.

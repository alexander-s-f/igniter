# Distributed Consensus with Igniter — v1

`require "igniter/consensus"` provides a Raft-inspired consensus cluster built on
Igniter's Actor primitives. The Raft protocol is fully encapsulated — users interact
with the high-level `Cluster` API and an optional `StateMachine` subclass.

---

## Quick start

```ruby
require "igniter/consensus"

# Start a 5-node cluster with the built-in key-value state machine
cluster = Igniter::Consensus::Cluster.start(nodes: %i[n1 n2 n3 n4 n5])
cluster.wait_for_leader

cluster.write(key: :price, value: 99)   # replicated to all nodes
cluster.read(:price)                     # => 99

cluster.stop!
```

---

## Architecture

Two complementary Igniter primitives map naturally to consensus protocols:

| Primitive | Role |
|-----------|------|
| `Igniter::Consensus::Node` | Raft agent — leader election, log replication (internal) |
| `Igniter::Consensus::Cluster` | Lifecycle management + high-level read/write API |
| `Igniter::Consensus::StateMachine` | User-extensible state machine DSL |
| `Igniter::Consensus::ReadQuery` | Built-in single-shot read Contract |

```
Cluster of 5 Node agents, each registered in Igniter::Registry

 ┌─────────────────────────────────────────────────────────────┐
 │  n1: follower │  n2: follower │  n3: LEADER  │  n4: follower │  n5: follower
 └───────────────┴───────────────┴──────────────┴───────────────┴───────────────┘
                                        │
                     ┌──────────────────┼──────────────────┐
              heartbeat (50ms)    AppendEntries       commit on quorum(3/5)
```

### Leader election flow

```
Follower ──(timeout 1–1.5 s)──► Candidate ──(quorum votes)──► Leader
   ▲                                                               │
   └────────────────── AppendEntries heartbeat (50 ms) ◄──────────┘
```

1. A follower that receives no heartbeat within its randomised election timeout
   becomes a **Candidate** and broadcasts `RequestVote` to all peers.
2. A node that hasn't voted in this term grants its vote if the candidate's log
   is at least as up-to-date as its own.
3. The first candidate to collect **majority votes** (quorum = ⌊N/2⌋ + 1) becomes
   **Leader** and immediately starts heartbeating.
4. Randomised timeouts (1.0–1.5 s) prevent simultaneous elections (split votes).

---

## `Cluster` API

### Starting a cluster

```ruby
cluster = Igniter::Consensus::Cluster.start(
  nodes:         %i[n1 n2 n3 n4 n5],   # Registry names for each node
  state_machine: MyStateMachine,         # optional — default is KV store
  verbose:       false,                  # print Raft events to stdout
)
```

`start` creates nodes and returns immediately — it does **not** wait for leader
election. Call `wait_for_leader` if you need a leader before proceeding.

### Waiting for a leader

```ruby
leader_ref = cluster.wait_for_leader          # blocks up to ~2 s
leader_ref = cluster.wait_for_leader(timeout: 5)  # custom timeout
```

Raises `Igniter::Consensus::NoLeaderError` if no leader is elected within the timeout.

### Writing

```ruby
# Default KV protocol
cluster.write(key: :price, value: 99)

# Custom state machine command
cluster.write(type: :add_order, id: "o1", data: { price: 42, qty: 10 })
```

Raises `NoLeaderError` if no leader is available. Returns `self` (chainable).

### Reading

```ruby
cluster.read(:price)              # => 99 (reads from leader's committed state)
cluster.state_machine_snapshot    # => { price: 99, ... } (full snapshot)
```

### Quorum and status

```ruby
cluster.quorum_size    # => 3 (minimum votes for 5-node cluster)
cluster.has_quorum?    # => true
cluster.alive_count    # => 5
cluster.status         # => [{ node_id: :n1, role: :follower, term: 2, ... }, ...]
```

### Stopping

```ruby
cluster.stop!           # graceful stop of all nodes (timeout: 2s default)
cluster.stop!(timeout: 5)
```

### Contract integration

```ruby
q = cluster.read_contract(key: :price)   # returns ReadQuery instance
q.resolve_all
q.result.value   # => 99
```

---

## `StateMachine` — custom command reducers

Subclass `Igniter::Consensus::StateMachine` and declare handlers with `apply`:

```ruby
class OrderBook < Igniter::Consensus::StateMachine
  # Each handler receives (state, command) and must return the NEW state (immutably).
  apply :add_order do |state, cmd|
    state.merge(cmd[:id] => cmd[:order])
  end

  apply :cancel_order do |state, cmd|
    state.reject { |k, _| k == cmd[:id] }
  end

  apply :update_price do |state, cmd|
    return state unless state.key?(cmd[:id])
    state.merge(cmd[:id] => state[cmd[:id]].merge(price: cmd[:price]))
  end
end

cluster = Igniter::Consensus::Cluster.start(
  nodes: %i[n1 n2 n3 n4 n5],
  state_machine: OrderBook,
)

cluster.write(type: :add_order, id: "ord-1", order: { vendor: "ACME", price: 42.0 })
cluster.read("ord-1")   # => { vendor: "ACME", price: 42.0 }
```

### Default KV protocol (no subclass needed)

When no `state_machine:` is provided, commands use a simple key-value protocol:

| Command | Effect |
|---------|--------|
| `{ key: :x, value: 42 }` | Set `state_machine[:x] = 42` |
| `{ key: :x, op: :delete }` | Remove `:x` from state machine |

---

## `ReadQuery` — declarative Contract read

`ReadQuery` is a built-in `Igniter::Contract` with the dependency graph
`find_leader → read_value`:

```ruby
q = Igniter::Consensus::ReadQuery.new(cluster: cluster, key: :price)
q.resolve_all
q.result.value   # => 99
```

Or use `Cluster#read_contract` for convenience:

```ruby
q = cluster.read_contract(key: :price)
q.resolve_all
q.result.value   # => 99
```

### Custom read Contract

You can build your own Contracts using the bundled executors:

```ruby
class PriceCheck < Igniter::Contract
  define do
    input :cluster
    input :threshold

    compute :leader,       with: :cluster,         call: Igniter::Consensus::FindLeader
    compute :current_price, with: [:leader],        call: ReadCurrentPrice
    compute :verdict,      with: [:current_price, :threshold], call: EvaluatePrice

    output :verdict
  end
end
```

---

## Practical Example — `BidAuction`

Models the auction problem: N vendors submit bids durably to the consensus log
before the winner is selected. Combines `Igniter::Contract` parallel execution
with consensus-backed durability.

```ruby
class SubmitBid < Igniter::Executor
  # The dep name varies per compute node (vendor1_bid / vendor2_bid / …).
  # Using ** captures whichever named bid dep is passed.
  def call(cluster:, **bid_kwarg)
    bid = bid_kwarg.values.first   # { vendor_id:, price: }
    ref = cluster.leader
    raise Igniter::ResolutionError, "No leader — cannot submit bid" unless ref
    ref.send(:client_write, command: { key: :"bid_#{bid[:vendor_id]}", value: bid[:price] })
    bid
  end
end

class SelectWinner < Igniter::Executor
  def call(bid1:, bid2:, bid3:)
    [bid1, bid2, bid3].min_by { |b| b[:price] }
  end
end

class BidAuction < Igniter::Contract
  runner :thread_pool, pool_size: 3   # bid1, bid2, bid3 run concurrently

  define do
    input :cluster
    input :vendor1_bid   # { vendor_id: String, price: Float }
    input :vendor2_bid
    input :vendor3_bid

    # No deps between bid1/bid2/bid3 → submitted to the consensus log in parallel
    compute :bid1,   with: [:cluster, :vendor1_bid], call: SubmitBid
    compute :bid2,   with: [:cluster, :vendor2_bid], call: SubmitBid
    compute :bid3,   with: [:cluster, :vendor3_bid], call: SubmitBid

    # Depends on all three → runs only after every bid is committed
    compute :winner, with: [:bid1, :bid2, :bid3],    call: SelectWinner

    output :winner
  end
end
```

Usage:

```ruby
auction = BidAuction.new(
  cluster:     cluster,
  vendor1_bid: { vendor_id: "alpha",   price: 45.00 },
  vendor2_bid: { vendor_id: "betacor", price: 38.50 },
  vendor3_bid: { vendor_id: "gamma",   price: 52.00 },
)
auction.resolve_all
puts auction.result.winner   # => { vendor_id: "betacor", price: 38.5 }
```

The Igniter dependency graph enforces the correct ordering automatically:
- `bid1`, `bid2`, `bid3` have no mutual deps → `thread_pool` submits them concurrently.
- `winner` depends on all three → it never runs before every bid is logged.

---

## Quorum Failure and Safety Guarantees

Raft is a **CP system** (Consistent + Partition-tolerant). With fewer than `⌊N/2⌋ + 1`
nodes alive, no leader can be elected and the cluster is **unavailable** — but it
never returns stale or conflicting data.

```ruby
# Kill enough nodes to break quorum (3/5 needed, only 2 survive)
(3).times { cluster_nodes.pop.kill }

begin
  cluster.read_contract(key: :price).resolve_all
rescue Igniter::Error => e
  puts e.message
  # => "No leader in cluster — retry later [graph=ReadQuery, node=leader …]"
end

# Or catch at the Cluster level before even attempting a Contract:
cluster.has_quorum?   # => false
cluster.write(key: :x, value: 1)
# => Igniter::Consensus::NoLeaderError: No leader available
```

`FindLeader` scans all known nodes, finds no leader, and raises `Igniter::ResolutionError`.
The resolver enriches it with full context (graph, node, execution_id).

---

## Critical Implementation Gotchas

### 1. `next` not `return` inside `on` blocks

`on :type do |state:, payload:| … end` registers a **Proc** (not a lambda).
`return` inside a Proc raises `LocalJumpError` at runtime.
Use `next value` for early exits:

```ruby
# ✗ LocalJumpError at runtime
on :vote_response do |state:, payload:|
  return state unless msg[:vote_granted]
end

# ✓ correct
on :vote_response do |state:, payload:|
  next state unless msg[:vote_granted]
end
```

### 2. Sync-reply handlers must return a non-Hash

The Agent runner applies this logic to the handler's return value:

```
Hash  → @state_holder.set(result)   # treated as NEW STATE; caller gets nil
other → send as reply to call()
```

For synchronous queries, wrap the result in a Struct:

```ruby
StatusInfo = Struct.new(:role, :term, :node_id, keyword_init: true)

on :status do |state:, payload:|
  StatusInfo.new(role: state[:role], term: state[:term], node_id: state[:node_id])
end

ref.call(:status).role   # => :leader
```

`Igniter::Consensus::Node` uses `NodeStatus` and `NodeReadResult` structs internally.

### 3. `ref.state` vs `ref.call()`

| Method | Mechanism | Use when |
|--------|-----------|----------|
| `ref.state` | Reads `StateHolder` directly (Mutex, no mailbox) | Polling from the main thread; leader discovery |
| `ref.call(:type)` | Goes through mailbox, blocks until reply | Need agent-thread consistency; sync queries |

`Cluster#leader` and `Cluster#read` use `ref.state` for performance-sensitive
leader polling.

### 4. Class-method helpers must NOT be `private_class_method`

Helpers called from `schedule`/`on` blocks (which run in the Agent's Runner thread)
must be accessible via explicit class reference (`Node.find_peer`, etc.). Making them
`private_class_method` blocks these calls since the blocks use explicit receiver form.

### 5. Heartbeat : election timeout ratio

Raft recommends heartbeat interval be **10× smaller** than the minimum election
timeout. With Ruby's green-thread scheduling jitter, a 1:20 ratio is more reliable:

```ruby
HEARTBEAT_INTERVAL      = 0.05  # 50 ms
ELECTION_TIMEOUT_BASE   = 1.0   # 1000 ms minimum (1:20 ratio)
ELECTION_TIMEOUT_JITTER = 0.5   # + random 0–500 ms
```

With a tighter ratio (e.g., 1:3) followers can time out before they receive the
first heartbeat from a freshly elected leader, causing cascading elections.

---

## Extending the Pattern

### Custom state machine commands

```ruby
class InventoryMachine < Igniter::Consensus::StateMachine
  apply :set     do |state, cmd| state.merge(cmd[:key] => cmd[:value]) end
  apply :incr    do |state, cmd| state.merge(cmd[:key] => (state[cmd[:key]] || 0) + cmd[:by]) end
  apply :delete  do |state, cmd| state.reject { |k, _| k == cmd[:key] } end
end
```

### Distributed lock

```ruby
class AcquireLock < Igniter::Executor
  def call(cluster:, lock_key:, owner:)
    ref = cluster.leader
    raise Igniter::ResolutionError, "No leader" unless ref
    current = ref.state[:state_machine][lock_key]
    raise Igniter::ResolutionError, "Lock held by #{current}" if current
    ref.send(:client_write, command: { key: lock_key, value: owner })
    :acquired
  end
end
```

### Multi-Raft / partitioned keyspace

Start separate clusters per shard and route writes by key hash:

```ruby
SHARD_CLUSTERS = {
  0 => Igniter::Consensus::Cluster.start(nodes: %i[n1a n2a n3a]),
  1 => Igniter::Consensus::Cluster.start(nodes: %i[n1b n2b n3b]),
}

def shard_for(key) = key.hash % SHARD_CLUSTERS.size
def cluster_for(key) = SHARD_CLUSTERS[shard_for(key)]
```

### Redis-backed log persistence

Access the underlying Node agent via `Igniter::Registry` to intercept writes:

```ruby
# Subscribe to writes via a custom state machine that persists to Redis:
class RedisBackedMachine < Igniter::Consensus::StateMachine
  apply :set do |state, cmd|
    $redis.rpush("raft:log", { key: cmd[:key], value: cmd[:value] }.to_json)
    state.merge(cmd[:key] => cmd[:value])
  end
end
```

---

## Running the Demo

```bash
bundle exec ruby examples/consensus.rb
```

Output covers 10 steps:

| Step | Description |
|------|-------------|
| 1 | Start 5-node cluster |
| 2 | Leader elected via `wait_for_leader` |
| 3 | Two writes committed to the log |
| 4 | Full cluster status snapshot |
| 5 | `ReadQuery` contract reads `:price` |
| 6 | Leader crash simulation |
| 7 | New leader elected; write + read after failover |
| 8 | Custom `CounterMachine` in a 3-node cluster |
| 9 | `BidAuction` — three vendors bid in parallel; bids replicated before winner selected |
| 10 | Quorum failure — `ReadQuery` raises `ResolutionError` (CP guarantee) |

---

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/consensus.rb` | Entry point (`require "igniter/consensus"`) |
| `lib/igniter/consensus/cluster.rb` | **Public API** — lifecycle, read, write, status |
| `lib/igniter/consensus/state_machine.rb` | User DSL — `apply :type do \|state, cmd\| end` |
| `lib/igniter/consensus/node.rb` | Internal Raft agent (full protocol) |
| `lib/igniter/consensus/executors.rb` | `FindLeader`, `ReadValue`, `SubmitCommand` |
| `lib/igniter/consensus/read_query.rb` | `ReadQuery` built-in Contract |
| `lib/igniter/consensus/errors.rb` | `NoLeaderError`, `QuorumLostError` |
| `examples/consensus.rb` | Full working demo (10 steps) |
| `spec/igniter/consensus_spec.rb` | Test suite (35 examples) |

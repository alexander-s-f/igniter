# frozen_string_literal: true

# examples/consensus.rb
#
# Demonstrates Igniter::Cluster::Consensus — a Raft-inspired consensus cluster.
#
# Two APIs are shown:
#
#   High-level  Cluster.start / write / read / read_contract
#   Low-level   Raw Igniter::Contract with Consensus executors (BidAuction)
#
# The Raft protocol (leader election, log replication, quorum commits) is
# fully encapsulated inside Igniter::Cluster::Consensus::Node. Users only interact
# with Cluster and, optionally, a custom StateMachine subclass.
#
# Run: bundle exec ruby examples/consensus.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/cluster"

puts "=" * 62
puts "  Igniter::Cluster::Consensus Demo (5-node Raft cluster)"
puts "=" * 62

NODES = %i[n1 n2 n3 n4 n5].freeze

# ─────────────────────────────────────────────────────────────────────────────
# [1] Start cluster with the default KV state machine
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[1] Starting #{NODES.size}-node cluster"

cluster = Igniter::Cluster::Consensus::Cluster.start(nodes: NODES)
puts "  Nodes: #{NODES.join(", ")}"
puts "  Quorum needed: #{cluster.quorum_size}/#{NODES.size}"

# ─────────────────────────────────────────────────────────────────────────────
# [2] Wait for a leader — Cluster#wait_for_leader polls until election completes
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[2] Waiting for leader election..."

leader_ref = cluster.wait_for_leader
puts "  Leader: #{leader_ref.state[:node_id]}  term=#{leader_ref.state[:term]}"

# ─────────────────────────────────────────────────────────────────────────────
# [3] Writes — Cluster#write dispatches to the leader
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[3] Writing to consensus log"

cluster.write(key: :price,     value: 99)
cluster.write(key: :available, value: true)
sleep 0.5  # allow replication

# ─────────────────────────────────────────────────────────────────────────────
# [4] Cluster status via Cluster#status
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[4] Cluster state after replication"
puts "  #{"node".ljust(5)} #{"role".ljust(10)} #{"term".ljust(5)} " \
     "#{"log".ljust(4)} #{"ci".ljust(4)} state_machine"
puts "  " + "-" * 58

cluster.status.each do |s|
  puts "  #{s[:node_id].to_s.ljust(5)} #{s[:role].to_s.ljust(10)} " \
       "#{s[:term].to_s.ljust(5)} #{s[:log_size].to_s.ljust(4)} " \
       "#{s[:commit_index].to_s.ljust(4)} #{s[:state_machine].inspect}"
end

# ─────────────────────────────────────────────────────────────────────────────
# [5] ReadQuery contract — declarative graph: find_leader → read_value
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[5] ReadQuery contract: reading :price"

q = cluster.read_contract(key: :price)
q.resolve_all
puts "  :price=#{q.result.value}"

# ─────────────────────────────────────────────────────────────────────────────
# [6] Leader crash → automatic failover
# ─────────────────────────────────────────────────────────────────────────────
old_leader_id = leader_ref.state[:node_id]
puts "\n[6] Crashing leader #{old_leader_id}..."

Igniter::Registry.find(old_leader_id)&.kill
Igniter::Registry.unregister(old_leader_id)

surviving_ids = NODES.reject { |n| n == old_leader_id }
surviving = Igniter::Cluster::Consensus::Cluster.new(nodes: surviving_ids)

puts "  Waiting for new election..."
new_leader_ref = surviving.wait_for_leader
puts "  New leader: #{new_leader_ref.state[:node_id]}  term=#{new_leader_ref.state[:term]}"

# ─────────────────────────────────────────────────────────────────────────────
# [7] Post-failover write + read via ReadQuery
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[7] Write after failover"

surviving.write(key: :price, value: 150)
sleep 0.4

q2 = surviving.read_contract(key: :price)
q2.resolve_all
puts "  :price after failover = #{q2.result.value}"

# ─────────────────────────────────────────────────────────────────────────────
# [8] Custom state machine — counter with typed commands
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[8] Custom state machine (counter)"

class CounterMachine < Igniter::Cluster::Consensus::StateMachine
  apply :increment do |state, cmd|
    state.merge(cmd[:key] => (state[cmd[:key]] || 0) + cmd[:by])
  end
  apply :reset do |state, cmd|
    state.merge(cmd[:key] => 0)
  end
end

counter_cluster = Igniter::Cluster::Consensus::Cluster.start(
  nodes: %i[cx1 cx2 cx3],
  state_machine: CounterMachine,
)
counter_cluster.wait_for_leader
counter_cluster.write(type: :increment, key: :page_views, by: 100)
counter_cluster.write(type: :increment, key: :page_views, by: 250)
sleep 0.4
puts "  page_views = #{counter_cluster.read(:page_views)}"
counter_cluster.stop!

# ─────────────────────────────────────────────────────────────────────────────
# [9] BidAuction — parallel bid submission with durable consensus log
#
# Key Igniter properties:
#   1. bid1/bid2/bid3 have no mutual deps → thread_pool submits them concurrently
#   2. winner depends on all three → runs only after every bid is logged
#   3. Same SubmitBid executor reused for all three bids (captures dep name via **)
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[9] BidAuction — three vendors submit bids in parallel"

class SubmitBid < Igniter::Executor
  # Called with: cluster: + one named bid dep (vendor1_bid / vendor2_bid / …).
  # The dep name differs per compute node; ** captures whichever is passed.
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

    compute :bid1,   with: [:cluster, :vendor1_bid], call: SubmitBid
    compute :bid2,   with: [:cluster, :vendor2_bid], call: SubmitBid
    compute :bid3,   with: [:cluster, :vendor3_bid], call: SubmitBid

    compute :winner, with: [:bid1, :bid2, :bid3], call: SelectWinner

    output :winner
  end
end

auction = BidAuction.new(
  cluster:     surviving,
  vendor1_bid: { vendor_id: "alpha",   price: 45.00 },
  vendor2_bid: { vendor_id: "betacor", price: 38.50 },
  vendor3_bid: { vendor_id: "gamma",   price: 52.00 },
)
auction.resolve_all
winner = auction.result.winner
puts "  Winner: vendor=#{winner[:vendor_id]}  price=$#{"%.2f" % winner[:price]}"

sleep 0.4
puts "  Bids in consensus log:"
surviving.status.each do |s|
  bids = s[:state_machine].select { |k, _| k.to_s.start_with?("bid_") }
                           .map    { |k, v| "#{k}=$#{"%.2f" % v}" }
                           .join("  ")
  puts "  #{s[:node_id].to_s.ljust(5)} #{s[:role].to_s.ljust(10)} #{bids}"
end

# ─────────────────────────────────────────────────────────────────────────────
# [10] Quorum failure — Raft's CP safety guarantee
#
# With only 2/5 nodes alive (< quorum 3), no leader can be elected.
# The cluster becomes unavailable rather than returning stale/inconsistent data.
# ─────────────────────────────────────────────────────────────────────────────
puts "\n[10] Quorum failure: Raft's CP guarantee"

# Identify the current leader among surviving nodes, then kill it plus one follower
minority_ids = surviving_ids.reject { |n|
  ref = Igniter::Registry.find(n)
  ref&.alive? && ref.state[:role] == :leader
}.first(2)

(surviving_ids - minority_ids).each do |nid|
  Igniter::Registry.find(nid)&.kill rescue nil
  Igniter::Registry.unregister(nid) rescue nil
end

puts "  Surviving: #{minority_ids.join(", ")}  (quorum needs #{cluster.quorum_size}/#{NODES.size})"
puts "  Waiting — no leader should be elected..."
sleep Igniter::Cluster::Consensus::ELECTION_TIMEOUT_BASE +
      Igniter::Cluster::Consensus::ELECTION_TIMEOUT_JITTER + 0.3

minority_roles = minority_ids.map { |n|
  ref = Igniter::Registry.find(n)
  ref&.alive? ? "#{n}:#{ref.state[:role]}" : "#{n}:dead"
}
puts "  States: #{minority_roles.join("  ")}"

minority_cluster = Igniter::Cluster::Consensus::Cluster.new(nodes: minority_ids)
puts "  ConsensusQuery with #{minority_ids.size}/#{NODES.size} nodes:"
begin
  minority_cluster.read_contract(key: :price).resolve_all
  puts "  UNEXPECTED: query succeeded"
rescue Igniter::Error => e
  puts "    → #{e.class.name.split("::").last}: #{e.message}"
  puts "    (correct — cluster is unavailable, not returning stale data)"
end

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────
minority_ids.each { |n| Igniter::Registry.find(n)&.stop(timeout: 2) rescue nil }
Igniter::Registry.clear
puts "\nDone."

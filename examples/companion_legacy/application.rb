#!/usr/bin/env ruby
# frozen_string_literal: true

# Companion AI Assistant — orchestrator node.
# Hosts ChatContract (big LLM) and VoiceAssistantContract (coordinator).
# Calls inference nodes (RPi) for ASR, Intent, and TTS via HTTP.
#
# Usage (single node, all local):
#   bundle exec ruby application.rb
#
# Usage (k3s cluster, Redis, external inference):
#   INFERENCE_NODE_URL=http://rpi1:4568 \
#   REDIS_URL=redis://redis-svc:6379    \
#   LOG_FORMAT=json                     \
#   bundle exec ruby application.rb
#
# Usage (with Consensus — multiple orchestrators share replicated notes store):
#   CONSENSUS_NODES=node1,node2,node3   \
#   bundle exec ruby application.rb
#
# Environment:
#   ORCHESTRATOR_PORT   — TCP port (default from application.yml: 4567)
#   INFERENCE_NODE_URL  — RPi inference node URL (default: http://localhost:4568)
#   CHAT_NODE_URL       — Node running ChatContract (default: self)
#   CHAT_MODEL          — Ollama model (default: llama3.1:8b)
#   REDIS_URL           — Redis URL for persistent store (optional)
#   LOG_FORMAT          — "text" or "json"
#   CONSENSUS_NODES     — Comma-separated Raft node names (optional)

require_relative "lib/companion/boot"

Companion::Boot.setup_load_path!

require "igniter/app"
require "igniter/core"
require "igniter/ai"

class CompanionApp < Igniter::App
  config_file File.join(__dir__, "application.yml")

  # Load in dependency order: tools and skills first (executors reference them).
  tools_path     "app/tools"
  skills_path    "app/skills"
  executors_path "app/executors"
  contracts_path "app/contracts"
  agents_path    "app/agents"

  on_boot do
    Companion::Boot.configure_ai!

    # Optional: Consensus cluster for replicated notes store.
    if ENV["CONSENSUS_NODES"]
      require "igniter/cluster"
      require_relative "lib/companion/shared/session_state_machine"

      node_ids = ENV["CONSENSUS_NODES"].split(",").map { |s| s.strip.to_sym }
      cluster  = Igniter::Cluster::Consensus::Cluster.start(
        nodes:         node_ids,
        state_machine: Companion::SessionStateMachine,
        verbose:       false
      )
      begin
        cluster.wait_for_leader(timeout: 5)
        Companion::NotesStore.configure_cluster(cluster)
        puts "Consensus cluster active: #{node_ids.size} nodes, " \
             "leader=#{cluster.leader&.name}, quorum=#{cluster.quorum_size}"
      rescue => e
        warn "Consensus cluster unavailable (#{e.message}) — using in-process notes store"
      end
      at_exit { cluster.stop!(timeout: 3) rescue nil }
    end

    # Register contracts for HTTP dispatch.
    register "ChatContract",          Companion::ChatContract
    register "VoiceAssistantContract", Companion::VoiceAssistantContract
  end

  configure do |c|
    c.port       = ENV.fetch("ORCHESTRATOR_PORT", "4567").to_i
    c.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
    c.store = if ENV["REDIS_URL"]
                require "redis"
                Igniter::Runtime::Stores::RedisStore.new(
                  redis:     Redis.new(url: ENV["REDIS_URL"]),
                  namespace: "companion:executions"
                )
              else
                Igniter::Runtime::Stores::MemoryStore.new
              end
  end

  # Prune stale in-memory sessions every hour.
  # In production, Redis TTL handles this automatically.
  schedule :session_gc, every: "1h" do
    # placeholder — extend with session store cleanup as needed
  end
end

CompanionApp.start if $PROGRAM_NAME == __FILE__

#!/usr/bin/env ruby
# frozen_string_literal: true

# Companion orchestrator — HP t740 (x86_64, 32 GB).
# Hosts ChatContract (big LLM) and VoiceAssistantContract (coordinator).
# Calls inference nodes (RPi) for ASR, Intent, and TTS via HTTP.
#
# Usage (single node, all local):
#   bundle exec ruby examples/companion/application.rb
#
# Usage (k3s cluster):
#   INFERENCE_NODE_URL=http://rpi1:4568 \
#   REDIS_URL=redis://redis-svc:6379    \
#   LOG_FORMAT=json                     \
#   bundle exec ruby examples/companion/application.rb
#
# Environment:
#   ORCHESTRATOR_PORT   — TCP port (default from application.yml: 4567)
#   INFERENCE_NODE_URL  — RPi inference node URL (default: http://localhost:4568)
#   CHAT_NODE_URL       — Node running ChatContract (default: self)
#   CHAT_MODEL          — Ollama model (default: llama3.1:8b)
#   REDIS_URL           — Redis URL for persistent store (optional)
#   LOG_FORMAT          — "text" or "json" (overrides application.yml)

$LOAD_PATH.unshift(File.join(__dir__, "../../lib"))

require "igniter"
require "igniter/server"
require "igniter/metrics"
require "igniter/integrations/llm"
require "igniter/application"

base = __dir__
require_relative "#{base}/executors/chat_executor"
require_relative "#{base}/contracts/chat_contract"
require_relative "#{base}/contracts/voice_assistant_contract"

class CompanionOrchestratorApp < Igniter::Application
  config_file File.join(__dir__, "application.yml")

  configure do |c|
    # Port override from environment
    c.port       = ENV.fetch("ORCHESTRATOR_PORT", "4567").to_i
    # Log format override from environment
    c.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
    # Prometheus metrics
    c.metrics_collector = Igniter::Metrics::Collector.new
    # Store: Redis for persistence, MemoryStore for local dev
    c.store = if ENV["REDIS_URL"]
                require "redis"
                Igniter::Runtime::Stores::RedisStore.new(
                  redis:     Redis.new(url: ENV["REDIS_URL"]),
                  namespace: "companion:executions",
                )
              else
                Igniter::Runtime::Stores::MemoryStore.new
              end
  end

  register "ChatContract",          Companion::ChatContract
  register "VoiceAssistantContract", Companion::VoiceAssistantContract

  # Prune stale in-memory sessions every hour.
  # In production, Redis TTL handles this automatically.
  schedule :session_gc, every: "1h" do
    # placeholder — extend when session store is added
    Igniter::Runtime::Stores::MemoryStore::GC_TICK_LOGGED = true if defined?(COMPANION_GC_VERBOSE)
  end
end

# Configure LLM integration (Ollama running locally or via cluster service)
Igniter::LLM.configure do |c|
  c.default_provider = :ollama
  c.ollama.url       = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
end

if $PROGRAM_NAME == __FILE__
  puts "Companion orchestrator starting..."
  puts "  Port:           #{CompanionOrchestratorApp.config.port}"
  puts "  Inference node: #{ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")}"
  puts "  Chat model:     #{ENV.fetch("CHAT_MODEL", "llama3.1:8b")}"
  puts "  Store:          #{CompanionOrchestratorApp.config.store&.class&.name&.split("::")&.last || "MemoryStore"}"
  puts "  Log format:     #{CompanionOrchestratorApp.config.log_format}"
  puts

  CompanionOrchestratorApp.start
end

#!/usr/bin/env ruby
# frozen_string_literal: true

# Orchestrator node — runs on HP t740 (x86_64, 32 GB RAM).
#
# Hosts: VoiceAssistantContract (pipeline coordinator) + ChatContract (big LLM).
# Calls out to inference nodes (RPi) for ASR, intent, and TTS via HTTP.
#
# Usage:
#   # Start Ollama first: ollama serve  (pull llama3.1:8b on first run)
#   # Start Redis:        redis-server
#
#   INFERENCE_NODE_URL=http://rpi1:4568 \
#   REDIS_URL=redis://localhost:6379 \
#   bundle exec ruby examples/companion/servers/orchestrator_server.rb
#
# Environment:
#   ORCHESTRATOR_PORT  — TCP port (default: 4567)
#   INFERENCE_NODE_URL — RPi inference node URL (default: http://localhost:4568)
#   CHAT_NODE_URL      — Node running ChatContract (default: http://localhost:4567 = self)
#   CHAT_MODEL         — Ollama model (default: llama3.1:8b)
#   REDIS_URL          — Redis for session/execution store (optional, uses memory if unset)

$LOAD_PATH.unshift(File.join(__dir__, "../../../lib"))

require "igniter"
require "igniter/server"
require "igniter/metrics"
require "igniter/integrations/llm"

base = File.join(__dir__, "..")
require_relative "#{base}/executors/chat_executor"
require_relative "#{base}/contracts/chat_contract"
require_relative "#{base}/contracts/voice_assistant_contract"

# Configure LLM integration (Ollama, local)
Igniter::LLM.configure do |c|
  c.default_provider = :ollama
  c.ollama.url       = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
end

# Execution store — Redis for persistence, memory for local dev
store = if ENV["REDIS_URL"]
          require "redis"
          Igniter::Runtime::Stores::RedisStore.new(
            redis:     Redis.new(url: ENV["REDIS_URL"]),
            namespace: "companion:executions"
          )
        else
          Igniter::Runtime::Stores::MemoryStore.new
        end

Igniter::Server.configure do |c|
  c.host       = "0.0.0.0"
  c.port       = ENV.fetch("ORCHESTRATOR_PORT", "4567").to_i
  c.store      = store
  c.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
  c.drain_timeout     = 30
  c.metrics_collector = Igniter::Metrics::Collector.new

  c.register "ChatContract",          Companion::ChatContract
  c.register "VoiceAssistantContract", Companion::VoiceAssistantContract
end

puts "Companion orchestrator starting on port #{Igniter::Server.config.port}"
puts "  Inference node: #{ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")}"
puts "  Chat model:     #{ENV.fetch("CHAT_MODEL", "llama3.1:8b")}"
puts "  Store:          #{store.class.name.split("::").last}"

Igniter::Server.start

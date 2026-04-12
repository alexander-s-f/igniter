#!/usr/bin/env ruby
# frozen_string_literal: true

# Inference node — focused sidecar service for each Raspberry Pi 5.
#
# Hosts: ASRContract (Whisper), IntentContract (small LLM), TTSContract (Piper).
# The orchestrator app calls these via HTTP. This entrypoint intentionally stays
# a small raw server rather than a second full Igniter::Application.
#
# Usage:
#   # On RPi — start Whisper server first:
#   #   uvicorn faster_whisper_server.server:app --host 0.0.0.0 --port 8765
#   #   ollama serve  (pulls qwen2.5:1.5b on first run)
#
#   bundle exec ruby examples/companion_legacy/inference/server.rb
#
# Environment:
#   INFERENCE_PORT  — TCP port for this node (default: 4568)
#   WHISPER_URL     — faster-whisper URL (default: http://localhost:8765)
#   INTENT_MODEL    — Ollama model for intent (default: qwen2.5:1.5b)
#   PIPER_MODEL     — Piper voice model (default: en_US-lessac-medium)

require_relative "../lib/companion/boot"

Companion::Boot.setup_load_path!

require "igniter/server"
require "igniter/core/metrics"
require "igniter/ai"

Companion::Boot.configure_ai!
Companion::Boot.load_inference!

Igniter::Server.configure do |config|
  config.host = "0.0.0.0"
  config.port = ENV.fetch("INFERENCE_PORT", "4568").to_i
  config.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
  config.drain_timeout = 30
  config.metrics_collector = Igniter::Metrics::Collector.new
  config.register "ASRContract", Companion::ASRContract
  config.register "IntentContract", Companion::IntentContract
  config.register "TTSContract", Companion::TTSContract
end

puts "Companion inference node starting on port #{Igniter::Server.config.port}"
puts "  Whisper: #{ENV.fetch("WHISPER_URL", "http://localhost:8765")}"
puts "  Intent model: #{ENV.fetch("INTENT_MODEL", "qwen2.5:1.5b")}"
puts "  Piper model: #{ENV.fetch("PIPER_MODEL", "en_US-lessac-medium")}"

Igniter::Server.start

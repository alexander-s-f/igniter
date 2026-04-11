#!/usr/bin/env ruby
# frozen_string_literal: true

# Inference node — runs on each Raspberry Pi 5.
#
# Hosts: ASRContract (Whisper), IntentContract (small LLM), TTSContract (Piper).
# The orchestrator (HP t740) calls these via HTTP.
#
# Usage:
#   # On RPi — start Whisper server first:
#   #   uvicorn faster_whisper_server.server:app --host 0.0.0.0 --port 8765
#   #   ollama serve  (pulls qwen2.5:1.5b on first run)
#
#   bundle exec ruby examples/companion/servers/inference_server.rb
#
# Environment:
#   INFERENCE_PORT  — TCP port for this node (default: 4568)
#   WHISPER_URL     — faster-whisper URL (default: http://localhost:8765)
#   INTENT_MODEL    — Ollama model for intent (default: qwen2.5:1.5b)
#   PIPER_MODEL     — Piper voice model (default: en_US-lessac-medium)

$LOAD_PATH.unshift(File.join(__dir__, "../../../lib"))

require "igniter"
require "igniter/server"
require "igniter/metrics"

base = File.join(__dir__, "..")

require "igniter/integrations/llm"
Igniter::LLM.configure do |c|
  c.default_provider = :ollama
  c.ollama.url       = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
end

require_relative "#{base}/app/tools/time_tool"
require_relative "#{base}/app/executors/whisper_executor"
require_relative "#{base}/app/executors/piper_executor"
require_relative "#{base}/app/executors/intent_executor"
require_relative "#{base}/app/contracts/asr_contract"
require_relative "#{base}/app/contracts/intent_contract"
require_relative "#{base}/app/contracts/tts_contract"

Igniter::Server.configure do |c|
  c.host       = "0.0.0.0"
  c.port       = ENV.fetch("INFERENCE_PORT", "4568").to_i
  c.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
  c.drain_timeout = 30
  c.metrics_collector = Igniter::Metrics::Collector.new

  c.register "ASRContract",    Companion::ASRContract
  c.register "IntentContract", Companion::IntentContract
  c.register "TTSContract",    Companion::TTSContract
end

puts "Companion inference node starting on port #{Igniter::Server.config.port}"
puts "  Whisper: #{ENV.fetch("WHISPER_URL", "http://localhost:8765")}"
puts "  Intent model: #{ENV.fetch("INTENT_MODEL", "qwen2.5:1.5b")}"
puts "  Piper model: #{ENV.fetch("PIPER_MODEL", "en_US-lessac-medium")}"

Igniter::Server.start

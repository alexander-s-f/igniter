#!/usr/bin/env ruby
# frozen_string_literal: true

# Companion demo — runs the full pipeline in a single process with mock executors.
# No hardware, no Ollama, no Whisper, no Piper needed.
#
# Usage:
#   bundle exec ruby examples/companion/demo.rb
#
# With a real Ollama (still single-process, no ESP32):
#   COMPANION_REAL_LLM=1 bundle exec ruby examples/companion/demo.rb

$LOAD_PATH.unshift(File.join(__dir__, "../../lib"))

require "igniter"
require "base64"

base = __dir__

# ── Load executors ──────────────────────────────────────────────────────────
if ENV["COMPANION_REAL_LLM"]
  require "igniter/integrations/llm"
  require_relative "#{base}/executors/whisper_executor"
  require_relative "#{base}/executors/piper_executor"
  require_relative "#{base}/executors/intent_executor"
  require_relative "#{base}/executors/chat_executor"
  puts "[demo] Using real LLM executors (Ollama must be running)"
else
  require_relative "#{base}/executors/mock_executors"
  # Alias mock executors under their real names for contracts to resolve
  module Companion
    WhisperExecutor = MockWhisperExecutor
    PiperExecutor   = MockPiperExecutor
    IntentExecutor  = MockIntentExecutor
    ChatExecutor    = MockChatExecutor
  end
  puts "[demo] Using mock executors (no hardware/Ollama needed)"
end

# ── Load contracts ──────────────────────────────────────────────────────────
require_relative "#{base}/contracts/asr_contract"
require_relative "#{base}/contracts/intent_contract"
require_relative "#{base}/contracts/chat_contract"
require_relative "#{base}/contracts/tts_contract"

# ── Single-process pipeline (no HTTP, all local) ────────────────────────────
#
# In production this runs distributed; here we compose the contracts inline.
module Companion
  class LocalPipelineContract < Igniter::Contract
    define do
      input :audio_data
      input :conversation_history
      input :session_id

      # Step 1: ASR
      compose :asr_comp, contract: Companion::ASRContract,
                         inputs:   { audio_data: :audio_data }
      export :transcript, from: :asr_comp   # → output(:transcript, from: "asr_comp.transcript")

      # Step 2: Intent
      compose :intent_comp, contract: Companion::IntentContract,
                            inputs:   { text: :transcript }
      export :intent, from: :intent_comp

      # Step 3: Chat
      compose :chat_comp, contract: Companion::ChatContract,
                          inputs:   {
                            message:              :transcript,
                            conversation_history: :conversation_history,
                            intent:               :intent
                          }
      export :response_text, from: :chat_comp

      # Step 4: TTS
      compose :tts_comp, contract: Companion::TTSContract,
                         inputs:   { text: :response_text }
      export :audio_response, from: :tts_comp
      # export already creates output nodes — no separate output declarations needed
    end
  end
end

# ── Session helper ───────────────────────────────────────────────────────────
class Session
  attr_reader :history

  def initialize
    @history = []
    @id      = "demo-#{Time.now.to_i}"
  end

  def push(transcript, response)
    @history << { role: "user",      content: transcript }
    @history << { role: "assistant", content: response }
    @history = @history.last(20)  # keep last 10 turns
  end

  def id = @id
end

# ── Fake audio (silence) for demo ────────────────────────────────────────────
def fake_audio
  pcm = "\x00\x00" * 1600  # 0.1s silence at 16kHz
  Base64.strict_encode64(pcm)
end

# ── Run interactive loop ─────────────────────────────────────────────────────
puts
puts "=" * 60
puts "  Companion AI Assistant — Demo Mode"
puts "=" * 60
puts "  Each turn simulates receiving audio from ESP32."
puts "  Press Ctrl+C to exit."
puts

session = Session.new
turn    = 0

loop do
  turn += 1
  puts "\n── Turn #{turn} " + "─" * 44

  contract = Companion::LocalPipelineContract.new(
    audio_data:           fake_audio,
    conversation_history: session.history,
    session_id:           session.id
  )

  begin
    contract.resolve_all
    result = contract.result

    puts "  Heard:    \"#{result.transcript}\""
    puts "  Intent:   #{result.intent[:category]} (#{(result.intent[:confidence] * 100).round}%)"
    puts "  Response: \"#{result.response_text}\""
    puts "  Audio:    #{result.audio_response.length} chars (Base64 WAV)"

    session.push(result.transcript, result.response_text)
  rescue Igniter::Error => e
    puts "  [ERROR] #{e.message}"
  end

  print "\n  Press Enter for next turn, or Ctrl+C to exit... "
  $stdin.gets
end

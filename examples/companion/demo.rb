#!/usr/bin/env ruby
# frozen_string_literal: true

# Companion demo — runs the full pipeline in a single process with mock executors.
# No hardware, no Ollama, no Whisper, no Piper needed.
#
# Usage (mock executors, tools simulated, no consensus):
#   bundle exec ruby examples/companion/demo.rb
#
# With Consensus (replicated notes store, in-process 3-node cluster):
#   COMPANION_CONSENSUS=1 bundle exec ruby examples/companion/demo.rb
#
# With a real LLM (actual tool-use loop, requires Ollama):
#   COMPANION_REAL_LLM=1 bundle exec ruby examples/companion/demo.rb

$LOAD_PATH.unshift(File.join(__dir__, "../../lib"))

require "igniter"
require "base64"

base = __dir__

# ── Load tools (always needed) ──────────────────────────────────────────────
require_relative "#{base}/tools/time_tool"
require_relative "#{base}/tools/weather_tool"
require_relative "#{base}/tools/notes_tool"

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

# ── Section 1: Tool schemas ──────────────────────────────────────────────────
puts
puts "=" * 60
puts "  Tools Available to ChatExecutor"
puts "=" * 60

tools = [Companion::TimeTool, Companion::WeatherTool,
         Companion::SaveNoteTool, Companion::GetNotesTool]

tools.each do |tool|
  schema = tool.to_schema
  caps   = tool.required_capabilities
  puts
  puts "  #{tool.tool_name}  #{caps.any? ? "(requires: #{caps.join(", ")})" : "(no capabilities required)"}"
  puts "  Description: #{schema[:description]}"
  params = schema.dig(:parameters, :properties) || {}
  if params.any?
    puts "  Parameters:"
    params.each do |name, info|
      req = (schema.dig(:parameters, :required) || []).include?(name.to_s) ? " *required" : ""
      puts "    #{name} (#{info[:type]}#{req}): #{info[:description]}"
    end
  else
    puts "  Parameters: none"
  end
end

puts
puts "  Capability guard demo:"
save_tool = Companion::SaveNoteTool.new
begin
  save_tool.call_with_capability_check!(allowed_capabilities: [], key: "test", value: "x")
rescue Igniter::Tool::CapabilityError => e
  puts "  [ok] CapabilityError raised: #{e.message}"
end
begin
  result = save_tool.call_with_capability_check!(
    allowed_capabilities: [:storage],
    key: "demo_key", value: "hello from capability demo"
  )
  puts "  [ok] Call succeeded: #{result}"
ensure
  Companion::NotesStore.reset!
end

# ── Section 2: Consensus-backed notes store ──────────────────────────────────
if ENV["COMPANION_CONSENSUS"]
  require "igniter/consensus"
  require_relative "#{base}/session_state_machine"

  puts
  puts "=" * 60
  puts "  Consensus Cluster — Replicated Notes Store"
  puts "=" * 60
  puts
  puts "  Starting 3-node Raft cluster with SessionStateMachine..."

  cluster = Igniter::Consensus::Cluster.start(
    nodes:         [:companion_1, :companion_2, :companion_3],
    state_machine: Companion::SessionStateMachine,
    verbose:       false
  )
  cluster.wait_for_leader(timeout: 4)
  puts "  Leader elected: #{cluster.leader.name}"
  puts "  Quorum size:    #{cluster.quorum_size}/#{cluster.alive_count} nodes"

  # Back the notes store with the cluster
  Companion::NotesStore.configure_cluster(cluster)
  puts "  NotesStore → consensus-backed (replicated across #{cluster.alive_count} nodes)"

  # Write some notes via the cluster
  puts
  puts "  Writing notes..."
  Companion::NotesStore.save("favorite_language", "Ruby")
  Companion::NotesStore.save("timezone", "UTC+3")
  puts "  Saved: favorite_language = \"Ruby\""
  puts "  Saved: timezone = \"UTC+3\""

  # Append session turns via the state machine
  cluster.write(type: :append_turn, role: "user",      content: "Hello!")
  cluster.write(type: :append_turn, role: "assistant", content: "Hi there! How can I help?")

  # Read back the replicated state
  snapshot = cluster.state_machine_snapshot
  puts
  puts "  Replicated state:"
  puts "    notes:   #{snapshot[:notes]}"
  puts "    history: #{snapshot[:history].size} turn(s)"

  # Show fault tolerance: kill one node and keep reading
  puts
  puts "  Killing one node to simulate failure..."
  first_node = cluster.instance_variable_get(:@refs).values.first
  first_node.stop
  sleep 0.2
  puts "  Alive nodes: #{cluster.alive_count}/3  Has quorum: #{cluster.has_quorum?}"

  notes = Companion::NotesStore.all
  puts "  Notes still accessible: #{notes}"
  puts
  puts "  [ok] Consensus cluster maintains reads after single node failure"

  at_exit { cluster.stop!(timeout: 2) }
end

# ── Single-process pipeline (no HTTP, all local) ────────────────────────────
module Companion
  class LocalPipelineContract < Igniter::Contract
    define do
      input :audio_data
      input :conversation_history
      input :session_id

      # Step 1: ASR
      compose :asr_comp, contract: Companion::ASRContract,
                         inputs:   { audio_data: :audio_data }
      export :transcript, from: :asr_comp

      # Step 2: Intent
      compose :intent_comp, contract: Companion::IntentContract,
                            inputs:   { text: :transcript }
      export :intent, from: :intent_comp

      # Step 3: Chat (with tools — real or simulated)
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
if ENV["COMPANION_REAL_LLM"]
  puts "  ChatExecutor: real LLM with auto tool-use loop (Ollama)"
elsif ENV["COMPANION_CONSENSUS"]
  puts "  ChatExecutor: mock (tools simulated), notes backed by Consensus"
else
  puts "  ChatExecutor: mock (tools simulated in-process)"
  puts "  Tip: COMPANION_REAL_LLM=1 to enable real LLM tool-use loop"
  puts "  Tip: COMPANION_CONSENSUS=1 to enable replicated notes store"
end
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

    # Show current notes when tools have been invoked
    notes = Companion::NotesStore.all
    puts "  Notes:    #{notes}" unless notes.empty?

    session.push(result.transcript, result.response_text)
  rescue Igniter::Error => e
    puts "  [ERROR] #{e.message}"
  end

  print "\n  Press Enter for next turn, or Ctrl+C to exit... "
  $stdin.gets
end

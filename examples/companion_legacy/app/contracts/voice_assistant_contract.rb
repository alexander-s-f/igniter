# frozen_string_literal: true

require "igniter/server"

module Companion
  # Main distributed pipeline. Runs on the orchestrator node (HP t740).
  #
  # Takes raw audio from ESP32, fans out across inference nodes, returns speech.
  #
  #   ESP32 ──audio──▶ orchestrator:4567
  #                         │
  #                 ┌───────┼──────────────┐
  #                 ▼       ▼              │
  #           [ASR]   [Intent]             │   ← inference node (RPi)
  #                 │       │              │
  #                 └───┬───┘              │
  #                     ▼                 │
  #                  [Chat]               │   ← orchestrator (local, big model)
  #                     │                 │
  #                     ▼                 │
  #                   [TTS] ──────────────┘   ← inference node (RPi)
  #                     │
  #   ESP32 ◀──audio────┘
  #
  # Environment variables:
  #   INFERENCE_NODE_URL  — URL of the inference node  (default: http://localhost:4568)
  #   CHAT_NODE_URL       — URL of the chat node       (default: http://localhost:4567)
  #                         (may be same server if ChatContract is local)
  #
  # Inputs:
  #   audio_data            — Base64 WAV from ESP32 (16kHz 16-bit mono PCM)
  #   conversation_history  — Array<{role:,content:}> prior turns (passed by client)
  #   session_id            — opaque String for tracing
  #
  # Outputs:
  #   audio_response    — Base64 WAV to play on ESP32
  #   response_text     — text version for UI / logging
  #   transcript        — what was heard
  #   intent            — detected intent hash
  class VoiceAssistantContract < Igniter::Contract
    define do
      input :audio_data
      input :conversation_history
      input :session_id

      inference_node = ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")
      chat_node      = ENV.fetch("CHAT_NODE_URL",      "http://localhost:4567")

      # ── 1. Speech → Text ───────────────────────────────────────────────────
      remote :transcript,
             contract: "ASRContract",
             node:     inference_node,
             inputs:   { audio_data: :audio_data },
             timeout:  20

      # ── 2. Intent (feeds Chat for tone awareness) ──────────────────────────
      remote :intent,
             contract: "IntentContract",
             node:     inference_node,
             inputs:   { text: :transcript }

      # ── 3. LLM response (big model, same or dedicated node) ────────────────
      remote :response_text,
             contract: "ChatContract",
             node:     chat_node,
             inputs:   {
               message:              :transcript,
               conversation_history: :conversation_history,
               intent:               :intent
             },
             timeout: 45

      # ── 4. Text → Speech ───────────────────────────────────────────────────
      remote :audio_response,
             contract: "TTSContract",
             node:     inference_node,
             inputs:   { text: :response_text },
             timeout:  20

      output :audio_response
      output :response_text
      output :transcript
      output :intent
    end
  end
end

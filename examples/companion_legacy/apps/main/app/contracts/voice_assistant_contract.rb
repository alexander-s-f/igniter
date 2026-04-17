# frozen_string_literal: true

require "igniter/server"

module Companion
  class VoiceAssistantContract < Igniter::Contract
    define do
      input :audio_data
      input :conversation_history
      input :session_id

      inference_node = ENV.fetch("INFERENCE_NODE_URL", "http://localhost:4568")
      chat_node = ENV.fetch("CHAT_NODE_URL", "http://localhost:4567")

      remote :transcript,
             contract: "ASRContract",
             node: inference_node,
             inputs: { audio_data: :audio_data },
             timeout: 20

      remote :intent,
             contract: "IntentContract",
             node: inference_node,
             inputs: { text: :transcript }

      remote :response_text,
             contract: "ChatContract",
             node: chat_node,
             inputs: {
               message: :transcript,
               conversation_history: :conversation_history,
               intent: :intent
             },
             timeout: 45

      remote :audio_response,
             contract: "TTSContract",
             node: inference_node,
             inputs: { text: :response_text },
             timeout: 20

      output :audio_response
      output :response_text
      output :transcript
      output :intent
    end
  end
end

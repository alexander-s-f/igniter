# frozen_string_literal: true

require "igniter"

module Companion
  class LocalPipelineContract < Igniter::Contract
    define do
      input :audio_data
      input :conversation_history
      input :session_id

      compose :asr_comp, contract: Companion::ASRContract,
                         inputs: { audio_data: :audio_data }
      export :transcript, from: :asr_comp

      compose :intent_comp, contract: Companion::IntentContract,
                            inputs: { text: :transcript }
      export :intent, from: :intent_comp

      compose :chat_comp, contract: Companion::ChatContract,
                          inputs: {
                            message: :transcript,
                            conversation_history: :conversation_history,
                            intent: :intent
                          }
      export :response_text, from: :chat_comp

      compose :tts_comp, contract: Companion::TTSContract,
                         inputs: { text: :response_text }
      export :audio_response, from: :tts_comp
    end
  end
end

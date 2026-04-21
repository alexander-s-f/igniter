# frozen_string_literal: true

require_relative "../support/assistant_adapter"

module Companion
  class BriefingRequestContract < Igniter::Contract
    runner :store, agent_adapter: Companion::Main::Support::AssistantAdapter.new

    define do
      input :requester
      input :request

      agent :briefing,
            via: :companion_writer,
            message: :draft_briefing,
            reply: :stream,
            session_policy: :manual,
            inputs: { requester: :requester, request: :request }

      output :briefing
    end
  end
end

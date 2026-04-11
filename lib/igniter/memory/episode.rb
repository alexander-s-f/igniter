# frozen_string_literal: true

module Igniter
  module Memory
    # Immutable value object representing a single recorded event in agent history.
    #
    # @!attribute [r] id
    #   @return [Integer] unique identifier within the store
    # @!attribute [r] agent_id
    #   @return [String] identifier of the agent that recorded this episode
    # @!attribute [r] session_id
    #   @return [String, nil] optional session grouping identifier
    # @!attribute [r] ts
    #   @return [Integer] Unix timestamp of when the episode was recorded
    # @!attribute [r] type
    #   @return [String, Symbol] category of the episode (e.g. :tool_call, :response)
    # @!attribute [r] content
    #   @return [String] textual description of what happened
    # @!attribute [r] outcome
    #   @return [String, nil] result descriptor, e.g. "success" or "failure"
    # @!attribute [r] importance
    #   @return [Float] relevance weight in [0.0, 1.0], default 0.5
    Episode = Struct.new(
      :id, :agent_id, :session_id, :ts,
      :type, :content, :outcome, :importance,
      keyword_init: true
    )
  end
end

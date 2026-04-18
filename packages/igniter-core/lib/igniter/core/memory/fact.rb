# frozen_string_literal: true

module Igniter
  module Memory
    # Immutable value object representing a persisted learned fact for an agent.
    #
    # Facts represent stable knowledge extracted from experience, keyed by a
    # string name and associated with a confidence score.
    #
    # @!attribute [r] id
    #   @return [Integer] unique identifier within the store
    # @!attribute [r] agent_id
    #   @return [String] identifier of the agent that owns this fact
    # @!attribute [r] key
    #   @return [String] fact name (e.g. "user_timezone", "preferred_format")
    # @!attribute [r] value
    #   @return [Object] the fact's value
    # @!attribute [r] confidence
    #   @return [Float] confidence score in [0.0, 1.0], default 1.0
    # @!attribute [r] updated_at
    #   @return [Integer] Unix timestamp of last upsert
    Fact = Struct.new(
      :id, :agent_id, :key, :value, :confidence, :updated_at,
      keyword_init: true
    )
  end
end

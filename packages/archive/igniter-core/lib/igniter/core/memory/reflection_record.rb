# frozen_string_literal: true

module Igniter
  module Memory
    # Immutable value object representing the output of a reflection cycle.
    #
    # A ReflectionRecord captures the summary and optional system-prompt patch
    # produced by a ReflectionCycle run. It can be applied to update an agent's
    # system prompt or used as an audit trail.
    #
    # @!attribute [r] id
    #   @return [Integer] unique identifier within the store
    # @!attribute [r] agent_id
    #   @return [String] identifier of the agent this reflection belongs to
    # @!attribute [r] ts
    #   @return [Integer] Unix timestamp when the reflection was recorded
    # @!attribute [r] summary
    #   @return [String] human-readable summary of findings
    # @!attribute [r] system_patch
    #   @return [String, nil] optional suggested replacement/patch for system prompt
    # @!attribute [r] applied
    #   @return [Boolean] whether this reflection has been applied to the agent
    ReflectionRecord = Struct.new(
      :id, :agent_id, :ts, :summary, :system_patch, :applied,
      keyword_init: true
    )
  end
end

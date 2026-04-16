# frozen_string_literal: true

require "igniter/core/tool"

module Companion
  class TimeTool < Igniter::Tool
    description "Get the current date and time. Use this when the user asks what time or date it is."

    def call
      now = Time.now
      "Current time: #{now.strftime("%A, %B %d, %Y at %I:%M %p")}"
    end
  end
end

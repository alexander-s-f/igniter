# frozen_string_literal: true

require "igniter/core/tool"

module Companion
  class WeatherTool < Igniter::Tool
    description "Get the current weather for a location. Returns temperature and conditions."

    param :location, type: :string, required: true,
                     desc: "City name or location (e.g. 'New York', 'London')"

    requires_capability :network

    CONDITIONS = ["sunny", "partly cloudy", "cloudy", "rainy", "windy", "foggy"].freeze

    def call(location:)
      temp_f = rand(55..85)
      temp_c = ((temp_f - 32) * 5.0 / 9).round
      condition = CONDITIONS.sample
      "Weather in #{location}: #{temp_f}°F (#{temp_c}°C), #{condition}"
    end
  end
end

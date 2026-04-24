# frozen_string_literal: true

require_relative "contractable/acceptance"
require_relative "contractable/adapters"
require_relative "contractable/config"
require_relative "contractable/runner"

module Igniter
  module Embed
    module Contractable
      module_function

      def build(name, &block)
        config = Config.new(name: name)
        block&.call(config)
        Runner.new(config: config)
      end
    end
  end
end

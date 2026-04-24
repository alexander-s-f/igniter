# frozen_string_literal: true

require "igniter/contracts"
require "igniter/extensions/contracts"

require_relative "embed/errors"
require_relative "embed/config"
require_relative "embed/registry"
require_relative "embed/execution_envelope"
require_relative "embed/contract_handle"
require_relative "embed/container"
require_relative "embed/contractable"

module Igniter
  module Embed
    class << self
      def configure(name, &block)
        config = Config.new(name: name)
        block&.call(config)
        Container.new(config: config)
      end

      def contractable(name, &block)
        Contractable.build(name, &block)
      end
    end
  end
end

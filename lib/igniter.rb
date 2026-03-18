# frozen_string_literal: true

require_relative "igniter/version"
require_relative "igniter/errors"
require_relative "igniter/model"
require_relative "igniter/compiler"
require_relative "igniter/events"
require_relative "igniter/runtime"
require_relative "igniter/dsl"
require_relative "igniter/extensions"
require_relative "igniter/contract"

module Igniter
  class << self
    def compile(&block)
      DSL::ContractBuilder.compile(&block)
    end
  end
end

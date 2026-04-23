# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/dsl")
require_relative "dsl/contract_builder"
require_relative "dsl/schema_builder"

module Igniter
  module DSL
  end
end

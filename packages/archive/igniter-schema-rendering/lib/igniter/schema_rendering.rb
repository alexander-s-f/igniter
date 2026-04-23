# frozen_string_literal: true

require "igniter-frontend"

require_relative "schema_rendering/version"
require_relative "schema_rendering/schema"
require_relative "schema_rendering/patcher"
require_relative "schema_rendering/store"
require_relative "schema_rendering/submission_normalizer"
require_relative "schema_rendering/submission_validator"
require_relative "schema_rendering/submission_processor"
require_relative "schema_rendering/renderer"
require_relative "schema_rendering/page"

module Igniter
  module SchemaRendering
    Store = SchemaStore unless const_defined?(:Store, false)
    Patcher = SchemaPatcher unless const_defined?(:Patcher, false)
  end
end

# frozen_string_literal: true

require_relative "../../igniter"
require_relative "view/builder"
require_relative "view/component"
require_relative "view/form_builder"
require_relative "view/page"
require_relative "view/response"
require_relative "view/schema"
require_relative "view/schema_patcher"
require_relative "view/schema_renderer"
require_relative "view/schema_store"
require_relative "view/submission_normalizer"
require_relative "view/submission_processor"
require_relative "view/submission_validator"

module Igniter
  module Plugins
    module View
      module_function

      def render(&block)
        builder = Builder.new
        block.call(builder)
        builder.to_s
      end

      alias fragment render
    end
  end
end

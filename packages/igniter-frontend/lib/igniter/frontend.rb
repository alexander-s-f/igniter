# frozen_string_literal: true

require "igniter/app"

require_relative "frontend/version"
require_relative "frontend/builder"
require_relative "frontend/component"
require_relative "frontend/form_builder"
require_relative "frontend/page"
require_relative "frontend/request"
require_relative "frontend/response"
require_relative "frontend/app_access"
require_relative "frontend/context"
require_relative "frontend/handler"
require_relative "frontend/app"
require_relative "frontend/tailwind"
require_relative "frontend/arbre"
require_relative "frontend/arbre_page"
require_relative "frontend/components"

module Igniter
  module Frontend
    module_function

    def render(&block)
      builder = Builder.new
      block.call(builder)
      builder.to_s
    end

    alias fragment render
  end
end

# frozen_string_literal: true

require "igniter/app"
require "igniter/plugins/view"
require "igniter/plugins/view/arbre"

require_relative "frontend/version"
require_relative "frontend/request"
require_relative "frontend/response"
require_relative "frontend/app_access"
require_relative "frontend/context"
require_relative "frontend/handler"
require_relative "frontend/app"
require_relative "frontend/arbre_page"
require_relative "frontend/schema_page"
require_relative "frontend/components"

module Igniter
  module Frontend
  end
end

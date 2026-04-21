# frozen_string_literal: true

require "json"
require "igniter-frontend"
require_relative "../../contexts/home_context"

module Companion
  module Dashboard
    module Views
      class HomePage < Igniter::Frontend::ArbrePage
        template_root __dir__
        template "home_page"
        layout "layout"

        def initialize(context:)
          @context = context
        end

        def template_locals
          { page_context: @context }
        end

        def page_title
          @context.title
        end

        def body_class
          companion_theme.fetch(:body_class)
        end

        def main_class
          companion_theme.fetch(:main_class)
        end

        def tailwind_cdn_url
          Igniter::Frontend::Tailwind::PLAY_CDN_URL
        end

        def tailwind_config_script
          "tailwind.config = #{JSON.generate(companion_theme.fetch(:tailwind_config))};"
        end

        private

        def companion_theme
          @companion_theme ||= Igniter::Frontend::Tailwind.theme(:companion)
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative "../tailwind"
require_relative "component"

require_relative "components/action_group"
require_relative "components/badge"
require_relative "components/breadcrumbs"
require_relative "components/card"
require_relative "components/conversation_panel"
require_relative "components/event_list"
require_relative "components/json_panel"
require_relative "components/key_value_list"
require_relative "components/metric_grid"
require_relative "components/page_header"
require_relative "components/panel"
require_relative "components/resource_list"
require_relative "components/scenario_card"
require_relative "components/tabs"

module Igniter
  module Frontend
    module Arbre
      class Page
        class << self
          def render_fragment(assigns: {}, helpers: nil, &block)
            Arbre.ensure_available!
            context_class.new(assigns, helpers, &block).to_s
          end

          def render_page(title:, lang: "en", theme: :companion,
                          body_class: Igniter::Frontend::Tailwind::DEFAULT_BODY_CLASS,
                          main_class: Igniter::Frontend::Tailwind::DEFAULT_MAIN_CLASS,
                          include_play_cdn: true, tailwind_config: nil, head_content: nil,
                          assigns: {}, helpers: nil, &block)
            fragment = render_fragment(assigns: assigns, helpers: helpers, &block)

            Igniter::Frontend::Tailwind.render_page(
              title: title,
              lang: lang,
              theme: theme,
              body_class: body_class,
              main_class: main_class,
              include_play_cdn: include_play_cdn,
              tailwind_config: tailwind_config,
              head_content: head_content
            ) do |main|
              main.raw(fragment)
            end
          end

          private

          def context_class
            Arbre.context_class
          end
        end
      end
    end
  end
end

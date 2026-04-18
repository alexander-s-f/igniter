# frozen_string_literal: true

require_relative "../tailwind"
require_relative "component"
require_relative "components/badge"
require_relative "components/breadcrumbs"
require_relative "components/card"
require_relative "components/page_header"
require_relative "components/panel"

module Igniter
  module Plugins
    module View
      module Arbre
        class Page
          class << self
            def render_fragment(assigns: {}, helpers: nil, &block)
              Arbre.ensure_available!
              context_class.new(assigns, helpers, &block).to_s
            end

            def render_page(title:, lang: "en", theme: :companion, body_class: Tailwind::DEFAULT_BODY_CLASS,
                            main_class: Tailwind::DEFAULT_MAIN_CLASS, include_play_cdn: true,
                            tailwind_config: nil, head_content: nil, assigns: {}, helpers: nil, &block)
              fragment = render_fragment(assigns: assigns, helpers: helpers, &block)

              Tailwind.render_page(
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
end

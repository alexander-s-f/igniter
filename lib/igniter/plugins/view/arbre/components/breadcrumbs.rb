# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class Breadcrumbs < Arbre::Component
            builder_method :breadcrumbs

            DEFAULT_NAV_CLASS = "mb-4".freeze
            DEFAULT_LIST_CLASS = "inline-flex items-center gap-2 text-sm text-stone-400".freeze
            DEFAULT_ITEM_CLASS = "inline-flex items-center gap-2".freeze
            DEFAULT_LINK_CLASS = "transition hover:text-white".freeze
            DEFAULT_CURRENT_CLASS = "font-medium text-white".freeze
            DEFAULT_SEPARATOR_CLASS = "text-stone-600".freeze

            def build(*args, &block)
              options = extract_options!(args)
              theme = options.delete(:theme) || :companion
              class_name = options.delete(:class_name)
              list_class = options.delete(:list_class)
              ui_theme(theme)
              @item_class = merge_classes(DEFAULT_ITEM_CLASS, options.delete(:item_class))
              @link_class = merge_classes(DEFAULT_LINK_CLASS, options.delete(:link_class))
              @current_class = merge_classes(DEFAULT_CURRENT_CLASS, options.delete(:current_class))
              @separator_class = merge_classes(DEFAULT_SEPARATOR_CLASS, options.delete(:separator_class))
              @index = 0

              super(options.merge(class: merge_classes(DEFAULT_NAV_CLASS, class_name), "aria-label": "Breadcrumb"))
              @crumbs = ol(class: merge_classes(DEFAULT_LIST_CLASS, list_class))
              render_build_block(block)
            end

            def crumb(label, value = nil, current: false)
              rendered_label = humanize_label(label)
              index = @index
              separator_class = @separator_class
              current_class = @current_class
              link_class = @link_class
              item_class = @item_class

              @crumbs.li(class: item_class) do
                span("/", class: separator_class) if index.positive?

                if current || value.nil?
                  span(rendered_label, class: current_class, "aria-current": current ? "page" : nil)
                else
                  a(rendered_label, href: value, class: link_class)
                end
              end

              @index += 1
            end

            private

            def tag_name
              "nav"
            end
          end
        end
      end
    end
  end
end

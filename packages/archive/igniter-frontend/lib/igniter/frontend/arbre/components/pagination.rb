# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Pagination < Arbre::Component
          builder_method :pagination

          DEFAULT_WINDOW = 5

          def build(*args)
            options = extract_options!(args)
            theme = options.delete(:theme) || :companion
            class_name = options.delete(:class_name)
            current_page = normalize_page(options.delete(:current_page) || 1)
            total_pages = normalize_page(options.delete(:total_pages) || 1)
            total_count = options.delete(:total_count)
            per_page = options.delete(:per_page)
            item_name = options.delete(:item_name) || "items"
            href_builder = options.delete(:href_builder)
            window = normalize_page(options.delete(:window) || DEFAULT_WINDOW)
            compact = options.delete(:compact)

            @theme = ui_theme(theme)
            @current_page = [current_page, total_pages].min
            @total_pages = total_pages
            @total_count = total_count
            @per_page = per_page
            @item_name = item_name.to_s
            @href_builder = href_builder
            @window = window
            @compact = compact

            super(options.merge(class: merge_classes("pagination-panel grid gap-3", class_name)))
            render_component
          end

          private

          def render_component
            render_summary
            render_controls if @total_pages > 1
          end

          def render_summary
            div(summary_text, class: @theme.muted_text_class(extra: @compact ? "text-sm" : nil))
          end

          def render_controls
            nav("aria-label": "#{humanize_label(@item_name)} pagination", class: "flex flex-wrap items-center gap-2") do |bar|
              render_edge_link(bar, "Previous", @current_page - 1, disabled: @current_page <= 1)
              page_window.each do |page|
                render_page_link(bar, page)
              end
              render_edge_link(bar, "Next", @current_page + 1, disabled: @current_page >= @total_pages)
            end
          end

          def render_edge_link(bar, label, page, disabled:)
            if disabled
              bar.span(label, class: disabled_class)
            else
              bar.a(label, href: page_href(page), class: action_class(:ghost))
            end
          end

          def render_page_link(bar, page)
            if page == @current_page
              bar.span(page.to_s, class: current_page_class, "aria-current": "page")
            else
              bar.a(page.to_s, href: page_href(page), class: action_class(:soft))
            end
          end

          def page_window
            return (1..@total_pages).to_a if @total_pages <= @window

            half = @window / 2
            start_page = [@current_page - half, 1].max
            end_page = start_page + @window - 1

            if end_page > @total_pages
              end_page = @total_pages
              start_page = end_page - @window + 1
            end

            (start_page..end_page).to_a
          end

          def page_href(page)
            return "#" unless @href_builder

            @href_builder.call(page)
          end

          def summary_text
            return "Page #{@current_page} of #{@total_pages}" if @total_count.nil? || @per_page.nil?
            return "No #{display_item_name} yet." if @total_count.zero?

            first = ((@current_page - 1) * @per_page) + 1
            last = [@current_page * @per_page, @total_count].min
            "Showing #{first}-#{last} of #{@total_count} #{display_item_name}"
          end

          def display_item_name
            @item_name.tr("_", " ")
          end

          def action_class(variant)
            Igniter::Frontend::Tailwind::UI::Tokens.action(
              variant: variant,
              theme: :orange,
              size: :sm
            )
          end

          def current_page_class
            Igniter::Frontend::Tailwind::UI::Tokens.badge(theme: :orange)
          end

          def disabled_class
            merge_classes(
              "inline-flex items-center justify-center rounded-full border border-white/10 bg-white/[0.03] px-4 py-2 text-sm",
              "text-stone-500"
            )
          end

          def normalize_page(value)
            integer = value.to_i
            integer.positive? ? integer : 1
          end

          def tag_name
            "section"
          end
        end
      end
    end
  end
end

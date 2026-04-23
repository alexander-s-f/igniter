# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class SidebarShell < Arbre::Component
          builder_method :sidebar_shell

          Item = ::Data.define(:label, :href, :current, :meta)
          Section = ::Data.define(:title, :items)

          def build(*args, &block)
            options = extract_options!(args)
            @title = options.delete(:title)
            @subtitle = options.delete(:subtitle)
            @sections = normalize_sections(options.delete(:sections) || [])
            @summary_items = normalize_summary_items(options.delete(:summary_items) || [])
            class_name = options.delete(:class_name)
            sidebar_class_name = options.delete(:sidebar_class_name)
            content_class_name = options.delete(:content_class_name)

            super(options.merge(class: merge_classes("sidebar-shell grid gap-6 xl:grid-cols-[280px_minmax(0,1fr)]", class_name)))
            @sidebar = build_sidebar(sidebar_class_name)
            @content = div(class: merge_classes("grid gap-6 min-w-0", content_class_name))
            render_build_block(block)
          end

          def add_child(child)
            return super if @content.nil? || child.equal?(@sidebar) || child.equal?(@content)

            @content << child
          end

          private

          def build_sidebar(class_name)
            aside(class: merge_classes("grid gap-4 self-start xl:sticky xl:top-6", class_name)) do |sidebar|
              sidebar.div(class: "rounded-[30px] border border-white/10 bg-[#20130f]/95 p-5 shadow-2xl shadow-black/20") do |card|
                if @title || @subtitle
                  card.div(class: "grid gap-1") do |header|
                    header.div(@title, class: "text-sm font-semibold uppercase tracking-[0.22em] text-orange-200") if @title
                    header.div(@subtitle, class: "text-sm leading-6 text-stone-400") if @subtitle
                  end
                end

                if @summary_items.any?
                  card.div(class: "mt-5 grid gap-3") do |summary|
                    @summary_items.each do |item|
                      summary.div(class: "rounded-2xl border border-white/10 bg-white/[0.03] px-4 py-3") do |row|
                        row.div(item.fetch(:label), class: "text-[11px] font-semibold uppercase tracking-[0.18em] text-stone-400")
                        row.div(item.fetch(:value).to_s, class: "mt-1 text-sm font-medium text-stone-100")
                      end
                    end
                  end
                end
              end

              @sections.each do |section|
                sidebar.nav("aria-label": section.title.to_s, class: "rounded-[28px] border border-white/10 bg-[#20130f]/95 p-5 shadow-2xl shadow-black/20") do |nav_view|
                  nav_view.div(section.title.to_s, class: "text-[11px] font-semibold uppercase tracking-[0.18em] text-stone-400") if section.title
                  nav_view.div(class: "mt-4 grid gap-2") do |list|
                    section.items.each { |item| render_item(list, item) }
                  end
                end
              end
            end
          end

          def render_item(list, item)
            classes = Igniter::Frontend::Tailwind::UI::Tokens.action(
              variant: item.current ? :soft : :ghost,
              theme: :orange,
              size: :sm,
              extra: "w-full justify-between"
            )

            list.a(href: item.href, class: classes, "aria-current": (item.current ? "page" : nil)) do |link|
              link.span(item.label.to_s)
              link.span(item.meta.to_s, class: "text-[11px] uppercase tracking-[0.18em] text-stone-400") if item.meta
            end
          end

          def normalize_sections(sections)
            sections.map do |section|
              Section.new(
                section[:title],
                Array(section[:items]).map { |item| Item.new(item[:label], item[:href], item[:current], item[:meta]) }
              )
            end
          end

          def normalize_summary_items(items)
            items.map { |item| { label: item[:label], value: item[:value] } }
          end

          def tag_name
            "section"
          end
        end
      end
    end
  end
end

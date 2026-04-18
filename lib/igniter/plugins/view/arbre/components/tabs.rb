# frozen_string_literal: true

require "json"
require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class Tabs < Arbre::Component
            builder_method :tabs

            def build(*args, &block)
              options = extract_options!(args)
              title = options.delete(:title)
              subtitle = options.delete(:subtitle)
              span = options.delete(:span)
              class_name = options.delete(:class_name)
              tabs_id = options.delete(:id) || "tabs-#{object_id.abs}"
              span_class = span ? "span-#{span}" : nil

              @tabs_id = tabs_id
              @tabs = []

              super(
                options.merge(
                  id: @tabs_id,
                  class: merge_classes("panel tabs-panel", span_class, class_name),
                  "data-tabs": "true"
                )
              )

              build_heading(title, subtitle)
              render_build_block(block)
              render_tabs(title || "Tabs")
            end

            def add_child(child)
              super
            end

            def meta(value = nil, &block)
              container = ensure_header_container!
              value.nil? ? container.div(class: "meta", &block) : container.div(value, class: "meta", &block)
            end

            def actions(class_name: nil, &block)
              ensure_header_container!.action_group(class_name: class_name, &block)
            end

            def tab(title, active: nil, id: nil, &block)
              active = @tabs.empty? if active.nil?
              fragment = id || fragmentize(title)
              pane_id = "#{@tabs_id}-#{fragment}"
              button_id = "#{pane_id}-tab"
              @tabs << {
                title: title,
                active: active,
                pane_id: pane_id,
                button_id: button_id,
                block: block
              }
            end

            def json_tab(title, payload:, panel_id: nil, active: nil, id: nil)
              tab(title, active: active, id: id) do |pane|
                pane.pre(id: panel_id) { |code| code.text_node(JSON.pretty_generate(payload)) }
              end
            end

            private

            def render_tabs(label)
              div(class: "tabs-nav", role: "tablist", "aria-label": label) do |nav|
                @tabs.each do |entry|
                  nav.button(
                    entry.fetch(:title),
                    type: "button",
                    id: entry.fetch(:button_id),
                    class: merge_classes("tab-button", entry.fetch(:active) ? "active" : nil),
                    role: "tab",
                    "aria-controls": entry.fetch(:pane_id),
                    "aria-selected": entry.fetch(:active).to_s,
                    tabindex: entry.fetch(:active) ? "0" : "-1",
                    "data-tab-button": "true",
                    "data-tab-target": entry.fetch(:pane_id)
                  )
                end
              end

              div(class: "panel-body tabs-body") do |body|
                body.div(class: "tabs-panes") do |panes|
                  @tabs.each do |entry|
                    panes.div(
                      id: entry.fetch(:pane_id),
                      class: merge_classes("tab-pane", entry.fetch(:active) ? "active" : nil),
                      role: "tabpanel",
                      "aria-labelledby": entry.fetch(:button_id),
                      "data-tab-pane": "true"
                    ) do |pane|
                      render_tab_content(pane, entry[:block])
                    end
                  end
                end
              end
            end

            def render_tab_content(pane, block)
              return unless block

              if block.arity.zero?
                pane.instance_exec(&block)
              else
                block.call(pane)
              end
            end

            def build_heading(title, subtitle)
              return if title.nil? && subtitle.nil?

              ensure_heading_container!
              @heading.h2(title) if title
              @heading.div(subtitle, class: "caption") if subtitle
            end

            def ensure_header_container!
              @header ||= div(class: "panel-header")
            end

            def ensure_heading_container!
              ensure_header_container!
              @heading ||= @header.div(class: "panel-heading")
            end

            def fragmentize(value)
              value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
            end

            def tag_name
              "article"
            end
          end
        end
      end
    end
  end
end

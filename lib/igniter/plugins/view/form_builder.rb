# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class FormBuilder
        attr_reader :view

        def initialize(view)
          @view = view
        end

        def label(for_id, text = nil, **attrs, &block)
          view.tag(:label, attrs.merge(for: for_id)) do |label_view|
            if block
              block.call(label_view)
            else
              label_view.text(text)
            end
          end
        end

        def input(name, type: "text", value: nil, **attrs)
          view.tag(:input, attrs.merge(type: type, name: name, value: value))
        end

        def hidden(name, value, **attrs)
          input(name, type: "hidden", value: value, **attrs)
        end

        def checkbox(name, value: "1", checked: false, **attrs)
          view.tag(:input, attrs.merge(type: "checkbox", name: name, value: value, checked: checked))
        end

        def textarea(name, value: nil, **attrs)
          view.tag(:textarea, attrs.merge(name: name)) { |textarea| textarea.text(value) unless value.nil? }
        end

        def select(name, options:, selected: nil, **attrs)
          view.tag(:select, attrs.merge(name: name)) do |select_view|
            options.each do |label, value|
              option_attrs = { value: value }
              option_attrs[:selected] = true if selected.to_s == value.to_s
              select_view.tag(:option, option_attrs) { |option| option.text(label) }
            end
          end
        end

        def button(text = nil, type: "button", **attrs, &block)
          view.tag(:button, attrs.merge(type: type)) do |button_view|
            if block
              block.call(button_view)
            else
              button_view.text(text)
            end
          end
        end

        def submit(text = "Submit", **attrs)
          button(text, type: "submit", **attrs)
        end
      end
    end
  end
end

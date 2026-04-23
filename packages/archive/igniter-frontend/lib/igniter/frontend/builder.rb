# frozen_string_literal: true

require "cgi"

module Igniter
  module Frontend
    class Builder
      VOID_TAGS = %i[area base br col embed hr img input link meta param source track wbr].freeze

      def initialize(output = +"")
        @output = output
      end

      def doctype(type = "html")
        @output << "<!DOCTYPE #{escape_text(type)}>\n"
        nil
      end

      def tag(name, attrs = nil, content = nil, **kwargs, &block)
        if !attrs.nil? && !attrs.is_a?(Hash)
          content = attrs
          attrs = nil
        end

        attrs = normalize_attrs((attrs || {}).merge(kwargs))
        @output << "<#{name}#{render_attrs(attrs)}>"

        if VOID_TAGS.include?(name.to_sym) && block.nil? && content.nil?
          return nil
        end

        if block
          block.call(self)
        elsif !content.nil?
          text(content)
        end

        @output << "</#{name}>"
        nil
      end

      def text(value)
        @output << escape_text(value)
        nil
      end

      def component(component = nil, **kwargs)
        instance = component.is_a?(Class) ? component.new(**kwargs) : component
        raise ArgumentError, "component must be a component instance or class" if instance.nil?

        instance.render_in(self)
        nil
      end

      def form(action:, method: "post", **attrs)
        tag(:form, attrs.merge(action: action, method: method)) do |form_view|
          yield(FormBuilder.new(form_view))
        end
      end

      def button(text = nil, type: "button", **attrs, &block)
        tag(:button, attrs.merge(type: type)) do |button_view|
          if block
            block.call(button_view)
          else
            button_view.text(text)
          end
        end
      end

      def raw(value)
        @output << value.to_s
        nil
      end

      def capture(&block)
        nested = self.class.new
        block.call(nested)
        nested.to_s
      end

      def to_s
        @output.dup
      end

      private

      def escape_text(value)
        CGI.escape_html(value.to_s)
      end

      def normalize_attrs(attrs, prefix = nil)
        attrs.each_with_object({}) do |(key, value), result|
          next if value.nil? || value == false

          attr_name = [prefix, key.to_s.tr("_", "-")].compact.join("-")

          if value.is_a?(Hash)
            result.merge!(normalize_attrs(value, attr_name))
            next
          end

          result[attr_name] =
            case value
            when Array
              value.compact.join(" ")
            when true
              true
            else
              value
            end
        end
      end

      def render_attrs(attrs)
        return "" if attrs.empty?

        attrs.map do |key, value|
          value == true ? " #{key}" : " #{key}=\"#{escape_text(value)}\""
        end.join
      end
    end
  end
end

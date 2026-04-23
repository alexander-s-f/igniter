# frozen_string_literal: true

module Igniter
  module SchemaRendering
    class Schema
      Error = Class.new(ArgumentError)

      NODE_TYPES = %w[
        stack
        grid
        section
        card
        fieldset
        notice
        actions
        heading
        text
        form
        input
        textarea
        select
        checkbox
        submit
      ].freeze

      def self.load(payload)
        new(payload)
      end

      attr_reader :data

      def initialize(payload)
        @data = deep_stringify_keys(payload)
        validate!
      end

      def id
        data.fetch("id")
      end

      def version
        data.fetch("version", 1)
      end

      def kind
        data.fetch("kind")
      end

      def title
        data.fetch("title")
      end

      def layout
        data.fetch("layout")
      end

      def actions
        data.fetch("actions", {})
      end

      def meta
        data.fetch("meta", {})
      end

      def policy
        data.fetch("policy", {})
      end

      def form_for_action(action_id)
        find_node(layout) do |node|
          node["type"] == "form" && node["action"].to_s == action_id.to_s
        end
      end

      def to_h
        Marshal.load(Marshal.dump(data))
      end

      def action(action_id)
        actions.fetch(action_id.to_s, nil)
      end

      private

      def validate!
        raise Error, "schema must be a Hash" unless data.is_a?(Hash)
        raise Error, "schema id is required" if blank?(data["id"])
        raise Error, "schema kind must be 'page'" unless data["kind"] == "page"
        raise Error, "schema title is required" if blank?(data["title"])
        raise Error, "schema layout must be a Hash" unless data["layout"].is_a?(Hash)

        validate_node!(data["layout"], path: "layout")
      end

      def validate_node!(node, path:)
        raise Error, "#{path} must be a Hash" unless node.is_a?(Hash)

        type = node["type"].to_s
        raise Error, "#{path}.type is required" if type.empty?
        raise Error, "#{path}.type '#{type}' is not supported" unless NODE_TYPES.include?(type)

        case type
        when "stack", "grid", "section", "card", "fieldset", "actions"
          validate_children!(node, path: path)
        when "heading"
          raise Error, "#{path}.text is required" if blank?(node["text"])
        when "notice"
          raise Error, "#{path}.message is required" if blank?(node["message"])
        when "text"
          raise Error, "#{path}.text is required" if blank?(node["text"])
        when "form"
          raise Error, "#{path}.action is required" if blank?(node["action"])
          validate_children!(node, path: path)
        when "input", "textarea", "select", "checkbox"
          raise Error, "#{path}.name is required" if blank?(node["name"])
          raise Error, "#{path}.label is required" if blank?(node["label"])
          validate_options!(node, path: path) if type == "select"
        when "submit"
          raise Error, "#{path}.label is required" if blank?(node["label"])
        end
      end

      def validate_children!(node, path:)
        children = node.fetch("children", [])
        raise Error, "#{path}.children must be an Array" unless children.is_a?(Array)

        children.each_with_index do |child, index|
          validate_node!(child, path: "#{path}.children[#{index}]")
        end
      end

      def validate_options!(node, path:)
        options = node.fetch("options", [])
        raise Error, "#{path}.options must be an Array" unless options.is_a?(Array)

        options.each_with_index do |option, index|
          unless option.is_a?(Hash) && !blank?(option["label"]) && option.key?("value")
            raise Error, "#{path}.options[#{index}] must include label and value"
          end
        end
      end

      def blank?(value)
        value.nil? || value.to_s.strip.empty?
      end

      def find_node(node, &block)
        return node if block.call(node)

        Array(node["children"]).each do |child|
          found = find_node(child, &block)
          return found if found
        end

        nil
      end

      def deep_stringify_keys(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, entry), memo|
            memo[key.to_s] = deep_stringify_keys(entry)
          end
        when Array
          value.map { |entry| deep_stringify_keys(entry) }
        else
          value
        end
      end
    end
  end
end

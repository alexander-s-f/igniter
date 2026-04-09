# frozen_string_literal: true

module Igniter
  module LLM
    # Manages a conversation message history for multi-turn LLM interactions.
    # Immutable — each operation returns a new Context.
    #
    # Usage:
    #   ctx = Igniter::LLM::Context.empty(system: "You are a helpful assistant.")
    #   ctx = ctx.append_user("What is Ruby?")
    #   ctx = ctx.append_assistant("Ruby is a dynamic language...")
    #   ctx.messages  # => [{role: :system, ...}, {role: :user, ...}, {role: :assistant, ...}]
    class Context
      attr_reader :messages

      def initialize(messages = [])
        @messages = messages.freeze
      end

      def self.empty(system: nil)
        initial = system ? [{ role: :system, content: system }] : []
        new(initial)
      end

      def self.from_h(data)
        msgs = (data[:messages] || data["messages"] || []).map do |m|
          { role: (m[:role] || m["role"]).to_sym, content: (m[:content] || m["content"]).to_s }
        end
        new(msgs)
      end

      def append_user(content)
        append(role: :user, content: content)
      end

      def append_assistant(content)
        append(role: :assistant, content: content)
      end

      def append_tool_result(tool_name, content)
        append(role: :tool, content: content.to_s, name: tool_name.to_s)
      end

      def append(message)
        self.class.new(@messages + [message.transform_keys(&:to_sym)])
      end

      def with_system(content)
        existing = @messages.reject { |m| m[:role] == :system }
        self.class.new([{ role: :system, content: content }] + existing)
      end

      def last_assistant_message
        @messages.reverse.find { |m| m[:role] == :assistant }
      end

      def length
        @messages.length
      end

      def empty?
        @messages.empty?
      end

      def to_a
        @messages.map { |m| { "role" => m[:role].to_s, "content" => m[:content].to_s } }
      end

      def to_h
        { messages: @messages }
      end
    end
  end
end

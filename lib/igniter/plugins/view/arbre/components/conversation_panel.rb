# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class ConversationPanel < Arbre::Component
            builder_method :conversation_panel

            def build(*args, &block)
              options = extract_options!(args)
              title = options.delete(:title)
              subtitle = options.delete(:subtitle)
              span = options.delete(:span)
              class_name = options.delete(:class_name)
              span_class = span ? "span-#{span}" : nil

              super(options.merge(class: merge_classes("panel", span_class, class_name)))
              h2(title) if title
              div(subtitle, class: "caption") if subtitle
              render_build_block(block)
            end

            def notice(message, tone: :ok)
              css_class = tone.to_sym == :error ? "error" : "ok"
              div(message, class: css_class)
            end

            def transcript(messages:, id: nil, empty_role: "assistant", empty_message: "No chat yet.")
              div(id: id, class: "chat-log") do |chat_log|
                if Array(messages).empty?
                  chat_log.div class: "chat-turn" do |turn|
                    turn.strong empty_role
                    turn.div empty_message, class: "caption"
                  end
                else
                  Array(messages).each do |message|
                    chat_log.div class: "chat-turn" do |turn|
                      turn.strong message.fetch("role")
                      turn.div message.fetch("content")
                      next unless message.dig("metadata", "action_status")

                      turn.div "action=#{message.dig("metadata", "action_status")}", class: "caption"
                    end
                  end
                end
              end
            end

            private

            def tag_name
              "article"
            end
          end
        end
      end
    end
  end
end

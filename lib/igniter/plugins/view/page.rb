# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class Page < Component
        private

        def render_document(view, title:, lang: "en", body_attrs: {}, &block)
          view.doctype
          view.tag(:html, lang: lang) do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:meta, name: "viewport", content: "width=device-width, initial-scale=1")
              head.tag(:title, title)
              yield_head(head) if respond_to?(:yield_head, true)
            end
            html.tag(:body, body_attrs) do |body|
              block.call(body)
            end
          end
        end
      end
    end
  end
end

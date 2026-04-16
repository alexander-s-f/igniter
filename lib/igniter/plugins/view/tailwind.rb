# frozen_string_literal: true

require "json"

require_relative "../view"
require_relative "tailwind/ui"

module Igniter
  module Plugins
    module View
      module Tailwind
        PLAY_CDN_URL = "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4".freeze
        DEFAULT_BODY_CLASS = "min-h-screen bg-slate-950 text-slate-100 antialiased".freeze
        DEFAULT_MAIN_CLASS = "mx-auto flex min-h-screen w-full max-w-6xl flex-col gap-10 px-6 py-10 lg:px-10".freeze

        module_function

        def render_page(title:, lang: "en", body_class: DEFAULT_BODY_CLASS, main_class: DEFAULT_MAIN_CLASS,
                        include_play_cdn: true, tailwind_config: nil, head_content: nil, &block)
          raise ArgumentError, "render_page requires a block" unless block

          View.render do |view|
            view.doctype
            view.tag(:html, lang: lang) do |html|
              html.tag(:head) do |head|
                head.tag(:meta, charset: "utf-8")
                head.tag(:meta, name: "viewport", content: "width=device-width, initial-scale=1")
                head.tag(:title, title)
                head.tag(:script, src: PLAY_CDN_URL) if include_play_cdn
                render_config_script(head, tailwind_config) if tailwind_config
                head_content&.call(head)
              end

              html.tag(:body, class: body_class) do |body|
                body.tag(:main, class: main_class) do |main|
                  block.call(main)
                end
              end
            end
          end
        end

        def render_message_page(title:, eyebrow:, message:, back_label:, back_path:, detail: nil,
                                lang: "en", body_class: DEFAULT_BODY_CLASS, main_class: DEFAULT_MAIN_CLASS,
                                include_play_cdn: true, tailwind_config: nil, head_content: nil, **message_page_options)
          render_page(
            title: title,
            lang: lang,
            body_class: body_class,
            main_class: main_class,
            include_play_cdn: include_play_cdn,
            tailwind_config: tailwind_config,
            head_content: head_content
          ) do |main|
            main.component(
              UI::MessagePage.new(
                title: title,
                eyebrow: eyebrow,
                message: message,
                back_label: back_label,
                back_path: back_path,
                detail: detail,
                **message_page_options
              )
            )
          end
        end

        def render_config_script(view, config)
          payload = config.is_a?(String) ? config : "tailwind.config = #{JSON.generate(config)};"
          view.tag(:script, type: "text/javascript") do |script|
            script.raw(payload)
          end
        end
        private_class_method :render_config_script
      end
    end
  end
end

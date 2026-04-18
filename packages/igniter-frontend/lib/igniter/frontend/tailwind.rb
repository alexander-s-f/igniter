# frozen_string_literal: true

require "json"

require_relative "../frontend"
require_relative "tailwind/ui"
require_relative "tailwind/realtime"
require_relative "tailwind/surfaces"

module Igniter
  module Frontend
    module Tailwind
      PLAY_CDN_URL = "https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4".freeze
      MERMAID_CDN_URL = "https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js".freeze
      DEFAULT_BODY_CLASS = "min-h-screen bg-slate-950 text-slate-100 antialiased".freeze
      DEFAULT_MAIN_CLASS = "mx-auto flex min-h-screen w-full max-w-6xl flex-col gap-10 px-6 py-10 lg:px-10".freeze
      DEFAULT_TAILWIND_CONFIG = {
        theme: {
          extend: {
            fontFamily: {
              display: ["Fraunces", "Iowan Old Style", "Palatino Linotype", "serif"],
              body: ["IBM Plex Sans", "Avenir Next", "system-ui", "sans-serif"],
              mono: ["IBM Plex Mono", "SFMono-Regular", "Menlo", "monospace"]
            }
          }
        }
      }.freeze
      THEMES = {
        default: {
          body_class: DEFAULT_BODY_CLASS,
          main_class: DEFAULT_MAIN_CLASS,
          tailwind_config: DEFAULT_TAILWIND_CONFIG
        },
        ops: {
          body_class: "min-h-screen bg-stone-950 text-stone-100 antialiased selection:bg-amber-300/30 selection:text-white",
          main_class: "mx-auto flex min-h-screen w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
          tailwind_config: {
            theme: {
              extend: {
                fontFamily: {
                  display: ["Fraunces", "Iowan Old Style", "Palatino Linotype", "serif"],
                  body: ["IBM Plex Sans", "Avenir Next", "system-ui", "sans-serif"],
                  mono: ["IBM Plex Mono", "SFMono-Regular", "Menlo", "monospace"]
                },
                colors: {
                  lab: {
                    accent: "#D97706",
                    canvas: "#0c0a09",
                    panel: "#1c1917",
                    line: "#292524"
                  }
                },
                boxShadow: {
                  glow: "0 20px 80px rgba(217, 119, 6, 0.10)"
                }
              }
            }
          }
        },
        companion: {
          body_class: "min-h-screen bg-[#160f0d] text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
          main_class: "mx-auto flex min-h-screen w-full max-w-7xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
          tailwind_config: {
            theme: {
              extend: {
                fontFamily: {
                  display: ["Fraunces", "Iowan Old Style", "Palatino Linotype", "serif"],
                  body: ["IBM Plex Sans", "Avenir Next", "system-ui", "sans-serif"],
                  mono: ["IBM Plex Mono", "SFMono-Regular", "Menlo", "monospace"]
                },
                colors: {
                  companion: {
                    accent: "#c26b3d",
                    panel: "#2a1914"
                  }
                }
              }
            }
          }
        },
        schema: {
          body_class: "min-h-screen bg-stone-950 text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
          main_class: "mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-5 px-4 py-6 sm:px-6 lg:px-8",
          tailwind_config: DEFAULT_TAILWIND_CONFIG
        }
      }.freeze

      module_function

      def render_page(title:, lang: "en", theme: nil, body_class: DEFAULT_BODY_CLASS, main_class: DEFAULT_MAIN_CLASS,
                      include_play_cdn: true, tailwind_config: nil, head_content: nil, &block)
        raise ArgumentError, "render_page requires a block" unless block
        resolved = resolve_page_options(theme: theme, body_class: body_class, main_class: main_class, tailwind_config: tailwind_config)

        Frontend.render do |view|
          view.doctype
          view.tag(:html, lang: lang) do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:meta, name: "viewport", content: "width=device-width, initial-scale=1")
              head.tag(:title, title)
              head.tag(:script, src: PLAY_CDN_URL) if include_play_cdn
              render_config_script(head, resolved.fetch(:tailwind_config)) if resolved[:tailwind_config]
              head_content&.call(head)
            end

            html.tag(:body, class: resolved.fetch(:body_class)) do |body|
              body.tag(:main, class: resolved.fetch(:main_class)) do |main|
                block.call(main)
              end
            end
          end
        end
      end

      def render_message_page(title:, eyebrow:, message:, back_label:, back_path:, detail: nil,
                              lang: "en", theme: nil, body_class: DEFAULT_BODY_CLASS, main_class: DEFAULT_MAIN_CLASS,
                              include_play_cdn: true, tailwind_config: nil, head_content: nil, **message_page_options)
        render_page(
          title: title,
          lang: lang,
          theme: theme,
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

      def theme(theme_name)
        THEMES.fetch(theme_name.to_sym)
      end

      def resolve_page_options(theme:, body_class:, main_class:, tailwind_config:)
        preset = theme ? self.theme(theme) : {}

        {
          body_class: body_class == DEFAULT_BODY_CLASS ? preset.fetch(:body_class, body_class) : body_class,
          main_class: main_class == DEFAULT_MAIN_CLASS ? preset.fetch(:main_class, main_class) : main_class,
          tailwind_config: if tailwind_config
                             deep_merge(preset.fetch(:tailwind_config, {}), tailwind_config)
                           else
                             preset[:tailwind_config]
                           end
        }
      end
      private_class_method :resolve_page_options

      def render_config_script(view, config)
        payload = config.is_a?(String) ? config : "tailwind.config = #{JSON.generate(config)};"
        view.tag(:script, type: "text/javascript") do |script|
          script.raw(payload)
        end
      end
      private_class_method :render_config_script

      def deep_merge(base, override)
        return override unless base.is_a?(Hash) && override.is_a?(Hash)

        base.merge(override) do |_key, left, right|
          left.is_a?(Hash) && right.is_a?(Hash) ? deep_merge(left, right) : right
        end
      end
      private_class_method :deep_merge
    end
  end
end

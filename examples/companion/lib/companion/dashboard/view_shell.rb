# frozen_string_literal: true

require "igniter/plugins/view"
require "igniter/plugins/view/tailwind"

module Companion
  module Dashboard
    module ViewShell
      TAILWIND_CONFIG = {
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
      }.freeze

      module_function

      def render_message_page(title:, eyebrow:, message:, back_label:, back_path:, detail: nil)
        Igniter::Plugins::View::Tailwind.render_page(
          title: title,
          body_class: "min-h-screen bg-[#160f0d] text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
          main_class: "mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
          tailwind_config: TAILWIND_CONFIG
        ) do |main|
          main.tag(:section,
                   class: "relative overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.24),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8 lg:px-10") do |hero|
            hero.tag(:div, class: "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,146,60,0.14),_transparent_65%)] lg:block")
            hero.tag(:div, class: "relative z-10 max-w-3xl") do |content|
              content.tag(:p, eyebrow, class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75")
              content.tag(:h1, title, class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl")
              content.tag(:p, message, class: "mt-4 text-base leading-7 text-stone-300 sm:text-lg")
              if detail
                content.tag(:p, class: "mt-4") do |paragraph|
                  paragraph.tag(:code, detail, class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100")
                end
              end
              content.tag(:div, class: "mt-6 flex flex-wrap gap-3") do |actions|
                actions.tag(:a,
                            back_label,
                            href: back_path,
                            class: "inline-flex rounded-full border border-orange-300/20 bg-orange-300/90 px-5 py-3 text-sm font-semibold uppercase tracking-[0.18em] text-stone-950 transition hover:bg-orange-200")
              end
            end
          end
        end
      end
    end
  end
end

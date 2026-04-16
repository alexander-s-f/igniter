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
        Igniter::Plugins::View::Tailwind.render_message_page(
          title: title,
          eyebrow: eyebrow,
          message: message,
          back_label: back_label,
          back_path: back_path,
          detail: detail,
          body_class: "min-h-screen bg-[#160f0d] text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
          main_class: "mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
          tailwind_config: TAILWIND_CONFIG
        )
      end
    end
  end
end

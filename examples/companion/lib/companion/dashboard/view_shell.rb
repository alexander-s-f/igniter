# frozen_string_literal: true

require "igniter/plugins/view"
require "igniter/plugins/view/tailwind"

module Companion
  module Dashboard
    module ViewShell
      module_function

      def render_message_page(title:, eyebrow:, message:, back_label:, back_path:, detail: nil)
        Igniter::Plugins::View::Tailwind.render_message_page(
          title: title,
          eyebrow: eyebrow,
          message: message,
          back_label: back_label,
          back_path: back_path,
          detail: detail,
          theme: :companion,
          main_class: "mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-6 px-4 py-6 sm:px-6 lg:px-8",
          **Igniter::Plugins::View::Tailwind::UI::Theme.fetch(:companion).message_page_options
        )
      end
    end
  end
end

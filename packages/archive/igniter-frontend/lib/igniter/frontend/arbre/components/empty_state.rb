# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class EmptyState < Arbre::Component
          builder_method :empty_state

          def build(*args)
            options = extract_options!(args)
            title = args.shift || options.delete(:title) || "Nothing here yet"
            message = options.delete(:message)
            action_label = options.delete(:action_label)
            action_href = options.delete(:action_href)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("rounded-[28px] border border-dashed border-white/10 bg-white/[0.03] px-5 py-6 text-center", class_name)))
            div(title, class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            div(message, class: "mt-2 text-sm leading-6 text-stone-400") if message
            if action_label && action_href
              a(
                action_label,
                href: action_href,
                class: Igniter::Frontend::Tailwind::UI::Tokens.underline_link(theme: :orange, extra: "mt-4 inline-flex text-sm")
              )
            end
          end

          def tag_name
            "section"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class LoadingState < Arbre::Component
          builder_method :loading_state

          def build(*args)
            options = extract_options!(args)
            title = args.shift || options.delete(:title) || "Loading"
            message = options.delete(:message)
            lines = (options.delete(:lines) || 3).to_i
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("rounded-[28px] border border-white/10 bg-white/[0.03] px-5 py-6", class_name)))
            div(title, class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300")
            div(message, class: "mt-2 text-sm leading-6 text-stone-400") if message
            div(class: "mt-5 grid gap-3") do |stack|
              lines.times do |index|
                width_class =
                  case index % 3
                  when 0 then "w-full"
                  when 1 then "w-4/5"
                  else "w-3/5"
                  end

                stack.div(class: merge_classes("h-3 animate-pulse rounded-full bg-white/10", width_class))
              end
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

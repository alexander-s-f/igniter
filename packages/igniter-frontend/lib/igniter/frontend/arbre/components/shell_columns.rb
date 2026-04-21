# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class ShellColumns < Arbre::Component
          builder_method :shell_columns

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)
            @main_class_name = options.delete(:main_class_name)
            @aside_class_name = options.delete(:aside_class_name)

            super(options.merge(class: merge_classes("grid gap-6 xl:grid-cols-[minmax(0,1.2fr)_minmax(320px,0.8fr)]", class_name)))
            @main = section(class: merge_classes("grid gap-6 min-w-0", @main_class_name))
            @aside = section(class: merge_classes("grid gap-6 min-w-0", @aside_class_name))
            render_build_block(block)
          end

          def add_child(child)
            return super if @building_slot || child.equal?(@main) || child.equal?(@aside)

            ensure_main! << child
          end

          def main(&block)
            ensure_main!.instance_exec(&block) if block
            nil
          end

          def aside(&block)
            ensure_aside!.instance_exec(&block) if block
            nil
          end

          private

          def ensure_main!
            return @main if @main

            @building_slot = true
            @main = section(class: merge_classes("grid gap-6 min-w-0", @main_class_name))
          ensure
            @building_slot = false
          end

          def ensure_aside!
            return @aside if @aside

            @building_slot = true
            @aside = section(class: merge_classes("grid gap-6 min-w-0", @aside_class_name))
          ensure
            @building_slot = false
          end

          def tag_name
            "section"
          end
        end
      end
    end
  end
end

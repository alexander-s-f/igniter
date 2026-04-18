# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      module Arbre
        FallbackElement = Class.new do
          def self.builder_method(*)
            nil
          end
        end

        raw_text_base_class = if Arbre.available?
                                dependency = Arbre.dependency
                                if dependency.const_defined?(:Element)
                                  dependency.const_get(:Element)
                                else
                                  component_class.superclass
                                end
                              else
                                FallbackElement
                              end

        class RawTextNode < raw_text_base_class
          builder_method :raw_text

          def build(content)
            @content = content.to_s
          end

          def to_s
            @content
          end

          def tag_name
            nil
          end
        end
      end
    end
  end
end

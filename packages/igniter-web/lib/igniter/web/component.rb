# frozen_string_literal: true

module Igniter
  module Web
    module Fallback
      class Component
        def self.builder_method(*)
          nil
        end
      end
    end

    class Component < (Arbre.available? ? Arbre.component_class : Fallback::Component)
      class << self
        def define(builder_name = nil, &block)
          klass = Class.new(self)
          klass.builder_method(builder_name) if builder_name
          klass.build_with(&block) if block
          klass
        end

        def build_with(&block)
          return @build_block unless block

          @build_block = block
        end
      end

      def build(*args, **kwargs, &_block)
        build_block = self.class.build_with
        return super() unless build_block

        instance_exec(*args, **kwargs, &build_block)
      rescue NoMethodError => error
        raise unless error.name == :build

        self
      end

      private

      def render_build_block(block, *args)
        return unless block

        if block.arity.zero?
          instance_exec(&block)
        else
          block.call(*args)
        end
      end
    end
  end
end

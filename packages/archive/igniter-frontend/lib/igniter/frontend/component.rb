# frozen_string_literal: true

module Igniter
  module Frontend
    class Component
      def self.render(**kwargs)
        new(**kwargs).render
      end

      def render
        Frontend.render { |view| render_in(view) }
      end

      def render_in(view)
        call(view)
        nil
      end

      def call(_view)
        raise NotImplementedError, "#{self.class} must implement #call(view)"
      end
    end
  end
end

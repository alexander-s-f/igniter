# frozen_string_literal: true

require_relative "tailwind"

module Igniter
  module Frontend
    module Arbre
      class MissingDependencyError < LoadError
      end

      module_function

      def available?
        !dependency.nil?
      rescue MissingDependencyError
        false
      end

      def component_class
        dependency.const_get(:Component)
      end

      def context_class
        dependency.const_get(:Context)
      end

      def ensure_available!
        dependency
      end

      def dependency
        return ::Arbre if defined?(::Arbre)

        require "arbre"
        ::Arbre
      rescue LoadError
        raise MissingDependencyError,
              "Arbre integration requires the `arbre` gem. Add it to your app and load " \
              "`igniter-frontend` only where you need that adapter."
      end
    end
  end
end

require_relative "arbre/component"
require_relative "arbre/page"
require_relative "arbre/raw_text_node"
require_relative "arbre/template_page"

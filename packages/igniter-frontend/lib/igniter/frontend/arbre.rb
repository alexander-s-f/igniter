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
              "`igniter-frontend` now ships with a required `arbre` dependency. " \
              "If it is missing in this environment, run bundle install or reinstall the gem."
      end
    end
  end
end

require_relative "arbre/component"
require_relative "arbre/page"
require_relative "arbre/raw_text_node"
require_relative "arbre/template_page"

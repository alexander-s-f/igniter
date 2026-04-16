# frozen_string_literal: true

require_relative "../view"

module Igniter
  module Plugins
    module View
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

        def dependency
          return ::Arbre if defined?(::Arbre)

          require "arbre"
          ::Arbre
        rescue LoadError
          raise MissingDependencyError,
                "Arbre integration requires the `arbre` gem. Add it to your app and load " \
                "`igniter/plugins/view/arbre` only where you need that adapter."
        end
      end
    end
  end
end

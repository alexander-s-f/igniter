# frozen_string_literal: true

require_relative "../view"

module Igniter
  module Plugins
    module View
      module Arbre
        class MissingDependencyError < LoadError
        end

        module Components
        end

        autoload :Component, "igniter/plugins/view/arbre/component"
        autoload :Page, "igniter/plugins/view/arbre/page"
        autoload :RawTextNode, "igniter/plugins/view/arbre/raw_text_node"
        autoload :TemplatePage, "igniter/plugins/view/arbre/template_page"
        Components.autoload :Breadcrumbs, "igniter/plugins/view/arbre/components/breadcrumbs"
        Components.autoload :Card, "igniter/plugins/view/arbre/components/card"

        View.const_set(:ArbrePage, TemplatePage) unless View.const_defined?(:ArbrePage, false)

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
                "`igniter/plugins/view/arbre` only where you need that adapter."
        end
      end
    end
  end
end

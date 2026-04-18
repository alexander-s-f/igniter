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
        Components.autoload :ActionGroup, "igniter/plugins/view/arbre/components/action_group"
        Components.autoload :Badge, "igniter/plugins/view/arbre/components/badge"
        Components.autoload :Breadcrumbs, "igniter/plugins/view/arbre/components/breadcrumbs"
        Components.autoload :Card, "igniter/plugins/view/arbre/components/card"
        Components.autoload :ConversationPanel, "igniter/plugins/view/arbre/components/conversation_panel"
        Components.autoload :EventList, "igniter/plugins/view/arbre/components/event_list"
        Components.autoload :JsonPanel, "igniter/plugins/view/arbre/components/json_panel"
        Components.autoload :KeyValueList, "igniter/plugins/view/arbre/components/key_value_list"
        Components.autoload :MetricGrid, "igniter/plugins/view/arbre/components/metric_grid"
        Components.autoload :PageHeader, "igniter/plugins/view/arbre/components/page_header"
        Components.autoload :Panel, "igniter/plugins/view/arbre/components/panel"
        Components.autoload :ResourceList, "igniter/plugins/view/arbre/components/resource_list"
        Components.autoload :ScenarioCard, "igniter/plugins/view/arbre/components/scenario_card"
        Components.autoload :Tabs, "igniter/plugins/view/arbre/components/tabs"

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

        View.const_set(:ArbrePage, TemplatePage) unless View.const_defined?(:ArbrePage, false)
      end
    end
  end
end

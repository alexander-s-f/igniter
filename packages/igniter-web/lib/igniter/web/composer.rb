# frozen_string_literal: true

module Igniter
  module Web
    class Composer
      ZONE_ORDER = %i[summary main aside footer].freeze

      class << self
        def compose(...)
          new.compose(...)
        end
      end

      def initialize(policy: CompositionPolicy.new)
        @policy = policy
      end

      def compose(screen)
        graph = ViewGraph.new(root: root_node(screen))
        CompositionResult.new(
          screen: screen,
          graph: graph,
          findings: @policy.findings_for(screen)
        )
      end

      private

      def root_node(screen)
        zones = ZONE_ORDER.map { |name| zone_node(name, screen) }
        ViewNode.new(
          kind: :screen,
          name: screen.name,
          role: screen.intent,
          props: {
            title: screen.title_text,
            compose_with: screen.composition_preset,
            options: screen.options
          }.compact,
          children: zones
        )
      end

      def zone_node(name, screen)
        ViewNode.new(
          kind: :zone,
          name: name,
          children: screen.elements
                          .select { |element| zone_for(element) == name }
                          .map { |element| element_node(element) }
        )
      end

      def element_node(element)
        ViewNode.new(
          kind: element.kind,
          name: element.name,
          role: element.role,
          props: element.options
        )
      end

      def zone_for(element)
        return :summary if element.role == :summary
        return :aside if element.role == :aside
        return :footer if element.kind == :action
        return :main if %i[ask compare stream].include?(element.kind)

        case element.kind
        when :subject
          :summary
        when :actor, :chat
          :aside
        else
          :main
        end
      end
    end
  end
end

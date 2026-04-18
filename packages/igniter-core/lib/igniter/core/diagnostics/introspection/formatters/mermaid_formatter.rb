# frozen_string_literal: true

module Igniter
  module Diagnostics
    module Introspection
      module Formatters
        class MermaidFormatter
          def self.call(structure)
            new(structure).call
          end

          def initialize(structure)
            @structure = structure
            @output = StringIO.new
          end

          def call
            # Устанавливаем направление диаграммы слева направо
            @output.puts "graph LR"
            @output.puts "classDef default fill:#fff,stroke:#333,stroke-width:2px;"

            # Запускаем рекурсивную отрисовку
            draw_nodes_and_links(@structure)

            @output.string
          end

          private

          def draw_nodes_and_links(nodes)
            nodes.each do |node|
              # 1. Если узел - это Namespace, создаем для него subgraph
              if node[:type] == "Namespace"
                @output.puts "  subgraph #{node[:name]}"
                # Рекурсивно отрисовываем всех детей внутри подграфа
                draw_nodes_and_links(node[:children])
                @output.puts "  end"
              else
                # 2. Если это обычный узел, просто объявляем его
                node_text = "\"#{node[:name]}<br>[#{node[:details]}]\""
                @output.puts "  #{node[:path]}(#{node_text})"

                # У обычного узла тоже могут быть дети (например, проекции у композиции),
                # их тоже нужно отрисовать.
                draw_nodes_and_links(node[:children])
              end

              # 3. После объявления узла (или целого подграфа) рисуем его зависимости
              node[:dependencies].each do |dep_path|
                @output.puts "  #{dep_path} --> #{node[:path]}"
              end
            end
          end
        end
      end
    end
  end
end
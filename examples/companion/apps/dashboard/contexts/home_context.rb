# frozen_string_literal: true

module Companion
  module Dashboard
    module Contexts
      class HomeContext
        def self.build(snapshot:, base_path:, error_message: nil, form_values: {})
          new(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            form_values: form_values
          )
        end

        def initialize(snapshot:, base_path:, error_message:, form_values:)
          @snapshot = snapshot
          @base_path = base_path.to_s
          @error_message = error_message
          @form_values = form_values
        end

        attr_reader :snapshot
        attr_reader :error_message
        attr_reader :form_values

        def title
          "Companion Operator Desk"
        end

        def description
          "Public proving ground for the Igniter assistant and operator workflow."
        end

        def generated_at
          snapshot.fetch(:generated_at)
        end

        def stack
          snapshot.fetch(:stack)
        end

        def counts
          snapshot.fetch(:counts)
        end

        def notes
          snapshot.fetch(:notes)
        end

        def nodes
          snapshot.fetch(:nodes)
        end

        def route(path)
          prefix = @base_path.sub(%r{/+\z}, "")
          return path if prefix.empty?

          [prefix, path.sub(%r{\A/}, "")].join("/")
        end

        def summary_metrics
          [
            { label: "Apps", value: stack.fetch(:apps).size, hint: "mounted stack apps" },
            { label: "Nodes", value: counts.fetch(:nodes), hint: "runtime targets in snapshot" },
            { label: "Notes", value: counts.fetch(:notes), hint: "shared assistant/operator scratchpad" }
          ]
        end

        def operator_links
          [
            { label: "Overview API", href: route("/api/overview") },
            { label: "Operator Console", href: route("/operator") },
            { label: "Operator API", href: route("/api/operator") },
            { label: "Main Status", href: "/v1/home/status" }
          ]
        end

        def node_cards
          nodes.map do |name, service|
            {
              title: name.to_s,
              detail: "role=#{service.fetch(:role)}",
              meta: "host=#{service.fetch(:host)} port=#{service.fetch(:port)} public=#{service.fetch(:public)}",
              command: service.fetch(:command),
              mounts: service.fetch(:mounts)
            }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "uri"

module Companion
  module Dashboard
    module Contexts
      class HomeContext
        NOTES_PER_PAGE = 3

        def self.build(snapshot:, base_path:, error_message: nil, form_values: {}, filter_values: {})
          new(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            form_values: form_values,
            filter_values: filter_values
          )
        end

        def initialize(snapshot:, base_path:, error_message:, form_values:, filter_values:)
          @snapshot = snapshot
          @base_path = base_path.to_s
          @error_message = error_message
          @form_values = form_values
          @filter_values = filter_values
        end

        attr_reader :snapshot
        attr_reader :error_message
        attr_reader :form_values
        attr_reader :filter_values

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

        def node_rows
          rows = nodes.map do |name, service|
            {
              name: name.to_s,
              role: service.fetch(:role),
              endpoint: "#{service.fetch(:host)}:#{service.fetch(:port)}",
              public: service.fetch(:public),
              mounts: service.fetch(:mounts).map { |app, mount| "#{app}: #{mount}" },
              command: service.fetch(:command)
            }
          end

          query = @filter_values.fetch("q", "").to_s.strip.downcase
          role = @filter_values.fetch("role", "").to_s
          public_filter = @filter_values.fetch("public", "").to_s

          rows = rows.select do |row|
            matches_query = if query.empty?
                              true
                            else
                              [
                                row.fetch(:name),
                                row.fetch(:role),
                                row.fetch(:endpoint),
                                row.fetch(:mounts).join(" "),
                                row.fetch(:command)
                              ].join(" ").downcase.include?(query)
                            end

            matches_role = role.empty? || row.fetch(:role).to_s == role
            matches_public = public_filter.empty? || row.fetch(:public).to_s == public_filter

            matches_query && matches_role && matches_public
          end

          rows
        end

        def node_filter_values
          {
            "q" => @filter_values.fetch("q", ""),
            "role" => @filter_values.fetch("role", ""),
            "public" => @filter_values.fetch("public", "")
          }
        end

        def node_role_options
          nodes.values.map { |service| service.fetch(:role).to_s }.uniq.sort
        end

        def node_public_options
          [["Public", "true"], ["Private", "false"]]
        end

        def paginated_notes
          notes.slice(note_offset, notes_per_page) || []
        end

        def notes_total_count
          notes.size
        end

        def notes_per_page
          NOTES_PER_PAGE
        end

        def notes_page
          requested = @filter_values.fetch("notes_page", "1").to_i
          requested = 1 unless requested.positive?

          [requested, notes_total_pages].min
        end

        def notes_total_pages
          total = (notes_total_count.to_f / notes_per_page).ceil
          total.positive? ? total : 1
        end

        def notes_page_href(page)
          page = page.to_i
          page = 1 unless page.positive?

          params = @filter_values.each_with_object({}) do |(key, value), memo|
            next if value.nil? || value.to_s.empty?
            memo[key.to_s] = value
          end

          if page == 1
            params.delete("notes_page")
          else
            params["notes_page"] = page.to_s
          end

          query = URI.encode_www_form(params)
          query.empty? ? route("/") : "#{route("/")}?" + query
        end

        def snapshot_preview
          {
            stack: stack,
            counts: counts,
            notes: notes.first(3).map { |note| note.slice("text", "source", "created_at") },
            nodes: nodes.transform_values do |service|
              {
                role: service.fetch(:role),
                endpoint: "#{service.fetch(:host)}:#{service.fetch(:port)}",
                public: service.fetch(:public),
                mounts: service.fetch(:mounts)
              }
            end
          }
        end

        private

        def note_offset
          (notes_page - 1) * notes_per_page
        end
      end
    end
  end
end

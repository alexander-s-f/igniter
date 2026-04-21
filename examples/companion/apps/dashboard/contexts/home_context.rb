# frozen_string_literal: true

require "uri"

module Companion
  module Dashboard
    module Contexts
      class HomeContext
        NOTES_PER_PAGE = 3

        def self.build(snapshot:, base_path:, error_message: nil, form_values: {}, assistant_form_values: {}, filter_values: {},
                       compare_form_values: {}, compare_results: nil)
          new(
            snapshot: snapshot,
            base_path: base_path,
            error_message: error_message,
            form_values: form_values,
            assistant_form_values: assistant_form_values,
            filter_values: filter_values,
            compare_form_values: compare_form_values,
            compare_results: compare_results
          )
        end

        def initialize(snapshot:, base_path:, error_message:, form_values:, assistant_form_values:, filter_values:, compare_form_values:, compare_results:)
          @snapshot = snapshot
          @base_path = base_path.to_s
          @error_message = error_message
          @form_values = form_values
          @assistant_form_values = assistant_form_values
          @filter_values = filter_values
          @compare_form_values = compare_form_values
          @compare_results = compare_results
        end

        attr_reader :snapshot
        attr_reader :error_message
        attr_reader :form_values
        attr_reader :assistant_form_values
        attr_reader :filter_values
        attr_reader :compare_form_values
        attr_reader :compare_results

        def title
          "Companion Operator Desk"
        end

        def description
          "Runtime, notes, and cluster visibility for the Companion operator surface."
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
            { label: "Requests", value: counts.fetch(:assistant_requests, 0), hint: "assistant workflows opened from the desk" }
          ]
        end

        def shell_title
          "Companion"
        end

        def shell_subtitle
          "Operator desk and runtime visibility"
        end

        def operator_desk_href
          route("/")
        end

        def assistant_href
          route("/assistant")
        end

        def current_nav_key
          :desk
        end

        def shell_summary_items
          [
            { label: "Root App", value: stack.fetch(:root_app) },
            { label: "Default Node", value: stack.fetch(:default_node) },
            { label: "Generated", value: generated_at }
          ]
        end

        def shell_sections
          [
            {
              title: "Workspace",
              items: [
                { label: "Operator Desk", href: operator_desk_href, current: current_nav_key == :desk, meta: "home" },
                { label: "Assistant", href: assistant_href, current: current_nav_key == :assistant, meta: "workflow" },
                { label: "Operator Console", href: route("/operator"), meta: "built-in" }
              ]
            },
            {
              title: "APIs",
              items: [
                { label: "Overview API", href: route("/api/overview"), meta: "snapshot" },
                { label: "Operator API", href: route("/api/operator"), meta: "actions" },
                { label: "Main Status", href: "/v1/home/status", meta: "runtime" },
                { label: "Assistant API", href: "/v1/assistant/requests", meta: "workflow" }
              ]
            }
          ]
        end

        def breadcrumbs
          [
            { label: "Companion", href: operator_desk_href },
            { label: "Dashboard", href: operator_desk_href },
            { label: "Operator Desk", current: true }
          ]
        end

        def operator_links
          [
            { label: "Assistant Lane", href: assistant_href },
            { label: "Overview API", href: route("/api/overview") },
            { label: "Operator Console", href: route("/operator") },
            { label: "Operator API", href: route("/api/operator") },
            { label: "Main Status", href: "/v1/home/status" },
            { label: "Assistant API", href: "/v1/assistant/requests" }
          ]
        end

        def assistant
          snapshot.fetch(:assistant, {})
        end

        def assistant_summary
          assistant.fetch(:summary, {})
        end

        def assistant_runtime
          assistant.fetch(:runtime, {})
        end

        def assistant_runtime_config
          assistant_runtime.fetch(:config, {})
        end

        def assistant_runtime_status
          assistant_runtime.fetch(:status, {})
        end

        def assistant_runtime_channels
          assistant_runtime.fetch(:channels, [])
        end

        def assistant_runtime_routing
          assistant_runtime.fetch(:routing, {})
        end

        def assistant_credential_policy
          assistant_runtime.fetch(:credential_policy, {})
        end

        def assistant_requests
          assistant.fetch(:requests, [])
        end

        def assistant_followups
          assistant.fetch(:followups, [])
        end

        def assistant_form_defaults
          {
            "requester" => assistant_form_values.fetch("requester", ""),
            "request" => assistant_form_values.fetch("request", "")
          }
        end

        def assistant_notice
          return "Assistant request opened." if @filter_values["assistant_created"] == "1"
          return "Assistant follow-up completed." if @filter_values["assistant_completed"] == "1"
          return "Assistant request re-delivered." if @filter_values["assistant_redelivered"] == "1"
          return "Assistant runtime updated." if @filter_values["runtime_updated"] == "1"

          nil
        end

        def assistant_runtime_form_defaults
          {
            "mode" => assistant_runtime_config.fetch(:mode, :manual).to_s,
            "provider" => assistant_runtime_config.fetch(:provider, :ollama).to_s,
            "model" => assistant_runtime_config.fetch(:model, "qwen2.5-coder:latest").to_s,
            "base_url" => assistant_runtime_config.fetch(:base_url, "http://127.0.0.1:11434").to_s,
            "timeout_seconds" => assistant_runtime_config.fetch(:timeout_seconds, 20).to_s,
            "delivery_mode" => assistant_runtime_config.fetch(:delivery_mode, :simulate).to_s,
            "delivery_strategy" => assistant_runtime_config.fetch(:delivery_strategy, :prefer_openai).to_s,
            "openai_model" => assistant_runtime_config.fetch(:openai_model, "gpt-4o").to_s,
            "anthropic_model" => assistant_runtime_config.fetch(:anthropic_model, "claude-sonnet-4-6").to_s
          }
        end

        def assistant_request_rows
          assistant_requests.map do |record|
            {
              id: record.fetch(:id),
              requester: record.fetch(:requester),
              status: record.fetch(:status),
              submitted_at: record.fetch(:submitted_at),
              request: record.fetch(:request)
            }
          end
        end

        def actionable_assistant_requests
          assistant_requests.select do |record|
            %i[pending open acknowledged].include?(record.fetch(:status))
          end
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

        def runtime_status
          nodes.empty? ? :pending : :ready
        end

        def primary_node_public?
          nodes.values.first&.fetch(:public, nil)
        end

        def notes_per_node_ratio
          return 0 if nodes.empty?

          notes_total_count.to_f / nodes.size
        end

        def public_node_share
          return 0 if nodes.empty?

          nodes.values.count { |service| service.fetch(:public) }.to_f / nodes.size
        end

        def runtime_signal_rows
          [
            { label: :status, value: runtime_status, as: :indicator },
            { label: :generated_at, value: generated_at, as: :datetime },
            { label: :public_surface, value: primary_node_public?, as: :boolean },
            { label: :mounted_apps, value: stack.fetch(:apps).size, as: :number },
            { label: :notes_per_node, value: notes_per_node_ratio, as: :number },
            { label: :public_node_share, value: public_node_share, as: :percentage }
          ]
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
            assistant_summary: assistant_summary,
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

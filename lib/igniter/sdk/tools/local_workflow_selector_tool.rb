# frozen_string_literal: true

module Igniter
  module Tools
    class LocalWorkflowSelectorTool < Igniter::Tool
      WORKFLOW_CATALOG = [
        {
          id: "ruby_workspace_dev",
          label: "Ruby workspace development",
          goals: %w[general_dev ruby cluster],
          required_utilities: %w[ruby bundle git],
          optional_utilities: %w[rake rspec sqlite3 rg],
          recommended_commands: [
            "bundle install",
            "bundle exec rspec",
            "bin/dev"
          ],
          rationale: "Good default for developing Igniter workspaces and running specs locally."
        },
        {
          id: "platformio_esp32",
          label: "ESP32 firmware development with PlatformIO",
          goals: %w[esp32 hardware embedded],
          required_utilities: %w[pio],
          optional_utilities: %w[python3 git],
          recommended_commands: [
            "pio run",
            "pio run -t upload",
            "pio device monitor"
          ],
          rationale: "Best fit for iterative ESP32 bring-up, firmware flashing, and serial debugging."
        },
        {
          id: "arduino_esp32",
          label: "ESP32 CLI flashing with Arduino/esptool",
          goals: %w[esp32 hardware embedded recovery],
          required_utilities: [],
          alternative_required_sets: [%w[arduino-cli], %w[esptool.py]],
          optional_utilities: %w[python3],
          recommended_commands: [
            "arduino-cli compile",
            "arduino-cli upload",
            "esptool.py --chip esp32 ..."
          ],
          rationale: "Useful as an alternative or recovery path when PlatformIO is not available."
        },
        {
          id: "docker_compose_dev",
          label: "Containerized local stack",
          goals: %w[containers deploy cluster],
          required_utilities: %w[docker],
          optional_utilities: %w[docker-compose],
          recommended_commands: [
            "bin/start --write-compose",
            "docker compose up",
            "docker compose logs -f"
          ],
          rationale: "Useful when the workspace should run as a local multi-process stack with container boundaries."
        },
        {
          id: "local_llm_ollama",
          label: "Local LLM via Ollama",
          goals: %w[ai inference local_llm],
          required_utilities: %w[ollama],
          optional_utilities: %w[curl],
          recommended_commands: [
            "ollama serve",
            "ollama pull <model>"
          ],
          rationale: "Enables local inference experiments without a hosted API."
        },
        {
          id: "media_pipeline",
          label: "Audio/video/media preprocessing",
          goals: %w[media audio video asr tts],
          required_utilities: %w[ffmpeg],
          optional_utilities: %w[python3],
          recommended_commands: [
            "ffmpeg -i input.wav output.mp3"
          ],
          rationale: "Useful for audio normalization, transcoding, and dataset preparation."
        },
        {
          id: "local_sqlite_ops",
          label: "Local SQLite inspection and debugging",
          goals: %w[data sqlite debug],
          required_utilities: %w[sqlite3],
          optional_utilities: %w[rg],
          recommended_commands: [
            "sqlite3 var/app.sqlite3",
            ".tables"
          ],
          rationale: "Helpful for local-first app data inspection and debugging."
        },
        {
          id: "python_sidecar",
          label: "Python sidecar tooling",
          goals: %w[python scripts data],
          required_utilities: %w[python3],
          optional_utilities: %w[pip3],
          recommended_commands: [
            "python3 script.py",
            "pip3 install <package>"
          ],
          rationale: "Useful when the node needs lightweight scripting or data-processing helpers."
        },
        {
          id: "node_frontend_tooling",
          label: "Node-based frontend or tooling workflow",
          goals: %w[node frontend ui tooling],
          required_utilities: %w[node],
          optional_utilities: %w[npm pnpm yarn],
          recommended_commands: [
            "npm install",
            "npm run dev"
          ],
          rationale: "Useful for UI plugins, build tooling, or frontend assets."
        }
      ].freeze

      description "Use a local system snapshot to recommend which development or runtime workflows are actually available on this machine."

      param :goals, type: :array, default: [],
                    desc: "Optional goal tags such as esp32, cluster, ai, media, sqlite, frontend."
      param :include_discovery, type: :boolean, default: true,
                                desc: "Include the underlying system discovery snapshot in the result."
      param :include_unavailable, type: :boolean, default: true,
                                  desc: "Include workflows that are currently unavailable along with missing utilities."
      param :workflow_candidates, type: :array, default: [],
                                  desc: "Optional workflow ids to limit evaluation."
      param :scan_path_entries, type: :boolean, default: false,
                                desc: "Whether to include a discovered executable listing in the underlying discovery step."
      param :path_entry_limit, type: :integer, default: 100,
                               desc: "Maximum number of PATH executables to include when scanning."

      requires_capability :system_read

      def call(goals: [], include_discovery: true, include_unavailable: true, workflow_candidates: [],
               scan_path_entries: false, path_entry_limit: 100)
        discovery = Igniter::Tools::SystemDiscoveryTool.new.call(
          scan_path_entries: scan_path_entries,
          path_entry_limit: path_entry_limit
        )

        goal_list = Array(goals).map(&:to_s).reject(&:empty?)
        selected_workflows = catalog_for(workflow_candidates, goal_list)
        evaluated = evaluate_workflows(selected_workflows, discovery, include_unavailable: include_unavailable)

        {
          generated_at: Time.now.utc.iso8601,
          goals: goal_list,
          available_workflows: evaluated.select { |workflow| workflow[:available] },
          unavailable_workflows: include_unavailable ? evaluated.reject { |workflow| workflow[:available] } : [],
          recommended_workflows: recommended_workflows(evaluated, goal_list),
          suggested_next_steps: suggested_next_steps(evaluated, goal_list),
          discovery: include_discovery ? discovery : nil
        }.compact
      end

      private

      def catalog_for(workflow_candidates, goals)
        workflows = if Array(workflow_candidates).empty?
                      WORKFLOW_CATALOG
                    else
                      requested = Array(workflow_candidates).map(&:to_s)
                      WORKFLOW_CATALOG.select { |workflow| requested.include?(workflow.fetch(:id)) }
                    end

        return workflows if goals.empty?

        tagged = workflows.select do |workflow|
          (workflow.fetch(:goals, []) & goals).any?
        end

        tagged.empty? ? workflows : tagged
      end

      def evaluate_workflows(workflows, discovery, include_unavailable:)
        utilities = Array(discovery.dig(:paths, :utility_candidates))
        availability = utilities.each_with_object({}) do |entry, memo|
          memo[entry.fetch(:name)] = entry.fetch(:present)
        end

        workflows.each_with_object([]) do |workflow, memo|
          evaluated = evaluate_workflow(workflow, availability)
          next if !include_unavailable && !evaluated[:available]

          memo << evaluated
        end
      end

      def evaluate_workflow(workflow, availability)
        required = workflow.fetch(:required_utilities, [])
        optional = workflow.fetch(:optional_utilities, [])
        alternatives = workflow.fetch(:alternative_required_sets, [])

        missing_required = required.reject { |utility| availability[utility] }
        alternative_satisfied = alternatives.empty? || alternatives.any? do |set|
          Array(set).all? { |utility| availability[utility] }
        end

        available = missing_required.empty? && alternative_satisfied
        missing_alternatives = if alternative_satisfied || alternatives.empty?
                                 []
                               else
                                 alternatives.map { |set| Array(set).join(" + ") }
                               end

        {
          id: workflow.fetch(:id),
          label: workflow.fetch(:label),
          goals: workflow.fetch(:goals, []),
          available: available,
          required_utilities: required,
          optional_utilities: optional,
          missing_utilities: missing_required,
          alternative_required_sets: alternatives,
          missing_alternative_sets: missing_alternatives,
          available_optional_utilities: optional.select { |utility| availability[utility] },
          recommended_commands: workflow.fetch(:recommended_commands, []),
          rationale: workflow.fetch(:rationale),
          score: workflow_score(workflow, availability)
        }
      end

      def workflow_score(workflow, availability)
        required = workflow.fetch(:required_utilities, [])
        optional = workflow.fetch(:optional_utilities, [])
        available_required = required.count { |utility| availability[utility] }
        available_optional = optional.count { |utility| availability[utility] }
        base = available_required * 10
        base += available_optional

        if workflow.fetch(:alternative_required_sets, []).any?
          satisfied = workflow.fetch(:alternative_required_sets).any? do |set|
            Array(set).all? { |utility| availability[utility] }
          end
          base += 8 if satisfied
        end

        base
      end

      def recommended_workflows(evaluated, goals)
        list = evaluated.select { |workflow| workflow[:available] }
        list = list.sort_by { |workflow| [-goal_overlap(workflow, goals), -workflow[:score], workflow[:id]] }
        list.first(3)
      end

      def suggested_next_steps(evaluated, goals)
        available = recommended_workflows(evaluated, goals)
        return ["Run system discovery only; no matching workflow was available on this node."] if available.empty?

        available.flat_map do |workflow|
          workflow.fetch(:recommended_commands, []).first(2).map do |command|
            "#{workflow[:label]}: #{command}"
          end
        end
      end

      def goal_overlap(workflow, goals)
        return 0 if goals.empty?

        (Array(workflow[:goals]) & goals).size
      end
    end
  end
end

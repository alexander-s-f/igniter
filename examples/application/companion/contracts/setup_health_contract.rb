# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHealthContract, outputs: %i[status check_count review_count descriptor checks review_items summary] do
      input :readiness
      input :relation_health
      input :manifest_glossary_health
      input :materializer_status_descriptor_health
      input :infrastructure_loop_health

      compute :checks,
              depends_on: %i[
                readiness relation_health manifest_glossary_health
                materializer_status_descriptor_health infrastructure_loop_health
              ] do |readiness:, relation_health:, manifest_glossary_health:, materializer_status_descriptor_health:, infrastructure_loop_health:|
        [
          Companion::Contracts.check(:persistence_ready, readiness.fetch(:status, nil) == :ready),
          Companion::Contracts.check(:relation_health_report_only, relation_health.key?(:relation_reports) && relation_health.key?(:repair_suggestions)),
          Companion::Contracts.check(:manifest_glossary_stable, manifest_glossary_health.fetch(:status, nil) == :stable),
          Companion::Contracts.check(:materializer_descriptor_stable, materializer_status_descriptor_health.fetch(:status, nil) == :stable),
          Companion::Contracts.check(:infrastructure_loop_self_supporting, infrastructure_loop_health.fetch(:status, nil) == :self_supporting)
        ]
      end

      compute :review_items,
              depends_on: %i[readiness relation_health manifest_glossary_health materializer_status_descriptor_health infrastructure_loop_health] do |readiness:, relation_health:, manifest_glossary_health:, materializer_status_descriptor_health:, infrastructure_loop_health:|
        items = []
        items << { kind: :persistence_blocked, detail: readiness.fetch(:summary) } unless readiness.fetch(:status, nil) == :ready
        items << { kind: :relation_warning, count: relation_health.fetch(:warning_count) } if relation_health.fetch(:warning_count).positive?
        items << { kind: :manifest_glossary_drift, terms: manifest_glossary_health.fetch(:missing_terms) } unless manifest_glossary_health.fetch(:missing_terms, []).empty?
        items << { kind: :materializer_descriptor_drift, terms: materializer_status_descriptor_health.fetch(:missing_terms) } unless materializer_status_descriptor_health.fetch(:missing_terms, []).empty?
        items << { kind: :infrastructure_loop_review, detail: infrastructure_loop_health.fetch(:summary) } unless infrastructure_loop_health.fetch(:status, nil) == :self_supporting
        items
      end

      compute :check_count, depends_on: [:checks] do |checks:|
        checks.length
      end

      compute :review_count, depends_on: [:review_items] do |review_items:|
        review_items.length
      end

      compute :status, depends_on: %i[checks review_items] do |checks:, review_items:|
        checks.all? { |check| check.fetch(:present) } && review_items.empty? ? :stable : :needs_review
      end

      compute :descriptor, depends_on: [:checks] do |checks:|
        {
          schema_version: 1,
          kind: :setup_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          sources: %i[
            readiness relation_health manifest_glossary_health
            materializer_status_descriptor_health infrastructure_loop_health
          ],
          check_terms: checks.map { |check| check.fetch(:term) },
          review_item_policy: :diagnostic_only
        }
      end

      compute :summary, depends_on: %i[status check_count review_count] do |status:, check_count:, review_count:|
        "#{status}: #{check_count} setup health checks, #{review_count} review items, report-only."
      end

      output :status
      output :check_count
      output :review_count
      output :descriptor
      output :checks
      output :review_items
      output :summary
    end
  end
end

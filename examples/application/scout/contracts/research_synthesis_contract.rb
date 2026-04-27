# frozen_string_literal: true

require "igniter/contracts"

module Scout
  module Contracts
    class ResearchSynthesisContract
      DIRECTIONS = %w[governance velocity balanced].freeze
      GOVERNANCE_TAGS = %w[governance security policy compliance].freeze
      VELOCITY_TAGS = %w[velocity productivity developer-experience training].freeze

      def self.evaluate(topic:, sources:, checkpoint_choice: nil)
        new(topic: topic, sources: sources, checkpoint_choice: checkpoint_choice).evaluate
      end

      def initialize(topic:, sources:, checkpoint_choice: nil)
        @topic = topic.to_s.strip
        @sources = sources
        @checkpoint_choice = checkpoint_choice&.to_s
      end

      def evaluate
        result = Igniter::Contracts.with.run(inputs: contract_inputs) do
          input :topic
          input :sources
          input :checkpoint_choice

          compute :source_claims, depends_on: [:sources] do |sources:|
            ResearchSynthesisContract.source_claims(sources)
          end

          compute :findings, depends_on: [:source_claims] do |source_claims:|
            ResearchSynthesisContract.findings(source_claims)
          end

          compute :contradictions, depends_on: [:findings] do |findings:|
            ResearchSynthesisContract.contradictions(findings)
          end

          compute :direction_options, depends_on: %i[findings contradictions] do |findings:, contradictions:|
            ResearchSynthesisContract.direction_options(findings, contradictions)
          end

          compute :checkpoint_readiness, depends_on: %i[findings direction_options checkpoint_choice] do |findings:, direction_options:, checkpoint_choice:|
            ResearchSynthesisContract.checkpoint_readiness(findings, direction_options, checkpoint_choice)
          end

          compute :synthesis_payload, depends_on: %i[topic sources findings contradictions direction_options checkpoint_choice checkpoint_readiness] do |topic:, sources:, findings:, contradictions:, direction_options:, checkpoint_choice:, checkpoint_readiness:|
            ResearchSynthesisContract.synthesis_payload(
              topic,
              sources,
              findings,
              contradictions,
              direction_options,
              checkpoint_choice,
              checkpoint_readiness
            )
          end

          output :source_claims
          output :findings
          output :contradictions
          output :direction_options
          output :checkpoint_readiness
          output :synthesis_payload
        end

        {
          topic: topic,
          sources: sources,
          source_claims: result.output(:source_claims),
          findings: result.output(:findings),
          contradictions: result.output(:contradictions),
          direction_options: result.output(:direction_options),
          checkpoint_readiness: result.output(:checkpoint_readiness),
          synthesis_payload: result.output(:synthesis_payload)
        }.freeze
      end

      def self.source_claims(sources)
        sources.flat_map do |source|
          source.fetch(:claims).map do |claim|
            direction = direction_for(source.fetch(:tags), claim.fetch(:statement))
            {
              id: "#{source.fetch(:id)}:#{claim.fetch(:anchor)}",
              source_id: source.fetch(:id),
              source_title: source.fetch(:title),
              source_type: source.fetch(:source_type),
              source_path: source.fetch(:source_path),
              citation_anchor: claim.fetch(:anchor),
              citation_id: "#{source.fetch(:id)}##{claim.fetch(:anchor)}",
              statement: claim.fetch(:statement),
              tags: source.fetch(:tags),
              direction: direction
            }.freeze
          end
        end.freeze
      end

      def self.findings(claims)
        claims.map.with_index do |claim, index|
          {
            id: "finding-#{index + 1}",
            statement: claim.fetch(:statement),
            direction: claim.fetch(:direction),
            confidence_signal: confidence_signal(claim),
            source_refs: [
              {
                source_id: claim.fetch(:source_id),
                citation_id: claim.fetch(:citation_id),
                citation_anchor: claim.fetch(:citation_anchor),
                source_path: claim.fetch(:source_path)
              }.freeze
            ].freeze
          }.freeze
        end.freeze
      end

      def self.contradictions(findings)
        governance = findings.select { |finding| finding.fetch(:direction) == :governance }
        velocity = findings.select { |finding| finding.fetch(:direction) == :velocity }
        return [].freeze if governance.empty? || velocity.empty?

        [
          {
            id: "tension-governance-vs-velocity",
            directions: %i[governance velocity],
            summary: "Sources emphasize both governance controls and adoption speed.",
            supporting_finding_ids: (governance.first(2) + velocity.first(2)).map { |finding| finding.fetch(:id) }.freeze,
            source_refs: (governance.first(2) + velocity.first(2)).flat_map { |finding| finding.fetch(:source_refs) }.freeze
          }.freeze
        ].freeze
      end

      def self.direction_options(findings, contradictions)
        options = findings.map { |finding| finding.fetch(:direction).to_s }.uniq.sort
        options << "balanced" if contradictions.any?
        (options & DIRECTIONS).freeze
      end

      def self.checkpoint_readiness(findings, options, checkpoint_choice)
        choice = checkpoint_choice.to_s
        ready = findings.any? && options.include?(choice)
        {
          ready: ready,
          choice: ready ? choice : nil,
          options: options,
          missing: missing_reason(findings, options, choice)
        }.freeze
      end

      def self.synthesis_payload(topic, sources, findings, contradictions, direction_options, checkpoint_choice, readiness)
        {
          topic: {
            original: topic,
            normalized: topic.downcase
          },
          sources: sources.map { |source| source_payload(source) }.freeze,
          findings: findings,
          contradictions: contradictions,
          checkpoint: {
            choice: readiness.fetch(:choice),
            requested_choice: checkpoint_choice,
            options: direction_options,
            ready: readiness.fetch(:ready)
          },
          synthesis: synthesis_text(topic, findings, readiness.fetch(:choice)),
          provenance: {
            contract: "scout_research_synthesis:v1",
            source_paths: sources.map { |source| source.fetch(:source_path) }.sort
          },
          deferred: [
            { code: :no_network_search, reason: "Scout reads seeded local source fixtures only." },
            { code: :no_llm_provider, reason: "Findings and synthesis are deterministic fixture-derived text." },
            { code: :no_connectors, reason: "External source connectors remain out of scope." },
            { code: :no_live_transport, reason: "Progress is represented by explicit commands and snapshots." }
          ].freeze,
          valid: readiness.fetch(:ready)
        }.freeze
      end

      def self.direction_for(tags, statement)
        text = "#{Array(tags).join(" ")} #{statement}".downcase
        return :governance if GOVERNANCE_TAGS.any? { |tag| text.include?(tag) }
        return :velocity if VELOCITY_TAGS.any? { |tag| text.include?(tag) }

        :balanced
      end

      def self.confidence_signal(claim)
        return :high if claim.fetch(:source_type) == "checklist"
        return :medium if claim.fetch(:source_type) == "internal_note"

        :supporting
      end

      def self.missing_reason(findings, options, choice)
        return :no_findings if findings.empty?
        return :invalid_checkpoint unless options.include?(choice)

        nil
      end

      def self.source_payload(source)
        {
          id: source.fetch(:id),
          title: source.fetch(:title),
          type: source.fetch(:source_type),
          date: source.fetch(:date),
          audience: source.fetch(:audience),
          tags: source.fetch(:tags),
          source_path: source.fetch(:source_path),
          citation_anchors: source.fetch(:claims).map { |claim| claim.fetch(:anchor) }.freeze
        }.freeze
      end

      def self.synthesis_text(topic, findings, choice)
        selected = choice || "balanced"
        selected_findings = findings.select { |finding| finding.fetch(:direction).to_s == selected }
        selected_findings = findings.first(2) if selected_findings.empty?
        statements = selected_findings.first(2).map { |finding| finding.fetch(:statement) }
        "For #{topic}, Scout recommends a #{selected} reading: #{statements.join(" ")}"
      end

      private

      attr_reader :topic, :sources, :checkpoint_choice

      def contract_inputs
        {
          topic: topic,
          sources: sources,
          checkpoint_choice: checkpoint_choice
        }
      end
    end
  end
end

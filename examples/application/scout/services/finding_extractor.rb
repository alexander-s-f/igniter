# frozen_string_literal: true

require_relative "../contracts/research_synthesis_contract"

module Scout
  module Services
    class FindingExtractor
      def analyze(topic:, sources:, checkpoint_choice: nil)
        Contracts::ResearchSynthesisContract.evaluate(
          topic: topic,
          sources: sources,
          checkpoint_choice: checkpoint_choice
        )
      end
    end
  end
end

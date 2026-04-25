# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

require_relative "intent_vocabulary"
require_relative "intent_packet"
require_relative "rule_extractor"
require_relative "local_llm_extractor"

module SemanticGateway
  # The main pipeline. Three-stage adaptive processing:
  #
  #   Stage 1: Rule-based (instant, always runs)
  #   Stage 2: Local LLM enrichment (if confidence < threshold AND ollama available)
  #   Stage 3: Confidence gate — report what couldn't be resolved as residue
  #
  # Output: IntentPacket ready for large LLM API and agent routing.

  class Gateway
    LLM_THRESHOLD = CONFIDENCE_THRESHOLD  # from local_llm_extractor.rb

    Result = Struct.new(
      :packet,        # IntentPacket — the compressed structured intent
      :stage,         # Integer — which stage produced the final result
      :duration_ms,   # Float — total processing time
      :llm_used,      # Boolean — was local LLM invoked?
      keyword_init: true
    ) do
      def to_report
        lines = []
        lines << packet.to_report
        lines << "│"
        lines << "│  Stage:      #{stage} (#{stage_label})"
        lines << "│  LLM used:   #{llm_used ? "yes (local)" : "no (rule-based)"}"
        lines << "│  Time:       #{duration_ms.round(1)}ms"
        lines << "└──────────────────────────────────────────────────────"
        lines.join("\n")
      end

      private

      def stage_label
        case stage
        when 1 then "rule-based, high confidence"
        when 2 then "local LLM enriched"
        when 3 then "residue preserved"
        end
      end
    end

    def self.process(text)
      new.process(text)
    end

    def process(text)
      start = monotonic_ms

      # Stage 1: Rule-based extraction
      packet = RuleExtractor.call(text)

      stage    = 1
      llm_used = false

      # Stage 2: Local LLM enrichment if needed and available
      if packet.confidence < LLM_THRESHOLD && LocalLLMExtractor.available?
        packet   = LocalLLMExtractor.call(text, base_intent: packet)
        stage    = 2
        llm_used = true
      end

      # Stage 3: If still low confidence, tag residue
      if packet.confidence < 0.55
        packet = IntentPacket.new(**packet.to_h.merge(
          residue: packet.residue || text[0..120]
        ))
        stage = 3
      end

      Result.new(
        packet:      packet,
        stage:       stage,
        duration_ms: monotonic_ms - start,
        llm_used:    llm_used
      )
    end

    private

    def monotonic_ms
      Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000
    end
  end
end

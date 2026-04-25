# frozen_string_literal: true

module LineUp
  # Measures how well a LineUp preserves the semantic content of the original.
  #
  # Semantic score: 0–N, one point per required field that is recoverable
  # from the lineup without reading the original text.
  #
  # The economic test (from grammar-compressed-interaction.md):
  #   lineup_tokens + repair_cost < original_tokens  →  compression is worthwhile

  class Scorer
    REQUIRED_FIELDS = %i[task subject roles must forbid evidence next_step].freeze
    AVG_FIELD_PROSE_TOKENS = 25 # conservative estimate of tokens per lost field

    Result = Struct.new(
      :original_tokens,
      :lineup_tokens,
      :compression_ratio,
      :semantic_score,
      :max_semantic_score,
      :fields_preserved,
      :fields_missing,
      :repair_cost,
      :net_value,
      :verdict,
      keyword_init: true
    ) do
      def to_report
        lines = []
        lines << "┌─ Compression Report ─────────────────────────────────"
        lines << "│  Original:    #{original_tokens} tokens"
        lines << "│  Line-Up:     #{lineup_tokens} tokens"
        lines << "│  Ratio:       #{format("%.2fx", compression_ratio)}"
        lines << "│"
        lines << "│  Semantic:    #{semantic_score}/#{max_semantic_score} fields preserved"
        lines << "│  Preserved:   #{fields_preserved.join(", ")}"
        lines << "│  Missing:     #{fields_missing.empty? ? "none" : fields_missing.join(", ")}"
        lines << "│"
        lines << "│  Repair cost: #{repair_cost} tokens"
        lines << "│  Net value:   #{net_value > 0 ? "+#{net_value}" : net_value} tokens"
        lines << "│  Verdict:     #{verdict}"
        lines << "└──────────────────────────────────────────────────────"
        lines.join("\n")
      end
    end

    def self.score(lineup, original_text)
      new.score(lineup, original_text)
    end

    def score(lineup, original_text)
      original_tokens = estimate_tokens(original_text)
      lineup_tokens   = lineup.token_count

      preserved, missing = check_fields(lineup)
      semantic_score     = preserved.length

      repair_cost = missing.length * AVG_FIELD_PROSE_TOKENS
      net_value   = original_tokens - (lineup_tokens + repair_cost)

      @original_tokens = original_tokens
      Result.new(
        original_tokens:    original_tokens,
        lineup_tokens:      lineup_tokens,
        compression_ratio:  original_tokens.to_f / [lineup_tokens, 1].max,
        semantic_score:     semantic_score,
        max_semantic_score: REQUIRED_FIELDS.length,
        fields_preserved:   preserved,
        fields_missing:     missing,
        repair_cost:        repair_cost,
        net_value:          net_value,
        verdict:            verdict(net_value, semantic_score)
      )
    end

    # Session-scale economics: how does compression pay off at N messages?
    def self.session_economics(avg_original_tokens:, avg_lineup_tokens:, grammar_cost: 200, n_messages: 50)
      compressed_total = grammar_cost + (avg_lineup_tokens * n_messages)
      prose_total      = avg_original_tokens * n_messages
      saving           = prose_total - compressed_total
      break_even       = (grammar_cost.to_f / [avg_original_tokens - avg_lineup_tokens, 1].max).ceil

      {
        n_messages:       n_messages,
        grammar_cost:     grammar_cost,
        compressed_total: compressed_total,
        prose_total:      prose_total,
        saving:           saving,
        saving_pct:       (saving.to_f / prose_total * 100).round(1),
        break_even:       break_even
      }
    end

    private

    def check_fields(lineup)
      preserved = []
      missing   = []

      REQUIRED_FIELDS.each do |field|
        val = lineup.send(field)
        filled = val && !(val.respond_to?(:empty?) ? val.empty? : false)
        filled ? preserved << field : missing << field
      end

      [preserved, missing]
    end

    def estimate_tokens(text)
      # Conservative: chars / 4
      (text.length / 4.0).ceil
    end

    def verdict(net_value, semantic_score)
      if semantic_score == REQUIRED_FIELDS.length && net_value > 0
        "✓ worthwhile — full semantic preservation, positive net value"
      elsif semantic_score >= REQUIRED_FIELDS.length - 1 && net_value > 0
        "~ acceptable — minor field loss, still saves tokens"
      elsif net_value <= 0 && original_tokens < 80
        "→ already lean — message too short to benefit from compression"
      elsif net_value <= 0
        "✗ not worthwhile — repair cost exceeds compression gain"
      else
        "! semantic loss — #{REQUIRED_FIELDS.length - semantic_score} fields missing"
      end
    end

    def original_tokens
      @original_tokens ||= 0
    end
  end
end

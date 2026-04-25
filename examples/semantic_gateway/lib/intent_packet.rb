# frozen_string_literal: true

module SemanticGateway
  # The structured output of the gateway — what agents and the large LLM receive.
  # Compact, routable, unambiguous.

  IntentPacket = Struct.new(
    :action,      # Symbol  — what to do (:create, :fix, :explain, ...)
    :domains,     # Array   — which domains are in scope
    :subject,     # String  — what specifically (extracted noun phrase)
    :style,       # Array   — implicit quality constraints
    :urgency,     # Symbol  — :high / :normal / :low
    :route,       # Array   — which agents handle this
    :confidence,  # Float   — 0.0-1.0, how sure we are
    :residue,     # String? — anything that couldn't be compressed
    :source_tokens, # Integer — original token count
    keyword_init: true
  ) do
    def to_compact
      # Deliberately minimal — shared vocabulary handles expansion on the other end
      dom  = domains.map { |d| d.to_s.split("_").first(2).join("_") }.join("+")
      sty  = style.empty? ? "" : " [#{style.map { |s| s.to_s.gsub(/keep_|no_|follow_|with_/, "") }.join(",")}]"
      urg  = urgency == :normal ? "" : " !#{urgency}"
      rte  = route == :broadcast ? "→all" : "→#{route.map { |r| r.to_s.split("_").last(2).join("_") }.join(",")}"
      res  = residue ? "; residue:#{residue[0..40].inspect}" : ""
      subj = subject ? " #{subject}" : ""

      "intent(:#{action},#{dom}#{subj}#{sty}#{urg},#{rte},#{confidence})#{res}"
    end

    def to_agent_slice(agent)
      relevant_domains = domains.select { |d|
        (IntentVocabulary::ROUTING[d] || []).include?(agent)
      }
      IntentPacket.new(
        action:       action,
        domains:      relevant_domains,
        subject:      subject,
        style:        style,
        urgency:      urgency,
        route:        [agent],
        confidence:   confidence,
        residue:      residue,
        source_tokens: source_tokens
      )
    end

    def token_count
      (to_compact.length / 4.0).ceil
    end

    def compression_ratio
      return 1.0 if source_tokens.to_i == 0
      (source_tokens.to_f / token_count).round(2)
    end

    def to_report
      lines = []
      lines << "┌─ Intent Parse ───────────────────────────────────────"
      lines << "│  Action:     #{action}"
      lines << "│  Domains:    #{domains.join(", ")}"
      lines << "│  Subject:    #{subject || "(none extracted)"}"
      lines << "│  Style:      #{style.empty? ? "(none)" : style.join(", ")}"
      lines << "│  Urgency:    #{urgency}"
      lines << "│  Route:      → #{route_display}"
      lines << "│  Confidence: #{(confidence * 100).round}%"
      lines << "│"
      lines << "│  Source:     #{source_tokens} tokens"
      lines << "│  Packet:     #{token_count} tokens"
      lines << "│  Ratio:      #{compression_ratio}x"
      lines << "│  Residue:    #{residue ? residue[0..60] : "none"}"
      lines << "└──────────────────────────────────────────────────────"
      lines.join("\n")
    end

    private

    def route_display
      route == :broadcast ? "ALL agents" : route.map { |r| ":#{r}" }.join(", ")
    end
  end
end

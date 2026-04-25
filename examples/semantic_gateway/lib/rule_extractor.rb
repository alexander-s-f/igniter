# frozen_string_literal: true

require_relative "intent_vocabulary"
require_relative "intent_packet"

module SemanticGateway
  # Stage 1: Rule-based intent extraction.
  # Instant, deterministic, no LLM required.
  # Covers ~60% of common human requests at confidence > 0.75.

  class RuleExtractor
    def self.call(text)
      new(text).extract
    end

    def initialize(text)
      @text = text.strip
    end

    def extract
      action  = IntentVocabulary.extract_intent(@text)
      domains = IntentVocabulary.extract_domains(@text)
      style   = IntentVocabulary.extract_style(@text)
      urgency = IntentVocabulary.extract_urgency(@text)
      subject = extract_subject(@text, domains)
      route   = IntentVocabulary.routing_for(domains, action)

      confidence = calculate_confidence(action, domains, subject)

      IntentPacket.new(
        action:        action,
        domains:       domains,
        subject:       subject,
        style:         style,
        urgency:       urgency,
        route:         route,
        confidence:    confidence,
        residue:       nil,
        source_tokens: estimate_tokens(@text)
      )
    end

    private

    def extract_subject(text, domains)
      # Try to extract the noun phrase that is the target of the action.
      # Strategy: look for quoted terms, then domain-specific nouns.
      if (m = text.match(/"([^"]+)"|`([^`]+)`/))
        return (m[1] || m[2]).strip
      end

      # Domain-specific extraction heuristics
      case domains.first
      when :authentication
        return "login_page"    if text.match?(/login.?page|sign.?in.?page/i)
        return "registration"  if text.match?(/register|sign.?up/i)
        return "password_reset" if text.match?(/password.?reset|forgot.?password/i)
        "auth_flow"
      when :data_layer
        if (m = text.match(/\b(the\s+)?(\w+)\s+(table|model|query|record|schema)/i))
          return m[2].downcase
        end
        "data_query"
      when :frontend
        if (m = text.match(/\b(\w+)\s+(page|form|component|view|modal|button)/i))
          return "#{m[1].downcase}_#{m[2].downcase}"
        end
        "ui_component"
      when :api_layer
        if (m = text.match(%r{/([\w/]+)|(\w+)\s+endpoint|([a-z]\w{3,})\s+api}i))
          candidate = (m[1] || m[2] || m[3])&.downcase
          return candidate if candidate && !%w[the a an this our].include?(candidate)
        end
        "api_endpoint"
      when :optimize
        if (m = text.match(/\b(the\s+)?(\w+)\s+(query|request|method|function|call)/i))
          return m[2].downcase
        end
        "performance"
      else
        # Fallback: find a noun after common action words
        if (m = text.match(/\b(?:add|fix|create|build|update|review|check)\s+(?:a\s+|an\s+|the\s+)?([a-z]\w{3,20})(?:\s+to|\s+in|\s+for|[,.]|\s*$)/i))
          candidate = m[1].strip.downcase
          candidate unless %w[the a an this that it its].include?(candidate)
        end
      end
    end

    def calculate_confidence(action, domains, subject)
      score = 0.0
      score += 0.35 if action != :unknown
      score += 0.30 unless domains.empty?
      score += 0.25 if subject
      score += 0.10 if domains.length >= 2   # multi-domain = clearer intent
      [score, 1.0].min.round(2)
    end

    def estimate_tokens(text)
      (text.length / 4.0).ceil
    end
  end
end

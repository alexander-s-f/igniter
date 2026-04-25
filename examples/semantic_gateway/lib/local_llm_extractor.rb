# frozen_string_literal: true

module SemanticGateway
  # Stage 2: Local LLM enrichment.
  # Uses a small model (Phi-3 Mini, Qwen2.5-3B, Llama 3.2-3B) running locally
  # via ollama or llama.cpp to enrich what rule-based extraction missed.
  #
  # Runs only when rule-based confidence < CONFIDENCE_THRESHOLD.
  # Falls back gracefully if no local LLM is available.
  #
  # To activate: install ollama and pull a model:
  #   brew install ollama && ollama pull phi3:mini
  #   or: ollama pull qwen2.5:3b

  CONFIDENCE_THRESHOLD = 0.75

  class LocalLLMExtractor
    DEFAULT_MODEL  = "phi3:mini".freeze
    OLLAMA_URL     = "http://localhost:11434/api/generate".freeze
    TIMEOUT_SECS   = 8

    def self.call(text, base_intent:, vocabulary: IntentVocabulary)
      new(text, base_intent: base_intent, vocabulary: vocabulary).enrich
    end

    def self.available?
      require "net/http"
      uri = URI("http://localhost:11434/api/tags")
      resp = Net::HTTP.get_response(uri)
      resp.is_a?(Net::HTTPSuccess)
    rescue StandardError
      false
    end

    def initialize(text, base_intent:, vocabulary:)
      @text         = text
      @base_intent  = base_intent
      @vocabulary   = vocabulary
    end

    def enrich
      return @base_intent unless self.class.available?

      raw = query_llm(build_prompt)
      parsed = parse_llm_output(raw)
      merge_with_base(parsed)
    rescue StandardError => e
      # LLM failure is non-fatal — fall back to rule-based result
      warn "LocalLLM unavailable: #{e.message}" if ENV["DEBUG"]
      @base_intent
    end

    private

    EXTRACTION_PROMPT = <<~PROMPT.freeze
      You are a semantic extractor for an AI agent system.
      Given a human request, extract a structured intent.

      OUTPUT FORMAT (one field per line, skip unknown fields):
        action: one of [create, fix, explain, review, deploy, refactor, test, optimize, migrate, document]
        domain: one or more of [authentication, data_layer, frontend, api_layer, infrastructure, ai_layer, testing, security]
        subject: the specific thing being acted on (short noun phrase, snake_case)
        style: comma-separated constraints [keep_simple, production_grade, no_external_deps, follow_existing_pattern, expedite, no_breaking_changes, with_tests]
        urgency: one of [high, normal, low]
        residue: anything important that doesn't fit the above fields (verbatim quote, max 20 words)
        confidence: 0.0 to 1.0

      RULES:
        - Be sparse: only output fields where you are confident
        - subject should be short (1-4 words, snake_case)
        - If the request is ambiguous, reflect that in confidence (< 0.7)
        - residue: only use for truly irreducible information

      REQUEST: %<text>s

      OUTPUT:
    PROMPT

    def build_prompt
      format(EXTRACTION_PROMPT, text: @text)
    end

    def query_llm(prompt)
      require "net/http"
      require "json"

      uri  = URI(OLLAMA_URL)
      body = { model: DEFAULT_MODEL, prompt: prompt, stream: false }.to_json

      req              = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body         = body

      resp = Net::HTTP.start(uri.host, uri.port, read_timeout: TIMEOUT_SECS) do |http|
        http.request(req)
      end

      JSON.parse(resp.body)["response"].to_s.strip
    end

    def parse_llm_output(raw)
      result = {}

      raw.each_line do |line|
        line = line.strip
        next if line.empty?

        key, _, value = line.partition(":")
        key   = key.strip.downcase.to_sym
        value = value.strip

        case key
        when :action
          result[:action] = value.to_sym if IntentVocabulary::INTENTS.key?(value.to_sym)
        when :domain
          result[:domains] = value.split(/,\s*/).filter_map { |d|
            sym = d.strip.to_sym
            sym if IntentVocabulary::DOMAINS.key?(sym)
          }
        when :subject
          result[:subject] = value.gsub(/\s+/, "_").downcase unless value.empty?
        when :style
          result[:style] = value.split(/,\s*/).filter_map { |s|
            sym = s.strip.to_sym
            sym if IntentVocabulary::STYLE_SIGNALS.key?(sym)
          }
        when :urgency
          result[:urgency] = value.to_sym if %i[high normal low].include?(value.to_sym)
        when :residue
          result[:residue] = value unless value.empty? || value.downcase == "none"
        when :confidence
          result[:confidence] = [[value.to_f, 0.0].max, 1.0].min
        end
      end

      result
    end

    def merge_with_base(llm_result)
      # LLM output wins on specific fields, rule-based wins on routing
      merged_domains = ((@base_intent.domains || []) + (llm_result[:domains] || [])).uniq
      merged_style   = ((@base_intent.style   || []) + (llm_result[:style]   || [])).uniq

      action     = llm_result[:action]     || @base_intent.action
      subject    = llm_result[:subject]    || @base_intent.subject
      urgency    = llm_result[:urgency]    || @base_intent.urgency
      confidence = llm_result[:confidence] || @base_intent.confidence
      residue    = llm_result[:residue]    || @base_intent.residue

      route = IntentVocabulary.routing_for(merged_domains, action)

      IntentPacket.new(
        action:        action,
        domains:       merged_domains,
        subject:       subject,
        style:         merged_style,
        urgency:       urgency,
        route:         route,
        confidence:    confidence,
        residue:       residue,
        source_tokens: @base_intent.source_tokens
      )
    end
  end
end

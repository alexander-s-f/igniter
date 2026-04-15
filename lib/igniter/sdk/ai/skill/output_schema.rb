# frozen_string_literal: true

require "json"

module Igniter
  module AI
    # DSL for declaring a typed JSON output contract on a Skill.
    #
    # When an +output_schema+ block is given, the Skill automatically:
    #   1. Appends a JSON instruction to every prompt sent to the LLM.
    #   2. Parses the LLM response as JSON on return.
    #   3. Wraps the parsed data in a +StructuredResult+ with field readers.
    #
    # == Definition
    #
    #   class AnalysisSkill < Igniter::AI::Skill
    #     output_schema do
    #       field :summary,    String
    #       field :confidence, Float
    #       field :sources,    Array
    #     end
    #   end
    #
    # == Usage
    #
    #   result = AnalysisSkill.call(document: "...")
    #   result.summary     # => "This document covers..."
    #   result.confidence  # => 0.91
    #   result.to_h        # => { summary: "...", confidence: 0.91, sources: [...] }
    class Skill::OutputSchema
      # Raised when the LLM response cannot be parsed into the declared schema.
      class ParseError < Igniter::Error; end

      # Maps Ruby constant types to JSON Schema type strings.
      TYPE_MAP = {
        String => "string",
        Integer => "number",
        Float => "number",
        Array => "array",
        Hash => "object"
      }.freeze

      Field = Struct.new(:name, :type, keyword_init: true)

      def initialize(&block)
        @fields = []
        instance_eval(&block) if block
      end

      # Declare a field in the output schema.
      # @param name [Symbol, String] field name
      # @param type [Class]          expected Ruby type (String, Integer, Float, Array, Hash)
      def field(name, type)
        @fields << Field.new(name: name.to_sym, type: type)
        self
      end

      # Frozen array of declared fields.
      def fields
        @fields.dup
      end

      # Human-readable JSON description injected into the prompt.
      # Example: { "summary": string, "confidence": number }
      def to_json_description
        pairs = @fields.map { |f| "\"#{f.name}\": #{TYPE_MAP.fetch(f.type, "string")}" }
        "{ #{pairs.join(", ")} }"
      end

      # Parse LLM response text into a +StructuredResult+.
      # Extracts the first JSON object found in +text+.
      #
      # @param text [String] raw LLM response
      # @return [StructuredResult]
      # @raise [ParseError] if no JSON object is found or JSON is invalid
      def parse(text)
        json_str = text.match(/\{.*\}/m)&.to_s
        raise ParseError, "No JSON object found in LLM response" unless json_str

        data = JSON.parse(json_str)
        Skill::StructuredResult.new(@fields, data)
      rescue JSON::ParserError => e
        raise ParseError, "Invalid JSON in LLM response: #{e.message}"
      end
    end

    # A typed result object returned by skills with an +output_schema+.
    # Provides reader methods for each declared field plus +to_h+ / +to_json+.
    class Skill::StructuredResult
      def initialize(fields, data)
        @fields = fields
        @data   = data.transform_keys(&:to_sym)
        fields.each { |f| define_singleton_method(f.name) { @data[f.name] } }
      end

      # Returns a plain Hash keyed by field names (symbols).
      def to_h
        @fields.each_with_object({}) { |f, h| h[f.name] = @data[f.name] }
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      def inspect
        "#<Igniter::AI::Skill::StructuredResult #{to_h}>"
      end
    end
  end
end

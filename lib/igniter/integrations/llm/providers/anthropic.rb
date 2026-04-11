# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Igniter
  module LLM
    module Providers
      # Anthropic Claude provider.
      # Requires ANTHROPIC_API_KEY environment variable or explicit api_key:.
      #
      # API docs: https://docs.anthropic.com/en/api/messages
      #
      # Key differences from OpenAI-compatible providers:
      #   - system prompt is a top-level field, not a message
      #   - response content is an array of typed blocks (text, tool_use)
      #   - tool definitions use input_schema instead of parameters
      class Anthropic < Base # rubocop:disable Metrics/ClassLength
        ANTHROPIC_VERSION = "2023-06-01"
        API_BASE = "https://api.anthropic.com"

        def initialize(api_key: ENV["ANTHROPIC_API_KEY"], base_url: API_BASE, timeout: 120)
          super()
          @api_key = api_key
          @base_url = base_url.chomp("/")
          @timeout = timeout
        end

        # Send a chat completion request.
        # Extracts any system message from the messages array automatically.
        def chat(messages:, model:, tools: [], **options) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          validate_api_key!

          system_content, chat_messages = extract_system(messages)

          body = {
            model: model,
            max_tokens: options.delete(:max_tokens) || 4096,
            messages: chat_messages
          }
          body[:system] = system_content if system_content
          body[:tools] = normalize_tools(tools) if tools.any?
          body[:temperature] = options[:temperature] if options[:temperature]
          body[:top_p] = options[:top_p] if options[:top_p]

          response = post("/v1/messages", body)
          parse_response(response)
        end

        private

        def extract_system(messages)
          system_msg = messages.find { |m| (m[:role] || m["role"]).to_s == "system" }
          other = messages.reject { |m| (m[:role] || m["role"]).to_s == "system" }
          system_content = system_msg ? (system_msg[:content] || system_msg["content"]) : nil
          [system_content, normalize_messages(other)]
        end

        def parse_response(response) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          content_blocks = response.fetch("content", [])

          text_content = content_blocks
                         .select { |b| b["type"] == "text" }
                         .map { |b| b["text"] }
                         .join

          tool_calls = content_blocks
                       .select { |b| b["type"] == "tool_use" }
                       .map do |b|
            {
              id:        b["id"].to_s,
              name:      b["name"].to_s,
              arguments: (b["input"] || {}).transform_keys(&:to_sym),
            }
          end

          usage = response.fetch("usage", {})
          record_usage(
            prompt_tokens: usage["input_tokens"] || 0,
            completion_tokens: usage["output_tokens"] || 0
          )

          { role: :assistant, content: text_content, tool_calls: tool_calls }
        end

        def normalize_messages(messages) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          messages.flat_map do |m|
            role = (m[:role] || m["role"]).to_sym

            case role
            when :assistant
              calls = Array(m[:tool_calls])
              if calls.any?
                # Anthropic requires tool_use blocks inside the content array
                blocks = []
                blocks << { "type" => "text", "text" => m[:content].to_s } unless m[:content].to_s.empty?
                calls.each do |tc|
                  blocks << {
                    "type"  => "tool_use",
                    "id"    => tc[:id].to_s,
                    "name"  => tc[:name].to_s,
                    "input" => (tc[:arguments] || {}).transform_keys(&:to_s),
                  }
                end
                [{ "role" => "assistant", "content" => blocks }]
              else
                [{ "role" => "assistant", "content" => m[:content].to_s }]
              end
            when :tool_results
              # All results for one LLM turn → single user message with tool_result blocks
              blocks = Array(m[:results]).map do |r|
                { "type" => "tool_result", "tool_use_id" => r[:id].to_s, "content" => r[:content].to_s }
              end
              [{ "role" => "user", "content" => blocks }]
            else
              [{ "role" => role.to_s, "content" => (m[:content] || m["content"]).to_s }]
            end
          end
        end

        def normalize_tools(tools)
          tools.map do |tool|
            {
              "name" => tool[:name].to_s,
              "description" => tool[:description].to_s,
              "input_schema" => tool.fetch(:parameters) { { "type" => "object", "properties" => {} } }
            }
          end
        end

        def post(path, body) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          uri = URI.parse("#{@base_url}#{path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = uri.scheme == "https"
          http.read_timeout = @timeout
          http.open_timeout = 10

          request = Net::HTTP::Post.new(uri.path, headers)
          request.body = JSON.generate(body)

          response = http.request(request)
          handle_response(response)
        rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout => e
          raise Igniter::LLM::ProviderError, "Cannot connect to Anthropic API: #{e.message}"
        end

        def headers
          {
            "Content-Type" => "application/json",
            "x-api-key" => @api_key.to_s,
            "anthropic-version" => ANTHROPIC_VERSION
          }
        end

        def handle_response(response) # rubocop:disable Metrics/MethodLength
          unless response.is_a?(Net::HTTPSuccess)
            body = begin
              JSON.parse(response.body)
            rescue StandardError
              {}
            end
            error_msg = body.dig("error", "message") || response.body.to_s.slice(0, 200)
            raise Igniter::LLM::ProviderError, "Anthropic API error #{response.code}: #{error_msg}"
          end

          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise Igniter::LLM::ProviderError, "Anthropic returned invalid JSON: #{e.message}"
        end

        def validate_api_key!
          return if @api_key && !@api_key.empty?

          raise Igniter::LLM::ConfigurationError,
                "Anthropic API key not configured. Set ANTHROPIC_API_KEY or pass api_key: to the provider."
        end
      end
    end
  end
end

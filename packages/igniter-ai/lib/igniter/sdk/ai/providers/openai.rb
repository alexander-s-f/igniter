# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Igniter
  module AI
    module Providers
      # OpenAI provider (also compatible with Azure OpenAI and any OpenAI-compatible API).
      # Requires OPENAI_API_KEY environment variable or explicit api_key:.
      #
      # API docs: https://platform.openai.com/docs/api-reference/chat
      #
      # Compatible with: OpenAI, Azure OpenAI, Groq, Together AI,
      #                  Mistral, DeepSeek, and any OpenAI-compatible endpoint.
      class OpenAI < Base # rubocop:disable Metrics/ClassLength
        API_BASE = "https://api.openai.com"

        def initialize(api_key: ENV["OPENAI_API_KEY"], base_url: API_BASE, timeout: 120)
          super()
          @api_key = api_key
          @base_url = base_url.chomp("/")
          @timeout = timeout
        end

        # Send a chat completion request.
        def chat(messages:, model:, tools: [], **options) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          validate_api_key!

          body = {
            model: model,
            messages: normalize_messages(messages)
          }
          body[:tools] = normalize_tools(tools) if tools.any?
          body[:temperature] = options[:temperature] if options.key?(:temperature)
          body[:top_p] = options[:top_p] if options.key?(:top_p)
          body[:max_tokens] = options[:max_tokens] if options.key?(:max_tokens)
          body[:seed] = options[:seed] if options.key?(:seed)
          body[:stop] = options[:stop] if options.key?(:stop)

          response = post("/v1/chat/completions", body)
          parse_response(response)
        end

        private

        def parse_response(response) # rubocop:disable Metrics/MethodLength
          message = response.dig("choices", 0, "message") || {}
          usage = response.fetch("usage", {})

          record_usage(
            prompt_tokens: usage["prompt_tokens"] || 0,
            completion_tokens: usage["completion_tokens"] || 0
          )

          {
            role: (message["role"] || "assistant").to_sym,
            content: message["content"].to_s,
            tool_calls: parse_tool_calls(message["tool_calls"])
          }
        end

        def parse_tool_calls(raw)
          return [] unless raw.is_a?(Array)

          raw.map do |tc|
            fn = tc["function"] || {}
            {
              id:        tc["id"].to_s,
              name:      fn["name"].to_s,
              arguments: parse_arguments(fn["arguments"]),
            }
          end
        end

        def parse_arguments(args)
          case args
          when Hash then args.transform_keys(&:to_sym)
          when String then JSON.parse(args).transform_keys(&:to_sym)
          else {}
          end
        rescue JSON::ParserError
          {}
        end

        def normalize_messages(messages) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          messages.flat_map do |m|
            role = (m[:role] || m["role"]).to_sym

            case role
            when :assistant
              calls = Array(m[:tool_calls])
              if calls.any?
                # OpenAI assistant message with tool_calls field
                formatted = calls.map do |tc|
                  {
                    "id"       => tc[:id].to_s,
                    "type"     => "function",
                    "function" => {
                      "name"      => tc[:name].to_s,
                      "arguments" => JSON.generate(tc[:arguments] || {}),
                    },
                  }
                end
                [{ "role" => "assistant", "content" => m[:content].to_s, "tool_calls" => formatted }]
              else
                [{ "role" => "assistant", "content" => m[:content].to_s }]
              end
            when :tool_results
              # OpenAI expects one :tool message per result
              Array(m[:results]).map do |r|
                { "role" => "tool", "tool_call_id" => r[:id].to_s, "name" => r[:name].to_s, "content" => r[:content].to_s }
              end
            else
              [{ "role" => role.to_s, "content" => (m[:content] || m["content"]).to_s }]
            end
          end
        end

        def normalize_tools(tools)
          tools.map do |tool|
            {
              "type" => "function",
              "function" => {
                "name" => tool[:name].to_s,
                "description" => tool[:description].to_s,
                "parameters" => tool.fetch(:parameters) { { "type" => "object", "properties" => {} } }
              }
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
          raise Igniter::AI::ProviderError, "Cannot connect to OpenAI API at #{@base_url}: #{e.message}"
        end

        def headers
          {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{@api_key}"
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
            raise Igniter::AI::ProviderError, "OpenAI API error #{response.code}: #{error_msg}"
          end

          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise Igniter::AI::ProviderError, "OpenAI returned invalid JSON: #{e.message}"
        end

        def validate_api_key!
          return if @api_key && !@api_key.empty?

          raise Igniter::AI::ConfigurationError,
                "OpenAI API key not configured. Set OPENAI_API_KEY or pass api_key: to the provider."
        end
      end
    end
  end
end

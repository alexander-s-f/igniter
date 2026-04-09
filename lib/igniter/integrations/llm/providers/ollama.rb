# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Igniter
  module LLM
    module Providers
      # Ollama provider — calls the local Ollama REST API.
      # Requires Ollama to be running: https://ollama.com
      #
      # Ollama API docs: https://github.com/ollama/ollama/blob/main/docs/api.md
      class Ollama < Base
        def initialize(base_url: "http://localhost:11434", timeout: 120)
          super()
          @base_url = base_url.chomp("/")
          @timeout = timeout
        end

        # Send a chat completion request.
        # Returns: { role: "assistant", content: "...", tool_calls: [...] }
        def chat(messages:, model:, tools: [], **options) # rubocop:disable Metrics/MethodLength
          body = {
            model: model,
            messages: normalize_messages(messages),
            stream: false,
            options: build_options(options)
          }.compact

          body[:tools] = normalize_tools(tools) if tools.any?

          response = post("/api/chat", body)

          message = response.fetch("message", {})
          record_usage(
            prompt_tokens: response["prompt_eval_count"] || 0,
            completion_tokens: response["eval_count"] || 0
          )

          {
            role: message.fetch("role", "assistant").to_sym,
            content: message.fetch("content", ""),
            tool_calls: parse_tool_calls(message["tool_calls"])
          }
        end

        def models
          get("/api/tags").fetch("models", []).map { |m| m["name"] }
        end

        private

        def post(path, body)
          uri = URI.parse("#{@base_url}#{path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.read_timeout = @timeout
          http.open_timeout = 10

          request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
          request.body = JSON.generate(body)

          response = http.request(request)
          handle_response(response)
        rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout => e
          raise Igniter::LLM::ProviderError, "Cannot connect to Ollama at #{@base_url}: #{e.message}"
        end

        def get(path)
          uri = URI.parse("#{@base_url}#{path}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = 10
          response = http.get(uri.path)
          handle_response(response)
        end

        def handle_response(response)
          unless response.is_a?(Net::HTTPSuccess)
            raise Igniter::LLM::ProviderError,
                  "Ollama API error #{response.code}: #{response.body.to_s.slice(0, 200)}"
          end

          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise Igniter::LLM::ProviderError, "Ollama returned invalid JSON: #{e.message}"
        end

        def normalize_messages(messages)
          messages.map do |msg|
            { "role" => msg[:role].to_s, "content" => msg[:content].to_s }
          end
        end

        def normalize_tools(tools)
          tools.map do |tool|
            {
              "type" => "function",
              "function" => {
                "name" => tool[:name].to_s,
                "description" => tool[:description].to_s,
                "parameters" => tool.fetch(:parameters, { type: "object", properties: {} })
              }
            }
          end
        end

        def parse_tool_calls(raw)
          return [] unless raw.is_a?(Array)

          raw.map do |tc|
            fn = tc["function"] || tc
            {
              name: fn["name"].to_s,
              arguments: parse_arguments(fn["arguments"])
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

        def build_options(opts)
          known = %i[temperature top_p top_k seed num_predict stop]
          filtered = opts.slice(*known)
          filtered.empty? ? nil : filtered.transform_keys(&:to_s)
        end
      end
    end
  end
end

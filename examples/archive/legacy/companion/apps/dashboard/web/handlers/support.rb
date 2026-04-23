# frozen_string_literal: true

require "uri"

module Companion
  module Dashboard
    module Handlers
      module Support
        module_function

        def base_path_for(env)
          env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
        end

        def query_params_for(env)
          URI.decode_www_form(env.fetch("QUERY_STRING", "").to_s).each_with_object({}) do |(key, value), memo|
            memo[key.to_s] = value
          end
        end

        def route_for(base_path, path)
          prefix = base_path.to_s.sub(%r{/+\z}, "")
          return path if prefix.empty?

          [prefix, path.sub(%r{\A/}, "")].join("/")
        end
      end
    end
  end
end

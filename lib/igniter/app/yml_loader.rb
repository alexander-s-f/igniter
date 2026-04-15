# frozen_string_literal: true

require "yaml"

module Igniter
  class App
    # Loads an app.yml and applies values to an AppConfig.
    # YAML is loaded BEFORE the Ruby configure block, so blocks always win.
    #
    # Supported YAML structure:
    #   app_host:
    #     port: 4567
    #     host: "0.0.0.0"
    #     log_format: json        # "text" or "json"
    #     drain_timeout: 30
    class YmlLoader
      APP_HOST_MAPPINGS = {
        "port" => ->(cfg, v) { cfg.app_host.port = Integer(v) },
        "host" => ->(cfg, v) { cfg.app_host.host = v.to_s },
        "log_format" => ->(cfg, v) { cfg.app_host.log_format = v.to_sym },
        "drain_timeout" => ->(cfg, v) { cfg.app_host.drain_timeout = Integer(v) }
      }.freeze

      def self.load(path)
        return {} unless File.exist?(path.to_s)

        YAML.safe_load(File.read(path)) || {}
      end

      def self.apply(config, yml)
        apply_app_host_section(config, yml["app_host"] || {})
      end

      def self.apply_app_host_section(config, section)
        APP_HOST_MAPPINGS.each do |key, setter|
          value = section[key]
          setter.call(config, value) unless value.nil?
        end
      end
    end
  end
end

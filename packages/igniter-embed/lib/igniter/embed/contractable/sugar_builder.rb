# frozen_string_literal: true

module Igniter
  module Embed
    module Contractable
      class SugarBuilder
        attr_reader :configured

        def initialize(config:)
          @config = config
          @configured = false
        end

        def migration(from:, to:)
          mark_configured!
          config.role :migration_candidate
          config.stage :shadowed
          config.primary from
          config.candidate to
          config
        end

        def migrate(from, to:)
          migration(from: from, to: to)
        end

        def observe(callable)
          mark_configured!
          config.role :observed_service
          config.stage :captured
          config.primary callable
          config
        end

        def discover(callable)
          mark_configured!
          config.role :discovery_probe
          config.stage :profiled
          config.primary callable
          config
        end

        def shadow(async: nil, sample: nil)
          mark_configured!
          config.async(async) unless async.nil?
          config.sample(sample) unless sample.nil?
          config
        end

        def capture(**options)
          mark_configured!
          config.metadata(capture: options)
        end

        def configured?
          !!configured
        end

        def method_missing(name, ...)
          if config.respond_to?(name)
            mark_configured!
            return config.public_send(name, ...)
          end

          super
        end

        def respond_to_missing?(name, include_private = false)
          config.respond_to?(name, include_private) || super
        end

        private

        attr_reader :config

        def mark_configured!
          @configured = true
        end
      end
    end
  end
end

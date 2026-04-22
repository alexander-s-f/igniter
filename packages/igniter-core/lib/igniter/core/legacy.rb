# frozen_string_literal: true

module Igniter
  module Core
    module Legacy
      REQUIRE_MODE_ENV = "IGNITER_LEGACY_CORE_REQUIRE"
      FALLBACK_MODE_ENV = "IGNITER_LEGACY_CORE_MODE"
      DEFAULT_MODE = :warn

      RequireError = Class.new(LoadError)

      class << self
        def require!(entrypoint)
          case mode
          when :off
            nil
          when :error
            raise RequireError, message_for(entrypoint)
          else
            warn_once(entrypoint)
          end
        end

        def mode
          value = ENV.fetch(REQUIRE_MODE_ENV) { ENV.fetch(FALLBACK_MODE_ENV, DEFAULT_MODE.to_s) }

          case value.to_s.strip.downcase
          when "", "warn", "warning"
            :warn
          when "error", "raise", "exception"
            :error
          when "off", "silent", "none", "0", "false"
            :off
          else
            DEFAULT_MODE
          end
        end

        def message_for(entrypoint)
          <<~MSG.strip
            #{entrypoint} loads igniter-core, which is now a legacy reference implementation kept in the monorepo for migration parity only.
            Migrate to `require "igniter-contracts"` / `require "igniter/contracts"` and contracts-facing packs like `require "igniter/extensions/contracts"`.
            Set #{REQUIRE_MODE_ENV}=off to silence this notice or #{REQUIRE_MODE_ENV}=error to fail fast.
          MSG
        end

        private

        def warn_once(entrypoint)
          return if @warning_emitted

          warning = "WARNING: #{message_for(entrypoint)}\n"
          defined?(Warning) ? Warning.warn(warning) : warn(warning)
          @warning_emitted = true
        end
      end
    end
  end
end

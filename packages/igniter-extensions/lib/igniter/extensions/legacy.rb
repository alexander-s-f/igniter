# frozen_string_literal: true

module Igniter
  module Extensions
    module Legacy
      REPLACEMENTS = {
        "igniter/extensions/auditing" => "execution/diagnostics packs in igniter-contracts or igniter-extensions",
        "igniter/extensions/capabilities" => "contracts-side validation or diagnostics packs instead of patching CompiledGraph globally",
        "igniter/extensions/content_addressing" => "a dedicated contracts effect/runtime pack for content-addressed reuse",
        "igniter/extensions/dataflow" => "Igniter::Extensions::Contracts::DataflowPack",
        "igniter/extensions/differential" => "Igniter::Extensions::Contracts::DifferentialPack",
        "igniter/extensions/execution_report" => "Igniter::Extensions::Contracts::ExecutionReportPack",
        "igniter/extensions/incremental" => "Igniter::Extensions::Contracts::IncrementalPack",
        "igniter/extensions/introspection" => "structured contracts introspection via CompilationReport/DiagnosticsReport",
        "igniter/extensions/invariants" => "contracts validators or diagnostics contributors instead of global runtime patching",
        "igniter/extensions/provenance" => "Igniter::Extensions::Contracts::ProvenancePack",
        "igniter/extensions/reactive" => "contracts-side subscriptions or diagnostics packs instead of core extension hooks",
        "igniter/extensions/saga" => "Igniter::Extensions::Contracts::SagaPack"
      }.freeze

      REQUIRE_MODE_ENV = "IGNITER_LEGACY_CORE_REQUIRE"
      FALLBACK_MODE_ENV = "IGNITER_LEGACY_CORE_MODE"
      DEFAULT_MODE = :warn

      RequireError = Class.new(LoadError)

      class << self
        def entrypoints
          REPLACEMENTS.keys.sort
        end

        def replacement_for(entrypoint)
          REPLACEMENTS[normalize_entrypoint(entrypoint)]
        end

        def require!(entrypoint, replacement: nil)
          replacement ||= replacement_for(entrypoint)

          case mode
          when :off
            nil
          when :error
            raise RequireError, message_for(entrypoint, replacement: replacement)
          else
            warn_once(entrypoint, replacement: replacement)
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

        def message_for(entrypoint, replacement:)
          entrypoint = normalize_entrypoint(entrypoint)
          replacement ||= replacement_for(entrypoint)
          lines = [
            "#{entrypoint} is a legacy core-backed extension activator kept only for migration while igniter-core is retired."
          ]

          if replacement
            lines << "Prefer #{replacement} on top of `require \"igniter/extensions/contracts\"` when migrating this behavior."
          else
            lines << "Prefer contracts-facing packs built on `require \"igniter/extensions/contracts\"`."
          end

          lines << "Set #{REQUIRE_MODE_ENV}=off to silence this notice or #{REQUIRE_MODE_ENV}=error to fail fast."
          lines.join(" ")
        end

        private

        def normalize_entrypoint(entrypoint)
          entrypoint.to_s.strip.sub(/\.rb\z/, "")
        end

        def warn_once(entrypoint, replacement:)
          @warnings ||= {}
          entrypoint = normalize_entrypoint(entrypoint)
          return if @warnings[entrypoint]

          warning = "WARNING: #{message_for(entrypoint, replacement: replacement)}\n"
          defined?(Warning) ? Warning.warn(warning) : warn(warning)
          @warnings[entrypoint] = true
        end
      end
    end
  end
end

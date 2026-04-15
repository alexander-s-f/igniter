# frozen_string_literal: true

module Igniter
  class Application
    # Global registry of canonical application host builders.
    #
    # Host profiles such as :app and :cluster_app are registered here so the
    # application DSL can stay declarative while runtime-specific packs remain
    # pluggable.
    class HostRegistry
      class << self
        def register(name, builder = nil, &block)
          resolved_builder = builder || block
          raise ArgumentError, "host registration requires a builder block or callable" unless resolved_builder

          registry[normalize_name(name)] = resolved_builder
        end

        def fetch(name)
          registry.fetch(normalize_name(name))
        end

        def names
          registry.keys
        end

        def registered?(name)
          registry.key?(normalize_name(name))
        end

        private

        def registry
          @registry ||= {}
        end

        def normalize_name(name)
          name.to_sym
        end
      end
    end
  end
end

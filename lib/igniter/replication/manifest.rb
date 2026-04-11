# frozen_string_literal: true

require "securerandom"

module Igniter
  module Replication
    # Self-description of a running Igniter instance, used during replication.
    #
    # Call Manifest.current to capture the current process's metadata.
    class Manifest
      attr_reader :gem_version, :ruby_version, :source_path,
                  :startup_command, :instance_id

      def self.current
        spec = defined?(Gem) && Gem.loaded_specs["igniter"]
        new(
          gem_version: Igniter::VERSION,
          ruby_version: RUBY_VERSION,
          source_path: spec&.gem_dir || File.expand_path("../../..", __dir__),
          startup_command: $PROGRAM_NAME,
          instance_id: SecureRandom.uuid
        )
      end

      def initialize(gem_version:, ruby_version:, source_path:, startup_command:, instance_id:)
        @gem_version     = gem_version
        @ruby_version    = ruby_version
        @source_path     = source_path
        @startup_command = startup_command
        @instance_id     = instance_id
        freeze
      end

      def to_h
        {
          gem_version: gem_version,
          ruby_version: ruby_version,
          source_path: source_path,
          startup_command: startup_command,
          instance_id: instance_id
        }
      end
    end
  end
end

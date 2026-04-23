# frozen_string_literal: true

module Igniter
  class App
    class BootReport
      attr_reader :base_dir, :actions, :snapshot

      def initialize(base_dir:, actions:, snapshot:)
        @base_dir = base_dir
        @actions = actions.dup.freeze
        @snapshot = snapshot
        freeze
      end

      def loaded_code?
        actions.include?(:code_loaded)
      end

      def scheduler_started?
        actions.include?(:scheduler_started)
      end

      def transport_activated?
        actions.include?(:transport_activated)
      end

      def to_h
        {
          base_dir: base_dir,
          actions: actions.dup,
          snapshot: snapshot.to_h
        }
      end
    end
  end
end

# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class Result
        attr_reader :app_class, :opened, :existing

        def initialize(app_class:, opened:, existing:)
          @app_class = app_class
          @opened = Array(opened).map { |entry| entry.freeze }.freeze
          @existing = Array(existing).map { |entry| entry.freeze }.freeze
          freeze
        end

        def status
          return :opened if opened.any? && existing.empty?
          return :existing if existing.any? && opened.empty?
          return :partial if opened.any? && existing.any?

          :noop
        end

        def opened?
          !opened.empty?
        end

        def existing?
          !existing.empty?
        end

        def to_h
          {
            app: app_class.name,
            status: status,
            opened: opened,
            existing: existing
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Result
        attr_reader :app_class, :applied, :blocked, :skipped

        def initialize(app_class:, applied:, blocked:, skipped: [])
          @app_class = app_class
          @applied = Array(applied).map { |entry| entry.freeze }.freeze
          @blocked = Array(blocked).map { |entry| entry.freeze }.freeze
          @skipped = Array(skipped).map { |entry| entry.freeze }.freeze
          freeze
        end

        def status
          return :applied if @blocked.empty? && @applied.any?
          return :blocked if @blocked.any? && @applied.empty?
          return :partial if @blocked.any? && @applied.any?

          :noop
        end

        def applied?
          !@applied.empty?
        end

        def blocked?
          !@blocked.empty?
        end

        def to_h
          {
            app: app_class.name,
            status: status,
            applied: applied,
            blocked: blocked,
            skipped: skipped
          }
        end
      end
    end
  end
end

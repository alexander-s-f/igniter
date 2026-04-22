# frozen_string_literal: true

module Igniter
  module Contracts
    class DiagnosticsReport
      attr_reader :sections

      def initialize
        @sections = {}
      end

      def add_section(name, value)
        sections[name.to_sym] = value
      end

      def section(name)
        sections.fetch(name.to_sym)
      end
    end
  end
end

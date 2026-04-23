# frozen_string_literal: true

module Igniter
  module Application
    class Provider
      def services(environment:)
        {}
      end

      def interfaces(environment:)
        {}
      end

      def boot(environment:); end

      def shutdown(environment:); end
    end
  end
end

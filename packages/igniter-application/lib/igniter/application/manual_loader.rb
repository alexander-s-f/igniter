# frozen_string_literal: true

module Igniter
  module Application
    class ManualLoader
      def load!(_base_dir:, _paths:, _environment:)
        self
      end
    end
  end
end

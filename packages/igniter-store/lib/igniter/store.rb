# frozen_string_literal: true

require_relative "store/access_path"
require_relative "store/fact"
require_relative "store/fact_log"
require_relative "store/file_backend"
require_relative "store/igniter_store"
require_relative "store/read_cache"
require_relative "store/schema_graph"

module Igniter
  module Store
    class << self
      def memory
        IgniterStore.new
      end

      def open(path)
        IgniterStore.open(path)
      end

      def access_path(...)
        AccessPath.new(...)
      end
    end
  end
end

# frozen_string_literal: true

module Igniter
  module Store
    NATIVE = false unless const_defined?(:NATIVE) # overwritten by native.rb when extension loads
  end
end

require_relative "store/native"          # attempt to load Rust extension
require_relative "store/access_path"
require_relative "store/fact"              # Ruby Struct + Fact.from_h (always loaded)
require_relative "store/fact_log"          # Ruby FactLog + native all_facts patch
require_relative "store/wire_protocol"
require_relative "store/file_backend"      # Ruby FileBackend + native snapshot patch
require_relative "store/server_config"
require_relative "store/server_logger"
require_relative "store/subscription_registry"
require_relative "store/network_backend"
require_relative "store/store_server"
require_relative "store/igniter_store"
require_relative "store/read_cache"
require_relative "store/schema_graph"
require_relative "store/protocol"
require_relative "store/http_adapter"
require_relative "store/tcp_adapter"

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

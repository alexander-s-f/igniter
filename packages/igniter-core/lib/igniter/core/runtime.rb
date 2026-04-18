# frozen_string_literal: true

require_relative "runtime/node_state"
require_relative "runtime/cache"
require_relative "runtime/deferred_result"
require_relative "runtime/collection_result"
require_relative "runtime/input_validator"
require_relative "runtime/planner"
require_relative "runtime/job_worker"
require_relative "runtime/runners/inline_runner"
require_relative "runtime/runners/store_runner"
require_relative "runtime/runners/thread_pool_runner"
require_relative "runtime/stores/active_record_store"
require_relative "runtime/stores/file_store"
require_relative "runtime/stores/memory_store"
require_relative "runtime/stores/redis_store"
require_relative "runtime/stores/sqlite_store"
require_relative "runtime/runner_factory"
require_relative "runtime/remote_adapter"
require_relative "runtime/resolver"
require_relative "runtime/invalidator"
require_relative "runtime/result"
require_relative "runtime/execution"

module Igniter
  module Runtime
    ConfigurationError = Class.new(Igniter::Error)
  end
end

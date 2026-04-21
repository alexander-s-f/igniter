# frozen_string_literal: true

require "fileutils"
require "igniter/sdk/data"

module Companion
  module Shared
    module RuntimeProfile
      class << self
        def cluster_mode?
          ENV["COMPANION_DEV_CLUSTER"].to_s == "true" || ENV["IGNITER_ENV"].to_s == "dev-cluster"
        end

        def node_name
          configured = ENV["IGNITER_NODE"].to_s.strip
          return configured unless configured.empty?

          "main"
        end

        def node_slug
          sanitize(node_name)
        end

        def root_dir
          File.expand_path("../../..", __dir__)
        end

        def storage_root
          return File.join(root_dir, "var") unless cluster_mode?

          File.join(root_dir, "var", "dev-cluster", "nodes", node_slug)
        end

        def execution_store_path(app_name)
          if cluster_mode?
            File.join(storage_root, "#{sanitize(app_name)}_executions.sqlite3")
          else
            File.join(root_dir, "var", "#{sanitize(app_name)}_executions.sqlite3")
          end
        end

        def note_store_path
          return File.join(root_dir, "var", "notes.json") unless cluster_mode?

          File.join(storage_root, "notes.json")
        end

        def assistant_request_store_path
          return File.join(root_dir, "var", "assistant_requests.json") unless cluster_mode?

          File.join(storage_root, "assistant_requests.json")
        end

        def stack_data_path
          return File.join(root_dir, "var", "companion_data.sqlite3") unless cluster_mode?

          File.join(storage_root, "companion_data.sqlite3")
        end

        def execution_store(app_name)
          ensure_storage_root!
          Igniter::Runtime::Stores::SQLiteStore.new(path: execution_store_path(app_name))
        end

        def note_store
          ensure_storage_root!
          Igniter::Data::Stores::File.new(path: note_store_path)
        end

        def ensure_storage_root!
          FileUtils.mkdir_p(storage_root)
        end

        private

        def sanitize(value)
          value.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        end
      end
    end
  end
end

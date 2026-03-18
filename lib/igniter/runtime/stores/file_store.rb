# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Runtime
    module Stores
      class FileStore
        def initialize(root:)
          @root = root
          FileUtils.mkdir_p(@root)
        end

        def save(snapshot)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          File.write(path_for(execution_id), JSON.pretty_generate(snapshot))
          execution_id
        end

        def fetch(execution_id)
          JSON.parse(File.read(path_for(execution_id)))
        rescue Errno::ENOENT
          raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'"
        end

        def delete(execution_id)
          FileUtils.rm_f(path_for(execution_id))
        end

        def exist?(execution_id)
          File.exist?(path_for(execution_id))
        end

        private

        def path_for(execution_id)
          File.join(@root, "#{execution_id}.json")
        end
      end
    end
  end
end

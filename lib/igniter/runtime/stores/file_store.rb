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

        def save(snapshot, correlation: nil, graph: nil)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          data = snapshot.merge(
            _graph: graph,
            _correlation: correlation&.transform_keys(&:to_s)
          ).compact
          File.write(path_for(execution_id), JSON.pretty_generate(data))
          execution_id
        end

        def find_by_correlation(graph:, correlation:)
          normalized = correlation.transform_keys(&:to_s)
          each_snapshot do |data|
            next unless data["_graph"] == graph

            stored_corr = data["_correlation"] || {}
            return data["execution_id"] if stored_corr == normalized
          end
          nil
        end

        def list_all(graph: nil)
          results = []
          each_snapshot do |data|
            next if graph && data["_graph"] != graph

            results << data["execution_id"]
          end
          results
        end

        def list_pending(graph: nil)
          results = []
          each_snapshot do |data|
            next if graph && data["_graph"] != graph

            states = data["states"] || {}
            pending = states.any? do |_name, state|
              (state["status"] || state[:status]).to_s == "pending"
            end
            results << data["execution_id"] if pending
          end
          results
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

        def each_snapshot(&block)
          Dir.glob(File.join(@root, "*.json")).each do |file|
            data = JSON.parse(File.read(file))
            block.call(data)
          rescue JSON::ParserError
            next
          end
        end
      end
    end
  end
end

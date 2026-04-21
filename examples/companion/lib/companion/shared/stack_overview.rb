# frozen_string_literal: true

require "time"
require_relative "note_store"

module Companion
  module Shared
    module StackOverview
      module_function

      def build
        deployment = Companion::Stack.deployment_snapshot
        notes = Companion::Shared::NoteStore.all
        nodes = deployment.fetch("nodes").transform_values do |config|
          {
            role: config["role"],
            public: config["public"],
            port: config["port"],
            host: config["host"],
            command: config["command"],
            mounts: config.fetch("mounts", {})
          }
        end

        {
          generated_at: Time.now.utc.iso8601,
          stack: {
            name: Companion::Stack.stack_settings.dig("stack", "name"),
            root_app: deployment.dig("stack", "root_app"),
            default_node: deployment.dig("stack", "default_node"),
            mounts: deployment.dig("stack", "mounts"),
            apps: Companion::Stack.app_names.map(&:to_s)
          },
          counts: {
            apps: Companion::Stack.app_names.size,
            nodes: nodes.size,
            notes: notes.size
          },
          notes: notes.first(8),
          nodes: nodes,
          apps: deployment.fetch("apps").transform_values do |config|
            {
              path: config["path"],
              class_name: config["class_name"],
              default: config["default"]
            }
          end
        }
      end
    end
  end
end

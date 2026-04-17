# frozen_string_literal: true

require "time"
require_relative "capability_profile"
require_relative "note_store"

module Companion
  module Shared
    module StackOverview
      module_function

      def build
        deployment = Companion::Stack.deployment_snapshot
        notes = Companion::Shared::NoteStore.all
        services = deployment.fetch("services").transform_values do |config|
          {
            role: config["role"],
            public: config["public"],
            replicas: config["replicas"],
            port: config.dig("http", "port"),
            command: config["command"],
            apps: Array(config["apps"]),
            root_app: config["root_app"],
            mounts: config.fetch("mounts", {})
          }
        end

        {
          generated_at: Time.now.utc.iso8601,
          stack: {
            name: Companion::Stack.stack_settings.dig("stack", "name"),
            default_app: deployment.dig("stack", "default_app"),
            default_service: deployment.dig("stack", "default_service"),
            profile: deployment.dig("stack", "topology_profile"),
            apps: Companion::Stack.app_names.map(&:to_s)
          },
          counts: {
            apps: Companion::Stack.app_names.size,
            services: services.size,
            notes: notes.size,
            discovered_peers: CapabilityProfile.discovered_peers.size
          },
          notes: notes.first(8),
          current_node: CapabilityProfile.discovery_snapshot,
          discovered_peers: CapabilityProfile.discovered_peers,
          services: services,
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

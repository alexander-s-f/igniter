# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "../../lib/companion/boot"
require_relative "../../lib/companion/shared/telegram_webhook"

module Companion
  class MainApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    tools_path     "app/tools"
    skills_path    "app/skills"
    executors_path "app/executors"
    contracts_path "app/contracts"
    agents_path    "app/agents"

    route "POST", "/telegram/webhook", with: Companion::TelegramWebhook

    on_boot do
      Companion::Boot.configure_persistence!(app_name: :main)
      Companion::Boot.configure_ai!

      if ENV["CONSENSUS_NODES"]
        require "igniter/cluster"
        require_relative "../../lib/companion/shared/session_state_machine"

        node_ids = ENV["CONSENSUS_NODES"].split(",").map { |value| value.strip.to_sym }
        cluster = Igniter::Cluster::Consensus::Cluster.start(
          nodes: node_ids,
          state_machine: Companion::SessionStateMachine,
          verbose: false
        )
        begin
          cluster.wait_for_leader(timeout: 5)
          Companion::NotesStore.configure_cluster(cluster)
          puts "Consensus cluster active: #{node_ids.size} nodes, " \
               "leader=#{cluster.leader&.name}, quorum=#{cluster.quorum_size}"
        rescue StandardError => e
          warn "Consensus cluster unavailable (#{e.message}) — using in-process notes store"
        end
        at_exit { cluster.stop!(timeout: 3) rescue nil }
      end

      register "ChatContract", Companion::ChatContract
      register "VoiceAssistantContract", Companion::VoiceAssistantContract
    end

    configure do |c|
      c.app_host.port = ENV.fetch("ORCHESTRATOR_PORT", "4567").to_i
      c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      c.store = Companion::Boot.default_execution_store(app_name: :main)
    end

    schedule :session_gc, every: "1h" do
      # placeholder — extend with session store cleanup as needed
    end
  end
end

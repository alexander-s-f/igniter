# frozen_string_literal: true

require "igniter/application"
require "igniter/core"
require "igniter/core/metrics"
require_relative "../../lib/companion/boot"

module Companion
  class InferenceApp < Igniter::Application
    root_dir __dir__
    config_file "application.yml"

    executors_path "app/executors"
    contracts_path "app/contracts"

    on_boot do
      Companion::Boot.configure_persistence!(app_name: :inference)
      Companion::Boot.configure_ai!

      register "ASRContract", Companion::ASRContract
      register "IntentContract", Companion::IntentContract
      register "TTSContract", Companion::TTSContract
    end

    configure do |c|
      c.server_host.host = "0.0.0.0"
      c.server_host.port = ENV.fetch("INFERENCE_PORT", "4568").to_i
      c.server_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      c.server_host.drain_timeout = 30
      c.metrics_collector = Igniter::Metrics::Collector.new
      c.store = Companion::Boot.default_execution_store(app_name: :inference)
    end
  end
end

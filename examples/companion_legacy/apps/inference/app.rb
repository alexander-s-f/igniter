# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require "igniter/core/metrics"
require_relative "../../lib/companion/boot"

module Companion
  class InferenceApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

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
      c.app_host.host = "0.0.0.0"
      c.app_host.port = ENV.fetch("INFERENCE_PORT", "4568").to_i
      c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      c.app_host.drain_timeout = 30
      c.metrics_collector = Igniter::Metrics::Collector.new
      c.store = Companion::Boot.default_execution_store(app_name: :inference)
    end
  end
end

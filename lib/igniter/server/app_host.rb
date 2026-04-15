# frozen_string_literal: true

require_relative "../server"
require_relative "../app/host_registry"
require_relative "../app/app_host"

module Igniter
  module Server
    Igniter::App::HostRegistry.register(:app) do
      Igniter::App::AppHost.new
    end
  end
end

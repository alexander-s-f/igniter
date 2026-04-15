# frozen_string_literal: true

require_relative "../server"
require_relative "../app/host_registry"
require_relative "../app/server_host"

module Igniter
  module Server
    Igniter::Application::HostRegistry.register(:server) do
      Igniter::Application::ServerHost.new
    end
  end
end

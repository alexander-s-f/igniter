# frozen_string_literal: true

require_relative "../server"
require_relative "../application/host_registry"
require_relative "../application/server_host"

module Igniter
  module Server
    Igniter::Application::HostRegistry.register(:server) do
      Igniter::Application::ServerHost.new
    end

    ApplicationHost = Igniter::Application::ServerHost unless const_defined?(:ApplicationHost, false)
  end
end

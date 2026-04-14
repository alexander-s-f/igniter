# frozen_string_literal: true

require_relative "../application/server_host"

module Igniter
  module Server
    ApplicationHost = Igniter::Application::ServerHost unless const_defined?(:ApplicationHost, false)
  end
end

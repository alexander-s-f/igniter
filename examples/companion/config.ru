# frozen_string_literal: true
# Rack entry point — use with Puma or any Rack-compatible server.
#   bundle exec puma config.ru

require_relative "stack"

service = ENV["IGNITER_SERVICE"] || ENV["IGNITER_APP"] || "main"
run Companion::Stack.rack_service(service)

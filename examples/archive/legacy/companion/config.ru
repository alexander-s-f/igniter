# frozen_string_literal: true
# Rack entry point — use with Puma or any Rack-compatible server.
#   bundle exec puma config.ru

require_relative "stack"

node = ENV["IGNITER_NODE"]
run Companion::Stack.rack_node(node)

# frozen_string_literal: true

require_relative "operator/policy"
require_relative "operator/handler_result"
require_relative "operator/lifecycle_contract"
require_relative "operator/handler_registry"
require_relative "operator/dispatcher"
require_relative "operator/handlers"

Igniter::App::Operator::HandlerRegistry.register(
  :orchestration,
  Igniter::App::Operator::Handlers::OrchestrationHandler.new
)
Igniter::App::Operator::HandlerRegistry.register(
  :ignition,
  Igniter::App::Operator::Handlers::IgniteHandler.new
)

# frozen_string_literal: true

require_relative "scheduler_registry"
require_relative "threaded_scheduler_adapter"

Igniter::Application::SchedulerRegistry.register(:threaded) do
  Igniter::Application::ThreadedSchedulerAdapter.new
end

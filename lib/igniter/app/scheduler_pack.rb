# frozen_string_literal: true

require_relative "scheduler_registry"
require_relative "threaded_scheduler_adapter"

Igniter::App::SchedulerRegistry.register(:threaded) do
  Igniter::App::ThreadedSchedulerAdapter.new
end

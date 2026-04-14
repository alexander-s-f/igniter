# frozen_string_literal: true

module Igniter
  class Application
    # Abstract seam for background job runtime ownership.
    #
    # Application owns job declarations via `schedule`, while the scheduler
    # adapter decides how those jobs are executed, started, and stopped.
    class SchedulerAdapter
      def start(config:, jobs:)
        raise NotImplementedError, "#{self.class} must implement #start"
      end

      def stop; end
    end
  end
end

# frozen_string_literal: true

require_relative "runtime_context"
require_relative "diagnostics/runtime_contributor"

module Igniter
  class App
    module Diagnostics
      Igniter::Diagnostics.register_report_contributor(
        :app_runtime,
        RuntimeContributor
      )
    end
  end
end

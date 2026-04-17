# frozen_string_literal: true

require_relative "runtime_context"
require_relative "diagnostics/runtime_contributor"
require_relative "diagnostics/app_host_contributor"
require_relative "diagnostics/cluster_app_host_contributor"
require_relative "diagnostics/loader_contributor"
require_relative "diagnostics/scheduler_contributor"
require_relative "diagnostics/sdk_contributor"

module Igniter
  class App
    module Diagnostics
      Igniter::Diagnostics.register_report_contributor(
        :app_runtime,
        RuntimeContributor
      )
      Igniter::Diagnostics.register_report_contributor(
        :app_host,
        AppHostContributor
      )
      Igniter::Diagnostics.register_report_contributor(
        :cluster_app_host,
        ClusterAppHostContributor
      )
      Igniter::Diagnostics.register_report_contributor(
        :app_loader,
        LoaderContributor
      )
      Igniter::Diagnostics.register_report_contributor(
        :app_scheduler,
        SchedulerContributor
      )
      Igniter::Diagnostics.register_report_contributor(
        :app_sdk,
        SdkContributor
      )
    end
  end
end

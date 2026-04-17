# frozen_string_literal: true

require_relative "diagnostics/routing_contributor"

module Igniter
  module Cluster
    module Diagnostics
      Igniter::Diagnostics.register_report_contributor(
        :cluster_routing,
        RoutingContributor
      )
    end
  end
end

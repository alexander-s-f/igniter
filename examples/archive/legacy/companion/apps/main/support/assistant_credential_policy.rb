# frozen_string_literal: true

require "igniter/app"

module Companion
  module Main
    module Support
      module AssistantCredentialPolicy
        module_function

        class ExternalAPICredentialPolicy < Igniter::App::Credentials::Policies::LocalOnlyPolicy
          def initialize(**overrides)
            defaults = {
              description: "Credentials stay node-local by default. Prefer routing work to credential-owning nodes over copying secrets.",
              metadata: {
                notes: [
                  "No automatic cross-node credential propagation.",
                  "Weakly trusted nodes should not receive long-lived external API credentials.",
                  "Any future replication should be policy-driven and auditable."
                ]
              }
            }

            super(**defaults.merge(overrides))
          end
        end

        def current
          ExternalAPICredentialPolicy.new
        end

        def allow_local_use?
          current.allows_scope?(:local)
        end

        def allow_remote_propagation?
          current.allows_scope?(:remote)
        end

        def channel_allowed?(scope:)
          current.allows_scope?(scope)
        end

        def serialize(policy = current)
          policy.to_h.merge(
            key: policy.name,
            summary: policy.description,
            notes: Array(policy.metadata[:notes]),
            operator_approval_for_replication: policy.operator_approval_required
          )
        end
      end
    end
  end
end

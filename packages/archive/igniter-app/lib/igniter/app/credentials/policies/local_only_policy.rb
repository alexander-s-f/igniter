# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      module Policies
        class LocalOnlyPolicy < CredentialPolicy
          def initialize(**overrides)
            defaults = {
              name: :local_only,
              label: "Local Only",
              secret_class: :local_only,
              propagation: :disabled,
              route_over_replicate: true,
              weak_trust_behavior: :deny,
              operator_approval_required: true,
              description: "Credentials stay node-local by default. Prefer routing work to credential-owning nodes over copying secrets.",
              metadata: {
                notes: [
                  "No automatic cross-node credential propagation.",
                  "Weakly trusted nodes should not receive long-lived external credentials.",
                  "Route work before considering any secret replication."
                ]
              }
            }

            super(**defaults.merge(overrides))
          end
        end
      end
    end
  end
end

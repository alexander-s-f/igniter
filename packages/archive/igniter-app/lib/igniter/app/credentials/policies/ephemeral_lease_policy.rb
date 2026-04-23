# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      module Policies
        class EphemeralLeasePolicy < CredentialPolicy
          def initialize(**overrides)
            defaults = {
              name: :ephemeral_lease,
              label: "Ephemeral Lease",
              secret_class: :ephemeral_lease,
              propagation: :ephemeral,
              route_over_replicate: true,
              weak_trust_behavior: :deny,
              operator_approval_required: true,
              description: "Credentials may be issued as bounded, auditable leases rather than replicated as long-lived secrets.",
              metadata: {
                lease_mode: :ephemeral,
                declared_only: true,
                notes: [
                  "Use leases for bounded cross-node work, not for normal secret fan-out.",
                  "Leases should be auditable, revocable, and time-bounded.",
                  "This policy is a declared contract foundation before transport is implemented."
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

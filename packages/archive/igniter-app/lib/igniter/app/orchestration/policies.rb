# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      module Policies
        class Base < Igniter::App::Operator::Policy
          def initialize(name:, default_operation:, allowed_operations:, runtime_completion:, description:, lifecycle_operations:, operation_aliases: {}, default_routing: {})
            operation_mapping = build_operation_mapping(allowed_operations, operation_aliases)

            super(
              name: name,
              default_operation: default_operation,
              allowed_operations: allowed_operations,
              lifecycle_operations: lifecycle_operations,
              operation_aliases: operation_aliases,
              default_routing: default_routing,
              operation_lifecycle: operation_mapping,
              execution_operations: operation_mapping,
              runtime_completion: runtime_completion,
              description: description
            )
          end

          private

          def build_operation_mapping(allowed_operations, operation_aliases)
            normalized_aliases = (operation_aliases || {}).each_with_object({}) do |(operation, lifecycle_operation), memo|
              memo[operation.to_sym] = lifecycle_operation.to_sym
            end

            Array(allowed_operations).each_with_object({}) do |operation, memo|
              normalized = operation.to_sym
              memo[normalized] = normalized_aliases.fetch(normalized, normalized)
            end
          end
        end

        class InteractiveSessionPolicy < Base
          def initialize
            super(
              name: :interactive_session,
              default_operation: :wake,
              allowed_operations: %i[wake handoff complete dismiss],
              lifecycle_operations: %i[acknowledge resolve dismiss],
              operation_aliases: {
                wake: :acknowledge,
                handoff: :acknowledge,
                complete: :resolve
              },
              default_routing: {
                queue: "interactive-sessions",
                channel: "inbox://interactive-sessions"
              },
              runtime_completion: :optional,
              description: "operator-facing interactive session; wake or hand off the session first, complete it only when the conversation is actually done"
            )
          end
        end

        class ManualCompletionPolicy < Base
          def initialize
            super(
              name: :manual_completion,
              default_operation: :approve,
              allowed_operations: %i[approve handoff dismiss],
              lifecycle_operations: %i[acknowledge resolve dismiss],
              operation_aliases: {
                approve: :resolve,
                handoff: :acknowledge
              },
              default_routing: {
                queue: "manual-completions",
                channel: "inbox://manual-completions"
              },
              runtime_completion: :required,
              description: "manual completion step; approve when the operator has an explicit completion value, or hand it off without completing runtime state yet"
            )
          end
        end

        class SingleTurnCompletionPolicy < Base
          def initialize
            super(
              name: :single_turn_completion,
              default_operation: :complete,
              allowed_operations: %i[complete dismiss],
              lifecycle_operations: %i[resolve dismiss],
              operation_aliases: {
                complete: :resolve
              },
              default_routing: {
                queue: "single-turn-completions",
                channel: "inbox://single-turn-completions"
              },
              runtime_completion: :required,
              description: "single-turn streamed step; complete it when the one-shot result is ready, or dismiss it when the workflow intentionally abandons the step"
            )
          end
        end

        class DeferredReplyPolicy < Base
          def initialize
            super(
              name: :deferred_reply,
              default_operation: :reply,
              allowed_operations: %i[reply handoff dismiss],
              lifecycle_operations: %i[acknowledge resolve dismiss],
              operation_aliases: {
                reply: :resolve,
                handoff: :acknowledge
              },
              default_routing: {
                queue: "deferred-replies",
                channel: "inbox://deferred-replies"
              },
              runtime_completion: :optional,
              description: "deferred reply step; reply when the answer arrives, or hand the waiting work to an operator without completing the runtime session yet"
            )
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      module Policies
        class Base
          attr_reader :name, :default_operation, :allowed_operations, :runtime_completion, :description, :lifecycle_operations, :operation_aliases, :default_routing

          def initialize(name:, default_operation:, allowed_operations:, runtime_completion:, description:, lifecycle_operations:, operation_aliases: {}, default_routing: {})
            @name = name.to_sym
            @default_operation = default_operation.to_sym
            @allowed_operations = Array(allowed_operations).map(&:to_sym).freeze
            @runtime_completion = runtime_completion.to_sym
            @description = description.to_s
            @lifecycle_operations = Array(lifecycle_operations).map(&:to_sym).freeze
            @operation_aliases = normalize_aliases(operation_aliases)
            @default_routing = normalize_routing(default_routing)
            freeze
          end

          def allows_operation?(operation)
            normalized = operation.to_sym
            allowed_operations.include?(normalized) || lifecycle_operations.include?(normalized)
          end

          def lifecycle_operation_for(operation)
            operation_aliases.fetch(operation.to_sym, operation.to_sym)
          end

          def default_lifecycle_operation
            lifecycle_operation_for(default_operation)
          end

          def to_h
            {
              name: name,
              default_operation: default_operation,
              allowed_operations: allowed_operations,
              lifecycle_operations: lifecycle_operations,
              operation_aliases: operation_aliases,
              default_routing: default_routing,
              runtime_completion: runtime_completion,
              description: description
            }.freeze
          end

          private

          def normalize_aliases(operation_aliases)
            operation_aliases.each_with_object({}) do |(operation, lifecycle_operation), memo|
              memo[operation.to_sym] = lifecycle_operation.to_sym
            end.freeze
          end

          def normalize_routing(routing)
            routing.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end.freeze
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

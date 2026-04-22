# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      class Compiler
        class << self
          def compile(profile:, &block)
            builder = Builder.build(profile: profile, &block)
            operations = normalize(builder.operations, profile: profile)
            validate(operations, profile: profile)
            CompiledGraph.new(operations: operations, profile_fingerprint: profile.fingerprint)
          end

          private

          def normalize(operations, profile:)
            hook_spec = Assembly::HookSpecs.fetch(:normalizers)

            profile.normalizers.each do |entry|
              operations = entry.value.call(operations: operations, profile: profile)
              operations = hook_spec.validate_result!(entry.key, operations)
            end
            operations
          end

          def validate(operations, profile:)
            profile.validators.each do |entry|
              entry.value.call(operations: operations, profile: profile)
            end
          end
        end
      end
    end
  end
end

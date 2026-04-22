# frozen_string_literal: true

module Igniter
  module Contracts
    class << self
      def build_kernel
        Assembly::Kernel.new.install(BaselinePack)
      end

      def default_kernel
        @default_kernel ||= build_kernel
      end

      def default_profile
        @default_profile ||= default_kernel.finalize
      end

      def compile(profile: default_profile, &block)
        Execution::Compiler.compile(profile: profile, &block)
      end

      def execute(compiled_graph, inputs:, profile: default_profile)
        Execution::Runtime.execute(compiled_graph, inputs: inputs, profile: profile)
      end

      def diagnose(result, profile: default_profile)
        Execution::Diagnostics.build_report(result: result, profile: profile)
      end

      def reset_defaults!
        @default_kernel = nil
        @default_profile = nil
      end
    end
  end
end

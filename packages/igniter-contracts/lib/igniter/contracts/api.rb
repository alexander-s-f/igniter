# frozen_string_literal: true

module Igniter
  module Contracts
    class << self
      def build_kernel
        Kernel.new.install(BaselinePack)
      end

      def default_kernel
        @default_kernel ||= build_kernel
      end

      def default_profile
        @default_profile ||= default_kernel.finalize
      end

      def compile(profile: default_profile, &block)
        Compiler.compile(profile: profile, &block)
      end

      def execute(compiled_graph, inputs:, profile: default_profile)
        Runtime.execute(compiled_graph, inputs: inputs, profile: profile)
      end

      def reset_defaults!
        @default_kernel = nil
        @default_profile = nil
      end
    end
  end
end

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

      def reset_defaults!
        @default_kernel = nil
        @default_profile = nil
      end
    end
  end
end

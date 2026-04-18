# frozen_string_literal: true

module Igniter
  module Cluster
    module Events
      module HookSupport
        private

        def run_before_hooks(hooks, context)
          hooks.each { |hook| invoke_hook(hook, context) }
        end

        def run_after_hooks(hooks, context)
          hooks.each { |hook| invoke_hook(hook, context) }
        end

        def run_around_hooks(hooks, context, &block)
          hooks.reverse.reduce(block) do |inner, hook|
            lambda do
              invoke_hook(hook, context.merge(proceed: inner))
            end
          end.call
        end

        def invoke_hook(hook, context)
          hook.call(**context)
        rescue ArgumentError
          hook.call(context)
        end
      end
    end
  end
end

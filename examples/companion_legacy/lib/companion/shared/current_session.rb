# frozen_string_literal: true

module Companion
  module CurrentSession
    THREAD_KEY = :companion_current_session

    module_function

    def with(context)
      previous = Thread.current[THREAD_KEY]
      Thread.current[THREAD_KEY] = normalize(context)
      yield
    ensure
      Thread.current[THREAD_KEY] = previous
    end

    def context
      normalize(Thread.current[THREAD_KEY])
    end

    def reset!
      Thread.current[THREAD_KEY] = nil
    end

    def normalize(context)
      return nil unless context.is_a?(Hash)

      context.each_with_object({}) do |(key, value), memo|
        memo[key.to_sym] = value
      end
    end
  end
end

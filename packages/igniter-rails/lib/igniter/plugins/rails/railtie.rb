# frozen_string_literal: true

module Igniter
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "igniter.configure_store" do
        # Auto-configure store based on available adapters unless already set
        next if Igniter.instance_variable_defined?(:@execution_store)

        Igniter.execution_store =
          if defined?(Redis) && ::Rails.application.config.respond_to?(:redis)
            Igniter::Runtime::Stores::RedisStore.new(::Redis.current)
          else
            Igniter::Runtime::Stores::MemoryStore.new
          end
      end

      initializer "igniter.load_contracts" do
        ::Rails.autoloaders.main.on_load("ApplicationContract") do
          # Hook point for future eager loading of compiled contracts
        end
      end
    end
  end
end

# frozen_string_literal: true

module Igniter
  module Server
    class ApplicationHost
      def activate!(environment:)
        Igniter::Server.activate_remote_adapter!
        Igniter::Server.activate_agent_adapter!
        self
      end

      def projection_for(environment:)
        ApplicationConfigProjection.from_environment(environment)
      end

      def build_config(environment:)
        projection_for(environment: environment).to_server_config
      end

      def start(environment:)
        activate!(environment: environment)
        HttpServer.new(build_config(environment: environment)).start
      end

      def rack_app(environment:)
        RackApp.new(build_config(environment: environment))
      end
    end
  end
end

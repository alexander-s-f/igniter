# frozen_string_literal: true

module Igniter
  class App
    # Abstract host adapter seam for application runtimes.
    #
    # Application owns app assembly (autoloading, config layering, registration,
    # scheduling), while the host adapter owns deployment/runtime specifics such
    # as transport activation and the concrete object returned by #start/#rack_app.
    class HostAdapter
      def build_config(app_config)
        raise NotImplementedError, "#{self.class} must implement #build_config"
      end

      def activate_transport!; end

      def start(config:)
        raise NotImplementedError, "#{self.class} must implement #start"
      end

      def rack_app(config:)
        raise NotImplementedError, "#{self.class} must implement #rack_app"
      end
    end
  end
end

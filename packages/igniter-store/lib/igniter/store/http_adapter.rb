# frozen_string_literal: true

require "rack"
require "json"

module Igniter
  module Store
    # HTTP transport adapter for the Igniter Store Open Protocol.
    #
    # Exposes Protocol::Interpreter over HTTP via a Rack-compatible app.
    # The canonical endpoint is POST /v1/dispatch which accepts and returns
    # a WireEnvelope JSON object.
    #
    # Usage:
    #   adapter = HTTPAdapter.new(interpreter: interpreter, port: 7300)
    #   adapter.rack_app   # → Rack-compatible, mountable in any server
    #   adapter.start      # → foreground via Puma (dev dep)
    #   adapter.start_async / adapter.stop
    class HTTPAdapter
      module ResponseHelper
        private

        def json_response(status, data)
          body = JSON.generate(data)
          [status, { "Content-Type" => "application/json", "Content-Length" => body.bytesize.to_s }, [body]]
        end

        def method_not_allowed
          json_response(405, { error: "Method not allowed" })
        end
      end

      class DispatchHandler
        include ResponseHelper

        def initialize(interpreter)
          @interpreter = interpreter
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "POST"

          body = env["rack.input"].read
          begin
            envelope = JSON.parse(body, symbolize_names: true)
          rescue JSON::ParserError => e
            return json_response(400, { error: "Invalid JSON: #{e.message}" })
          end

          json_response(200, @interpreter.wire.dispatch(envelope))
        end
      end

      class HealthHandler
        include ResponseHelper

        def initialize(health_provider: nil)
          @health_provider = health_provider
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          health = @health_provider ? @health_provider.call : { protocol: :igniter_store, schema_version: 1, status: :ready }
          json_response(200, health)
        end
      end

      class MetadataHandler
        include ResponseHelper

        def initialize(interpreter)
          @interpreter = interpreter
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          json_response(200, @interpreter.metadata_snapshot)
        end
      end

      # Returns the canonical observability snapshot at GET /v1/status.
      # When +status_provider+ is given (e.g. StoreServer#observability_snapshot),
      # it is called to produce the full server+storage shape.
      # Otherwise falls back to the interpreter's storage-level snapshot.
      class StatusHandler
        include ResponseHelper

        def initialize(interpreter:, status_provider: nil)
          @interpreter     = interpreter
          @status_provider = status_provider
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          data = @status_provider ? @status_provider.call : @interpreter.observability_snapshot
          json_response(200, data)
        end
      end

      # Readiness probe: 200 when ready to serve traffic, 503 otherwise (draining,
      # stopped, or initialising).  +ready_provider+ must return truthy/falsy.
      class ReadyHandler
        include ResponseHelper

        def initialize(ready_provider: nil)
          @ready_provider = ready_provider
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          ready = @ready_provider ? @ready_provider.call : true
          if ready
            json_response(200, { status: "ready" })
          else
            json_response(503, { status: "unavailable" })
          end
        end
      end

      # Returns the metrics sub-hash from the observability snapshot.
      class MetricsHandler
        include ResponseHelper

        def initialize(metrics_provider: nil)
          @metrics_provider = metrics_provider
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          data = @metrics_provider ? @metrics_provider.call : {}
          json_response(200, data)
        end
      end

      # Returns recent structured events from the server event ring buffer.
      class EventsRecentHandler
        include ResponseHelper

        def initialize(events_provider: nil)
          @events_provider = events_provider
        end

        def call(env)
          return method_not_allowed unless env["REQUEST_METHOD"] == "GET"

          events = @events_provider ? @events_provider.call : []
          json_response(200, { events: events, count: events.size })
        end
      end

      # ── Adapter ──────────────────────────────────────────────────────────────

      def initialize(interpreter:, port: 7300, host: "0.0.0.0",
                     health_provider: nil, status_provider: nil,
                     ready_provider: nil, metrics_provider: nil, events_provider: nil)
        @interpreter      = interpreter
        @port             = port
        @host             = host
        @health_provider  = health_provider
        @status_provider  = status_provider
        @ready_provider   = ready_provider
        @metrics_provider = metrics_provider
        @events_provider  = events_provider
        @puma             = nil
        @thread           = nil
      end

      # Returns a Rack-compatible app mountable in any Rack server.
      def rack_app
        interp = @interpreter
        hp     = @health_provider
        sp     = @status_provider
        rp     = @ready_provider
        mp     = @metrics_provider
        ep     = @events_provider
        not_found = ->(env) {
          body = JSON.generate({ error: "Not found: #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]}" })
          [404, { "Content-Type" => "application/json", "Content-Length" => body.bytesize.to_s }, [body]]
        }

        Rack::Builder.new do
          map "/v1/dispatch"       do run DispatchHandler.new(interp) end
          map "/v1/health"         do run HealthHandler.new(health_provider: hp) end
          map "/v1/status"         do run StatusHandler.new(interpreter: interp, status_provider: sp) end
          map "/v1/ready"          do run ReadyHandler.new(ready_provider: rp) end
          map "/v1/metrics"        do run MetricsHandler.new(metrics_provider: mp) end
          map "/v1/events/recent"  do run EventsRecentHandler.new(events_provider: ep) end
          map "/v1/metadata"       do run MetadataHandler.new(interp) end
          run not_found
        end
      end

      # Starts the server in the current thread (blocks). Requires puma.
      def start
        require "puma"
        @puma = Puma::Server.new(rack_app)
        @puma.add_tcp_listener(@host, @port)
        @puma.run.join
      end

      # Starts in a background thread. Returns self.
      def start_async
        @thread = Thread.new { start }
        sleep 0.05
        self
      end

      def stop
        @puma&.stop(true) rescue nil
        @thread&.join(2) rescue nil
        self
      end

      def bind_address
        "#{@host}:#{@port}"
      end
    end
  end
end

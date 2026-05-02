# frozen_string_literal: true

require "socket"
require "json"
require_relative "wire_protocol"
require_relative "server_config"
require_relative "server_logger"
require_relative "server_metrics"
require_relative "subscription_registry"

module Igniter
  module Store
    # Minimal TCP / Unix socket server that exposes durable fact storage over
    # the network.  Clients use NetworkBackend to connect.
    #
    # The server is the "durability half" of the network topology: it persists
    # facts and serves replay requests.  All in-memory indices (scope, partition,
    # cache, coercions) are rebuilt by each client from the replayed facts.
    #
    # Lifecycle:
    #   server = StoreServer.new(host: "127.0.0.1", port: 7400, backend: :file, path: "store.wal")
    #   server.start_async            # background thread
    #   server.wait_until_ready       # blocks until accepting (no sleep needed)
    #   ...
    #   server.stop                   # graceful drain, then close
    #
    # Foreground / CLI:
    #   server.start_foreground       # sets signal traps, blocks until stop
    #
    # Configuration object:
    #   config = ServerConfig.new(host: "0.0.0.0", port: 7400, backend: :file, ...)
    #   server = StoreServer.new(config: config)
    class StoreServer
      include WireProtocol

      # ── Constructor ──────────────────────────────────────────────────────────

      # Accepts keyword args (backward compatible) OR a +config:+ ServerConfig.
      # Keyword args take precedence over config fields when both are given.
      def initialize(host: nil, port: nil, transport: nil, backend: nil, path: nil,
                     logger: nil, pid_file: nil, drain_timeout: nil,
                     max_connections: nil, config: nil,
                     # Legacy positional-style: address: "host:port"
                     address: nil,
                     metrics_thresholds: {})
        cfg = config || ServerConfig.new

        # Keyword args override the config where explicitly provided.
        resolved_host      = host      || (address ? split_address(address).first : nil) || cfg.host
        resolved_port      = port      || (address ? split_address(address).last  : nil) || cfg.port
        resolved_transport = transport || cfg.transport
        resolved_backend   = backend   || cfg.backend
        resolved_path      = path      || cfg.path
        resolved_pid       = pid_file  || cfg.pid_file
        resolved_drain     = drain_timeout  || cfg.drain_timeout
        resolved_max       = max_connections || cfg.max_connections

        log_io    = config&.log_io    || $stdout
        log_level = config&.log_level || :info

        @logger          = logger || ServerLogger.new(log_io, log_level)
        @backend_type    = resolved_backend
        @transport_type  = resolved_transport
        @backend         = build_backend(resolved_backend, resolved_path)
        @server          = build_server(resolved_host, resolved_port, resolved_transport)
        @write_mutex     = Mutex.new
        @active          = 0
        @active_mutex    = Mutex.new
        @in_memory_facts = []
        @stopped         = false
        @started_at      = nil
        @pid_file        = resolved_pid
        @drain_timeout   = resolved_drain
        @max_connections = resolved_max
        @ready_mutex     = Mutex.new
        @ready_cond      = ConditionVariable.new
        # The server socket is bound and listening as soon as build_server returns.
        # Signal readiness here so wait_until_ready is race-free for callers that
        # connect before start_async is called.
        @registry        = SubscriptionRegistry.new
        @ready_latch     = true
        @started_at      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        # Cache the bind address string now while the socket is guaranteed open,
        # so start/stop threads don't race on @server.addr after close.
        @bind_address_str = resolved_transport == :unix ?
          resolved_host.to_s :
          "#{@server.addr[3]}:#{@server.addr[1]}"
        @metrics    = ServerMetrics.new(thresholds: metrics_thresholds)
        @last_error = nil
        write_pid_file(resolved_pid)
      end

      # ── Lifecycle ────────────────────────────────────────────────────────────

      # Starts the accept loop in the calling thread (blocks until #stop).
      def start
        @logger.info("Listening on #{@bind_address_str} " \
                     "(transport=#{@transport_type} backend=#{@backend_type})")
        @logger.event(:server_start,
                      bind_address: @bind_address_str,
                      transport:    @transport_type,
                      backend:      @backend_type)
        until @stopped
          begin
            client = @server.accept
          rescue IOError, Errno::EBADF
            break
          end

          active = @active_mutex.synchronize { @active += 1; @active }

          if @max_connections && active > @max_connections
            @active_mutex.synchronize { @active -= 1 }
            @metrics.record_connection_rejected
            @logger.event(:alert, type: :max_connections, active: active, max: @max_connections)
            client.close rescue nil
            next
          end

          @logger.debug("Connection accepted (active=#{active})")
          Thread.new(client) { |s| handle_client(s) }
        end
      ensure
        remove_pid_file
        @logger.info("Stopped.")
        @logger.event(:server_stop, bind_address: @bind_address_str)
      end

      # Starts the accept loop in a background daemon thread.
      # Call wait_until_ready after this to avoid race conditions.
      def start_async
        Thread.new do
          Thread.current.abort_on_exception = false
          start
        end
      end

      # Blocks until the server's accept loop is running and ready for connections.
      # Replaces the sleep 0.05 hack in callers.
      def wait_until_ready(timeout: 2)
        @ready_mutex.synchronize do
          deadline = Time.now + timeout
          until @ready_latch
            remaining = deadline - Time.now
            raise "StoreServer did not become ready within #{timeout}s" if remaining <= 0
            @ready_cond.wait(@ready_mutex, remaining)
          end
        end
        self
      end

      # Starts the accept loop with SIGTERM/SIGINT traps for CLI/foreground use.
      # Blocks until a signal or #stop is called.
      def start_foreground
        trap("SIGTERM") { stop }
        trap("INT")     { stop }
        start
      end

      # Gracefully stops the server.
      # 1. Closes the server socket (no new connections accepted).
      # 2. Waits up to +timeout+ seconds for active connections to finish.
      # 3. Force-closes remaining connections and closes the backend.
      def stop(timeout: nil)
        t = timeout || @drain_timeout
        @stopped = true
        @logger.info("Stopping (drain_timeout=#{t}s)...")
        @server.close rescue nil
        remove_pid_file

        deadline = Time.now + t
        loop do
          active = @active_mutex.synchronize { @active }
          break if active.zero? || Time.now >= deadline
          @logger.debug("Draining #{active} connection(s)...")
          sleep 0.05
        end

        remaining = @active_mutex.synchronize { @active }
        @logger.warn("Force-closing #{remaining} connection(s).") if remaining.positive?
        @write_mutex.synchronize { @backend&.close rescue nil }
      end

      # ── Accessors ────────────────────────────────────────────────────────────

      # Canonical bind address string (e.g. "127.0.0.1:7400" or "/tmp/store.sock").
      # Cached at initialize time — safe to call even after stop closes the socket.
      def bind_address
        @bind_address_str
      end

      # Number of currently active client connections.
      def active_connections
        @active_mutex.synchronize { @active }
      end

      # Number of active push subscriptions for a given store name.
      def subscription_count(store)
        @registry.subscriber_count(store)
      end

      # Compact health snapshot Hash.
      # status: :ready | :stopped
      def health_snapshot
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        snap = @metrics.snapshot
        {
          schema_version:     1,
          status:             @stopped ? :stopped : :ready,
          backend:            @backend_type.to_s,
          transport:          @transport_type.to_s,
          bind_address:       @bind_address_str,
          uptime_ms:          ((@started_at ? now - @started_at : 0) * 1000).ceil,
          active_connections: active_connections,
          subscriptions:      snap[:subscription_count],
          last_error:         @last_error
        }
      end

      # Full metrics snapshot including counters, connection telemetry, and storage stats.
      def metrics_snapshot
        @metrics.snapshot(backend: @backend)
      end

      # Lazy Protocol::Interpreter for the envelope dispatch layer.
      # Owns a fresh IgniterStore independent of the legacy fact log.
      # HTTP and TCP adapters share this interpreter instance.
      def protocol
        @protocol ||= Protocol::Interpreter.new(IgniterStore.new)
      end

      # Starts the legacy accept loop plus optional HTTP/TCP envelope adapters,
      # all in one foreground process. Adapters are stopped on exit.
      def start_with_adapters(http_port: nil, tcp_port: nil)
        http = http_port ? HTTPAdapter.new(
          interpreter:     protocol,
          port:            http_port,
          health_provider: method(:health_snapshot)
        ) : nil
        tcp  = tcp_port  ? TCPAdapter.new(interpreter: protocol, port: tcp_port)  : nil
        http&.start_async
        tcp&.start_async
        start_foreground
      ensure
        http&.stop
        tcp&.stop
      end

      # ── Private ──────────────────────────────────────────────────────────────

      private

      def build_backend(type, path)
        case type
        when :memory then nil
        when :file   then FileBackend.new(path.to_s)
        else raise ArgumentError, "StoreServer backend must be :memory or :file, got #{type.inspect}"
        end
      end

      def build_server(host, port, transport)
        case transport
        when :tcp
          server = TCPServer.new(host.to_s, Integer(port))
          server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
          server
        when :unix
          UNIXServer.new(host.to_s)
        else
          raise ArgumentError, "Unknown transport: #{transport.inspect}. Use :tcp or :unix"
        end
      end

      def split_address(address)
        host, port_s = address.to_s.split(":")
        [host, port_s ? Integer(port_s) : 7400]
      end

      def handle_client(socket)
        close_reason = :normal
        conn_id      = nil

        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true) rescue nil
        remote_addr = socket.peeraddr(false)[2] rescue "unknown"
        conn_id = @metrics.record_connection_accepted(remote_addr: remote_addr)
        @logger.event(:connection_open, connection_id: conn_id, remote_addr: remote_addr)

        loop do
          body = read_frame(socket)
          break unless body

          req = JSON.parse(body, symbolize_names: true)

          if req[:op] == "subscribe"
            stores = (req[:stores] || []).map(&:to_s)
            handle_subscription_mode(socket, stores, connection_id: conn_id)
            break
          end

          resp       = dispatch(req)
          resp_json  = JSON.generate(resp)
          resp_frame = encode_frame(resp_json)
          @metrics.record_request(
            connection_id: conn_id, op: req[:op].to_s,
            bytes_in: body.bytesize, bytes_out: resp_frame.bytesize
          )
          if resp[:ok] == false
            @metrics.record_error(op: req[:op].to_s, error_class: "RequestError")
            @logger.event(:request_error, level: :warn,
                          connection_id: conn_id, op: req[:op].to_s, error: resp[:error])
          else
            @logger.event(:request, level: :debug, connection_id: conn_id, op: req[:op].to_s)
          end
          socket.write(resp_frame)
          break if req[:op] == "close"
        end
      rescue IOError, Errno::ECONNRESET, Errno::EPIPE, Errno::EBADF
        close_reason = :io_error
      rescue => e
        close_reason = :error
        @last_error  = e.message
        @logger.warn("handle_client: #{e.class}: #{e.message}")
        @logger.event(:backend_error, level: :error,
                      connection_id: conn_id, error_class: e.class.to_s, message: e.message)
        @metrics.record_error(op: "connection", error_class: e.class.to_s)
      ensure
        socket.close rescue nil
        @active_mutex.synchronize { @active -= 1 }
        if conn_id
          @metrics.record_connection_closed(id: conn_id, reason: close_reason)
          @logger.event(:connection_close, connection_id: conn_id, reason: close_reason)
        end
        @logger.debug("Connection closed (active=#{@active_mutex.synchronize { @active }})")
      end

      def handle_subscription_mode(socket, stores, connection_id: nil)
        write_mutex = Mutex.new
        adapter = lambda do |fact|
          frame = encode_frame(JSON.generate({ event: "fact_written", fact: fact.to_h }))
          write_mutex.synchronize { socket.write(frame) }
        end

        # Ack before registering: no concurrent writes possible until after this line.
        socket.write(encode_frame(JSON.generate({ ok: true })))
        stores.each { |s| @metrics.record_subscription_opened(store: s) }
        @logger.event(:subscription_open, connection_id: connection_id, stores: stores)
        record = @registry.subscribe(stores: stores, &adapter)

        loop do
          body = read_frame(socket)
          break unless body
          break if JSON.parse(body, symbolize_names: true)[:op] == "close"
        end
      rescue IOError, Errno::ECONNRESET, Errno::EPIPE, Errno::EBADF
        nil
      ensure
        @registry.unsubscribe(record)
        stores.each { |s| @metrics.record_subscription_closed(store: s) }
        @logger.event(:subscription_close, connection_id: connection_id, stores: stores)
      end

      def dispatch(req)
        case req[:op]
        when "write_fact"
          fact = decode_fact(req[:fact])
          @write_mutex.synchronize do
            @backend&.write_fact(fact)
            @in_memory_facts << fact
          end
          @registry.fan_out(fact)
          @metrics.record_facts_written
          { ok: true }

        when "replay"
          facts = @write_mutex.synchronize do
            @backend ? @backend.replay : @in_memory_facts.dup
          end
          @metrics.record_facts_replayed(count: facts.size)
          { ok: true, facts: facts.map(&:to_h) }

        when "write_snapshot"
          if @backend.respond_to?(:write_snapshot)
            facts = (req[:facts] || []).map { |h| decode_fact(h) }
            @write_mutex.synchronize { @backend.write_snapshot(facts) }
            { ok: true }
          else
            { ok: true }
          end

        when "stats"
          uptime_ms = @started_at ?
            ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at) * 1000).ceil : 0
          facts_written = @write_mutex.synchronize { @in_memory_facts.size }
          {
            ok:                 true,
            facts_written:      facts_written,
            connections_active: @active_mutex.synchronize { @active },
            uptime_ms:          uptime_ms
          }

        when "server_status"
          snap = @metrics.snapshot(backend: @backend)
          { ok: true }.merge(snap)

        when "ping"
          { ok: true, pong: true }

        when "close"
          { ok: true }

        else
          { ok: false, error: "Unknown op: #{req[:op].inspect}" }
        end
      rescue => e
        { ok: false, error: e.message }
      end

      def decode_fact(h)
        Fact.from_h(h)
      end

      def write_pid_file(path)
        return unless path
        File.write(path, "#{Process.pid}\n")
        @logger.info("PID #{Process.pid} written to #{path}")
      rescue SystemCallError => e
        @logger.warn("Could not write PID file #{path}: #{e.message}")
      end

      def remove_pid_file
        return unless @pid_file && File.exist?(@pid_file)
        File.delete(@pid_file)
      rescue SystemCallError
        nil
      end
    end
  end
end

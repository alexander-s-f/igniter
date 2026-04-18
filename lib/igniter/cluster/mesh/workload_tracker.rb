# frozen_string_literal: true

module Igniter
  module Cluster
    module Mesh
      # Thread-safe accumulator of runtime workload signals across all peers.
      #
      # Each peer-capability pair maintains a sliding window of the most recent
      # `window_size` WorkloadSignal records. Older signals are dropped when the
      # window overflows, keeping memory bounded.
      #
      # Usage:
      #   tracker = WorkloadTracker.new(window_size: 100)
      #   tracker.record("node-a", :database, success: true, duration_ms: 42)
      #   tracker.record("node-a", :database, success: false, error: e)
      #
      #   report = tracker.report_for("node-a")
      #   report.failure_rate   # => 0.5
      #   report.degraded?      # => false (threshold is 0.3 by default)
      #
      #   tracker.degraded_peers   # => ["node-a"] when any peer exceeds threshold
      #   tracker.reset_peer!("node-a")  # clear signals for a specific peer
      class WorkloadTracker
        DEFAULT_WINDOW_SIZE          = 200
        DEFAULT_DEGRADED_THRESHOLD   = 0.3   # failure rate above which peer is degraded
        DEFAULT_OVERLOAD_THRESHOLD_MS = 1000  # avg ms above which peer is overloaded

        attr_reader :window_size, :degraded_threshold, :overload_threshold_ms

        def initialize(window_size: DEFAULT_WINDOW_SIZE,
                       degraded_threshold: DEFAULT_DEGRADED_THRESHOLD,
                       overload_threshold_ms: DEFAULT_OVERLOAD_THRESHOLD_MS)
          @window_size           = window_size
          @degraded_threshold    = degraded_threshold.to_f
          @overload_threshold_ms = overload_threshold_ms.to_f
          @windows               = Hash.new { |h, k| h[k] = [] }
          @mutex                 = Mutex.new
        end

        # Record a single workload signal for a peer-capability pair.
        #
        # @param peer_name   [String]
        # @param capability  [Symbol, nil]
        # @param success     [Boolean]
        # @param duration_ms [Numeric, nil]
        # @param error       [Exception, nil]
        # @return [WorkloadSignal]
        def record(peer_name, capability = nil, success:, duration_ms: nil, error: nil)
          signal = WorkloadSignal.build(
            peer_name:   peer_name,
            capability:  capability,
            success:     success,
            duration_ms: duration_ms,
            error:       error
          )
          @mutex.synchronize do
            key = window_key(peer_name, capability)
            window = @windows[key]
            window << signal
            window.shift if window.size > @window_size
          end
          signal
        end

        # Compute and return a capacity report for a single peer (all capabilities combined).
        #
        # @param peer_name [String]
        # @return [PeerCapacityReport]
        def report_for(peer_name)
          signals   = signals_for_peer(peer_name)
          caps      = capabilities_seen_for(peer_name)
          build_report(peer_name, signals, capabilities: caps)
        end

        # All signals recorded for a peer across all its capabilities.
        #
        # @return [Array<WorkloadSignal>]
        def signals_for_peer(peer_name)
          @mutex.synchronize do
            @windows
              .select { |k, _| k.start_with?("#{peer_name}:") || k == peer_name.to_s }
              .values.flatten
          end
        end

        # Capacity report for a specific peer+capability pair.
        #
        # @return [PeerCapacityReport]
        def report_for_capability(peer_name, capability)
          key     = window_key(peer_name, capability)
          signals = @mutex.synchronize { @windows[key].dup }
          build_report(peer_name, signals, capabilities: [capability&.to_sym].compact)
        end

        # Aggregated reports for every peer seen so far (snapshot).
        #
        # @return [Hash<String, PeerCapacityReport>]
        def all_reports
          peer_names = @mutex.synchronize do
            @windows.keys.map { |k| k.split(":").first }.uniq
          end
          peer_names.each_with_object({}) { |name, h| h[name] = report_for(name) }
        end

        # Peers whose failure_rate exceeds `degraded_threshold`.
        #
        # @param threshold [Float, nil]  override for this call
        # @return [Array<String>]
        def degraded_peers(threshold: nil)
          t = (threshold || @degraded_threshold).to_f
          all_reports.select { |_, r| r.failure_rate >= t }.keys
        end

        # Peers whose avg_duration_ms exceeds `overload_threshold_ms`.
        #
        # @param threshold_ms [Numeric, nil]  override for this call
        # @return [Array<String>]
        def overloaded_peers(threshold_ms: nil)
          t = (threshold_ms || @overload_threshold_ms).to_f
          all_reports.select { |_, r| r.avg_duration_ms && r.avg_duration_ms >= t }.keys
        end

        # All peer names with recorded signals.
        #
        # @return [Array<String>]
        def known_peers
          @mutex.synchronize do
            @windows.keys.map { |k| k.split(":").first }.uniq
          end
        end

        # Clear signals for a specific peer (e.g. after repair).
        #
        # @param peer_name [String]
        # @return [self]
        def reset_peer!(peer_name)
          @mutex.synchronize do
            @windows.reject! { |k, _| k.start_with?("#{peer_name}:") || k == peer_name.to_s }
          end
          self
        end

        # Clear all signals.
        #
        # @return [self]
        def reset!
          @mutex.synchronize { @windows.clear }
          self
        end

        def total_signals
          @mutex.synchronize { @windows.values.sum(&:size) }
        end

        # Build the mesh_workload metadata hash for a peer, suitable for merging
        # into a NodeObservation's metadata. Returns nil if no signals recorded.
        #
        # @param peer_name [String]
        # @return [Hash, nil]
        def to_metadata_for(peer_name)
          report = report_for(peer_name)
          return nil if report.total.zero?

          {
            mesh_workload: {
              failure_rate:    report.failure_rate,
              avg_duration_ms: report.avg_duration_ms,
              total:           report.total,
              degraded:        report.degraded?,
              overloaded:      report.overloaded?
            }.compact
          }
        end

        private

        def window_key(peer_name, capability)
          capability ? "#{peer_name}:#{capability}" : peer_name.to_s
        end

        def capabilities_seen_for(peer_name)
          @mutex.synchronize do
            @windows
              .keys
              .select { |k| k.start_with?("#{peer_name}:") }
              .map    { |k| k.split(":", 2).last.to_sym }
          end
        end

        def build_report(peer_name, signals, capabilities:)
          total     = signals.size
          successes = signals.count(&:success)
          failures  = total - successes

          failure_rate = total.zero? ? 0.0 : failures.to_f / total

          durations    = signals.filter_map(&:duration_ms)
          avg_ms       = durations.empty? ? nil : durations.sum / durations.size

          PeerCapacityReport.new(
            peer_name:       peer_name.to_s,
            total:           total,
            successes:       successes,
            failures:        failures,
            failure_rate:    failure_rate,
            avg_duration_ms: avg_ms,
            degraded:        failure_rate >= @degraded_threshold,
            overloaded:      avg_ms && avg_ms >= @overload_threshold_ms,
            capabilities:    capabilities
          )
        end
      end
    end
  end
end

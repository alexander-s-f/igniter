# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/stream_loop")
module Igniter
  # Runs an Igniter contract in a continuous tick-loop.
  #
  # Each tick resolves the contract with the current inputs and delivers the
  # result to the on_result callback. Useful for sensor polling, feed
  # processing, or any recurring computation.
  #
  #   stream = Igniter::StreamLoop.new(
  #     contract:      SensorContract,
  #     tick_interval: 0.1,
  #     inputs:        { sensor_id: "temp-1", threshold: 25.0 },
  #     on_result:     ->(result) { puts result.status },
  #     on_error:      ->(err)    { warn err.message }
  #   )
  #
  #   stream.start
  #   stream.update_inputs(threshold: 30.0)  # hot-swap inputs between ticks
  #   stream.stop
  #
  class StreamLoop
    def initialize(contract:, tick_interval: 1.0, inputs: {}, on_result: nil, on_error: nil)
      @contract_class = contract
      @tick_interval  = tick_interval.to_f
      @on_result      = on_result
      @on_error       = on_error
      @mutex          = Mutex.new
      @current_inputs = inputs.dup
      @running        = false
      @thread         = nil
    end

    # Start the loop in a background thread. Returns self.
    def start
      @running = true
      @thread  = Thread.new { loop_body }
      @thread.abort_on_exception = false
      self
    end

    # Stop the loop and wait for the current tick to finish.
    def stop(timeout: 5)
      @running = false
      @thread&.join(timeout)
      self
    end

    # Merge +new_inputs+ into the current input set. Takes effect on the next tick.
    def update_inputs(new_inputs)
      @mutex.synchronize { @current_inputs.merge!(new_inputs) }
      self
    end

    def alive?
      @thread&.alive? || false
    end

    private

    def loop_body
      while @running
        tick_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        run_tick
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - tick_start
        sleep_for = [@tick_interval - elapsed, 0].max
        sleep(sleep_for) if sleep_for.positive? && @running
      end
    end

    def run_tick
      inputs   = @mutex.synchronize { @current_inputs.dup }
      contract = @contract_class.new(**inputs)
      contract.resolve_all
      @on_result&.call(contract.result)
    rescue StandardError => e
      @on_error&.call(e)
    end
  end
end

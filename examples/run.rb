#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "rbconfig"
require "timeout"

require_relative "catalog"

module IgniterExamples
  class Runner
    Result = Struct.new(
      :example,
      :status,
      :stdout,
      :stderr,
      :exit_status,
      :elapsed,
      :reason,
      keyword_init: true
    ) do
      def ok?
        status == :passed
      end
    end

    def run(example, extra_args: nil)
      unless example.runnable?
        return Result.new(example: example, status: :skipped, reason: example.skip_reason)
      end

      argv = extra_args.nil? ? example.command_args : extra_args
      if !example.autonomous? && argv.empty?
        return Result.new(example: example, status: :skipped, reason: example.skip_reason)
      end

      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stdout = +""
      stderr = +""
      exit_status = nil

      Timeout.timeout(example.timeout) do
        stdout, stderr, process_status = Open3.capture3(
          RbConfig.ruby,
          example.full_path,
          *argv
        )
        exit_status = process_status.exitstatus
      end

      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      failure_reason = validate_output(example, stdout, exit_status)
      status = failure_reason ? :failed : :passed

      Result.new(
        example: example,
        status: status,
        stdout: stdout,
        stderr: stderr,
        exit_status: exit_status,
        elapsed: elapsed,
        reason: failure_reason
      )
    rescue Timeout::Error
      Result.new(
        example: example,
        status: :failed,
        stdout: stdout,
        stderr: stderr,
        exit_status: nil,
        elapsed: Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at,
        reason: "timed out after #{example.timeout}s"
      )
    end

    private

    def validate_output(example, stdout, exit_status)
      return "exited with status #{exit_status}" unless exit_status == 0

      missing = Array(example.expected_fragments).reject { |fragment| stdout.include?(fragment) }
      return nil if missing.empty?

      "missing expected output: #{missing.first.inspect}"
    end
  end
end

def print_usage
  puts "Usage:"
  puts "  ruby examples/run.rb list"
  puts "  ruby examples/run.rb smoke"
  puts "  ruby examples/run.rb all"
  puts "  ruby examples/run.rb run <example> [example args...]"
end

def print_list
  IgniterExamples.all.each do |example|
    suffix = example.skip_reason ? " (#{example.skip_reason})" : ""
    puts "#{example.status.to_s.ljust(11)} #{example.id.ljust(24)} #{example.summary}#{suffix}"
  end
end

def print_result(result)
  label = result.status.to_s.upcase.ljust(7)
  timing = result.elapsed ? format("%0.2fs", result.elapsed) : "--"
  line = "#{label} #{result.example.id.ljust(24)} #{timing}"
  line += "  #{result.reason}" if result.reason
  puts line

  return unless result.status == :failed

  unless result.stderr.to_s.empty?
    first_error = result.stderr.lines.first.to_s.strip
    puts "        stderr: #{first_error}" unless first_error.empty?
  end
end

def run_examples(examples, extra_args: nil)
  runner = IgniterExamples::Runner.new
  results = examples.map do |example|
    runner.run(example, extra_args: extra_args)
  end

  results.each { |result| print_result(result) }

  passed = results.count(&:ok?)
  failed = results.count { |result| result.status == :failed }
  skipped = results.count { |result| result.status == :skipped }

  puts
  puts "Summary: #{passed} passed, #{failed} failed, #{skipped} skipped"

  exit(failed.zero? ? 0 : 1)
end

command = ARGV.shift || "smoke"

case command
when "list"
  print_list
when "smoke"
  run_examples(IgniterExamples.smoke)
when "all"
  run_examples(IgniterExamples.all)
when "run"
  name = ARGV.shift
  unless name
    print_usage
    exit 1
  end

  example = IgniterExamples.find(name)
  unless example
    warn "Unknown example: #{name}"
    exit 1
  end

  run_examples([example], extra_args: ARGV)
else
  print_usage
  exit 1
end

#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Igniter Store Playground
# ========================
# Run all demos:
#   ruby playground/run.rb
#
# Run a single demo:
#   ruby playground/run.rb 01
#   ruby playground/run.rb 03 06
#
# Start an interactive REPL with everything pre-loaded:
#   ruby playground/run.rb repl
#
# From the package root (packages/igniter-companion/):
#   bundle exec ruby playground/run.rb

require_relative "setup"

DEMO_DIR = File.join(__dir__, "demos")

ALL_DEMOS = {
  "01" => { file: "01_basic.rb",       title: "Write / Read / Scope",            method: :run_01 },
  "02" => { file: "02_time_travel.rb", title: "Time Travel",                      method: :run_02 },
  "03" => { file: "03_history.rb",     title: "History & Partition Replay",       method: :run_03 },
  "04" => { file: "04_coercion.rb",    title: "Schema Version Coercion",          method: :run_04 },
  "05" => { file: "05_snapshot.rb",    title: "WAL Snapshot Checkpoint",          method: :run_05 },
  "06" => { file: "06_concurrent.rb",  title: "Concurrency",                      method: :run_06 },
  "07" => { file: "07_network.rb",     title: "NetworkBackend / StoreServer",     method: :run_07 }
}.freeze

def banner
  width = 60
  puts "═" * width
  puts " Igniter Store Playground".center(width)
  puts " igniter-companion · igniter-store".center(width)
  puts " NATIVE = #{Igniter::Store::NATIVE}".center(width)
  puts "═" * width
end

def run_demos(keys)
  store = Playground.store
  store_with_log = Playground::Tools::Logger.new(store)

  keys.each do |key|
    meta = ALL_DEMOS[key]
    unless meta
      puts "  Unknown demo: #{key.inspect}  (valid: #{ALL_DEMOS.keys.join(', ')})"
      next
    end

    require File.join(DEMO_DIR, meta[:file])
    method(meta[:method]).call(store_with_log)
  end

  puts ""
  store_with_log.summary
  Playground::Tools::Inspector.new(store).print_stats
end

def start_repl(binding_ctx)
  puts "\n▸ Starting IRB session with 'store', 'inspector', 'logger' pre-loaded."
  puts "  Type 'exit' to quit.\n\n"
  require "irb"
  IRB.start
end

# ── Entry point ──────────────────────────────────────────────────────────────

banner

args = ARGV.dup

if args.include?("repl")
  require_relative "setup"
  Dir[File.join(DEMO_DIR, "*.rb")].sort.each { |f| require f }
  $store     = Playground.store
  $logger    = Playground::Tools::Logger.new($store)
  $inspector = Playground::Tools::Inspector.new($store)
  puts "  $store, $logger, $inspector are ready."
  start_repl(binding)
else
  selected = args.empty? ? ALL_DEMOS.keys : args.map { |a| a.rjust(2, "0") }
  run_demos(selected)
end

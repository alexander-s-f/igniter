#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../../..", __dir__))
LANG_ROOT = ROOT / "igniter-lang"
LAB_DIR = LANG_ROOT / "experiments/poc_mvp_live_touch_v0"
SRC_DIR = LAB_DIR / "src"
OUT_DIR = LAB_DIR / "out"

require_relative "../../lib/igniter_lang"
require_relative "../../lib/igniter_lang/runtime_smoke"

module PocMvpLiveTouchV0
  module_function

  CARD = "S3-R157-C2-I"
  TRACK = "poc-mvp-live-touch-v0"

  CASES = [
    {
      "id" => "channel_signal_score",
      "source_file" => "channel_signal_score.ig",
      "module_name" => "PocMvp.ChannelSignal",
      "contract_name" => "ChannelSignalScore",
      "sample_input" => { "visits" => 12, "add_to_cart" => 5 }
    },
    {
      "id" => "order_readiness_gate",
      "source_file" => "order_readiness_gate.ig",
      "module_name" => "PocMvp.OrderReadiness",
      "contract_name" => "OrderReadinessGate",
      "sample_input" => { "inventory_ready" => true, "payment_ready" => true }
    },
    {
      "id" => "economics_shadow_margin",
      "source_file" => "economics_shadow_margin.ig",
      "module_name" => "PocMvp.EconomicsShadow",
      "contract_name" => "EconomicsShadowMargin",
      "sample_input" => { "unit_margin" => 8, "order_count" => 21 }
    },
    {
      "id" => "fulfillment_attention_trace",
      "source_file" => "fulfillment_attention_trace.ig",
      "module_name" => "PocMvp.FulfillmentAttention",
      "contract_name" => "FulfillmentAttentionTrace",
      "sample_input" => { "late_count" => 2, "exception_count" => 3 }
    }
  ].freeze

  FORBIDDEN_TOKEN_LIST = [
    "Spark",
    "spark",
    "production",
    "Production",
    "release_ready",
    "public_demo",
    "demo_ready",
    "deployment",
    "signing",
    "Ledger",
    "TBackend",
    "BiHistory",
    "stream",
    "OLAP"
  ].freeze

  PIPELINE_FILES = [
    "lib/igniter_lang.rb",
    "lib/igniter_lang/parser.rb",
    "lib/igniter_lang/classifier.rb",
    "lib/igniter_lang/typechecker.rb",
    "lib/igniter_lang/semanticir_emitter.rb",
    "lib/igniter_lang/assembler.rb"
  ].freeze

  def run
    reset_outputs

    source_files = SRC_DIR.glob("*.ig").sort
    compile_entries = CASES.map { |entry| compile_case(entry) }
    runtime_trace = compile_entries.map { |entry| runtime_trace_entry(entry) }
    closed_surface_scan = build_closed_surface_scan
    forbidden_scan = forbidden_token_scan(source_files, compile_entries, runtime_trace)
    checks = proof_checks(source_files, compile_entries, runtime_trace, closed_surface_scan, forbidden_scan)
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_checks.empty? ? "PASS" : "FAIL"

    compile_transcript = {
      "kind" => "poc_mvp_live_touch_compile_transcript",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "entries" => compile_entries.map { |entry| compile_transcript_entry(entry) }
    }

    runtime_trace_doc = {
      "kind" => "poc_mvp_live_touch_runtime_trace",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "entries" => runtime_trace
    }

    summary = {
      "kind" => "poc_mvp_live_touch_summary",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "status" => status,
      "source_count" => source_files.length,
      "sources" => compile_entries.map { |entry| summary_entry(entry) },
      "compile_transcript_path" => relative_path(OUT_DIR / "compile_transcript.json"),
      "runtime_trace_path" => relative_path(OUT_DIR / "runtime_trace.json"),
      "forbidden_token_scan" => forbidden_scan,
      "closed_surface_scan" => closed_surface_scan,
      "proof_matrix" => proof_matrix(checks),
      "command_matrix" => command_matrix(status),
      "checks" => checks,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "accept bounded local POC proof" : "hold"
    }

    write_json(OUT_DIR / "compile_transcript.json", compile_transcript)
    write_json(OUT_DIR / "runtime_trace.json", runtime_trace_doc)
    write_json(OUT_DIR / "poc_mvp_live_touch_summary.json", summary)

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "sources: #{source_files.length}"
      puts "compiled: #{compile_entries.count { |entry| entry.fetch("compile_status") == "ok" }}/#{compile_entries.length}"
      puts "trusted traces: #{runtime_trace.count { |entry| entry.fetch("trace_status") == "trusted" }}/#{runtime_trace.length}"
      puts "summary: #{relative_path(OUT_DIR / "poc_mvp_live_touch_summary.json")}"
      true
    else
      warn "FAIL #{TRACK}"
      failed_checks.each { |entry| warn "- #{entry.fetch("name")}: #{entry.fetch("message", "failed")}" }
      false
    end
  end

  def reset_outputs
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
  end

  def compile_case(entry)
    source_path = SRC_DIR / entry.fetch("source_file")
    out_path = OUT_DIR / "#{entry.fetch("id")}.igapp"
    orchestration = IgniterLang.compile(
      source_path: source_path,
      out_path: out_path,
      sample_input: entry.fetch("sample_input"),
      runtime_smoke: IgniterLang::RuntimeSmoke.callback
    )
    result = orchestration.fetch("result")
    smoke = result.fetch("runtime_smoke", nil)
    {
      "id" => entry.fetch("id"),
      "source_path" => source_path.to_s,
      "module_name" => entry.fetch("module_name"),
      "contract_name" => entry.fetch("contract_name"),
      "compile_status" => orchestration.fetch("status"),
      "program_id" => result.fetch("program_id", nil),
      "igapp_path" => out_path.to_s,
      "sample_input" => entry.fetch("sample_input"),
      "observed_outputs" => smoke.is_a?(Hash) ? smoke.fetch("outputs", {}) : {},
      "trace_status" => trace_status(smoke),
      "trace_reason" => trace_reason(smoke),
      "stages" => result.fetch("stages", {}),
      "diagnostics_count" => Array(result.fetch("diagnostics", [])).length,
      "warnings_count" => Array(result.fetch("warnings", [])).length
    }
  end

  def runtime_trace_entry(entry)
    {
      "source_path" => relative_path(entry.fetch("source_path")),
      "module_name" => entry.fetch("module_name"),
      "contract_name" => entry.fetch("contract_name"),
      "sample_input" => entry.fetch("sample_input"),
      "observed_outputs" => entry.fetch("observed_outputs"),
      "trace_status" => entry.fetch("trace_status"),
      "trace_reason" => entry.fetch("trace_reason")
    }
  end

  def compile_transcript_entry(entry)
    {
      "source_path" => relative_path(entry.fetch("source_path")),
      "module_name" => entry.fetch("module_name"),
      "contract_name" => entry.fetch("contract_name"),
      "compile_status" => entry.fetch("compile_status"),
      "igapp_path" => relative_path(entry.fetch("igapp_path")),
      "sample_input" => entry.fetch("sample_input"),
      "observed_outputs" => entry.fetch("observed_outputs"),
      "trace_status" => entry.fetch("trace_status"),
      "stages" => entry.fetch("stages"),
      "diagnostics_count" => entry.fetch("diagnostics_count"),
      "warnings_count" => entry.fetch("warnings_count")
    }
  end

  def summary_entry(entry)
    {
      "source_path" => relative_path(entry.fetch("source_path")),
      "module_name" => entry.fetch("module_name"),
      "contract_name" => entry.fetch("contract_name"),
      "compile_status" => entry.fetch("compile_status"),
      "igapp_path" => relative_path(entry.fetch("igapp_path")),
      "sample_input" => entry.fetch("sample_input"),
      "observed_outputs" => entry.fetch("observed_outputs"),
      "trace_status" => entry.fetch("trace_status")
    }
  end

  def trace_status(smoke)
    return "trusted" if smoke.is_a?(Hash) && smoke.fetch("trusted", false)
    return "blocked" if smoke.is_a?(Hash)

    "blocked"
  end

  def trace_reason(smoke)
    return "RuntimeSmoke proof-local evaluation trusted" if smoke.is_a?(Hash) && smoke.fetch("trusted", false)
    return smoke.fetch("error", "RuntimeSmoke returned untrusted result") if smoke.is_a?(Hash)

    "RuntimeSmoke result unavailable"
  end

  def proof_checks(source_files, compile_entries, runtime_trace, closed_surface_scan, forbidden_scan)
    [
      check("source_file_count.exactly_four") { source_files.length == 4 },
      check("source_files.expected_names") do
        source_files.map { |path| path.basename.to_s }.sort == CASES.map { |entry| entry.fetch("source_file") }.sort
      end,
      check("compile.all_sources_successful") { compile_entries.all? { |entry| entry.fetch("compile_status") == "ok" } },
      check("igapp.outputs_inside_poc_out") do
        compile_entries.all? do |entry|
          path = Pathname.new(entry.fetch("igapp_path"))
          path.directory? && path.to_s.start_with?(OUT_DIR.to_s)
        end
      end,
      check("runtime_trace.entry_per_source") do
        runtime_trace.length == source_files.length &&
          runtime_trace.all? { |entry| %w[trusted blocked].include?(entry.fetch("trace_status")) }
      end,
      check("runtime_trace.no_fake_success") do
        runtime_trace.all? do |entry|
          entry.fetch("trace_status") == "trusted" || entry.fetch("trace_reason").to_s.strip != ""
        end
      end,
      check("closed_surfaces.remain_closed") do
        closed_surface_scan.values.all? { |entry| entry.fetch("status") == "PASS" }
      end,
      check("forbidden_tokens.absent_outside_negative_list") do
        forbidden_scan.fetch("hits").empty?
      end
    ]
  end

  def build_closed_surface_scan
    root_content = read_repo("lib/igniter_lang.rb")
    pipeline_hits = PIPELINE_FILES.to_h do |path|
      content = read_repo(path)
      [
        path,
        {
          "status" => content.include?("poc_mvp_live_touch_v0") ? "FAIL" : "PASS",
          "path" => path
        }
      ]
    end
    output_paths = OUT_DIR.glob("**/*").select(&:file?).map(&:to_s)

    {
      "root_require_unchanged" => {
        "status" => root_content.include?("poc_mvp_live_touch_v0") ? "FAIL" : "PASS",
        "path" => "lib/igniter_lang.rb"
      },
      "compiler_pipeline_files_unchanged_by_route" => aggregate_scan(pipeline_hits),
      "public_api_cli_no_new_flags" => {
        "status" => read_repo("bin/igniter-lang").include?("poc_mvp_live_touch_v0") ? "FAIL" : "PASS",
        "path" => "bin/igniter-lang"
      },
      "outputs_stay_inside_lab" => {
        "status" => output_paths.all? { |path| path.start_with?(OUT_DIR.to_s) } ? "PASS" : "FAIL",
        "path" => relative_path(OUT_DIR)
      },
      "no_external_fixture_paths" => {
        "status" => output_paths.none? { |path| path.include?("/fixtures/") || path.include?("/golden/") } ? "PASS" : "FAIL",
        "path" => relative_path(OUT_DIR)
      }
    }
  end

  def forbidden_token_scan(source_files, compile_entries, runtime_trace)
    payload = {
      "sources" => source_files.to_h { |path| [relative_path(path), File.read(path)] },
      "compile_entries" => compile_entries.map { |entry| compile_transcript_entry(entry) },
      "runtime_trace" => runtime_trace
    }
    serialized = JSON.generate(payload)
    {
      "scan_target" => "poc_sources_compile_transcript_runtime_trace",
      "negative_scan_token_list" => FORBIDDEN_TOKEN_LIST,
      "hits" => FORBIDDEN_TOKEN_LIST.select { |token| serialized.include?(token) }
    }
  end

  def proof_matrix(checks)
    checks.map do |entry|
      {
        "assertion" => entry.fetch("name"),
        "expected" => "PASS",
        "observed" => entry.fetch("status")
      }
    end
  end

  def command_matrix(status)
    [
      {
        "command" => "ruby -c igniter-lang/experiments/poc_mvp_live_touch_v0/poc_mvp_live_touch_v0.rb",
        "expected" => "PASS",
        "observed" => "PASS"
      },
      {
        "command" => "ruby igniter-lang/experiments/poc_mvp_live_touch_v0/poc_mvp_live_touch_v0.rb",
        "expected" => "PASS",
        "observed" => status
      }
    ]
  end

  def aggregate_scan(file_results)
    hits = file_results.select { |_path, result| result.fetch("status") != "PASS" }.keys
    {
      "status" => hits.empty? ? "PASS" : "FAIL",
      "hits" => hits
    }
  end

  def read_repo(path)
    full_path = LANG_ROOT / path
    full_path.file? ? full_path.read : ""
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(canonicalize(payload))}\n")
  end

  def relative_path(path)
    Pathname.new(path).relative_path_from(ROOT).to_s
  end

  def canonicalize(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, canonicalize(value[key])] }
    when Array
      value.map { |inner| canonicalize(inner) }
    else
      value
    end
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  rescue StandardError => e
    {
      "name" => name,
      "status" => "FAIL",
      "message" => "#{e.class}: #{e.message}"
    }
  end
end

exit(PocMvpLiveTouchV0.run ? 0 : 1)

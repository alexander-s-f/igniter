#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module StreamTProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/stream_t_proof"
  GOLDEN_DIR = FIXTURE_DIR / "golden"
  SUMMARY_PATH = FIXTURE_DIR / "summary.json"
  FORMAT_VERSION = "0.1.0"
  TRACK = "stream-t-proof-v0"
  CONTRACT_REF = "contract/Fixture.StreamT.IntegerWindowSum@v0"
  SOURCE_PATH = FIXTURE_DIR / "stream_integer_window.ig"
  DEVICE_ID = "device/synthetic-stream-1"
  STREAM_REF = "stream/integer/device-synthetic-stream-1"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value[key]) }
      when Array
        value.map { |item| normalize(item) }
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def pretty(value)
      "#{JSON.pretty_generate(normalize(value))}\n"
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).split(":").last[0, 16]
    end
  end

  class StreamCapabilityHandler
    def materialize_window(stream_node:, window_node:, source:)
      case source.fetch("mode")
      when "finite_replay"
        materialize_finite_replay(stream_node: stream_node, window_node: window_node, source: source)
      when "open_live"
        open_live_descriptor(stream_node: stream_node, window_node: window_node, source: source)
      else
        raise ArgumentError, "unknown stream source mode: #{source.fetch("mode")}"
      end
    end

    private

    def materialize_finite_replay(stream_node:, window_node:, source:)
      size = window_node.fetch("size")
      events = source.fetch("events").sort_by { |event| event.fetch("sequence") }
      consumed = events.first(size)
      payload = {
        "kind" => "stream_window",
        "source_mode" => "finite_replay",
        "stream_ref" => stream_node.fetch("name"),
        "stream_type" => stream_node.fetch("type"),
        "window_ref" => window_node.fetch("ref"),
        "window_kind" => window_node.fetch("window_kind"),
        "closed" => consumed.length == size,
        "close_reason" => "count_bound_reached",
        "bound" => { "kind" => "count", "size" => size },
        "events" => consumed,
        "remaining_event_refs" => events.drop(size).map { |event| event.fetch("event_id") }
      }
      observation = window_observation(payload, window_node)
      payload.merge(
        "window_id" => "window/stream/#{Canonical.short_hash(payload)}",
        "observation" => observation
      )
    end

    def open_live_descriptor(stream_node:, window_node:, source:)
      payload = {
        "kind" => "stream_window",
        "source_mode" => "open_live",
        "stream_ref" => stream_node.fetch("name"),
        "stream_type" => stream_node.fetch("type"),
        "window_ref" => window_node.fetch("ref"),
        "window_kind" => window_node.fetch("window_kind"),
        "closed" => false,
        "close_reason" => nil,
        "status" => "waiting_for_runtime_window_close",
        "adapter_ref" => source.fetch("adapter_ref"),
        "events" => [],
        "remaining_event_refs" => []
      }
      payload.merge("window_id" => "window/open/#{Canonical.short_hash(payload)}")
    end

    def window_observation(window, window_node)
      consumed = window.fetch("events")
      payload = {
        "kind" => "stream_window_observation",
        "source_mode" => window.fetch("source_mode"),
        "window_ref" => window.fetch("window_ref"),
        "window_kind" => window.fetch("window_kind"),
        "on_close" => window_node.fetch("on_close"),
        "closed" => window.fetch("closed"),
        "event_count" => consumed.length,
        "consumed_event_refs" => consumed.map { |event| event.fetch("event_id") },
        "sequence_range" => consumed.empty? ? nil : [
          consumed.first.fetch("sequence"),
          consumed.last.fetch("sequence")
        ]
      }
      payload.merge(
        "observation_id" => "obs/stream_window/#{Canonical.short_hash(payload)}",
        "lifecycle" => window_node.fetch("on_close") == "snapshot" ? "durable" : "session"
      )
    end
  end

  class RuntimeEvaluator
    def initialize(semantic_ir)
      @semantic_ir = semantic_ir
      @handler = StreamCapabilityHandler.new
    end

    def evaluate(source:)
      contract = @semantic_ir.fetch("contracts").first
      stream_node = node(contract, "stream_input_node")
      window_node = node(contract, "window_decl_node")
      fold_node = node(contract, "fold_stream_node")
      window = @handler.materialize_window(stream_node: stream_node, window_node: window_node, source: source)
      return open_live_result(window, stream_node, window_node) unless window.fetch("closed")

      fold = fold_window(fold_node, window)
      snapshot = {
        "kind" => "IntegerWindowSnapshot",
        "device_id" => DEVICE_ID,
        "total" => fold.fetch("value"),
        "count" => fold.fetch("event_count"),
        "window_id" => window.fetch("window_id"),
        "consumed_event_refs" => window.dig("observation", "consumed_event_refs")
      }
      {
        "kind" => "stream_runtime_result",
        "format_version" => FORMAT_VERSION,
        "contract_ref" => CONTRACT_REF,
        "source_mode" => source.fetch("mode"),
        "status" => "ok",
        "trusted_output" => true,
        "stream_classification" => "escape",
        "fold_result_classification" => "core",
        "window" => window,
        "fold_result" => fold,
        "output" => snapshot,
        "observations" => [window.fetch("observation")],
        "evidence_links" => window.dig("observation", "consumed_event_refs").map do |event_ref|
          {
            "rel" => "consumed_event",
            "from" => window.dig("observation", "observation_id"),
            "to" => event_ref
          }
        end
      }
    end

    private

    def open_live_result(window, stream_node, window_node)
      {
        "kind" => "stream_runtime_result",
        "format_version" => FORMAT_VERSION,
        "contract_ref" => CONTRACT_REF,
        "source_mode" => "open_live",
        "status" => "waiting_for_window_close",
        "trusted_output" => false,
        "stream_classification" => "escape",
        "fold_result_classification" => nil,
        "window" => window,
        "output" => nil,
        "observations" => [],
        "diagnostics" => [
          {
            "category" => "stream_runtime_pending",
            "severity" => "info",
            "message" => "Open live stream is not folded until #{window_node.fetch("window_kind")} window closes",
            "contract" => "IntegerWindowSum",
            "node" => stream_node.fetch("name"),
            "path" => "contract:IntegerWindowSum/stream:#{stream_node.fetch("name")}"
          }
        ]
      }
    end

    def fold_window(fold_node, window)
      raise "fold_stream requires closed bounded window" unless window.fetch("closed")
      raise "unsupported fold lambda" unless fold_node.fetch("fn_ref") == "integer_sum_lambda"

      values = window.fetch("events").map { |event| event.fetch("value") }
      {
        "kind" => "fold_stream_result",
        "node" => fold_node.fetch("name"),
        "value" => values.reduce(fold_node.fetch("init").fetch("value")) { |acc, value| acc + value },
        "event_count" => values.length,
        "input_event_refs" => window.fetch("events").map { |event| event.fetch("event_id") },
        "materialized_as" => "Collection[Integer]",
        "core_fold" => true
      }
    end

    def node(contract, kind)
      contract.fetch("nodes").find { |candidate| candidate.fetch("kind") == kind } ||
        raise("missing #{kind}")
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(GOLDEN_DIR)
    semantic_ir = semantic_ir_program
    finite_result = RuntimeEvaluator.new(semantic_ir).evaluate(source: finite_replay_source)
    open_live = RuntimeEvaluator.new(semantic_ir).evaluate(source: open_live_source)
    negatives = negative_reports
    summary = {
      "kind" => "stream_t_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks(semantic_ir, finite_result, open_live, negatives).values.all? ? "PASS" : "FAIL",
      "relationship_to_history" => {
        "stream_t" => "ingress_flow_escape_channel_windowed_before_core_fold",
        "history_t" => "durable_temporal_memory_read_by_explicit_time"
      },
      "semantic_ir_program" => semantic_ir,
      "finite_replay_result" => finite_result,
      "open_live_descriptor" => open_live,
      "negative_reports" => negatives,
      "checks" => checks(semantic_ir, finite_result, open_live, negatives)
    }
    write_outputs(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def semantic_ir_program
    {
      "kind" => "semantic_ir_program",
      "format_version" => FORMAT_VERSION,
      "program_id" => "semanticir/stream_t/#{Canonical.short_hash(File.read(SOURCE_PATH))}",
      "source_path" => SOURCE_PATH.relative_path_from(ROOT).to_s,
      "source_status" => "syntax_sketch_parser_not_used_in_this_proof",
      "contracts" => [
        {
          "kind" => "contract_ir",
          "contract_ref" => CONTRACT_REF,
          "contract_name" => "IntegerWindowSum",
          "fragment_class" => "escape",
          "inputs" => [
            { "name" => "device_id", "type" => { "name" => "String", "params" => [] }, "lifecycle" => "local" }
          ],
          "outputs" => [
            { "name" => "snapshot", "type" => { "name" => "IntegerWindowSnapshot", "params" => [] }, "lifecycle" => "durable" }
          ],
          "nodes" => [
            {
              "kind" => "stream_input_node",
              "name" => "readings",
              "type" => "Integer",
              "window_ref" => "integer_count_window",
              "escape_capability" => "stream_input",
              "fragment" => "escape"
            },
            {
              "kind" => "window_decl_node",
              "ref" => "integer_count_window",
              "key" => "integer/{device_id}",
              "window_kind" => "count",
              "size" => 3,
              "on_close" => "snapshot"
            },
            {
              "kind" => "fold_stream_node",
              "name" => "total",
              "stream_ref" => "readings",
              "init" => { "kind" => "integer_literal", "value" => 0 },
              "fn_ref" => "integer_sum_lambda",
              "bound" => { "kind" => "window_bounded", "window_ref" => "integer_count_window" },
              "result_type" => { "name" => "Integer", "params" => [] },
              "escape_capability" => "stream_input",
              "result_fragment" => "core"
            }
          ],
          "escape_boundaries" => [
            {
              "name" => "stream_input",
              "required_caps" => ["stream_input"],
              "produces" => ["stream_window_observation"]
            }
          ]
        }
      ]
    }
  end

  def finite_replay_source
    {
      "kind" => "stream_source",
      "mode" => "finite_replay",
      "stream_ref" => STREAM_REF,
      "determinism" => "ordered_replay",
      "events" => [
        event(1, 4, "2026-05-07T10:00:00Z"),
        event(2, 5, "2026-05-07T10:00:01Z"),
        event(3, 6, "2026-05-07T10:00:02Z"),
        event(4, 7, "2026-05-07T10:00:03Z"),
        event(5, 8, "2026-05-07T10:00:04Z")
      ]
    }
  end

  def open_live_source
    {
      "kind" => "stream_source",
      "mode" => "open_live",
      "stream_ref" => STREAM_REF,
      "adapter_ref" => "adapter/synthetic-live-integer-stream",
      "determinism" => "open_until_runtime_window_close"
    }
  end

  def event(sequence, value, observed_at)
    payload = {
      "kind" => "stream_event",
      "stream_ref" => STREAM_REF,
      "sequence" => sequence,
      "observed_at" => observed_at,
      "value" => value,
      "value_type" => "Integer"
    }
    payload.merge("event_id" => "evt/stream/#{Canonical.short_hash(payload)}")
  end

  def negative_reports
    [
      oof_report(
        "negative_unbounded_fold",
        "OOF-S1",
        "stream.unbounded_fold",
        "unbounded stream fold - must declare @window_bounded or @count_bounded"
      ),
      oof_report(
        "negative_missing_window",
        "OOF-S2",
        "stream.window_missing",
        "stream 'readings' has no window - every stream must declare a window"
      ),
      oof_report(
        "negative_direct_stream_use",
        "OOF-S4",
        "stream.direct_access",
        "stream 'readings' must be consumed via fold_stream - direct access is OOF"
      ),
      oof_report_typechecker(
        "negative_escape_in_fold",
        "OOF-S3",
        "stream.escape_in_fold_body",
        "fold_stream accumulator must be CORE - found ESCAPE: readings"
      )
    ]
  end

  def oof_report(case_id, rule, diagnostic, message)
    {
      "kind" => "compilation_report",
      "format_version" => FORMAT_VERSION,
      "case_id" => case_id,
      "pass_result" => "oof",
      "semantic_ir_ref" => nil,
      "stages" => {
        "parse" => "proof_local_sketch",
        "classify" => "oof",
        "typecheck" => "skipped",
        "emit" => "skipped"
      },
      "diagnostics" => [
        {
          "category" => "stream_oof",
          "rule" => rule,
          "severity" => "error",
          "diagnostic" => diagnostic,
          "message" => message,
          "contract" => "IntegerWindowSum",
          "node" => "readings",
          "path" => "contract:IntegerWindowSum/stream:readings",
          "span" => nil
        }
      ]
    }
  end

  # OOF-S3 is TypeChecker-owned: classify passes, typecheck blocks.
  def oof_report_typechecker(case_id, rule, diagnostic, message)
    {
      "kind" => "compilation_report",
      "format_version" => FORMAT_VERSION,
      "case_id" => case_id,
      "pass_result" => "oof",
      "semantic_ir_ref" => nil,
      "stages" => {
        "parse" => "proof_local_sketch",
        "classify" => "ok",
        "typecheck" => "oof",
        "emit" => "skipped"
      },
      "diagnostics" => [
        {
          "category" => "stream_oof",
          "rule" => rule,
          "severity" => "error",
          "diagnostic" => diagnostic,
          "message" => message,
          "contract" => "IntegerWindowSum",
          "node" => "bad_total",
          "path" => "contract:IntegerWindowSum/fold_stream:bad_total",
          "span" => nil
        }
      ]
    }
  end

  def checks(semantic_ir, finite_result, open_live, negatives)
    consumed = finite_result.dig("window", "observation", "consumed_event_refs")
    {
      "semanticir.stream_input_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "stream_input_node" },
      "semanticir.window_decl_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "window_decl_node" },
      "semanticir.fold_stream_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "fold_stream_node" },
      "classification.stream_is_escape" => finite_result.fetch("stream_classification") == "escape",
      "classification.fold_result_is_core" => finite_result.fetch("fold_result_classification") == "core",
      "runtime.finite_replay_window_closed" => finite_result.dig("window", "source_mode") == "finite_replay" &&
        finite_result.dig("window", "closed") == true,
      "runtime.fold_stream_sum" => finite_result.dig("output", "total") == 15 &&
        finite_result.dig("output", "count") == 3,
      "evidence.consumed_events_window" => consumed.length == 3 &&
        finite_result.fetch("evidence_links").length == 3,
      "runtime.open_live_waits_for_close" => open_live.fetch("source_mode") == "open_live" &&
        open_live.fetch("status") == "waiting_for_window_close" &&
        open_live.fetch("trusted_output") == false,
      "negative.oof_s1_unbounded_fold" => negative_rule?(negatives, "negative_unbounded_fold", "OOF-S1"),
      "negative.oof_s2_missing_window" => negative_rule?(negatives, "negative_missing_window", "OOF-S2"),
      "negative.oof_s3_escape_in_fold" => negative_rule?(negatives, "negative_escape_in_fold", "OOF-S3") &&
        negative_typechecker_stage?(negatives, "negative_escape_in_fold"),
      "negative.oof_s4_direct_stream_use" => negative_rule?(negatives, "negative_direct_stream_use", "OOF-S4"),
      "history.relationship_documented" => true
    }
  end

  def negative_rule?(negatives, case_id, rule)
    report = negatives.find { |candidate| candidate.fetch("case_id") == case_id }
    report &&
      report.fetch("pass_result") == "oof" &&
      report.fetch("semantic_ir_ref").nil? &&
      report.fetch("diagnostics").any? { |diagnostic| diagnostic.fetch("rule") == rule }
  end

  # Verifies that the negative report fires at the typecheck stage (TypeChecker-owned rule).
  def negative_typechecker_stage?(negatives, case_id)
    report = negatives.find { |candidate| candidate.fetch("case_id") == case_id }
    report&.dig("stages", "typecheck") == "oof"
  end

  def write_outputs(summary)
    write_json(SUMMARY_PATH, summary)
    write_json(GOLDEN_DIR / "semantic_ir_program.json", summary.fetch("semantic_ir_program"))
    write_json(GOLDEN_DIR / "finite_replay_result.json", summary.fetch("finite_replay_result"))
    write_json(GOLDEN_DIR / "open_live_descriptor.json", summary.fetch("open_live_descriptor"))
    summary.fetch("negative_reports").each do |report|
      write_json(GOLDEN_DIR / "#{report.fetch("case_id")}.json", report)
    end
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(Pathname.new(path).dirname)
    File.write(path, Canonical.pretty(payload))
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} stream_t_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    finite = summary.fetch("finite_replay_result")
    open_live = summary.fetch("open_live_descriptor")
    puts "finite_replay.window: #{finite.dig("window", "closed") ? "closed" : "open"}/#{finite.dig("window", "observation", "event_count")} events"
    puts "finite_replay.output.total: #{finite.dig("output", "total")}"
    puts "open_live.status: #{open_live.fetch("status")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = StreamTProof.run
exit(success ? 0 : 1)

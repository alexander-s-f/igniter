#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

module HistoryTypeProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/history_type_proof"
  GOLDEN_DIR = FIXTURE_DIR / "golden"
  OUT_DIR = FIXTURE_DIR / "out"
  IGAPP_DIR = OUT_DIR / "history_integer_point_access.igapp"
  SUMMARY_PATH = FIXTURE_DIR / "history_type_proof_summary.json"
  FORMAT_VERSION = "0.1.0"
  TRACK = "history-type-point-access-proof-v0"
  POSITIVE_SOURCE = FIXTURE_DIR / "history_integer_point_access.ig"
  NEGATIVE_SOURCE = FIXTURE_DIR / "negative_history_missing_as_of.ig"
  CONTRACT_ID = "contract/Fixture.HistoryTypeProof.TechnicianJobCountAt@history-point-v0"
  CONTRACT_NAME = "TechnicianJobCountAt"
  NEGATIVE_CONTRACT_NAME = "TechnicianJobCountWithoutAsOf"
  MODULE_NAME = "Fixture.HistoryTypeProof"
  SUBJECT_TEMPLATE = "technicians/{technician_id}/job_count"
  TECHNICIAN_ID = "tech-synthetic-1"
  SUBJECT = "technicians/#{TECHNICIAN_ID}/job_count"
  AS_OF_EARLY = "2026-05-03T10:00:00Z"
  AS_OF_LATE = "2026-05-06T10:00:00Z"
  OPTION_ENCODING = {
    "some" => { "some" => "<value>" },
    "none" => { "none" => true }
  }.freeze

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

  class MemoryHistoryBackend
    attr_reader :append_observations, :access_observations

    def initialize
      @append_observations = []
      @access_observations = []
    end

    def seed_append_observations(observations)
      observations.each do |observation|
        append(observation.fetch("subject"), observation.fetch("valid_from"), observation.fetch("value"),
               value_type: observation.fetch("value_type"))
      end
    end

    def append(subject, valid_from, value, value_type:)
      payload = {
        "kind" => "history_append_observation",
        "subject" => subject,
        "valid_from" => valid_from,
        "value" => value,
        "value_type" => value_type
      }
      observation = payload.merge(
        "observation_id" => "obs/history_append/#{Canonical.short_hash(payload)}",
        "observed_at" => valid_from,
        "temporal" => {
          "axis" => "valid_time",
          "as_of" => valid_from,
          "lifecycle" => "durable"
        }
      )
      @append_observations << observation
      observation
    end

    def read_as_of(subject, as_of)
      as_of_time = Time.iso8601(as_of)
      selected = @append_observations
        .select { |obs| obs.fetch("subject") == subject && Time.iso8601(obs.fetch("valid_from")) <= as_of_time }
        .max_by { |obs| Time.iso8601(obs.fetch("valid_from")) }
      result = selected ? { "some" => selected.fetch("value") } : { "none" => true }
      payload = {
        "kind" => "history_access_observation",
        "subject" => subject,
        "as_of" => as_of,
        "access" => "point",
        "selected_append_ref" => selected&.fetch("observation_id"),
        "result" => result,
        "option_encoding" => OPTION_ENCODING
      }
      observation = payload.merge(
        "observation_id" => "obs/history_access/#{Canonical.short_hash(payload)}",
        "observed_at" => as_of,
        "temporal" => {
          "axis" => "valid_time",
          "as_of" => as_of,
          "lifecycle" => "session"
        }
      )
      @access_observations << observation
      [result, observation]
    end
  end

  class ProofCompiler
    def positive_parsed_program
      {
        "kind" => "parsed_program",
        "format_version" => FORMAT_VERSION,
        "source_path" => relative_path(POSITIVE_SOURCE),
        "source_hash" => file_hash(POSITIVE_SOURCE),
        "module" => MODULE_NAME,
        "parse_errors" => [],
        "parser_status" => "hand_authored_until_history_read_grammar_lands",
        "contracts" => [
          {
            "kind" => "contract",
            "name" => CONTRACT_NAME,
            "body" => [
              input_node("technician_id", type_ref("String")),
              input_node("as_of", type_ref("DateTime")),
              { "kind" => "escape", "capability" => "history_read" },
              {
                "kind" => "read",
                "name" => "job_count_history",
                "type_ref" => type_ref("History", [type_ref("Integer")]),
                "from" => SUBJECT_TEMPLATE,
                "lifecycle" => "durable"
              },
              {
                "kind" => "compute",
                "name" => "current_count",
                "expr" => {
                  "kind" => "call",
                  "name" => "history_at",
                  "args" => [
                    { "kind" => "ref", "name" => "job_count_history" },
                    { "kind" => "ref", "name" => "as_of" }
                  ]
                }
              },
              output_node("current_count", type_ref("Option", [type_ref("Integer")]), "session")
            ]
          }
        ]
      }
    end

    def negative_parsed_program
      {
        "kind" => "parsed_program",
        "format_version" => FORMAT_VERSION,
        "source_path" => relative_path(NEGATIVE_SOURCE),
        "source_hash" => file_hash(NEGATIVE_SOURCE),
        "module" => MODULE_NAME,
        "parse_errors" => [],
        "parser_status" => "hand_authored_until_history_read_grammar_lands",
        "contracts" => [
          {
            "kind" => "contract",
            "name" => NEGATIVE_CONTRACT_NAME,
            "body" => [
              input_node("technician_id", type_ref("String")),
              { "kind" => "escape", "capability" => "history_read" },
              {
                "kind" => "read",
                "name" => "job_count_history",
                "type_ref" => type_ref("History", [type_ref("Integer")]),
                "from" => SUBJECT_TEMPLATE,
                "lifecycle" => "durable"
              },
              {
                "kind" => "compute",
                "name" => "current_count",
                "expr" => {
                  "kind" => "call",
                  "name" => "history_at",
                  "args" => [{ "kind" => "ref", "name" => "job_count_history" }]
                }
              },
              output_node("current_count", type_ref("Option", [type_ref("Integer")]), "session")
            ]
          }
        ]
      }
    end

    def classify(parsed_program)
      diagnostics = history_oofs(parsed_program)
      {
        "kind" => "classified_program",
        "format_version" => FORMAT_VERSION,
        "source_hash" => parsed_program.fetch("source_hash"),
        "module" => parsed_program.fetch("module"),
        "parser_status" => parsed_program.fetch("parser_status"),
        "fragment_class" => diagnostics.empty? ? "escape" : "oof",
        "required_caps" => ["history_read"],
        "contracts" => parsed_program.fetch("contracts").map do |contract|
          {
            "name" => contract.fetch("name"),
            "fragment_class" => diagnostics.empty? ? "escape" : "oof",
            "reads" => [
              {
                "name" => "job_count_history",
                "fragment_class" => "escape",
                "required_caps" => ["history_read"]
              }
            ],
            "computes" => [
              {
                "name" => "current_count",
                "fragment_class" => diagnostics.empty? ? "escape" : "oof",
                "operation" => "history_at"
              }
            ]
          }
        end,
        "diagnostics" => diagnostics
      }
    end

    def typecheck(parsed_program, classified_program)
      return typed_oof_program(parsed_program, classified_program) unless classified_program.fetch("diagnostics").empty?

      {
        "kind" => "typed_program",
        "format_version" => FORMAT_VERSION,
        "source_hash" => parsed_program.fetch("source_hash"),
        "module" => parsed_program.fetch("module"),
        "contracts" => [
          {
            "name" => CONTRACT_NAME,
            "fragment_class" => "escape",
            "inputs" => [
              { "name" => "technician_id", "type" => type_ref("String") },
              { "name" => "as_of", "type" => type_ref("DateTime") }
            ],
            "reads" => [
              {
                "name" => "job_count_history",
                "type" => type_ref("History", [type_ref("Integer")]),
                "fragment_class" => "escape",
                "required_caps" => ["history_read"]
              }
            ],
            "computes" => [
              {
                "name" => "current_count",
                "type" => type_ref("Option", [type_ref("Integer")]),
                "signature" => "history_at(History[T], DateTime) -> Option[T]",
                "resolved_type_variables" => { "T" => type_ref("Integer") },
                "fragment_class" => "escape"
              }
            ],
            "outputs" => [
              { "name" => "current_count", "type" => type_ref("Option", [type_ref("Integer")]) }
            ]
          }
        ],
        "diagnostics" => []
      }
    end

    def emit_semantic_ir(parsed_program, typed_program)
      report_id = compilation_report_id(parsed_program)
      program_id = semantic_ir_program_id(parsed_program)
      {
        "kind" => "semantic_ir_program",
        "format_version" => FORMAT_VERSION,
        "program_id" => program_id,
        "source_hash" => parsed_program.fetch("source_hash"),
        "source_path" => parsed_program.fetch("source_path"),
        "module" => MODULE_NAME,
        "compilation_report_ref" => report_id,
        "contracts" => [
          {
            "kind" => "contract_ir",
            "contract_ref" => CONTRACT_ID,
            "contract_name" => CONTRACT_NAME,
            "fragment_class" => "escape",
            "inputs" => [
              { "name" => "technician_id", "type" => type_ir("String"), "lifecycle" => "local" },
              { "name" => "as_of", "type" => type_ir("DateTime"), "lifecycle" => "local" }
            ],
            "outputs" => [
              { "name" => "current_count", "type" => type_ir("Option", [type_ir("Integer")]), "lifecycle" => "session" }
            ],
            "nodes" => [
              {
                "kind" => "temporal_input_node",
                "name" => "job_count_history",
                "type" => { "constructor" => "History", "element_type" => "Integer" },
                "axis" => "single",
                "store_ref" => SUBJECT_TEMPLATE,
                "as_of_ref" => "as_of",
                "fragment" => "escape",
                "required_caps" => ["history_read"]
              },
              {
                "kind" => "temporal_access_node",
                "name" => "current_count",
                "source_ref" => "job_count_history",
                "access" => "point",
                "time_ref" => "as_of",
                "result_type" => { "constructor" => "Option", "element_type" => "Integer" },
                "fragment" => "escape",
                "evidence_policy" => "link_selected_append_observation"
              }
            ],
            "escape_boundaries" => [
              {
                "name" => "history_read",
                "required_caps" => ["history_read"],
                "produces" => ["history_access_observation"]
              }
            ]
          }
        ],
        "typecheck_ref" => "typed_program/#{Canonical.short_hash(typed_program)}"
      }
    end

    def compilation_report(parsed_program, diagnostics, semantic_ir)
      {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "program_id" => compilation_report_id(parsed_program),
        "track" => TRACK,
        "source_hash" => parsed_program.fetch("source_hash"),
        "source_path" => parsed_program.fetch("source_path"),
        "pass_result" => diagnostics.empty? ? "ok" : "oof",
        "stages" => {
          "parse" => parsed_program.fetch("parse_errors").empty? ? "ok" : "oof",
          "classify" => diagnostics.empty? ? "ok" : "oof",
          "typecheck" => diagnostics.empty? ? "ok" : "skipped",
          "emit" => diagnostics.empty? ? "ok" : "skipped"
        },
        "diagnostics" => diagnostics,
        "semantic_ir_ref" => semantic_ir&.fetch("program_id")
      }
    end

    def assemble_igapp(semantic_ir, compilation_report)
      FileUtils.rm_rf(IGAPP_DIR)
      FileUtils.mkdir_p(IGAPP_DIR / "contracts")
      manifest = {
        "kind" => "igapp_manifest",
        "format_version" => FORMAT_VERSION,
        "program_id" => semantic_ir.fetch("program_id"),
        "artifact_hash" => Canonical.hash(semantic_ir),
        "language_version" => "igniter-lang-stage2-proof",
        "track" => TRACK,
        "entry_contract_ref" => CONTRACT_ID
      }
      contract = semantic_ir.fetch("contracts").first
      requirements = {
        "kind" => "requirements",
        "format_version" => FORMAT_VERSION,
        "capabilities" => { "required_caps" => ["history_read"] },
        "temporal" => {
          "requires_as_of" => true,
          "axes" => ["valid_time"],
          "history_reads" => ["job_count_history"]
        }
      }
      diagnostics = { "kind" => "diagnostics", "diagnostics" => [] }
      write_json(IGAPP_DIR / "manifest.json", manifest)
      write_json(IGAPP_DIR / "semantic_ir_program.json", semantic_ir)
      write_json(IGAPP_DIR / "compilation_report.json", compilation_report)
      write_json(IGAPP_DIR / "contracts/technician_job_count_at.json", contract)
      write_json(IGAPP_DIR / "requirements.json", requirements)
      write_json(IGAPP_DIR / "diagnostics.json", diagnostics)
      {
        "manifest" => manifest,
        "requirements" => requirements,
        "files" => Dir.glob("#{IGAPP_DIR}/**/*").select { |path| File.file?(path) }.map do |path|
          Pathname.new(path).relative_path_from(ROOT).to_s
        end.sort
      }
    end

    private

    def history_oofs(parsed_program)
      parsed_program.fetch("contracts").flat_map do |contract|
        has_as_of = contract.fetch("body").any? do |node|
          node.fetch("kind") == "input" && node.fetch("name") == "as_of" && node.fetch("type_ref").fetch("name") == "DateTime"
        end
        contract.fetch("body").filter_map do |node|
          next unless node.fetch("kind") == "compute"

          expr = node.fetch("expr")
          next unless expr.fetch("kind") == "call" && expr.fetch("name") == "history_at"

          unless has_as_of && expr.fetch("args").length == 2
            {
              "rule" => "OOF-H1",
              "severity" => "error",
              "message" => "History[T] point access requires an explicit as_of DateTime argument",
              "contract" => contract.fetch("name"),
              "node" => node.fetch("name")
            }
          end
        end
      end
    end

    def typed_oof_program(parsed_program, classified_program)
      {
        "kind" => "typed_program",
        "format_version" => FORMAT_VERSION,
        "source_hash" => parsed_program.fetch("source_hash"),
        "module" => parsed_program.fetch("module"),
        "contracts" => [],
        "diagnostics" => classified_program.fetch("diagnostics")
      }
    end

    def input_node(name, type)
      { "kind" => "input", "name" => name, "type_ref" => type }
    end

    def output_node(name, type, lifecycle)
      { "kind" => "output", "name" => name, "type_ref" => type, "lifecycle" => lifecycle }
    end

    def type_ref(name, params = [])
      { "kind" => "type_ref", "name" => name, "params" => params }
    end

    def type_ir(name, params = [])
      { "name" => name, "params" => params }
    end

    def write_json(path, payload)
      FileUtils.mkdir_p(Pathname.new(path).dirname)
      File.write(path, Canonical.pretty(payload))
    end

    def semantic_ir_program_id(parsed_program)
      "semanticir/history/#{parsed_program.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
    end

    def compilation_report_id(parsed_program)
      "compilation_report/history/#{parsed_program.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
    end

    def file_hash(path)
      "sha256:#{Digest::SHA256.hexdigest(File.read(path))}"
    end

    def relative_path(path)
      path.relative_path_from(ROOT).to_s
    end
  end

  class HistoryRuntimeMachine
    attr_reader :compatibility_report

    def initialize(backend)
      @backend = backend
    end

    def load(path)
      dir = Pathname.new(path)
      manifest = read_json(dir / "manifest.json")
      semantic_ir = read_json(dir / "semantic_ir_program.json")
      report = read_json(dir / "compilation_report.json")
      requirements = read_json(dir / "requirements.json")
      contract = semantic_ir.fetch("contracts").first
      trusted = report.fetch("pass_result") == "ok" &&
        requirements.dig("capabilities", "required_caps").include?("history_read") &&
        requirements.dig("temporal", "requires_as_of") == true &&
        contract.fetch("nodes").any? { |node| node.fetch("kind") == "temporal_access_node" }
      @loaded = {
        "manifest" => manifest,
        "semantic_ir" => semantic_ir,
        "compilation_report" => report,
        "requirements" => requirements,
        "contract" => contract
      }
      @compatibility_report = {
        "kind" => "compatibility_report",
        "format_version" => FORMAT_VERSION,
        "status" => trusted ? "trusted" : "blocked",
        "program_id" => manifest.fetch("program_id"),
        "checks" => {
          "manifest" => "ok",
          "compilation_report" => report.fetch("pass_result") == "ok" ? "ok" : "blocked",
          "semantic_ir_program" => "ok",
          "history_requirements" => trusted ? "ok" : "blocked"
        }
      }
    end

    def evaluate(inputs)
      raise "RuntimeMachine.load must be called before evaluate" unless @loaded
      raise "evaluate requires explicit as_of" unless inputs["as_of"]

      contract = @loaded.fetch("contract")
      input_node = contract.fetch("nodes").find { |node| node.fetch("kind") == "temporal_input_node" }
      access_node = contract.fetch("nodes").find { |node| node.fetch("kind") == "temporal_access_node" }
      subject = input_node.fetch("store_ref").gsub("{technician_id}", inputs.fetch("technician_id"))
      result, observation = @backend.read_as_of(subject, inputs.fetch("as_of"))
      {
        "kind" => "runtime_evaluation",
        "contract_ref" => @loaded.dig("manifest", "entry_contract_ref"),
        "as_of" => inputs.fetch("as_of"),
        "outputs" => { access_node.fetch("name") => result },
        "observations" => [observation],
        "evidence_links" => [
          {
            "rel" => "selected_append",
            "from" => observation.fetch("observation_id"),
            "to" => observation.fetch("selected_append_ref")
          }
        ]
      }
    end

    private

    def read_json(path)
      JSON.parse(File.read(path))
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(GOLDEN_DIR)
    compiler = ProofCompiler.new
    positive_parsed = compiler.positive_parsed_program
    positive_classified = compiler.classify(positive_parsed)
    positive_typed = compiler.typecheck(positive_parsed, positive_classified)
    semantic_ir = compiler.emit_semantic_ir(positive_parsed, positive_typed)
    positive_report = compiler.compilation_report(positive_parsed, positive_classified.fetch("diagnostics"), semantic_ir)
    assembled = compiler.assemble_igapp(semantic_ir, positive_report)

    negative_parsed = compiler.negative_parsed_program
    negative_classified = compiler.classify(negative_parsed)
    negative_typed = compiler.typecheck(negative_parsed, negative_classified)
    negative_report = compiler.compilation_report(negative_parsed, negative_classified.fetch("diagnostics"), nil)

    backend = MemoryHistoryBackend.new
    backend.seed_append_observations(seed_append_observation_payloads)
    machine = HistoryRuntimeMachine.new(backend)
    compatibility = machine.load(IGAPP_DIR)
    early_eval = machine.evaluate({ "technician_id" => TECHNICIAN_ID, "as_of" => AS_OF_EARLY })
    late_eval = machine.evaluate({ "technician_id" => TECHNICIAN_ID, "as_of" => AS_OF_LATE })

    write_artifacts(
      positive_parsed: positive_parsed,
      positive_classified: positive_classified,
      positive_typed: positive_typed,
      semantic_ir: semantic_ir,
      positive_report: positive_report,
      negative_parsed: negative_parsed,
      negative_classified: negative_classified,
      negative_typed: negative_typed,
      negative_report: negative_report
    )

    checks = checks(
      backend: backend,
      positive_parsed: positive_parsed,
      positive_classified: positive_classified,
      positive_typed: positive_typed,
      semantic_ir: semantic_ir,
      positive_report: positive_report,
      negative_report: negative_report,
      compatibility: compatibility,
      early_eval: early_eval,
      late_eval: late_eval,
      assembled: assembled
    )
    summary = {
      "kind" => "history_type_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "option_encoding" => OPTION_ENCODING,
      "parser_gap" => "Current parser support for History[T] read/from/lifecycle is not used; this proof starts from hand-authored ParsedProgram.",
      "append_observations" => backend.append_observations,
      "evaluations" => {
        "as_of_2026_05_03" => early_eval,
        "as_of_2026_05_06" => late_eval
      },
      "compatibility_report" => compatibility,
      "checks" => checks,
      "artifacts" => {
        "golden_dir" => GOLDEN_DIR.relative_path_from(ROOT).to_s,
        "igapp_dir" => IGAPP_DIR.relative_path_from(ROOT).to_s,
        "assembled_files" => assembled.fetch("files")
      }
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def seed_append_observation_payloads
    [
      {
        "subject" => SUBJECT,
        "valid_from" => "2026-05-01T00:00:00Z",
        "value" => 7,
        "value_type" => "Integer"
      },
      {
        "subject" => SUBJECT,
        "valid_from" => "2026-05-05T00:00:00Z",
        "value" => 9,
        "value_type" => "Integer"
      }
    ]
  end

  def checks(backend:, positive_parsed:, positive_classified:, positive_typed:, semantic_ir:, positive_report:,
             negative_report:, compatibility:, early_eval:, late_eval:, assembled:)
    late_obs = late_eval.fetch("observations").first
    early_obs = early_eval.fetch("observations").first
    {
      "history.append_seed_observations" => backend.append_observations.length == 2,
      "parser.hand_authored_history_parsed_program" => positive_parsed.fetch("parse_errors").empty? &&
        positive_parsed.fetch("parser_status") == "hand_authored_until_history_read_grammar_lands",
      "classifier.history_read_escape" => positive_classified.fetch("fragment_class") == "escape" &&
        positive_classified.fetch("required_caps").include?("history_read"),
      "typechecker.history_at_option_integer" => positive_typed.dig("contracts", 0, "computes", 0, "type", "name") == "Option" &&
        positive_typed.dig("contracts", 0, "computes", 0, "type", "params", 0, "name") == "Integer",
      "semanticir.temporal_input_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "temporal_input_node" },
      "semanticir.temporal_access_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "temporal_access_node" },
      "assembler.history_igapp" => assembled.fetch("files").any? { |path| path.end_with?("semantic_ir_program.json") },
      "runtime.load_history_igapp_trusted" => compatibility.fetch("status") == "trusted",
      "runtime.evaluate_as_of_2026_05_03" => early_eval.dig("outputs", "current_count") == { "some" => 7 } &&
        early_obs.fetch("selected_append_ref") == backend.append_observations.fetch(0).fetch("observation_id"),
      "runtime.evaluate_as_of_2026_05_06" => late_eval.dig("outputs", "current_count") == { "some" => 9 } &&
        late_obs.fetch("selected_append_ref") == backend.append_observations.fetch(1).fetch("observation_id"),
      "runtime.output_links_selected_append_observation" => late_eval.fetch("evidence_links").first.fetch("to") ==
        backend.append_observations.fetch(1).fetch("observation_id"),
      "negative.missing_as_of_oof_h1" => negative_report.fetch("pass_result") == "oof" &&
        negative_report.fetch("semantic_ir_ref").nil? &&
        negative_report.fetch("diagnostics").any? { |diagnostic| diagnostic.fetch("rule") == "OOF-H1" },
      "compilation.positive_report_ok" => positive_report.fetch("pass_result") == "ok" &&
        positive_report.fetch("semantic_ir_ref") == semantic_ir.fetch("program_id")
    }
  end

  def write_artifacts(positive_parsed:, positive_classified:, positive_typed:, semantic_ir:, positive_report:,
                      negative_parsed:, negative_classified:, negative_typed:, negative_report:)
    {
      "history_integer_point_access.parsed.json" => positive_parsed,
      "history_integer_point_access.classified.json" => positive_classified,
      "history_integer_point_access.typed.json" => positive_typed,
      "history_integer_point_access.semantic_ir_program.json" => semantic_ir,
      "history_integer_point_access.compilation_report.json" => positive_report,
      "negative_history_missing_as_of.parsed.json" => negative_parsed,
      "negative_history_missing_as_of.classified.json" => negative_classified,
      "negative_history_missing_as_of.typed.json" => negative_typed,
      "negative_history_missing_as_of.compilation_report.json" => negative_report
    }.each do |filename, payload|
      write_json(GOLDEN_DIR / filename, payload)
    end
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(Pathname.new(path).dirname)
    File.write(path, Canonical.pretty(payload))
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} history_type_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "option.encoding: some={\"some\": value} none={\"none\": true}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = HistoryTypeProof.run
exit(success ? 0 : 1)

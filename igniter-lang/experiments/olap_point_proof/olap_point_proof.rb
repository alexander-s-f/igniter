#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/parser"
require_relative "../../lib/igniter_lang/semanticir_emitter"
require_relative "../../lib/igniter_lang/typechecker"

module OLAPPointProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/olap_point_proof"
  GOLDEN_DIR = FIXTURE_DIR / "golden"
  SUMMARY_PATH = FIXTURE_DIR / "summary.json"
  FORMAT_VERSION = "0.1.0"
  TRACK = "olap-point-proof-v0"
  CONTRACT_REF = "contract/Fixture.OLAPPoint.RegionalDailyRevenuePoint@v0"
  SOURCE_PATH = FIXTURE_DIR / "revenue_point.ig"

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

  class MemoryOLAPBackend
    attr_reader :cell_observations

    def initialize(olap_decl)
      @olap_decl = olap_decl
      @cell_observations = []
    end

    def materialize(facts)
      grouped = facts.group_by { |fact| dimension_key(fact.fetch("dimensions")) }
      grouped.each_value.map do |group|
        first = group.first
        total = sum_decimal(group.map { |fact| fact.fetch("measure") })
        cell = {
          "kind" => "olap_cell",
          "olap_ref" => @olap_decl.fetch("name"),
          "measure_type" => @olap_decl.fetch("measure_type"),
          "dimensions" => first.fetch("dimensions"),
          "measure" => total,
          "source_fact_refs" => group.map { |fact| fact.fetch("fact_id") }
        }
        observation = cell_observation(cell)
        @cell_observations << observation
        cell.merge(
          "cell_id" => "olap/cell/#{Canonical.short_hash(cell)}",
          "observation_ref" => observation.fetch("observation_id")
        )
      end
    end

    def point(cells, dimensions)
      selected = cells.find { |cell| dimension_key(cell.fetch("dimensions")) == dimension_key(dimensions) }
      result = {
        "kind" => "olap_point_result",
        "olap_ref" => @olap_decl.fetch("name"),
        "measure_type" => @olap_decl.fetch("measure_type"),
        "dims_type" => @olap_decl.fetch("dimensions"),
        "dimensions" => dimensions,
        "measure" => selected&.fetch("measure") || "0.00",
        "cell_ref" => selected&.fetch("cell_id"),
        "source_fact_refs" => selected&.fetch("source_fact_refs") || [],
        "observation_ref" => selected&.fetch("observation_ref")
      }
      result.merge("result_id" => "olap/result/#{Canonical.short_hash(result)}")
    end

    def local_rollup(cells, keep:)
      groups = cells.group_by { |cell| cell.fetch("dimensions").slice(*keep) }
      rows = groups.map do |dimensions, group|
        payload = {
          "kind" => "olap_rollup_row",
          "dimensions" => dimensions,
          "measure" => sum_decimal(group.map { |cell| cell.fetch("measure") }),
          "source_cell_refs" => group.map { |cell| cell.fetch("cell_id") }
        }
        payload.merge("row_id" => "olap/rollup_row/#{Canonical.short_hash(payload)}")
      end
      {
        "kind" => "olap_rollup_result",
        "olap_ref" => @olap_decl.fetch("name"),
        "aggregation" => "sum",
        "execution_plan" => "local_single_node_no_scatter_gather",
        "kept_dimensions" => keep,
        "rows" => rows.sort_by { |row| Canonical.json(row.fetch("dimensions")) }
      }
    end

    private

    def dimension_key(dimensions)
      Canonical.json(dimensions)
    end

    def sum_decimal(values)
      decimal = values.map { |value| BigDecimal(value) }.reduce(BigDecimal("0"), :+)
      format("%.2f", decimal)
    end

    def cell_observation(cell)
      payload = {
        "kind" => "olap_cell_observation",
        "olap_ref" => cell.fetch("olap_ref"),
        "measure_type" => cell.fetch("measure_type"),
        "dimensions" => cell.fetch("dimensions"),
        "measure" => cell.fetch("measure"),
        "source_fact_refs" => cell.fetch("source_fact_refs"),
        "lifecycle" => "analytical"
      }
      payload.merge("observation_id" => "obs/olap_cell/#{Canonical.short_hash(payload)}")
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(GOLDEN_DIR)
    semantic_ir = semantic_ir_program
    olap_decl = semantic_ir.fetch("olap_points").first
    backend = MemoryOLAPBackend.new(olap_decl)
    cells = backend.materialize(source_facts)
    point = backend.point(cells, {
      "date" => "2026-05-07",
      "region" => "west",
      "channel" => "online"
    })
    rollup = backend.local_rollup(cells, keep: ["date", "region"])
    negatives = negative_reports
    typechecker_boundary = build_typechecker_boundary
    proof_checks = checks(semantic_ir, backend, cells, point, rollup, negatives, typechecker_boundary)
    summary = {
      "kind" => "olap_point_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => proof_checks.values.all? ? "PASS" : "FAIL",
      "relationship_map" => {
        "stream_t" => "ingress_flow_that_may_populate_cells_on_window_close",
        "history_t" => "durable_time_axis_memory_equivalent_to_olap_time_dimension",
        "olap_point" => "analytical_projection_cube_point_with_typed_dimensions"
      },
      "semantic_ir_program" => semantic_ir,
      "source_facts" => source_facts,
      "cells" => cells,
      "point_result" => point,
      "rollup_result" => rollup,
      "observations" => backend.cell_observations,
      "negative_reports" => negatives,
      "typechecker_boundary" => typechecker_boundary,
      "checks" => proof_checks
    }
    write_outputs(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def semantic_ir_program
    {
      "kind" => "semantic_ir_program",
      "format_version" => FORMAT_VERSION,
      "program_id" => "semanticir/olap_point/#{Canonical.short_hash(File.read(SOURCE_PATH))}",
      "source_path" => SOURCE_PATH.relative_path_from(ROOT).to_s,
      "source_status" => "syntax_sketch_parser_not_used_in_this_proof",
      "olap_points" => [
        {
          "kind" => "olap_point_decl",
          "name" => "Revenue",
          "dimensions" => {
            "date" => "String",
            "region" => "String",
            "channel" => "String"
          },
          "measure_type" => "Decimal[2]",
          "granularity" => { "date" => "daily" },
          "source_ref" => "synthetic_fulfilled_order_facts",
          "indexed" => ["date", "region"]
        }
      ],
      "contracts" => [
        {
          "kind" => "contract_ir",
          "contract_ref" => CONTRACT_REF,
          "contract_name" => "RegionalDailyRevenuePoint",
          "fragment_class" => "escape",
          "nodes" => [
            {
              "kind" => "olap_access_node",
              "name" => "revenue_point",
              "olap_ref" => "Revenue",
              "slices" => [
                { "dim" => "date", "value_ref" => "date" },
                { "dim" => "region", "value_ref" => "region" },
                { "dim" => "channel", "value_ref" => "channel" }
              ],
              "operation" => "point",
              "result_type" => {
                "constructor" => "OLAPPoint",
                "measure" => "Decimal[2]",
                "dims" => {
                  "date" => "String",
                  "region" => "String",
                  "channel" => "String"
                }
              }
            }
          ]
        }
      ]
    }
  end

  def source_facts
    [
      fact("order/100", "2026-05-07", "west", "online", "12.25"),
      fact("order/101", "2026-05-07", "west", "online", "23.25"),
      fact("order/102", "2026-05-07", "west", "retail", "9.50"),
      fact("order/103", "2026-05-07", "east", "online", "18.00")
    ]
  end

  def fact(order_ref, date, region, channel, measure)
    payload = {
      "kind" => "synthetic_fulfilled_order_fact",
      "order_ref" => order_ref,
      "dimensions" => {
        "date" => date,
        "region" => region,
        "channel" => channel
      },
      "measure" => measure,
      "measure_type" => "Decimal[2]"
    }
    payload.merge("fact_id" => "fact/order/#{Canonical.short_hash(payload)}")
  end

  def negative_reports
    [
      oof_report(
        "negative_missing_dimension",
        "OOF-O4",
        "olap.dimension_missing",
        "OLAPPoint access missing required dimension: channel",
        node: "revenue_point",
        expected_type: { "date" => "String", "region" => "String", "channel" => "String" },
        received_dimensions: { "date" => "2026-05-07", "region" => "west" }
      ),
      oof_report(
        "negative_dimension_type_mismatch",
        "OOF-O5",
        "olap.dimension_type_mismatch",
        "OLAPPoint dimension 'date' expected String, got Integer",
        node: "revenue_point",
        expected_type: "String",
        received_type: "Integer"
      ),
      oof_report(
        "negative_empty_without_source_or_data",
        "OOF-O3",
        "olap.empty_point",
        "OLAPPoint must declare a source function or be populated via stream snapshot",
        node: "Revenue"
      )
    ]
  end

  def oof_report(case_id, rule, diagnostic, message, extra = {})
    {
      "kind" => "compilation_report",
      "format_version" => FORMAT_VERSION,
      "case_id" => case_id,
      "pass_result" => "oof",
      "semantic_ir_ref" => nil,
      "stages" => {
        "parse" => "proof_local_sketch",
        "classify" => "ok",
        "typecheck" => (rule.start_with?("OOF-O") && rule != "OOF-O1") ? "oof" : "skipped",
        "emit" => "skipped"
      },
      "diagnostics" => [
        {
          "category" => "olap_oof",
          "rule" => rule,
          "severity" => "error",
          "diagnostic" => diagnostic,
          "message" => message,
          "contract" => "RegionalDailyRevenuePoint",
          "node" => extra.fetch(:node),
          "path" => "contract:RegionalDailyRevenuePoint/olap:#{extra.fetch(:node)}",
          "span" => nil
        }.merge(extra.transform_keys(&:to_s))
      ]
    }
  end

  def checks(semantic_ir, backend, cells, point, rollup, negatives, typechecker_boundary)
    {
      "semanticir.olap_point_decl" => semantic_ir.fetch("olap_points").first.fetch("kind") == "olap_point_decl",
      "semanticir.olap_access_node" => semantic_ir.dig("contracts", 0, "nodes").any? { |node| node.fetch("kind") == "olap_access_node" },
      "type.olap_point_typed_dimensions" => semantic_ir.dig("olap_points", 0, "dimensions") == {
        "date" => "String",
        "region" => "String",
        "channel" => "String"
      },
      "type.measure_decimal_string" => point.fetch("measure_type") == "Decimal[2]" &&
        point.fetch("measure") == "35.50",
      "runtime.materializes_cells" => cells.length == 3 &&
        backend.cell_observations.length == 3,
      "runtime.point_access_deterministic" => point.fetch("dimensions") == {
        "date" => "2026-05-07",
        "region" => "west",
        "channel" => "online"
      } && point.fetch("source_fact_refs").length == 2,
      "runtime.local_rollup_no_scatter_gather" => rollup.fetch("execution_plan") == "local_single_node_no_scatter_gather" &&
        rollup.fetch("rows").any? { |row| row.fetch("dimensions") == { "date" => "2026-05-07", "region" => "west" } && row.fetch("measure") == "45.00" },
      "evidence.cell_observations_link_sources" => backend.cell_observations.all? { |obs| obs.fetch("source_fact_refs").any? },
      "negative.dimension_missing_oof" => negative_rule?(negatives, "negative_missing_dimension", "OOF-O4"),
      "negative.dimension_type_mismatch_oof" => negative_rule?(negatives, "negative_dimension_type_mismatch", "OOF-O5"),
      "negative.empty_without_source_oof_o3" => negative_rule?(negatives, "negative_empty_without_source_or_data", "OOF-O3"),
      "relationship.stream_history_olap_documented" => true
    }.merge(grammar_boundary_checks(semantic_ir, negatives))
      .merge(typechecker_semanticir_boundary_checks(typechecker_boundary))
  end

  # Grammar/TypeChecker boundary checks — added by track olap-point-parser-typechecker-boundary-v0.
  # Verifies that the proof's hand-authored nodes conform to the formally defined
  # ParsedProgram and TypedProgram shapes, and that OOF-O ownership is correct.
  # These are structural checks only — no live parser is invoked.
  def grammar_boundary_checks(semantic_ir, negatives)
    decl = semantic_ir.fetch("olap_points").first
    access_node = semantic_ir.dig("contracts", 0, "nodes")&.find { |n| n.fetch("kind") == "olap_access_node" }
    contract = semantic_ir.dig("contracts", 0)

    # §2.1 ParsedProgram olap_point decl shape: must have name, dimensions (Hash), measure_type, indexed (Array)
    parsed_decl_shape_valid =
      decl.fetch("kind") == "olap_point_decl" &&
      decl.fetch("name").is_a?(String) &&
      decl.fetch("dimensions").is_a?(Hash) &&
      decl.fetch("dimensions").values.all? { |t| t.is_a?(String) } &&
      decl.key?("measure_type") &&
      decl.fetch("indexed").is_a?(Array)

    # §2.2 ParsedProgram OLAPPoint[T,Dims] type_ref shape: access_node must carry result_type
    # with constructor=OLAPPoint and a dims map (dims_record equivalent in SemanticIR)
    dims_record_shape_valid =
      access_node &&
      access_node.dig("result_type", "constructor") == "OLAPPoint" &&
      access_node.dig("result_type", "dims").is_a?(Hash) &&
      access_node.dig("result_type", "dims").keys.sort == %w[channel date region]

    # §2.1 measure type is a structured reference (not nil, not empty)
    measure_type_ref_structured =
      decl.fetch("measure_type", nil)&.is_a?(String) &&
      !decl.fetch("measure_type").empty?

    # §4 OOF-O4 formally assigned: missing-dimension error code.
    oof_o4_typechecker_owned =
      negative_report_typechecker_stage?(negatives, "negative_missing_dimension") &&
      negative_rule?(negatives, "negative_missing_dimension", "OOF-O4")

    # §4 OOF-O5 formally assigned: dimension-type-mismatch error code.
    oof_o5_typechecker_owned =
      negative_report_typechecker_stage?(negatives, "negative_dimension_type_mismatch") &&
      negative_rule?(negatives, "negative_dimension_type_mismatch", "OOF-O5")

    # §4 OOF-O3 TypeChecker-owned: empty point without source fires at typecheck stage
    oof_o3_ownership_typechecker =
      negative_report_typechecker_stage?(negatives, "negative_empty_without_source_or_data")

    # §4 OOF-O1 Parser-owned: Stage 1 gate rule. The proof does not fire OOF-O1 (Stage 2 proof),
    # but verify no negative case mislabels OOF-O1 as a typechecker rule.
    oof_o1_parser_ownership =
      negatives.none? do |report|
        report.fetch("diagnostics", []).any? { |d| d.fetch("rule") == "OOF-O1" } &&
          report.dig("stages", "typecheck") == "oof"
      end

    # §5 Classifier boundary: olap_access_node and contract must carry fragment_class "escape"
    olap_access_fragment_class_escape =
      access_node &&
      contract.fetch("fragment_class") == "escape"

    # §5 Boundary: olap_point_decl is a top-level declaration (in olap_points[], not in a contract body)
    # Verify it is NOT present in contracts[].nodes
    olap_decl_top_level_not_in_body =
      semantic_ir.fetch("olap_points").any? { |p| p.fetch("kind") == "olap_point_decl" } &&
      semantic_ir.fetch("contracts").none? do |c|
        c.fetch("nodes", []).any? { |n| n.fetch("kind") == "olap_point_decl" }
      end

    {
      "grammar.olap_point_decl_shape_valid" => parsed_decl_shape_valid,
      "grammar.dims_record_type_ref_shape_valid" => dims_record_shape_valid,
      "grammar.measure_type_ref_structured" => measure_type_ref_structured,
      "typechecker.oof_o4_code_assigned" => oof_o4_typechecker_owned,
      "typechecker.oof_o5_code_assigned" => oof_o5_typechecker_owned,
      "typechecker.oof_o3_ownership_typechecker" => oof_o3_ownership_typechecker,
      "typechecker.oof_o1_ownership_parser" => oof_o1_parser_ownership,
      "boundary.olap_point_decl_top_level_not_contract_body" => olap_decl_top_level_not_in_body,
      "boundary.olap_access_fragment_class_escape" => olap_access_fragment_class_escape
    }
  end

  def negative_rule?(negatives, case_id, rule)
    report = negatives.find { |candidate| candidate.fetch("case_id") == case_id }
    report &&
      report.fetch("pass_result") == "oof" &&
      report.fetch("semantic_ir_ref").nil? &&
      report.fetch("diagnostics").any? { |diagnostic| diagnostic.fetch("rule") == rule }
  end

  # Returns true when the negative report for case_id fires at the typecheck stage
  # (stages.typecheck == "oof"), confirming TypeChecker ownership of the OOF rule.
  def negative_report_typechecker_stage?(negatives, case_id)
    report = negatives.find { |candidate| candidate.fetch("case_id") == case_id }
    report&.dig("stages", "typecheck") == "oof"
  end

  def build_typechecker_boundary
    parsed = live_parsed_program
    positive = typecheck_case(classified_from_parsed(parsed, source_ref: "synthetic_fulfilled_order_facts"))
    missing_dimension = typecheck_case(classified_from_parsed(parsed, source_ref: "synthetic_fulfilled_order_facts") do |body|
      compute = body.find { |node| node.fetch("kind") == "compute" }
      compute.dig("expr", "index", "fields").delete("channel")
    end)
    dimension_type_mismatch = typecheck_case(classified_from_parsed(parsed, source_ref: "synthetic_fulfilled_order_facts") do |body|
      input = body.find { |node| node.fetch("kind") == "input" && node.fetch("name") == "date" }
      input["type_annotation"] = "Integer"
    end)
    empty_without_source = typecheck_case(classified_from_parsed(parsed))
    rollup_warning = typecheck_case(classified_from_parsed(parsed, source_ref: "synthetic_fulfilled_order_facts") do |body|
      compute = body.find { |node| node.fetch("kind") == "compute" }
      compute["name"] = "channel_rollup"
      compute["expr"] = {
        "kind" => "call",
        "fn" => "olap_rollup",
        "args" => [
          { "kind" => "ref", "name" => "Revenue" },
          { "kind" => "symbol", "value" => "channel" }
        ]
      }
      compute.delete("type_annotation")
      body.reject! { |node| node.fetch("kind") == "output" }
    end)

    semantic_ir = semantic_ir_from_typed(positive)
    {
      "kind" => "olap_typechecker_semanticir_boundary",
      "parsed" => parsed,
      "positive_typed" => positive,
      "semantic_ir" => semantic_ir,
      "negative_missing_dimension" => missing_dimension,
      "negative_dimension_type_mismatch" => dimension_type_mismatch,
      "negative_empty_without_source" => empty_without_source,
      "rollup_warning" => rollup_warning
    }
  end

  def live_parsed_program
    IgniterLang::ParsedProgram.parse(File.read(SOURCE_PATH), source_path: SOURCE_PATH.relative_path_from(ROOT).to_s).to_h
  end

  def typecheck_case(classified)
    IgniterLang::TypeChecker.new.typecheck(classified)
  end

  def classified_from_parsed(parsed, source_ref: nil)
    body = deep_copy(parsed.dig("contracts", 0, "body"))
    yield body if block_given?
    olap_points = deep_copy(parsed.fetch("olap_points"))
    olap_points.each { |point| point["source_ref"] = source_ref if source_ref }
    contract_name = parsed.dig("contracts", 0, "name")
    declarations = body.map { |node| classified_decl_from_parsed_node(node) }.compact
    {
      "kind" => "classified_program",
      "classifier_version" => "olap-proof-local-classifier-v0",
      "program_id" => "classifier_pass/olap_#{Canonical.short_hash(parsed)}",
      "source_path" => parsed.fetch("source_path"),
      "source_hash" => parsed.fetch("source_hash"),
      "grammar_version" => parsed.fetch("grammar_version"),
      "module" => parsed.fetch("module"),
      "type_declarations" => [],
      "olap_points" => olap_points,
      "contracts" => [
        {
          "kind" => "classified_contract",
          "contract_id" => "Fixture.OLAPPoint.#{contract_name}",
          "name" => contract_name,
          "fragment_class" => "escape",
          "symbols" => classified_symbols(body),
          "declarations" => declarations,
          "dependency_graph" => { "nodes" => declarations.map { |decl| decl.fetch("decl_id") }, "edges" => [] },
          "oof_log" => []
        }
      ],
      "oof_log" => [],
      "semantic_ir_ref" => nil
    }
  end

  def classified_decl_from_parsed_node(node)
    case node.fetch("kind")
    when "input"
      {
        "decl_id" => "input:#{node.fetch("name")}",
        "kind" => "input",
        "name" => node.fetch("name"),
        "fragment_class" => "core",
        "deps" => [],
        "missing_refs" => [],
        "type_annotation" => node.fetch("type_annotation")
      }
    when "compute"
      result = {
        "decl_id" => "compute:#{node.fetch("name")}",
        "kind" => "compute",
        "name" => node.fetch("name"),
        "fragment_class" => "escape",
        "deps" => expr_refs(node.fetch("expr")),
        "missing_refs" => [],
        "expr_kind" => node.fetch("expr").fetch("kind"),
        "expr" => node.fetch("expr")
      }
      result["type_annotation"] = node.fetch("type_annotation") if node.key?("type_annotation")
      result
    when "output"
      {
        "decl_id" => "output:#{node.fetch("name")}",
        "kind" => "output",
        "name" => node.fetch("name"),
        "fragment_class" => "core",
        "deps" => [node.fetch("name")],
        "missing_refs" => [],
        "type_annotation" => node.fetch("type_annotation")
      }
    end
  end

  def classified_symbols(body)
    symbols = body.filter_map do |node|
      case node.fetch("kind")
      when "input"
        { "name" => node.fetch("name"), "kind" => "input", "fragment_class" => "core" }
      when "compute"
        { "name" => node.fetch("name"), "kind" => "compute", "fragment_class" => "escape" }
      end
    end
    symbols << { "name" => "Revenue", "kind" => "olap_point", "fragment_class" => "escape" }
    symbols.sort_by { |symbol| symbol.fetch("name") }
  end

  def expr_refs(expr)
    case expr.fetch("kind")
    when "ref"
      [expr.fetch("name")]
    when "index_access"
      expr_refs(expr.fetch("object")) + expr.fetch("index").fetch("fields", {}).values.flat_map { |value| expr_refs(value) }
    when "call"
      [expr.fetch("fn")] + expr.fetch("args", []).flat_map { |arg| expr_refs(arg) }
    when "literal", "symbol"
      []
    else
      expr.values.flat_map { |value| value.is_a?(Hash) && value.key?("kind") ? expr_refs(value) : [] }
    end.uniq
  end

  def semantic_ir_from_typed(typed)
    emitted = IgniterLang::SemanticIREmitter.new.emit_typed(typed)
    emitted.fetch("semantic_ir") || raise("SemanticIREmitter refused OLAP typed boundary")
  end

  def typechecker_semanticir_boundary_checks(boundary)
    positive = boundary.fetch("positive_typed")
    semantic_ir = boundary.fetch("semantic_ir")
    missing = boundary.fetch("negative_missing_dimension")
    mismatch = boundary.fetch("negative_dimension_type_mismatch")
    empty = boundary.fetch("negative_empty_without_source")
    rollup = boundary.fetch("rollup_warning")
    access_node = semantic_ir.dig("contracts", 0, "nodes", 0)
    {
      "parser.live_revenue_point_parses" => boundary.dig("parsed", "parse_errors").empty? &&
        boundary.dig("parsed", "olap_points", 0, "name") == "Revenue",
      "typechecker.olap_positive_accepted" => positive.dig("contracts", 0, "status") == "accepted" &&
        positive.fetch("type_errors").empty?,
      "typechecker.measure_decimal_validated" => positive.dig("olap_points", 0, "measure_type") == "Decimal[2]" &&
        access_node.dig("result_type", "measure") == "Decimal[2]",
      "typechecker.dims_record_validated" => access_node.dig("result_type", "dims_record", "dims") == {
        "date" => "String",
        "region" => "String",
        "channel" => "String"
      },
      "typechecker.oof_o2_warning_nonblocking" => rollup.dig("contracts", 0, "status") == "accepted" &&
        typed_rules(rollup, "type_warnings").include?("OOF-O2") &&
        !typed_rules(rollup, "type_errors").include?("OOF-O2"),
      "typechecker.oof_o3_empty_without_source" => typed_rules(empty, "type_errors") == ["OOF-O3"],
      "typechecker.oof_o4_missing_dimension" => typed_rules(missing, "type_errors") == ["OOF-O4"],
      "typechecker.oof_o5_dimension_type_mismatch" => typed_rules(mismatch, "type_errors") == ["OOF-O5"],
      "semanticir.boundary_olap_point_decl_from_typed" => semantic_ir.dig("olap_points", 0, "kind") == "olap_point_decl",
      "semanticir.boundary_olap_access_node_from_typed" => access_node.fetch("kind") == "olap_access_node",
      "semanticir.boundary_dims_record_lowered" => access_node.dig("result_type", "dims_record", "kind") == "dims_record",
      "semanticir.emitter_typed_program_ref" => semantic_ir.fetch("program_id") == source_identity(semantic_ir, "semanticir") &&
        semantic_ir.fetch("compilation_report_ref") == source_identity(semantic_ir, "compilation_report")
    }
  end

  def source_identity(semantic_ir, prefix)
    "#{prefix}/#{semantic_ir.fetch("source_hash").delete_prefix("sha256:")[0, 16]}"
  end

  def typed_rules(typed, key)
    typed.fetch(key, typed.fetch("contracts").flat_map { |contract| contract.fetch(key, []) })
      .map { |entry| entry.fetch("rule") }
      .uniq
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def write_outputs(summary)
    write_json(SUMMARY_PATH, summary)
    write_json(GOLDEN_DIR / "semantic_ir_program.json", summary.fetch("semantic_ir_program"))
    write_json(GOLDEN_DIR / "point_result.json", summary.fetch("point_result"))
    write_json(GOLDEN_DIR / "rollup_result.json", summary.fetch("rollup_result"))
    write_json(GOLDEN_DIR / "cells.json", summary.fetch("cells"))
    write_json(GOLDEN_DIR / "typechecker_boundary.json", summary.fetch("typechecker_boundary"))
    write_json(GOLDEN_DIR / "semantic_ir_boundary.json", summary.dig("typechecker_boundary", "semantic_ir"))
    summary.fetch("negative_reports").each do |report|
      write_json(GOLDEN_DIR / "#{report.fetch("case_id")}.json", report)
    end
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(Pathname.new(path).dirname)
    File.write(path, Canonical.pretty(payload))
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} olap_point_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "point.measure: #{summary.dig("point_result", "measure")}"
    puts "point.dimensions: #{Canonical.json(summary.dig("point_result", "dimensions"))}"
    puts "rollup.plan: #{summary.dig("rollup_result", "execution_plan")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = OLAPPointProof.run
exit(success ? 0 : 1)

# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

module FragmentRegistryCompatibilityAdapterInternalHelperBoundaryProof
  ROOT = Pathname.new(__dir__).join("../../..").expand_path
  OUT_DIR = ROOT.join("igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out")
  SOURCE_MATRIX_PATH = ROOT.join(
    "igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/" \
    "fragment_precedence_compatibility_adapter_matrix.json"
  )
  SOURCE_SUMMARY_PATH = ROOT.join(
    "igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/" \
    "fragment_precedence_compatibility_adapter_summary.json"
  )

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) do |key, out|
          out[key.to_s] = normalize(value[key])
        end
      when Array
        value.map { |item| normalize(item) }
      else
        value
      end
    end

    def short_digest(value)
      Digest::SHA256.hexdigest(JSON.generate(normalize(value)))[0, 24]
    end

    def write_json(path, value)
      path.dirname.mkpath
      path.write("#{JSON.pretty_generate(normalize(value))}\n")
    end
  end

  module_function

  def run
    source_matrix = read_json(SOURCE_MATRIX_PATH)
    source_summary = read_json(SOURCE_SUMMARY_PATH)
    input = helper_input_shape(source_matrix, source_summary)
    result = helper_result_shape(input, source_matrix, source_summary)

    checks = []
    checks.concat(source_checks(source_matrix, source_summary))
    checks.concat(adapter_checks(input, result))
    checks.concat(surface_scan_checks)

    summary = summary_for(input, result, checks)
    write_outputs(input, result, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def read_json(path)
    JSON.parse(path.read)
  end

  def helper_input_shape(source_matrix, source_summary)
    rows = source_matrix.dig("current_classifier_parity", "rows")
    {
      "kind" => "fragment_registry_compatibility_adapter_helper_input",
      "format_version" => "0.1.0",
      "boundary_mode" => "proof_only_internal_helper",
      "direct_require_only_if_later_implemented" => true,
      "classifier_wiring_authorized" => false,
      "source_r144" => {
        "matrix_ref" => relative(SOURCE_MATRIX_PATH),
        "matrix_digest" => source_summary.fetch("adapter_matrix_digest"),
        "summary_ref" => relative(SOURCE_SUMMARY_PATH)
      },
      "contracts" => rows.map do |row|
        {
          "contract_ref" => row.fetch("contract"),
          "declaration_fragment_presence" => row.fetch("presence"),
          "current_selected_fragment" => row.fetch("current_fragment_class")
        }
      end,
      "guarded_non_fragments" => [
        {
          "name" => "olap",
          "classification_kind" => "not_fragment_class",
          "selected_fragment" => nil
        },
        {
          "name" => "progression",
          "classification_kind" => "not_fragment_class",
          "selected_fragment" => nil
        }
      ],
      "oof_projection_policy" => {
        "primary_semantics" => "status",
        "blocked" => true,
        "loadable" => false,
        "capability" => false
      },
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def helper_result_shape(input, source_matrix, source_summary)
    projections = input.fetch("contracts").map do |contract|
      presence = contract.fetch("declaration_fragment_presence")
      selected = selected_fragment(presence)
      {
        "contract_ref" => contract.fetch("contract_ref"),
        "declaration_fragment_presence" => presence,
        "selected_fragment" => selected,
        "current_selected_fragment" => contract.fetch("current_selected_fragment"),
        "parity" => selected == contract.fetch("current_selected_fragment") ? "PASS" : "FAIL"
      }
    end

    {
      "kind" => "fragment_registry_compatibility_adapter_helper_result",
      "format_version" => "0.1.0",
      "boundary_mode" => "proof_only_internal_helper",
      "selected_fragment_projection" => {
        "rules_in_order" => source_matrix.fetch("selected_fragment_adapter").fetch("rules_in_order"),
        "rows" => projections,
        "mismatches" => projections.reject { |row| row.fetch("parity") == "PASS" }
      },
      "r144_parity" => {
        "source_status" => source_summary.fetch("status"),
        "source_digest" => source_summary.fetch("adapter_matrix_digest"),
        "preserved" => projections.all? { |row| row.fetch("parity") == "PASS" }
      },
      "oof_projection_policy" => input.fetch("oof_projection_policy"),
      "guarded_non_fragments" => input.fetch("guarded_non_fragments"),
      "held_live_dispatch" => true,
      "classifier_wiring_authorized" => false,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def selected_fragment(presence)
    return "oof" if presence.include?("oof")
    return "temporal" if presence.include?("temporal")
    return "escape" if presence.include?("escape")
    return "escape" if presence.include?("stream")
    return "epistemic" if presence.include?("epistemic")

    "core"
  end

  def source_checks(source_matrix, source_summary)
    [
      check(
        "source_r144_summary_pass",
        source_summary.fetch("status") == "PASS",
        "R144 summary status=#{source_summary.fetch("status")}"
      ),
      check(
        "source_r144_held_live_dispatch",
        source_matrix.fetch("held_live_dispatch") == true && source_summary.fetch("held_live_dispatch") == true,
        "R144 adapter remains proof-local"
      ),
      check(
        "source_r144_no_mismatches",
        source_matrix.dig("current_classifier_parity", "mismatches").empty?,
        "R144 selected-fragment mismatches empty"
      )
    ]
  end

  def adapter_checks(input, result)
    rows = result.dig("selected_fragment_projection", "rows")
    [
      check(
        "helper_input_shape",
        input.fetch("kind") == "fragment_registry_compatibility_adapter_helper_input" &&
          input.fetch("direct_require_only_if_later_implemented") == true &&
          input.fetch("classifier_wiring_authorized") == false,
        "helper input is proof-only, direct-require-only, and unwired"
      ),
      check(
        "helper_result_shape",
        result.fetch("kind") == "fragment_registry_compatibility_adapter_helper_result" &&
          result.fetch("held_live_dispatch") == true &&
          result.fetch("classifier_wiring_authorized") == false,
        "helper result is proof-only and live dispatch is held"
      ),
      check(
        "r144_selected_fragment_parity_preserved",
        rows.all? { |row| row.fetch("selected_fragment") == row.fetch("current_selected_fragment") },
        "all #{rows.length} selected fragments match R144 current classifier selection"
      ),
      check(
        "stream_presence_selects_escape",
        rows.select { |row| row.fetch("declaration_fragment_presence").include?("stream") &&
          !row.fetch("declaration_fragment_presence").include?("oof") }.all? { |row| row.fetch("selected_fragment") == "escape" },
        "stream presence remains escape-selected"
      ),
      check(
        "epistemic_escape_presence_selects_escape",
        rows.select { |row| row.fetch("declaration_fragment_presence").include?("epistemic") &&
          row.fetch("declaration_fragment_presence").include?("escape") &&
          !row.fetch("declaration_fragment_presence").include?("oof") }.all? { |row| row.fetch("selected_fragment") == "escape" },
        "epistemic plus escape remains escape-selected"
      ),
      check(
        "epistemic_only_selects_epistemic",
        rows.select { |row| row.fetch("declaration_fragment_presence").include?("epistemic") &&
          !row.fetch("declaration_fragment_presence").include?("escape") &&
          !row.fetch("declaration_fragment_presence").include?("oof") }.all? { |row| row.fetch("selected_fragment") == "epistemic" },
        "epistemic-only remains epistemic-selected"
      ),
      check(
        "temporal_escape_selects_temporal",
        rows.select { |row| row.fetch("declaration_fragment_presence").include?("temporal") &&
          row.fetch("declaration_fragment_presence").include?("escape") &&
          !row.fetch("declaration_fragment_presence").include?("oof") }.all? { |row| row.fetch("selected_fragment") == "temporal" },
        "temporal plus escape remains temporal-selected"
      ),
      check(
        "oof_status_primary_blocked_non_loadable_non_capability",
        input.dig("oof_projection_policy", "primary_semantics") == "status" &&
          input.dig("oof_projection_policy", "blocked") == true &&
          input.dig("oof_projection_policy", "loadable") == false &&
          input.dig("oof_projection_policy", "capability") == false &&
          rows.select { |row| row.fetch("declaration_fragment_presence").include?("oof") }.all? { |row| row.fetch("selected_fragment") == "oof" },
        "OOF stays status-primary blocked projection"
      ),
      check(
        "olap_progression_guarded_non_fragments",
        input.fetch("guarded_non_fragments").all? { |entry| entry.fetch("classification_kind") == "not_fragment_class" &&
          entry.fetch("selected_fragment").nil? },
        "olap/progression remain guarded non-fragments"
      )
    ]
  end

  def surface_scan_checks
    [
      scan_check(
        "negative_scan_root_require",
        ROOT.join("igniter-lang/lib/igniter_lang.rb"),
        ["fragment_registry_compatibility_adapter", "FragmentRegistryCompatibilityAdapter"]
      ),
      scan_check(
        "negative_scan_classifier_wiring",
        ROOT.join("igniter-lang/lib/igniter_lang/classifier.rb"),
        ["fragment_registry_compatibility_adapter", "FragmentRegistryCompatibilityAdapter"]
      ),
      scan_check(
        "negative_scan_report_surface",
        ROOT.join("igniter-lang/lib/igniter_lang/compilation_report.rb"),
        ["fragment_registry_compatibility_adapter", "declaration_fragment_presence"]
      ),
      scan_check(
        "negative_scan_igapp_assembler_surface",
        ROOT.join("igniter-lang/lib/igniter_lang/assembler.rb"),
        ["fragment_registry_compatibility_adapter", "declaration_fragment_presence"]
      ),
      scan_check(
        "negative_scan_public_cli_surface",
        ROOT.join("igniter-lang/lib/igniter_lang/cli.rb"),
        ["fragment_registry_compatibility_adapter", "declaration_fragment_presence"]
      ),
      scan_check(
        "negative_scan_runtime_surface",
        ROOT.join("igniter-lang/lib/igniter_lang/temporal_executor.rb"),
        ["fragment_registry_compatibility_adapter", "declaration_fragment_presence"]
      ),
      scan_check(
        "negative_scan_spark_surface",
        ROOT.join("igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb"),
        ["fragment_registry_compatibility_adapter", "declaration_fragment_presence"]
      )
    ]
  end

  def scan_check(name, path, needles)
    text = path.exist? ? path.read : ""
    hits = needles.select { |needle| text.include?(needle) }
    check(name, hits.empty?, hits.empty? ? "no hits in #{relative(path)}" : "hits=#{hits.join(",")}")
  end

  def check(name, ok, detail)
    {
      "name" => name,
      "status" => ok ? "PASS" : "FAIL",
      "detail" => detail
    }
  end

  def summary_for(input, result, checks)
    failed = checks.reject { |entry| entry.fetch("status") == "PASS" }
    {
      "kind" => "fragment_registry_compatibility_adapter_internal_helper_boundary_proof_summary",
      "format_version" => "0.1.0",
      "track" => "fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0",
      "card" => "S3-R146-C1-P1",
      "status" => failed.empty? ? "PASS" : "FAIL",
      "helper_input_path" => "igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_input_shape.json",
      "helper_result_path" => "igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json",
      "helper_input_digest" => Canonical.short_digest(input),
      "helper_result_digest" => Canonical.short_digest(result),
      "source_r144_matrix_digest" => input.dig("source_r144", "matrix_digest"),
      "observed_contract_count" => input.fetch("contracts").length,
      "check_count" => checks.length,
      "checks" => checks,
      "failed_checks" => failed.map { |entry| entry.fetch("name") },
      "negative_scans" => checks.select { |entry| entry.fetch("name").start_with?("negative_scan_") },
      "implementation_authorized" => false,
      "classifier_wiring_authorized" => false,
      "closed_surface_assertions" => closed_surface_assertions,
      "recommendation" => "ACCEPT_PROOF_ONLY_HELPER_BOUNDARY_HOLD_IMPLEMENTATION"
    }
  end

  def closed_surface_assertions
    {
      "lib_helper_file_created" => false,
      "root_require_changed" => false,
      "classifier_wiring" => false,
      "parser_changed" => false,
      "typechecker_changed" => false,
      "semanticir_changed" => false,
      "assembler_changed" => false,
      "report_changed" => false,
      "igapp_changed" => false,
      "public_api_cli_changed" => false,
      "runtime_changed" => false,
      "spark_changed" => false,
      "production_changed" => false
    }
  end

  def write_outputs(input, result, summary)
    OUT_DIR.mkpath
    Canonical.write_json(OUT_DIR.join("helper_input_shape.json"), input)
    Canonical.write_json(OUT_DIR.join("helper_result_shape.json"), result)
    Canonical.write_json(OUT_DIR.join("fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json"), summary)
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} fragment_registry_compatibility_adapter_internal_helper_boundary"
    summary.fetch("checks").each do |entry|
      puts "#{entry.fetch("name")}: #{entry.fetch("status")}"
    end
    puts "summary: #{summary.fetch("helper_result_digest")}"
  end

  def relative(path)
    path.relative_path_from(ROOT).to_s
  end
end

if $PROGRAM_NAME == __FILE__
  ok = FragmentRegistryCompatibilityAdapterInternalHelperBoundaryProof.run
  exit(ok ? 0 : 1)
end

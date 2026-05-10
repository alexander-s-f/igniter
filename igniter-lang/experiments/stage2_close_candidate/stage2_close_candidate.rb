#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "open3"
require "pathname"
require "time"

module Stage2CloseCandidate
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  IGNITER_LANG_ROOT = ROOT / "igniter-lang"
  LIB_PATH = IGNITER_LANG_ROOT / "lib"
  OUT_DIR = IGNITER_LANG_ROOT / "experiments/stage2_close_candidate"
  SUMMARY_PATH = OUT_DIR / "stage2_close_candidate.json"
  TMP_DIR = Pathname.new("/private/tmp/igniter_lang_stage2_close_candidate")

  REQUIRED_PROOFS = [
    {
      "id" => "production_compiler_cli",
      "label" => "Production compiler CLI/API facade proof",
      "surface" => "package_facade",
      "command" => ["ruby", "igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb"]
    },
    {
      "id" => "invariant_severity",
      "label" => "Invariant severity runtime observation proof",
      "surface" => "invariant_runtime_observations",
      "command" => ["ruby", "igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb"]
    },
    {
      "id" => "olap_point",
      "label" => "OLAPPoint proof",
      "surface" => "olap_point",
      "command" => ["ruby", "igniter-lang/experiments/olap_point_proof/olap_point_proof.rb"]
    },
    {
      "id" => "stream_fold",
      "label" => "stream T bounded fold proof",
      "surface" => "stream_fold",
      "command" => ["ruby", "igniter-lang/experiments/stream_t_proof/stream_t_proof.rb"]
    },
    {
      "id" => "history_type",
      "label" => "History[T] point access proof",
      "surface" => "history_bihistory_temporal_access",
      "command" => ["ruby", "igniter-lang/experiments/history_type_proof/history_type_proof.rb"]
    },
    {
      "id" => "sparkcrm_bihistory",
      "label" => "SparkCRM BiHistory fixture proof",
      "surface" => "history_bihistory_temporal_access",
      "command" => ["ruby", "igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb"]
    },
    {
      "id" => "ledger_tbackend_descriptor",
      "label" => "Ledger TBackend descriptor fixture proof",
      "surface" => "ledger_tbackend_descriptor",
      "command" => ["ruby", "igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb"]
    },
    {
      "id" => "stage1_regression",
      "label" => "Stage 1 close candidate regression",
      "surface" => "stage1_regression",
      "command" => ["ruby", "igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb"]
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    preconditions = package_preconditions
    facade = run_package_facade_smoke
    proofs = REQUIRED_PROOFS.map { |proof| run_proof(proof) }
    summary = build_summary(preconditions: preconditions, facade: facade, proofs: proofs)
    write_summary(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def package_preconditions
    [
      file_precondition("gemspec_present", IGNITER_LANG_ROOT / "igniter_lang.gemspec"),
      file_precondition("version_file_present", LIB_PATH / "igniter_lang/version.rb"),
      file_precondition("package_facade_present", LIB_PATH / "igniter_lang.rb"),
      executable_precondition("igc_bin_executable", IGNITER_LANG_ROOT / "bin/igc")
    ]
  end

  def file_precondition(id, path)
    {
      "id" => id,
      "status" => path.file? ? "PASS" : "FAIL",
      "path" => path.relative_path_from(ROOT).to_s
    }
  end

  def executable_precondition(id, path)
    {
      "id" => id,
      "status" => path.file? && path.executable? ? "PASS" : "FAIL",
      "path" => path.relative_path_from(ROOT).to_s
    }
  end

  def run_package_facade_smoke
    $LOAD_PATH.unshift(LIB_PATH.to_s) unless $LOAD_PATH.include?(LIB_PATH.to_s)
    require "igniter_lang"

    source_path = IGNITER_LANG_ROOT / "experiments/source_to_semanticir_fixture/add.ig"
    out_path = TMP_DIR / "facade_add.igapp"
    FileUtils.mkdir_p(TMP_DIR)
    FileUtils.rm_rf(out_path)

    orchestration = IgniterLang.compile(source_path: source_path, out_path: out_path)
    result = orchestration.fetch("result")
    status = orchestration.fetch("status") == "ok" && out_path.directory? ? "PASS" : "FAIL"

    {
      "id" => "package_facade_direct_compile",
      "label" => "Direct IgniterLang.compile facade smoke",
      "status" => status,
      "entrypoint" => "IgniterLang.compile",
      "facade_version" => facade_version,
      "source_path" => source_path.relative_path_from(ROOT).to_s,
      "igapp_path" => out_path.to_s,
      "program_id" => result["program_id"],
      "contracts" => result.fetch("contracts", []),
      "stages" => result.fetch("stages", {}),
      "diagnostics" => result.fetch("diagnostics", [])
    }
  rescue => e
    {
      "id" => "package_facade_direct_compile",
      "label" => "Direct IgniterLang.compile facade smoke",
      "status" => "FAIL",
      "entrypoint" => "IgniterLang.compile",
      "facade_version" => facade_version,
      "error" => "#{e.class}: #{e.message}"
    }
  end

  def facade_version
    return IgniterLang::VERSION if defined?(IgniterLang::VERSION)

    "unknown"
  end

  def run_proof(proof)
    stdout, stderr, status = Open3.capture3(*proof.fetch("command"), chdir: ROOT.to_s)
    proof.merge(
      "status" => status.success? ? "PASS" : "FAIL",
      "exit_status" => status.exitstatus,
      "checks" => parse_checks(stdout),
      "stdout" => stdout.lines.map(&:chomp),
      "stderr" => stderr.lines.map(&:chomp)
    )
  end

  def parse_checks(stdout)
    stdout.lines.filter_map do |line|
      next unless (match = line.chomp.match(/\A(?<name>[^:]+): (?<status>ok|PASS|FAIL)\z/))

      {
        "name" => match[:name],
        "status" => match[:status] == "FAIL" ? "FAIL" : "PASS"
      }
    end
  end

  def build_summary(preconditions:, facade:, proofs:)
    surface_checks = build_surface_checks(facade: facade, proofs: proofs)
    status = all_pass?(preconditions) && facade.fetch("status") == "PASS" &&
      all_pass?(surface_checks) && all_pass?(proofs) ? "PASS" : "FAIL"

    {
      "kind" => "stage2_close_candidate",
      "format_version" => "0.1.0",
      "track" => "stage2-close-candidate-v0",
      "stage" => "stage2",
      "status" => status,
      "verdict" => status == "PASS" ? "stage2_close_candidate" : "blocked",
      "timestamp" => Time.now.utc.iso8601,
      "_volatile_fields" => ["timestamp"],
      "facade" => {
        "entrypoint" => "IgniterLang.compile",
        "facade_version" => facade.fetch("facade_version", "unknown"),
        "load_path" => LIB_PATH.relative_path_from(ROOT).to_s,
        "libs_loaded" => logical_libs_loaded,
        "files_loaded" => files_loaded
      },
      "preconditions" => preconditions,
      "package_facade_smoke" => facade,
      "surface_checks" => surface_checks,
      "proofs_run" => proofs,
      "fixture_set" => fixture_set,
      "deferred_gaps" => deferred_gaps,
      "close_candidate_signals" => close_candidate_signals
    }
  end

  def build_surface_checks(facade:, proofs:)
    [
      {
        "id" => "package_facade",
        "status" => surface_status(proofs, "package_facade", extra: [facade]),
        "evidence" => {
          "direct_api_compile" => facade.fetch("status"),
          "cli_shared_facade" => proof_status(proofs, "production_compiler_cli"),
          "entrypoint" => "IgniterLang.compile"
        }
      },
      {
        "id" => "invariant_runtime_observations",
        "status" => surface_status(proofs, "invariant_runtime_observations"),
        "evidence" => {
          "compile_time_node" => "invariant_node",
          "runtime_violation_observation" => "invariant_violation_observation",
          "severities" => ["error", "warn", "soft", "metric"]
        }
      },
      {
        "id" => "olap_point",
        "status" => surface_status(proofs, "olap_point"),
        "evidence" => {
          "declaration" => "olap_point",
          "ast" => "dims_record",
          "boundary" => "typed_olap_point_to_semantic_ir"
        }
      },
      {
        "id" => "stream_fold",
        "status" => surface_status(proofs, "stream_fold"),
        "evidence" => {
          "operator" => "fold_stream",
          "oof_guards" => ["missing_window", "direct_stream_arithmetic", "stream_escape"]
        }
      },
      {
        "id" => "history_bihistory_temporal_access",
        "status" => surface_status(proofs, "history_bihistory_temporal_access"),
        "evidence" => {
          "history_capability" => "history_read",
          "bihistory_capability" => "bihistory_read",
          "option_encoding" => { "some" => { "kind" => "some", "value" => "T" }, "none" => { "kind" => "none" } }
        }
      },
      {
        "id" => "ledger_tbackend_descriptor",
        "status" => surface_status(proofs, "ledger_tbackend_descriptor"),
        "evidence" => {
          "binding" => "metadata_only",
          "hook_methods" => ["read_as_of", "bihistory_at"],
          "capabilities" => ["history_read", "bihistory_read"]
        }
      },
      {
        "id" => "stage1_regression",
        "status" => surface_status(proofs, "stage1_regression")
      }
    ]
  end

  def proof_status(proofs, id)
    proofs.find { |proof| proof.fetch("id") == id }&.fetch("status", "FAIL") || "FAIL"
  end

  def surface_status(proofs, surface, extra: [])
    matching = proofs.select { |proof| proof.fetch("surface") == surface }
    statuses = matching.map { |proof| proof.fetch("status") } + extra.map { |proof| proof.fetch("status") }
    statuses.any? && statuses.all? { |status| status == "PASS" } ? "PASS" : "FAIL"
  end

  def all_pass?(items)
    items.all? { |item| item.fetch("status") == "PASS" }
  end

  def logical_libs_loaded
    files_loaded.map do |path|
      path.sub(%r{\Aigniter-lang/lib/}, "").sub(/\.rb\z/, "")
    end
  end

  def files_loaded
    $LOADED_FEATURES.filter_map do |feature|
      path = Pathname.new(feature)
      next unless path.to_s.start_with?(LIB_PATH.to_s)

      path.relative_path_from(ROOT).to_s
    end.sort
  end

  def fixture_set
    [
      "igniter-lang/experiments/source_to_semanticir_fixture/add.ig",
      "igniter-lang/experiments/olap_point_proof/revenue_point.ig",
      "igniter-lang/experiments/stream_t_proof/stream_integer_window.ig",
      "igniter-lang/experiments/history_type_proof/history_integer_point_access.ig",
      "igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb",
      "igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb"
    ]
  end

  def deferred_gaps
    [
      {
        "id" => "production_tbackend_adapter_binding",
        "status" => "deferred",
        "summary" => "Ledger/Durable adapter descriptor exists, but no real production backend package binding is closed."
      },
      {
        "id" => "olap_distributed_execution",
        "status" => "deferred",
        "summary" => "OLAP scatter/gather, rollup, and distributed execution remain out of scope."
      },
      {
        "id" => "invariant_persistence",
        "status" => "deferred",
        "summary" => "Runtime invariant observations are proof-backed, but production persistence is not closed."
      },
      {
        "id" => "deferred_invariant_oofs",
        "status" => "deferred",
        "summary" => "OOF-I1, OOF-I3, and OOF-I5 remain deferred by Stage 2 governance."
      },
      {
        "id" => "gem_release_readiness",
        "status" => "deferred",
        "summary" => "Gemspec/bin skeleton is proven locally; final metadata, CI, and RubyGems release policy remain outside this close candidate."
      }
    ]
  end

  def close_candidate_signals
    [
      {
        "id" => "stage2_surfaces_closed_in_proof",
        "status" => "closed_in_proof",
        "summary" => "Invariant, OLAP, stream, History/BiHistory, Ledger descriptor, and package facade checks are all required PASS surfaces."
      },
      {
        "id" => "public_facade_used",
        "status" => "closed_in_proof",
        "summary" => "The candidate uses IgniterLang.compile for direct package facade evidence."
      },
      {
        "id" => "stage1_regression_preserved",
        "status" => "closed_in_proof",
        "summary" => "The Stage 1 close candidate remains part of the required Stage 2 close run."
      }
    ]
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} stage2_close_candidate"
    puts "verdict: #{summary.fetch("verdict")}"
    summary.fetch("surface_checks").each do |surface|
      puts "#{surface.fetch("id")}: #{surface.fetch("status")}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = Stage2CloseCandidate.run
exit(success ? 0 : 1)

#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module CompilerProfileR32ShadowChainBackreference
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_r32_shadow_chain_backreference/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_r32_shadow_chain_backreference_summary.json"

  DISCUSSION_PATH = LANG_ROOT / "docs/discussions/r32-durable-audit-prop032-and-compiler-profile-pressure-v0.md"
  CLOSURE_INDEX_PATH = LANG_ROOT / "docs/tracks/compiler-profile-chain-closure-index-v0.md"
  TRACK_PATH = LANG_ROOT / "docs/tracks/compiler-profile-r32-shadow-chain-backreference-v0.md"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-r32-shadow-chain-backreference-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)

    discussion = read(DISCUSSION_PATH)
    closure_index = read(CLOSURE_INDEX_PATH)
    track_doc = read(TRACK_PATH)

    checks = {
      "discussion.names_m3_shadow_dependency_map" => discussion.include?("M-3: A dependency map") &&
        discussion.include?("shadow proof chain"),
      "discussion.points_to_closure_index" => discussion.include?("compiler-profile-chain-closure-index-v0.md"),
      "track_records_m3_disposition" => track_doc.include?("M-3") &&
        track_doc.include?("addressed-by-closure-index"),
      "track_links_pressure_and_index" => track_doc.include?(DISCUSSION_PATH.relative_path_from(LANG_ROOT).to_s) &&
        track_doc.include?(CLOSURE_INDEX_PATH.relative_path_from(LANG_ROOT).to_s),
      "track_preserves_shadow_scope" => track_doc.include?("No production CompilerKernel") &&
        track_doc.include?("No `.igapp` or `.ilk` format change") &&
        track_doc.include?("No runtime execution authority"),
      "closure_index_includes_backreference" => closure_index.include?("compiler-profile-r32-shadow-chain-backreference-v0")
    }

    summary = {
      "kind" => "compiler_profile_r32_shadow_chain_backreference_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "r32_pressure_item" => "M-3",
      "disposition" => "addressed-by-closure-index",
      "backreferences" => {
        "pressure_discussion" => DISCUSSION_PATH.relative_path_from(ROOT).to_s,
        "closure_index" => CLOSURE_INDEX_PATH.relative_path_from(ROOT).to_s,
        "track_doc" => TRACK_PATH.relative_path_from(ROOT).to_s
      },
      "checks" => checks,
      "what_this_authorizes" => [
        "Treat the closure index as the current dependency-map answer for R32 M-3."
      ],
      "what_this_does_not_authorize" => [
        "No production CompilerKernel implementation.",
        "No compiler dispatch rewrite.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ]
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def read(path)
    File.read(path)
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_r32_shadow_chain_backreference"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileR32ShadowChainBackreference.run
exit(success ? 0 : 1)

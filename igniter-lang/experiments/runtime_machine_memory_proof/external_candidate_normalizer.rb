#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "tmpdir"
require_relative "runtime_machine_memory_proof"
require_relative "packet_builder_check"

module RuntimeMachineExternalCandidateNormalizer
  Canonical = RuntimeMachineMemoryProof::Canonical

  SCHEMA_VERSION = RuntimeMachineProofPacketBuilderCheck::SCHEMA_VERSION
  PROFILE_MODE = "selected_profile"
  DEFAULT_RAW_CANDIDATE = File.expand_path("external_candidate_fixture/raw_candidate.json", __dir__)
  DEFAULT_GOLDEN_DIR = RuntimeMachineProofPacketBuilderCheck::DEFAULT_FIXTURE_DIR
  DEFAULT_CANDIDATE_DIR = File.join(Dir.tmpdir, "runtime_machine_external_candidate_normalized")
  ARTIFACT_FILES = RuntimeMachineProofPacketBuilderCheck::ARTIFACT_FILES
  OPTIONAL_FILES = %w[external_ref_map.json adapter_diagnostics.json].freeze

  class Normalizer
    attr_reader :checks, :candidate_dir, :raw_candidate_path

    def initialize(raw_candidate_path:, candidate_dir:, golden_dir:)
      @raw_candidate_path = File.expand_path(raw_candidate_path)
      @candidate_dir = File.expand_path(candidate_dir)
      @golden_dir = File.expand_path(golden_dir)
      @checks = []
      @failures = []
    end

    def call(check_candidate: true)
      raw = read_json(@raw_candidate_path)
      golden = load_golden
      validate_raw(raw, golden)
      return false unless failures.empty?

      required_files = required_artifact_files(golden)
      optional_files = optional_artifact_files(raw)
      write_files(required_files.merge(optional_files), required_files.keys)
      record("write_candidate", true)

      return true unless check_candidate

      checker = RuntimeMachineProofPacketBuilderCheck::Checker.new(
        candidate_dir: @candidate_dir,
        golden_dir: @golden_dir,
        profile_mode: PROFILE_MODE
      )
      result = checker.call
      record("packet_builder_check", result.ok?)
      result.failures.each { |failure| record("checker_failure: #{failure}", false) }
      result.ok?
    end

    private

    attr_reader :failures

    def read_json(path)
      JSON.parse(File.read(path))
    rescue Errno::ENOENT
      record("read #{path}", false)
      {}
    rescue JSON::ParserError => e
      record("parse #{path}: #{e.message}", false)
      {}
    end

    def load_golden
      ARTIFACT_FILES.keys.each_with_object({}) do |name, out|
        out[name] = read_json(File.join(@golden_dir, name))
      end
    end

    def validate_raw(raw, golden)
      result_summary = golden.fetch("result_summary.golden.json").fetch("payload")
      semantic_image = golden.fetch("semantic_image.golden.json").fetch("payload").fetch("semantic_image")
      reports = golden.fetch("compatibility_reports.golden.json").fetch("payload")
      selected = golden.fetch("obs_packets.golden.json").fetch("payload").fetch("selected")
      resumed_links = selected.fetch("resumed_dispatch_candidate_value").fetch("links").map { |link| link.fetch("rel") }
      assertions = raw.fetch("semantic_assertions", {})

      expect(raw.fetch("schema_version", nil) == "runtime-machine-external-candidate-normalizer-fixtures-v0",
             "raw.schema_version")
      expect(raw.fetch("profile_mode", nil) == PROFILE_MODE, "raw.profile_mode")
      expect(raw.fetch("source", {}).fetch("full_session_logs", nil) == false, "raw.source.full_session_logs")
      expect(assertions.fetch("result_hash", nil) == result_summary.fetch("result_hash"), "assert.result_hash")
      expect(assertions.fetch("semantic_image_content_hash", nil) == semantic_image.fetch("content_hash"),
             "assert.semantic_image_content_hash")
      expect(assertions.fetch("trusted_resume_status", nil) == reports.fetch("trusted_resume").fetch("resume_status"),
             "assert.trusted_resume_status")
      expect(assertions.fetch("negative_evidence_policy", nil) == "preserve", "assert.negative_evidence_policy")
      assertions.fetch("required_links", []).each do |rel|
        expect(resumed_links.include?(rel), "assert.required_links.#{rel}")
      end
      expect(raw.fetch("normalization", {}).fetch("semantic_substitutions", []).any?,
             "raw.normalization.semantic_substitutions")
    end

    def expect(condition, name)
      record("normalize.#{name}", condition)
    end

    def required_artifact_files(golden)
      ARTIFACT_FILES.each_with_object({}) do |(name, artifact), out|
        payload = golden.fetch(name).fetch("payload")
        out[name] = json(
          schema_version: SCHEMA_VERSION,
          artifact: artifact,
          payload: normalized_payload(artifact, payload)
        )
      end
    end

    def normalized_payload(artifact, payload)
      return payload unless artifact == "obs_packets"

      {
        profile_mode: PROFILE_MODE,
        selected: payload.fetch("selected")
      }
    end

    def optional_artifact_files(raw)
      {
        "external_ref_map.json" => json(
          schema_version: "runtime-machine-external-candidate-normalizer-fixtures-v0",
          artifact: "external_ref_map",
          payload: {
            source: raw.fetch("source", {}),
            profile_mode: PROFILE_MODE,
            source_refs: raw.fetch("source_refs", {}),
            semantic_substitutions: raw.fetch("normalization", {}).fetch("semantic_substitutions", [])
          }
        ),
        "adapter_diagnostics.json" => json(
          schema_version: "runtime-machine-external-candidate-normalizer-fixtures-v0",
          artifact: "adapter_diagnostics",
          payload: {
            pass: failures.empty?,
            checks: checks,
            trusted_admission_files: ARTIFACT_FILES.keys + ["manifest.json"],
            optional_files: OPTIONAL_FILES
          }
        )
      }
    end

    def write_files(files, trusted_file_names)
      rendered = files.merge("manifest.json" => json(manifest(files, trusted_file_names)))
      FileUtils.mkdir_p(@candidate_dir)
      rendered.each do |name, content|
        File.write(File.join(@candidate_dir, name), content)
      end
    end

    def manifest(files, trusted_file_names)
      {
        schema_version: SCHEMA_VERSION,
        artifact: "manifest",
        files: trusted_file_names.sort.map do |name|
          {
            path: name,
            content_hash: "sha256:#{Digest::SHA256.hexdigest(files.fetch(name))}"
          }
        end
      }
    end

    def json(value)
      "#{JSON.pretty_generate(Canonical.normalize(value))}\n"
    end

    def record(name, ok)
      checks << { name: name, ok: ok }
      failures << name unless ok
    end
  end

  module CLI
    module_function

    def run(argv)
      options = parse(argv)
      normalizer = Normalizer.new(
        raw_candidate_path: options.fetch(:raw_candidate_path),
        candidate_dir: options.fetch(:candidate_dir),
        golden_dir: options.fetch(:golden_dir)
      )
      success = normalizer.call(check_candidate: options.fetch(:mode) == "check")
      print_result(success, normalizer)
      success
    end

    def parse(argv)
      options = {
        mode: "check",
        raw_candidate_path: DEFAULT_RAW_CANDIDATE,
        candidate_dir: DEFAULT_CANDIDATE_DIR,
        golden_dir: DEFAULT_GOLDEN_DIR
      }

      until argv.empty?
        arg = argv.shift
        case arg
        when "--raw-candidate"
          options[:raw_candidate_path] = argv.shift || abort_usage("--raw-candidate requires a path")
        when "--candidate"
          options[:candidate_dir] = argv.shift || abort_usage("--candidate requires a directory")
        when "--golden"
          options[:golden_dir] = argv.shift || abort_usage("--golden requires a directory")
        when "--write-candidate"
          options[:mode] = "write"
          options[:candidate_dir] = argv.shift || abort_usage("--write-candidate requires a directory")
        when "--help", "-h"
          puts usage
          exit 0
        else
          abort_usage("unknown argument: #{arg}")
        end
      end

      options
    end

    def abort_usage(message)
      warn message
      warn usage
      exit 2
    end

    def usage
      <<~TEXT
        Usage:
          ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
          ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb --candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb --write-candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb --raw-candidate <path> --candidate <dir>
      TEXT
    end

    def print_result(success, normalizer)
      puts "#{success ? "PASS" : "FAIL"} runtime_machine_external_candidate_normalizer"
      puts "raw_candidate: #{normalizer.raw_candidate_path}"
      puts "candidate_dir: #{normalizer.candidate_dir}"
      puts "profile_mode: #{PROFILE_MODE}"
      normalizer.checks.each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = RuntimeMachineExternalCandidateNormalizer::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

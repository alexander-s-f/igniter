#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "tmpdir"
require_relative "runtime_machine_memory_proof"
require_relative "packet_builder_check"

module RuntimeMachineProofSidecarBuilderProfiles
  Canonical = RuntimeMachineMemoryProof::Canonical
  SCHEMA_VERSION = RuntimeMachineMemoryProof::FixtureArtifacts::SCHEMA_VERSION

  DEFAULT_GOLDEN_DIR = RuntimeMachineProofPacketBuilderCheck::DEFAULT_FIXTURE_DIR
  DEFAULT_CANDIDATE_DIR = File.join(Dir.tmpdir, "runtime_machine_proof_sidecar_builder_profiles")

  class ProfileSet
    def initialize(proof_artifacts)
      @proof_artifacts = proof_artifacts
    end

    def files
      rendered = artifact_profiles.each_with_object({}) do |profile, out|
        out[profile.file_name] = json(profile.to_h)
      end
      rendered["manifest.json"] = json(manifest(rendered))
      rendered
    end

    private

    def artifact_profiles
      [
        ObsPacketsProfile.new(@proof_artifacts.fetch("obs_packets")),
        SemanticImageProfile.new(@proof_artifacts.fetch("semantic_image")),
        CompatibilityReportsProfile.new(@proof_artifacts.fetch("compatibility_reports")),
        NegativeEvidenceProfile.new(@proof_artifacts.fetch("negative_evidence")),
        ResultSummaryProfile.new(@proof_artifacts.fetch("result_summary"))
      ]
    end

    def manifest(rendered_files)
      {
        schema_version: SCHEMA_VERSION,
        artifact: "manifest",
        files: rendered_files.keys.sort.map do |name|
          {
            path: name,
            content_hash: "sha256:#{Digest::SHA256.hexdigest(rendered_files.fetch(name))}"
          }
        end
      }
    end

    def json(value)
      "#{JSON.pretty_generate(Canonical.normalize(value))}\n"
    end
  end

  class ArtifactProfile
    def initialize(artifact, file_name, payload)
      @artifact = artifact
      @file_name = file_name
      @payload = payload
    end

    attr_reader :file_name

    def to_h
      {
        schema_version: SCHEMA_VERSION,
        artifact: @artifact,
        payload: @payload
      }
    end
  end

  class ObsPacketsProfile < ArtifactProfile
    def initialize(payload)
      super("obs_packets", "obs_packets.golden.json", payload)
    end
  end

  class SemanticImageProfile < ArtifactProfile
    def initialize(payload)
      super("semantic_image", "semantic_image.golden.json", payload)
    end
  end

  class CompatibilityReportsProfile < ArtifactProfile
    def initialize(payload)
      super("compatibility_reports", "compatibility_reports.golden.json", payload)
    end
  end

  class NegativeEvidenceProfile < ArtifactProfile
    def initialize(payload)
      super("negative_evidence", "negative_evidence.golden.json", payload)
    end
  end

  class ResultSummaryProfile < ArtifactProfile
    def initialize(payload)
      super("result_summary", "result_summary.golden.json", payload)
    end
  end

  class Builder
    def initialize(candidate_dir:, golden_dir:)
      @candidate_dir = File.expand_path(candidate_dir)
      @golden_dir = File.expand_path(golden_dir)
      @checks = []
    end

    attr_reader :checks, :candidate_dir

    def write_candidate
      runner = RuntimeMachineMemoryProof::ProofRunner.new
      proof_ok = runner.run(print_summary: false)
      record("proof_capture", proof_ok)
      return false unless proof_ok

      files = ProfileSet.new(runner.artifacts).files
      FileUtils.mkdir_p(@candidate_dir)
      files.each do |name, content|
        File.write(File.join(@candidate_dir, name), content)
      end
      record("write_candidate", true)
      true
    end

    def check_candidate
      checker = RuntimeMachineProofPacketBuilderCheck::Checker.new(
        candidate_dir: @candidate_dir,
        golden_dir: @golden_dir
      )
      result = checker.call
      record("packet_builder_check", result.ok?)
      result.failures.each { |failure| record("checker_failure: #{failure}", false) }
      result.ok?
    end

    private

    def record(name, ok)
      @checks << { name: name, ok: ok }
    end
  end

  module CLI
    module_function

    def run(argv)
      options = parse(argv)
      builder = Builder.new(
        candidate_dir: options.fetch(:candidate_dir),
        golden_dir: options.fetch(:golden_dir)
      )

      write_ok = builder.write_candidate
      check_ok = options.fetch(:mode) == "write" ? true : builder.check_candidate
      success = write_ok && check_ok

      print_result(success, builder)
      success
    end

    def parse(argv)
      options = {
        mode: "check",
        candidate_dir: DEFAULT_CANDIDATE_DIR,
        golden_dir: DEFAULT_GOLDEN_DIR
      }

      until argv.empty?
        arg = argv.shift
        case arg
        when "--candidate"
          options[:candidate_dir] = argv.shift || abort_usage("--candidate requires a directory")
        when "--write-candidate"
          options[:mode] = "write"
          options[:candidate_dir] = argv.shift || abort_usage("--write-candidate requires a directory")
        when "--golden"
          options[:golden_dir] = argv.shift || abort_usage("--golden requires a directory")
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
          ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
          ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --write-candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --golden <dir> --candidate <dir>
      TEXT
    end

    def print_result(success, builder)
      puts "#{success ? "PASS" : "FAIL"} runtime_machine_proof_sidecar_builder_profiles"
      puts "candidate_dir: #{builder.candidate_dir}"
      builder.checks.each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = RuntimeMachineProofSidecarBuilderProfiles::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

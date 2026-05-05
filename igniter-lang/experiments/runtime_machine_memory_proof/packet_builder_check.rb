#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require_relative "runtime_machine_memory_proof"

module RuntimeMachineProofPacketBuilderCheck
  Canonical = RuntimeMachineMemoryProof::Canonical

  SCHEMA_VERSION = RuntimeMachineMemoryProof::FixtureArtifacts::SCHEMA_VERSION
  DEFAULT_FIXTURE_DIR = File.expand_path("fixtures", __dir__)
  PROFILE_MODES = %w[full_log selected_profile].freeze

  ARTIFACT_FILES = {
    "obs_packets.golden.json" => "obs_packets",
    "semantic_image.golden.json" => "semantic_image",
    "compatibility_reports.golden.json" => "compatibility_reports",
    "negative_evidence.golden.json" => "negative_evidence",
    "result_summary.golden.json" => "result_summary"
  }.freeze

  ALL_FILES = (ARTIFACT_FILES.keys + ["manifest.json"]).freeze
  OBS_KINDS = %w[
    descriptor_observation
    failure_observation
    fact_observation
    platform_observation
    receipt_observation
    value_observation
  ].freeze

  class Result
    attr_reader :checks, :failures

    def initialize
      @checks = []
      @failures = []
    end

    def category(name)
      before = @failures.length
      yield
      @checks << { name: name, ok: @failures.length == before }
    end

    def expect(condition, message)
      @failures << message unless condition
    end

    def ok?
      @failures.empty?
    end
  end

  class Checker
    def initialize(candidate_dir:, golden_dir:, profile_mode: "full_log")
      @candidate_dir = File.expand_path(candidate_dir)
      @golden_dir = File.expand_path(golden_dir)
      @profile_mode = normalize_profile_mode(profile_mode)
      @result = Result.new
      @candidate = {}
      @golden = {}
      @seen_packets = {}
    end

    def call
      load_sets
      @result.category("profile_mode") { check_profile_mode }
      @result.category("manifest") { check_manifest(@candidate_dir, @candidate.fetch("manifest.json")) }
      @result.category("artifact_headers") { check_artifact_headers(@candidate) }
      @result.category("obs_packets") { check_obs_packets }
      @result.category("semantic_image") { check_semantic_image }
      @result.category("compatibility_reports") { check_compatibility_reports }
      @result.category("negative_evidence") { check_negative_evidence }
      @result.category("result_summary") { check_result_summary }
      unless @candidate_dir == @golden_dir
        category = full_log_mode? ? "golden_comparison" : "selected_comparison"
        @result.category(category) { check_against_golden }
      end
      @result
    end

    private

    def normalize_profile_mode(mode)
      mode.to_s.tr("-", "_")
    end

    def full_log_mode?
      @profile_mode == "full_log"
    end

    def check_profile_mode
      @result.expect(PROFILE_MODES.include?(@profile_mode), "unknown profile mode: #{@profile_mode}")
    end

    def load_sets
      ALL_FILES.each do |name|
        @candidate[name] = read_json(File.join(@candidate_dir, name))
        @golden[name] = read_json(File.join(@golden_dir, name))
      end
    end

    def read_json(path)
      JSON.parse(File.read(path))
    rescue Errno::ENOENT
      @result.expect(false, "missing file: #{path}")
      {}
    rescue JSON::ParserError => e
      @result.expect(false, "invalid JSON: #{path}: #{e.message}")
      {}
    end

    def check_manifest(dir, manifest)
      @result.expect(manifest.fetch("schema_version", nil) == SCHEMA_VERSION, "manifest schema mismatch")
      @result.expect(manifest.fetch("artifact", nil) == "manifest", "manifest artifact mismatch")

      indexed = manifest.fetch("files", []).each_with_object({}) do |entry, out|
        out[entry.fetch("path", nil)] = entry.fetch("content_hash", nil)
      end

      ARTIFACT_FILES.each_key do |name|
        path = File.join(dir, name)
        expected_hash = indexed[name]
        actual_hash = File.file?(path) ? raw_hash(path) : nil

        @result.expect(!expected_hash.nil?, "manifest missing #{name}")
        @result.expect(expected_hash == actual_hash, "manifest hash mismatch for #{name}")
      end
    end

    def raw_hash(path)
      "sha256:#{Digest::SHA256.hexdigest(File.read(path))}"
    end

    def check_artifact_headers(files)
      ARTIFACT_FILES.each do |name, artifact|
        file = files.fetch(name)
        @result.expect(file.fetch("schema_version", nil) == SCHEMA_VERSION, "#{name} schema mismatch")
        @result.expect(file.fetch("artifact", nil) == artifact, "#{name} artifact mismatch")
        @result.expect(file.key?("payload"), "#{name} missing payload")
      end
    end

    def check_obs_packets
      obs = artifact_payload("obs_packets.golden.json")
      sessions = obs.fetch("sessions", {})

      if full_log_mode?
        %w[session_a session_b].each do |name|
          entries = sessions.fetch(name, [])
          @result.expect(entries.any?, "#{name} packet log is empty")
          check_session_entries(name, entries)
        end
      else
        @result.expect(obs.fetch("profile_mode", nil) == @profile_mode, "selected profile mode mismatch")
        sessions.each { |name, entries| check_session_entries(name, entries) }
      end

      selected = obs.fetch("selected", {})
      %w[
        dispatch_candidate_value
        resumed_dispatch_candidate_value
        semantic_image_packet
        trusted_compatibility_report_packet
      ].each do |name|
        check_packet(selected.fetch(name, {}), "selected.#{name}")
      end

      value_packet = selected.fetch("resumed_dispatch_candidate_value", {})
      rels = link_rels(value_packet)
      @result.expect(rels.count("read_from") >= 4, "resumed value packet missing read_from links")
      @result.expect(rels.include?("executed_by"), "resumed value packet missing executed_by link")
      @result.expect(rels.include?("produced_in"), "resumed value packet missing produced_in link")
      @result.expect(rels.count("observed_under") >= 3, "resumed value packet missing observed_under links")
    end

    def check_session_entries(name, entries)
      entries.each_with_index do |entry, index|
        @result.expect(entry.fetch("seq_id", nil).is_a?(Integer), "#{name}[#{index}] seq_id missing")
        @result.expect(entry.fetch("transaction_time", nil).is_a?(String), "#{name}[#{index}] transaction_time missing")
        check_packet(entry.fetch("packet", {}), "#{name}[#{index}].packet")
      end
    end

    def check_semantic_image
      payload = artifact_payload("semantic_image.golden.json")
      image = payload.fetch("semantic_image", {})
      image_packet = payload.fetch("semantic_image_packet", {})
      receipt = payload.fetch("checkpoint_receipt", {})

      base = image.reject { |key, _| %w[image_id content_hash].include?(key) }
      expected_content_hash = Canonical.hash(base)
      expected_image_id = "image/#{expected_content_hash.split(":").last[0, 16]}"

      @result.expect(image.fetch("content_hash", nil) == expected_content_hash, "semantic image content_hash mismatch")
      @result.expect(image.fetch("image_id", nil) == expected_image_id, "semantic image image_id mismatch")
      @result.expect(image_packet.fetch("payload", nil) == image, "semantic image packet payload mismatch")
      check_packet(image_packet, "semantic_image_packet")
      check_packet(receipt, "checkpoint_receipt")

      checkpoint = image.fetch("checkpoint", {})
      cursor = image.fetch("replay_cursor", {})
      @result.expect(checkpoint.fetch("seq_id", nil) == cursor.fetch("position", nil), "checkpoint seq_id does not match replay cursor")
      @result.expect(receipt.fetch("payload", {}).fetch("semantic_image_ref", nil) == image_packet.fetch("id", nil),
                     "checkpoint receipt does not reference semantic image packet")
    end

    def check_compatibility_reports
      reports = artifact_payload("compatibility_reports.golden.json")
      expected_status = {
        "trusted_resume" => "trusted",
        "blocked_empty_backend_resume" => "blocked",
        "downgraded_runtime_drift" => "downgraded",
        "blocked_contract_drift" => "blocked"
      }

      expected_status.each do |name, status|
        report = reports.fetch(name, {})
        @result.expect(report.fetch("resume_status", nil) == status, "#{name} resume_status mismatch")
        @result.expect(report.fetch("report_id", nil) == "compat/#{Canonical.short_hash(report.fetch("checks", []))}",
                       "#{name} report_id mismatch")
        @result.expect(derived_resume_status(report.fetch("checks", [])) == status, "#{name} derived status mismatch")
      end

      runtime_drift = reports.fetch("downgraded_runtime_drift", {}).fetch("checks", [])
      @result.expect(check_outcome(runtime_drift, "runtime") == "downgrade", "runtime drift should downgrade runtime")
      @result.expect(check_outcome(runtime_drift, "backend") == "compatible", "runtime drift should not block backend")

      empty_backend = reports.fetch("blocked_empty_backend_resume", {}).fetch("checks", [])
      @result.expect(check_outcome(empty_backend, "snapshot") == "blocked", "empty backend should block snapshot")
      @result.expect(check_outcome(empty_backend, "replay") == "blocked", "empty backend should block replay")
    end

    def check_negative_evidence
      payload = artifact_payload("negative_evidence.golden.json")
      ambient = payload.fetch("failure_packets", {}).fetch("ambient_time", {})
      check_packet(ambient, "negative.ambient_time")
      @result.expect(ambient.fetch("payload", {}).fetch("reason_code", nil) == "temporal.as_of_missing",
                     "ambient time failure reason mismatch")

      same_value = payload.fetch("same_value_without_evidence", {})
      value_packet = same_value.fetch("value_packet", {})
      evidence = same_value.fetch("evidence_status", {})
      check_packet(value_packet, "negative.same_value_without_evidence.value_packet")
      @result.expect(value_packet.fetch("payload_hash", nil) == same_value.fetch("expected_result_hash", nil),
                     "same value expected hash mismatch")
      @result.expect(evidence.fetch("status", nil) == "provisional", "same value evidence should be provisional")
      @result.expect(evidence.fetch("missing", []) == %w[executed_by read_from observed_under produced_in],
                     "same value missing evidence list mismatch")
    end

    def check_result_summary
      payload = artifact_payload("result_summary.golden.json")
      @result.expect(payload.fetch("pass", nil) == true, "result summary pass is not true")
      @result.expect(payload.fetch("same_result_hash", nil) == true, "result summary same_result_hash is not true")
      @result.expect(payload.fetch("result_hash", nil) == payload.fetch("resumed_result_hash", nil),
                     "result hashes differ")
      @result.expect(payload.fetch("evidence_status", {}).fetch("status", nil) == "trusted",
                     "result evidence status is not trusted")
      @result.expect(payload.fetch("checks", []).all? { |check| check.fetch("ok", false) },
                     "one or more proof checks failed")
    end

    def check_against_golden
      return check_selected_against_golden unless full_log_mode?

      ARTIFACT_FILES.each_key do |name|
        candidate_payload = @candidate.fetch(name).fetch("payload", nil)
        golden_payload = @golden.fetch(name).fetch("payload", nil)
        @result.expect(Canonical.normalize(candidate_payload) == Canonical.normalize(golden_payload),
                       "candidate payload differs from golden for #{name}")
      end
    end

    def check_selected_against_golden
      candidate_obs = @candidate.fetch("obs_packets.golden.json").fetch("payload", {})
      golden_obs = @golden.fetch("obs_packets.golden.json").fetch("payload", {})
      candidate_selected = candidate_obs.fetch("selected", {})
      golden_selected = golden_obs.fetch("selected", {})

      @result.expect(
        Canonical.normalize(candidate_selected) == Canonical.normalize(golden_selected),
        "candidate selected packets differ from golden selected packets"
      )

      candidate_summary = @candidate.fetch("result_summary.golden.json").fetch("payload", {})
      golden_summary = @golden.fetch("result_summary.golden.json").fetch("payload", {})
      @result.expect(
        candidate_summary.fetch("result_hash", nil) == golden_summary.fetch("result_hash", nil),
        "candidate result hash differs from golden result hash"
      )
    end

    def artifact_payload(name)
      @candidate.fetch(name, {}).fetch("payload", {})
    end

    def check_packet(packet, path)
      %w[id kind subject payload payload_hash temporal links].each do |field|
        @result.expect(packet.key?(field), "#{path} missing #{field}")
      end
      return unless packet.key?("payload")

      @result.expect(OBS_KINDS.include?(packet.fetch("kind", nil)), "#{path} unknown kind")
      @result.expect(packet.fetch("payload_hash", nil) == Canonical.hash(packet.fetch("payload")),
                     "#{path} payload_hash mismatch")
      @result.expect(packet.fetch("id", nil) == expected_packet_id(packet), "#{path} packet id mismatch")
      @result.expect(packet.fetch("links", []).is_a?(Array), "#{path} links must be an array")

      packet.fetch("links", []).each_with_index do |link, index|
        @result.expect(link.key?("rel"), "#{path}.links[#{index}] missing rel")
        @result.expect(link.key?("ref"), "#{path}.links[#{index}] missing ref")
        @result.expect([true, false].include?(link.fetch("required", nil)),
                       "#{path}.links[#{index}] missing boolean required")
      end

      packet_id = packet.fetch("id", nil)
      normalized = Canonical.normalize(packet)
      if @seen_packets.key?(packet_id)
        @result.expect(@seen_packets.fetch(packet_id) == normalized, "#{path} reuses packet id with different payload")
      else
        @seen_packets[packet_id] = normalized
      end
    end

    def expected_packet_id(packet)
      identity_material = {
        kind: packet.fetch("kind"),
        subject: packet.fetch("subject"),
        payload_hash: packet.fetch("payload_hash"),
        temporal: packet.fetch("temporal"),
        links: packet.fetch("links")
      }
      "obs/#{Canonical.short_hash(identity_material)}"
    end

    def link_rels(packet)
      packet.fetch("links", []).map { |link| link.fetch("rel", nil) }
    end

    def derived_resume_status(checks)
      outcomes = checks.map { |check| check.fetch("outcome", nil) }
      return "blocked" if outcomes.include?("blocked")
      return "downgraded" if outcomes.include?("downgrade")

      "trusted"
    end

    def check_outcome(checks, dimension)
      checks.find { |check| check.fetch("dimension", nil) == dimension }&.fetch("outcome", nil)
    end
  end

  module CLI
    module_function

    def run(argv)
      options = parse(argv)
      checker = Checker.new(
        candidate_dir: options.fetch(:candidate_dir),
        golden_dir: options.fetch(:golden_dir),
        profile_mode: options.fetch(:profile_mode)
      )
      result = checker.call
      print_result(result)
      result.ok?
    end

    def parse(argv)
      options = {
        golden_dir: DEFAULT_FIXTURE_DIR,
        candidate_dir: nil,
        profile_mode: "full_log"
      }

      until argv.empty?
        arg = argv.shift
        case arg
        when "--golden"
          options[:golden_dir] = argv.shift || abort_usage("--golden requires a directory")
        when "--candidate"
          options[:candidate_dir] = argv.shift || abort_usage("--candidate requires a directory")
        when "--profile-mode"
          options[:profile_mode] = normalize_profile_mode(argv.shift || abort_usage("--profile-mode requires a mode"))
        when "--help", "-h"
          puts usage
          exit 0
        else
          abort_usage("unknown argument: #{arg}")
        end
      end

      options[:candidate_dir] ||= options.fetch(:golden_dir)
      options
    end

    def normalize_profile_mode(mode)
      mode.to_s.tr("-", "_")
    end

    def abort_usage(message)
      warn message
      warn usage
      exit 2
    end

    def usage
      <<~TEXT
        Usage:
          ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
          ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --golden <dir> --candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --profile-mode selected_profile --candidate <dir>
      TEXT
    end

    def print_result(result)
      puts "#{result.ok? ? "PASS" : "FAIL"} runtime_machine_proof_packet_builder_check"
      result.checks.each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      result.failures.each { |failure| puts "failure: #{failure}" }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = RuntimeMachineProofPacketBuilderCheck::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

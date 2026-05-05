#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "tmpdir"
require_relative "runtime_machine_memory_proof"

module RuntimeMachineFFIRubyReceiptFixtures
  Canonical = RuntimeMachineMemoryProof::Canonical
  ObsPacket = RuntimeMachineMemoryProof::ObsPacket

  SCHEMA_VERSION = "runtime-machine-ffi-ruby-receipt-fixtures-v0"
  DEFAULT_FIXTURE_DIR = File.expand_path("ffi_ruby_receipt_fixtures", __dir__)
  DEFAULT_CANDIDATE_DIR = File.join(Dir.tmpdir, "runtime_machine_ffi_ruby_receipt_fixtures")
  PACKET_FILE = "ffi_ruby_receipts.golden.json"
  MANIFEST_FILE = "manifest.json"
  PROOF_AS_OF = RuntimeMachineMemoryProof::PROOF_AS_OF
  RULE_VERSION = "ffi_ruby_receipts@1"
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

  module Link
    module_function

    def to(rel, ref, required: true)
      { rel: rel.to_s, ref: ref.to_s, required: required }
    end
  end

  class FixtureSet
    def files
      packets = json(packet_artifact)
      {
        PACKET_FILE => packets,
        MANIFEST_FILE => json(manifest(PACKET_FILE => packets))
      }
    end

    private

    def packet_artifact
      descriptors = descriptor_packets
      scenarios = scenario_packets(descriptors)

      {
        schema_version: SCHEMA_VERSION,
        artifact: "ffi_ruby_receipt_fixtures",
        payload: {
          descriptors: descriptors.transform_values(&:to_h),
          packets: scenarios.transform_values(&:to_h),
          expectations: expectations(descriptors, scenarios)
        }
      }
    end

    def descriptor_packets
      {
        order_lookup_ffi: packet(
          kind: "descriptor_observation",
          subject: "ffi://ruby/spark.order_lookup.v0",
          payload: {
            descriptor: "FFIRequirement",
            ffi_id: "spark.order_lookup.v0",
            host_lang: "ruby",
            host_ref: "SparkCRM::OrderLookup.call",
            input_ports: [{ name: "order_id", type_tag: "OrderId", required: true }],
            output_ports: [{ name: "order", type_tag: "OrderSnapshot", required: true }],
            effects: ["read"],
            capabilities: ["orders_read"],
            lifecycle: "session",
            failures: %w[not_found permission_denied timeout],
            audit: false,
            fragment_class: "ESCAPE"
          },
          temporal: temporal("load", fact_scope: "ffi/spark.order_lookup.v0"),
          links: [
            Link.to("observed_under", "axiom/core-v0"),
            Link.to("produced_in", "execution_environment/ffi_fixture")
          ]
        ),
        assign_technician_ffi: packet(
          kind: "descriptor_observation",
          subject: "ffi://ruby/spark.assign_technician.v0",
          payload: {
            descriptor: "FFIRequirement",
            ffi_id: "spark.assign_technician.v0",
            host_lang: "ruby",
            host_ref: "SparkCRM::AssignTechnician.call",
            input_ports: [
              { name: "order_id", type_tag: "OrderId", required: true },
              { name: "technician_id", type_tag: "TechnicianId", required: true }
            ],
            output_ports: [
              { name: "assignment_receipt", type_tag: "AssignmentReceipt", required: true }
            ],
            effects: ["write"],
            capabilities: ["dispatch_assign"],
            lifecycle: "durable",
            failures: %w[conflict permission_denied timeout],
            audit: true,
            fragment_class: "ESCAPE"
          },
          temporal: temporal("load", fact_scope: "ffi/spark.assign_technician.v0"),
          links: [
            Link.to("observed_under", "axiom/core-v0"),
            Link.to("produced_in", "execution_environment/ffi_fixture")
          ]
        )
      }
    end

    def scenario_packets(descriptors)
      order_lookup_ref = descriptors.fetch(:order_lookup_ffi).id
      assign_ref = descriptors.fetch(:assign_technician_ffi).id

      {
        read_success: packet(
          kind: "fact_observation",
          subject: "ffi://ruby/spark.order_lookup.v0/order/O-100",
          payload: {
            ffi_id: "spark.order_lookup.v0",
            host_ref: "SparkCRM::OrderLookup.call",
            effect: "read",
            outcome: "success",
            result_type: "OrderSnapshot",
            output: {
              order_id: "O-100",
              service: "install",
              status: "open"
            },
            lifecycle: "session",
            host_call_attempted: true
          },
          temporal: temporal("session", fact_scope: "spark/order/O-100"),
          links: [
            Link.to("read_from", order_lookup_ref),
            Link.to("read_from", "external:spark://orders/O-100"),
            Link.to("executed_by", "runtime/ffi_executor/ruby"),
            Link.to("produced_in", "execution_environment/server")
          ]
        ),
        write_audit_success: packet(
          kind: "receipt_observation",
          subject: "ffi://ruby/spark.assign_technician.v0/order/O-100",
          payload: {
            ffi_id: "spark.assign_technician.v0",
            host_ref: "SparkCRM::AssignTechnician.call",
            effect: "write",
            outcome: "success",
            receipt_type: "AssignmentReceipt",
            order_id: "O-100",
            technician_id: "T-7",
            idempotency_key: "dispatch/O-100/T-7/rule-v3",
            status: "committed",
            lifecycle: "audit",
            host_call_attempted: true
          },
          temporal: temporal("audit", fact_scope: "spark/order/O-100"),
          links: [
            Link.to("caused_by", "obs/dispatch_decision_pinned"),
            Link.to("read_from", assign_ref),
            Link.to("read_from", "obs/resumed_dispatch_candidate_value"),
            Link.to("executed_by", "runtime/ffi_executor/ruby"),
            Link.to("produced_in", "execution_environment/server")
          ]
        ),
        capability_denied: packet(
          kind: "failure_observation",
          subject: "ffi://ruby/spark.assign_technician.v0/order/O-101",
          payload: {
            reason_code: "capability.denied",
            ffi_id: "spark.assign_technician.v0",
            host_ref: "SparkCRM::AssignTechnician.call",
            effect: "write",
            required_capability: "dispatch_assign",
            granted_capabilities: ["orders_read"],
            missing_capabilities: ["dispatch_assign"],
            retryable: false,
            lifecycle: "session",
            host_call_attempted: false
          },
          temporal: temporal("session", fact_scope: "spark/order/O-101"),
          links: [
            Link.to("caused_by", "obs/dispatch_decision_pinned"),
            Link.to("read_from", assign_ref),
            Link.to("executed_by", "runtime/ffi_executor/ruby"),
            Link.to("produced_in", "execution_environment/server")
          ]
        ),
        host_error: packet(
          kind: "failure_observation",
          subject: "ffi://ruby/spark.assign_technician.v0/order/O-102",
          payload: {
            reason_code: "ffi.host_error",
            ffi_id: "spark.assign_technician.v0",
            host_ref: "SparkCRM::AssignTechnician.call",
            effect: "write",
            declared_failure: "conflict",
            error_class: "SparkCRM::ConflictError",
            error_message: "conflict: already assigned",
            retryable: true,
            lifecycle: "session",
            host_call_attempted: true
          },
          temporal: temporal("session", fact_scope: "spark/order/O-102"),
          links: [
            Link.to("caused_by", "obs/dispatch_decision_pinned"),
            Link.to("read_from", assign_ref),
            Link.to("executed_by", "runtime/ffi_executor/ruby"),
            Link.to("produced_in", "execution_environment/server")
          ]
        )
      }
    end

    def expectations(descriptors, scenarios)
      {
        descriptors: descriptors.keys.map(&:to_s),
        packets: scenarios.keys.map(&:to_s),
        required_links: {
          read_success: %w[read_from executed_by produced_in],
          write_audit_success: %w[caused_by read_from executed_by produced_in],
          capability_denied: %w[caused_by read_from executed_by produced_in],
          host_error: %w[caused_by read_from executed_by produced_in]
        },
        lifecycle: {
          read_success: "session",
          write_audit_success: "audit",
          capability_denied: "session",
          host_error: "session"
        },
        reason_codes: {
          capability_denied: "capability.denied",
          host_error: "ffi.host_error"
        }
      }
    end

    def packet(kind:, subject:, payload:, temporal:, links:)
      ObsPacket.new(kind: kind, subject: subject, payload: payload, temporal: temporal, links: links)
    end

    def temporal(lifecycle, fact_scope:)
      {
        as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION,
        lifecycle: lifecycle,
        fact_scope: fact_scope
      }
    end

    def manifest(files)
      {
        schema_version: SCHEMA_VERSION,
        artifact: "manifest",
        files: files.keys.sort.map do |name|
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
  end

  class Checker
    def initialize(fixture_dir:)
      @fixture_dir = File.expand_path(fixture_dir)
      @result = Result.new
      @seen_packets = {}
    end

    def call
      artifact = read_json(File.join(@fixture_dir, PACKET_FILE))
      manifest = read_json(File.join(@fixture_dir, MANIFEST_FILE))
      payload = artifact.fetch("payload", {})
      descriptors = payload.fetch("descriptors", {})
      packets = payload.fetch("packets", {})

      @result.category("manifest") { check_manifest(manifest) }
      @result.category("artifact_header") { check_artifact_header(artifact) }
      @result.category("descriptor_packets") { check_packet_set(descriptors) }
      @result.category("scenario_packets") { check_packet_set(packets) }
      @result.category("read_success") { check_read_success(packets.fetch("read_success", {})) }
      @result.category("write_audit_success") { check_write_audit_success(packets.fetch("write_audit_success", {})) }
      @result.category("capability_denied") { check_capability_denied(packets.fetch("capability_denied", {})) }
      @result.category("host_error") { check_host_error(packets.fetch("host_error", {})) }
      @result.category("cross_case") { check_cross_case(packets) }
      @result
    end

    private

    def read_json(path)
      JSON.parse(File.read(path))
    rescue Errno::ENOENT
      @result.expect(false, "missing file: #{path}")
      {}
    rescue JSON::ParserError => e
      @result.expect(false, "invalid JSON: #{path}: #{e.message}")
      {}
    end

    def check_manifest(manifest)
      @result.expect(manifest.fetch("schema_version", nil) == SCHEMA_VERSION, "manifest schema mismatch")
      @result.expect(manifest.fetch("artifact", nil) == "manifest", "manifest artifact mismatch")
      indexed = manifest.fetch("files", []).to_h { |entry| [entry.fetch("path", nil), entry.fetch("content_hash", nil)] }
      expected_hash = indexed[PACKET_FILE]
      actual_hash = "sha256:#{Digest::SHA256.hexdigest(File.read(File.join(@fixture_dir, PACKET_FILE)))}"
      @result.expect(indexed.keys == [PACKET_FILE], "manifest should trust only #{PACKET_FILE}")
      @result.expect(expected_hash == actual_hash, "manifest hash mismatch for #{PACKET_FILE}")
    end

    def check_artifact_header(artifact)
      @result.expect(artifact.fetch("schema_version", nil) == SCHEMA_VERSION, "artifact schema mismatch")
      @result.expect(artifact.fetch("artifact", nil) == "ffi_ruby_receipt_fixtures", "artifact name mismatch")
      @result.expect(artifact.fetch("payload", {}).key?("packets"), "artifact payload missing packets")
      @result.expect(artifact.fetch("payload", {}).key?("expectations"), "artifact payload missing expectations")
    end

    def check_packet_set(packets)
      packets.each do |name, packet|
        check_packet(packet, name)
      end
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

    def check_read_success(packet)
      expect_packet(packet, kind: "fact_observation", lifecycle: "session")
      payload = packet.fetch("payload", {})
      @result.expect(payload.fetch("ffi_id", nil) == "spark.order_lookup.v0", "read ffi_id mismatch")
      @result.expect(payload.fetch("effect", nil) == "read", "read effect mismatch")
      @result.expect(payload.fetch("outcome", nil) == "success", "read outcome mismatch")
      @result.expect(payload.fetch("host_call_attempted", nil) == true, "read should call host")
      expect_links(packet, %w[read_from executed_by produced_in])
    end

    def check_write_audit_success(packet)
      expect_packet(packet, kind: "receipt_observation", lifecycle: "audit")
      payload = packet.fetch("payload", {})
      @result.expect(payload.fetch("ffi_id", nil) == "spark.assign_technician.v0", "write ffi_id mismatch")
      @result.expect(payload.fetch("effect", nil) == "write", "write effect mismatch")
      @result.expect(payload.fetch("status", nil) == "committed", "write status mismatch")
      @result.expect(payload.fetch("idempotency_key", nil).to_s.start_with?("dispatch/"),
                     "write missing idempotency key")
      @result.expect(payload.fetch("host_call_attempted", nil) == true, "write should call host")
      expect_links(packet, %w[caused_by read_from executed_by produced_in])
    end

    def check_capability_denied(packet)
      expect_packet(packet, kind: "failure_observation", lifecycle: "session")
      payload = packet.fetch("payload", {})
      @result.expect(payload.fetch("reason_code", nil) == "capability.denied", "capability reason mismatch")
      @result.expect(payload.fetch("required_capability", nil) == "dispatch_assign", "required capability mismatch")
      @result.expect(payload.fetch("missing_capabilities", []) == ["dispatch_assign"], "missing capabilities mismatch")
      @result.expect(payload.fetch("host_call_attempted", nil) == false, "capability denial must not call host")
      expect_links(packet, %w[caused_by read_from executed_by produced_in])
    end

    def check_host_error(packet)
      expect_packet(packet, kind: "failure_observation", lifecycle: "session")
      payload = packet.fetch("payload", {})
      @result.expect(payload.fetch("reason_code", nil) == "ffi.host_error", "host error reason mismatch")
      @result.expect(payload.fetch("declared_failure", nil) == "conflict", "declared failure mismatch")
      @result.expect(payload.fetch("error_class", nil) == "SparkCRM::ConflictError", "error class mismatch")
      @result.expect(payload.fetch("host_call_attempted", nil) == true, "host error should call host")
      expect_links(packet, %w[caused_by read_from executed_by produced_in])
    end

    def check_cross_case(packets)
      @result.expect(packets.keys.sort == %w[capability_denied host_error read_success write_audit_success],
                     "unexpected scenario packet set")
      write = packets.fetch("write_audit_success", {})
      denied = packets.fetch("capability_denied", {})
      host_error = packets.fetch("host_error", {})
      @result.expect(write.fetch("kind", nil) == "receipt_observation", "write success should be receipt")
      @result.expect(denied.fetch("kind", nil) == "failure_observation", "capability denied should be failure")
      @result.expect(host_error.fetch("kind", nil) == "failure_observation", "host error should be failure")
      @result.expect(denied.fetch("payload_hash", nil) != host_error.fetch("payload_hash", nil),
                     "failure cases should have distinct payload hashes")
    end

    def expect_packet(packet, kind:, lifecycle:)
      @result.expect(packet.fetch("kind", nil) == kind, "#{kind} kind mismatch")
      @result.expect(packet.fetch("temporal", {}).fetch("lifecycle", nil) == lifecycle,
                     "#{kind} lifecycle mismatch")
    end

    def expect_links(packet, required_rels)
      rels = packet.fetch("links", []).map { |link| link.fetch("rel", nil) }
      required_rels.each do |rel|
        @result.expect(rels.include?(rel), "#{packet.fetch("subject", "packet")} missing #{rel} link")
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
  end

  module CLI
    module_function

    def run(argv)
      options = parse(argv)
      if options.fetch(:mode) == "write"
        write_fixtures(options.fetch(:fixture_dir))
      end

      result = Checker.new(fixture_dir: options.fetch(:fixture_dir)).call
      print_result(result, options.fetch(:fixture_dir))
      result.ok?
    end

    def parse(argv)
      options = {
        mode: "check",
        fixture_dir: DEFAULT_FIXTURE_DIR
      }

      until argv.empty?
        arg = argv.shift
        case arg
        when "--write-fixtures"
          options[:mode] = "write"
        when "--candidate"
          options[:fixture_dir] = argv.shift || abort_usage("--candidate requires a directory")
        when "--help", "-h"
          puts usage
          exit 0
        else
          abort_usage("unknown argument: #{arg}")
        end
      end

      options
    end

    def write_fixtures(fixture_dir)
      FileUtils.mkdir_p(fixture_dir)
      FixtureSet.new.files.each do |name, content|
        File.write(File.join(fixture_dir, name), content)
      end
    end

    def abort_usage(message)
      warn message
      warn usage
      exit 2
    end

    def usage
      <<~TEXT
        Usage:
          ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb
          ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --write-fixtures
          ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --write-fixtures --candidate <dir>
          ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --candidate <dir>
      TEXT
    end

    def print_result(result, fixture_dir)
      puts "#{result.ok? ? "PASS" : "FAIL"} runtime_machine_ffi_ruby_receipt_fixtures"
      puts "fixture_dir: #{File.expand_path(fixture_dir)}"
      result.checks.each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
      result.failures.each { |failure| puts "failure: #{failure}" }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = RuntimeMachineFFIRubyReceiptFixtures::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

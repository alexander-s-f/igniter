#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "time"

module RuntimeMachineMemoryProof
  PROOF_AS_OF = "2026-05-05T10:42:00Z"
  RULE_VERSION = "toy_dispatch@1"

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
      when Symbol
        value.to_s
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).split(":").last[0, 16]
    end
  end

  module DeterministicClock
    module_function

    def at_seq(seq_id)
      (Time.utc(2026, 5, 5, 10, 42, 0) + seq_id).iso8601
    end
  end

  class ObsPacket
    attr_reader :id, :kind, :subject, :payload, :payload_hash, :temporal, :links

    def initialize(kind:, subject:, payload:, temporal:, links: [])
      @kind = kind.to_s
      @subject = subject.to_s
      @payload = Canonical.normalize(payload)
      @temporal = Canonical.normalize(temporal)
      @links = Canonical.normalize(links)
      @payload_hash = Canonical.hash(@payload)
      @id = "obs/#{Canonical.short_hash(identity_material)}"
    end

    def to_h
      {
        id: @id,
        kind: @kind,
        subject: @subject,
        payload: @payload,
        payload_hash: @payload_hash,
        temporal: @temporal,
        links: @links
      }
    end

    def link_rels
      @links.map { |link| link.fetch("rel") }
    end

    private

    def identity_material
      {
        kind: @kind,
        subject: @subject,
        payload_hash: @payload_hash,
        temporal: @temporal,
        links: @links
      }
    end
  end

  class MemoryTBackend
    attr_reader :entries

    def initialize(entries: [], snapshots: {}, idempotency_index: {})
      @entries = entries.map(&:dup)
      @snapshots = snapshots.transform_values(&:dup)
      @idempotency_index = idempotency_index.dup
    end

    def describe
      {
        backend_id: "memory-proof",
        backend_kind: "memory",
        version: "0.1.0",
        capabilities: {
          read_as_of: true,
          append_atomic: true,
          replay_enabled: true,
          snapshot_enabled: true,
          compact_enabled: false,
          subscribe_enabled: false,
          max_replay_window: nil,
          consistency: "single_process_total_order"
        },
        durability_model: "process_memory",
        loss_window: "all_on_process_loss"
      }
    end

    def append(packet, idempotency_key: nil)
      key = idempotency_key || packet.id
      if @idempotency_index.key?(key)
        existing = entry_at_seq(@idempotency_index.fetch(key))
        return receipt_for(existing, packet, duplicate: true)
      end

      seq_id = @entries.length + 1
      entry = {
        seq_id: seq_id,
        packet: packet,
        transaction_time: DeterministicClock.at_seq(seq_id)
      }

      @entries << entry
      @idempotency_index[key] = seq_id
      receipt_for(entry, packet, duplicate: false)
    end

    def read(subject:, as_of:, type_hint: nil)
      _type_hint = type_hint
      visible = @entries.select do |entry|
        packet = entry.fetch(:packet)
        packet.kind == "fact_observation" &&
          packet.subject == subject.to_s &&
          visible_at?(packet.temporal.fetch("as_of", nil), as_of)
      end

      visible.max_by { |entry| entry.fetch(:seq_id) }&.fetch(:packet)
    end

    def replay(cursor:, filter: nil, limit: nil)
      _filter = filter
      position = cursor.fetch(:position)
      inclusive = cursor.fetch(:inclusive, false)
      selected = @entries.select do |entry|
        seq_id = entry.fetch(:seq_id)
        inclusive ? seq_id >= position : seq_id > position
      end
      selected = selected.first(limit) if limit
      last = selected.last

      {
        observations: selected.map { |entry| entry.fetch(:packet) },
        next_cursor: last && {
          anchor: "seq_id",
          position: last.fetch(:seq_id),
          inclusive: false
        },
        truncated: limit ? selected.length == limit : false
      }
    end

    def snapshot(horizon:)
      seq_id = last_seq
      material = {
        horizon: horizon,
        seq_id: seq_id,
        packets: @entries.map do |entry|
          packet = entry.fetch(:packet)
          {
            seq_id: entry.fetch(:seq_id),
            id: packet.id,
            payload_hash: packet.payload_hash
          }
        end
      }
      snapshot_hash = Canonical.hash(material)
      snapshot_ref = "memory-snapshot/#{Canonical.short_hash(material)}"

      @snapshots[snapshot_ref] = {
        snapshot_ref: snapshot_ref,
        snapshot_hash: snapshot_hash,
        seq_id: seq_id,
        horizon: Canonical.normalize(horizon),
        entries: @entries.map(&:dup),
        idempotency_index: @idempotency_index.dup
      }

      {
        snapshot_ref: snapshot_ref,
        snapshot_hash: snapshot_hash,
        seq_id: seq_id,
        horizon: Canonical.normalize(horizon)
      }
    end

    def restore(snapshot_ref)
      snapshot = @snapshots.fetch(snapshot_ref)
      MemoryTBackend.new(
        entries: snapshot.fetch(:entries),
        snapshots: @snapshots,
        idempotency_index: snapshot.fetch(:idempotency_index)
      )
    end

    def snapshot_available?(snapshot_ref, snapshot_hash)
      snapshot = @snapshots[snapshot_ref]
      snapshot && snapshot.fetch(:snapshot_hash) == snapshot_hash
    end

    def replay_available?(seq_id)
      last_seq >= seq_id.to_i
    end

    def last_seq
      @entries.length
    end

    private

    def entry_at_seq(seq_id)
      @entries.fetch(seq_id - 1)
    end

    def receipt_for(entry, packet, duplicate:)
      {
        seq_id: entry.fetch(:seq_id),
        transaction_time: entry.fetch(:transaction_time),
        content_hash: packet.payload_hash,
        obs_id: packet.id,
        duplicate: duplicate
      }
    end

    def visible_at?(packet_as_of, requested_as_of)
      return false unless packet_as_of && requested_as_of

      packet_as_of <= requested_as_of
    end
  end

  class ToyDispatchContract
    attr_reader :compiled_graph_hash

    def initialize(graph_version: "toy-dispatch-contract-v0", schema_version: "0.0.0")
      @graph_version = graph_version
      @schema_version = schema_version
      @compiled_graph_hash = Canonical.hash(descriptor_payload)
    end

    def descriptor_payload
      {
        name: "ToyDispatchContract",
        version: @graph_version,
        fragment_class: "CORE",
        required_escapes: [],
        effects: [],
        capabilities: [],
        reads: [
          "OrderRequest(order_id)",
          "TechnicianProfile(technician_id)",
          "ScheduleSlot(technician_id, as_of)",
          "OffSchedule(technician_id, as_of)"
        ],
        output: "DispatchCandidate"
      }
    end

    def schema_descriptor
      @schema_descriptor ||= begin
        surface = {
          schema_version: @schema_version,
          port_surface: [
            { dir: "in", name: "order_id", type_tag: "String", lifecycle: "local", required: true },
            { dir: "in", name: "technician_id", type_tag: "String", lifecycle: "local", required: true },
            { dir: "out", name: "dispatch_candidate", type_tag: "DispatchCandidate", lifecycle: "session" }
          ],
          type_env: ["DispatchCandidate", "String"],
          trait_bounds: []
        }
        Canonical.normalize(
          surface.merge(
            schema_fingerprint: Canonical.hash(surface),
            migrations: []
          )
        )
      end
    end

    def schema_version
      schema_descriptor.fetch("schema_version")
    end

    def schema_fingerprint
      schema_descriptor.fetch("schema_fingerprint")
    end

    def evaluate(order:, profile:, schedule_slot:, off_schedule:, inputs:)
      service_match = profile.fetch("services").include?(order.fetch("service"))
      schedule_conflict = schedule_slot.fetch("occupied")
      off_schedule_conflict = off_schedule.fetch("disabled")
      available = service_match && !schedule_conflict && !off_schedule_conflict

      reason_codes = []
      reason_codes << (service_match ? "service_match" : "service_mismatch")
      reason_codes << (schedule_conflict ? "schedule_conflict" : "schedule_free")
      reason_codes << (off_schedule_conflict ? "off_schedule_conflict" : "not_off_schedule")

      {
        order_id: inputs.fetch(:order_id),
        technician_id: inputs.fetch(:technician_id),
        available: available,
        reason_codes: reason_codes
      }
    end
  end

  class RuntimeMachine
    attr_reader :machine_id, :session_id, :backend, :state, :loaded_unit
    attr_reader :loaded_schema_descriptor
    attr_reader :axiom_descriptor_ref, :runtime_contract_ref
    attr_reader :execution_environment_ref, :tbackend_descriptor_ref
    attr_reader :last_value_packet, :last_result_hash

    def initialize(machine_id:, session_id:, backend:, runtime_version: "proof-runtime-v1")
      @machine_id = machine_id
      @session_id = session_id
      @backend = backend
      @runtime_version = runtime_version
      @state = "unbooted"
      @loaded_unit = nil
      @loaded_schema_descriptor = nil
      @contract = nil
      @last_value_packet = nil
      @last_result_hash = nil
    end

    def boot
      return failure("runtime.invalid_transition", "boot requires unbooted machine") unless @state == "unbooted"

      axiom = packet(
        kind: "platform_observation",
        subject: "axiom/core-v0",
        payload: {
          descriptor: "AxiomDescriptor",
          version: "core-v0",
          hash_policy: "canonical-json-sha256",
          temporal_policy: "explicit_only"
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "boot" },
        links: []
      )
      @backend.append(axiom, idempotency_key: axiom.id)
      @axiom_descriptor_ref = axiom.id

      runtime = packet(
        kind: "platform_observation",
        subject: "runtime/proof-inline",
        payload: {
          descriptor: "RuntimeContract",
          version: @runtime_version,
          scheduler: "inline",
          concurrency: "single_threaded",
          clock_policy: "explicit_only",
          cache_policy: "none",
          capability_executor: "deny_by_default"
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "boot" },
        links: observed_under_axiom
      )
      @backend.append(runtime, idempotency_key: runtime.id)
      @runtime_contract_ref = runtime.id

      tbackend = packet(
        kind: "platform_observation",
        subject: "tbackend/memory-proof",
        payload: @backend.describe,
        temporal: { as_of: PROOF_AS_OF, lifecycle: "boot" },
        links: observed_under_runtime
      )
      @backend.append(tbackend, idempotency_key: tbackend.id)
      @tbackend_descriptor_ref = tbackend.id

      environment = packet(
        kind: "platform_observation",
        subject: "execution-environment/#{@machine_id}",
        payload: {
          descriptor: "ExecutionEnvironment",
          machine_id: @machine_id,
          session_id: @session_id,
          host: "standalone-proof",
          process_model: "single_process"
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "boot" },
        links: observed_under_runtime_backend
      )
      @backend.append(environment, idempotency_key: environment.id)
      @execution_environment_ref = environment.id

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/boot",
        payload: { transition: "boot", status: "ok", next_state: "booted" },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "boot" },
        links: evidence_links
      )
      @backend.append(receipt)

      @state = "booted"
      { status: "ok", receipt: receipt }
    end

    def load(contract)
      return failure("runtime.invalid_transition", "load requires booted machine") unless %w[booted loaded].include?(@state)

      descriptor = packet(
        kind: "descriptor_observation",
        subject: "contract/toy-dispatch",
        payload: contract.descriptor_payload.merge(compiled_graph_hash: contract.compiled_graph_hash),
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links
      )
      @backend.append(descriptor, idempotency_key: descriptor.id)

      fragment = packet(
        kind: "descriptor_observation",
        subject: "fragment/toy-dispatch",
        payload: {
          fragment_class: "CORE",
          required_escapes: [],
          compiled_graph_hash: contract.compiled_graph_hash
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links + [link("describes", descriptor.id)]
      )
      @backend.append(fragment, idempotency_key: fragment.id)

      @loaded_schema_descriptor = schema_descriptor_for(contract)
      @loaded_unit = {
        unit_id: "loaded-unit/#{Canonical.short_hash(contract.descriptor_payload)}",
        contract_descriptor_ref: descriptor.id,
        fragment_descriptor_ref: fragment.id,
        compiled_graph_hash: contract.compiled_graph_hash,
        fragment_class: "CORE",
        schema_version: @loaded_schema_descriptor.fetch("schema_version"),
        schema_fingerprint: @loaded_schema_descriptor.fetch("schema_fingerprint")
      }
      @contract = contract

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/load",
        payload: { transition: "load", status: "ok", loaded_unit: @loaded_unit },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links + [link("describes", descriptor.id)]
      )
      @backend.append(receipt)

      @state = "loaded"
      { status: "ok", loaded_unit: @loaded_unit, receipt: receipt }
    end

    def evaluate(order_id:, technician_id:, as_of:, rule_version:)
      return failure("temporal.as_of_missing", "evaluate requires explicit as_of") unless as_of
      return failure("runtime.invalid_transition", "evaluate requires loaded machine") unless @state == "loaded"

      @state = "evaluating"
      reads = read_inputs(order_id: order_id, technician_id: technician_id, as_of: as_of)
      return reads if reads.fetch(:status) == "blocked"

      payload = @contract.evaluate(
        order: reads.fetch(:order).payload,
        profile: reads.fetch(:profile).payload,
        schedule_slot: reads.fetch(:schedule_slot).payload,
        off_schedule: reads.fetch(:off_schedule).payload,
        inputs: { order_id: order_id, technician_id: technician_id }
      )

      value = packet(
        kind: "value_observation",
        subject: "dispatch-candidate/#{order_id}/#{technician_id}",
        payload: payload,
        temporal: { as_of: as_of, rule_version: rule_version },
        links: evidence_links +
          [link("executed_by", @runtime_contract_ref)] +
          reads.fetch(:packets).map { |packet| link("read_from", packet.id) }
      )
      @backend.append(value)

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/evaluate",
        payload: {
          transition: "evaluate",
          status: "ok",
          value_ref: value.id,
          result_hash: value.payload_hash
        },
        temporal: { as_of: as_of, rule_version: rule_version },
        links: evidence_links + [link("caused_by", value.id)]
      )
      @backend.append(receipt)

      @state = "loaded"
      @last_value_packet = value
      @last_result_hash = value.payload_hash

      {
        status: "ok",
        payload: payload,
        value_packet: value,
        result_hash: value.payload_hash,
        receipt: receipt
      }
    end

    def checkpoint(horizon:)
      return failure("runtime.invalid_transition", "checkpoint requires loaded machine") unless @state == "loaded"

      snapshot = @backend.snapshot(horizon: horizon)
      checkpoint_ref = {
        checkpoint_id: "checkpoint/#{Canonical.short_hash(snapshot)}",
        as_of: horizon.fetch(:as_of),
        seq_id: snapshot.fetch(:seq_id),
        snapshot_ref: snapshot.fetch(:snapshot_ref),
        snapshot_hash: snapshot.fetch(:snapshot_hash),
        created_at: DeterministicClock.at_seq(@backend.last_seq + 1)
      }
      observation_ids = @backend.entries.map { |entry| entry.fetch(:packet).id }

      image_base = {
        session_id: @session_id,
        produced_at: checkpoint_ref.fetch(:created_at),
        axiom_descriptor_ref: @axiom_descriptor_ref,
        runtime_contract_ref: @runtime_contract_ref,
        backend_descriptor_ref: @tbackend_descriptor_ref,
        backend_descriptor_hash: Canonical.hash(@backend.describe),
        execution_environment_ref: @execution_environment_ref,
        contract_descriptor_ref: @loaded_unit.fetch(:contract_descriptor_ref),
        compiled_graph_hash: @loaded_unit.fetch(:compiled_graph_hash),
        observation_count: observation_ids.length,
        observation_hash: Canonical.hash(observation_ids),
        value_refs: [@last_value_packet.id],
        value_hashes: [@last_result_hash],
        receipt_refs: observation_ids.select { |id| id.start_with?("obs/") },
        checkpoint: checkpoint_ref,
        replay_cursor: {
          anchor: "seq_id",
          position: checkpoint_ref.fetch(:seq_id),
          inclusive: false
        },
        temporal_horizon: horizon,
        # PROP-017: schema evolution fields
        schema_version: schema_descriptor.fetch("schema_version"),
        schema_fingerprint: schema_descriptor.fetch("schema_fingerprint")
      }
      image_id = "image/#{Canonical.short_hash(image_base)}"
      semantic_image = image_base.merge(
        image_id: image_id,
        content_hash: Canonical.hash(image_base)
      )

      image_packet = packet(
        kind: "platform_observation",
        subject: "semantic-image/#{@session_id}",
        payload: semantic_image,
        temporal: { as_of: horizon.fetch(:as_of), lifecycle: "checkpoint" },
        links: evidence_links + [link("caused_by", @last_value_packet.id)]
      )
      @backend.append(image_packet)

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/checkpoint",
        payload: {
          transition: "checkpoint",
          status: "ok",
          semantic_image_ref: image_packet.id,
          image_id: image_id
        },
        temporal: { as_of: horizon.fetch(:as_of), lifecycle: "checkpoint" },
        links: evidence_links + [link("caused_by", image_packet.id)]
      )
      @backend.append(receipt)

      @state = "checkpointed"
      {
        status: "ok",
        snapshot: snapshot,
        checkpoint_ref: checkpoint_ref,
        semantic_image: Canonical.normalize(semantic_image),
        semantic_image_packet: image_packet,
        receipt: receipt
      }
    end

    def resume(image:, requested_as_of:, intent: "exact_replay")
      report = CompatibilityChecker.new(
        machine: self,
        image: image,
        requested_as_of: requested_as_of,
        intent: intent
      ).call

      report_packet = packet(
        kind: "platform_observation",
        subject: "compatibility-report/#{@session_id}",
        payload: report,
        temporal: { as_of: requested_as_of, lifecycle: "resume" },
        links: evidence_links + [link("caused_by", image.fetch("image_id"))]
      )
      @backend.append(report_packet)

      resume_packet = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/resume",
        payload: {
          transition: "resume",
          status: report.fetch("resume_status"),
          image_id: image.fetch("image_id")
        },
        temporal: { as_of: requested_as_of, lifecycle: "resume" },
        links: evidence_links + [link("caused_by", report_packet.id)]
      )
      @backend.append(resume_packet)

      @state = report.fetch("resume_status") == "blocked" ? "failed" : "loaded"
      { status: report.fetch("resume_status"), report: report, packet: report_packet }
    end

    def fact_packet(subject:, payload:, as_of:)
      packet(
        kind: "fact_observation",
        subject: subject,
        payload: payload,
        temporal: { as_of: as_of },
        links: evidence_links
      )
    end

    def evidence_links
      [
        link("observed_under", @axiom_descriptor_ref),
        link("observed_under", @runtime_contract_ref),
        link("observed_under", @tbackend_descriptor_ref),
        link("produced_in", @execution_environment_ref)
      ].reject { |item| item.fetch(:ref).nil? }
    end

    private

    def schema_descriptor
      @loaded_schema_descriptor || default_schema_descriptor
    end

    def schema_descriptor_for(unit)
      if unit.respond_to?(:schema_descriptor)
        Canonical.normalize(unit.schema_descriptor)
      else
        default_schema_descriptor
      end
    end

    def default_schema_descriptor
      {
        "schema_version" => "0.0.0",
        "schema_fingerprint" => "sha256:unknown",
        "migrations" => []
      }
    end

    def packet(kind:, subject:, payload:, temporal:, links:)
      ObsPacket.new(
        kind: kind,
        subject: subject,
        payload: payload,
        temporal: temporal,
        links: links
      )
    end

    def read_inputs(order_id:, technician_id:, as_of:)
      subjects = {
        order: "order/#{order_id}",
        profile: "technician-profile/#{technician_id}",
        schedule_slot: "schedule-slot/#{technician_id}/#{as_of}",
        off_schedule: "off-schedule/#{technician_id}/#{as_of}"
      }

      packets = {}
      subjects.each do |name, subject|
        packet = @backend.read(subject: subject, as_of: as_of)
        return missing_fact(subject, as_of) unless packet

        packets[name] = packet
      end

      packets.merge(status: "ok", packets: packets.values)
    end

    def missing_fact(subject, as_of)
      failure(
        "tbackend.fact_missing",
        "required fact was not visible at as_of",
        context: { subject: subject, as_of: as_of }
      )
    end

    def failure(reason_code, message, context: {})
      packet = ObsPacket.new(
        kind: "failure_observation",
        subject: "runtime-machine/#{@machine_id}/failure",
        payload: {
          reason_code: reason_code,
          status: "blocked",
          message: message,
          context: context
        },
        temporal: { as_of: context[:as_of] },
        links: evidence_links
      )
      @backend.append(packet)
      @state = "loaded" if @state == "evaluating"
      { status: "blocked", reason_code: reason_code, packet: packet }
    end

    def observed_under_axiom
      [link("observed_under", @axiom_descriptor_ref)]
    end

    def observed_under_runtime
      observed_under_axiom + [link("observed_under", @runtime_contract_ref)]
    end

    def observed_under_runtime_backend
      observed_under_runtime + [link("observed_under", @tbackend_descriptor_ref)]
    end

    def link(rel, ref, required: true)
      { rel: rel, ref: ref, required: required }
    end
  end

  class CompatibilityChecker
    def initialize(machine:, image:, requested_as_of:, intent:)
      @machine = machine
      @image = Canonical.normalize(image)
      @requested_as_of = requested_as_of
      @intent = intent
    end

    def call
      checks = [
        check("axiom", @image.fetch("axiom_descriptor_ref"), @machine.axiom_descriptor_ref, "blocked"),
        check("runtime", @image.fetch("runtime_contract_ref"), @machine.runtime_contract_ref, "downgrade"),
        check("backend", @image.fetch("backend_descriptor_hash"), Canonical.hash(@machine.backend.describe), "blocked"),
        check(
          "contract",
          @image.fetch("compiled_graph_hash"),
          @machine.loaded_unit&.fetch(:compiled_graph_hash, nil),
          "blocked"
        ),
        check("temporal", @image.fetch("temporal_horizon").fetch("as_of"), @requested_as_of, "blocked"),
        snapshot_check,
        replay_check,
        schema_check    # PROP-017: 4th CompatibilityReport dimension
      ]
      status = resume_status(checks)

      Canonical.normalize(
        report_id: "compat/#{Canonical.short_hash(checks)}",
        image_id: @image.fetch("image_id"),
        intent: @intent,
        checks: checks,
        resume_status: status,
        reproducibility: status == "trusted" ? "reproducible_within_memory_harness" : status
      )
    end

    private

    def check(dimension, expected, actual, mismatch_outcome)
      outcome = expected == actual ? "compatible" : mismatch_outcome
      {
        dimension: dimension,
        outcome: outcome,
        expected: expected,
        actual: actual,
        severity: severity_for(outcome)
      }
    end

    def snapshot_check
      checkpoint = @image.fetch("checkpoint")
      available = @machine.backend.snapshot_available?(
        checkpoint.fetch("snapshot_ref"),
        checkpoint.fetch("snapshot_hash")
      )
      {
        dimension: "snapshot",
        outcome: available ? "compatible" : "blocked",
        expected: checkpoint.fetch("snapshot_ref"),
        actual: available ? checkpoint.fetch("snapshot_ref") : nil,
        severity: available ? "info" : "critical"
      }
    end

    def replay_check
      seq_id = @image.fetch("checkpoint").fetch("seq_id")
      available = @machine.backend.replay_available?(seq_id)
      {
        dimension: "replay",
        outcome: available ? "compatible" : "blocked",
        expected: "seq>=#{seq_id}",
        actual: "seq=#{@machine.backend.last_seq}",
        severity: available ? "info" : "critical"
      }
    end

    def severity_for(outcome)
      case outcome
      when "compatible" then "info"
      when "downgrade"  then "warning"
      when "provisional" then "warning"
      when "migrating"  then "warning"
      else "critical"
      end
    end

    # PROP-017: schema_check — 4th CompatibilityReport dimension.
    # Compares image.schema_fingerprint with the loaded unit schema descriptor.
    def schema_check
      image_ver         = @image.fetch("schema_version", "0.0.0")
      image_fingerprint = @image.fetch("schema_fingerprint", nil)

      # If SemanticImage has no schema fields (pre-PROP-017 harness image),
      # treat as trusted to preserve backward compat with existing specs.
      if image_fingerprint.nil?
        return {
          dimension:           "schema",
          outcome:             "compatible",
          expected:            "(pre-PROP-017 image: no fingerprint)",
          actual:              "(no fingerprint available)",
          severity:            "info",
          schema_version:      image_ver,
          fingerprint_match:   true,
          change_class:        "none",
          migration_available: false,
          decision:            "trusted"
        }
      end

      current_schema = @machine.loaded_schema_descriptor
      current_version = current_schema&.fetch("schema_version", "0.0.0") || "0.0.0"
      current_fingerprint = current_schema&.fetch("schema_fingerprint", nil)

      match = image_fingerprint == current_fingerprint

      if match
        outcome      = "compatible"
        change_class = "none"
        decision     = "trusted"
      else
        # Determine change class: breaking if major version differs, else safe
        old_major = image_ver.split(".").first.to_i
        new_major = current_version.split(".").first.to_i
        if new_major > old_major
          change_class = "breaking"
          outcome      = "blocked"
        else
          change_class = "safe"
          outcome      = "provisional"
        end

        # Check if a migration is available
        migrations = current_schema&.fetch("migrations", []) || []
        migration  = migrations.find { |m|
          m["from_version"] == image_ver && m["to_version"] == current_version
        }
        if migration
          outcome  = "migrating"
          decision = "migrating"
        else
          decision = change_class == "breaking" ? "blocked" : "provisional"
        end
      end

      {
        dimension:           "schema",
        outcome:             outcome,
        expected:            image_fingerprint,
        actual:              current_fingerprint,
        severity:            severity_for(outcome),
        schema_version:      { from: image_ver, to: current_version },
        fingerprint_match:   match,
        change_class:        match ? "none" : change_class,
        migration_available: !!(migrations&.any?),
        decision:            match ? "trusted" : decision
      }
    end

    def resume_status(checks)
      outcomes = checks.map { |check| check.fetch(:outcome) }
      return "blocked" if outcomes.include?("blocked")
      return "migrating" if outcomes.include?("migrating")
      return "downgraded" if outcomes.include?("downgrade")
      return "provisional" if outcomes.include?("provisional")

      "trusted"
    end
  end

  module Fixture
    module_function

    def seed(machine)
      facts = {
        "order/order/o-1" => { service: "install" },
        "technician-profile/tech/t-17" => { services: ["install"], zone: "north" },
        "schedule-slot/tech/t-17/#{PROOF_AS_OF}" => { occupied: false },
        "off-schedule/tech/t-17/#{PROOF_AS_OF}" => { disabled: false }
      }

      facts.each do |subject, payload|
        packet = machine.fact_packet(subject: subject, payload: payload, as_of: PROOF_AS_OF)
        machine.backend.append(packet, idempotency_key: packet.id)
      end
    end

    def horizon
      {
        as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION,
        fact_scope: {
          technician_id: "tech/t-17",
          order_id: "order/o-1"
        }
      }
    end
  end

  module EvidenceVerifier
    module_function

    def value_packet_status(packet)
      rels = packet.link_rels
      missing = []
      missing << "executed_by" unless rels.include?("executed_by")
      missing << "read_from" unless rels.count("read_from") >= 4
      missing << "observed_under" unless rels.count("observed_under") >= 3
      missing << "produced_in" unless rels.include?("produced_in")

      {
        status: missing.empty? ? "trusted" : "provisional",
        missing: missing
      }
    end
  end

  module FixtureArtifacts
    SCHEMA_VERSION = "runtime-machine-proof-packet-fixtures-v0"

    module_function

    def build(golden:, checks:, negative_reports:, negative_failures:, negative_evidence:)
      Canonical.normalize(
        schema_version: SCHEMA_VERSION,
        generated_by: "runtime_machine_memory_proof.rb",
        proof_as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION,
        obs_packets: obs_packets(golden),
        semantic_image: semantic_image(golden),
        compatibility_reports: compatibility_reports(golden, negative_reports),
        negative_evidence: negative_evidence.merge(failure_packets: negative_failures),
        result_summary: result_summary(golden, checks)
      )
    end

    def files(artifacts)
      {
        "obs_packets.golden.json" => {
          schema_version: SCHEMA_VERSION,
          artifact: "obs_packets",
          payload: artifacts.fetch("obs_packets")
        },
        "semantic_image.golden.json" => {
          schema_version: SCHEMA_VERSION,
          artifact: "semantic_image",
          payload: artifacts.fetch("semantic_image")
        },
        "compatibility_reports.golden.json" => {
          schema_version: SCHEMA_VERSION,
          artifact: "compatibility_reports",
          payload: artifacts.fetch("compatibility_reports")
        },
        "negative_evidence.golden.json" => {
          schema_version: SCHEMA_VERSION,
          artifact: "negative_evidence",
          payload: artifacts.fetch("negative_evidence")
        },
        "result_summary.golden.json" => {
          schema_version: SCHEMA_VERSION,
          artifact: "result_summary",
          payload: artifacts.fetch("result_summary")
        }
      }
    end

    def obs_packets(golden)
      {
        sessions: {
          session_a: golden.fetch(:session_a_entries).map { |entry| entry_to_h(entry) },
          session_b: golden.fetch(:session_b_entries).map { |entry| entry_to_h(entry) }
        },
        selected: {
          dispatch_candidate_value: golden.fetch(:value_packet).to_h,
          resumed_dispatch_candidate_value: golden.fetch(:resumed_value_packet).to_h,
          semantic_image_packet: golden.fetch(:semantic_image_packet).to_h,
          trusted_compatibility_report_packet: golden.fetch(:compatibility_packet).to_h
        }
      }
    end

    def semantic_image(golden)
      {
        semantic_image: golden.fetch(:semantic_image),
        semantic_image_packet: golden.fetch(:semantic_image_packet).to_h,
        checkpoint_receipt: golden.fetch(:checkpoint_receipt).to_h
      }
    end

    def compatibility_reports(golden, negative_reports)
      {
        trusted_resume: golden.fetch(:compatibility_report),
        blocked_empty_backend_resume: negative_reports.fetch("empty_backend_resume"),
        downgraded_runtime_drift: negative_reports.fetch("runtime_drift"),
        blocked_contract_drift: negative_reports.fetch("contract_drift"),
        provisional_schema_drift: negative_reports.fetch("schema_drift")
      }
    end

    def result_summary(golden, checks)
      {
        proof_name: "runtime_machine_memory_proof",
        pass: checks.all? { |check| check.fetch(:ok) },
        checks: checks,
        result_hash: golden.fetch(:result_hash),
        resumed_result_hash: golden.fetch(:resumed_result_hash),
        same_result_hash: golden.fetch(:result_hash) == golden.fetch(:resumed_result_hash),
        evidence_status: golden.fetch(:evidence_status)
      }
    end

    def entry_to_h(entry)
      {
        seq_id: entry.fetch(:seq_id),
        transaction_time: entry.fetch(:transaction_time),
        packet: entry.fetch(:packet).to_h
      }
    end
  end

  module FixtureFiles
    DEFAULT_DIR = File.expand_path("fixtures", __dir__)

    module_function

    def write(dir, artifacts)
      FileUtils.mkdir_p(dir)
      files = rendered_files(artifacts)

      files.each do |name, content|
        File.write(File.join(dir, name), content)
      end

      files
    end

    def verify(dir, artifacts)
      expected = rendered_files(artifacts)
      expected.filter_map do |name, content|
        path = File.join(dir, name)
        if !File.file?(path)
          { file: name, reason: "missing" }
        elsif File.read(path) != content
          { file: name, reason: "content_mismatch" }
        end
      end
    end

    def rendered_files(artifacts)
      payloads = FixtureArtifacts.files(artifacts)
      rendered = payloads.transform_values { |payload| json(payload) }
      rendered["manifest.json"] = json(manifest(rendered))
      rendered
    end

    def manifest(rendered_payloads)
      {
        schema_version: FixtureArtifacts::SCHEMA_VERSION,
        artifact: "manifest",
        files: rendered_payloads.keys.sort.map do |name|
          {
            path: name,
            content_hash: "sha256:#{Digest::SHA256.hexdigest(rendered_payloads.fetch(name))}"
          }
        end
      }
    end

    def json(value)
      "#{JSON.pretty_generate(Canonical.normalize(value))}\n"
    end
  end

  class ProofRunner
    attr_reader :artifacts

    def initialize
      @print_summary = true
      @checks = []
      @golden = nil
      @artifacts = nil
      @negative_reports = {}
      @negative_failures = {}
      @negative_evidence = {}
    end

    def run(print_summary: true)
      @print_summary = print_summary
      @golden = run_golden_path
      run_negative_ambient_time
      run_negative_empty_backend_resume
      run_negative_runtime_drift
      run_negative_contract_drift
      run_negative_schema_drift
      run_negative_value_without_evidence
      @artifacts = FixtureArtifacts.build(
        golden: @golden,
        checks: @checks,
        negative_reports: @negative_reports,
        negative_failures: @negative_failures,
        negative_evidence: @negative_evidence
      )
      print_summary_output if @print_summary
      success?
    end

    private

    def run_golden_path
      backend = MemoryTBackend.new
      machine_a = RuntimeMachine.new(
        machine_id: "runtime-machine/memory-proof-a",
        session_id: "session/a",
        backend: backend
      )
      contract = ToyDispatchContract.new

      boot = machine_a.boot
      check("golden.boot", boot.fetch(:status) == "ok")
      Fixture.seed(machine_a)

      load = machine_a.load(contract)
      check("golden.load", load.fetch(:status) == "ok" && load.fetch(:loaded_unit).fetch(:fragment_class) == "CORE")

      eval_a = machine_a.evaluate(
        order_id: "order/o-1",
        technician_id: "tech/t-17",
        as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION
      )
      check("golden.evaluate", eval_a.fetch(:status) == "ok" && eval_a.fetch(:payload).fetch(:available))

      checkpoint = machine_a.checkpoint(horizon: Fixture.horizon)
      check("golden.checkpoint", checkpoint.fetch(:status) == "ok")
      check(
        "golden.semantic_image_schema_descriptor",
        checkpoint.fetch(:semantic_image).fetch("schema_fingerprint") ==
          machine_a.loaded_schema_descriptor.fetch("schema_fingerprint") &&
          checkpoint.fetch(:semantic_image).fetch("schema_fingerprint") != "sha256:unknown"
      )

      restored_backend = backend.restore(checkpoint.fetch(:snapshot).fetch(:snapshot_ref))
      machine_b = RuntimeMachine.new(
        machine_id: "runtime-machine/memory-proof-b",
        session_id: "session/b",
        backend: restored_backend
      )
      machine_b.boot
      machine_b.load(contract)
      resume = machine_b.resume(
        image: checkpoint.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )
      check("golden.resume", resume.fetch(:status) == "trusted")
      schema_check = resume.fetch(:report).fetch("checks").find { |item| item.fetch("dimension") == "schema" }
      check(
        "golden.schema_check_trusted",
        schema_check.fetch("decision") == "trusted" &&
          schema_check.fetch("fingerprint_match") == true &&
          schema_check.fetch("actual") == checkpoint.fetch(:semantic_image).fetch("schema_fingerprint")
      )

      eval_b = machine_b.evaluate(
        order_id: "order/o-1",
        technician_id: "tech/t-17",
        as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION
      )
      check("golden.same_result_hash", eval_b.fetch(:result_hash) == eval_a.fetch(:result_hash))
      evidence = EvidenceVerifier.value_packet_status(eval_b.fetch(:value_packet))
      check("golden.evidence_links", evidence.fetch(:status) == "trusted")

      {
        backend: backend,
        contract: contract,
        session_a_entries: backend.entries.map(&:dup),
        session_b_entries: restored_backend.entries.map(&:dup),
        semantic_image: checkpoint.fetch(:semantic_image),
        semantic_image_packet: checkpoint.fetch(:semantic_image_packet),
        checkpoint_receipt: checkpoint.fetch(:receipt),
        compatibility_report: resume.fetch(:report),
        compatibility_packet: resume.fetch(:packet),
        result_hash: eval_a.fetch(:result_hash),
        resumed_result_hash: eval_b.fetch(:result_hash),
        result_payload: eval_a.fetch(:payload),
        value_packet: eval_a.fetch(:value_packet),
        resumed_value_packet: eval_b.fetch(:value_packet),
        evidence_status: evidence
      }
    end

    def run_negative_ambient_time
      backend = MemoryTBackend.new
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/negative-as-of",
        session_id: "session/negative-as-of",
        backend: backend
      )
      machine.boot
      Fixture.seed(machine)
      machine.load(ToyDispatchContract.new)
      result = machine.evaluate(
        order_id: "order/o-1",
        technician_id: "tech/t-17",
        as_of: nil,
        rule_version: RULE_VERSION
      )

      @negative_failures["ambient_time"] = result.fetch(:packet).to_h
      check("negative.ambient_time_blocked", result.fetch(:reason_code) == "temporal.as_of_missing")
    end

    def run_negative_empty_backend_resume
      backend = MemoryTBackend.new
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/negative-empty-backend",
        session_id: "session/negative-empty-backend",
        backend: backend
      )
      machine.boot
      machine.load(@golden.fetch(:contract))
      resume = machine.resume(
        image: @golden.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )

      @negative_reports["empty_backend_resume"] = resume.fetch(:report)
      check("negative.empty_backend_resume_blocked", resume.fetch(:status) == "blocked")
    end

    def run_negative_runtime_drift
      backend = @golden.fetch(:backend).restore(
        @golden.fetch(:semantic_image).fetch("checkpoint").fetch("snapshot_ref")
      )
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/negative-runtime-drift",
        session_id: "session/negative-runtime-drift",
        backend: backend,
        runtime_version: "proof-runtime-v2"
      )
      machine.boot
      machine.load(@golden.fetch(:contract))
      resume = machine.resume(
        image: @golden.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )

      @negative_reports["runtime_drift"] = resume.fetch(:report)
      check("negative.runtime_drift_downgraded", resume.fetch(:status) == "downgraded")
    end

    def run_negative_contract_drift
      backend = @golden.fetch(:backend).restore(
        @golden.fetch(:semantic_image).fetch("checkpoint").fetch("snapshot_ref")
      )
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/negative-contract-drift",
        session_id: "session/negative-contract-drift",
        backend: backend
      )
      machine.boot
      machine.load(ToyDispatchContract.new(graph_version: "toy-dispatch-contract-v2"))
      resume = machine.resume(
        image: @golden.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )

      @negative_reports["contract_drift"] = resume.fetch(:report)
      check("negative.contract_drift_blocked", resume.fetch(:status) == "blocked")
    end

    def run_negative_schema_drift
      backend = @golden.fetch(:backend).restore(
        @golden.fetch(:semantic_image).fetch("checkpoint").fetch("snapshot_ref")
      )
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/negative-schema-drift",
        session_id: "session/negative-schema-drift",
        backend: backend
      )
      machine.boot
      machine.load(ToyDispatchContract.new(schema_version: "0.1.0"))
      resume = machine.resume(
        image: @golden.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )
      schema_check = resume.fetch(:report).fetch("checks").find { |item| item.fetch("dimension") == "schema" }

      @negative_reports["schema_drift"] = resume.fetch(:report)
      check(
        "negative.schema_drift_provisional",
        resume.fetch(:status) == "provisional" &&
          schema_check.fetch("decision") == "provisional" &&
          schema_check.fetch("fingerprint_match") == false
      )
    end

    def run_negative_value_without_evidence
      fake = ObsPacket.new(
        kind: "value_observation",
        subject: "dispatch-candidate/order/o-1/tech/t-17",
        payload: @golden.fetch(:result_payload),
        temporal: { as_of: PROOF_AS_OF, rule_version: RULE_VERSION },
        links: []
      )
      evidence = EvidenceVerifier.value_packet_status(fake)

      @negative_evidence["same_value_without_evidence"] = {
        value_packet: fake.to_h,
        evidence_status: evidence,
        expected_result_hash: @golden.fetch(:result_hash)
      }
      check("negative.same_value_without_evidence", fake.payload_hash == @golden.fetch(:result_hash))
      check("negative.evidence_missing_provisional", evidence.fetch(:status) == "provisional")
    end

    def check(name, ok)
      @checks << { name: name, ok: ok }
    end

    def success?
      @checks.all? { |check| check.fetch(:ok) }
    end

    def print_summary_output
      puts "#{success? ? "PASS" : "FAIL"} runtime_machine_memory_proof"
      @checks.each do |check|
        puts "#{check.fetch(:name)}: #{check.fetch(:ok) ? "ok" : "fail"}"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift
  runner = RuntimeMachineMemoryProof::ProofRunner.new

  case command
  when "--write-fixtures"
    dir = ARGV.shift || RuntimeMachineMemoryProof::FixtureFiles::DEFAULT_DIR
    success = runner.run(print_summary: false)
    RuntimeMachineMemoryProof::FixtureFiles.write(dir, runner.artifacts) if success
    puts "WROTE runtime_machine_memory_proof_fixtures #{dir}" if success
    exit(success ? 0 : 1)
  when "--verify-fixtures"
    dir = ARGV.shift || RuntimeMachineMemoryProof::FixtureFiles::DEFAULT_DIR
    success = runner.run(print_summary: false)
    mismatches = RuntimeMachineMemoryProof::FixtureFiles.verify(dir, runner.artifacts)
    if success && mismatches.empty?
      puts "PASS runtime_machine_memory_proof_fixtures"
      exit 0
    end

    puts "FAIL runtime_machine_memory_proof_fixtures"
    mismatches.each do |mismatch|
      puts "#{mismatch.fetch(:file)}: #{mismatch.fetch(:reason)}"
    end
    exit 1
  else
    success = runner.run
    exit(success ? 0 : 1)
  end
end

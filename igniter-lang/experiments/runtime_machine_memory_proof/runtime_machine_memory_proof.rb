#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "time"

require_relative "../temporal_access_runtime/temporal_access_runtime"

module RuntimeMachineMemoryProof
  PROOF_AS_OF = "2026-05-05T10:42:00Z"
  RULE_VERSION = "toy_dispatch@1"
  TemporalRuntime = IgniterLang::TemporalAccessRuntime

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

  class MemoryTemporalAccessAdapter
    attr_reader :capabilities

    def initialize(backend, capabilities: [TemporalRuntime::Capabilities::HISTORY_READ])
      @backend = backend
      @capabilities = capabilities
    end

    def supports_capability?(capability)
      @capabilities.include?(capability)
    end

    def read_as_of(subject, as_of)
      packet = @backend.read(subject: subject, as_of: as_of)
      result = packet ? TemporalRuntime::Option.some(packet.payload) : TemporalRuntime::Option.none
      observation = {
        "kind" => "runtime_machine_temporal_access_observation",
        "subject" => subject,
        "as_of" => as_of,
        "selected_append_ref" => packet&.id,
        "result" => result
      }
      observation["observation_id"] = "obs/runtime_temporal_access/#{TemporalRuntime::Canonical.short_hash(observation)}"
      [result, observation]
    end
  end

  class MissingReadAsOfTemporalAdapter
    attr_reader :capabilities

    def initialize
      @capabilities = [TemporalRuntime::Capabilities::HISTORY_READ]
    end

    def supports_capability?(capability)
      @capabilities.include?(capability)
    end
  end

  class ToyDispatchContract
    attr_reader :compiled_graph_hash

    def initialize(graph_version: "toy-dispatch-contract-v0", schema_version: "0.0.0", migrations: [])
      @graph_version = graph_version
      @schema_version = schema_version
      @migrations = Canonical.normalize(migrations)
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
            migrations: @migrations
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

  class TemporalDispatchContract
    attr_reader :compiled_graph_hash

    def initialize
      @compiled_graph_hash = Canonical.hash(descriptor_payload)
    end

    def contract_subject
      "contract/temporal-dispatch"
    end

    def fragment_subject
      "fragment/temporal-dispatch"
    end

    def fragment_class
      "ESCAPE"
    end

    def required_escapes
      ["history_read"]
    end

    def descriptor_payload
      {
        name: "TemporalDispatchContract",
        version: "temporal-dispatch-contract-v0",
        fragment_class: fragment_class,
        required_escapes: required_escapes,
        capabilities: [TemporalRuntime::Capabilities::HISTORY_READ],
        nodes: semantic_contract.fetch("nodes").map { |node| node.fetch("kind") },
        output: "Option[ScheduleSlot]"
      }
    end

    def schema_descriptor
      surface = {
        schema_version: "0.0.0",
        port_surface: [
          { dir: "in", name: "technician_id", type_tag: "String", lifecycle: "local", required: true },
          { dir: "in", name: "as_of", type_tag: "DateTime", lifecycle: "local", required: true },
          { dir: "out", name: "schedule_slot", type_tag: "Option[ScheduleSlot]", lifecycle: "session" }
        ],
        type_env: ["Option[ScheduleSlot]", "String", "DateTime"],
        trait_bounds: []
      }
      Canonical.normalize(surface.merge(schema_fingerprint: Canonical.hash(surface), migrations: []))
    end

    def runtime_requirements
      { "capabilities" => { "required_caps" => [TemporalRuntime::Capabilities::HISTORY_READ] } }
    end

    def semantic_contract
      {
        "kind" => "contract_ir",
        "contract_name" => "TemporalDispatchContract",
        "fragment_class" => "escape",
        "nodes" => [
          {
            "kind" => "temporal_input_node",
            "name" => "schedule_slot_history",
            "type" => { "constructor" => "History", "element_type" => "ScheduleSlot" },
            "axis" => "single",
            "store_ref" => "schedule-slot/{technician_id}/{as_of}",
            "as_of_ref" => "as_of",
            "fragment" => "escape",
            "required_caps" => [TemporalRuntime::Capabilities::HISTORY_READ]
          },
          {
            "kind" => "temporal_access_node",
            "name" => "schedule_slot_at",
            "source_ref" => "schedule_slot_history",
            "access" => "point",
            "time_ref" => "as_of",
            "result_type" => { "constructor" => "Option", "element_type" => "ScheduleSlot" },
            "fragment" => "escape",
            "evidence_policy" => "link_selected_append_observation"
          }
        ]
      }
    end
  end

  module TemporalRuntimeErrorShape
    module_function

    def from_load_check(load_check)
      check = load_check.fetch("checks", []).find { |candidate| candidate.fetch("status") == "blocked" } || {}
      if check.fetch("missing_capabilities", []).any?
        {
          "reason_code" => "temporal_access.missing_capability",
          "message" => "temporal access capability is unavailable",
          "capability" => check.fetch("missing_capabilities").first,
          "node" => check["node"],
          "axis" => check["axis"]
        }
      elsif check.fetch("missing_backend_methods", []).any?
        {
          "reason_code" => "temporal_access.backend_contract_missing",
          "message" => "temporal backend adapter is missing required method",
          "backend_method" => check.fetch("missing_backend_methods").first,
          "node" => check["node"],
          "axis" => check["axis"]
        }
      elsif check.fetch("missing_declared_capabilities", []).any?
        {
          "reason_code" => "temporal_access.missing_declared_capability",
          "message" => "contract requirements do not declare temporal access capability",
          "capability" => check.fetch("missing_declared_capabilities").first,
          "node" => check["node"],
          "axis" => check["axis"]
        }
      else
        {
          "reason_code" => "temporal_access.hook_blocked",
          "message" => "temporal access hook load check blocked",
          "node" => check["node"],
          "axis" => check["axis"]
        }
      end
    end

    def from_exception(error, node:)
      case error
      when TemporalRuntime::CapabilityError
        {
          "reason_code" => "temporal_access.missing_capability",
          "message" => error.message,
          "capability" => error.capability,
          "node" => node
        }
      when TemporalRuntime::BackendContractError
        {
          "reason_code" => "temporal_access.backend_contract_missing",
          "message" => error.message,
          "backend_method" => error.method_name.to_s,
          "axis" => error.axis,
          "node" => node
        }
      else
        {
          "reason_code" => "temporal_access.evaluate_failed",
          "message" => error.message,
          "node" => node
        }
      end
    end
  end

  class RuntimeMachine
    attr_reader :machine_id, :session_id, :backend, :state, :loaded_unit
    attr_reader :loaded_schema_descriptor
    attr_reader :axiom_descriptor_ref, :runtime_contract_ref
    attr_reader :execution_environment_ref, :tbackend_descriptor_ref
    attr_reader :last_value_packet, :last_result_hash
    attr_reader :temporal_access_hook_check

    def initialize(machine_id:, session_id:, backend:, runtime_version: "proof-runtime-v1")
      @machine_id = machine_id
      @session_id = session_id
      @backend = backend
      @runtime_version = runtime_version
      @state = "unbooted"
      @loaded_unit = nil
      @loaded_schema_descriptor = nil
      @contract = nil
      @temporal_access_hook = nil
      @temporal_contract = nil
      @temporal_access_hook_check = nil
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

    def load(contract, temporal_backend: nil)
      return failure("runtime.invalid_transition", "load requires booted machine") unless %w[booted loaded].include?(@state)

      descriptor = packet(
        kind: "descriptor_observation",
        subject: contract.respond_to?(:contract_subject) ? contract.contract_subject : "contract/toy-dispatch",
        payload: contract.descriptor_payload.merge(compiled_graph_hash: contract.compiled_graph_hash),
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links
      )
      @backend.append(descriptor, idempotency_key: descriptor.id)

      fragment = packet(
        kind: "descriptor_observation",
        subject: contract.respond_to?(:fragment_subject) ? contract.fragment_subject : "fragment/toy-dispatch",
        payload: {
          fragment_class: contract.respond_to?(:fragment_class) ? contract.fragment_class : "CORE",
          required_escapes: contract.respond_to?(:required_escapes) ? contract.required_escapes : [],
          compiled_graph_hash: contract.compiled_graph_hash
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links + [link("describes", descriptor.id)]
      )
      @backend.append(fragment, idempotency_key: fragment.id)

      temporal_hook = nil
      temporal_hook_check = nil
      if contract.respond_to?(:semantic_contract)
        temporal_backend ||= MemoryTemporalAccessAdapter.new(@backend)
        temporal_hook = TemporalRuntime::RuntimeMachineHook.new(
          backend: temporal_backend,
          capabilities: temporal_backend.respond_to?(:capabilities) ? temporal_backend.capabilities : nil
        )
        temporal_hook_check = temporal_hook.load_check(
          contract: contract.semantic_contract,
          requirements: contract.respond_to?(:runtime_requirements) ? contract.runtime_requirements : {}
        )
        unless temporal_hook_check.fetch("status") == "ok"
          error_shape = TemporalRuntimeErrorShape.from_load_check(temporal_hook_check)
          return failure(
            error_shape.fetch("reason_code"),
            error_shape.fetch("message"),
            context: { error: error_shape, temporal_access_hook: temporal_hook_check, as_of: PROOF_AS_OF }
          )
        end
      end

      @loaded_schema_descriptor = schema_descriptor_for(contract)
      migration_descriptor_refs_by_id = emit_migration_descriptors(@loaded_schema_descriptor.fetch("migrations", []))
      migration_descriptor_refs = migration_descriptor_refs_by_id.values
      @loaded_unit = {
        unit_id: "loaded-unit/#{Canonical.short_hash(contract.descriptor_payload)}",
        contract_descriptor_ref: descriptor.id,
        fragment_descriptor_ref: fragment.id,
        compiled_graph_hash: contract.compiled_graph_hash,
        fragment_class: contract.respond_to?(:fragment_class) ? contract.fragment_class : "CORE",
        schema_version: @loaded_schema_descriptor.fetch("schema_version"),
        schema_fingerprint: @loaded_schema_descriptor.fetch("schema_fingerprint"),
        migration_descriptor_refs: migration_descriptor_refs,
        migration_descriptor_refs_by_id: migration_descriptor_refs_by_id
      }
      @loaded_unit[:temporal_access_hook] = temporal_hook_check if temporal_hook_check
      @contract = contract
      @temporal_access_hook = temporal_hook
      @temporal_contract = contract.semantic_contract if contract.respond_to?(:semantic_contract)
      @temporal_access_hook_check = temporal_hook_check

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/load",
        payload: {
          transition: "load",
          status: "ok",
          loaded_unit: @loaded_unit,
          migration_descriptor_refs: migration_descriptor_refs
        },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
        links: evidence_links + [link("describes", descriptor.id)]
      )
      @backend.append(receipt)

      @state = "loaded"
      { status: "ok", loaded_unit: @loaded_unit, receipt: receipt }
    end

    def emit_schema_migration_receipt(image:, report:, migration:, as_of:)
      return failure("runtime.invalid_transition", "schema migration receipt requires loaded machine") unless @state == "loaded"

      migration_id = migration.fetch("migration_id")
      intent = packet(
        kind: "intent_observation",
        subject: "#{migration_id}/intent",
        payload: {
          intent: "schema_migration",
          migration_id: migration_id,
          from_version: migration.fetch("from_version"),
          to_version: migration.fetch("to_version"),
          old_image_id: image.fetch("image_id"),
          old_schema_fingerprint: image.fetch("schema_fingerprint"),
          new_schema_fingerprint: @loaded_schema_descriptor.fetch("schema_fingerprint"),
          compatibility_report_id: report.fetch("report_id")
        },
        temporal: { as_of: as_of, lifecycle: "local" },
        links: evidence_links + [link("caused_by", image.fetch("image_id"))]
      )
      @backend.append(intent)

      receipt = packet(
        kind: "receipt_observation",
        subject: "#{migration_id}/receipt",
        payload: {
          transition: "schema_migration",
          status: "migrated",
          strategy: migration.fetch("strategy", "identity"),
          migration_id: migration_id,
          from_version: migration.fetch("from_version"),
          to_version: migration.fetch("to_version"),
          old_image_id: image.fetch("image_id"),
          old_schema_fingerprint: image.fetch("schema_fingerprint"),
          new_schema_fingerprint: @loaded_schema_descriptor.fetch("schema_fingerprint"),
          compatibility_report_id: report.fetch("report_id")
        },
        temporal: { as_of: as_of, lifecycle: "audit" },
        links: evidence_links +
          [link("caused_by", intent.id)] +
          [link("produced_by", migration_id)] +
          [link("replaces", image.fetch("image_id"))]
      )
      @backend.append(receipt)

      { status: "ok", intent: intent, receipt: receipt }
    end

    def emit_replacement_semantic_image(old_image:, migration_receipt:, as_of:)
      return failure("runtime.invalid_transition", "replacement SemanticImage requires loaded machine") unless @state == "loaded"

      observation_ids = @backend.entries.map { |entry| entry.fetch(:packet).id }
      receipt_id = migration_receipt.id
      migration_id = migration_receipt.payload.fetch("migration_id")
      migration_descriptor_ref = @loaded_unit.fetch(:migration_descriptor_refs_by_id, {}).fetch(migration_id, migration_id)
      schema_descriptor = schema_descriptor()
      image_base = old_image.merge(
        "session_id" => @session_id,
        "produced_at" => DeterministicClock.at_seq(@backend.last_seq + 1),
        "execution_environment_ref" => @execution_environment_ref,
        "contract_descriptor_ref" => @loaded_unit.fetch(:contract_descriptor_ref),
        "observation_count" => observation_ids.length,
        "observation_hash" => Canonical.hash(observation_ids),
        "receipt_refs" => observation_ids.select { |id| id.start_with?("obs/") },
        "schema_version" => schema_descriptor.fetch("schema_version"),
        "schema_fingerprint" => schema_descriptor.fetch("schema_fingerprint"),
        "migration_receipt_ref" => receipt_id,
        "replaces_image_id" => old_image.fetch("image_id"),
        "migration_chain" => []
      ).reject { |key, _| %w[image_id content_hash].include?(key) }
      image_id = "image/#{Canonical.short_hash(image_base)}"
      replacement_image = image_base.merge(
        "image_id" => image_id,
        "content_hash" => Canonical.hash(image_base)
      )

      image_packet = packet(
        kind: "platform_observation",
        subject: "semantic-image/#{@session_id}/replacement",
        payload: replacement_image,
        temporal: { as_of: as_of, lifecycle: "session" },
        links: evidence_links +
          [link("caused_by", receipt_id)] +
          [link("produced_by", migration_descriptor_ref)] +
          [link("replaces", old_image.fetch("image_id"))]
      )
      @backend.append(image_packet)

      { status: "ok", semantic_image: Canonical.normalize(replacement_image), packet: image_packet }
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

    def evaluate_temporal_access(node_name:, inputs:, as_of:, rule_version:)
      return failure("runtime.invalid_transition", "temporal access evaluate requires loaded machine") unless @state == "loaded"
      return failure("temporal_access.hook_missing", "temporal access hook is not loaded") unless @temporal_access_hook

      @state = "evaluating"
      access_node = @temporal_contract.fetch("nodes").find do |node|
        node.fetch("kind") == "temporal_access_node" && node.fetch("name") == node_name
      end
      return failure("temporal_access.node_missing", "temporal access node is not present", context: { node: node_name }) unless access_node

      temporal_inputs = @temporal_contract.fetch("nodes")
        .select { |node| node.fetch("kind") == "temporal_input_node" }
        .to_h { |node| [node.fetch("name"), node] }

      access_eval = @temporal_access_hook.evaluate(access_node, temporal_inputs: temporal_inputs, inputs: inputs)
      value = packet(
        kind: "value_observation",
        subject: "temporal-access/#{node_name}",
        payload: {
          temporal_access_loader: "TemporalAccessRuntime::RuntimeMachineHook",
          node: node_name,
          result: access_eval.fetch("result"),
          observation: access_eval.fetch("observation"),
          evidence_links: access_eval.fetch("evidence_links")
        },
        temporal: { as_of: as_of, rule_version: rule_version },
        links: evidence_links + access_eval.fetch("evidence_links").map do |link_payload|
          link(link_payload.fetch("rel"), link_payload.fetch("to"))
        end
      )
      @backend.append(value)

      receipt = packet(
        kind: "receipt_observation",
        subject: "runtime-machine/#{@machine_id}/temporal-access",
        payload: {
          transition: "evaluate_temporal_access",
          status: "ok",
          value_ref: value.id,
          result_hash: value.payload_hash,
          temporal_access_hook: @temporal_access_hook_check
        },
        temporal: { as_of: as_of, rule_version: rule_version },
        links: evidence_links + [link("caused_by", value.id)]
      )
      @backend.append(receipt)

      @state = "loaded"
      {
        status: "ok",
        temporal_access: access_eval,
        value_packet: value,
        result_hash: value.payload_hash,
        receipt: receipt
      }
    rescue TemporalRuntime::CapabilityError, TemporalRuntime::BackendContractError => e
      error_shape = TemporalRuntimeErrorShape.from_exception(e, node: node_name)
      failure(error_shape.fetch("reason_code"), error_shape.fetch("message"), context: { error: error_shape, as_of: as_of })
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

    def emit_migration_descriptors(migrations)
      migrations.each_with_object({}) do |migration, out|
        packet = packet(
          kind: "descriptor_observation",
          subject: migration.fetch("migration_id"),
          payload: migration.merge(
            "descriptor" => "MigrationDescriptor",
            "receipt_lifecycle" => "audit",
            "requires_replaces_link" => true
          ),
          temporal: { as_of: PROOF_AS_OF, lifecycle: "load" },
          links: evidence_links
        )
        @backend.append(packet, idempotency_key: packet.id)
        out[migration.fetch("migration_id")] = packet.id
      end
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
      migrations = current_schema&.fetch("migrations", []) || []
      migration = nil
      replacement_oof = replacement_image_oof

      if replacement_oof
        return {
          dimension:           "schema",
          outcome:             "blocked",
          expected:            image_fingerprint,
          actual:              current_fingerprint,
          severity:            "critical",
          schema_version:      { from: image_ver, to: current_version },
          fingerprint_match:   match,
          change_class:        "replacement_image_malformed",
          migration_available: false,
          migration_ref:       nil,
          decision:            "blocked",
          oof_code:            replacement_oof
        }
      end

      if replacement_image? && !match
        return {
          dimension:           "schema",
          outcome:             "blocked",
          expected:            image_fingerprint,
          actual:              current_fingerprint,
          severity:            "critical",
          schema_version:      { from: image_ver, to: current_version },
          fingerprint_match:   false,
          change_class:        "replacement_fingerprint_mismatch",
          migration_available: false,
          migration_ref:       nil,
          decision:            "blocked",
          oof_code:            "OOF-MR3"
        }
      end

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
        migration_available: !migration.nil?,
        migration_ref:       migration&.fetch("migration_id", nil),
        decision:            match ? "trusted" : decision
      }
    end

    def replacement_image?
      @image.key?("replaces_image_id") || @image.key?("migration_receipt_ref")
    end

    def replacement_image_oof
      return nil unless replacement_image?

      return "OOF-MR1" unless @image.fetch("replaces_image_id", nil).is_a?(String)
      return "OOF-MR1" unless @image.fetch("migration_receipt_ref", nil).is_a?(String)
      return "OOF-MR1" unless @image.fetch("migration_chain", nil).is_a?(Array)
      return "OOF-MR2" if @image.key?("fragment_report")

      nil
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

    def schema_migration(from_version:, to_version:)
      {
        "migration_id" => "migration://toy-dispatch/#{from_version}->#{to_version}",
        "contract_id" => "toy-dispatch",
        "from_version" => from_version,
        "to_version" => to_version,
        "fragment_class" => "ESCAPE",
        "strategy" => "identity_schema_migration",
        "lifecycle" => "audit"
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

    def build(golden:, checks:, negative_reports:, negative_failures:, negative_evidence:, migration_fixture:)
      Canonical.normalize(
        schema_version: SCHEMA_VERSION,
        generated_by: "runtime_machine_memory_proof.rb",
        proof_as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION,
        obs_packets: obs_packets(golden, migration_fixture),
        semantic_image: semantic_image(golden, migration_fixture),
        compatibility_reports: compatibility_reports(golden, negative_reports, migration_fixture),
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

    def obs_packets(golden, migration_fixture)
      {
        sessions: {
          session_a: golden.fetch(:session_a_entries).map { |entry| entry_to_h(entry) },
          session_b: golden.fetch(:session_b_entries).map { |entry| entry_to_h(entry) }
        },
        selected: {
          dispatch_candidate_value: golden.fetch(:value_packet).to_h,
          resumed_dispatch_candidate_value: golden.fetch(:resumed_value_packet).to_h,
          semantic_image_packet: golden.fetch(:semantic_image_packet).to_h,
          trusted_compatibility_report_packet: golden.fetch(:compatibility_packet).to_h,
          schema_migration_compatibility_report_packet: migration_fixture.fetch(:packet).to_h,
          schema_migration_intent: migration_fixture.fetch(:intent).to_h,
          schema_migration_receipt: migration_fixture.fetch(:receipt).to_h,
          replacement_semantic_image_packet: migration_fixture.fetch(:replacement_packet).to_h,
          replacement_trusted_compatibility_report_packet: migration_fixture.fetch(:replacement_report_packet).to_h
        }
      }
    end

    def semantic_image(golden, migration_fixture)
      {
        semantic_image: golden.fetch(:semantic_image),
        semantic_image_packet: golden.fetch(:semantic_image_packet).to_h,
        checkpoint_receipt: golden.fetch(:checkpoint_receipt).to_h,
        replacement_semantic_image: migration_fixture.fetch(:replacement_image),
        replacement_semantic_image_packet: migration_fixture.fetch(:replacement_packet).to_h
      }
    end

    def compatibility_reports(golden, negative_reports, migration_fixture)
      {
        trusted_resume: golden.fetch(:compatibility_report),
        blocked_empty_backend_resume: negative_reports.fetch("empty_backend_resume"),
        downgraded_runtime_drift: negative_reports.fetch("runtime_drift"),
        blocked_contract_drift: negative_reports.fetch("contract_drift"),
        provisional_schema_drift: negative_reports.fetch("schema_drift"),
        blocked_migration_replacement_wrong_fingerprint: negative_reports.fetch("migration_replacement_wrong_fingerprint"),
        migrating_schema_drift: migration_fixture.fetch(:report),
        trusted_after_migration_replacement: migration_fixture.fetch(:replacement_report)
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
      @migration_fixture = nil
    end

    def run(print_summary: true)
      @print_summary = print_summary
      @golden = run_golden_path
      run_temporal_access_hook_integration
      run_negative_ambient_time
      run_negative_empty_backend_resume
      run_negative_runtime_drift
      run_negative_contract_drift
      run_negative_schema_drift
      @migration_fixture = run_schema_migration_fixture
      run_negative_value_without_evidence
      @artifacts = FixtureArtifacts.build(
        golden: @golden,
        checks: @checks,
        negative_reports: @negative_reports,
        negative_failures: @negative_failures,
        negative_evidence: @negative_evidence,
        migration_fixture: @migration_fixture
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

    def run_temporal_access_hook_integration
      backend = MemoryTBackend.new
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/temporal-access",
        session_id: "session/temporal-access",
        backend: backend
      )
      contract = TemporalDispatchContract.new
      machine.boot
      Fixture.seed(machine)

      load = machine.load(contract)
      hook_check = load.fetch(:loaded_unit).fetch(:temporal_access_hook)
      eval = machine.evaluate_temporal_access(
        node_name: "schedule_slot_at",
        inputs: { "technician_id" => "tech/t-17", "as_of" => PROOF_AS_OF },
        as_of: PROOF_AS_OF,
        rule_version: RULE_VERSION
      )
      result = eval.dig(:temporal_access, "result")
      selected_ref = eval.dig(:temporal_access, "evidence_links", 0, "to")

      check(
        "temporal_access.load_hook_check",
        load.fetch(:status) == "ok" &&
          hook_check.fetch("status") == "ok" &&
          hook_check.fetch("checks").first.fetch("required_capabilities") == [TemporalRuntime::Capabilities::HISTORY_READ]
      )
      check(
        "temporal_access.resolver_hook_evaluate",
        eval.fetch(:status) == "ok" &&
          eval.fetch(:value_packet).payload.fetch("temporal_access_loader") == "TemporalAccessRuntime::RuntimeMachineHook" &&
          result.fetch("kind") == "some" &&
          result.dig("value", "occupied") == false
      )
      check(
        "temporal_access.evidence_link_selected_append",
        selected_ref.to_s.start_with?("obs/")
      )

      run_negative_temporal_missing_capability(contract)
      run_negative_temporal_missing_backend_method(contract)
    end

    def run_negative_temporal_missing_capability(contract)
      backend = MemoryTBackend.new
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/temporal-missing-capability",
        session_id: "session/temporal-missing-capability",
        backend: backend
      )
      machine.boot
      load = machine.load(
        contract,
        temporal_backend: MemoryTemporalAccessAdapter.new(backend, capabilities: [])
      )

      @negative_failures["temporal_missing_capability"] = load.fetch(:packet).to_h
      error = load.fetch(:packet).payload.fetch("context").fetch("error")
      check(
        "negative.temporal_missing_capability_blocked",
        load.fetch(:status) == "blocked" &&
          load.fetch(:reason_code) == "temporal_access.missing_capability" &&
          error.fetch("capability") == TemporalRuntime::Capabilities::HISTORY_READ
      )
    end

    def run_negative_temporal_missing_backend_method(contract)
      backend = MemoryTBackend.new
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/temporal-missing-backend-method",
        session_id: "session/temporal-missing-backend-method",
        backend: backend
      )
      machine.boot
      load = machine.load(contract, temporal_backend: MissingReadAsOfTemporalAdapter.new)

      @negative_failures["temporal_missing_backend_method"] = load.fetch(:packet).to_h
      error = load.fetch(:packet).payload.fetch("context").fetch("error")
      check(
        "negative.temporal_missing_backend_method_blocked",
        load.fetch(:status) == "blocked" &&
          load.fetch(:reason_code) == "temporal_access.backend_contract_missing" &&
          error.fetch("backend_method") == "read_as_of"
      )
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

    def run_schema_migration_fixture
      migration = Fixture.schema_migration(from_version: "0.0.0", to_version: "0.1.0")
      backend = @golden.fetch(:backend).restore(
        @golden.fetch(:semantic_image).fetch("checkpoint").fetch("snapshot_ref")
      )
      machine = RuntimeMachine.new(
        machine_id: "runtime-machine/schema-migration",
        session_id: "session/schema-migration",
        backend: backend
      )
      machine.boot
      load = machine.load(ToyDispatchContract.new(schema_version: "0.1.0", migrations: [migration]))
      resume = machine.resume(
        image: @golden.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )
      schema_check = resume.fetch(:report).fetch("checks").find { |item| item.fetch("dimension") == "schema" }
      migration_receipt = machine.emit_schema_migration_receipt(
        image: @golden.fetch(:semantic_image),
        report: resume.fetch(:report),
        migration: migration,
        as_of: PROOF_AS_OF
      )
      receipt_links = migration_receipt.fetch(:receipt).link_rels
      replacement_image = machine.emit_replacement_semantic_image(
        old_image: @golden.fetch(:semantic_image),
        migration_receipt: migration_receipt.fetch(:receipt),
        as_of: PROOF_AS_OF
      )
      replacement_links = replacement_image.fetch(:packet).link_rels
      replacement_resume = machine.resume(
        image: replacement_image.fetch(:semantic_image),
        requested_as_of: PROOF_AS_OF
      )
      replacement_schema_check = replacement_resume.fetch(:report).fetch("checks").find { |item| item.fetch("dimension") == "schema" }
      forged_replacement = forged_replacement_image_wrong_fingerprint(replacement_image.fetch(:semantic_image))
      forged_resume = machine.resume(
        image: forged_replacement,
        requested_as_of: PROOF_AS_OF
      )
      forged_schema_check = forged_resume.fetch(:report).fetch("checks").find { |item| item.fetch("dimension") == "schema" }

      check(
        "migration.schema_check_migrating",
        resume.fetch(:status) == "migrating" &&
          schema_check.fetch("decision") == "migrating" &&
          schema_check.fetch("migration_available") == true &&
          schema_check.fetch("migration_ref") == migration.fetch("migration_id")
      )
      check("migration.descriptor_loaded", load.fetch(:loaded_unit).fetch(:migration_descriptor_refs).any?)
      check(
        "migration.receipt_links",
        migration_receipt.fetch(:status) == "ok" &&
          receipt_links.include?("replaces") &&
          receipt_links.include?("caused_by") &&
          receipt_links.include?("produced_by")
      )
      check(
        "migration.P-1-replacement_migration_receipt_ref",
        replacement_image.fetch(:semantic_image).fetch("migration_receipt_ref") == migration_receipt.fetch(:receipt).id
      )
      check(
        "migration.P-2-replacement_replaces_image_id",
        replacement_image.fetch(:semantic_image).fetch("replaces_image_id") == @golden.fetch(:semantic_image).fetch("image_id")
      )
      check(
        "migration.P-3-packet_replaces_old_image",
        replacement_image.fetch(:packet).links.any? do |link|
          link.fetch("rel") == "replaces" &&
            link.fetch("ref") == @golden.fetch(:semantic_image).fetch("image_id")
        end
      )
      check(
        "migration.P-4-packet_caused_by_receipt",
        replacement_image.fetch(:packet).links.any? do |link|
          link.fetch("rel") == "caused_by" &&
            link.fetch("ref") == migration_receipt.fetch(:receipt).id
        end
      )
      check(
        "migration.P-5-packet_no_supersedes",
        !replacement_links.include?("supersedes")
      )
      check(
        "migration.P-6-replacement_schema_fingerprint_match",
        replacement_image.fetch(:semantic_image).fetch("schema_fingerprint") ==
          machine.loaded_schema_descriptor.fetch("schema_fingerprint")
      )
      check(
        "migration.P-7-replacement_schema_check_trusted",
        replacement_schema_check.fetch("decision") == "trusted"
      )
      check(
        "migration.P-8-replacement_report_trusted",
        replacement_resume.fetch(:status) == "trusted"
      )
      check(
        "migration.P-9-single_hop_migration_chain",
        replacement_image.fetch(:semantic_image).fetch("migration_chain") == []
      )
      check(
        "migration.P-10-OOF-MR3_wrong_fingerprint_blocked",
        forged_resume.fetch(:status) == "blocked" &&
          forged_schema_check.fetch("decision") == "blocked" &&
          forged_schema_check.fetch("oof_code") == "OOF-MR3"
      )
      check(
        "migration.replacement_image_links",
        replacement_image.fetch(:status) == "ok" &&
          replacement_links.include?("replaces") &&
          replacement_links.include?("caused_by") &&
          replacement_links.include?("produced_by") &&
          replacement_links.include?("produced_in") &&
          replacement_image.fetch(:semantic_image).fetch("migration_receipt_ref") == migration_receipt.fetch(:receipt).id &&
          replacement_image.fetch(:semantic_image).fetch("replaces_image_id") == @golden.fetch(:semantic_image).fetch("image_id")
      )
      check(
        "migration.replacement_image_schema",
        replacement_image.fetch(:semantic_image).fetch("image_id") != @golden.fetch(:semantic_image).fetch("image_id") &&
          replacement_image.fetch(:semantic_image).fetch("schema_version") == "0.1.0" &&
          replacement_image.fetch(:semantic_image).fetch("schema_fingerprint") ==
            machine.loaded_schema_descriptor.fetch("schema_fingerprint")
      )
      check(
        "migration.replacement_report_trusted",
        replacement_resume.fetch(:status) == "trusted" &&
          replacement_resume.fetch(:report).fetch("image_id") == replacement_image.fetch(:semantic_image).fetch("image_id") &&
          replacement_schema_check.fetch("decision") == "trusted" &&
          replacement_schema_check.fetch("fingerprint_match") == true &&
          replacement_schema_check.fetch("actual") == replacement_image.fetch(:semantic_image).fetch("schema_fingerprint")
      )

      @negative_reports["migration_replacement_wrong_fingerprint"] = forged_resume.fetch(:report)

      {
        report: resume.fetch(:report),
        packet: resume.fetch(:packet),
        migration: migration,
        intent: migration_receipt.fetch(:intent),
        receipt: migration_receipt.fetch(:receipt),
        replacement_image: replacement_image.fetch(:semantic_image),
        replacement_packet: replacement_image.fetch(:packet),
        replacement_report: replacement_resume.fetch(:report),
        replacement_report_packet: replacement_resume.fetch(:packet)
      }
    end

    def forged_replacement_image_wrong_fingerprint(image)
      image_base = image.merge(
        "schema_fingerprint" => "sha256:forged_wrong_schema_fingerprint"
      ).reject { |key, _| %w[image_id content_hash].include?(key) }
      image_id = "image/#{Canonical.short_hash(image_base)}"
      Canonical.normalize(
        image_base.merge(
          "image_id" => image_id,
          "content_hash" => Canonical.hash(image_base)
        )
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

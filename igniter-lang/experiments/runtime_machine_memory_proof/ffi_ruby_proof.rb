#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "runtime_machine_memory_proof"

# =============================================================================
# FFI Ruby Contractable Proof
# Proves PROP-012 §Contractable FFI call discipline against MemoryTBackend.
#
# Structure:
#   FFIRequirement  — typed declaration of an FFI boundary
#   CapabilityGate  — checks required caps against granted
#   FFIAdapter      — wraps a Ruby callable as a contractable ESCAPE call
#   RuntimeMachine  — extended with call_ffi(ffi_id, inputs)
# =============================================================================

module RuntimeMachineMemoryProof
  # ---------------------------------------------------------------------------
  # FFIRequirement: typed declaration of a Ruby host call boundary
  # ---------------------------------------------------------------------------
  class FFIRequirement
    attr_reader :ffi_id, :host_ref, :host_lang, :input_ports, :output_ports,
                :effects, :capabilities, :lifecycle, :failures, :audit

    def initialize(
      ffi_id:,
      host_ref:,
      host_lang: :ruby,
      input_ports: [],
      output_ports: [],
      effects: [],
      capabilities: [],
      lifecycle: "session",
      failures: [],
      audit: false
    )
      @ffi_id       = ffi_id
      @host_ref     = host_ref
      @host_lang    = host_lang
      @input_ports  = input_ports
      @output_ports = output_ports
      @effects      = effects.map(&:to_s)
      @capabilities = capabilities.map(&:to_s)
      @lifecycle    = lifecycle.to_s
      @failures     = failures.map(&:to_s)
      @audit        = audit
    end

    def receipt_lifecycle
      audit ? "audit" : lifecycle
    end

    def to_descriptor
      {
        ffi_id:        ffi_id,
        host_ref:      host_ref,
        host_lang:     host_lang.to_s,
        effects:       effects,
        capabilities:  capabilities,
        lifecycle:     lifecycle,
        failures:      failures,
        audit:         audit,
        fragment_class: "escape"
      }
    end
  end

  # ---------------------------------------------------------------------------
  # CapabilityGate: checks required capabilities against a granted set
  # ---------------------------------------------------------------------------
  class CapabilityGate
    def initialize(granted_caps = [])
      @granted = Set.new(granted_caps.map(&:to_s))
    end

    def check(required_caps)
      missing = required_caps.map(&:to_s).reject { |cap| @granted.include?(cap) }
      missing.empty? ? :granted : [:denied, missing]
    end

    def grant(cap)
      @granted.add(cap.to_s)
      self
    end

    def revoke(cap)
      @granted.delete(cap.to_s)
      self
    end

    def granted?(cap)
      @granted.include?(cap.to_s)
    end
  end

  # ---------------------------------------------------------------------------
  # FFIAdapter: wraps a Ruby callable as a contractable ESCAPE boundary
  # ---------------------------------------------------------------------------
  class FFIAdapter
    attr_reader :requirement

    def initialize(requirement, callable)
      @requirement = requirement
      @callable    = callable
    end

    # Call the FFI with the full PROP-012 discipline:
    # [1] intent_obs -> [2] capability check -> [3] host call -> [4] receipt/failure
    def call(inputs:, machine:, gate:)
      ffi = @requirement
      call_id = Canonical.short_hash({ ffi_id: ffi.ffi_id, inputs: inputs, ts: machine.backend.last_seq })

      # [1] intent_observation
      intent = machine.send(:packet,
        kind:     "intent_observation",
        subject:  "ffi://#{ffi.ffi_id}/intent",
        payload:  { ffi_id: ffi.ffi_id, host_ref: ffi.host_ref, inputs: Canonical.normalize(inputs), call_id: call_id },
        temporal: { as_of: PROOF_AS_OF, lifecycle: "local" },
        links:    machine.evidence_links
      )
      machine.backend.append(intent)

      # [2] capability check
      result = gate.check(ffi.capabilities)
      if result != :granted
        _, missing = result
        failure = machine.send(:packet,
          kind:     "failure_observation",
          subject:  "ffi://#{ffi.ffi_id}/failure",
          payload:  { reason_code: "capability.denied", ffi_id: ffi.ffi_id,
                      missing_caps: missing, call_id: call_id },
          temporal: { as_of: PROOF_AS_OF, lifecycle: "session" },
          links:    machine.evidence_links + [machine.send(:link, "caused_by", intent.id)]
        )
        machine.backend.append(failure)
        return { status: :denied, reason_code: "capability.denied", failure_obs: failure }
      end

      # [3] host call
      output = begin
        @callable.call(inputs)
      rescue => e
        host_failure = machine.send(:packet,
          kind:     "failure_observation",
          subject:  "ffi://#{ffi.ffi_id}/failure",
          payload:  { reason_code: "ffi.host_error", ffi_id: ffi.ffi_id,
                      error_class: e.class.name, error_message: e.message, call_id: call_id },
          temporal: { as_of: PROOF_AS_OF, lifecycle: "session" },
          links:    machine.evidence_links + [machine.send(:link, "caused_by", intent.id)]
        )
        machine.backend.append(host_failure)
        return { status: :host_error, reason_code: "ffi.host_error", failure_obs: host_failure }
      end

      # [4] receipt_observation
      receipt = machine.send(:packet,
        kind:     "receipt_observation",
        subject:  "ffi://#{ffi.ffi_id}/receipt",
        payload:  { ffi_id: ffi.ffi_id, host_ref: ffi.host_ref,
                    output: Canonical.normalize(output), call_id: call_id },
        temporal: { as_of: PROOF_AS_OF, lifecycle: ffi.receipt_lifecycle },
        links:    machine.evidence_links +
                  [machine.send(:link, "caused_by",   intent.id),
                   machine.send(:link, "produced_by", "ffi://#{ffi.ffi_id}")]
      )
      machine.backend.append(receipt)

      { status: :ok, output: output, intent_obs: intent, receipt_obs: receipt }
    end
  end

  # ---------------------------------------------------------------------------
  # RuntimeMachine extension: register and call FFI adapters
  # ---------------------------------------------------------------------------
  class RuntimeMachine
    def register_ffi(adapter)
      @ffi_registry ||= {}
      @ffi_registry[adapter.requirement.ffi_id] = adapter
    end

    def call_ffi(ffi_id, inputs, gate:)
      adapter = (@ffi_registry || {})[ffi_id]
      unless adapter
        return failure("ffi.not_registered", "No FFI registered for #{ffi_id}")
      end
      adapter.call(inputs: inputs, machine: self, gate: gate)
    end

    def ffi_descriptor_obs(adapter, as_of: PROOF_AS_OF)
      desc = send(:packet,
        kind:     "descriptor_observation",
        subject:  "ffi://#{adapter.requirement.ffi_id}",
        payload:  adapter.requirement.to_descriptor,
        temporal: { as_of: as_of, lifecycle: "load" },
        links:    evidence_links
      )
      backend.append(desc, idempotency_key: desc.id)
      desc
    end
  end

  # ---------------------------------------------------------------------------
  # Example Ruby host callables (test doubles — no real external calls)
  # ---------------------------------------------------------------------------
  module HostStubs
    # Read-only: looks up order data (ESCAPE, no capability required)
    OrderLookup = lambda do |inputs|
      order_id = inputs[:order_id] || inputs["order_id"]
      raise ArgumentError, "order_id required" unless order_id
      raise KeyError, "order not found: #{order_id}" if order_id == "not_found"

      { order_id: order_id, service: "install", status: "open" }
    end

    # Write: assigns a technician (ESCAPE + capability + audit receipt)
    AssignTechnician = lambda do |inputs|
      order_id      = inputs[:order_id]      || inputs["order_id"]
      technician_id = inputs[:technician_id] || inputs["technician_id"]
      raise ArgumentError, "order_id required"      unless order_id
      raise ArgumentError, "technician_id required" unless technician_id
      raise RuntimeError,  "conflict: already assigned" if technician_id == "t-conflict"

      { assignment_id: "asn-#{order_id}-#{technician_id}", status: "assigned" }
    end
  end

  # ---------------------------------------------------------------------------
  # FFI declarations matching PROP-012 examples
  # ---------------------------------------------------------------------------
  OrderLookupFFI = FFIRequirement.new(
    ffi_id:       "order_lookup",
    host_ref:     "SparkCRM::OrderLookup",
    effects:      [:read],
    capabilities: [],
    lifecycle:    "session",
    failures:     ["not_found", "permission_denied"],
    audit:        false
  )

  AssignTechnicianFFI = FFIRequirement.new(
    ffi_id:       "assign_technician",
    host_ref:     "SparkCRM::AssignTechnician",
    effects:      [:write],
    capabilities: ["dispatch_assign"],
    lifecycle:    "durable",
    failures:     ["conflict", "permission_denied"],
    audit:        true
  )
end

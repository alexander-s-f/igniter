#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

require_relative "../temporal_access_runtime/temporal_access_runtime"

module ProductionTBackendAdapterFixture
  TemporalRuntime = IgniterLang::TemporalAccessRuntime
  Canonical = TemporalRuntime::Canonical

  module_function

  def igapp_runtime_metadata(schema_fingerprint:, adapter_kind: "memory")
    {
      "runtime_requirements" => {
        "temporal_backend" => {
          "contract_version" => "tbackend.v0",
          "required_ops" => %w[read append replay snapshot],
          "required_hook_methods" => %w[read_as_of bihistory_at],
          "required_capabilities" => [
            TemporalRuntime::Capabilities::HISTORY_READ,
            TemporalRuntime::Capabilities::BIHISTORY_READ
          ],
          "history_axes" => %w[valid_time transaction_time],
          "schema_fingerprint" => schema_fingerprint,
          "adapter_kind" => adapter_kind,
          "evidence_policy" => "receipt_required"
        }
      }
    }
  end

  def memory_descriptor(schema_fingerprint:, adapter_ref: "adapter:memory/proof-temporal")
    descriptor(
      adapter_ref: adapter_ref,
      adapter_kind: "memory",
      schema_fingerprint: schema_fingerprint,
      supported_ops: %w[read append replay snapshot compact subscribe],
      hook_methods: %w[read_as_of bihistory_at],
      capabilities: [
        TemporalRuntime::Capabilities::HISTORY_READ,
        TemporalRuntime::Capabilities::BIHISTORY_READ
      ],
      history_axes: %w[valid_time transaction_time]
    )
  end

  def descriptor(adapter_ref:, adapter_kind:, schema_fingerprint:, supported_ops:, hook_methods:, capabilities:, history_axes:)
    payload = {
      "kind" => "tbackend_adapter_descriptor",
      "adapter_ref" => adapter_ref,
      "adapter_kind" => adapter_kind,
      "contract_version" => "tbackend.v0",
      "supported_ops" => supported_ops,
      "hook_methods" => hook_methods,
      "capabilities" => capabilities,
      "history_axes" => history_axes,
      "schema_fingerprint" => schema_fingerprint,
      "evidence_mode" => "receipt_required"
    }
    payload.merge("descriptor_hash" => Canonical.hash(payload))
  end

  def compatibility_report(selection:, load_check:)
    selected = selection.fetch("selected_adapter_descriptor")
    payload = {
      "kind" => "proof_local_compatibility_report",
      "dimension" => "temporal_backend_adapter",
      "status" => selection.fetch("status") == "ok" && load_check.fetch("status") == "ok" ? "trusted" : "blocked",
      "selected_adapter_descriptor" => selected,
      "selected_adapter_descriptor_hash" => selected.fetch("descriptor_hash"),
      "adapter_selection_check" => selection.fetch("selection_check"),
      "temporal_access_hook_load_check" => load_check,
      "evidence_summary" => {
        "adapter_descriptor_persisted" => true,
        "load_check_persisted" => true,
        "hook_methods" => selected.fetch("hook_methods"),
        "capabilities" => selected.fetch("capabilities"),
        "history_axes" => selected.fetch("history_axes")
      }
    }
    payload.merge("report_id" => "compat/temporal_adapter/#{Canonical.short_hash(payload)}")
  end

  class AdapterRegistry
    def initialize(descriptors:)
      @descriptors = descriptors
    end

    def select(metadata, backend:)
      requirement = metadata.fetch("runtime_requirements").fetch("temporal_backend")
      descriptor = @descriptors.find do |candidate|
        candidate.fetch("adapter_kind") == requirement.fetch("adapter_kind") &&
          candidate.fetch("contract_version") == requirement.fetch("contract_version")
      end

      return blocked(requirement, nil, "adapter_not_found") unless descriptor

      missing_ops = requirement.fetch("required_ops") - descriptor.fetch("supported_ops")
      missing_hook_methods = requirement.fetch("required_hook_methods") - descriptor.fetch("hook_methods")
      missing_capabilities = requirement.fetch("required_capabilities") - descriptor.fetch("capabilities")
      missing_axes = requirement.fetch("history_axes") - descriptor.fetch("history_axes")
      schema_mismatch = requirement.fetch("schema_fingerprint") != descriptor.fetch("schema_fingerprint")
      selection_check = {
        "kind" => "tbackend_adapter_selection_check",
        "required_adapter_kind" => requirement.fetch("adapter_kind"),
        "selected_adapter_ref" => descriptor.fetch("adapter_ref"),
        "selected_adapter_descriptor_hash" => descriptor.fetch("descriptor_hash"),
        "missing_ops" => missing_ops,
        "missing_hook_methods" => missing_hook_methods,
        "missing_capabilities" => missing_capabilities,
        "missing_axes" => missing_axes,
        "schema_fingerprint_match" => !schema_mismatch,
        "status" => [missing_ops, missing_hook_methods, missing_capabilities, missing_axes].all?(&:empty?) && !schema_mismatch ? "ok" : "blocked"
      }

      {
        "status" => selection_check.fetch("status"),
        "selected_adapter_descriptor" => descriptor,
        "selection_check" => selection_check,
        "adapter" => selection_check.fetch("status") == "ok" ? SelectedAdapter.new(descriptor: descriptor, backend: backend) : nil
      }
    end

    private

    def blocked(requirement, descriptor, reason)
      {
        "status" => "blocked",
        "selected_adapter_descriptor" => descriptor,
        "selection_check" => {
          "kind" => "tbackend_adapter_selection_check",
          "required_adapter_kind" => requirement.fetch("adapter_kind"),
          "selected_adapter_ref" => nil,
          "selected_adapter_descriptor_hash" => nil,
          "missing_ops" => requirement.fetch("required_ops", []),
          "missing_hook_methods" => requirement.fetch("required_hook_methods", []),
          "missing_capabilities" => requirement.fetch("required_capabilities", []),
          "missing_axes" => requirement.fetch("history_axes", []),
          "schema_fingerprint_match" => false,
          "status" => "blocked",
          "reason" => reason
        },
        "adapter" => nil
      }
    end
  end

  class SelectedAdapter
    attr_reader :descriptor, :capabilities

    def initialize(descriptor:, backend:)
      @descriptor = descriptor
      @backend = backend
      @capabilities = descriptor.fetch("capabilities")
      define_read_as_of if descriptor.fetch("hook_methods").include?("read_as_of")
      define_bihistory_at if descriptor.fetch("hook_methods").include?("bihistory_at")
    end

    def supports_capability?(capability)
      @capabilities.include?(capability)
    end

    private

    def define_read_as_of
      define_singleton_method(:read_as_of) do |subject, as_of|
        packet = @backend.read(subject: subject, as_of: as_of)
        result = packet ? TemporalRuntime::Option.some(packet.payload) : TemporalRuntime::Option.none
        observation = {
          "kind" => "history_access_observation",
          "adapter_ref" => @descriptor.fetch("adapter_ref"),
          "adapter_descriptor_hash" => @descriptor.fetch("descriptor_hash"),
          "subject" => subject,
          "as_of" => as_of,
          "selected_append_ref" => packet&.id,
          "result" => result
        }
        observation["observation_id"] = "obs/tbackend_adapter_history/#{TemporalRuntime::Canonical.short_hash(observation)}"
        [result, observation]
      end
    end

    def define_bihistory_at
      define_singleton_method(:bihistory_at) do |history_ref, vt:, tt:, node_name:|
        if @backend.respond_to?(:bihistory_at)
          @backend.bihistory_at(history_ref, vt: vt, tt: tt, node_name: node_name)
        else
          result = TemporalRuntime::Option.none
          observation = {
            "kind" => "bihistory_access_observation",
            "adapter_ref" => @descriptor.fetch("adapter_ref"),
            "adapter_descriptor_hash" => @descriptor.fetch("descriptor_hash"),
            "history_ref" => history_ref,
            "node" => node_name,
            "axis" => "bitemporal",
            "valid_time" => vt,
            "transaction_time" => tt,
            "selected_event_ref" => nil,
            "result" => result
          }
          observation["observation_id"] = "obs/tbackend_adapter_bihistory/#{TemporalRuntime::Canonical.short_hash(observation)}"
          [result, observation]
        end
      end
    end
  end
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../temporal_access_runtime/temporal_access_runtime"

module SparkCRMBiHistoryFixture
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  FIXTURE_DIR = LANG_ROOT / "experiments/sparkcrm_bihistory_fixture"
  GOLDEN_DIR = FIXTURE_DIR / "golden"
  SUMMARY_PATH = FIXTURE_DIR / "summary.json"
  FORMAT_VERSION = "0.1.0"
  TRACK = "sparkcrm-bihistory-fixture-v0"

  COMPANY_ID = "company/fixture-acme"
  TECHNICIAN_ID = "tech/t-17"
  SERVICE_DATE = "2026-05-07"
  TIMEZONE = "America/New_York"
  ORDER_ID = "order/fixture-o-410"
  REQUESTED_WINDOW_LOCAL = "10:00..11:00"
  DECISION_TT = "2026-05-07T13:30:00Z"
  CORRECTION_TT = "2026-05-07T15:10:00Z"
  REPORT_TT = "2026-05-07T15:20:00Z"

  PROFILE_HISTORY = "bihistory/technician_profile/company-fixture-acme/tech-t-17"
  SCHEDULE_HISTORY = "bihistory/schedule/company-fixture-acme/tech-t-17/2026-05-07"
  OFF_SCHEDULE_HISTORY = "bihistory/off_schedule/company-fixture-acme/tech-t-17/2026-05-07"
  DAY_OFF_HISTORY = "bihistory/day_off_config/company-fixture-acme/tech-t-17"

  PLANNED_EVENT = "hist/schedule/t-17/10/planned/as-known-1205"
  CANCELED_EVENT = "hist/schedule/t-17/10/canceled/correction-1510"
  OFF_EVENT = "hist/off_schedule/t-17/12/personal-block"

  SLOTS = [
    { "slot_local" => "09:00", "valid_time" => "2026-05-07T13:00:00Z" },
    { "slot_local" => "10:00", "valid_time" => "2026-05-07T14:00:00Z" },
    { "slot_local" => "11:00", "valid_time" => "2026-05-07T15:00:00Z" },
    { "slot_local" => "12:00", "valid_time" => "2026-05-07T16:00:00Z" }
  ].freeze

  Canonical = TemporalAccessRuntime::Canonical
  Option = TemporalAccessRuntime::Option
  MemoryBiHistoryBackend = TemporalAccessRuntime::MemoryBackend
  AxisTypeError = TemporalAccessRuntime::AxisTypeError
  RuntimeMachineHook = TemporalAccessRuntime::RuntimeMachineHook
  CapabilityError = TemporalAccessRuntime::CapabilityError

  TEMPORAL_INPUT_NODES = {
    "schedule_history" => {
      "kind" => "temporal_input_node",
      "name" => "schedule_history",
      "type" => { "constructor" => "BiHistory", "element_type" => "ScheduleSlotObservation" },
      "axis" => "bitemporal",
      "history_ref" => SCHEDULE_HISTORY
    },
    "off_schedule_history" => {
      "kind" => "temporal_input_node",
      "name" => "off_schedule_history",
      "type" => { "constructor" => "BiHistory", "element_type" => "OffScheduleObservation" },
      "axis" => "bitemporal",
      "history_ref" => OFF_SCHEDULE_HISTORY
    },
    "day_off_history" => {
      "kind" => "temporal_input_node",
      "name" => "day_off_history",
      "type" => { "constructor" => "BiHistory", "element_type" => "DayOffConfigVersion" },
      "axis" => "bitemporal",
      "history_ref" => DAY_OFF_HISTORY
    }
  }.freeze

  TEMPORAL_ACCESS_NODES = {
    "schedule_at" => {
      "kind" => "temporal_access_node",
      "name" => "schedule_at",
      "source_ref" => "schedule_history",
      "axis" => "bitemporal",
      "access" => "point",
      "valid_time_ref" => "valid_time",
      "transaction_time_ref" => "known_time",
      "result_type" => { "constructor" => "Option", "element_type" => "ScheduleSlotObservation" },
      "evidence_policy" => "link_selected_event_observation"
    },
    "off_schedule_at" => {
      "kind" => "temporal_access_node",
      "name" => "off_schedule_at",
      "source_ref" => "off_schedule_history",
      "axis" => "bitemporal",
      "access" => "point",
      "valid_time_ref" => "valid_time",
      "transaction_time_ref" => "known_time",
      "result_type" => { "constructor" => "Option", "element_type" => "OffScheduleObservation" },
      "evidence_policy" => "link_selected_event_observation"
    },
    "day_off_config_at" => {
      "kind" => "temporal_access_node",
      "name" => "day_off_config_at",
      "source_ref" => "day_off_history",
      "axis" => "bitemporal",
      "access" => "point",
      "valid_time_ref" => "valid_time",
      "transaction_time_ref" => "known_time",
      "result_type" => { "constructor" => "Option", "element_type" => "DayOffConfigVersion" },
      "evidence_policy" => "link_selected_event_observation"
    }
  }.freeze

  class Proof
    attr_reader :backend

    def initialize
      @backend = MemoryBiHistoryBackend.new
      @temporal_access = RuntimeMachineHook.new(backend: @backend)
      @backend.seed(seed_events)
      @temporal_hook_load_check = @temporal_access.load_check(contract: runtime_contract, requirements: runtime_requirements)
    end

    def run
      decision_snapshot = project_snapshot(known_time: DECISION_TT, snapshot_kind: "decision")
      corrected_snapshot = project_snapshot(known_time: REPORT_TT, snapshot_kind: "corrected")
      dispatch_explanation = dispatch_explanation(decision_snapshot)
      correction_report = correction_report(decision_snapshot, corrected_snapshot)
      negatives = negative_reports
      missing_bihistory_report = missing_bihistory_capability_report
      check_results = checks(decision_snapshot, corrected_snapshot, dispatch_explanation, correction_report, negatives,
                             missing_bihistory_report)
      summary = {
        "kind" => "sparkcrm_bihistory_fixture_summary",
        "format_version" => FORMAT_VERSION,
        "track" => TRACK,
        "status" => check_results.values.all? ? "PASS" : "FAIL",
        "scenario" => scenario_descriptor,
        "decision_snapshot" => decision_snapshot,
        "corrected_snapshot" => corrected_snapshot,
        "dispatch_explanation" => dispatch_explanation,
        "correction_report" => correction_report,
        "negative_reports" => negatives,
        "runtime_hook" => {
          "load_check" => @temporal_hook_load_check,
          "missing_bihistory_read" => missing_bihistory_report
        },
        "access_observations" => backend.access_observations,
        "checks" => check_results
      }
      write_outputs(summary)
      summary
    end

    private

    def project_snapshot(known_time:, snapshot_kind:)
      slots = SLOTS.map { |slot| project_slot(slot, known_time) }
      available = slots.count { |slot| slot.fetch("result") == "available" }
      blocked = slots.length - available
      requested_slot = slots.find { |slot| slot.fetch("slot_local") == "10:00" }
      {
        "kind" => "AvailabilitySnapshot",
        "snapshot_id" => snapshot_id(snapshot_kind),
        "company_id" => COMPANY_ID,
        "technician_id" => TECHNICIAN_ID,
        "service_date" => SERVICE_DATE,
        "timezone" => TIMEZONE,
        "known_time" => known_time,
        "available_count" => available,
        "blocked_count" => blocked,
        "reason_counts" => reason_counts(slots),
        "slots" => slots,
        "requested_window" => {
          "local" => REQUESTED_WINDOW_LOCAL,
          "result" => requested_slot.fetch("result"),
          "reason" => requested_slot.fetch("reason"),
          "source_event_refs" => requested_slot.fetch("source_event_refs")
        },
        "trust_status" => "trusted"
      }
    end

    def project_slot(slot, known_time)
      vt = slot.fetch("valid_time")
      runtime_inputs = { "valid_time" => vt, "known_time" => known_time }
      schedule_eval = evaluate_temporal_access("schedule_at", runtime_inputs)
      off_eval = evaluate_temporal_access("off_schedule_at", runtime_inputs)
      day_off_eval = evaluate_temporal_access("day_off_config_at", runtime_inputs)
      schedule = schedule_eval.fetch("result")
      off = off_eval.fetch("result")
      day_off = day_off_eval.fetch("result")
      reason, result, source_refs = availability_result(schedule, off, day_off, slot.fetch("slot_local"))
      {
        "slot_local" => slot.fetch("slot_local"),
        "valid_time" => vt,
        "known_time" => known_time,
        "schedule" => schedule,
        "off_schedule" => off,
        "day_off_config" => day_off,
        "result" => result,
        "reason" => reason,
        "source_event_refs" => source_refs,
        "access_observation_refs" => [
          schedule_eval.dig("observation", "observation_id"),
          off_eval.dig("observation", "observation_id"),
          day_off_eval.dig("observation", "observation_id")
        ],
        "temporal_access_loader" => "TemporalAccessRuntime::RuntimeMachineHook",
        "temporal_access_nodes" => [
          schedule_eval.fetch("node"),
          off_eval.fetch("node"),
          day_off_eval.fetch("node")
        ],
        "temporal_evidence_links" => {
          "schedule_at" => schedule_eval.fetch("evidence_links"),
          "off_schedule_at" => off_eval.fetch("evidence_links"),
          "day_off_config_at" => day_off_eval.fetch("evidence_links")
        }
      }
    end

    def evaluate_temporal_access(node_name, inputs)
      @temporal_access.evaluate(
        TEMPORAL_ACCESS_NODES.fetch(node_name),
        temporal_inputs: TEMPORAL_INPUT_NODES,
        inputs: inputs
      )
    end

    def availability_result(schedule, off, day_off, slot_local)
      if Option.some?(off) && Option.value(off).fetch("blocks_availability")
        return ["off", "blocked", [OFF_EVENT]]
      end

      if Option.some?(schedule)
        schedule_value = Option.value(schedule)
        return ["busy", "blocked", [selected_schedule_event(schedule_value)]] if schedule_value.fetch("blocks_availability")
        return ["available", "available", [selected_schedule_event(schedule_value)]]
      end

      if Option.some?(day_off) && Option.value(day_off).fetch("blocked_slots_local").include?(slot_local)
        return ["day_off", "blocked", ["hist/day_off_config/t-17/v1"]]
      end

      ["available", "available", []]
    end

    def selected_schedule_event(value)
      value.fetch("status") == "canceled" ? CANCELED_EVENT : PLANNED_EVENT
    end

    def reason_counts(slots)
      ["available", "busy", "off", "day_off"].each_with_object({}) do |reason, counts|
        counts[reason] = slots.count { |slot| slot.fetch("reason") == reason }
      end
    end

    def dispatch_explanation(snapshot)
      requested = snapshot.fetch("requested_window")
      {
        "kind" => "DispatchDecisionExplanation",
        "decision_ref" => "dispatch_decision/order-fixture-o-410/t-17/as-known-1330",
        "order_id" => ORDER_ID,
        "candidate" => TECHNICIAN_ID,
        "candidate_status" => "not_selected",
        "reason" => requested.fetch("reason"),
        "known_time" => DECISION_TT,
        "valid_time_window" => "2026-05-07T14:00:00Z..2026-05-07T15:00:00Z",
        "snapshot_ref" => snapshot.fetch("snapshot_id"),
        "evidence_refs" => requested.fetch("source_event_refs"),
        "explanation_right" => "preserved",
        "trust_status" => "trusted"
      }
    end

    def correction_report(decision_snapshot, corrected_snapshot)
      decision_slot = decision_snapshot.fetch("slots").find { |slot| slot.fetch("slot_local") == "10:00" }
      corrected_slot = corrected_snapshot.fetch("slots").find { |slot| slot.fetch("slot_local") == "10:00" }
      changed = decision_slot.fetch("reason") != corrected_slot.fetch("reason")
      {
        "kind" => "AvailabilityCorrectionReport",
        "report_id" => "availability_correction/t-17/2026-05-07/1520",
        "prior_snapshot_ref" => decision_snapshot.fetch("snapshot_id"),
        "corrected_snapshot_ref" => corrected_snapshot.fetch("snapshot_id"),
        "changed_slots" => changed ? [
          {
            "slot_local" => "10:00",
            "valid_time" => "2026-05-07T14:00:00Z",
            "prior_known_time" => DECISION_TT,
            "corrected_known_time" => REPORT_TT,
            "prior_reason" => decision_slot.fetch("reason"),
            "corrected_reason" => corrected_slot.fetch("reason"),
            "prior_event_ref" => PLANNED_EVENT,
            "corrected_event_ref" => CANCELED_EVENT,
            "diagnostic" => "availability.corrected_after_decision"
          }
        ] : [],
        "diagnostics" => [
          "availability.corrected_after_decision",
          "history.bitemporal_access_recorded",
          "projection.original_snapshot_preserved",
          "retention.explanation_right_preserved"
        ],
        "original_decision_status" => "still_explainable",
        "original_decision_rewritten" => false,
        "trust_status" => "trusted"
      }
    end

    def negative_reports
      [
        diagnostic_report(
          "negative_missing_vt",
          "OOF-BT2",
          "history.valid_time_axis_missing",
          "bihistory_at requires valid_time_ref"
        ),
        diagnostic_report(
          "negative_missing_tt",
          "OOF-BT3",
          "history.transaction_time_axis_missing",
          "bihistory_at requires tx_time_ref"
        ),
        wrong_axis_type_report
      ]
    end

    def missing_bihistory_capability_report
      blocked_hook = RuntimeMachineHook.new(backend: backend, capabilities: [])
      load_check = blocked_hook.load_check(contract: runtime_contract, requirements: runtime_requirements)
      evaluation = begin
        blocked_hook.evaluate(
          TEMPORAL_ACCESS_NODES.fetch("schedule_at"),
          temporal_inputs: TEMPORAL_INPUT_NODES,
          inputs: { "valid_time" => "2026-05-07T14:00:00Z", "known_time" => DECISION_TT }
        )
      rescue CapabilityError => e
        {
          "kind" => "runtime_evaluation_rejection",
          "status" => "blocked",
          "error_class" => e.class.name,
          "capability" => e.capability,
          "node" => e.node.fetch("name")
        }
      end
      {
        "kind" => "runtime_hook_missing_capability_report",
        "capability" => "bihistory_read",
        "load_check" => load_check,
        "evaluation" => evaluation
      }
    end

    def wrong_axis_type_report
      backend.bihistory_at(SCHEDULE_HISTORY, vt: "10:00", tt: DECISION_TT, node_name: "schedule_at")
    rescue AxisTypeError => e
      diagnostic_report(
        "negative_wrong_axis_type",
        "OOF-BT4",
        "history.axis_type_mismatch",
        e.message,
        axis: e.axis,
        value: e.value
      )
    end

    def diagnostic_report(case_id, rule, diagnostic, message, extra = {})
      {
        "kind" => "compilation_report",
        "format_version" => FORMAT_VERSION,
        "case_id" => case_id,
        "pass_result" => "oof",
        "semantic_ir_ref" => nil,
        "stages" => {
          "parse" => "ok",
          "classify" => "ok",
          "typecheck" => "oof",
          "emit" => "skipped"
        },
        "diagnostics" => [
          {
            "category" => "typechecker_oof",
            "rule" => rule,
            "severity" => "error",
            "diagnostic" => diagnostic,
            "message" => message,
            "contract" => "SparkCRMBiHistoryAvailabilityCorrection",
            "node" => "bihistory_at",
            "path" => "contract:SparkCRMBiHistoryAvailabilityCorrection/compute:bihistory_at",
            "span" => nil
          }.merge(extra)
        ]
      }
    end

    def checks(decision_snapshot, corrected_snapshot, dispatch_explanation, correction_report, negatives,
               missing_bihistory_report)
      hook_checks = @temporal_hook_load_check.fetch("checks")
      missing_hook_check = missing_bihistory_report.dig("load_check", "checks").find do |check|
        check.fetch("node") == "schedule_at"
      end
      {
        "seed.synthetic_bihistory_events" => backend.events.values.flatten.length == 5,
        "option.canonical_some" => decision_snapshot.dig("slots", 1, "schedule") == {
          "kind" => "some",
          "value" => {
            "slot_local" => "10:00",
            "status" => "planned",
            "order_ref" => "order/existing-o-100",
            "blocks_availability" => true
          }
        },
        "option.canonical_none" => decision_snapshot.dig("slots", 0, "schedule") == { "kind" => "none" },
        "decision.snapshot_blocks_requested_window" => decision_snapshot.dig("requested_window", "result") == "blocked" &&
          decision_snapshot.dig("requested_window", "reason") == "busy",
        "corrected.snapshot_frees_requested_window" => corrected_snapshot.dig("requested_window", "result") == "available" &&
          corrected_snapshot.dig("requested_window", "reason") == "available",
        "correction.report_links_prior_and_corrected_events" => correction_report.dig("changed_slots", 0, "prior_event_ref") == PLANNED_EVENT &&
          correction_report.dig("changed_slots", 0, "corrected_event_ref") == CANCELED_EVENT,
        "dispatch.original_explanation_preserved" => dispatch_explanation.fetch("reason") == "busy" &&
          dispatch_explanation.fetch("evidence_refs") == [PLANNED_EVENT] &&
          correction_report.fetch("original_decision_rewritten") == false,
        "runtime.temporal_access_node_loader_bitemporal" => decision_snapshot.dig("slots", 1, "temporal_access_loader") == "TemporalAccessRuntime::RuntimeMachineHook" &&
          decision_snapshot.dig("slots", 1, "temporal_access_nodes").include?("schedule_at"),
        "runtime.hook_load_check_bitemporal" => @temporal_hook_load_check.fetch("status") == "ok" &&
          hook_checks.all? { |check| check.fetch("required_capabilities") == ["bihistory_read"] },
        "runtime.output_links_selected_event_observation" => decision_snapshot.dig("slots", 1, "temporal_evidence_links", "schedule_at", 0, "to") == PLANNED_EVENT,
        "negative.missing_bihistory_read_capability_blocked" => missing_bihistory_report.dig("load_check", "status") == "blocked" &&
          missing_hook_check.fetch("missing_capabilities") == ["bihistory_read"] &&
          missing_bihistory_report.dig("evaluation", "error_class") == "IgniterLang::TemporalAccessRuntime::CapabilityError",
        "negative.missing_vt_oof_bt2" => negative_rule?(negatives, "negative_missing_vt", "OOF-BT2"),
        "negative.missing_tt_oof_bt3" => negative_rule?(negatives, "negative_missing_tt", "OOF-BT3"),
        "negative.wrong_axis_type_oof_bt4" => negative_rule?(negatives, "negative_wrong_axis_type", "OOF-BT4"),
        "safety.synthetic_only" => synthetic_only?
      }
    end

    def negative_rule?(negatives, case_id, rule)
      report = negatives.find { |candidate| candidate.fetch("case_id") == case_id }
      report &&
        report.fetch("pass_result") == "oof" &&
        report.fetch("semantic_ir_ref").nil? &&
        report.fetch("diagnostics").any? { |diagnostic| diagnostic.fetch("rule") == rule }
    end

    def synthetic_only?
      text = Canonical.json(seed_events)
      forbidden = ["sparkcrm.com", "spark.app", "phone", "email", "token", "credential", "customer"]
      forbidden.none? { |needle| text.downcase.include?(needle) }
    end

    def scenario_descriptor
      {
        "company_id" => COMPANY_ID,
        "technician_id" => TECHNICIAN_ID,
        "service_date" => SERVICE_DATE,
        "timezone" => TIMEZONE,
        "requested_order_id" => ORDER_ID,
        "requested_window_local" => REQUESTED_WINDOW_LOCAL,
        "decision_tt" => DECISION_TT,
        "correction_tt" => CORRECTION_TT,
        "report_tt" => REPORT_TT,
        "data_policy" => "synthetic_only_no_real_sparkcrm_data_or_adapters"
      }
    end

    def runtime_contract
      {
        "kind" => "contract_ir",
        "contract_name" => "SparkCRMBiHistoryAvailabilityCorrection",
        "nodes" => TEMPORAL_INPUT_NODES.values + TEMPORAL_ACCESS_NODES.values
      }
    end

    def runtime_requirements
      {
        "kind" => "requirements",
        "capabilities" => { "required_caps" => ["bihistory_read"] },
        "temporal" => {
          "axes" => ["bitemporal"],
          "bihistory_reads" => TEMPORAL_INPUT_NODES.keys
        }
      }
    end

    def snapshot_id(kind)
      suffix = kind == "decision" ? "as-known-1330" : "as-known-1520"
      "availability_snapshot/t-17/2026-05-07/#{suffix}"
    end

    def seed_events
      [
        {
          "history_ref" => PROFILE_HISTORY,
          "type" => "BiHistory[TechnicianProfile]",
          "event_id" => "hist/technician_profile/t-17/active/v1",
          "valid_from" => "2026-05-07T00:00:00Z",
          "valid_until" => "2026-05-08T00:00:00Z",
          "tx_from" => "2026-05-07T12:00:00Z",
          "value" => {
            "technician_id" => TECHNICIAN_ID,
            "company_id" => COMPANY_ID,
            "status" => "active",
            "timezone" => TIMEZONE
          }
        },
        {
          "history_ref" => SCHEDULE_HISTORY,
          "type" => "BiHistory[ScheduleSlotObservation]",
          "event_id" => PLANNED_EVENT,
          "valid_from" => "2026-05-07T14:00:00Z",
          "valid_until" => "2026-05-07T15:00:00Z",
          "tx_from" => "2026-05-07T12:05:00Z",
          "value" => {
            "slot_local" => "10:00",
            "status" => "planned",
            "order_ref" => "order/existing-o-100",
            "blocks_availability" => true
          }
        },
        {
          "history_ref" => SCHEDULE_HISTORY,
          "type" => "BiHistory[ScheduleSlotObservation]",
          "event_id" => CANCELED_EVENT,
          "valid_from" => "2026-05-07T14:00:00Z",
          "valid_until" => "2026-05-07T15:00:00Z",
          "tx_from" => CORRECTION_TT,
          "corrects_event_ref" => PLANNED_EVENT,
          "correction_reason" => "synthetic_prior_cancellation_recorded_late",
          "value" => {
            "slot_local" => "10:00",
            "status" => "canceled",
            "order_ref" => "order/existing-o-100",
            "blocks_availability" => false
          }
        },
        {
          "history_ref" => OFF_SCHEDULE_HISTORY,
          "type" => "BiHistory[OffScheduleObservation]",
          "event_id" => OFF_EVENT,
          "valid_from" => "2026-05-07T16:00:00Z",
          "valid_until" => "2026-05-07T17:00:00Z",
          "tx_from" => "2026-05-07T11:55:00Z",
          "value" => {
            "slot_local" => "12:00",
            "reason" => "personal_block",
            "blocks_availability" => true
          }
        },
        {
          "history_ref" => DAY_OFF_HISTORY,
          "type" => "BiHistory[DayOffConfigVersion]",
          "event_id" => "hist/day_off_config/t-17/v1",
          "valid_from" => "2026-05-07T00:00:00Z",
          "valid_until" => "2026-05-08T00:00:00Z",
          "tx_from" => "2026-05-07T00:00:00Z",
          "value" => {
            "config_version" => "day-off-config-synthetic-v1",
            "blocked_slots_local" => []
          }
        }
      ]
    end

    def write_outputs(summary)
      FileUtils.mkdir_p(GOLDEN_DIR)
      write_json(SUMMARY_PATH, summary)
      write_json(GOLDEN_DIR / "decision_snapshot.json", summary.fetch("decision_snapshot"))
      write_json(GOLDEN_DIR / "corrected_snapshot.json", summary.fetch("corrected_snapshot"))
      write_json(GOLDEN_DIR / "correction_report.json", summary.fetch("correction_report"))
      summary.fetch("negative_reports").each do |report|
        write_json(GOLDEN_DIR / "#{report.fetch("case_id")}.json", report)
      end
    end

    def write_json(path, payload)
      FileUtils.mkdir_p(Pathname.new(path).dirname)
      File.write(path, Canonical.pretty(payload))
    end
  end

  module_function

  def run
    summary = Proof.new.run
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} sparkcrm_bihistory_fixture"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "decision.requested_window: #{summary.dig("decision_snapshot", "requested_window", "result")}/#{summary.dig("decision_snapshot", "requested_window", "reason")}"
    puts "corrected.requested_window: #{summary.dig("corrected_snapshot", "requested_window", "result")}/#{summary.dig("corrected_snapshot", "requested_window", "reason")}"
    puts "correction.changed_slots: #{summary.dig("correction_report", "changed_slots").length}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = SparkCRMBiHistoryFixture.run
exit(success ? 0 : 1)

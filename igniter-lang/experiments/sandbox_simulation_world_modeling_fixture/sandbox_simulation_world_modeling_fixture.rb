#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module SandboxSimulationWorldModelingFixture
  AS_OF = "2026-05-06T13:00:00Z"
  MODEL_ID = "world_model/spark-like-dispatch-capacity@0.1.0"
  ASSUMPTION_SET_ID = "assumptions/dispatch-capacity/synthetic-simple@1"
  BASELINE_PARAMS_ID = "params/dispatch-capacity/baseline@1"
  INTERVENTION_PARAMS_ID = "params/dispatch-capacity/add-one-technician@1"
  INTERVENTION_ID = "intervention/add-one-technician@1"
  BASELINE_SCENARIO_ID = "scenario/dispatch-capacity/baseline@1"
  INTERVENTION_SCENARIO_ID = "scenario/dispatch-capacity/add-one-technician@1"
  BASELINE_RUN_ID = "scenario_run/dispatch-capacity/baseline/20260507"
  INTERVENTION_RUN_ID = "scenario_run/dispatch-capacity/add-one-technician/20260507"
  HORIZON = "2026-05-07T09:00:00-04:00..2026-05-07T17:00:00-04:00"
  MAX_STEPS = 6
  RUNTIME_REF = "runtime/synthetic-fixture"
  SESSION_ID = "session/sandbox-simulation-world-modeling-fixture-v0"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value[key]) }
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

  class Proof
    def initialize
      @observations = []
    end

    def self.positive
      new.positive
    end

    def self.synthetic_as_real
      new.synthetic_as_real
    end

    def self.counterfactual_as_audit
      new.counterfactual_as_audit
    end

    def self.unbounded_loop
      new.unbounded_loop
    end

    def self.missing_randomness_policy
      new.missing_randomness_policy
    end

    def self.missing_calibration_evidence
      new.missing_calibration_evidence
    end

    def positive
      model_packet = emit_descriptor("WorldModel", MODEL_ID, world_model)
      assumptions_packet = emit_descriptor("AssumptionSet", ASSUMPTION_SET_ID, assumption_set)
      baseline_params_packet = emit_descriptor("ParameterSet", BASELINE_PARAMS_ID, baseline_params)
      intervention_params_packet = emit_descriptor("ParameterSet", INTERVENTION_PARAMS_ID, intervention_params)
      intervention_packet = emit_descriptor("Intervention", INTERVENTION_ID, intervention)

      baseline = scenario_run(
        scenario_run_id: BASELINE_RUN_ID,
        scenario_ref: BASELINE_SCENARIO_ID,
        parameter_set_ref: BASELINE_PARAMS_ID,
        technician_count: 1,
        observation_kind: "SyntheticObservation",
        intervention_ref: nil,
        evidence_refs: [model_packet, assumptions_packet, baseline_params_packet].map { |packet| packet.fetch("id") }
      )
      add_one = scenario_run(
        scenario_run_id: INTERVENTION_RUN_ID,
        scenario_ref: INTERVENTION_SCENARIO_ID,
        parameter_set_ref: INTERVENTION_PARAMS_ID,
        technician_count: 2,
        observation_kind: "CounterfactualObservation",
        intervention_ref: INTERVENTION_ID,
        evidence_refs: [model_packet, assumptions_packet, intervention_params_packet, intervention_packet].map { |packet| packet.fetch("id") }
      )
      comparison = comparison_report(baseline, add_one)
      validity = model_validity_report

      result("positive").merge(
        "world_model" => world_model,
        "assumption_set" => assumption_set,
        "baseline_parameter_set" => baseline_params,
        "intervention_parameter_set" => intervention_params,
        "intervention" => intervention,
        "baseline_run" => baseline,
        "intervention_run" => add_one,
        "comparison_report" => comparison,
        "model_validity_report" => validity
      )
    end

    def synthetic_as_real
      failure(
        "simulation.synthetic_observation_used_as_real",
        "SyntheticObservation cannot be declared as RealObservation",
        observation_ref: "synthetic/dispatch-capacity/baseline/j-001",
        declared_as: "RealObservation",
        comparison_report_status: "invalid"
      )
      result("synthetic_as_real")
    end

    def counterfactual_as_audit
      failure(
        "simulation.counterfactual_not_audit_fact",
        "CounterfactualObservation cannot prove actual execution",
        observation_ref: "counterfactual/dispatch-capacity/add-one-tech/j-002",
        linked_to: "operation_execution/real-world-placeholder",
        link_rel: "proves_actual_execution"
      )
      result("counterfactual_as_audit")
    end

    def unbounded_loop
      failure(
        "simulation.unbounded_loop_oof",
        "ScenarioRun requires a static max_steps bound",
        scenario_run_id: "scenario_run/unbounded",
        max_steps: nil,
        event_source: "live_stream",
        fragment_class: "OOF"
      )
      result("unbounded_loop")
    end

    def missing_randomness_policy
      failure(
        "simulation.randomness_policy_missing",
        "Stochastic simulation requires seed or sampling policy evidence",
        model_kind: "monte_carlo",
        sample_count: 1000,
        random_seed: nil,
        sampling_policy_ref: nil,
        fragment_class: "ESCAPE_or_OOF"
      )
      result("missing_randomness_policy")
    end

    def missing_calibration_evidence
      failure(
        "model_validity.calibration_evidence_missing",
        "ModelValidityReport cannot claim validated status without calibration evidence",
        calibration_evidence_refs: [],
        attempted_status: "validated",
        allowed_status: "unvalidated_synthetic"
      )
      result("missing_calibration_evidence")
    end

    private

    def world_model
      {
        "model_id" => MODEL_ID,
        "model_kind" => "deterministic_discrete_event",
        "modeled_system_boundary" => "synthetic_dispatch_capacity",
        "state_schema_ref" => "state_schema/dispatch-capacity@1",
        "event_schema_ref" => "event_schema/synthetic-job-request@1",
        "transition_rules_ref" => "transition_rules/slot_assignment@1",
        "allowed_observation_kinds" => ["SyntheticObservation", "CounterfactualObservation", "ForecastObservation"],
        "validity_policy_ref" => "model_validity_policy/sandbox-unvalidated@1"
      }
    end

    def assumption_set
      {
        "assumption_set_id" => ASSUMPTION_SET_ID,
        "model_ref" => MODEL_ID,
        "calibration_status" => "none_sandbox_unvalidated",
        "calibration_evidence_refs" => [],
        "assumptions" => [
          "all jobs have fixed two-hour duration",
          "all technicians are equally skilled",
          "travel time is ignored",
          "requesters accept any technician in the same slot",
          "demand events are deterministic and predeclared",
          "no cancellations occur"
        ],
        "invalidity_conditions" => [
          "travel time matters",
          "skills differ",
          "appointment windows are flexible",
          "demand distribution is calibrated from reality"
        ],
        "evidence_links" => []
      }
    end

    def baseline_params
      parameter_set(BASELINE_PARAMS_ID, 1)
    end

    def intervention_params
      parameter_set(INTERVENTION_PARAMS_ID, 2)
    end

    def parameter_set(parameter_set_id, technician_count)
      {
        "parameter_set_id" => parameter_set_id,
        "model_ref" => MODEL_ID,
        "parameters" => {
          "technician_count" => technician_count,
          "workday_slots" => workday_slots,
          "assignment_policy" => "first_available_technician"
        },
        "unit_policy" => {
          "technician_count" => "integer_count",
          "workday_slots" => "two_hour_local_slots"
        },
        "deterministic_seed" => "none",
        "randomness_policy_ref" => "not_applicable_deterministic"
      }
    end

    def intervention
      {
        "intervention_id" => INTERVENTION_ID,
        "kind" => "capacity_change",
        "target_parameter" => "technician_count",
        "from_value" => 1,
        "to_value" => 2,
        "do_not_confuse_with_observation" => true
      }
    end

    def workday_slots
      [
        "2026-05-07T09:00:00-04:00..2026-05-07T11:00:00-04:00",
        "2026-05-07T11:00:00-04:00..2026-05-07T13:00:00-04:00",
        "2026-05-07T13:00:00-04:00..2026-05-07T15:00:00-04:00",
        "2026-05-07T15:00:00-04:00..2026-05-07T17:00:00-04:00"
      ]
    end

    def events
      [
        job("j-001", workday_slots.fetch(0)),
        job("j-002", workday_slots.fetch(0)),
        job("j-003", workday_slots.fetch(1)),
        job("j-004", workday_slots.fetch(1)),
        job("j-005", workday_slots.fetch(2)),
        job("j-006", workday_slots.fetch(3))
      ]
    end

    def job(id, slot)
      { "event_id" => id, "requested_slot" => slot, "duration_slots" => 1 }
    end

    def scenario_run(scenario_run_id:, scenario_ref:, parameter_set_ref:, technician_count:, observation_kind:, intervention_ref:, evidence_refs:)
      slot_usage = Hash.new(0)
      event_observations = events.each_with_index.map do |event, index|
        used = slot_usage[event.fetch("requested_slot")]
        accepted = used < technician_count
        slot_usage[event.fetch("requested_slot")] += 1 if accepted
        emit_event_observation(scenario_run_id, event, index, technician_count, accepted, observation_kind)
      end
      summary = summarize(event_observations, technician_count)
      payload = {
        "kind" => "ScenarioRun",
        "scenario_run_id" => scenario_run_id,
        "scenario_ref" => scenario_ref,
        "world_model_ref" => MODEL_ID,
        "assumption_set_ref" => ASSUMPTION_SET_ID,
        "parameter_set_ref" => parameter_set_ref,
        "intervention_ref" => intervention_ref,
        "simulation_horizon" => HORIZON,
        "observation_kind" => observation_kind,
        "max_steps" => MAX_STEPS,
        "step_bound_source" => "deterministic_event_list.count",
        "event_count" => events.length,
        "status" => "completed",
        "summary" => summary,
        "event_observation_refs" => event_observations.map { |packet| packet.fetch("id") }
      }
      packet = obs(
        kind: "scenario_run_observation",
        subject: scenario_run_id,
        payload: payload,
        lifecycle: "session",
        links: evidence_refs.map { |ref| link("derived_from", ref) } + event_observations.map { |packet| link("emitted", packet.fetch("id")) }
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def emit_event_observation(scenario_run_id, event, index, technician_count, accepted, observation_kind)
      scenario_slug = scenario_run_id.split("/").fetch(2)
      obs_kind = observation_kind == "CounterfactualObservation" ? "counterfactual_observation" : "synthetic_observation"
      obs(
        kind: obs_kind,
        subject: "#{scenario_slug}/#{event.fetch("event_id")}",
        payload: {
          "kind" => observation_kind,
          "scenario_run_ref" => scenario_run_id,
          "step_index" => index,
          "event" => event,
          "technician_capacity" => technician_count,
          "outcome" => accepted ? "accepted" : "missed_capacity",
          "may_authorize_production_action" => false
        },
        lifecycle: "session",
        links: [link("produced_by", scenario_run_id), link("observed_under", RUNTIME_REF)]
      )
    end

    def summarize(event_observations, technician_count)
      outcomes = event_observations.map { |packet| packet.fetch("payload").fetch("outcome") }
      accepted = outcomes.count("accepted")
      missed = outcomes.count("missed_capacity")
      available_slots = workday_slots.length * technician_count
      {
        "accepted_job_count" => accepted,
        "missed_job_count" => missed,
        "conflict_count" => missed,
        "available_technician_slots" => available_slots,
        "used_technician_slots" => accepted,
        "technician_slot_utilization" => format_ratio(accepted, available_slots)
      }
    end

    def comparison_report(baseline, intervention_run)
      base = baseline.fetch("summary")
      changed = intervention_run.fetch("summary")
      payload = {
        "kind" => "ComparisonReport",
        "report_id" => "comparison/dispatch-capacity/baseline-vs-add-one-tech@1",
        "baseline_run_ref" => baseline.fetch("scenario_run_id"),
        "comparison_run_ref" => intervention_run.fetch("scenario_run_id"),
        "comparison_kind" => "counterfactual",
        "metrics" => {
          "accepted_job_count_delta" => changed.fetch("accepted_job_count") - base.fetch("accepted_job_count"),
          "missed_job_count_delta" => changed.fetch("missed_job_count") - base.fetch("missed_job_count"),
          "conflict_count_delta" => changed.fetch("conflict_count") - base.fetch("conflict_count"),
          "utilization_delta" => "-0.25"
        },
        "interpretation" => [
          "add-one-technician removes all synthetic capacity misses",
          "added capacity reduces utilization from 1.00 to 0.75",
          "result is strategy pressure, not action authority"
        ],
        "trust_status" => "synthetic_counterfactual",
        "may_authorize_production_action" => false
      }
      packet = obs(
        kind: "report_observation",
        subject: payload.fetch("report_id"),
        payload: payload,
        lifecycle: "session",
        links: [link("compares", baseline.fetch("obs_id")), link("compares", intervention_run.fetch("obs_id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def model_validity_report
      payload = {
        "kind" => "ModelValidityReport",
        "report_id" => "model_validity/dispatch-capacity/synthetic-simple@1",
        "world_model_ref" => MODEL_ID,
        "assumption_set_ref" => ASSUMPTION_SET_ID,
        "calibration_evidence_refs" => [],
        "validation_window" => nil,
        "status" => "unvalidated_synthetic",
        "allowed_uses" => ["language_fixture", "scenario_comparison_shape", "trust_boundary_pressure"],
        "forbidden_uses" => ["production_staffing_decision", "real_capacity_forecast", "personnel_claim"]
      }
      packet = obs(
        kind: "report_observation",
        subject: payload.fetch("report_id"),
        payload: payload,
        lifecycle: "session",
        links: [link("evaluates", MODEL_ID), link("evaluates", ASSUMPTION_SET_ID)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def emit_descriptor(kind_name, subject, payload)
      obs(
        kind: "descriptor_observation",
        subject: subject,
        payload: payload.merge("kind" => kind_name),
        lifecycle: "durable",
        links: [link("produced_in", SESSION_ID)]
      )
    end

    def failure(diagnostic, message, context = {})
      obs(
        kind: "failure_observation",
        subject: "simulation_failure/#{diagnostic}",
        payload: {
          "status" => "blocked",
          "diagnostic" => diagnostic,
          "message" => message,
          "context" => context
        },
        lifecycle: "session",
        links: [link("observed_under", RUNTIME_REF)]
      )
    end

    def format_ratio(numerator, denominator)
      format("%.2f", numerator.fdiv(denominator))
    end

    def result(case_name)
      {
        "case" => case_name,
        "observations" => Canonical.normalize(@observations)
      }
    end

    def obs(kind:, subject:, payload:, lifecycle:, links:)
      packet = {
        "id" => nil,
        "kind" => kind,
        "subject" => subject,
        "payload" => Canonical.normalize(payload),
        "payload_hash" => Canonical.hash(payload),
        "temporal" => { "as_of" => AS_OF, "lifecycle" => lifecycle },
        "links" => Canonical.normalize(links)
      }
      packet["id"] = "obs/#{Canonical.short_hash(packet.reject { |key, _| key == "id" })}"
      @observations << packet
      packet
    end

    def link(rel, ref)
      { "rel" => rel, "ref" => ref, "required" => true }
    end
  end

  module Checker
    module_function

    def call
      results = {
        "positive" => Proof.positive,
        "synthetic_as_real" => Proof.synthetic_as_real,
        "counterfactual_as_audit" => Proof.counterfactual_as_audit,
        "unbounded_loop" => Proof.unbounded_loop,
        "missing_randomness_policy" => Proof.missing_randomness_policy,
        "missing_calibration_evidence" => Proof.missing_calibration_evidence
      }
      checks = [
        check("positive.world_model_descriptor", world_model_descriptor?(results.fetch("positive"))),
        check("positive.assumption_calibration_explicit", assumption_calibration?(results.fetch("positive"))),
        check("positive.max_steps_bounded", max_steps_bounded?(results.fetch("positive"))),
        check("baseline.metrics", metrics?(results.fetch("positive").fetch("baseline_run"), accepted: 4, missed: 2, conflicts: 2, utilization: "1.00")),
        check("intervention.metrics", metrics?(results.fetch("positive").fetch("intervention_run"), accepted: 6, missed: 0, conflicts: 0, utilization: "0.75")),
        check("comparison.deltas", comparison_deltas?(results.fetch("positive").fetch("comparison_report"))),
        check("validity.unvalidated_synthetic", validity_unvalidated?(results.fetch("positive").fetch("model_validity_report"))),
        check("observation_kinds.not_real", no_real_observations?(results.fetch("positive"))),
        check("negative.synthetic_as_real_blocked", failure?(results.fetch("synthetic_as_real"), "simulation.synthetic_observation_used_as_real")),
        check("negative.counterfactual_audit_blocked", failure?(results.fetch("counterfactual_as_audit"), "simulation.counterfactual_not_audit_fact")),
        check("negative.unbounded_loop_blocked", failure?(results.fetch("unbounded_loop"), "simulation.unbounded_loop_oof", "fragment_class" => "OOF")),
        check("negative.randomness_policy_missing", failure?(results.fetch("missing_randomness_policy"), "simulation.randomness_policy_missing")),
        check("negative.calibration_missing", failure?(results.fetch("missing_calibration_evidence"), "model_validity.calibration_evidence_missing")),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def world_model_descriptor?(result)
      model = result.fetch("world_model")
      model.fetch("model_kind") == "deterministic_discrete_event" &&
        model.fetch("allowed_observation_kinds").sort == %w[CounterfactualObservation ForecastObservation SyntheticObservation]
    end

    def assumption_calibration?(result)
      assumptions = result.fetch("assumption_set")
      assumptions.fetch("calibration_status") == "none_sandbox_unvalidated" &&
        assumptions.fetch("calibration_evidence_refs").empty?
    end

    def max_steps_bounded?(result)
      [result.fetch("baseline_run"), result.fetch("intervention_run")].all? do |run|
        run.fetch("max_steps") == MAX_STEPS &&
          run.fetch("event_count") == MAX_STEPS &&
          run.fetch("step_bound_source") == "deterministic_event_list.count"
      end
    end

    def metrics?(run, accepted:, missed:, conflicts:, utilization:)
      summary = run.fetch("summary")
      summary.fetch("accepted_job_count") == accepted &&
        summary.fetch("missed_job_count") == missed &&
        summary.fetch("conflict_count") == conflicts &&
        summary.fetch("technician_slot_utilization") == utilization
    end

    def comparison_deltas?(report)
      metrics = report.fetch("metrics")
      metrics == {
        "accepted_job_count_delta" => 2,
        "conflict_count_delta" => -2,
        "missed_job_count_delta" => -2,
        "utilization_delta" => "-0.25"
      } &&
        report.fetch("trust_status") == "synthetic_counterfactual" &&
        report.fetch("may_authorize_production_action") == false
    end

    def validity_unvalidated?(report)
      report.fetch("status") == "unvalidated_synthetic" &&
        report.fetch("calibration_evidence_refs").empty? &&
        report.fetch("forbidden_uses").include?("production_staffing_decision") &&
        report.fetch("forbidden_uses").include?("real_capacity_forecast")
    end

    def no_real_observations?(result)
      observations = result.fetch("observations")
      observations.none? { |obs| JSON.generate(obs).include?("RealObservation") } &&
        observations.count { |obs| obs.fetch("kind") == "synthetic_observation" } == 6 &&
        observations.count { |obs| obs.fetch("kind") == "counterfactual_observation" } == 6
    end

    def failure?(result, diagnostic, context_match = {})
      result.fetch("observations").any? do |obs|
        next false unless obs.fetch("kind") == "failure_observation"
        payload = obs.fetch("payload")
        payload.fetch("diagnostic") == diagnostic &&
          payload.fetch("status") == "blocked" &&
          context_match.all? { |key, value| payload.fetch("context").fetch(key) == value }
      end
    end

    def synthetic_only?(results)
      text = JSON.generate(results)
      forbidden = %w[
        http://
        https://
        token
        secret
        password
        endpoint
        raw_provider_payload
        provider_config
        customer
        phone
        email
        production_order
        infrastructure
      ]
      forbidden.none? { |item| text.include?(item) }
    end

    def check(name, ok)
      { "name" => name, "ok" => ok }
    end
  end

  module CLI
    module_function

    def run(argv)
      result = Checker.call
      if argv.delete("--dump")
        puts JSON.pretty_generate(Canonical.normalize(result.fetch("results")))
        return true
      end
      print_result(result)
      result.fetch("checks").all? { |check| check.fetch("ok") }
    end

    def print_result(result)
      ok = result.fetch("checks").all? { |check| check.fetch("ok") }
      puts "#{ok ? "PASS" : "FAIL"} sandbox_simulation_world_modeling_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      baseline = positive.fetch("baseline_run").fetch("summary")
      intervention = positive.fetch("intervention_run").fetch("summary")
      deltas = positive.fetch("comparison_report").fetch("metrics")
      validity = positive.fetch("model_validity_report")
      puts "baseline: accepted=#{baseline.fetch("accepted_job_count")} missed=#{baseline.fetch("missed_job_count")} utilization=#{baseline.fetch("technician_slot_utilization")}"
      puts "intervention: accepted=#{intervention.fetch("accepted_job_count")} missed=#{intervention.fetch("missed_job_count")} utilization=#{intervention.fetch("technician_slot_utilization")}"
      puts "comparison: accepted_delta=#{deltas.fetch("accepted_job_count_delta")} missed_delta=#{deltas.fetch("missed_job_count_delta")}"
      puts "validity: #{validity.fetch("status")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = SandboxSimulationWorldModelingFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

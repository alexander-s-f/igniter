#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module SparkOperationActionLifecycleFixture
  AS_OF = "2026-05-06T13:00:00Z"
  COMPANY_ID = "company/fixture-acme"
  ACTOR_ID = "employee/tech-17"
  TECHNICIAN_ID = "tech/t-17"
  ORDER_ID = "order/fixture-o-200"
  SCHEDULE_ID = "schedule/fixture-s-200"
  SCHEMA_VERSION = "operation_action_schema@0.1.0"
  POLICY_VERSION = "appointment_policy@1"
  CONFIG_VERSION = "company_action_config@1"
  HORIZON = "2026-05-06T13:00:00Z..2026-05-06T13:30:00Z"
  CONTEXT_ID = "operation_context/company-fixture-acme/schedule-fixture-s-200/asof-20260506T130000Z"
  POLICY_ID = "action_policy/schedule-fixture-s-200/asof-20260506T130000Z"
  SOURCE = "employee_ui"
  SOURCE_REF = "source/fixture-ui-session-001"
  SESSION_ID = "session/spark-operation-action-lifecycle-fixture-v0"
  RUNTIME_REF = "runtime/synthetic-fixture"

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
    def initialize(bridge_capability: true)
      @bridge_capability = bridge_capability
      @observations = []
      @requests = []
      @executions = []
      @schedule = schedule_fact("planned")
      @policy_projection = nil
      @context_hash = nil
    end

    def self.positive
      new.positive
    end

    def self.policy_drift
      new.policy_drift
    end

    def self.unexpected_request_mutation
      new.unexpected_request_mutation
    end

    def self.missing_execution_receipt
      new.missing_execution_receipt
    end

    def self.no_op
      new.no_op
    end

    def self.bridge_capability_missing
      new(bridge_capability: false).bridge_capability_missing
    end

    def positive
      establish_context
      policy = build_action_policy_projection
      execution = execute_action("operation_intent/fixture/in-progress-001", "appointment_in_progress", "2026-05-06T13:05:00Z", policy)
      request = request_action("operation_intent/fixture/cancel-request-001", "appointment_cancel_request", "2026-05-06T13:10:00Z")
      duplicate = request_action("operation_intent/fixture/cancel-request-duplicate-001", "appointment_cancel_request", "2026-05-06T13:11:00Z")
      bridge = external_bridge(request.fetch("receipt_id"))
      result("positive").merge(
        "policy_projection" => policy,
        "execution_receipt" => execution,
        "request_receipt" => request,
        "duplicate_receipt" => duplicate,
        "external_bridge_receipt" => bridge
      )
    end

    def policy_drift
      establish_context
      policy = build_action_policy_projection
      @schedule = schedule_fact("canceled")
      receipt = execute_action("operation_intent/fixture/in-progress-policy-drift", "appointment_in_progress", "2026-05-06T13:12:00Z", policy)
      result("policy_drift").merge("policy_projection" => policy, "failure_receipt" => receipt)
    end

    def unexpected_request_mutation
      establish_context
      build_action_policy_projection
      receipt = request_action(
        "operation_intent/fixture/cancel-request-mutating",
        "appointment_cancel_request",
        "2026-05-06T13:10:00Z",
        forced_after_status: "canceled"
      )
      result("unexpected_request_mutation").merge("failure_receipt" => receipt)
    end

    def missing_execution_receipt
      establish_context
      before = @schedule
      after = schedule_fact("done")
      receipt = obs(
        kind: "failure_observation",
        subject: "operation_execution_missing_receipt/#{SCHEDULE_ID}",
        payload: {
          "kind" => "OperationFailure",
          "status" => "blocked",
          "diagnostic" => "operation_execution.receipt_missing_for_state_transition",
          "semantic_image_status" => "provisional_or_blocked",
          "before_state" => { "schedule_status" => before.fetch("status") },
          "after_state" => { "schedule_status" => after.fetch("status") },
          "schedule_status_changed" => true
        },
        lifecycle: "session",
        links: [link("about", SCHEDULE_ID), link("observed_under", RUNTIME_REF)]
      )
      result("missing_execution_receipt").merge("failure_receipt" => receipt)
    end

    def no_op
      establish_context
      @schedule = schedule_fact("in_progress")
      policy = build_action_policy_projection
      receipt = execute_action("operation_intent/fixture/in-progress-no-op", "appointment_in_progress", "2026-05-06T13:08:00Z", policy)
      result("no_op").merge("no_op_receipt" => receipt)
    end

    def bridge_capability_missing
      establish_context
      build_action_policy_projection
      request = request_action("operation_intent/fixture/cancel-request-001", "appointment_cancel_request", "2026-05-06T13:10:00Z")
      bridge = external_bridge(request.fetch("receipt_id"))
      result("bridge_capability_missing").merge("request_receipt" => request, "bridge_receipt" => bridge)
    end

    private

    def establish_context
      actor_obs = obs(kind: "fact_observation", subject: ACTOR_ID, payload: actor_fact, lifecycle: "durable", links: [link("scoped_to", COMPANY_ID)])
      order_obs = obs(kind: "fact_observation", subject: ORDER_ID, payload: order_fact, lifecycle: "durable", links: [link("scoped_to", COMPANY_ID)])
      schedule_obs = obs(kind: "fact_observation", subject: SCHEDULE_ID, payload: @schedule, lifecycle: "durable", links: [link("scoped_to", COMPANY_ID), link("about", ORDER_ID)])
      config_obs = obs(kind: "fact_observation", subject: "company_action_config/#{COMPANY_ID}/v1", payload: config_fact, lifecycle: "durable", links: [link("scoped_to", COMPANY_ID)])
      context = {
        "kind" => "OperationContext",
        "context_id" => CONTEXT_ID,
        "actor_ref" => ACTOR_ID,
        "company_ref" => COMPANY_ID,
        "order_ref" => ORDER_ID,
        "schedule_ref" => SCHEDULE_ID,
        "policy_version" => POLICY_VERSION,
        "action_config_version" => CONFIG_VERSION,
        "operation_horizon" => HORIZON,
        "as_of" => AS_OF,
        "source" => SOURCE,
        "source_ref" => SOURCE_REF,
        "evidence_refs" => [actor_obs.fetch("id"), order_obs.fetch("id"), schedule_obs.fetch("id"), config_obs.fetch("id")]
      }
      @context_hash = Canonical.hash(current_execution_context)
      obs(
        kind: "platform_observation",
        subject: CONTEXT_ID,
        payload: context.merge("context_hash" => @context_hash),
        lifecycle: "session",
        links: context.fetch("evidence_refs").map { |ref| link("derived_from", ref) } + [link("produced_in", SESSION_ID)]
      )
    end

    def build_action_policy_projection
      visible = [
        action("appointment_in_progress", "execution", true, "technician_owns_planned_appointment"),
        action("appointment_complete", "execution", true, "technician_can_manage_not_done_not_canceled_appointment"),
        action("appointment_cancel_request", "request", true, "technician_can_request_cancel_for_open_appointment"),
        action("operator_callback", "request", true, "technician_can_request_operator_callback")
      ]
      hidden = [action("appointment_dispute", "request", false, "action_disabled_or_schedule_not_disputable")]
      payload = {
        "kind" => "ActionPolicyProjection",
        "projection_id" => POLICY_ID,
        "context_ref" => CONTEXT_ID,
        "context_hash" => @context_hash,
        "visible_actions" => visible,
        "hidden_actions" => hidden,
        "visibility_is_authority" => false,
        "executable_authority_requires_fresh_check" => true
      }
      packet = obs(
        kind: "projection_observation",
        subject: POLICY_ID,
        payload: payload,
        lifecycle: "session",
        links: [link("computed_under", CONTEXT_ID), link("scoped_to", COMPANY_ID)]
      )
      @policy_projection = payload.merge("obs_id" => packet.fetch("id"))
    end

    def execute_action(intent_id, action_key, performed_at, policy)
      intent = operation_intent(intent_id, action_key, "execution", performed_at, policy_projection_ref: policy.fetch("obs_id"))
      return no_op_receipt(intent, policy) if action_key == "appointment_in_progress" && @schedule.fetch("status") == "in_progress"

      current_context_hash = Canonical.hash(current_execution_context)
      unless current_context_hash == policy.fetch("context_hash") && @schedule.fetch("status") == "planned"
        return operation_failure(
          "operation_action.policy_context_drift",
          "fresh OperationContext and executable check required",
          intent,
          schedule_status_changed: false,
          requires: ["fresh OperationContext", "fresh executable policy check"]
        )
      end

      check = executable_action_check(intent, current_context_hash)
      before_status = @schedule.fetch("status")
      @schedule = schedule_fact("in_progress")
      after_status = @schedule.fetch("status")
      receipt = {
        "kind" => "OperationExecutionReceipt",
        "receipt_id" => "operation_execution/fixture/exec-001",
        "action" => action_key,
        "action_kind" => "execution",
        "company_id" => COMPANY_ID,
        "subject_ref" => SCHEDULE_ID,
        "performed_by_ref" => ACTOR_ID,
        "performed_at" => performed_at,
        "source" => SOURCE,
        "source_ref" => SOURCE_REF,
        "before_state" => { "schedule_status" => before_status },
        "after_state" => { "schedule_status" => after_status },
        "result_payload_policy" => "redacted_business_summary",
        "operation_request_ref" => nil,
        "status" => "ok",
        "schedule_status_changed" => true
      }
      packet = obs(
        kind: "receipt_observation",
        subject: receipt.fetch("receipt_id"),
        payload: receipt,
        lifecycle: "audit",
        links: [
          link("caused_by", intent.fetch("obs_id")),
          link("checked_against", check.fetch("id")),
          link("mutated", SCHEDULE_ID)
        ]
      )
      @executions << receipt.merge("obs_id" => packet.fetch("id"))
      receipt.merge("obs_id" => packet.fetch("id"))
    end

    def request_action(intent_id, action_key, requested_at, forced_after_status: nil)
      intent = operation_intent(intent_id, action_key, "request", requested_at)
      before_status = @schedule.fetch("status")
      after_status = forced_after_status || before_status
      if after_status != before_status
        return operation_failure(
          "operation_request.unexpected_subject_mutation",
          "request action must not mutate schedule status",
          intent,
          request_created: false,
          execution_created: false
        )
      end

      duplicate = @requests.find do |request|
        request.fetch("action") == action_key &&
          request.fetch("subject_ref") == SCHEDULE_ID &&
          request.fetch("request_status") == "pending"
      end
      return duplicate_pending_receipt(intent, duplicate) if duplicate

      receipt = {
        "kind" => "OperationRequestReceipt",
        "receipt_id" => "operation_request/fixture/req-001",
        "action" => action_key,
        "action_kind" => "request",
        "company_id" => COMPANY_ID,
        "subject_ref" => SCHEDULE_ID,
        "requested_by_ref" => ACTOR_ID,
        "requested_at" => requested_at,
        "source" => SOURCE,
        "source_ref" => SOURCE_REF,
        "request_status" => "pending",
        "idempotency_scope" => {
          "subject_ref" => SCHEDULE_ID,
          "action" => action_key,
          "status" => "pending"
        },
        "schedule_status_changed" => false,
        "status" => "created"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: receipt.fetch("receipt_id"),
        payload: receipt,
        lifecycle: "audit",
        links: [link("caused_by", intent.fetch("obs_id")), link("about", SCHEDULE_ID)]
      )
      stored = receipt.merge("obs_id" => packet.fetch("id"))
      @requests << stored
      stored
    end

    def duplicate_pending_receipt(intent, duplicate)
      receipt = {
        "kind" => "OperationRequestReceipt",
        "receipt_id" => "operation_request/fixture/req-001-duplicate-receipt",
        "action" => "appointment_cancel_request",
        "action_kind" => "request",
        "duplicate_of" => duplicate.fetch("receipt_id"),
        "request_status" => "pending",
        "status" => "duplicate_pending_suppressed",
        "created_new_request" => false,
        "schedule_status_changed" => false,
        "diagnostic" => "operation_request.duplicate_pending"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: receipt.fetch("receipt_id"),
        payload: receipt,
        lifecycle: "audit",
        links: [link("caused_by", intent.fetch("obs_id")), link("duplicates", duplicate.fetch("obs_id"))]
      )
      receipt.merge("obs_id" => packet.fetch("id"))
    end

    def external_bridge(operation_request_ref)
      unless @bridge_capability
        return obs(
          kind: "failure_observation",
          subject: "external_bridge/helpdesk_ticket/#{operation_request_ref}",
          payload: {
            "kind" => "ExternalBridgeFailure",
            "status" => "bridge_skipped_or_blocked",
            "diagnostic" => "external_bridge.capability_missing",
            "operation_request_status" => "pending",
            "core_operation_valid" => true,
            "external_record_created" => false
          },
          lifecycle: "session",
          links: [link("bridges", operation_request_ref)]
        )
      end

      intent = obs(
        kind: "intent_observation",
        subject: "external_bridge_intent/fixture/req-001",
        payload: {
          "kind" => "ExternalBridgeIntent",
          "intent_id" => "external_bridge_intent/fixture/req-001",
          "bridge_kind" => "helpdesk_ticket",
          "subject_ref" => operation_request_ref,
          "capability_ref" => "capability/helpdesk_ticket_create@fixture",
          "payload_policy" => "provider_neutral_summary"
        },
        lifecycle: "session",
        links: [link("about", operation_request_ref)]
      )
      receipt = {
        "kind" => "ExternalBridgeReceipt",
        "receipt_id" => "external_bridge_receipt/fixture/req-001",
        "bridge_kind" => "helpdesk_ticket",
        "subject_ref" => operation_request_ref,
        "external_record_ref" => "external_record/fixture/ticket-001",
        "provider_payload_policy" => "redacted",
        "status" => "ok"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: receipt.fetch("receipt_id"),
        payload: receipt,
        lifecycle: "audit",
        links: [link("caused_by", intent.fetch("id")), link("bridges", operation_request_ref)]
      )
      receipt.merge("obs_id" => packet.fetch("id"))
    end

    def no_op_receipt(intent, policy)
      receipt = {
        "kind" => "OperationNoOpReceipt",
        "receipt_id" => "operation_noop/fixture/in-progress-001",
        "action" => "appointment_in_progress",
        "action_kind" => "execution",
        "status" => "no_op",
        "diagnostic" => "operation_execution.already_in_target_state",
        "new_execution_receipt_required" => "open_question",
        "schedule_status_changed" => false,
        "subject_ref" => SCHEDULE_ID
      }
      packet = obs(
        kind: "receipt_observation",
        subject: receipt.fetch("receipt_id"),
        payload: receipt,
        lifecycle: "audit",
        links: [link("caused_by", intent.fetch("obs_id")), link("checked_against", policy.fetch("obs_id"))]
      )
      receipt.merge("obs_id" => packet.fetch("id"))
    end

    def operation_failure(diagnostic, message, intent, extra = {})
      payload = {
        "kind" => "OperationFailure",
        "status" => "blocked",
        "diagnostic" => diagnostic,
        "message" => message,
        "schedule_status_changed" => false
      }.merge(extra)
      obs(
        kind: "failure_observation",
        subject: "operation_failure/#{intent.fetch("intent_id")}",
        payload: payload,
        lifecycle: "session",
        links: [link("caused_by", intent.fetch("obs_id")), link("about", SCHEDULE_ID)]
      )
    end

    def operation_intent(intent_id, action_key, action_kind, requested_at, policy_projection_ref: nil)
      payload = {
        "kind" => "OperationIntent",
        "intent_id" => intent_id,
        "action" => action_key,
        "action_kind" => action_kind,
        "actor_ref" => ACTOR_ID,
        "subject_ref" => SCHEDULE_ID,
        "source" => SOURCE,
        "source_ref" => SOURCE_REF,
        "requested_at" => requested_at,
        "policy_projection_ref" => policy_projection_ref,
        "payload_policy" => action_kind == "request" ? "redacted_reason_summary" : "redacted_business_summary"
      }
      packet = obs(
        kind: "intent_observation",
        subject: intent_id,
        payload: payload,
        lifecycle: "session",
        links: [link("scoped_to", COMPANY_ID), link("about", SCHEDULE_ID)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def executable_action_check(intent, current_context_hash)
      obs(
        kind: "platform_observation",
        subject: "executable_action_check/#{intent.fetch("intent_id")}",
        payload: {
          "kind" => "ExecutableActionCheck",
          "intent_ref" => intent.fetch("intent_id"),
          "policy_projection_ref" => intent.fetch("policy_projection_ref"),
          "policy_context_hash" => @policy_projection.fetch("context_hash"),
          "current_context_hash" => current_context_hash,
          "status" => "ok",
          "visibility_was_not_authority" => true
        },
        lifecycle: "session",
        links: [link("checked_against", @policy_projection.fetch("obs_id"))]
      )
    end

    def current_execution_context
      {
        "actor" => actor_fact,
        "order" => order_fact,
        "schedule" => @schedule,
        "config" => config_fact,
        "policy_version" => POLICY_VERSION,
        "action_config_version" => CONFIG_VERSION
      }
    end

    def actor_fact
      {
        "kind" => "ActorObservation",
        "actor_id" => ACTOR_ID,
        "company_id" => COMPANY_ID,
        "roles" => ["technician"],
        "technician_ref" => TECHNICIAN_ID,
        "subordinate_technician_refs" => [],
        "manage_all_orders" => false,
        "status" => "active"
      }
    end

    def order_fact
      {
        "kind" => "OperationSubjectObservation",
        "order_id" => ORDER_ID,
        "company_id" => COMPANY_ID,
        "order_status" => "scheduled",
        "subject_kind" => "order_schedule"
      }
    end

    def schedule_fact(status)
      {
        "kind" => "ScheduleStateObservation",
        "schedule_id" => SCHEDULE_ID,
        "order_id" => ORDER_ID,
        "company_id" => COMPANY_ID,
        "technician_id" => TECHNICIAN_ID,
        "status" => status,
        "start_at" => "2026-05-06T14:00:00Z",
        "end_at" => "2026-05-06T15:00:00Z",
        "disputable" => false
      }
    end

    def config_fact
      {
        "kind" => "CompanyActionConfigVersion",
        "company_id" => COMPANY_ID,
        "version" => CONFIG_VERSION,
        "enabled_actions" => [
          "appointment_in_progress",
          "appointment_complete",
          "appointment_cancel_request",
          "operator_callback"
        ],
        "disabled_actions" => ["appointment_dispute"]
      }
    end

    def action(key, kind, executable, reason)
      {
        "key" => key,
        "action_kind" => kind,
        "executable_under_current_context" => executable,
        "reason" => reason
      }
    end

    def result(case_name)
      {
        "case" => case_name,
        "schedule_status" => @schedule.fetch("status"),
        "requests" => Canonical.normalize(@requests),
        "executions" => Canonical.normalize(@executions),
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
        "policy_drift" => Proof.policy_drift,
        "unexpected_request_mutation" => Proof.unexpected_request_mutation,
        "missing_execution_receipt" => Proof.missing_execution_receipt,
        "no_op" => Proof.no_op,
        "bridge_capability_missing" => Proof.bridge_capability_missing
      }
      checks = [
        check("policy.visible_hidden_table", policy_table?(results.fetch("positive"))),
        check("policy.visibility_not_authority", visibility_not_authority?(results.fetch("positive"))),
        check("execution.in_progress_receipt", execution_receipt?(results.fetch("positive"))),
        check("request.cancel_pending_receipt", request_receipt?(results.fetch("positive"))),
        check("request.no_schedule_mutation", request_does_not_mutate_schedule?(results.fetch("positive"))),
        check("duplicate.pending_non_admission", duplicate_pending?(results.fetch("positive"))),
        check("bridge.capability_present_receipt", bridge_receipt?(results.fetch("positive"))),
        check("negative.policy_drift_blocked", failure?(results.fetch("policy_drift"), "operation_action.policy_context_drift")),
        check("negative.request_mutation_blocked", failure?(results.fetch("unexpected_request_mutation"), "operation_request.unexpected_subject_mutation")),
        check("negative.missing_execution_receipt_blocked", failure?(results.fetch("missing_execution_receipt"), "operation_execution.receipt_missing_for_state_transition")),
        check("negative.no_op_receipt", no_op?(results.fetch("no_op"))),
        check("negative.bridge_capability_missing", bridge_missing?(results.fetch("bridge_capability_missing"))),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def policy_table?(result)
      policy = result.fetch("policy_projection")
      visible = policy.fetch("visible_actions")
      hidden = policy.fetch("hidden_actions")
      visible.map { |action| action.fetch("key") }.sort == %w[
        appointment_cancel_request
        appointment_complete
        appointment_in_progress
        operator_callback
      ] &&
        visible.count { |action| action.fetch("action_kind") == "execution" } == 2 &&
        visible.count { |action| action.fetch("action_kind") == "request" } == 2 &&
        hidden == [
          {
            "action_kind" => "request",
            "executable_under_current_context" => false,
            "key" => "appointment_dispute",
            "reason" => "action_disabled_or_schedule_not_disputable"
          }
        ]
    end

    def visibility_not_authority?(result)
      policy = result.fetch("policy_projection")
      checks = result.fetch("observations").select do |obs|
        obs.fetch("payload").fetch("kind", nil) == "ExecutableActionCheck"
      end
      policy.fetch("visibility_is_authority") == false &&
        policy.fetch("executable_authority_requires_fresh_check") == true &&
        checks.any? { |obs| obs.fetch("payload").fetch("visibility_was_not_authority") == true }
    end

    def execution_receipt?(result)
      receipt = result.fetch("execution_receipt")
      receipt.fetch("status") == "ok" &&
        receipt.fetch("before_state").fetch("schedule_status") == "planned" &&
        receipt.fetch("after_state").fetch("schedule_status") == "in_progress" &&
        receipt.fetch("schedule_status_changed") == true &&
        result.fetch("schedule_status") == "in_progress"
    end

    def request_receipt?(result)
      receipt = result.fetch("request_receipt")
      receipt.fetch("status") == "created" &&
        receipt.fetch("request_status") == "pending" &&
        receipt.fetch("action_kind") == "request"
    end

    def request_does_not_mutate_schedule?(result)
      result.fetch("request_receipt").fetch("schedule_status_changed") == false &&
        result.fetch("schedule_status") == "in_progress"
    end

    def duplicate_pending?(result)
      receipt = result.fetch("duplicate_receipt")
      result.fetch("requests").length == 1 &&
        receipt.fetch("status") == "duplicate_pending_suppressed" &&
        receipt.fetch("created_new_request") == false &&
        receipt.fetch("schedule_status_changed") == false &&
        receipt.fetch("diagnostic") == "operation_request.duplicate_pending"
    end

    def bridge_receipt?(result)
      receipt = result.fetch("external_bridge_receipt")
      receipt.fetch("status") == "ok" &&
        receipt.fetch("provider_payload_policy") == "redacted" &&
        receipt.fetch("external_record_ref") == "external_record/fixture/ticket-001"
    end

    def failure?(result, diagnostic)
      result.fetch("observations").any? do |obs|
        obs.fetch("kind") == "failure_observation" &&
          obs.fetch("payload").fetch("diagnostic") == diagnostic &&
          obs.fetch("payload").fetch("status") == "blocked"
      end
    end

    def no_op?(result)
      receipt = result.fetch("no_op_receipt")
      receipt.fetch("kind") == "OperationNoOpReceipt" &&
        receipt.fetch("status") == "no_op" &&
        receipt.fetch("diagnostic") == "operation_execution.already_in_target_state" &&
        receipt.fetch("schedule_status_changed") == false
    end

    def bridge_missing?(result)
      receipt = result.fetch("bridge_receipt").fetch("payload")
      result.fetch("request_receipt").fetch("request_status") == "pending" &&
        receipt.fetch("status") == "bridge_skipped_or_blocked" &&
        receipt.fetch("diagnostic") == "external_bridge.capability_missing" &&
        receipt.fetch("core_operation_valid") == true &&
        receipt.fetch("external_record_created") == false
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
      puts "#{ok ? "PASS" : "FAIL"} spark_operation_action_lifecycle_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      puts "positive.policy.visible: #{positive.fetch("policy_projection").fetch("visible_actions").map { |action| "#{action.fetch("key")}:#{action.fetch("action_kind")}" }.join(", ")}"
      puts "positive.execution: #{positive.fetch("execution_receipt").fetch("before_state").fetch("schedule_status")} -> #{positive.fetch("execution_receipt").fetch("after_state").fetch("schedule_status")}"
      puts "positive.request: #{positive.fetch("request_receipt").fetch("status")} schedule_changed=#{positive.fetch("request_receipt").fetch("schedule_status_changed")}"
      puts "duplicate: #{positive.fetch("duplicate_receipt").fetch("status")} created_new_request=#{positive.fetch("duplicate_receipt").fetch("created_new_request")}"
      bridge_missing = result.fetch("results").fetch("bridge_capability_missing").fetch("bridge_receipt").fetch("payload")
      puts "bridge_missing: #{bridge_missing.fetch("status")} diagnostic=#{bridge_missing.fetch("diagnostic")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = SparkOperationActionLifecycleFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module SparkTechnicianAvailabilityFixture
  AS_OF = "2026-05-06T12:30:00Z"
  PIPELINE_ID = "pipeline/spark-technician-availability-fixture-v0"
  SESSION_ID = "session/spark-technician-availability-fixture-v0"
  RUNTIME_REF = "runtime/synthetic-fixture"
  COMPANY_ID = "company/fixture-acme"
  TECHNICIAN_ID = "tech/t-17"
  EMPLOYEE_ID = "employee/e-17"
  DATE = "2026-05-06"
  TIMEZONE = "America/New_York"
  RULE_VERSION = "availability_rules@1"
  SCHEMA_VERSION = "0.1.0"

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

  class Failure < StandardError
    attr_reader :kind, :context

    def initialize(kind:, message:, context:)
      super(message)
      @kind = kind
      @context = context
    end
  end

  class Proof
    def initialize
      @observations = []
      @step_obs_ids = []
      @previous_step_obs_id = nil
    end

    def self.run_case(name, mutations = {})
      new.run_case(name, mutations)
    end

    def run_case(name, mutations)
      @case_name = name
      facts = synthetic_facts(mutations)
      @context = synthetic_context(mutations)
      @observations = []
      @step_obs_ids = []
      @previous_step_obs_id = nil
      @first_failure_ref = nil
      @snapshot = nil

      scope = step("establish_tenant_scope", 0, []) { establish_tenant_scope(facts) }
      horizon = scope && step("validate_availability_horizon", 1, [scope.fetch("source_ref")]) { validate_horizon(facts, scope) }
      reads = horizon && step("read_scoped_facts", 2, [horizon.fetch("obs_id")]) { read_scoped_facts(facts, scope, horizon) }
      projection = reads && step("compute_availability_projection", 3, reads.fetch("read_obs_ids")) do
        compute_projection(reads, scope, horizon)
      end
      snapshot = projection && step("materialize_availability_snapshot", 4, [projection.fetch("obs_id")]) do
        materialize_snapshot(projection, horizon)
      end

      trace = pipeline_trace(snapshot ? "ok" : "failed")
      {
        "case" => name,
        "status" => snapshot ? "ok" : "blocked",
        "snapshot" => snapshot,
        "projection" => projection,
        "pipeline_trace" => trace,
        "observations" => @observations
      }
    end

    private

    def synthetic_context(mutations)
      {
        "tenant_free" => false,
        "company_id" => mutations.fetch(:horizon_company_id, COMPANY_ID),
        "timezone" => mutations.fetch(:horizon_timezone, TIMEZONE),
        "requested_window_local" => mutations.fetch(
          :requested_window_local,
          {
            "start_hour" => 9,
            "end_hour" => 16,
            "start" => "2026-05-06T09:00:00-04:00",
            "end" => "2026-05-06T16:00:00-04:00"
          }
        ),
        "requested_window_utc" => "2026-05-06T13:00:00Z..2026-05-06T20:00:00Z",
        "as_of" => AS_OF,
        "rule_version" => RULE_VERSION
      }
    end

    def synthetic_facts(mutations)
      {
        "location_scope" => {
          "location_id" => "location/fixture-north",
          "company_id" => mutations.fetch(:location_company_id, COMPANY_ID),
          "scope_version" => "tenant-scope-v1"
        },
        "company_policy" => {
          "company_id" => COMPANY_ID,
          "timezone" => mutations.fetch(:policy_timezone, TIMEZONE),
          "beginning_of_day_hour" => 8,
          "end_of_day_hour" => 17,
          "slot_duration_minutes" => 60,
          "boundary_mode" => "strict"
        },
        "technician_profile" => {
          "technician_id" => TECHNICIAN_ID,
          "employee_id" => EMPLOYEE_ID,
          "company_id" => mutations.fetch(:technician_company_id, COMPANY_ID),
          "status" => mutations.fetch(:technician_status, "active"),
          "roles" => ["technician"],
          "services" => ["service/appliance"],
          "zones" => ["zone/north"]
        },
        "schedule_slots" => [
          {
            "schedule_id" => "schedule/t-17/2026-05-06/10",
            "company_id" => mutations.fetch(:schedule_company_id, COMPANY_ID),
            "technician_id" => TECHNICIAN_ID,
            "order_id" => "order/o-100",
            "start_hour" => 10,
            "end_hour" => 11,
            "status" => mutations.fetch(:schedule_status, "planned"),
            "kind" => "initial_order"
          }
        ],
        "off_schedules" => [
          {
            "off_schedule_id" => "off/t-17/2026-05-06/12",
            "company_id" => COMPANY_ID,
            "technician_id" => TECHNICIAN_ID,
            "start_hour" => 12,
            "end_hour" => 13,
            "reason" => "manual_block",
            "source" => "dispatcher"
          }
        ],
        "day_off_config" => {
          "config_id" => "day_off_config/e-17/v1",
          "employee_id" => EMPLOYEE_ID,
          "technician_id" => TECHNICIAN_ID,
          "company_id" => COMPANY_ID,
          "schema_version" => SCHEMA_VERSION,
          "effective_from" => "2026-05-01",
          "rule_version" => "day_off_rules@1",
          "weekly_rules" => { "wed" => [14] }
        }
      }
    end

    def establish_tenant_scope(facts)
      location_obs = obs(
        kind: "fact_observation",
        subject: "location_scope/fixture-north",
        payload: facts.fetch("location_scope"),
        lifecycle: "durable",
        links: []
      )
      company_id = @context.fetch("company_id")
      fail!("availability.tenant_scope_missing", "company_id missing from fact scope") unless company_id
      fail!(
        "availability.tenant_scope_mismatch",
        "location scope does not match requested company",
        offending_refs: [location_obs.fetch("id")]
      ) unless facts.fetch("location_scope").fetch("company_id") == company_id

      {
        "company_id" => company_id,
        "scope_version" => facts.fetch("location_scope").fetch("scope_version"),
        "source_ref" => location_obs.fetch("id"),
        "established_at" => AS_OF,
        "obs_id" => location_obs.fetch("id")
      }
    end

    def validate_horizon(facts, scope)
      policy = facts.fetch("company_policy")
      fail!("availability.timezone_drift", "horizon timezone differs from company policy") unless policy.fetch("timezone") == @context.fetch("timezone")

      window = @context.fetch("requested_window_local")
      start_hour = window.fetch("start_hour")
      end_hour = window.fetch("end_hour")
      valid_window = start_hour < end_hour &&
        start_hour >= policy.fetch("beginning_of_day_hour") &&
        end_hour <= policy.fetch("end_of_day_hour")
      fail!("availability.invalid_time_window", "requested window is outside company workday") unless valid_window

      payload = {
        "projection_name" => "availability[technician, requested_window]",
        "mode" => "reproducible",
        "as_of" => AS_OF,
        "rule_version" => RULE_VERSION,
        "timezone" => @context.fetch("timezone"),
        "requested_window_local" => "#{window.fetch("start")}..#{window.fetch("end")}",
        "requested_window_utc" => @context.fetch("requested_window_utc"),
        "fact_scope" => {
          "company_id" => scope.fetch("company_id"),
          "scope_ref" => scope.fetch("source_ref"),
          "scope_version" => scope.fetch("scope_version"),
          "technician_id" => TECHNICIAN_ID
        }
      }
      obs = obs(
        kind: "platform_observation",
        subject: "availability_horizon/#{TECHNICIAN_ID}/#{DATE}",
        payload: payload,
        lifecycle: "session",
        links: [link("scoped_to", scope.fetch("company_id")), link("scope_source", scope.fetch("source_ref"))]
      )
      payload.merge("obs_id" => obs.fetch("id"))
    end

    def read_scoped_facts(facts, scope, _horizon)
      profile = scoped_read("technician_profile", "TechnicianProfile", facts.fetch("technician_profile"), scope, min: 1, max: 1)
      schedule = scoped_read("schedule_slots", "ScheduleSlotObservation", facts.fetch("schedule_slots"), scope, min: 0, max: 500)
      off_schedule = scoped_read("off_schedules", "OffScheduleObservation", facts.fetch("off_schedules"), scope, min: 0, max: 500)
      day_off = scoped_read("day_off_config", "DayOffConfigVersion", facts.fetch("day_off_config"), scope, min: 1, max: 1)
      reads = [profile, schedule, off_schedule, day_off]
      bundle = obs(
        kind: "platform_observation",
        subject: "scoped_fact_read_bundle/#{TECHNICIAN_ID}/#{DATE}",
        payload: {
          "kind" => "ScopedFactReadBundle",
          "tenant_scope" => scope,
          "read_refs" => reads.map { |read| read.fetch("obs_id") },
          "status" => "ok"
        },
        lifecycle: "session",
        links: reads.map { |read| link("contains", read.fetch("obs_id")) }
      )
      {
        "profile" => profile.fetch("facts").fetch(0),
        "schedule_slots" => schedule.fetch("facts"),
        "off_schedules" => off_schedule.fetch("facts"),
        "day_off_config" => day_off.fetch("facts").fetch(0),
        "read_obs_ids" => reads.map { |read| read.fetch("obs_id") },
        "obs_id" => bundle.fetch("id")
      }
    end

    def scoped_read(subject, type_name, fact_or_facts, scope, min:, max:)
      facts = fact_or_facts.is_a?(Hash) ? [fact_or_facts] : Array(fact_or_facts)
      scoped = facts.select { |fact| fact.fetch("company_id", nil) == scope.fetch("company_id") }
      offending = facts - scoped
      unless offending.empty?
        offending_obs = offending.map do |fact|
          obs(kind: "fact_observation", subject: "#{subject}/offending", payload: fact, lifecycle: "durable", links: [link("belongs_to", fact.fetch("company_id", "unknown"))])
        end
        fail!(
          "availability.tenant_scope_mismatch",
          "#{subject} contains facts outside tenant scope",
          offending_refs: offending_obs.map { |item| item.fetch("id") }
        )
      end

      unless scoped.length >= min && scoped.length <= max
        fail!("availability.cardinality_bound_failed", "#{subject} cardinality outside #{min}..#{max}")
      end

      fact_obs = scoped.map do |fact|
        obs(kind: "fact_observation", subject: "#{subject}/#{TECHNICIAN_ID}/#{DATE}", payload: fact, lifecycle: "durable", links: [link("scoped_to", scope.fetch("company_id"))])
      end
      read_payload = {
        "kind" => "ScopedFactRead",
        "subject" => subject,
        "type" => type_name,
        "as_of" => AS_OF,
        "tenant_scope" => scope,
        "cardinality_bound" => { "min" => min, "max" => max, "source" => "declared" },
        "schema_version" => SCHEMA_VERSION,
        "lifecycle" => "durable",
        "result" => { "status" => "ok", "count" => scoped.length, "fact_refs" => fact_obs.map { |item| item.fetch("id") } }
      }
      read_obs = obs(
        kind: "platform_observation",
        subject: "scoped_fact_read/#{subject}",
        payload: read_payload,
        lifecycle: "session",
        links: fact_obs.map { |item| link("read_from", item.fetch("id")) } + [link("scoped_to", scope.fetch("company_id"))]
      )
      { "facts" => scoped, "obs_id" => read_obs.fetch("id"), "fact_obs_ids" => fact_obs.map { |item| item.fetch("id") } }
    end

    def compute_projection(reads, scope, horizon)
      profile = reads.fetch("profile")
      fail!("availability.inactive_technician", "technician is not active") unless profile.fetch("status") == "active"

      schedule_slots = reads.fetch("schedule_slots")
      bad_status = schedule_slots.find { |slot| !%w[planned confirmed].include?(slot.fetch("status")) }
      if bad_status
        fail!(
          "availability.schedule_status_evidence_mismatch",
          "schedule status does not support trusted busy-slot evidence",
          schedule_id: bad_status.fetch("schedule_id"),
          status: bad_status.fetch("status")
        )
      end

      window = @context.fetch("requested_window_local")
      slots = (window.fetch("start_hour")...window.fetch("end_hour")).map do |hour|
        slot_for_hour(hour, reads)
      end
      available_count = slots.count { |slot| slot.fetch("status") == "available" }
      payload = {
        "technician_id" => TECHNICIAN_ID,
        "company_id" => scope.fetch("company_id"),
        "status" => available_count.positive? ? "available" : "unavailable",
        "available_count" => available_count,
        "blocked_count" => slots.length - available_count,
        "slots" => slots,
        "meaning_status" => "reproducible"
      }
      obs = obs(
        kind: "value_observation",
        subject: "availability_projection/#{TECHNICIAN_ID}/#{DATE}",
        payload: payload,
        lifecycle: "window",
        links: [link("computed_under", horizon.fetch("obs_id"))] +
          reads.fetch("read_obs_ids").map { |id| link("derived_from", id) }
      )
      payload.merge("obs_id" => obs.fetch("id"))
    end

    def slot_for_hour(hour, reads)
      reasons = []
      evidence_refs = []
      schedule = reads.fetch("schedule_slots").find { |slot| hour >= slot.fetch("start_hour") && hour < slot.fetch("end_hour") }
      off_schedule = reads.fetch("off_schedules").find { |slot| hour >= slot.fetch("start_hour") && hour < slot.fetch("end_hour") }
      day_off_hours = reads.fetch("day_off_config").fetch("weekly_rules").fetch("wed", [])

      if schedule
        reasons << "busy"
        evidence_refs << schedule.fetch("schedule_id")
      elsif off_schedule
        reasons << "off"
        evidence_refs << off_schedule.fetch("off_schedule_id")
      elsif day_off_hours.include?(hour)
        reasons << "day_off"
        evidence_refs << reads.fetch("day_off_config").fetch("config_id")
      end

      {
        "hour" => hour,
        "utc_start" => "2026-05-06T#{format("%02d", hour + 4)}:00:00Z",
        "status" => reasons.fetch(0, "available"),
        "why_not" => reasons,
        "evidence_refs" => evidence_refs
      }
    end

    def materialize_snapshot(projection, horizon)
      slots = projection.fetch("slots")
      reason_counts = slots.each_with_object({ "busy" => 0, "off" => 0, "day_off" => 0, "available" => 0 }) do |slot, out|
        if slot.fetch("why_not").empty?
          out["available"] += 1
        else
          slot.fetch("why_not").each { |reason| out[reason] += 1 }
        end
      end
      payload = {
        "snapshot_id" => "availability_snapshot/t-17/20260506/requested-window/v1",
        "company_id" => COMPANY_ID,
        "technician_id" => TECHNICIAN_ID,
        "requested_window_utc" => @context.fetch("requested_window_utc"),
        "status" => projection.fetch("status"),
        "available_count" => projection.fetch("available_count"),
        "blocked_count" => projection.fetch("blocked_count"),
        "reason_counts" => reason_counts,
        "source_summary_hash" => Canonical.hash([projection.fetch("obs_id"), horizon.fetch("obs_id"), reason_counts])
      }
      obs = obs(
        kind: "snapshot_observation",
        subject: "availability_snapshot/#{TECHNICIAN_ID}/#{DATE}",
        payload: payload,
        lifecycle: "compacted",
        links: [link("materializes", projection.fetch("obs_id")), link("computed_under", horizon.fetch("obs_id"))]
      )
      @snapshot = payload.merge("obs_id" => obs.fetch("id"))
    end

    def step(step_id, index, input_refs)
      result = yield
      step_obs = step_observation(step_id, index, "ok", input_refs, result.fetch("obs_id", nil), nil)
      @previous_step_obs_id = step_obs.fetch("id")
      result
    rescue Failure => e
      failure = failure_observation(e)
      step_obs = step_observation(step_id, index, "err", input_refs, nil, failure.fetch("id"))
      @first_failure_ref = step_obs.fetch("id")
      @previous_step_obs_id = step_obs.fetch("id")
      nil
    end

    def step_observation(step_id, index, status, input_refs, output_ref, failure_ref)
      payload = {
        "step_id" => step_id,
        "pipeline_id" => PIPELINE_ID,
        "step_index" => index,
        "status" => status,
        "input_refs" => input_refs.compact,
        "output_ref" => output_ref,
        "failure_ref" => failure_ref,
        "temporal" => temporal("session"),
        "tenant_scope" => @context["company_id"] && {
          "company_id" => @context["company_id"],
          "established_at" => AS_OF
        }
      }
      links = [link("produced_in", SESSION_ID), link("observed_under", RUNTIME_REF)]
      links << link("caused_by", @previous_step_obs_id) if @previous_step_obs_id
      obs = obs(kind: "step_observation", subject: "#{PIPELINE_ID}/#{step_id}", payload: payload, lifecycle: "session", links: links)
      @step_obs_ids << obs.fetch("id")
      obs
    end

    def pipeline_trace(status)
      payload = {
        "pipeline_id" => PIPELINE_ID,
        "steps_attempted" => @step_obs_ids,
        "first_failure_ref" => @first_failure_ref,
        "status" => status,
        "temporal" => temporal("session"),
        "tenant_scope" => @context["company_id"] && { "company_id" => @context["company_id"], "established_at" => AS_OF }
      }
      obs(
        kind: "platform_observation",
        subject: "#{PIPELINE_ID}/trace/#{@case_name}",
        payload: payload,
        lifecycle: "session",
        links: [link("produced_in", SESSION_ID), link("observed_under", RUNTIME_REF)]
      )
    end

    def failure_observation(failure)
      payload = {
        "decision" => "blocked",
        "failure_kind" => failure.kind,
        "message" => failure.message,
        "context" => failure.context,
        "must_not_emit" => "AvailabilitySnapshot"
      }
      obs(kind: "failure_observation", subject: "availability_failure/#{@case_name}", payload: payload, lifecycle: "session", links: [])
    end

    def fail!(kind, message, context = {})
      raise Failure.new(kind: kind, message: message, context: context)
    end

    def obs(kind:, subject:, payload:, lifecycle:, links:)
      packet = {
        "id" => nil,
        "kind" => kind,
        "subject" => subject,
        "payload" => Canonical.normalize(payload),
        "payload_hash" => Canonical.hash(payload),
        "temporal" => temporal(lifecycle),
        "links" => Canonical.normalize(links)
      }
      packet["id"] = "obs/#{Canonical.short_hash(packet.reject { |key, _| key == "id" })}"
      @observations << packet
      packet
    end

    def temporal(lifecycle)
      { "as_of" => AS_OF, "lifecycle" => lifecycle, "rule_version" => RULE_VERSION }
    end

    def link(rel, ref)
      { "rel" => rel, "ref" => ref, "required" => true }
    end
  end

  module Checker
    module_function

    def call
      positive = Proof.run_case("positive")
      negatives = {
        "wrong_tenant" => Proof.run_case("wrong_tenant", schedule_company_id: "company/other"),
        "invalid_time_window" => Proof.run_case(
          "invalid_time_window",
          requested_window_local: {
            "start_hour" => 7,
            "end_hour" => 16,
            "start" => "2026-05-06T07:00:00-04:00",
            "end" => "2026-05-06T16:00:00-04:00"
          }
        ),
        "inactive_technician" => Proof.run_case("inactive_technician", technician_status: "inactive"),
        "status_mismatch" => Proof.run_case("status_mismatch", schedule_status: "canceled")
      }
      results = { "positive" => positive, "negatives" => negatives }
      checks = [
        check("positive.pipeline_trace_ok", positive.fetch("pipeline_trace").fetch("payload").fetch("status") == "ok"),
        check("positive.snapshot_counts", snapshot_counts_ok?(positive.fetch("snapshot"))),
        check("positive.why_not_reasons", why_not_reasons_ok?(positive.fetch("projection"))),
        check("positive.step_observations", step_observations_ok?(positive, expected_count: 5)),
        check("positive.scoped_fact_reads", scoped_fact_reads_ok?(positive)),
        check("negative.wrong_tenant_blocked", failure_kind?(negatives.fetch("wrong_tenant"), "availability.tenant_scope_mismatch")),
        check("negative.invalid_time_window_blocked", failure_kind?(negatives.fetch("invalid_time_window"), "availability.invalid_time_window")),
        check("negative.inactive_technician_blocked", failure_kind?(negatives.fetch("inactive_technician"), "availability.inactive_technician")),
        check("negative.status_mismatch_blocked", failure_kind?(negatives.fetch("status_mismatch"), "availability.schedule_status_evidence_mismatch")),
        check("negative.no_trusted_snapshots", negatives.values.all? { |result| result.fetch("snapshot").nil? }),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def snapshot_counts_ok?(snapshot)
      snapshot &&
        snapshot.fetch("available_count") == 4 &&
        snapshot.fetch("blocked_count") == 3 &&
        snapshot.fetch("reason_counts") == { "available" => 4, "busy" => 1, "day_off" => 1, "off" => 1 }
    end

    def why_not_reasons_ok?(projection)
      expected = {
        9 => ["available", []],
        10 => ["busy", ["busy"]],
        11 => ["available", []],
        12 => ["off", ["off"]],
        13 => ["available", []],
        14 => ["day_off", ["day_off"]],
        15 => ["available", []]
      }
      projection.fetch("slots").all? do |slot|
        expected.fetch(slot.fetch("hour")) == [slot.fetch("status"), slot.fetch("why_not")]
      end
    end

    def step_observations_ok?(result, expected_count:)
      steps = result.fetch("observations").select { |obs| obs.fetch("kind") == "step_observation" }
      steps.length == expected_count && steps.all? { |obs| %w[ok err].include?(obs.fetch("payload").fetch("status")) }
    end

    def scoped_fact_reads_ok?(result)
      reads = result.fetch("observations").select do |obs|
        obs.fetch("kind") == "platform_observation" &&
          obs.fetch("payload").fetch("kind", nil) == "ScopedFactRead"
      end
      reads.length == 4 &&
        reads.all? { |obs| obs.fetch("payload").fetch("tenant_scope").fetch("company_id") == COMPANY_ID } &&
        reads.all? { |obs| obs.fetch("payload").fetch("cardinality_bound").fetch("max").is_a?(Integer) }
    end

    def failure_kind?(result, kind)
      result.fetch("status") == "blocked" &&
        result.fetch("observations").any? do |obs|
          obs.fetch("kind") == "failure_observation" &&
            obs.fetch("payload").fetch("failure_kind") == kind
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
        provider_payload
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
      puts "#{ok ? "PASS" : "FAIL"} spark_technician_availability_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      snapshot = positive.fetch("snapshot")
      puts "positive.snapshot: #{snapshot.fetch("status")} available=#{snapshot.fetch("available_count")} blocked=#{snapshot.fetch("blocked_count")}"
      puts "positive.why_not: #{positive.fetch("projection").fetch("slots").map { |slot| "#{slot.fetch("hour")}:#{slot.fetch("status")}" }.join(", ")}"
      failures = result.fetch("results").fetch("negatives").transform_values do |case_result|
        case_result.fetch("observations").find { |obs| obs.fetch("kind") == "failure_observation" }.fetch("payload").fetch("failure_kind")
      end
      puts "negative.failures: #{failures.map { |name, kind| "#{name}=#{kind}" }.join(", ")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = SparkTechnicianAvailabilityFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

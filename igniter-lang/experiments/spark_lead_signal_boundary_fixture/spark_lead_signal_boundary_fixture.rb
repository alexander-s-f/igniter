#!/usr/bin/env ruby
# frozen_string_literal: true

require "bigdecimal"
require "digest"
require "json"

module SparkLeadSignalBoundaryFixture
  AS_OF = "2026-05-06T11:05:00Z"
  COMPANY_ID = "company/fixture-acme"
  BOUNDARY_ID = "lead_boundary/company-fixture-acme/20260506T10Z"
  BOUNDARY_START = "2026-05-06T10:00:00Z"
  BOUNDARY_END = "2026-05-06T11:00:00Z"
  HOUR_BUCKET = "#{BOUNDARY_START}..#{BOUNDARY_END}"
  ROLLUP_ID = "lead_rollup/company-fixture-acme/20260506T10Z/web/appliance/vendor"
  SCHEMA_VERSION = "lead_signal_schema@0.1.0"
  ROLLUP_RULE_VERSION = "lead_rollup_rules@1"
  RETENTION_RULE_VERSION = "lead_retention_rules@1"
  CANONICALIZATION_REF = "canonical/lead_signal_idempotency@1"
  SESSION_ID = "session/spark-lead-signal-boundary-fixture-v0"
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
    def initialize
      @observations = []
      @admitted = []
      @idempotency_index = {}
      @boundary_state = "open"
      @horizon_obs_id = nil
      @rollup = nil
      @dry_run_receipt = nil
    end

    def self.positive
      new.positive
    end

    def self.duplicate
      new.duplicate
    end

    def self.decimal_drift
      new.decimal_drift
    end

    def self.late_boundary
      new.late_boundary
    end

    def self.retention_before_coverage
      new.retention_before_coverage
    end

    def positive
      emit_boundary_horizon
      base_signals.each { |signal| admit_signal(signal) }
      materialize_rollup
      close_boundary
      dry_run = retention_dry_run
      execute = retention_execute
      exact_decimal_pressure = decimal_pressure_observation
      result("positive").merge(
        "rollup" => @rollup,
        "dry_run_retention_receipt" => dry_run,
        "execution_retention_receipt" => execute,
        "decimal_pressure" => exact_decimal_pressure
      )
    end

    def duplicate
      emit_boundary_horizon
      base_signals.each { |signal| admit_signal(signal) }
      materialize_rollup
      before_hash = Canonical.hash(@rollup)
      duplicate_receipt = admit_signal(duplicate_signal)
      after_hash = Canonical.hash(@rollup)
      result("duplicate").merge(
        "duplicate_receipt" => duplicate_receipt,
        "rollup_before_hash" => before_hash,
        "rollup_after_hash" => after_hash,
        "rollup" => @rollup
      )
    end

    def decimal_drift
      emit_boundary_horizon
      receipt = admit_signal(decimal_drift_signal)
      pressure = decimal_pressure_observation
      result("decimal_drift").merge(
        "decimal_drift_receipt" => receipt,
        "decimal_pressure" => pressure,
        "rollup" => @rollup
      )
    end

    def late_boundary
      positive_result = positive
      before_hash = Canonical.hash(@rollup)
      receipt = admit_signal(late_signal)
      after_hash = Canonical.hash(@rollup)
      result("late_boundary").merge(
        "baseline" => positive_result,
        "late_receipt" => receipt,
        "rollup_before_hash" => before_hash,
        "rollup_after_hash" => after_hash,
        "rollup" => @rollup
      )
    end

    def retention_before_coverage
      emit_boundary_horizon
      receipt = retention_execute
      result("retention_before_coverage").merge("retention_receipt" => receipt)
    end

    private

    def base_signals
      [
        signal("ls-001", "upi/fixture-a", "2026-05-06T10:05:00Z", true, "125.50", "request/fixture-r-001", "trace/fixture-t-001"),
        signal("ls-002", "upi/fixture-b", "2026-05-06T10:20:00Z", false, "0.00", "request/fixture-r-002", "trace/fixture-t-002"),
        signal("ls-003", "upi/fixture-c", "2026-05-06T10:45:00Z", true, "80.25", "request/fixture-r-003", "trace/fixture-t-003")
      ]
    end

    def duplicate_signal
      signal(
        "ls-001-duplicate",
        "upi/fixture-a",
        "2026-05-06T10:05:00Z",
        true,
        "125.50",
        "request/fixture-r-001b",
        "trace/fixture-t-001b"
      )
    end

    def decimal_drift_signal
      signal("ls-decimal-drift", "upi/fixture-d", "2026-05-06T10:10:00Z", true, 125.5, "request/fixture-r-dec", "trace/fixture-t-dec")
    end

    def late_signal
      signal(
        "ls-004-late",
        "upi/fixture-d",
        "2026-05-06T10:55:00Z",
        true,
        "10.00",
        "request/fixture-r-004",
        "trace/fixture-t-004",
        arrived_at: "2026-05-06T12:30:00Z"
      )
    end

    def signal(short_id, upi_ref, signal_at, accepted, bid_value, request_ref, trace_ref, arrived_at: AS_OF)
      {
        "signal_ref" => "lead_signal/fixture/#{short_id}",
        "company_id" => COMPANY_ID,
        "channel_ref" => "channel/fixture-web",
        "trade_ref" => "trade/fixture-appliance",
        "vendor_ref" => "vendor/fixture-marketplace",
        "geo_ref" => "geo/fixture-region-001",
        "did_ref" => "did/fixture-main",
        "upi_ref" => upi_ref,
        "signal_at" => signal_at,
        "arrived_at" => arrived_at,
        "accepted" => accepted,
        "bid" => bid_value.is_a?(String) ? decimal(bid_value) : bid_value,
        "request_ref" => request_ref,
        "trace_ref" => trace_ref
      }
    end

    def decimal(value)
      { "kind" => "Decimal", "value" => value, "scale" => 2, "currency" => "USD" }
    end

    def emit_boundary_horizon
      obs = obs(
        kind: "platform_observation",
        subject: BOUNDARY_ID,
        payload: {
          "kind" => "LeadSignalBoundaryHorizon",
          "boundary_id" => BOUNDARY_ID,
          "mode" => "reproducible",
          "hour_bucket_utc" => HOUR_BUCKET,
          "as_of" => AS_OF,
          "rollup_rule_version" => ROLLUP_RULE_VERSION,
          "schema_version" => SCHEMA_VERSION,
          "fact_scope" => {
            "company_id" => COMPANY_ID,
            "stores" => ["lead_signals", "lead_signal_hourly_rollups", "retention_receipts"]
          }
        },
        lifecycle: "session",
        links: [link("scoped_to", COMPANY_ID), link("produced_in", SESSION_ID)]
      )
      @horizon_obs_id = obs.fetch("id")
      obs
    end

    def admit_signal(signal)
      return late_boundary_receipt(signal) unless @boundary_state == "open"
      return decimal_invalid_receipt(signal) unless canonical_decimal?(signal.fetch("bid"))
      return boundary_window_receipt(signal) unless signal.fetch("signal_at") >= BOUNDARY_START && signal.fetch("signal_at") < BOUNDARY_END

      key_payload = idempotency_payload(signal)
      key = idempotency_key(key_payload)
      return duplicate_suppression_receipt(signal, key) if @idempotency_index.key?(key)

      idem_obs = idempotency_observation(signal, key, key_payload)
      signal_obs = lead_signal_observation(signal, key, idem_obs.fetch("id"))
      admitted = signal.merge("idempotency_key" => key, "obs_id" => signal_obs.fetch("id"), "idempotency_obs_id" => idem_obs.fetch("id"))
      @idempotency_index[key] = admitted
      @admitted << admitted
      { "status" => "admitted", "signal_obs_id" => signal_obs.fetch("id"), "idempotency_key" => key }
    end

    def idempotency_payload(signal)
      {
        "accepted" => signal.fetch("accepted"),
        "bid_decimal_string" => signal.fetch("bid").fetch("value"),
        "channel_ref" => signal.fetch("channel_ref"),
        "company_id" => signal.fetch("company_id"),
        "did_ref" => signal.fetch("did_ref"),
        "geo_ref" => signal.fetch("geo_ref"),
        "signal_at_utc_iso8601" => signal.fetch("signal_at"),
        "trade_ref" => signal.fetch("trade_ref"),
        "upi_ref" => signal.fetch("upi_ref"),
        "vendor_ref" => signal.fetch("vendor_ref")
      }
    end

    def idempotency_key(payload)
      "idem/sha256/#{Digest::SHA256.hexdigest(Canonical.json(payload))}"
    end

    def canonical_decimal?(value)
      value.is_a?(Hash) &&
        value.fetch("kind", nil) == "Decimal" &&
        value.fetch("scale", nil) == 2 &&
        value.fetch("currency", nil) == "USD" &&
        value.fetch("value", nil).is_a?(String) &&
        value.fetch("value").match?(/\A\d+\.\d{2}\z/)
    end

    def idempotency_observation(signal, key, key_payload)
      obs(
        kind: "platform_observation",
        subject: key,
        payload: {
          "kind" => "IdempotencyKeyObservation",
          "key" => key,
          "algorithm" => "sha256",
          "canonicalization_ref" => CANONICALIZATION_REF,
          "preimage_policy" => "field_refs_only",
          "canonical_preimage_hash" => Canonical.hash(key_payload)
        },
        lifecycle: "durable",
        links: [link("derived_from", signal.fetch("signal_ref"))]
      )
    end

    def lead_signal_observation(signal, key, idem_obs_id)
      obs(
        kind: "fact_observation",
        subject: signal.fetch("signal_ref"),
        payload: {
          "kind" => "LeadSignalObservation",
          "signal" => signal,
          "idempotency_key" => key,
          "payload_policy" => "redacted_raw_vendor_payload"
        },
        lifecycle: "window",
        links: [
          link("scoped_to", COMPANY_ID),
          link("belongs_to_boundary", BOUNDARY_ID),
          link("has_idempotency_key", idem_obs_id)
        ]
      )
    end

    def duplicate_suppression_receipt(signal, key)
      duplicate_of = @idempotency_index.fetch(key)
      obs(
        kind: "platform_observation",
        subject: "duplicate_suppression/#{signal.fetch("signal_ref")}",
        payload: {
          "kind" => "DuplicateSuppressionReceipt",
          "status" => "duplicate_suppressed",
          "decision" => "non_admission",
          "diagnostic" => "lead_signal.duplicate_idempotency_key",
          "signal_ref" => signal.fetch("signal_ref"),
          "duplicate_of" => key,
          "original_signal_ref" => duplicate_of.fetch("signal_ref"),
          "rollup_changed" => false,
          "retention_candidate_count_delta" => 0
        },
        lifecycle: "session",
        links: [link("duplicates", duplicate_of.fetch("obs_id")), link("scoped_to", COMPANY_ID)]
      )
    end

    def decimal_invalid_receipt(signal)
      obs(
        kind: "failure_observation",
        subject: "lead_signal_decimal_failure/#{signal.fetch("signal_ref")}",
        payload: {
          "status" => "blocked",
          "diagnostic" => "lead_signal.bid_decimal_invalid",
          "reason" => "bid must be canonical Decimal string with fixed scale before rollup",
          "bid_source_type" => signal.fetch("bid").class.name,
          "rollup_changed" => false
        },
        lifecycle: "session",
        links: [link("scoped_to", COMPANY_ID), link("blocked_before", "HourlyLeadSignalRollup")]
      )
    end

    def boundary_window_receipt(signal)
      obs(
        kind: "failure_observation",
        subject: "lead_signal_boundary_window_failure/#{signal.fetch("signal_ref")}",
        payload: {
          "status" => "blocked",
          "diagnostic" => "lead_signal.outside_boundary_window",
          "rollup_changed" => false
        },
        lifecycle: "session",
        links: [link("belongs_to_boundary", BOUNDARY_ID)]
      )
    end

    def late_boundary_receipt(signal)
      obs(
        kind: "platform_observation",
        subject: "late_boundary_mutation/#{signal.fetch("signal_ref")}",
        payload: {
          "kind" => "BoundaryMutationReceipt",
          "status" => "blocked",
          "diagnostic" => "lead_signal.late_boundary_reopen_required",
          "boundary_ref" => BOUNDARY_ID,
          "boundary_state" => @boundary_state,
          "signal_ref" => signal.fetch("signal_ref"),
          "rollup_changed" => false,
          "requires" => ["BoundaryReopenIntent", "ReopenReceipt", "replacement SemanticImage if rollup changes"]
        },
        lifecycle: "session",
        links: [link("blocked_by", BOUNDARY_ID), link("scoped_to", COMPANY_ID)]
      )
    end

    def materialize_rollup
      accepted = @admitted.select { |signal| signal.fetch("accepted") }
      rejected = @admitted.reject { |signal| signal.fetch("accepted") }
      accepted_total = decimal_sum(accepted)
      rejected_total = decimal_sum(rejected)
      total = decimal_sum(@admitted)

      payload = {
        "kind" => "HourlyLeadSignalRollup",
        "rollup_id" => ROLLUP_ID,
        "boundary_id" => BOUNDARY_ID,
        "bucket_at" => BOUNDARY_START,
        "dimensions" => {
          "company_id" => COMPANY_ID,
          "channel_ref" => "channel/fixture-web",
          "trade_ref" => "trade/fixture-appliance",
          "vendor_ref" => "vendor/fixture-marketplace",
          "geo_ref" => "geo/fixture-region-001"
        },
        "metrics" => {
          "accepted_count" => accepted.length,
          "rejected_count" => rejected.length,
          "total_count" => @admitted.length,
          "accepted_bid_amount" => decimal(accepted_total),
          "rejected_bid_amount" => decimal(rejected_total),
          "total_bid_amount" => decimal(total),
          "first_signal_at" => @admitted.map { |signal| signal.fetch("signal_at") }.min,
          "last_signal_at" => @admitted.map { |signal| signal.fetch("signal_at") }.max
        },
        "source_summary_hash" => Canonical.hash(@admitted.map { |signal| signal.fetch("obs_id") }.sort)
      }
      packet = obs(
        kind: "snapshot_observation",
        subject: ROLLUP_ID,
        payload: payload,
        lifecycle: "durable",
        links: [link("computed_under", @horizon_obs_id)] +
          @admitted.map { |signal| link("aggregated_from", signal.fetch("obs_id")) }
      )
      @rollup = payload.merge("obs_id" => packet.fetch("id"))
    end

    def decimal_sum(signals)
      total = signals.map { |signal| BigDecimal(signal.fetch("bid").fetch("value")) }.reduce(BigDecimal("0.00"), :+)
      format("%.2f", total)
    end

    def close_boundary
      @boundary_state = "closed"
      obs(
        kind: "platform_observation",
        subject: "boundary_close/#{BOUNDARY_ID}",
        payload: {
          "kind" => "BoundaryCloseReceipt",
          "boundary_ref" => BOUNDARY_ID,
          "status" => "closed",
          "closed_at" => AS_OF,
          "rollup_ref" => ROLLUP_ID
        },
        lifecycle: "session",
        links: [link("materializes", @rollup.fetch("obs_id"))]
      )
    end

    def retention_dry_run
      @dry_run_receipt = obs(
        kind: "retention_receipt",
        subject: "retention/lead_signal/dry-run/company-fixture-acme/20260506T10Z",
        payload: {
          "kind" => "RetentionReceipt",
          "mode" => "dry_run",
          "policy_ref" => RETENTION_RULE_VERSION,
          "boundary_ref" => BOUNDARY_ID,
          "candidate_count" => @admitted.length,
          "would_compact_count" => @admitted.length,
          "would_delete_raw_payload_count" => @admitted.length,
          "preserved_refs" => [ROLLUP_ID] + @admitted.map { |signal| signal.fetch("idempotency_key") },
          "status" => "ok"
        },
        lifecycle: "audit",
        links: [link("covers", @rollup.fetch("obs_id"))]
      )
    end

    def retention_execute
      unless @boundary_state == "closed" && @rollup && @dry_run_receipt
        return obs(
          kind: "retention_receipt",
          subject: "retention/lead_signal/execute/company-fixture-acme/20260506T10Z",
          payload: {
            "kind" => "RetentionReceipt",
            "mode" => "execute",
            "policy_ref" => RETENTION_RULE_VERSION,
            "boundary_ref" => BOUNDARY_ID,
            "status" => "blocked",
            "diagnostic" => "retention.boundary_coverage_missing",
            "deleted_raw_payload_count" => 0,
            "requires" => ["closed boundary", "HourlyLeadSignalRollup", "retention dry-run receipt or explicit skip policy"]
          },
          lifecycle: "audit",
          links: [link("scoped_to", COMPANY_ID)]
        )
      end

      obs(
        kind: "retention_receipt",
        subject: "retention/lead_signal/execute/company-fixture-acme/20260506T10Z",
        payload: {
          "kind" => "RetentionReceipt",
          "mode" => "execute",
          "policy_ref" => RETENTION_RULE_VERSION,
          "boundary_ref" => BOUNDARY_ID,
          "compacted_count" => @admitted.length,
          "deleted_raw_payload_count" => @admitted.length,
          "preserved_stub_count" => @admitted.length,
          "rollup_preserved" => true,
          "preserved_refs" => [ROLLUP_ID] + @admitted.map { |signal| signal.fetch("idempotency_key") },
          "status" => "ok"
        },
        lifecycle: "audit",
        links: [link("follows", @dry_run_receipt.fetch("id")), link("preserves", @rollup.fetch("obs_id"))]
      )
    ensure
      @boundary_state = "retained" if @rollup && @dry_run_receipt
    end

    def decimal_pressure_observation
      total = BigDecimal("0.10") + BigDecimal("0.20")
      obs(
        kind: "platform_observation",
        subject: "decimal_pressure/lead_bid/0_10_plus_0_20",
        payload: {
          "kind" => "DecimalExactnessProof",
          "operands" => [decimal("0.10"), decimal("0.20")],
          "operator" => "stdlib.decimal.add",
          "result" => decimal(format("%.2f", total)),
          "float_result_forbidden" => true
        },
        lifecycle: "session",
        links: [link("observed_under", RUNTIME_REF)]
      )
    end

    def result(case_name)
      {
        "case" => case_name,
        "admitted" => Canonical.normalize(@admitted),
        "admitted_count" => @admitted.length,
        "idempotency_keys" => @idempotency_index.keys.sort,
        "boundary_state" => @boundary_state,
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
        "duplicate" => Proof.duplicate,
        "decimal_drift" => Proof.decimal_drift,
        "late_boundary" => Proof.late_boundary,
        "retention_before_coverage" => Proof.retention_before_coverage
      }
      checks = [
        check("positive.admitted_signal_count", positive_admitted_count?(results.fetch("positive"))),
        check("positive.rollup_counts", rollup_counts?(results.fetch("positive").fetch("rollup"))),
        check("positive.decimal_totals_exact", decimal_totals_exact?(results.fetch("positive"))),
        check("positive.idempotency_evidence", idempotency_evidence?(results.fetch("positive"))),
        check("positive.retention_receipts", retention_receipts?(results.fetch("positive"))),
        check("duplicate.non_admission", duplicate_non_admission?(results.fetch("duplicate"))),
        check("duplicate.rollup_unchanged", unchanged_rollup?(results.fetch("duplicate"))),
        check("decimal.drift_blocked", decimal_drift_blocked?(results.fetch("decimal_drift"))),
        check("decimal.no_float_drift", decimal_pressure_exact?(results.fetch("decimal_drift"))),
        check("late.closed_boundary_blocked", late_boundary_blocked?(results.fetch("late_boundary"))),
        check("late.rollup_unchanged", unchanged_rollup?(results.fetch("late_boundary"))),
        check("retention.coverage_required", retention_coverage_required?(results.fetch("retention_before_coverage"))),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def positive_admitted_count?(result)
      result.fetch("admitted_count") == 3 &&
        lead_signal_observations(result).length == 3
    end

    def rollup_counts?(rollup)
      metrics = rollup.fetch("metrics")
      metrics.fetch("accepted_count") == 2 &&
        metrics.fetch("rejected_count") == 1 &&
        metrics.fetch("total_count") == 3
    end

    def decimal_totals_exact?(result)
      metrics = result.fetch("rollup").fetch("metrics")
      metrics.fetch("accepted_bid_amount") == decimal("205.75") &&
        metrics.fetch("rejected_bid_amount") == decimal("0.00") &&
        metrics.fetch("total_bid_amount") == decimal("205.75")
    end

    def idempotency_evidence?(result)
      result.fetch("idempotency_keys").length == 3 &&
        result.fetch("idempotency_keys").all? { |key| key.start_with?("idem/sha256/") } &&
        result.fetch("observations").count do |obs|
          obs.fetch("payload").fetch("kind", nil) == "IdempotencyKeyObservation"
        end == 3
    end

    def retention_receipts?(result)
      dry_run = result.fetch("dry_run_retention_receipt").fetch("payload")
      execute = result.fetch("execution_retention_receipt").fetch("payload")
      dry_run.fetch("mode") == "dry_run" &&
        dry_run.fetch("candidate_count") == 3 &&
        execute.fetch("mode") == "execute" &&
        execute.fetch("deleted_raw_payload_count") == 3 &&
        execute.fetch("rollup_preserved") == true &&
        execute.fetch("preserved_refs").include?(ROLLUP_ID)
    end

    def duplicate_non_admission?(result)
      receipt = result.fetch("duplicate_receipt").fetch("payload")
      receipt.fetch("status") == "duplicate_suppressed" &&
        receipt.fetch("decision") == "non_admission" &&
        receipt.fetch("diagnostic") == "lead_signal.duplicate_idempotency_key" &&
        receipt.fetch("rollup_changed") == false &&
        lead_signal_observations(result).length == 3
    end

    def unchanged_rollup?(result)
      result.fetch("rollup_before_hash") == result.fetch("rollup_after_hash")
    end

    def decimal_drift_blocked?(result)
      receipt = result.fetch("decimal_drift_receipt").fetch("payload")
      result.fetch("admitted_count").zero? &&
        result.fetch("rollup").nil? &&
        receipt.fetch("status") == "blocked" &&
        receipt.fetch("diagnostic") == "lead_signal.bid_decimal_invalid" &&
        receipt.fetch("rollup_changed") == false
    end

    def decimal_pressure_exact?(result)
      result.fetch("decimal_pressure").fetch("payload").fetch("result") == decimal("0.30")
    end

    def late_boundary_blocked?(result)
      receipt = result.fetch("late_receipt").fetch("payload")
      receipt.fetch("status") == "blocked" &&
        receipt.fetch("diagnostic") == "lead_signal.late_boundary_reopen_required" &&
        receipt.fetch("rollup_changed") == false
    end

    def retention_coverage_required?(result)
      receipt = result.fetch("retention_receipt").fetch("payload")
      receipt.fetch("status") == "blocked" &&
        receipt.fetch("diagnostic") == "retention.boundary_coverage_missing" &&
        receipt.fetch("deleted_raw_payload_count").zero?
    end

    def lead_signal_observations(result)
      result.fetch("observations").select do |obs|
        obs.fetch("kind") == "fact_observation" &&
          obs.fetch("payload").fetch("kind", nil) == "LeadSignalObservation"
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

    def decimal(value)
      { "kind" => "Decimal", "value" => value, "scale" => 2, "currency" => "USD" }
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
      puts "#{ok ? "PASS" : "FAIL"} spark_lead_signal_boundary_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      metrics = positive.fetch("rollup").fetch("metrics")
      puts "positive.rollup: accepted=#{metrics.fetch("accepted_count")} rejected=#{metrics.fetch("rejected_count")} total_bid=#{metrics.fetch("total_bid_amount").fetch("value")}"
      duplicate = result.fetch("results").fetch("duplicate").fetch("duplicate_receipt").fetch("payload")
      puts "duplicate: #{duplicate.fetch("status")} diagnostic=#{duplicate.fetch("diagnostic")}"
      late = result.fetch("results").fetch("late_boundary").fetch("late_receipt").fetch("payload")
      puts "late_boundary: #{late.fetch("status")} diagnostic=#{late.fetch("diagnostic")}"
      retention = result.fetch("results").fetch("retention_before_coverage").fetch("retention_receipt").fetch("payload")
      puts "retention_before_coverage: #{retention.fetch("status")} diagnostic=#{retention.fetch("diagnostic")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = SparkLeadSignalBoundaryFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end

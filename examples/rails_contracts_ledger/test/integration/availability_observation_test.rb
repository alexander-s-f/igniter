# frozen_string_literal: true

require "test_helper"

class AvailabilityObservationTest < ActionDispatch::IntegrationTest
  test "records a redacted observed-service receipt and exposes it by observation id" do
    get availability_path, params: {
      request_ref: "req-001",
      company_ref: "company-alpha",
      service_area_ref: "area-north",
      trade_ref: "hvac",
      window_ref: "2026-05-20-am",
      raw_customer_payload: "must-not-appear",
      provider_token: "secret-token"
    }

    assert_response :success
    body = JSON.parse(response.body)
    observation_id = body.fetch("observation_id")

    get observation_path(observation_id)

    assert_response :success
    receipt_body = JSON.parse(response.body)
    observation = receipt_body.fetch("observation")

    assert_equal "contractable_observation", observation.fetch("receipt_kind")
    assert_equal "availability_slot_map", observation.fetch("name")
    assert_equal "observed_service", observation.fetch("role")
    assert_equal "observe", observation.fetch("mode")
    assert_equal "ok", observation.fetch("status")
    assert_equal "only", observation.fetch("redaction").fetch("input_policy")

    inputs = observation.fetch("inputs")
    assert_equal "req-001", inputs.fetch("request_ref")
    assert_equal "company-alpha", inputs.fetch("company_ref")
    refute_includes inputs.keys, "raw_customer_payload"
    refute_includes inputs.keys, "provider_token"

    outputs = observation.fetch("primary").fetch("outputs")
    assert_includes outputs.keys, "input_digest"
    assert_includes outputs.keys, "output_digest"
    assert_includes outputs.keys, "reason_codes"

    event_names = receipt_body.fetch("events").map { |event| event.fetch("event") }
    assert_includes event_names, "primary_success"
    assert_includes event_names, "observation"
  end
end

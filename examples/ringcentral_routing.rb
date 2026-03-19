# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "pp"

class InboundCallContract < Igniter::Contract
  define do
    input :session_id, type: :string
    input :direction, type: :string
    input :from, type: :string
    input :to, type: :string
    input :start_time, type: :string

    compute :summary, with: %i[session_id from to start_time] do |session_id:, from:, to:, start_time:|
      {
        session_id: session_id,
        direction: "Inbound",
        customer_phone: from,
        lookup_phone: from,
        dialed_phone: to,
        started_at: start_time
      }
    end

    output :summary
  end
end

class OutboundCallContract < Igniter::Contract
  define do
    input :session_id, type: :string
    input :direction, type: :string
    input :from, type: :string
    input :to, type: :string
    input :start_time, type: :string

    compute :summary, with: %i[session_id from to start_time] do |session_id:, from:, to:, start_time:|
      {
        session_id: session_id,
        direction: "Outbound",
        customer_phone: to,
        lookup_phone: to,
        operator_phone: from,
        started_at: start_time
      }
    end

    output :summary
  end
end

class UnknownDirectionContract < Igniter::Contract
  define do
    input :session_id, type: :string
    input :direction, type: :string
    input :from, type: :string
    input :to, type: :string
    input :start_time, type: :string

    compute :summary, with: %i[session_id direction] do |session_id:, direction:|
      {
        session_id: session_id,
        direction: direction,
        ignored: true
      }
    end

    output :summary
  end
end

class CallEventContract < Igniter::Contract
  define do
    input :session_id, type: :string
    input :direction, type: :string
    input :from, type: :string
    input :to, type: :string
    input :start_time, type: :string

    branch :call_context, with: :direction, inputs: {
      session_id: :session_id,
      direction: :direction,
      from: :from,
      to: :to,
      start_time: :start_time
    } do
      on "Inbound", contract: InboundCallContract
      on "Outbound", contract: OutboundCallContract
      default contract: UnknownDirectionContract
    end

    export :summary, from: :call_context
  end
end

class CallConnectedContract < Igniter::Contract
  define do
    input :extension_id, type: :integer
    input :active_calls, type: :array
    input :telephony_status, type: :string

    guard :has_calls, with: :active_calls, message: "No active calls" do |active_calls:|
      active_calls.any?
    end

    collection :calls,
      with: :active_calls,
      each: CallEventContract,
      key: :session_id,
      mode: :collect,
      map_inputs: lambda { |item:|
        {
          session_id: item.fetch("telephonySessionId"),
          direction: item.fetch("direction"),
          from: item.fetch("from"),
          to: item.fetch("to"),
          start_time: item.fetch("startTime")
        }
      }

    compute :call_summaries, with: :calls do |calls:|
      calls.successes.values.map { |item| item.result.summary }
    end

    aggregate :routing_summary, with: %i[calls call_summaries extension_id telephony_status has_calls] do |calls:, call_summaries:, extension_id:, telephony_status:, has_calls:|
      has_calls
      {
        extension_id: extension_id,
        telephony_status: telephony_status,
        total_calls: calls.summary[:total],
        succeeded_calls: calls.summary[:succeeded],
        failed_calls: calls.summary[:failed],
        inbound_calls: call_summaries.count { |item| item[:direction] == "Inbound" },
        outbound_calls: call_summaries.count { |item| item[:direction] == "Outbound" },
        ignored_calls: call_summaries.count { |item| item[:ignored] }
      }
    end

    output :calls
    output :routing_summary
  end
end

class NoCallContract < Igniter::Contract
  define do
    input :extension_id, type: :integer
    input :telephony_status, type: :string
    input :active_calls, type: :array

    compute :routing_summary, with: %i[extension_id telephony_status] do |extension_id:, telephony_status:|
      {
        extension_id: extension_id,
        telephony_status: telephony_status,
        clear_operator: true
      }
    end

    output :routing_summary
  end
end

class RingingContract < Igniter::Contract
  define do
    input :extension_id, type: :integer
    input :telephony_status, type: :string
    input :active_calls, type: :array

    compute :routing_summary, with: %i[extension_id telephony_status] do |extension_id:, telephony_status:|
      {
        extension_id: extension_id,
        telephony_status: telephony_status,
        ringing: true
      }
    end

    output :routing_summary
  end
end

class UnknownStatusContract < Igniter::Contract
  define do
    input :extension_id, type: :integer
    input :telephony_status, type: :string
    input :active_calls, type: :array

    compute :routing_summary, with: %i[extension_id telephony_status] do |extension_id:, telephony_status:|
      {
        extension_id: extension_id,
        telephony_status: telephony_status,
        ignored_status: true
      }
    end

    output :routing_summary
  end
end

class RingcentralWebhookContract < Igniter::Contract
  define do
    input :payload

    scope :parse do
      project :body, from: :payload, key: :body, default: {}
      project :telephony_status, from: :body, key: "telephonyStatus"
      project :extension_id, from: :body, key: "extensionId"
      project :active_calls, from: :body, key: "activeCalls", default: []
    end

    branch :status_route, with: :telephony_status, inputs: {
      extension_id: :extension_id,
      telephony_status: :telephony_status,
      active_calls: :active_calls
    } do
      on "CallConnected", contract: CallConnectedContract
      on "NoCall", contract: NoCallContract
      on "Ringing", contract: RingingContract
      default contract: UnknownStatusContract
    end

    export :routing_summary, from: :status_route
    output :status_route
  end
end

payload = {
  "body" => {
    "extensionId" => 62872332031,
    "telephonyStatus" => "CallConnected",
    "activeCalls" => [
      {
        "from" => "+18009066027",
        "to" => "+16199627154",
        "direction" => "Outbound",
        "startTime" => "2024-04-01T16:18:13.553Z",
        "telephonySessionId" => "s-outbound-1"
      },
      {
        "from" => "+13125550100",
        "to" => "+18009066027",
        "direction" => "Inbound",
        "startTime" => "2024-04-01T16:19:10.000Z",
        "telephonySessionId" => "s-inbound-2"
      },
      {
        "from" => "+13125550199",
        "to" => "+18009066027",
        "direction" => "Parked",
        "startTime" => "2024-04-01T16:20:00.000Z",
        "telephonySessionId" => "s-unknown-3"
      }
    ]
  }
}

contract = RingcentralWebhookContract.new(payload: payload)

puts contract.explain_plan
puts "---"
puts "routing_summary=#{contract.result.routing_summary.inspect}"
puts "status_route_branch=#{contract.events.find { |event| event.type == :branch_selected }.payload[:matched_case]}"
puts "child_collection_summary=#{contract.result.status_route.calls.summary.inspect}"
puts "child_diagnostics_status=#{contract.result.status_route.execution.diagnostics.to_h[:status]}"
pp contract.result.status_route.calls.as_json

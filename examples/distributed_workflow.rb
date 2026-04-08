# frozen_string_literal: true

$LOAD_PATH.unshift File.join(__dir__, "../lib")
require "igniter"

store = Igniter::Runtime::Stores::MemoryStore.new

class LeadWorkflow < Igniter::Contract
  correlate_by :request_id, :company_id

  define do
    input :request_id
    input :company_id

    await :crm_data, event: :crm_webhook_received
    await :billing_data, event: :billing_data_fetched

    aggregate :report, with: %i[crm_data billing_data] do |crm_data:, billing_data:|
      { crm: crm_data, billing: billing_data }
    end

    output :report
  end
end

puts "==> Starting execution..."
execution = LeadWorkflow.start(
  { request_id: "req-1", company_id: "co-42" },
  store: store
)
puts "pending? #{execution.pending?}"

puts "\n==> Delivering CRM event..."
execution = LeadWorkflow.deliver_event(
  :crm_webhook_received,
  correlation: { request_id: "req-1", company_id: "co-42" },
  payload: { name: "Acme Corp", tier: "enterprise" },
  store: store
)
puts "still pending? #{execution.pending?}"

puts "\n==> Delivering billing event..."
execution = LeadWorkflow.deliver_event(
  :billing_data_fetched,
  correlation: { request_id: "req-1", company_id: "co-42" },
  payload: { plan: "pro", mrr: 500 },
  store: store
)

puts "\n==> Final result:"
puts "success? #{execution.success?}"
puts "report: #{execution.result.report.inspect}"

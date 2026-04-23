# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

class TechnicianAvailabilityContract < Igniter::Contract
  define do
    input :technician_id
    input :active

    guard :active_technician, with: :active, eq: true, message: "Technician inactive"

    compute :summary, with: %i[technician_id active_technician] do |technician_id:, active_technician:|
      active_technician
      { id: technician_id, status: "available" }
    end

    output :summary
  end
end

class TechnicianAvailabilityBatchContract < Igniter::Contract
  define do
    input :technician_inputs, type: :array

    collection :technicians,
      with: :technician_inputs,
      each: TechnicianAvailabilityContract,
      key: :technician_id,
      mode: :collect

    output :technicians
  end
end

contract = TechnicianAvailabilityBatchContract.new(
  technician_inputs: [
    { technician_id: 1, active: true },
    { technician_id: 2, active: false },
    { technician_id: 3, active: true }
  ]
)

result = contract.result.technicians

puts "summary=#{result.summary.inspect}"
puts "items_summary=#{result.items_summary.inspect}"
puts "failed_items=#{result.failed_items.inspect}"
puts "---"
puts contract.diagnostics_text

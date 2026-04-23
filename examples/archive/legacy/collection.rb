# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

class TechnicianContract < Igniter::Contract
  define do
    input :technician_id
    input :name

    compute :summary, with: %i[technician_id name] do |technician_id:, name:|
      { id: technician_id, name: name }
    end

    output :summary
  end
end

class TechnicianBatchContract < Igniter::Contract
  define do
    input :technician_inputs, type: :array

    collection :technicians,
      with: :technician_inputs,
      each: TechnicianContract,
      key: :technician_id,
      mode: :collect

    output :technicians
  end
end

contract = TechnicianBatchContract.new(
  technician_inputs: [
    { technician_id: 1, name: "Anna" },
    { technician_id: 2, name: "Mike" }
  ]
)

result = contract.result.technicians

puts "keys=#{result.keys.inspect}"
puts "items=#{result.to_h.inspect}"

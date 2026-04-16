# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe "Igniter diagnostics" do
  let(:contract_class) do
    Class.new(Igniter::Contract) do
      define do
        input :order_total
        input :country

        compute :vat_rate, depends_on: [:country] do |country:|
          country == "UA" ? 0.2 : 0.0
        end

        compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
          order_total * (1 + vat_rate)
        end

        output :gross_total
      end
    end
  end

  it "builds a structured diagnostics report" do
    contract = contract_class.new(order_total: 100, country: "UA")

    report = contract.diagnostics.to_h

    expect(report).to include(
      graph: "AnonymousContract",
      execution_id: contract.execution.events.execution_id,
      status: :succeeded,
      outputs: { gross_total: 120.0 }
    )
    expect(report[:nodes]).to include(total: 4, succeeded: 4, failed: 0, stale: 0)
    expect(report[:events]).to include(latest_type: :execution_finished)
  end

  it "formats diagnostics as text and markdown" do
    contract = contract_class.new(order_total: 100, country: "UA")

    text = contract.diagnostics_text
    markdown = contract.diagnostics_markdown

    expect(text).to include("Diagnostics AnonymousContract")
    expect(text).to include("Status: succeeded")
    expect(markdown).to include("# Diagnostics AnonymousContract")
    expect(markdown).to include("- Status: `succeeded`")
  end

  it "surfaces failed nodes in the diagnostics report" do
    failing_contract = Class.new(Igniter::Contract) do
      define do
        input :order_total

        compute :gross_total, depends_on: [:order_total] do |order_total:|
          raise "boom #{order_total}"
        end

        output :gross_total
      end
    end

    contract = failing_contract.new(order_total: 100)

    report = contract.diagnostics.to_h
    expect(report[:status]).to eq(:failed)
    expect(report[:nodes][:failed_nodes].first).to include(node_name: :gross_total)
    expect(report[:errors].first[:message]).to include("boom 100")
  end

  it "summarizes collection item failures in diagnostics" do
    child_contract = Class.new(Igniter::Contract) do
      define do
        input :technician_id

        guard :active_technician, with: :technician_id, message: "Technician inactive" do |technician_id:|
          technician_id != 2
        end

        compute :summary, with: %i[technician_id active_technician] do |technician_id:, active_technician:|
          active_technician
          { id: technician_id }
        end

        output :summary
      end
    end

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :technician_inputs, type: :array

        collection :technicians, with: :technician_inputs, each: child_contract, key: :technician_id, mode: :collect

        output :technicians
      end
    end

    contract = contract_class.new(technician_inputs: [
      { technician_id: 1 },
      { technician_id: 2 }
    ])

    report = contract.diagnostics.to_h
    text = contract.diagnostics_text
    markdown = contract.diagnostics_markdown

    expect(report[:status]).to eq(:succeeded)
    expect(report[:outputs][:technicians]).to include(
      mode: :collect,
      summary: include(total: 2, succeeded: 1, failed: 1, status: :partial_failure)
    )
    expect(report[:collection_nodes]).to include(
      include(
        node_name: :technicians,
        total: 2,
        succeeded: 1,
        failed: 1,
        status: :partial_failure,
        failed_items: [include(key: 2, message: include("Technician inactive"))]
      )
    )
    expect(text).to include("Collections: technicians total=2 succeeded=1 failed=1 status=partial_failure")
    expect(text).to include("failed_items=2(")
    expect(markdown).to include("## Collections")
    expect(markdown).to include("`technicians`: total=2, succeeded=1, failed=1, status=partial_failure")
    expect(markdown).to include("`technicians[2]` failed: Technician inactive")
  end

  it "formats nested result and collection outputs compactly in diagnostics text" do
    child_contract = Class.new(Igniter::Contract) do
      define do
        input :technician_inputs, type: :array

        collection :technicians, with: :technician_inputs, each: Class.new(Igniter::Contract) {
          define do
            input :technician_id

            compute :summary, with: :technician_id do |technician_id:|
              { id: technician_id }
            end

            output :summary
          end
        }, key: :technician_id, mode: :collect

        output :technicians
      end
    end

    parent_contract = Class.new(Igniter::Contract) do
      define do
        input :technician_inputs, type: :array

        compose :batch, contract: child_contract, inputs: {
          technician_inputs: :technician_inputs
        }

        output :batch
      end
    end

    contract = parent_contract.new(technician_inputs: [{ technician_id: 1 }, { technician_id: 2 }])

    text = contract.diagnostics_text
    markdown = contract.diagnostics_markdown

    expect(text).to include('batch={technicians: {mode=:collect, total=2, succeeded=2, failed=0, status=:succeeded, keys=[1, 2], failed_keys=[]}}')
    expect(markdown).to include("- Outputs: batch={technicians: {mode=:collect, total=2, succeeded=2, failed=0, status=:succeeded, keys=[1, 2], failed_keys=[]}}")
  end

  it "supports output presenters for compact diagnostics formatting" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :rows, type: :array
        output :rows
      end

      present :rows do |value:, **|
        {
          total: value.size,
          company_ids: value.map { |row| row[:company_id] }.uniq
        }
      end
    end

    contract = contract_class.new(rows: [
      { company_id: "1", location_id: "746" },
      { company_id: "2", location_id: "1666" }
    ])

    report = contract.diagnostics.to_h
    text = contract.diagnostics_text
    markdown = contract.diagnostics_markdown

    expect(report[:outputs][:rows]).to eq([
      { company_id: "1", location_id: "746" },
      { company_id: "2", location_id: "1666" }
    ])
    expect(text).to include('rows={total: 2, company_ids: ["1", "2"]}')
    expect(markdown).to include('- Outputs: rows={total: 2, company_ids: ["1", "2"]}')
  end

  describe "distributed routing traces" do
    let(:pending_trace) do
      {
        routing_mode: :capability,
        query: { all_of: [:orders], tags: [:linux] },
        selected_url: nil,
        eligible_count: 0,
        peers: [
          { name: "orders-linux", reasons: [:unreachable] }
        ]
      }
    end

    let(:failed_trace) do
      {
        routing_mode: :pinned,
        peer_name: "audit-node",
        known: true,
        selected_url: "http://audit:4567",
        reachable: false,
        reasons: [:unreachable]
      }
    end

    let(:pending_adapter) do
      trace = pending_trace
      Class.new do
        define_method(:initialize) { |routing_trace| @routing_trace = routing_trace }

        define_method(:call) do |node:, **|
          raise Igniter::Cluster::Mesh::DeferredCapabilityError.new(
            :orders,
            Igniter::Runtime::DeferredResult.build(
              token: "route-order-42",
              payload: { query: { all_of: [:orders] } },
              source_node: node.name,
              waiting_on: node.name
            ),
            query: { all_of: [:orders] },
            explanation: @routing_trace
          )
        end
      end.new(trace)
    end

    let(:failed_adapter) do
      trace = failed_trace
      Class.new do
        define_method(:initialize) { |routing_trace| @routing_trace = routing_trace }

        define_method(:call) do |**|
          raise Igniter::ResolutionError.new(
            "Pinned peer is unreachable",
            context: { routing_trace: @routing_trace }
          )
        end
      end.new(trace)
    end

    let(:pending_contract_class) do
      adapter = pending_adapter
      Class.new(Igniter::Contract) do
        runner :inline, remote_adapter: adapter

        define do
          input :order_id
          remote :order_result, contract: "ProcessOrder", node: "http://unused.example", inputs: { id: :order_id }
          output :order_result
        end
      end
    end

    let(:failed_contract_class) do
      adapter = failed_adapter
      Class.new(Igniter::Contract) do
        runner :inline, remote_adapter: adapter

        define do
          input :event
          remote :audit_result, contract: "WriteAudit", node: "http://unused.example", inputs: { event: :event }
          output :audit_result
        end
      end
    end

    it "surfaces routing traces for pending remote outputs in diagnostics" do
      contract = pending_contract_class.new(order_id: 42)

      report = contract.diagnostics.to_h
      text = contract.diagnostics_text
      markdown = contract.diagnostics_markdown

      expect(report[:status]).to eq(:pending)
      expect(report[:outputs][:order_result]).to include(
        token: "route-order-42",
        routing_trace: pending_trace,
        routing_trace_summary: "mode=capability query={:all_of=>[:orders], :tags=>[:linux]} eligible=0 selected=none reasons=unreachable"
      )
      expect(text).to include("routing=mode=capability query={:all_of=>[:orders], :tags=>[:linux]} eligible=0 selected=none reasons=unreachable")
      expect(markdown).to include("routing=mode=capability query={:all_of=>[:orders], :tags=>[:linux]} eligible=0 selected=none reasons=unreachable")
    end

    it "surfaces routing traces for failed remote outputs in diagnostics" do
      contract = failed_contract_class.new(event: "created")

      report = contract.diagnostics.to_h
      text = contract.diagnostics_text
      markdown = contract.diagnostics_markdown

      expect(report[:status]).to eq(:failed)
      expect(report[:outputs][:audit_result]).to include(
        status: :failed,
        routing_trace: failed_trace,
        routing_trace_summary: "mode=pinned peer=audit-node selected=http://audit:4567 reachable=false reasons=unreachable"
      )
      expect(report[:outputs][:audit_result][:error]).to include("Pinned peer is unreachable")
      expect(report[:errors].first).to include(
        node_name: :audit_result,
        routing_trace: failed_trace,
        routing_trace_summary: "mode=pinned peer=audit-node selected=http://audit:4567 reachable=false reasons=unreachable"
      )
      expect(text).to include("audit_result=Igniter::ResolutionError[mode=pinned peer=audit-node selected=http://audit:4567 reachable=false reasons=unreachable]")
      expect(markdown).to include("`mode=pinned peer=audit-node selected=http://audit:4567 reachable=false reasons=unreachable`")
    end
  end
end

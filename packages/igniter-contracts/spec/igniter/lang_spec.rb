# frozen_string_literal: true

require_relative "../spec_helper"
require "igniter/lang"

RSpec.describe Igniter::Lang do
  it "loads the additive lang entrypoint without changing contracts execution" do
    backend = described_class.ruby_backend
    compiled = backend.compile do
      input :amount
      output :amount
    end

    result = backend.execute(compiled, inputs: { amount: 42 })

    expect(result.output(:amount)).to eq(42)
  end

  it "builds immutable serializable type descriptors" do
    history = described_class::History[String]
    bi_history = described_class::BiHistory[Integer]
    olap_point = described_class::OLAPPoint[Numeric, { region: String, month: String }]
    forecast = described_class::Forecast[Float]

    expect(history).to be_frozen
    expect(history.to_h).to eq(kind: :history, of: "String", dimensions: {}, metadata: {})
    expect(bi_history.to_h).to include(kind: :bi_history, of: "Integer")
    expect(olap_point.to_h).to eq(
      kind: :olap_point,
      of: "Numeric",
      dimensions: { region: "String", month: "String" },
      metadata: {}
    )
    expect(forecast.to_h).to include(kind: :forecast, of: "Float")
  end

  it "preserves descriptors as operation metadata and reports them through verification" do
    backend = described_class.ruby_backend
    price_history = described_class::History[Numeric]
    report = backend.verify do
      input :price_history, type: price_history

      compute :latest_price, depends_on: [:price_history], type: Numeric do |price_history:|
        price_history.fetch(:latest)
      end

      output :latest_price
    end

    expect(report).to be_ok
    expect(report.descriptors).to eq([
                                       {
                                         node: :price_history,
                                         kind: :input,
                                         type: {
                                           kind: :history,
                                           of: "Numeric",
                                           dimensions: {},
                                           metadata: {}
                                         }
                                       }
                                     ])
    expect(report.to_h.fetch(:descriptors)).to eq(report.descriptors)
  end

  it "turns current compilation findings into a read-only verification report" do
    backend = described_class.ruby_backend
    report = backend.verify do
      input :amount
      compute :tax, depends_on: [:missing_amount] do |missing_amount:|
        missing_amount * 0.2
      end
      output :tax
    end

    expect(report).to be_invalid
    expect(report.findings.first.fetch(:code)).to eq(:missing_compute_dependencies)
    expect(report.to_h.fetch(:ok)).to eq(false)
  end
end

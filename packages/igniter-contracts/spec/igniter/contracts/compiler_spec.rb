# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Compiler do
  it "rejects duplicate non-output node names" do
    expect do
      Igniter::Contracts.compile do
        input :amount
        compute :amount, depends_on: [:amount] do |amount:|
          amount
        end
      end
    end.to raise_error(Igniter::Contracts::ValidationError, /duplicate node names: amount/)
  end

  it "rejects outputs that point at undefined nodes" do
    expect do
      Igniter::Contracts.compile do
        output :missing_total
      end
    end.to raise_error(Igniter::Contracts::ValidationError, /output targets are not defined: missing_total/)
  end

  it "exposes structured validation findings on compiler errors" do
    expect do
      Igniter::Contracts.compile do
        output :missing_total
      end
    end.to raise_error(Igniter::Contracts::ValidationError) { |error|
      expect(error.findings.map(&:code)).to eq([:missing_output_targets])
      expect(error.findings.first.subjects).to eq([:missing_total])
    }
  end

  it "rejects compute dependencies that are not defined" do
    expect do
      Igniter::Contracts.compile do
        compute :tax, depends_on: [:amount] do |amount:|
          amount * 0.2
        end
        output :tax
      end
    end.to raise_error(Igniter::Contracts::ValidationError, /compute dependencies are not defined: amount/)
  end

  it "normalizes dependency names through the baseline normalizer seam" do
    compiled = Igniter::Contracts.compile do
      input :amount
      compute :tax, depends_on: ["amount"] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    expect(compiled.operations[1].attributes[:depends_on]).to eq([:amount])
  end

  it "builds a structured validation report without raising" do
    report = Igniter::Contracts.validation_report do
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :missing_total
    end

    expect(report).to be_a(Igniter::Contracts::ValidationReport)
    expect(report).to be_invalid
    expect(report.findings.map(&:code)).to eq(%i[missing_output_targets missing_compute_dependencies])
  end

  it "builds a compilation report with normalized operations and compiled graph on success" do
    report = Igniter::Contracts.compilation_report do
      input :amount
      compute :tax, depends_on: ["amount"] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    expect(report).to be_a(Igniter::Contracts::CompilationReport)
    expect(report).to be_ok
    expect(report.operations[1].attributes[:depends_on]).to eq([:amount])
    expect(report.compiled_graph).to be_a(Igniter::Contracts::CompiledGraph)
  end

  it "rejects baseline node kinds that do not have runtime semantics yet" do
    expect do
      Igniter::Contracts.compile do
        input :amount
        branch :tax_logic, on: :amount
        output :amount
      end
    end.to raise_error(Igniter::Contracts::ValidationError, /baseline runtime does not support node kinds yet: branch/)
  end

  it "rejects project nodes whose source is not defined" do
    profile = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ProjectPack).finalize

    expect do
      Igniter::Contracts.compile(profile: profile) do
        project :country, from: :pricing, key: :country
        output :country
      end
    end.to raise_error(Igniter::Contracts::ValidationError, /project sources are not defined: pricing/)
  end
end

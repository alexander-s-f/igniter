# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Igniter::Contracts assembly/execution boundaries" do
  CONTRACTS_ROOT = File.expand_path("../../../lib/igniter/contracts", __dir__)

  ASSEMBLY_ALLOWED_EXECUTION_REFERENCES = {
    "assembly/baseline_pack.rb" => %w[
      Execution::BaselineNormalizers
      Execution::BaselineRuntime
      Execution::BaselineValidators
      Execution::InlineExecutor
    ],
    "assembly/const_pack.rb" => %w[
      Execution::ConstRuntime
    ],
    "assembly/project_pack.rb" => %w[
      Execution::ProjectRuntime
      Execution::ProjectValidators
    ],
    "assembly/hook_result_policies.rb" => %w[
      Execution::ExecutionResult
      Execution::Operation
      Execution::ValidationFinding
    ]
  }.freeze

  EXECUTION_ALLOWED_ASSEMBLY_REFERENCES = {
    "execution/compiler.rb" => %w[
      Assembly::HookSpecs
    ]
  }.freeze

  def read_contract_file(relative_path)
    File.read(File.join(CONTRACTS_ROOT, relative_path))
  end

  def namespace_references(relative_path, namespace)
    read_contract_file(relative_path)
      .scan(/\b#{Regexp.escape(namespace)}::[A-Za-z0-9_:]+/)
      .uniq
      .sort
  end

  it "keeps core Assembly infrastructure free from Execution implementation references" do
    assembly_files = Dir.glob(File.join(CONTRACTS_ROOT, "assembly/*.rb"))
                        .map { |path| path.delete_prefix("#{CONTRACTS_ROOT}/") }
                        .sort

    core_files = assembly_files.reject { |relative_path| ASSEMBLY_ALLOWED_EXECUTION_REFERENCES.key?(relative_path) }

    core_files.each do |relative_path|
      expect(namespace_references(relative_path, "Execution")).to eq([]), relative_path
    end
  end

  it "limits Assembly -> Execution references to explicit registration and contract files" do
    ASSEMBLY_ALLOWED_EXECUTION_REFERENCES.each do |relative_path, allowed_references|
      expect(namespace_references(relative_path, "Execution")).to eq(allowed_references.sort), relative_path
    end
  end

  it "keeps Execution free from Assembly mutation internals" do
    execution_files = Dir.glob(File.join(CONTRACTS_ROOT, "execution/*.rb"))
                         .map { |path| path.delete_prefix("#{CONTRACTS_ROOT}/") }
                         .sort

    execution_files.each do |relative_path|
      allowed_references = EXECUTION_ALLOWED_ASSEMBLY_REFERENCES.fetch(relative_path, [])
      expect(namespace_references(relative_path, "Assembly")).to eq(allowed_references.sort), relative_path
    end
  end
end

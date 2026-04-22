# frozen_string_literal: true

require_relative "contracts/errors"
require_relative "contracts/assembly"
require_relative "contracts/execution"

module Igniter
  module Contracts
    Registry = Assembly::Registry
    OrderedRegistry = Assembly::OrderedRegistry
    Pack = Assembly::Pack
    PackManifest = Assembly::PackManifest
    NodeType = Assembly::NodeType
    DslKeyword = Assembly::DslKeyword
    HookResultPolicies = Assembly::HookResultPolicies
    HookSpec = Assembly::HookSpec
    HookSpecs = Assembly::HookSpecs
    Profile = Assembly::Profile
    Kernel = Assembly::Kernel
    BaselinePack = Assembly::BaselinePack

    CompiledGraph = Execution::CompiledGraph
    Builder = Execution::Builder
    Compiler = Execution::Compiler
    ExecutionResult = Execution::ExecutionResult
    Runtime = Execution::Runtime
    DiagnosticsReport = Execution::DiagnosticsReport
    Diagnostics = Execution::Diagnostics
    BaselineNormalizers = Execution::BaselineNormalizers
    BaselineValidators = Execution::BaselineValidators
    BaselineRuntime = Execution::BaselineRuntime
  end
end

require_relative "contracts/const_pack"
require_relative "contracts/project_pack"
require_relative "contracts/api"

# frozen_string_literal: true

require "igniter/contracts"
require_relative "contracts/aggregate_pack"
require_relative "contracts/audit_pack"
require_relative "contracts/commerce_pack"
require_relative "contracts/creator_pack"
require_relative "contracts/dataflow_pack"
require_relative "contracts/debug_pack"
require_relative "contracts/differential_pack"
require_relative "contracts/execution_report_pack"
require_relative "contracts/incremental_pack"
require_relative "contracts/journal_pack"
require_relative "contracts/lookup_pack"
require_relative "contracts/mcp_pack"
require_relative "contracts/provenance_pack"
require_relative "contracts/reactive_pack"
require_relative "contracts/saga_pack"

module Igniter
  module Extensions
    module Contracts
      DEFAULT_PACKS = [
        ExecutionReportPack,
        LookupPack
      ].freeze

      AVAILABLE_PACKS = (
        DEFAULT_PACKS +
        [AggregatePack, AuditPack, CommercePack, CreatorPack, DataflowPack, DebugPack, DifferentialPack, IncrementalPack, JournalPack, McpPack, ProvenancePack, ReactivePack, SagaPack]
      ).freeze

      PRESETS = {
        default: DEFAULT_PACKS,
        commerce: [ExecutionReportPack, CommercePack]
      }.freeze

      class << self
        def default_packs
          DEFAULT_PACKS
        end

        def available_packs
          AVAILABLE_PACKS
        end

        def presets
          PRESETS
        end

        def packs_for(name)
          presets.fetch(name.to_sym)
        rescue KeyError
          raise ArgumentError, "unknown contracts preset #{name}"
        end

        def build_profile(*packs)
          Igniter::Contracts.build_profile(*normalize_packs(packs))
        end

        def with(*packs)
          Igniter::Contracts.with(*normalize_packs(packs))
        end

        def build_preset_profile(name)
          build_profile(*packs_for(name))
        end

        def with_preset(name)
          with(*packs_for(name))
        end

        def lineage(result, output_name)
          ProvenancePack.lineage(result, output_name)
        end

        def explain(result, output_name)
          ProvenancePack.explain(result, output_name)
        end

        def build_compensations(&block)
          SagaPack.build(&block)
        end

        def run_saga(environment, inputs:, compensations:, compiled_graph: nil, &block)
          SagaPack.run(
            environment,
            inputs: inputs,
            compensations: compensations,
            compiled_graph: compiled_graph,
            &block
          )
        end

        def build_incremental_session(environment, compiled_graph: nil, &block)
          IncrementalPack.session(environment, compiled_graph: compiled_graph, &block)
        end

        def build_dataflow_session(environment, source:, key:, window: nil, context: [], &block)
          DataflowPack.session(
            environment,
            source: source,
            key: key,
            window: window,
            context: context,
            &block
          )
        end

        def compare_differential( # rubocop:disable Metrics/ParameterLists
          inputs:,
          primary_environment: nil,
          primary_compiled_graph: nil,
          primary_result: nil,
          candidate_environment: nil,
          candidate_compiled_graph: nil,
          candidate_result: nil,
          tolerance: nil,
          primary_name: "primary",
          candidate_name: "candidate"
        )
          DifferentialPack.compare(
            inputs: inputs,
            primary_environment: primary_environment,
            primary_compiled_graph: primary_compiled_graph,
            primary_result: primary_result,
            candidate_environment: candidate_environment,
            candidate_compiled_graph: candidate_compiled_graph,
            candidate_result: candidate_result,
            tolerance: tolerance,
            primary_name: primary_name,
            candidate_name: candidate_name
          )
        end

        def shadow_differential(**arguments)
          DifferentialPack.shadow(**arguments)
        end

        def audit_snapshot(result)
          AuditPack.snapshot(result)
        end

        def audit_report(environment, inputs: nil, compiled_graph: nil, &block)
          AuditPack.report(environment, inputs: inputs, compiled_graph: compiled_graph, &block)
        end

        def build_reactions(&block)
          ReactivePack.build(&block)
        end

        def dispatch_reactive(target, reactions:)
          ReactivePack.dispatch(target, reactions: reactions)
        end

        def run_reactive(environment, inputs:, reactions:, compiled_graph: nil, &block)
          ReactivePack.run(environment, inputs: inputs, reactions: reactions, compiled_graph: compiled_graph, &block)
        end

        def run_incremental_reactive(session, inputs:, reactions:)
          ReactivePack.run_incremental(session, inputs: inputs, reactions: reactions)
        end

        def debug_profile(target)
          profile = target.respond_to?(:profile) ? target.profile : target
          DebugPack.profile_snapshot(profile)
        end

        def debug_pack(pack_or_name, target)
          profile = target.respond_to?(:profile) ? target.profile : target
          DebugPack.pack_snapshot(pack_or_name, profile: profile)
        end

        def audit_pack(pack, target = nil)
          profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          DebugPack.audit(pack, profile: profile)
        end

        def creator_profiles
          CreatorPack.available_profiles
        end

        def creator_scopes
          CreatorPack.available_scopes
        end

        def scaffold_pack(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: :monorepo_package)
          CreatorPack.scaffold(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope
          )
        end

        def creator_report(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: :monorepo_package, pack: nil, target: nil)
          runtime_profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          CreatorPack.report(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope,
            pack: pack,
            target_profile: runtime_profile
          )
        end

        def creator_workflow(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: :monorepo_package, pack: nil, target: nil)
          runtime_profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          CreatorPack.workflow(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope,
            pack: pack,
            target_profile: runtime_profile
          )
        end

        def creator_wizard(name: nil, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: nil, root: nil, mode: :skip_existing, pack: nil, target: nil)
          runtime_profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          CreatorPack.wizard(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope,
            root: root,
            mode: mode,
            pack: pack,
            target_profile: runtime_profile
          )
        end

        def creator_writer(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: :monorepo_package, pack: nil, target: nil, root:, mode: :skip_existing)
          runtime_profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          CreatorPack.writer(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope,
            pack: pack,
            target_profile: runtime_profile,
            root: root,
            mode: mode
          )
        end

        def write_pack_scaffold(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: :monorepo_package, pack: nil, target: nil, root:, mode: :skip_existing)
          runtime_profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          CreatorPack.write(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities,
            scope: scope,
            pack: pack,
            target_profile: runtime_profile,
            root: root,
            mode: mode
          )
        end

        def mcp_tools
          McpPack.tool_catalog
        end

        def mcp_call(tool_name, target: nil, **arguments, &block)
          McpPack.call(tool_name, target: target, **arguments, &block)
        end

        def mcp_creator_session(target: nil, **arguments)
          mcp_call(:creator_session_start, target: target, **arguments)
        end

        def debug_snapshot(result, profile:)
          DebugPack.snapshot(result, profile: profile)
        end

        def debug_report(environment, inputs: nil, compiled_graph: nil, &block)
          DebugPack.report(environment, inputs: inputs, compiled_graph: compiled_graph, &block)
        end

        private

        def normalize_packs(packs)
          normalized = packs.flatten.compact
          normalized.empty? ? default_packs : normalized
        end
      end
    end
  end
end

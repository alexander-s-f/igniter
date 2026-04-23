# frozen_string_literal: true

require_relative "mcp/tool_definition"
require_relative "mcp/tool_result"
require_relative "mcp/creator_session"

module Igniter
  module Extensions
    module Contracts
      module McpPack
        module_function

        TOOL_DEFINITIONS = [
          Mcp::ToolDefinition.new(name: :inspect_profile, summary: "Return a structured profile snapshot."),
          Mcp::ToolDefinition.new(name: :inspect_pack, summary: "Return a structured installed-pack snapshot."),
          Mcp::ToolDefinition.new(name: :audit_pack, summary: "Audit a custom pack against creator/debug quality seams."),
          Mcp::ToolDefinition.new(name: :debug_report, summary: "Compile or execute and return a structured debug report."),
          Mcp::ToolDefinition.new(name: :creator_wizard, summary: "Build a stateful creator wizard payload."),
          Mcp::ToolDefinition.new(name: :creator_session_start, summary: "Create a serialized creator session payload."),
          Mcp::ToolDefinition.new(name: :creator_session_apply, summary: "Apply updates to a serialized creator session payload."),
          Mcp::ToolDefinition.new(name: :creator_session_workflow, summary: "Build workflow payload from a serialized creator session."),
          Mcp::ToolDefinition.new(name: :creator_session_write_plan, summary: "Build writer plan payload from a serialized creator session."),
          Mcp::ToolDefinition.new(name: :creator_session_write, summary: "Write scaffold files from a serialized creator session.", mutating: true),
          Mcp::ToolDefinition.new(name: :creator_workflow, summary: "Build a creator workflow payload."),
          Mcp::ToolDefinition.new(name: :creator_write_plan, summary: "Build a creator writer plan payload."),
          Mcp::ToolDefinition.new(name: :creator_write, summary: "Write a creator scaffold to disk.", mutating: true)
        ].freeze

        def manifest
          Igniter::Contracts::PackManifest.new(
            name: :extensions_mcp,
            metadata: { category: :tooling }
          )
        end

        def install_into(kernel)
          install_dependency_pack(kernel, DebugPack)
          install_dependency_pack(kernel, CreatorPack)
          kernel
        end

        def tools
          TOOL_DEFINITIONS
        end

        def tool_catalog
          tools.map(&:to_h)
        end

        def call(tool_name, target: nil, **arguments, &block)
          definition = tool_definition(tool_name)
          payload = dispatch(definition.name, target: target, **arguments, &block)
          Mcp::ToolResult.new(
            tool_name: definition.name,
            payload: payload,
            mutating: definition.mutating
          )
        end

        def tool_definition(tool_name)
          tools.find { |definition| definition.name == tool_name.to_sym } ||
            raise(ArgumentError, "unknown MCP tool #{tool_name.inspect}")
        end

        def dispatch(tool_name, target: nil, **arguments, &block)
          case tool_name.to_sym
          when :inspect_profile
            profile_from(target).then { |profile| DebugPack.profile_snapshot(profile).to_h }
          when :inspect_pack
            profile = profile_from(target)
            DebugPack.pack_snapshot(arguments.fetch(:pack), profile: profile).to_h
          when :audit_pack
            DebugPack.audit(arguments.fetch(:pack), profile: profile_from(target, optional: true)).to_h
          when :debug_report
            environment = environment_from(target)
            DebugPack.report(
              environment,
              inputs: arguments[:inputs],
              compiled_graph: arguments[:compiled_graph],
              &block
            ).to_h
          when :creator_wizard
            CreatorPack.wizard(
              name: arguments[:name],
              kind: arguments[:kind],
              namespace: arguments.fetch(:namespace, "MyCompany::IgniterPacks"),
              profile: arguments[:profile],
              capabilities: arguments[:capabilities],
              scope: arguments[:scope],
              root: arguments[:root],
              mode: arguments.fetch(:mode, :skip_existing),
              pack: arguments[:pack],
              target_profile: profile_from(target, optional: true)
            ).to_h
          when :creator_session_start
            creator_session_from(arguments, target: target).to_h
          when :creator_session_apply
            session = session_from(arguments.fetch(:session) { arguments.fetch("session") }, target: target)
            session.apply(**symbolize_keys(arguments.fetch(:updates) { arguments.fetch("updates") })).to_h
          when :creator_session_workflow
            session_from(arguments.fetch(:session) { arguments.fetch("session") }, target: target).workflow_payload
          when :creator_session_write_plan
            session_from(arguments.fetch(:session) { arguments.fetch("session") }, target: target).write_plan_payload
          when :creator_session_write
            session_from(arguments.fetch(:session) { arguments.fetch("session") }, target: target).write_payload
          when :creator_workflow
            CreatorPack.workflow(
              name: arguments.fetch(:name),
              kind: arguments[:kind],
              namespace: arguments.fetch(:namespace, "MyCompany::IgniterPacks"),
              profile: arguments[:profile],
              capabilities: arguments[:capabilities],
              scope: arguments.fetch(:scope, :monorepo_package),
              pack: arguments[:pack],
              target_profile: profile_from(target, optional: true)
            ).to_h
          when :creator_write_plan
            CreatorPack.writer(
              name: arguments.fetch(:name),
              kind: arguments[:kind],
              namespace: arguments.fetch(:namespace, "MyCompany::IgniterPacks"),
              profile: arguments[:profile],
              capabilities: arguments[:capabilities],
              scope: arguments.fetch(:scope, :monorepo_package),
              pack: arguments[:pack],
              target_profile: profile_from(target, optional: true),
              root: arguments.fetch(:root),
              mode: arguments.fetch(:mode, :skip_existing)
            ).plan.to_h
          when :creator_write
            CreatorPack.write(
              name: arguments.fetch(:name),
              kind: arguments[:kind],
              namespace: arguments.fetch(:namespace, "MyCompany::IgniterPacks"),
              profile: arguments[:profile],
              capabilities: arguments[:capabilities],
              scope: arguments.fetch(:scope, :monorepo_package),
              pack: arguments[:pack],
              target_profile: profile_from(target, optional: true),
              root: arguments.fetch(:root),
              mode: arguments.fetch(:mode, :skip_existing)
            ).to_h
          else
            raise ArgumentError, "unsupported MCP tool #{tool_name.inspect}"
          end
        end

        def install_dependency_pack(kernel, pack)
          return if kernel.pack_manifests.any? { |manifest| manifest.name == pack.manifest.name }

          kernel.install(pack)
        end

        def profile_from(target, optional: false)
          profile =
            case target
            when nil
              nil
            else
              target.respond_to?(:profile) ? target.profile : target
            end

          return profile if optional || profile

          raise ArgumentError, "McpPack tool requires an environment or profile target"
        end

        def environment_from(target)
          return target if target.respond_to?(:profile) && target.respond_to?(:execute)

          raise ArgumentError, "McpPack debug_report requires an environment target"
        end

        def creator_session_from(arguments, target:)
          Mcp::CreatorSession.new(
            name: arguments[:name],
            kind: arguments[:kind],
            namespace: arguments.fetch(:namespace, "MyCompany::IgniterPacks"),
            profile: arguments[:profile],
            capabilities: arguments[:capabilities],
            scope: arguments[:scope],
            root: arguments[:root],
            mode: arguments.fetch(:mode, :skip_existing),
            pack: arguments[:pack],
            target_profile: profile_from(target, optional: true)
          )
        end

        def session_from(payload, target:)
          Mcp::CreatorSession.from_h(
            symbolize_keys(payload),
            target_profile: profile_from(target, optional: true)
          )
        end

        def symbolize_keys(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key.respond_to?(:to_sym) ? key.to_sym : key] = symbolize_keys(nested)
            end
          when Array
            value.map { |item| symbolize_keys(item) }
          else
            value
          end
        end
      end
    end
  end
end

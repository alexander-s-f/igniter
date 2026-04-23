# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module Creator
        class Wizard
          attr_reader :name, :kind, :namespace, :profile, :capabilities, :scope, :root, :mode, :pack, :target_profile

          def initialize(name: nil, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, scope: nil, root: nil, mode: :skip_existing, pack: nil, target_profile: nil)
            @name = normalize_name(name)
            @kind = kind&.to_sym
            @namespace = normalize_namespace(namespace)
            @profile = profile&.to_sym
            @capabilities = Array(capabilities).map(&:to_sym).uniq.freeze
            @scope = scope&.to_sym
            @root = root&.to_s
            @mode = mode.to_sym
            @pack = pack
            @target_profile = target_profile
            freeze
          end

          def apply(**updates)
            self.class.new(
              name: updates.fetch(:name, name),
              kind: updates.fetch(:kind, kind),
              namespace: updates.fetch(:namespace, namespace),
              profile: updates.fetch(:profile, profile),
              capabilities: updates.fetch(:capabilities, capabilities),
              scope: updates.fetch(:scope, scope),
              root: updates.fetch(:root, root),
              mode: updates.fetch(:mode, mode),
              pack: updates.fetch(:pack, pack),
              target_profile: updates.fetch(:target_profile, target_profile)
            )
          end

          def authoring_profile
            return nil unless profile || kind || !capabilities.empty?

            Profile.build(
              profile: profile,
              kind: kind,
              capabilities: capabilities
            )
          end

          def target_scope
            return nil unless scope

            Scope.build(scope)
          end

          def ready_for_workflow?
            !name.nil? && !authoring_profile.nil? && !target_scope.nil?
          end

          def ready_for_writer?
            ready_for_workflow? && !effective_root.nil?
          end

          def effective_root
            return root unless root.nil? || root.empty?
            return nil unless scope

            suggested_root
          end

          def suggested_root
            case scope
            when :standalone_gem
              name ? "./#{name}" : "./my_pack"
            when :app_local, :monorepo_package
              "."
            else
              nil
            end
          end

          def pending_decisions
            decisions = []
            unless name
              decisions << {
                key: :name,
                prompt: "Choose a short pack name",
                options: []
              }
            end

            unless authoring_profile
              decisions << {
                key: :profile,
                prompt: "Choose an authoring profile or provide capabilities",
                options: Profile.available
              }
            end

            unless target_scope
              decisions << {
                key: :scope,
                prompt: "Choose the target scope for the pack",
                options: Scope.available
              }
            end

            if ready_for_workflow? && root.nil?
              decisions << {
                key: :root,
                prompt: "Choose the filesystem root for generated files",
                options: [suggested_root].compact
              }
            end

            decisions
          end

          def current_decision
            pending_decisions.first
          end

          def workflow
            raise ArgumentError, "creator wizard is missing decisions: #{pending_decisions.map { |decision| decision.fetch(:key) }.join(', ')}" unless ready_for_workflow?

            CreatorPack.workflow(
              name: name,
              kind: kind,
              namespace: namespace,
              profile: profile,
              capabilities: capabilities,
              scope: scope,
              pack: pack,
              target_profile: target_profile
            )
          end

          def writer
            raise ArgumentError, "creator wizard needs a root before writing scaffold files" unless ready_for_writer?

            workflow.writer(root: effective_root, mode: mode)
          end

          def to_h
            {
              name: name,
              kind: kind,
              namespace: namespace,
              profile: profile,
              capabilities: capabilities,
              scope: scope,
              root: root,
              suggested_root: suggested_root,
              effective_root: effective_root,
              mode: mode,
              ready_for_workflow: ready_for_workflow?,
              ready_for_writer: ready_for_writer?,
              authoring_profile: authoring_profile&.to_h,
              target_scope: target_scope&.to_h,
              pending_decisions: pending_decisions
            }
          end

          private

          def normalize_name(value)
            return nil if value.nil?

            normalized = value.to_s.strip.gsub(/_pack\z/, "").downcase
            normalized.empty? ? nil : normalized
          end

          def normalize_namespace(value)
            normalized = value.to_s.strip
            normalized.empty? ? "MyCompany::IgniterPacks" : normalized
          end
        end
      end
    end
  end
end

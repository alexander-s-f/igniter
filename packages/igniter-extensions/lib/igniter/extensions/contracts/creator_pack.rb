# frozen_string_literal: true

require_relative "creator/profile"
require_relative "creator/scaffold"
require_relative "creator/report"

module Igniter
  module Extensions
    module Contracts
      module CreatorPack
        module_function

        def manifest
          Igniter::Contracts::PackManifest.new(
            name: :extensions_creator,
            metadata: { category: :developer }
          )
        end

        def install_into(kernel)
          install_dependency_pack(kernel, DebugPack)
          kernel
        end

        def available_profiles
          Creator::Profile.available
        end

        def scaffold(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil)
          authoring_profile = Creator::Profile.build(profile: profile, kind: kind, capabilities: capabilities)
          generated = Creator::Scaffold.new(
            name: name,
            kind: authoring_profile.kind,
            namespace: namespace,
            profile: authoring_profile
          )
          generated
        end

        def report(name:, kind: nil, namespace: "MyCompany::IgniterPacks", profile: nil, capabilities: nil, pack: nil, target_profile: nil)
          generated = scaffold(
            name: name,
            kind: kind,
            namespace: namespace,
            profile: profile,
            capabilities: capabilities
          )
          audit = pack ? DebugPack.audit(pack, profile: target_profile) : nil

          Creator::Report.new(scaffold: generated, audit: audit)
        end

        def install_dependency_pack(kernel, pack)
          return if kernel.pack_manifests.any? { |manifest| manifest.name == pack.manifest.name }

          kernel.install(pack)
        end
      end
    end
  end
end

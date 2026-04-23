# frozen_string_literal: true

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

        def scaffold(name:, kind: :feature, namespace: "MyCompany::IgniterPacks")
          Creator::Scaffold.new(name: name, kind: kind, namespace: namespace)
        end

        def report(name:, kind: :feature, namespace: "MyCompany::IgniterPacks", pack: nil, profile: nil)
          generated = scaffold(name: name, kind: kind, namespace: namespace)
          audit = pack ? DebugPack.audit(pack, profile: profile) : nil

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

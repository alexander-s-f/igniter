# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe "installed capsule registry" do
  it "records complete transfer receipts as installed capsule entries" do
    Dir.mktmpdir("igniter-installed-capsules") do |root|
      registry = Igniter::Application.file_backed_installed_capsule_registry(root: root)
      receipt = {
        complete: true,
        valid: true,
        committed: true,
        artifact_path: File.join(root, "bundle"),
        destination_root: File.join(root, "destination"),
        counts: { planned: 1, applied: 1, verified: 1, findings: 0, refusals: 0, skipped: 0, manual_actions: 0 },
        findings: [],
        refusals: [],
        skipped: []
      }

      entry = Igniter::Application.record_installed_capsule(
        :horoscope,
        receipt: receipt,
        registry: registry,
        source: "local-hub",
        version: "0.1.0",
        metadata: { audience: :companion }
      )

      expect(entry.to_h).to include(
        name: :horoscope,
        status: :installed,
        complete: true,
        valid: true,
        committed: true,
        source: "local-hub",
        version: "0.1.0"
      )
      expect(registry.installed?(:horoscope)).to be(true)
      expect(registry.fetch(:horoscope).metadata).to eq(audience: "companion")
      expect(registry.entries.map(&:name)).to eq([:horoscope])
    end
  end

  it "keeps incomplete transfer receipts visible as blocked entries" do
    Dir.mktmpdir("igniter-installed-capsules") do |root|
      registry = Igniter::Application.file_backed_installed_capsule_registry(root: root)

      entry = registry.record(
        :operator,
        receipt: {
          complete: false,
          valid: true,
          committed: true,
          manual_actions: [{ type: :confirm_provider }]
        }
      )

      expect(entry.status).to eq(:blocked)
      expect(entry.installed?).to be(false)
      expect(registry.installed?(:missing)).to be(false)
    end
  end
end
